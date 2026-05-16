// SCP-049 Cure Action from Foundation-19 PR #13
// Provides a targeted cure action for SCP-049

/datum/action/scp049cure
	name = "Cure Target"
	desc = "Attempt to cure a target of the pestilence."
	button_icon = 'icons/scp/scp-049.dmi'
	button_icon_state = "cure"
	background_icon_state = "bg_default"

	/// Range for cure action
	var/cure_range = 2
	/// Cooldown for cure action
	var/cure_cooldown_time = 60 SECONDS
	/// Current cooldown
	var/cure_cooldown = 0

/datum/action/scp049cure/New(Target)
	..()
	// Don't delete if owner is not set yet - it will be set when granted
	if(owner && !istype(owner, /mob/living/scp/scp049))
		qdel(src)

/datum/action/scp049cure/IsAvailable(feedback = FALSE)
	if(!..())
		return FALSE

	if(!owner || !istype(owner, /mob/living/scp/scp049))
		return FALSE

	if(world.time < cure_cooldown)
		if(feedback)
			to_chat(owner, "<span class='warning'>The cure needs time to prepare...</span>")
		return FALSE

	// Check if there are any valid targets in range
	var/mob/living/scp/scp049/scp = owner
	for(var/mob/living/carbon/human/H in range(cure_range, scp))
		if(HAS_TRAIT(H, TRAIT_PESTILENCE))
			return TRUE

	if(feedback)
		to_chat(owner, "<span class='warning'>No afflicted targets in range.</span>")
	return FALSE

/datum/action/scp049cure/Trigger(trigger_flags)
	if(!..())
		return FALSE

	if(!IsAvailable(TRUE))
		return FALSE

	if(!owner || !istype(owner, /mob/living/scp/scp049))
		return FALSE

	var/mob/living/scp/scp049/scp = owner

	// Get list of valid targets
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(cure_range, scp))
		if(HAS_TRAIT(H, TRAIT_PESTILENCE))
			targets += H

	if(!length(targets))
		to_chat(scp, "<span class='warning'>No afflicted targets in range.</span>")
		return FALSE

	var/mob/living/carbon/human/target
	if(length(targets) == 1)
		target = targets[1]
	else
		target = input(scp, "Select target to cure:", "Cure Target") as null|mob in targets

	if(!target)
		return FALSE

	if(get_dist(scp, target) > cure_range)
		to_chat(scp, "<span class='warning'>Target is too far away.</span>")
		return FALSE

	if(!HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(scp, "<span class='warning'>Target is not afflicted with pestilence.</span>")
		return FALSE

	// Perform cure
	perform_cure(scp, target)
	return TRUE

/datum/action/scp049cure/proc/perform_cure(mob/living/scp/scp049/scp, mob/living/carbon/human/target)
	if(!scp || !target) // Safety check
		return

	cure_cooldown = world.time + cure_cooldown_time

	// Call the cure function
	scp.cure_target(target)

/datum/action/scp049cure/proc/update_cure_button()
	// Update button based on availability
	if(!owner) // Safety check
		return

	if(IsAvailable())
		button_icon_state = "cure"
	else
		button_icon_state = "cure_disabled"
	build_all_button_icons(UPDATE_BUTTON_ICON, FALSE)
