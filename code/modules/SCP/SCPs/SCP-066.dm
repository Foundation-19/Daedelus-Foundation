/obj/item/scp066
	name = "Eric's Toy"
	desc = "A small metal sphere, about the size of a tennis ball. It occasionally produces faint tones."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller"
	w_class = WEIGHT_CLASS_SMALL

	force = 0
	throwforce = 0
	throw_range = 7
	throw_speed = 2

	var/interaction_count = 0
	var/cooldown_time = 0
	var/imitating = FALSE
	var/original_icon
	var/original_icon_state
	var/original_name
	var/original_desc
	var/has_said_eric = FALSE
	var/memetic_pulse_cooldown = 0
	var/memetic_pulse_interval = 60 SECONDS
	var/alert_sent = FALSE

	var/static/list/gentle_sounds = list(
		'sound/machines/chime.ogg',
		'sound/machines/ping.ogg',
		'sound/machines/beep.ogg',
		'sound/effects/bamf.ogg',
		'sound/effects/sparks1.ogg',
		'sound/effects/sparks2.ogg'
	)

	var/static/list/eric_sounds = list(
		'sound/voice/hiss1.ogg',
		'sound/voice/hiss2.ogg',
		'sound/voice/hiss3.ogg'
	)

	var/static/list/severe_sounds = list(
		'sound/effects/explosion1.ogg',
		'sound/effects/explosion2.ogg',
		'sound/effects/explosion3.ogg'
	)

/obj/item/scp066/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Eric's Toy", SCP_SAFE, "066")
	original_icon = icon
	original_icon_state = icon_state
	original_name = name
	original_desc = desc
	START_PROCESSING(SSobj, src)

/obj/item/scp066/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scp066/process()
	if(world.time < memetic_pulse_cooldown)
		return
	memetic_pulse_cooldown = world.time + memetic_pulse_interval

	if(interaction_count < 5)
		return

	if(prob(min(interaction_count * 5, 40)))
		memetic_pulse()

/obj/item/scp066/attack_self(mob/user)
	if(world.time < cooldown_time)
		return

	interaction_count++
	cooldown_time = world.time + 20

	trigger_response(user)

	if(prob(15))
		attempt_imitation()

	if(!has_said_eric && interaction_count >= 8 && prob(20))
		say_eric(user)

	hook_scp_interaction(user, "SCP-066", INTERACTION_TYPE_OBSERVATION)

	if(interaction_count >= 10 && !alert_sent)
		alert_sent = TRUE
		scp066_alert()

/obj/item/scp066/attack_hand(mob/user)
	if(istype(loc, /mob))
		trigger_response(user)
	return ..()

/obj/item/scp066/pickup(mob/user)
	. = ..()
	if(world.time < cooldown_time)
		return

	interaction_count++
	cooldown_time = world.time + 20

	if(prob(30))
		trigger_response(user)

	if(prob(10))
		attempt_imitation()

	hook_scp_interaction(user, "SCP-066", INTERACTION_TYPE_OBSERVATION)

/obj/item/scp066/proc/trigger_response(mob/user)
	var/severity = get_response_severity()

	switch(severity)
		if(1)
			playsound(src, pick(gentle_sounds), 30, FALSE)
			user.visible_message(
				"<span class='notice'>[src] produces a gentle chime.</span>",
				"<span class='notice'>[src] plays a soft tone in your hands.</span>"
			)
		if(2)
			playsound(src, pick(gentle_sounds), 60, FALSE)
			user.visible_message(
				"<span class='notice'>[src] emits a pleasant melody.</span>",
				"<span class='notice'>[src] plays a pleasant tune.</span>"
			)
		if(3)
			if(prob(50))
				playsound(src, pick(eric_sounds), 70, FALSE)
				user.visible_message(
					"<span class='warning'>[src] says something indistinct.</span>",
					"<span class='warning'>[src] murmurs something you can't quite make out.</span>"
				)
			else
				playsound(src, pick(severe_sounds), 80, FALSE)
				user.visible_message(
					"<span class='warning'>[src] produces a loud, jarring note!</span>",
					"<span class='warning'>[src] blasts a loud sound, making you wince!</span>"
				)
		if(4)
			playsound(src, pick(severe_sounds), 100, FALSE)
			user.visible_message(
				"<span class='danger'>[src] blasts a deafening crash of sound!</span>",
				"<span class='danger'>[src] unleashes a deafening crash of sound that rattles your bones!</span>"
			)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/ears/E = H.getorganslot(ORGAN_SLOT_EARS)
				if(E)
					E.adjustEarDamage(0, 8)
				var/throwdir = pick(GLOB.alldirs)
				var/turf/target_turf = get_ranged_target_turf(H, throwdir, 2)
				if(target_turf)
					H.throw_at(target_turf, 2, 2)
				hook_scp_combat(H, "SCP-066", 0, 15)
		if(5)
			playsound(src, pick(severe_sounds), 120, FALSE)
			user.visible_message(
				"<span class='bolddanger'>[src] erupts with a catastrophic burst of sound!</span>",
				"<span class='bolddanger'>[src] erupts with an earth-shaking blast of sound!</span>"
			)
			for(var/mob/living/carbon/human/H in range(3, src))
				var/obj/item/organ/ears/E = H.getorganslot(ORGAN_SLOT_EARS)
				if(E)
					E.adjustEarDamage(0, 15)
				H.apply_damage(25, BRUTE)
				var/throwdir = pick(GLOB.alldirs)
				var/turf/target_turf = get_ranged_target_turf(H, throwdir, 4)
				if(target_turf)
					H.throw_at(target_turf, 4, 3)
				hook_scp_combat(H, "SCP-066", 25, 30)
			SCP?.log_interaction(user, "severe_response")

