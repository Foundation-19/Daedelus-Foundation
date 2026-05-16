// Roleplay Character Development System
// Extends existing mind and personnel systems with deep roleplay features

SUBSYSTEM_DEF(roleplay_character)
	name = "Roleplay Character"
	wait = 300 // 5 minutes
	priority = FIRE_PRIORITY_ROLEPLAY
	init_order = INIT_ORDER_ROLEPLAY
	var/datum/roleplay_character_manager/manager

/datum/controller/subsystem/roleplay_character/Initialize()
	manager = new /datum/roleplay_character_manager()
	world.log << "Roleplay Character Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/roleplay_character/fire()
	if(manager)
		manager.process_roleplay_characters()

// Roleplay Character Manager
/datum/roleplay_character_manager
	var/list/character_sheets = list() // ckey -> roleplay_character_sheet
	var/list/character_relationships = list() // relationship_id -> relationship_data
	var/list/character_development = list() // development_id -> development_data
	var/list/personality_traits = list() // trait_id -> trait_data
	var/list/character_goals = list() // goal_id -> goal_data
	var/list/character_achievements = list() // achievement_id -> achievement_data

	// Character development metrics
	var/total_characters_created = 0
	var/active_characters = 0
	var/average_character_depth = 0
	var/character_interaction_count = 0
	var/relationship_network_size = 0

/datum/roleplay_character_manager/New()
	. = ..()
	initialize_personality_traits()
	initialize_character_goals()
	initialize_achievements()

/datum/roleplay_character_manager/proc/process_roleplay_characters()
	// Process character development
	for(var/ckey in character_sheets)
		var/datum/roleplay_character_sheet/character = character_sheets[ckey]
		if(character)
			character.process_character_development()

	// Update metrics
	update_character_metrics()

	// Process relationships
	process_character_relationships()

// Roleplay Character Sheet
/datum/roleplay_character_sheet
	var/ckey = ""
	var/character_name = ""
	var/character_type = "" // "foundation", "scp", "dclass", "visitor"
	var/character_background = ""
	var/personality_traits = list()
	var/character_goals = list()
	var/character_relationships = list()
	var/character_achievements = list()
	var/character_development_log = list()
	var/character_creation_date = 0
	var/character_last_updated = 0

	// Integration with existing systems
	var/datum/mind/linked_mind
	var/datum/personnel_record/linked_personnel_record

	// Character appearance and style
	var/datum/roleplay_appearance/appearance
	var/datum/roleplay_personality/personality
	var/datum/roleplay_character_growth/growth
	var/datum/roleplay_character_skills/skills

/datum/roleplay_character_sheet/New(var/ckey, var/name, var/type)
	src.ckey = ckey
	src.character_name = name
	src.character_type = type
	src.character_creation_date = world.time
	src.character_last_updated = world.time

	// Initialize subsystems
	appearance = new /datum/roleplay_appearance()
	personality = new /datum/roleplay_personality()
	growth = new /datum/roleplay_character_growth()
	skills = new /datum/roleplay_character_skills()

	// Link to existing systems
	link_to_existing_systems()

/datum/roleplay_character_sheet/proc/link_to_existing_systems()
	// Link to mind system
	for(var/client/C in GLOB.clients)
		if(C.ckey == ckey)
			linked_mind = C.mob?.mind
			break

	// Link to personnel record if available
	if(SSpersonnel_persistence && SSpersonnel_persistence.manager)
		linked_personnel_record = SSpersonnel_persistence.manager.personnel_records[ckey]

/datum/roleplay_character_sheet/proc/process_character_development()
	// Update character development based on recent activities
	if(linked_mind)
		// Track skill development
		skills.update_skills_from_mind(linked_mind)

		// Track personality development
		personality.update_personality_from_activities(linked_mind)

		// Track growth milestones
		growth.check_growth_milestones(linked_mind)

	character_last_updated = world.time

// Roleplay Appearance System
/datum/roleplay_appearance
	var/face_details = list()
	var/body_details = list()
	var/clothing_preferences = list()
	var/accessories = list()
	var/unique_features = list()
	var/appearance_notes = ""
	var/character_style = ""
	var/character_quirks = list()

/datum/roleplay_appearance/proc/set_face_detail(detail_type, value)
	face_details[detail_type] = value

/datum/roleplay_appearance/proc/set_body_detail(detail_type, value)
	body_details[detail_type] = value

/datum/roleplay_appearance/proc/add_clothing_preference(preference_type, description)
	clothing_preferences[preference_type] = description

/datum/roleplay_appearance/proc/add_unique_feature(feature_type, description)
	unique_features[feature_type] = description

