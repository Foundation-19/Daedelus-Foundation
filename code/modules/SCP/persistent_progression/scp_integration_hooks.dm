#ifndef THREAT_LEVEL_GREEN
#define THREAT_LEVEL_GREEN 0
#define THREAT_LEVEL_YELLOW 1
#define THREAT_LEVEL_ORANGE 2
#define THREAT_LEVEL_RED 3
#endif

#ifndef DISPATCH_SECURITY
#define DISPATCH_SECURITY 1
#define DISPATCH_MEDICAL 2
#define DISPATCH_ENGINEERING 3
#define DISPATCH_MTF 4
#endif

#ifndef NETWORK_NODE_OFFLINE
#define NETWORK_NODE_OFFLINE 0
#define NETWORK_NODE_ONLINE 1
#define NETWORK_NODE_DEGRADED 2
#define NETWORK_NODE_COMPROMISED 3
#endif

var/list/scp_breach_cooldown = list()

/proc/hook_scp_breach(scp_id, atom/scp_atom)
	if(!scp_id)
		return FALSE

	if(scp_breach_cooldown[scp_id] && world.time < scp_breach_cooldown[scp_id])
		return FALSE

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
		if(instance && instance.containment_status == "breached")
			return FALSE

	scp_breach_cooldown[scp_id] = world.time + 5 MINUTES

	var/breach_zone = "unknown"
	if(scp_atom)
		var/area/A = get_area(scp_atom)
		breach_zone = get_containment_zone(A) || "unknown"

	log_game("SCP Breach: [scp_id] at [scp_atom ? get_area_name(scp_atom) : "unknown"]")

	if(SSfacility_announcements)
		SSfacility_announcements.announce_breach(scp_id, breach_zone)

	if(breach_zone == "lcz" || breach_zone == "hcz")
		set_zone_emergency_lighting(breach_zone, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/conditional_restore_zone_lighting, breach_zone, scp_id), 5 MINUTES)

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
		if(instance)
			instance.containment_status = "breached"
			instance.containment_health = 0
			instance.last_breach = world.time
			instance.add_breach_record()

		SSscp_persistence?.manager?.active_breaches++
		SSscp_persistence?.manager?.global_containment_stability = max(0, SSscp_persistence?.manager?.global_containment_stability - 10)

	var/is_keter = FALSE
	if(SSscp_persistence?.manager?.scp_instances?[scp_id])
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
		if(instance.containment_class == SCP_KETER)
			is_keter = TRUE

	if(SSsecurity_level)
		var/target_level = SEC_LEVEL_RED
		if(is_keter)
			target_level = SEC_LEVEL_DELTA
		if(SSsecurity_level.current_level < target_level)
			set_foundation_security_code(target_level, "Containment breach: [scp_id]")

	if(SScontainment_evaluation)
		trigger_containment_evaluation(scp_id)

	if(SSpersistent_progression && SSpersistent_progression.analytics_manager)
		SSpersistent_progression.analytics_manager.track_event(null, "scp_breach", list("scp_id" = scp_id, "zone" = breach_zone))

	if(scp_atom && (breach_zone == "lcz" || breach_zone == "hcz"))
		for(var/mob/living/carbon/human/H in range(7, scp_atom))
			if(H.stat == DEAD || !H.ckey)
				continue
			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(id_card && (ACCESS_SECURITY in id_card.access))
				report_first_responder(H, scp_id)
				break

	report_breach_to_round_log(scp_id, breach_zone)
	track_containment_breach_response(scp_id, list())

	if(SSscp_gameplay)
		SSscp_gameplay.seal_zone_doors(breach_zone)
		log_round_event("scp_breach", "[scp_id] breached in [breach_zone]", scp_id)

	if(istype(scp_atom, /mob/living/scp))
		var/mob/living/scp/S = scp_atom
		S.evolve_from_interaction()

	if(GLOB.scp_role_controller)
		var/scp_type = get_scp_type_from_id(scp_id)
		if(scp_type)
			addtimer(CALLBACK(GLOB.scp_role_controller, TYPE_PROC_REF(/datum/scp_role_controller, offer_all_available_scp_roles)), 30 SECONDS)

	if(SSfoundation_comms)
		var/_hook_threat_level = THREAT_LEVEL_YELLOW
		if(findtext(scp_id, "682") || findtext(scp_id, "106"))
			_hook_threat_level = THREAT_LEVEL_RED
		else if(findtext(scp_id, "096") || findtext(scp_id, "049") || findtext(scp_id, "457") || findtext(scp_id, "939"))
			_hook_threat_level = THREAT_LEVEL_ORANGE
		var/_hook_loc_name = "Unknown"
		if(scp_atom)
			var/area/_hook_A = get_area(scp_atom)
			if(_hook_A)
				_hook_loc_name = _hook_A.name
		SSfoundation_comms.register_threat("SCP-[scp_id] Containment Breach", "scp_breach", _hook_threat_level, _hook_loc_name, "SCP-[scp_id] has breached containment. All personnel exercise extreme caution.")
		SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "SCP-[scp_id] containment breach in [_hook_loc_name]. All security personnel respond immediately.", 2)
		SSfoundation_comms.create_dispatch(null, DISPATCH_MTF, "SCP-[scp_id] breach confirmed. Mobilize containment teams to [_hook_loc_name].", 2)

	if(findtext(scp_id, "079") && SSit_network)
		SSit_network.scp079_network_presence = min(100, SSit_network.scp079_network_presence + 40)
		if(SSraisa)
			var/datum/info_breach/_hook_IB = new("SCP-079 Network Intrusion", "SCP-079", "Facility network systems", 3)
			SSraisa.register_breach(_hook_IB)

	if(SSanomalous_investigations)
		SSanomalous_investigations.open_case("SCP-[scp_id]", "Automatic case opened due to SCP-[scp_id] containment breach.")

	hook_breach_budget_impact(scp_id)
	hook_breach_mtf_auto_deploy(scp_id)
	hook_breach_containment_integrity(scp_id, scp_atom)
	hook_breach_medical_response(scp_id, scp_atom)
	hook_breach_ventilation_contamination(scp_id, scp_atom)
	hook_breach_triage_detection(scp_id, scp_atom)
	hook_breach_patrol_generation(scp_id, scp_atom)

	if(scp_atom && minimap_renderer)
		var/datum/minimap_marker/marker = new(scp_atom, MINIMAP_LAYER_SECURITY | MINIMAP_LAYER_MTF | MINIMAP_LAYER_COMMAND, "#ff0000", "minimap_breach_[scp_id]")
		GLOB.minimap_markers[scp_id] = marker

	if(GLOB.foundation_network)
		var/datum/net_bus/containment_bus = GLOB.foundation_network.get_bus(NET_CHANNEL_CONTAINMENT)
		if(containment_bus)
			var/datum/net_signal/breach_signal = new(list("scp_id" = scp_id, "zone" = breach_zone, "time" = world.time), NET_CMD_ALERT, null, NET_TRANSMIT_WIRED)
			containment_bus.broadcast_packet(breach_signal)

	return TRUE

