/area/shuttle/foundation_elevator
	name = "Foundation Elevator"
	requires_power = FALSE
	area_flags = NONE

/area/shuttle/foundation_elevator/gatea
	name = "Gate A Elevator"

/area/shuttle/foundation_elevator/commstower
	name = "Communications Tower Elevator"

/area/shuttle/foundation_elevator/hcz082
	name = "HCZ-082 Elevator"

/area/shuttle/foundation_elevator/robotics
	name = "Robotics Elevator"

/area/shuttle/foundation_elevator/scp106
	name = "SCP-106 Elevator"

/area/shuttle/foundation_elevator/uhcztolhcz
	name = "UHCZ-LHCZ Elevator"

/obj/docking_port/mobile/elevator/foundation
	name = "Foundation Elevator"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	callTime = 5 SECONDS
	ignitionTime = 0
	rechargeTime = 3 SECONDS

/obj/docking_port/mobile/elevator/foundation/gatea
	id = "elevator_gatea"
	name = "Gate A Elevator"
	area_type = /area/shuttle/foundation_elevator/gatea

/obj/docking_port/mobile/elevator/foundation/commstower
	id = "elevator_commstower"
	name = "Communications Tower Elevator"
	area_type = /area/shuttle/foundation_elevator/commstower

/obj/docking_port/mobile/elevator/foundation/hcz082
	id = "elevator_hcz082"
	name = "HCZ-082 Elevator"
	area_type = /area/shuttle/foundation_elevator/hcz082

/obj/docking_port/mobile/elevator/foundation/robotics
	id = "elevator_robotics"
	name = "Robotics Elevator"
	area_type = /area/shuttle/foundation_elevator/robotics

/obj/docking_port/mobile/elevator/foundation/scp106
	id = "elevator_scp106"
	name = "SCP-106 Elevator"
	area_type = /area/shuttle/foundation_elevator/scp106

/obj/docking_port/mobile/elevator/foundation/uhcztolhcz
	id = "elevator_uhcztolhcz"
	name = "UHCZ-LHCZ Elevator"
	area_type = /area/shuttle/foundation_elevator/uhcztolhcz

/obj/docking_port/stationary/foundation_elevator
	name = "Elevator Dock"
	width = 3
	height = 3
	dwidth = 1
	dheight = 1

/obj/docking_port/stationary/foundation_elevator/gatea_lower
	id = "elevator_gatea_lower"
	name = "Gate A - Lower Level"

/obj/docking_port/stationary/foundation_elevator/gatea_upper
	id = "elevator_gatea_upper"
	name = "Gate A - Surface Level"

/obj/docking_port/stationary/foundation_elevator/commstower_lower
	id = "elevator_commstower_lower"
	name = "Communications Tower - Lower Level"

/obj/docking_port/stationary/foundation_elevator/commstower_upper
	id = "elevator_commstower_upper"
	name = "Communications Tower - Upper Level"

/obj/docking_port/stationary/foundation_elevator/hcz082_lower
	id = "elevator_hcz082_lower"
	name = "HCZ-082 - Lower Level"

/obj/docking_port/stationary/foundation_elevator/hcz082_upper
	id = "elevator_hcz082_upper"
	name = "HCZ-082 - Upper Level"

/obj/docking_port/stationary/foundation_elevator/robotics_lower
	id = "elevator_robotics_lower"
	name = "Robotics - Lower Level"

/obj/docking_port/stationary/foundation_elevator/robotics_upper
	id = "elevator_robotics_upper"
	name = "Robotics - Upper Level"

/obj/docking_port/stationary/foundation_elevator/scp106_lower
	id = "elevator_scp106_lower"
	name = "SCP-106 - Lower Level"

/obj/docking_port/stationary/foundation_elevator/scp106_upper
	id = "elevator_scp106_upper"
	name = "SCP-106 - Upper Level"

/obj/docking_port/stationary/foundation_elevator/uhcztolhcz_lower
	id = "elevator_uhcztolhcz_lower"
	name = "UHCZ-LHCZ - Lower Level"

/obj/docking_port/stationary/foundation_elevator/uhcztolhcz_upper
	id = "elevator_uhcztolhcz_upper"
	name = "UHCZ-LHCZ - Upper Level"

/obj/machinery/computer/shuttle/foundation_elevator
	name = "Elevator Control Panel"
	desc = "A control panel for selecting elevator destination floors."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	icon_screen = "shuttle"
	light_color = LIGHT_COLOR_CYAN
	admin_controlled = FALSE

/obj/machinery/computer/shuttle/foundation_elevator/gatea
	name = "Gate A Elevator Panel"
	shuttleId = "elevator_gatea"
	possible_destinations = "elevator_gatea_lower;elevator_gatea_upper"

/obj/machinery/computer/shuttle/foundation_elevator/commstower
	name = "Communications Tower Elevator Panel"
	shuttleId = "elevator_commstower"
	possible_destinations = "elevator_commstower_lower;elevator_commstower_upper"

/obj/machinery/computer/shuttle/foundation_elevator/hcz082
	name = "HCZ-082 Elevator Panel"
	shuttleId = "elevator_hcz082"
	possible_destinations = "elevator_hcz082_lower;elevator_hcz082_upper"

