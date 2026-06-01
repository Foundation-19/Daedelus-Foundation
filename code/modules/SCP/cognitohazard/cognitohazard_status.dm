/datum/movespeed_modifier/flesh_corruption
	slowdown = 0.5

/datum/status_effect/cognitohazard_exposure
	id = "cognitohazard_exposure"
	duration = -1
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_CHANGE
	exclusive_group = "scp_cognitohazard"
	alert_type = /atom/movable/screen/alert/status_effect/cognitohazard_exposure

	var/accumulation = 0
	var/max_accumulation = 100
	var/current_tier = 0
	var/source_id = "generic"
	var/darkness_amplified = FALSE
	var/protection_level = COGNITOHAZARD_PROTECTION_NONE

	var/list/tier_messages = list(
		"",
		"You feel a growing sense of unease...",
		"Paranoid thoughts creep into your mind...",
		"You begin to see things that aren't there...",
		"A compulsion grips you, your body fights against itself...",
		"Your mind fractures under the strain. Reality breaks apart.",
	)

	var/list/tier_thresholds = list(
		COGNITOHAZARD_TIER_1_THRESHOLD,
		COGNITOHAZARD_TIER_2_THRESHOLD,
		COGNITOHAZARD_TIER_3_THRESHOLD,
		COGNITOHAZARD_TIER_4_THRESHOLD,
		COGNITOHAZARD_TIER_5_THRESHOLD,
	)

/datum/status_effect/cognitohazard_exposure/pre_check()
	if(!ishuman(owner))
		return FALSE
	if(owner.stat == DEAD)
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_SCP610_IMMUNE))
		return FALSE
	if(owner.SCP)
		return FALSE
	return TRUE

/datum/status_effect/cognitohazard_exposure/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_change))
	update_protection()
	return TRUE

/datum/status_effect/cognitohazard_exposure/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
	if(current_tier >= COGNITOHAZARD_TIER_HALLUCINATION)
		clear_hallucinations()

/datum/status_effect/cognitohazard_exposure/on_change(list/arguments)
	if(length(arguments) < 3)
		return
	var/extra_accumulation = arguments[3]
	if(extra_accumulation <= 0)
		return
	extra_accumulation = modify_change(extra_accumulation)
	if(extra_accumulation <= 0)
		return
	accumulation = min(accumulation + extra_accumulation, max_accumulation)
	update_tier()

/datum/status_effect/cognitohazard_exposure/modify_change(change_amount)
	if(protection_level >= COGNITOHAZARD_PROTECTION_FULL)
		return 0
	return change_amount * (1 - protection_level)

/datum/status_effect/cognitohazard_exposure/tick(delta_time, times_fired)
	if(owner.stat == DEAD)
		qdel(src)
		return

	update_protection()
	update_darkness()

	accumulation = max(0, accumulation - COGNITOHAZARD_DECAY_RATE)

	if(protection_level < COGNITOHAZARD_PROTECTION_FULL && accumulation < max_accumulation)
		var/growth = COGNITOHAZARD_ACCUMULATION_RATE
		if(darkness_amplified)
			growth *= COGNITOHAZARD_DARKNESS_MULTIPLIER
		accumulation = min(accumulation + growth, max_accumulation)

	update_tier()
	apply_tier_effects()

/datum/status_effect/cognitohazard_exposure/proc/update_protection()
	protection_level = COGNITOHAZARD_PROTECTION_NONE

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	if(istype(H.wear_suit, /obj/item/clothing/suit/bio_suit))
		protection_level += COGNITOHAZARD_PROTECTION_PARTIAL

	if(istype(H.head, /obj/item/clothing/head/bio_hood))
		protection_level += COGNITOHAZARD_PROTECTION_PARTIAL

	if(istype(H.wear_mask, /obj/item/clothing/mask/gas))
		protection_level += COGNITOHAZARD_PROTECTION_PARTIAL

	if(H.has_status_effect(/datum/status_effect/memetic_shield))
		protection_level += COGNITOHAZARD_PROTECTION_PARTIAL

	protection_level = clamp(protection_level, 0, 1)

/datum/status_effect/cognitohazard_exposure/proc/update_darkness()
	var/turf/T = get_turf(owner)
	if(!T)
		darkness_amplified = FALSE
		return
	darkness_amplified = T.get_lumcount() < 0.3

/datum/status_effect/cognitohazard_exposure/proc/update_tier()
	var/new_tier = 0
	for(var/i in 1 to length(tier_thresholds))
		if(accumulation >= tier_thresholds[i])
			new_tier = i

	if(new_tier != current_tier)
		if(new_tier > current_tier)
			on_tier_escalation(current_tier, new_tier)
		else
			on_tier_deescalation(current_tier, new_tier)
		current_tier = new_tier

	if(linked_alert)
		linked_alert.desc = "Cognitohazard exposure: [round(accumulation, 0.1)]% | Tier [current_tier] | Source: [source_id]"

