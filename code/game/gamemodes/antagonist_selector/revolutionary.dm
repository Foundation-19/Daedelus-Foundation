/datum/antagonist_selector/revolutionary
	//Atleast 1 of any head.
	required_jobs = list(
		list(JOB_SITE_DIRECTOR = 1),
		list(JOB_HUMAN_RESOURCES_DIRECTOR = 1),
		list(JOB_GUARD_COMMANDER = 1),
		list(JOB_ENGINEERING_DIRECTOR = 1),
		list(JOB_MEDICAL_DIRECTOR = 1),
		list(JOB_RESEARCH_DIRECTOR = 1)
	)

	restricted_jobs = list(
		JOB_SITE_DIRECTOR,
		JOB_HUMAN_RESOURCES_DIRECTOR,
		JOB_AI,
		JOB_CYBORG,
		JOB_JUNIOR_EZ_GUARD,
		JOB_EZ_GUARD,
		JOB_SENIOR_EZ_GUARD,
		JOB_EZ_ZONE_SUPERVISOR,
		JOB_RAISA_AGENT,
		JOB_INVESTIGATIONS_AGENT,
		JOB_LCZ_ZONE_JUNIOR_LIEUTENANT,
		JOB_SENIOR_LCZ_GUARD,
		JOB_LCZ_GUARD,
		JOB_JUNIOR_LCZ_GUARD,
		JOB_HCZ_ZONE_SENIOR_LIEUTENANT,
		JOB_SENIOR_HCZ_GUARD,
		JOB_HCZ_GUARD,
		JOB_JUNIOR_HCZ_GUARD,
	)

	antag_flag = ROLE_REV_HEAD
	antag_datum = /datum/antagonist/rev/head

/datum/antagonist_selector/revolutionary/give_antag_datums(datum/game_mode/gamemode)
	var/datum/game_mode/revolution/rev_gamemode = gamemode

	for(var/datum/mind/M in selected_antagonists)
		if(!rev_gamemode.check_eligible(M))
			selected_antagonists -= M
			log_game("Revolution: discarded [M.name] from head revolutionary due to ineligibility.")
			continue

		var/datum/antagonist/rev/head/new_head = new antag_datum()
		new_head.give_flash = TRUE
		new_head.remove_clumsy = TRUE
		M.add_antag_datum(new_head, rev_gamemode.revolution)
