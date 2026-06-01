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
	if(SSfoundation_budget)
		var/budget_bonus = 50 + (route.zone == "hcz" ? 75 : 0)
		var/datum/department_budget/B = SSfoundation_budget.department_budgets["security"]
		if(B)
			B.allocate(budget_bonus)
			SSfoundation_budget.total_budget += budget_bonus
	if(SSscp_research?.manager)
		var/research_bonus = 5
		if(route.zone == "hcz")
			research_bonus = 15
		else if(route.zone == "lcz")
			research_bonus = 10
		SSscp_research?.manager?.adjust_research_points(research_bonus, "guard_patrol:[route.route_id]")

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


