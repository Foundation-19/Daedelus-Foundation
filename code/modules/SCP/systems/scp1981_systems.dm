// SCP-1981 Modular Systems
// Video Manipulation, Reality Distortion, and Temporal Effects Systems

// Video Manipulation System - Manages the video recording's effects
/datum/scp1981_video_system
	var/obj/item/scp1981/owner
	var/video_manipulation = 0
	var/max_video_manipulation = 100
	var/video_evolution = 1
	var/max_video_evolution = 5
	var/video_cooldown = 0
	var/video_cooldown_time = 30 SECONDS
	var/video_events = 0

/datum/scp1981_video_system/New(obj/item/scp1981/new_owner)
	owner = new_owner

/datum/scp1981_video_system/proc/process_video()
	if(!owner)
		return

	// Check for nearby viewers
	var/list/viewers = list()
	for(var/mob/living/carbon/human/H in range(5, owner))
		if(H.stat != DEAD)
			viewers += H

	// Automatic video manipulation when people are nearby
	if(length(viewers) > 0 && prob(2))
		increase_video_manipulation()

	// Apply video effects to viewers
	if(video_manipulation > 10 && length(viewers) > 0)
		apply_video_effects(viewers)

	// Check for evolution
	if(video_manipulation >= max_video_manipulation && video_evolution < max_video_evolution && prob(1))
		evolve_video_stage()

/datum/scp1981_video_system/proc/increase_video_manipulation()
	video_manipulation = min(max_video_manipulation, video_manipulation + 5)
	video_events++

/datum/scp1981_video_system/proc/apply_video_effects(list/viewers)
	for(var/mob/living/carbon/human/H in viewers)
		var/video_intensity = video_manipulation / max_video_manipulation

		if(prob(8 * video_intensity))
			to_chat(H, span_danger("You see disturbing video imagery that seems to distort reality..."))
			H.adjustBruteLoss(2)

		if(prob(5 * video_intensity))
			to_chat(H, span_danger("The video recording shows impossible scenes that shouldn't exist..."))
			if(H.stamina)
				H.stamina.adjust(-10)

/datum/scp1981_video_system/proc/evolve_video_stage()
	video_evolution = min(max_video_evolution, video_evolution + 1)

	var/evolution_message = ""
	switch(video_evolution)
		if(2)
			evolution_message = "SCP-1981 evolves enhanced video manipulation!"
		if(3)
			evolution_message = "SCP-1981 evolves reality distortion abilities!"
		if(4)
			evolution_message = "SCP-1981 evolves temporal manipulation powers!"
		if(5)
			evolution_message = "SCP-1981 achieves ultimate video evolution!"

	owner.visible_message(span_danger("[evolution_message]"))

// Reality Distortion System - Manages reality-warping effects
/datum/scp1981_reality_system
	var/obj/item/scp1981/owner
	var/reality_distortion = 0
	var/max_reality_distortion = 100
	var/distortion_potency = 1
	var/max_distortion_potency = 10
	var/reality_cooldown = 0
	var/reality_cooldown_time = 20 SECONDS
	var/reality_events = 0

/datum/scp1981_reality_system/New(obj/item/scp1981/new_owner)
	owner = new_owner

/datum/scp1981_reality_system/proc/process_reality()
	if(!owner)
		return

	// Check for nearby targets
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(4, owner))
		if(H.stat != DEAD)
			targets += H

	// Automatic reality distortion when people are nearby
	if(length(targets) > 0 && prob(1))
		increase_reality_distortion()

	// Apply reality effects
	if(reality_distortion > 15 && length(targets) > 0)
		apply_reality_effects(targets)

	// Increase distortion potency over time
	if(reality_distortion > 50 && distortion_potency < max_distortion_potency && prob(1))
		increase_distortion_potency()

/datum/scp1981_reality_system/proc/increase_reality_distortion()
	reality_distortion = min(max_reality_distortion, reality_distortion + 3)
	reality_events++

/datum/scp1981_reality_system/proc/apply_reality_effects(list/targets)
	for(var/mob/living/carbon/human/H in targets)
		var/distortion_factor = reality_distortion / max_reality_distortion

		if(prob(6 * distortion_factor))
			to_chat(H, span_danger("Reality seems to distort and warp around you..."))
			H.adjustBruteLoss(3)

		if(prob(4 * distortion_factor))
			to_chat(H, span_danger("The laws of physics seem to bend and break..."))
			if(H.stamina)
				H.stamina.adjust(-15)

/datum/scp1981_reality_system/proc/increase_distortion_potency()
	distortion_potency = min(max_distortion_potency, distortion_potency + 1)

	for(var/mob/living/carbon/human/H in range(6, owner))
		if(H.stat != DEAD)
			to_chat(H, span_danger("The reality distortion becomes more potent and dangerous..."))