// Roleplay Personality System
/datum/roleplay_personality
	var/traits = list()
	var/quirks = list()
	var/fears = list()
	var/aspirations = list()
	var/communication_style = ""
	var/decision_making_style = ""
	var/social_preferences = list()
	var/emotional_tendencies = list()

/datum/roleplay_personality/proc/add_trait(trait_name, strength = 1)
	traits[trait_name] = strength

/datum/roleplay_personality/proc/add_quirk(quirk_name, description)
	quirks[quirk_name] = description

/datum/roleplay_personality/proc/add_fear(fear_name, intensity = 1)
	fears[fear_name] = intensity

/datum/roleplay_personality/proc/add_aspiration(aspiration_name, priority = 1)
	aspirations[aspiration_name] = priority

/datum/roleplay_personality/proc/update_personality_from_activities(datum/mind/mind)
	// Update personality based on recent activities
	if(!mind || !mind.current)
		return

	// Analyze recent actions and update personality accordingly
	// This would integrate with the existing skill and activity systems

// Roleplay Character Growth System
/datum/roleplay_character_growth
	var/roleplay_experience_points = 0
	var/character_level = 1
	var/growth_milestones = list()
	var/development_goals = list()
	var/character_arcs = list()
	var/legacy_impacts = list()
	var/character_evolution = list()
	var/personal_growth_areas = list()

/datum/roleplay_character_growth/proc/add_experience(amount, reason = "Unknown")
	roleplay_experience_points += amount

	// Check for level up
	var/required_exp = character_level * 100
	if(roleplay_experience_points >= required_exp)
		level_up()

/datum/roleplay_character_growth/proc/level_up()
	character_level++

	// Add milestone
	var/milestone = list(
		"type" = "level_up",
		"level" = character_level,
		"timestamp" = world.time,
		"description" = "Reached character level [character_level]"
	)
	growth_milestones += milestone

	// Notify player if online
	// Note: This will be implemented when character reference is available
	// for(var/client/C in GLOB.clients)
	// 	if(C.ckey == character.ckey)
	// 		to_chat(C, "<span class='notice'>Your character has reached level [character_level]!</span>")
	// 		break

/datum/roleplay_character_growth/proc/check_growth_milestones(datum/mind/mind)
	// Check for various growth milestones based on character activities
	if(!mind || !mind.current)
		return

	// Example milestones:
	// - First SCP interaction
	// - First research project
	// - First containment breach
	// - First character relationship
	// - First achievement

// Roleplay Character Skills System
/datum/roleplay_character_skills
	var/roleplay_skills = list()
	var/social_skills = list()
	var/knowledge_skills = list()
	var/specialization_skills = list()
	var/skill_experience = list()
	var/skill_milestones = list()
	var/character_specializations = list()

/datum/roleplay_character_skills/proc/update_skills_from_mind(datum/mind/mind)
	if(!mind)
		return

	// Update skills based on mind's known_skills
	for(var/skill_type in mind.known_skills)
		var/skill_data = mind.known_skills[skill_type]
		var/skill_level = skill_data[SKILL_LVL]
		var/skill_exp = skill_data[SKILL_EXP]

		// Map existing skills to roleplay skills
		map_skill_to_roleplay_skill(skill_type, skill_level, skill_exp)

/datum/roleplay_character_skills/proc/map_skill_to_roleplay_skill(skill_type, level, exp)
	// Map existing skills to roleplay skill categories
	switch(skill_type)
		if(/datum/skill/research)
			knowledge_skills["foundation_lore"] = level
			knowledge_skills["scp_knowledge"] = level
		if(/datum/skill/combat)
			roleplay_skills["combat_roleplay"] = level
		if(/datum/skill/engineering)
			knowledge_skills["technical_expertise"] = level
		if(/datum/skill/chemistry)
			knowledge_skills["medical_knowledge"] = level
		if(/datum/skill/security)
			roleplay_skills["security_roleplay"] = level

// Character Relationship Network
/datum/roleplay_relationship_network
	var/relationships = list()
	var/relationship_strength = list()
	var/relationship_type = list()
	var/relationship_history = list()
	var/trust_levels = list()
	var/conflict_history = list()
	var/alliance_networks = list()
	var/rivalry_networks = list()

/datum/roleplay_relationship_network/proc/add_relationship(character1_ckey, character2_ckey, relationship_type, initial_strength = 1)
	var/relationship_id = "[character1_ckey]_[character2_ckey]"

	relationships[relationship_id] = list(
		"character1" = character1_ckey,
		"character2" = character2_ckey,
		"type" = relationship_type,
		"strength" = initial_strength,
		"trust" = 50,
		"created" = world.time,
		"history" = list()
	)

	relationship_strength[relationship_id] = initial_strength
	relationship_type[relationship_id] = relationship_type
	trust_levels[relationship_id] = 50

