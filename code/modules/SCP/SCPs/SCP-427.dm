// SCP-427: Healing Locket
// A small, ornately carved locket that provides rapid healing but transforms the user into a monster with prolonged use
// Lore: SCP-427 heals any injury instantly, but after 3+ minutes of continuous use begins to cause uncontrolled tissue growth
// Known as "SCP-427-1" transformation — a fleshy, aggressive monster with regenerative abilities

#define TRANSFORMATION_STAGE_NONE 0
#define TRANSFORMATION_STAGE_EUPHORIA 1
#define TRANSFORMATION_STAGE_DEPENDENCY 2
#define TRANSFORMATION_STAGE_MUTATION 3
#define TRANSFORMATION_STAGE_HORROR 4
#define TRANSFORMATION_STAGE_MONSTER 5

/obj/item/clothing/neck/scp427
	name = "ornate locket"
	desc = "A small, ornately carved locket made out of polished silver material. An intricate floral pattern covers its surface."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "bronze"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_NECK
	var/locket_open = FALSE
	var/addiction_strength = 0
	var/transformation_timer_id = null
	var/addiction_timer_id = null

	// Transformation tracking per user
	var/list/transformation_stage = list()	// user_key → stage (0-5)
	var/list/time_used = list()				// user_key → seconds of open exposure
	var/list/sanity_damage_accumulated = list()

	// Timing (in seconds)
	var/transformation_time_stage_1 = 15	// Euphoria begins
	var/transformation_time_stage_2 = 45	// Dependency begins
	var/transformation_time_stage_3 = 90	// First mutations
	var/transformation_time_stage_4 = 180	// Body horror
	var/transformation_time_stage_5 = 300	// Full monster

	// Healing stats
	var/heal_rate_brute = 12
	var/heal_rate_burn = 12
	var/heal_rate_toxin = 6
	var/heal_rate_oxy = 6

	// Visual effect tracking
	var/list/client_colours_applied = list()
	var/static/list/transform_messages = list(
		"euphoria" = list(
			"You feel an intense euphoric warmth spreading from the locket.",
			"The world seems brighter and clearer than ever before.",
			"All your worries fade away. This feels perfect.",
		),
		"dependency" = list(
			"You can't imagine ever closing the locket. The warmth is everything.",
			"Closing the locket for even a moment feels unthinkable.",
			"You need the locket's warmth. You need it always.",
		),
		"mutation" = list(
			"Your skin feels tight and strange where it touches the locket.",
			"You notice small, painless nodules forming under your skin.",
			"Your joints ache pleasantly when you think about closing the locket.",
		),
		"horror" = list(
			"Your flesh seems to be moving independently under the skin.",
			"Bone spikes push gently against your skin from the inside.",
			"You can feel extra muscle mass growing where there shouldn't be any.",
		),
	)

/obj/item/clothing/neck/scp427/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Ornate Locket", SCP_SAFE, "427")

/obj/item/clothing/neck/scp427/process(delta_time)
	var/mob/living/carbon/human/user = loc
	if(!istype(user))
		return

	if(!locket_open)
		return

	var/user_key = user.ckey || "\ref[user]"
	if(!(user_key in time_used))
		time_used[user_key] = 0
		transformation_stage[user_key] = TRANSFORMATION_STAGE_NONE
		sanity_damage_accumulated[user_key] = 0

	time_used[user_key] += delta_time

	apply_healing(user)
	update_transformation_stage(user)
	apply_stage_effects(user)
	handle_addiction(user)
	apply_sanity_effects(user)

/obj/item/clothing/neck/scp427/proc/apply_healing(mob/living/carbon/human/user)
	var/heal_modifier = 1.0

	if(transformation_stage[user.ckey || "\ref[user]"] >= TRANSFORMATION_STAGE_MUTATION)
		heal_modifier = 1.3

	user.adjustBruteLoss(-heal_rate_brute * heal_modifier)
	user.adjustFireLoss(-heal_rate_burn * heal_modifier)
	user.adjustToxLoss(-heal_rate_toxin * heal_modifier)
	user.adjustOxyLoss(-heal_rate_oxy * heal_modifier)

	on_healing_applied(user, heal_rate_brute * heal_modifier)

	if(user.sanity)
		user.sanity.adjust_sanity(1, "SCP-427 euphoria")

