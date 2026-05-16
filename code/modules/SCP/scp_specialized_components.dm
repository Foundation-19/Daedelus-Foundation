// Specialized SCP Components for Advanced Component System
// These components handle unique abilities and mechanics for specific SCPs

// SCP-049: The Plague Doctor
/datum/scp_advanced_component/scp_049_plague_doctor
	name = "SCP-049 Plague Doctor System"
	description = "Handles plague doctor abilities and corpse reanimation"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_CRITICAL

	var/plague_level = 0
	var/max_plague_level = 100
	var/reanimation_cooldown = 0
	var/reanimation_delay = 300 SECONDS
	var/list/reanimated_corpses = list()
	var/cure_progress = 0
	var/max_cure_progress = 100

/datum/scp_advanced_component/scp_049_plague_doctor/on_initialize()
	provided_interfaces = list("plague_doctor", "reanimation")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_plague_effects"

	return TRUE

/datum/scp_advanced_component/scp_049_plague_doctor/proc/process_plague_effects(event_data)
	// Process plague effects
	if(plague_level > 0)
		for(var/mob/living/carbon/human/H in range(5, parent_mob))
			if(H.stat == DEAD)
				attempt_reanimation(H)

/datum/scp_advanced_component/scp_049_plague_doctor/proc/attempt_reanimation(mob/living/carbon/human/target)
	if(world.time < reanimation_cooldown)
		return FALSE

	reanimation_cooldown = world.time + reanimation_delay
	reanimated_corpses += target

	to_chat(parent_mob, "<span class='notice'>You have cured [target] of their illness.</span>")
	to_chat(target, "<span class='danger'>You feel an overwhelming urge to spread the cure...</span>")

	return TRUE

// SCP-096: The Shy Guy
/datum/scp_advanced_component/scp_096_shy_guy
	name = "SCP-096 Shy Guy System"
	description = "Handles rage mechanics and face viewing"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_CRITICAL

	var/rage_level = 0
	var/max_rage_level = 100
	var/rage_decay_rate = 1
	var/rage_decay_delay = 0
	var/rage_decay_interval = 10 SECONDS
	var/list/viewed_faces = list()
	var/berserk_mode = FALSE

/datum/scp_advanced_component/scp_096_shy_guy/on_initialize()
	provided_interfaces = list("shy_guy", "rage_system")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_rage_system"

	return TRUE

/datum/scp_advanced_component/scp_096_shy_guy/proc/process_rage_system(event_data)
	process_rage_decay()
	process_berserk_mode()

/datum/scp_advanced_component/scp_096_shy_guy/proc/process_rage_decay()
	if(world.time < rage_decay_delay)
		return

	rage_decay_delay = world.time + rage_decay_interval

	if(rage_level > 0)
		rage_level = max(0, rage_level - rage_decay_rate)

		if(rage_level == 0 && berserk_mode)
			end_berserk_mode()

/datum/scp_advanced_component/scp_096_shy_guy/proc/process_berserk_mode()
	if(rage_level >= max_rage_level && !berserk_mode)
		start_berserk_mode()

/datum/scp_advanced_component/scp_096_shy_guy/proc/start_berserk_mode()
	berserk_mode = TRUE
	to_chat(parent_mob, "<span class='danger'>RAGE OVERWHELMS YOU!</span>")

/datum/scp_advanced_component/scp_096_shy_guy/proc/end_berserk_mode()
	berserk_mode = FALSE
	to_chat(parent_mob, "<span class='notice'>Your rage subsides.</span>")

// SCP-106: The Old Man
/datum/scp_advanced_component/scp_106_old_man
	name = "SCP-106 Old Man System"
	description = "Handles pocket dimension and corrosion abilities"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/pocket_dimension_cooldown = 0
	var/pocket_dimension_delay = 600 SECONDS
	var/corrosion_level = 0
	var/max_corrosion_level = 100
	var/list/captured_victims = list()

/datum/scp_advanced_component/scp_106_old_man/on_initialize()
	provided_interfaces = list("old_man", "pocket_dimension")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_corrosion"

	return TRUE

/datum/scp_advanced_component/scp_106_old_man/proc/process_corrosion(event_data)
	// Process corrosion effects
	for(var/mob/living/carbon/human/H in range(3, parent_mob))
		if(H.stat != DEAD)
			H.adjust_bodytemperature(-5) // Corrosion effect

// SCP-173: The Sculpture
/datum/scp_advanced_component/scp_173_sculpture
	name = "SCP-173 Sculpture System"
	description = "Handles movement restrictions and neck snapping abilities"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_CRITICAL

	var/movement_allowed = FALSE
	var/snap_cooldown = 0
	var/snap_delay = 60 SECONDS
	var/list/observed_by = list()
	var/snap_range = 1

