/mob/living/scp/scp999
	ai_enabled = TRUE
	name = "SCP-999"
	desc = "A large, amorphous, gelatinous mass of translucent orange slime. It appears to be friendly and seeks physical contact."
	icon = 'icons/scp/scp-999.dmi'
	icon_state = "scp999"
	real_name = "SCP-999"
	use_custom_sprite = TRUE
	persistence_id = "SCP-999"
	maxHealth = 150
	health = 150

	var/healing_power = 25
	var/healing_cooldown = 0
	var/healing_cooldown_time = 15 SECONDS
	var/list/healed_targets = list()
	var/list/mood_improved_targets = list()
	var/happiness_level = 0
	var/max_happiness = 100
	var/comfort_radius = 3

	var/healing_sessions = 0
	var/mood_improvements = 0
	var/comfort_provided = 0

	var/tickle_cooldown = 0
	var/tickle_cooldown_time = 8 SECONDS
	var/calm_scp_cooldown = 0
	var/calm_scp_cooldown_time = 30 SECONDS
	var/babble_cooldown = 0
	var/babble_cooldown_time = 12 SECONDS

	var/static/list/glubby_prefixes = list("Glr", "Blrb", "Wrr", "Mrr", "Blp", "Gl", "Br", "Wr")
	var/static/list/glubby_middles = list("u", "oo", "ub", "bl", "rr", "rp", "mp", "b")
	var/static/list/glubby_suffixes = list("p!", "b!", "p~", "b~", "t!", "sh!", "rp!", "ble!")
	var/static/list/happy_sounds = list('sound/effects/bamf.ogg', 'sound/machines/chime.ogg', 'sound/machines/ping.ogg')
	var/static/list/tickle_sounds = list('sound/misc/slip.ogg', 'sound/effects/bamf.ogg')

/mob/living/scp/scp999/Initialize()
	. = ..()

	SCP = new /datum/scp(
		src,
		"SCP-999",
		SCP_SAFE,
		"999",
		SCP_PLAYABLE
	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	max_scp_armor = 25
	scp_armor = max_scp_armor

/mob/living/scp/scp999/Destroy()
	healed_targets = list()
	mood_improved_targets = list()
	return ..()

/mob/living/scp/scp999/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, range = 7)
	if(!message || stat == DEAD)
		return

	if(!client || forced)
		message = generate_glubby_speech()
	else
		message = glubbify(message)

	..(message, bubble_type, list("scp999"), sanitize, language, ignore_spam, forced, filterproof, range)

/mob/living/scp/scp999/proc/generate_glubby_speech()
	var/num_parts = rand(2, 5)
	var/list/parts = list()
	for(var/i in 1 to num_parts)
		parts += pick(glubby_prefixes) + pick(glubby_middles) + pick(glubby_suffixes)
	return jointext(parts, " ")

/mob/living/scp/scp999/proc/glubbify(message)
	var/list/words = splittext(message, " ")
	var/list/result = list()
	for(var/word in words)
		if(length(word) <= 2 || prob(25))
			result += pick(glubby_prefixes) + pick(glubby_middles) + pick(glubby_suffixes)
		else
			var/first = copytext(word, 1, 2)
			var/glub = pick(glubby_middles) + pick(glubby_middles)
			var/end = pick(glubby_suffixes)
			result += first + glub + end
	return jointext(result, " ")

/mob/living/scp/scp999/process_scp_effects()
	. = ..()

	provide_comfort()

	if(!client)
		var/mob/living/carbon/human/target = find_target()
		if(target)
			approach_target(target)

	if(prob(8))
		auto_babble()

	try_calm_nearby_scps()

	update_happiness()

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP)
			continue
		award_research_points("999", "behavior", 2, H.ckey)

/mob/living/scp/scp999/proc/auto_babble()
	if(world.time < babble_cooldown)
		return
	babble_cooldown = world.time + babble_cooldown_time
	say(generate_glubby_speech())
	if(prob(40))
		playsound(src, pick(happy_sounds), 30, TRUE)

