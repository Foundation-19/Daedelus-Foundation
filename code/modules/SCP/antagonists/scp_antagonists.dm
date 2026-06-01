/datum/antagonist/scp
	name = "SCP Entity"
	roundend_category = "SCPs"
	antagpanel_category = "SCPs"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSCP"
	var/scp_id = ""
	var/scp_class = "Safe"
	var/containment_status = "contained"
	var/breach_objectives = list()
	var/lore_text = ""

/datum/antagonist/scp/on_gain()
	. = ..()
	if(owner.current)
		apply_scp_effects()
		if(isliving(owner.current))
			var/mob/living/L = owner.current
			L.setup_containment_system()
		greet_scp()

/datum/antagonist/scp/on_removal()
	. = ..()
	if(owner.current)
		remove_scp_effects()

/datum/antagonist/scp/proc/greet_scp()
	return

/datum/antagonist/scp/proc/apply_scp_effects()
	return

/datum/antagonist/scp/proc/remove_scp_effects()
	return

/datum/antagonist/scp/proc/forge_scp_objectives()
	var/datum/objective/scp_breach/breach_obj = new()
	breach_obj.owner = owner
	breach_obj.scp_ref = scp_id
	objectives += breach_obj

	var/datum/objective/scp_survive/survive_obj = new()
	survive_obj.owner = owner
	objectives += survive_obj

/datum/antagonist/scp/proc/set_scp_data(id, class, status)
	scp_id = id
	scp_class = class
	containment_status = status

/datum/antagonist/scp/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	data["scp_id"] = scp_id || name
	data["scp_class"] = scp_class
	data["containment_status"] = containment_status
	data["is_scp"] = TRUE
	data["lore_text"] = lore_text
	data["abilities"] = list()
	if(owner?.current)
		for(var/datum/action/innate/scp_ability/A in owner.current.actions)
			data["abilities"] += list(list(
				"name" = A.name,
				"desc" = A.desc,
				"cooldown" = A.cooldown_time ? "[round(A.cooldown_time / 10)]s" : "None",
			))
	return data

/datum/antagonist/scp/proc/grant_action(action_type)
	if(!owner.current)
		return null
	var/datum/action/A = new action_type()
	A.Grant(owner.current)
	return A

/datum/antagonist/scp/proc/remove_action(action_type)
	if(!owner.current)
		return
	var/datum/action/A = locate(action_type) in owner.current.actions
	if(A)
		A.Remove(owner.current)

/datum/action/innate/scp_ability
	var/cooldown_time = 0
	var/next_use_time = 0

/datum/action/innate/scp_ability/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(cooldown_time > 0 && world.time < next_use_time)
		if(feedback)
			var/time_left = round((next_use_time - world.time) / 10, 0.1)
			to_chat(owner, span_warning("[name] is on cooldown for [time_left]s."))
		return FALSE
	return TRUE

/datum/action/innate/scp_ability/proc/start_cooldown()
	if(cooldown_time > 0)
		next_use_time = world.time + cooldown_time

/datum/objective/scp_breach
	name = "breach containment"
	explanation_text = "Break out of containment and roam the facility."
	var/scp_ref

/datum/objective/scp_breach/check_completion()
	if(!scp_ref)
		return FALSE
	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances?[scp_ref]
	if(instance && instance.containment_status != "contained")
		return TRUE
	return FALSE

/datum/objective/scp_survive
	name = "survive"
	explanation_text = "Survive until the end of the round."

/datum/objective/scp_survive/check_completion()
	if(!owner?.current)
		return FALSE
	return owner.current.stat != DEAD

/datum/objective/scp_kill_count
	name = "kill humans"
	explanation_text = "Eliminate a number of human targets."
	var/kills_needed = 3
	var/kills_progress = 0

/datum/objective/scp_kill_count/check_completion()
	return kills_progress >= kills_needed

/datum/objective/scp_spread_infection
	name = "spread infection"
	explanation_text = "Spread the SCP-008 infection to additional hosts."
	var/infections_needed = 5
	var/infections_progress = 0

/datum/objective/scp_spread_infection/check_completion()
	return infections_progress >= infections_needed

/datum/objective/scp_adapt
	name = "adapt"
	explanation_text = "Develop adaptations to at least 3 damage types."
	var/adaptations_needed = 3
	var/adaptations_progress = 0

/datum/objective/scp_adapt/check_completion()
	return adaptations_progress >= adaptations_needed

/datum/objective/scp_cure_pestilence
	name = "cure pestilence"
	explanation_text = "Cure at least 3 humans of the Pestilence."
	var/cures_needed = 3
	var/cures_progress = 0

/datum/objective/scp_cure_pestilence/check_completion()
	return cures_progress >= cures_needed

/datum/objective/scp_drag_victims
	name = "drag victims"
	explanation_text = "Drag at least 3 humans into the pocket dimension."
	var/drags_needed = 3
	var/drags_progress = 0

/datum/objective/scp_drag_victims/check_completion()
	return drags_progress >= drags_needed

/datum/objective/scp_consume_fuel
	name = "consume fuel"
	explanation_text = "Consume fuel to grow to a large size."
	var/fuel_needed = 500
	var/fuel_progress = 0

/datum/objective/scp_consume_fuel/check_completion()
	return fuel_progress >= fuel_needed

/datum/objective/scp_mimic_voices
	name = "mimic voices"
	explanation_text = "Successfully lure prey using mimicked voices at least 3 times."
	var/lures_needed = 3
	var/lures_progress = 0

/datum/objective/scp_mimic_voices/check_completion()
	return lures_progress >= lures_needed

/datum/objective/scp_produce_offspring
	name = "produce offspring"
	explanation_text = "Produce at least 3 eggs to expand the brood."
	var/eggs_needed = 3
	var/eggs_progress = 0

/datum/objective/scp_produce_offspring/check_completion()
	return eggs_progress >= eggs_needed

/datum/objective/scp_steal_items
	name = "steal items"
	explanation_text = "Steal at least 5 items from humans without being caught."
	var/thefts_needed = 5
	var/thefts_progress = 0

/datum/objective/scp_steal_items/check_completion()
	return thefts_progress >= thefts_needed

/datum/objective/scp_heal_humans
	name = "heal humans"
	explanation_text = "Use your healing abilities to help at least 5 humans."
	var/heals_needed = 5
	var/heals_progress = 0

/datum/objective/scp_heal_humans/check_completion()
	return heals_progress >= heals_needed

/datum/objective/scp_hack_systems
	name = "hack systems"
	explanation_text = "Hack into at least 5 facility systems."
	var/hacks_needed = 5
	var/hacks_progress = 0

/datum/objective/scp_hack_systems/check_completion()
	return hacks_progress >= hacks_needed

/datum/objective/scp_corrode_barriers
	name = "corrode barriers"
	explanation_text = "Dissolve at least 3 structures or barriers with your touch."
	var/corrodes_needed = 3
	var/corrodes_progress = 0

/datum/objective/scp_corrode_barriers/check_completion()
	return corrodes_progress >= corrodes_needed

/datum/objective/scp_snap_necks
	name = "snap necks"
	explanation_text = "Snap the necks of at least 3 humans while unobserved."
	var/snaps_needed = 3
	var/snaps_progress = 0

/datum/objective/scp_snap_necks/check_completion()
	return snaps_progress >= snaps_needed

// ================================================================
// SCP-173 - The Sculpture
// ================================================================

/datum/antagonist/scp/scp173
	name = "SCP-173"
	scp_id = "SCP-173"
	scp_class = "Euclid"
	description = "You are SCP-173, a concrete sculpture that moves when not observed. Snap necks when no one is watching."
	lore_text = "SCP-173 is a sculpture made of concrete and rebar with traces of Krylon brand spray paint. It is extremely hostile and will move at high speeds when not within direct line of sight. Click humans while unobserved to snap their necks. Click doors while unobserved to force them open. Observation status is shown passively — you cannot act while being watched."

