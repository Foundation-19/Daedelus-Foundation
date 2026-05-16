/datum/persistent_class
	var/class_id = "default"
	var/class_name = "Default Class"
	var/class_description = "A basic class"
	var/required_rank = 0
	var/max_rank = 6
	var/list/allowed_factions = list("foundation")
	var/list/class_abilities = list()
	var/list/class_equipment = list()
	var/list/alt_titles = list()
	var/icon_state = "default"
	var/color = "#FFFFFF"
	var/experience_multiplier = 1.0

/datum/persistent_class/security
	class_id = "security"
	class_name = "Security Specialist"
	class_description = "Combat-focused class with weapon proficiency and tactical training."
	allowed_factions = list("foundation", "uiu")
	experience_multiplier = 1.2
	color = "#FF4444"
	icon_state = "security"

	alt_titles = list(
		"recruit" = "Security Recruit",
		"officer" = "Security Officer",
		"sergeant" = "Security Sergeant",
		"lieutenant" = "Security Lieutenant",
		"captain" = "Security Captain",
		"commander" = "Security Commander",
		"director" = "Director of Security"
	)

/datum/persistent_class/research
	class_id = "research"
	class_name = "Research Analyst"
	class_description = "Science-focused class with SCP research and analysis capabilities."
	allowed_factions = list("foundation", "goc", "serpents_hand")
	experience_multiplier = 1.1
	color = "#4444FF"
	icon_state = "research"

	alt_titles = list(
		"assistant" = "Research Assistant",
		"scientist" = "Research Scientist",
		"senior_scientist" = "Senior Research Scientist",
		"lead_researcher" = "Lead Researcher",
		"research_director" = "Research Director",
		"chief_scientist" = "Chief Scientist",
		"head_of_research" = "Head of Research"
	)

/datum/persistent_class/medical
	class_id = "medical"
	class_name = "Medical Practitioner"
	class_description = "Medical-focused class with healing and medical expertise."
	allowed_factions = list("foundation", "uiu")
	experience_multiplier = 1.1
	color = "#44FF44"
	icon_state = "medical"

	alt_titles = list(
		"intern" = "Medical Intern",
		"nurse" = "Medical Nurse",
		"doctor" = "Medical Doctor",
		"surgeon" = "Surgeon",
		"chief_physician" = "Chief Physician",
		"medical_director" = "Medical Director",
		"chief_medical_officer" = "Chief Medical Officer"
	)

/datum/persistent_class/engineering
	class_id = "engineering"
	class_name = "Engineering Technician"
	class_description = "Engineering-focused class with construction and maintenance skills."
	allowed_factions = list("foundation", "uiu")
	experience_multiplier = 1.0
	color = "#FFAA44"
	icon_state = "engineering"

	alt_titles = list(
		"apprentice" = "Engineering Apprentice",
		"technician" = "Engineering Technician",
		"engineer" = "Engineer",
		"senior_engineer" = "Senior Engineer",
		"chief_engineer" = "Chief Engineer",
		"engineering_director" = "Engineering Director",
		"head_of_engineering" = "Head of Engineering"
	)

/datum/persistent_class/administrative
	class_id = "administrative"
	class_name = "Administrative Officer"
	class_description = "Leadership-focused class with coordination and management abilities."
	allowed_factions = list("foundation", "uiu", "mcd")
	experience_multiplier = 1.3
	color = "#AA44FF"
	icon_state = "administrative"

	alt_titles = list(
		"clerk" = "Administrative Clerk",
		"assistant" = "Administrative Assistant",
		"supervisor" = "Administrative Supervisor",
		"manager" = "Administrative Manager",
		"director" = "Administrative Director",
		"deputy_site_director" = "Deputy Site Director",
		"site_director" = "Site Director"
	)

/datum/persistent_class/containment
	class_id = "containment"
	class_name = "Containment Specialist"
	class_description = "SCP-focused class with specialized containment knowledge."
	allowed_factions = list("foundation")
	experience_multiplier = 1.4
	color = "#FF44AA"
	icon_state = "containment"

	alt_titles = list(
		"trainee" = "Containment Trainee",
		"specialist" = "Containment Specialist",
		"senior_specialist" = "Senior Containment Specialist",
		"containment_officer" = "Containment Officer",
		"containment_director" = "Containment Director",
		"chief_containment" = "Chief Containment Officer",
		"head_of_containment" = "Head of Containment"
	)

/datum/persistent_class/proc/get_rank_requirement(rank_level)
	// Use a switch statement instead of list access to avoid bounds issues
	switch(rank_level)
		if(0)
			return 0      // Recruit/Assistant/etc
		if(1)
			return 500    // Officer/Scientist/etc
		if(2)
			return 1500   // Sergeant/Senior/etc
		if(3)
			return 3000   // Lieutenant/Lead/etc
		if(4)
			return 6000   // Captain/Director/etc
		if(5)
			return 10000  // Commander/Chief/etc
		if(6)
			return 15000  // Director/Head/etc
		else
			// Out of bounds - return max rank requirement
			return 15000  // Director/Head/etc

/datum/persistent_class/proc/get_rank_name(rank_level)
	// Bounds checking to prevent runtime errors
	if(rank_level < 0 || rank_level > max_rank)
		return "Unknown Rank"

	var/list/rank_keys = alt_titles
	var/current_index = 1
	for(var/rank_key in rank_keys)
		if(current_index == rank_level + 1)
			return alt_titles[rank_key]
		current_index++
	return "Unknown Rank"

/datum/persistent_class/proc/get_rank_color(rank_level)
	// Use a switch statement instead of list access to avoid bounds issues
	switch(rank_level)
		if(0)
			return "#808080" // Gray
		if(1)
			return "#0066CC" // Blue
		if(2)
			return "#0066CC" // Blue
		if(3)
			return "#0066CC" // Blue
		if(4)
			return "#0066CC" // Blue
		if(5)
			return "#0066CC" // Blue
		if(6)
			return "#FF6600" // Orange
		else
			// Out of bounds - return max rank color
			return "#FF6600" // Orange

/datum/persistent_class/proc/export_to_json()
	var/list/data = list()
	data["class_id"] = class_id
	data["class_name"] = class_name
	data["class_description"] = class_description
	data["required_rank"] = required_rank
	data["max_rank"] = max_rank
	data["allowed_factions"] = allowed_factions
	data["class_abilities"] = class_abilities
	data["class_equipment"] = class_equipment
	data["alt_titles"] = alt_titles
	data["icon_state"] = icon_state
	data["color"] = color
	data["experience_multiplier"] = experience_multiplier
	return json_encode(data)