/mob/living/scp/scp999/proc/provide_comfort()
	if(world.time < healing_cooldown)
		return

	healing_cooldown = world.time + 5 SECONDS

	for(var/mob/living/carbon/human/H in range(comfort_radius, src))
		if(H == src || H.SCP)
			continue

		var/heal_amount = 5
		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
			H.adjustToxLoss(-heal_amount)

		if(H.reagents && !H.reagents.has_reagent(/datum/reagent/medicine/anomalous_happiness))
			H.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 2)

		if(!(H.ckey in mood_improved_targets))
			mood_improved_targets += H.ckey
			if(length(mood_improved_targets) > 100)
				mood_improved_targets.Cut(1, 51)
			mood_improvements++
			comfort_provided++
			to_chat(H, "<span class='notice'>You feel a sense of calm and happiness from [src]'s presence.</span>")

/mob/living/scp/scp999/proc/find_target()
	var/mob/living/carbon/human/closest = null
	var/shortest_distance = 999

	for(var/mob/living/carbon/human/H in view(10, src))
		if(H == src || H.SCP)
			continue

		if(H.health < H.maxHealth * 0.8)
			var/distance = get_dist(src, H)
			if(distance < shortest_distance)
				shortest_distance = distance
				closest = H

	return closest

/mob/living/scp/scp999/proc/approach_target(mob/living/carbon/human/target)
	if(!target)
		return

	step_towards(src, target)

	if(get_dist(src, target) <= 1)
		heal_target(target)

/mob/living/scp/scp999/proc/heal_target(mob/living/carbon/human/target)
	if(!target || world.time < healing_cooldown)
		return

	healing_cooldown = world.time + healing_cooldown_time
	var/heal_amount = healing_power

	visible_message("<span class='notice'>[src] gently nuzzles [target], enveloping them in warm slime!</span>")
	playsound(src, pick(happy_sounds), 30, TRUE)

	target.adjustBruteLoss(-heal_amount)
	target.adjustFireLoss(-heal_amount)
	target.adjustToxLoss(-heal_amount)

	if(target.reagents)
		target.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 5)

	if(!(target.ckey in healed_targets))
		healed_targets += target.ckey
		if(length(healed_targets) > 100)
			healed_targets.Cut(1, 51)
		healing_sessions++

	to_chat(target, "<span class='notice'>You feel completely healed and rejuvenated! A warm euphoria spreads through you.</span>")

	if(target && target.ckey)
		hook_scp_care(target, "SCP-999", "healing")
		hook_scp_interaction(target, "SCP-999", INTERACTION_TYPE_CARE, list("heal_amount" = heal_amount))

	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && H != target && !H.SCP)
			award_research_points("999", "healing", 12, H.ckey)

	add_interaction_record(target, "healing")

/mob/living/scp/scp999/proc/try_calm_nearby_scps()
	if(world.time < calm_scp_cooldown)
		return

	for(var/mob/living/scp/S in range(comfort_radius + 2, src))
		if(S == src || S.stat == DEAD)
			continue

		if(istype(S, /mob/living/scp/scp096))
			calm_scp096(S)
			calm_scp_cooldown = world.time + calm_scp_cooldown_time
			return

		if(istype(S, /mob/living/scp/scp106))
			calm_scp106(S)
			calm_scp_cooldown = world.time + calm_scp_cooldown_time
			return

/mob/living/scp/scp999/proc/calm_scp096(mob/living/scp/scp096/scp096)
	if(!scp096)
		return

	visible_message("<span class='notice'>[src] warbles soothingly at [scp096]. The air grows heavy with comfort.</span>")
	playsound(src, pick(happy_sounds), 40, TRUE)

	if(scp096.state == "screaming")
		scp096.docile_grace_until = world.time + 15 SECONDS
		to_chat(scp096, "<span class='notice'>A wave of calm washes over you. The rage struggles against the warmth...</span>")
	else if(scp096.state == "docile")
		scp096.docile_grace_until = world.time + 30 SECONDS
		to_chat(scp096, "<span class='notice'>The warm presence soothes you. You feel less inclined to react.</span>")

	for(var/mob/living/carbon/human/H in range(5, src))
		award_research_points("999", "calm_scp", 20, H.ckey)

/mob/living/scp/scp999/proc/calm_scp106(mob/living/scp/scp106/scp106)
	if(!scp106)
		return

	visible_message("<span class='notice'>[src] blorbles at [scp106]. The corrosive entity seems to slow slightly.</span>")

	if(scp106.corrosion_active)
		scp106.corrosion_active = FALSE
		addtimer(CALLBACK(scp106, /mob/living/scp/scp106/proc/toggle_corrosion, TRUE), 20 SECONDS)
		to_chat(scp106, "<span class='notice'>An unusual warmth permeates you. The hunger fades, briefly.</span>")

	for(var/mob/living/carbon/human/H in range(5, src))
		award_research_points("999", "calm_scp", 15, H.ckey)



