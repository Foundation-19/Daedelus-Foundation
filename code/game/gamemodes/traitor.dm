///What percentage of the crew can become traitors.
#define TRAITOR_SCALING_COEFF 0.15

/datum/game_mode/traitor
	name = "Traitor"

	weight = GAMEMODE_WEIGHT_NEVER
	///The antagonist selector for this gamemode.
	var/datum/antagonist_selector/traitor/antag_selector

/datum/game_mode/traitor/pre_setup()
	. = ..()

	var/num_traitors = max(1, round(length(SSticker.ready_players) * TRAITOR_SCALING_COEFF))

	antag_selector = new /datum/antagonist_selector/traitor()
	antag_selector.setup(num_traitors, possible_antags)

/datum/game_mode/traitor/post_setup()
	. = ..()
	antag_selector.give_antag_datums(src)
