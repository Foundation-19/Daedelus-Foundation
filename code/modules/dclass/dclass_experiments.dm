// D-Class Experiment Integration
// Links D-Class personnel to the SCP experiment system

#ifndef DCLASS_TRUST_HOSTILE
#define DCLASS_TRUST_HOSTILE 0
#define DCLASS_TRUST_SUSPICIOUS 1
#define DCLASS_TRUST_NEUTRAL 2
#define DCLASS_TRUST_COOPERATIVE 3
#define DCLASS_TRUST_TRUSTED 4
#define DCLASS_STATUS_GENERAL 0
#define DCLASS_STATUS_TEST_SUBJECT 1
#define DCLASS_STATUS_MEDICAL_SUBJECT 2
#define DCLASS_STATUS_CONTAINMENT_ASSIST 3
#endif

#ifndef EXPERIMENT_TYPE_BEHAVIORAL
#define EXPERIMENT_TYPE_BEHAVIORAL 1
#define EXPERIMENT_TYPE_CONTAINMENT 2
#define EXPERIMENT_TYPE_INTERACTION 3
#define EXPERIMENT_TYPE_HAZARD 4
#define EXPERIMENT_TYPE_MEDICAL 5
#define EXPERIMENT_TYPE_TECHNICAL 6
#define EXPERIMENT_TYPE_COGNITIVE 7
#define EXPERIMENT_TYPE_EXPLORATION 8
#define EXPERIMENT_TYPE_CARE 9
#define EXPERIMENT_TYPE_OBSERVATION 10
#define EXPERIMENT_RISK_MINIMAL 1
#define EXPERIMENT_RISK_LOW 2
#define EXPERIMENT_RISK_MEDIUM 3
#define EXPERIMENT_RISK_HIGH 4
#define EXPERIMENT_RISK_CRITICAL 5
#endif

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
#endif

#define DCLASS_TEST_VOLUNTEER 1
#define DCLASS_TEST_MANDATORY 2
#define DCLASS_TEST_EMERGENCY 3

SUBSYSTEM_DEF(dclass_experiments)
	name = "D-Class Experiments"
	wait = 300
	priority = FIRE_PRIORITY_DCLASS
	var/list/pending_subject_requests = list()
	var/list/active_test_subjects = list()
	var/list/test_history = list()

/datum/controller/subsystem/dclass_experiments/Initialize()
	world.log << "D-Class Experiment System: Initialized"
	return ..()

/datum/controller/subsystem/dclass_experiments/fire()
	process_pending_requests()
	check_active_subjects()

/datum/controller/subsystem/dclass_experiments/proc/process_pending_requests()
	for(var/request_id in pending_subject_requests)
		var/list/request = pending_subject_requests[request_id]
		if(request["expires"] && world.time > request["expires"])
			pending_subject_requests -= request_id
			var/requester = request["requester"]
			if(istype(requester, /mob/living/carbon/human))
				to_chat(requester, span_warning("D-Class subject request expired."))

/datum/controller/subsystem/dclass_experiments/proc/check_active_subjects()
	for(var/ckey in active_test_subjects)
		var/mob/living/carbon/human/H = get_mob_by_ckey(ckey)
		if(!H || H.stat == DEAD)
			var/list/subject_data = active_test_subjects[ckey]
			on_subject_death(ckey, subject_data)

/datum/controller/subsystem/dclass_experiments/proc/on_subject_death(ckey, list/subject_data)
	var/datum/dclass_player/player = SSdclass.manager?.get_dclass_player(ckey)
	if(player)
		player.add_incident("test_death", "Died during testing with [subject_data["scp_id"]]", "major")
		if(subject_data["experiment_id"])
			var/datum/scp_experiment/exp = SSscp_experiments?.manager?.active_experiments[subject_data["experiment_id"]]
			if(exp)
				exp.record_data("subject_death", ckey)
	active_test_subjects -= ckey

/datum/controller/subsystem/dclass_experiments/proc/request_test_subject(mob/living/carbon/human/requester, scp_id, test_type, danger_level, mandatory = FALSE)
	if(!requester || !requester.ckey)
		return null

	var/request_id = "req_[requester.ckey]_[scp_id]_[world.time]"

	var/list/eligible_subjects = get_eligible_subjects(danger_level, mandatory)

	if(!length(eligible_subjects))
		pending_subject_requests[request_id] = list(
			"requester" = requester,
			"scp_id" = scp_id,
			"test_type" = test_type,
			"danger_level" = danger_level,
			"mandatory" = mandatory,
			"expires" = world.time + 3000
		)
		to_chat(requester, span_notice("No D-Class subjects currently available. Request queued."))
		return null

	return eligible_subjects

