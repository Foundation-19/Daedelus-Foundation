#define STORY_ARC_BREACH "breach"
#define STORY_ARC_RIOT "riot"
#define STORY_ARC_CASCADE "cascade"
#define STORY_ARC_CI_RAID "ci_raid"
#define STORY_ARC_OUTBREAK "outbreak"
#define STORY_ARC_CORRUPTION "corruption"
#define STORY_ARC_TAKEOVER "takeover"

#define BREACH_STAGE_DETECTED "detected"
#define BREACH_STAGE_RESPONSE "response_deployed"
#define BREACH_STAGE_ENGAGED "engaged"
#define BREACH_STAGE_RECONTAINED "recontained"
#define BREACH_STAGE_FAILED "failed"

#define RIOT_STAGE_UNREST "unrest"
#define RIOT_STAGE_PROTEST "protest"
#define RIOT_STAGE_RIOT "riot"
#define RIOT_STAGE_SUPPRESSED "suppressed"
#define RIOT_STAGE_ARMED "armed_uprising"

#define CI_STAGE_INSERTION "insertion"
#define CI_STAGE_INFILTRATION "infiltration"
#define CI_STAGE_ASSAULT "assault"
#define CI_STAGE_REPELLED "repelled"
#define CI_STAGE_BREACHED "breached"

#define OUTBREAK_STAGE_DETECTED "detected"
#define OUTBREAK_STAGE_QUARANTINE "quarantine"
#define OUTBREAK_STAGE_CONTAINED "contained"
#define OUTBREAK_STAGE_CRITICAL "critical"

#define CORRUPTION_STAGE_EXPOSED "exposed"
#define CORRUPTION_STAGE_SPREADING "spreading"
#define CORRUPTION_STAGE_RESISTED "resisted"
#define CORRUPTION_STAGE_CONSUMED "consumed"

#define TAKEOVER_STAGE_INTRUSION "intrusion"
#define TAKEOVER_STAGE_EXPANDING "expanding"
#define TAKEOVER_STAGE_CONFRONTED "confronted"
#define TAKEOVER_STAGE_PURGED "purged"
#define TAKEOVER_STAGE_DOMINATED "dominated"

#define ARC_STALE_TIME 18000
#define JOURNAL_MAX_LENGTH 500
#define JOURNAL_COOLDOWN 600

#define TIMELINE_EVENT_BREACH "breach"
#define TIMELINE_EVENT_RECONTAINMENT "recontainment"
#define TIMELINE_EVENT_COMBAT "combat"
#define TIMELINE_EVENT_RESEARCH "research"
#define TIMELINE_EVENT_RIOT "riot"
#define TIMELINE_EVENT_CI_RAID "ci_raid"
#define TIMELINE_EVENT_OUTBREAK "outbreak"
#define TIMELINE_EVENT_DEATH "death"
#define TIMELINE_EVENT_LOCKDOWN "lockdown"
#define TIMELINE_EVENT_CORRUPTION "corruption"
#define TIMELINE_EVENT_TAKEOVER "takeover"

SUBSYSTEM_DEF(storytelling)
	name = "Storytelling"
	wait = 600
	priority = FIRE_PRIORITY_ROLEPLAY
	init_order = INIT_ORDER_ROLEPLAY
	var/datum/storytelling_manager/manager

/datum/controller/subsystem/storytelling/Initialize()
	manager = new /datum/storytelling_manager()
	return ..()

/datum/controller/subsystem/storytelling/fire()
	if(manager)
		manager.process_arcs()

/datum/storytelling_manager
	var/list/active_arcs = list()
	var/list/completed_arcs = list()
	var/list/timeline = list()
	var/list/journal_entries = list()
	var/list/journal_cooldowns = list()
	var/total_arcs_created = 0
	var/stale_check_counter = 0

/datum/storytelling_manager/proc/process_arcs()
	stale_check_counter++
	var/list/to_finalize = list()
	for(var/arc_id in active_arcs)
		var/datum/story_arc/arc = active_arcs[arc_id]
		if(QDELETED(arc))
			to_finalize += arc_id
			continue
		arc.check_stage()
		if(stale_check_counter >= 5)
			if(arc.is_stale())
				arc.complete("stale")
				to_finalize += arc_id
	if(stale_check_counter >= 5)
		stale_check_counter = 0
	for(var/arc_id in to_finalize)
		finalize_arc(arc_id, "stale")

