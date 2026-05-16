/datum/preference/blob/antagonists
	savefile_key = "antagonists"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/blob/antagonists/create_default_value()
	. = list()
	for(var/antagonist in GLOB.special_roles)
		.[antagonist] = TRUE

	// Add all playable SCPs to the list
	var/list/playable_scps = get_all_playable_scp_roles()
	for(var/scp_role in playable_scps)
		if(!(scp_role in .))
			.[scp_role] = TRUE

/datum/preference/blob/antagonists/deserialize(input, datum/preferences/preferences)
	var/list/reference = create_default_value()
	input |= reference
	input &= reference
	for(var/antagonist in input)
		input[antagonist] = !!input[antagonist]
	return input

/datum/preference/blob/antagonists/user_edit(mob/user, datum/preferences/prefs, list/params)
	var/list/client_antags = prefs.read_preference(type)
	if(params["select_all"])
		for(var/antag in client_antags)
			client_antags[antag] = TRUE
		return prefs.update_preference(src, client_antags)

	if(params["select_all_available"])
		// Only enable SCP and hostile group roles that the player has access to
		var/list/available_roles = get_available_scp_roles(prefs.parent.ckey)
		for(var/antag in client_antags)
			if(is_scp_or_hostile_role(antag) && (antag in available_roles))
				client_antags[antag] = TRUE
		return prefs.update_preference(src, client_antags)

	if(params["deselect_all"])
		for(var/antag in client_antags)
			client_antags[antag] = FALSE
		return prefs.update_preference(src, client_antags)

	var/antag = params["toggle_antag"]
	if(!(antag in client_antags))
		return

	client_antags[antag] = !client_antags[antag]
	return prefs.update_preference(src, client_antags)

/datum/preference/blob/antagonists/proc/get_available_scp_roles(ckey)
	var/list/available_roles = list()

	// Check SCP management system for player access
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

		// Get player permissions from the performance system
		available_roles = manager.get_player_available_scps(ckey)

	return available_roles

/datum/preference/blob/antagonists/proc/is_scp_or_hostile_role(role)
	// Check if the role is an SCP or hostile group role
	var/list/scp_roles = get_all_playable_scp_roles()
	scp_roles += list(
		ROLE_SARKIC_CULT,
		ROLE_CHAOS_INSURGENCY,
		ROLE_SERPENTS_HAND
	)

	return (role in scp_roles)

/datum/preference/blob/antagonists/proc/get_all_playable_scp_roles()
	var/list/playable_scp_roles = list()

	// Define all playable SCPs (not just currently spawned ones)
	playable_scp_roles = list(
		"SCP-173",    // The Sculpture
		"SCP-096",    // The Shy Guy
		"SCP-035",    // The Possessive Mask
		"SCP-049",    // The Plague Doctor
		"SCP-2427-3", // The Mechanical Spider
		"SCP-457",    // The Burning Man
		"SCP-343",    // God
		"SCP-3349",   // Reality Bender
		"SCP-2343",   // Benevolent Entity
		"SCP-2020",   // Dimensional Entity
		"SCP-1507",   // Pink Plastic Flamingo
		"SCP-131",    // The Eye Pods
		"SCP-017",    // Shadow Person
		"SCP-106",    // The Old Man
		"SCP-082",    // The Cannibal
		"SCP-939",    // With Many Voices
		"SCP-999",    // The Tickle Monster
		"SCP-5295",   // Temporal Entity
		"SCP-1048"    // The Teddy Bear
	)

	return playable_scp_roles

/datum/preferences/proc/get_antag_bans()
	var/list/antag_bans = list()

	for (var/datum/dynamic_ruleset/dynamic_ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/antag_flag = initial(dynamic_ruleset.antag_flag)
		var/antag_flag_override = initial(dynamic_ruleset.antag_flag_override)

		if (isnull(antag_flag))
			continue

		if (is_banned_from(parent.ckey, list(antag_flag_override || antag_flag, ROLE_SYNDICATE)))
			antag_bans += antag_flag

	return antag_bans

/datum/preferences/proc/get_antag_days_left()
	if (!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return

	var/list/antag_days_left = list()

	for (var/datum/dynamic_ruleset/dynamic_ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/antag_flag = initial(dynamic_ruleset.antag_flag)
		var/antag_flag_override = initial(dynamic_ruleset.antag_flag_override)

		if (isnull(antag_flag))
			continue

		var/days_needed = parent?.get_remaining_days(
			GLOB.special_roles[antag_flag_override || antag_flag]
		)

		if (days_needed > 0)
			antag_days_left[antag_flag] = days_needed

	return antag_days_left
