/datum/scp939_voice_system
	var/mob/living/scp/scp939/owner = null
	var/list/learned_voices = list()
	var/mimicry_accuracy = SCP939_INITIAL_MIMICRY_ACCURACY
	var/max_mimicry_accuracy = SCP939_MAX_MIMICRY_ACCURACY
	var/current_mimicked_voice = null
	var/speech_cooldown = 0
	var/speech_cooldown_time = SCP939_SPEECH_COOLDOWN
	var/learning_rate = 1.0
	var/voice_retention = SCP939_VOICE_RETENTION
	var/last_voice_learning = 0
	var/voice_learning_interval = SCP939_VOICE_LEARNING_INTERVAL

/datum/scp939_voice_system/New(mob/living/scp/scp939/new_owner)
	. = ..()
	owner = new_owner

/datum/scp939_voice_system/Destroy()
	learned_voices = null
	owner = null
	return ..()

/datum/scp939_voice_system/proc/process_voice()
	if(world.time >= last_voice_learning + voice_learning_interval)
		scan_for_voices()
		last_voice_learning = world.time

	if(speech_cooldown > 0)
		speech_cooldown = max(0, speech_cooldown - 1)

/datum/scp939_voice_system/proc/scan_for_voices()
	if(!owner || owner.stat == DEAD)
		return

	for(var/mob/living/carbon/human/H in view(7, owner))
		if(H.stat != DEAD && H != owner)
			learn_voice(H)

/datum/scp939_voice_system/proc/learn_voice(mob/living/carbon/human/speaker)
	if(!speaker || !speaker.name)
		return

	var/voice_id = speaker.name
	if(!learned_voices[voice_id])
		learned_voices[voice_id] = list(
			"name" = speaker.name,
			"voice_pattern" = generate_voice_pattern(speaker),
			"usage_count" = 0,
			"last_heard" = world.time,
			"accuracy" = 30
		)

	var/list/voice_data = learned_voices[voice_id]
	voice_data["last_heard"] = world.time
	voice_data["usage_count"]++

	voice_data["accuracy"] = min(100, voice_data["accuracy"] + learning_rate)

/datum/scp939_voice_system/proc/generate_voice_pattern(mob/living/carbon/human/speaker)
	var/pattern = ""
	pattern += "[speaker.gender]"
	pattern += "[speaker.age]"
	return pattern

/datum/scp939_voice_system/proc/mimic_voice(voice_id, message, emotion = null)
	if(speech_cooldown > 0)
		return FALSE

	if(!learned_voices[voice_id])
		return FALSE

	var/list/voice_data = learned_voices[voice_id]
	var/accuracy = voice_data["accuracy"] * (mimicry_accuracy / 100)

	if(prob(accuracy))
		owner.say(message)
		speech_cooldown = speech_cooldown_time
		current_mimicked_voice = voice_id

		apply_voice_effects(message, voice_id, emotion)
		return TRUE

	return FALSE

/datum/scp939_voice_system/proc/apply_voice_effects(message, voice_id, emotion)
	for(var/mob/living/carbon/human/H in view(7, owner))
		if(H.stat != DEAD && H != owner)
			if(H.sanity)
				H.sanity.adjust_sanity(-5, "voice_mimicry")

			if(prob(30))
				H.visible_message(span_warning("[H] looks confused and frightened."))

/datum/scp939_pack_system
	var/mob/living/scp/scp939/owner = null
	var/list/pack_members = list()
	var/list/hunting_formation = list()
	var/list/territory_boundaries = list()
	var/pack_communication_cooldown = 0
	var/pack_communication_time = SCP939_PACK_COMMUNICATION_COOLDOWN
	var/last_pack_update = 0
	var/pack_update_interval = SCP939_PACK_UPDATE_INTERVAL

/datum/scp939_pack_system/New(mob/living/scp/scp939/new_owner)
	. = ..()
	owner = new_owner
	find_pack_members()

/datum/scp939_pack_system/Destroy()
	pack_members = null
	owner = null
	return ..()

/datum/scp939_pack_system/proc/process_pack()
	if(world.time >= last_pack_update + pack_update_interval)
		find_pack_members()
		last_pack_update = world.time

	if(pack_communication_cooldown > 0)
		pack_communication_cooldown = max(0, pack_communication_cooldown - 1)