/datum/controller/subsystem/dclass_experiments/proc/get_eligible_subjects(danger_level, mandatory = FALSE)
	var/list/eligible = list()

	for(var/ckey in SSdclass.manager?.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob)
			continue

		if(player.mob.stat == DEAD)
			continue

		if(ckey in active_test_subjects)
			continue

		if(!can_participate_in_test(player, danger_level))
			continue

		if(mandatory || player.trust_level >= DCLASS_TRUST_COOPERATIVE)
			eligible[ckey] = list(
				"player" = player,
				"trust" = player.trust_level,
				"tests_completed" = player.tests_completed,
				"health" = player.mob.health
			)

	return eligible

/datum/controller/subsystem/dclass_experiments/proc/can_participate_in_test(datum/dclass_player/player, danger_level)
	if(!player || !player.mob)
		return FALSE

	if(player.strikes >= 3 && danger_level >= EXPERIMENT_RISK_HIGH)
		return FALSE

	if(player.trust_level == DCLASS_TRUST_HOSTILE && danger_level >= EXPERIMENT_RISK_MEDIUM)
		return FALSE

	return TRUE

/datum/controller/subsystem/dclass_experiments/proc/assign_subject_to_experiment(mob/living/carbon/human/subject, experiment_id, scp_id, test_type, danger_level)
	if(!subject || !subject.ckey)
		return FALSE

	var/datum/dclass_player/player = SSdclass.manager?.get_dclass_player(subject.ckey)
	if(!player)
		return FALSE

	active_test_subjects[subject.ckey] = list(
		"experiment_id" = experiment_id,
		"scp_id" = scp_id,
		"test_type" = test_type,
		"danger_level" = danger_level,
		"start_time" = world.time,
		"voluntary" = (player.trust_level >= DCLASS_TRUST_COOPERATIVE)
	)

	player.status = DCLASS_STATUS_TEST_SUBJECT

	var/reward_preview = calculate_test_reward(danger_level, player.trust_level)
	to_chat(subject, span_notice("You have been assigned to testing with [scp_id]."))
	to_chat(subject, span_notice("Estimated compensation: [reward_preview] credits."))
	to_chat(subject, span_warning("Report to the designated testing area immediately."))

	return TRUE

/datum/controller/subsystem/dclass_experiments/proc/complete_subject_participation(mob/living/carbon/human/subject, outcome, scp_id, danger_level)
	if(!subject || !subject.ckey)
		return FALSE

	var/datum/dclass_player/player = SSdclass.manager?.get_dclass_player(subject.ckey)
	if(!player)
		return FALSE

	var/was_voluntary = FALSE
	var/related_exp_id = null
	if(subject.ckey in active_test_subjects)
		was_voluntary = active_test_subjects[subject.ckey]["voluntary"]
		related_exp_id = active_test_subjects[subject.ckey]["experiment_id"]
		active_test_subjects -= subject.ckey

	player.record_test(scp_id, "standard", outcome, danger_level)

	var/credit_reward = calculate_test_reward(danger_level, player.trust_level)
	player.adjust_credits(credit_reward, "Test participation: [scp_id]")

	switch(outcome)
		if("success", "partial_success")
			player.adjust_trust(was_voluntary ? 8 : 5, "Successful test participation")
			if(was_voluntary)
				player.good_behavior_points += 5
		if("failure")
			player.adjust_trust(was_voluntary ? 3 : 1, "Test participation")
		if("refused")
			player.adjust_trust(-10, "Test refusal")
			player.add_incident("test_refusal", "Refused testing with [scp_id]", "major")

	record_test_history(subject.ckey, scp_id, outcome, danger_level, credit_reward)

	player.status = DCLASS_STATUS_GENERAL

	track_scp_interaction(subject, scp_id, "dclass_testing", outcome)
	if(SSscp_experiments?.manager && related_exp_id && SSscp_experiments.manager.active_experiments[related_exp_id])
		var/exp_outcome = (outcome == "success" || outcome == "partial_success") ? 2 : 5
		SSscp_experiments.manager.complete_experiment(related_exp_id, exp_outcome, subject)

	to_chat(subject, span_notice("Testing complete. You earned [credit_reward] credits."))

	return TRUE