/mob/living/scp/scp999/proc/tickle_target(mob/living/carbon/human/target)
	if(!target || world.time < tickle_cooldown)
		return

	tickle_cooldown = world.time + tickle_cooldown_time

	visible_message("<span class='notice'>[src] wraps around [target] and tickles them enthusiastically!</span>")
	playsound(src, pick(tickle_sounds), 40, TRUE)

	to_chat(target, "<span class='notice'>[src] tickles you! You can't help but laugh uncontrollably!</span>")

	if(target.reagents)
		target.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 8)

	target.adjustBruteLoss(-5)
	target.adjustFireLoss(-5)

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3)

	if(target.ckey)
		hook_scp_interaction(target, "SCP-999", INTERACTION_TYPE_CARE, list("type" = "tickle"))

/mob/living/scp/scp999/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.combat_mode)
			heal_target(H)
		else
			tickle_target(H)
		return

	return ..()

/mob/living/scp/scp999/attack_hand(mob/living/carbon/human/user)
	if(user.combat_mode)
		return ..()

	if(world.time < tickle_cooldown)
		to_chat(user, "<span class='notice'>[src] burbles happily at your touch!</span>")
		if(user.reagents)
			user.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 2)
		return ..()

	visible_message("<span class='notice'>[user] pets [src]! It warbles with delight!</span>")
	playsound(src, pick(happy_sounds), 30, TRUE)

	if(user.reagents)
		user.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 3)

	to_chat(user, "<span class='notice'>Touching [src] fills you with warm euphoria!</span>")

	if(user.ckey)
		hook_scp_interaction(user, "SCP-999", INTERACTION_TYPE_CARE, list("type" = "pet"))

	return ..()

/mob/living/scp/scp999/proc/update_happiness()
	if(healing_sessions > 0 || comfort_provided > 0)
		happiness_level = min(max_happiness, happiness_level + 1)

	healing_power = 25 + (happiness_level / 4)

/mob/living/scp/scp999/proc/heal_nearby_ability()
	if(world.time < healing_cooldown)
		return

	var/heal_amount = healing_power / 2
	to_chat(src, "<span class='notice'>You release a burst of healing energy. Healed: [length(healed_targets)]</span>")

	for(var/mob/living/carbon/human/H in range(comfort_radius, src))
		if(H != src && !H.SCP)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
			H.adjustToxLoss(-heal_amount)
			if(H.reagents)
				H.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 4)
			if(!(H.ckey in healed_targets))
				healed_targets += H.ckey
				healing_sessions++
			to_chat(H, "<span class='notice'>You feel a wave of healing energy from [src]!</span>")

	healing_cooldown = world.time + healing_cooldown_time

/mob/living/scp/scp999/proc/comfort_zone_ability()
	to_chat(src, "<span class='notice'>You create a comfort zone. Comfort provided: [comfort_provided]</span>")

	for(var/mob/living/carbon/human/H in range(comfort_radius, src))
		if(H != src && !H.SCP)
			to_chat(H, "<span class='notice'>You feel overwhelming comfort and peace...</span>")
			H.adjustBruteLoss(-(healing_power / 2))
			H.adjustFireLoss(-(healing_power / 2))
			H.adjustToxLoss(-(healing_power / 2))
			if(H.reagents)
				H.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 6)

/mob/living/scp/scp999/proc/view_healing_stats_ability()
	var/message = "<h2>SCP-999 Healing Statistics</h2>"
	message += "<b>Healing Power:</b> [healing_power]<br>"
	message += "<b>Happiness Level:</b> [happiness_level]/[max_happiness]<br>"
	message += "<b>Comfort Radius:</b> [comfort_radius]<br>"
	message += "<b>Cooldown:</b> [healing_cooldown_time / 10]s<br>"
	message += "<b>Healed Targets:</b> [length(healed_targets)]<br>"
	message += "<b>Mood Improvements:</b> [length(mood_improved_targets)]<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/scp/scp999/get_status_tab_items()
	. = ..()
	. += "Healing Power: [healing_power]"
	. += "Happiness Level: [happiness_level]/[max_happiness]"
	. += "Comfort Radius: [comfort_radius]"
	. += "Healed Targets: [length(healed_targets)]"