/datum/storytelling_manager/proc/create_arc(arc_type, scp_id)
	var/arc_id = "[arc_type]_[world.time]_[rand(1000,9999)]"
	var/datum/story_arc/arc = new(arc_id, arc_type, scp_id)
	if(!arc)
		return null
	active_arcs[arc_id] = arc
	total_arcs_created++
	log_storytelling("Arc created: [arc.arc_title] ([arc_type])")
	var/timeline_type = arc_type == STORY_ARC_CORRUPTION ? TIMELINE_EVENT_CORRUPTION : arc_type == STORY_ARC_TAKEOVER ? TIMELINE_EVENT_TAKEOVER : TIMELINE_EVENT_BREACH
	log_timeline(timeline_type, arc.arc_title, null)
	announce_arc_creation(arc)
	return arc

/datum/storytelling_manager/proc/announce_arc_creation(datum/story_arc/arc)
	if(!arc)
		return
	switch(arc.arc_type)
		if(STORY_ARC_BREACH, STORY_ARC_CASCADE)
			priority_announce("NARRATIVE TRACKER: Containment breach arc initiated for [arc.scp_id]. All relevant personnel take note.", null, null, ANNOUNCER_ALERT)
		if(STORY_ARC_RIOT)
			priority_announce("NARRATIVE TRACKER: D-Class unrest arc initiated. Security personnel be advised.", null, null, ANNOUNCER_ALERT)
		if(STORY_ARC_CI_RAID)
			priority_announce("NARRATIVE TRACKER: Hostile incursion arc initiated. All hands to battle stations.", null, null, ANNOUNCER_ALERT)
		if(STORY_ARC_OUTBREAK)
			priority_announce("NARRATIVE TRACKER: Pathogen outbreak arc initiated. Medical personnel respond.", null, null, ANNOUNCER_ALERT)
		if(STORY_ARC_CORRUPTION)
			priority_announce("NARRATIVE TRACKER: Anomalous corruption detected. Research and security personnel investigate.", null, null, ANNOUNCER_ALERT)
		if(STORY_ARC_TAKEOVER)
			priority_announce("NARRATIVE TRACKER: AI system anomaly detected. Engineering and command personnel respond.", null, null, ANNOUNCER_ALERT)

/datum/storytelling_manager/proc/find_arc_by_scp(scp_id, arc_type)
	for(var/arc_id in active_arcs)
		var/datum/story_arc/arc = active_arcs[arc_id]
		if(!QDELETED(arc) && arc.scp_id == scp_id && (arc_type == null || arc.arc_type == arc_type))
			return arc
	return null

/datum/storytelling_manager/proc/find_arc_by_type(arc_type)
	var/list/results = list()
	for(var/arc_id in active_arcs)
		var/datum/story_arc/arc = active_arcs[arc_id]
		if(!QDELETED(arc) && arc.arc_type == arc_type)
			results += arc
	return results

/datum/storytelling_manager/proc/complete_arc(arc_id, outcome)
	var/datum/story_arc/arc = active_arcs[arc_id]
	if(!arc)
		return FALSE
	arc.complete(outcome)
	return TRUE

/datum/storytelling_manager/proc/finalize_arc(arc_id, outcome)
	var/datum/story_arc/arc = active_arcs[arc_id]
	if(!arc)
		return
	completed_arcs[arc_id] = arc
	active_arcs -= arc_id

/datum/storytelling_manager/proc/log_timeline(event_type, event_text, ckey)
	var/entry = list(
		"time" = world.time,
		"time_string" = time2text(world.time, "hh:mm:ss"),
		"type" = event_type,
		"text" = event_text,
		"ckey" = ckey
	)
	timeline += list(entry)
	if(GLOB.scp_round_report)
		GLOB.scp_round_report.log_story_event(event_type, event_text, ckey, world.time)

/datum/storytelling_manager/proc/write_journal(mob/living/carbon/human/author, entry_text)
	if(!author || !author.ckey)
		return FALSE
	if(!entry_text || length(entry_text) > JOURNAL_MAX_LENGTH)
		return FALSE
	var/last_time = journal_cooldowns[author.ckey] || 0
	if(world.time - last_time < JOURNAL_COOLDOWN)
		return FALSE
	journal_cooldowns[author.ckey] = world.time
	var/entry = list(
		"time" = world.time,
		"time_string" = time2text(world.time, "hh:mm:ss"),
		"ckey" = author.ckey,
		"name" = author.name,
		"job" = author.job || "Unknown",
		"text" = entry_text
	)
	journal_entries += list(entry)
	log_storytelling("Journal entry by [author.ckey]")
	return TRUE