/datum/roleplay_relationship_network/proc/update_relationship(relationship_id, interaction_type, impact)
	if(!relationships[relationship_id])
		return

	var/relationship = relationships[relationship_id]

	// Update relationship strength
	relationship["strength"] = max(0, min(100, relationship["strength"] + impact))
	relationship_strength[relationship_id] = relationship["strength"]

	// Add to history
	var/history_entry = list(
		"timestamp" = world.time,
		"interaction" = interaction_type,
		"impact" = impact
	)
	relationship["history"] += history_entry
	relationship_history[relationship_id] = relationship["history"]

// Character Manager Procs
/datum/roleplay_character_manager/proc/create_character(ckey, name, character_type)
	if(character_sheets[ckey])
		return character_sheets[ckey] // Already exists

	var/datum/roleplay_character_sheet/new_character = new /datum/roleplay_character_sheet(ckey, name, character_type)
	character_sheets[ckey] = new_character
	total_characters_created++

	world.log << "Roleplay Character: Created character [name] ([character_type]) for [ckey]"
	return new_character

/datum/roleplay_character_manager/proc/get_character(ckey)
	return character_sheets[ckey]

/datum/roleplay_character_manager/proc/update_character(ckey, updates)
	var/datum/roleplay_character_sheet/character = character_sheets[ckey]
	if(!character)
		return FALSE

	for(var/field in updates)
		character.vars[field] = updates[field]

	character.character_last_updated = world.time
	return TRUE

/datum/roleplay_character_manager/proc/process_character_relationships()
	// Process relationship updates and conflicts
	for(var/relationship_id in character_relationships)
		var/datum/relationship = character_relationships[relationship_id]
		if(relationship)
			continue

/datum/roleplay_character_manager/proc/update_character_metrics()
	active_characters = length(character_sheets)

	// Calculate average character depth
	var/total_depth = 0
	for(var/ckey in character_sheets)
		var/datum/roleplay_character_sheet/character = character_sheets[ckey]
		if(character)
			total_depth += character.growth?.character_level || 1

	if(active_characters > 0)
		average_character_depth = total_depth / active_characters

// Initialize personality traits
/datum/roleplay_character_manager/proc/initialize_personality_traits()
	personality_traits = list(
		"ambitious" = "Driven to achieve goals and advance",
		"analytical" = "Thinks logically and systematically",
		"compassionate" = "Cares deeply about others",
		"curious" = "Eager to learn and explore",
		"disciplined" = "Maintains strict self-control",
		"empathic" = "Understands others' emotions",
		"fearless" = "Shows little fear in dangerous situations",
		"friendly" = "Warm and approachable to others",
		"honest" = "Always tells the truth",
		"imaginative" = "Creative and innovative thinking",
		"independent" = "Prefers to work alone",
		"intelligent" = "Quick to learn and understand",
		"loyal" = "Faithful to friends and causes",
		"mysterious" = "Keeps secrets and maintains mystery",
		"optimistic" = "Sees the positive in situations",
		"pragmatic" = "Practical and realistic approach",
		"protective" = "Defends others from harm",
		"reserved" = "Quiet and keeps to self",
		"resourceful" = "Finds creative solutions to problems",
		"responsible" = "Takes ownership of actions"
	)

// Initialize character goals
/datum/roleplay_character_manager/proc/initialize_character_goals()
	character_goals = list(
		"advance_career" = "Rise through Foundation ranks",
		"research_scp" = "Study and understand SCPs",
		"protect_foundation" = "Defend Foundation interests",
		"escape_facility" = "Break free from containment",
		"cause_chaos" = "Create disorder and destruction",
		"find_truth" = "Discover hidden knowledge",
		"help_others" = "Assist and protect people",
		"gain_power" = "Acquire influence and authority",
		"maintain_secrets" = "Keep information hidden",
		"survive" = "Stay alive at all costs"
	)

// Initialize achievements
/datum/roleplay_character_manager/proc/initialize_achievements()
	character_achievements = list(
		"first_interaction" = "First meaningful character interaction",
		"relationship_formed" = "Formed first character relationship",
		"story_created" = "Created first collaborative story",
		"milestone_reached" = "Reached character development milestone",
		"community_contribution" = "Made significant community contribution",
		"roleplay_mastery" = "Demonstrated exceptional roleplay skills",
		"character_depth" = "Developed deep character complexity",
		"storytelling_excellence" = "Created compelling narratives",
		"leadership_demonstrated" = "Showed natural leadership abilities",
		"immersion_achieved" = "Achieved deep roleplay immersion"
	)