/mob/living/scp/scp999/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-999, a friendly gelatinous entity that heals and improves mood.</span>")
		else
			to_chat(user, "<span class='notice'>A friendly orange slime that seems to radiate happiness and healing energy. Just being near it makes you feel lighter.</span>")

/mob/living/scp/scp999/scp_death()
	visible_message("<span class='danger'>[src] appears to lose its vibrant color and stops moving!</span>")
	playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
	..()

/mob/living/scp/scp999/proc/heal_nearby()
	heal_nearby_ability()

/mob/living/scp/scp999/proc/comfort_zone()
	comfort_zone_ability()

/mob/living/scp/scp999/proc/view_healing_stats()
	view_healing_stats_ability()

/mob/living/scp/scp999/proc/view_scp999_persistence_data()
	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-999 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Healing Sessions:</b> [healing_sessions]<br>"
	message += "<b>Mood Improvements:</b> [mood_improvements]<br>"
	message += "<b>Comfort Provided:</b> [comfort_provided]<br>"
	message += "<b>Healed Targets:</b> [length(healed_targets)]<br>"
	message += "<b>Mood Improved Targets:</b> [length(mood_improved_targets)]<br>"
	message += "<b>Healing Power:</b> [healing_power]<br>"
	message += "<b>Happiness Level:</b> [happiness_level]/[max_happiness]<br>"
	message += "<b>Comfort Radius:</b> [comfort_radius]<br>"
	message += "<b>Health:</b> [health]/[maxHealth]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[persistence_id]
		if(instance)
			message += "<b>Interaction History:</b> [length(instance.interaction_history)] records<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/datum/reagent/medicine/anomalous_happiness
	name = "Anomalous Happiness"
	description = "A warm golden fluid secreted by SCP-999. Induces intense euphoria and mild healing."
	taste_description = "warmth and joy"
	reagent_state = LIQUID
	color = "#FFB347"
	ingest_met = 0.4
	overdose_threshold = 30
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/anomalous_happiness/affect_blood(mob/living/carbon/C, removed)
	if(C.stat == DEAD)
		return
	C.adjustBruteLoss(-0.5 * removed)
	C.adjustFireLoss(-0.5 * removed)
	if(prob(15))
		var/list/messages = list(
			"You feel a warm glow of happiness.",
			"Everything seems a little brighter.",
			"A sense of deep contentment settles over you.",
			"You can't help but smile.",
			"The world feels a little kinder."
		)
		to_chat(C, "<span class='notice'>[pick(messages)]</span>")

/datum/reagent/medicine/anomalous_happiness/on_mob_metabolize(mob/living/carbon/C, class)
	. = ..()
	to_chat(C, "<span class='notice'>A wave of euphoria washes over you!</span>")

/datum/reagent/medicine/anomalous_happiness/on_mob_end_metabolize(mob/living/carbon/C, class)
	. = ..()
	to_chat(C, "<span class='warning'>The warm happiness fades, leaving a gentle afterglow.</span>")

/datum/reagent/medicine/anomalous_happiness/overdose_process(mob/living/carbon/C, removed)
	if(prob(25))
		to_chat(C, "<span class='warning'>The happiness is almost overwhelming... your thoughts feel hazy.</span>")
		C.adjust_confusion(2 SECONDS)
	C.adjust_drowsyness(1 SECONDS)

/mob/living/scp/scp999/process_ai()
	if(stat == DEAD)
		return
	if(containment_status == "breached" && prob(15))
		calm_enraged_096()
	apply_mood_aura()
	var/mob/living/carbon/human/closest_hurt
	var/closest_dist = INFINITY
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.stat == DEAD)
			continue
		if(H.health >= H.maxHealth * 0.9)
			continue
		var/dist = get_dist(src, H)
		if(dist < closest_dist)
			closest_dist = dist
			closest_hurt = H
	if(closest_hurt)
		if(get_dist(src, closest_hurt) > 1)
			step_to(src, get_step_towards(src, closest_hurt))
		else
			heal_target(closest_hurt)
	else if(prob(30))
		step_rand(src)
	try_calm_nearby_scps()
