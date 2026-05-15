/obj/machinery/elevator
	name = "Facility Elevator"
	desc = "A heavy-duty freight elevator for moving between facility levels."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/current_z = 1
	var/target_z = 2
	var/moving = FALSE
	var/move_delay = 50
	var/elevator_id = "main"
	var/list/linked_doors = list()
	var/announcing = TRUE

/obj/machinery/elevator/Initialize(mapload)
	. = ..()
	current_z = z
	LAZYADD(GLOB.elevators, src)

/obj/machinery/elevator/Destroy()
	LAZYREMOVE(GLOB.elevators, src)
	return ..()

/obj/machinery/elevator/attack_hand(mob/user)
	if(moving)
		to_chat(user, span_warning("The elevator is already in motion."))
		return
	ui_interact(user)

/obj/machinery/elevator/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationElevator", name)
		ui.open()

/obj/machinery/elevator/ui_data(mob/user)
	var/list/data = list()
	data["current_level"] = get_level_name(current_z)
	data["moving"] = moving
	data["available_levels"] = list()
	for(var/z_level in 1 to world.maxz)
		if(z_level == current_z)
			continue
		if(has_elevator_stop(z_level))
			data["available_levels"] += list(list(
				"z" = z_level,
				"name" = get_level_name(z_level),
			))
	return data

/obj/machinery/elevator/proc/get_level_name(z_level)
	switch(z_level)
		if(1)
			return "Surface - Gate A"
		if(2)
			return "Entrance Zone"
		if(3)
			return "Light Containment Zone"
		if(4)
			return "Heavy Containment Zone"
		else
			return "Level [z_level]"

/obj/machinery/elevator/proc/has_elevator_stop(z_level)
	return TRUE

/obj/machinery/elevator/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("goto_level")
			var/target = text2num(params["z"])
			if(!target || target == current_z || moving)
				return
			start_move(target)

/obj/machinery/elevator/proc/start_move(new_z)
	if(moving)
		return
	moving = TRUE
	target_z = new_z

	if(announcing)
		var/level_name = get_level_name(target_z)
		visible_message(span_notice("Elevator departing for [level_name]. Please stand clear of the doors."))

	addtimer(CALLBACK(src, /obj/machinery/elevator/proc/complete_move), move_delay)

/obj/machinery/elevator/proc/complete_move()
	if(!moving)
		return

	var/turf/T = locate(x, y, target_z)
	if(T)
		for(var/atom/movable/AM in get_turf(src))
			if(AM == src)
				continue
			if(ismob(AM) || isobj(AM))
				AM.forceMove(locate(x, y, target_z))

	current_z = target_z
	moving = FALSE

	if(announcing)
		var/level_name = get_level_name(current_z)
		visible_message(span_notice("Elevator arriving at [level_name]."))

/obj/machinery/elevator_button
	name = "Elevator Call Button"
	desc = "Press to call the elevator to this level."
	icon = 'icons/obj/objects.dmi'
	icon_state = "doorctrl0"
	anchored = TRUE
	var/elevator_id = "main"

/obj/machinery/elevator_button/attack_hand(mob/user)
	for(var/obj/machinery/elevator/E in GLOB.elevators)
		if(E.elevator_id == elevator_id && !E.moving)
			E.start_move(z)
			playsound(src, 'sound/machines/doors/airlock_close.ogg', 50, TRUE)
			to_chat(user, span_notice("Elevator called."))
			return
	to_chat(user, span_warning("Elevator is currently unavailable."))

GLOBAL_LIST_EMPTY(elevators)