/datum/storytelling_manager/proc/get_journal_for(ckey)
	var/list/result = list()
	for(var/list/entry in journal_entries)
		if(entry["ckey"] == ckey)
			result += list(entry)
	return result

/datum/storytelling_manager/proc/get_round_summary()
	var/list/summary = list()
	summary["round_duration"] = SSticker.round_start_time ? world.time - SSticker.round_start_time : 0
	summary["total_arcs"] = total_arcs_created
	summary["active_arcs"] = length(active_arcs)
	summary["completed_arcs"] = length(completed_arcs)
	summary["timeline_entries"] = length(timeline)
	summary["journal_entries"] = length(journal_entries)
	var/list/arc_summaries = list()
	for(var/arc_id in completed_arcs)
		var/datum/story_arc/arc = completed_arcs[arc_id]
		if(arc)
			arc_summaries += list(list(
				"title" = arc.arc_title,
				"type" = arc.arc_type,
				"outcome" = arc.outcome,
				"duration" = arc.completion_time ? arc.completion_time - arc.creation_time : 0
			))
	for(var/arc_id in active_arcs)
		var/datum/story_arc/arc = active_arcs[arc_id]
		if(arc)
			arc_summaries += list(list(
				"title" = arc.arc_title,
				"type" = arc.arc_type,
				"stage" = arc.stage,
				"outcome" = "ongoing",
				"duration" = world.time - arc.creation_time
			))
	summary["arcs"] = arc_summaries
	return summary

/proc/log_storytelling(message)
	world.log << "Storytelling: [message]"

/datum/story_arc
	var/arc_id = ""
	var/arc_type = ""
	var/arc_title = ""
	var/scp_id = ""
	var/stage = ""
	var/outcome = ""
	var/creation_time = 0
	var/completion_time = 0
	var/list/participants = list()
	var/list/stages = list()
	var/xp_reward = 0
	var/last_stage_check = 0
	var/last_progress_time = 0

/datum/story_arc/New(arc_id, arc_type, scp_id)
	src.arc_id = arc_id
	src.arc_type = arc_type
	src.scp_id = scp_id
	src.creation_time = world.time
	src.last_stage_check = world.time
	src.last_progress_time = world.time
	setup_arc()

/datum/story_arc/proc/setup_arc()
	switch(arc_type)
		if(STORY_ARC_BREACH)
			arc_title = "Containment Breach: [scp_id]"
			stages = list(BREACH_STAGE_DETECTED, BREACH_STAGE_RESPONSE, BREACH_STAGE_ENGAGED, BREACH_STAGE_RECONTAINED)
			stage = BREACH_STAGE_DETECTED
			xp_reward = 75
		if(STORY_ARC_RIOT)
			arc_title = "D-Class Uprising"
			stages = list(RIOT_STAGE_UNREST, RIOT_STAGE_PROTEST, RIOT_STAGE_RIOT, RIOT_STAGE_SUPPRESSED)
			stage = RIOT_STAGE_UNREST
			xp_reward = 50
		if(STORY_ARC_CASCADE)
			arc_title = "Cascade Failure"
			stages = list(BREACH_STAGE_DETECTED, BREACH_STAGE_RESPONSE, BREACH_STAGE_FAILED)
			stage = BREACH_STAGE_DETECTED
			xp_reward = 150
		if(STORY_ARC_CI_RAID)
			arc_title = "Chaos Insurgency Incursion"
			stages = list(CI_STAGE_INSERTION, CI_STAGE_INFILTRATION, CI_STAGE_ASSAULT, CI_STAGE_REPELLED)
			stage = CI_STAGE_INSERTION
			xp_reward = 100
		if(STORY_ARC_OUTBREAK)
			arc_title = "Outbreak Protocol"
			stages = list(OUTBREAK_STAGE_DETECTED, OUTBREAK_STAGE_QUARANTINE, OUTBREAK_STAGE_CONTAINED)
			stage = OUTBREAK_STAGE_DETECTED
			xp_reward = 60
		if(STORY_ARC_CORRUPTION)
			arc_title = "Anomalous Corruption: [scp_id]"
			stages = list(CORRUPTION_STAGE_EXPOSED, CORRUPTION_STAGE_SPREADING, CORRUPTION_STAGE_RESISTED)
			stage = CORRUPTION_STAGE_EXPOSED
			xp_reward = 80
		if(STORY_ARC_TAKEOVER)
			arc_title = "AI Takeover: [scp_id]"
			stages = list(TAKEOVER_STAGE_INTRUSION, TAKEOVER_STAGE_EXPANDING, TAKEOVER_STAGE_CONFRONTED, TAKEOVER_STAGE_PURGED)
			stage = TAKEOVER_STAGE_INTRUSION
			xp_reward = 120

