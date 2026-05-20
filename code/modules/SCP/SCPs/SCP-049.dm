// SCP-049 - The Plague Doctor
// Complete Foundation-19 implementation with persistence and sanity integration
// Ported from: https://github.com/Foundation-19/Daedelus-Foundation/pull/13/files

/mob/living/scp/scp049
	ai_enabled = TRUE
	name = "SCP-049"
	desc = "A tall humanoid figure wearing the black robes and bird-like mask of a medieval plague doctor."
	icon = 'icons/scp/scp-049.dmi'
	icon_state = ""
	real_name = "SCP-049"
	persistence_id = "SCP-049"

	// Core mechanics from Foundation-19
	var/pestilence_level = 0
	var/max_pestilence_level = SCP049_MAX_PESTILENCE_LEVEL
	var/pestilence_detect_radius = SCP049_PESTILENCE_SPREAD_RADIUS
	var/pestilence_detect_chance = SCP049_PESTILENCE_INFECTION_CHANCE
	var/pestilence_cooldown = 0
	var/pestilence_cooldown_time = SCP049_PESTILENCE_COOLDOWN

	// Cure mechanics
	var/cure_potency = 1
	var/max_cure_potency = SCP049_MAX_CURE_POTENCY
	var/cure_cooldown = 0
	var/cure_cooldown_time = SCP049_CURE_COOLDOWN
	var/cure_range = SCP049_CURE_RANGE
	var/cure_effectiveness = SCP049_CURE_EFFECTIVENESS

	// Door breaching
	var/breach_cooldown = 0
	var/breach_cooldown_time = SCP049_BREACH_COOLDOWN
	var/breach_range = SCP049_BREACH_RANGE
	var/breach_power = SCP049_BREACH_POWER

	// Research and evolution
	var/research_progress = 0
	var/max_research_progress = SCP049_MAX_RESEARCH_PROGRESS
	var/evolution_stage = 1
	var/max_evolution_stage = SCP049_MAX_EVOLUTION_STAGE
	var/research_cooldown = 0
	var/research_cooldown_time = SCP049_RESEARCH_COOLDOWN

	// Audio and announcements (Foundation-19 style)
	var/last_announcement = 0
	var/announcement_cooldown = SCP049_ANNOUNCEMENT_COOLDOWN
	var/list/announcement_messages = list(
		"The pestilence must be cured...",
		"I can see the disease within you...",
		"The cure is within my grasp...",
		"Death is not the end, but the beginning of the cure...",
		"I will save you all from the pestilence...",
		"My work here is not yet complete...",
		"The Great Work must continue..."
	)

	// Enhanced persistence tracking
	var/detections_performed = 0
	var/cures_attempted = 0
	var/cures_successful = 0
	var/research_breakthroughs = 0
	var/evolution_events = 0
	var/session_start_time = 0
	var/turf/lure_target = null
	var/total_playtime = 0

	// Command system for SCP-049-1 servants
	var/datum/scp049_command_system/command_system

	// Progression integration tracking
	var/containment_breaches = 0

/mob/living/scp/scp049/Initialize()
	. = ..()

	faction |= "scp049"

	// Set proper species (Foundation-19 approach)
	// Create SCP datum with proper flags
	SCP = new /datum/scp(src, "Plague Doctor", SCP_EUCLID, "049", SCP_SENTIENT)

	// Add door breacher component
	AddComponent(/datum/component/doorBreacher, breach_range, breach_power, breach_cooldown_time, 'sound/scp/scp049/SCP049_2.ogg', "breaches through the doors with unnatural force!")

	// Set session start time
	session_start_time = world.time

	// Initialize command system
	command_system = new /datum/scp049_command_system(src)

	// Set up HUD systems
	setup_pestilence_hud()

	// Initial announcement
	announce_presence()

	// Load persistence data
	load_persistence_data()

	// Remove bodypart overlays to prevent covering the SCP icon

	// Grant language
	grant_language(/datum/language/common, TRUE, TRUE)

/mob/living/scp/scp049/proc/setup_pestilence_hud()
	// Add pestilence HUD capability (handled by species)
	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.add_atom_to_hud(src)

