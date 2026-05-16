// Skill Integration System
// Integrates the player progression system with the existing skill system

SUBSYSTEM_DEF(skill_integration)
	name = "Skill Integration"
	wait = 300 // 5 seconds
	priority = FIRE_PRIORITY_PERSISTENT_PROGRESSION
	init_order = INIT_ORDER_PERSISTENCE_PROGRESSION
	var/datum/skill_integration_manager/manager

/datum/controller/subsystem/skill_integration/Initialize()
	manager = new /datum/skill_integration_manager()
	world.log << "Skill Integration Subsystem: Initialized"
	return ..()

/datum/controller/subsystem/skill_integration/fire()
	if(manager)
		manager.process_skill_integration()

// Helper function to get skill name
/proc/get_skill_name(skill_type)
	if(!skill_type)
		return "Unknown Skill"
	var/datum/skill/skill_instance = new skill_type()
	var/skill_name = skill_instance.name
	qdel(skill_instance)
	return skill_name

// Skill Integration Manager
/datum/skill_integration_manager
	var/list/skill_mappings = list() // skill_type -> progression_class mapping
	var/list/progression_skill_boosts = list() // class_id -> skill_boosts
	var/list/skill_progression_rewards = list() // skill_level -> progression_rewards
	var/list/integration_cache = list() // ckey -> integration_data
	var/sync_interval = 600 // 10 minutes
	var/last_sync_time = 0
	var/list/research_milestones = list() // Track research milestones
	var/list/combat_milestones = list() // Track combat milestones
	var/list/engineering_milestones = list() // Track engineering milestones
	var/list/security_milestones = list() // Track security milestones

/datum/skill_integration_manager/New()
	initialize_skill_mappings()
	initialize_progression_boosts()
	initialize_skill_rewards()

/datum/skill_integration_manager/proc/initialize_skill_mappings()
	// Map existing skills to progression classes
	skill_mappings[/datum/skill/cleaning] = "service"
	skill_mappings[/datum/skill/gaming] = "service"
	skill_mappings[/datum/skill/combat] = "combat"
	skill_mappings[/datum/skill/containment] = "containment"
	skill_mappings[/datum/skill/chemistry] = "science"
	skill_mappings[/datum/skill/surgery] = "medical"
	skill_mappings[/datum/skill/research] = "science"
	skill_mappings[/datum/skill/engineering] = "engineering"
	skill_mappings[/datum/skill/security] = "security"

/datum/skill_integration_manager/proc/initialize_progression_boosts()
	// Define skill experience boosts based on progression class
	progression_skill_boosts["service"] = list(
		/datum/skill/cleaning = 1.5,
		/datum/skill/gaming = 1.3
	)
	progression_skill_boosts["combat"] = list(
		/datum/skill/combat = 1.4
	)
	progression_skill_boosts["containment"] = list(
		/datum/skill/containment = 1.6
	)
	progression_skill_boosts["science"] = list(
		/datum/skill/chemistry = 1.5,
		/datum/skill/research = 1.5
	)
	progression_skill_boosts["medical"] = list(
		/datum/skill/surgery = 1.5
	)
	progression_skill_boosts["engineering"] = list(
		/datum/skill/engineering = 1.5
	)
	progression_skill_boosts["security"] = list(
		/datum/skill/security = 1.5
	)

/datum/skill_integration_manager/proc/initialize_skill_rewards()
	skill_progression_rewards["expert"] = list(
		"min_level" = SKILL_LEVEL_EXPERT,
		"experience_bonus" = 100,
		"unlock_item" = "expert_certification",
		"title_unlock" = "Expert"
	)
	skill_progression_rewards["master"] = list(
		"min_level" = SKILL_LEVEL_MASTER,
		"experience_bonus" = 250,
		"unlock_item" = "master_certification",
		"title_unlock" = "Master",
		"rank_boost" = 1
	)

/datum/skill_integration_manager/proc/process_skill_integration()
	// Main processing loop for skill integration
	if(world.time - last_sync_time < sync_interval)
		return

	// Sync skill data with progression system
	sync_skill_progression_data()
	last_sync_time = world.time

/datum/skill_integration_manager/proc/sync_skill_progression_data()
	// Sync skill levels with progression system
	for(var/client/C in GLOB.clients)
		if(!C.mob || !C.mob.mind)
			continue

		var/datum/mind/mind = C.mob.mind
		var/ckey = C.ckey

		// Get or create integration data
		var/list/integration_data = get_integration_data(ckey)

		// Update skill mappings
		update_skill_mappings(mind, integration_data)

		// Apply progression boosts
		apply_progression_boosts(mind, integration_data)

		// Check for skill rewards
		check_skill_rewards(mind, integration_data)

/datum/skill_integration_manager/proc/get_integration_data(ckey)
	if(!integration_cache[ckey])
		integration_cache[ckey] = list(
			"last_sync" = 0,
			"skill_levels" = list(),
			"progression_boosts" = list(),
			"rewards_claimed" = list()
		)
	return integration_cache[ckey]

