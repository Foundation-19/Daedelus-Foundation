#ifndef INTERACTION_TYPE_OBSERVATION
#define INTERACTION_TYPE_OBSERVATION 1
#define INTERACTION_TYPE_COMBAT 2
#define INTERACTION_TYPE_CONTAINMENT 3
#define INTERACTION_TYPE_RESEARCH 4
#define INTERACTION_TYPE_COMMUNICATION 5
#define INTERACTION_TYPE_EXPERIMENT 6
#define INTERACTION_TYPE_CARE 7
#define INTERACTION_TYPE_EXPLORATION 8
#define INTERACTION_TYPE_SURVIVAL 9
#define INTERACTION_TYPE_MEDICAL 10

#define INTERACTION_RISK_NONE 0
#define INTERACTION_RISK_LOW 1
#define INTERACTION_RISK_MEDIUM 2
#define INTERACTION_RISK_HIGH 3
#define INTERACTION_RISK_CRITICAL 4
#endif

/proc/hook_scp_breach(scp_id, atom/scp_atom)
	if(!scp_id)
		return FALSE

	var/breach_zone = "unknown"
	if(scp_atom)
		var/area/A = get_area(scp_atom)
		breach_zone = get_containment_zone(A) || "unknown"

	log_game("SCP Breach: [scp_id] at [scp_atom ? get_area_name(scp_atom) : "unknown"]")

	if(SSfacility_announcements)
		SSfacility_announcements.announce_breach(scp_id, breach_zone)

	if(breach_zone == "lcz" || breach_zone == "hcz")
		set_zone_emergency_lighting(breach_zone, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/set_zone_emergency_lighting, breach_zone, FALSE), 5 MINUTES)

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
		if(instance)
			instance.containment_status = "breached"
			instance.containment_health = 0
			instance.last_breach = world.time
			instance.add_breach_record()

		SSscp_persistence.manager.active_breaches++
		SSscp_persistence.manager.global_containment_stability = max(0, SSscp_persistence.manager.global_containment_stability - 10)

	var/is_keter = FALSE
	if(SSscp_persistence?.manager?.scp_instances?[scp_id])
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
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

	if(GLOB.scp_role_controller)
		var/scp_type = get_scp_type_from_id(scp_id)
		if(scp_type)
			addtimer(CALLBACK(GLOB.scp_role_controller, TYPE_PROC_REF(/datum/scp_role_controller, offer_all_available_scp_roles)), 30 SECONDS)

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

	log_game("SCP Recontained: [scp_id]")

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
		if(instance)
			instance.containment_status = "contained"
			instance.containment_health = 100
			instance.add_interaction_record(null, "recontained")

		SSscp_persistence.manager.active_breaches = max(0, SSscp_persistence.manager.active_breaches - 1)
		SSscp_persistence.manager.global_containment_stability = min(100, SSscp_persistence.manager.global_containment_stability + 5)

	if(SScontainment_evaluation)
		complete_containment_evaluation(scp_id, participants)

	report_recontainment_to_round_log(scp_id, participants)

	if(SSpersistent_progression)
		if(participants)
			for(var/mob/living/carbon/human/H in participants)
				if(H.ckey)
					SSpersistent_progression.award_experience(H.ckey, "scp_containment_assist", 0, "SCP-[scp_id] Recontainment")
					var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(H.ckey)
					if(pdata)
						pdata.total_containment_breaches++
						if(pdata.current_job)
							pdata.respond_to_containment_breach(pdata.current_job, scp_id, "recontainment", "successful")

		if(SSpersistent_progression.analytics_manager)
			SSpersistent_progression.analytics_manager.track_event(null, "scp_recontainment", list("scp_id" = scp_id, "participants" = length(participants || list())))

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
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
		if(instance)
			instance.add_interaction_record(victim, "player_death")
	if(SScontainment_evaluation)
		report_containment_casualty(scp_id, 1)
	if(victim.ckey && SSpersistent_progression)
		var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(victim.ckey)
		if(pdata)
			pdata.total_deaths++

/proc/hook_scp_damage(scp_id, damage_percent)
	if(!scp_id)
		return
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
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
