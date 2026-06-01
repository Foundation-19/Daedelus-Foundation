// SCP-2343 - A Benevolent Entity (Trickster)
// A man who offers deals that always come with ironic prices.
// Per wiki: SCP-2343 is a reality-bending entity that appears helpful
// but every "gift" carries a hidden cost. The deals are always fulfilled
// literally but never in the way the recipient intends.

/mob/living/scp/scp2343
	ai_enabled = TRUE
	name = "strange american man"
	desc = "A brusk and wiley man of american descent. Something about him feels... off."
	icon = 'icons/scp/scp_2343.dmi'
	icon_state = "americangod"
	real_name = "SCP-2343"
	status_flags = 0

	var/trick_cooldown = 0
	var/trick_cooldown_time = 20 SECONDS
	var/deal_cooldown = 0
	var/deal_cooldown_time = 30 SECONDS
	var/disappear_cooldown = 0
	var/disappear_cooldown_time = 60 SECONDS

	var/list/active_deals = list()
	var/list/deal_victims = list()
	var/deals_made = 0
	var/tricks_pulled = 0
	var/ironic_backfires = 0

	var/datum/scp2343_benevolence_system/benevolence_system
	var/datum/scp2343_research_system/research_system

/mob/living/scp/scp2343/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "benevolent entity", SCP_SAFE, "2343", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	benevolence_system = new /datum/scp2343_benevolence_system(src)
	research_system = new /datum/scp2343_research_system(src)

	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/scp/scp2343/proc/pull_small_trick,
		/mob/living/scp/scp2343/proc/offer_deal,
		/mob/living/scp/scp2343/proc/disappear_ability,
	))

/mob/living/scp/scp2343/Destroy()
	QDEL_NULL(benevolence_system)
	QDEL_NULL(research_system)
	active_deals = list()
	deal_victims = list()
	return ..()

/mob/living/scp/scp2343/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	benevolence_system?.process_benevolence()
	research_system?.process_research()
	process_active_deals()
	if(prob(2))
		check_scp_interactions()

/mob/living/scp/scp2343/proc/process_active_deals()
	var/list/expired = list()
	for(var/ckey in active_deals)
		var/list/deal = active_deals[ckey]
		var/mob/living/carbon/human/victim = deal["victim"]
		if(QDELETED(victim) || victim.stat == DEAD)
			expired += ckey
			continue
		var/timer = deal["timer"]
		if(world.time >= timer)
			trigger_deal_backfire(victim, deal)
			expired += ckey
	for(var/ckey in expired)
		active_deals -= ckey

/mob/living/scp/scp2343/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, range = 7)
	. = ..()
	if(.)
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD && H != src)
				hook_scp_interaction(H, "SCP-2343", INTERACTION_TYPE_COMMUNICATION)

/mob/living/scp/scp2343/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, span_notice("A man with a disarming smile. He seems to have reality-bending powers."))
		to_chat(user, span_warning("His deals always come with a catch..."))

// ===== VERBS =====