/obj/item/clothing/neck/scp427/proc/update_transformation_stage(mob/living/carbon/human/user)
	var/user_key = user.ckey || "\ref[user]"
	var/current_time = time_used[user_key]
	var/current_stage = transformation_stage[user_key]

	var/new_stage = TRANSFORMATION_STAGE_NONE
	if(current_time >= transformation_time_stage_5)
		new_stage = TRANSFORMATION_STAGE_MONSTER
	else if(current_time >= transformation_time_stage_4)
		new_stage = TRANSFORMATION_STAGE_HORROR
	else if(current_time >= transformation_time_stage_3)
		new_stage = TRANSFORMATION_STAGE_MUTATION
	else if(current_time >= transformation_time_stage_2)
		new_stage = TRANSFORMATION_STAGE_DEPENDENCY
	else if(current_time >= transformation_time_stage_1)
		new_stage = TRANSFORMATION_STAGE_EUPHORIA

	if(new_stage != current_stage)
		on_stage_change(user, current_stage, new_stage)
		transformation_stage[user_key] = new_stage

/obj/item/clothing/neck/scp427/proc/on_stage_change(mob/living/carbon/human/user, old_stage, new_stage)
	if(!user || !user.client)
		return

	switch(new_stage)
		if(TRANSFORMATION_STAGE_EUPHORIA)
			to_chat(user, span_notice("[pick(transform_messages["euphoria"])]"))
			user.sanity?.adjust_sanity(5, "SCP-427 initial euphoria")

		if(TRANSFORMATION_STAGE_DEPENDENCY)
			to_chat(user, span_warning("[pick(transform_messages["dependency"])]"))
			addiction_strength = min(addiction_strength + 0.2, 0.8)

		if(TRANSFORMATION_STAGE_MUTATION)
			to_chat(user, span_danger("[pick(transform_messages["mutation"])]"))
			apply_mutation_effects(user)
			addiction_strength = min(addiction_strength + 0.3, 1.0)

		if(TRANSFORMATION_STAGE_HORROR)
			to_chat(user, span_userdanger("[pick(transform_messages["horror"])]"))
			apply_body_horror_effects(user)
			shake_camera(user, 4, 2)

		if(TRANSFORMATION_STAGE_MONSTER)
			begin_full_transformation(user)

/obj/item/clothing/neck/scp427/proc/apply_stage_effects(mob/living/carbon/human/user)
	var/stage = transformation_stage[user.ckey || "\ref[user]"]

	switch(stage)
		if(TRANSFORMATION_STAGE_EUPHORIA)
			if(prob(5))
				to_chat(user, span_notice("The warmth from the locket spreads through your entire body."))

		if(TRANSFORMATION_STAGE_DEPENDENCY)
			if(prob(3))
				user.emote("sigh")
			if(prob(2) && !locket_open)
				user.visible_message(
					span_warning("[user]'s hand twitches toward the locket."),
					span_danger("You feel an overwhelming urge to open the locket again.")
				)

		if(TRANSFORMATION_STAGE_MUTATION)
			if(prob(4))
				user.adjustBruteLoss(1)
				to_chat(user, span_warning("You feel a sharp pain as something shifts under your skin."))
			if(prob(2))
				shake_camera(user, 1, 1)

		if(TRANSFORMATION_STAGE_HORROR)
			if(prob(5))
				user.adjustBruteLoss(rand(2, 5))
				user.emote("scream")
			if(prob(3))
				user.visible_message(
					span_danger("[user]'s skin bulges unnaturally!"),
					span_userdanger("Something moves violently beneath your skin!")
				)
				shake_camera(user, 3, 2)

/obj/item/clothing/neck/scp427/proc/apply_mutation_effects(mob/living/carbon/human/user)
	if(!user.client)
		return

	user.add_client_colour(/datum/client_colour/scp427_mutation)
	client_colours_applied[user.ckey || "\ref[user]"] = TRUE

	to_chat(user, span_danger("The world takes on a reddish tint as your body begins to change..."))

/obj/item/clothing/neck/scp427/proc/apply_body_horror_effects(mob/living/carbon/human/user)
	if(!user.client)
		return

	user.Stun(20)
	shake_camera(user, 6, 3)

	var/atom/movable/plane_master_controller/game/pmc = user.hud_used?.plane_master_controllers?[PLANE_MASTERS_GAME]
	if(pmc)
		pmc.add_filter("scp427_wave", 1, list("type" = "wave", "size" = 3, "x" = 8, "y" = 8))
		for(var/filter in pmc.get_filters("scp427_wave"))
			animate(filter, time = 10 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 8, flags = ANIMATION_PARALLEL)

