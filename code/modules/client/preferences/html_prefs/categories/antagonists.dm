/datum/preference_group/category/antagonists
	name = "SCPs & Hostile Groups"
	priority = 30

	modules = list(
		/datum/preference_group/scp_antagonists
	)

/datum/preference_group/category/antagonists/get_content(datum/preferences/prefs)
	. = ..()
	for(var/datum/preference_group/module as anything in modules)
		. += module.get_content(prefs)

/datum/preference_group/scp_antagonists

/datum/preference_group/scp_antagonists/get_content(datum/preferences/prefs)
	. = ..()
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block;min-width:50%;max-width:50%;margin-left: auto;margin-right: auto'>
		<legend class='computerLegend tooltip'>
			<b>SCPs & Hostile Groups</b>
			<span class='tooltiptext'>Choose which SCPs and hostile groups you can play as. Access is controlled by admins.</span>
		</legend>
		<div style='text-align: center'>
			[button_element(prefs, "Select All Available", "pref_act=[/datum/preference/blob/antagonists];select_all_available=1")]
			[button_element(prefs, "Deselect All", "pref_act=[/datum/preference/blob/antagonists];deselect_all=1")]
		</div>
	<div class='flexColumn' style='height: 560px;display: block;overflow-y: scroll'>
	"}

	// Get SCP management data to check access
	var/list/available_roles = get_available_scp_roles(prefs.parent.ckey)
	var/list/client_antags = sort_list(prefs.read_preference(/datum/preference/blob/antagonists))

	var/i = 0
	var/background_color = "#7c5500"
	for(var/antagonist in client_antags)
		// Only show SCP and hostile group roles
		if(!is_scp_or_hostile_role(antagonist))
			continue

		i++
		background_color = i %% 2 ? "#7c5500" : "#533200"



		. += {"
		<div class='flexRow' style='justify-content: space-between; background-color:[background_color]'>
			<div style='padding-left: 0.5em;padding-right: 0.5em'>
				<span class='computerText'>[antagonist]</span>
				[(antagonist in available_roles) ? "<span style='color: green; font-size: 10px;'> (Available)</span>" : "<span style='color: red; font-size: 10px;'> (Restricted)</span>"]
			</div>
			<div>
				[button_element(prefs, client_antags[antagonist] ? "ENABLED" : "DISABLED", "pref_act=[/datum/preference/blob/antagonists];toggle_antag=[antagonist]", style = "margin-right: 0.5em")]
			</div>
		</div>
		"}
	. += "</div></fieldset>"

/datum/preference_group/scp_antagonists/proc/get_available_scp_roles(ckey)
	var/list/available_roles = list()

	// Check SCP management system for player access
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_persistence_manager/manager = SSscp_persistence.manager

		// Get player permissions from the performance system
		available_roles = manager.get_player_available_scps(ckey)

	return available_roles

/datum/preference_group/scp_antagonists/proc/is_scp_or_hostile_role(role)
	// Check if the role is an SCP or hostile group role
	var/list/scp_roles = get_all_playable_scp_roles()
	scp_roles += list(
		ROLE_SARKIC_CULT,
		ROLE_CHAOS_INSURGENCY,
		ROLE_SERPENTS_HAND
	)

	return (role in scp_roles)

/datum/preference_group/scp_antagonists/proc/get_all_playable_scp_roles()
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