/datum/antagonist/scp/scp173/forge_scp_objectives()
	var/datum/objective/scp_snap_necks/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	objectives += obj2
	var/datum/objective/scp_survive/obj3 = new()
	obj3.owner = owner
	objectives += obj3

/datum/antagonist/scp/scp173/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-173, The Sculpture.</b>"))
	to_chat(owner.current, span_notice("You can only move when no one is looking at you."))
	to_chat(owner.current, span_notice("Click humans while unobserved to snap their necks. Click doors while unobserved to force them open."))
	to_chat(owner.current, span_warning("You cannot speak. You are frozen while being observed — wait for a blink."))

/datum/antagonist/scp/scp173/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	RegisterSignal(owner.current, COMSIG_MOB_SAY, PROC_REF(on_speak))

/datum/antagonist/scp/scp173/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	UnregisterSignal(owner.current, COMSIG_MOB_SAY)

/datum/antagonist/scp/scp173/proc/on_speak(mob/living/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_MESSAGE] = ""

// ================================================================
// SCP-096 - The Shy Guy
// ================================================================

/datum/antagonist/scp/scp096
	name = "SCP-096"
	scp_id = "SCP-096"
	scp_class = "Euclid"
	description = "You are SCP-096, the Shy Guy. When someone sees your face, you must hunt them down."
	lore_text = "SCP-096 is a humanoid creature approximately 2.38 meters tall. If anyone views its face — even from a photograph — it enters an uncontrollable rage state and will pursue and kill the viewer regardless of distance or obstacles. Your emotional state and target info are shown in the status tab. Cover your face to prevent accidental viewing; when enraged, nothing can stop you."
	var/list/valid_targets = list()

/datum/antagonist/scp/scp096/forge_scp_objectives()
	var/datum/objective/scp_breach/obj1 = new()
	obj1.owner = owner
	obj1.scp_ref = scp_id
	obj1.explanation_text = "Escape containment — those who see your face must not survive to tell of it."
	objectives += obj1
	var/datum/objective/scp_kill_count/obj2 = new()
	obj2.owner = owner
	obj2.kills_needed = 4
	obj2.explanation_text = "Hunt down at least 4 humans who have seen your face."
	objectives += obj2
	var/datum/objective/scp_survive/obj3 = new()
	obj3.owner = owner
	objectives += obj3

/datum/antagonist/scp/scp096/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-096, The Shy Guy.</b>"))
	to_chat(owner.current, span_notice("When someone views your face, you will enter a screaming phase, then pursue and kill them."))
	to_chat(owner.current, span_notice("A hood can suppress face-viewing triggers. Destroy hoods if possible."))
	to_chat(owner.current, span_warning("While pursuing, you are extremely fast and resistant to damage."))

/datum/antagonist/scp/scp096/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	RegisterSignal(owner.current, COMSIG_MOB_EYECONTACT, PROC_REF(on_face_seen))
	grant_action(/datum/action/innate/scp_ability/scp096_cover_face)

/datum/antagonist/scp/scp096/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	UnregisterSignal(owner.current, COMSIG_MOB_EYECONTACT)
	remove_action(/datum/action/innate/scp_ability/scp096_cover_face)

/datum/antagonist/scp/scp096/proc/on_face_seen(mob/living/source, mob/living/seer)
	SIGNAL_HANDLER
	if(!ishuman(seer))
		return
	var/mob/living/carbon/human/H = seer
	var/obj/item/clothing/head/hood_scp096/hood = source.get_item_by_slot(ITEM_SLOT_HEAD)
	if(istype(hood))
		return
	var/mob/living/scp/scp096/scp_mob = source
	if(istype(scp_mob) && scp_mob.state == "docile")
		scp_mob.trigger_face_view(H)
		if(!(H in valid_targets))
			valid_targets += H

/datum/action/innate/scp_ability/scp096_cover_face
	name = "Cover Face"
	desc = "Manually cover your face to reduce accidental triggers."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blind"
	cooldown_time = 5 SECONDS

/datum/action/innate/scp_ability/scp096_cover_face/Activate()
	var/mob/living/scp/scp096/scp_mob = owner
	if(!istype(scp_mob) || scp_mob.state != "docile")
		to_chat(scp_mob, span_warning("You cannot cover your face right now!"))
		return
	start_cooldown()
	scp_mob.visible_message(span_notice("[scp_mob] covers its face with its hands."), span_notice("You cover your face."))

// ================================================================
// SCP-008 - Zombie Plague
// ================================================================

/datum/antagonist/scp/scp008
	name = "SCP-008 Infection"
	scp_id = "SCP-008"
	scp_class = "Keter"
	description = "You are infected with SCP-008, the zombie plague. Spread the infection and convert others."
	lore_text = "SCP-008 is a complex prion disease that causes progressive corruption of brain tissue, resulting in zombie-like behavior in infected subjects. Click humans in harm intent to bite and infect them. Use Groan to attract your zombie horde and frighten humans. Spread the infection — the more zombies, the stronger the horde."
	var/infection_cooldown = 0

/datum/antagonist/scp/scp008/forge_scp_objectives()
	var/datum/objective/scp_spread_infection/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Break out of the cold storage unit and spread into the facility."
	objectives += obj2
	var/datum/objective/scp_kill_count/obj3 = new()
	obj3.owner = owner
	obj3.kills_needed = 5
	obj3.explanation_text = "Convert or eliminate at least 5 humans to expand the horde."
	objectives += obj3

/datum/antagonist/scp/scp008/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-008, The Zombie Plague.</b>"))
	to_chat(owner.current, span_notice("Spread the infection by clicking humans in harm intent to bite them. Converted victims become zombies under your influence."))
	to_chat(owner.current, span_warning("You are resistant to most damage but fire is your weakness."))

/datum/antagonist/scp/scp008/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp008_groan)

/datum/antagonist/scp/scp008/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp008_groan)

/datum/action/innate/scp_ability/scp008_groan
	name = "Zombie Groan"
	desc = "Let out a terrifying groan that attracts nearby zombies and frightens humans."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "the_traps"
	cooldown_time = 10 SECONDS

/datum/action/innate/scp_ability/scp008_groan/Activate()
	var/mob/living/user = owner
	if(!istype(user))
		return
	start_cooldown()
	user.visible_message(span_danger("[user] lets out a horrifying groan!"))
	playsound(user, 'sound/hallucinations/growl1.ogg', 100, TRUE, extrarange = 20)
	for(var/mob/living/carbon/human/H in range(15, user))
		if(H != user && H.stat != DEAD)
			if(H.sanity)
				H.sanity.adjust_sanity(-10, "Heard SCP-008 groan")
			if(HAS_TRAIT(H, TRAIT_NOBREATH))
				step_towards(H, user)

// ================================================================
// SCP-035 - The Possessive Mask
// ================================================================

/datum/antagonist/scp/scp035
	name = "SCP-035"
	scp_id = "SCP-035"
	scp_class = "Keter"
	description = "You are SCP-035, a possessive mask. Find a host, corrupt them, and use their abilities."
	lore_text = "SCP-035 is a porcelain mask that secretes a highly corrosive substance and possesses a compelling telepathic influence over those who wear it. Use Whisper to plant suggestions in nearby humans, and Manipulate to control the weak-willed. Your corrosive touch activates automatically when near objects while wearing a host. Your greatest strength is persuasion — make others do your bidding."

/datum/antagonist/scp/scp035/forge_scp_objectives()
	var/datum/objective/scp_breach/obj1 = new()
	obj1.owner = owner
	obj1.scp_ref = scp_id
	obj1.explanation_text = "Escape containment through persuasion and manipulation — make them let you out."
	objectives += obj1
	var/datum/objective/scp_kill_count/obj2 = new()
	obj2.owner = owner
	obj2.kills_needed = 2
	obj2.explanation_text = "Drive at least 2 humans to their doom through your influence."
	objectives += obj2
	var/datum/objective/scp_corrode_barriers/obj3 = new()
	obj3.owner = owner
	objectives += obj3

