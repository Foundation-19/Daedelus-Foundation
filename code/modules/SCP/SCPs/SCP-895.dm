/obj/structure/coffin/scp895
	name = "dark wooden coffin"
	desc = "A large, dark wooden coffin with ornate brass fittings. Something about it fills you with a deep sense of dread."
	icon_state = "scp895"
	density = TRUE
	anchored = TRUE
	max_integrity = 200

	var/hallucination_range_camera = 15
	var/hallucination_range_direct = 2
	var/list/affected_viewers = list()
	var/hallucination_tick = 0

/obj/structure/coffin/scp895/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Coffin", SCP_EUCLID, "895")
	START_PROCESSING(SSobj, src)

/obj/structure/coffin/scp895/Destroy()
	affected_viewers = list()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/coffin/scp895/process()
	hallucination_tick++

	if(hallucination_tick % 5 != 0)
		return

	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(QDELETED(H) || H.stat == DEAD || H.SCP)
			continue

		var/distance = get_dist(H, src)

		var/viewing_through_camera = FALSE
		if(distance > hallucination_range_direct)
			for(var/obj/machinery/camera/C in range(hallucination_range_camera, src))
				if(C.can_use() && get_dist(H, C) <= 1)
					viewing_through_camera = TRUE
					break

		if(viewing_through_camera)
			if(!(H in affected_viewers))
				affected_viewers[H] = 0
			affected_viewers[H] = min(100, affected_viewers[H] + rand(3, 8))
			apply_hallucination_effect(H, affected_viewers[H], TRUE)
		else if(distance <= hallucination_range_direct)
			if(!(H in affected_viewers))
				affected_viewers[H] = 0
			affected_viewers[H] = min(30, affected_viewers[H] + rand(1, 3))
			apply_hallucination_effect(H, affected_viewers[H], FALSE)
		else
			if(H in affected_viewers)
				affected_viewers[H] = max(0, affected_viewers[H] - 2)
				if(affected_viewers[H] <= 0)
					affected_viewers -= H

/obj/structure/coffin/scp895/proc/apply_hallucination_effect(mob/living/carbon/human/target, level, through_camera)
	if(!target || level <= 0)
		return

	if(through_camera)
		if(level >= 10 && prob(15))
			to_chat(target, span_warning("You feel uneasy looking at the camera feed..."))
			playsound(target, 'sound/scp/scare1.ogg', 20, TRUE)
		if(level >= 25 && prob(15))
			to_chat(target, span_danger("You see something wrong in the camera feed — a shape that shouldn't be there."))
			playsound(target, 'sound/scp/scare2.ogg', 30, TRUE)
			if(target.stamina)
				target.stamina.adjust(-2)
		if(level >= 40 && prob(15))
			to_chat(target, span_danger("A corpse stares back at you from the monitor. For a moment, it looks like someone you know."))
			playsound(target, 'sound/scp/scare3.ogg', 40, TRUE)
			if(target.stamina)
				target.stamina.adjust(-5)
			target.adjustBruteLoss(2)
		if(level >= 55 && prob(15))
			to_chat(target, span_userdanger("DEATH. You see it everywhere in the feed. Every face is a skull. Every shadow holds a body."))
			playsound(target, 'sound/scp/scare4.ogg', 50, TRUE)
			if(target.stamina)
				target.stamina.adjust(-10)
			target.adjustBruteLoss(5)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 10)
		if(level >= 70 && prob(20))
			to_chat(target, span_userdanger("Your heart races as the imagery becomes unbearable. Corpses fill every frame. You cannot look away."))
			playsound(target, 'sound/scp/scare1.ogg', 60, TRUE)
			target.adjustBruteLoss(10)
			target.adjustToxLoss(5)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 20)
		if(level >= 85 && prob(25))
			to_chat(target, span_userdanger("Your chest tightens with terror. The feed shows YOUR corpse. YOUR death."))
			playsound(target, 'sound/scp/scare3.ogg', 70, TRUE)
			target.adjustBruteLoss(15)
			target.adjustToxLoss(10)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 30)
		if(level >= 100 && prob(30))
			target.visible_message(span_danger("[target] clutches their chest and collapses!"), span_userdanger("YOUR HEART STOPS. THE COFFIN SHOWS YOU YOUR END."))
			playsound(target, 'sound/scp/scare4.ogg', 80, TRUE)
			target.adjustBruteLoss(30)
			target.adjustToxLoss(20)
			if(target.sanity)
				target.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 50)
			if(prob(20))
				target.Unconscious(100)

		if(level >= 50)
			hook_scp_combat(target, "SCP-895", 5, 0)
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
		affected_viewers[user] = 10

/obj/structure/coffin/scp895/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A large, dark wooden coffin with ornate brass fittings. Viewing it through camera feeds causes escalating hallucinations."))
	to_chat(user, span_warning("Do NOT observe through security cameras. Direct proximity is less dangerous but still unsettling."))
