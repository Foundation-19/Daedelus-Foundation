#define CROSS_INTERACT_TIER_1 1
#define CROSS_INTERACT_TIER_2 2
#define CROSS_INTERACT_TIER_3 3
#define CROSS_INTERACT_TIER_4 4
#define CROSS_INTERACT_TIER_5 5

/datum/cross_scp_interaction
	var/interaction_id
	var/name
	var/description
	var/scp_id_1
	var/scp_id_2
	var/tier = 1
	var/research_required_scp1 = 3
	var/research_required_scp2 = 3
	var/probability = 2
	var/range_required = 15
	var/discovered = FALSE
	var/discovery_time
	var/discovered_by
	var/trigger_count = 0
	var/last_trigger_time = 0
	var/cooldown = 60 SECONDS

/datum/cross_scp_interaction/New(interaction_id, name, description, scp_id_1, scp_id_2, tier, req1, req2, prob, range_req, cooldown_time)
	src.interaction_id = interaction_id
	src.name = name
	src.description = description
	src.scp_id_1 = scp_id_1
	src.scp_id_2 = scp_id_2
	src.tier = tier
	src.research_required_scp1 = req1
	src.research_required_scp2 = req2
	src.probability = prob
	src.range_required = range_req
	src.cooldown = cooldown_time

SUBSYSTEM_DEF(scp_cross_interactions)
	name = "SCP Cross-Interactions"
	wait = 300
	priority = FIRE_PRIORITY_INPUT
	var/list/interactions = list()
	var/list/discovered_interactions = list()
	var/setup_complete = FALSE

/datum/controller/subsystem/scp_cross_interactions/Initialize()
	initialize_cross_interactions()
	setup_complete = TRUE
	return ..()

/datum/controller/subsystem/scp_cross_interactions/fire()
	if(!setup_complete)
		return
	process_cross_interactions()