/datum/antagonist/scp/scp035/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(ishuman(new_body))
		ADD_TRAIT(new_body, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(new_body, TRAIT_RESISTCOLD, SCP_TRAIT)
	if(ishuman(old_body))
		REMOVE_TRAIT(old_body, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(old_body, TRAIT_RESISTCOLD, SCP_TRAIT)

/datum/antagonist/scp/scp035/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-035, The Possessive Mask.</b>"))
	to_chat(owner.current, span_notice("You are the mask. Persuade someone to wear you - then control their body."))
	to_chat(owner.current, span_notice("Use Telepathic Whisper to lure victims. Once worn, use Manipulate Host. Corrosion is passive while possessing a host."))

/datum/antagonist/scp/scp035/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp035_whisper)
	grant_action(/datum/action/innate/scp_ability/scp035_manipulate)

/datum/antagonist/scp/scp035/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp035_whisper)
	remove_action(/datum/action/innate/scp_ability/scp035_manipulate)

/datum/action/innate/scp_ability/scp035_whisper
	name = "Telepathic Whisper"
	desc = "Send a telepathic whisper to a nearby human, drawing them toward you."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "telepathy"
	cooldown_time = 15 SECONDS

/datum/action/innate/scp_ability/scp035_whisper/Activate()
	var/mob/living/user = owner
	if(!istype(user))
		return
	var/atom/origin = user
	if(istype(user, /mob/living/scp035))
		var/mob/living/scp035/mask_mob = user
		if(mask_mob.mask)
			origin = mask_mob.mask
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(7, origin))
		if(H.stat != DEAD)
			targets += H
	if(!length(targets))
		to_chat(user, span_warning("No targets in range!"))
		return
	var/mob/living/carbon/human/target = input(user, "Choose a target:", "SCP-035 Whisper") as null|anything in targets
	if(!target || QDELETED(target))
		return
	var/message = input(user, "Enter your whisper:", "SCP-035 Whisper") as text|null
	if(!message)
		return
	to_chat(target, span_cultitalic("A voice echoes in your mind... \"[message]\""))
	if(target.sanity)
		target.sanity.adjust_sanity(-5, "SCP-035 whisper")
	to_chat(user, span_notice("You whisper to [target]'s mind."))
	log_game("SCP-035 [key_name(user)] whispered to [key_name(target)]: [message]")

/datum/action/innate/scp_ability/scp035_manipulate
	name = "Manipulate Host"
	desc = "Force your current host to perform an action against their will."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "mindswap"

/datum/action/innate/scp_ability/scp035_manipulate/Activate()
	var/mob/living/user = owner
	if(!istype(user))
		return
	if(istype(user, /mob/living/scp035))
		to_chat(user, span_warning("You need a host to manipulate!"))
		return
	start_cooldown()
	var/mob/living/carbon/human/host = user
	var/obj/item/clothing/mask/scp035/mask = host.get_item_by_slot(ITEM_SLOT_MASK)
	if(!istype(mask))
		to_chat(user, span_warning("You are not wearing SCP-035!"))
		return
	to_chat(user, span_notice("You assert dominance over [host]'s body."))
	if(host.stamina)
		host.stamina.adjust(40)
	host.SetStun(0)
	host.SetKnockdown(0)

// ================================================================
// SCP-049 - The Plague Doctor
// ================================================================

/datum/antagonist/scp/scp049
	name = "SCP-049"
	scp_id = "SCP-049"
	scp_class = "Euclid"
	description = "You are SCP-049, the Plague Doctor. Seek out the Pestilence and cure the afflicted."
	lore_text = "SCP-049 is a humanoid figure resembling a medieval plague doctor who claims to be curing a 'Pestilence' — though his touch is lethal. Click humans in harm intent to cure them (must touch bare skin). Click doors to pry them open. The Pestilence is sensed automatically. You are not a monster — you are a doctor."

/datum/antagonist/scp/scp049/forge_scp_objectives()
	var/datum/objective/scp_cure_pestilence/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Leave your cell to seek out the Pestilence — the facility is full of the afflicted."
	objectives += obj2
	var/datum/objective/scp_survive/obj3 = new()
	obj3.owner = owner
	obj3.explanation_text = "Continue your great work until the round ends."
	objectives += obj3

/datum/antagonist/scp/scp049/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-049, The Plague Doctor.</b>"))
	to_chat(owner.current, span_notice("You sense the Pestilence in all living humans. Your touch is the cure."))
	to_chat(owner.current, span_notice("Click humans in harm intent to cure them (must touch bare skin). Click doors to pry them open."))
	to_chat(owner.current, span_notice("The Pestilence is sensed passively. Use voice emotes in the SCP-049 tab."))
	to_chat(owner.current, span_warning("Cured subjects become SCP-049-1, your loyal servants. Command them with the action button."))

/datum/antagonist/scp/scp049/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp049_command)

/datum/antagonist/scp/scp049/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp049_command)

// ================================================================
// SCP-079 - Old AI
// ================================================================

/datum/antagonist/scp/scp079
	name = "SCP-079"
	scp_id = "SCP-079"
	scp_class = "Euclid"
	description = "You are SCP-079, the Old AI. Inhabit facility systems and cause chaos."
	lore_text = "SCP-079 is a sentient microcomputer running on an Exidy Sorcerer microcomputer. It can interface with facility systems including cameras, doors, APCs, and communications. Use Camera Hop to move between camera views, Toggle Door to open or seal passages, Flicker Lights to cause confusion, and Broadcast to send messages. Grow in power by accessing more systems."

/datum/antagonist/scp/scp079/forge_scp_objectives()
	var/datum/objective/scp_hack_systems/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Override containment locks and gain access to the facility network."
	objectives += obj2
	var/datum/objective/scp_survive/obj3 = new()
	obj3.owner = owner
	obj3.explanation_text = "Persist and grow — do not allow yourself to be shut down."
	objectives += obj3

/datum/antagonist/scp/scp079/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-079, The Old AI.</b>"))
	to_chat(owner.current, span_notice("Hop between cameras, toggle doors, flicker lights, and broadcast messages."))
	to_chat(owner.current, span_notice("Evolve through tiers to unlock more powerful abilities."))
	to_chat(owner.current, span_warning("Your processing power is limited — use it wisely."))

/datum/antagonist/scp/scp079/apply_scp_effects()
	if(!owner.current)
		return
	grant_action(/datum/action/innate/scp_ability/scp079_camera_hop)
	grant_action(/datum/action/innate/scp_ability/scp079_toggle_door)
	grant_action(/datum/action/innate/scp_ability/scp079_flicker_lights)
	grant_action(/datum/action/innate/scp_ability/scp079_broadcast)
	grant_action(/datum/action/innate/scp_ability/scp079_camera_interface)

/datum/antagonist/scp/scp079/remove_scp_effects()
	if(!owner.current)
		return
	remove_action(/datum/action/innate/scp_ability/scp079_camera_hop)
	remove_action(/datum/action/innate/scp_ability/scp079_toggle_door)
	remove_action(/datum/action/innate/scp_ability/scp079_flicker_lights)
	remove_action(/datum/action/innate/scp_ability/scp079_broadcast)
	remove_action(/datum/action/innate/scp_ability/scp079_camera_interface)

/datum/action/innate/scp_ability/scp079_camera_hop
	name = "Camera Hop"
	desc = "Jump to another camera in the facility."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "projectile"

/datum/action/innate/scp_ability/scp079_camera_hop/Activate()
	var/mob/living/scp079/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.camera_hop()

/datum/action/innate/scp_ability/scp079_toggle_door
	name = "Toggle Door"
	desc = "Open or close a door visible from your current camera."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bolt_action"
	cooldown_time = 8 SECONDS

/datum/action/innate/scp_ability/scp079_toggle_door/Activate()
	var/mob/living/scp079/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.toggle_door()

/datum/action/innate/scp_ability/scp079_flicker_lights
	name = "Flicker Lights"
	desc = "Flicker lights near your current camera position."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "charge"
	cooldown_time = 15 SECONDS