// Temporal Effects System - Manages time manipulation
/datum/scp1981_temporal_system
	var/obj/item/scp1981/owner
	var/temporal_effects = 0
	var/max_temporal_effects = 100
	var/temporal_mastery = 0
	var/max_temporal_mastery = 100
	var/temporal_cooldown = 0
	var/temporal_cooldown_time = 45 SECONDS
	var/temporal_events = 0

/datum/scp1981_temporal_system/New(obj/item/scp1981/new_owner)
	owner = new_owner

/datum/scp1981_temporal_system/proc/process_temporal()
	if(!owner)
		return

	// Check for nearby targets
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(6, owner))
		if(H.stat != DEAD)
			targets += H

	// Automatic temporal effects when people are nearby
	if(length(targets) > 0 && prob(1))
		increase_temporal_effects()

	// Apply temporal effects
	if(temporal_effects > 20 && length(targets) > 0)
		apply_temporal_effects(targets)

	// Increase temporal mastery over time
	if(temporal_effects > 60 && temporal_mastery < max_temporal_mastery && prob(1))
		increase_temporal_mastery()

/datum/scp1981_temporal_system/proc/increase_temporal_effects()
	temporal_effects = min(max_temporal_effects, temporal_effects + 4)
	temporal_events++

/datum/scp1981_temporal_system/proc/apply_temporal_effects(list/targets)
	for(var/mob/living/carbon/human/H in targets)
		var/temporal_factor = temporal_effects / max_temporal_effects

		if(prob(5 * temporal_factor))
			to_chat(H, span_danger("Time seems to behave strangely around you..."))
			H.adjustBruteLoss(2)

		if(prob(3 * temporal_factor))
			to_chat(H, span_danger("You feel moments of temporal displacement..."))
			if(H.stamina)
				H.stamina.adjust(-12)

/datum/scp1981_temporal_system/proc/increase_temporal_mastery()
	temporal_mastery = min(max_temporal_mastery, temporal_mastery + 5)

	for(var/mob/living/carbon/human/H in range(8, owner))
		if(H.stat != DEAD)
			to_chat(H, span_danger("The temporal manipulation becomes more sophisticated..."))

// Synthesis System - Manages combined effects
/datum/scp1981_synthesis_system
	var/obj/item/scp1981/owner
	var/synthesis_cooldown = 0
	var/synthesis_cooldown_time = 60 SECONDS
	var/synthesis_events = 0

/datum/scp1981_synthesis_system/New(obj/item/scp1981/new_owner)
	owner = new_owner

/datum/scp1981_synthesis_system/proc/process_synthesis()
	if(!owner)
		return

	// Check if conditions are right for synthesis
	if(owner.video_system && owner.reality_system && owner.temporal_system)
		var/video_ready = owner.video_system.video_manipulation > 70
		var/reality_ready = owner.reality_system.reality_distortion > 70
		var/temporal_ready = owner.temporal_system.temporal_effects > 70

		if(video_ready && reality_ready && temporal_ready && world.time >= synthesis_cooldown)
			trigger_synthesis()

/datum/scp1981_synthesis_system/proc/trigger_synthesis()
	synthesis_cooldown = world.time + synthesis_cooldown_time
	synthesis_events++

	// Create powerful combined effects
	for(var/mob/living/carbon/human/H in range(8, owner))
		if(H.stat != DEAD)
			to_chat(H, span_danger("You experience overwhelming video distortion and reality warping!"))
			H.adjustBruteLoss(15)
			if(H.stamina)
				H.stamina.adjust(-25)

	owner.visible_message(span_danger("SCP-1981 synthesizes all its effects in a powerful burst!"))

// Research System - Collects data on SCP-1981's effects
/datum/scp1981_research_system
	var/obj/item/scp1981/owner
	var/list/research_data = list()

/datum/scp1981_research_system/New(obj/item/scp1981/new_owner)
	owner = new_owner

/datum/scp1981_research_system/proc/process_research()
	if(!owner)
		return

	// Collect research data
	var/list/current_data = list(
		"video_manipulation" = owner.video_system ? owner.video_system.video_manipulation : 0,
		"video_evolution" = owner.video_system ? owner.video_system.video_evolution : 1,
		"reality_distortion" = owner.reality_system ? owner.reality_system.reality_distortion : 0,
		"distortion_potency" = owner.reality_system ? owner.reality_system.distortion_potency : 1,
		"temporal_effects" = owner.temporal_system ? owner.temporal_system.temporal_effects : 0,
		"temporal_mastery" = owner.temporal_system ? owner.temporal_system.temporal_mastery : 0,
		"video_events" = owner.video_system ? owner.video_system.video_events : 0,
		"reality_events" = owner.reality_system ? owner.reality_system.reality_events : 0,
		"temporal_events" = owner.temporal_system ? owner.temporal_system.temporal_events : 0,
		"synthesis_events" = owner.synthesis_system ? owner.synthesis_system.synthesis_events : 0
	)

	// Store data for research integration
	research_data = current_data

/datum/scp1981_research_system/proc/contribute_research_data()
	if(!owner || !owner.SCP)
		return

	// Store research data for later integration
	// Note: Research integration will be handled by the main SCP system