/datum/controller/subsystem/scp_cross_interactions/proc/initialize_cross_interactions()
	register_interaction("079_open_173_door","Digital Liberation","SCP-079 opens doors near SCP-173 when unobserved, facilitating its movement.","SCP-079","SCP-173",CROSS_INTERACT_TIER_1,2,2,5,15,60 SECONDS)
	register_interaction("079_disable_096_cameras","Blinding the Watchers","SCP-079 disables security cameras near SCP-096 containment, preventing remote monitoring.","SCP-079","SCP-096",CROSS_INTERACT_TIER_2,3,2,3,20,90 SECONDS)
	register_interaction("079_lock_049_containment","Quarantine Override","SCP-079 locks down SCP-049 containment doors to prevent personnel from escaping the good Doctor.","SCP-079","SCP-049",CROSS_INTERACT_TIER_2,3,3,3,15,120 SECONDS)
	register_interaction("079_redirect_939_lures","Voice Channeling","SCP-079 hijacks intercoms near SCP-939, amplifying its voice mimicry to lure prey from greater distances.","SCP-079","SCP-939",CROSS_INTERACT_TIER_3,4,3,3,20,120 SECONDS)
	register_interaction("079_broadcast_035_propaganda","Corrupted Signal","SCP-079 broadcasts SCP-035's psychological influence through facility speakers, extending its telepathy range.","SCP-079","SCP-035",CROSS_INTERACT_TIER_3,4,3,2,30,180 SECONDS)
	register_interaction("079_flicker_096_lights","Shadow Protocol","SCP-079 flickers lights near SCP-096, creating brief darkness windows that allow 096 to move unobserved.","SCP-079","SCP-096",CROSS_INTERACT_TIER_4,5,4,2,20,180 SECONDS)
	register_interaction("106_corrode_173_containment","Corrosive Pressure","SCP-106 corrodes SCP-173's containment walls when nearby, weakening structural integrity.","SCP-106","SCP-173",CROSS_INTERACT_TIER_1,2,2,3,10,90 SECONDS)
	register_interaction("106_corrode_682_chamber","Acid Meet Acid","SCP-106 corrodes SCP-682's containment chamber. 682 seems to absorb the corrosion, accelerating adaptation.","SCP-106","SCP-682",CROSS_INTERACT_TIER_3,3,3,2,12,180 SECONDS)
	register_interaction("106_pocket_035_host","Dimensional Abduction","SCP-106 drags SCP-035's host into the pocket dimension. 035 possesses the decaying host to spy from within.","SCP-106","SCP-035",CROSS_INTERACT_TIER_4,4,4,1,5,300 SECONDS)
	register_interaction("106_pocket_939_prey","Dimensional Ambush","SCP-106 pulls SCP-939's prey into the pocket dimension. The combined trauma amplifies 939's mimicry with dimensional echoes.","SCP-106","SCP-939",CROSS_INTERACT_TIER_4,4,3,2,8,240 SECONDS)
	register_interaction("049_detect_008","Pestilence Resonance","SCP-049 senses SCP-008-infected subjects nearby, recognizing them as 'partially cured' of the Pestilence.","SCP-049","SCP-008",CROSS_INTERACT_TIER_1,2,2,2,10,60 SECONDS)
	register_interaction("049_sense_035_host","Corrupted Flesh","SCP-049 perceives SCP-035's host as uniquely pestilent, becoming agitated and focused on 'curing' them.","SCP-049","SCP-035",CROSS_INTERACT_TIER_2,3,3,3,8,90 SECONDS)
	register_interaction("049_cure_008_zombie","Double Cure","SCP-049 attempts to 'cure' an SCP-008 zombie. The result is an abomination combining both anomalies.","SCP-049","SCP-008",CROSS_INTERACT_TIER_4,5,4,1,5,600 SECONDS)
	register_interaction("035_manipulate_049","Silver Tongue","SCP-035's psychological influence calms SCP-049, convincing the Doctor that it is already 'cured' of the Pestilence.","SCP-035","SCP-049",CROSS_INTERACT_TIER_2,3,3,4,6,120 SECONDS)
	register_interaction("035_possess_008_zombie","Dead Man's Switch","SCP-035 possesses an SCP-008 zombie, creating a sentient infected host that can spread 008 deliberately.","SCP-035","SCP-008",CROSS_INTERACT_TIER_5,5,5,1,5,600 SECONDS)
	register_interaction("035_corrupt_939_voice","Poisoned Whispers","SCP-035 amplifies SCP-939's voice mimicry with its own psychological corruption, making the lures nearly irresistible.","SCP-035","SCP-939",CROSS_INTERACT_TIER_3,4,3,2,10,180 SECONDS)
	register_interaction("914_refine_500","Miracle Refinement","SCP-914 on Fine setting applied to SCP-500 creates an enhanced variant with doubled efficacy.","SCP-914","SCP-500",CROSS_INTERACT_TIER_2,3,2,0,3,0)
	register_interaction("914_refine_113","Gender Refinement","SCP-914 refines SCP-113 into a safer variant with reduced rejection risk.","SCP-914","SCP-113",CROSS_INTERACT_TIER_2,3,2,0,3,0)
	register_interaction("914_refine_714","Shield Refinement","SCP-914 on Very Fine setting applied to SCP-714 creates an enhanced protective ring with expanded coverage.","SCP-914","SCP-714",CROSS_INTERACT_TIER_3,4,3,0,3,0)
	register_interaction("914_refine_513","Bell Refinement","SCP-914 on Rough setting destroys SCP-513's memetic properties. On 1:1 it creates an inverted cowbell that repels 513-1.","SCP-914","SCP-513",CROSS_INTERACT_TIER_3,4,3,0,3,0)
	register_interaction("914_refine_427","Locket Refinement","SCP-914 on Fine setting creates a stabilized SCP-427 variant that heals without the flesh-melting side effect.","SCP-914","SCP-427",CROSS_INTERACT_TIER_4,5,4,0,3,0)
	register_interaction("914_refine_178","Glasses Refinement","SCP-914 on 1:1 setting modifies SCP-178 to reveal entities without the hostile manifestation side effect.","SCP-914","SCP-178",CROSS_INTERACT_TIER_4,5,4,0,3,0)
	register_interaction("914_refine_1499","Mask Refinement","SCP-914 on Fine setting creates SCP-1499-B that allows controlled dimensional shifts without full immersion.","SCP-914","SCP-1499",CROSS_INTERACT_TIER_5,5,5,0,3,0)
	register_interaction("999_calm_096","Tickle Therapy","SCP-999's presence has a measurable calming effect on SCP-096, reducing rage state duration by 30%.","SCP-999","SCP-096",CROSS_INTERACT_TIER_2,3,3,4,5,120 SECONDS)
	register_interaction("999_calm_682","Unlikely Friendship","SCP-999 is one of the few entities SCP-682 tolerates. 682 becomes docile for a brief period in 999's presence.","SCP-999","SCP-682",CROSS_INTERACT_TIER_3,3,4,3,5,180 SECONDS)
	register_interaction("999_counter_513","Joyful Counter","SCP-999's emotional aura counters SCP-513-1's stalking effect. Affected personnel feel the presence recede.","SCP-999","SCP-513",CROSS_INTERACT_TIER_2,3,3,5,7,90 SECONDS)
	register_interaction("999_counter_035","Emotional Shield","SCP-999's presence creates a temporary resistance to SCP-035's psychological influence in nearby personnel.","SCP-999","SCP-035",CROSS_INTERACT_TIER_3,4,3,3,6,120 SECONDS)
	register_interaction("999_heal_049_victims","Anti-Pestilence","SCP-999's healing properties can partially reverse SCP-049's 'cure' effects on recent victims.","SCP-999","SCP-049",CROSS_INTERACT_TIER_4,4,4,2,5,240 SECONDS)
	register_interaction("682_resist_106","Adapted Immunity","SCP-682 adapts to SCP-106's corrosion after exposure, becoming temporarily immune to dimensional decay.","SCP-682","SCP-106",CROSS_INTERACT_TIER_3,3,3,3,8,300 SECONDS)
	register_interaction("682_fight_457","Fire and Fury","SCP-682 engages SCP-457 in combat. 682 adapts fire resistance; 457 feeds on the destruction and grows.","SCP-682","SCP-457",CROSS_INTERACT_TIER_3,3,3,5,8,180 SECONDS)
	register_interaction("682_consume_008","Plague Eater","SCP-682 consumes SCP-008 infected tissue and derives temporary biological enhancement from the pathogen.","SCP-682","SCP-008",CROSS_INTERACT_TIER_4,4,4,2,6,300 SECONDS)
	register_interaction("682_adapt_914_output","Unrefinable","SCP-914 refinement on SCP-682 tissue samples causes immediate adaptation. 682 gains resistance to the refinement effect.","SCP-914","SCP-682",CROSS_INTERACT_TIER_5,5,5,0,3,0)
	register_interaction("457_feed_895_corpse","Pyre of Shadows","SCP-457 burns remains near SCP-895. The corrupted smoke extends 895's hallucination range through ventilation.","SCP-457","SCP-895",CROSS_INTERACT_TIER_3,3,3,2,10,180 SECONDS)
	register_interaction("457_ignite_106_residue","Burning Trail","SCP-457 ignites SCP-106's corrosive residue, creating toxic fumes that spread through corridors.","SCP-457","SCP-106",CROSS_INTERACT_TIER_2,3,2,4,8,120 SECONDS)
	register_interaction("895_corrupt_079_cameras","Signal Corruption","SCP-895's visual corruption bleeds into SCP-079's camera network, causing glitched feeds and erratic AI behavior.","SCP-895","SCP-079",CROSS_INTERACT_TIER_3,3,3,3,15,180 SECONDS)
	register_interaction("1471_manifest_near_939","Shadow Pack","SCP-1471 entities are drawn to SCP-939's hunting grounds, creating visual hallucinations that mask 939's approach.","SCP-1471","SCP-939",CROSS_INTERACT_TIER_3,3,3,2,15,240 SECONDS)
	register_interaction("939_mimic_035_voice","Perfect Impersonation","SCP-939 mimics SCP-035's host voice patterns with uncanny accuracy after proximity, creating irresistible lures.","SCP-939","SCP-035",CROSS_INTERACT_TIER_3,3,3,3,10,180 SECONDS)
	register_interaction("1499_dimension_106_pocket","Dimensional Overlap","SCP-1499's dimension temporarily overlaps with SCP-106's pocket dimension, allowing cross-dimensional observation.","SCP-1499","SCP-106",CROSS_INTERACT_TIER_5,5,5,1,5,600 SECONDS)
	register_interaction("714_shield_513","Ring of Silence","SCP-714's protective properties shield the wearer from SCP-513's memetic stalking effect.","SCP-714","SCP-513",CROSS_INTERACT_TIER_2,3,3,0,2,0)
	register_interaction("714_shield_012","Compulsion Resistance","SCP-714's protective properties grant temporary resistance to SCP-012's compulsive writing effect.","SCP-714","SCP-012",CROSS_INTERACT_TIER_3,4,3,0,2,0)
	register_interaction("714_shield_895","Mental Fortress","SCP-714's protective properties partially block SCP-895's visual corruption when viewing through cameras.","SCP-714","SCP-895",CROSS_INTERACT_TIER_3,4,3,0,5,0)
	register_interaction("427_heal_008_infection","Cursed Cure","SCP-427 can halt SCP-008 infection progression temporarily, but the combination accelerates 427's corruption effect.","SCP-427","SCP-008",CROSS_INTERACT_TIER_4,5,4,0,2,0)
	register_interaction("500_cure_008","Universal Antidote","An SCP-500 pill can cure SCP-008 infection entirely at any stage. This is the only known complete cure.","SCP-500","SCP-008",CROSS_INTERACT_TIER_2,3,2,0,2,0)
	register_interaction("500_cure_049_touch","Undoing the Cure","An SCP-500 pill can reverse SCP-049's 'cure' on a recent victim, restoring cognitive function.","SCP-500","SCP-049",CROSS_INTERACT_TIER_3,4,3,0,2,0)
	register_interaction("500_cure_513_stalked","Presence Banishment","An SCP-500 pill can permanently end SCP-513-1's stalking effect on a victim.","SCP-500","SCP-513",CROSS_INTERACT_TIER_2,3,2,0,2,0)
	register_interaction("500_cure_1471","Digital Purge","An SCP-500 pill causes the body to reject SCP-1471's memetic influence, resetting manifestation level.","SCP-500","SCP-1471",CROSS_INTERACT_TIER_3,4,3,0,2,0)
	world.log << "SCP Cross-Interactions: Registered [length(interactions)] interactions"

