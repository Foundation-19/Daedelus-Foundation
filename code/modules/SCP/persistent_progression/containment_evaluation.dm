#define CONTAINMENT_RATING_S 1
#define CONTAINMENT_RATING_A 2
#define CONTAINMENT_RATING_B 3
#define CONTAINMENT_RATING_C 4
#define CONTAINMENT_RATING_D 5
#define CONTAINMENT_RATING_F 6

#define METRIC_RESPONSE_TIME "response_time"
#define METRIC_PERSONNEL_SAFETY "personnel_safety"
#define METRIC_SCP_CONDITION "scp_condition"
#define METRIC_FACILITY_DAMAGE "facility_damage"
#define METRIC_CONTAINMENT_TIME "containment_time"
#define METRIC_PROTOCOL_ADHERENCE "protocol_adherence"

SUBSYSTEM_DEF(containment_evaluation)
	name = "Containment Evaluation"
	wait = 300
	priority = FIRE_PRIORITY_INPUT
	var/datum/containment_evaluation_manager/manager

/datum/controller/subsystem/containment_evaluation/Initialize()
	manager = new /datum/containment_evaluation_manager()
	world.log << "Containment Evaluation System: Initialized"
	return ..()

/datum/controller/subsystem/containment_evaluation/fire()
	if(manager)
		manager.process_evaluations()

/datum/containment_evaluation_manager
	var/list/active_evaluations = list()
	var/list/completed_evaluations = list()
	var/list/breach_history = list()
	var/list/player_containment_stats = list()
	
	var/global_rating_distribution = list(
		"S" = 0,
		"A" = 0,
		"B" = 0,
		"C" = 0,
		"D" = 0,
		"F" = 0
	)
	
	var/evaluation_xp_multiplier = 1.0

/datum/containment_evaluation_manager/proc/start_evaluation(scp_id, breach_type = "standard")
	var/eval_id = "eval_[scp_id]_[world.time]"
	var/datum/containment_evaluation/eval = new(eval_id, scp_id, breach_type)
	
	active_evaluations[eval_id] = eval
	breach_history += list(list(
		"eval_id" = eval_id,
		"scp_id" = scp_id,
		"start_time" = world.time,
		"type" = breach_type
	))
	
	message_admins("Containment breach detected: [scp_id]. Evaluation started.")
	
	return eval

/datum/containment_evaluation_manager/proc/process_evaluations()
	for(var/eval_id in active_evaluations)
		var/datum/containment_evaluation/eval = active_evaluations[eval_id]
		if(eval)
			eval.process_evaluation()

/datum/containment_evaluation_manager/proc/complete_evaluation(eval_id, list/participants)
	var/datum/containment_evaluation/eval = active_evaluations[eval_id]
	if(!eval)
		return FALSE
	
	eval.end_time = world.time
	eval.status = "completed"
	
	var/rating = calculate_rating(eval)
	eval.rating = rating
	
	for(var/mob/living/carbon/human/H in participants)
		record_player_participation(H, eval, rating)
		award_rating_rewards(H, rating, eval)
	
	global_rating_distribution[get_rating_name(rating)]++
	
	completed_evaluations[eval_id] = eval
	active_evaluations -= eval_id
	
	notify_rating(eval, participants)
	
	return TRUE

/datum/containment_evaluation_manager/proc/calculate_rating(datum/containment_evaluation/eval)
	if(!eval)
		return CONTAINMENT_RATING_F
	
	var/total_score = 0
	var/max_score = 0
	
	for(var/metric_id in eval.metrics)
		var/datum/containment_metric/metric = eval.metrics[metric_id]
		total_score += metric.score * metric.weight
		max_score += 100 * metric.weight
	
	if(max_score == 0)
		return CONTAINMENT_RATING_F
	
	var/percentage = (total_score / max_score) * 100
	
	if(percentage >= 95)
		return CONTAINMENT_RATING_S
	else if(percentage >= 85)
		return CONTAINMENT_RATING_A
	else if(percentage >= 70)
		return CONTAINMENT_RATING_B
	else if(percentage >= 50)
		return CONTAINMENT_RATING_C
	else if(percentage >= 25)
		return CONTAINMENT_RATING_D
	else
		return CONTAINMENT_RATING_F

/datum/containment_evaluation_manager/proc/get_rating_name(rating)
	switch(rating)
		if(CONTAINMENT_RATING_S)
			return "S"
		if(CONTAINMENT_RATING_A)
			return "A"
		if(CONTAINMENT_RATING_B)
			return "B"
		if(CONTAINMENT_RATING_C)
			return "C"
		if(CONTAINMENT_RATING_D)
			return "D"
		if(CONTAINMENT_RATING_F)
			return "F"
	return "F"

