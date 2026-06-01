#ifndef TENSION_HIGH
#define TENSION_HIGH 75
#endif

SUBSYSTEM_DEF(scp_chain_breach)
	name = "SCP Chain Breach"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_ROLEPLAY
	init_order = INIT_ORDER_DEFAULT
	var/list/chain_breaches = list()
	var/check_counter = 0

/datum/controller/subsystem/scp_chain_breach/Initialize()
	initialize_chain_breaches()
	return ..()

/datum/controller/subsystem/scp_chain_breach/fire()
	check_counter++
	for(var/datum/scp_chain_breach/CB in chain_breaches)
		if(CB.check_trigger())
			CB.trigger_breach()
	if(check_counter >= 3)
		check_counter = 0
		for(var/datum/scp_chain_breach/CB in chain_breaches)
			if(CB.triggered && !CB.effects_applied)
				CB.apply_delayed_effects()

/datum/scp_chain_breach
	var/breach_id
	var/list/trigger_conditions = list()
	var/list/breach_effects = list()
	var/triggered = FALSE
	var/effects_applied = FALSE
	var/trigger_time = 0
	var/description = ""

/datum/scp_chain_breach/proc/check_trigger()
	if(triggered)
		return FALSE
	for(var/condition in trigger_conditions)
		if(!evaluate_condition(condition))
			return FALSE
	return TRUE

/datum/scp_chain_breach/proc/evaluate_condition(condition)
	switch(condition)
		if("multi_breach")
			var/breached_count = 0
			if(SSscp_persistence?.manager?.scp_instances)
				for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
					var/datum/scp_instance/SI = SSscp_persistence?.manager?.scp_instances[scp_id]
					if(SI && SI.containment_status == "breached")
						breached_count++
			return breached_count >= 2
		if("power_failure")
			var/failed_count = 0
			for(var/obj/machinery/power/apc/APC as anything in INSTANCES_OF(/obj/machinery/power/apc))
				if(QDELETED(APC))
					continue
				if(istype(get_area(APC), /area/scp) && (APC.machine_stat & NOPOWER))
					failed_count++
			return failed_count >= 3
		if("containment_critical")
			var/critical_count = 0
			if(SSscp_persistence?.manager?.scp_instances)
				for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
					var/datum/scp_instance/SI = SSscp_persistence?.manager?.scp_instances[scp_id]
					if(SI && SI.containment_status == "breached")
						critical_count++
			return critical_count >= 1
		if("dclass_riot_active")
			if(SSdclass_riot && SSdclass_riot.current_riot && SSdclass_riot.current_riot.riot_active)
				return SSdclass_riot.current_riot.stage >= 3
			return FALSE
		if("high_tension")
			if(SSfoundation_politics && SSfoundation_politics.manager)
				return SSfoundation_politics.manager.political_tensions >= TENSION_HIGH
			return FALSE
		if("bsl4_pathogen")
			if(SSfoundation_pathogens)
				var/list/infections = SSfoundation_pathogens.get_infections_by_bsl(BSL_4)
				return length(infections) >= 1
			return FALSE
	return FALSE

/datum/scp_chain_breach/proc/trigger_breach()
	if(triggered)
		return
	triggered = TRUE
	trigger_time = world.time
	for(var/effect in breach_effects)
		apply_effect(effect)
	hook_storytelling_cascade(breach_id)
	if(SSfoundation_politics?.manager)
		SSfoundation_politics.manager.create_political_event("conflict", "Chain Breach: [breach_id]", description, list("security", "engineering"), 20)

/datum/scp_chain_breach/proc/apply_delayed_effects()
	return

