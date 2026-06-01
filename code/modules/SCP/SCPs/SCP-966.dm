// SCP-966 - Sleep Killer
// Foundation-19 style: all mechanics inline, no modular datums.
// Passive: drains drowsyness in radius, causes nightmares, auto-stalks nearby humans.
// Click: attacks drowsy humans with invisible claws.
// Verbs: Toggle Invisibility, Stalk Target (in SCP-966 tab)

/mob/living/scp/scp966
	ai_enabled = TRUE
	name = "SCP-966"
	desc = "An invisible creature that causes sleep deprivation. You can barely make out its shimmering outline."
	icon = 'icons/scp/scp-966.dmi'
	icon_state = "scp966"
	real_name = "SCP-966"
	status_flags = 0

	var/sleep_intensity = 1
	var/max_sleep_intensity = 5
	var/sleep_drain_interval = 10 SECONDS
	var/next_sleep_drain = 0
	var/sleep_effect_radius = 5

	var/stealth_active = TRUE
	var/next_stealth_toggle = 0
	var/stealth_toggle_interval = 20 SECONDS

	var/list/stalked_targets = list()
	var/next_stalk_scan = 0
	var/stalk_scan_interval = 15 SECONDS

	var/next_nightmare = 0
	var/nightmare_interval = 30 SECONDS

	var/next_research = 0
	var/research_interval = 40 SECONDS

	var/victims_sleep_deprived = 0
	var/nightmares_caused = 0

/mob/living/scp/scp966/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Sleep Killer", SCP_EUCLID, "966", SCP_PLAYABLE)
	SCP.min_playercount = 25
	SCP.min_time = 10 MINUTES
	grant_language(/datum/language/common, TRUE, TRUE)

	add_verb(src, list(
		/mob/living/scp/scp966/proc/verb_toggle_invisibility,
		/mob/living/scp/scp966/proc/verb_stalk_target,
	))

/mob/living/scp/scp966/Life()
	. = ..()
	if(stat == DEAD)
		return
	ProcessSleepDrain()
	ProcessStealth()
	ProcessStalking()
	ProcessNightmares()
	ProcessResearch()

/mob/living/scp/scp966/proc/ProcessSleepDrain()
	if(world.time < next_sleep_drain)
		return
	next_sleep_drain = world.time + sleep_drain_interval
	for(var/mob/living/carbon/human/H in range(sleep_effect_radius, src))
		if(H == src || H.stat == DEAD)
			continue
		H.adjust_drowsyness(sleep_intensity * 2)
		if(prob(30))
			to_chat(H, span_warning("An oppressive exhaustion presses upon you. Your eyelids feel heavy."))
		if(H.drowsyness >= 60 && prob(15))
			H.AdjustSleeping(20)
			to_chat(H, span_warning("You can't keep your eyes open any longer..."))
			victims_sleep_deprived++

/mob/living/scp/scp966/proc/ProcessStealth()
	if(world.time > next_stealth_toggle && prob(10))
		next_stealth_toggle = world.time + stealth_toggle_interval
		stealth_active = !stealth_active
		if(!stealth_active && prob(30))
			visible_message(span_notice("A shimmer reveals something in the air, then fades."))

/mob/living/scp/scp966/proc/ProcessStalking()
	if(world.time < next_stalk_scan)
		return
	next_stalk_scan = world.time + stalk_scan_interval
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in view(6, src))
		if(H != src && H.stat != DEAD)
			candidates += H
	if(length(candidates))
		var/mob/living/carbon/human/choice = pick(candidates)
		if(!(choice in stalked_targets))
			stalked_targets += choice
			to_chat(choice, span_danger("You feel an unseen gaze upon you..."))

/mob/living/scp/scp966/proc/ProcessNightmares()
	if(world.time < next_nightmare)
		return
	next_nightmare = world.time + nightmare_interval
	if(prob(15))
		var/list/victims = list()
		for(var/mob/living/carbon/human/H in view(4, src))
			if(H != src && H.stat != DEAD)
				victims += H
		if(length(victims))
			var/mob/living/carbon/human/v = pick(victims)
			to_chat(v, span_danger("A waking nightmare grips you with dread."))
			v.adjust_drowsyness(8)
			v.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
			nightmares_caused++

/mob/living/scp/scp966/proc/ProcessResearch()
	if(world.time < next_research)
		return
	next_research = world.time
	SCP?.award_research(null, "sleep_deprivation_phenomena", 8)

/mob/living/scp/scp966/UnarmedAttack(atom/A)
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return ..()
	if(H.drowsyness >= 30)
		H.apply_damage(sleep_intensity * 3, BRUTE)
		H.visible_message(span_danger("Something invisible slashes at [H]!"), span_danger("You feel claws tear into you!"))
		hook_scp_combat(H, "SCP-966", sleep_intensity * 3, 10)
		return
	to_chat(src, span_warning("[H] is too alert to attack effectively. Weaken them first with sleep deprivation."))

/mob/living/scp/scp966/proc/verb_toggle_invisibility()
	set name = "Toggle Invisibility"
	set category = "SCP-966"
	stealth_active = !stealth_active
	to_chat(src, span_notice(stealth_active ? "You fade into the shadows." : "You become more visible."))

/mob/living/scp/scp966/proc/action_toggle_invisibility()
	verb_toggle_invisibility()