/datum/status_effect/cognitohazard_exposure/proc/on_tier_escalation(old_tier, new_tier)
	if(new_tier >= 1 && new_tier <= 5)
		to_chat(owner, span_warning(tier_messages[new_tier]))

/datum/status_effect/cognitohazard_exposure/proc/on_tier_deescalation(old_tier, new_tier)
	if(old_tier >= COGNITOHAZARD_TIER_HALLUCINATION && new_tier < COGNITOHAZARD_TIER_HALLUCINATION)
		clear_hallucinations()

/datum/status_effect/cognitohazard_exposure/proc/apply_tier_effects()
	var/strength = current_tier * 0.2

	switch(current_tier)
		if(COGNITOHAZARD_TIER_UNEASE)
			if(prob(3 * strength))
				owner.emote("shiver")

		if(COGNITOHAZARD_TIER_PARANOIA)
			if(prob(5 * strength))
				owner.adjust_drugginess(2 SECONDS)
			if(prob(3 * strength))
				owner.add_movespeed_modifier(/datum/movespeed_modifier/flesh_corruption)
				addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/flesh_corruption), 3 SECONDS)

		if(COGNITOHAZARD_TIER_HALLUCINATION)
			if(prob(5 * strength))
				spawn_hallucination()
			if(prob(5 * strength))
				owner.hallucination += 5

		if(COGNITOHAZARD_TIER_COMPULSION)
			if(prob(8 * strength))
				owner.adjustBruteLoss(2)
			if(prob(5 * strength))
				owner.hallucination += 8
			if(prob(3 * strength))
				spawn_hallucination()

		if(COGNITOHAZARD_TIER_BREAKDOWN)
			if(prob(10 * strength))
				owner.adjustBruteLoss(3)
				owner.adjustToxLoss(3)
			if(prob(8 * strength))
				owner.hallucination += 10
			if(prob(5 * strength))
				spawn_hallucination()
			if(prob(2 * strength))
				owner.adjustToxLoss(20, cause_of_death = "cognitohazard_cardiac_arrest")

/datum/status_effect/cognitohazard_exposure/proc/spawn_hallucination()
	if(!owner.client)
		return

	var/hallucination_type = rand(1, 3)
	switch(hallucination_type)
		if(1)
			var/list/sounds = list(
				'sound/effects/ghost.ogg',
				'sound/effects/ghost2.ogg',
				'sound/hallucinations/i_see_you1.ogg',
				'sound/hallucinations/wail.ogg',
			)
			owner.playsound_local(get_turf(owner), pick(sounds), 50, TRUE)
		if(2)
			var/list/alerts = list(
				"You hear whispers coming from the walls...",
				"Something is watching you from the shadows...",
				"The air itself seems to twist around you...",
				"A voice in your head screams warnings...",
			)
			to_chat(owner, span_boldannounce(pick(alerts)))
		if(3)
			var/turf/T = get_turf(owner)
			if(!T)
				return
			var/image/I = image(icon = 'icons/effects/effects.dmi', loc = T, icon_state = pick("nothing", "smoke"), layer = ABOVE_MOB_LAYER)
			owner.client.images += I
			addtimer(CALLBACK(src, PROC_REF(remove_hallucination_image), I), 8 SECONDS)

/datum/status_effect/cognitohazard_exposure/proc/remove_hallucination_image(image/I)
	if(owner?.client)
		owner.client.images -= I
	qdel(I)

/datum/status_effect/cognitohazard_exposure/proc/clear_hallucinations()
	if(!owner?.client)
		return
	var/list/to_remove = list()
	for(var/image/I in owner.client.images)
		if(I.icon == 'icons/effects/effects.dmi')
			to_remove += I
	for(var/image/I in to_remove)
		owner.client.images -= I
		qdel(I)

/datum/status_effect/cognitohazard_exposure/proc/on_z_change()
	SIGNAL_HANDLER
	update_protection()
	update_darkness()

/datum/status_effect/cognitohazard_exposure/get_examine_text()
	return span_warning("Subject shows signs of cognitohazard exposure (Tier [current_tier], [round(accumulation, 0.1)]% accumulation).")

/atom/movable/screen/alert/status_effect/cognitohazard_exposure
	name = "Cognitohazard Exposure"
	desc = "You are being exposed to a cognitohazardous effect."
	icon_state = "cult_sense"
