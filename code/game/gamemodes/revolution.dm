#define REVOLUTION_SCALING_COEFF 0.1
///The absolute cap of headrevs.
#define REVOLUTION_MAX_HEADREVS 3

/datum/game_mode/revolution
	name = "Revolution"

	weight = GAMEMODE_WEIGHT_NEVER
	min_pop = 25

	var/datum/team/revolution/revolution
	var/round_winner
	///The antagonist selector for this gamemode.
	var/datum/antagonist_selector/revolutionary/antag_selector

/datum/game_mode/revolution/pre_setup()
	. = ..()
	var/num_revs = clamp(round(length(SSticker.ready_players) * REVOLUTION_SCALING_COEFF), 1, REVOLUTION_MAX_HEADREVS)

	antag_selector = new /datum/antagonist_selector/revolutionary()
	antag_selector.setup(num_revs, possible_antags)

/datum/game_mode/revolution/setup_antags()
	revolution = new()
	. = ..()

	antag_selector.give_antag_datums(src)

	revolution.update_objectives()
	revolution.update_heads()
	SSshuttle.registerHostileEnvironment(revolution)

/// Checks for revhead loss conditions and other antag datums.
/datum/game_mode/revolution/proc/check_eligible(datum/mind/M)
	var/turf/T = get_turf(M.current)
	if(!considered_afk(M) && considered_alive(M) && is_station_level(T.z) && !M.antag_datums?.len && !HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return TRUE
	return FALSE

/datum/game_mode/revolution/process(delta_time)
	round_winner = revolution.check_completion()
	if(round_winner)
		datum_flags &= ~DF_ISPROCESSING

/datum/game_mode/revolution/check_finished()
	. = ..()
	if(.)
		return
	return !!round_winner

/datum/game_mode/revolution/set_round_result()
	. = ..()
	revolution.round_result(round_winner)
