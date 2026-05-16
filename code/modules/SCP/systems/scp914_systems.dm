// SCP-914 System Datums
// Modular systems for SCP-914's redesigned mechanics

// ===== REFINEMENT SYSTEM =====
/datum/scp914_refinement_system
	var/obj/machinery/scp914/owner
	var/refinement_setting = "ROUGH"
	var/list/refinement_settings = list("ROUGH", "COARSE", "1:1", "FINE", "VERY FINE")
	var/refinement_cooldown = 0
	var/refinement_cooldown_time = 60 SECONDS
	var/list/input_objects = list()
	var/list/output_objects = list()
	var/refinement_progress = 0
	var/max_refinement_progress = 100
	var/active = FALSE
	var/refinement_quality = 1.0
	var/max_quality = 5.0
	var/refinement_mastery = 0
	var/max_refinement_mastery = 100
	var/refinement_efficiency = 1.0
	var/max_refinement_efficiency = 3.0
	var/breakthrough_chance = 5
	var/max_breakthrough_chance = 25
	var/catastrophe_chance = 2
	var/max_catastrophe_chance = 10
	var/refinement_radius = 2
	var/refinement_radius_expansion = 0
	var/max_radius_expansion = 5
	var/refinement_cooldown_reduction = 0
	var/max_cooldown_reduction = 50

	// Statistics
	var/refinements_performed = 0
	var/objects_destroyed = 0
	var/objects_enhanced = 0
	var/refinement_breakthroughs = 0
	var/refinement_catastrophes = 0
	var/total_materials_processed = 0

/datum/scp914_refinement_system/New(obj/machinery/scp914/new_owner)
	owner = new_owner

/datum/scp914_refinement_system/proc/process_refinement()
	if(!active || refinement_progress >= max_refinement_progress)
		return

	var/progress_increase = 5 * refinement_efficiency
	refinement_progress += progress_increase

	// Visual and audio effects
	playsound(owner, 'sound/weapons/punch1.ogg', 30, TRUE)

	// Update quality based on setting and mastery
	update_refinement_quality()

	// Chance for breakthrough or catastrophe
	if(prob(breakthrough_chance))
		create_breakthrough()
	else if(prob(catastrophe_chance))
		create_catastrophe()

	if(refinement_progress >= max_refinement_progress)
		complete_refinement()

/datum/scp914_refinement_system/proc/update_refinement_quality()
	var/base_quality = 1.0
	switch(refinement_setting)
		if("ROUGH")
			base_quality = 0.5
		if("COARSE")
			base_quality = 1.0
		if("1:1")
			base_quality = 2.0
		if("FINE")
			base_quality = 3.5
		if("VERY FINE")
			base_quality = 5.0

	refinement_quality = base_quality * (1 + (refinement_mastery / 100))

/datum/scp914_refinement_system/proc/create_breakthrough()
	refinement_breakthroughs++
	breakthrough_chance = min(max_breakthrough_chance, breakthrough_chance + 1)

	owner.visible_message("<span class='notice'>SCP-914 creates a breakthrough refinement!</span>")

	// Enhance nearby objects
	for(var/obj/O in range(refinement_radius + refinement_radius_expansion, owner))
		if(O != owner)
			owner.visible_message("<span class='notice'>[O] is enhanced by SCP-914's breakthrough!</span>")

/datum/scp914_refinement_system/proc/create_catastrophe()
	refinement_catastrophes++
	catastrophe_chance = min(max_catastrophe_chance, catastrophe_chance + 1)

	owner.visible_message("<span class='danger'>SCP-914 experiences a refinement catastrophe!</span>")

	// Damage nearby objects
	for(var/obj/O in range(refinement_radius + refinement_radius_expansion, owner))
		if(O != owner)
			owner.visible_message("<span class='danger'>[O] is damaged by SCP-914's catastrophe!</span>")

/datum/scp914_refinement_system/proc/complete_refinement()
	active = FALSE

	// Award research points to nearby researchers
	for(var/mob/living/carbon/human/H in view(5, owner))
		if(H.SCP) // Skip SCPs
			continue

			// Award research points for observing SCP-914 refinement
	// Research data will be collected by the research integration system

	refinements_performed++

	// Process input objects
	for(var/obj/item/item in input_objects)
		if(item)
			process_refinement_item(item)

	input_objects.Cut()

	// Update persistence
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-914"]
		if(instance)
			instance.add_interaction_record(null, "refinement_completed")