/datum/story_arc/proc/check_stage()
	if(world.time - last_stage_check < 100)
		return
	last_stage_check = world.time
	switch(arc_type)
		if(STORY_ARC_BREACH, STORY_ARC_CASCADE)
			check_breach_stage()
		if(STORY_ARC_RIOT)
			check_riot_stage()
		if(STORY_ARC_CI_RAID)
			check_ci_stage()
		if(STORY_ARC_OUTBREAK)
			check_outbreak_stage()
		if(STORY_ARC_CORRUPTION)
			check_corruption_stage()
		if(STORY_ARC_TAKEOVER)
			check_takeover_stage()

/datum/story_arc/proc/is_stale()
	if(world.time - last_progress_time > ARC_STALE_TIME)
		return TRUE
	return FALSE

/datum/story_arc/proc/check_breach_stage()
	switch(stage)
		if(BREACH_STAGE_DETECTED)
			if(check_security_responded())
				advance_stage(BREACH_STAGE_RESPONSE)
		if(BREACH_STAGE_RESPONSE)
			if(check_combat_engaged())
				advance_stage(BREACH_STAGE_ENGAGED)
		if(BREACH_STAGE_ENGAGED)
			if(check_scp_contained(scp_id))
				complete(BREACH_STAGE_RECONTAINED)
			else if(check_response_wiped())
				complete(BREACH_STAGE_FAILED)

/datum/story_arc/proc/check_security_responded()
	if(!SSscp_persistence?.manager?.scp_instances?[scp_id])
		return FALSE
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
	if(!instance || instance.containment_status != "breached")
		return FALSE
	var/mob/living/scp/found_scp
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(QDELETED(S))
			continue
		if(S.persistence_id == scp_id)
			found_scp = S
			break
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD)
			continue
		if(!H.job)
			continue
		if(H.job == "MTF Commander" || H.job == "MTF Operative" || H.job == "MTF Medic" || H.job == "MTF Heavy")
			var/turf/scp_turf = found_scp ? get_turf(found_scp) : null
			if(!found_scp || (scp_turf && get_dist(get_turf(H), scp_turf) < 30))
				return TRUE
		if(H.job == JOB_LCZ_GUARD || H.job == JOB_HCZ_GUARD || H.job == JOB_EZ_GUARD || H.job == JOB_LCZ_ZONE_JUNIOR_LIEUTENANT || H.job == JOB_HCZ_ZONE_SENIOR_LIEUTENANT || H.job == JOB_EZ_ZONE_SUPERVISOR || H.job == JOB_GUARD_COMMANDER)
			var/turf/scp_turf2 = found_scp ? get_turf(found_scp) : null
			if(!found_scp || (scp_turf2 && get_dist(get_turf(H), scp_turf2) < 30))
				return TRUE
	return FALSE

/datum/story_arc/proc/check_combat_engaged()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD)
			continue
		if(!H.job)
			continue
		if(H.job == "MTF Commander" || H.job == "MTF Operative" || H.job == JOB_LCZ_GUARD || H.job == JOB_HCZ_GUARD || H.job == JOB_EZ_GUARD)
			if(H.combat_mode)
				return TRUE
	return FALSE

/datum/story_arc/proc/check_response_wiped()
	var/response_alive = 0
	var/response_total = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(!H.job)
			continue
		if(H.job == "MTF Commander" || H.job == "MTF Operative" || H.job == "MTF Medic" || H.job == "MTF Heavy")
			response_total++
			if(H.stat != DEAD)
				response_alive++
	if(response_total > 0 && response_alive == 0)
		return TRUE
	return FALSE

