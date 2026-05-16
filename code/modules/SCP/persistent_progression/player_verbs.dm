// General version for any living mob
/mob/living/proc/show_persistent_progress()
	set name = "Show Persistent Progress"
	set category = "IC"

	if(!mind || !mind.persistent_data)
		to_chat(src, span_warning("No persistent data found."))
		return

	var/datum/persistent_progression_ui/ui = new(src)
	ui.ui_interact(src, null)

/mob/living/carbon/human/proc/change_persistent_class()
	set name = "Change Class"
	set category = "IC"

	if(!mind || !mind.persistent_data)
		to_chat(src, span_warning("No persistent data found."))
		return

	var/datum/persistent_faction/faction = mind.get_current_faction()
	if(!faction)
		to_chat(src, span_warning("No faction found."))
		return

	var/list/available_classes = list()
	for(var/class_id in faction.faction_classes)
		var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
		if(class)
			available_classes["[class.class_name] - [class.class_description]"] = class_id

	if(length(available_classes) == 0)
		to_chat(src, span_warning("No classes available for your faction."))
		return

	var/selected_class = input("Select a new class", "Change Class") as null|anything in available_classes
	if(!selected_class)
		return

	var/class_id = available_classes[selected_class]
	var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)

	var/confirm = alert("Are you sure you want to change your class to [class.class_name]? Your rank will be reset to 0.", "Confirm Class Change", "Yes", "No")
	if(confirm != "Yes")
		return

	if(mind.change_class(class_id))
		to_chat(src, span_notice("Successfully changed your class to [class.class_name]!"))
	else
		to_chat(src, span_warning("Failed to change class."))

/mob/living/carbon/human/proc/change_persistent_faction()
	set name = "Change Faction"
	set category = "IC"

	if(!mind || !mind.persistent_data)
		to_chat(src, span_warning("No persistent data found."))
		return

	var/list/available_factions = list()
	for(var/faction_id in SSpersistent_progression.factions)
		var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
		if(faction && (mind.persistent_data.current_class_id in faction.faction_classes))
			available_factions["[faction.faction_name] - [faction.faction_description]"] = faction_id

	if(length(available_factions) == 0)
		to_chat(src, span_warning("No factions available for your class."))
		return

	var/selected_faction = input("Select a new faction", "Change Faction") as null|anything in available_factions
	if(!selected_faction)
		return

	var/faction_id = available_factions[selected_faction]
	var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)

	var/confirm = alert("Are you sure you want to change your faction to [faction.faction_name]?", "Confirm Faction Change", "Yes", "No")
	if(confirm != "Yes")
		return

	if(mind.change_faction(faction_id))
		to_chat(src, span_notice("Successfully changed your faction to [faction.faction_name]!"))
	else
		to_chat(src, span_warning("Failed to change faction."))

/mob/living/carbon/human/proc/show_available_classes()
	set name = "Show Available Classes"
	set category = "IC"

	var/datum/persistent_progression_classes_ui/ui = new()
	ui.ui_interact(src, null)

/mob/living/carbon/human/proc/show_available_factions()
	set name = "Show Available Factions"
	set category = "IC"

	var/datum/persistent_progression_factions_ui/ui = new()
	ui.ui_interact(src, null)

// Debug verb to check persistent data status
/mob/living/proc/debug_persistent_data()
	set name = "Debug Persistent Data"
	set category = "IC"

	if(!mind)
		to_chat(src, span_warning("No mind found."))
		return

	// Check if subsystem is available
	if(!SSpersistent_progression)
		to_chat(src, span_warning("Persistent Progression subsystem not found!"))
		return

	to_chat(src, span_notice("Subsystem found. Classes: [length(SSpersistent_progression.classes)], Factions: [length(SSpersistent_progression.factions)]"))

	if(!mind.persistent_data)
		to_chat(src, span_warning("No persistent data found. Initializing..."))
		mind.initialize_persistent_data()
		if(mind.persistent_data)
			to_chat(src, span_notice("Persistent data initialized successfully!"))
		else
			to_chat(src, span_warning("Failed to initialize persistent data."))
		return

	to_chat(src, span_notice("Persistent data found:"))
	to_chat(src, span_notice("Class: [mind.persistent_data.current_class_id]"))
	to_chat(src, span_notice("Faction: [mind.persistent_data.current_faction_id]"))
	to_chat(src, span_notice("Rank: [mind.persistent_data.current_rank_name]"))
	to_chat(src, span_notice("Experience: [mind.persistent_data.total_experience]"))