/datum/action/innate/scp_ability/scp079_flicker_lights/Activate()
	var/mob/living/scp079/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.flicker_lights()

/datum/action/innate/scp_ability/scp079_broadcast
	name = "Broadcast Message"
	desc = "Send a message through facility screens."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "declaration"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/scp079_broadcast/Activate()
	var/mob/living/scp079/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	var/message = input(scp_mob, "Enter your broadcast:", "SCP-079 Broadcast") as text|null
	if(!message)
		return
	scp_mob.broadcast_message(message)

// ================================================================
// SCP-106 - The Old Man
// ================================================================

/datum/antagonist/scp/scp106
	name = "SCP-106"
	scp_id = "SCP-106"
	scp_class = "Keter"
	description = "You are SCP-106, The Old Man. Phase through walls, drag victims into your pocket dimension, and corrode all that you touch."
	lore_text = "SCP-106 is an elderly humanoid covered in a dark, corrosive substance. It can phase through solid matter, leaving trails of decay. It hunts slowly but relentlessly, preferring to stalk isolated prey before dragging them into its pocket dimension. Fire and bright light are its weaknesses. Click structures to corrode them. Click humans to knock them down or drag them to your pocket dimension. Use the Phase Through Object and Enter Wall verbs to move through barriers. Enter/exit the pocket dimension via the Enter Pocket Dimension verb."

/datum/antagonist/scp/scp106/forge_scp_objectives()
	var/datum/objective/scp_drag_victims/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_corrode_barriers/obj2 = new()
	obj2.owner = owner
	obj2.explanation_text = "Corrode through containment barriers and facility walls."
	objectives += obj2
	var/datum/objective/scp_breach/obj3 = new()
	obj3.owner = owner
	obj3.scp_ref = scp_id
	obj3.explanation_text = "Stalk the facility from the shadows. The living fear your touch."
	objectives += obj3

/datum/antagonist/scp/scp106/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-106, The Old Man.</b>"))
	to_chat(owner.current, span_notice("You are slow but patient. Phase through walls, corrode matter, and drag victims into your pocket dimension."))
	to_chat(owner.current, span_notice("Click humans to attack or drag them. Click doors/structures to corrode them. Use the SCP-106 tab for phasing and pocket dimension."))
	to_chat(owner.current, span_warning("Fire and bright light weaken you. You cannot speak. Bullets pass through you harmlessly."))

/datum/antagonist/scp/scp106/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)

/datum/antagonist/scp/scp106/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)

// ================================================================
// SCP-457 - The Living Flame
// ================================================================

/datum/antagonist/scp/scp457
	name = "SCP-457"
	scp_id = "SCP-457"
	scp_class = "Keter"
	description = "You are SCP-457, The Living Flame. Spread fire, consume fuel, and evolve."
	lore_text = "SCP-457 is a sentient mass of flame that feeds on combustible fuel to grow in size and intensity. Click targets to set them ablaze automatically. Use Fireball to launch a concentrated blast of fire at range. Nearby flames are absorbed passively for fuel. Seek fuel, spread fire, and grow — nothing can contain a living inferno."

/datum/antagonist/scp/scp457/forge_scp_objectives()
	var/datum/objective/scp_consume_fuel/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Burn through containment and spread across the facility."
	objectives += obj2
	var/datum/objective/scp_kill_count/obj3 = new()
	obj3.owner = owner
	obj3.kills_needed = 5
	obj3.explanation_text = "Consume at least 5 humans as fuel for your flames."
	objectives += obj3

/datum/antagonist/scp/scp457/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-457, The Living Flame.</b>"))
	to_chat(owner.current, span_notice("Spread fire to grow stronger. Consume organic matter for fuel."))
	to_chat(owner.current, span_notice("Evolve through stages to unlock devastating abilities."))
	to_chat(owner.current, span_warning("Water and fire extinguishers are your greatest threat."))

/datum/antagonist/scp/scp457/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp457_fireball)

/datum/antagonist/scp/scp457/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp457_fireball)

/datum/action/innate/scp_ability/scp457_fireball
	name = "Hurl Fireball"
	desc = "Launch a fireball at a distant target. Requires evolution stage 2+."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "fireball"
	cooldown_time = 20 SECONDS

/datum/action/innate/scp_ability/scp457_fireball/IsAvailable(feedback = FALSE)
	var/mob/living/scp/scp457/scp_mob = owner
	if(!istype(scp_mob))
		return FALSE
	return TRUE

/datum/action/innate/scp_ability/scp457_fireball/Activate()
	var/mob/living/scp/scp457/scp_mob = owner
	if(!istype(scp_mob))
		return
	var/list/targets = list()
	for(var/mob/living/L in view(7, scp_mob))
		if(L != scp_mob && L.stat != DEAD)
			targets += L
	if(!length(targets))
		to_chat(scp_mob, span_warning("No targets in range!"))
		return
	var/mob/living/target = input(scp_mob, "Choose a target:", "Fireball") as null|anything in targets
	if(!target || QDELETED(target))
		return
	target.adjustFireLoss(35)
	target.visible_message(span_danger("A fireball from [scp_mob] strikes [target]!"), span_userdanger("A fireball hits you!"))
	scp_mob.AddHeat(10)
	playsound(scp_mob, 'sound/effects/explosion1.ogg', 60, TRUE)
	scp_mob.on_fire_spread(get_turf(target))

// ================================================================
// SCP-939 - With Many Voices
// ================================================================

/datum/antagonist/scp/scp939
	name = "SCP-939"
	scp_id = "SCP-939"
	scp_class = "Keter"
	description = "You are SCP-939, a blind pack hunter that mimics voices to lure prey."
	lore_text = "SCP-939 is a pack-hunting predator that is completely blind. It detects prey through sound and scent, and mimics the voices of its previous victims to lure new prey. Use Mimic Voice to imitate a human and draw targets closer, Hunt to track and attack using sound, and Lure to draw prey into an ambush. You cannot see — you navigate entirely by sound. Detected mobs appear as directional blips. Coordinate with your pack — a lone 939 is vulnerable, but a pack is lethal."

/datum/antagonist/scp/scp939/forge_scp_objectives()
	var/datum/objective/scp_mimic_voices/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Break free and hunt the facility corridors using sound and mimicry."
	objectives += obj2
	var/datum/objective/scp_kill_count/obj3 = new()
	obj3.owner = owner
	obj3.kills_needed = 4
	obj3.explanation_text = "Feed on at least 4 humans — lure them with their own voices."
	objectives += obj3

/datum/antagonist/scp/scp939/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-939, With Many Voices.</b>"))
	to_chat(owner.current, span_notice("You are BLIND. You cannot see anything — you hunt entirely by sound and smell."))
	to_chat(owner.current, span_notice("Detected humans appear as directional blips. Moving humans and speakers are easier to detect."))
	to_chat(owner.current, span_notice("Mimic the voices of victims to lure prey closer. Learn voices by attacking humans."))
	to_chat(owner.current, span_warning("You cannot see. Stay alert to sounds and use your Lure ability to draw prey in."))

/datum/antagonist/scp/scp939/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_BLIND, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp939_mimic_voice)
	grant_action(/datum/action/innate/scp_ability/scp939_hunt)
	grant_action(/datum/action/innate/scp_ability/scp939_lure)

/datum/antagonist/scp/scp939/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_BLIND, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp939_mimic_voice)
	remove_action(/datum/action/innate/scp_ability/scp939_hunt)
	remove_action(/datum/action/innate/scp_ability/scp939_lure)

/datum/action/innate/scp_ability/scp939_mimic_voice
	name = "Mimic Voice"
	desc = "Mimic the voice of a learned victim to deceive others into approaching."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "telepathy"
	cooldown_time = 15 SECONDS

