// SCP-082 - Fernand the Cannibal
// A large, polite, well-mannered humanoid who speaks French and English.
// Cooperative with staff when well-fed, but will cannibalize those he can isolate.
// Defines moved to code/modules/SCP/scp_defines.dm

/mob/living/scp/scp082
	ai_enabled = TRUE
	name = "SCP-082"
	desc = "A large, well-mannered humanoid standing nearly two and a half meters tall. He carries himself with an air of quiet dignity."
	icon = 'icons/scp/scp-082.dmi'
	icon_state = "082_fullbody"
	real_name = "SCP-082"
	status_flags = 0

	var/satiation = SCP082_SATIATION_MAX
	var/last_greet_time = 0
	var/last_offer_time = 0
	var/last_consume_time = 0
	var/offered_target = null
	var/datum/scp082_hospitality_system/hospitality_system
	var/datum/scp082_french_system/french_system

	var/meals_consumed = 0
	var/conversations_held = 0
	var/offers_made = 0

/mob/living/scp/scp082/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Fernand", SCP_EUCLID, "082", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	hospitality_system = new /datum/scp082_hospitality_system(src)
	french_system = new /datum/scp082_french_system(src)

	maxHealth = 400
	health = maxHealth

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/scp/scp082/proc/verb_greet_nearby,
		/mob/living/scp/scp082/proc/verb_offer_food,
		/mob/living/scp/scp082/proc/verb_speak_french,
	))

/mob/living/scp/scp082/scp_death()
	icon_state = "082-dead"
	..()

	START_PROCESSING(SSobj, src)


/mob/living/scp/scp082/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(hospitality_system)
	QDEL_NULL(french_system)
	return ..()

/mob/living/scp/scp082/process()
	if(stat == DEAD)
		return

	satiation = max(0, satiation - SCP082_SATIATION_DECAY_RATE)

	if(hospitality_system)
		hospitality_system.tick()

	if(french_system)
		french_system.tick()

	if(health < maxHealth && satiation > SCP082_HUNGER_THRESHOLD_HUNGRY)
		adjustBruteLoss(-0.5)

/mob/living/scp/scp082/proc/is_hungry()
	return satiation < SCP082_HUNGER_THRESHOLD_HUNGRY

/mob/living/scp/scp082/proc/is_starving()
	return satiation < SCP082_HUNGER_THRESHOLD_STARVING

/mob/living/scp/scp082/proc/is_well_fed()
	return satiation >= SCP082_HUNGER_THRESHOLD_HUNGRY

/mob/living/scp/scp082/examine(mob/user)
	. = ..()
	if(is_hungry())
		. += span_warning("There is a subtle hunger behind his polite demeanor.")
	else
		. += span_notice("He appears content and well-fed.")
	. += span_notice("He stands nearly 2.4 meters tall, a gentleman of considerable stature.")

/mob/living/scp/scp082/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, range = 7)
	. = ..()
	if(!.)
		return

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD && H != src)
			hook_scp_interaction(H, "SCP-082", INTERACTION_TYPE_COMMUNICATION)
			conversations_held++

/mob/living/scp/scp082/UnarmedAttack(atom/A)
	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = A
		if(combat_mode && should_attack_target(target))
			attack_victim(target)
			return
		if(!combat_mode && is_hungry() && hospitality_system?.can_offer(target))
			hospitality_system.offer_hospitality(target)
			return

	. = ..()

/mob/living/scp/scp082/proc/should_attack_target(mob/living/carbon/human/target)
	if(target.stat == DEAD)
		return FALSE
	if(target == src)
		return FALSE
	if(!is_hungry())
		return FALSE
	var/count = 0
	for(var/mob/living/carbon/human/H in viewers(7, src))
		if(H != src && H != target && H.stat != DEAD)
			count++
	if(count > 2)
		return FALSE
	return TRUE

/mob/living/scp/scp082/proc/attack_victim(mob/living/carbon/human/victim)
	if(world.time < last_consume_time)
		return

	victim.adjustBruteLoss(SCP082_ATTACK_DAMAGE)
	last_consume_time = world.time + SCP082_CONSUME_COOLDOWN

	if(victim.stat == DEAD)
		consume_victim(victim)
	else
		victim.visible_message(span_danger("[src] strikes [victim] with terrible force!"), \
			span_userdanger("[src] attacks you with terrifying strength!"))
		hook_scp_combat(victim, "SCP-082", SCP082_ATTACK_DAMAGE, 0)
		if(victim.sanity)
			victim.sanity.adjust_sanity(-10, "scp082_attack")

/mob/living/scp/scp082/proc/consume_victim(mob/living/carbon/human/victim)
	if(!victim || victim.stat != DEAD)
		return

	meals_consumed++
	satiation = min(SCP082_SATIATION_MAX, satiation + 35)
	adjustBruteLoss(-SCP082_FEED_HEAL_AMOUNT)

	victim.visible_message(span_danger("[src] consumes [victim] with practiced composure."))
	hook_scp_combat(victim, "SCP-082", 100, 0)
	hook_player_death_near_scp(victim, "SCP-082")

	victim.gib()

/mob/living/scp/scp082/get_status_tab_items()
	var/list/status_items = ..()
	status_items += "Satiation: [round(satiation, 1)]/[SCP082_SATIATION_MAX]"
	status_items += "Hunger: [is_starving() ? "STARVING" : is_hungry() ? "Hungry" : "Well-fed"]"
	status_items += "Meals Consumed: [meals_consumed]"
	status_items += "Conversations: [conversations_held]"
	status_items += "Offers Made: [offers_made]"
	return status_items

/mob/living/scp/scp082/proc/greet_nearby()
	if(world.time < last_greet_time + SCP082_GREET_COOLDOWN)
		to_chat(src, span_warning("You have greeted people too recently."))
		return

	last_greet_time = world.time

	var/list/nearby = list()
	for(var/mob/living/carbon/human/H in range(5, src))
		if(H != src && H.stat != DEAD)
			nearby += H

	if(!length(nearby))
		to_chat(src, span_warning("There is no one nearby to greet."))
		return

	var/greeting = french_system?.get_greeting() || "Bonjour, my friends."

	visible_message(span_notice("<b>[src]</b> says, \"[greeting]\""))

	for(var/mob/living/carbon/human/H in nearby)
		hook_scp_interaction(H, "SCP-082", INTERACTION_TYPE_COMMUNICATION)
		conversations_held++

/mob/living/scp/scp082/proc/offer_food()
	var/list/nearby = list()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H != src && H.stat != DEAD)
			nearby += H

	if(!length(nearby))
		to_chat(src, span_warning("There is no one nearby to offer hospitality."))
		return

	var/mob/living/carbon/human/target = input(src, "Whom do you wish to invite?", "Offer Hospitality") as null|anything in nearby
	if(!target || !target.Adjacent(src))
		return

	if(world.time < last_offer_time + SCP082_OFFER_COOLDOWN)
		to_chat(src, span_warning("You have offered hospitality too recently."))
		return

	hospitality_system?.offer_hospitality(target)

/mob/living/scp/scp082/proc/speak_french()
	var/phrase = french_system?.get_random_phrase()
	if(phrase)
		say(phrase)

/mob/living/scp/scp082/proc/check_hunger()
	var/status = "well-fed and content"
	if(is_hungry())
		status = "hungry - you should eat soon"
	if(is_starving())
		status = "STARVING - you must feed"

	to_chat(src, span_notice("You are [status]. Satiation: [round(satiation, 1)]/[SCP082_SATIATION_MAX]"))

/mob/living/scp/scp082/proc/verb_greet_nearby()
	set name = "Greet Nearby"
	set category = "SCP-082"
	greet_nearby()

/mob/living/scp/scp082/proc/verb_offer_food()
	set name = "Offer Hospitality"
	set category = "SCP-082"
	offer_food()

/mob/living/scp/scp082/proc/verb_speak_french()
	set name = "Speak French"
	set category = "SCP-082"
	speak_french()

// Hospitality System - Lures victims through polite conversation
/datum/scp082_hospitality_system
	var/mob/living/scp/scp082/parent
	var/offer_cooldown = 0
	var/offer_cooldown_time = SCP082_OFFER_COOLDOWN
	var/list/guests_welcomed = list()
	var/list/current_guest = null

	var/list/offer_phrases = list(
		"Please, come in. I have prepared a meal for you.",
		"Would you care for some wine? I insist.",
		"You look tired, mon ami. Sit with me a while.",
		"I have been so lonely. Will you not stay for dinner?",
		"Allow me to be a proper host. Please, enjoy my hospitality.",
		"You must try this dish. I prepared it with great care.",
		"Join me, won't you? It has been so long since I had company."
	)

	var/list/lure_phrases = list(
		"Come closer, I cannot hear you from there.",
		"The food is getting cold. Please, sit beside me.",
		"Do not be shy. I do not bite... much.",
		"You are perfectly safe here. I am a gentleman, after all.",
		"Let me pour you another glass. Stay a little longer."
	)

/datum/scp082_hospitality_system/New(mob/living/scp/scp082/P)
	parent = P

/datum/scp082_hospitality_system/proc/tick()
	if(!parent || parent.stat == DEAD)
		return

	if(parent.is_hungry() && prob(3))
		var/mob/living/carbon/human/target = find_isolated_target()
		if(target)
			whisper_lure(target)

/datum/scp082_hospitality_system/proc/can_offer(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return FALSE
	if(world.time < offer_cooldown)
		return FALSE
	return TRUE

/datum/scp082_hospitality_system/proc/offer_hospitality(mob/living/carbon/human/target)
	if(!can_offer(target))
		return FALSE

	offer_cooldown = world.time + offer_cooldown_time
	current_guest = target
	parent.offers_made++

	var/phrase = pick(offer_phrases)
	parent.visible_message(span_notice("<b>[parent]</b> says to [target], \"[phrase]\""), \
		span_notice("You offer your hospitality to [target]."))

	hook_scp_interaction(target, "SCP-082", INTERACTION_TYPE_COMMUNICATION)
	parent.conversations_held++

	if(parent.is_hungry() && target.Adjacent(parent))
		addtimer(CALLBACK(src, PROC_REF(consider_attacking), target), 30)

	return TRUE

/datum/scp082_hospitality_system/proc/whisper_lure(mob/living/carbon/human/target)
	var/phrase = pick(lure_phrases)
	parent.visible_message(span_notice("<b>[parent]</b> whispers to [target], \"[phrase]\""), \
		span_notice("You whisper to [target]."))

/datum/scp082_hospitality_system/proc/find_isolated_target()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in range(7, parent))
		if(H == parent || H.stat == DEAD)
			continue
		var/witness_count = 0
		for(var/mob/living/carbon/human/W in viewers(5, H))
			if(W != parent && W != H && W.stat != DEAD)
				witness_count++
		if(witness_count <= 1)
			candidates += H

	if(length(candidates))
		return pick(candidates)
	return null

/datum/scp082_hospitality_system/proc/consider_attacking(mob/living/carbon/human/target)
	if(!parent || !target || parent.stat == DEAD || target.stat == DEAD)
		return
	if(!target.Adjacent(parent))
		return
	if(!parent.is_hungry())
		return
	if(parent.should_attack_target(target))
		parent.set_combat_mode(TRUE)
		parent.attack_victim(target)
		hook_scp_breach("SCP-082", parent)

// French Speech System
/datum/scp082_french_system
	var/mob/living/scp/scp082/parent
	var/last_auto_phrase = 0
	var/auto_phrase_interval = 600
	var/french_chance = 40

	var/list/greetings = list(
		"Bonjour, mes amis!",
		"Ah, welcome! Entrez, entrez.",
		"Good evening. Bonsoir to you all.",
		"Ah, visitors! Comment allez-vous?",
		"Enchanté! It is so good to see you.",
		"Bonjour! I hope you are well today."
	)

	var/list/polite_phrases = list(
		"Such is life, n'est-ce pas?",
		"Impressive, truly. Magnifique.",
		"Of course, mon ami. Of course.",
		"C'est la vie, as we say.",
		"Ah, but you must understand...",
		"Naturellement. It is only natural.",
		"I assure you, I am quite civilised.",
		"Please, do not be alarmed. I am a gentleman.",
		"One must have standards, even in captivity.",
		"The Foundation treats me well. I am grateful."
	)

	var/list/hungry_phrases = list(
		"I am... peckish. A small appetite, nothing more.",
		"Do you smell that? J'ai faim.",
		"Perhaps we could share a meal, you and I.",
		"You look... nourishing. Forgive me, a poor joke.",
		"I wonder... what does human taste like tonight?",
		"Mon Dieu, I am so very hungry.",
		"Will no one dine with me? Just the two of us?"
	)

	var/list/dining_phrases = list(
		"Magnifique! Exquisite, truly.",
		"Ah, délicieux. My compliments.",
		"One must savor every bite, non?",
		"A meal shared is a meal treasured.",
		"C'est magnifique! I am satisfied."
	)

	var/list/lonely_phrases = list(
		"It is so quiet here. Je suis seul.",
		"Will no one talk to me? Just for a moment?",
		"I miss the sound of voices. La conversation.",
		"Being alone... it wears on the soul.",
		"Is anyone there? Personne ne répond."
	)

/datum/scp082_french_system/New(mob/living/scp/scp082/P)
	parent = P

/datum/scp082_french_system/proc/tick()
	if(!parent || parent.stat == DEAD)
		return

	if(world.time > last_auto_phrase + auto_phrase_interval && prob(5))
		last_auto_phrase = world.time
		auto_speak()

/datum/scp082_french_system/proc/auto_speak()
	var/list/nearby_humans = list()
	for(var/mob/living/carbon/human/H in range(5, parent))
		if(H != parent && H.stat != DEAD)
			nearby_humans += H

	var/phrase
	if(!length(nearby_humans))
		phrase = pick(lonely_phrases)
	else if(parent.is_starving())
		phrase = pick(hungry_phrases)
	else if(parent.is_hungry())
		phrase = pick(hungry_phrases)
	else
		phrase = pick(polite_phrases)

	parent.say(phrase)

/datum/scp082_french_system/proc/get_greeting()
	return pick(greetings)

/datum/scp082_french_system/proc/get_random_phrase()
	if(parent.is_starving())
		return pick(hungry_phrases)
	if(parent.is_hungry())
		return pick(hungry_phrases)
	return pick(polite_phrases)

/datum/scp082_french_system/proc/get_dining_phrase()
	return pick(dining_phrases)

/mob/living/scp/scp082/process_ai()
	if(stat == DEAD)
		return

	if(is_starving())
		var/mob/living/carbon/human/target = null
		var/best_dist = 7
		for(var/mob/living/carbon/human/H in view(best_dist, src))
			if(H.stat == DEAD || H == src)
				continue
			var/dist = get_dist(src, H)
			if(dist < best_dist)
				if(hospitality_system?.find_isolated_target())
					target = H
					best_dist = dist
		if(target)
			if(get_dist(src, target) <= 1)
				if(prob(25))
					attack_victim(target)
			else
				ai_step_towards(target)
			return
		if(world.time > last_offer_time + SCP082_OFFER_COOLDOWN)
			for(var/mob/living/carbon/human/H in view(5, src))
				if(H.stat != DEAD && H != src)
					offer_food(H)
					break
			return

	if(is_hungry())
		if(world.time > last_offer_time + SCP082_OFFER_COOLDOWN)
			for(var/mob/living/carbon/human/H in view(4, src))
				if(H.stat != DEAD && H != src)
					offer_food(H)
					break
		else if(prob(20))
			step_rand(src)
		return

	if(world.time > last_greet_time + SCP082_GREET_COOLDOWN)
		for(var/mob/living/carbon/human/H in view(4, src))
			if(H.stat != DEAD && H != src)
				greet_nearby()
				break

	if(prob(15))
		step_rand(src)

