/datum/breach_strategy
	var/breach_min_elapsed = 15 MINUTES
	var/anomaly_min_elapsed = 5 MINUTES

/datum/breach_strategy/proc/get_breach_interval()
	return 20 MINUTES

/datum/breach_strategy/proc/get_anomaly_interval()
	return 10 MINUTES

/datum/breach_strategy/proc/get_reinforcement_interval()
	return 15 MINUTES

/datum/breach_strategy/controlled
	breach_min_elapsed = 15 MINUTES
	anomaly_min_elapsed = 5 MINUTES

/datum/breach_strategy/controlled/get_breach_interval()
	return 20 MINUTES

/datum/breach_strategy/controlled/get_anomaly_interval()
	return 10 MINUTES

/datum/breach_strategy/controlled/get_reinforcement_interval()
	return 15 MINUTES

/datum/breach_strategy/cascading
	breach_min_elapsed = 5 MINUTES
	anomaly_min_elapsed = 2 MINUTES

/datum/breach_strategy/cascading/get_breach_interval()
	return 8 MINUTES

/datum/breach_strategy/cascading/get_anomaly_interval()
	return 5 MINUTES

/datum/breach_strategy/cascading/get_reinforcement_interval()
	return 6 MINUTES

/datum/breach_strategy/debug
	breach_min_elapsed = 1 MINUTES
	anomaly_min_elapsed = 30 SECONDS

/datum/breach_strategy/debug/get_breach_interval()
	return 2 MINUTES

/datum/breach_strategy/debug/get_anomaly_interval()
	return 1 MINUTES

/datum/breach_strategy/debug/get_reinforcement_interval()
	return 1 MINUTES

/datum/facility_director
	var/datum/breach_strategy/strategy
	var/next_breach_event
	var/next_anomaly_event
	var/next_reinforcement_event
	var/breach_start_time = 30 MINUTES
	var/anomaly_start_time = 10 MINUTES
	var/reinforcement_start_time = 23 MINUTES
	var/alive_breach_percentage_threshold = 0.1
	var/dead_crew_threshold = 0.3
	var/minimum_population = 10
	var/round_start_time = 0
	var/static/list/breach_event_pool = list(
		list(/datum/round_event_control/scp_containment_breach, 20, 15 MINUTES),
		list(/datum/round_event_control/scp_power_fluctuation, 15, 5 MINUTES),
		list(/datum/round_event_control/scp_containment_degradation, 15, 10 MINUTES),
	)
	var/static/list/anomaly_event_pool = list(
		list(/datum/round_event_control/scp_memetic_outbreak, 15, 15 MINUTES),
		list(/datum/round_event_control/scp_cognito_hazard, 10, 20 MINUTES),
		list(/datum/round_event_control/scp_power_surge, 15, 10 MINUTES),
		list(/datum/round_event_control/scp_vent_contamination, 10, 15 MINUTES),
	)

/datum/facility_director/New()
	strategy = new /datum/breach_strategy/controlled()
	round_start_time = world.time
	next_breach_event = world.time + breach_start_time
	next_anomaly_event = world.time + anomaly_start_time
	next_reinforcement_event = world.time + reinforcement_start_time
	START_PROCESSING(SSprocessing, src)

/datum/facility_director/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(strategy)
	return ..()

/datum/facility_director/process(delta_time)
	var/active_players = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!QDELETED(H) && H.stat != DEAD && H.client)
			active_players++
	if(active_players < minimum_population)
		return
	if(world.time >= next_breach_event)
		check_breach_cycle()
	if(world.time >= next_anomaly_event)
		check_anomaly_cycle()
	if(world.time >= next_reinforcement_event)
		check_reinforcement_cycle()

/datum/facility_director/proc/check_breach_cycle()
	next_breach_event = world.time + strategy.get_breach_interval()
	var/elapsed = world.time - round_start_time
	var/list/valid_events = list()
	for(var/list/pool_entry in breach_event_pool)
		var/event_type = pool_entry[1]
		var/weight = pool_entry[2]
		var/min_time = pool_entry[3]
		if(elapsed >= min_time)
			valid_events[event_type] = weight
	if(!length(valid_events))
		return
	var/picked_type = pick_weight(valid_events)
	fire_breach_event(picked_type)

/datum/facility_director/proc/check_anomaly_cycle()
	next_anomaly_event = world.time + strategy.get_anomaly_interval()
	var/elapsed = world.time - round_start_time
	var/list/valid_events = list()
	for(var/list/pool_entry in anomaly_event_pool)
		var/event_type = pool_entry[1]
		var/weight = pool_entry[2]
		var/min_time = pool_entry[3]
		if(elapsed >= min_time)
			valid_events[event_type] = weight
	if(!length(valid_events))
		return
	var/picked_type = pick_weight(valid_events)
	fire_anomaly_event(picked_type)

/datum/facility_director/proc/check_reinforcement_cycle()
	next_reinforcement_event = world.time + strategy.get_reinforcement_interval()
	var/breached_count = 0
	var/total_scp_count = 0
	var/dead_crew = 0
	var/total_crew = 0
	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
			total_scp_count++
			if(instance.containment_status == "breached")
				breached_count++
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || !H.client)
			continue
		total_crew++
		if(H.stat == DEAD)
			dead_crew++
	var/breach_ratio = total_scp_count > 0 ? breached_count / total_scp_count : 0
	var/dead_ratio = total_crew > 0 ? dead_crew / total_crew : 0
	if(breach_ratio >= alive_breach_percentage_threshold)
		deploy_mtf_reinforcements()
	else if(dead_ratio >= dead_crew_threshold)
		deploy_crew_reinforcements()

/datum/facility_director/proc/deploy_mtf_reinforcements()
	var/list/breached_scps = list()
	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
			if(instance.containment_status == "breached")
				breached_scps += scp_id
	var/scp_list = length(breached_scps) ? english_list(breached_scps) : "unknown entities"
	priority_announce("ALERT: Mobile Task Force dispatch authorized. Active breaches: [scp_list]. All personnel cooperate with MTF operations.", "MTF DEPLOYMENT", null, ANNOUNCER_ALERT)
	for(var/obj/machinery/mtf_deployment_console/console in world)
		if(QDELETED(console))
			continue
		var/list/team_data = console.available_teams?["mtf_epsilon11"]
		if(team_data)
			console.deploy_mtf_team("mtf_epsilon11", team_data, null)
			break

/datum/facility_director/proc/deploy_crew_reinforcements()
	priority_announce("EMERGENCY: Critical personnel losses detected. Emergency crew reinforcements authorized. All available personnel assist with recontainment.", "EMERGENCY REINFORCEMENTS", null, ANNOUNCER_ALERT)

/datum/facility_director/proc/fire_breach_event(event_type)
	for(var/datum/round_event_control/E as anything in SSevents.control)
		if(E.type == event_type)
			SSevents.TriggerEvent(E)
			return

/datum/facility_director/proc/fire_anomaly_event(event_type)
	for(var/datum/round_event_control/E as anything in SSevents.control)
		if(E.type == event_type)
			SSevents.TriggerEvent(E)
			return