/mob/living/scp/scp2343/proc/pull_small_trick()
	set name = "Pull Small Trick"
	set category = "SCP-2343"

	if(stat == DEAD)
		return
	if(world.time < trick_cooldown)
		to_chat(src, span_warning("You need to wait before pulling another trick."))
		return

	trick_cooldown = world.time + trick_cooldown_time
	tricks_pulled++

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H != src && H.stat != DEAD)
			targets += H
	if(!length(targets))
		to_chat(src, span_warning("No targets nearby."))
		return

	var/mob/living/carbon/human/target = pick(targets)
	var/trick = rand(1, 6)

	switch(trick)
		if(1)
			var/obj/item/W = target.get_active_held_item()
			if(W)
				var/turf/T = get_step(target, pick(GLOB.alldirs))
				target.dropItemToGround(W)
				if(T)
					W.forceMove(T)
				target.visible_message(span_notice("[target]'s [W.name] slips from their grasp and slides away!"), span_warning("Your [W.name] slips from your hand!"))
			else
				target.adjust_drowsyness(5 SECONDS)
				target.visible_message(span_notice("[target] looks momentarily confused."), span_warning("Your thoughts scatter briefly..."))
		if(2)
			var/old_dir = target.dir
			var/new_dir = pick(NORTH, SOUTH, EAST, WEST)
			if(new_dir != old_dir)
				target.setDir(new_dir)
				target.visible_message(span_notice("[target] suddenly turns to face a different direction!"), span_warning("You feel disoriented — which way were you facing?"))
		if(3)
			var/list/items = target.get_equipped_items()
			if(length(items))
				var/obj/item/I = pick(items)
				var/old_name = I.name
				var/old_desc = I.desc
				I.name = "suspicious [old_name]"
				I.desc = "Something seems... off about this [old_name]."
				addtimer(CALLBACK(src, PROC_REF(reset_item_identity), I, old_name, old_desc), 30 SECONDS)
				to_chat(target, span_warning("Your [old_name] looks... different somehow."))
			else
				target.set_jitter_if_lower(20)
				to_chat(target, span_warning("A strange shiver runs through you."))
		if(4)
			var/list/sounds = list('sound/effects/bamf.ogg', 'sound/machines/chime.ogg', 'sound/effects/sparks1.ogg')
			playsound(target, pick(sounds), 30, TRUE)
			to_chat(target, span_warning("You hear a strange sound right next to you, but nothing is there."))
		if(5)
			target.set_jitter_if_lower(20)
			target.visible_message(span_notice("[target] stumbles slightly."), span_warning("The ground shifts beneath your feet!"))
		if(6)
			var/list/whispers = list(
				"Deal?",
				"I can help you...",
				"You want power? I know someone...",
				"That injury looks painful. I could fix it...",
				"You seem tired. I could give you energy...",
			)
			to_chat(target, span_warning("A whisper in your ear: \"[pick(whispers)]\""))
			if(target.sanity)
				target.sanity.adjust_sanity(-3)

	hook_scp_interaction(target, "SCP-2343", INTERACTION_TYPE_OBSERVATION)

/mob/living/scp/scp2343/proc/offer_deal()
	set name = "Offer Deal"
	set category = "SCP-2343"

	if(stat == DEAD)
		return
	if(world.time < deal_cooldown)
		to_chat(src, span_warning("You need to wait before offering another deal."))
		return

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(3, src))
		if(H != src && H.stat != DEAD)
			targets += H
	if(!length(targets))
		to_chat(src, span_warning("No targets nearby to offer a deal to."))
		return

	var/mob/living/carbon/human/target = input(src, "Choose who to offer a deal:", "SCP-2343 Deal") as null|anything in targets
	if(!target || QDELETED(target))
		return

	deal_cooldown = world.time + deal_cooldown_time
	deals_made++

	var/deal_type = rand(1, 5)
	var/offer_text
	var/duration

	switch(deal_type)
		if(1)
			offer_text = "I can heal your wounds... for a price."
			duration = 60 SECONDS
		if(2)
			offer_text = "I can give you speed... for a price."
			duration = 45 SECONDS
		if(3)
			offer_text = "I can make you stronger... for a price."
			duration = 50 SECONDS
		if(4)
			offer_text = "I can restore your mind... for a price."
			duration = 40 SECONDS
		if(5)
			offer_text = "I can give you knowledge... for a price."
			duration = 55 SECONDS

	visible_message(span_notice("[src] leans in toward [target]."), span_notice("You offer a deal to [target]."))
	to_chat(target, span_userdanger("[src] whispers: \"[offer_text]\""))
	to_chat(target, span_warning("You can accept the deal by shaking [src]'s hand. Use the 'Accept Deal' verb in the SCP-2343 tab."))

	if(!(target.ckey in deal_victims))
		deal_victims[target.ckey] = list("deals" = 0, "backfires" = 0)
	deal_victims[target.ckey]["deals"] += 1

	var/list/deal = list(
		"victim" = target,
		"type" = deal_type,
		"timer" = world.time + duration,
		"accepted" = FALSE,
	)
	active_deals[target.ckey] = deal

	addtimer(CALLBACK(src, PROC_REF(check_deal_expired), target.ckey), duration + 1 SECONDS)

	hook_scp_interaction(target, "SCP-2343", INTERACTION_TYPE_COMMUNICATION)

