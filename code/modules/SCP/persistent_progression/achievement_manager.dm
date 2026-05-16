// Achievement Manager System
// Manages achievements, unlocks, and rewards for the persistence system

/datum/achievement_manager
	var/name = "Achievement Manager"
	var/list/achievements = list()
	var/list/achievement_categories = list()
	var/list/achievement_tiers = list()
	var/total_achievements = 0
	var/secret_achievements_count = 0

/datum/achievement_manager/New()
	initialize_achievements()
	initialize_categories()
	initialize_tiers()

/datum/achievement_manager/proc/initialize_achievements()
	register_milestone_achievements()
	register_class_achievements()
	register_faction_achievements()
	register_hidden_achievements()
	register_job_achievements()
	register_scp_achievements()
	register_combat_achievements()
	register_research_achievements()
	register_medical_achievements()
	register_engineering_achievements()
	register_social_achievements()
	register_special_achievements()

/datum/achievement_manager/proc/initialize_categories()
	achievement_categories = list(
		"milestone" = list(
			"name" = "Milestones",
			"description" = "Major accomplishments and progress markers",
			"icon" = "milestone",
			"color" = "#FFD700"
		),
		"class" = list(
			"name" = "Class Progression",
			"description" = "Achievements tied to class progression",
			"icon" = "class",
			"color" = "#4169E1"
		),
		"faction" = list(
			"name" = "Faction Loyalty",
			"description" = "Achievements for faction dedication",
			"icon" = "faction",
			"color" = "#32CD32"
		),
		"job" = list(
			"name" = "Job Performance",
			"description" = "Achievements for job excellence",
			"icon" = "job",
			"color" = "#9370DB"
		),
		"scp" = list(
			"name" = "SCP Interactions",
			"description" = "Achievements related to SCP encounters",
			"icon" = "scp",
			"color" = "#DC143C"
		),
		"combat" = list(
			"name" = "Combat Excellence",
			"description" = "Achievements for combat prowess",
			"icon" = "combat",
			"color" = "#FF4500"
		),
		"research" = list(
			"name" = "Research & Discovery",
			"description" = "Scientific achievements",
			"icon" = "research",
			"color" = "#1E90FF"
		),
		"medical" = list(
			"name" = "Medical Excellence",
			"description" = "Medical achievements",
			"icon" = "medical",
			"color" = "#00CED1"
		),
		"engineering" = list(
			"name" = "Engineering Mastery",
			"description" = "Engineering achievements",
			"icon" = "engineering",
			"color" = "#FFA500"
		),
		"social" = list(
			"name" = "Social & Teamwork",
			"description" = "Achievements for cooperation",
			"icon" = "social",
			"color" = "#FF69B4"
		),
		"hidden" = list(
			"name" = "Hidden",
			"description" = "Secret achievements",
			"icon" = "hidden",
			"color" = "#808080"
		),
		"special" = list(
			"name" = "Special",
			"description" = "Unique achievements",
			"icon" = "special",
			"color" = "#FF1493"
		)
	)

/datum/achievement_manager/proc/initialize_tiers()
	achievement_tiers = list(
		"bronze" = list(
			"name" = "Bronze",
			"points" = 10,
			"color" = "#CD7F32",
			"icon" = "bronze"
		),
		"silver" = list(
			"name" = "Silver",
			"points" = 25,
			"color" = "#C0C0C0",
			"icon" = "silver"
		),
		"gold" = list(
			"name" = "Gold",
			"points" = 50,
			"color" = "#FFD700",
			"icon" = "gold"
		),
		"platinum" = list(
			"name" = "Platinum",
			"points" = 100,
			"color" = "#E5E4E2",
			"icon" = "platinum"
		),
		"diamond" = list(
			"name" = "Diamond",
			"points" = 200,
			"color" = "#B9F2FF",
			"icon" = "diamond"
		)
	)

/datum/achievement
	var/achievement_id
	var/achievement_name
	var/achievement_description
	var/achievement_category = "milestone"
	var/achievement_tier = "bronze"
	var/achievement_points = 10
	var/achievement_max_progress = 1
	var/achievement_icon = "default"
	var/achievement_color = "#FFFFFF"
	var/achievement_hidden = FALSE
	var/achievement_repeatable = FALSE
	var/achievement_cooldown = 0
	var/list/achievement_prerequisites = list()
	var/list/achievement_rewards = list()
	var/achievement_notification_message = ""

