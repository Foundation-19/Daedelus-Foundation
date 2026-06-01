// SCP-347 - The Invisible Woman
// A female entity that is completely invisible except when consuming food.

/mob/living/scp/scp347
	ai_enabled = TRUE
	name = "SCP-347"
	desc = "A female humanoid entity that is completely invisible to the naked eye."
	icon = 'icons/scp/scp347/scp-347.dmi'
	icon_state = "scp347"
	real_name = "Claire"
	gender = FEMALE

	var/invisibility_level = 60
	var/is_revealed = FALSE
	var/reveal_timer = null
	var/hunger_drain_rate = 0.5
	var/stealth_cooldown = 0
	var/stealth_cooldown_time = 30 SECONDS
	var/pickpocket_cooldown = 0
	var/pickpocket_cooldown_time = 20 SECONDS
	var/items_stolen = 0
	var/areas_infiltrated = 0
	var/last_stealth_action = 0

/mob/living/scp/scp347/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Invisible Woman", SCP_EUCLID, "347", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	grant_language(/datum/language/common, TRUE, TRUE)

	apply_invisibility()

	add_verb(src, list(
		/mob/living/scp/scp347/proc/verb_stealth_sprint,
		/mob/living/scp/scp347/proc/verb_toggle_visibility,
	))

/mob/living/scp/scp347/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(!is_revealed && nutrition > NUTRITION_LEVEL_FULL)
		temporary_reveal(5 SECONDS)
		to_chat(src, span_warning("Your full stomach briefly reveals you!"))

	if(nutrition < NUTRITION_LEVEL_STARVING)
		adjust_nutrition(-hunger_drain_rate)

/mob/living/scp/scp347/proc/apply_invisibility()
	if(stat == DEAD)
		return
	is_revealed = FALSE
	alpha = 0
	invisibility = invisibility_level
	add_client_colour(/datum/client_colour/scp347_invisible)

/mob/living/scp/scp347/proc/remove_invisibility()
	is_revealed = TRUE
	alpha = 255
	invisibility = 0
	remove_client_colour(/datum/client_colour/scp347_invisible)
	for(var/obj/item/I in src)
		if(I.loc == src)
			I.alpha = initial(I.alpha)
			I.invisibility = initial(I.invisibility)
	if(reveal_timer)
		deltimer(reveal_timer)
	reveal_timer = null

/mob/living/scp/scp347/proc/temporary_reveal(duration = 10 SECONDS)
	remove_invisibility()
	reveal_timer = addtimer(CALLBACK(src, .proc/apply_invisibility), duration, TIMER_STOPPABLE)

/mob/living/scp/scp347/Move()
	. = ..()
	if(!is_revealed && prob(5))
		playsound(src, 'sound/effects/bamf.ogg', 10, TRUE)

/mob/living/scp/scp347/attack_hand(mob/living/carbon/human/attacker)
	if(!is_revealed && prob(30))
		to_chat(attacker, span_warning("Your hand passes through empty air... or does it?"))
	. = ..()

/mob/living/scp/scp347/equip_to_slot_or_del(obj/item/I, slot)
	. = ..()
	if(!is_revealed && I)
		I.alpha = 0
		I.invisibility = invisibility_level

/mob/living/scp/scp347/proc/stealth_pickpocket(mob/living/carbon/human/target)
	if(stat == DEAD)
		return
	if(pickpocket_cooldown > world.time)
		to_chat(src, span_warning("You need to wait before attempting another pickpocket."))
		return
	if(is_revealed)
		to_chat(src, span_warning("You can't pickpocket while visible!"))
		return
	if(!target || target.stat == DEAD)
		return
	if(get_dist(src, target) > 1)
		to_chat(src, span_warning("You need to be closer to pickpocket."))
		return

	pickpocket_cooldown = world.time + pickpocket_cooldown_time

	var/obj/item/stolen = null
	var/list/pockets = list()
	if(target.held_items)
		for(var/obj/item/I in target.held_items)
			pockets += I
	if(target.belt)
		pockets += target.belt

	if(!length(pockets))
		to_chat(src, span_notice("[target] has nothing worth taking."))
		return

	stolen = pick(pockets)

	if(prob(15))
		to_chat(target, span_warning("You feel something brush against you!"))
		temporary_reveal(3 SECONDS)
		to_chat(src, span_danger("You bumped into [target]! You're briefly visible!"))
		return

	target.dropItemToGround(stolen)
	put_in_hands(stolen)
	items_stolen++
	to_chat(src, span_notice("You successfully lifted [stolen.name] from [target]!"))