/mob/living/scp/scp2343/proc/check_deal_expired(ckey)
	var/list/deal = active_deals[ckey]
	if(!deal)
		return
	if(!deal["accepted"])
		var/mob/living/carbon/human/victim = deal["victim"]
		if(victim)
			to_chat(victim, span_notice("The offer fades... [src] shrugs."))
		active_deals -= ckey

/mob/living/scp/scp2343/proc/accept_deal(mob/living/carbon/human/target)
	if(!target || !ishuman(target))
		return

	var/list/deal = active_deals[target.ckey]
	if(!deal)
		to_chat(target, span_warning("There is no deal to accept."))
		return
	if(deal["accepted"])
		to_chat(target, span_warning("You already accepted a deal."))
		return

	if(get_dist(src, target) > 1)
		to_chat(target, span_warning("You need to be closer to shake hands."))
		return

	deal["accepted"] = TRUE
	visible_message(span_notice("[target] shakes [src]'s hand!"), span_notice("[target] accepts your deal!"))
	to_chat(target, span_notice("The deal is struck. You feel a surge of power..."))

	var/deal_type = deal["type"]

	switch(deal_type)
		if(1)
			target.adjustBruteLoss(-50)
			target.adjustFireLoss(-50)
			target.adjustToxLoss(-20)
			to_chat(target, span_notice("Your wounds knit closed! You feel whole again."))
		if(2)
			target.add_movespeed_modifier(/datum/movespeed_modifier/scp2343_deal_speed)
			addtimer(CALLBACK(target, /mob/living/carbon/human/proc/remove_scp2343_speed_buff), 30 SECONDS)
			to_chat(target, span_notice("You feel incredibly fast! Your legs move like the wind!"))
		if(3)
			target.next_move_modifier = 0.5
			addtimer(CALLBACK(target, /mob/living/carbon/human/proc/remove_scp2343_strength_buff), 30 SECONDS)
			to_chat(target, span_notice("Your muscles surge with power! You feel unstoppable!"))
		if(4)
			target.hallucination = 0
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, -30)
			if(target.sanity)
				target.sanity.adjust_sanity(30)
			to_chat(target, span_notice("Your mind clears! Every trauma fades away!"))
		if(5)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, -20)
			if(target.sanity)
				target.sanity.adjust_sanity(15)
			to_chat(target, span_notice("Knowledge floods your mind! You understand things you couldn't before!"))

	hook_scp_interaction(target, "SCP-2343", INTERACTION_TYPE_EXPERIMENT)

// ===== DEAL BACKFIRES =====
// Every deal is fulfilled literally but with an ironic twist.
// The backfire triggers after the deal duration expires.

/mob/living/scp/scp2343/proc/trigger_deal_backfire(mob/living/carbon/human/victim, list/deal)
	if(QDELETED(victim) || victim.stat == DEAD)
		return

	ironic_backfires++
	if(victim.ckey in deal_victims)
		deal_victims[victim.ckey]["backfires"] += 1

	var/deal_type = deal["type"]

	switch(deal_type)
		if(1)
			victim.adjustBruteLoss(30)
			victim.adjustFireLoss(30)
			to_chat(victim, span_userdanger("The healing reverses! Your wounds tear open again — worse than before!"))
			victim.emote("scream")
		if(2)
			victim.add_movespeed_modifier(/datum/movespeed_modifier/scp2343_deal_slowness)
			addtimer(CALLBACK(victim, /mob/living/carbon/human/proc/remove_scp2343_slowness), 30 SECONDS)
			to_chat(victim, span_userdanger("Your legs give out! Every step is agony — you can barely move!"))
		if(3)
			victim.adjustBruteLoss(20)
			victim.Stun(60)
			to_chat(victim, span_userdanger("Your muscles seize up violently! The strength was borrowed, and now the debt comes due!"))
		if(4)
			victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
			victim.hallucination += 30
			if(victim.sanity)
				victim.sanity.adjust_sanity(-30)
			to_chat(victim, span_userdanger("Your mind fractures! The clarity was a lie — your thoughts scatter into chaos!"))
		if(5)
			victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)
			victim.set_jitter_if_lower(30)
			to_chat(victim, span_userdanger("The knowledge burns! Your mind rebels against what it learned!"))

	visible_message(span_warning("[src] watches [victim] with a knowing smile."), span_notice("The deal comes due."))
	hook_scp_combat(victim, "SCP-2343", 30, 20)