/datum/achievement/New(id, name, description, category = "milestone", tier = "bronze")
	achievement_id = id
	achievement_name = name
	achievement_description = description
	achievement_category = category
	achievement_tier = tier
	switch(tier)
		if("bronze")
			achievement_points = 10
		if("silver")
			achievement_points = 25
		if("gold")
			achievement_points = 50
		if("platinum")
			achievement_points = 100
		if("diamond")
			achievement_points = 200

/datum/achievement_manager/proc/register_achievement(datum/achievement/achievement)
	if(!achievement || !achievement.achievement_id)
		return FALSE

	if(achievements[achievement.achievement_id])
		return FALSE

	achievements[achievement.achievement_id] = achievement
	total_achievements++

	if(achievement.achievement_hidden)
		secret_achievements_count++

	return TRUE

/datum/achievement_manager/proc/get_achievement(achievement_id)
	return achievements[achievement_id]

/datum/achievement_manager/proc/get_achievements_by_category(category)
	var/list/category_achievements = list()
	for(var/id in achievements)
		var/datum/achievement/achievement = achievements[id]
		if(achievement.achievement_category == category)
			category_achievements[id] = achievement
	return category_achievements

/datum/achievement_manager/proc/get_achievements_by_tier(tier)
	var/list/tier_achievements = list()
	for(var/id in achievements)
		var/datum/achievement/achievement = achievements[id]
		if(achievement.achievement_tier == tier)
			tier_achievements[id] = achievement
	return tier_achievements

/datum/achievement_manager/proc/get_visible_achievements()
	var/list/visible = list()
	for(var/id in achievements)
		var/datum/achievement/achievement = achievements[id]
		if(!achievement.achievement_hidden)
			visible[id] = achievement
	return visible

/datum/achievement_manager/proc/get_secret_achievements()
	var/list/secret = list()
	for(var/id in achievements)
		var/datum/achievement/achievement = achievements[id]
		if(achievement.achievement_hidden)
			secret[id] = achievement
	return secret

/datum/achievement_manager/proc/register_milestone_achievements()
	register_achievement(new /datum/achievement("first_experience", "First Steps", "Earn your first experience point", "milestone", "bronze"))
	register_achievement(new /datum/achievement("first_round", "Welcome Aboard", "Complete your first round", "milestone", "bronze"))
	register_achievement(new /datum/achievement("exp_1000", "Getting Started", "Earn 1,000 total experience", "milestone", "bronze"))
	register_achievement(new /datum/achievement("exp_5000", "Making Progress", "Earn 5,000 total experience", "milestone", "silver"))
	register_achievement(new /datum/achievement("exp_10000", "Experienced", "Earn 10,000 total experience", "milestone", "silver"))
	register_achievement(new /datum/achievement("exp_50000", "Veteran", "Earn 50,000 total experience", "milestone", "gold"))
	register_achievement(new /datum/achievement("exp_100000", "Master", "Earn 100,000 total experience", "milestone", "platinum"))
	register_achievement(new /datum/achievement("rounds_10", "Regular", "Complete 10 rounds", "milestone", "bronze"))
	register_achievement(new /datum/achievement("rounds_50", "Dedicated", "Complete 50 rounds", "milestone", "silver"))
	register_achievement(new /datum/achievement("rounds_100", "Veteran Player", "Complete 100 rounds", "milestone", "gold"))
	register_achievement(new /datum/achievement("rounds_500", "Legend", "Complete 500 rounds", "milestone", "platinum"))
	register_achievement(new /datum/achievement("survival_master", "Survival Master", "Survive 90% of rounds after 50 rounds played", "milestone", "diamond"))
	register_achievement(new /datum/achievement("pacifist_run", "Pacifist", "Complete a round without dealing any damage", "milestone", "gold"))
	register_achievement(new /datum/achievement("explorer", "Explorer", "Explore 90% of the map in a single round", "milestone", "gold"))

