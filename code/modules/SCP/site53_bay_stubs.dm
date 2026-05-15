// Site53 map stubs - Bay/VORE types that don't exist in /tg/
// Placeholder types so the map loads without runtime errors

/obj/machinery/access_button
	name = "access button"



/obj/machinery/access_button/airlock_exterior
	name = "exterior access button"

/obj/machinery/access_button/airlock_interior
	name = "interior access button"

/obj/machinery/ai_status_display
	name = "AI display"



/obj/machinery/cryopod
	name = "cryogenic pod"



/obj/machinery/cryopod/living_quarters
	name = "living quarters pod"

/obj/machinery/cryopod/robot
	name = "robot storage pod"

/obj/machinery/embedded_controller/radio/airlock
	name = "airlock controller"

/obj/machinery/embedded_controller/radio/airlock/access_controller
	name = "access controller"

/obj/machinery/embedded_controller/radio/airlock/airlock_controller
	name = "airlock controller"

/obj/machinery/fabricator
	name = "fabricator"



/obj/machinery/fabricator/micro
	name = "micro fabricator"

/obj/machinery/fabricator/micro/bartender
	name = "bartender micro-fab"

/obj/machinery/message_server
	name = "message server"



/obj/machinery/optable
	name = "operating table"
	density = TRUE

/obj/machinery/psi_meter
	name = "psi meter"

/obj/machinery/r_n_d
	name = "R&D machine"

/obj/machinery/r_n_d/circuit_imprinter
	name = "circuit imprinter"

/obj/machinery/r_n_d/destructive_analyzer
	name = "destructive analyzer"

/obj/machinery/r_n_d/protolathe
	name = "protolathe"

/obj/machinery/r_n_d/server
	name = "R&D server"

/obj/machinery/r_n_d/server/core
	name = "core R&D server"

/obj/machinery/r_n_d/server/robotics
	name = "robotics R&D server"

/obj/machinery/self_destruct
	name = "self-destruct mechanism"

/obj/structure/scp_914
	name = "SCP-914"
	density = TRUE
	anchored = TRUE

/obj/structure/scp082_trunk
	name = "trunk"
	density = TRUE

	density = TRUE

/obj/structure/scp173_cage
	name = "containment cage"
	density = TRUE

	density = TRUE

/obj/turbolift_map_holder
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

/obj/turbolift_map_holder/Initialize(mapload)
	. = ..()
	current_z = z
	LAZYADD(GLOB.elevators, src)

/obj/turbolift_map_holder/Destroy()
	LAZYREMOVE(GLOB.elevators, src)
	return ..()

/obj/turbolift_map_holder/attack_hand(mob/user)
	if(moving)
		to_chat(user, span_warning("The elevator is already in motion."))
		return
	ui_interact(user)

/obj/turbolift_map_holder/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationElevator", name)
		ui.open()

/obj/turbolift_map_holder/ui_data(mob/user)
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

/obj/turbolift_map_holder/proc/get_level_name(z_level)
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

/obj/turbolift_map_holder/proc/has_elevator_stop(z_level)
	return TRUE

/obj/turbolift_map_holder/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "goto_level")
		var/target = text2num(params["z"])
		if(!target || target == current_z || moving)
			return
		start_move(target)

/obj/turbolift_map_holder/proc/start_move(new_z)
	if(moving)
		return
	moving = TRUE
	target_z = new_z
	if(announcing)
		var/level_name = get_level_name(target_z)
		visible_message(span_notice("Elevator departing for [level_name]. Please stand clear of the doors."))
	addtimer(CALLBACK(src, /obj/turbolift_map_holder/proc/complete_move), move_delay)

/obj/turbolift_map_holder/proc/complete_move()
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

/obj/turbolift_map_holder/commstower
	name = "Communications Tower Elevator"
	elevator_id = "commstower"

/obj/turbolift_map_holder/gatea
	name = "Gate A Elevator"
	elevator_id = "gatea"

/obj/turbolift_map_holder/hcz082
	name = "HCZ-082 Elevator"
	elevator_id = "hcz082"

/obj/turbolift_map_holder/robotics
	name = "Robotics Elevator"
	elevator_id = "robotics"

/obj/turbolift_map_holder/scp106
	name = "SCP-106 Elevator"
	elevator_id = "scp106"