/mob/living/scp/scp049/proc/announce_presence()
	if(world.time < last_announcement + announcement_cooldown)
		return

	last_announcement = world.time
	var/announcement = pick(announcement_messages)

	// Play characteristic audio (Foundation-19 approach)
	playsound(src, 'sound/scp/scp049/SCP049_1.ogg', 50, 0)

	// Send announcement to nearby players
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.z == z && get_dist(H, src) <= 15)
			to_chat(H, "<span class='danger'><b>[announcement]</b></span>")

			// Apply sanity effects for non-Foundation personnel
			if(H.job != "Site Director" && H.job != "Research Director" && H.job != "Senior Researcher")
				if(H.sanity)
					H.sanity.adjust_sanity(-5, "Heard SCP-049 speak")
				continue

// Pestilence detection (SCP-049 senses the Pestilence in others — its delusion)
/mob/living/scp/scp049/proc/detect_pestilence()
	if(world.time < pestilence_cooldown)
		to_chat(src, "<span class='warning'>You need a moment to sense the Pestilence again...</span>")
		return FALSE

	pestilence_cooldown = world.time + pestilence_cooldown_time

	pestilence_level = min(max_pestilence_level, pestilence_level + 10)

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/H in range(pestilence_detect_radius, src))
		if(H != src && !isscp049_1(H))
			nearby_targets += H

	var/detected_count = 0
	for(var/mob/living/carbon/human/H in nearby_targets)
		if(prob(pestilence_detect_chance + (pestilence_level / 10)))
			mark_pestilence(H)
			on_pestilence_detected(H)
			detected_count++

	detections_performed++

	playsound(src, 'sound/scp/scp049/SCP049_2.ogg', 80, 0)
	visible_message("<span class='danger'>[src] senses the Pestilence in those nearby, eyes narrowing behind the mask...</span>")

	to_chat(src, "<span class='notice'>Pestilence detected in [detected_count] subjects. Level: [pestilence_level]/[max_pestilence_level]</span>")

	save_persistence_data()
	return TRUE