/datum/achievement_manager/proc/register_class_achievements()
	register_achievement(new /datum/achievement("class_security_novice", "Security Novice", "Reach rank 1 in Security class", "class", "bronze"))
	register_achievement(new /datum/achievement("class_security_expert", "Security Expert", "Reach rank 5 in Security class", "class", "gold"))
	register_achievement(new /datum/achievement("class_security_master", "Security Master", "Reach max rank in Security class", "class", "platinum"))
	register_achievement(new /datum/achievement("class_research_novice", "Research Novice", "Reach rank 1 in Research class", "class", "bronze"))
	register_achievement(new /datum/achievement("class_research_expert", "Research Expert", "Reach rank 5 in Research class", "class", "gold"))
	register_achievement(new /datum/achievement("class_research_master", "Research Master", "Reach max rank in Research class", "class", "platinum"))
	register_achievement(new /datum/achievement("class_medical_novice", "Medical Novice", "Reach rank 1 in Medical class", "class", "bronze"))
	register_achievement(new /datum/achievement("class_medical_expert", "Medical Expert", "Reach rank 5 in Medical class", "class", "gold"))
	register_achievement(new /datum/achievement("class_medical_master", "Medical Master", "Reach max rank in Medical class", "class", "platinum"))
	register_achievement(new /datum/achievement("class_engineering_novice", "Engineering Novice", "Reach rank 1 in Engineering class", "class", "bronze"))
	register_achievement(new /datum/achievement("class_engineering_expert", "Engineering Expert", "Reach rank 5 in Engineering class", "class", "gold"))
	register_achievement(new /datum/achievement("class_engineering_master", "Engineering Master", "Reach max rank in Engineering class", "class", "platinum"))
	register_achievement(new /datum/achievement("class_containment_novice", "Containment Novice", "Reach rank 1 in Containment class", "class", "bronze"))
	register_achievement(new /datum/achievement("class_containment_expert", "Containment Expert", "Reach rank 5 in Containment class", "class", "gold"))
	register_achievement(new /datum/achievement("class_containment_master", "Containment Master", "Reach max rank in Containment class", "class", "diamond"))

/datum/achievement_manager/proc/register_faction_achievements()
	register_achievement(new /datum/achievement("foundation_loyalty", "Foundation Loyalist", "Play 50 rounds as Foundation", "faction", "gold"))
	register_achievement(new /datum/achievement("foundation_dedication", "Foundation Dedication", "Play 100 rounds as Foundation", "faction", "platinum"))
	register_achievement(new /datum/achievement("goc_loyalty", "GOC Operative", "Play 50 rounds as GOC", "faction", "gold"))
	register_achievement(new /datum/achievement("serpents_hand_loyalty", "Serpent's Hand Scholar", "Play 50 rounds as Serpent's Hand", "faction", "gold"))
	register_achievement(new /datum/achievement("chaos_insurgency_loyalty", "Chaos Insurgent", "Play 50 rounds as Chaos Insurgency", "faction", "gold"))
	register_achievement(new /datum/achievement("mcd_loyalty", "MCD Executive", "Play 50 rounds as MCD", "faction", "gold"))
	register_achievement(new /datum/achievement("uiu_loyalty", "UIU Agent", "Play 50 rounds as UIU", "faction", "gold"))

/datum/achievement_manager/proc/register_hidden_achievements()
	var/datum/achievement/secret1 = new /datum/achievement("hidden_scp_173", "Don't Blink", "Have a close encounter with SCP-173", "hidden", "silver")
	secret1.achievement_hidden = TRUE
	register_achievement(secret1)

	var/datum/achievement/secret2 = new /datum/achievement("hidden_scp_096", "The Shy Guy", "See something you shouldn't have", "hidden", "gold")
	secret2.achievement_hidden = TRUE
	register_achievement(secret2)

	var/datum/achievement/secret3 = new /datum/achievement("hidden_containment_breach", "Code Black", "Experience a major containment breach", "hidden", "silver")
	secret3.achievement_hidden = TRUE
	register_achievement(secret3)

	var/datum/achievement/secret4 = new /datum/achievement("hidden_sacrifice", "Ultimate Sacrifice", "Sacrifice yourself to save others", "hidden", "diamond")
	secret4.achievement_hidden = TRUE
	register_achievement(secret4)

	var/datum/achievement/secret5 = new /datum/achievement("hidden_impossible", "Against All Odds", "Survive an impossible situation", "hidden", "platinum")
	secret5.achievement_hidden = TRUE
	register_achievement(secret5)