/datum/scp_advanced_component/scp_173_sculpture/on_initialize()
	provided_interfaces = list("sculpture", "movement_restriction", "neck_snapper")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "check_observation"

	return TRUE

/datum/scp_advanced_component/scp_173_sculpture/proc/check_observation(event_data)
	observed_by.Cut()

	for(var/mob/living/carbon/human/H in range(7, parent_mob))
		if(H.client && H.see_invisible >= parent_mob.invisibility)
			observed_by += H

	movement_allowed = (length(observed_by) == 0)

	if(!movement_allowed)
		parent_mob.vars["movement_locked"] = TRUE
	else
		parent_mob.vars["movement_locked"] = FALSE

// SCP-457: Burning Man Component
/datum/scp_advanced_component/scp_457_burning_man
	name = "SCP-457 Burning Man System"
	description = "Handles fire manipulation and heat generation"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/fire_intensity = 50
	var/max_fire_intensity = 100
	var/heat_generation = 10
	var/list/burning_targets = list()
	var/fire_spread_radius = 2

/datum/scp_advanced_component/scp_457_burning_man/on_initialize()
	provided_interfaces = list("burning_man", "fire_manipulation")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_fire_effects"

	return TRUE

/datum/scp_advanced_component/scp_457_burning_man/proc/process_fire_effects(event_data)
	for(var/mob/living/carbon/human/H in range(3, parent_mob))
		H.adjust_bodytemperature(heat_generation)

// SCP-999: Tickle Monster Component
/datum/scp_advanced_component/scp_999_tickle_monster
	name = "SCP-999 Tickle Monster System"
	description = "Handles healing and positive effects"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/healing_power = 25
	var/healing_cooldown = 0
	var/healing_delay = 30 SECONDS
	var/list/healed_targets = list()
	var/positive_aura_radius = 5

/datum/scp_advanced_component/scp_999_tickle_monster/on_initialize()
	provided_interfaces = list("tickle_monster", "healing_ability")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_positive_aura"

	return TRUE

/datum/scp_advanced_component/scp_999_tickle_monster/proc/process_positive_aura(event_data)
	for(var/mob/living/carbon/human/H in range(positive_aura_radius, parent_mob))
		if(H.stat != DEAD)
			H.vars["happiness"] = min(100, (H.vars["happiness"] || 0) + 1)

// SCP-343: God Component
/datum/scp_advanced_component/scp_343_god
	name = "SCP-343 God System"
	description = "Handles divine powers and reality manipulation"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_CRITICAL

	var/divine_power = 100
	var/max_divine_power = 100
	var/reality_manipulation_cooldown = 0
	var/reality_manipulation_delay = 600 SECONDS
	var/list/miracles_performed = list()

/datum/scp_advanced_component/scp_343_god/on_initialize()
	provided_interfaces = list("god", "divine_powers")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_divine_regeneration"

	return TRUE

/datum/scp_advanced_component/scp_343_god/proc/process_divine_regeneration(event_data)
	if(divine_power < max_divine_power)
		divine_power = min(max_divine_power, divine_power + 1)

// SCP-082: Cannibal Component
/datum/scp_advanced_component/scp_082_cannibal
	name = "SCP-082 Cannibal System"
	description = "Handles cannibalistic abilities and hunger"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/hunger_level = 0
	var/max_hunger_level = 100
	var/hunger_increase_rate = 1
	var/cannibal_cooldown = 0
	var/cannibal_delay = 180 SECONDS
	var/list/consumed_victims = list()

/datum/scp_advanced_component/scp_082_cannibal/on_initialize()
	provided_interfaces = list("cannibal", "hunger_system")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_hunger"

	return TRUE

/datum/scp_advanced_component/scp_082_cannibal/proc/process_hunger(event_data)
	hunger_level = min(max_hunger_level, hunger_level + hunger_increase_rate)

	if(hunger_level >= max_hunger_level)
		to_chat(parent_mob, "<span class='danger'>You are starving!</span>")

// SCP-939: Voice Mimic Component
/datum/scp_advanced_component/scp_939_voice_mimic
	name = "SCP-939 Voice Mimic System"
	description = "Handles voice mimicry and pack behavior"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/list/mimicked_voices = list()
	var/list/pack_members = list()
	var/voice_mimicry_cooldown = 0
	var/voice_mimicry_delay = 60 SECONDS
	var/pack_communication_range = 10

/datum/scp_advanced_component/scp_939_voice_mimic/on_initialize()
	provided_interfaces = list("voice_mimic", "pack_behavior")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_pack_communication"

	return TRUE

