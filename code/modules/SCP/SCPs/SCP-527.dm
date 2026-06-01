// SCP-527 - Mr. Fish
// A fish-man from the SCP-005 "Mr." series

/mob/living/scp/scp527
	ai_enabled = TRUE
	name = "Mr. Fish"
	desc = "A humanoid male with a fish head. He appears to be a specimen from the 'Mr.' series of SCPs."
	icon = 'icons/scp/scp-527.dmi'
	icon_state = "scp527"
	status_flags = 0

	var/datum/scp527_aquatic_system/aquatic_system
	var/datum/scp527_ability_system/ability_system
	var/datum/scp527_research_system/research_system

	var/swim_time = 0
	var/conversations_held = 0

/mob/living/scp/scp527/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "Mr. Fish", SCP_SAFE, "527", SCP_PLAYABLE|SCP_ROLEPLAY)
	SCP.min_playercount = 15
	SCP.min_time = 5 MINUTES

	aquatic_system = new /datum/scp527_aquatic_system(src)
	ability_system = new /datum/scp527_ability_system(src)
	research_system = new /datum/scp527_research_system(src)

	grant_language(/datum/language/common, TRUE, TRUE)

/mob/living/scp/scp527/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(aquatic_system)
		aquatic_system.process_aquatic()

/mob/living/scp/scp527/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, range = 7)
	. = ..()
	if(.)
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD && H != src)
				hook_scp_interaction(H, "SCP-527", INTERACTION_TYPE_COMMUNICATION)
				conversations_held++

/mob/living/scp/scp527/UnarmedAttack(atom/A)
	. = ..()
	if(istype(A, /obj/structure/sink) || istype(A, /turf/open/water))
		if(aquatic_system)
			aquatic_system.enter_water()
			swim_time++
			hook_scp_interaction(src, "SCP-527", INTERACTION_TYPE_EXPLORATION)

/mob/living/scp/scp527/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A fish-headed humanoid from Dr. Wondertainment's 'Mr.' series."))
	to_chat(user, span_notice("He seems comfortable in and out of water."))

/mob/living/scp/scp527/proc/dive()
	var/turf/open/water/W = locate() in range(1, src)
	if(W)
		forceMove(W)
		visible_message(span_notice("[src] dives into the water!"))
		if(aquatic_system)
			aquatic_system.enter_water()
	else
		to_chat(src, span_warning("No water nearby to dive into!"))

/mob/living/scp/scp527/proc/breathe_underwater()
	if(aquatic_system)
		aquatic_system.toggle_underwater_mode()
		to_chat(src, span_notice("You [aquatic_system.underwater_mode ? "begin" : "stop"] breathing underwater."))

/datum/scp527_aquatic_system
	var/mob/living/carbon/human/parent
	var/underwater_mode = FALSE
	var/swim_speed_bonus = 2
	var/water_healing_rate = 1
	var/max_breath_hold = 300

/datum/scp527_aquatic_system/New(mob/living/carbon/human/P)
	parent = P

/datum/scp527_aquatic_system/proc/process_aquatic()
	if(!parent)
		return

	var/turf/T = get_turf(parent)
	if(istype(T, /turf/open/water))
		if(parent.health < parent.maxHealth)
			parent.adjustBruteLoss(-water_healing_rate)

/datum/scp527_aquatic_system/proc/enter_water()
	underwater_mode = TRUE

/datum/scp527_aquatic_system/proc/exit_water()
	underwater_mode = FALSE

/datum/scp527_aquatic_system/proc/toggle_underwater_mode()
	underwater_mode = !underwater_mode

/datum/scp527_ability_system
	var/mob/living/carbon/human/parent
	var/fish_communication_range = 10
	var/speed_in_water = 2

/datum/scp527_ability_system/New(mob/living/carbon/human/P)
	parent = P

/datum/scp527_ability_system/proc/communicate_with_fish()
	if(!parent)
		return

	var/list/nearby_fish = list()
	for(var/mob/living/simple_animal/A in range(fish_communication_range, parent))
		if(findtext(lowertext(A.name), "fish"))
			nearby_fish += A

	if(length(nearby_fish) > 0)
		to_chat(parent, span_notice("You sense [length(nearby_fish)] fish nearby."))
		return nearby_fish

/datum/scp527_research_system
	var/mob/living/carbon/human/parent
	var/list/research_data = list()
	var/water_time = 0

/datum/scp527_research_system/New(mob/living/carbon/human/P)
	parent = P

/mob/living/scp/scp527/process_ai()
	if(stat == DEAD)
		return

	if(health < maxHealth * 0.5)
		var/turf/open/water/W = locate() in range(7, src)
		if(W)
			if(get_dist(src, W) > 1)
				ai_step_towards(W)
			else
				dive()
			return

	if(world.time % 50 == 0)
		var/mob/living/carbon/human/H = locate() in view(4, src)
		if(H && H.stat != DEAD)
			var/greetings = list("Glub.", "Bloop.", "Nice weather... for fish.", "Hello there.")
			say(pick(greetings))

	if(prob(10))
		step_rand(src)