/proc/get_scp_type_from_id(scp_id)
	if(!scp_id)
		return null
	var/id = lowertext(scp_id)
	if(findtext(id, "173"))
		return SCP_ROLE_173
	if(findtext(id, "096"))
		return SCP_ROLE_096
	if(findtext(id, "008"))
		return SCP_ROLE_008
	if(findtext(id, "035"))
		return SCP_ROLE_035
	if(findtext(id, "049"))
		return SCP_ROLE_049
	if(findtext(id, "079"))
		return SCP_ROLE_079
	if(findtext(id, "106"))
		return SCP_ROLE_106
	if(findtext(id, "457"))
		return SCP_ROLE_457
	if(findtext(id, "939"))
		return SCP_ROLE_939
	if(findtext(id, "682"))
		return SCP_ROLE_682
	return null

/proc/hook_scp_recontainment(scp_id, list/participants)
	if(!scp_id)
		return FALSE

	scp_breach_cooldown -= scp_id

	log_game("SCP Recontained: [scp_id]")

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
		if(instance)
			instance.containment_status = "contained"
			instance.containment_health = 100
			instance.add_interaction_record(null, "recontained")

		SSscp_persistence?.manager?.active_breaches = max(0, SSscp_persistence?.manager?.active_breaches - 1)
		SSscp_persistence?.manager?.global_containment_stability = min(100, SSscp_persistence?.manager?.global_containment_stability + 5)

	if(SScontainment_evaluation)
		complete_containment_evaluation(scp_id, participants)

	report_recontainment_to_round_log(scp_id, participants)

	if(SSscp_gameplay)
		log_round_event("scp_recontainment", "[scp_id] recontained", scp_id)

	if(SSround_objectives)
		SSround_objectives.report_objective_progress("guard_recontain", 1)

	if(SSpersistent_progression)
		if(participants)
			for(var/mob/living/carbon/human/H in participants)
				if(H.ckey)
					SSpersistent_progression.award_experience(H.ckey, "scp_containment_assist", 0, "SCP-[scp_id] Recontainment")
					var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(H.ckey)
					if(pdata)
						pdata.total_recontainments++
						if(pdata.current_job)
							pdata.respond_to_containment_breach(pdata.current_job, scp_id, "recontainment", "successful")

		if(SSpersistent_progression.analytics_manager)
			SSpersistent_progression.analytics_manager.track_event(null, "scp_recontainment", list("scp_id" = scp_id, "participants" = length(participants || list())))

	if(SSfoundation_comms)
		for(var/datum/facility_threat/T in SSfoundation_comms.threats)
			if(!T.resolved && findtext(T.threat_name, scp_id))
				var/_hook_resolver = "Containment Team"
				if(participants && length(participants))
					var/list/_hook_names = list()
					for(var/mob/living/carbon/human/H in participants)
						_hook_names += H.real_name
					if(length(_hook_names))
						_hook_resolver = jointext(_hook_names, ", ")
				T.resolve(_hook_resolver)
		SSfoundation_comms.recalculate_threat_level()

	if(SSanomalous_investigations)
		SSanomalous_investigations.close_case("SCP-[scp_id]")

	if(findtext(scp_id, "079") && SSit_network)
		SSit_network.scp079_network_presence = max(0, SSit_network.scp079_network_presence - 30)
		for(var/datum/network_node/N in SSit_network.nodes)
			N.scp079_influence = max(0, N.scp079_influence - 15)
			if(N.scp079_influence <= 50 && N.integrity >= 50)
				N.status = NETWORK_NODE_ONLINE
		SSit_network.recalculate_integrity()

	hook_recontainment_budget_recovery(scp_id, participants)
	hook_recontainment_security_level_downgrade()
	hook_recontainment_integrity_repair(scp_id)

	var/datum/minimap_marker/old_marker = GLOB.minimap_markers[scp_id]
	if(old_marker)
		GLOB.minimap_markers -= scp_id
		qdel(old_marker)

	return TRUE

