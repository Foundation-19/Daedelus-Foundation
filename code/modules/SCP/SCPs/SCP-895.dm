/obj/structure/coffin/scp895
	name = "dark wooden coffin"
	desc = "A large, dark wooden coffin with ornate brass fittings. Something about it fills you with a deep sense of dread."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp895"
	density = TRUE
	anchored = TRUE
	max_integrity = 200

	var/hallucination_range_camera = 15
	var/hallucination_range_direct = 2
	var/list/affected_viewers = list()
	var/hallucination_tick = 0
	var/feeding_corpses = 0
	var/feed_bonus = 0
	var/list/camera_distortion_images = list()
	var/distortion_update_cooldown = 0
	var/distortion_update_interval = 5 SECONDS

/obj/structure/coffin/scp895/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Coffin", SCP_EUCLID, "895")
	START_PROCESSING(SSobj, src)

/obj/structure/coffin/scp895/Destroy()
	affected_viewers = list()
	clear_all_distortion()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/coffin/scp895/process()
	hallucination_tick++

	if(hallucination_tick % 5 != 0)
		return

	if(world.time >= distortion_update_cooldown)
		update_camera_distortion()
		distortion_update_cooldown = world.time + distortion_update_interval

	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(QDELETED(H) || H.stat == DEAD || H.SCP)
			continue

		var/distance = get_dist(H, src)

		var/viewing_through_camera = FALSE
		var/obj/machinery/camera/viewed_camera = null
		if(distance > hallucination_range_direct)
			for(var/obj/machinery/camera/C in range(hallucination_range_camera, src))
				if(C.can_use() && get_dist(H, C) <= 1)
					viewing_through_camera = TRUE
					viewed_camera = C
					break

		if(viewing_through_camera)
			if(!(H in affected_viewers))
				affected_viewers[H] = list("level" = 0, "camera" = viewed_camera, "duration" = 0, "last_event" = 0)
			var/list/data = affected_viewers[H]
			data["level"] = min(100 + feed_bonus, data["level"] + rand(3, 8))
			data["duration"] += 1
			data["camera"] = viewed_camera
			apply_hallucination_effect(H, data["level"], TRUE, data)
		else if(distance <= hallucination_range_direct)
			if(!(H in affected_viewers))
				affected_viewers[H] = list("level" = 0, "duration" = 0, "last_event" = 0)
			var/list/data = affected_viewers[H]
			data["level"] = min(30 + feed_bonus, data["level"] + rand(1, 3))
			data["duration"] += 1
			apply_hallucination_effect(H, data["level"], FALSE, data)
		else
			if(H in affected_viewers)
				var/list/data = affected_viewers[H]
				data["level"] = max(0, data["level"] - 2)
				data["duration"] = max(0, data["duration"] - 1)
				if(data["level"] <= 0)
					affected_viewers -= H

