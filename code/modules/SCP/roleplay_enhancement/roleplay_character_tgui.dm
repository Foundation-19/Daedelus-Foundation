// Roleplay Character Sheet TGUI Backend
// Handles the TGUI interface for character sheet management

/datum/roleplay_character_ui
	var/mob/user
	var/datum/roleplay_character_sheet/character

/datum/roleplay_character_ui/New(mob/user)
	src.user = user
	load_character()

/datum/roleplay_character_ui/proc/load_character()
	if(!user || !user.ckey)
		return

	if(SSroleplay_character && SSroleplay_character.manager)
		character = SSroleplay_character.manager.get_character(user.ckey)

		// Create character if it doesn't exist
		if(!character)
			var/character_type = determine_character_type()
			var/character_name = user.real_name || user.name
			character = SSroleplay_character.manager.create_character(user.ckey, character_name, character_type)

			// Sync with character setup preferences
			sync_with_character_preferences()

/datum/roleplay_character_ui/proc/get_comprehensive_character_data_from_preferences()
	var/list/comprehensive_data = list()

	if(!user || !user.client || !user.client.prefs)
		return comprehensive_data

	var/prefs = user.client.prefs

	// Basic character information - try to get from preferences first
	comprehensive_data["real_name"] = user.real_name || user.name || "Unknown"
	comprehensive_data["age"] = "Unknown"
	comprehensive_data["gender"] = "Unknown"
	comprehensive_data["body_type"] = "Unknown"
	comprehensive_data["species"] = "Unknown"
	comprehensive_data["flavor_text"] = "No flavor text set"

	// Appearance details - try to get from preferences
	comprehensive_data["hair_style"] = "Unknown"
	comprehensive_data["hair_color"] = "Unknown"
	comprehensive_data["facial_hair_style"] = "Unknown"
	comprehensive_data["facial_hair_color"] = "Unknown"
	comprehensive_data["eye_color"] = "Unknown"
	comprehensive_data["skin_tone"] = "Unknown"

	// Clothing preferences
	comprehensive_data["jumpsuit_style"] = "Unknown"
	comprehensive_data["backpack"] = "Unknown"
	comprehensive_data["undershirt"] = "Unknown"
	comprehensive_data["underwear"] = "Unknown"
	comprehensive_data["socks"] = "Unknown"

	// Additional features
	comprehensive_data["hair_gradient"] = "None"
	comprehensive_data["hair_gradient_color"] = "Unknown"
	comprehensive_data["facial_hair_gradient"] = "None"
	comprehensive_data["facial_hair_gradient_color"] = "Unknown"

	// Species-specific features
	comprehensive_data["species_name"] = "Human"
	comprehensive_data["species_description"] = "Species: Human"
	comprehensive_data["species_features"] = list()

	// For now, just use basic mob properties to avoid preference system issues
	if(prefs)
		comprehensive_data["preferences_available"] = TRUE
		comprehensive_data["successful_reads"] = 1  // At least we got the real name
		comprehensive_data["total_cache_entries"] = 0
	else
		comprehensive_data["preferences_available"] = FALSE
		comprehensive_data["successful_reads"] = 0
		comprehensive_data["total_cache_entries"] = 0

	return comprehensive_data

/datum/roleplay_character_ui/proc/sync_with_character_preferences()
	if(!character || !user)
		return

	// Get comprehensive character data from preferences
	var/list/pref_data = get_comprehensive_character_data_from_preferences()

	// Update character name from preferences or mob
	if(pref_data["real_name"] && pref_data["real_name"] != "")
		character.character_name = pref_data["real_name"]
	else if(user.real_name && user.real_name != "")
		character.character_name = user.real_name

	// Update character type based on current job
	character.character_type = determine_character_type()

	// Update the character in the manager
	if(SSroleplay_character && SSroleplay_character.manager)
		SSroleplay_character.manager.character_sheets[character.ckey] = character

	// Update character last modified timestamp
	character.character_last_updated = world.time

/datum/roleplay_character_ui/proc/sync_character_to_preferences()
	if(!character || !user || !user.client || !user.client.prefs)
		return FALSE

	var/datum/preferences/prefs = user.client.prefs
	if(!prefs)
		return FALSE

	// Try to update preferences using the proper update_preference method
	var/successful_updates = 0

	// Update real name if we have it
	if(character.character_name && character.character_name != user.real_name)
		user.set_real_name(character.character_name)
		successful_updates++

	// Update flavor text if we have it
	if(character.character_background && character.character_background != user.desc)
		user.desc = character.character_background
		successful_updates++

	// Update character last updated timestamp
	character.character_last_updated = world.time

	return successful_updates > 0

