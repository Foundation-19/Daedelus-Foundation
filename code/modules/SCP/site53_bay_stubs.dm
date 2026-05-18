/obj/machinery/access_button
	name = "access button"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	desc = "A button for cycling airlocks."
	power_channel = AREA_USAGE_ENVIRON
	var/ab_id_tag
	var/interior_door_tag
	var/exterior_door_tag
	var/cycling = FALSE

/obj/machinery/access_button/attack_hand(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("[src] has no power."))
		return
	if(cycling)
		to_chat(user, span_warning("Airlock is already cycling."))
		return
	cycling = TRUE
	flick("doorctrl0", src)
	var/list/doors = list()
	for(var/obj/machinery/door/airlock/A in range(5, src))
		if(A.id_tag == ab_id_tag || A.id_tag == interior_door_tag || A.id_tag == exterior_door_tag)
			doors += A
	if(length(doors))
		for(var/obj/machinery/door/airlock/A in doors)
			if(A.density)
				A.open()
			else
				A.close()
	else
		for(var/obj/machinery/door/airlock/A in range(10, src))
			if(A.density)
				A.open()
			else
				A.close()
	addtimer(CALLBACK(src, PROC_REF(reset_cycling)), 30)

/obj/machinery/access_button/proc/reset_cycling()
	cycling = FALSE

/obj/machinery/access_button/airlock_exterior
	name = "exterior access button"
	icon_state = "doorctrl"

/obj/machinery/access_button/airlock_interior
	name = "interior access button"
	icon_state = "doorctrl1"

/obj/machinery/ai_status_display
	name = "AI display"
	icon = 'icons/obj/computer.dmi'
	icon_state = "generic"
	density = FALSE

/obj/machinery/cryopod
	name = "cryogenic pod"
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	anchored = TRUE
	var/mob/living/stored_mob

/obj/machinery/cryopod/attack_hand(mob/user)
	if(stored_mob)
		to_chat(user, span_notice("[stored_mob] is stored in this pod."))
		return
	to_chat(user, span_notice("The cryogenic pod is empty."))

/obj/machinery/cryopod/living_quarters
	name = "living quarters pod"

/obj/machinery/cryopod/robot
	name = "robot storage pod"
	icon_state = "biogen-empty"

/obj/machinery/embedded_controller/radio/airlock
	name = "airlock controller"

/obj/machinery/embedded_controller/radio/airlock/access_controller
	name = "access controller"

/obj/machinery/embedded_controller/radio/airlock/airlock_controller
	name = "airlock controller"

/obj/machinery/fabricator
	name = "fabricator"
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	anchored = TRUE

/obj/machinery/fabricator/micro
	name = "micro fabricator"
	icon_state = "biogen-empty"

/obj/machinery/fabricator/micro/bartender
	name = "bartender micro-fab"

/obj/machinery/message_server
	name = "message server"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "message_server"
	density = TRUE
	anchored = TRUE

/obj/machinery/optable
	name = "operating table"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "optable"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER

/obj/machinery/optable/attack_hand(mob/user)
	if(!isliving(user))
		return
	var/mob/living/L = user
	var/mob/living/target = locate() in get_turf(L)
	if(target && target != L)
		target.forceMove(get_turf(src))
		target.set_lying_angle(target.lying_angle == 0 ? 90 : 0)
		visible_message(span_notice("[L] puts [target] on the operating table."))
		return

/obj/machinery/psi_meter
	name = "psi meter"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "d_analyzer"
	density = TRUE

/obj/machinery/r_n_d
	name = "R&D machine"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
	density = TRUE
	anchored = TRUE

/obj/machinery/r_n_d/circuit_imprinter
	name = "circuit imprinter"
	icon_state = "circuit_imprinter"

/obj/machinery/r_n_d/destructive_analyzer
	name = "destructive analyzer"
	icon_state = "d_analyzer"

/obj/machinery/r_n_d/protolathe
	name = "protolathe"
	icon_state = "protolathe"

/obj/machinery/r_n_d/server
	name = "R&D server"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "message_server"

/obj/machinery/r_n_d/server/core
	name = "core R&D server"

/obj/machinery/r_n_d/server/robotics
	name = "robotics R&D server"

/obj/machinery/self_destruct
	name = "Foundation On-Site Warhead"
	desc = "A nuclear self-destruct device. In case of catastrophic containment failure, this is the last resort."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/self_destruct/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	var/obj/machinery/nuclearbomb/foundation/N = new(T)
	if(name != "Foundation On-Site Warhead")
		N.name = name
	return INITIALIZE_HINT_QDEL

/obj/structure/scp_914
	name = "SCP-914"
	desc = "A large clockwork device with an input and output booth."
	density = TRUE
	anchored = TRUE

/obj/structure/scp_914/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/machinery/scp914(T)
	return INITIALIZE_HINT_QDEL

/obj/structure/scp082_trunk
	name = "trunk"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrate"
	density = TRUE

/obj/structure/scp173_cage
	name = "SCP-173 Containment Cage"
	desc = "A reinforced containment cage for SCP-173. Keep closed at all times."
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	density = TRUE
	anchored = TRUE
	var/open = FALSE
	var/mob/living/caged_mob