/datum/containment_evaluation_manager/proc/record_player_participation(mob/living/carbon/human/player, datum/containment_evaluation/eval, rating)
	if(!player || !player.ckey)
		return
	
	var/ckey = player.ckey
	if(!(ckey in player_containment_stats))
		player_containment_stats[ckey] = new /datum/player_containment_stats(ckey)
	
	var/datum/player_containment_stats/stats = player_containment_stats[ckey]
	stats.total_containments++
	stats.containment_by_scp[eval.scp_id] = (stats.containment_by_scp[eval.scp_id] || 0) + 1
	
	switch(rating)
		if(CONTAINMENT_RATING_S)
			stats.rating_s_count++
		if(CONTAINMENT_RATING_A)
			stats.rating_a_count++
		if(CONTAINMENT_RATING_B)
			stats.rating_b_count++
		if(CONTAINMENT_RATING_C)
			stats.rating_c_count++
		if(CONTAINMENT_RATING_D)
			stats.rating_d_count++
		if(CONTAINMENT_RATING_F)
			stats.rating_f_count++
	
	stats.update_average_rating()

/datum/containment_evaluation_manager/proc/award_rating_rewards(mob/living/carbon/human/player, rating, datum/containment_evaluation/eval)
	if(!player || !player.ckey)
		return
	
	var/xp_base = 0
	var/reward_multiplier = 1.0
	
	switch(rating)
		if(CONTAINMENT_RATING_S)
			xp_base = 150
			reward_multiplier = 1.5
		if(CONTAINMENT_RATING_A)
			xp_base = 100
			reward_multiplier = 1.25
		if(CONTAINMENT_RATING_B)
			xp_base = 50
			reward_multiplier = 1.0
		if(CONTAINMENT_RATING_C)
			xp_base = 25
			reward_multiplier = 0.75
		if(CONTAINMENT_RATING_D)
			xp_base = 0
			reward_multiplier = 0.5
		if(CONTAINMENT_RATING_F)
			xp_base = -50
			reward_multiplier = 0.25
	
	var/final_xp = round(xp_base * reward_multiplier * evaluation_xp_multiplier)
	
	if(SSpersistent_progression)
		SSpersistent_progression.award_experience(player.ckey, "containment_breach_response", final_xp, "containment_rating")

/datum/containment_evaluation_manager/proc/notify_rating(datum/containment_evaluation/eval, list/participants)
	var/rating_name = get_rating_name(eval.rating)
	var/message = "Containment of [eval.scp_id] completed with rating: [rating_name]"
	var/class = "notice"
	
	switch(eval.rating)
		if(CONTAINMENT_RATING_S)
			class = "boldnotice"
			message += " - PERFECT CONTAINMENT!"
		if(CONTAINMENT_RATING_A)
			class = "notice"
			message += " - Excellent work!"
		if(CONTAINMENT_RATING_B)
			class = "notice"
			message += " - Good job!"
		if(CONTAINMENT_RATING_C)
			class = "warning"
			message += " - Room for improvement."
		if(CONTAINMENT_RATING_D)
			class = "warning"
			message += " - Substandard performance."
		if(CONTAINMENT_RATING_F)
			class = "danger"
			message += " - CONTAINMENT FAILURE!"
	
	for(var/mob/living/carbon/human/H in participants)
		to_chat(H, "<span class='[class]'>[message]</span>")

/datum/containment_evaluation_manager/proc/get_player_stats(ckey)
	if(!ckey)
		return null
	if(!(ckey in player_containment_stats))
		player_containment_stats[ckey] = new /datum/player_containment_stats(ckey)
	return player_containment_stats[ckey]

/datum/containment_evaluation_manager/proc/get_evaluation(eval_id)
	return active_evaluations[eval_id] || completed_evaluations[eval_id]

/datum/containment_evaluation_manager/proc/update_metric(eval_id, metric_type, value)
	var/datum/containment_evaluation/eval = active_evaluations[eval_id]
	if(!eval)
		return FALSE
	
	eval.update_metric(metric_type, value)
	return TRUE

/datum/containment_evaluation
	var/eval_id
	var/scp_id
	var/breach_type
	var/start_time
	var/end_time
	var/status = "active"
	var/rating
	
	var/list/datum/containment_metric/metrics = list()
	var/list/participants = list()
	var/list/events = list()
	
	var/response_time_start
	var/response_time_end
	var/first_responder

/datum/containment_evaluation/New(id, scp, breach_t)
	eval_id = id
	scp_id = scp
	breach_type = breach_t
	start_time = world.time
	
	initialize_metrics()

