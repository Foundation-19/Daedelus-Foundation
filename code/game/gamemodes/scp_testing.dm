/datum/game_mode/scp_testing
	name = "SCP Testing"
	weight = GAMEMODE_WEIGHT_UNCOMMON
	votable = TRUE

	min_pop = 5
	required_enemies = 0
	max_pop = INFINITY

	var/test_phase = 0
	var/list/active_experiments = list()
	var/round_start_time
	var/breach_triggered = FALSE

/datum/game_mode/scp_testing/pre_setup()
	..()
	return TRUE

/datum/game_mode/scp_testing/post_setup(report)
	. = ..()
	round_start_time = world.time
	test_phase = 1

	priority_announce("Welcome to Site-53. Today's shift focus: Anomalous Object Testing. Research personnel, review your experiment assignments. D-Class personnel, report to testing chambers.", "SITE-53 COMMAND", sound_type = ANNOUNCER_DEFAULT)

/datum/game_mode/scp_testing/process(delta_time)
	if(breach_triggered)
		return
	var/time_elapsed = world.time - round_start_time
	if(time_elapsed > 20 MINUTES && prob(2))
		testing_incident()

/datum/game_mode/scp_testing/proc/testing_incident()
	breach_triggered = TRUE
	var/list/breachable = list("SCP-173", "SCP-096", "SCP-049", "SCP-079")
	var/scp_id = pick(breachable)
	var/atom/scp_atom = find_scp_mob(scp_id)
	hook_scp_breach(scp_id, scp_atom)
	priority_announce("ALERT: Testing incident involving [scp_id]. Containment breach confirmed. Security personnel respond immediately.", "TESTING INCIDENT", sound_type = ANNOUNCER_ALERT)

/datum/game_mode/scp_testing/check_finished()
	..()
	if(!SSticker.setup_done)
		return FALSE
	var/time_elapsed = world.time - round_start_time
	if(time_elapsed > 90 MINUTES)
		return TRUE
	return FALSE

/datum/game_mode/scp_testing/set_round_result()
	if(breach_triggered)
		SSticker.mode_result = "Testing Incident - Partial Breach"
	else
		SSticker.mode_result = "Successful Testing Shift"
