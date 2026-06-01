#ifndef SCP_PATROL_ACTIVE
#define SCP_PATROL_ACTIVE 0
#define SCP_PATROL_COMPLETED 1
#define SCP_PATROL_ABANDONED 2
#endif

#ifndef SCP_ANOMALY_CONTAINMENT_DAMAGE
#define SCP_ANOMALY_CONTAINMENT_DAMAGE "containment_damage"
#define SCP_ANOMALY_UNAUTHORIZED_ACCESS "unauthorized_access"
#define SCP_ANOMALY_SUSPICIOUS_ACTIVITY "suspicious_activity"
#define SCP_ANOMALY_ENVIRONMENTAL_HAZARD "environmental_hazard"
#define SCP_ANOMALY_SCP_CONTACT "scp_contact"
#endif

SUBSYSTEM_DEF(scp_patrol)
	name = "SCP Patrol"
	wait = 20 SECONDS
	flags = SS_NO_FIRE

	var/list/patrol_routes = list()
	var/list/active_patrols = list()
	var/list/patrol_log = list()
	var/list/anomaly_reports = list()
	var/list/guard_stats = list()
	var/total_patrols_completed = 0
	var/total_anomalies_reported = 0
	var/total_breach_responses = 0
	var/total_contraband_seized = 0

/datum/controller/subsystem/scp_patrol/Initialize(time)
	. = ..()
	generate_patrol_routes()

/datum/controller/subsystem/scp_patrol/proc/generate_patrol_routes()
	patrol_routes = list()
	var/list/route_defs = list(
		list("LCZ Corridor Alpha Sweep", "lcz", 4, 1, "Standard sweep of LCZ Corridor Alpha for unauthorized personnel and containment irregularities."),
		list("LCZ Containment Door Check", "lcz", 5, 2, "Inspect all containment door seals and locking mechanisms in LCZ containment wing."),
		list("LCZ D-Class Block Perimeter", "lcz", 3, 1, "Perimeter check around D-Class cell block for escape attempts and contraband."),
		list("LCZ Safe Class Inspection", "lcz", 4, 1, "Routine inspection of Safe-class SCP containment chambers in LCZ."),
		list("HCZ Corridor Bravo Sweep", "hcz", 5, 2, "Sweep of HCZ Corridor Bravo for structural damage and unauthorized access."),
		list("HCZ Keter Wing Inspection", "hcz", 6, 3, "High-priority inspection of Keter-class containment wing in HCZ."),
		list("HCZ Euclid Monitoring Round", "hcz", 4, 2, "Monitoring round of Euclid-class containment chambers in HCZ."),
		list("HCZ Server Room Security", "hcz", 3, 2, "Security check of HCZ server room and electronic systems."),
		list("EZ Main Corridor Patrol", "ez", 4, 1, "Patrol of EZ main corridor for visitor compliance and general security."),
		list("EZ Command Area Security", "ez", 3, 1, "Security sweep of EZ command area and administrative offices."),
		list("EZ Checkpoint Inspection", "ez", 5, 2, "Inspection of all EZ security checkpoints and access logs."),
		list("EZ Perimeter Sweep", "ez", 4, 1, "Perimeter sweep of EZ boundary for unauthorized entry or exit."),
	)
	var/route_id_counter = 1
	for(var/list/D in route_defs)
		var/route_name = D[1]
		var/zone = D[2]
		var/waypoints = D[3]
		var/threat = D[4]
		var/desc = D[5]
		patrol_routes += list(list(
			"route_id" = "patrol_[route_id_counter]",
			"name" = route_name,
			"zone" = zone,
			"waypoints" = waypoints,
			"threat_level" = threat,
			"reward_research" = 5 + threat * 5,
			"description" = desc,
		))
		route_id_counter++

/datum/controller/subsystem/scp_patrol/proc/accept_patrol(route_id, mob/living/carbon/human/guard)
	if(!istype(guard))
		return FALSE
	for(var/list/A in active_patrols)
		if(A["guard_ckey"] == guard.ckey && A["status"] == SCP_PATROL_ACTIVE)
			return FALSE
	var/list/route = null
	for(var/list/R in patrol_routes)
		if(R["route_id"] == route_id)
			route = R
			break
	if(!route)
		return FALSE
	var/list/waypoint_list = list()
	for(var/i in 1 to route["waypoints"])
		waypoint_list += list(list(
			"index" = i,
			"visited" = FALSE,
		))
	active_patrols += list(list(
		"route_id" = route_id,
		"route_name" = route["name"],
		"zone" = route["zone"],
		"threat_level" = route["threat_level"],
		"reward_research" = route["reward_research"],
		"guard_ckey" = guard.ckey,
		"guard_name" = guard.real_name,
		"waypoints" = waypoint_list,
		"waypoints_total" = route["waypoints"],
		"waypoints_visited" = 0,
		"status" = SCP_PATROL_ACTIVE,
		"time_started" = world.time,
		"time_completed" = 0,
	))
	var/list/stats = get_guard_stats(guard.ckey)
	stats["total_patrols"]++
	stats["last_active"] = world.time
	return TRUE