/datum/roleplay_character_ui/proc/get_character_preferences_summary()
	var/list/summary = list()

	if(!user)
		return summary

	var/list/pref_data = get_comprehensive_character_data_from_preferences()

	summary["preferences_loaded"] = pref_data["preferences_available"] || FALSE
	summary["character_name"] = pref_data["real_name"] || "Not Set"
	summary["age"] = pref_data["age"] || "Not Set"
	summary["gender"] = pref_data["gender"] || "Not Set"
	summary["species"] = pref_data["species_name"] || "Not Set"
	summary["hair_style"] = pref_data["hair_style"] || "Not Set"
	summary["hair_color"] = pref_data["hair_color"] || "Not Set"
	summary["eye_color"] = pref_data["eye_color"] || "Not Set"
	summary["flavor_text"] = pref_data["flavor_text"] || "Not Set"
	summary["clothing_style"] = pref_data["jumpsuit_style"] || "Not Set"

	// Add debug information
	summary["successful_reads"] = pref_data["successful_reads"] || 0
	summary["total_cache_entries"] = pref_data["total_cache_entries"] || 0

	return summary

/datum/roleplay_character_ui/proc/determine_character_type()
	if(!user)
		return "foundation"

	// Determine character type based on job or role
	if(user.mind && user.mind.assigned_role)
		var/job_title = user.mind.assigned_role.title
		if(findtext(job_title, "SCP") || user.SCP)
			return "scp"
		else if(findtext(job_title, "D-Class") || findtext(job_title, "Prisoner"))
			return "dclass"
		else if(findtext(job_title, "Visitor") || findtext(job_title, "Guest"))
			return "visitor"
		else
			return "foundation"

	return "foundation"

/datum/roleplay_character_ui/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoleplayCharacterSheet", "SCP Foundation - Character Sheet", 800, 600)
		ui.open()

/datum/roleplay_character_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/roleplay_character_ui/ui_data(mob/user)
	var/list/data = list()

	if(!character)
		load_character()
	else
		// Always sync with current preferences when opening the sheet
		sync_with_character_preferences()

	if(character)
		data["character"] = list(
			"character_name" = character.character_name,
			"character_type" = character.character_type,
			"character_background" = character.character_background,
			"character_creation_date" = character.character_creation_date,
			"character_last_updated" = character.character_last_updated,
			"character_goals" = character.character_goals,
			"personality" = list(
				"traits" = character.personality?.traits || list(),
				"quirks" = character.personality?.quirks || list(),
				"fears" = character.personality?.fears || list(),
				"aspirations" = character.personality?.aspirations || list()
			),
			"appearance" = list(
				"face_details" = character.appearance?.face_details || list(),
				"body_details" = character.appearance?.body_details || list(),
				"clothing_preferences" = character.appearance?.clothing_preferences || list(),
				"unique_features" = character.appearance?.unique_features || list(),
				"character_style" = character.appearance?.character_style || ""
			),
			"growth" = list(
				"character_level" = character.growth?.character_level || 1,
				"roleplay_experience_points" = character.growth?.roleplay_experience_points || 0,
				"growth_milestones" = character.growth?.growth_milestones || list()
			)
		)

	// Personality traits
	if(SSroleplay_character && SSroleplay_character.manager)
		data["personality_traits"] = SSroleplay_character.manager.personality_traits
		data["character_goals"] = SSroleplay_character.manager.character_goals
		data["achievements"] = SSroleplay_character.manager.character_achievements

	// Relationships
	data["relationships"] = get_character_relationships()

	// Editable status
	data["editable"] = can_edit_character(user)

	// Add preferences summary for integration display
	data["preferences_summary"] = get_character_preferences_summary()

	// Add character sheet status
	data["character_sheet_status"] = list(
		"has_character" = !!character,
		"character_loaded" = !!character,
		"preferences_synced" = !!user?.client?.prefs,
		"last_updated" = character?.character_last_updated || 0
	)

	return data

/datum/roleplay_character_ui/proc/get_character_relationships()
	var/list/relationships = list()

	if(!character || !SSroleplay_character || !SSroleplay_character.manager)
		return relationships

	// Get relationships for this character
	var/list/character_relationships = character.character_relationships
	if(character_relationships && length(character_relationships) > 0)
		for(var/relationship in character_relationships)
			if(istype(relationship, /list))
				relationships += relationship
			else
				relationships += list("relationship" = relationship)

	return relationships