/datum/skill_integration_manager/proc/update_skill_mappings(datum/mind/mind, list/integration_data)
	// Update skill mappings based on current skill levels
	for(var/skill_type in skill_mappings)
		var/skill_level = mind.get_skill_level(skill_type)
		integration_data["skill_levels"][skill_type] = skill_level

/datum/skill_integration_manager/proc/apply_progression_boosts(datum/mind/mind, list/integration_data)
	if(!mind)
		return
	// Clear previous boosts
	mind.experience_multiplier_reasons -= "progression_boost"

	if(!mind.persistent_data)
		return

	var/class_id = mind.persistent_data.current_class_id
	var/list/skill_boosts = progression_skill_boosts[class_id]
	if(!length(skill_boosts))
		return

	for(var/skill_type in skill_boosts)
		var/boost = skill_boosts[skill_type]
		if(boost > 1.0)
			mind.experience_multiplier_reasons["progression_boost"] += (boost - 1.0)

	if(!integration_data["progression_boosts"])
		integration_data["progression_boosts"] = list()
	integration_data["progression_boosts"] = skill_boosts

/datum/skill_integration_manager/proc/check_skill_rewards(datum/mind/mind, list/integration_data)
	// Check for skill-based rewards and achievements
	for(var/skill_type in skill_mappings)
		var/skill_level = mind.get_skill_level(skill_type)
		var/reward_key = "[skill_type]_[skill_level]"

		if(skill_level >= SKILL_LEVEL_EXPERT && !integration_data["rewards_claimed"][reward_key])
			award_skill_reward(mind, skill_type, skill_level)
			integration_data["rewards_claimed"][reward_key] = TRUE

/datum/skill_integration_manager/proc/award_skill_reward(datum/mind/mind, skill_type, skill_level)
	// Award rewards for reaching skill milestones
	var/reward_data = skill_progression_rewards[skill_level]
	if(!reward_data)
		return

	// Award experience bonus
	if(reward_data["experience_bonus"])
		mind.adjust_experience(skill_type, reward_data["experience_bonus"])

	// Notify player
	var/skill_name = get_skill_name(skill_type)
	to_chat(mind.current, "<span class='notice'>Congratulations! You've reached [skill_level] level in [skill_name]!</span>")

// Research Skill Integration
/datum/skill_integration_manager/proc/on_research_activity(mob/living/carbon/human/researcher, research_type, base_experience = 0)
	if(!researcher || !researcher.mind)
		return

	var/enhanced_experience = apply_research_skill_bonuses(researcher, research_type, base_experience)

	// Award experience using the correct proc
	researcher.mind.adjust_experience(/datum/skill/research, enhanced_experience)

	// Apply research skill effects
	apply_research_skill_effects(researcher, research_type)

	// Check for achievements and rewards
	check_research_achievements(researcher)
	award_research_rewards(researcher, research_type)

	// Notify player of skill bonus
	if(enhanced_experience > base_experience)
		to_chat(researcher, "<span class='notice'>Your research skills provide a [round((enhanced_experience - base_experience) / base_experience * 100)]% bonus to research experience!</span>")

/datum/skill_integration_manager/proc/apply_research_skill_bonuses(mob/living/carbon/human/researcher, research_type, base_experience)
	if(!researcher || !researcher.mind)
		return base_experience

	var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0
	var/skill_bonus = research_skill * 0.02 // +2% per skill level

	// Apply research type-specific bonuses
	switch(research_type)
		if("scp_study")
			skill_bonus += research_skill * 0.01 // Additional +1% for SCP study
		if("experiment")
			skill_bonus += research_skill * 0.015 // Additional +1.5% for experiments
		if("documentation")
			skill_bonus += research_skill * 0.008 // Additional +0.8% for documentation
		if("breakthrough")
			skill_bonus += research_skill * 0.025 // Additional +2.5% for breakthroughs
		if("collaboration")
			skill_bonus += research_skill * 0.012 // Additional +1.2% for collaboration

	// Level-based research mastery bonuses
	if(research_skill >= 25)
		skill_bonus += 0.1 // +10% at level 25
	if(research_skill >= 50)
		skill_bonus += 0.2 // +20% at level 50
	if(research_skill >= 75)
		skill_bonus += 0.3 // +30% at level 75
	if(research_skill >= 100)
		skill_bonus += 0.5 // +50% at level 100

	return base_experience * (1 + skill_bonus)

/datum/skill_integration_manager/proc/apply_research_skill_effects(mob/living/carbon/human/researcher, research_type)
	if(!researcher || !researcher.mind)
		return

	var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0

	// Apply skill-based effects
	if(research_skill >= 25)
		trigger_research_intuition(researcher, research_type)
	if(research_skill >= 50)
		trigger_research_mastery(researcher, research_type)
	if(research_skill >= 75)
		trigger_research_breakthrough(researcher, research_type)
	if(research_skill >= 100)
		trigger_legendary_research(researcher, research_type)

