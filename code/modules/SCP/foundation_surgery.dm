#define TRAIT_MEMETIC_SHIELDING "memetic_shielding"

/obj/item/implant/amnestic
	name = "amnestic implant"
	desc = "A subdermal implant that releases amnestic compounds on remote trigger."
	actions_types = list(/datum/action/item_action/trigger_amnestic)
	var/amnestic_class = "A"
	var/activated = FALSE

/obj/item/implant/amnestic/activate()
	if(activated)
		return
	activated = TRUE
	var/mob/living/carbon/human/H = imp_in
	if(!istype(H))
		return
	apply_amnestic_effects(H, amnestic_class)
	qdel(src)

/datum/action/item_action/trigger_amnestic
	name = "Trigger Amnestic Implant"

/obj/item/implantcase/amnestic
	name = "amnestic implant case"
	desc = "A glass case containing an amnestic implant."
	imp = /obj/item/implant/amnestic

/obj/item/implant/containment
	name = "containment tracking chip"
	desc = "A subdermal tracking chip used to monitor D-Class and SCP-exposed personnel."
	actions_types = list(/datum/action/item_action/track_containment_chip)

/obj/item/implantcase/containment
	name = "containment chip case"
	desc = "A glass case containing a containment tracking chip."
	imp = /obj/item/implant/containment

/datum/action/item_action/track_containment_chip
	name = "Track Containment Chip"

/datum/surgery_step/anomalous_purge
	name = "Purge Anomalous Influence"
	desc = "Surgically removes anomalous compulsion and influence from a patient's brain."
	surgery_flags = SURGERY_NEEDS_DEENCASEMENT
	allowed_tools = list(
		TOOL_HEMOSTAT = 85,
		TOOL_SCREWDRIVER = 35
	)
	var/purge_cooldown = 5 MINUTES
	var/static/list/purged_mobs = list()

/datum/surgery_step/anomalous_purge/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = ..()
	if(!affected)
		return
	if(affected.body_zone == BODY_ZONE_HEAD)
		return TRUE

/datum/surgery_step/anomalous_purge/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	var/obj/item/organ/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		to_chat(user, span_warning("[target] doesn't have a brain to operate on."))
		return FALSE
	if(locate(/datum/element/scp513_stalked) in target.status_effects)
		return TRUE
	if(target.mind?.has_antag_datum(/datum/antagonist/sarkic))
		return TRUE
	if(target.mind?.has_antag_datum(/datum/antagonist/chaos_insurgency))
		return TRUE
	if(target.mind?.has_antag_datum(/datum/antagonist/serpents_hand))
		return TRUE
	if(target.hallucination > 30)
		return TRUE
	to_chat(user, span_notice("[target] shows no signs of anomalous influence that can be surgically treated."))
	return TRUE