/obj/item/clothing/neck/scp427/proc/begin_full_transformation(mob/living/carbon/human/user)
	var/turf/user_turf = get_turf(user)
	forceMove(user_turf)

	playsound(user_turf, 'sound/effects/bang.ogg', 75, TRUE, 12)
	user.visible_message(
		span_danger("[user]'s body begins to violently mutate!"),
		span_userdanger("YOUR BODY IS TEARING ITSELF APART! IT'S TRANSFORMING!")
	)

	user.Stun(60)
	shake_camera(user, 10, 4)

	clear_visual_effects(user)

	deltimer(transformation_timer_id)
	transformation_timer_id = addtimer(CALLBACK(src, PROC_REF(complete_transformation), user), 50, TIMER_STOPPABLE)

/obj/item/clothing/neck/scp427/proc/complete_transformation(mob/living/carbon/human/user)
	if(!user)
		return

	var/turf/user_turf = get_turf(user)
	playsound(user_turf, 'sound/effects/explosion1.ogg', 100, TRUE, 12)

	user.visible_message(
		span_danger("[user] erupts into a writhing mass of flesh and bone!"),
		span_userdanger("YOU ARE NO LONGER HUMAN!")
	)

	SCP.log_interaction(user, "transformation")
	SCP.award_research(user, "anomaly", 50)

	user.ghostize(TRUE)
	user.dust()

	var/mob/living/simple_animal/hostile/scp427_1/monster = new /mob/living/simple_animal/hostile/scp427_1(user_turf)
	monster.name = "SCP-427-1"
	monster.desc = "A horrific amalgamation of flesh, bone, and muscle. Its form constantly shifts and writhes."
	monster.transformed_from = user.name

	hook_scp_breach("SCP-427", src)
	on_transformation(user)

/obj/item/clothing/neck/scp427/proc/handle_addiction(mob/living/carbon/human/user)
	if(!locket_open && addiction_strength > 0)
		if(prob(addiction_strength * 10))
			to_chat(user, span_warning("You feel an intense craving to open the locket again."))
			user.sanity?.adjust_sanity(-2, "SCP-427 withdrawal")
			user.adjustBruteLoss(rand(1, 3))

		if(prob(addiction_strength * 5))
			user.visible_message(
				span_notice("[user]'s hand trembles near the locket."),
				span_danger("Your hand moves toward the locket against your will!")
			)
			deltimer(addiction_timer_id)
			addiction_timer_id = addtimer(CALLBACK(src, PROC_REF(attempt_auto_open), user), 10, TIMER_STOPPABLE)

/obj/item/clothing/neck/scp427/proc/attempt_auto_open(mob/living/carbon/human/user)
	if(user && !locket_open && user.is_holding(src))
		attack_self(user)

/obj/item/clothing/neck/scp427/proc/apply_sanity_effects(mob/living/carbon/human/user)
	if(!user.sanity)
		return

	var/user_key = user.ckey || "\ref[user]"
	var/stage = transformation_stage[user_key]

	var/sanity_effect = 0
	switch(stage)
		if(TRANSFORMATION_STAGE_EUPHORIA)
			sanity_effect = 1
		if(TRANSFORMATION_STAGE_DEPENDENCY)
			sanity_effect = 0
		if(TRANSFORMATION_STAGE_MUTATION)
			sanity_effect = -1
		if(TRANSFORMATION_STAGE_HORROR)
			sanity_effect = -3
		if(TRANSFORMATION_STAGE_MONSTER)
			sanity_effect = -5

	user.sanity.adjust_sanity(sanity_effect, "SCP-427 exposure")

	if(stage >= TRANSFORMATION_STAGE_MUTATION)
		sanity_damage_accumulated[user_key] = (sanity_damage_accumulated[user_key] || 0) + 1
		if(sanity_damage_accumulated[user_key] >= 30)
			user.sanity.add_trauma("scp_exposure", 10)

/obj/item/clothing/neck/scp427/proc/clear_visual_effects(mob/living/carbon/human/user)
	if(!user || !user.client)
		return

	var/user_key = user.ckey || "\ref[user]"
	if(user_key in client_colours_applied)
		user.remove_client_colour(/datum/client_colour/scp427_mutation)
		client_colours_applied -= user_key

	var/atom/movable/plane_master_controller/game/pmc = user.hud_used?.plane_master_controllers?[PLANE_MASTERS_GAME]
	if(pmc)
		pmc.remove_filter("scp427_wave")