/mob/living/scp/scp049/proc/mark_pestilence(mob/living/carbon/human/target)
	if(!target)
		return FALSE

	if(HAS_TRAIT(target, TRAIT_PESTILENCE_IMMUNE))
		to_chat(src, "<span class='warning'>[target] appears... free of the Pestilence. Intriguing.</span>")
		return FALSE

	if(HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(src, "<span class='notice'>The Pestilence still festers within [target]...</span>")
		return FALSE

	ADD_TRAIT(target, TRAIT_PESTILENCE, "scp049")
	target.update_pestilence_hud()

	to_chat(src, "<span class='notice'>You sense the Pestilence within [target]... They must be cured.</span>")
	playsound(target, 'sound/scp/scp049/SCP049_3.ogg', 30, 0)

	if(target.sanity)
		target.sanity.adjust_sanity(-10, "Sensed by SCP-049 as Pestilence carrier")

/mob/living/scp/scp049/proc/isscp049_1(mob/M)
	return istype(M, /mob/living/simple_animal/hostile/zombie/scp049_1)



// Enhanced cure mechanics (Foundation-19 approach)
/mob/living/scp/scp049/proc/cure_target(mob/living/carbon/human/target)
	if(world.time < cure_cooldown)
		to_chat(src, "<span class='warning'>The cure needs time to prepare...</span>")
		return FALSE

	if(!target)
		to_chat(src, "<span class='warning'>There is no subject to cure.</span>")
		return FALSE

	if(get_dist(src, target) > cure_range)
		to_chat(src, "<span class='warning'>You must be closer to administer the cure.</span>")
		return FALSE

	cure_cooldown = world.time + cure_cooldown_time
	cures_attempted++

	visible_message("<span class='notice'>[src] begins the great work on [target]...</span>")
	playsound(src, 'sound/scp/scp049/SCP049_Cure1.ogg', 60, 0)

	if(!HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(src, "<span class='notice'>Ah... you are afflicted with the Pestilence. I can sense it. Allow me to cure you.</span>")
	else
		to_chat(src, "<span class='notice'>Yes... the Pestilence is strong in this one. The cure must be administered.</span>")

	to_chat(target, "<span class='danger'>SCP-049's touch is cold beyond imagination... The 'cure' is agony beyond description...</span>")

	on_cure_attempt(target)

	if(target.sanity)
		target.sanity.adjust_sanity(-30, "Touched by SCP-049 — the cure")

	track_scp049_cure(src, target, TRUE)

	create_scp049_1(target)

	cures_successful++
	cure_potency = min(max_cure_potency, cure_potency + 1)
	playsound(src, 'sound/scp/scp049/SCP049_Cure2.ogg', 60, 0)

	save_persistence_data()
	return TRUE

/mob/living/scp/scp049/proc/create_scp049_1(mob/living/carbon/human/target)
	var/turf/T = get_turf(target)
	target.dust(just_ash = FALSE, drop_items = TRUE, force = TRUE)

	var/mob/living/simple_animal/hostile/zombie/scp049_1/zombie = new(T)
	zombie.name = "SCP-049-1"
	zombie.real_name = "SCP-049-1"
	zombie.maxHealth = target.maxHealth * 1.5
	zombie.health = zombie.maxHealth

	zombie.melee_damage_lower = SCP049_1_MELEE_DAMAGE_LOWER
	zombie.melee_damage_upper = SCP049_1_MELEE_DAMAGE_UPPER
	zombie.move_to_delay = SCP049_1_MOVE_DELAY
	zombie.setup_servant(src)
	if(target.client)
		zombie.key = target.key
		to_chat(zombie, "<span class='danger'>You have been converted into SCP-049-1! You are now a mindless servant of SCP-049.</span>")

	visible_message("<span class='danger'>[target] has been converted into SCP-049-1!</span>")
	playsound(src, 'sound/scp/scp049/SCP049_4.ogg', 70, 0)

// Door breaching (uses component)
/mob/living/scp/scp049/proc/breach_doors()
	// Trigger the door breacher component
	SEND_SIGNAL(src, COMSIG_MOB_BREACH_DOORS)

// Research mechanics
/mob/living/scp/scp049/proc/research_cure()
	if(world.time < research_cooldown)
		to_chat(src, "<span class='warning'>More research time is required...</span>")
		return FALSE

	research_cooldown = world.time + research_cooldown_time
	research_progress += rand(10, 25)

	to_chat(src, "<span class='notice'>Research progress: [research_progress]/[max_research_progress]</span>")

	if(research_progress >= max_research_progress)
		trigger_evolution()

	save_persistence_data()
	return TRUE

/mob/living/scp/scp049/proc/trigger_evolution()
	if(evolution_stage >= max_evolution_stage)
		to_chat(src, "<span class='notice'>You have achieved the pinnacle of the Great Work.</span>")
		return

	evolution_stage++
	evolution_events++
	research_progress = 0

	// Enhanced abilities per evolution stage
	switch(evolution_stage)
		if(2)
			pestilence_detect_radius++
			cure_effectiveness += 10
			to_chat(src, "<span class='notice'>Your understanding deepens. You can sense the Pestilence from farther away.</span>")
		if(3)
			pestilence_detect_chance += 10
			cure_range++
			to_chat(src, "<span class='notice'>Your cure becomes more refined and potent.</span>")
		if(4)
			max_pestilence_level += 50
			breach_power += 25
			to_chat(src, "<span class='notice'>Your influence grows stronger. Barriers mean nothing.</span>")
		if(5)
			to_chat(src, "<span class='notice'>You have achieved perfect understanding of the Great Work.</span>")
			apply_stage_5_abilities()

	research_breakthroughs++
	on_evolution()
	announce_evolution()
	save_persistence_data()

/mob/living/scp/scp049/proc/announce_evolution()
	var/announcement = "SCP-049 has evolved to stage [evolution_stage]! The Great Work progresses..."
	for(var/mob/M in GLOB.player_list)
		if(QDELETED(M))
			continue
		to_chat(M, "<span class='danger'><b>[announcement]</b></span>")
	playsound(src, 'sound/scp/scp049/SCP049_5.ogg', 100, 0)

// Enhanced persistence integration
/mob/living/scp/scp049/proc/save_persistence_data()
	var/list/persistence_data = list(
		"pestilence_level" = pestilence_level,
		"cure_potency" = cure_potency,
		"evolution_stage" = evolution_stage,
		"research_progress" = research_progress,
		"detections_performed" = detections_performed,
		"cures_attempted" = cures_attempted,
		"cures_successful" = cures_successful,
		"research_breakthroughs" = research_breakthroughs,
		"evolution_events" = evolution_events,
		"total_playtime" = total_playtime + (world.time - session_start_time)
	)

	if(SSscp_persistence && SSscp_persistence.manager)
		SSscp_persistence.manager.save_scp_data("SCP-049", persistence_data)

/mob/living/scp/scp049/proc/load_persistence_data()
	if(SSscp_persistence && SSscp_persistence.manager)
		var/list/persistence_data = SSscp_persistence.manager.load_scp_data("SCP-049")
		if(persistence_data)
			pestilence_level = persistence_data["pestilence_level"] || 0
			cure_potency = persistence_data["cure_potency"] || 1
			evolution_stage = persistence_data["evolution_stage"] || 1
			research_progress = persistence_data["research_progress"] || 0
			detections_performed = persistence_data["detections_performed"] || 0
			cures_attempted = persistence_data["cures_attempted"] || 0
			cures_successful = persistence_data["cures_successful"] || 0
			research_breakthroughs = persistence_data["research_breakthroughs"] || 0
			evolution_events = persistence_data["evolution_events"] || 0
			total_playtime = persistence_data["total_playtime"] || 0

/mob/living/scp/scp049/proc/detect_pestilence_verb()
	detect_pestilence()

/mob/living/scp/scp049/proc/breach_doors_verb()
	breach_doors()

/mob/living/scp/scp049/proc/research_cure_verb()
	research_cure()

/mob/living/scp/scp049/proc/announce_verb()
	announce_presence()

/mob/living/scp/scp049/proc/show_status_verb()
	show_status()

/mob/living/scp/scp049/proc/show_status()
	var/status_text = "<b>SCP-049 Status Report:</b><br>"
	status_text += "Pestilence Level: [pestilence_level]/[max_pestilence_level]<br>"
	status_text += "Cure Potency: [cure_potency]/[max_cure_potency]<br>"
	status_text += "Evolution Stage: [evolution_stage]/[max_evolution_stage]<br>"
	status_text += "Research Progress: [research_progress]/[max_research_progress]<br>"
	status_text += "<br><b>Statistics:</b><br>"
	status_text += "Detections Performed: [detections_performed]<br>"
	status_text += "Cures Attempted: [cures_attempted] (Successful: [cures_successful])<br>"
	status_text += "Research Breakthroughs: [research_breakthroughs]<br>"
	status_text += "Total Playtime: [round((total_playtime + (world.time - session_start_time))/600, 0.1)] minutes"

	to_chat(src, status_text)

// Visual effect for pestilence spread
/obj/effect/temp_visual/pestilence_spread
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	duration = 3 SECONDS
	color = "#00ff00"

// Progression Integration Hooks
/mob/living/scp/scp049/proc/on_cure_attempt(mob/living/carbon/human/target)
	if(!target || !target.ckey)
		return
	
	var/list/data = list("success" = FALSE)
	hook_scp_interaction(target, "SCP-049", INTERACTION_TYPE_MEDICAL, data)
	hook_scp_combat(target, "SCP-049", 50, 0)

/mob/living/scp/scp049/proc/on_pestilence_detected(mob/living/carbon/human/target)
	if(!target || !target.ckey)
		return
	
	hook_scp_combat(target, "SCP-049", 0, 0)
	start_scp_survival_tracking(target, "SCP-049", INTERACTION_RISK_HIGH)

/mob/living/scp/scp049/proc/on_evolution()
	if(SSscp_specializations && SSscp_specializations.manager && src.ckey)
		SSscp_specializations.manager.add_specialization_xp(src.ckey, SPEC_TRACK_RESEARCH, 100)

/mob/living/scp/scp049/proc/on_breach()
	containment_breaches++
	hook_scp_breach("SCP-049", src)

/mob/living/scp/scp049/proc/on_recontainment()
	hook_scp_recontainment("SCP-049", list("method" = "standard"))

/mob/living/scp/scp049/Destroy()
	QDEL_NULL(command_system)
	QDEL_NULL(SCP)
	announcement_messages = null
	lure_target = null
	return ..()