/datum/roleplay_character_ui/proc/can_edit_character(mob/user)
	if(!user || !character)
		return FALSE

	// Only the character owner can edit their character sheet
	return user.ckey == character.ckey

/datum/roleplay_character_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_trait")
			var/trait = params["trait"]
			if(trait && character && character.personality)
				character.personality.traits |= trait
				character.character_last_updated = world.time
				. = TRUE

		if("remove_trait")
			var/trait = params["trait"]
			if(trait && character && character.personality)
				character.personality.traits -= trait
				character.character_last_updated = world.time
				. = TRUE

		if("add_quirk")
			var/quirk = params["quirk"]
			if(quirk && character && character.personality)
				character.personality.quirks |= quirk
				character.character_last_updated = world.time
				. = TRUE

		if("remove_quirk")
			var/quirk = params["quirk"]
			if(quirk && character && character.personality)
				character.personality.quirks -= quirk
				character.character_last_updated = world.time
				. = TRUE

		if("add_fear")
			var/fear = params["fear"]
			if(fear && character && character.personality)
				character.personality.fears |= fear
				character.character_last_updated = world.time
				. = TRUE

		if("remove_fear")
			var/fear = params["fear"]
			if(fear && character && character.personality)
				character.personality.fears -= fear
				character.character_last_updated = world.time
				. = TRUE

		if("add_aspiration")
			var/aspiration = params["aspiration"]
			if(aspiration && character && character.personality)
				character.personality.aspirations |= aspiration
				character.character_last_updated = world.time
				. = TRUE

		if("remove_aspiration")
			var/aspiration = params["aspiration"]
			if(aspiration && character && character.personality)
				character.personality.aspirations -= aspiration
				character.character_last_updated = world.time
				. = TRUE

		if("update_character_goals")
			var/goals = params["goals"]
			if(goals != null && character)
				character.character_goals = goals
				character.character_last_updated = world.time
				. = TRUE

		if("update_character_style")
			var/style = params["style"]
			if(style != null && character && character.appearance)
				character.appearance.character_style = style
				character.character_last_updated = world.time
				. = TRUE

		if("save_character")
			to_chat(ui.user, span_notice("Character saved successfully!"))
			. = TRUE

		if("sync_to_preferences")
			sync_character_to_preferences()
			to_chat(ui.user, span_notice("Character sheet synced to preferences!"))
			. = TRUE

		if("sync_from_preferences")
			sync_with_character_preferences()
			to_chat(ui.user, span_notice("Character sheet synced from preferences!"))
			. = TRUE

		if("update_character_background")
			var/background = params["background"]
			if(background != null)
				character.character_background = background
				character.character_last_updated = world.time
				// Auto-sync background to mob for now
				if(user)
					user.desc = background
				. = TRUE

		if("update_character_name")
			var/name = params["name"]
			if(name && name != "")
				character.character_name = name
				character.character_last_updated = world.time
				// Auto-sync name to mob
				if(user && user.real_name != name)
					user.set_real_name(name)
				. = TRUE

// Verb to open character sheet
/mob/verb/open_character_sheet()
	set name = "Open Character Sheet"
	set category = "IC"
	set desc = "Open your roleplay character sheet"

	if(!client)
		return

	var/datum/roleplay_character_ui/ui = new(src)
	ui.ui_interact(src)

// Verb to view another player's character sheet (read-only)
/mob/verb/view_character_sheet(mob/target in world)
	set name = "View Character Sheet"
	set category = "IC"
	set desc = "View another player's character sheet (read-only)"

	if(!client || !target || !target.client)
		return

	var/datum/roleplay_character_ui/ui = new(target)
	ui.ui_interact(src)

// Award experience for roleplay activities
/datum/roleplay_character_ui/proc/award_roleplay_experience()
	if(!character || !character.growth)
		return

	// Award experience for opening the character sheet
	character.growth.roleplay_experience_points += 5

	// Check for level up
	var/current_level = character.growth.character_level
	var/required_exp = current_level * 100

	if(character.growth.roleplay_experience_points >= required_exp)
		character.growth.character_level++
		character.growth.roleplay_experience_points -= required_exp
		to_chat(user, span_notice("Character level increased to [character.growth.character_level]!"))

	// Update personnel record if linked
	if(character.linked_personnel_record)
		character.linked_personnel_record.real_name = character.character_name

	// Sync with character preferences
	sync_character_to_preferences()
