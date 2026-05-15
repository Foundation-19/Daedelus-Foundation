/obj/machinery/computer/scp_testing_console
	name = "SCP Testing Console"
	desc = "A console for submitting and managing SCP testing requests."
	icon_screen = "research"
	icon_keyboard = "research_key"
	circuit = /obj/item/circuitboard/computer/scp_testing_console
	var/current_scp = null
	var/current_subject = null
	var/test_type = "Standard Exposure"
	var/risk_level = 1
	var/test_active = FALSE
	var/observations = ""

/obj/machinery/computer/scp_testing_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPTestingConsole", "SCP Testing Console")
		ui.open()

/obj/machinery/computer/scp_testing_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/scp_testing_console/ui_data(mob/user)
	var/list/data = list()
	var/list/scp_list = list()

	for(var/mob/living/L in GLOB.mob_living_list)
		if(!istype(L, /mob/living/scp))
			continue
		if(L.stat == DEAD)
			continue
		var/status = "contained"
		if("containment_status" in L.vars)
			status = L.vars["containment_status"]
		scp_list += list(list(
			"name" = L.name,
			"ref" = REF(L),
			"status" = status
		))

	var/list/subjects = list()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(H.stat == DEAD)
			continue
		if(H.job != JOB_DCLASS && H.job != "D-Class Personnel")
			continue
		subjects += list(list(
			"name" = H.real_name,
			"ref" = REF(H)
		))

	data["scp_list"] = scp_list
	data["subjects"] = subjects
	data["current_scp"] = current_scp
	data["current_subject"] = current_subject
	data["test_type"] = test_type
	data["risk_level"] = risk_level
	data["test_active"] = test_active
	data["observations"] = observations

	return data

/obj/machinery/computer/scp_testing_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_scp")
			current_scp = params["ref"]
			return TRUE

		if("select_subject")
			current_subject = params["ref"]
			return TRUE

		if("set_test_type")
			test_type = params["type"] || "Standard Exposure"
			return TRUE

		if("set_risk_level")
			risk_level = text2num(params["level"]) || 1
			risk_level = clamp(risk_level, 1, 5)
			return TRUE

		if("start_test")
			if(!current_scp || !current_subject)
				return

			test_active = TRUE
			observations = ""

			var/mob/living/scp/S = locate(current_scp)
			var/mob/living/carbon/human/H = locate(current_subject)

			if(S && H)
				if(GLOB.scp_admin_log)
					GLOB.scp_admin_log.log_event("test_start", S.name, usr?.ckey || "N/A", H.real_name, "Test type: [test_type], Risk: [risk_level]", risk_level)

				priority_announce("SCP Testing Protocol initiated. SCP: [S.name], Subject: [H.real_name]. Test Type: [test_type]. Risk Level: [risk_level].", "Testing Protocol", "Research Department", ANNOUNCER_ALERT)

			return TRUE

		if("log_observation")
			var/note = params["note"]
			if(!note)
				return
			observations += "[gameTimestamp("hh:mm")] - [note]<br>"
			return TRUE

		if("set_outcome")
			if(!test_active)
				return

			var/outcome = params["outcome"] || "Inconclusive"
			test_active = FALSE

			var/mob/living/scp/S = locate(current_scp)
			var/mob/living/carbon/human/H = locate(current_subject)

			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("test_complete", S ? S.name : "N/A", usr?.ckey || "N/A", H ? H.real_name : "N/A", "Outcome: [outcome]", risk_level)

			priority_announce("SCP Testing Protocol complete. SCP: [S ? S.name : "N/A"], Outcome: [outcome].", "Testing Complete", "Research Department", ANNOUNCER_ALERT)

			var/obj/item/paper/report = new(get_turf(src))
			report.name = "Test Report — [S ? S.name : "Unknown"]"
			report.info = {"
				<center><b>SCP FOUNDATION — TEST REPORT</b></center>
				<hr>
				<b>SCP:</b> [S ? S.name : "N/A"]<br>
				<b>Subject:</b> [H ? H.real_name : "N/A"]<br>
				<b>Test Type:</b> [test_type]<br>
				<b>Risk Level:</b> [risk_level]<br>
				<b>Outcome:</b> [outcome]<br>
				<b>Researcher:</b> [usr?.real_name || "Unknown"]<br>
				<hr>
				<b>Observations:</b><br>
				[observations || "None recorded."]<br>
				<hr>
				<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br>
			"}

			return TRUE

/obj/item/circuitboard/computer/scp_testing_console
	name = "SCP Testing Console (Computer Board)"
	build_path = /obj/machinery/computer/scp_testing_console