/obj/turbolift_map_holder/uhcztolhcz
	name = "UHCZ-LHCZ Elevator"
	elevator_id = "uhcztolhcz"

/obj/vehicle/train
	name = "train"

/obj/vehicle/train/cargo
	name = "cargo train"

/obj/vehicle/train/cargo/engine
	name = "cargo engine"

/obj/vehicle/train/cargo/trolley
	name = "cargo trolley"

/obj/machinery/deployable
	name = "deployable barrier"

/obj/machinery/holoposter
	name = "holoposter"

/obj/structure/window/bulletproof
	name = "bulletproof window"

/obj/effect/turf_decal/corner/euclid
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/border
	icon_state = "bordercolor"
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/bordercorner
	icon_state = "bordercolorcorner"
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/mono
	icon_state = "bordercolormonofull"
	color = "#CCFF00"

/obj/effect/turf_decal/corner/keter
	color = "#FF0000"

/obj/effect/turf_decal/corner/keter/border
	icon_state = "bordercolor"
	color = "#FF0000"

/obj/effect/turf_decal/corner/keter/bordercorner
	icon_state = "bordercolorcorner"
	color = "#FF0000"

/obj/effect/turf_decal/corner/safe
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/border
	icon_state = "bordercolor"
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/bordercorner
	icon_state = "bordercolorcorner"
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/mono
	icon_state = "bordercolormonofull"
	color = "#00CC00"

/obj/effect/turf_decal/corner/research
	color = "#9933FF"

/obj/effect/turf_decal/corner/research/border
	icon_state = "bordercolor"
	color = "#9933FF"

/obj/effect/turf_decal/corner/paleblue
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/border
	icon_state = "bordercolor"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/bordercorner
	icon_state = "bordercolorcorner"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/diagonal
	icon_state = "corner_white_diagonal"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/mono
	icon_state = "bordercolormonofull"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/half
	icon_state = "bordercolorhalf"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/beige
	color = "#C8A882"

/obj/effect/turf_decal/corner/beige/border
	icon_state = "bordercolor"
	color = "#C8A882"

/obj/effect/turf_decal/corner/beige/mono
	icon_state = "bordercolormonofull"
	color = "#C8A882"

/obj/effect/turf_decal/corner/b_green
	color = "#00FF00"

/obj/effect/turf_decal/corner/b_green/border
	icon_state = "bordercolor"
	color = "#00FF00"

/obj/effect/turf_decal/corner/lime
	color = "#99FF00"

/obj/effect/turf_decal/corner/lime/border
	icon_state = "bordercolor"
	color = "#99FF00"

/obj/effect/turf_decal/corner/lime/bordercorner
	icon_state = "bordercolorcorner"
	color = "#99FF00"

/obj/effect/turf_decal/corner/purple
	color = "#CC00FF"

/obj/effect/turf_decal/corner/purple/border
	icon_state = "bordercolor"
	color = "#CC00FF"

/obj/effect/turf_decal/corner/brown
	color = "#865C2A"

/obj/effect/turf_decal/corner/brown/border
	icon_state = "bordercolor"
	color = "#865C2A"

/obj/effect/turf_decal/corner/brown/bordercorner
	icon_state = "bordercolorcorner"
	color = "#865C2A"

/obj/effect/turf_decal/corner/brown/mono
	icon_state = "bordercolormonofull"
	color = "#865C2A"

/obj/effect/turf_decal/corner/orange
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/border
	icon_state = "bordercolor"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/bordercorner
	icon_state = "bordercolorcorner"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/mono
	icon_state = "bordercolormonofull"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/half
	icon_state = "bordercolorhalf"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/three_quarters
	icon_state = "corner_white_three_quarters"
	color = "#FF9900"

/obj/effect/turf_decal/corner/green
	color = "#00CC00"

/obj/effect/turf_decal/corner/green/border
	icon_state = "bordercolor"
	color = "#00CC00"

/obj/effect/turf_decal/corner/green/bordercorner
	icon_state = "bordercolorcorner"
	color = "#00CC00"

/obj/effect/turf_decal/corner/green/mono
	icon_state = "bordercolormonofull"
	color = "#00CC00"