/obj/structure/scp173_cage/attack_hand(mob/user)
	if(open)
		close_cage()
	else
		open_cage()

/obj/structure/scp173_cage/proc/open_cage()
	open = TRUE
	density = FALSE
	icon_state = "safe-open"
	visible_message(span_notice("[src] opens."))
	if(caged_mob)
		caged_mob.forceMove(get_turf(src))
		caged_mob = null

/obj/structure/scp173_cage/proc/close_cage()
	open = FALSE
	density = TRUE
	icon_state = "safe"
	visible_message(span_notice("[src] closes."))
	for(var/mob/living/L in get_turf(src))
		if(istype(L, /mob/living/scp/scp173))
			caged_mob = L
			break

/obj/structure/scp173_cage/attackby(obj/item/W, mob/user, params)
	if(open)
		close_cage()
	else
		open_cage()

/obj/structure/stasis_cage
	name = "stasis cage"
	desc = "A reinforced container that places its occupant in stasis."
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	density = TRUE
	anchored = TRUE

/obj/turbolift_map_holder
	name = "Facility Elevator"
	desc = "A heavy-duty freight elevator for moving between facility levels."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/moving = FALSE
	var/elevator_id = ""
	var/upper_z = 0
	var/lower_z = 0

/obj/turbolift_map_holder/Initialize(mapload)
	. = ..()
	find_z_levels()

/obj/turbolift_map_holder/proc/find_z_levels()
	if(upper_z && lower_z)
		return
	var/list/candidates = list()
	if(z == 1)
		candidates = list(2)
	else if(z == 2)
		candidates = list(1, 3)
	else if(z == 3)
		candidates = list(2, 4)
	else if(z == 4)
		candidates = list(3)
	for(var/cz in candidates)
		var/turf/T = locate(x, y, cz)
		if(T)
			var/area/A = T.loc
			if(!istype(A, /area/space))
				if(cz > z && !upper_z)
					upper_z = cz
				else if(cz < z && !lower_z)
					lower_z = cz
	if(!upper_z && !lower_z)
		for(var/cz in candidates)
			var/turf/T = locate(x, y, cz)
			if(T)
				if(cz > z)
					upper_z = cz
				else
					lower_z = cz

/obj/turbolift_map_holder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(moving)
		to_chat(user, span_warning("Elevator is already in motion."))
		return
	var/target_z = (z == lower_z) ? upper_z : lower_z
	if(!target_z)
		to_chat(user, span_warning("Elevator destination unavailable."))
		return
	move_elevator(target_z, user)

/obj/turbolift_map_holder/attack_ai(mob/user)
	attack_hand(user)

/obj/turbolift_map_holder/proc/move_elevator(target_z, mob/user)
	if(moving)
		return
	moving = TRUE
	playsound(loc, 'sound/machines/door_open.ogg', 50, TRUE)
	if(user)
		to_chat(user, span_notice("Elevator moving to [target_z == upper_z ? "upper" : "lower"] level..."))
	addtimer(CALLBACK(src, PROC_REF(do_elevator_move), target_z), 3 SECONDS)

/obj/turbolift_map_holder/proc/do_elevator_move(target_z)
	var/turf/dest = locate(x, y, target_z)
	if(!dest)
		moving = FALSE
		return
	for(var/turf/T in block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z)))
		for(var/atom/movable/AM in T)
			if(AM.anchored || AM == src)
				continue
			if(ismob(AM))
				var/mob/M = AM
				M.forceMove(locate(AM.x, AM.y, target_z))
			else if(isobj(AM))
				AM.forceMove(locate(AM.x, AM.y, target_z))
	playsound(loc, 'sound/machines/door_close.ogg', 50, TRUE)
	moving = FALSE

/obj/turbolift_map_holder/commstower
	name = "Communications Tower Elevator"
	elevator_id = "elevator_commstower"

/obj/turbolift_map_holder/gatea
	name = "Gate A Elevator"
	elevator_id = "elevator_gatea"

/obj/turbolift_map_holder/hcz082
	name = "HCZ-082 Elevator"
	elevator_id = "elevator_hcz082"

/obj/turbolift_map_holder/robotics
	name = "Robotics Elevator"
	elevator_id = "elevator_robotics"

/obj/turbolift_map_holder/scp106
	name = "SCP-106 Elevator"
	elevator_id = "elevator_scp106"

/obj/turbolift_map_holder/uhcztolhcz
	name = "UHCZ-LHCZ Elevator"
	elevator_id = "elevator_uhcztolhcz"

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
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"

/obj/machinery/holoposter
	name = "holoposter"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"

/obj/structure/window/bulletproof
	name = "bulletproof window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "fwindow"
	max_integrity = 200
	armor = list(MELEE = 50, BULLET = 90, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)

/obj/effect/landmark/reinforced
	name = "reinforced landmark"

/obj/effect/landmark/reinforced/titanium
	name = "reinforced titanium landmark"

/obj/effect/landmark/reinforced_phoron
	name = "reinforced phoron landmark"

/obj/effect/landmark/reinforced_phoron/titanium
	name = "reinforced phoron titanium landmark"