/datum/controller/subsystem/dclass_experiments/proc/calculate_test_reward(danger_level, trust_level)
	var/base = 50
	switch(danger_level)
		if(EXPERIMENT_RISK_MINIMAL)
			base = 30
		if(EXPERIMENT_RISK_LOW)
			base = 50
		if(EXPERIMENT_RISK_MEDIUM)
			base = 100
		if(EXPERIMENT_RISK_HIGH)
			base = 200
		if(EXPERIMENT_RISK_CRITICAL)
			base = 400

	var/trust_bonus = trust_level * 15
	return base + trust_bonus

/datum/controller/subsystem/dclass_experiments/proc/record_test_history(ckey, scp_id, outcome, danger_level, reward)
	test_history += list(list(
		"ckey" = ckey,
		"scp_id" = scp_id,
		"outcome" = outcome,
		"danger" = danger_level,
		"reward" = reward,
		"timestamp" = world.time
	))

/datum/controller/subsystem/dclass_experiments/proc/get_subject_status(ckey)
	if(ckey in active_test_subjects)
		return active_test_subjects[ckey]
	return null

/obj/machinery/dclass_experiment_terminal
	name = "D-Class Assignment Terminal"
	desc = "A terminal for assigning D-Class personnel to SCP testing."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE

	var/selected_scp_id = null
	var/selected_test_type = EXPERIMENT_TYPE_BEHAVIORAL
	var/selected_danger_level = EXPERIMENT_RISK_LOW
	var/mandatory_assignment = FALSE

/obj/machinery/dclass_experiment_terminal/attack_hand(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(!is_researcher(H))
		to_chat(H, span_warning("Only authorized research personnel can use this terminal."))
		return

	ui_interact(H)

/obj/machinery/dclass_experiment_terminal/proc/is_researcher(mob/living/carbon/human/H)
	if(!H.job)
		return FALSE
	return (H.job in list("Scientist", "Research Director", "Senior Researcher", "Research Assistant", "Medical Doctor"))

/obj/machinery/dclass_experiment_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DclassExperimentTerminal")
		ui.open()

/obj/machinery/dclass_experiment_terminal/ui_data(mob/user)
	var/list/data = list()

	data["selected_scp"] = selected_scp_id
	data["selected_test_type"] = selected_test_type
	data["selected_danger"] = selected_danger_level
	data["mandatory"] = mandatory_assignment

	data["available_scps"] = list()
	if(SSscp_persistence?.manager)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			data["available_scps"] += list(list(
				"id" = scp_id,
				"class" = instance?.containment_class || "Unknown"
			))

	data["eligible_subjects"] = list()
	if(selected_scp_id)
		var/list/eligible = SSdclass_experiments?.get_eligible_subjects(selected_danger_level, mandatory_assignment)
		if(eligible)
			for(var/ckey in eligible)
				var/list/subject_info = eligible[ckey]
				var/datum/dclass_player/player = subject_info["player"]
				data["eligible_subjects"] += list(list(
					"ckey" = ckey,
					"name" = player?.dclass_number || "Unknown",
					"trust" = player?.trust_level || 0,
					"tests" = player?.tests_completed || 0,
					"health" = round(subject_info["health"] || 0)
				))

	var/datum/dclass_player/viewer_data
	if(user.ckey)
		viewer_data = SSdclass.manager?.get_dclass_player(user.ckey)
	data["is_dclass"] = !!viewer_data

	return data

/obj/machinery/dclass_experiment_terminal/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_scp")
			selected_scp_id = params["scp_id"]
			. = TRUE
		if("select_test_type")
			selected_test_type = text2num(params["type"])
			. = TRUE
		if("select_danger")
			selected_danger_level = text2num(params["danger"])
			. = TRUE
		if("toggle_mandatory")
			mandatory_assignment = !mandatory_assignment
			. = TRUE
		if("assign_subject")
			var/ckey = params["ckey"]
			if(!ckey || !selected_scp_id)
				return

			var/mob/living/carbon/human/subject
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.ckey == ckey)
					subject = H
					break

			if(!subject)
				to_chat(usr, span_warning("Subject not found."))
				return

			var/exp_id = "exp_[selected_scp_id]_[world.time]"

			if(SSdclass_experiments?.assign_subject_to_experiment(subject, exp_id, selected_scp_id, selected_test_type, selected_danger_level))
				to_chat(usr, span_notice("D-Class [subject.name] assigned to testing."))
				. = TRUE
			else
				to_chat(usr, span_warning("Failed to assign subject."))
		if("complete_test")
			var/ckey = params["ckey"]
			var/outcome = params["outcome"]

			var/mob/living/carbon/human/subject
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.ckey == ckey)
					subject = H
					break

			if(subject && SSdclass_experiments)
				SSdclass_experiments.complete_subject_participation(subject, outcome, selected_scp_id, selected_danger_level)
				. = TRUE