/datum/story_arc/proc/check_scp_contained(scp_check_id)
	if(!scp_check_id)
		return FALSE
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_check_id]
		if(instance && instance.containment_status == "contained")
			return TRUE
	return FALSE

/datum/story_arc/proc/check_riot_stage()
	if(!SSdclass_riot)
		if(stage == RIOT_STAGE_RIOT || stage == RIOT_STAGE_PROTEST)
			complete(RIOT_STAGE_SUPPRESSED)
		return
	if(!SSdclass_riot.current_riot || !SSdclass_riot.current_riot.riot_active)
		if(stage == RIOT_STAGE_RIOT || stage == RIOT_STAGE_PROTEST)
			complete(RIOT_STAGE_SUPPRESSED)
		return
	var/datum/dclass_riot/riot = SSdclass_riot.current_riot
	switch(stage)
		if(RIOT_STAGE_UNREST)
			if(riot.stage >= 2)
				advance_stage(RIOT_STAGE_PROTEST)
		if(RIOT_STAGE_PROTEST)
			if(riot.stage >= 3)
				advance_stage(RIOT_STAGE_RIOT)
		if(RIOT_STAGE_RIOT)
			if(riot.stage >= 4)
				advance_stage(RIOT_STAGE_ARMED)
			if(riot.riot_active && riot.suppression_progress >= 100)
				complete(RIOT_STAGE_SUPPRESSED)
		if(RIOT_STAGE_ARMED)
			if(!riot.riot_active)
				complete(RIOT_STAGE_SUPPRESSED)

/datum/story_arc/proc/check_ci_stage()
	var/list/ci_operatives = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD)
			continue
		if(H.mind?.has_antag_datum(/datum/antagonist/chaos_insurgency))
			ci_operatives += H
	var/alive_ci = length(ci_operatives)
	switch(stage)
		if(CI_STAGE_INSERTION)
			if(alive_ci > 0)
				advance_stage(CI_STAGE_INFILTRATION)
		if(CI_STAGE_INFILTRATION)
			if(alive_ci == 0)
				complete(CI_STAGE_REPELLED)
			else if(check_ci_near_containment(ci_operatives))
				advance_stage(CI_STAGE_ASSAULT)
		if(CI_STAGE_ASSAULT)
			if(alive_ci == 0)
				complete(CI_STAGE_REPELLED)
			else if(check_ci_breached_containment(ci_operatives))
				complete(CI_STAGE_BREACHED)

/datum/story_arc/proc/check_outbreak_stage()
	switch(stage)
		if(OUTBREAK_STAGE_DETECTED)
			if(check_quarantine_active())
				advance_stage(OUTBREAK_STAGE_QUARANTINE)
		if(OUTBREAK_STAGE_QUARANTINE)
			if(check_outbreak_resolved())
				complete(OUTBREAK_STAGE_CONTAINED)
			else if(check_outbreak_critical())
				advance_stage(OUTBREAK_STAGE_CRITICAL)
		if(OUTBREAK_STAGE_CRITICAL)
			if(check_outbreak_resolved())
				complete(OUTBREAK_STAGE_CONTAINED)

/datum/story_arc/proc/check_corruption_stage()
	switch(stage)
		if(CORRUPTION_STAGE_EXPOSED)
			if(check_corruption_spreading())
				advance_stage(CORRUPTION_STAGE_SPREADING)
		if(CORRUPTION_STAGE_SPREADING)
			if(check_corruption_resisted())
				complete(CORRUPTION_STAGE_RESISTED)
			else if(check_corruption_consumed())
				complete(CORRUPTION_STAGE_CONSUMED)

/datum/story_arc/proc/check_takeover_stage()
	switch(stage)
		if(TAKEOVER_STAGE_INTRUSION)
			if(check_takeover_expanding())
				advance_stage(TAKEOVER_STAGE_EXPANDING)
		if(TAKEOVER_STAGE_EXPANDING)
			if(check_takeover_confronted())
				advance_stage(TAKEOVER_STAGE_CONFRONTED)
		if(TAKEOVER_STAGE_CONFRONTED)
			if(check_takeover_purged())
				complete(TAKEOVER_STAGE_PURGED)
			else if(check_takeover_dominated())
				complete(TAKEOVER_STAGE_DOMINATED)

