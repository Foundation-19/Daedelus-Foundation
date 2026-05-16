///What percentage of the crew can become heretics.
#define HERETIC_SCALING_COEFF 0.1

/datum/game_mode/heretic
	name = "Heretic"

	weight = GAMEMODE_WEIGHT_NEVER
	///The antagonist selector for this gamemode.
	var/datum/antagonist_selector/heretic/antag_selector

/datum/game_mode/heretic/pre_setup()
	. = ..()

	var/num_heretics = max(1, round(length(SSticker.ready_players) * HERETIC_SCALING_COEFF))

	antag_selector = new /datum/antagonist_selector/heretic()
	antag_selector.setup(num_heretics, possible_antags)

/datum/game_mode/heretic/post_setup()
	. = ..()
	antag_selector.give_antag_datums(src)