/proc/hook_scp_interaction(mob/living/carbon/human/player, scp_id, interaction_type, list/data = null)
	if(!player || !scp_id)
		return FALSE
	if(SSscp_interactions)
		SSscp_interactions.manager?.log_interaction(player, scp_id, interaction_type, data)
	hook_dclass_scp_interaction(player, scp_id, interaction_type, data)
	track_scp_interaction(player, scp_id, interaction_type, "completed")

	if(SSpersistent_progression)
		var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(player.ckey)
		if(pdata)
			pdata.total_scp_interactions++
			if(pdata.current_job)
				pdata.interact_with_scp(pdata.current_job, scp_id, "interaction", "completed")
			if(interaction_type == INTERACTION_TYPE_OBSERVATION)
				SSpersistent_progression.award_experience(player.ckey, "scp_observation", 0, "SCP-[scp_id] Observation")
			else if(interaction_type == INTERACTION_TYPE_RESEARCH)
				SSpersistent_progression.award_experience(player.ckey, "scp_research_contribution", 0, "SCP-[scp_id] Research")
			else if(interaction_type == INTERACTION_TYPE_CARE)
				SSpersistent_progression.award_experience(player.ckey, "scp_care_provided", 0, "SCP-[scp_id] Care")

	if(interaction_type == INTERACTION_TYPE_MEDICAL && SSround_objectives)
		SSround_objectives.report_objective_progress("medical_treat", 1)

	if(interaction_type == INTERACTION_TYPE_COMBAT && SSraisa)
		SSraisa.record_incident(player)

	if(interaction_type == INTERACTION_TYPE_OBSERVATION && SSraisa)
		SSraisa.record_observation(player)

	if(SSpsychology)
		var/_hook_exp_type = "physical"
		if(interaction_type == INTERACTION_TYPE_COMMUNICATION)
			_hook_exp_type = "cognitive"
		else if(interaction_type == INTERACTION_TYPE_EXPLORATION)
			_hook_exp_type = "environmental"
		else if(interaction_type == INTERACTION_TYPE_COMBAT)
			_hook_exp_type = "traumatic"
		else if(interaction_type == INTERACTION_TYPE_EXPERIMENT)
			_hook_exp_type = "experimental"
		var/_hook_symptoms = ""
		if(interaction_type == INTERACTION_TYPE_COMBAT)
			_hook_symptoms = "Elevated stress response, possible PTSD indicators"
		else if(interaction_type == INTERACTION_TYPE_COMMUNICATION)
			_hook_symptoms = "Mild cognitive dissonance reported"
		SSpsychology.record_exposure(player, "SCP-[scp_id]", _hook_exp_type, _hook_symptoms)
		if(ishuman(player))
			var/mob/living/carbon/human/_hook_H = player
			if(_hook_H.sanity && interaction_type == INTERACTION_TYPE_COMBAT)
				_hook_H.sanity.adjust_sanity(-5, "scp_combat")
			else if(_hook_H.sanity && interaction_type == INTERACTION_TYPE_COMMUNICATION)
				_hook_H.sanity.adjust_sanity(-2, "scp_communication")

	return TRUE

/proc/hook_scp_observation(mob/living/carbon/human/observer, scp_id)
	if(!observer || !scp_id)
		return FALSE
	hook_scp_interaction(observer, scp_id, INTERACTION_TYPE_OBSERVATION)
	return TRUE

/proc/hook_scp_combat(mob/living/carbon/human/fighter, scp_id, damage_dealt = 0, damage_taken = 0)
	if(!fighter || !scp_id)
		return FALSE
	var/list/data = list("damage_dealt" = damage_dealt, "damage_taken" = damage_taken)
	hook_scp_interaction(fighter, scp_id, INTERACTION_TYPE_COMBAT, data)
	if(fighter.ckey && SSpersistent_progression)
		SSpersistent_progression.award_experience(fighter.ckey, "scp_combat", 0, "SCP-[scp_id] Combat")
		var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(fighter.ckey)
		if(pdata)
			pdata.total_damage_dealt += damage_dealt
	return TRUE

/proc/hook_scp_research(mob/living/carbon/human/researcher, scp_id, research_type = "general")
	if(!researcher || !scp_id)
		return FALSE
	hook_scp_interaction(researcher, scp_id, INTERACTION_TYPE_RESEARCH, list("type" = research_type))
	if(SSfoundation_budget)
		var/_hook_bonus = 500
		if(research_type == "breakthrough")
			_hook_bonus = 2000
		else if(research_type == "detailed")
			_hook_bonus = 1000
		var/datum/department_budget/B = SSfoundation_budget.department_budgets["science"]
		if(B)
			B.allocate(_hook_bonus)
	if(SSraisa)
		SSraisa.record_observation(researcher)
	return TRUE

/proc/hook_scp_experiment(mob/living/carbon/human/researcher, scp_id, experiment_type)
	if(!researcher || !scp_id)
		return FALSE
	hook_scp_interaction(researcher, scp_id, INTERACTION_TYPE_EXPERIMENT, list("type" = experiment_type))
	if(researcher.ckey && SSpersistent_progression)
		var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(researcher.ckey)
		if(pdata)
			pdata.total_research_completed++
	return TRUE

/proc/hook_scp_care(mob/living/carbon/human/caregiver, scp_id, care_type = "standard")
	if(!caregiver || !scp_id)
		return FALSE
	hook_scp_interaction(caregiver, scp_id, INTERACTION_TYPE_CARE, list("type" = care_type))
	return TRUE

/proc/hook_scp_communication(mob/living/carbon/human/speaker, scp_id, message = "")
	if(!speaker || !scp_id)
		return FALSE
	hook_scp_interaction(speaker, scp_id, INTERACTION_TYPE_COMMUNICATION, list("message" = message))
	return TRUE

/proc/hook_scp_exploration(mob/living/carbon/human/explorer, scp_id, depth = 0, duration = 0)
	if(!explorer || !scp_id)
		return FALSE
	hook_scp_interaction(explorer, scp_id, INTERACTION_TYPE_EXPLORATION, list("depth" = depth, "duration" = duration))
	if(explorer.ckey && SSpersistent_progression)
		SSpersistent_progression.award_experience(explorer.ckey, "scp_exploration_milestone", 0, "SCP-[scp_id] Exploration")
	return TRUE