/obj/structure/coffin/scp895/proc/apply_hallucination_effect(mob/living/carbon/human/target, level, through_camera, list/data)
	if(!target || level <= 0)
		return

	if(through_camera)
		if(level >= 5 && prob(10))
			to_chat(target, span_warning("The camera feed flickers with static for a moment..."))
			if(target.hallucination < 5)
				target.hallucination += 3

		if(level >= 10 && prob(15))
			to_chat(target, span_warning("You feel uneasy looking at the camera feed..."))
			playsound(target, 'sound/scp/scare1.ogg', 20, TRUE)

		if(level >= 20 && prob(15))
			to_chat(target, span_danger("The camera feed shows a dark shape moving in the corner of the frame."))
			playsound(target, 'sound/scp/scare1.ogg', 25, TRUE)
			if(target.stamina)
				target.stamina.adjust(-2)
			target.hallucination += 5

		if(level >= 25 && prob(15))
			to_chat(target, span_danger("You see something wrong in the camera feed — a shape that shouldn't be there."))
			playsound(target, 'sound/scp/scare2.ogg', 30, TRUE)
			if(target.stamina)
				target.stamina.adjust(-2)

		if(level >= 35 && prob(15))
			to_chat(target, span_danger("A face appears in the camera feed — pale, gaunt, and staring directly at you. It vanishes when you blink."))
			playsound(target, 'sound/scp/scare2.ogg', 35, TRUE)
			if(target.stamina)
				target.stamina.adjust(-3)
			target.hallucination += 8

		if(level >= 40 && prob(15))
			to_chat(target, span_danger("A corpse stares back at you from the monitor. For a moment, it looks like someone you know."))
			playsound(target, 'sound/scp/scare3.ogg', 40, TRUE)
			if(target.stamina)
				target.stamina.adjust(-5)
			target.adjustBruteLoss(2)

		if(level >= 50 && prob(15))
			to_chat(target, span_danger("The camera feed shows a body on the floor. As you watch, it turns its head to look at you."))
			playsound(target, 'sound/scp/scare3.ogg', 45, TRUE)
			if(target.stamina)
				target.stamina.adjust(-7)
			target.adjustBruteLoss(3)
			target.hallucination += 10

		if(level >= 55 && prob(15))
			to_chat(target, span_userdanger("DEATH. You see it everywhere in the feed. Every face is a skull. Every shadow holds a body."))
			playsound(target, 'sound/scp/scare4.ogg', 50, TRUE)
			if(target.stamina)
				target.stamina.adjust(-10)
			target.adjustBruteLoss(5)
			if(target.sanity)
				target.sanity.adjust_sanity(-15, "scp895_intense_hallucination")

		if(level >= 65 && prob(15))
			to_chat(target, span_userdanger("The bodies in the camera feed begin to move. They crawl toward the lens, reaching for YOU."))
			playsound(target, 'sound/scp/scare1.ogg', 55, TRUE)
			if(target.stamina)
				target.stamina.adjust(-12)
			target.adjustBruteLoss(7)
			target.hallucination += 15

		if(level >= 70 && prob(20))
			to_chat(target, span_userdanger("Your heart races as the imagery becomes unbearable. Corpses fill every frame. You cannot look away."))
			playsound(target, 'sound/scp/scare1.ogg', 60, TRUE)
			target.adjustBruteLoss(10)
			target.adjustToxLoss(5, cause_of_death = "cardiac_arrest_scp895")
			if(target.sanity)
				target.sanity.adjust_sanity(-20, "scp895_severe_hallucination")

		if(level >= 80 && prob(20))
			to_chat(target, span_userdanger("You see YOURSELF dead in the camera feed. Your own corpse stares back with empty eyes. Blood pools around your body."))
			playsound(target, 'sound/scp/scare3.ogg', 65, TRUE)
			target.adjustBruteLoss(12)
			target.adjustToxLoss(8, cause_of_death = "cardiac_arrest_scp895")
			if(target.sanity)
				target.sanity.adjust_sanity(-25, "scp895_self_image")

		if(level >= 85 && prob(25))
			to_chat(target, span_userdanger("Your chest tightens with terror. The feed shows YOUR corpse. YOUR death. The figure in the coffin knows your name."))
			playsound(target, 'sound/scp/scare3.ogg', 70, TRUE)
			target.adjustBruteLoss(15)
			target.adjustToxLoss(10, cause_of_death = "cardiac_arrest_scp895")
			if(target.sanity)
				target.sanity.adjust_sanity(-30, "scp895_terror")
			if(target.hallucination < 30)
				target.hallucination += 20

		if(level >= 100 && prob(30))
			target.visible_message(span_danger("[target] clutches their chest and collapses!"), span_userdanger("YOUR HEART STOPS. THE COFFIN SHOWS YOU YOUR END. THE WORLD GOES DARK."))
			playsound(target, 'sound/scp/scare4.ogg', 80, TRUE)
			target.adjustBruteLoss(30)
			target.adjustToxLoss(20, cause_of_death = "cardiac_arrest_scp895")
			if(target.sanity)
				target.sanity.adjust_sanity(-50, "scp895_fatal_terror")
			if(prob(20 + feed_bonus))
				target.Unconscious(100)

		if(level >= 50)
			hook_scp_combat(target, "SCP-895", 5 + feed_bonus, 0)

		if(level >= 30 && data && prob(8))
			camera_distortion_event(target, data["camera"], level)

	else
		if(level >= 5 && prob(10))
			to_chat(target, span_warning("You feel a faint unease near the coffin."))
			playsound(target, 'sound/scp/spook/Bell2.ogg', 15, TRUE)

		if(level >= 15 && prob(10))
			to_chat(target, span_warning("The air around the coffin feels heavy with dread."))
			playsound(target, 'sound/scp/spook/Bell3.ogg', 25, TRUE)
			if(target.stamina)
				target.stamina.adjust(-1)

		if(level >= 25 && prob(10))
			to_chat(target, span_danger("Something about the coffin fills you with a sense of impending doom."))
			playsound(target, 'sound/effects/ghost.ogg', 30, TRUE)
			if(target.stamina)
				target.stamina.adjust(-3)