/datum/achievement_manager/proc/register_job_achievements()
	register_achievement(new /datum/achievement("job_security_arrests_10", "Making Arrests", "Make 10 arrests as Security", "job", "bronze"))
	register_achievement(new /datum/achievement("job_security_arrests_50", "Enforcer", "Make 50 arrests as Security", "job", "silver"))
	register_achievement(new /datum/achievement("job_security_arrests_100", "Justice Served", "Make 100 arrests as Security", "job", "gold"))
	register_achievement(new /datum/achievement("job_medical_saves_10", "Life Saver", "Save 10 patients as Medical", "job", "bronze"))
	register_achievement(new /datum/achievement("job_medical_saves_50", "Miracle Worker", "Save 50 patients as Medical", "job", "silver"))
	register_achievement(new /datum/achievement("job_medical_saves_100", "Guardian Angel", "Save 100 patients as Medical", "job", "gold"))
	register_achievement(new /datum/achievement("job_research_papers_5", "Published Author", "Publish 5 research papers", "job", "bronze"))
	register_achievement(new /datum/achievement("job_research_papers_25", "Prolific Researcher", "Publish 25 research papers", "job", "silver"))
	register_achievement(new /datum/achievement("job_research_papers_50", "Scientific Pioneer", "Publish 50 research papers", "job", "gold"))
	register_achievement(new /datum/achievement("job_engineering_builds_50", "Builder", "Build 50 structures or machines", "job", "bronze"))
	register_achievement(new /datum/achievement("job_engineering_builds_200", "Architect", "Build 200 structures or machines", "job", "silver"))
	register_achievement(new /datum/achievement("job_engineering_builds_500", "Master Builder", "Build 500 structures or machines", "job", "gold"))