/datum/scp914_refinement_system/proc/process_refinement_item(obj/item/item)
	if(!item)
		return

	var/result_type = scp914_process_item(item, refinement_setting)

	if(isnull(result_type))
		objects_destroyed++
		owner.visible_message("<span class='danger'>[item] is destroyed by SCP-914!</span>")
		qdel(item)
	else if(result_type == item.type && refinement_setting != SCP914_ONE_TO_ONE)
		output_objects += item
		item.forceMove(owner)
		owner.visible_message("<span class='notice'>[item] passes through SCP-914 unchanged.</span>")
	else
		var/obj/item/result = new result_type(get_turf(owner))
		if(result)
			if(refinement_setting == SCP914_FINE || refinement_setting == SCP914_VERY_FINE)
				result.name = "refined [result.name]"
				if(refinement_setting == SCP914_VERY_FINE && prob(30))
					result.name = "anomalous [result.name]"
					result.desc = "[result.desc] It crackles with strange energy."
			output_objects += result
			objects_enhanced++
			owner.visible_message("<span class='notice'>[item] is refined into [result.name] by SCP-914!</span>")
		qdel(item)

	total_materials_processed++

/datum/scp914_refinement_system/proc/process_refinement_mastery()
	if(refinements_performed > 0 && refinement_mastery < max_refinement_mastery)
		if(prob(2))
			refinement_mastery = min(max_refinement_mastery, refinement_mastery + 1)

// ===== REALITY MANIPULATION SYSTEM =====
/datum/scp914_reality_system
	var/obj/machinery/scp914/owner
	var/reality_manipulation = 0
	var/max_reality_manipulation = 100
	var/reality_manipulation_cooldown = 0
	var/reality_manipulation_cooldown_time = 45 SECONDS
	var/reality_manipulations = 0
	var/reality_distortion_radius = 3

/datum/scp914_reality_system/New(obj/machinery/scp914/new_owner)
	owner = new_owner

/datum/scp914_reality_system/proc/process_reality_manipulation()
	if(reality_manipulation > 0 && prob(1))
		// Create reality distortions
		for(var/mob/living/carbon/human/H in range(reality_distortion_radius, owner))
			if(H != owner)
				to_chat(H, "<span class='notice'>You feel reality shifting around SCP-914...</span>")

/datum/scp914_reality_system/proc/activate_reality_manipulation()
	if(world.time < reality_manipulation_cooldown)
		return FALSE

	reality_manipulation_cooldown = world.time + reality_manipulation_cooldown_time
	reality_manipulation = min(max_reality_manipulation, reality_manipulation + 20)
	reality_manipulations++

	return TRUE

// ===== TEMPORAL EFFECTS SYSTEM =====
/datum/scp914_temporal_system
	var/obj/machinery/scp914/owner
	var/temporal_effects = 0
	var/max_temporal_effects = 100
	var/temporal_events = 0
	var/temporal_distortion_radius = 3

/datum/scp914_temporal_system/New(obj/machinery/scp914/new_owner)
	owner = new_owner

/datum/scp914_temporal_system/proc/process_temporal_effects()
	if(temporal_effects > 0 && prob(1))
		// Create temporal distortions
		for(var/mob/living/carbon/human/H in range(temporal_distortion_radius, owner))
			if(H != owner)
				to_chat(H, "<span class='notice'>You feel time warping around SCP-914...</span>")
				temporal_events++

/datum/scp914_temporal_system/proc/activate_temporal_effects()
	temporal_effects = min(max_temporal_effects, temporal_effects + 20)
	temporal_events++
	return TRUE

// ===== MATERIAL SYNTHESIS SYSTEM =====
/datum/scp914_material_system
	var/obj/machinery/scp914/owner
	var/material_synthesis = 0
	var/max_material_synthesis = 100
	var/material_synthesis_cooldown = 0
	var/material_synthesis_cooldown_time = 30 SECONDS
	var/material_syntheses = 0
	var/list/refined_materials = list()

/datum/scp914_material_system/New(obj/machinery/scp914/new_owner)
	owner = new_owner

/datum/scp914_material_system/proc/process_material_synthesis()
	if(material_synthesis > 0 && prob(1))
		// Synthesize new materials
		var/list/new_materials = list("reality_fabric", "temporal_essence", "dimensional_crystal", "existence_particle")
		var/new_material = pick(new_materials)

		if(!(new_material in refined_materials))
			refined_materials += new_material
			material_syntheses++

/datum/scp914_material_system/proc/activate_material_synthesis()
	if(world.time < material_synthesis_cooldown)
		return FALSE

	material_synthesis_cooldown = world.time + material_synthesis_cooldown_time
	material_synthesis = min(max_material_synthesis, material_synthesis + 20)
	material_syntheses++

	return TRUE

// ===== CONTAINMENT SYSTEM =====
/datum/scp914_containment_system
	var/obj/machinery/scp914/owner
	var/containment_status = "contained"
	var/access_level_required = 2
	var/emergency_shutdown = FALSE
	var/containment_breach = FALSE
	var/safety_protocols_active = TRUE