/datum/controller/subsystem/scp_patrol/proc/visit_checkpoint(guard_ckey)
	var/list/active = null
	for(var/list/A in active_patrols)
		if(A["guard_ckey"] == guard_ckey && A["status"] == SCP_PATROL_ACTIVE)
			active = A
			break
	if(!active)
		return FALSE
	if(active["waypoints_visited"] >= active["waypoints_total"])
		return FALSE
	var/list/waypoint_list = active["waypoints"]
	var/visited = FALSE
	for(var/list/WP in waypoint_list)
		if(!WP["visited"])
			WP["visited"] = TRUE
			visited = TRUE
			break
	if(!visited)
		return FALSE
	active["waypoints_visited"]++
	var/list/stats = get_guard_stats(guard_ckey)
	stats["checkpoints_visited"]++
	stats["last_active"] = world.time
	if(prob(20))
		var/anomaly_types = list(SCP_ANOMALY_CONTAINMENT_DAMAGE, SCP_ANOMALY_UNAUTHORIZED_ACCESS, SCP_ANOMALY_SUSPICIOUS_ACTIVITY, SCP_ANOMALY_ENVIRONMENTAL_HAZARD)
		report_anomaly(guard_ckey, pick(anomaly_types), active["zone"], "Anomaly discovered during patrol of [active["route_name"]] at checkpoint [active["waypoints_visited"]].")
	if(active["waypoints_visited"] >= active["waypoints_total"])
		complete_patrol(guard_ckey, TRUE)
	return TRUE

/datum/controller/subsystem/scp_patrol/proc/complete_patrol(guard_ckey, completed)
	var/list/active = null
	var/active_idx = 0
	for(var/i in 1 to length(active_patrols))
		var/list/A = active_patrols[i]
		if(A["guard_ckey"] == guard_ckey && A["status"] == SCP_PATROL_ACTIVE)
			active = A
			active_idx = i
			break
	if(!active)
		return FALSE
	active["status"] = completed ? SCP_PATROL_COMPLETED : SCP_PATROL_ABANDONED
	active["time_completed"] = world.time
	var/reward = 0
	if(completed)
		reward = active["reward_research"]
		total_patrols_completed++
		if(SSscp_research?.manager)
			SSscp_research?.manager?.adjust_research_points(reward, "patrol_complete:[active["route_id"]]")
	var/list/stats = get_guard_stats(guard_ckey)
	if(completed)
		stats["patrols_completed"]++
	else
		stats["patrols_abandoned"]++
	stats["last_active"] = world.time
	patrol_log += list(active)
	active_patrols.Cut(active_idx, active_idx + 1)
	return TRUE

/datum/controller/subsystem/scp_patrol/proc/abandon_patrol(guard_ckey)
	return complete_patrol(guard_ckey, FALSE)