/datum/surgery_step/anomalous_purge/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	user.visible_message(span_notice("[user] begins carefully excising anomalous tissue from [target]'s brain."), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/anomalous_purge/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/purged_something = FALSE

	if(locate(/datum/element/scp513_stalked) in target.status_effects)
		target.RemoveElement(/datum/element/scp513_stalked)
		to_chat(target, span_notice("The watching presence fades from your mind."))
		purged_something = TRUE

	if(target.hallucination > 0)
		target.hallucination = max(0, target.hallucination - 50)
		purged_something = TRUE

	if(target.mind?.has_antag_datum(/datum/antagonist/sarkic))
		target.mind.remove_antag_datum(/datum/antagonist/sarkic)
		to_chat(target, span_warning("The alien thoughts in your mind dissolve. Your old self resurfaces."))
		purged_something = TRUE

	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
	target.setOrganLoss(ORGAN_SLOT_BRAIN, max(target.getOrganLoss(ORGAN_SLOT_BRAIN), 10))

	if(purged_something)
		user.visible_message(span_notice("[user] successfully removes anomalous tissue from [target]'s brain!"), vision_distance = COMBAT_MESSAGE_RANGE)
		log_game("Anomalous purge surgery performed on [key_name(target)] by [key_name(user)]")
		if(GLOB.scp_admin_log)
			GLOB.scp_admin_log.log_event("surgery", "N/A", user.ckey, target.ckey, "Anomalous purge surgery", 2)
	else
		user.visible_message(span_notice("[user] finds no anomalous tissue to remove from [target]'s brain."), vision_distance = COMBAT_MESSAGE_RANGE)
	..()

/datum/surgery_step/anomalous_purge/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		user.visible_message(span_warning("[user] slips and damages [target]'s brain!"), vision_distance = COMBAT_MESSAGE_RANGE)
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
	else
		user.visible_message(span_warning("[user] suddenly notices the brain is gone."), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/memetic_shielding
	name = "Install Memetic Shielding"
	desc = "Implants a memetic shielding mesh over the brain to resist cognitohazards."
	surgery_flags = SURGERY_NEEDS_DEENCASEMENT
	allowed_tools = list(
		/obj/item/stack/sheet/telekill = 85,
		TOOL_HEMOSTAT = 40
	)

/datum/surgery_step/memetic_shielding/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = ..()
	if(!affected)
		return
	if(affected.body_zone == BODY_ZONE_HEAD)
		return TRUE

/datum/surgery_step/memetic_shielding/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	var/obj/item/organ/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		to_chat(user, span_warning("[target] doesn't have a brain."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MEMETIC_SHIELDING))
		to_chat(user, span_warning("[target] already has memetic shielding installed."))
		return FALSE

/datum/surgery_step/memetic_shielding/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	user.visible_message(span_notice("[user] begins implanting a memetic shielding mesh over [target]'s brain."), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/memetic_shielding/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	ADD_TRAIT(target, TRAIT_MEMETIC_SHIELDING, "memetic_shielding_surgery")
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15)
	if(istype(tool, /obj/item/stack/sheet/telekill))
		var/obj/item/stack/sheet/telekill/TK = tool
		TK.use(1)
	user.visible_message(span_notice("[user] completes the memetic shielding implantation on [target]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	to_chat(target, span_notice("Your mind feels more resilient. Cognitohazards will have a harder time affecting you."))
	log_game("Memetic shielding surgery performed on [key_name(target)] by [key_name(user)]")
	..()

/datum/surgery_step/memetic_shielding/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		user.visible_message(span_warning("[user] damages [target]'s brain during the shielding procedure!"), vision_distance = COMBAT_MESSAGE_RANGE)
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)
		if(istype(tool, /obj/item/stack/sheet/telekill))
			var/obj/item/stack/sheet/telekill/TK = tool
			TK.use(1)
	else
		user.visible_message(span_warning("[user] suddenly notices the brain is gone."), vision_distance = COMBAT_MESSAGE_RANGE)

/obj/item/surgical_disk/foundation
	name = "Foundation Surgical Programs Disk"
	desc = "A disk containing Foundation-specific surgical programs for anomalous influence removal and memetic shielding installation."
	icon_state = "disk_surgery"
	var/list/available_surgeries = list(
		/datum/surgery_step/anomalous_purge,
		/datum/surgery_step/memetic_shielding,
	)

/obj/item/surgical_disk/foundation/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/list/options = list("Anomalous Purge", "Memetic Shielding")
	var/choice = input(H, "Select a surgical program to learn:", "Foundation Surgery") as null|anything in options
	if(!choice)
		return
	var/datum/surgery_step/learned_step
	switch(choice)
		if("Anomalous Purge")
			learned_step = /datum/surgery_step/anomalous_purge
		if("Memetic Shielding")
			learned_step = /datum/surgery_step/memetic_shielding
	if(learned_step)
		to_chat(H, span_notice("You study the [choice] surgical procedure from the disk."))
		hook_scp_interaction(H, "Foundation Surgery", INTERACTION_TYPE_MEDICAL)