/datum/scp_chain_breach/proc/apply_effect(effect)
	switch(effect)
		if("cascade_containment_failure")
			if(SSscp_persistence?.manager?.scp_instances)
				for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
					var/datum/scp_instance/SI = SSscp_persistence?.manager?.scp_instances[scp_id]
					if(SI && SI.containment_health > 0)
						SI.containment_health = max(0, SI.containment_health - 15)
			priority_announce("CASCADE CONTAINMENT FAILURE DETECTED. ALL SCP CONTAINMENT SYSTEMS COMPROMISED.", "CRITICAL ALERT", null, 'sound/misc/notice1.ogg')
		if("facility_lockdown")
			trigger_facility_lockdown("Chain Breach Protocol")
		if("power_diversion")
			var/list/diverted_apcs = list()
			for(var/obj/machinery/power/apc/APC as anything in INSTANCES_OF(/obj/machinery/power/apc))
				if(QDELETED(APC))
					continue
				if(istype(get_area(APC), /area/scp/lcz))
					APC.charging = APC_NOT_CHARGING
					diverted_apcs += APC
				else if(istype(get_area(APC), /area/scp/hcz))
					APC.charging = APC_CHARGING
					diverted_apcs += APC
			if(length(diverted_apcs))
				addtimer(CALLBACK(GLOBAL_PROC, /proc/reset_power_diversion, diverted_apcs), 5 MINUTES)
			priority_announce("POWER DIVERSION TO HEAVY CONTAINMENT. LIGHT CONTAINMENT POWER REDUCED.", "POWER ALERT", null, 'sound/misc/notice1.ogg')
		if("security_recall")
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(QDELETED(H))
					continue
				if(H.stat == DEAD || !H.client)
					continue
				if(!H.job)
					continue
				if(H.job == JOB_LCZ_GUARD || H.job == JOB_HCZ_GUARD || H.job == JOB_EZ_GUARD || H.job == JOB_GUARD_COMMANDER || H.job == JOB_LCZ_ZONE_JUNIOR_LIEUTENANT || H.job == JOB_HCZ_ZONE_SENIOR_LIEUTENANT || H.job == JOB_EZ_ZONE_SUPERVISOR)
					to_chat(H, span_warning("Chain breach protocol activated. All security personnel report to containment zones immediately."))
		if("scp_079_awakening")
			for(var/mob/living/scp079/S in GLOB.mob_list)
				if(QDELETED(S))
					continue
				S.advance_tier()
		if("scp_106_empowerment")
			for(var/mob/living/scp/scp106/S in GLOB.mob_list)
				if(QDELETED(S))
					continue
				if(SSscp_persistence?.manager?.scp_instances?["SCP-106"])
					var/datum/scp_instance/SI = SSscp_persistence?.manager?.scp_instances["SCP-106"]
					SI.containment_health = max(0, SI.containment_health - 25)
		if("tension_spike")
			if(SSfoundation_politics?.manager)
				SSfoundation_politics.manager.political_tensions = min(100, SSfoundation_politics.manager.political_tensions + 25)
		if("research_data_loss")
			if(SSscp_research?.manager)
				adjust_global_research_points(-500, "chain_breach_data_loss")
		if("contagion_acceleration")
			if(GLOB.contagion_tracker)
				for(var/list/contagion in GLOB.contagion_tracker.active_contagions)
					contagion["spread_count"] += 3
		if("security_level_escalation")
			if(SSsecurity_level && SSsecurity_level.current_level < SEC_LEVEL_RED)
				set_foundation_security_code(SEC_LEVEL_RED, "Chain breach escalation")

/proc/reset_power_diversion(list/diverted_apcs)
	for(var/obj/machinery/power/apc/APC in diverted_apcs)
		if(!QDELETED(APC))
			APC.charging = APC_CHARGING
			APC.update_appearance()

/proc/hook_storytelling_cascade(breach_id)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/list/cascades = SSstorytelling.manager.find_arc_by_type("cascade")
	if(!length(cascades))
		SSstorytelling.manager.create_arc("cascade", breach_id)
	SSstorytelling.manager.log_timeline("breach", "Chain breach triggered: [breach_id]", null)

/proc/initialize_chain_breaches()
	var/datum/controller/subsystem/scp_chain_breach/SS = SSscp_chain_breach
	if(!SS)
		return
	SS.chain_breaches = list()

	var/datum/scp_chain_breach/cascade = new()
	cascade.breach_id = "cascade_failure"
	cascade.trigger_conditions = list("multi_breach")
	cascade.breach_effects = list("cascade_containment_failure", "facility_lockdown", "tension_spike")
	cascade.description = "Multiple breaches triggered cascade failure."
	SS.chain_breaches += cascade

	var/datum/scp_chain_breach/power_cascade = new()
	power_cascade.breach_id = "power_cascade"
	power_cascade.trigger_conditions = list("power_failure", "containment_critical")
	power_cascade.breach_effects = list("cascade_containment_failure", "power_diversion", "research_data_loss")
	power_cascade.description = "Power failure compromised containment integrity."
	SS.chain_breaches += power_cascade

	var/datum/scp_chain_breach/riot_cascade = new()
	riot_cascade.breach_id = "riot_cascade"
	riot_cascade.trigger_conditions = list("dclass_riot_active", "containment_critical")
	riot_cascade.breach_effects = list("security_recall", "facility_lockdown", "security_level_escalation")
	riot_cascade.description = "D-Class riot threatens containment security."
	SS.chain_breaches += riot_cascade

	var/datum/scp_chain_breach/scp079_empower = new()
	scp079_empower.breach_id = "079_empowerment"
	scp079_empower.trigger_conditions = list("power_failure")
	scp079_empower.breach_effects = list("scp_079_awakening")
	scp079_empower.description = "Power failure allowed SCP-079 to expand its influence."
	SS.chain_breaches += scp079_empower

	var/datum/scp_chain_breach/scp106_empower = new()
	scp106_empower.breach_id = "106_empowerment"
	scp106_empower.trigger_conditions = list("multi_breach")
	scp106_empower.breach_effects = list("scp_106_empowerment", "tension_spike")
	scp106_empower.description = "Multiple breaches weakened SCP-106 containment."
	SS.chain_breaches += scp106_empower

	var/datum/scp_chain_breach/outbreak_cascade = new()
	outbreak_cascade.breach_id = "outbreak_cascade"
	outbreak_cascade.trigger_conditions = list("bsl4_pathogen", "containment_critical")
	outbreak_cascade.breach_effects = list("facility_lockdown", "contagion_acceleration", "security_level_escalation")
	outbreak_cascade.description = "BSL-4 pathogen combined with containment breach."
	SS.chain_breaches += outbreak_cascade

	var/datum/scp_chain_breach/political_cascade = new()
	political_cascade.breach_id = "political_crisis"
	political_cascade.trigger_conditions = list("high_tension", "containment_critical")
	political_cascade.breach_effects = list("tension_spike", "research_data_loss")
	political_cascade.description = "Political tensions escalated during containment crisis."
	SS.chain_breaches += political_cascade