/datum/scp939_pack_system/proc/find_pack_members()
	pack_members.Cut()
	for(var/mob/living/scp/scp939/H in GLOB.mob_list)
		if(QDELETED(H))
			continue
		if(H == owner || H.stat == DEAD)
			continue
		if(H.z == owner.z)
			pack_members += H
			if(H.pack_system)
				H.pack_system.pack_members |= owner

/datum/scp939_pack_system/proc/coordinate_with_pack()
	if(pack_communication_cooldown > 0)
		return FALSE

	for(var/mob/living/scp/scp939/member in pack_members)
		if(QDELETED(member))
			continue
		if(member.stat != DEAD && member.pack_system)
			member.pack_system.receive_coordination(owner)

	pack_communication_cooldown = pack_communication_time
	return TRUE

/datum/scp939_pack_system/proc/receive_coordination(mob/living/scp/scp939/coordinator)
	if(coordinator.hunting_system && coordinator.hunting_system.current_target)
		owner.hunting_system?.share_target(coordinator.hunting_system.current_target)

/datum/scp939_pack_system/proc/establish_territory()
	var/area/current_area = get_area(owner)
	if(current_area && !(current_area in territory_boundaries))
		territory_boundaries += current_area
		return TRUE
	return FALSE

/datum/scp939_psychology_system
	var/mob/living/scp/scp939/owner = null
	var/list/target_profiles = list()
	var/list/manipulation_tactics = list()
	var/last_psychology_update = 0
	var/psychology_update_interval = SCP939_PSYCHOLOGY_UPDATE_INTERVAL

/datum/scp939_psychology_system/New(mob/living/scp/scp939/new_owner)
	. = ..()
	owner = new_owner
	setup_manipulation_tactics()

/datum/scp939_psychology_system/Destroy()
	target_profiles = null
	owner = null
	return ..()

/datum/scp939_psychology_system/proc/process_psychology()
	if(world.time >= last_psychology_update + psychology_update_interval)
		update_psychological_profiles()
		last_psychology_update = world.time

/datum/scp939_psychology_system/proc/setup_manipulation_tactics()
	manipulation_tactics = list(
		"trust_violation" = "Use familiar voices to betray expectations",
		"isolation" = "Separate targets from groups using voice calls",
		"false_hope" = "Offer apparent rescue to increase despair",
		"authority_confusion" = "Undermine command structure with false orders",
		"social_exploitation" = "Use knowledge of relationships against targets"
	)

/datum/scp939_psychology_system/proc/update_psychological_profiles()
	for(var/mob/living/carbon/human/H in view(10, owner))
		if(H.stat != DEAD && H != owner)
			analyze_target_psychology(H)

/datum/scp939_psychology_system/proc/analyze_target_psychology(mob/living/carbon/human/target)
	var/target_id = target.name
	if(!target_profiles[target_id])
		target_profiles[target_id] = list(
			"name" = target.name,
			"fear_level" = 0,
			"trust_level" = 100,
			"social_bonds" = list(),
			"vulnerabilities" = list(),
			"last_analysis" = world.time
		)

	var/list/profile = target_profiles[target_id]
	profile["last_analysis"] = world.time

	if(target.sanity)
		profile["fear_level"] = 100 - target.sanity.sanity_level
		profile["trust_level"] = max(0, profile["trust_level"] - 5)

/datum/scp939_psychology_system/proc/apply_psychological_pressure(mob/living/carbon/human/target)
	var/target_id = target.name
	if(!target_profiles[target_id])
		return FALSE

	var/list/profile = target_profiles[target_id]

	if(target.sanity)
		target.sanity.adjust_sanity(-10, "psychological_pressure")

	profile["trust_level"] = max(0, profile["trust_level"] - 10)

	target.visible_message(span_warning("[target] looks increasingly terrified."))
	return TRUE

/datum/scp939_psychology_system/proc/exploit_social_bonds(mob/living/carbon/human/target, relationship)
	var/target_id = target.name
	if(!target_profiles[target_id])
		return FALSE

	var/list/profile = target_profiles[target_id]
	if(relationship in profile["social_bonds"])
		if(target.sanity)
			target.sanity.adjust_sanity(-15, "social_exploitation")
		return TRUE

	return FALSE

