/datum/game_mode/scp_keter_scenario
	name = "Keter Scenario"
	weight = GAMEMODE_WEIGHT_RARE
	votable = TRUE

	min_pop = 25
	required_enemies = 0
	max_pop = INFINITY

	var/scenario_phase = 0
	var/list/keter_breached = list()
	var/nuke_armed = FALSE
	var/nuke_timer_id
	var/nuke_detonation_time = 10 MINUTES
	var/round_start_time
	var/evacuation_progress = 0

/datum/game_mode/scp_keter_scenario/pre_setup()
	..()
	return TRUE

/datum/game_mode/scp_keter_scenario/post_setup(report)
	. = ..()
	round_start_time = world.time
	scenario_phase = 1

	priority_announce("CRITICAL ALERT: Multiple Keter-class SCPs showing anomalous activity spikes. Emergency containment protocols initiated. All personnel prepare for worst-case scenario.", "KETER WARNING", sound_type = ANNOUNCER_ALERT)

	addtimer(CALLBACK(src, .proc/trigger_keter_breach), rand(3 MINUTES, 8 MINUTES))

/datum/game_mode/scp_keter_scenario/proc/trigger_keter_breach()
	scenario_phase = 2

	var/list/keter_scps = list("SCP-106", "SCP-682", "SCP-939")
	var/list/euclid_scps = list("SCP-173", "SCP-049", "SCP-096", "SCP-457")

	for(var/scp_id in keter_scps)
		if(SSscp_persistence?.manager?.scp_instances?[scp_id])
			var/atom/scp_atom = find_scp_mob(scp_id)
			hook_scp_breach(scp_id, scp_atom)
			keter_breached += scp_id

	if(length(SSticker.ready_players) >= 35)
		var/euclid_id = pick(euclid_scps)
		var/atom/euclid_atom = find_scp_mob(euclid_id)
		hook_scp_breach(euclid_id, euclid_atom)
		keter_breached += euclid_id

	priority_announce("CATALYTIC EVENT: [english_list(keter_breached)] STATUS: BREACHED. THIS IS NOT A DRILL. O5 COUNCIL NOTIFIED. ON-SITE NUCLEAR DEVICE ON STANDBY.", "KETER CATASTROPHIC", sound_type = ANNOUNCER_ALERT)
	trigger_facility_lockdown("Keter-class containment failure")

	addtimer(CALLBACK(src, .proc/consider_nuke), 20 MINUTES)

/datum/game_mode/scp_keter_scenario/proc/consider_nuke()
	if(scenario_phase < 2)
		return
	var/still_breached = 0
	for(var/scp_id in keter_breached)
		if(SSscp_persistence?.manager?.scp_instances?[scp_id])
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(instance.containment_status == "breached")
				still_breached++
	if(still_breached >= 2)
		priority_announce("O5 ORDER: On-site nuclear warhead authorization granted. Site Director may initiate detonation sequence if recontainment fails.", "O5 COUNCIL", sound_type = ANNOUNCER_ALERT)
		nuke_armed = TRUE

/datum/game_mode/scp_keter_scenario/proc/activate_nuke(mob/user)
	if(!nuke_armed)
		return
	if(nuke_timer_id)
		return
	nuke_timer_id = addtimer(CALLBACK(src, .proc/detonate_nuke), nuke_detonation_time, TIMER_STOPPABLE)
	priority_announce("WARNING: ON-SITE NUCLEAR DEVICE ACTIVATED. DETONATION IN [DisplayTimeText(nuke_detonation_time)]. ALL PERSONNEL EVACUATE IMMEDIATELY.", "NUCLEAR ALERT", sound_type = ANNOUNCER_ALERT)

/datum/game_mode/scp_keter_scenario/proc/cancel_nuke(mob/user)
	if(!nuke_timer_id)
		return
	deltimer(nuke_timer_id)
	nuke_timer_id = null
	priority_announce("NOTICE: Nuclear detonation sequence cancelled.", "NUCLEAR ALERT", sound_type = ANNOUNCER_DEFAULT)

/datum/game_mode/scp_keter_scenario/proc/detonate_nuke()
	GLOB.station_was_nuked = TRUE
	SSticker.set_force_ending(TRUE)

/datum/game_mode/scp_keter_scenario/process(delta_time)
	if(scenario_phase >= 2)
		var/contained_count = 0
		for(var/scp_id in keter_breached)
			if(SSscp_persistence?.manager?.scp_instances?[scp_id])
				var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
				if(instance.containment_status == "contained" || instance.containment_status == "neutralized")
					contained_count++
		if(contained_count >= length(keter_breached))
			scenario_phase = 3
			priority_announce("NOTICE: All Keter-class SCPs recontained. Facility returning to emergency operations.", "KETER RESOLVED", sound_type = ANNOUNCER_DEFAULT)
			addtimer(CALLBACK(src, .proc/end_round), 3 MINUTES)

/datum/game_mode/scp_keter_scenario/proc/end_round()
	SSticker.set_force_ending(TRUE)

/datum/game_mode/scp_keter_scenario/check_finished()
	..()
	if(!SSticker.setup_done)
		return FALSE
	if(GLOB.station_was_nuked)
		return TRUE
	if(scenario_phase >= 3)
		return TRUE
	var/time_elapsed = world.time - round_start_time
	if(time_elapsed > 90 MINUTES)
		return TRUE
	return FALSE

/datum/game_mode/scp_keter_scenario/set_round_result()
	if(GLOB.station_was_nuked)
		SSticker.mode_result = "Nuclear Detonation - Facility Destroyed"
	else if(scenario_phase >= 3)
		SSticker.mode_result = "Foundation Victory - Keter SCPs Recontained"
	else
		SSticker.mode_result = "Containment Failure - Keter SCPs Active"