/datum/controller/subsystem/scp_cross_interactions/proc/register_interaction(id, name, desc, scp1, scp2, tier, req1, req2, prob, range_req, cooldown_time)
	var/datum/cross_scp_interaction/I = new(id, name, desc, scp1, scp2, tier, req1, req2, prob, range_req, cooldown_time)
	interactions[id] = I

/datum/controller/subsystem/scp_cross_interactions/proc/process_cross_interactions()
	for(var/interaction_id in interactions)
		var/datum/cross_scp_interaction/I = interactions[interaction_id]
		if(!I.discovered)
			continue
		if(I.probability <= 0)
			continue
		if(world.time - I.last_trigger_time < I.cooldown)
			continue
		if(!prob(I.probability))
			continue
		var/mob/living/scp1 = find_scp_mob(I.scp_id_1)
		var/mob/living/scp2 = find_scp_mob(I.scp_id_2)
		if(!scp1 || !scp2)
			continue
		if(scp1.stat == DEAD || scp2.stat == DEAD)
			continue
		if(I.range_required > 0 && get_dist(scp1, scp2) > I.range_required)
			continue
		if(!check_research_requirement(I))
			continue
		execute_interaction(interaction_id, scp1, scp2)

/datum/controller/subsystem/scp_cross_interactions/proc/check_research_requirement(datum/cross_scp_interaction/I)
	if(!SSscp_research || !SSscp_research.manager)
		return TRUE
	var/level1 = get_scp_research_level(I.scp_id_1)
	var/level2 = get_scp_research_level(I.scp_id_2)
	if(level1 >= I.research_required_scp1 && level2 >= I.research_required_scp2)
		return TRUE
	return FALSE