/obj/machinery/computer/shuttle/foundation_elevator/robotics
	name = "Robotics Elevator Panel"
	shuttleId = "elevator_robotics"
	possible_destinations = "elevator_robotics_lower;elevator_robotics_upper"

/obj/machinery/computer/shuttle/foundation_elevator/scp106
	name = "SCP-106 Elevator Panel"
	shuttleId = "elevator_scp106"
	possible_destinations = "elevator_scp106_lower;elevator_scp106_upper"

/obj/machinery/computer/shuttle/foundation_elevator/uhcztolhcz
	name = "UHCZ-LHCZ Elevator Panel"
	shuttleId = "elevator_uhcztolhcz"
	possible_destinations = "elevator_uhcztolhcz_lower;elevator_uhcztolhcz_upper"

/obj/machinery/elevator_button/foundation
	name = "Elevator Call Button"
	desc = "Press to call the elevator to this level."
	icon = 'icons/obj/objects.dmi'
	icon_state = "doorctrl0"
	anchored = TRUE
	var/elevator_id = ""
	var/target_dock_id = ""

/obj/machinery/elevator_button/foundation/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!elevator_id)
		return

	var/obj/docking_port/mobile/elevator/foundation/E = SSshuttle.getShuttle(elevator_id)
	if(!E)
		to_chat(user, span_warning("Elevator unavailable."))
		return

	if(E.mode != SHUTTLE_IDLE)
		to_chat(user, span_warning("Elevator is in transit. Please wait."))
		return

	var/obj/docking_port/stationary/dock = SSshuttle.getDock(target_dock_id)
	if(!dock)
		to_chat(user, span_warning("No dock found."))
		return

	if(E.get_docked() == dock)
		to_chat(user, span_notice("Elevator is already at this level."))
		return

	SSshuttle.moveShuttle(elevator_id, target_dock_id, TRUE)
	playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
	to_chat(user, span_notice("Elevator called."))

/obj/machinery/elevator_button/foundation/gatea_lower
	elevator_id = "elevator_gatea"
	target_dock_id = "elevator_gatea_lower"

/obj/machinery/elevator_button/foundation/gatea_upper
	elevator_id = "elevator_gatea"
	target_dock_id = "elevator_gatea_upper"

/obj/machinery/elevator_button/foundation/commstower_lower
	elevator_id = "elevator_commstower"
	target_dock_id = "elevator_commstower_lower"

/obj/machinery/elevator_button/foundation/commstower_upper
	elevator_id = "elevator_commstower"
	target_dock_id = "elevator_commstower_upper"

/obj/machinery/elevator_button/foundation/hcz082_lower
	elevator_id = "elevator_hcz082"
	target_dock_id = "elevator_hcz082_lower"

/obj/machinery/elevator_button/foundation/hcz082_upper
	elevator_id = "elevator_hcz082"
	target_dock_id = "elevator_hcz082_upper"

/obj/machinery/elevator_button/foundation/robotics_lower
	elevator_id = "elevator_robotics"
	target_dock_id = "elevator_robotics_lower"

/obj/machinery/elevator_button/foundation/robotics_upper
	elevator_id = "elevator_robotics"
	target_dock_id = "elevator_robotics_upper"

/obj/machinery/elevator_button/foundation/scp106_lower
	elevator_id = "elevator_scp106"
	target_dock_id = "elevator_scp106_lower"

/obj/machinery/elevator_button/foundation/scp106_upper
	elevator_id = "elevator_scp106"
	target_dock_id = "elevator_scp106_upper"

/obj/machinery/elevator_button/foundation/uhcztolhcz_lower
	elevator_id = "elevator_uhcztolhcz"
	target_dock_id = "elevator_uhcztolhcz_lower"

/obj/machinery/elevator_button/foundation/uhcztolhcz_upper
	elevator_id = "elevator_uhcztolhcz"
	target_dock_id = "elevator_uhcztolhcz_upper"

/obj/machinery/power/rtg/foundation
	name = "Foundation Nuclear Reactor Core"
	desc = "A compact nuclear fission reactor core. Provides reliable power for decades."
	power_gen = 50000

/obj/machinery/power/rtg/foundation/backup
	name = "Foundation Backup Generator"
	desc = "A backup radioisotope generator for emergency power."
	power_gen = 20000

/obj/machinery/elevator_door
	name = "Elevator Door"
	desc = "A heavy elevator door."
	icon = 'icons/obj/doors/airlocks/station/airlock.dmi'
	icon_state = "door_closed"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/elevator_id = ""
	var/dock_id = ""

/obj/machinery/elevator_door/proc/open_door()
	if(!density)
		return
	density = FALSE
	opacity = FALSE
	icon_state = "door_open"
	playsound(src, 'sound/machines/door_open.ogg', 50, TRUE)

/obj/machinery/elevator_door/proc/close_door()
	if(density)
		return
	density = TRUE
	opacity = TRUE
	icon_state = "door_closed"
	playsound(src, 'sound/machines/door_close.ogg', 50, TRUE)