// ===== DISAPPEAR =====

/mob/living/scp/scp2343/proc/disappear_ability()
	set name = "Disappear"
	set category = "SCP-2343"

	if(stat == DEAD)
		return
	if(world.time < disappear_cooldown)
		to_chat(src, span_warning("You need to wait before disappearing again."))
		return

	disappear_cooldown = world.time + disappear_cooldown_time

	visible_message(span_warning("[src] snaps their fingers and vanishes!"))
	playsound(src, 'sound/effects/bamf.ogg', 50, TRUE)

	invisibility = INVISIBILITY_OBSERVER
	alpha = 0
	density = FALSE

	addtimer(CALLBACK(src, PROC_REF(reappear)), 15 SECONDS)

/mob/living/scp/scp2343/proc/reappear()
	if(QDELETED(src))
		return
	invisibility = 0
	alpha = 255
	density = initial(density)
	visible_message(span_warning("[src] reappears with a grin!"))
	playsound(src, 'sound/effects/phasein.ogg', 50, TRUE)

/mob/living/scp/scp2343/proc/reset_item_identity(obj/item/I, old_name, old_desc)
	if(QDELETED(I))
		return
	I.name = old_name
	I.desc = old_desc

/mob/living/scp/scp2343/proc/check_scp_interactions()
	if(stat == DEAD)
		return
	if(!SSscp_cross_interactions?.setup_complete)
		return
	if(prob(3))
		for(var/mob/living/simple_animal/hostile/scp610_fleshman/M in range(6, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("2343_benevolence_610", src, M)
				break
	if(prob(3))
		for(var/mob/living/scp/scp049/M in range(8, src))
			if(M.stat != DEAD)
				SSscp_cross_interactions.execute_interaction("2343_benevolence_049", src, M)
				break

/mob/living/scp/scp2343/proc/on_benevolent_act(mob/living/carbon/human/beneficiary)
	if(!beneficiary)
		return
	hook_scp_care(beneficiary, "SCP-2343", "benevolence")

/mob/living/scp/scp2343/get_status_tab_items()
	. = ..()
	. += "Deals Made: [deals_made]"
	. += "Tricks Pulled: [tricks_pulled]"
	. += "Ironic Backfires: [ironic_backfires]"
	. += "Active Deals: [length(active_deals)]"

// ===== HELPER PROCS ON HUMANS =====

/mob/living/carbon/human/proc/remove_scp2343_speed_buff()
	remove_movespeed_modifier(/datum/movespeed_modifier/scp2343_deal_speed)

/mob/living/carbon/human/proc/remove_scp2343_strength_buff()
	next_move_modifier = initial(next_move_modifier)

/mob/living/carbon/human/proc/remove_scp2343_slowness()
	remove_movespeed_modifier(/datum/movespeed_modifier/scp2343_deal_slowness)

// ===== MOVESPEED MODIFIERS =====

/datum/movespeed_modifier/scp2343_deal_speed
	id = "scp2343_deal_speed"
	priority = 100
	slowdown = -2

/datum/movespeed_modifier/scp2343_deal_slowness
	id = "scp2343_deal_slowness"
	priority = 100
	slowdown = 4