/datum/controller/subsystem/scp_cross_interactions/proc/get_scp_research_level(scp_id)
	if(!SSscp_research || !SSscp_research.manager)
		return 0
	var/max_level = 0
	for(var/project_id in SSscp_research.manager.research_projects)
		var/datum/research_data/project = SSscp_research.manager.research_projects[project_id]
		if(project.scp_designation == scp_id && project.status == "ACTIVE")
			max_level = max(max_level, project.research_level)
	return max_level

/datum/controller/subsystem/scp_cross_interactions/proc/try_discover_interaction(scp_id, researcher_ckey)
	if(!SSscp_research || !SSscp_research.manager)
		return
	for(var/interaction_id in interactions)
		var/datum/cross_scp_interaction/I = interactions[interaction_id]
		if(I.discovered)
			continue
		var/level1 = get_scp_research_level(I.scp_id_1)
		var/level2 = get_scp_research_level(I.scp_id_2)
		var/discovery_chance = 0
		if(I.scp_id_1 == scp_id && level1 >= I.research_required_scp1)
			discovery_chance = 10 + (level1 * 5)
		else if(I.scp_id_2 == scp_id && level2 >= I.research_required_scp2)
			discovery_chance = 10 + (level2 * 5)
		if(discovery_chance > 0 && prob(discovery_chance))
			discover_interaction(interaction_id, researcher_ckey)

/datum/controller/subsystem/scp_cross_interactions/proc/discover_interaction(interaction_id, researcher_ckey)
	var/datum/cross_scp_interaction/I = interactions[interaction_id]
	if(!I || I.discovered)
		return
	I.discovered = TRUE
	I.discovery_time = world.time
	I.discovered_by = researcher_ckey
	discovered_interactions[interaction_id] = I
	log_game("SCP Cross-Interaction Discovered: [I.name] ([I.scp_id_1] x [I.scp_id_2]) by [researcher_ckey || "system"]")
	if(researcher_ckey && SSscp_research?.manager)
		var/datum/researcher_data/researcher = SSscp_research.manager.get_researcher_profile(researcher_ckey)
		if(researcher)
			researcher.research_points += 500
			researcher.achievements += "Discovered: [I.name]"
	for(var/client/C in GLOB.clients)
		if(C?.mob?.ckey == researcher_ckey)
			to_chat(C, span_boldnotice("RESEARCH DISCOVERY: Cross-anomaly interaction '[I.name]' identified between [I.scp_id_1] and [I.scp_id_2]! +500 research points"))
			break