/datum/scp939_territory_system
	var/mob/living/scp/scp939/owner = null
	var/list/controlled_areas = list()
	var/list/patrol_routes = list()
	var/list/ambush_points = list()
	var/list/escape_routes = list()
	var/list/resource_caches = list()
	var/territory_radius = SCP939_BASE_TERRITORY_RADIUS
	var/max_territory_radius = SCP939_MAX_TERRITORY_RADIUS
	var/last_territory_update = 0
	var/territory_update_interval = SCP939_TERRITORY_UPDATE_INTERVAL

/datum/scp939_territory_system/New(mob/living/scp/scp939/new_owner)
	. = ..()
	owner = new_owner

/datum/scp939_territory_system/Destroy()
	controlled_areas = null
	owner = null
	return ..()

/datum/scp939_territory_system/proc/process_territory()
	if(world.time >= last_territory_update + territory_update_interval)
		update_territory_control()
		last_territory_update = world.time

/datum/scp939_territory_system/proc/update_territory_control()
	var/area/current_area = get_area(owner)
	if(current_area && !(current_area in controlled_areas))
		controlled_areas += current_area
		establish_patrol_routes(current_area)

/datum/scp939_territory_system/proc/establish_patrol_routes(area/territory)
	var/list/routes = list()
	for(var/turf/T in territory)
		if(prob(5))
			routes += T

	patrol_routes[territory] = routes

/datum/scp939_territory_system/proc/prepare_ambush_point(turf/location)
	if(!(location in ambush_points))
		ambush_points += location
		return TRUE
	return FALSE

/datum/scp939_territory_system/proc/is_in_controlled_territory(atom/target)
	var/area/target_area = get_area(target)
	return target_area in controlled_areas

/datum/scp939_hunting_system
	var/mob/living/scp/scp939/owner = null
	var/list/hunting_targets = list()
	var/mob/living/carbon/human/current_target = null
	var/hunt_mode = FALSE
	var/ambush_prepared = FALSE
	var/list/hunting_strategies = list()
	var/current_strategy = null
	var/last_hunt_update = 0
	var/hunt_update_interval = SCP939_HUNT_UPDATE_INTERVAL

/datum/scp939_hunting_system/New(mob/living/scp/scp939/new_owner)
	. = ..()
	owner = new_owner
	setup_hunting_strategies()

/datum/scp939_hunting_system/Destroy()
	hunting_targets = null
	current_target = null
	owner = null
	return ..()

/datum/scp939_hunting_system/proc/process_hunting()
	if(world.time >= last_hunt_update + hunt_update_interval)
		update_hunting_status()
		last_hunt_update = world.time

/datum/scp939_hunting_system/proc/setup_hunting_strategies()
	hunting_strategies = list(
		"lure" = "Use voice mimicry to attract targets",
		"ambush" = "Set up coordinated ambush points",
		"pack_hunt" = "Coordinate with pack members",
		"psychological" = "Use psychological manipulation",
		"territorial" = "Use territory control advantages"
	)

/datum/scp939_hunting_system/proc/update_hunting_status()
	if(!current_target || current_target.stat == DEAD)
		current_target = null
		hunt_mode = FALSE
		return

	if(get_dist(owner, current_target) > 15)
		current_target = null
		hunt_mode = FALSE
		return

	execute_hunting_strategy()

/datum/scp939_hunting_system/proc/identify_targets()
	hunting_targets.Cut()

	for(var/mob/living/carbon/human/H in view(10, owner))
		if(H.stat != DEAD && H != owner)
			var/target_score = calculate_target_score(H)
			hunting_targets[H] = target_score

/datum/scp939_hunting_system/proc/calculate_target_score(mob/living/carbon/human/target)
	var/score = 0

	var/nearby_allies = 0
	for(var/mob/living/carbon/human/H in view(3, target))
		if(H != target && H.stat != DEAD)
			nearby_allies++

	score += (5 - nearby_allies) * 10

	if(target.health < 50)
		score += 20

	if(target.sanity && target.sanity.sanity_level < 50)
		score += 15

	return score

/datum/scp939_hunting_system/proc/select_target()
	identify_targets()

	if(length(hunting_targets) > 0)
		current_target = hunting_targets[1]
		hunt_mode = TRUE
		return TRUE

	return FALSE