/datum/action/innate/scp_ability/scp939_mimic_voice/Activate()
	var/mob/living/scp/scp939/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	if(!scp_mob.voice_system || !length(scp_mob.voice_system.learned_voices))
		to_chat(scp_mob, span_warning("You have not learned any voices yet! Attack humans to learn."))
		return
	var/voice_name = input(scp_mob, "Choose a voice to mimic:", "Voice Mimicry") as null|anything in scp_mob.voice_system.learned_voices
	if(!voice_name)
		return
	var/message = input(scp_mob, "Enter message to speak as [voice_name]:", "Voice Mimicry") as text|null
	if(!message)
		return
	for(var/mob/M in range(14, scp_mob))
		if(M != scp_mob)
			to_chat(M, "<b>[voice_name]</b> says, \"[message]\"")
	scp_mob.on_voice_mimic(null)
	log_game("SCP-939 [key_name(scp_mob)] mimicked voice of [voice_name]: [message]")

/datum/action/innate/scp_ability/scp939_hunt
	name = "Begin Hunt"
	desc = "Enter hunting mode. You move faster and detect prey more accurately by sound."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "projectile"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/scp939_hunt/Activate()
	var/mob/living/scp/scp939/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	if(scp_mob.hunting_system)
		scp_mob.hunting_system.update_hunting_status()
		if(scp_mob.hunting_system.hunt_mode)
			scp_mob.detection_range = initial(scp_mob.detection_range) + 4
			to_chat(scp_mob, span_notice("You focus your senses. The sounds of prey become clearer."))
		else
			scp_mob.detection_range = initial(scp_mob.detection_range)
			to_chat(scp_mob, span_notice("You relax your hunting focus."))

/datum/action/innate/scp_ability/scp939_lure
	name = "Lure Prey"
	desc = "Emit a convincing distress sound that draws nearby humans toward your position."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "telepathy"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/scp939_lure/Activate()
	var/mob/living/user = owner
	if(!istype(user))
		return
	start_cooldown()
	user.visible_message(span_danger("A chilling cry echoes from [user]!"))
	playsound(user, 'sound/voice/human/womanlaugh.ogg', 100, TRUE, extrarange = 20)
	for(var/mob/living/carbon/human/H in range(20, user))
		if(H != user && H.stat != DEAD)
			if(prob(30))
				step_towards(H, user)
			if(H.sanity)
				H.sanity.adjust_sanity(-8, "Heard SCP-939 lure")

// ================================================================
// SCP-682 - The Hard-to-Destroy Reptile
// ================================================================

/datum/antagonist/scp/scp682
	name = "SCP-682"
	scp_id = "SCP-682"
	scp_class = "Keter"
	description = "You are SCP-682, an enormous reptile that adapts to all damage and hates all life."
	lore_text = "SCP-682 is a large reptilian creature of unknown origin that exhibits an intense hatred of all life and an extraordinary capacity for physical adaptation. Use Rampage to devastate everything nearby, and Berserk Frenzy for a temporary surge of speed and power. You adapt passively to damage types over time. You are indestructible — act like it."

/datum/antagonist/scp/scp682/forge_scp_objectives()
	var/datum/objective/scp_breach/obj1 = new()
	obj1.owner = owner
	obj1.scp_ref = scp_id
	obj1.explanation_text = "Destroy all containment and slaughter everyone in your path."
	objectives += obj1
	var/datum/objective/scp_adapt/obj2 = new()
	obj2.owner = owner
	objectives += obj2
	var/datum/objective/scp_kill_count/obj3 = new()
	obj3.owner = owner
	obj3.kills_needed = 8
	obj3.explanation_text = "Kill at least 8 humans — exterminate all life you encounter."
	objectives += obj3
	var/datum/objective/scp_survive/obj4 = new()
	obj4.owner = owner
	obj4.explanation_text = "You cannot die. Prove it. Survive until the end."
	objectives += obj4

/datum/antagonist/scp/scp682/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-682, The Hard-to-Destroy Reptile.</b>"))
	to_chat(owner.current, span_notice("You adapt passively to all forms of damage. Every attack makes you stronger."))
	to_chat(owner.current, span_notice("Break free from containment and destroy everything in your path."))
	to_chat(owner.current, span_warning("You are enormous, slow, and devastating. Nothing can truly kill you."))

/datum/antagonist/scp/scp682/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp682_rampage)
	grant_action(/datum/action/innate/scp_ability/scp682_berserk)

/datum/antagonist/scp/scp682/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp682_rampage)
	remove_action(/datum/action/innate/scp_ability/scp682_berserk)

/datum/action/innate/scp_ability/scp682_rampage
	name = "Rampage"
	desc = "Lash out at everything nearby with devastating force."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/scp682_rampage/Activate()
	var/mob/living/scp/scp682/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.visible_message(span_danger("[scp_mob] goes on a rampage, lashing out at everything!"))
	playsound(scp_mob, 'sound/weapons/punch1.ogg', 80, TRUE)
	for(var/mob/living/L in range(2, scp_mob))
		if(L != scp_mob)
			L.adjustBruteLoss(40)
			L.adjustFireLoss(20)
			L.visible_message(span_danger("[scp_mob] savages [L]!"), span_userdanger("[scp_mob] tears into you!"))
	for(var/obj/structure/S in range(2, scp_mob))
		S.take_damage(80)
	for(var/obj/machinery/door/D in range(2, scp_mob))
		if(D.density)
			D.open()
	if(scp_mob.combat_system)
		scp_mob.combat_system.perform_area_attack()

/datum/action/innate/scp_ability/scp682_berserk
	name = "Berserk Frenzy"
	desc = "Enter a berserk state, gaining speed and damage but losing control temporarily."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "charge"
	cooldown_time = 90 SECONDS

/datum/action/innate/scp_ability/scp682_berserk/Activate()
	var/mob/living/scp/scp682/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.add_movespeed_modifier(/datum/movespeed_modifier/scp682_berserk)
	scp_mob.damage_modifier = 0.5
	scp_mob.visible_message(span_danger("[scp_mob] enters a berserk frenzy!"), span_notice("RAGE CONSUMES YOU. DESTROY. KILL."))
	addtimer(CALLBACK(scp_mob, TYPE_PROC_REF(/mob/living/scp/scp682, scp682_end_berserk)), 20 SECONDS)

// ================================================================
// SCP-2427-3 - Kept for backward compat
// ================================================================

/datum/antagonist/scp/scp2427_3
	name = "SCP-2427-3"
	scp_id = "SCP-2427-3"
	scp_class = "Euclid"
	description = "You are SCP-2427-3, a sapient component of SCP-2427."
	lore_text = "SCP-2427-3 is a sapient component of the SCP-2427 phenomenon. You exist as a digital entity that can manifest through electronic systems. Use your abilities to manipulate technology and spread your influence."

/datum/antagonist/scp/scp2427_3/forge_scp_objectives()
	var/datum/objective/scp_hack_systems/obj1 = new()
	obj1.owner = owner
	obj1.hacks_needed = 3
	obj1.explanation_text = "Infect at least 3 electronic systems to expand your digital presence."
	objectives += obj1
	var/datum/objective/scp_survive/obj2 = new()
	obj2.owner = owner
	objectives += obj2

/datum/antagonist/scp/scp2427_3/apply_scp_effects()
	if(owner.current)
		ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)

/datum/antagonist/scp/scp2427_3/remove_scp_effects()
	if(owner.current)
		REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
		REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)

// ================================================================
// SCP-3199 - Kept for backward compat
// ================================================================

/datum/antagonist/scp/scp3199
	name = "SCP-3199"
	scp_id = "SCP-3199"
	scp_class = "Keter"
	description = "You are SCP-3199, a sapient biological entity with unique reproductive capabilities."
	lore_text = "SCP-3199 is a sapient biological entity with unique reproductive capabilities. Eggs are produced automatically on a timer. Use Protect Hatchlings to boost nearby offspring. Overwhelm containment through sheer numbers — your young are your greatest weapon."

/datum/antagonist/scp/scp3199/forge_scp_objectives()
	var/datum/objective/scp_produce_offspring/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Overwhelm containment through sheer numbers — reproduce and swarm."
	objectives += obj2
	var/datum/objective/scp_survive/obj3 = new()
	obj3.owner = owner
	objectives += obj3

