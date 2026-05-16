///What percentage of the crew can become culists.
#define CULT_SCALING_COEFF 0.15

/datum/game_mode/bloodcult
	name = "Blood Cult"

	weight = GAMEMODE_WEIGHT_NEVER
	min_pop = 30
	required_enemies = 2

	///The cult created by the gamemode.
	var/datum/team/cult/main_cult
	///The antagonist selector for this gamemode.
	var/datum/antagonist_selector/cultist/antag_selector

/datum/game_mode/bloodcult/pre_setup()
	. = ..()

	var/num_cultists = max(1, round(length(SSticker.ready_players) * CULT_SCALING_COEFF))

	antag_selector = new /datum/antagonist_selector/cultist()
	antag_selector.setup(num_cultists, possible_antags)

/datum/game_mode/bloodcult/post_setup()
	. = ..()
	antag_selector.give_antag_datums(src)

/datum/game_mode/bloodcult/set_round_result()
	. = ..()
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE
