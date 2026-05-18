/datum/hud/ghost_scp
	var/mob/dead/observer/owner_ghost
	var/list/buttons = list()
	var/atom/movable/screen/button_track
	var/atom/movable/screen/button_orbit
	var/atom/movable/screen/button_breach_status

/datum/hud/ghost_scp/New(mob/dead/observer/O)
	..()
	owner_ghost = O
	setup_buttons()

/datum/hud/ghost_scp/proc/setup_buttons()
	button_track = new /atom/movable/screen/ghost_scp/track()
	button_track.hud = src
	button_track.screen_loc = "CENTER-2:0,SOUTH+1:0"

	button_orbit = new /atom/movable/screen/ghost_scp/orbit()
	button_orbit.hud = src
	button_orbit.screen_loc = "CENTER:0,SOUTH+1:0"

	button_breach_status = new /atom/movable/screen/ghost_scp/breach_status()
	button_breach_status.hud = src
	button_breach_status.screen_loc = "CENTER+2:0,SOUTH+1:0"

	buttons = list(button_track, button_orbit, button_breach_status)

/datum/hud/ghost_scp/proc/show_to(mob/dead/observer/O)
	if(!O.client)
		return
	for(var/atom/movable/screen/S in buttons)
		O.client.screen += S

/datum/hud/ghost_scp/proc/hide_from(mob/dead/observer/O)
	if(!O.client)
		return
	for(var/atom/movable/screen/S in buttons)
		O.client.screen -= S

/datum/hud/ghost_scp/proc/get_scp_list()
	var/list/scp_tracked = list()
	for(var/mob/living/L in GLOB.mob_living_list)
		if(!istype(L, /mob/living/scp))
			continue
		if(L.stat == DEAD)
			continue
		scp_tracked += L
	return scp_tracked

/datum/hud/ghost_scp/proc/get_breach_info()
	var/list/breached = list()
	for(var/mob/living/L in GLOB.mob_living_list)
		if(!istype(L, /mob/living/scp))
			continue
		if(L.stat == DEAD)
			continue
		var/containment_status = "contained"
		if("containment_status" in L.vars)
			containment_status = L.vars["containment_status"]
		if(containment_status == "breached")
			breached += L
	return breached

/atom/movable/screen/ghost_scp
	icon = 'icons/mob/hud.dmi'

/atom/movable/screen/ghost_scp/track
	name = "Track SCPs"
	icon_state = "hudhealthy"

/atom/movable/screen/ghost_scp/track/Click()
	..()
	if(!hud || !usr)
		return

	var/datum/hud/ghost_scp/scp_hud = hud
	var/list/scps = scp_hud.get_scp_list()
	if(!length(scps))
		to_chat(usr, span_notice("No active SCPs detected."))
		return

	var/list/choices = list()
	for(var/mob/living/L in scps)
		choices["[L.name] ([get_area_name(L, TRUE)])"] = L

	var/choice = input(usr, "Select an SCP to track:", "SCP Tracking") as null|anything in choices
	if(!choice)
		return

	var/mob/living/target = choices[choice]
	if(target && usr)
		var/mob/dead/observer/O = usr
		O.ManualFollow(target)

/atom/movable/screen/ghost_scp/orbit
	name = "Orbit Breached SCPs"
	icon_state = "hudill1"

/atom/movable/screen/ghost_scp/orbit/Click()
	..()
	if(!hud || !usr)
		return

	var/datum/hud/ghost_scp/scp_hud = hud
	var/list/breached = scp_hud.get_breach_info()
	if(!length(breached))
		to_chat(usr, span_notice("No breached SCPs detected."))
		return

	var/mob/living/target = pick(breached)
	var/mob/dead/observer/O = usr
	O.ManualFollow(target)

/atom/movable/screen/ghost_scp/breach_status
	name = "Breach Status"
	icon_state = "huddead"

/atom/movable/screen/ghost_scp/breach_status/Click()
	..()
	if(!hud || !usr)
		return

	var/datum/hud/ghost_scp/scp_hud = hud
	var/list/breached = scp_hud.get_breach_info()
	var/list/contained = list()

	for(var/mob/living/L in GLOB.mob_living_list)
		if(!istype(L, /mob/living/scp))
			continue
		if(L.stat == DEAD)
			continue
		var/containment_status = "contained"
		if("containment_status" in L.vars)
			containment_status = L.vars["containment_status"]
		if(containment_status == "contained")
			contained += L

	to_chat(usr, span_notice("<b>SCP Breach Status Report</b>"))
	to_chat(usr, span_notice("Contained: [length(contained)] | Breached: [length(breached)]"))

	for(var/mob/living/S in breached)
		to_chat(usr, span_danger("[S.name] — BREACHED — [get_area_name(S, TRUE)]"))

	for(var/mob/living/S in contained)
		to_chat(usr, span_notice("[S.name] — CONTAINED"))

/mob/dead/observer/var/scp_ghost_hud_active = FALSE

/mob/dead/observer/verb/toggle_scp_hud()
	set name = "Toggle SCP HUD"
	set category = "Ghost"
	set desc = "Toggle the SCP tracking HUD for ghosts."

	if(!client)
		return

	var/datum/hud/ghost_scp/scp_hud_datum = new(src)
	if(scp_ghost_hud_active)
		scp_ghost_hud_active = FALSE
		scp_hud_datum.hide_from(src)
		to_chat(src, span_notice("SCP HUD disabled."))
	else
		scp_ghost_hud_active = TRUE
		scp_hud_datum.show_to(src)
		to_chat(src, span_notice("SCP HUD enabled. Use the buttons to track SCPs."))
