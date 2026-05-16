/mob/living/scp/scp966
	name = "SCP-966"
	desc = "An invisible creature that causes sleep deprivation. You can barely make out its shimmering outline."
	icon = 'icons/scp/scp-966.dmi'
	icon_state = "scp966"
	real_name = "SCP-966"
	status_flags = 0

	var/datum/scp966_sleep_system/sleep_system
	var/datum/scp966_stealth_system/stealth_system
	var/datum/scp966_stalk_system/stalk_system
	var/datum/scp966_nightmare_system/nightmare_system
	var/datum/scp966_research_system/research_system

	var/victims_sleep_deprived = 0
	var/stalk_targets = 0
	var/nightmares_caused = 0

/mob/living/scp/scp966/Initialize()
	. = ..()
	set_species(/datum/species/scp966)
	SCP = new /datum/scp(src, "Sleep Killer", SCP_EUCLID, "966", SCP_PLAYABLE)
	SCP.min_playercount = 25
	SCP.min_time = 10 MINUTES

	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	grant_language(/datum/language/common, TRUE, TRUE)

/mob/living/scp/scp966/proc/initialize_systems()
	sleep_system = new /datum/scp966_sleep_system(src)
	stealth_system = new /datum/scp966_stealth_system(src)
	stalk_system = new /datum/scp966_stalk_system(src)
	nightmare_system = new /datum/scp966_nightmare_system(src)
	research_system = new /datum/scp966_research_system(src)

/mob/living/scp/scp966/Destroy()
	QDEL_NULL(sleep_system)
	QDEL_NULL(stealth_system)
	QDEL_NULL(stalk_system)
	QDEL_NULL(nightmare_system)
	QDEL_NULL(research_system)
	return ..()

/mob/living/scp/scp966/Life()
	. = ..()
	if(stat == DEAD)
		return

	sleep_system?.process_sleep()
	stealth_system?.process_stealth()
	stalk_system?.process_stalk()
	nightmare_system?.process_nightmares()
	research_system?.process_research()

/mob/living/scp/scp966/UnarmedAttack(atom/A)
	if(!ishuman(A))
		return ..()

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return ..()

	if(sleep_system && H.drowsyness >= 30)
		H.apply_damage(sleep_system.intensity * 3, BRUTE)
		H.visible_message("<span class='danger'>Something invisible slashes at [H]!</span>", "<span class='danger'>You feel claws tear into you!</span>")
		hook_scp_combat(H, "SCP-966", sleep_system.intensity * 3, 10)
		return

	to_chat(src, "<span class='warning'>[H] is too alert to attack effectively. Weaken them first with sleep deprivation.</span>")

/mob/living/scp/scp966/proc/toggle_invisibility()
	if(stealth_system?.active)
		stealth_system.active = FALSE
		to_chat(src, "<span class='notice'>You become more visible.</span>")
	else if(stealth_system)
		stealth_system.active = TRUE
		to_chat(src, "<span class='notice'>You fade into the shadows.</span>")

/mob/living/scp/scp966/proc/induce_insomnia()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H.stat != DEAD && H != src)
			targets += H

	if(!length(targets))
		to_chat(src, "<span class='warning'>No valid targets nearby.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose target:", "Induce Insomnia") as null|anything in targets
	if(!target)
		return

	if(sleep_system)
		sleep_system.intensity = min(sleep_system.max_intensity, sleep_system.intensity + 1)
		target.drowsyness = max(0, target.drowsyness - 20)
		victims_sleep_deprived++
		hook_scp_interaction(target, "SCP-966", INTERACTION_TYPE_COMBAT)
		to_chat(target, "<span class='danger'>A wave of unnatural wakefulness crashes over you! You feel exhausted but cannot sleep.</span>")

/mob/living/scp/scp966/proc/stalk_target()
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(15, src))
		if(H.stat != DEAD && H != src)
			targets += H

	if(!length(targets))
		to_chat(src, "<span class='warning'>No valid targets nearby.</span>")
		return

	var/mob/living/carbon/human/target = input(src, "Choose target to stalk:", "Stalk") as null|anything in targets
	if(!target)
		return

	if(stalk_system && !(target in stalk_system.stalked))
		stalk_system.stalked += target
		stalk_targets++
		hook_scp_interaction(target, "SCP-966", INTERACTION_TYPE_OBSERVATION)
		to_chat(target, "<span class='danger'>You feel an unseen gaze upon you...</span>")

/mob/living/scp/scp966/proc/get_scp_status()
	var/list/status = list()
	status += "=== SCP-966 Status ==="
	status += "Sleep aura active"
	status += "Stalked: [length(stalk_system?.stalked) || 0]"
	status += "Victims deprived: [victims_sleep_deprived]"
	status += "Nightmares caused: [nightmares_caused]"
	return status

/mob/living/scp/scp966/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(H, "<span class='warning'>SCP-966: A sleep-inducing predator. Victims suffer extreme sleep deprivation before being attacked.</span>")
		else
			var/can_see = FALSE
			if(istype(H.glasses, /obj/item/clothing/glasses/night))
				can_see = TRUE
			if(H.has_quirk(/datum/quirk/item_quirk/nearsighted))
				can_see = FALSE
			if(can_see)
				to_chat(H, "<span class='warning'>Through your lenses, you can make out a thin, skeletal figure crouching in the air...</span>")
			else
				to_chat(H, "<span class='warning'>You can barely see something shimmering in the air...</span>")

/mob/living/scp/scp966/get_status_tab_items()
	. = ..()
	. += "Victims Deprived: [victims_sleep_deprived]"
	. += "Stalked Targets: [length(stalk_system?.stalked) || 0]"
	. += "Nightmares Caused: [nightmares_caused]"
	. += "Sleep Intensity: [sleep_system?.intensity || 0]/[sleep_system?.max_intensity || 5]"