/datum/achievement_manager/proc/register_scp_achievements()
	register_achievement(new /datum/achievement("scp_interactions_10", "SCP Encounters", "Have 10 SCP interactions", "scp", "bronze"))
	register_achievement(new /datum/achievement("scp_interactions_50", "SCP Veteran", "Have 50 SCP interactions", "scp", "silver"))
	register_achievement(new /datum/achievement("scp_interactions_100", "SCP Expert", "Have 100 SCP interactions", "scp", "gold"))
	register_achievement(new /datum/achievement("scp_containment_10", "Containment Specialist", "Participate in 10 re-containments", "scp", "silver"))
	register_achievement(new /datum/achievement("scp_containment_50", "Containment Expert", "Participate in 50 re-containments", "scp", "gold"))
	register_achievement(new /datum/achievement("scp_containment_100", "Containment Master", "Participate in 100 re-containments", "scp", "platinum"))
	register_achievement(new /datum/achievement("scp_research_25", "SCP Researcher", "Conduct 25 SCP experiments", "scp", "silver"))
	register_achievement(new /datum/achievement("scp_research_100", "SCP Scholar", "Conduct 100 SCP experiments", "scp", "gold"))
	
	register_achievement(new /datum/achievement("scp_first_contact_5", "First Contact Novice", "Make first contact with 5 SCPs", "scp", "bronze"))
	register_achievement(new /datum/achievement("scp_first_contact_15", "First Contact Explorer", "Make first contact with 15 SCPs", "scp", "silver"))
	register_achievement(new /datum/achievement("scp_first_contact_30", "First Contact Veteran", "Make first contact with 30 SCPs", "scp", "gold"))
	register_achievement(new /datum/achievement("scp_first_contact_all", "Complete Catalog", "Make first contact with all SCPs", "scp", "diamond"))
	
	register_achievement(new /datum/achievement("scp173_survive_10", "Don't Blink", "Survive 10 encounters with SCP-173", "scp", "bronze"))
	register_achievement(new /datum/achievement("scp173_observe_100", "Observation Duty", "Observe SCP-173 for 100 total minutes", "scp", "silver"))
	register_achievement(new /datum/achievement("scp173_contain_5", "Sculpture Wrangler", "Participate in 5 SCP-173 re-containments", "scp", "gold"))
	
	register_achievement(new /datum/achievement("scp096_avoid_10", "You Didn't See Anything", "Avoid triggering SCP-096's rage 10 times", "scp", "silver"))
	register_achievement(new /datum/achievement("scp096_survive_5", "Shy Guy Survivor", "Survive 5 SCP-096 rage states", "scp", "gold"))
	register_achievement(new /datum/achievement("scp096_contain_3", "Shy Guy Handler", "Participate in 3 SCP-096 re-containments", "scp", "platinum"))
	
	register_achievement(new /datum/achievement("scp106_escape_5", "Pocket Escape", "Escape SCP-106's pocket dimension 5 times", "scp", "gold"))
	register_achievement(new /datum/achievement("scp106_recall_3", "Recall Specialist", "Successfully use recall protocol 3 times", "scp", "platinum"))
	register_achievement(new /datum/achievement("scp106_survive_10", "Old Man Dodger", "Survive 10 encounters with SCP-106", "scp", "silver"))
	
	register_achievement(new /datum/achievement("scp049_cured_5", "Cured by the Doctor", "Be successfully cured by SCP-049", "scp", "bronze"))
	register_achievement(new /datum/achievement("scp049_survive_10", "Pestilence Survivor", "Survive 10 encounters with SCP-049", "scp", "silver"))
	register_achievement(new /datum/achievement("scp049_research_10", "Plague Researcher", "Conduct 10 experiments on SCP-049", "scp", "gold"))
	
	register_achievement(new /datum/achievement("scp914_refine_50", "Clockwork Operator", "Use SCP-914 to refine 50 items", "scp", "silver"))
	register_achievement(new /datum/achievement("scp914_breakthrough_5", "Breakthrough!", "Achieve 5 refinement breakthroughs with SCP-914", "scp", "gold"))
	register_achievement(new /datum/achievement("scp914_perfect", "Perfect Refinement", "Achieve a perfect refinement result", "scp", "platinum"))
	
	register_achievement(new /datum/achievement("scp939_survive_5", "Mimic Survivor", "Survive 5 encounters with SCP-939", "scp", "silver"))
	register_achievement(new /datum/achievement("scp939_deceive_3", "Not Fooled", "Detect SCP-939's mimicry 3 times", "scp", "gold"))
	
	register_achievement(new /datum/achievement("scp682_encounter_1", "Hard to Destroy", "Survive an encounter with SCP-682", "scp", "gold"))
	register_achievement(new /datum/achievement("scp682_contain_1", "Taming the Beast", "Participate in re-containing SCP-682", "scp", "diamond"))
	
	register_achievement(new /datum/achievement("scp999_play_10", "Best Friend", "Play with SCP-999 10 times", "scp", "bronze"))
	register_achievement(new /datum/achievement("scp999_healed_20", "Tickle Therapy", "Be healed by SCP-999 20 times", "scp", "silver"))
	register_achievement(new /datum/achievement("scp999_friend", "SCP-999's Favorite", "Become SCP-999's best friend", "scp", "gold"))
	
	register_achievement(new /datum/achievement("scp500_use_5", "Miracle Cure", "Use SCP-500 to cure 5 critical conditions", "scp", "gold"))
	register_achievement(new /datum/achievement("scp294_coffee_50", "Coffee Connoisseur", "Dispense 50 drinks from SCP-294", "scp", "bronze"))
	register_achievement(new /datum/achievement("scp294_rare_10", "Rare Brew", "Dispense 10 rare liquids from SCP-294", "scp", "silver"))
	
	register_achievement(new /datum/achievement("scp087_explore_1", "Stairway Explorer", "Explore SCP-087", "scp", "silver"))
	register_achievement(new /datum/achievement("scp087_deep_1", "How Deep?", "Reach the bottom of SCP-087", "scp", "platinum"))
	register_achievement(new /datum/achievement("scp3008_survive_1", "IKEA Employee", "Survive inside SCP-3008 for 30 minutes", "scp", "gold"))
	register_achievement(new /datum/achievement("scp3008_escape_1", "IKEA Escapee", "Escape from SCP-3008", "scp", "diamond"))
	
	register_achievement(new /datum/achievement("containment_rating_s_10", "S-Rated Specialist", "Achieve 10 S-rated containments", "scp", "gold"))
	register_achievement(new /datum/achievement("containment_rating_s_50", "S-Rated Master", "Achieve 50 S-rated containments", "scp", "platinum"))
	register_achievement(new /datum/achievement("containment_perfect_streak", "Perfect Streak", "Achieve 5 S-rated containments in a row", "scp", "diamond"))
	
	register_achievement(new /datum/achievement("scp_experiment_success_50", "Successful Experimenter", "Complete 50 successful experiments", "scp", "silver"))
	register_achievement(new /datum/achievement("scp_experiment_breakthrough_10", "Research Breakthrough", "Achieve 10 major experiment breakthroughs", "scp", "gold"))
	register_achievement(new /datum/achievement("scp_experiment_catastrophe_1", "Catastrophe Survivor", "Survive a catastrophic experiment failure", "scp", "platinum"))
	
	register_achievement(new /datum/achievement("scp_specialization_research", "Research Specialist", "Reach Specialist tier in Research track", "scp", "platinum"))
	register_achievement(new /datum/achievement("scp_specialization_containment", "Containment Specialist", "Reach Specialist tier in Containment track", "scp", "platinum"))
	register_achievement(new /datum/achievement("scp_specialization_field", "Field Specialist", "Reach Specialist tier in Field Operations track", "scp", "platinum"))
	register_achievement(new /datum/achievement("scp_specialization_medical", "Medical Specialist", "Reach Specialist tier in Medical track", "scp", "platinum"))
	register_achievement(new /datum/achievement("scp_specialization_all", "Master of All Trades", "Reach Specialist tier in all tracks", "scp", "diamond"))