/datum/story_arc/proc/check_corruption_spreading()
	if(scp_id && SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
		if(instance && instance.containment_status == "breached")
			var/affected = 0
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(QDELETED(H))
					continue
				if(H.stat == DEAD)
					continue
				if(H.mind && (HAS_TRAIT(H, TRAIT_POSSESSION_IMMUNE) || HAS_TRAIT(H, TRAIT_CORRUPTION_RESISTANT)))
					continue
				var/area/A = get_area(H)
				if(A && istype(A, /area/scp/))
					affected++
			return affected >= 3
	return FALSE

/datum/story_arc/proc/check_corruption_resisted()
	if(scp_id)
		return check_scp_contained(scp_id)
	return FALSE

/datum/story_arc/proc/check_corruption_consumed()
	if(scp_id && SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
		if(instance && instance.containment_status == "breached")
			var/affected = 0
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(QDELETED(H))
					continue
				if(H.stat == DEAD)
					continue
				var/area/A = get_area(H)
				if(A && istype(A, /area/scp/))
					affected++
			return affected >= 8
	return FALSE

/datum/story_arc/proc/check_takeover_expanding()
	var/apc_count = 0
	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		if(QDELETED(A))
			continue
		if(A.machine_stat & NOPOWER)
			apc_count++
	return apc_count >= 5

/datum/story_arc/proc/check_takeover_confronted()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD)
			continue
		if(H.job == JOB_ENGINEERING_DIRECTOR || H.job == JOB_CONTAINMENT_ENGINEER || H.job == JOB_IT_TECHNICIAN)
			var/area/A = get_area(H)
			if(A && (istype(A, /area/scp/hcz) || istype(A, /area/scp/lcz)))
				return TRUE
	return FALSE

/datum/story_arc/proc/check_takeover_purged()
	if(scp_id)
		return check_scp_contained(scp_id)
	return FALSE

/datum/story_arc/proc/check_takeover_dominated()
	var/apc_count = 0
	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		if(QDELETED(A))
			continue
		if(A.machine_stat & NOPOWER)
			apc_count++
	return apc_count >= 15

/datum/story_arc/proc/advance_stage(new_stage)
	if(stage == new_stage)
		return
	stage = new_stage
	last_progress_time = world.time
	if(SSstorytelling && SSstorytelling.manager)
		var/event_type = TIMELINE_EVENT_BREACH
		switch(arc_type)
			if(STORY_ARC_RIOT)
				event_type = TIMELINE_EVENT_RIOT
			if(STORY_ARC_CI_RAID)
				event_type = TIMELINE_EVENT_CI_RAID
			if(STORY_ARC_OUTBREAK)
				event_type = TIMELINE_EVENT_OUTBREAK
			if(STORY_ARC_CORRUPTION)
				event_type = TIMELINE_EVENT_CORRUPTION
			if(STORY_ARC_TAKEOVER)
				event_type = TIMELINE_EVENT_TAKEOVER
		SSstorytelling.manager.log_timeline(event_type, "[arc_title] - Stage: [new_stage]", null)
	log_storytelling("Arc [arc_title] advanced to [new_stage]")

/datum/story_arc/proc/complete(outcome)
	src.outcome = outcome
	src.completion_time = world.time
	award_completion_xp()
	if(SSstorytelling && SSstorytelling.manager)
		var/event_type = TIMELINE_EVENT_BREACH
		switch(arc_type)
			if(STORY_ARC_RIOT)
				event_type = TIMELINE_EVENT_RIOT
			if(STORY_ARC_CI_RAID)
				event_type = TIMELINE_EVENT_CI_RAID
			if(STORY_ARC_OUTBREAK)
				event_type = TIMELINE_EVENT_OUTBREAK
			if(STORY_ARC_CORRUPTION)
				event_type = TIMELINE_EVENT_CORRUPTION
			if(STORY_ARC_TAKEOVER)
				event_type = TIMELINE_EVENT_TAKEOVER
		SSstorytelling.manager.log_timeline(event_type, "[arc_title] - Completed: [outcome]", null)
		SSstorytelling.manager.finalize_arc(arc_id, outcome)
	hook_politics_on_arc_complete(arc_type, outcome)
	log_storytelling("Arc [arc_title] completed: [outcome]")

/datum/story_arc/proc/hook_politics_on_arc_complete(arc_type, outcome)
	if(!SSfoundation_politics?.manager)
		return
	var/failed = (outcome == BREACH_STAGE_FAILED || outcome == CI_STAGE_BREACHED || outcome == OUTBREAK_STAGE_CRITICAL || outcome == CORRUPTION_STAGE_CONSUMED || outcome == TAKEOVER_STAGE_DOMINATED)
	if(failed)
		SSfoundation_politics.manager.political_tensions = min(100, SSfoundation_politics.manager.political_tensions + 20)
		SSfoundation_politics.manager.spend_budget("security", 10000, "Arc Failed: [arc_title]")
		SSfoundation_politics.manager.spend_budget("administrative", 5000, "Arc Failed: [arc_title]")
	else
		SSfoundation_politics.manager.political_tensions = max(0, SSfoundation_politics.manager.political_tensions - 10)
		var/datum/department/sec = SSfoundation_politics.manager.departments["security"]
		if(sec)
			sec.department_influence = min(100, sec.department_influence + 5)

/datum/story_arc/proc/award_completion_xp()
	var/xp_amount = xp_reward
	if(outcome == BREACH_STAGE_FAILED || outcome == CI_STAGE_BREACHED || outcome == OUTBREAK_STAGE_CRITICAL || outcome == CORRUPTION_STAGE_CONSUMED || outcome == TAKEOVER_STAGE_DOMINATED)
		xp_amount = round(xp_reward * 0.3)
	if(!SSpersistent_progression)
		return
	for(var/ckey in participants)
		SSpersistent_progression.award_experience(ckey, "story_arc_completion", xp_amount, "[arc_title]: [outcome]")

/datum/story_arc/proc/add_participant(ckey)
	if(!ckey || (ckey in participants))
		return
	participants += ckey

/datum/story_arc/proc/check_ci_near_containment(list/ci_operatives)
	for(var/mob/living/carbon/human/H in ci_operatives)
		if(QDELETED(H))
			continue
		var/area/A = get_area(H)
		if(A && (istype(A, /area/scp/hcz) || istype(A, /area/scp/lcz)))
			return TRUE
	return FALSE

/datum/story_arc/proc/check_ci_breached_containment(list/ci_operatives)
	for(var/mob/living/carbon/human/H in ci_operatives)
		if(QDELETED(H))
			continue
		if(H.mind)
			var/datum/antagonist/chaos_insurgency/ci = H.mind.has_antag_datum(/datum/antagonist/chaos_insurgency)
			if(ci && ci.objectives)
				for(var/datum/objective/O in ci.objectives)
					if(O.check_completion() == TRUE)
						return TRUE
	return FALSE

/datum/story_arc/proc/check_quarantine_active()
	if(!GLOB.contagion_tracker)
		if(SSfoundation_pathogens)
			var/list/active = SSfoundation_pathogens.active_infections
			return length(active) > 0
		return FALSE
	return length(GLOB.contagion_tracker.quarantine_zones) > 0

/datum/story_arc/proc/check_outbreak_resolved()
	if(!GLOB.contagion_tracker && !SSfoundation_pathogens)
		return FALSE
	var/active_infections = 0
	if(GLOB.contagion_tracker)
		active_infections += length(GLOB.contagion_tracker.active_contagions)
	if(SSfoundation_pathogens)
		active_infections += length(SSfoundation_pathogens.active_infections)
	return active_infections == 0

/datum/story_arc/proc/check_outbreak_critical()
	if(SSmedical_persistence && SSmedical_persistence.manager)
		return SSmedical_persistence.manager.active_outbreaks >= 3
	return FALSE

/proc/hook_storytelling_breach(scp_id, atom/scp_atom)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/datum/story_arc/existing = SSstorytelling.manager.find_arc_by_scp(scp_id, STORY_ARC_BREACH)
	if(existing)
		return
	var/breach_count = length(SSstorytelling.manager.find_arc_by_type(STORY_ARC_BREACH)) + length(SSstorytelling.manager.find_arc_by_type(STORY_ARC_CASCADE))
	var/arc_type = breach_count >= 2 ? STORY_ARC_CASCADE : STORY_ARC_BREACH
	var/datum/story_arc/arc = SSstorytelling.manager.create_arc(arc_type, scp_id)
	if(!arc)
		return
	if(scp_atom)
		var/area/A = get_area(scp_atom)
		var/zone = get_containment_zone(A) || "unknown"
		SSstorytelling.manager.log_timeline(TIMELINE_EVENT_BREACH, "Containment breach: [scp_id] in [zone]", null)
	if(arc_type == STORY_ARC_CASCADE)
		SSstorytelling.manager.log_timeline(TIMELINE_EVENT_BREACH, "CASCADE FAILURE: Multiple simultaneous breaches detected!", null)

/proc/hook_storytelling_recontainment(scp_id, list/participants)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/datum/story_arc/arc = SSstorytelling.manager.find_arc_by_scp(scp_id)
	if(!arc)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_RECONTAINMENT, "[scp_id] recontained", null)
	if(participants)
		for(var/mob/living/carbon/human/H in participants)
			if(H && H.ckey)
				arc.add_participant(H.ckey)

