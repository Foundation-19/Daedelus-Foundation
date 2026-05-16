// D-Class Escort and Restraint System
// Security personnel can handcuff D-Class and escort them between areas
// Escorts must stay close or D-Class can attempt to break free

/obj/item/restraints/handcuffs/foundation
	name = "Foundation restraints"
	desc = "Heavy-duty zip-tie restraints used for D-Class and prisoner transport."
	icon_state = "handcuff"
	breakouttime = 45 SECONDS

/obj/item/restraints/legcuffs/beartrap/foundation
	name = "Foundation leg irons"
	desc = "Steel leg restraints that severely limit movement speed."
	breakouttime = 60 SECONDS

/obj/item/storage/box/foundation_restraints
	name = "restraint kit"
	desc = "A box containing Foundation-standard restraints for D-Class transport."

/obj/item/storage/box/foundation_restraints/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/restraints/handcuffs/foundation(src)

/datum/movespeed_modifier/escorted
	id = "escorted"
	slowdown = 0.5
	variable = TRUE

/datum/dclass_restraint_tracker
	var/mob/living/carbon/human/dclass
	var/mob/living/carbon/human/escort
	var/escape_attempts = 0
	var/last_escape_attempt = 0
	var/escape_attempt_cooldown = 3 MINUTES

/datum/dclass_restraint_tracker/New(mob/living/carbon/human/new_dclass)
	dclass = new_dclass
	if(dclass)
		RegisterSignal(dclass, COMSIG_PARENT_QDELETING, PROC_REF(on_dclass_deleted))

/datum/dclass_restraint_tracker/Destroy()
	on_escort_lost()
	if(dclass)
		UnregisterSignal(dclass, COMSIG_PARENT_QDELETING)
	dclass = null
	return ..()

/datum/dclass_restraint_tracker/proc/on_dclass_deleted(datum/source)
	SIGNAL_HANDLER
	on_escort_lost()
	if(dclass)
		UnregisterSignal(dclass, COMSIG_PARENT_QDELETING)
	dclass = null

/datum/dclass_restraint_tracker/proc/set_escort(mob/living/carbon/human/new_escort)
	if(escort == new_escort)
		return
	if(escort)
		on_escort_lost()
	escort = new_escort
	if(escort)
		on_escort_gained()

/datum/dclass_restraint_tracker/proc/on_escort_gained()
	if(dclass)
		dclass.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/escorted, TRUE, 0.5)
	RegisterSignal(escort, COMSIG_PARENT_QDELETING, PROC_REF(on_escort_deleted))
	RegisterSignal(escort, COMSIG_LIVING_DEATH, PROC_REF(on_escort_death))

/datum/dclass_restraint_tracker/proc/on_escort_lost()
	if(dclass)
		dclass.remove_movespeed_modifier(/datum/movespeed_modifier/escorted)
	if(escort)
		UnregisterSignal(escort, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	escort = null

/datum/dclass_restraint_tracker/proc/on_escort_deleted(datum/source)
	SIGNAL_HANDLER
	on_escort_lost()

/datum/dclass_restraint_tracker/proc/on_escort_death(datum/source, gibbed)
	SIGNAL_HANDLER
	on_escort_lost()

/datum/dclass_restraint_tracker/proc/attempt_escape()
	if(QDELETED(dclass))
		return FALSE
	if(world.time < last_escape_attempt + escape_attempt_cooldown)
		return FALSE
	last_escape_attempt = world.time

	var/escape_chance = 15
	if(escort && get_dist(dclass, escort) > 3)
		escape_chance += 30
	if(dclass.health < dclass.maxHealth * 0.5)
		escape_chance -= 10

	if(prob(escape_chance))
		on_successful_escape()
		return TRUE
	else
		on_failed_escape()
		return FALSE

/datum/dclass_restraint_tracker/proc/on_successful_escape()
	if(QDELETED(dclass))
		return
	dclass.visible_message(span_danger("[dclass] breaks free from the restraints!"), span_notice("You break free from the restraints!"))
	if(dclass.handcuffed)
		dclass.dropItemToGround(dclass.handcuffed, force = TRUE)
	if(dclass.legcuffed)
		dclass.dropItemToGround(dclass.legcuffed, force = TRUE)
	on_escort_lost()

/datum/dclass_restraint_tracker/proc/on_failed_escape()
	if(QDELETED(dclass))
		return
	dclass.visible_message(span_warning("[dclass] struggles against the restraints but fails!"), span_warning("You fail to break free!"))
	if(escort)
		to_chat(escort, span_danger("[dclass] attempted to escape from restraints!"))