/mob/living/scp/scp966/proc/verb_stalk_target()
	set name = "Stalk Target"
	set category = "SCP-966"
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in range(15, src))
		if(H.stat != DEAD && H != src)
			targets += H
	if(!length(targets))
		to_chat(src, span_warning("No valid targets nearby."))
		return
	var/mob/living/carbon/human/target = input(src, "Choose target to stalk:", "Stalk") as null|anything in targets
	if(!target)
		return
	if(!(target in stalked_targets))
		stalked_targets += target
		hook_scp_interaction(target, "SCP-966", INTERACTION_TYPE_OBSERVATION)
		to_chat(target, span_danger("You feel an unseen gaze upon you..."))

/mob/living/scp/scp966/proc/action_stalk_target()
	verb_stalk_target()

/mob/living/scp/scp966/process_ai()
	if(stat == DEAD)
		return
	if(containment_status != "breached")
		return
	if(world.time < last_ai_tick + ai_tick_interval)
		return
	last_ai_tick = world.time

	ProcessSleepDrain()
	ProcessNightmares()

	var/mob/living/carbon/human/drowsy_prey = ai_find_drowsy_target()
	if(drowsy_prey)
		ai_attack_drowsy(drowsy_prey)
		return

	var/mob/living/carbon/human/stalk_target = ai_find_stalk_target()
	if(stalk_target)
		ai_stalk_target(stalk_target)
		return

	ai_stealth_wander()

/mob/living/scp/scp966/proc/ai_find_drowsy_target()
	var/mob/living/carbon/human/best = null
	var/best_drowsy = -1
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H == src || H.stat == DEAD)
			continue
		if(H.drowsyness >= 30 && H.drowsyness > best_drowsy)
			best_drowsy = H.drowsyness
			best = H
	return best

/mob/living/scp/scp966/proc/ai_attack_drowsy(mob/living/carbon/human/target)
	if(get_dist(src, target) > 1)
		step_to(src, target)
		if(stealth_active && prob(30))
			stealth_active = FALSE
			addtimer(CALLBACK(src, PROC_REF(restore_stealth)), 3 SECONDS)
		return

	target.apply_damage(sleep_intensity * 3, BRUTE)
	target.visible_message(span_danger("Something invisible slashes at [target]!"), span_danger("You feel claws tear into you!"))
	hook_scp_combat(target, "SCP-966", sleep_intensity * 3, 10)
	playsound(target, 'sound/weapons/slash.ogg', 40, TRUE)

	if(prob(20))
		stealth_active = FALSE
		addtimer(CALLBACK(src, PROC_REF(restore_stealth)), 2 SECONDS)

/mob/living/scp/scp966/proc/restore_stealth()
	stealth_active = TRUE

/mob/living/scp/scp966/proc/ai_find_stalk_target()
	var/mob/living/carbon/human/best = null
	var/best_dist = INFINITY
	for(var/mob/living/carbon/human/H in view(8, src))
		if(H == src || H.stat == DEAD)
			continue
		var/d = get_dist(src, H)
		if(d < best_dist)
			best_dist = d
			best = H
	return best

/mob/living/scp/scp966/proc/ai_stalk_target(mob/living/carbon/human/target)
	if(get_dist(src, target) <= 2)
		if(!(target in stalked_targets))
			stalked_targets += target
			to_chat(target, span_danger("You feel an unseen gaze upon you..."))
			hook_scp_interaction(target, "SCP-966", INTERACTION_TYPE_OBSERVATION)
		return

	var/ideal_dist = 3
	if(get_dist(src, target) > ideal_dist + 2)
		step_to(src, target)
	else if(get_dist(src, target) < ideal_dist)
		var/atom/flee_dir = get_step_away(src, target)
		if(flee_dir)
			Move(get_turf(flee_dir))
	else if(prob(30))
		var/atom/flank = get_step(target, pick(GLOB.alldirs))
		if(flank && !flank.density)
			step_to(src, flank)

/mob/living/scp/scp966/proc/ai_stealth_wander()
	if(prob(15))
		stealth_active = !stealth_active

	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range * 2)
		step_to(src, ai_home_turf)
	else
		step_rand(src)

	if(prob(10))
		visible_message(span_notice("A shimmer reveals something in the air, then fades."))

/mob/living/scp/scp966/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(H, span_warning("SCP-966: A sleep-inducing predator. Victims suffer extreme sleep deprivation before being attacked."))
		else
			var/can_see = FALSE
			if(istype(H.glasses, /obj/item/clothing/glasses/night))
				can_see = TRUE
			if(H.has_quirk(/datum/quirk/item_quirk/nearsighted))
				can_see = FALSE
			if(can_see)
				to_chat(H, span_warning("Through your lenses, you can make out a thin, skeletal figure crouching in the air..."))
			else
				to_chat(H, span_warning("You can barely see something shimmering in the air..."))

/mob/living/scp/scp966/get_status_tab_items()
	. = ..()
	. += "Victims Deprived: [victims_sleep_deprived]"
	. += "Stalked Targets: [length(stalked_targets)]"
	. += "Nightmares Caused: [nightmares_caused]"
	. += "Sleep Intensity: [sleep_intensity]/[max_sleep_intensity]"
	. += "Invisible: [stealth_active ? "Yes" : "No"]"