/obj/item/scp066/proc/get_response_severity()
	var/base_chance = min(interaction_count * 10, 80)

	if(prob(100 - base_chance))
		return 1

	if(interaction_count <= 3)
		return pick(1, 1, 2, 2, 3)

	if(interaction_count <= 7)
		return pick(2, 3, 3, 4)

	if(interaction_count <= 12)
		return pick(3, 4, 4, 5)

	return pick(4, 5, 5)

/obj/item/scp066/proc/say_eric(mob/user)
	has_said_eric = TRUE
	visible_message("<span class='warning'>[src] vibrates intensely and speaks in a deep, resonant voice:</span>")
	say("Eric?")
	playsound(src, 'sound/voice/hiss1.ogg', 100, FALSE)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
		to_chat(H, "<span class='warning'>The voice reverberates through your skull. Something feels wrong.</span>")
		hook_scp_interaction(H, "SCP-066", INTERACTION_TYPE_OBSERVATION, list("eric_event" = TRUE))

	addtimer(CALLBACK(src, PROC_REF(post_eric_effect)), 5 SECONDS)

/obj/item/scp066/proc/post_eric_effect()
	if(QDELETED(src))
		return

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat == DEAD)
			continue
		if(prob(30))
			H.adjust_drowsyness(5 SECONDS)
			to_chat(H, "<span class='warning'>A strange heaviness settles in your mind.</span>")

	if(prob(40))
		playsound(loc, pick(gentle_sounds), 50, FALSE)

/obj/item/scp066/proc/memetic_pulse()
	for(var/mob/living/carbon/human/H in range(4, src))
		if(H.stat == DEAD)
			continue
		if(prob(25))
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
			to_chat(H, "<span class='warning'>You feel a brief, sharp headache.</span>")

/obj/item/scp066/proc/scp066_alert()
	var/area/A = get_area(src)
	if(A)
		priority_announce("Anomalous sound activity detected in [A.name]. Personnel are advised to avoid handling SCP-066.", "SCP Monitoring System", null, ANNOUNCER_ALERT)

/obj/item/scp066/proc/attempt_imitation()
	var/list/nearby_items = list()
	for(var/obj/item/I in range(3, src))
		if(I == src)
			continue
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			continue
		nearby_items += I

	if(!length(nearby_items))
		return

	var/obj/item/target = pick(nearby_items)

	imitating = TRUE
	icon = target.icon
	icon_state = target.icon_state
	name = target.name
	desc = "It looks like \a [target.name], but something seems off about it..."

	addtimer(CALLBACK(src, PROC_REF(reset_appearance)), rand(200, 600))

/obj/item/scp066/proc/reset_appearance()
	if(!imitating)
		return
	imitating = FALSE
	icon = original_icon
	icon_state = original_icon_state
	name = original_name
	desc = original_desc

/obj/item/scp066/examine(mob/user)
	. = ..()
	if(imitating)
		. += "<span class='warning'>Something about this [name] seems wrong...</span>"
	else
		. += "<span class='notice'>A small metal sphere. It occasionally produces faint sounds.</span>"

	if(interaction_count > 0 && ishuman(user))
		if(interaction_count >= 10)
			. += "<span class='danger'>It has been handled many times. Further interaction may be extremely dangerous.</span>"
		else if(interaction_count >= 5)
			. += "<span class='warning'>It has been handled several times. It seems to be getting more reactive.</span>"
		else
			. += "<span class='notice'>It has been handled a few times.</span>"

	if(has_said_eric)
		. += "<span class='warning'>It seems to be searching for something... someone.</span>"

/obj/item/scp066/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		interaction_count++
		trigger_response(H)
		hook_scp_combat(H, "SCP-066", 5, 5)