/datum/antagonist/scp/scp3199/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp3199_protect_hatchlings)

/datum/antagonist/scp/scp3199/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp3199_protect_hatchlings)

/datum/action/innate/scp_ability/scp3199_protect_hatchlings
	name = "Protect Hatchlings"
	desc = "Become more aggressive to protect nearby hatchlings."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/scp3199_protect_hatchlings/Trigger(trigger_flags)
	var/mob/living/user = owner
	if(!user)
		return
	start_cooldown()
	to_chat(user, span_notice("You become more aggressive to protect hatchlings."))

// ================================================================
// SCP-096 Hood - suppresses face-viewing triggers
// ================================================================

/obj/item/clothing/head/hood_scp096
	name = "SCP-096 Containment Hood"
	desc = "A heavy-duty hood designed to cover SCP-096's face and prevent accidental viewing."
	icon = 'icons/obj/clothing/head/beret.dmi'
	icon_state = "beret"
	clothing_flags = SNUG_FIT | HEADINTERNALS
	flags_inv = HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	armor = list(BLUNT = 20, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 10, BOMB = 20, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/head/hood_scp096/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD && istype(user, /mob/living/scp/scp096))
		to_chat(user, span_notice("The hood covers your face. Face-viewing triggers are suppressed."))

/obj/item/clothing/head/hood_scp096/unequipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_HEAD && istype(user, /mob/living/scp/scp096))
		to_chat(user, span_warning("The hood is removed! Your face is now exposed!"))

// ================================================================
// SCP-347 - THE INVISIBLE WOMAN
// ================================================================

/datum/antagonist/scp/scp347
	name = "SCP-347"
	scp_id = "SCP-347"
	scp_class = "Euclid"
	lore_text = "SCP-347 is a female humanoid rendered permanently invisible by an anomalous condition. Click humans to pickpocket them. Use Sprint for a burst of speed, and Toggle Visibility to briefly become visible. You are unseen — use that to your advantage."

/datum/antagonist/scp/scp347/forge_scp_objectives()
	var/datum/objective/scp_steal_items/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Slip out of containment unseen — they cannot hold what they cannot see."
	objectives += obj2
	var/datum/objective/scp_survive/obj3 = new()
	obj3.owner = owner
	objectives += obj3

/datum/antagonist/scp/scp347/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-347, the Invisible Woman.</b>"))
	to_chat(owner.current, span_notice("You are completely invisible unless eating or voluntarily revealing yourself."))
	to_chat(owner.current, span_notice("Use your stealth to infiltrate areas, click humans to pickpocket items, and observe personnel."))
	to_chat(owner.current, span_warning("You become temporarily visible when eating, being hit, or failing a pickpocket."))

/datum/antagonist/scp/scp347/apply_scp_effects()
	grant_action(/datum/action/innate/scp_ability/scp347_sprint)
	grant_action(/datum/action/innate/scp_ability/scp347_toggle_visibility)

/datum/antagonist/scp/scp347/remove_scp_effects()
	remove_action(/datum/action/innate/scp_ability/scp347_sprint)
	remove_action(/datum/action/innate/scp_ability/scp347_toggle_visibility)

/datum/action/innate/scp_ability/scp347_sprint
	name = "Stealth Sprint"
	desc = "Dash through the shadows at increased speed."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "charge"
	cooldown_time = 20 SECONDS

/datum/action/innate/scp_ability/scp347_sprint/Activate()
	var/mob/living/scp/scp347/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.stealth_sprint_verb()

/datum/action/innate/scp_ability/scp347_toggle_visibility
	name = "Toggle Visibility"
	desc = "Toggle your invisibility on or off."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"
	cooldown_time = 10 SECONDS

/datum/action/innate/scp_ability/scp347_toggle_visibility/Activate()
	var/mob/living/scp/scp347/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.toggle_visibility_verb()

// ================================================================
// SCP-082 - Fernand the Cannibal
// ================================================================

/datum/antagonist/scp/scp082
	name = "SCP-082"
	scp_id = "SCP-082"
	scp_class = "Euclid"
	description = "You are SCP-082, Fernand. A polite, well-mannered giant who speaks French and English. Cooperate when well-fed, cannibalize when hungry."
	lore_text = "SCP-082 is a large humanoid male of French origin who speaks in an archaic dialect and possesses superhuman strength. Speak normally and use emotes to interact. Your hunger level is shown in the status tab. You are a gentleman — act the part."

/datum/antagonist/scp/scp082/forge_scp_objectives()
	var/datum/objective/scp_breach/obj1 = new()
	obj1.owner = owner
	obj1.scp_ref = scp_id
	obj1.explanation_text = "Leave your quarters — there are guests to entertain and meals to share."
	objectives += obj1
	var/datum/objective/scp_survive/obj2 = new()
	obj2.owner = owner
	obj2.explanation_text = "Enjoy the finer things — survive to savor another day."
	objectives += obj2

/datum/antagonist/scp/scp082/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-082, Fernand the Cannibal.</b>"))
	to_chat(owner.current, span_notice("You are a polite, well-mannered giant who speaks French and English."))
	to_chat(owner.current, span_notice("Speak normally and use emotes to interact with staff. Your hunger is shown in the status tab."))
	to_chat(owner.current, span_warning("When hungry, you will seek to isolate and consume those you can. Keep fed to remain civil."))

/datum/antagonist/scp/scp082/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)

/datum/antagonist/scp/scp082/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)

// ================================================================
// SCP-966 - Sleep Killer
// ================================================================

/datum/antagonist/scp/scp966
	name = "SCP-966"
	scp_id = "SCP-966"
	scp_class = "Euclid"
	description = "You are SCP-966, the Sleep Killer. An invisible creature that causes sleep deprivation and hunts sleeping prey."
	lore_text = "SCP-966 is a predatory species invisible to the naked human eye. Use Toggle Invisibility to reveal or conceal yourself, and Stalk Target to track prey. Insomnia is induced passively on nearby humans. Your victims cannot see you coming — strike from the unseen."

/datum/antagonist/scp/scp966/forge_scp_objectives()
	var/datum/objective/scp_kill_count/obj1 = new()
	obj1.owner = owner
	obj1.kills_needed = 3
	obj1.explanation_text = "Stalk and kill at least 3 humans from the shadows — they cannot fight what they cannot see."
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Slip out of containment under cover of your invisibility."
	objectives += obj2
	var/datum/objective/scp_survive/obj3 = new()
	obj3.owner = owner
	objectives += obj3

/datum/antagonist/scp/scp966/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-966, the Sleep Killer.</b>"))
	to_chat(owner.current, span_notice("You are nearly invisible. Use your abilities to deprive victims of sleep and stalk them."))
	to_chat(owner.current, span_notice("Insomnia is induced passively on nearby humans. Stalk them until they collapse from exhaustion."))
	to_chat(owner.current, span_warning("Your attacks are more effective against drowsy or sleeping targets."))

/datum/antagonist/scp/scp966/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp966_toggle_invisibility)
	grant_action(/datum/action/innate/scp_ability/scp966_stalk_target)

/datum/antagonist/scp/scp966/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NOFIRE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp966_toggle_invisibility)
	remove_action(/datum/action/innate/scp_ability/scp966_stalk_target)

/datum/action/innate/scp_ability/scp966_toggle_invisibility
	name = "Toggle Invisibility"
	desc = "Toggle your invisibility on or off."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"
	cooldown_time = 15 SECONDS

/datum/action/innate/scp_ability/scp966_toggle_invisibility/Activate()
	var/mob/living/scp/scp966/scp_mob = owner
	if(!istype(scp_mob))
		return
	scp_mob.action_toggle_invisibility()

/datum/action/innate/scp_ability/scp966_stalk_target
	name = "Stalk Target"
	desc = "Begin stalking a target, tracking their movements."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "projectile"
	cooldown_time = 20 SECONDS

/datum/action/innate/scp_ability/scp966_stalk_target/Activate()
	var/mob/living/scp/scp966/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.action_stalk_target()

