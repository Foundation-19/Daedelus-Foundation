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
	if(flame.heat_system)
		flame.heat_system.add_heat(30)
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
	if(flame.heat_system)
		flame.heat_system.add_heat(20)
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
