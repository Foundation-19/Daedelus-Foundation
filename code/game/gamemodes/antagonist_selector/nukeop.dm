/datum/antagonist_selector/nukeop
	restricted_jobs = list(
		JOB_SITE_DIRECTOR,
		JOB_GUARD_COMMANDER,
	)// Just to be sure that a nukie getting picked won't ever imply a Site or Security director not getting drafted

	antag_datum = /datum/antagonist/nukeop
	antag_flag = ROLE_OPERATIVE

	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader

/datum/antagonist_selector/nukeop/give_antag_datums(datum/game_mode/gamemode)
	var/datum/game_mode/nuclear_emergency/nukie_gamemode = gamemode

	var/chosen_leader = FALSE
	for(var/datum/mind/M as anything in shuffle(selected_antagonists))
		if (!chosen_leader)
			chosen_leader = TRUE
			var/datum/antagonist/nukeop/leader/new_op = M.add_antag_datum(antag_leader_datum)
			nukie_gamemode.nuke_team = new_op.nuke_team
		else
			var/datum/antagonist/nukeop/new_op = new antag_datum()
			M.add_antag_datum(new_op)
