// SCP-529 - Josie the Cat
// A cat with its rear half missing, yet appears healthy and mobile

/mob/living/simple_animal/scp529
	name = "Josie"
	desc = "A domestic cat with an unusual feature - its rear half is completely missing, yet it moves and behaves like a healthy cat."
	icon = 'icons/scp/scp-529.dmi'
	icon_state = "scp529"
	icon_living = "scp529"
	icon_dead = "scp529_dead"
	health = 50
	maxHealth = 50
	density = FALSE
	anchored = FALSE
	turns_per_move = 3
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "kicks"
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/weapons/tap.ogg'
	speak = list("Meow!", "Mew!", "Purr...", "Mrow?")
	speak_emote = list("meows", "mews", "purrs")
	emote_hear = list("meows", "purrs", "mews")
	emote_see = list("twitches its tail", "looks around", "grooms itself")

	var/datum/scp529_health_system/health_system
	var/datum/scp529_interaction_system/interaction_system
	var/datum/scp529_research_system/research_system

	var/pets_received = 0
	var/food_given = 0
	var/interactions_logged = 0

/mob/living/simple_animal/scp529/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "Josie", SCP_SAFE, "529")

	health_system = new /datum/scp529_health_system(src)
	interaction_system = new /datum/scp529_interaction_system(src)
	research_system = new /datum/scp529_research_system(src)

/mob/living/simple_animal/scp529/Destroy()
	QDEL_NULL(health_system)
	QDEL_NULL(interaction_system)
	QDEL_NULL(research_system)
	return ..()

/mob/living/simple_animal/scp529/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(health_system)
		health_system.process_health()

	if(interaction_system)
		interaction_system.process_interactions()

/mob/living/simple_animal/scp529/attack_hand(mob/living/carbon/human/user)
	. = ..()

	if(!user.combat_mode)
		pets_received++
		hook_scp_interaction(user, "SCP-529", INTERACTION_TYPE_CARE)
		emote("purrs at [user]", 1)

/mob/living/simple_animal/scp529/attackby(obj/item/I, mob/living/carbon/human/user, params)
	if(istype(I, /obj/item/food))
		food_given++
		hook_scp_interaction(user, "SCP-529", INTERACTION_TYPE_CARE)
		visible_message("<span class='notice'>[src] happily eats the [I.name]!</span>")
		qdel(I)
		return
	return ..()

/mob/living/simple_animal/scp529/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Despite having no rear half, this cat appears perfectly healthy and content.</span>")
	to_chat(user, "<span class='notice'>It seems to be named 'Josie'.</span>")

/datum/scp529_health_system
	var/mob/living/simple_animal/parent
	var/regeneration_rate = 0.5
	var/anomaly_stable = TRUE

/datum/scp529_health_system/New(mob/living/simple_animal/P)
	parent = P

/datum/scp529_health_system/proc/process_health()
	if(!parent)
		return

	if(parent.health < parent.maxHealth)
		parent.adjustBruteLoss(-regeneration_rate)

	if(prob(1))
		parent.visible_message("<span class='notice'>[parent]'s missing half briefly shimmers.</span>")

/datum/scp529_interaction_system
	var/mob/living/simple_animal/parent
	var/happiness_level = 50
	var/max_happiness = 100

/datum/scp529_interaction_system/New(mob/living/simple_animal/P)
	parent = P

/datum/scp529_interaction_system/proc/process_interactions()
	if(!parent)
		return

	if(happiness_level < max_happiness)
		happiness_level = min(max_happiness, happiness_level + 0.1)

/datum/scp529_interaction_system/proc/add_happiness(amount)
	happiness_level = clamp(happiness_level + amount, 0, max_happiness)

/datum/scp529_research_system
	var/mob/living/simple_animal/parent
	var/list/interaction_log = list()
	var/total_interactions = 0

/datum/scp529_research_system/New(mob/living/simple_animal/P)
	parent = P

/datum/scp529_research_system/proc/log_interaction(mob/user, interaction_type)
	total_interactions++
	interaction_log["[world.time]"] = list("user" = user?.ckey, "type" = interaction_type)
