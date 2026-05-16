/datum/preference_group/category/general
	name = "General"
	priority = 100

	modules = list(
		/datum/preference_group/body,
		/datum/preference_group/species,
		/datum/preference_group/job_specific,
		/datum/preference_group/appearance_mods,
		/datum/preference_group/meta,
		/datum/preference_group/quirks,
		/datum/preference_group/ipc_shackles,
	)

/datum/preference_group/category/general/get_content(datum/preferences/prefs)
	. = ..()

	// Computer-like interface with step-by-step process
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block; width: 100%; margin-bottom: 10px;'>
		<legend class='computerLegend'>
			<b>ENHANCED PERSONNEL FILE SYSTEM v2.1</b>
		</legend>
		<div style='text-align: center; margin: 10px;'>
			<span class='computerText'>Welcome to the Foundation Personnel Database</span><br>
			<span class='computerText'>Please complete all required fields for personnel registration</span>
		</div>
	</fieldset>
	"}

	// Profile Overview
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/S = new species_type
	var/species_name = S?.name || "Unknown"
	var/age_value = prefs.read_preference(/datum/preference/numeric/age)
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block; width: 100%; margin-bottom: 10px;'>
		<legend class='computerLegend'>
			<b>PROFILE OVERVIEW</b>
		</legend>
		<div style='text-align: center; margin: 10px;'>
			<span class='computerText'>Name: [prefs.read_preference(/datum/preference/name/real_name)]</span> ·
			<span class='computerText'>Species: [species_name]</span> ·
			<span class='computerText'>Age: [age_value]</span>
		</div>
	</fieldset>
	"}

	// Step 1: Faction Selection
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block; width: 100%; margin-bottom: 10px;'>
		<legend class='computerLegend'>
			<b>STEP 1: FACTION SELECTION</b>
		</legend>
		<div style='text-align: center; margin: 10px;'>
			<span class='computerText'>Select your primary organizational affiliation:</span><br><br>
	"}

	var/current_faction = prefs.read_preference(/datum/preference/choiced/faction)
	var/factions = list("foundation" = "SCP Foundation", "goc" = "Global Occult Coalition", "serpents_hand" = "Serpent's Hand", "chaos_insurgency" = "Chaos Insurgency", "mcd" = "Marshall, Carter & Dark", "uiu" = "Unusual Incidents Unit")

	for(var/faction_id in factions)
		var/faction_name = factions[faction_id]
		if(current_faction == faction_id)
			. += "<span class='linkOn'>[faction_name]</span> "
		else
			. += button_element(prefs, faction_name, "pref_act=/datum/preference/choiced/faction&new_value=[faction_id]") + " "

	. += "</div></fieldset>"

	// Step 2: Class Selection
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block; width: 100%; margin-bottom: 10px;'>
		<legend class='computerLegend'>
			<b>STEP 2: CLASS SELECTION</b>
		</legend>
		<div style='text-align: center; margin: 10px;'>
			<span class='computerText'>Select your primary specialization:</span><br><br>
	"}

	var/current_class = prefs.read_preference(/datum/preference/choiced/class)
	var/classes = list("administrative" = "Administrative", "security" = "Security", "research" = "Research", "medical" = "Medical", "engineering" = "Engineering", "intelligence" = "Intelligence")

	for(var/class_id in classes)
		var/class_name = classes[class_id]
		if(current_class == class_id)
			. += "<span class='linkOn'>[class_name]</span> "
		else
			. += button_element(prefs, class_name, "pref_act=/datum/preference/choiced/class&new_value=[class_id]") + " "

	. += "</div></fieldset>"

	// Step 3: Job Selection (based on faction and class)
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block; width: 100%; margin-bottom: 10px;'>
		<legend class='computerLegend'>
			<b>STEP 3: POSITION ASSIGNMENT</b>
		</legend>
		<div style='text-align: center; margin: 10px;'>
			<span class='computerText'>Available positions for [factions[current_faction]] - [classes[current_class]]:</span><br><br>
	"}

	// Get available jobs based on faction and class
	var/list/available_jobs = get_faction_class_jobs(current_faction, current_class)
	if(length(available_jobs))
		for(var/job_id in available_jobs)
			var/job_name = get_job_name(job_id)
			var/job_desc = get_job_description(job_name)
			. += {"<div style='margin-bottom:6px'>[button_element(prefs, job_name, "pref_act=[/datum/preference/blob/job_priority];set_job_high=[job_name]")]<br><span class='computerSubText'>[job_desc]</span></div>"}
	else
		. += "<span class='computerText'>No positions available for this combination.</span>"

	. += "</div></fieldset>"

	// Step 4: Character Customization
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block; width: 100%; margin-bottom: 10px;'>
		<legend class='computerLegend'>
			<b>STEP 4: PERSONNEL CUSTOMIZATION</b>
		</legend>
		<div style='text-align: center; margin: 10px;'>
			<span class='computerText'>Customize your personnel profile:</span><br><br>
	"}

	// Add existing modules for customization
	for(var/datum/preference_group/module as anything in modules)
		if(module.should_display(prefs))
			. += module.get_content(prefs)

	. += "</div></fieldset>"

	// Summary
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block; width: 100%; margin-bottom: 10px;'>
		<legend class='computerLegend'>
			<b>PERSONNEL SUMMARY</b>
		</legend>
		<div style='text-align: center; margin: 10px;'>
			<span class='computerText'>Faction: [factions[current_faction]]</span><br>
			<span class='computerText'>Class: [classes[current_class]]</span><br>
			<span class='computerText'>Name: [prefs.read_preference(/datum/preference/name/real_name)]</span><br>
			<span class='computerText'>Status: [current_faction && current_class ? "COMPLETE" : "INCOMPLETE"]</span>
		</div>
	</fieldset>
	"}