/proc/hook_player_death_near_scp(mob/living/carbon/human/victim, scp_id)
	if(!victim || !scp_id)
		return
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
		if(instance)
			instance.add_interaction_record(victim, "player_death")
	if(SScontainment_evaluation)
		report_containment_casualty(scp_id, 1)
	if(victim.ckey && SSpersistent_progression)
		var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(victim.ckey)
		if(pdata)
			pdata.total_deaths++

	if(SSanomalous_investigations)
		var/area/_hook_A = get_area(victim)
		var/_hook_loc_name = _hook_A ? _hook_A.name : "Unknown"
		var/datum/anomalous_evidence/_hook_E = new(null, "Biological", _hook_loc_name, "SCP-[scp_id]", "Casualty event: [victim.real_name] died near SCP-[scp_id] in [_hook_loc_name]")
		SSanomalous_investigations.log_evidence(_hook_E)

	if(SSfoundation_comms)
		for(var/datum/facility_threat/T in SSfoundation_comms.threats)
			if(!T.resolved && findtext(T.threat_name, scp_id) && T.threat_level < THREAT_LEVEL_RED)
				T.threat_level = min(THREAT_LEVEL_RED, T.threat_level + 1)
		SSfoundation_comms.recalculate_threat_level()

	if(SSraisa)
		SSraisa.record_incident(victim)

	if(SSpsychology)
		for(var/mob/living/carbon/human/H in hearers(7, victim))
			if(H != victim && H.stat != DEAD)
				SSpsychology.record_exposure(H, "SCP-[scp_id]", "witnessed_casualty", "Witnessed death of [victim.real_name] near SCP-[scp_id]")
				if(H.sanity)
					H.sanity.adjust_sanity(-10, "witnessed_scp_casualty")

/proc/hook_scp_damage(scp_id, damage_percent)
	if(!scp_id)
		return
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
		if(instance)
			instance.containment_health = max(0, instance.containment_health - damage_percent)
			if(instance.containment_health < 50 && instance.containment_status != "breached")
				hook_scp_breach(scp_id)
	if(SScontainment_evaluation)
		report_scp_damage(scp_id, damage_percent)

/proc/hook_facility_damage_near_scp(scp_id, damage_level)
	if(!scp_id)
		return
	if(SScontainment_evaluation)
		report_facility_damage(scp_id, damage_level)

/proc/hook_breach_containment_integrity(scp_id, atom/scp_atom)
	if(!SScontainment_integrity)
		return
	var/target_zone = null
	if(scp_atom)
		var/area/A = get_area(scp_atom)
		if(A)
			var/zone_name = get_containment_zone(A)
			if(zone_name)
				target_zone = zone_name
	if(!target_zone)
		for(var/list/Z in SScontainment_integrity.containment_zones)
			if(findtext(Z["name"], scp_id) || findtext(scp_id, Z["name"]))
				target_zone = Z["name"]
				break
	if(target_zone)
		SScontainment_integrity.repair_zone(target_zone, -30)
		SScontainment_integrity.generate_maintenance_task(target_zone, "breach_damage_[scp_id]")

/proc/hook_breach_medical_response(scp_id, atom/scp_atom)
	if(!SSscp_medical_response || !scp_atom)
		return
	for(var/mob/living/carbon/human/H in range(7, scp_atom))
		if(H.stat == DEAD || !H.ckey)
			continue
		if(H.getBruteLoss() > 20 || H.getFireLoss() > 20 || H.getToxLoss() > 20)
			SSscp_medical_response.report_scp_injury(H, "Breach-related injury", 3, "SCP-[scp_id]")

/proc/hook_breach_ventilation_contamination(scp_id, atom/scp_atom)
	if(!SSzone_ventilation)
		return
	var/zone_id = 0
	if(scp_atom)
		var/area/A = get_area(scp_atom)
		var/zone = get_containment_zone(A)
		if(zone == "lcz")
			zone_id = 1
		else if(zone == "hcz")
			zone_id = 2
		else if(zone == "ez")
			zone_id = 3
	if(zone_id > 0)
		SSzone_ventilation.report_contamination(zone_id, 15, "SCP-[scp_id] breach")

/proc/hook_recontainment_integrity_repair(scp_id)
	if(!SScontainment_integrity)
		return
	var/target_zone = null
	for(var/list/Z in SScontainment_integrity.containment_zones)
		if(findtext(Z["name"], scp_id) || findtext(scp_id, Z["name"]))
			target_zone = Z["name"]
			break
	if(target_zone)
		SScontainment_integrity.repair_zone(target_zone, 25)

/proc/hook_breach_triage_detection(scp_id, atom/scp_atom)
	if(!SSscp_triage || !scp_atom)
		return
	SSscp_triage.auto_detect_patients()

/proc/hook_breach_patrol_generation(scp_id, atom/scp_atom)
	if(!SSscp_patrol || !scp_atom)
		return
	var/area/A = get_area(scp_atom)
	var/zone = get_containment_zone(A)
	if(zone)
		SSscp_patrol.generate_dynamic_route(zone)