/datum/containment_evaluation/proc/initialize_metrics()
	metrics[METRIC_RESPONSE_TIME] = new /datum/containment_metric(
		METRIC_RESPONSE_TIME,
		"Response Time",
		0.20,
		"Time to respond to breach alert"
	)
	metrics[METRIC_PERSONNEL_SAFETY] = new /datum/containment_metric(
		METRIC_PERSONNEL_SAFETY,
		"Personnel Safety",
		0.25,
		"Casualties during containment"
	)
	metrics[METRIC_SCP_CONDITION] = new /datum/containment_metric(
		METRIC_SCP_CONDITION,
		"SCP Condition",
		0.15,
		"Damage to SCP during containment"
	)
	metrics[METRIC_FACILITY_DAMAGE] = new /datum/containment_metric(
		METRIC_FACILITY_DAMAGE,
		"Facility Damage",
		0.15,
		"Collateral destruction"
	)
	metrics[METRIC_CONTAINMENT_TIME] = new /datum/containment_metric(
		METRIC_CONTAINMENT_TIME,
		"Recontainment Speed",
		0.15,
		"Time to recontain"
	)
	metrics[METRIC_PROTOCOL_ADHERENCE] = new /datum/containment_metric(
		METRIC_PROTOCOL_ADHERENCE,
		"Protocol Adherence",
		0.10,
		"Following correct procedures"
	)
	
	response_time_start = world.time

/datum/containment_evaluation/proc/process_evaluation()
	if(metrics[METRIC_CONTAINMENT_TIME])
		var/elapsed = (world.time - start_time) / 600
		var/remaining = max(0, 100 - (elapsed * 2))
		metrics[METRIC_CONTAINMENT_TIME].score = remaining

/datum/containment_evaluation/proc/update_metric(metric_type, value)
	if(!(metric_type in metrics))
		return
	
	var/datum/containment_metric/metric = metrics[metric_type]
	
	switch(metric_type)
		if(METRIC_RESPONSE_TIME)
			if(!first_responder)
				first_responder = TRUE
				response_time_end = world.time
				var/response_seconds = (response_time_end - response_time_start) / 10
				metric.score = max(0, 100 - (response_seconds * 2))
		
		if(METRIC_PERSONNEL_SAFETY)
			metric.score = max(0, 100 - (value * 20))
		
		if(METRIC_SCP_CONDITION)
			metric.score = max(0, 100 - value)
		
		if(METRIC_FACILITY_DAMAGE)
			metric.score = max(0, 100 - (value * 10))
		
		if(METRIC_PROTOCOL_ADHERENCE)
			metric.score = clamp(value, 0, 100)

/datum/containment_evaluation/proc/add_participant(mob/living/carbon/human/participant)
	if(!participant || (participant in participants))
		return FALSE
	
	participants += participant
	events += list(list(
		"type" = "participant_added",
		"mob" = participant.name,
		"ckey" = participant.ckey,
		"time" = world.time
	))
	return TRUE

/datum/containment_evaluation/proc/add_event(event_type, data)
	events += list(list(
		"type" = event_type,
		"data" = data,
		"time" = world.time
	))

/datum/containment_metric
	var/metric_type
	var/name
	var/weight
	var/description
	var/score = 100
	var/data

/datum/containment_metric/New(type, n, w, desc)
	metric_type = type
	name = n
	weight = w
	description = desc
	score = 100

/datum/player_containment_stats
	var/ckey
	var/total_containments = 0
	var/rating_s_count = 0
	var/rating_a_count = 0
	var/rating_b_count = 0
	var/rating_c_count = 0
	var/rating_d_count = 0
	var/rating_f_count = 0
	var/average_rating = 0
	var/list/containment_by_scp = list()
	var/list/containing_by_role = list()

/datum/player_containment_stats/New(c)
	ckey = c

/datum/player_containment_stats/proc/update_average_rating()
	var/total = rating_s_count + rating_a_count + rating_b_count + rating_c_count + rating_d_count + rating_f_count
	if(total == 0)
		average_rating = 0
		return
	
	var/weighted_sum = (rating_s_count * 6) + (rating_a_count * 5) + (rating_b_count * 4) + (rating_c_count * 3) + (rating_d_count * 2) + (rating_f_count * 1)
	average_rating = weighted_sum / total

/datum/player_containment_stats/proc/get_summary()
	var/list/summary = list()
	summary["total"] = total_containments
	summary["ratings"] = list(
		"S" = rating_s_count,
		"A" = rating_a_count,
		"B" = rating_b_count,
		"C" = rating_c_count,
		"D" = rating_d_count,
		"F" = rating_f_count
	)
	summary["average"] = average_rating
	summary["by_scp"] = containment_by_scp
	return summary

