// Faction Integration System
// This system integrates persistent progression factions with the current game faction system

// Faction defines for integration with the current system
// These are now defined in the main defines files

// Faction integration datum
/datum/faction_integration
	var/list/faction_mappings = list()
	var/list/job_faction_assignments = list()
	var/list/faction_relationships = list()

/datum/faction_integration/New()
	initialize_faction_mappings()
	initialize_job_assignments()
	initialize_faction_relationships()

// All persistent factions currently map to FACTION_STATION because no distinct faction defines exist
// (FACTION_SYNDICATE, FACTION_NANOTRASEN, FACTION_FLOCK all alias to FACTION_STATION)
// TODO: Add FACTION_GOC, FACTION_SERPENTS_HAND, FACTION_CHAOS_INSURGENCY, FACTION_MCD, FACTION_UIU defines
/datum/faction_integration/proc/initialize_faction_mappings()
	faction_mappings = list(
		"foundation" = FACTION_STATION,
		"goc" = FACTION_STATION,
		"serpents_hand" = FACTION_STATION,
		"chaos_insurgency" = FACTION_STATION,
		"mcd" = FACTION_STATION,
		"uiu" = FACTION_STATION
	)



// Initialize job assignments to factions
/datum/faction_integration/proc/initialize_job_assignments()
	// Foundation jobs (default station jobs)
	job_faction_assignments["foundation"] = list(
		// Command
		"site_director", "o5_representative", "guard_commander", "research_director",
		"chief_medical_officer", "chief_engineer",
		// Security
		"lcz_zone_commander", "hcz_zone_commander", "ez_zone_commander", "lcz_guard",
		"hcz_guard", "ez_guard", "mtf_commander", "mtf_operative",
		// Medical
		"medical_doctor", "surgeon", "paramedic", "chemist", "virologist",
		"psychiatrist", "medical_intern", "coroner",
		// Science
		"senior_researcher", "researcher", "research_associate", "lab_technician",
		"xenobiologist", "roboticist", "chemist_science", "archaeologist", "field_agent",
		// Engineering
		"senior_engineer", "engineer", "junior_engineer", "atmospheric_technician",
		"containment_engineer", "electrical_engineer", "communications_technician", "maintenance_technician",
		// Supply
		"quartermaster", "cargo_technician", "shaft_miner", "logistics_officer", "supply_specialist",
		// Service
		"janitor", "cook", "bartender", "botanist", "chaplain", "curator", "lawyer",
		// D-Class
		"dclass_general", "dclass_medical", "dclass_kitchen", "dclass_janitorial",
		"dclass_mining"
	)

	// GOC jobs (Nanotrasen-aligned)
	job_faction_assignments["goc"] = list(
		"goc_commander", "goc_operative", "goc_researcher", "goc_medic", "goc_engineer"
	)

	// Serpent's Hand jobs (Syndicate-aligned)
	job_faction_assignments["serpents_hand"] = list(
		"serpent_librarian", "serpent_scout", "serpent_researcher", "serpent_guardian"
	)

	// Chaos Insurgency jobs (Syndicate-aligned)
	job_faction_assignments["chaos_insurgency"] = list(
		"insurgent_commander", "insurgent_operative", "insurgent_scientist", "insurgent_medic"
	)

	// MCD jobs (Nanotrasen-aligned)
	job_faction_assignments["mcd"] = list(
		"mcd_executive", "mcd_agent", "mcd_researcher", "mcd_security"
	)

	// UIU jobs (Station-aligned)
	job_faction_assignments["uiu"] = list(
		"uiu_agent", "uiu_detective", "uiu_medic", "uiu_technician"
	)

// Initialize faction relationships (allies, enemies, neutral)
/datum/faction_integration/proc/initialize_faction_relationships()
	faction_relationships = list(
		"foundation" = list(
			"allies" = list("uiu"),
			"enemies" = list("chaos_insurgency", "serpents_hand"),
			"neutral" = list("goc", "mcd")
		),
		"goc" = list(
			"allies" = list("mcd"),
			"enemies" = list("chaos_insurgency", "serpents_hand"),
			"neutral" = list("foundation", "uiu")
		),
		"serpents_hand" = list(
			"allies" = list("chaos_insurgency"),
			"enemies" = list("foundation", "goc", "mcd"),
			"neutral" = list("uiu")
		),
		"chaos_insurgency" = list(
			"allies" = list("serpents_hand"),
			"enemies" = list("foundation", "goc", "mcd"),
			"neutral" = list("uiu")
		),
		"mcd" = list(
			"allies" = list("goc"),
			"enemies" = list("chaos_insurgency", "serpents_hand"),
			"neutral" = list("foundation", "uiu")
		),
		"uiu" = list(
			"allies" = list("foundation"),
			"enemies" = list(),
			"neutral" = list("goc", "mcd", "serpents_hand", "chaos_insurgency")
		)
	)

// Get the game faction for a persistent faction
/datum/faction_integration/proc/get_game_faction(persistent_faction_id)
	return faction_mappings[persistent_faction_id] || FACTION_STATION

// Get the persistent faction for a game faction
/datum/faction_integration/proc/get_persistent_faction(game_faction)
	for(var/persistent_id in faction_mappings)
		if(faction_mappings[persistent_id] == game_faction)
			return persistent_id
	return "foundation"