/datum/scp914_containment_system/New(obj/machinery/scp914/new_owner)
	owner = new_owner

/datum/scp914_containment_system/proc/check_containment()
	// Simplified containment check - always contained for now
	if(containment_status != "contained")
		set_containment_status("contained")

/datum/scp914_containment_system/proc/set_containment_status(new_status)
	containment_status = new_status

	if(new_status == "breached")
		containment_breach = TRUE
		emergency_shutdown = TRUE
		owner.visible_message("<span class='danger'>SCP-914 containment breach detected! Emergency shutdown activated!</span>")
	else
		containment_breach = FALSE
		emergency_shutdown = FALSE

/datum/scp914_containment_system/proc/emergency_shutdown_procedure()
	emergency_shutdown = TRUE
	owner.visible_message("<span class='danger'>SCP-914 emergency shutdown activated!</span>")

	// Stop all active processes
	if(owner.refinement_system)
		owner.refinement_system.active = FALSE

// ===== ENVIRONMENTAL SYSTEM =====
/datum/scp914_environmental_system
	var/obj/machinery/scp914/owner
	var/environmental_effects_radius = 5
	var/reality_distortion_level = 0
	var/temporal_distortion_level = 0
	var/energy_fluctuation_level = 0

/datum/scp914_environmental_system/New(obj/machinery/scp914/new_owner)
	owner = new_owner

/datum/scp914_environmental_system/proc/process_environmental_effects()
	// Reality distortion effects
	if(reality_distortion_level > 0)
		for(var/mob/living/carbon/human/H in range(environmental_effects_radius, owner))
			if(prob(5))
				to_chat(H, "<span class='notice'>You notice subtle changes in the environment around SCP-914...</span>")

	// Temporal distortion effects
	if(temporal_distortion_level > 0)
		for(var/mob/living/carbon/human/H in range(environmental_effects_radius, owner))
			if(prob(3))
				to_chat(H, "<span class='notice'>Time seems to flow differently near SCP-914...</span>")

	// Energy fluctuation effects
	if(energy_fluctuation_level > 0)
		for(var/obj/machinery/power/apc/A in range(environmental_effects_radius, owner))
			if(prob(2))
				A.energy_fail(30)

// ===== RESEARCH INTEGRATION SYSTEM =====
/datum/scp914_research_integration
	var/obj/machinery/scp914/owner
	var/list/research_data = list()
	var/last_research_update = 0
	var/research_update_interval = 60 SECONDS

/datum/scp914_research_integration/New(obj/machinery/scp914/new_owner)
	owner = new_owner

/datum/scp914_research_integration/proc/update_research_data()
	if(world.time < last_research_update + research_update_interval)
		return

	last_research_update = world.time

	var/current_data = list(
		"refinements_performed" = owner.refinement_system.refinements_performed,
		"objects_destroyed" = owner.refinement_system.objects_destroyed,
		"objects_enhanced" = owner.refinement_system.objects_enhanced,
		"refinement_breakthroughs" = owner.refinement_system.refinement_breakthroughs,
		"refinement_catastrophes" = owner.refinement_system.refinement_catastrophes,
		"total_materials_processed" = owner.refinement_system.total_materials_processed,
		"refinement_mastery" = owner.refinement_system.refinement_mastery,
		"reality_manipulations" = owner.reality_system.reality_manipulations,
		"temporal_events" = owner.temporal_system.temporal_events,
		"material_syntheses" = owner.material_system.material_syntheses,
		"containment_status" = owner.containment_system.containment_status
	)

	research_data["last_update"] = current_data

	// Research data collected for analysis
	// Will be integrated with research persistence system when available

/datum/scp914_research_integration/proc/get_research_summary()
	var/summary = "<h2>SCP-914 Research Summary</h2>"
	summary += "<b>Total Refinements:</b> [owner.refinement_system.refinements_performed]<br>"
	summary += "<b>Success Rate:</b> [owner.refinement_system.objects_enhanced]/[owner.refinement_system.total_materials_processed]<br>"
	summary += "<b>Breakthroughs:</b> [owner.refinement_system.refinement_breakthroughs]<br>"
	summary += "<b>Catastrophes:</b> [owner.refinement_system.refinement_catastrophes]<br>"
	summary += "<b>Reality Manipulations:</b> [owner.reality_system.reality_manipulations]<br>"
	summary += "<b>Temporal Events:</b> [owner.temporal_system.temporal_events]<br>"
	summary += "<b>Material Syntheses:</b> [owner.material_system.material_syntheses]<br>"
	summary += "<b>Containment Status:</b> [owner.containment_system.containment_status]<br>"

	return summary