/obj/machinery/dclass_experiment_terminal/proc/get_test_type_name(type)
	switch(type)
		if(EXPERIMENT_TYPE_BEHAVIORAL)
			return "Behavioral"
		if(EXPERIMENT_TYPE_CONTAINMENT)
			return "Containment"
		if(EXPERIMENT_TYPE_INTERACTION)
			return "Interaction"
		if(EXPERIMENT_TYPE_HAZARD)
			return "Hazard"
		if(EXPERIMENT_TYPE_MEDICAL)
			return "Medical"
		if(EXPERIMENT_TYPE_TECHNICAL)
			return "Technical"
		if(EXPERIMENT_TYPE_COGNITIVE)
			return "Cognitive"
		if(EXPERIMENT_TYPE_EXPLORATION)
			return "Exploration"
		if(EXPERIMENT_TYPE_CARE)
			return "Care"
		if(EXPERIMENT_TYPE_OBSERVATION)
			return "Observation"
	return "Unknown"

/mob/living/carbon/human/proc/volunteer_for_testing()
	if(!ckey)
		return

	var/datum/dclass_player/player = SSdclass.manager?.get_dclass_player(ckey)
	if(!player)
		to_chat(src, span_warning("You are not registered as D-Class."))
		return

	if(player.trust_level < DCLASS_TRUST_COOPERATIVE)
		to_chat(src, span_warning("You need at least Cooperative trust level to volunteer."))
		return

	if(ckey in SSdclass_experiments?.active_test_subjects)
		to_chat(src, span_warning("You are already assigned to a test."))
		return

	var/list/available_tests = get_available_tests()

	if(!length(available_tests))
		to_chat(src, span_notice("No tests currently available for volunteers."))
		return

	var/choice = input(src, "Select a test to volunteer for:", "Volunteer for Testing") as null|anything in available_tests

	if(!choice)
		return

	var/list/test_info = available_tests[choice]

	var/confirm = alert(src, "Volunteer for test with [test_info["scp_id"]]?\nDanger Level: [test_info["danger"]]\nEstimated Reward: [test_info["reward"]] credits", "Confirm Volunteer", "Yes", "No")

	if(confirm != "Yes")
		return

	var/exp_id = "exp_[test_info["scp_id"]]_[world.time]"
	SSdclass_experiments?.assign_subject_to_experiment(src, exp_id, test_info["scp_id"], test_info["test_type"], test_info["danger"])

/mob/living/carbon/human/proc/get_available_tests()
	var/list/tests = list()

	if(!SSdclass_experiments?.pending_subject_requests)
		return tests

	for(var/request_id in SSdclass_experiments.pending_subject_requests)
		var/list/request = SSdclass_experiments.pending_subject_requests[request_id]
		if(request["mandatory"])
			continue

		var/reward = SSdclass_experiments.calculate_test_reward(request["danger_level"], SSdclass.manager?.get_dclass_player(ckey)?.trust_level || 2)
		tests["[request["scp_id"]] - [request["test_type"]]"] = list(
			"scp_id" = request["scp_id"],
			"test_type" = request["test_type"],
			"danger" = request["danger_level"],
			"reward" = reward
		)

	return tests