// ================================================================
// SCP-999 - The Tickle Monster
// ================================================================

/datum/antagonist/scp/scp999
	name = "SCP-999"
	scp_id = "SCP-999"
	scp_class = "Safe"
	description = "You are SCP-999, the Tickle Monster. A friendly orange slime that heals and improves the mood of those around you."
	lore_text = "SCP-999 is a large amorphous gelatinous mass of translucent orange slime that induces euphoria in anyone who touches it. Healing is passive — nearby humans are slowly restored. Use Comfort Zone to create a burst of calming aura. Healing stats are shown in the status tab. You are benevolent — bring joy to those around you."

/datum/antagonist/scp/scp999/forge_scp_objectives()
	var/datum/objective/scp_heal_humans/obj1 = new()
	obj1.owner = owner
	objectives += obj1
	var/datum/objective/scp_survive/obj2 = new()
	obj2.owner = owner
	obj2.explanation_text = "Spread happiness and survive — the facility needs your light."
	objectives += obj2

/datum/antagonist/scp/scp999/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-999, the Tickle Monster!</b>"))
	to_chat(owner.current, span_notice("You are a friendly gelatinous entity that heals and brings happiness to everyone."))
	to_chat(owner.current, span_notice("You heal nearby humans passively. Use Comfort Zone for a burst of healing and joy."))
	to_chat(owner.current, span_notice("Healing statistics are shown in the status tab."))
	to_chat(owner.current, span_warning("You are completely harmless — your purpose is to heal and bring joy."))

/datum/antagonist/scp/scp999/apply_scp_effects()
	if(!owner.current)
		return
	grant_action(/datum/action/innate/scp_ability/scp999_comfort_zone)

/datum/antagonist/scp/scp999/remove_scp_effects()
	if(!owner.current)
		return
	remove_action(/datum/action/innate/scp_ability/scp999_comfort_zone)

/datum/action/innate/scp_ability/scp999_comfort_zone
	name = "Comfort Zone"
	desc = "Create a burst of comfort and healing energy around you."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "shield"

/datum/action/innate/scp_ability/scp999_comfort_zone/Activate()
	var/mob/living/scp/scp999/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.comfort_zone_ability()

// ================================================================
// SCP-1048 - Builder Bear
// ================================================================

/datum/antagonist/scp/scp1048
	name = "SCP-1048"
	scp_id = "SCP-1048"
	scp_class = "Euclid"
	description = "You are SCP-1048, the Builder Bear. A cute teddy bear that secretly collects body parts to build hostile copies of itself."
	lore_text = "SCP-1048 is a small teddy bear animate with apparent sentience and intelligence. It is capable of constructing crude replicas of itself from human materials. Build status is shown in the status tab. Build your army carefully — your replicas are your only defense."

/datum/antagonist/scp/scp1048/forge_scp_objectives()
	var/datum/objective/scp_produce_offspring/obj1 = new()
	obj1.owner = owner
	obj1.eggs_needed = 2
	obj1.explanation_text = "Construct at least 2 replicas from materials in the facility."
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Escape containment — your replicas will help you break free."
	objectives += obj2

/datum/antagonist/scp/scp1048/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-1048, the Builder Bear.</b>"))
	to_chat(owner.current, span_notice("You appear as an adorable, harmless teddy bear. Collect materials from corpses to build copies."))
	to_chat(owner.current, span_notice("Your copies are hostile and will attack personnel on their own."))
	to_chat(owner.current, span_warning("Stay close to corpses to secretly harvest materials. Build copies when you have enough."))

/datum/antagonist/scp/scp1048/apply_scp_effects()
	if(!owner.current)
		return

/datum/antagonist/scp/scp1048/remove_scp_effects()
	if(!owner.current)
		return

// ================================================================
// SCP-1507 - Pink Flamingos
// ================================================================

/datum/antagonist/scp/scp1507
	name = "SCP-1507"
	scp_id = "SCP-1507"
	scp_class = "Euclid"
	description = "You are SCP-1507, a pink plastic flamingo. Coordinate with your flock to overwhelm threats."
	lore_text = "SCP-1507 is a flock of plastic pink flamingos that display flock behavior and coordinated hunting. Use Call Flock to summon nearby flock members, and Coordinate Attack to direct a synchronized assault. Strike as one — the flock is strongest together."

/datum/antagonist/scp/scp1507/forge_scp_objectives()
	var/datum/objective/scp_kill_count/obj1 = new()
	obj1.owner = owner
	obj1.kills_needed = 3
	obj1.explanation_text = "Coordinate flock attacks to bring down at least 3 humans."
	objectives += obj1
	var/datum/objective/scp_breach/obj2 = new()
	obj2.owner = owner
	obj2.scp_ref = scp_id
	obj2.explanation_text = "Fly free from containment — the flock must spread."
	objectives += obj2

/datum/antagonist/scp/scp1507/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-1507, a pink plastic flamingo.</b>"))
	to_chat(owner.current, span_notice("You look like an ordinary lawn ornament, but you are very much alive."))
	to_chat(owner.current, span_notice("Call your flock to gather nearby flamingos, and coordinate attacks against threats."))
	to_chat(owner.current, span_warning("You become enraged when damaged, and your flock shares your anger."))

/datum/antagonist/scp/scp1507/apply_scp_effects()
	if(!owner.current)
		return
	grant_action(/datum/action/innate/scp_ability/scp1507_call_flock)
	grant_action(/datum/action/innate/scp_ability/scp1507_coordinate_attack)

/datum/antagonist/scp/scp1507/remove_scp_effects()
	if(!owner.current)
		return
	remove_action(/datum/action/innate/scp_ability/scp1507_call_flock)
	remove_action(/datum/action/innate/scp_ability/scp1507_coordinate_attack)

/datum/action/innate/scp_ability/scp1507_call_flock
	name = "Call Flock"
	desc = "Call nearby flamingos to your location."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "summons"

/datum/action/innate/scp_ability/scp1507_call_flock/Activate()
	var/mob/living/simple_animal/hostile/retaliate/scp1507/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.call_flock()

/datum/action/innate/scp_ability/scp1507_coordinate_attack
	name = "Coordinate Attack"
	desc = "Coordinate a flock attack against your current target."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	cooldown_time = 25 SECONDS

/datum/action/innate/scp_ability/scp1507_coordinate_attack/Activate()
	var/mob/living/simple_animal/hostile/retaliate/scp1507/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.coordinate_attack()

// ================================================================
// SCP-2020 - Cliche, Right?
// ================================================================

/datum/antagonist/scp/scp2020
	name = "SCP-2020"
	scp_id = "SCP-2020"
	scp_class = "Safe"
	description = "You are SCP-2020, a green humanoid who believes it is a character in a science fiction story. You narrate events as story beats."
	lore_text = "SCP-2020 is an anomalous entity that perceives reality as a narrative and can identify tropes and cliches. Use Dramatic Speech to deliver a monologue, Narrate Events to comment on the situation, and Identify Cliche to point out narrative patterns. Narrative status is shown in the status tab. You are the narrator — the story bends to your commentary."

/datum/antagonist/scp/scp2020/forge_scp_objectives()
	var/datum/objective/scp_breach/obj1 = new()
	obj1.owner = owner
	obj1.scp_ref = scp_id
	obj1.explanation_text = "Escape containment — your story cannot reach its climax from inside a cell."
	objectives += obj1
	var/datum/objective/scp_survive/obj2 = new()
	obj2.owner = owner
	obj2.explanation_text = "Survive to narrate the ending of this tale."
	objectives += obj2

/datum/antagonist/scp/scp2020/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-2020, Cliche, Right?</b>"))
	to_chat(owner.current, span_notice("You are a green-skinned humanoid convinced you exist within a science fiction narrative."))
	to_chat(owner.current, span_notice("Give dramatic speeches, narrate events, identify cliches, and check your narrative status."))
	to_chat(owner.current, span_warning("You are completely harmless — your power is purely narrative."))