/datum/skill_integration_manager/proc/trigger_research_intuition(mob/living/carbon/human/researcher, research_type)
	// Level 25+ research ability
	to_chat(researcher, "<span class='notice'>Your research intuition helps you understand complex patterns.</span>")

/datum/skill_integration_manager/proc/trigger_research_mastery(mob/living/carbon/human/researcher, research_type)
	// Level 50+ research ability
	to_chat(researcher, "<span class='notice'>Your research mastery allows you to identify breakthrough opportunities.</span>")

/datum/skill_integration_manager/proc/trigger_research_breakthrough(mob/living/carbon/human/researcher, research_type)
	// Level 75+ research ability
	to_chat(researcher, "<span class='notice'>Your advanced research skills enable breakthrough discoveries.</span>")

/datum/skill_integration_manager/proc/trigger_legendary_research(mob/living/carbon/human/researcher, research_type)
	// Level 100+ research ability
	to_chat(researcher, "<span class='notice'>Your legendary research abilities unlock unprecedented insights.</span>")

/datum/skill_integration_manager/proc/check_research_achievements(mob/living/carbon/human/researcher)
	if(!researcher || !researcher.mind)
		return

	var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0

	// Check for research milestones
	if(research_skill >= 25 && !("research_25" in research_milestones))
		award_research_achievement(researcher, "research_25", "Research Apprentice")
	if(research_skill >= 50 && !("research_50" in research_milestones))
		award_research_achievement(researcher, "research_50", "Research Expert")
	if(research_skill >= 75 && !("research_75" in research_milestones))
		award_research_achievement(researcher, "research_75", "Research Master")
	if(research_skill >= 100 && !("research_100" in research_milestones))
		award_research_achievement(researcher, "research_100", "Research Legend")

/datum/skill_integration_manager/proc/award_research_achievement(mob/living/carbon/human/researcher, achievement_id, achievement_name)
	research_milestones += achievement_id
	to_chat(researcher, "<span class='achievement'>Achievement Unlocked: [achievement_name]!</span>")

/datum/skill_integration_manager/proc/award_research_rewards(mob/living/carbon/human/researcher, research_type)
	if(!researcher || !researcher.mind)
		return

	var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0

	// Award research-specific rewards
	if(research_skill >= 50)
		award_research_cloak(researcher)

/datum/skill_integration_manager/proc/award_research_cloak(mob/living/carbon/human/researcher)
	if(!researcher || has_research_cloak(researcher))
		return

	// Create and give research cloak
	var/obj/item/clothing/neck/cloak/skill_reward/research/research_cloak = new()
	researcher.put_in_hands(research_cloak)
	to_chat(researcher, "<span class='notice'>You receive a Research Master's Cloak for your expertise!</span>")

/datum/skill_integration_manager/proc/has_research_cloak(mob/living/carbon/human/researcher)
	if(!researcher)
		return FALSE

	for(var/obj/item/clothing/neck/cloak/skill_reward/research/cloak in researcher.get_all_contents())
		return TRUE
	return FALSE

// Missing procs that are being called by other systems
/datum/skill_integration_manager/proc/add_experience(mob/living/carbon/human/user, skill_type, amount)
	if(!user || !user.mind)
		return

	user.mind.adjust_experience(skill_type, amount)

/datum/skill_integration_manager/proc/calculate_research_breakthrough_chance(mob/living/carbon/human/researcher, base_chance = 0.05)
	if(!researcher || !researcher.mind)
		return base_chance

	var/research_skill = researcher.mind.get_skill_level(/datum/skill/research) || 0
	var/skill_bonus = research_skill * 0.001 // +0.1% per skill level

	// Level-based bonuses
	if(research_skill >= 25)
		skill_bonus += 0.02 // +2% at level 25
	if(research_skill >= 50)
		skill_bonus += 0.05 // +5% at level 50
	if(research_skill >= 75)
		skill_bonus += 0.1 // +10% at level 75
	if(research_skill >= 100)
		skill_bonus += 0.2 // +20% at level 100

	return min(base_chance + skill_bonus, 0.5) // Cap at 50%

/datum/skill_integration_manager/proc/process_player_skill_integration(mob/living/carbon/human/player)
	if(!player || !player.mind)
		return

	// Process skill integration for a specific player
	var/ckey = player.ckey
	if(!ckey)
		return

	var/list/integration_data = get_integration_data(ckey)
	update_skill_mappings(player.mind, integration_data)
	apply_progression_boosts(player.mind, integration_data)
	check_skill_rewards(player.mind, integration_data)

/datum/skill_integration_manager/proc/award_skill_milestone_rewards(mob/living/carbon/human/player, skill_type, milestone_level)
	if(!player || !player.mind)
		return

	// Award milestone rewards for reaching skill levels
	var/skill_level = player.mind.get_skill_level(skill_type)
	if(skill_level >= milestone_level)
		award_skill_reward(player.mind, skill_type, skill_level)