/datum/achievement_manager/proc/register_combat_achievements()
	register_achievement(new /datum/achievement("combat_kills_10", "Combatant", "Defeat 10 hostiles", "combat", "bronze"))
	register_achievement(new /datum/achievement("combat_kills_50", "Warrior", "Defeat 50 hostiles", "combat", "silver"))
	register_achievement(new /datum/achievement("combat_kills_100", "Veteran Warrior", "Defeat 100 hostiles", "combat", "gold"))
	register_achievement(new /datum/achievement("combat_damage_taken_10000", "Tough", "Withstand 10,000 total damage", "combat", "bronze"))
	register_achievement(new /datum/achievement("combat_damage_taken_50000", "Resilient", "Withstand 50,000 total damage", "combat", "silver"))
	register_achievement(new /datum/achievement("combat_damage_taken_100000", "Indomitable", "Withstand 100,000 total damage", "combat", "gold"))
	register_achievement(new /datum/achievement("combat_perfect_round", "Untouchable", "Complete a round without taking damage", "combat", "platinum"))

/datum/achievement_manager/proc/register_research_achievements()
	register_achievement(new /datum/achievement("research_discoveries_5", "Discoverer", "Make 5 scientific discoveries", "research", "bronze"))
	register_achievement(new /datum/achievement("research_discoveries_25", "Innovator", "Make 25 scientific discoveries", "research", "silver"))
	register_achievement(new /datum/achievement("research_discoveries_50", "Visionary", "Make 50 scientific discoveries", "research", "gold"))
	register_achievement(new /datum/achievement("research_projects_10", "Project Lead", "Complete 10 research projects", "research", "silver"))
	register_achievement(new /datum/achievement("research_projects_50", "Senior Researcher", "Complete 50 research projects", "research", "gold"))
	register_achievement(new /datum/achievement("research_breakthrough", "Breakthrough!", "Make a scientific breakthrough", "research", "gold"))

/datum/achievement_manager/proc/register_medical_achievements()
	register_achievement(new /datum/achievement("medical_treatments_50", "Healer", "Perform 50 medical treatments", "medical", "bronze"))
	register_achievement(new /datum/achievement("medical_treatments_200", "Doctor", "Perform 200 medical treatments", "medical", "silver"))
	register_achievement(new /datum/achievement("medical_treatments_500", "Surgeon", "Perform 500 medical treatments", "medical", "gold"))
	register_achievement(new /datum/achievement("medical_surgeries_10", "Surgeon", "Perform 10 surgeries", "medical", "silver"))
	register_achievement(new /datum/achievement("medical_surgeries_50", "Chief Surgeon", "Perform 50 surgeries", "medical", "gold"))
	register_achievement(new /datum/achievement("medical_revivals_10", "Resurrector", "Revive 10 patients", "medical", "gold"))
	register_achievement(new /datum/achievement("medical_revivals_50", "Miracle Worker", "Revive 50 patients", "medical", "platinum"))