/obj/structure/coffin/scp895/proc/camera_distortion_event(mob/living/carbon/human/target, obj/machinery/camera/C, level)
	if(!C || !C.can_use())
		return

	var/list/distortion_events = list(
		"The camera feed glitches — for a split second, every surface is covered in blood.",
		"Static fills the screen. When it clears, you see a figure standing where nothing was before.",
		"The camera shows the room empty. Then, slowly, a hand reaches up from the bottom of the frame.",
		"The feed inverts — white becomes black, and in the negative space, you see shapes. Human shapes. Dozens of them.",
		"A corpse is visible in the feed for exactly one frame. Then it's gone. You're not sure if you imagined it.",
	)

	if(level >= 70)
		distortion_events += list(
			"The camera shows YOU lying dead on the floor of this very room. Your eyes are open. You're smiling.",
			"Every camera feed on the monitor switches to show the same thing: the inside of a coffin. YOUR coffin.",
		)

	to_chat(target, span_danger("[pick(distortion_events)]"))
	target.hallucination += 5 + (level * 0.1)

/obj/structure/coffin/scp895/proc/update_camera_distortion()
	var/list/nearby_cameras = list()
	for(var/obj/machinery/camera/C in range(hallucination_range_camera, src))
		if(C.can_use())
			nearby_cameras += C

	for(var/obj/machinery/camera/C in nearby_cameras)
		var/distance = get_dist(C, src)
		var/distortion_strength = max(0, (hallucination_range_camera - distance) * 0.1 + feed_bonus * 0.05)

		if(distortion_strength > 0)
			for(var/mob/living/carbon/human/H in range(1, C))
				if(H.stat != DEAD && !H.SCP && H.client)
					H.hallucination = min(100, H.hallucination + distortion_strength * 0.5)

/obj/structure/coffin/scp895/proc/clear_all_distortion()
	camera_distortion_images = list()

/obj/structure/coffin/scp895/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ishuman(user) && (istype(I, /obj/item/food/meat/slab) || istype(I, /obj/item/bodypart)))
		var/mob/living/L = user
		if(L.combat_mode)
			return
		feeding_corpses++
		feed_bonus = min(30, feeding_corpses * 3)
		qdel(I)
		to_chat(user, span_warning("You place [I] into the coffin. The lid creaks shut on its own."))
		playsound(src, 'sound/effects/woodhit.ogg', 50, TRUE)
		hook_scp_interaction(user, "SCP-895", INTERACTION_TYPE_CONTAINMENT)
		if(feed_bonus >= 10)
			visible_message(span_warning("The coffin's brass fittings gleam with an unnatural luster. The air grows colder."))
		if(feed_bonus >= 20)
			visible_message(span_danger("The coffin seems to hum with satisfaction. Shadows in the room deepen."))
		if(feed_bonus >= 30)
			visible_message(span_userdanger("The coffin SHUDDERS. Something inside it is very, very pleased. All nearby camera feeds show static for a moment."))
			for(var/obj/machinery/camera/C in range(hallucination_range_camera, src))
				if(C.can_use())
					C.toggle_cam(null, FALSE)
					addtimer(CALLBACK(C, TYPE_PROC_REF(/obj/machinery/camera, toggle_cam), null, TRUE), 5 SECONDS)

/obj/structure/coffin/scp895/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return

	if(user.combat_mode)
		return

	to_chat(user, span_warning("You touch the coffin's surface. A wave of dread passes through you."))
	playsound(user, 'sound/scp/spook/Bell2.ogg', 30, TRUE)
	hook_scp_interaction(user, "SCP-895", INTERACTION_TYPE_OBSERVATION)
	if(!(user in affected_viewers))
		affected_viewers[user] = list("level" = 10, "duration" = 0, "last_event" = 0)

/obj/structure/coffin/scp895/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A large, dark wooden coffin with ornate brass fittings. Viewing it through camera feeds causes escalating hallucinations."))
	to_chat(user, span_warning("Do NOT observe through security cameras. Direct proximity is less dangerous but still unsettling."))
	if(feeding_corpses > 0)
		to_chat(user, span_danger("The coffin seems heavier than before. The brass fittings have an odd sheen."))
	if(feed_bonus >= 20)
		to_chat(user, span_userdanger("Something inside the coffin is awake and hungry. The air itself recoils from it."))
