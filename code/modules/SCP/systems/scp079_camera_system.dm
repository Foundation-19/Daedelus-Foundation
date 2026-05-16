/datum/action/innate/scp_ability/scp079_camera_interface
	name = "Camera Network Interface"
	desc = "Open the full camera network interface."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "camera_hop"
	cooldown_time = 5 SECONDS

/datum/action/innate/scp_ability/scp079_camera_interface/Activate()
	var/mob/living/scp079/scp_mob = owner
	if(!istype(scp_mob))
		return
	start_cooldown()
	scp_mob.ui_interact(owner)
