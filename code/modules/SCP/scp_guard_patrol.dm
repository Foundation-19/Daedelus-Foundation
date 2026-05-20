/obj/effect/landmark/guard_waypoint
	name = "guard patrol waypoint"
	var/waypoint_id = ""
	var/zone = "lcz"

/obj/effect/landmark/guard_waypoint/lcz_cell_block
	name = "LCZ Cell Block Waypoint"
	waypoint_id = "lcz_cell_block"
	zone = "lcz"

/obj/effect/landmark/guard_waypoint/lcz_checkpoint
	name = "LCZ Checkpoint Waypoint"
	waypoint_id = "lcz_checkpoint"
	zone = "lcz"

/obj/effect/landmark/guard_waypoint/lcz_cafeteria
	name = "LCZ Cafeteria Waypoint"
	waypoint_id = "lcz_cafeteria"
	zone = "lcz"

/obj/effect/landmark/guard_waypoint/lcz_work_area
	name = "LCZ Work Area Waypoint"
	waypoint_id = "lcz_work_area"
	zone = "lcz"

/obj/effect/landmark/guard_waypoint/hcz_checkpoint
	name = "HCZ Checkpoint Waypoint"
	waypoint_id = "hcz_checkpoint"
	zone = "hcz"

/obj/effect/landmark/guard_waypoint/hcz_scp_containment
	name = "HCZ SCP Containment Waypoint"
	waypoint_id = "hcz_scp_containment"
	zone = "hcz"

/obj/effect/landmark/guard_waypoint/hcz_medical
	name = "HCZ Medical Waypoint"
	waypoint_id = "hcz_medical"
	zone = "hcz"

/obj/effect/landmark/guard_waypoint/ez_entrance
	name = "EZ Entrance Waypoint"
	waypoint_id = "ez_entrance"
	zone = "ez"

/obj/effect/landmark/guard_waypoint/ez_command
	name = "EZ Command Waypoint"
	waypoint_id = "ez_command"
	zone = "ez"

/obj/effect/landmark/guard_waypoint/surface_gate
	name = "Surface Gate Waypoint"
	waypoint_id = "surface_gate"
	zone = "surface"

/datum/guard_patrol_route
	var/route_id = ""
	var/route_name = ""
	var/zone = ""
	var/list/waypoint_ids = list()
	var/patrol_cooldown = 5 MINUTES
	var/last_patrol_time = 0
	var/completed_count = 0
	var/active_guard_ckey = null

/datum/guard_patrol_route/proc/get_waypoint_turfs()
	var/list/turfs = list()
	for(var/wp_id in waypoint_ids)
		for(var/obj/effect/landmark/guard_waypoint/WP in GLOB.landmarks_list)
			if(WP.waypoint_id == wp_id)
				turfs += get_turf(WP)
				break
	return turfs

SUBSYSTEM_DEF(guard_patrols)
	name = "Guard Patrols"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_INPUT
	var/list/datum/guard_patrol_route/routes = list()
	var/routes_initialized = FALSE

/datum/controller/subsystem/guard_patrols/Initialize()
	. = ..()
	init_routes()

/datum/controller/subsystem/guard_patrols/proc/init_routes()
	if(routes_initialized)
		return
	routes_initialized = TRUE
	routes["lcz_standard"] = new /datum/guard_patrol_route/lcz_standard()
	routes["lcz_cell_check"] = new /datum/guard_patrol_route/lcz_cell_check()
	routes["hcz_containment"] = new /datum/guard_patrol_route/hcz_containment()
	routes["ez_perimeter"] = new /datum/guard_patrol_route/ez_perimeter()
	routes["surface_gate"] = new /datum/guard_patrol_route/surface_gate()

/datum/guard_patrol_route/lcz_standard
	route_id = "lcz_standard"
	route_name = "LCZ Standard Patrol"
	zone = "lcz"
	waypoint_ids = list("lcz_checkpoint", "lcz_cafeteria", "lcz_work_area", "lcz_cell_block")

/datum/guard_patrol_route/lcz_cell_check
	route_id = "lcz_cell_check"
	route_name = "LCZ Cell Block Check"
	zone = "lcz"
	waypoint_ids = list("lcz_cell_block", "lcz_cafeteria", "lcz_cell_block")
	patrol_cooldown = 3 MINUTES

/datum/guard_patrol_route/hcz_containment
	route_id = "hcz_containment"
	route_name = "HCZ Containment Sweep"
	zone = "hcz"
	waypoint_ids = list("hcz_checkpoint", "hcz_scp_containment", "hcz_medical", "hcz_checkpoint")

