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
	var/moving = FALSE
	var/elevator_id = ""
	var/announcing = TRUE

/obj/turbolift_map_holder/Initialize(mapload)
	. = ..()
	current_z = z

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
	data["current_floor"] = z
	data["moving"] = moving
	data["door_open"] = FALSE
	data["floors"] = list()
	var/obj/docking_port/mobile/elevator/foundation/E = SSshuttle.getShuttle(elevator_id)
	if(E)
		data["moving"] = (E.mode != SHUTTLE_IDLE)
		var/current_dock_id = E.getDockedId()
		for(var/obj/docking_port/stationary/foundation_elevator/dock in SSshuttle.stationary_docking_ports)
			if(!(dock.id in get_destinations()))
				continue
			var/is_current = (dock.id == current_dock_id)
			data["floors"] += list(list(
				"id" = dock.id,
				"name" = dock.name,
				"accessible" = TRUE,
			))
			if(is_current)
				data["current_floor"] = dock.id
	else
		data["floors"] = list(
			list("id" = "upper", "name" = "Upper Level", "accessible" = TRUE),
			list("id" = "lower", "name" = "Lower Level", "accessible" = TRUE),
		)
	return data

/obj/turbolift_map_holder/proc/get_destinations()
	return list()

/obj/turbolift_map_holder/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "goto")
		var/target_dock = params["floor"]
		if(!target_dock || moving)
			return
		if(elevator_id)
			SSshuttle.moveShuttle(elevator_id, target_dock, TRUE)
			moving = TRUE
			if(announcing)
				visible_message(span_notice("Elevator departing. Please stand clear."))
			addtimer(CALLBACK(src, /obj/turbolift_map_holder/proc/clear_moving), 6 SECONDS)
		else
			var/target_z = (current_z == 1) ? 2 : 1
			start_move_legacy(target_z)

/obj/turbolift_map_holder/proc/clear_moving()
	moving = FALSE

/obj/turbolift_map_holder/proc/start_move_legacy(new_z)
	if(moving)
		return
	moving = TRUE
	if(announcing)
		visible_message(span_notice("Elevator departing. Please stand clear."))
	addtimer(CALLBACK(src, /obj/turbolift_map_holder/proc/complete_move_legacy, new_z), 5 SECONDS)

/obj/turbolift_map_holder/proc/complete_move_legacy(new_z)
	var/turf/T = locate(x, y, new_z)
	if(T)
		for(var/atom/movable/AM in get_turf(src))
			if(AM == src)
				continue
			if(ismob(AM) || isobj(AM))
				AM.forceMove(locate(x, y, new_z))
	current_z = new_z
	moving = FALSE
	if(announcing)
		visible_message(span_notice("Elevator arriving."))

/obj/turbolift_map_holder/commstower
	name = "Communications Tower Elevator"
	elevator_id = "elevator_commstower"

/obj/turbolift_map_holder/commstower/get_destinations()
	return list("elevator_commstower_lower", "elevator_commstower_upper")

/obj/turbolift_map_holder/gatea
	name = "Gate A Elevator"
	elevator_id = "elevator_gatea"

/obj/turbolift_map_holder/gatea/get_destinations()
	return list("elevator_gatea_lower", "elevator_gatea_upper")

/obj/turbolift_map_holder/hcz082
	name = "HCZ-082 Elevator"
	elevator_id = "elevator_hcz082"

/obj/turbolift_map_holder/hcz082/get_destinations()
	return list("elevator_hcz082_lower", "elevator_hcz082_upper")

/obj/turbolift_map_holder/robotics
	name = "Robotics Elevator"
	elevator_id = "elevator_robotics"

/obj/turbolift_map_holder/robotics/get_destinations()
	return list("elevator_robotics_lower", "elevator_robotics_upper")

/obj/turbolift_map_holder/scp106
	name = "SCP-106 Elevator"
	elevator_id = "elevator_scp106"

/obj/turbolift_map_holder/scp106/get_destinations()
	return list("elevator_scp106_lower", "elevator_scp106_upper")

/obj/turbolift_map_holder/uhcztolhcz
	name = "UHCZ-LHCZ Elevator"
	elevator_id = "elevator_uhcztolhcz"

/obj/turbolift_map_holder/uhcztolhcz/get_destinations()
	return list("elevator_uhcztolhcz_lower", "elevator_uhcztolhcz_upper")

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

/obj/effect/landmark/reinforced
	name = "reinforced landmark"

/obj/effect/landmark/reinforced/titanium
	name = "reinforced titanium landmark"

/obj/effect/landmark/reinforced_phoron
	name = "reinforced phoron landmark"

/obj/effect/landmark/reinforced_phoron/titanium
	name = "reinforced phoron titanium landmark"