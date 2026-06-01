/proc/interact_079_open_173_door(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	var/mob/living/scp/scp173/scp173_mob = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!ai || !scp173_mob)
		return FALSE
	for(var/obj/machinery/door/airlock/D in range(3, scp173_mob))
		if(D.density && (D in ai.hacked_doors))
			D.open()
			ai.visible_message(span_danger("[D] slides open, triggered by an unseen force!"))
			return TRUE
	return FALSE

/proc/interact_079_disable_096_cameras(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	if(!ai || ai.tier < 3)
		return FALSE
	for(var/obj/machinery/camera/C in range(10, ai))
		var/area/cam_area = get_area(C)
		if(istype(cam_area, /area/scp/lcz/euclid_containment))
			C.machine_stat |= BROKEN
			C.update_appearance()
	return TRUE

/proc/interact_079_lock_049_containment(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	var/mob/living/scp/scp049/doctor = istype(scp1, /mob/living/scp/scp049) ? scp1 : scp2
	if(!ai || !doctor)
		return FALSE
	for(var/obj/machinery/door/airlock/D in range(5, doctor))
		if(!D.density)
			D.close()
			D.lock()
			D.visible_message(span_danger("[D] slams shut and locks!"))
	return TRUE

/proc/interact_079_redirect_939_lures(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	var/mob/living/scp/scp939/predator = istype(scp1, /mob/living/scp/scp939) ? scp1 : scp2
	if(!ai || !predator)
		return FALSE
	priority_announce("...help me... is anyone there... I'm hurt...", "INTERCOM: DISTRESS SIGNAL", null, null)
	return TRUE

/proc/interact_079_broadcast_035_propaganda(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!ai || !mask)
		return FALSE
	for(var/mob/living/carbon/human/H in range(15, mask))
		if(H.stat == DEAD || H.SCP)
			continue
		if(H.sanity)
			H.sanity.adjust_sanity(-10, "scp035_broadcast")
		to_chat(H, span_warning("A strange whisper echoes through the speakers..."))
	return TRUE

/proc/interact_079_flicker_096_lights(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	if(!ai || ai.tier < 4)
		return FALSE
	for(var/obj/machinery/light/L in range(10, ai))
		L.flicker()
	for(var/mob/living/carbon/human/H in range(8, ai))
		if(!H.stat)
			to_chat(H, span_warning("The lights flicker violently!"))
	return TRUE

/proc/interact_106_corrode_173_containment(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp106/larry = istype(scp1, /mob/living/scp/scp106) ? scp1 : scp2
	var/mob/living/scp/scp173/scp173_mob = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!larry || !scp173_mob)
		return FALSE
	for(var/turf/closed/wall/scp_containment/W in range(2, scp173_mob))
		if(W.containment_integrity > 0)
			W.damage_containment(25, "SCP-106 corrosion")
			larry.visible_message(span_danger("Dark corrosive residue seeps from the walls near SCP-173!"))
			return TRUE
	return FALSE

/proc/interact_106_corrode_682_chamber(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp106/larry = istype(scp1, /mob/living/scp/scp106) ? scp1 : scp2
	var/mob/living/scp/scp682/reptile = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!larry || !reptile)
		return FALSE
	for(var/turf/closed/wall/scp_containment/W in range(3, reptile))
		if(W.containment_integrity > 0)
			W.damage_containment(15, "SCP-106 corrosion")
	if(reptile.evolution_system)
		reptile.evolution_system.add_adaptation("acid_resistance", 0.5)
	larry.visible_message(span_danger("SCP-106's corrosion washes over SCP-682... who absorbs it with a rumbling growl."))
	return TRUE

/proc/interact_106_pocket_035_host(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp106/larry = istype(scp1, /mob/living/scp/scp106) ? scp1 : scp2
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!larry || !mask || !mask.mask)
		return FALSE
	var/mob/living/carbon/human/host = mask.mask.possession_system?.current_host
	if(!host || host.stat == DEAD)
		return FALSE
	host.visible_message(span_danger("A dark puddle forms beneath [host]! They begin to sink!"))
	host.apply_damage(20, BRUTE, sharpness = SHARP_EDGED)
	to_chat(host, span_userdanger("You are pulled into a dark, rotting dimension! SCP-035 whispers: \"Interesting... show me more.\""))
	return TRUE

/proc/interact_106_pocket_939_prey(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp106/larry = istype(scp1, /mob/living/scp/scp106) ? scp1 : scp2
	var/mob/living/scp/scp939/predator = istype(scp1, /mob/living/scp/scp939) ? scp1 : scp2
	if(!larry || !predator)
		return FALSE
	for(var/mob/living/carbon/human/H in range(3, predator))
		if(H.stat == DEAD || H.SCP)
			continue
		H.apply_damage(15, BRUTE, sharpness = SHARP_EDGED)
		to_chat(H, span_userdanger("A dark puddle drags you briefly into a decaying void!"))
		to_chat(predator, span_notice("The prey's terror echoes... delicious. New voice patterns acquired."))
		return TRUE
	return FALSE

/proc/interact_049_detect_008(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp049/doctor = istype(scp1, /mob/living/scp/scp049) ? scp1 : scp2
	if(!doctor)
		return FALSE
	for(var/mob/living/simple_animal/hostile/scp008_zombie/Z in range(10, doctor))
		to_chat(doctor, span_notice("You sense the Pestilence has been partially cured in a nearby subject... imperfect, but promising."))
		return TRUE
	return FALSE

/proc/interact_049_sense_035_host(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp049/doctor = istype(scp1, /mob/living/scp/scp049) ? scp1 : scp2
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!doctor || !mask)
		return FALSE
	var/mob/living/carbon/human/host = mask.mask?.possession_system?.current_host
	if(host)
		to_chat(doctor, span_warning("You sense an UNUSUALLY concentrated Pestilence in that host... it clouds your judgment. Fascinating."))
	else
		to_chat(doctor, span_notice("You detect a dormant but incredibly potent strain of the Pestilence nearby... unlike anything you've encountered."))
	return TRUE

/proc/interact_049_cure_008_zombie(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp049/doctor = istype(scp1, /mob/living/scp/scp049) ? scp1 : scp2
	if(!doctor)
		return FALSE
	for(var/mob/living/simple_animal/hostile/scp008_zombie/Z in range(3, doctor))
		Z.visible_message(span_danger("SCP-049 touches the SCP-008 zombie! The creature convulses violently!"))
		Z.maxHealth += 50
		Z.health = min(Z.health + 30, Z.maxHealth)
		Z.move_to_delay = max(3, Z.move_to_delay - 2)
		Z.name = "SCP-049-008 abomination"
		to_chat(doctor, span_notice("The Pestilence... it merges. A superior form emerges."))
		log_game("SCP-049-008 Abomination created at [get_area_name(doctor)]")
		return TRUE
	return FALSE

/proc/interact_035_manipulate_049(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	var/mob/living/scp/scp049/doctor = istype(scp1, /mob/living/scp/scp049) ? scp1 : scp2
	if(!mask || !doctor)
		return FALSE
	to_chat(doctor, span_notice("A calm voice speaks: \"Doctor... I am already cured. The Pestilence does not reside in me.\""))
	to_chat(doctor, span_notice("You feel... uncertain. The compulsion to cure fades temporarily."))
	return TRUE

/proc/interact_035_possess_008_zombie(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!mask || !mask.mask)
		return FALSE
	for(var/mob/living/simple_animal/hostile/scp008_zombie/Z in range(5, mask))
		Z.visible_message(span_danger("SCP-035's corrosive ichor seeps into the zombie! It stands upright with newfound intelligence!"))
		Z.name = "SCP-035-008 possessed"
		Z.melee_damage_lower = Z.melee_damage_lower + 10
		Z.melee_damage_upper = Z.melee_damage_upper + 10
		log_game("SCP-035-008 Possessed Zombie created at [get_area_name(mask)]")
		return TRUE
	return FALSE

/proc/interact_035_corrupt_939_voice(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	var/mob/living/scp/scp939/predator = istype(scp1, /mob/living/scp/scp939) ? scp1 : scp2
	if(!mask || !predator)
		return FALSE
	if(predator.voice_system)
		predator.voice_system.learn_voice(mask)
		predator.detection_range = min(20, predator.detection_range + 3)
		addtimer(CALLBACK(predator, /mob/living/scp/scp939/proc/reset_detection_range), 60 SECONDS)
	to_chat(predator, span_notice("New voice patterns merge with your own... the prey will not resist."))
	return TRUE

/mob/living/scp/scp939/proc/reset_detection_range()
	detection_range = initial(detection_range)

/proc/interact_999_calm_096(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp999/slime = istype(scp1, /mob/living/scp/scp999) ? scp1 : scp2
	if(!slime)
		return FALSE
	slime.visible_message(span_notice("SCP-999 approaches, emanating warmth and comfort. The air feels lighter."))
	for(var/mob/living/carbon/human/H in range(slime.comfort_radius, slime))
		if(H.sanity)
			H.sanity.adjust_sanity(15, "scp999_comfort")
	return TRUE

/proc/interact_999_calm_682(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp999/slime = istype(scp1, /mob/living/scp/scp999) ? scp1 : scp2
	var/mob/living/scp/scp682/reptile = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!slime || !reptile)
		return FALSE
	reptile.visible_message(span_notice("SCP-682 goes still, watching SCP-999 with what might be... tolerance?"))
	reptile.damage_modifier = max(0.3, reptile.damage_modifier - 0.3)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/restore_682_damage_modifier, reptile), 45 SECONDS)
	return TRUE

/proc/restore_682_damage_modifier(mob/living/scp/scp682/reptile)
	if(!QDELETED(reptile))
		reptile.damage_modifier = min(1.5, reptile.damage_modifier + 0.3)

/proc/interact_999_counter_513(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp999/slime = istype(scp1, /mob/living/scp/scp999) ? scp1 : scp2
	if(!slime)
		return FALSE
	for(var/mob/living/carbon/human/H in range(slime.comfort_radius, slime))
		if(H.stat != DEAD)
			H.RemoveElement(/datum/element/scp513_stalked)
			to_chat(H, span_notice("The looming presence recedes. You feel safe again."))
	return TRUE

/proc/interact_999_counter_035(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp999/slime = istype(scp1, /mob/living/scp/scp999) ? scp1 : scp2
	if(!slime)
		return FALSE
	for(var/mob/living/carbon/human/H in range(slime.comfort_radius, slime))
		if(H.sanity)
			H.sanity.adjust_sanity(20, "scp999_035_shield")
	return TRUE

/proc/interact_999_heal_049_victims(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp999/slime = istype(scp1, /mob/living/scp/scp999) ? scp1 : scp2
	if(!slime)
		return FALSE
	for(var/mob/living/carbon/human/H in range(slime.comfort_radius, slime))
		if(H.stat != DEAD)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, -15)
			H.adjustBruteLoss(-20, updating_health = TRUE)
			to_chat(H, span_notice("Warmth washes over you. Some of the damage recedes."))
			return TRUE
	return FALSE

/proc/interact_682_resist_106(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/reptile = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!reptile)
		return FALSE
	if(reptile.evolution_system)
		reptile.evolution_system.add_adaptation("dimensional_resistance", 1.0)
	reptile.visible_message(span_warning("SCP-682's scales shimmer and harden against dimensional decay!"))
	return TRUE

/proc/interact_682_fight_457(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/reptile = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	var/mob/living/scp/scp457/flame = istype(scp1, /mob/living/scp/scp457) ? scp1 : scp2
	if(!reptile || !flame)
		return FALSE
	reptile.adjustFireLoss(-50, updating_health = TRUE, forced = TRUE)
	if(reptile.evolution_system)
		reptile.evolution_system.add_adaptation("fire_resistance", 0.5)
	flame.AddHeat(30)
	reptile.visible_message(span_danger("SCP-682 and SCP-457 clash! Fire and fury! 682 begins adapting; 457 feeds on the destruction!"))
	return TRUE

/proc/interact_682_consume_008(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/reptile = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!reptile)
		return FALSE
	for(var/mob/living/simple_animal/hostile/scp008_zombie/Z in range(3, reptile))
		reptile.adjustBruteLoss(-30, updating_health = TRUE, forced = TRUE)
		if(reptile.evolution_system)
			reptile.evolution_system.add_adaptation("bioweapon_immunity", 0.5)
		Z.gib()
		reptile.visible_message(span_danger("SCP-682 devours the SCP-008 zombie whole! It seems... stronger."))
		return TRUE
	return FALSE

/proc/interact_457_feed_895_corpse(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp457/flame = istype(scp1, /mob/living/scp/scp457) ? scp1 : scp2
	var/obj/structure/coffin/scp895/coffin = istype(scp1, /obj/structure/coffin/scp895) ? scp1 : scp2
	if(!flame || !coffin)
		return FALSE
	flame.AddHeat(20)
	coffin.hallucination_range_camera = min(30, coffin.hallucination_range_camera + 5)
	coffin.hallucination_range_direct = min(6, coffin.hallucination_range_direct + 1)
	flame.visible_message(span_danger("SCP-457 burns near SCP-895! Corrupted smoke billows through the vents!"))
	return TRUE

/proc/interact_457_ignite_106_residue(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp457/flame = istype(scp1, /mob/living/scp/scp457) ? scp1 : scp2
	if(!flame)
		return FALSE
	for(var/obj/effect/scp106_residue/R in range(8, flame))
		var/turf/T = get_turf(R)
		qdel(R)
		for(var/mob/living/carbon/human/H in range(3, T))
			H.apply_damage(10, TOX)
			to_chat(H, span_warning("Toxic fumes burn your lungs!"))
		break
	flame.visible_message(span_danger("SCP-457 ignites SCP-106's residue! Toxic smoke fills the corridor!"))
	return TRUE

/proc/interact_895_corrupt_079_cameras(mob/living/scp1, mob/living/scp2)
	var/obj/structure/coffin/scp895/coffin = istype(scp1, /obj/structure/coffin/scp895) ? scp1 : scp2
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	if(!coffin || !ai)
		return FALSE
	ai.processing_power = max(10, ai.processing_power - 20)
	addtimer(CALLBACK(ai, /mob/living/scp079/proc/restore_processing_power), 60 SECONDS)
	ai.visible_message(span_warning("SCP-079's screen flickers with corrupted imagery!"))
	return TRUE

/mob/living/scp079/proc/restore_processing_power()
	processing_power = min(max_processing_power, processing_power + 20)

/proc/interact_1471_manifest_near_939(mob/living/scp1, mob/living/scp2)
	var/obj/item/device/scp1471/phone = istype(scp1, /obj/item/device/scp1471) ? scp1 : scp2
	var/mob/living/scp/scp939/predator = istype(scp1, /mob/living/scp/scp939) ? scp1 : scp2
	if(!phone || !predator)
		return FALSE
	for(var/mob/living/carbon/human/H in range(predator.detection_range, predator))
		if(H.stat != DEAD)
			H.hallucination += 15
			to_chat(H, span_warning("You see a shadowy figure in your peripheral vision... but it's not alone."))
			break
	return TRUE

/proc/interact_939_mimic_035_voice(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp939/predator = istype(scp1, /mob/living/scp/scp939) ? scp1 : scp2
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!predator || !mask)
		return FALSE
	if(predator.voice_system)
		predator.voice_system.learn_voice(mask)
	for(var/mob/living/carbon/human/H in range(predator.detection_range, predator))
		if(H.stat != DEAD && !H.SCP)
			to_chat(H, span_warning("You hear a familiar voice calling your name... it sounds so real..."))
			if(H.sanity)
				H.sanity.adjust_sanity(-5, "scp939_035_lure")
			break
	return TRUE

// ============================================================================
// SCP-610 CROSS-INTERACTIONS
// ============================================================================

/proc/interact_610_flesh_overrun_008(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(5, scp1))
		for(var/mob/living/simple_animal/hostile/scp008_zombie/Z in range(3, F))
			F.visible_message(span_danger("[F] consumes [Z]'s infected flesh!"))
			qdel(Z)
			F.adjustHealth(-20)
			break
		break
	return TRUE

/proc/interact_610_spread_on_682(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/lizard = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!lizard)
		return FALSE
	if(lizard.evolution_system)
		lizard.evolution_system.active_adaptations["bio_resistance"] = world.time + 120 SECONDS
	lizard.visible_message(span_danger("[lizard] shakes off the fleshy growth with extreme prejudice!"))
	return TRUE

/proc/interact_610_corrupt_939_voice(mob/living/scp1, mob/living/scp2)
	var/mob/living/simple_animal/hostile/scp610_half_infested/infested = locate() in range(5, scp1)
	if(!infested)
		return FALSE
	infested.visible_message(span_warning("[infested] emits a disturbing gurgling sound that harmonizes with nearby predatory calls..."))
	return TRUE

/proc/interact_610_absorb_035_host(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_610_infest_087_stairwell(mob/living/scp1, mob/living/scp2)
	var/obj/structure/scp087/stairs = istype(scp1, /obj/structure/scp087) ? scp1 : (istype(scp2, /obj/structure/scp087) ? scp2 : null)
	if(!stairs)
		return FALSE
	stairs.visible_message(span_warning("Flesh creeps begin spreading down the stairwell... The descent grows more horrifying."))
	return TRUE

/proc/interact_610_overrun_3008(mob/living/scp1, mob/living/scp2)
	for(var/obj/structure/scp610_flesh_structure/F in range(5, scp1))
		for(var/mob/living/simple_animal/hostile/retaliate/scp1507/staff in range(5, F))
			staff.visible_message(span_danger("[staff] attacks [F] with territorial fury!"))
			F.take_damage(15, BRUTE, "melee")
			break
		break
	return TRUE

/proc/interact_013_bluelady_012(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(5, scp1))
		if(H.stat == DEAD || H.SCP)
			continue
		if(prob(10))
			to_chat(H, span_warning("A ghostly melody fills your mind, compelling you to write..."))
	return TRUE

/proc/interact_017_shadow_173(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp173/statue = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!statue)
		return FALSE
	statue.visible_message(span_warning("A shadowy entity manifests near [statue], lingering in the darkness..."))
	return TRUE

/proc/interact_017_shadow_096(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_073_reflect_682(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/lizard = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!lizard)
		return FALSE
	if(lizard.evolution_system)
		lizard.evolution_system.active_adaptations["reflection_immunity"] = world.time + 180 SECONDS
	lizard.visible_message(span_danger("[lizard] seems to learn from the reflected damage, adapting rapidly!"))
	return TRUE

/proc/interact_073_reflect_457(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp457/flame = istype(scp1, /mob/living/scp/scp457) ? scp1 : scp2
	if(!flame)
		return FALSE
	flame.adjustFireLoss(30, updating_health = TRUE, forced = TRUE)
	flame.visible_message(span_danger("[flame] recoils as its own fire is reflected back!"))
	return TRUE

/proc/interact_076_dual_682(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/lizard = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(lizard?.evolution_system)
		lizard.evolution_system.active_adaptations["combat_experience"] = world.time + 300 SECONDS
	scp1.visible_message(span_danger("Two abominations clash in a devastating battle that shakes the facility!"))
	return TRUE

/proc/interact_076_dual_096(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_danger("A berserker and a screaming giant feed off each other's rage! The air crackles with hostility!"))
	return TRUE

/proc/interact_076_hunt_610(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(8, scp1))
		F.adjustHealth(40)
		F.visible_message(span_danger("A supernatural warrior carves through [F] with practiced efficiency!"))
		break
	return TRUE

/proc/interact_082_feed_610(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp082/chef = istype(scp1, /mob/living/scp/scp082) ? scp1 : scp2
	if(!chef)
		return FALSE
	chef.adjustBruteLoss(-15)
	chef.visible_message(span_danger("[chef] devours a piece of flesh with grotesque satisfaction, growing more robust!"))
	return TRUE

/proc/interact_082_feed_1048(mob/living/scp1, mob/living/scp2)
	var/mob/living/simple_animal/scp1048/bear = locate() in range(3, scp1)
	if(bear)
		bear.visible_message(span_warning("[scp1] eyes [bear] hungrily, but the bear construct fights back!"))
	return TRUE

/proc/interact_087_deep_fear_096(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_1048_build_610(mob/living/scp1, mob/living/scp2)
	var/mob/living/simple_animal/scp1048/bear = istype(scp1, /mob/living/simple_animal/scp1048) ? scp1 : scp2
	if(!bear)
		return FALSE
	var/turf/T = get_turf(bear)
	if(!T || !istype(T, /turf/open/flesh))
		return FALSE
	bear.visible_message(span_danger("[bear] constructs a flesh bear from the organic material!"))
	var/mob/living/simple_animal/hostile/scp610_fleshman/flesh_bear = new(T)
	flesh_bear.name = "SCP-1048-C (Flesh)"
	flesh_bear.maxHealth = 200
	flesh_bear.health = 200
	return TRUE

/proc/interact_105_portal_1128(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(5, scp1))
		if(H.stat == DEAD)
			continue
		for(var/turf/open/water/W in range(10, H))
			to_chat(H, span_warning("You feel a terrible awareness of something vast lurking in the water..."))
			break
		break
	return TRUE

/proc/interact_105_portal_106(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_notice("A portal flickers open, bypassing the dimensional decay nearby."))
	return TRUE

/proc/interact_1102_ladder_087(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_1102_ladder_1499(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_1128_aquatic_610(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(5, scp1))
		if(H.stat == DEAD || H.SCP)
			continue
		if(prob(10))
			scp610_infect(H, 15)
			to_chat(H, span_userdanger("The fear of the deep weakens your mental defenses! The flesh takes hold!"))
			break
	return TRUE

/proc/interact_131_watch_173(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp173/statue = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!statue)
		return FALSE
	statue.visible_message(span_notice("A small eye-pod creature stares unblinkingly at the sculpture, keeping it still."))
	return TRUE

/proc/interact_131_watch_096(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp096/shy = istype(scp1, /mob/living/scp/scp096) ? scp1 : scp2
	if(!shy)
		return FALSE
	scp1.visible_message(span_notice("A small eye-pod creature averts its gaze, making distressed sounds as a warning."))
	return TRUE

/proc/interact_1507_flock_610(mob/living/scp1, mob/living/scp2)
	for(var/obj/structure/scp610_flesh_structure/F in range(5, scp1))
		F.take_damage(10, BRUTE, "melee")
		F.visible_message(span_warning("A flamingo pecks aggressively at [F]!"))
		break
	return TRUE

/proc/interact_1507_flock_3008(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_151_mirror_035(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!mask)
		return FALSE
	for(var/mob/living/carbon/human/H in range(8, mask))
		if(H.stat == DEAD || H.SCP)
			continue
		if(prob(15))
			to_chat(H, span_warning("You see strange suggestions in the water's reflection..."))
			break
	return TRUE

/proc/interact_151_mirror_895(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(5, scp1))
		if(H.stat == DEAD)
			continue
		if(H.hallucination < 30)
			H.hallucination += 10
		break
	return TRUE

/proc/interact_1981_broadcast_079(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	if(!ai)
		return FALSE
	ai.visible_message(span_warning("Static from the broadcast interferes with [ai]'s processing..."))
	return TRUE

/proc/interact_1981_broadcast_035(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(8, scp1))
		if(H.stat == DEAD || H.SCP)
			continue
		if(prob(10))
			to_chat(H, span_warning("The broadcast mentions something that resonates with a dark presence in your mind..."))
			break
	return TRUE

/proc/interact_2020_phase_106(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_warning("Spatial distortions ripple through the area as two phasing entities interfere with each other!"))
	return TRUE

/proc/interact_2020_phase_1499(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_2343_benevolence_610(mob/living/scp1, mob/living/scp2)
	for(var/obj/structure/scp610_flesh_structure/F in range(5, scp1))
		F.take_damage(25, BURN, FIRE)
		F.visible_message(span_notice("The flesh withers and recoils from the benevolent presence!"))
		break
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/M in range(5, scp1))
		M.adjustHealth(15)
		break
	return TRUE

/proc/interact_2343_benevolence_049(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp049/doctor = istype(scp1, /mob/living/scp/scp049) ? scp1 : scp2
	if(!doctor)
		return FALSE
	doctor.visible_message(span_notice("[doctor] seems calmer in the benevolent presence, its compulsion diminished."))
	return TRUE

/proc/interact_2427_malfunction_079(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	if(!ai)
		return FALSE
	ai.visible_message(span_warning("[ai]'s processes stutter and glitch from electronic interference!"))
	return TRUE

/proc/interact_2427_malfunction_914(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_280_shadow_017(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_danger("Shadows merge and twist, forming a larger and more menacing darkness!"))
	return TRUE

/proc/interact_280_shadow_106(mob/living/scp1, mob/living/scp2)
	var/mob/living/simple_animal/hostile/scp280/shadow = istype(scp1, /mob/living/simple_animal/hostile/scp280) ? scp1 : scp2
	if(!shadow)
		return FALSE
	shadow.visible_message(span_warning("[shadow] slips through shadows into a dimensional pocket!"))
	return TRUE

/proc/interact_3008_staff_610(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/staff in range(5, scp1))
		for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(3, staff))
			staff.visible_message(span_danger("[staff] attacks [F] with staff-like fury!"))
			F.adjustHealth(20)
			break
		break
	return TRUE

/proc/interact_3199_egg_610(mob/living/scp1, mob/living/scp2)
	var/turf/T = get_turf(scp1)
	if(!T || !istype(T, /turf/open/flesh))
		return FALSE
	scp1.visible_message(span_danger("An egg hatches on the flesh, releasing a hybrid creature!"))
	return TRUE

/proc/interact_3199_egg_008(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_danger("Eggs hatch near infected tissue, releasing plague-spreading hybrids!"))
	return TRUE

/proc/interact_343_god_682(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/lizard = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!lizard)
		return FALSE
	lizard.adjustBruteLoss(30)
	lizard.visible_message(span_warning("[lizard] seems diminished in this presence, its adaptations failing."))
	return TRUE

/proc/interact_343_god_999(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp999/tickle = istype(scp1, /mob/living/scp/scp999) ? scp1 : scp2
	if(!tickle)
		return FALSE
	tickle.visible_message(span_notice("[tickle]'s aura glows brighter in the divine presence!"))
	return TRUE

/proc/interact_347_stealth_035(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!mask)
		return FALSE
	mask.visible_message(span_warning("An unseen agent extends the mask's influence..."))
	return TRUE

/proc/interact_408_swarm_173(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp173/statue = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!statue)
		return FALSE
	statue.visible_message(span_warning("A butterfly swarm obscures vision near [statue]..."))
	return TRUE

/proc/interact_408_swarm_096(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp096/shy = istype(scp1, /mob/living/scp/scp096) ? scp1 : scp2
	if(!shy)
		return FALSE
	shy.visible_message(span_warning("Butterflies swarm around [shy], briefly distracting it."))
	return TRUE

/proc/interact_527_trade_999(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_notice("A small dragon-like creature and a slime blob exchange objects in an adorable display."))
	return TRUE

/proc/interact_527_trade_082(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp082/chef = istype(scp1, /mob/living/scp/scp082) ? scp1 : scp2
	if(!chef)
		return FALSE
	chef.visible_message(span_notice("[chef] accepts ingredients from a small dragon-like creature and begins cooking!"))
	return TRUE

/proc/interact_529_half_cat_131(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_notice("A half-cat and an eye-pod creature form an adorable protective pair."))
	return TRUE

/proc/interact_966_stalk_610(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(5, scp1))
		var/datum/status_effect/scp610_infection/infection = H.has_status_effect(/datum/status_effect/scp610_infection)
		if(infection)
			infection.infection_progress += 5
			to_chat(H, span_warning("Your exhausted body can't fight the infection... it's spreading faster!"))
			break
	return TRUE

/proc/interact_966_stalk_096(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(8, scp1))
		if(H.stat == DEAD)
			continue
		if(prob(5))
			to_chat(H, span_warning("Your sleep-deprived eyes struggle to focus... you almost saw something terrible."))
			break
	return TRUE

/proc/interact_080_fog_610(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(5, scp1))
		F.alpha = 100
		F.visible_message(span_warning("[F] becomes nearly invisible in the fog!"))
		addtimer(CALLBACK(F, TYPE_PROC_REF(/atom, update_appearance)), 30 SECONDS)
		break
	return TRUE

/proc/interact_080_fog_173(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp173/statue = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!statue)
		return FALSE
	statue.visible_message(span_warning("Fog rolls in around [statue], reducing visibility..."))
	return TRUE

/proc/interact_080_fog_280(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_danger("The fog and shadows merge into a wall of living darkness!"))
	return TRUE

/proc/interact_066_eric_035(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!mask)
		return FALSE
	scp1.visible_message(span_warning("A small metal sphere repeatedly says 'Eric!' near [mask], disrupting its concentration."))
	return TRUE

/proc/interact_3349_liquid_008(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_danger("The reagent interacts with infected tissue, creating an accelerated infection vector!"))
	return TRUE

/proc/interact_3349_liquid_610(mob/living/scp1, mob/living/scp2)
	scp1.visible_message(span_danger("The reagent dissolves into liquid flesh that pulses with infection!"))
	return TRUE

/proc/interact_2398_baseball_173(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp173/statue = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!statue)
		return FALSE
	var/obj/item/material/twohanded/baseballbat/scp2398/bat = locate() in range(2, statue)
	if(!bat)
		return FALSE
	statue.visible_message(span_danger("[statue] is knocked backward by a powerful swing!"))
	step_away(statue, bat, 2)
	return TRUE

/proc/interact_2398_baseball_610(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(3, scp1))
		F.adjustHealth(25)
		F.visible_message(span_danger("[F] is knocked back by a powerful swing!"))
		break
	return TRUE

/proc/interact_247_illusion_096(mob/living/scp1, mob/living/scp2)
	return TRUE

/proc/interact_247_illusion_173(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp173/statue = istype(scp1, /mob/living/scp/scp173) ? scp1 : scp2
	if(!statue)
		return FALSE
	statue.visible_message(span_warning("[statue] appears as a harmless decorative piece... but something feels wrong."))
	return TRUE

/proc/interact_5295_digital_079(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp079/ai = istype(scp1, /mob/living/scp079) ? scp1 : scp2
	if(!ai)
		return FALSE
	ai.visible_message(span_warning("[ai] begins executing strange procedures from an unknown protocol..."))
	return TRUE

/proc/interact_035_manipulate_610(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp035/mask = istype(scp1, /mob/living/scp035) ? scp1 : scp2
	if(!mask)
		return FALSE
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(5, mask))
		F.visible_message(span_danger("[F] seems to move with unnatural purpose, as if directed by an intelligence beyond the flesh..."))
		break
	return TRUE

/proc/interact_049_sense_610_flesh(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp049/doctor = istype(scp1, /mob/living/scp/scp049) ? scp1 : scp2
	if(!doctor)
		return FALSE
	doctor.visible_message(span_warning("[doctor] becomes agitated, sensing an extreme form of the Pestilence in the flesh nearby!"))
	return TRUE

/proc/interact_999_calm_610(mob/living/scp1, mob/living/scp2)
	for(var/mob/living/carbon/human/H in range(5, scp1))
		var/datum/status_effect/scp610_infection/infection = H.has_status_effect(/datum/status_effect/scp610_infection)
		if(infection)
			infection.infection_progress = max(0, infection.infection_progress - 5)
			to_chat(H, span_notice("A warm, joyful aura soothes the burning in your flesh..."))
			break
	return TRUE

/proc/interact_682_adapt_610(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp682/lizard = istype(scp1, /mob/living/scp/scp682) ? scp1 : scp2
	if(!lizard)
		return FALSE
	if(lizard.evolution_system)
		lizard.evolution_system.active_adaptations["flesh_immunity"] = world.time + 300 SECONDS
	lizard.adjustBruteLoss(-10)
	lizard.visible_message(span_danger("[lizard] consumes the flesh creatures and grows stronger, completely immune to the infection!"))
	return TRUE

/proc/interact_457_burn_610(mob/living/scp1, mob/living/scp2)
	var/burned = FALSE
	for(var/obj/structure/scp610_flesh_structure/F in range(5, scp1))
		F.take_damage(40, BURN, FIRE)
		F.visible_message(span_danger("[F] burns rapidly in the intense heat!"))
		burned = TRUE
		break
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/M in range(5, scp1))
		M.adjustFireLoss(30)
		burned = TRUE
		break
	return burned

/proc/interact_939_hunt_610(mob/living/scp1, mob/living/scp2)
	var/mob/living/scp/scp939/predator = istype(scp1, /mob/living/scp/scp939) ? scp1 : scp2
	if(!predator)
		return FALSE
	for(var/mob/living/simple_animal/hostile/scp610_half_infested/infested in range(8, predator))
		infested.adjustHealth(20)
		infested.visible_message(span_danger("[predator] preys on the half-infested [infested]!"))
		break
	return TRUE