/mob/living/carbon/human/proc/check_test_status()
	if(!ckey)
		return

	var/list/status = SSdclass_experiments?.get_subject_status(ckey)

	if(!status)
		to_chat(src, span_notice("You are not currently assigned to any tests."))
		return

	var/info = "<h3>Current Test Assignment</h3>"
	info += "<b>SCP:</b> [status["scp_id"]]<br>"
	info += "<b>Test Type:</b> [status["test_type"]]<br>"
	info += "<b>Danger Level:</b> [status["danger_level"]]<br>"
	info += "<b>Assignment Time:</b> [round((world.time - status["start_time"]) / 600, 0.1)] minutes ago<br>"
	info += "<b>Voluntary:</b> [status["voluntary"] ? "Yes" : "No"]<br>"

	to_chat(src, span_notice("[info]"))

/mob/proc/manage_dclass_testing()
	set name = "Manage D-Class Testing"
	set category = "Research"
	set desc = "Request and manage D-Class test subjects."

	if(!ishuman(src))
		return

	var/mob/living/carbon/human/H = src

	if(!(H.job in list("Scientist", "Research Director", "Senior Researcher", "Medical Doctor")))
		to_chat(H, span_warning("Only research personnel can manage D-Class testing."))
		return

	var/choice = input(H, "D-Class Testing Management", "Select an action:") as null|anything in list("Request Subject", "View Active Subjects", "View Test History")

	if(!choice)
		return

	switch(choice)
		if("Request Subject")
			var/list/scp_options = list()
			if(SSscp_persistence?.manager)
				for(var/scp_id in SSscp_persistence.manager.scp_instances)
					scp_options += scp_id

			if(!length(scp_options))
				to_chat(H, span_warning("No SCPs available for testing."))
				return

			var/selected_scp = input(H, "Select SCP for testing:", "Request Subject") as null|anything in scp_options
			if(!selected_scp)
				return

			var/danger = input(H, "Select danger level:", "Request Subject") as null|anything in list("Minimal (1)", "Low (2)", "Medium (3)", "High (4)", "Critical (5)")
			if(!danger)
				return

			var/danger_level = text2num(danger[findtext(danger, "(")+1])

			var/mandatory = alert(H, "Is this a mandatory assignment?", "Request Subject", "Yes", "No") == "Yes"

			var/list/eligible = SSdclass_experiments?.request_test_subject(H, selected_scp, EXPERIMENT_TYPE_BEHAVIORAL, danger_level, mandatory)

			if(eligible && length(eligible))
				var/list/subject_choices = list()
				for(var/ckey in eligible)
					var/list/info = eligible[ckey]
					var/datum/dclass_player/player = info["player"]
					subject_choices["[player?.dclass_number || ckey] (Trust: [info["trust"]], Tests: [info["tests_completed"]])"] = ckey

				var/selected = input(H, "Select a D-Class subject:", "Available Subjects") as null|anything in subject_choices
				if(!selected)
					return

				var/selected_ckey = subject_choices[selected]
				var/mob/living/carbon/human/subject
				for(var/mob/living/carbon/human/M in GLOB.player_list)
					if(M.ckey == selected_ckey)
						subject = M
						break

				if(subject)
					var/exp_id = "exp_[selected_scp]_[world.time]"
					if(SSdclass_experiments?.assign_subject_to_experiment(subject, exp_id, selected_scp, EXPERIMENT_TYPE_BEHAVIORAL, danger_level))
						to_chat(H, span_notice("D-Class [subject.name] assigned to testing with [selected_scp]."))

		if("View Active Subjects")
			var/message = "<h3>Active D-Class Test Subjects</h3>"
			if(!length(SSdclass_experiments?.active_test_subjects))
				message += "<i>No active test subjects.</i>"
			else
				for(var/ckey in SSdclass_experiments.active_test_subjects)
					var/list/data = SSdclass_experiments.active_test_subjects[ckey]
					message += "<b>[ckey]</b>: [data["scp_id"]] (Danger: [data["danger_level"]])<br>"
			to_chat(H, span_notice("[message]"))

		if("View Test History")
			var/message = "<h3>Recent Test History</h3>"
			var/count = 0
			for(var/i = length(SSdclass_experiments?.test_history) to max(1, length(SSdclass_experiments?.test_history) - 9) step -1)
				if(count >= 10)
					break
				var/list/record = SSdclass_experiments.test_history[i]
				message += "[record["ckey"]]: [record["scp_id"]] - [record["outcome"]] ([record["reward"]] credits)<br>"
				count++
			to_chat(H, span_notice("[message]"))
