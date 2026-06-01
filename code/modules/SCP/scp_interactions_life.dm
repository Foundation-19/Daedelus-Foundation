/mob/living/scp079/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		if(prob(5))
			var/mob/living/scp/scp173/scp173_mob = find_scp_mob("SCP-173")
			if(scp173_mob && get_dist(src, scp173_mob) <= 15)
				hook_scp_cross_interaction("SCP-079", "SCP-173", "079_open_173_door")
		if(tier >= 3 && prob(3))
			hook_scp_cross_interaction("SCP-079", "SCP-096", "079_disable_096_cameras")
		return
	if(prob(2))
		for(var/mob/living/scp/scp173/M in range(15, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("079_open_173_door", src, M)
				break
	if(tier >= 3 && prob(2))
		SSscp_cross_interactions.execute_interaction("079_disable_096_cameras", src, src)
	if(tier >= 3 && prob(2))
		for(var/mob/living/scp/scp049/M in range(15, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("079_lock_049_containment", src, M)
				break
	if(tier >= 4 && prob(1))
		for(var/mob/living/scp/scp939/M in range(20, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("079_redirect_939_lures", src, M)
				break
	if(tier >= 4 && prob(1))
		for(var/mob/living/scp035/M in range(30, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("079_broadcast_035_propaganda", src, M)
				break
	if(tier >= 5 && prob(1))
		SSscp_cross_interactions.execute_interaction("079_flicker_096_lights", src, src)
	if(SSit_network && prob(3))
		SSit_network.scp079_network_presence = min(100, SSit_network.scp079_network_presence + 2)
		for(var/datum/network_node/N in SSit_network.nodes)
			if(get_area(src) && findtext(N.area_name, "Server"))
				N.apply_scp079_influence(3)

/mob/living/scp/scp106/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		if(prob(3))
			var/mob/living/scp/scp173/scp173_mob = find_scp_mob("SCP-173")
			if(scp173_mob && get_dist(src, scp173_mob) <= 10)
				hook_scp_cross_interaction("SCP-106", "SCP-173", "106_corrode_173_containment")
		return
	if(prob(3))
		for(var/mob/living/scp/scp173/M in range(10, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("106_corrode_173_containment", src, M)
				break
	if(prob(2))
		for(var/mob/living/scp/scp682/M in range(12, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("106_corrode_682_chamber", src, M)
				break
	if(prob(1))
		for(var/mob/living/scp035/M in range(5, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("106_pocket_035_host", src, M)
				break
	if(prob(1))
		for(var/mob/living/scp/scp939/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("106_pocket_939_prey", src, M)
				break
	if(SSit_network && prob(3))
		for(var/datum/network_node/N in SSit_network.nodes)
			var/area/node_area = get_area(src)
			if(node_area && findtext(N.area_name, "Server") && get_dist(src, locate(/area/station) in range(10, src)) < 15)
				N.degrade(5)
				break

/mob/living/scp/scp049/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		if(prob(2))
			hook_scp_cross_interaction("SCP-049", "SCP-008", "049_detect_008")
		return
	if(prob(2))
		SSscp_cross_interactions.execute_interaction("049_detect_008", src, src)
	if(prob(3))
		for(var/mob/living/scp035/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("049_sense_035_host", src, M)
				break
	if(prob(1))
		SSscp_cross_interactions.execute_interaction("049_cure_008_zombie", src, src)
	if(SSpsychology && prob(5))
		for(var/mob/living/carbon/human/H in range(7, src))
			if(H.stat != DEAD && !HAS_TRAIT(H, TRAIT_PESTILENCE))
				SSpsychology.record_exposure(H, "SCP-049", "proximity", "In proximity to SCP-049; potential Pestilence carrier detection")
				break

/mob/living/scp/scp999/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(4))
		SSscp_cross_interactions.execute_interaction("999_counter_513", src, src)
	if(prob(3))
		SSscp_cross_interactions.execute_interaction("999_calm_096", src, src)
	if(prob(3))
		for(var/mob/living/scp/scp682/M in range(5, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("999_calm_682", src, M)
				break
	if(prob(3))
		SSscp_cross_interactions.execute_interaction("999_counter_035", src, src)
	if(prob(2))
		SSscp_cross_interactions.execute_interaction("999_heal_049_victims", src, src)

/mob/living/scp/scp682/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp/scp106/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("682_resist_106", src, M)
				break
	if(prob(5))
		for(var/mob/living/scp/scp457/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("682_fight_457", src, M)
				break
	if(prob(2))
		SSscp_cross_interactions.execute_interaction("682_consume_008", src, src)

/mob/living/scp/scp457/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(2))
		for(var/obj/structure/coffin/scp895/M in range(10, src))
			SSscp_cross_interactions.execute_interaction("457_feed_895_corpse", src, M)
			break
	if(prob(4))
		for(var/obj/effect/scp106_residue/R in range(8, src))
			SSscp_cross_interactions.execute_interaction("457_ignite_106_residue", src, src)
			break

/mob/living/scp/scp939/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp035/M in range(10, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("939_mimic_035_voice", src, M)
				break
	if(prob(2))
		SSscp_cross_interactions.execute_interaction("1471_manifest_near_939", src, src)

/mob/living/scp035/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp/scp049/M in range(6, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("035_manipulate_049", src, M)
				break
	if(prob(1))
		SSscp_cross_interactions.execute_interaction("035_possess_008_zombie", src, src)
	if(prob(2))
		for(var/mob/living/scp/scp939/M in range(10, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("035_corrupt_939_voice", src, M)
				break

/proc/check_passive_cross_interaction(mob/living/carbon/human/H, interaction_id)
	if(!H || !SSscp_cross_interactions?.setup_complete)
		return FALSE
	var/datum/cross_scp_interaction/I = SSscp_cross_interactions.interactions[interaction_id]
	if(!I || !I.discovered)
		return FALSE
	if(!SSscp_cross_interactions.check_research_requirement(I))
		return FALSE
	return TRUE

/proc/apply_714_shield_513(mob/living/carbon/human/H)
	if(!check_passive_cross_interaction(H, "714_shield_513"))
		return FALSE
	H.RemoveElement(/datum/element/scp513_stalked)
	to_chat(H, span_notice("SCP-714 pulses warmly. The looming presence vanishes!"))
	return TRUE

/proc/apply_714_shield_895(mob/living/carbon/human/H)
	if(!check_passive_cross_interaction(H, "714_shield_895"))
		return FALSE
	if(H.hallucination > 0)
		H.hallucination = max(0, H.hallucination - 20)
		to_chat(H, span_notice("SCP-714 dampens the visual distortion..."))
		return TRUE
	return FALSE

/proc/apply_500_cure_513_stalked(mob/living/carbon/human/H)
	if(!check_passive_cross_interaction(H, "500_cure_513_stalked"))
		return FALSE
	H.RemoveElement(/datum/element/scp513_stalked)
	to_chat(H, span_notice("The SCP-500 pill banishes SCP-513-1's presence permanently!"))
	return TRUE

/proc/apply_500_cure_1471(mob/living/carbon/human/H)
	if(!check_passive_cross_interaction(H, "500_cure_1471"))
		return FALSE
	H.hallucination = max(0, H.hallucination - 20)
	to_chat(H, span_notice("The SCP-500 pill purges the strange influence from your mind!"))
	return TRUE

/proc/apply_427_heal_008(mob/living/carbon/human/H)
	if(!check_passive_cross_interaction(H, "427_heal_008_infection"))
		return FALSE
	H.adjustBruteLoss(-15, updating_health = TRUE)
	to_chat(H, span_warning("SCP-427 fights the infection... but you feel something else warping inside you."))
	H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
	return TRUE

/datum/scp_research_manager/proc/check_cross_interaction_discoveries(scp_designation, researcher_ckey)
	if(!SSscp_cross_interactions?.setup_complete)
		return
	SSscp_cross_interactions.try_discover_interaction(scp_designation, researcher_ckey)

/mob/living/scp/scp073/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp/scp682/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("073_reflect_682", src, M)
				break
	if(prob(4))
		for(var/mob/living/scp/scp457/M in range(6, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("073_reflect_457", src, M)
				break

/mob/living/scp/scp073/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp076/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp/scp682/M in range(6, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("076_dual_682", src, M)
				break
	if(prob(2))
		for(var/mob/living/scp/scp096/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("076_dual_096", src, M)
				break
	if(prob(3))
		for(var/mob/living/simple_animal/hostile/scp610_fleshman/M in range(10, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("076_hunt_610", src, M)
				break

/mob/living/scp/scp076/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp082/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(4))
		for(var/mob/living/simple_animal/hostile/scp610_fleshman/M in range(5, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("082_feed_610", src, M)
				break
	if(prob(3))
		for(var/mob/living/simple_animal/scp1048/M in range(6, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("082_feed_1048", src, M)
				break

/mob/living/scp/scp082/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp280/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp/scp106/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("280_shadow_106", src, M)
				break
	if(prob(2))
		SSscp_cross_interactions.execute_interaction("280_shadow_017", src, src)

/mob/living/scp/scp280/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp343/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp/scp682/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("343_god_682", src, M)
				break
	if(prob(4))
		for(var/mob/living/scp/scp999/M in range(5, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("343_god_999", src, M)
				break

/mob/living/scp/scp343/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp408/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/scp/scp173/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("408_swarm_173", src, M)
				break
	if(prob(2))
		for(var/mob/living/scp/scp096/M in range(10, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("408_swarm_096", src, M)
				break

/mob/living/scp/scp408/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp966/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(2))
		for(var/mob/living/simple_animal/hostile/scp610_fleshman/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("966_stalk_610", src, M)
				break
	if(prob(2))
		for(var/mob/living/scp/scp096/M in range(10, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("966_stalk_096", src, M)
				break

/mob/living/scp/scp966/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp3199/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(2))
		var/turf/T = get_turf(src)
		if(istype(T, /turf/open/flesh))
			SSscp_cross_interactions.execute_interaction("3199_egg_610", src, src)
	if(prob(2))
		SSscp_cross_interactions.execute_interaction("3199_egg_008", src, src)

/mob/living/scp/scp3199/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp1128/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(2))
		for(var/mob/living/simple_animal/hostile/scp610_fleshman/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("1128_aquatic_610", src, M)
				break

/mob/living/scp/scp1128/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(prob(2))
		check_scp_interactions()

/client/proc/view_cross_scp_interactions()
	set name = "View Cross-SCP Interactions"
	set category = "SCP"
	set desc = "View all cross-SCP interactions and their discovery status."

	if(!SSscp_cross_interactions?.setup_complete)
		to_chat(src, span_warning("Cross-interaction system not initialized."))
		return

	var/list/dat = list()
	dat += "<b>SCP Cross-Interaction Registry</b><br>"
	dat += "Total: [length(SSscp_cross_interactions.interactions)] | Discovered: [length(SSscp_cross_interactions.discovered_interactions)]<br><hr>"

	for(var/interaction_id in SSscp_cross_interactions.interactions)
		var/datum/cross_scp_interaction/I = SSscp_cross_interactions.interactions[interaction_id]
		var/status = I.discovered ? "<font color='green'>DISCOVERED</font>" : "<font color='red'>UNKNOWN</font>"
		dat += "<b>[I.name]</b> ([I.scp_id_1] x [I.scp_id_2]) - Tier [I.tier] - [status]<br>"
		if(I.discovered)
			dat += "  [I.description]<br>"
			dat += "  Triggers: [I.trigger_count] | Research Required: [I.research_required_scp1]/[I.research_required_scp2]<br>"
		dat += "<br>"

	var/datum/browser/popup = new(usr, "cross_scp_interactions", "Cross-SCP Interactions", 600, 500)
	popup.set_content(dat.Join())
	popup.open()
