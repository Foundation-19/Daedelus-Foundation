/mob/dead/observer/proc/open_ghost_actions()
	set name = "Ghost Actions"
	set category = "Ghost"

	var/datum/ghost_actions_ui/actions_ui = new(src)
	actions_ui.ui_interact(src)

/datum/ghost_actions_ui
	var/mob/dead/observer/owner

/datum/ghost_actions_ui/New(mob/dead/observer/owner)
	src.owner = owner

/datum/ghost_actions_ui/Destroy()
	owner = null
	return ..()

/datum/ghost_actions_ui/ui_state(mob/user)
	return GLOB.observer_state

/datum/ghost_actions_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GhostActions", "SCiPNet Ghost Interface")
		ui.open()

/datum/ghost_actions_ui/ui_data(mob/user)
	var/list/data = list()

	data["can_reenter"] = owner.can_reenter_corpse && owner.mind && !QDELETED(owner.mind.current)
	data["has_body"] = owner.mind && !QDELETED(owner.mind.current)
	data["data_huds_on"] = owner.data_huds_on
	data["health_scan"] = owner.health_scan
	data["chem_scan"] = owner.chem_scan
	data["gas_scan"] = owner.gas_scan
	data["exorcised"] = owner.exorcised
	data["following"] = owner.following ? owner.following.name : null
	data["ghost_orbit"] = owner.ghost_orbit

	var/static/list/orbit_modes = list(
		GHOST_ORBIT_CIRCLE,
		GHOST_ORBIT_TRIANGLE,
		GHOST_ORBIT_SQUARE,
		GHOST_ORBIT_HEXAGON,
		GHOST_ORBIT_PENTAGON,
	)
	var/list/modes_data = list()
	for(var/mode in orbit_modes)
		modes_data += list(list("id" = mode, "name" = capitalize(mode)))
	data["orbit_modes"] = modes_data

	return data

/datum/ghost_actions_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(!isobserver(usr))
		return

	switch(action)
		if("reenter_corpse")
			owner.reenter_corpse()
			. = TRUE
		if("stay_dead")
			owner.stay_dead()
			. = TRUE
		if("teleport")
			owner.dead_tele()
			. = TRUE
		if("follow")
			owner.follow()
			. = TRUE
		if("toggle_data_huds")
			owner.toggle_data_huds()
			. = TRUE
		if("toggle_health_scan")
			owner.health_scan = !owner.health_scan
			. = TRUE
		if("toggle_chem_scan")
			owner.chem_scan = !owner.chem_scan
			. = TRUE
		if("toggle_gas_scan")
			owner.gas_scan = !owner.gas_scan
			. = TRUE
		if("orbit_mode")
			var/mode = params["mode"]
			if(mode in list(GHOST_ORBIT_CIRCLE, GHOST_ORBIT_TRIANGLE, GHOST_ORBIT_SQUARE, GHOST_ORBIT_HEXAGON, GHOST_ORBIT_PENTAGON))
				owner.ghost_orbit = mode
			. = TRUE
		if("spawners_menu")
			owner.open_spawners_menu()
			. = TRUE
		if("minigames")
			owner.open_minigames_menu()
			. = TRUE
		if("pai")
			owner.register_pai()
			. = TRUE