/obj/item/clothing/neck/scp427/attack_self(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	locket_open = !locket_open
	to_chat(user, "You flip \the [src] [locket_open ? "open" : "closed"].")

	if(locket_open)
		icon_state = "bronze"
		START_PROCESSING(SSobj, src)
		to_chat(user, span_notice("You feel a warm, healing energy emanating from the locket."))
	else
		icon_state = "bronze"
		STOP_PROCESSING(SSobj, src)
		to_chat(user, span_notice("The healing energy fades as you close the locket."))
		clear_visual_effects(H)

/obj/item/clothing/neck/scp427/equipped(mob/user, slot)
	. = ..()
	if(locket_open && ishuman(user))
		to_chat(user, span_notice("The locket's healing energy flows through you."))

/obj/item/clothing/neck/scp427/unequipped(mob/user)
	. = ..()
	if(ishuman(user))
		clear_visual_effects(user)
		if(locket_open)
			to_chat(user, span_notice("The locket's effects fade as you remove it."))

/obj/item/clothing/neck/scp427/examine(mob/user)
	. = ..()
	. += span_notice("This ornate locket seems to have healing properties when opened.")

	if(locket_open)
		. += span_warning("The locket is open and emanating healing energy.")
		var/user_key = user.ckey || "\ref[user]"
		if(user_key in time_used)
			var/usage_time = time_used[user_key]
			var/stage = transformation_stage[user_key]

			switch(stage)
				if(TRANSFORMATION_STAGE_EUPHORIA)
					. += span_notice("You have used the locket for [usage_time] seconds.")
				if(TRANSFORMATION_STAGE_DEPENDENCY)
					. += span_warning("You feel dependent on the locket's warmth.")
				if(TRANSFORMATION_STAGE_MUTATION)
					. += span_danger("Your body is beginning to change. You should stop using the locket.")
				if(TRANSFORMATION_STAGE_HORROR)
					. += span_userdanger("YOUR BODY IS BEING TRANSFORMED! REMOVE THE LOCKET IMMEDIATELY!")
				if(TRANSFORMATION_STAGE_MONSTER)
					. += span_userdanger("TRANSFORMATION IS IMMINENT!")

/obj/item/clothing/neck/scp427/Destroy()
	STOP_PROCESSING(SSobj, src)
	deltimer(transformation_timer_id)
	deltimer(addiction_timer_id)
	QDEL_NULL(SCP)
	transformation_stage = null
	time_used = null
	sanity_damage_accumulated = null
	client_colours_applied = null
	return ..()

// SCP-427-1 monster
/mob/living/simple_animal/hostile/scp427_1
	name = "SCP-427-1"
	desc = "A horrific amalgamation of flesh, bone, and muscle. Its form constantly shifts and writhes."
	icon = 'icons/mob/eldritch_mobs.dmi'
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	icon_dead = "armsy_start"
	maxHealth = 200
	health = 200
	harm_intent_damage = 15
	melee_damage_lower = 25
	melee_damage_upper = 35
	attack_verb_continuous = "smashes"
	attack_verb_simple = "smash"
	attack_sound = 'sound/effects/blobattack.ogg'
	faction = list("scp", "hostile")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	weather_immunities = list("lava", "ash")
	var/transformed_from = "unknown"

/mob/living/simple_animal/hostile/scp427_1/Life()
	. = ..()
	if(.)
		adjustBruteLoss(-5)

		for(var/mob/living/carbon/human/H in view(5, src))
			if(H.sanity)
				H.sanity.adjust_sanity(-2, "SCP-427-1 presence")

/mob/living/simple_animal/hostile/scp427_1/attack_ghost(mob/user)
	. = ..()
	if(.)
		to_chat(user, span_danger("This was once [transformed_from]."))

// Mutation client colour
/datum/client_colour/scp427_mutation
	colour = list(1.1,0.1,0.1,0, 0.1,0.9,0.1,0, 0.1,0.1,0.8,0, 0,0,0,1, 0.1,0,0,0)
	priority = 10
	fade_in = 10
	fade_out = 20

// Hook integration
/obj/item/clothing/neck/scp427/proc/on_healing_applied(mob/living/carbon/human/patient, amount)
	if(!patient)
		return
	hook_scp_care(patient, "SCP-427", "healing")

/obj/item/clothing/neck/scp427/proc/on_transformation(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_player_death_near_scp(victim, "SCP-427")