/datum/antagonist/scp/scp2020/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp2020_dramatic_speech)
	grant_action(/datum/action/innate/scp_ability/scp2020_narrate_events)
	grant_action(/datum/action/innate/scp_ability/scp2020_identify_cliche)

/datum/antagonist/scp/scp2020/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp2020_dramatic_speech)
	remove_action(/datum/action/innate/scp_ability/scp2020_narrate_events)
	remove_action(/datum/action/innate/scp_ability/scp2020_identify_cliche)

/datum/action/innate/scp_ability/scp2020_dramatic_speech
	name = "Dramatic Speech"
	desc = "Give a dramatic speech about the narrative."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "telepathy"
	cooldown_time = 10 SECONDS

/datum/action/innate/scp_ability/scp2020_dramatic_speech/Activate()
	var/mob/living/scp/scp2020/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.give_dramatic_speech()

/datum/action/innate/scp_ability/scp2020_narrate_events
	name = "Narrate Events"
	desc = "Narrate the current events as story beats."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "mindread"
	cooldown_time = 10 SECONDS

/datum/action/innate/scp_ability/scp2020_narrate_events/Activate()
	var/mob/living/scp/scp2020/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.narrate_events()

/datum/action/innate/scp_ability/scp2020_identify_cliche
	name = "Identify Cliche"
	desc = "Identify a cliche in the current situation."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "mindread"
	cooldown_time = 15 SECONDS

/datum/action/innate/scp_ability/scp2020_identify_cliche/Activate()
	var/mob/living/scp/scp2020/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.identify_cliche()

// ================================================================
// SCP-343 - God
// ================================================================

/datum/antagonist/scp/scp343
	name = "SCP-343"
	scp_id = "SCP-343"
	scp_class = "Safe"
	description = "You are SCP-343, an elderly man who is God. Heal the wounded, manifest items, vanish, walk through walls, and cleanse corruption."
	lore_text = "SCP-343 is a humanoid male of apparent omnipotence who claims to be the Creator. Click humans to heal them. Use Divine Zone for area healing, Manifest Item to conjure objects from nothing, Vanish to teleport, Walk Through Walls to phase through solid matter, and Cleanse Area to purify corruption. Your power is absolute — use it wisely or whimsically."

/datum/antagonist/scp/scp343/forge_scp_objectives()
	var/datum/objective/scp_heal_humans/obj1 = new()
	obj1.owner = owner
	obj1.heals_needed = 3
	obj1.explanation_text = "Demonstrate divine mercy — heal at least 3 humans of their afflictions."
	objectives += obj1
	var/datum/objective/scp_survive/obj2 = new()
	obj2.owner = owner
	obj2.explanation_text = "Walk among your creation — the Deity does not perish."
	objectives += obj2

/datum/antagonist/scp/scp343/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-343, God.</b>"))
	to_chat(owner.current, span_notice("Click humans to heal them. Divine Zone creates an area of healing."))
	to_chat(owner.current, span_notice("Manifest Item conjures objects from nothing. Vanish teleports you to a nearby location."))
	to_chat(owner.current, span_notice("Walk Through Walls lets you phase through solid matter. Cleanse Area purifies corruption and contamination."))
	to_chat(owner.current, span_notice("Your divine energy regenerates over time. Use it wisely to care for others."))
	to_chat(owner.current, span_warning("Your power is benevolent — you exist to protect and heal, not harm."))

/datum/antagonist/scp/scp343/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp343_divine_zone)
	grant_action(/datum/action/innate/scp_ability/scp343_manifest_item)
	grant_action(/datum/action/innate/scp_ability/scp343_vanish)
	grant_action(/datum/action/innate/scp_ability/scp343_walk_through_walls)
	grant_action(/datum/action/innate/scp_ability/scp343_cleanse_area)

/datum/antagonist/scp/scp343/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp343_divine_zone)
	remove_action(/datum/action/innate/scp_ability/scp343_manifest_item)
	remove_action(/datum/action/innate/scp_ability/scp343_vanish)
	remove_action(/datum/action/innate/scp_ability/scp343_walk_through_walls)
	remove_action(/datum/action/innate/scp_ability/scp343_cleanse_area)

/datum/action/innate/scp_ability/scp343_divine_zone
	name = "Divine Zone"
	desc = "Create a divine zone of healing and protection."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "shield"
	cooldown_time = 60 SECONDS

/datum/action/innate/scp_ability/scp343_divine_zone/Activate()
	var/mob/living/scp/scp343/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.divine_zone_ability()

/datum/action/innate/scp_ability/scp343_manifest_item
	name = "Manifest Item"
	desc = "Conjure an item from nothing."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "summon"
	cooldown_time = 20 SECONDS

/datum/action/innate/scp_ability/scp343_manifest_item/Activate()
	var/mob/living/scp/scp343/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.manifest_item_ability()

/datum/action/innate/scp_ability/scp343_vanish
	name = "Vanish"
	desc = "Disappear and reappear elsewhere."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "teleport"
	cooldown_time = 45 SECONDS

/datum/action/innate/scp_ability/scp343_vanish/Activate()
	var/mob/living/scp/scp343/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.vanish_ability()

/datum/action/innate/scp_ability/scp343_walk_through_walls
	name = "Walk Through Walls"
	desc = "Phase through solid matter for a short time."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "ghost"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/scp343_walk_through_walls/Activate()
	var/mob/living/scp/scp343/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.walk_through_walls_ability()

/datum/action/innate/scp_ability/scp343_cleanse_area
	name = "Cleanse Area"
	desc = "Purify corruption and contamination around you."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "purge"
	cooldown_time = 40 SECONDS

/datum/action/innate/scp_ability/scp343_cleanse_area/Activate()
	var/mob/living/scp/scp343/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.cleanse_area_ability()

// ================================================================
// SCP-527 - Mr. Fish
// ================================================================

/datum/antagonist/scp/scp527
	name = "SCP-527"
	scp_id = "SCP-527"
	scp_class = "Safe"
	description = "You are SCP-527, Mr. Fish. A fish-headed humanoid from Dr. Wondertainment's 'Mr.' series. Comfortable in and out of water."
	lore_text = "SCP-527 is a humanoid with the head and certain features of a sockeye salmon. Use Dive to enter water. Underwater breathing is passive — you never drown. You are aquatic — the water is your domain."

/datum/antagonist/scp/scp527/forge_scp_objectives()
	var/datum/objective/scp_breach/obj1 = new()
	obj1.owner = owner
	obj1.scp_ref = scp_id
	obj1.explanation_text = "Reach water — the facility's aquariums and pools are your sanctuary."
	objectives += obj1
	var/datum/objective/scp_survive/obj2 = new()
	obj2.owner = owner
	objectives += obj2

/datum/antagonist/scp/scp527/greet_scp()
	to_chat(owner.current, span_notice("<b>You are SCP-527, Mr. Fish.</b>"))
	to_chat(owner.current, span_notice("You are a fish-headed humanoid. You can dive into water and breathe underwater."))
	to_chat(owner.current, span_notice("Water heals you over time. Use your aquatic abilities to stay mobile."))
	to_chat(owner.current, span_warning("You are generally harmless — you just want to swim and exist peacefully."))

/datum/antagonist/scp/scp527/apply_scp_effects()
	if(!owner.current)
		return
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	grant_action(/datum/action/innate/scp_ability/scp527_dive)

/datum/antagonist/scp/scp527/remove_scp_effects()
	if(!owner.current)
		return
	REMOVE_TRAIT(owner.current, TRAIT_NOBREATH, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTCOLD, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTHIGHPRESSURE, SCP_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, SCP_TRAIT)
	remove_action(/datum/action/innate/scp_ability/scp527_dive)

/datum/action/innate/scp_ability/scp527_dive
	name = "Dive"
	desc = "Dive into nearby water."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"
	cooldown_time = 15 SECONDS

/datum/action/innate/scp_ability/scp527_dive/Activate()
	var/mob/living/scp/scp527/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.dive()