/mob/proc/view_containment_stats()
	set name = "View Containment Stats"
	set category = "SCP"
	set desc = "View your containment statistics."
	
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		to_chat(src, "<span class='warning'>Containment evaluation system not available.</span>")
		return
	
	if(!ckey)
		return
	
	var/datum/containment_evaluation_manager/manager = SScontainment_evaluation.manager
	var/datum/player_containment_stats/stats = manager.get_player_stats(ckey)
	
	if(!stats)
		to_chat(src, "<span class='notice'>No containment statistics available yet.</span>")
		return
	
	var/list/summary = stats.get_summary()
	
	var/message = "<h2>Containment Statistics</h2>"
	message += "<b>Total Containments:</b> [summary["total"]]<br>"
	message += "<b>Average Rating:</b> [round(summary["average"], 0.1)]/6.0<br><br>"
	
	message += "<b>Rating Distribution:</b><br>"
	message += "- S: [summary["ratings"]["S"]]<br>"
	message += "- A: [summary["ratings"]["A"]]<br>"
	message += "- B: [summary["ratings"]["B"]]<br>"
	message += "- C: [summary["ratings"]["C"]]<br>"
	message += "- D: [summary["ratings"]["D"]]<br>"
	message += "- F: [summary["ratings"]["F"]]<br><br>"
	
	if(length(summary["by_scp"]) > 0)
		message += "<b>Containments by SCP:</b><br>"
		for(var/scp_id in summary["by_scp"])
			message += "- [scp_id]: [summary["by_scp"][scp_id]]<br>"
	
	to_chat(src, "<span class='notice'>[message]</span>")

/mob/proc/view_active_breaches()
	set name = "View Active Breaches"
	set category = "SCP"
	set desc = "View currently active containment breaches."
	
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		to_chat(src, "<span class='warning'>Containment evaluation system not available.</span>")
		return
	
	var/datum/containment_evaluation_manager/manager = SScontainment_evaluation.manager
	
	var/message = "<h2>Active Breaches</h2>"
	
	if(!length(manager.active_evaluations))
		message += "<i>No active breaches.</i>"
	else
		for(var/eval_id in manager.active_evaluations)
			var/datum/containment_evaluation/eval = manager.active_evaluations[eval_id]
			var/duration = round((world.time - eval.start_time) / 600, 0.1)
			
			message += "<b>[eval.scp_id]</b><br>"
			message += "- Duration: [duration] minutes<br>"
			message += "- Type: [eval.breach_type]<br>"
			message += "- Participants: [length(eval.participants)]<br><br>"
	
	to_chat(src, "<span class='notice'>[message]</span>")

/proc/trigger_containment_evaluation(scp_id, breach_type)
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		return null
	
	return SScontainment_evaluation.manager.start_evaluation(scp_id, breach_type)

/proc/complete_containment_evaluation(scp_id, list/participants)
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		return FALSE
	
	for(var/eval_id in SScontainment_evaluation.manager.active_evaluations)
		var/datum/containment_evaluation/eval = SScontainment_evaluation.manager.active_evaluations[eval_id]
		if(eval.scp_id == scp_id)
			return SScontainment_evaluation.manager.complete_evaluation(eval_id, participants)
	
	return FALSE

/proc/report_containment_casualty(eval_id, count)
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		return FALSE
	return SScontainment_evaluation.manager.update_metric(eval_id, METRIC_PERSONNEL_SAFETY, count)

/proc/report_facility_damage(eval_id, damage_level)
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		return FALSE
	return SScontainment_evaluation.manager.update_metric(eval_id, METRIC_FACILITY_DAMAGE, damage_level)

/proc/report_scp_damage(eval_id, damage_percent)
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		return FALSE
	return SScontainment_evaluation.manager.update_metric(eval_id, METRIC_SCP_CONDITION, damage_percent)

/proc/report_first_responder(mob/living/carbon/human/responder, scp_id)
	if(!SScontainment_evaluation || !SScontainment_evaluation.manager)
		return FALSE

	for(var/eval_id in SScontainment_evaluation.manager.active_evaluations)
		var/datum/containment_evaluation/eval = SScontainment_evaluation.manager.active_evaluations[eval_id]
		if(eval.scp_id == scp_id)
			eval.add_participant(responder)
			if(!eval.first_responder)
				SScontainment_evaluation.manager.update_metric(eval_id, METRIC_RESPONSE_TIME, 0)
				eval.first_responder = responder.ckey

			var/adherence_score = 80
			var/area/A = get_area(responder)
			var/zone = get_containment_zone(A)
			if(zone == "hcz" || zone == "lcz")
				adherence_score += 10
			if(responder.wear_id)
				var/obj/item/card/id/id_card = responder.get_idcard(TRUE)
				if(id_card && (ACCESS_SECURITY in id_card.access))
					adherence_score += 10
			SScontainment_evaluation.manager.update_metric(eval_id, METRIC_PROTOCOL_ADHERENCE, min(adherence_score, 100))
			return TRUE
	return FALSE