/proc/hook_storytelling_combat(mob/living/carbon/human/fighter, scp_id, damage_dealt, damage_taken)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_COMBAT, "Combat with [scp_id] - Dealt: [damage_dealt], Taken: [damage_taken]", fighter?.ckey)
	var/datum/story_arc/arc = SSstorytelling.manager.find_arc_by_scp(scp_id)
	if(arc && fighter && fighter.ckey)
		arc.add_participant(fighter.ckey)

/proc/hook_storytelling_research(researcher_ckey, experiment_name, scp_id, points)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_RESEARCH, "Research: [experiment_name] ([scp_id]) - [points] pts", researcher_ckey)

/proc/hook_storytelling_riot(stage)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/datum/story_arc/arc = null
	var/list/riots = SSstorytelling.manager.find_arc_by_type(STORY_ARC_RIOT)
	if(length(riots))
		arc = riots[1]
	if(!arc)
		arc = SSstorytelling.manager.create_arc(STORY_ARC_RIOT, "D-Class Riot")
	if(!arc)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_RIOT, "D-Class uprising - Stage: [stage]", null)

/proc/hook_storytelling_ci_raid()
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/datum/story_arc/arc = null
	var/list/raids = SSstorytelling.manager.find_arc_by_type(STORY_ARC_CI_RAID)
	if(length(raids))
		arc = raids[1]
	if(!arc)
		arc = SSstorytelling.manager.create_arc(STORY_ARC_CI_RAID, "Chaos Insurgency")
	if(!arc)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_CI_RAID, "Chaos Insurgency incursion detected!", null)