/datum/controller/subsystem/scp_patrol/proc/report_anomaly(guard_ckey, anomaly_type, location, description)
	if(!(anomaly_type in list(SCP_ANOMALY_CONTAINMENT_DAMAGE, SCP_ANOMALY_UNAUTHORIZED_ACCESS, SCP_ANOMALY_SUSPICIOUS_ACTIVITY, SCP_ANOMALY_ENVIRONMENTAL_HAZARD, SCP_ANOMALY_SCP_CONTACT)))
		return FALSE
	var/list/report = list(
		"anomaly_id" = "anom_[world.time]_[rand(100,999)]",
		"guard_ckey" = guard_ckey,
		"anomaly_type" = anomaly_type,
		"location" = location,
		"description" = description,
		"time_reported" = world.time,
		"resolved" = FALSE,
	)
	anomaly_reports += list(report)
	total_anomalies_reported++
	var/list/stats = get_guard_stats(guard_ckey)
	stats["anomalies_reported"]++
	stats["last_active"] = world.time
	var/research_reward = 10
	switch(anomaly_type)
		if(SCP_ANOMALY_CONTAINMENT_DAMAGE)
			research_reward = 15
			if(SSfoundation_comms)
				var/msg = "Containment damage reported in [location]. [description]"
				SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, msg, 2)
		if(SCP_ANOMALY_UNAUTHORIZED_ACCESS)
			research_reward = 12
			if(SSraisa)
				var/datum/intel_report/R = new(null, "unauthorized_access", location, "", "CONFIDENTIAL", "Unauthorized access reported in [location]. [description]", "Investigate access logs and detain suspects.")
				SSraisa.file_report(R)
		if(SCP_ANOMALY_SUSPICIOUS_ACTIVITY)
			research_reward = 10
			if(SSraisa)
				var/datum/intel_report/R = new(null, "suspicious_activity", location, "", "CONFIDENTIAL", "Suspicious activity reported in [location]. [description]", "Increase surveillance and investigate.")
				SSraisa.file_report(R)
		if(SCP_ANOMALY_ENVIRONMENTAL_HAZARD)
			research_reward = 12
			if(SSfoundation_comms)
				var/msg = "Environmental hazard reported in [location]. [description]"
				SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, msg, 1)
		if(SCP_ANOMALY_SCP_CONTACT)
			research_reward = 25
			priority_announce("SCP contact reported during patrol in [location]. All security personnel respond immediately.", "SECURITY ALERT", null, ANNOUNCER_ALERT)
	if(SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(research_reward, "anomaly_report:[report["anomaly_id"]]")
	return TRUE

/datum/controller/subsystem/scp_patrol/proc/respond_to_breach(guard_ckey, scp_id)
	total_breach_responses++
	var/list/stats = get_guard_stats(guard_ckey)
	stats["breach_responses"]++
	stats["last_active"] = world.time
	var/bonus = 20
	if(SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(bonus, "breach_response:[scp_id]")
	patrol_log += list(list(
		"route_id" = "breach_response",
		"route_name" = "Breach Response: [scp_id]",
		"zone" = "emergency",
		"guard_ckey" = guard_ckey,
		"status" = SCP_PATROL_COMPLETED,
		"time_started" = world.time,
		"time_completed" = world.time,
	))
	return TRUE

/datum/controller/subsystem/scp_patrol/proc/seize_contraband(guard_ckey, item_name, dclass_name)
	total_contraband_seized++
	var/list/stats = get_guard_stats(guard_ckey)
	stats["contraband_seized"]++
	stats["last_active"] = world.time
	if(SSdclass?.manager)
		var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(guard_ckey)
		if(player)
			player.suspicion_level = min(100, player.suspicion_level + 10)
	patrol_log += list(list(
		"route_id" = "contraband_seizure",
		"route_name" = "Contraband Seized: [item_name]",
		"zone" = "lcz",
		"guard_ckey" = guard_ckey,
		"status" = SCP_PATROL_COMPLETED,
		"time_started" = world.time,
		"time_completed" = world.time,
	))
	if(SSraisa)
		var/datum/intel_report/R = new(null, "contraband", dclass_name, "D-Class", "CONFIDENTIAL", "Contraband seized from D-Class [dclass_name]: [item_name]. Guard: [guard_ckey].", "Search D-Class cell and increase monitoring.")
		SSraisa.file_report(R)
	return TRUE

/datum/controller/subsystem/scp_patrol/proc/get_guard_stats(ckey)
	if(!guard_stats[ckey])
		guard_stats[ckey] = list(
			"total_patrols" = 0,
			"patrols_completed" = 0,
			"patrols_abandoned" = 0,
			"checkpoints_visited" = 0,
			"anomalies_reported" = 0,
			"breach_responses" = 0,
			"contraband_seized" = 0,
			"last_active" = 0,
		)
	return guard_stats[ckey]

/datum/controller/subsystem/scp_patrol/proc/get_available_routes(zone)
	var/list/available = list()
	var/list/active_route_ids = list()
	for(var/list/A in active_patrols)
		if(A["status"] == SCP_PATROL_ACTIVE)
			active_route_ids += A["route_id"]
	for(var/list/R in patrol_routes)
		if(zone && R["zone"] != zone)
			continue
		if(R["route_id"] in active_route_ids)
			continue
		available += list(R)
	return available

/datum/controller/subsystem/scp_patrol/proc/get_zone_threat_level(zone)
	var/threat = 1
	if(SSscp_persistence?.manager)
		var/breaches = SSscp_persistence?.manager?.active_breaches
		switch(zone)
			if("lcz")
				threat = 1 + min(2, breaches)
			if("hcz")
				threat = 1 + min(3, breaches * 2)
			if("ez")
				threat = 1 + min(1, breaches)
	if(SScontainment_integrity)
		var/integ = SScontainment_integrity.overall_integrity
		if(integ < CONTAINMENT_INTEGRITY_CRITICAL)
			threat = min(3, threat + 2)
		else if(integ < CONTAINMENT_INTEGRITY_LOW)
			threat = min(3, threat + 1)
	return threat

/datum/controller/subsystem/scp_patrol/proc/generate_dynamic_route(zone)
	var/breaches = 0
	if(SSscp_persistence?.manager)
		breaches = SSscp_persistence?.manager?.active_breaches
	if(breaches <= 0)
		return null
	var/waypoints = 3 + min(4, breaches)
	var/threat = min(3, 2 + breaches)
	var/reward = 5 + threat * 5 + breaches * 5
	var/list/route = list(
		"route_id" = "dynamic_[world.time]",
		"name" = "Emergency [uppertext(zone)] Sweep",
		"zone" = zone,
		"waypoints" = waypoints,
		"threat_level" = threat,
		"reward_research" = reward,
		"description" = "Emergency patrol route generated due to active containment breach in [uppertext(zone)]. High threat level.",
	)
	return route

/datum/computer_file/program/scp_patrol
	filename = "scp_patrol"
	filedesc = "SCP Patrol Management"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Manage patrol routes, report anomalies, and coordinate security patrols across the facility."
	size = 2
	tgui_id = "ScpPatrol"
	program_icon = "route"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = FALSE
	required_access = list(ACCESS_SECURITY)

/datum/computer_file/program/scp_patrol/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		data["access_denied"] = TRUE
		return data
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		data["access_denied"] = TRUE
		return data
	data["access_denied"] = FALSE
	if(!SSscp_patrol)
		return data
	data["patrol_routes"] = SSscp_patrol.patrol_routes
	var/list/user_patrols = list()
	for(var/list/A in SSscp_patrol.active_patrols)
		if(A["guard_ckey"] == H.ckey)
			user_patrols += list(A)
	data["active_patrols"] = user_patrols
	var/list/recent_log = list()
	var/log_len = length(SSscp_patrol.patrol_log)
	var/log_start = max(1, log_len - 19)
	for(var/i in log_start to log_len)
		recent_log += list(SSscp_patrol.patrol_log[i])
	data["patrol_log"] = recent_log
	var/list/recent_anomalies = list()
	var/anom_len = length(SSscp_patrol.anomaly_reports)
	var	anom_start = max(1, anom_len - 19)
	for(var/i in anom_start to anom_len)
		recent_anomalies += list(SSscp_patrol.anomaly_reports[i])
	data["anomaly_reports"] = recent_anomalies
	data["guard_stats"] = SSscp_patrol.get_guard_stats(H.ckey)
	data["total_patrols_completed"] = SSscp_patrol.total_patrols_completed
	data["total_anomalies_reported"] = SSscp_patrol.total_anomalies_reported
	data["total_breach_responses"] = SSscp_patrol.total_breach_responses
	data["total_contraband_seized"] = SSscp_patrol.total_contraband_seized
	var/list/zone_threat_levels = list(
		"lcz" = SSscp_patrol.get_zone_threat_level("lcz"),
		"hcz" = SSscp_patrol.get_zone_threat_level("hcz"),
		"ez" = SSscp_patrol.get_zone_threat_level("ez"),
	)
	data["zone_threat_levels"] = zone_threat_levels
	return data

/datum/computer_file/program/scp_patrol/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		return
	if(!SSscp_patrol)
		return
	switch(action)
		if("accept_patrol")
			var/route_id = params["route_id"]
			if(!route_id)
				return
			SSscp_patrol.accept_patrol(route_id, H)
			. = TRUE
		if("visit_checkpoint")
			SSscp_patrol.visit_checkpoint(H.ckey)
			. = TRUE
		if("complete_patrol")
			SSscp_patrol.complete_patrol(H.ckey, TRUE)
			. = TRUE
		if("abandon_patrol")
			SSscp_patrol.abandon_patrol(H.ckey)
			. = TRUE
		if("report_anomaly")
			var/anomaly_type = params["anomaly_type"]
			var/location = params["location"] || "Unknown"
			var/description = params["description"] || ""
			if(!anomaly_type)
				return
			SSscp_patrol.report_anomaly(H.ckey, anomaly_type, location, description)
			. = TRUE
		if("respond_to_breach")
			var/scp_id = params["scp_id"]
			if(!scp_id)
				return
			SSscp_patrol.respond_to_breach(H.ckey, scp_id)
			. = TRUE
		if("seize_contraband")
			var/item_name = params["item_name"]
			var/dclass_name = params["dclass_name"]
			if(!item_name || !dclass_name)
				return
			SSscp_patrol.seize_contraband(H.ckey, item_name, dclass_name)
			. = TRUE
