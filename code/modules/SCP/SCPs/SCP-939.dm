// SCP-939 - With Many Voices
// A blind, pack-hunting predator that mimics human voices to lure prey.
// Thematic accuracy: SCP-939 is completely blind. It navigates by sound and smell.
// It cannot see anything visually — it detects humans through audio cues and voice mimicry.
// In-game: TRAIT_BLIND is applied. The mob uses sound-based detection to "see" nearby mobs
// as temporary blips rather than actual visual contact.

/mob/living/scp/scp939
	name = "SCP-939"
	desc = "A large, eyeless predator. Its mouth is filled with needle-like teeth. It has no eyes — it hunts by sound."
	icon = 'icons/scp/scp_939.dmi'
	icon_state = "crawling"
	real_name = "SCP-939"
	persistence_id = "SCP-939"

	var/datum/scp939_voice_system/voice_system
	var/datum/scp939_pack_system/pack_system
	var/datum/scp939_psychology_system/psychology_system
	var/datum/scp939_territory_system/territory_system
	var/datum/scp939_hunting_system/hunting_system
	var/datum/scp939_research_integration/research_integration

	var/list/detected_mobs = list()
	var/last_detection_scan = 0
	var/detection_scan_interval = 2 SECONDS
	var/detection_range = 12
	var/scent_range = 7

/mob/living/scp/scp939/Initialize()
	. = ..()

	voice_system = new /datum/scp939_voice_system(src)
	pack_system = new /datum/scp939_pack_system(src)
	psychology_system = new /datum/scp939_psychology_system(src)
	territory_system = new /datum/scp939_territory_system(src)
	hunting_system = new /datum/scp939_hunting_system(src)
	research_integration = new /datum/scp939_research_integration(src)

	SCP = new /datum/scp(
		src,
		"SCP-939",
		SCP_KETER,
		"939",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 20
	SCP.min_time = 30 MINUTES

	maxHealth = SCP939_MAX_HEALTH
	health = maxHealth

	ADD_TRAIT(src, TRAIT_BLIND, SCP_TRAIT)

	fovangle = 360
	update_fov_angles()
	update_cone_show()

/mob/living/scp/scp939/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return
	if(stat == DEAD)
		return

	voice_system?.process_voice()
	pack_system?.process_pack()
	psychology_system?.process_psychology()
	territory_system?.process_territory()
	hunting_system?.process_hunting()
	research_integration?.process_research()

	process_sound_detection()

/mob/living/scp/scp939/Destroy()
	QDEL_NULL(voice_system)
	QDEL_NULL(pack_system)
	QDEL_NULL(psychology_system)
	QDEL_NULL(territory_system)
	QDEL_NULL(hunting_system)
	QDEL_NULL(research_integration)
	REMOVE_TRAIT(src, TRAIT_BLIND, SCP_TRAIT)
	detected_mobs = null
	return ..()

/mob/living/scp/scp939/proc/process_sound_detection()
	if(world.time < last_detection_scan + detection_scan_interval)
		return
	last_detection_scan = world.time

	detected_mobs.Cut()

	for(var/mob/living/carbon/human/H in range(detection_range, src))
		if(H == src || H.stat == DEAD || QDELETED(H))
			continue
		if(can_detect_mob(H))
			var/distance = get_dist(src, H)
			var/accuracy = max(1, 100 - (distance * 8))
			detected_mobs[H] = list(
				"direction" = get_dir(src, H),
				"distance" = distance,
				"certainty" = accuracy,
				"last_updated" = world.time
			)

/mob/living/scp/scp939/proc/can_detect_mob(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return FALSE

	var/distance = get_dist(src, target)
	if(distance > detection_range)
		return FALSE

	if(!HAS_TRAIT(target, TRAIT_NOBREATH))
		return TRUE

	if(distance <= scent_range)
		return TRUE

	return FALSE

/mob/living/scp/scp939/UnarmedAttack(atom/A)
	if(ismob(A))
		on_attack_mob(A)
		return
	return ..()

/mob/living/scp/scp939/proc/on_attack_mob(mob/living/target)
	if(!istype(target) || target == src)
		return
	target.adjustBruteLoss(25)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.sanity)
			H.sanity.adjust_sanity(-10, "scp939_attack")
	target.visible_message(span_danger("[src] slashes [target] with razor-sharp claws!"), \
		span_userdanger("[src] tears into you with its claws!"))
	playsound(target, 'sound/weapons/slash.ogg', 60, TRUE)

	if(ishuman(target))
		voice_system?.learn_voice(target)

/mob/living/scp/scp939/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), atom/sound_loc, message_range)
	. = ..()
	if(speaker && ishuman(speaker))
		voice_system?.learn_voice(speaker)
		var/distance = get_dist(src, speaker)
		if(distance <= detection_range)
			detected_mobs[speaker] = list(
				"direction" = get_dir(src, speaker),
				"distance" = distance,
				"certainty" = max(1, 100 - (distance * 8)),
				"last_updated" = world.time
			)

/mob/living/scp/scp939/get_status_tab_items()
	var/list/status_items = ..()
	if(voice_system)
		status_items += "Learned Voices: [length(voice_system.learned_voices)]"
	if(pack_system)
		status_items += "Pack Members: [length(pack_system.pack_members)]"
	status_items += "Detected Prey: [length(detected_mobs)]"
	if(hunting_system)
		status_items += "Hunt Mode: [hunting_system.hunt_mode ? "ACTIVE" : "INACTIVE"]"
		if(hunting_system.current_target)
			status_items += "Current Target: [hunting_system.current_target.name]"
	return status_items

/mob/living/scp/scp939/examine(mob/user)
	. = ..()
	. += span_warning("It has no eyes. It hunts by sound and smell.")

/mob/living/scp/scp939/proc/contribute_research_data()
	var/research_data = list(
		"scp_type" = "SCP-939",
		"learned_voices_count" = length(voice_system?.learned_voices) || 0,
		"pack_members_count" = length(pack_system?.pack_members) || 0,
		"detected_prey" = length(detected_mobs) || 0,
		"hunt_mode" = hunting_system?.hunt_mode || FALSE,
		"timestamp" = world.time
	)
	research_integration?.research_data["last_update"] = research_data

/mob/living/scp/scp939/proc/on_voice_mimic(mob/living/carbon/human/target)
	if(!target)
		return
	hook_scp_interaction(target, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/scp/scp939/proc/on_pack_communication(mob/living/carbon/human/pack_member)
	if(!pack_member)
		return
	hook_scp_interaction(pack_member, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/scp/scp939/proc/on_hunt_kill(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_breach("SCP-939", src)
	hook_scp_combat(victim, "SCP-939", 100, 0)
	voice_system?.learn_voice(victim)

/mob/living/scp/scp939/proc/on_hunt_start(mob/living/carbon/human/target)
	if(!target || !target.ckey)
		return

/mob/living/scp/scp939/proc/on_territory_claim(area/claimed_area)
	if(!claimed_area)
		return
	hook_scp_breach("SCP-939", src)

/mob/living/scp/scp939/proc/on_psychological_manipulation(mob/living/carbon/human/target)
	if(!target)
		return
	hook_scp_interaction(target, "SCP-939", INTERACTION_TYPE_COMMUNICATION)

/mob/living/scp/scp939/proc/on_recontainment()
	hook_scp_recontainment("SCP-939", list("method" = "standard"))