/proc/hook_storytelling_outbreak()
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/datum/story_arc/arc = null
	var/list/outbreaks = SSstorytelling.manager.find_arc_by_type(STORY_ARC_OUTBREAK)
	if(length(outbreaks))
		arc = outbreaks[1]
	if(!arc)
		arc = SSstorytelling.manager.create_arc(STORY_ARC_OUTBREAK, "Outbreak")
	if(!arc)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_OUTBREAK, "Outbreak protocol activated!", null)

/proc/hook_storytelling_corruption(scp_id)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/datum/story_arc/existing = SSstorytelling.manager.find_arc_by_scp(scp_id, STORY_ARC_CORRUPTION)
	if(existing)
		return
	var/datum/story_arc/arc = SSstorytelling.manager.create_arc(STORY_ARC_CORRUPTION, scp_id)
	if(!arc)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_CORRUPTION, "Anomalous corruption spreading from [scp_id]!", null)

/proc/hook_storytelling_takeover(scp_id)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	var/datum/story_arc/existing = SSstorytelling.manager.find_arc_by_scp(scp_id, STORY_ARC_TAKEOVER)
	if(existing)
		return
	var/datum/story_arc/arc = SSstorytelling.manager.create_arc(STORY_ARC_TAKEOVER, scp_id)
	if(!arc)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_TAKEOVER, "AI takeover attempt from [scp_id]!", null)

/proc/hook_storytelling_death(victim_name, cause, zone)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_DEATH, "Casualty: [victim_name] - [cause] in [zone]", null)

/proc/hook_storytelling_lockdown(reason, duration)
	if(!SSstorytelling || !SSstorytelling.manager)
		return
	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_LOCKDOWN, "Lockdown: [reason] ([duration])", null)

/datum/scp_round_report/proc/log_story_event(event_type, event_text, ckey, time)
	if(!story_log)
		story_log = list()
	story_log += list(list("type" = event_type, "text" = event_text, "ckey" = ckey, "time" = time))