/datum/guard_patrol_route/ez_perimeter
	route_id = "ez_perimeter"
	route_name = "EZ Perimeter Patrol"
	zone = "ez"
	waypoint_ids = list("ez_entrance", "ez_command", "ez_entrance")

/datum/guard_patrol_route/surface_gate
	route_id = "surface_gate"
	route_name = "Surface Gate Patrol"
	zone = "surface"
	waypoint_ids = list("surface_gate")
	patrol_cooldown = 10 MINUTES

/datum/controller/subsystem/guard_patrols/fire()
	for(var/route_id in routes)
		var/datum/guard_patrol_route/route = routes[route_id]
		if(world.time < route.last_patrol_time + route.patrol_cooldown)
			continue
		if(!route.active_guard_ckey)
			continue
		var/mob/living/carbon/human/guard
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.ckey == route.active_guard_ckey && H.stat != DEAD)
				guard = H
				break
		if(!guard)
			route.active_guard_ckey = null
			continue
		var/list/waypoint_turfs = route.get_waypoint_turfs()
		if(!length(waypoint_turfs))
			continue
		var/turf/target_turf = waypoint_turfs[1]
		if(get_dist(guard, target_turf) <= 3)
			complete_patrol_waypoint(guard, route)
		else
			var/obj/item/radio/headset/H = guard.get_item_by_slot(ITEM_SLOT_EARS)
			if(H)
				to_chat(guard, span_notice("Patrol waypoint: [get_area_name(target_turf)]. Head [dir2text(get_dir(guard, target_turf))]."))

/datum/controller/subsystem/guard_patrols/proc/complete_patrol_waypoint(mob/living/carbon/human/guard, datum/guard_patrol_route/route)
	to_chat(guard, span_notice("Patrol waypoint reached. Continue to the next checkpoint."))
	route.completed_count++
	route.last_patrol_time = world.time
	if(SSround_objectives)
		SSround_objectives.report_objective_progress("guard_recontain", 0)
	if(SSpersistent_progression)
		SSpersistent_progression.award_experience(guard.ckey, "scp_patrol", 0, "Patrol Route Completed")

/datum/controller/subsystem/guard_patrols/proc/assign_guard_to_route(mob/living/carbon/human/guard, route_id)
	var/datum/guard_patrol_route/route = routes[route_id]
	if(!route)
		return FALSE
	if(route.active_guard_ckey)
		var/mob/living/carbon/human/existing
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.ckey == route.active_guard_ckey && H.stat != DEAD)
				existing = H
				break
		if(existing)
			to_chat(guard, span_warning("This route is already assigned to [existing.real_name]."))
			return FALSE
	route.active_guard_ckey = guard.ckey
	route.last_patrol_time = world.time
	var/list/waypoint_turfs = route.get_waypoint_turfs()
	if(length(waypoint_turfs))
		var/turf/T = waypoint_turfs[1]
		to_chat(guard, span_notice("<b>PATROL ASSIGNED:</b> [route.route_name]. Proceed to the marked checkpoint in [get_area_name(T)]."))
	return TRUE

/datum/controller/subsystem/guard_patrols/proc/release_guard_from_route(mob/living/carbon/human/guard, route_id)
	var/datum/guard_patrol_route/route = routes[route_id]
	if(!route || route.active_guard_ckey != guard.ckey)
		return FALSE
	route.active_guard_ckey = null
	to_chat(guard, span_notice("You have been released from patrol duty."))
	return TRUE

/obj/machinery/computer/guard_patrol_console
	name = "Guard Patrol Console"
	desc = "A console for assigning and managing guard patrol routes throughout the facility."
	icon = 'icons/obj/computer.dmi'
	icon_state = "security"
	circuit = /obj/item/circuitboard/computer/guard_patrol_console
	req_access = list(ACCESS_SECURITY)
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

/obj/machinery/computer/guard_patrol_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GuardPatrolConsole", "GUARD PATROL SYSTEM")
		ui.open()