/datum/achievement_manager/proc/register_engineering_achievements()
	register_achievement(new /datum/achievement("engineering_repairs_50", "Repairman", "Repair 50 objects", "engineering", "bronze"))
	register_achievement(new /datum/achievement("engineering_repairs_200", "Technician", "Repair 200 objects", "engineering", "silver"))
	register_achievement(new /datum/achievement("engineering_repairs_500", "Engineer", "Repair 500 objects", "engineering", "gold"))
	register_achievement(new /datum/achievement("engineering_construction_100", "Constructor", "Build 100 objects", "engineering", "silver"))
	register_achievement(new /datum/achievement("engineering_construction_500", "Architect", "Build 500 objects", "engineering", "gold"))
	register_achievement(new /datum/achievement("engineering_maintenance_100", "Maintenance Pro", "Complete 100 maintenance tasks", "engineering", "silver"))

/datum/achievement_manager/proc/register_social_achievements()
	register_achievement(new /datum/achievement("social_team_rounds_10", "Team Player", "Complete 10 rounds with a team", "social", "bronze"))
	register_achievement(new /datum/achievement("social_team_rounds_50", "Squad Member", "Complete 50 rounds with a team", "social", "silver"))
	register_achievement(new /datum/achievement("social_team_rounds_100", "Squad Leader", "Complete 100 rounds with a team", "social", "gold"))
	register_achievement(new /datum/achievement("social_mentoring_10", "Mentor", "Mentor 10 new players", "social", "silver"))
	register_achievement(new /datum/achievement("social_mentoring_50", "Senior Mentor", "Mentor 50 new players", "social", "gold"))
	register_achievement(new /datum/achievement("social_commendations_10", "Commended", "Receive 10 commendations", "social", "silver"))

/datum/achievement_manager/proc/register_special_achievements()
	register_achievement(new /datum/achievement("special_beta_tester", "Beta Tester", "Participated in beta testing", "special", "platinum"))
	register_achievement(new /datum/achievement("special_event_winner", "Event Champion", "Won a special event", "special", "diamond"))
	register_achievement(new /datum/achievement("special_perfect_week", "Perfect Week", "Play every day for a week", "special", "gold"))
	register_achievement(new /datum/achievement("special_monthly_player", "Monthly Regular", "Play every day for a month", "special", "platinum"))
	register_achievement(new /datum/achievement("special_yearly_veteran", "Yearly Veteran", "Play for an entire year", "special", "diamond"))

/datum/achievement_manager/proc/check_prerequisites(ckey, achievement_id)
	var/datum/achievement/achievement = achievements[achievement_id]
	if(!achievement)
		return FALSE

	if(!length(achievement.achievement_prerequisites))
		return TRUE

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return FALSE

	for(var/prereq_id in achievement.achievement_prerequisites)
		if(!(prereq_id in player_data.achievements))
			return FALSE

	return TRUE

/datum/achievement_manager/proc/get_achievement_progress(ckey, achievement_id)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return 0

	if(achievement_id in player_data.achievements)
		return 100

	return player_data.achievement_progress[achievement_id] || 0

/datum/achievement_manager/proc/get_total_achievement_points()
	var/total = 0
	for(var/id in achievements)
		var/datum/achievement/achievement = achievements[id]
		total += achievement.achievement_points
	return total

/datum/achievement_manager/proc/get_player_achievement_points(ckey)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return 0

	var/total = 0
	for(var/achievement_id in player_data.achievements)
		var/datum/achievement/achievement = achievements[achievement_id]
		if(achievement)
			total += achievement.achievement_points

	return total

/datum/achievement_manager/proc/get_completion_percentage(ckey)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return 0

	var/total_achievements_count = length(achievements)
	if(total_achievements_count == 0)
		return 0

	var/unlocked = length(player_data.achievements)
	return round((unlocked / total_achievements_count) * 100)

/datum/achievement_manager/proc/export_achievements()
	var/list/data = list()
	data["total_achievements"] = length(achievements)
	data["secret_achievements"] = secret_achievements_count
	data["categories"] = achievement_categories
	data["tiers"] = achievement_tiers
	data["achievements"] = list()

	for(var/id in achievements)
		var/datum/achievement/achievement = achievements[id]
		if(!achievement.achievement_hidden)
			data["achievements"][id] = list(
				"name" = achievement.achievement_name,
				"description" = achievement.achievement_description,
				"category" = achievement.achievement_category,
				"tier" = achievement.achievement_tier,
				"points" = achievement.achievement_points,
				"max_progress" = achievement.achievement_max_progress
			)

	return json_encode(data)