/datum/scp_advanced_component/scp_939_voice_mimic/proc/process_pack_communication(event_data)
	for(var/mob/living/carbon/human/pack_member in pack_members)
		if(get_dist(parent_mob, pack_member) <= pack_communication_range)
			communicate_with_pack_member(pack_member)

/datum/scp_advanced_component/scp_939_voice_mimic/proc/communicate_with_pack_member(mob/living/carbon/human/member)
	to_chat(parent_mob, "<span class='notice'>You communicate with your pack member.</span>")

// SCP-966: Sleep Killer Component
/datum/scp_advanced_component/scp_966_sleep_killer
	name = "SCP-966 Sleep Killer System"
	description = "Handles invisibility and stealth mechanics"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/invisible = TRUE
	var/stealth_mode = TRUE
	var/visibility_cooldown = 0
	var/visibility_delay = 30 SECONDS
	var/list/detected_targets = list()
	var/stealth_range = 3

/datum/scp_advanced_component/scp_966_sleep_killer/on_initialize()
	provided_interfaces = list("invisible", "stealth_mode")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_stealth_detection"

	return TRUE

/datum/scp_advanced_component/scp_966_sleep_killer/proc/process_stealth_detection(event_data)
	for(var/mob/living/carbon/human/H in range(stealth_range, parent_mob))
		if(H.stat == UNCONSCIOUS)
			if(!(H in detected_targets))
				detected_targets += H
				to_chat(parent_mob, "<span class='notice'>You detect a vulnerable target: [H]</span>")

// SCP-131: Eye Pods Component
/datum/scp_advanced_component/scp_131_eye_pods
	name = "SCP-131 Eye Pods System"
	description = "Handles enhanced vision and communication"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/enhanced_vision_range = 10
	var/communication_range = 15
	var/list/eye_pod_partners = list()
	var/vision_boost_active = TRUE

/datum/scp_advanced_component/scp_131_eye_pods/on_initialize()
	provided_interfaces = list("eye_pod", "enhanced_vision")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_enhanced_vision"

	return TRUE

/datum/scp_advanced_component/scp_131_eye_pods/proc/process_enhanced_vision(event_data)
	if(vision_boost_active)
		parent_mob.vars["see_in_dark"] = 8
		parent_mob.vars["see_invisible"] = SEE_INVISIBLE_MINIMUM

// SCP-3349: Rainbow Serpent Component
/datum/scp_advanced_component/scp_3349_rainbow_serpent
	name = "SCP-3349 Rainbow Serpent System"
	description = "Handles rainbow effects and color manipulation"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/rainbow_trail_active = TRUE
	var/color_manipulation_cooldown = 0
	var/color_manipulation_delay = 45 SECONDS
	var/list/affected_areas = list()
	var/rainbow_radius = 4

/datum/scp_advanced_component/scp_3349_rainbow_serpent/on_initialize()
	provided_interfaces = list("rainbow_serpent", "color_manipulation")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_rainbow_trail"

	return TRUE

/datum/scp_advanced_component/scp_3349_rainbow_serpent/proc/process_rainbow_trail(event_data)
	if(rainbow_trail_active)
		var/turf/current_turf = get_turf(parent_mob)
		if(!(current_turf in affected_areas))
			affected_areas += current_turf
			current_turf.overlays += image('icons/effects/effects.dmi', "rainbow")

// SCP-5295: Half Cat Component
/datum/scp_advanced_component/scp_5295_half_cat
	name = "SCP-5295 Half Cat System"
	description = "Handles cat-like abilities and transformation"
	version = "2.0.0"
	component_category = "scp_specific"
	component_priority = COMPONENT_PRIORITY_HIGH

	var/cat_form = TRUE
	var/transformation_cooldown = 0
	var/transformation_delay = 120 SECONDS
	var/list/cat_abilities = list("climbing", "stealth", "agility")
	var/agility_boost = 1.5

/datum/scp_advanced_component/scp_5295_half_cat/on_initialize()
	provided_interfaces = list("half_cat", "cat_abilities")
	required_interfaces = list("scp_identity")

	manager.subscribe_to_event(COMPONENT_EVENT_TICK, src)
	event_handlers[COMPONENT_EVENT_TICK] = "process_cat_abilities"

	return TRUE

/datum/scp_advanced_component/scp_5295_half_cat/proc/process_cat_abilities(event_data)
	if(cat_form)
		parent_mob.vars["mob_size"] = MOB_SIZE_SMALL
		parent_mob.vars["speed"] = parent_mob.vars["speed"] * agility_boost
