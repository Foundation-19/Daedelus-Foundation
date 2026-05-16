/datum/antagonist_selector/cultist
	restricted_jobs = list(
		JOB_AI,
		JOB_SITE_DIRECTOR,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_INVESTIGATIONS_AGENT,
		JOB_HUMAN_RESOURCES_DIRECTOR,
		JOB_GUARD_COMMANDER,
		JOB_DCLASS,
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
		JOB_JUNIOR_HCZ_GUARD
	)

	antag_datum = /datum/antagonist/cult
	antag_flag = ROLE_CULTIST

/datum/antagonist_selector/cultist/give_antag_datums(datum/game_mode/gamemode)
	var/datum/game_mode/bloodcult/cult_gamemode = gamemode
	cult_gamemode.main_cult = new

	for(var/datum/mind/M in selected_antagonists)
		var/datum/antagonist/cult/new_cultist = new antag_datum()
		new_cultist.cult_team = cult_gamemode.main_cult
		new_cultist.give_equipment = TRUE
		M.add_antag_datum(new_cultist)
		GLOB.pre_setup_antags -= M

	cult_gamemode.main_cult.setup_objectives()