/obj/machinery/computer/guard_patrol_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/guard_patrol_console/ui_data(mob/user)
	var/list/data = list()
	var/list/route_data = list()
	if(SSguard_patrols)
		for(var/route_id in SSguard_patrols.routes)
			var/datum/guard_patrol_route/route = SSguard_patrols.routes[route_id]
			var/guard_name = "Unassigned"
			if(route.active_guard_ckey)
				var/mob/living/carbon/human/H
				for(var/mob/living/carbon/human/M in GLOB.player_list)
					if(M.ckey == route.active_guard_ckey && M.stat != DEAD)
						H = M
						break
				guard_name = H ? H.real_name : "Missing"
			route_data += list(list(
				"route_id" = route.route_id,
				"route_name" = route.route_name,
				"zone" = route.zone,
				"waypoint_count" = length(route.waypoint_ids),
				"guard_name" = guard_name,
				"completed_count" = route.completed_count,
				"on_cooldown" = (world.time < route.last_patrol_time + route.patrol_cooldown),
			))
	data["routes"] = route_data

	var/list/guard_data = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD)
			continue
		if(H.job && (findtext(H.job, "Guard") || findtext(H.job, "Security") || findtext(H.job, "MTF")))
			var/assigned_route = ""
			if(SSguard_patrols)
				for(var/r_id in SSguard_patrols.routes)
					var/datum/guard_patrol_route/r = SSguard_patrols.routes[r_id]
					if(r.active_guard_ckey == H.ckey)
						assigned_route = r.route_name
						break
			guard_data += list(list(
				"name" = H.real_name,
				"ckey" = H.ckey,
				"job" = H.job,
				"assigned_route" = assigned_route,
			))
	data["guards"] = guard_data

	var/list/escort_data = list()
	if(SSscp_gameplay)
		for(var/task_id in SSscp_gameplay.escort_tasks)
			var/datum/escort_task/task = SSscp_gameplay.escort_tasks[task_id]
			if(task.status == "expired" || task.status == "delivered" || task.status == "cancelled")
				continue
			escort_data += list(list(
				"task_id" = task.task_id,
				"subject_name" = task.subject ? task.subject.real_name : "Unknown",
				"scp_name" = task.scp_name,
				"test_type" = task.test_type,
				"risk_level" = task.risk_level,
				"status" = task.status,
				"guard_name" = task.escort_guard ? task.escort_guard.real_name : "Unassigned",
			))
	data["escorts"] = escort_data
	return data

/obj/machinery/computer/guard_patrol_console/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	if(!SSguard_patrols)
		return

	switch(action)
		if("assign_guard")
			var/guard_ckey = params["ckey"]
			var/route_id = params["route_id"]
			var/mob/living/carbon/human/guard
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.ckey == guard_ckey && H.stat != DEAD)
					guard = H
					break
			if(!guard)
				to_chat(usr, span_warning("Guard not found or dead."))
				return
			if(SSguard_patrols.assign_guard_to_route(guard, route_id))
				to_chat(usr, span_notice("[guard.real_name] assigned to patrol route."))
			. = TRUE
		if("release_guard")
			var/guard_ckey = params["ckey"]
			var/route_id = params["route_id"]
			var/mob/living/carbon/human/guard
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.ckey == guard_ckey && H.stat != DEAD)
					guard = H
					break
			if(!guard)
				return
			if(SSguard_patrols.release_guard_from_route(guard, route_id))
				to_chat(usr, span_notice("[guard.real_name] released from patrol."))
			. = TRUE
		if("self_assign")
			if(!ishuman(usr))
				return
			var/mob/living/carbon/human/H = usr
			var/route_id = params["route_id"]
			if(SSguard_patrols.assign_guard_to_route(H, route_id))
				to_chat(usr, span_notice("You have been assigned to patrol. Check your HUD for directions."))
			. = TRUE
		if("self_release")
			if(!ishuman(usr))
				return
			var/mob/living/carbon/human/H = usr
			for(var/r_id in SSguard_patrols.routes)
				var/datum/guard_patrol_route/route = SSguard_patrols.routes[r_id]
				if(route.active_guard_ckey == H.ckey)
					SSguard_patrols.release_guard_from_route(H, r_id)
					break
			. = TRUE
		if("accept_escort")
			if(!ishuman(usr))
				return
			var/mob/living/carbon/human/H = usr
			var/task_id = params["task_id"]
			if(!SSscp_gameplay)
				return
			var/datum/escort_task/task = SSscp_gameplay.escort_tasks[task_id]
			if(!task)
				return
			if(task.assign_guard(H))
				to_chat(usr, span_notice("You have accepted the escort task. Retrieve [task.subject.real_name] and bring them to the testing area."))
			. = TRUE
		if("complete_escort")
			if(!ishuman(usr))
				return
			var/task_id = params["task_id"]
			if(!SSscp_gameplay)
				return
			var/datum/escort_task/task = SSscp_gameplay.escort_tasks[task_id]
			if(!task || task.escort_guard != usr)
				return
			if(!task.subject || get_dist(usr, task.subject) > 3)
				to_chat(usr, span_warning("Subject must be nearby to complete delivery."))
				return
			if(task.complete_delivery())
				to_chat(usr, span_notice("Subject delivered successfully."))
			. = TRUE

/obj/item/circuitboard/computer/guard_patrol_console
	name = "Guard Patrol Console (Computer Board)"
	build_path = /obj/machinery/computer/guard_patrol_console