/mob/living/scp/scp347/proc/stealth_sprint()
	if(stat == DEAD)
		return
	if(stealth_cooldown > world.time)
		to_chat(src, span_warning("You need to wait before sprinting again."))
		return

	stealth_cooldown = world.time + stealth_cooldown_time
	add_movespeed_modifier("scp347_sprint")
	to_chat(src, span_notice("You dash through the shadows!"))
	addtimer(CALLBACK(src, .proc/end_sprint), 5 SECONDS)

/mob/living/scp/scp347/proc/end_sprint()
	remove_movespeed_modifier("scp347_sprint")

/mob/living/scp/scp347/proc/pickpocket_verb()
	var/mob/living/carbon/human/target = null
	for(var/mob/living/carbon/human/H in range(1, src))
		if(H != src && H.stat != DEAD)
			target = H
			break
	if(!target)
		to_chat(src, span_warning("No valid targets nearby."))
		return
	stealth_pickpocket(target)

/mob/living/scp/scp347/proc/stealth_sprint_verb()
	stealth_sprint()

/mob/living/scp/scp347/proc/toggle_visibility_verb()
	if(is_revealed)
		apply_invisibility()
		to_chat(src, span_notice("You fade from sight."))
	else
		remove_invisibility()
		to_chat(src, span_warning("You become visible!"))

/mob/living/scp/scp347/proc/show_status_verb()
	var/list/status = list()
	status += "=== SCP-347 Status ==="
	status += "State: [is_revealed ? "VISIBLE" : "INVISIBLE"]"
	status += "Items Stolen: [items_stolen]"
	status += "Areas Infiltrated: [areas_infiltrated]"
	for(var/line in status)
		to_chat(src, span_notice("[line]"))

/datum/client_colour/scp347_invisible
	priority = 100
	colour = list(
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		0,0,0,0.3
	)

/mob/living/scp/scp347/UnarmedAttack(atom/A)
	if(ishuman(A) && !combat_mode)
		var/mob/living/carbon/human/target = A
		if(target.stat != DEAD && !is_revealed)
			stealth_pickpocket(target)
			return
	return ..()

/mob/living/scp/scp347/proc/verb_stealth_sprint()
	set name = "Stealth Sprint"
	set category = "SCP-347"
	stealth_sprint()

/mob/living/scp/scp347/proc/verb_toggle_visibility()
	set name = "Toggle Visibility"
	set category = "SCP-347"
	if(is_revealed)
		apply_invisibility()
		to_chat(src, span_notice("You fade from sight."))
	else
		remove_invisibility()
		to_chat(src, span_warning("You become visible!"))

/mob/living/scp/scp347/Destroy()
	QDEL_NULL(SCP)
	return ..()

/mob/living/scp/scp347/process_ai()
	if(stat == DEAD)
		return

	if(is_revealed)
		var/turf/safest = null
		var/most_dist = 0
		for(var/mob/living/carbon/human/H in view(7, src))
			if(H == src || H.stat == DEAD)
				continue
			var/dist = get_dist(src, H)
			if(dist > most_dist)
				most_dist = dist
				safest = get_step_away(src, H)
		if(safest)
			step_towards(src, safest)
		return

	if(prob(5))
		for(var/mob/living/carbon/human/H in range(1, src))
			if(H != src && H.stat != DEAD)
				stealth_pickpocket(H)
				return

	if(prob(20))
		step_rand(src)