// Check if two factions are allies
/datum/faction_integration/proc/are_allies(faction1, faction2)
	if(!faction_relationships[faction1] || !faction_relationships[faction2])
		return FALSE
	return faction2 in faction_relationships[faction1]["allies"]

// Check if two factions are enemies
/datum/faction_integration/proc/are_enemies(faction1, faction2)
	if(!faction_relationships[faction1] || !faction_relationships[faction2])
		return FALSE
	return faction2 in faction_relationships[faction1]["enemies"]

// Get faction relationship status
/datum/faction_integration/proc/get_relationship_status(faction1, faction2)
	if(are_allies(faction1, faction2))
		return "ally"
	if(are_enemies(faction1, faction2))
		return "enemy"
	return "neutral"

// Apply faction to a mob based on persistent faction
/datum/faction_integration/proc/apply_faction_to_mob(mob/living/M, persistent_faction_id)
	if(!M || !persistent_faction_id)
		return

	// Now that we've replaced the default factions, we can use our factions directly
	M.faction = list(persistent_faction_id)

// Get faction for a job
/datum/faction_integration/proc/get_job_faction(job_title)
	for(var/faction_id in job_faction_assignments)
		if(job_title in job_faction_assignments[faction_id])
			return faction_id
	return "foundation" // Default to foundation

// Check if a job belongs to a specific faction
/datum/faction_integration/proc/job_belongs_to_faction(job_title, faction_id)
	if(!job_faction_assignments[faction_id])
		return FALSE
	return job_title in job_faction_assignments[faction_id]

// Get all jobs for a faction
/datum/faction_integration/proc/get_faction_jobs(faction_id)
	return job_faction_assignments[faction_id] || list()

// Get faction color for UI
/datum/faction_integration/proc/get_faction_color(faction_id)
	if(!SSpersistent_progression)
		return "#666666"
	var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
	return faction ? faction.faction_color : "#666666"

// Get faction icon for UI
/datum/faction_integration/proc/get_faction_icon(faction_id)
	if(!SSpersistent_progression)
		return "faction_default"
	var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
	return faction ? faction.faction_icon : "faction_default"

// Check if a mob should be hostile to another based on factions
/datum/faction_integration/proc/should_be_hostile(mob/living/M1, mob/living/M2)
	if(!M1 || !M2)
		return FALSE

	// Get factions directly from mobs (now using our custom factions)
	var/faction1 = null
	var/faction2 = null

	// Check if mobs have persistent faction data
	if(M1.mind && M1.mind.persistent_data && M1.mind.persistent_data.current_faction_id)
		faction1 = M1.mind.persistent_data.current_faction_id
	if(M2.mind && M2.mind.persistent_data && M2.mind.persistent_data.current_faction_id)
		faction2 = M2.mind.persistent_data.current_faction_id

	// If both have persistent factions, check relationship
	if(faction1 && faction2)
		return are_enemies(faction1, faction2)

	// Fall back to direct faction check (now using our custom factions)
	return !faction_check(M1.faction, M2.faction, FALSE)

// Hook for when a player joins a job
/datum/faction_integration/proc/on_job_assigned(mob/living/carbon/human/H, datum/job/J)
	if(!H || !J || !H.mind)
		return

	var/job_faction = get_job_faction(J.title)
	if(job_faction && H.mind && H.mind.persistent_data)
		// Update player's faction to match job
		H.mind.persistent_data.current_faction_id = job_faction

		// Apply faction to mob
		apply_faction_to_mob(H, job_faction)

		// Log faction assignment
		log_game("Faction Integration: [H.ckey] assigned to faction [job_faction] via job [J.title]")

// Hook for when a player changes faction manually
/datum/faction_integration/proc/on_faction_changed(mob/living/carbon/human/H, old_faction, new_faction)
	if(!H || !H.mind)
		return

	// Apply new faction to mob
	apply_faction_to_mob(H, new_faction)

	// Log faction change
	log_game("Faction Integration: [H.ckey] changed faction from [old_faction] to [new_faction]")

// Get faction statistics
/datum/faction_integration/proc/get_faction_stats()
	var/list/stats = list()

	if(!SSpersistent_progression)
		return stats

	for(var/faction_id in SSpersistent_progression.factions)
		var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(faction_id)
		if(faction)
			var/list/faction_stat = list()
			faction_stat["id"] = faction_id
			faction_stat["name"] = faction.faction_name
			faction_stat["member_count"] = 0
			faction_stat["total_experience"] = 0

			// Count members and experience
			for(var/ckey in SSpersistent_progression.player_data)
				var/datum/persistent_player_data/data = SSpersistent_progression.player_data[ckey]
				if(!data)
					continue
				if(data.current_faction_id == faction_id)
					faction_stat["member_count"]++
					faction_stat["total_experience"] += data.total_experience

			stats += list(faction_stat)

	return stats

// Global faction integration instance
GLOBAL_VAR_INIT(faction_integration, null)

// Initialize global faction integration
/proc/initialize_global_faction_integration()
	if(GLOB.faction_integration)
		return
	if(!SSpersistent_progression)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/initialize_global_faction_integration), 5 SECONDS)
		return
	GLOB.faction_integration = new /datum/faction_integration()
	log_game("Faction Integration: Initialized global faction integration")

