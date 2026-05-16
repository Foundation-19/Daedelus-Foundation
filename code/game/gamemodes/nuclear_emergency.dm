///What percentage of the crew can become traitors.
#define NUKIE_SCALING_COEFF 0.0555 // About 1 in 18 crew

/datum/game_mode/nuclear_emergency
	name = "Nuclear Emergency"

	weight = GAMEMODE_WEIGHT_NEVER
	required_enemies = 5
	min_pop = 25

	var/datum/team/nuclear/nuke_team
	///The antagonist selector for this gamemode.
	var/datum/antagonist_selector/nukeop/antag_selector

/datum/game_mode/nuclear_emergency/pre_setup()
	. = ..()

	var/num_nukies = max(required_enemies, round(length(SSticker.ready_players) * NUKIE_SCALING_COEFF))

	antag_selector = new /datum/antagonist_selector/nukeop()
	antag_selector.setup(num_nukies, possible_antags)

/datum/game_mode/nuclear_emergency/post_setup()
	. = ..()
	antag_selector.give_antag_datums(src)

/datum/game_mode/nuclear_emergency/set_round_result()
	. = ..()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH
