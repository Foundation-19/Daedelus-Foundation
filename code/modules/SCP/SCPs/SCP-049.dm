// SCP-049 - The Plague Doctor
// Foundation-19 style: contextual UnarmedAttack, passive pestilence, door pry on click,
// anger/patience, regen scales with zombies, voice emotes as verbs

/mob/living/scp/scp049
	ai_enabled = TRUE
	name = "SCP-049"
	desc = "A tall humanoid figure wearing the black robes and bird-like mask of a medieval plague doctor."
	icon = 'icons/scp/scp-049.dmi'
	icon_state = ""
	real_name = "SCP-049"
	persistence_id = "SCP-049"

	var/emote_cooldown = 5 SECONDS
	var/door_cooldown = 10 SECONDS
	var/base_regen = 0.05
	var/regen_multiply = 1.5
	var/heal_cooldown_time = 2 SECONDS

	var/cured_count = 0
	var/anger_timer = 0
	var/anger_timer_max = 40
	var/last_interaction_time = 0
	var/patience_limit = 15 MINUTES
	var/area/home_area = null

	var/emote_cooldown_track = 0
	var/door_cooldown_track = 0
	var/heal_cooldown_track = 0
	var/patience_cooldown_track = 0

	var/pestilence_level = 0
	var/max_pestilence_level = SCP049_MAX_PESTILENCE_LEVEL
	var/pestilence_detect_radius = SCP049_PESTILENCE_SPREAD_RADIUS
	var/pestilence_detect_chance = SCP049_PESTILENCE_INFECTION_CHANCE
	var/pestilence_cooldown = 0
	var/pestilence_cooldown_time = SCP049_PESTILENCE_COOLDOWN

	var/cure_potency = 1
	var/max_cure_potency = SCP049_MAX_CURE_POTENCY
	var/cure_cooldown = 0
	var/cure_cooldown_time = SCP049_CURE_COOLDOWN
	var/cure_range = SCP049_CURE_RANGE
	var/cure_effectiveness = SCP049_CURE_EFFECTIVENESS

	var/breach_cooldown = 0
	var/breach_cooldown_time = SCP049_BREACH_COOLDOWN
	var/breach_range = SCP049_BREACH_RANGE
	var/breach_power = SCP049_BREACH_POWER

	var/research_progress = 0
	var/max_research_progress = SCP049_MAX_RESEARCH_PROGRESS
	var/evolution_stage = 1
	var/max_evolution_stage = SCP049_MAX_EVOLUTION_STAGE
	var/research_cooldown = 0
	var/research_cooldown_time = SCP049_RESEARCH_COOLDOWN

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

	var/detections_performed = 0
	var/cures_attempted = 0
	var/cures_successful = 0
	var/research_breakthroughs = 0
	var/evolution_events = 0
	var/session_start_time = 0
	var/turf/lure_target = null
	var/total_playtime = 0

	var/datum/scp049_command_system/command_system

	var/containment_breaches = 0

/mob/living/scp/scp049/Initialize()
	. = ..()

	faction |= "scp049"

	SCP = new /datum/scp(src, "Plague Doctor", SCP_EUCLID, "049", SCP_SENTIENT)

	session_start_time = world.time
	home_area = get_area(src)
	command_system = new /datum/scp049_command_system(src)

	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.add_atom_to_hud(src)

	grant_language(/datum/language/common, TRUE, TRUE)
	load_persistence_data()

	add_verb(src, list(
		/mob/living/scp/scp049/proc/Greetings,
		/mob/living/scp/scp049/proc/YetAnotherVictim,
		/mob/living/scp/scp049/proc/YouAreNotDoctor,
		/mob/living/scp/scp049/proc/SenseDiseaseInYou,
		/mob/living/scp/scp049/proc/HereToCureYou,
	))

/mob/living/scp/scp049/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return
	if(stat == DEAD)
		return

	process_pestilence_passive()
	anger_timer = max(anger_timer - 1, 0)

	if(world.time > patience_cooldown_track && world.time > last_interaction_time + patience_limit && get_area(src) == home_area)
		patience_cooldown_track = world.time + 5 MINUTES
		to_chat(src, span_danger("They really abandoned you in here..? Seems like it's time to take a walk."))
		anger_timer = min(anger_timer + 15, anger_timer_max)

	if(cured_count < 1)
		return
	if((world.time - heal_cooldown_track) < heal_cooldown_time)
		return
	heal_cooldown_track = world.time
	var/heal_amount = -(base_regen * (cured_count * regen_multiply))
	adjustBruteLoss(heal_amount)
	adjustFireLoss(heal_amount)

/mob/living/scp/scp049/proc/process_pestilence_passive()
	for(var/mob/living/carbon/human/H in range(pestilence_detect_radius, src))
		if(H == src || isscp049_1(H))
			continue
		if(!HAS_TRAIT(H, TRAIT_PESTILENCE) && !HAS_TRAIT(H, TRAIT_PESTILENCE_IMMUNE))
			if(prob(3))
				ADD_TRAIT(H, TRAIT_PESTILENCE, "scp049")
				H.update_pestilence_hud()
				to_chat(src, span_danger("You sense the Pestilence within [H]... They must be cured."))

/mob/living/scp/scp049/UnarmedAttack(atom/A)
	if(!istype(A))
		return

	if(istype(A, /obj/machinery/door))
		changeNext_move(CLICK_CD_MELEE)
		OpenDoor(A)
		return

	if(!ishuman(A))
		return ..()

	var/mob/living/carbon/human/H = A

	if(isscp049_1(H))
		return ..()

	if(H.SCP)
		to_chat(src, span_warning("This thing... it isn't normal... you cannot cure it."))
		return

	changeNext_move(CLICK_CD_MELEE)

	if(combat_mode)
		if(!HAS_TRAIT(H, TRAIT_PESTILENCE))
			to_chat(src, span_warning("They are not infected with the Pestilence."))
			return

		if(can_touch_bare_skin(H))
			H.visible_message(span_danger("<i>[src] reaches towards [H]!</i>"))
			attack_voice_line()
			H.death()
			cured_count++
			cures_attempted++
			cures_successful++
			cure_potency = min(max_cure_potency, cure_potency + 1)
			to_chat(H, span_userdanger("You have been killed by SCP-049. Be patient as you may yet be cured..."))
			to_chat(src, span_notice("They are ready for your cure."))
			on_cure_attempt(H)
			track_scp049_cure(src, H, TRUE)
			playsound(H, 'sound/scp/scp049/SCP049_Cure1.ogg', 60, FALSE)
			save_persistence_data()
		else
			if(anger_timer >= anger_timer_max * 0.75)
				H.visible_message(span_danger("<i>[src] reaches towards [H], making them stumble!</i>"))
				H.Paralyze(20)
				return
			H.visible_message(span_warning("<i>[src] reaches towards [H], but nothing happens...</i>"))
			to_chat(src, span_warning("[H]'s [zone_selected] is covered. You must make contact with bare skin to kill!"))
		return
	else
		to_chat(src, span_notice("You refrain from curing as your intent is set to help."))
		return ..()

/mob/living/scp/scp049/attack_hand(mob/living/carbon/human/M)
	if(isscp049_1(M))
		to_chat(M, span_danger(span_bold("Do not attack your master!")))
		return

	if(M.combat_mode && M != src)
		if(!HAS_TRAIT(M, TRAIT_PESTILENCE) && !HAS_TRAIT(M, TRAIT_PESTILENCE_IMMUNE))
			ADD_TRAIT(M, TRAIT_PESTILENCE, "scp049")
			M.update_pestilence_hud()
		anger_timer = min(anger_timer + 2, anger_timer_max)
		last_interaction_time = world.time

	return ..()

/mob/living/scp/scp049/bullet_act(obj/projectile/P, def_zone)
	if(ishuman(P.firer) && P.firer != src)
		var/mob/living/carbon/human/H = P.firer
		if(isscp049_1(H))
			to_chat(H, span_danger(span_bold("Do not attack your master!")))
			return
		if(!HAS_TRAIT(H, TRAIT_PESTILENCE) && !HAS_TRAIT(H, TRAIT_PESTILENCE_IMMUNE))
			ADD_TRAIT(H, TRAIT_PESTILENCE, "scp049")
			H.update_pestilence_hud()
		anger_timer = min(anger_timer + 2, anger_timer_max)
		last_interaction_time = world.time
	return ..()

/mob/living/scp/scp049/attackby(obj/item/I, mob/living/user, params)
	if(isscp049_1(user))
		to_chat(user, span_danger(span_bold("Do not attack your master!")))
		return
	if(I.force > 0 && ishuman(user) && user != src)
		var/mob/living/carbon/human/H = user
		if(!HAS_TRAIT(H, TRAIT_PESTILENCE) && !HAS_TRAIT(H, TRAIT_PESTILENCE_IMMUNE))
			ADD_TRAIT(H, TRAIT_PESTILENCE, "scp049")
			H.update_pestilence_hud()
		anger_timer = min(anger_timer + 2, anger_timer_max)
		last_interaction_time = world.time
	return ..()

/mob/living/scp/scp049/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(HAS_TRAIT(H, TRAIT_PESTILENCE))
		var/pest_message = pick("They reek of the disease.", "They need to be cured.", "The disease is strong in them.", "You sense the pestilence in them.")
		to_chat(src, span_danger(span_bold(pest_message)))

/mob/living/scp/scp049/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), atom/sound_loc, message_range)
	. = ..()
	if(speaker == src)
		return
	last_interaction_time = world.time

/mob/living/scp/scp049/proc/can_touch_bare_skin(mob/living/carbon/human/target)
	if(!target)
		return FALSE
	var/list/covered_zones = target.get_covered_body_zones()
	var/zone = zone_selected
	if(zone in covered_zones)
		return FALSE
	return TRUE

/mob/living/scp/scp049/proc/OpenDoor(obj/machinery/door/D)
	if((world.time - door_cooldown_track) < door_cooldown)
		to_chat(src, span_warning("You can't open another door just yet!"))
		return
	if(!istype(D))
		return
	if(!D.density)
		return
	if(!D.Adjacent(src))
		to_chat(src, span_warning("[D] is too far away."))
		return

	var/open_time = 8 SECONDS - anger_timer * 2
	if(istype(D, /obj/machinery/door/poddoor))
		if(get_area(src) == home_area && world.time <= last_interaction_time + patience_limit && anger_timer < 5)
			to_chat(src, span_warning("You don't feel like leaving just yet."))
			return
		open_time += 10 SECONDS

	if(istype(D, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = D
		if(AR.locked)
			open_time += 3 SECONDS
		if(AR.welded)
			open_time += 3 SECONDS

	D.visible_message(span_warning("[src] begins to pry open [D]!"))
	playsound(get_turf(D), 'sound/machines/door_open.ogg', 35, TRUE)
	door_cooldown_track = world.time + open_time

	if(!do_after(src, open_time, D))
		return

	if(istype(D, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/AR = D
		AR.locked = FALSE
		AR.welded = FALSE

	D.open(TRUE)
	containment_breaches++
	on_breach()
	visible_message(span_danger("[src] forcefully pries open [D]!"))
	playsound(D, 'sound/scp/scp049/SCP049_2.ogg', 50, FALSE)

/mob/living/scp/scp049/proc/attack_voice_line()
	var/list/voicelines = list('sound/scp/scp049/SCP049_1.ogg', 'sound/scp/scp049/SCP049_2.ogg', 'sound/scp/scp049/SCP049_3.ogg', 'sound/scp/scp049/SCP049_4.ogg', 'sound/scp/scp049/SCP049_5.ogg')
	playsound(src, pick(voicelines), 30, FALSE)

/mob/living/scp/scp049/proc/PlagueDoctorCure(mob/living/carbon/human/target)
	if(target.stat != DEAD)
		return
	if(isscp049_1(target))
		return
	if(!HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(src, span_warning("They are not infected with the Pestilence."))
		return

	var/turf/T = get_turf(target)
	new /obj/effect/decal/cleanable/blood(T)
	playsound(T, 'sound/effects/splat.ogg', 20, TRUE)
	cured_count++

	target.visible_message(span_danger(span_bold("The lifeless corpse of [target] begins to convulse violently!")))
	REMOVE_TRAIT(target, TRAIT_PESTILENCE, "scp049")
	target.update_pestilence_hud()

	target.adjust_jitter(300)

	to_chat(src, span_notice("The cure is being administered..."))
	playsound(src, 'sound/scp/scp049/SCP049_Cure1.ogg', 60, FALSE)

	addtimer(CALLBACK(src, PROC_REF(FinishPlagueDoctorCure), target), 15 SECONDS)

/mob/living/scp/scp049/proc/FinishPlagueDoctorCure(mob/living/carbon/human/target)
	if(QDELETED(src) || QDELETED(target))
		return
	if(isscp049_1(target))
		return

	target.revive()
	target.visible_message(span_danger("[target]'s skin decays before your very eyes!"), \
		span_danger("You feel the last of your mind drift away... You must follow the one who cured you."))
	log_game("[key_name(target)] has transformed into an instance of 049-1!")

	target.Paralyze(40)

	playsound(get_turf(target), 'sound/hallucinations/wail.ogg', 25, TRUE)
	create_scp049_1(target)

	cures_successful++
	cure_potency = min(max_cure_potency, cure_potency + 1)
	on_cure_attempt(target)
	track_scp049_cure(src, target, TRUE)
	save_persistence_data()

/mob/living/scp/scp049/proc/create_scp049_1(mob/living/carbon/human/target)
	var/turf/T = get_turf(target)
	target.dust(just_ash = FALSE, drop_items = TRUE, force = TRUE)

	var/mob/living/simple_animal/hostile/zombie/scp049_1/zombie = new(T)
	zombie.name = "SCP-049-1"
	zombie.real_name = "SCP-049-1"
	zombie.maxHealth = SCP049_1_MAX_HEALTH
	zombie.health = zombie.maxHealth
	zombie.melee_damage_lower = SCP049_1_MELEE_DAMAGE_LOWER
	zombie.melee_damage_upper = SCP049_1_MELEE_DAMAGE_UPPER
	zombie.move_to_delay = SCP049_1_MOVE_DELAY
	zombie.setup_servant(src)
	if(target.client)
		zombie.key = target.key
		to_chat(zombie, span_danger("You have been converted into SCP-049-1! You are now a mindless servant of SCP-049."))

	visible_message(span_danger("[target] has been converted into SCP-049-1!"))
	playsound(src, 'sound/scp/scp049/SCP049_4.ogg', 70, FALSE)

/mob/living/scp/scp049/proc/isscp049_1(mob/M)
	return istype(M, /mob/living/simple_animal/hostile/zombie/scp049_1)

/mob/living/scp/scp049/proc/cure_target(mob/living/carbon/human/target)
	if(!target)
		return FALSE
	if(get_dist(src, target) > cure_range)
		to_chat(src, span_warning("You must be closer to administer the cure."))
		return FALSE
	if(target.stat != DEAD)
		to_chat(src, span_notice("They must be still for the cure..."))
		return FALSE
	PlagueDoctorCure(target)
	return TRUE

/mob/living/scp/scp049/proc/detect_pestilence()
	pestilence_level = min(max_pestilence_level, pestilence_level + 10)
	var/detected_count = 0
	for(var/mob/living/carbon/human/H in range(pestilence_detect_radius, src))
		if(H == src || isscp049_1(H))
			continue
		if(HAS_TRAIT(H, TRAIT_PESTILENCE))
			detected_count++
			on_pestilence_detected(H)
		else if(!HAS_TRAIT(H, TRAIT_PESTILENCE_IMMUNE) && prob(pestilence_detect_chance + (pestilence_level / 10)))
			ADD_TRAIT(H, TRAIT_PESTILENCE, "scp049")
			H.update_pestilence_hud()
			to_chat(src, span_notice("You sense the Pestilence within [H]... They must be cured."))
			detected_count++
			on_pestilence_detected(H)
	detections_performed++
	to_chat(src, span_notice("Pestilence detected in [detected_count] subjects. Level: [pestilence_level]/[max_pestilence_level]"))
	save_persistence_data()
	return TRUE

/mob/living/scp/scp049/proc/mark_pestilence(mob/living/carbon/human/target)
	if(!target)
		return FALSE
	if(HAS_TRAIT(target, TRAIT_PESTILENCE_IMMUNE))
		to_chat(src, span_warning("[target] appears... free of the Pestilence. Intriguing."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(src, span_notice("The Pestilence still festers within [target]..."))
		return FALSE
	ADD_TRAIT(target, TRAIT_PESTILENCE, "scp049")
	target.update_pestilence_hud()
	to_chat(src, span_notice("You sense the Pestilence within [target]... They must be cured."))
	playsound(target, 'sound/scp/scp049/SCP049_3.ogg', 30, FALSE)
	if(target.sanity)
		target.sanity.adjust_sanity(-10, "Sensed by SCP-049 as Pestilence carrier")
	return TRUE

/mob/living/scp/scp049/proc/breach_doors()
	for(var/obj/machinery/door/D in range(breach_range, src))
		if(D.density && D.Adjacent(src))
			OpenDoor(D)
			return

/mob/living/scp/scp049/proc/research_cure()
	if(world.time < research_cooldown)
		to_chat(src, span_warning("More research time is required..."))
		return FALSE
	research_cooldown = world.time + research_cooldown_time
	research_progress += rand(10, 25)
	to_chat(src, span_notice("Research progress: [research_progress]/[max_research_progress]"))
	if(research_progress >= max_research_progress)
		trigger_evolution()
	save_persistence_data()
	return TRUE

/mob/living/scp/scp049/proc/trigger_evolution()
	if(evolution_stage >= max_evolution_stage)
		to_chat(src, span_notice("You have achieved the pinnacle of the Great Work."))
		return
	evolution_stage++
	evolution_events++
	research_progress = 0
	switch(evolution_stage)
		if(2)
			pestilence_detect_radius++
			cure_effectiveness += 10
			to_chat(src, span_notice("Your understanding deepens. You can sense the Pestilence from farther away."))
		if(3)
			pestilence_detect_chance += 10
			cure_range++
			to_chat(src, span_notice("Your cure becomes more refined and potent."))
		if(4)
			max_pestilence_level += 50
			breach_power += 25
			to_chat(src, span_notice("Your influence grows stronger. Barriers mean nothing."))
		if(5)
			to_chat(src, span_notice("You have achieved perfect understanding of the Great Work."))
			apply_stage_5_abilities()
	research_breakthroughs++
	on_evolution()
	announce_evolution()
	save_persistence_data()

/mob/living/scp/scp049/proc/announce_evolution()
	var/announcement = "SCP-049 has evolved to stage [evolution_stage]! The Great Work progresses..."
	priority_announce(announcement, "SCP-049 Alert", , ANNOUNCER_ALERT)

/mob/living/scp/scp049/proc/announce_presence()
	if(world.time < last_announcement + announcement_cooldown)
		return
	last_announcement = world.time
	var/announcement = pick(announcement_messages)
	playsound(src, 'sound/scp/scp049/SCP049_1.ogg', 50, FALSE)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.z == z && get_dist(H, src) <= 15)
			to_chat(H, span_danger("<b>[announcement]</b>"))
			last_interaction_time = world.time

/mob/living/scp/scp049/proc/Greetings()
	set category = "SCP-049"
	set name = "Greetings"
	if(!CanSpecialEmote())
		return
	playsound(src, 'sound/scp/scp049/SCP049_1.ogg', 30, FALSE)

/mob/living/scp/scp049/proc/YetAnotherVictim()
	set category = "SCP-049"
	set name = "Yet Another Victim"
	if(!CanSpecialEmote())
		return
	playsound(src, 'sound/scp/scp049/SCP049_2.ogg', 30, FALSE)

/mob/living/scp/scp049/proc/YouAreNotDoctor()
	set category = "SCP-049"
	set name = "You Are Not A Doctor"
	if(!CanSpecialEmote())
		return
	playsound(src, 'sound/scp/scp049/SCP049_3.ogg', 30, FALSE)

/mob/living/scp/scp049/proc/SenseDiseaseInYou()
	set category = "SCP-049"
	set name = "I Sense The Disease"
	if(!CanSpecialEmote())
		return
	playsound(src, 'sound/scp/scp049/SCP049_4.ogg', 30, FALSE)

/mob/living/scp/scp049/proc/HereToCureYou()
	set category = "SCP-049"
	set name = "I'm Here To Cure You"
	if(!CanSpecialEmote())
		return
	playsound(src, 'sound/scp/scp049/SCP049_5.ogg', 30, FALSE)

/mob/living/scp/scp049/proc/CanSpecialEmote()
	if((world.time - emote_cooldown_track) > emote_cooldown)
		emote_cooldown_track = world.time
		return TRUE
	return FALSE

/mob/living/scp/scp049/get_status_tab_items()
	var/list/status_items = ..()
	status_items += "Pestilence Level: [pestilence_level]/[max_pestilence_level]"
	status_items += "Cure Potency: [cure_potency]/[max_cure_potency]"
	status_items += "Cured: [cured_count]"
	status_items += "Anger: [anger_timer]/[anger_timer_max]"
	status_items += "Evolution: [evolution_stage]/[max_evolution_stage]"
	status_items += "Research: [research_progress]/[max_research_progress]"
	return status_items

/mob/living/scp/scp049/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached")
		return
	if(world.time < last_ai_tick + ai_tick_interval)
		return
	last_ai_tick = world.time

	anger_timer = max(anger_timer - 1, 0)

	if(prob(5))
		announce_presence()

	var/mob/living/carbon/human/pestilence_carrier = ai_find_pestilence_carrier()
	var/mob/living/carbon/human/nearest_corpse = ai_find_dead_body()

	if(pestilence_carrier && get_dist(src, pestilence_carrier) <= 1)
		ai_attempt_cure(pestilence_carrier)
		return

	if(nearest_corpse && get_dist(src, nearest_corpse) <= 1)
		PlagueDoctorCure(nearest_corpse)
		playsound(src, pick('sound/scp/scp049/SCP049_1.ogg', 'sound/scp/scp049/SCP049_2.ogg'), 40, FALSE)
		return

	if(pestilence_carrier)
		ai_pursue_target(pestilence_carrier)
		return

	if(nearest_corpse)
		ai_pursue_target(nearest_corpse)
		return

	if(prob(30))
		ai_wander_and_pry()

/mob/living/scp/scp049/proc/ai_find_pestilence_carrier()
	var/mob/living/carbon/human/best = null
	var/best_dist = INFINITY
	for(var/mob/living/carbon/human/H in view(10, src))
		if(H == src || H.stat == DEAD || isscp049_1(H))
			continue
		if(!HAS_TRAIT(H, TRAIT_PESTILENCE))
			continue
		var/d = get_dist(src, H)
		if(d < best_dist)
			best_dist = d
			best = H
	return best

/mob/living/scp/scp049/proc/ai_find_dead_body()
	var/mob/living/carbon/human/best = null
	var/best_dist = INFINITY
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H == src || H.stat != DEAD)
			continue
		if(isscp049_1(H))
			continue
		var/d = get_dist(src, H)
		if(d < best_dist)
			best_dist = d
			best = H
	return best

/mob/living/scp/scp049/proc/ai_attempt_cure(mob/living/carbon/human/target)
	if(!can_touch_bare_skin(target))
		if(anger_timer >= anger_timer_max * 0.5)
			target.Paralyze(20)
			visible_message(span_danger("<i>[src] reaches towards [target], making them stumble!</i>"))
			attack_voice_line()
		else
			visible_message(span_warning("<i>[src] reaches towards [target], but nothing happens...</i>"))
		return
	target.visible_message(span_danger("<i>[src] reaches towards [target]!</i>"))
	attack_voice_line()
	target.death()
	cured_count++
	cures_attempted++
	cures_successful++
	cure_potency = min(max_cure_potency, cure_potency + 1)
	playsound(target, 'sound/scp/scp049/SCP049_Cure1.ogg', 60, FALSE)
	on_cure_attempt(target)
	track_scp049_cure(src, target, TRUE)
	save_persistence_data()

/mob/living/scp/scp049/proc/ai_pursue_target(mob/living/carbon/human/target)
	if(!target)
		return
	var/dist = get_dist(src, target)
	if(dist > 12)
		return

	var/turf/next_step = get_step_towards(src, target)
	var/blocked = FALSE
	for(var/obj/O in next_step)
		if(O.density)
			blocked = TRUE
			break
	if(next_step.density)
		blocked = TRUE

	if(blocked)
		var/obj/machinery/door/D = locate() in range(1, src)
		if(D && D.density && D.Adjacent(src))
			OpenDoor(D)
			return

	step_to(src, target)

	if(prob(10))
		attack_voice_line()

/mob/living/scp/scp049/proc/ai_wander_and_pry()
	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range * 2)
		var/obj/machinery/door/D = locate() in range(3, src)
		if(D && D.density && world.time >= door_cooldown_track + door_cooldown)
			OpenDoor(D)
			return
		step_to(src, ai_home_turf)
		return

	if(prob(20))
		var/obj/machinery/door/D = locate() in range(2, src)
		if(D && D.density && world.time >= door_cooldown_track + door_cooldown)
			OpenDoor(D)
			return

	step_rand(src)

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
		SSscp_persistence?.manager?.save_scp_data("SCP-049", persistence_data)

/mob/living/scp/scp049/proc/load_persistence_data()
	if(SSscp_persistence && SSscp_persistence.manager)
		var/list/persistence_data = SSscp_persistence?.manager?.load_scp_data("SCP-049")
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