/datum/scp939_hunting_system/proc/execute_hunting_strategy()
	if(!current_target)
		return

	if(!current_strategy)
		current_strategy = choose_strategy()

	switch(current_strategy)
		if("lure")
			execute_lure_strategy()
		if("ambush")
			execute_ambush_strategy()
		if("pack_hunt")
			execute_pack_hunt_strategy()
		if("psychological")
			execute_psychological_strategy()
		if("territorial")
			execute_territorial_strategy()

/datum/scp939_hunting_system/proc/choose_strategy()
	if(owner.pack_system && length(owner.pack_system.pack_members) > 0)
		return "pack_hunt"
	else if(owner.territory_system && owner.territory_system.is_in_controlled_territory(current_target))
		return "territorial"
	else if(owner.psychology_system && owner.psychology_system.target_profiles[current_target.name])
		return "psychological"
	else if(owner.territory_system && length(owner.territory_system.ambush_points) > 0)
		return "ambush"
	else
		return "lure"

/datum/scp939_hunting_system/proc/execute_lure_strategy()
	if(!current_target || !owner.voice_system)
		return

	var/list/available_voices = owner.voice_system.learned_voices
	if(length(available_voices) > 0)
		var/voice_id = pick(available_voices)
		var/message = "Help! I'm hurt! Please come quickly!"
		owner.voice_system.mimic_voice(voice_id, message, "distress")

/datum/scp939_hunting_system/proc/execute_ambush_strategy()
	if(!current_target || !owner.territory_system)
		return

	var/list/ambush_points = owner.territory_system.ambush_points
	if(length(ambush_points) > 0)
		var/turf/ambush_point = pick(ambush_points)
		if(get_dist(owner, ambush_point) > 1)
			step_towards(owner, ambush_point)

/datum/scp939_hunting_system/proc/execute_pack_hunt_strategy()
	if(!current_target || !owner.pack_system)
		return

	owner.pack_system.coordinate_with_pack()

	share_target(current_target)

/datum/scp939_hunting_system/proc/execute_psychological_strategy()
	if(!current_target || !owner.psychology_system)
		return

	owner.psychology_system.apply_psychological_pressure(current_target)

/datum/scp939_hunting_system/proc/execute_territorial_strategy()
	if(!current_target || !owner.territory_system)
		return

	if(owner.territory_system.is_in_controlled_territory(current_target))
		if(get_dist(owner, current_target) <= 1)
			attack_target(current_target)

/datum/scp939_hunting_system/proc/share_target(mob/living/carbon/human/target)
	if(!owner.pack_system)
		return
	for(var/mob/living/scp/scp939/member in owner.pack_system.pack_members)
		if(QDELETED(member))
			continue
		if(member.hunting_system && member != owner)
			member.hunting_system.current_target = target
			member.hunting_system.hunt_mode = TRUE

/datum/scp939_hunting_system/proc/attack_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	target.adjustBruteLoss(25)
	owner.visible_message(span_danger("[owner] viciously attacks [target]!"))

	if(target.sanity)
		target.sanity.adjust_sanity(-20, "scp939_attack")

	if(target.health <= 0)
		current_target = null
		hunt_mode = FALSE

/datum/scp939_research_integration
	var/mob/living/scp/scp939/owner = null
	var/list/research_data = list()
	var/last_research_update = 0
	var/research_update_interval = 120 SECONDS

/datum/scp939_research_integration/New(mob/living/scp/scp939/new_owner)
	. = ..()
	owner = new_owner

/datum/scp939_research_integration/proc/process_research()
	if(world.time >= last_research_update + research_update_interval)
		update_research_data()
		last_research_update = world.time

/datum/scp939_research_integration/proc/update_research_data()
	var/current_data = list(
		"learned_voices_count" = length(owner.voice_system?.learned_voices) || 0,
		"mimicry_accuracy" = owner.voice_system?.mimicry_accuracy || 0,
		"pack_members_count" = length(owner.pack_system?.pack_members) || 0,
		"controlled_areas_count" = length(owner.territory_system?.controlled_areas) || 0,
		"current_target" = owner.hunting_system?.current_target?.name || "none",
		"hunt_mode" = owner.hunting_system?.hunt_mode || FALSE,
		"timestamp" = world.time
	)

	research_data["last_update"] = current_data