/datum/controller/subsystem/scp_cross_interactions/proc/execute_interaction(interaction_id, mob/living/scp1, mob/living/scp2)
	var/datum/cross_scp_interaction/I = interactions[interaction_id]
	if(!I)
		return FALSE
	I.trigger_count++
	I.last_trigger_time = world.time
	var/result = execute_interaction_impl(interaction_id, scp1, scp2)
	if(result)
		hook_scp_cross_interaction(I.scp_id_1, I.scp_id_2, interaction_id)
	return result

/datum/controller/subsystem/scp_cross_interactions/proc/execute_interaction_impl(interaction_id, mob/living/scp1, mob/living/scp2)
	switch(interaction_id)
		if("079_open_173_door")
			return interact_079_open_173_door(scp1, scp2)
		if("079_disable_096_cameras")
			return interact_079_disable_096_cameras(scp1, scp2)
		if("079_lock_049_containment")
			return interact_079_lock_049_containment(scp1, scp2)
		if("079_redirect_939_lures")
			return interact_079_redirect_939_lures(scp1, scp2)
		if("079_broadcast_035_propaganda")
			return interact_079_broadcast_035_propaganda(scp1, scp2)
		if("079_flicker_096_lights")
			return interact_079_flicker_096_lights(scp1, scp2)
		if("106_corrode_173_containment")
			return interact_106_corrode_173_containment(scp1, scp2)
		if("106_corrode_682_chamber")
			return interact_106_corrode_682_chamber(scp1, scp2)
		if("106_pocket_035_host")
			return interact_106_pocket_035_host(scp1, scp2)
		if("106_pocket_939_prey")
			return interact_106_pocket_939_prey(scp1, scp2)
		if("049_detect_008")
			return interact_049_detect_008(scp1, scp2)
		if("049_sense_035_host")
			return interact_049_sense_035_host(scp1, scp2)
		if("049_cure_008_zombie")
			return interact_049_cure_008_zombie(scp1, scp2)
		if("035_manipulate_049")
			return interact_035_manipulate_049(scp1, scp2)
		if("035_possess_008_zombie")
			return interact_035_possess_008_zombie(scp1, scp2)
		if("035_corrupt_939_voice")
			return interact_035_corrupt_939_voice(scp1, scp2)
		if("999_calm_096")
			return interact_999_calm_096(scp1, scp2)
		if("999_calm_682")
			return interact_999_calm_682(scp1, scp2)
		if("999_counter_513")
			return interact_999_counter_513(scp1, scp2)
		if("999_counter_035")
			return interact_999_counter_035(scp1, scp2)
		if("999_heal_049_victims")
			return interact_999_heal_049_victims(scp1, scp2)
		if("682_resist_106")
			return interact_682_resist_106(scp1, scp2)
		if("682_fight_457")
			return interact_682_fight_457(scp1, scp2)
		if("682_consume_008")
			return interact_682_consume_008(scp1, scp2)
		if("457_feed_895_corpse")
			return interact_457_feed_895_corpse(scp1, scp2)
		if("457_ignite_106_residue")
			return interact_457_ignite_106_residue(scp1, scp2)
		if("895_corrupt_079_cameras")
			return interact_895_corrupt_079_cameras(scp1, scp2)
		if("1471_manifest_near_939")
			return interact_1471_manifest_near_939(scp1, scp2)
		if("939_mimic_035_voice")
			return interact_939_mimic_035_voice(scp1, scp2)
	return FALSE

/proc/hook_scp_cross_interaction(scp_id_1, scp_id_2, interaction_type)
	if(!scp_id_1 || !scp_id_2)
		return
	log_game("Cross-SCP Interaction: [scp_id_1] x [scp_id_2] - [interaction_type]")
	if(SSscp_persistence?.manager)
		var/datum/scp_instance/instance1 = SSscp_persistence.manager.scp_instances[scp_id_1]
		var/datum/scp_instance/instance2 = SSscp_persistence.manager.scp_instances[scp_id_2]
		if(instance1)
			instance1.add_interaction_record(null, "cross_interaction_[scp_id_2]")
		if(instance2)
			instance2.add_interaction_record(null, "cross_interaction_[scp_id_1]")