/obj/effect/turf_decal/corner/grey
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/grey/border
	icon_state = "bordercolor"
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/grey/mono
	icon_state = "bordercolormonofull"
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/black
	color = "#333333"

/obj/effect/turf_decal/corner/black/border
	icon_state = "bordercolor"
	color = "#333333"

/obj/effect/turf_decal/corner/black/diagonal
	icon_state = "corner_white_diagonal"
	color = "#333333"

/obj/effect/turf_decal/corner/black/full
	icon_state = "corner_white_full"
	color = "#333333"

/obj/effect/turf_decal/corner/blue
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/border
	icon_state = "bordercolor"
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/bordercorner
	icon_state = "bordercolorcorner"
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/mono
	icon_state = "bordercolormonofull"
	color = "#0066FF"

/obj/effect/turf_decal/corner/yellow
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/border
	icon_state = "bordercolor"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/bordercorner
	icon_state = "bordercolorcorner"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/mono
	icon_state = "bordercolormonofull"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/diagonal
	icon_state = "corner_white_diagonal"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/half
	icon_state = "bordercolorhalf"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/three_quarters
	icon_state = "corner_white_three_quarters"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/red
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/border
	icon_state = "bordercolor"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/bordercorner
	icon_state = "bordercolorcorner"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/bordercee
	icon_state = "bordercolorcee"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/diagonal
	icon_state = "corner_white_diagonal"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/mono
	icon_state = "bordercolormonofull"
	color = "#CC0000"

/obj/effect/turf_decal/stripes/red
	icon_state = "warning"
	color = "#CC0000"

/obj/effect/turf_decal/stripes/yellow
	icon_state = "warning"
	color = "#FFCC00"

/obj/effect/turf_decal/stripes/orange
	icon_state = "warning"
	color = "#FF9900"

/obj/effect/turf_decal/stripes/brown
	icon_state = "warning"
	color = "#865C2A"

/obj/effect/turf_decal/stripes/blue
	icon_state = "warning"
	color = "#0066FF"

/obj/effect/turf_decal/stripes/gray
	icon_state = "warning"
	color = "#8D8C8C"

/obj/effect/turf_decal/stripes/mauve
	icon_state = "warning"
	color = "#CC00FF"

/obj/effect/turf_decal/stripes/paleblue
	icon_state = "warning"
	color = "#66B2FF"

/obj/effect/turf_decal/industrial/warning
	icon_state = "warning"

/obj/effect/turf_decal/industrial/warning/corner
	icon_state = "warningcorner"

/obj/effect/turf_decal/industrial/outline
	icon_state = "outline"

/obj/effect/turf_decal/industrial/outline/yellow
	icon_state = "outline"
	color = "#FFCC00"

/obj/effect/turf_decal/industrial/outline/red
	icon_state = "outline"
	color = "#CC0000"

/obj/effect/turf_decal/industrial/outline/orange
	icon_state = "outline"
	color = "#FF9900"

/obj/effect/turf_decal/industrial/hatch
	icon_state = "delivery"

/obj/effect/turf_decal/industrial/hatch/red
	icon_state = "delivery"
	color = "#CC0000"

/obj/effect/turf_decal/industrial/hatch/yellow
	icon_state = "delivery"
	color = "#FFCC00"

/obj/effect/turf_decal/carpet/green
	icon_state = "carpet_green"

/obj/effect/turf_decal/carpet/orange
	icon_state = "carpet_orange"

/obj/effect/turf_decal/chapel
	icon_state = "chapel"

/obj/effect/turf_decal/spline/fancy/black
	icon_state = "spline_fancy_black"

/obj/effect/turf_decal/spline/fancy/black/corner
	icon_state = "spline_fancy_black_corner"

/obj/effect/turf_decal/spline/fancy/wood
	icon_state = "spline_fancy_wood"

/obj/effect/turf_decal/spline/plain/white
	icon_state = "spline_plain_white"

/obj/effect/landmark/reinforced
	name = "reinforced landmark"

/obj/effect/landmark/reinforced/titanium
	name = "reinforced titanium landmark"

/obj/effect/landmark/reinforced_phoron
	name = "reinforced phoron landmark"

/obj/effect/landmark/reinforced_phoron/titanium
	name = "reinforced phoron titanium landmark"