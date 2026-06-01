/mob/living/simple_animal/scp131
	name = "SCP-131"
	desc = "A teardrop-shaped creature with a single large eye."
	icon = 'icons/scp/SCP-131.dmi'
	health = 50
	maxHealth = 50
	density = FALSE
	anchored = FALSE
	turns_per_move = 2
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_harm_continuous = "kicks"
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/weapons/tap.ogg'

	var/babble_cooldown = 0
	var/babble_cooldown_time = 10 SECONDS
	var/scp173_stared = FALSE
	var/observation_range = 6
	var/bonded_friend_ref = null
	var/bond_strength = 0
	var/max_bond = 100
	var/bond_decay_rate = 0.5
	var/bond_gain_per_interact = 15
	var/panic_threshold = 40
	var/is_panicking = FALSE
	var/panic_cooldown = 0

	var/static/list/panic_sounds = list('sound/voice/edplaceholder.ogg', 'sound/effects/bamf.ogg')

/mob/living/simple_animal/scp131/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Eye Pods", SCP_SAFE, "131")

/mob/living/simple_animal/scp131/Destroy()
	bonded_friend_ref = null
	return ..()

/mob/living/simple_animal/scp131/Life()
	. = ..()
	if(stat == DEAD)
		return

	process_babbling()
	process_following()
	process_bond_decay()
	stare_down_scp173()
	process_panic()

/mob/living/simple_animal/scp131/proc/process_babbling()
	if(world.time < babble_cooldown)
		return
	babble_cooldown = world.time + babble_cooldown_time
	if(prob(30))
		say(get_babble())

/mob/living/simple_animal/scp131/proc/get_babble()
	return "Babu!"

/mob/living/simple_animal/scp131/proc/process_following()
	if(client)
		return

	var/mob/living/carbon/human/friend = get_bonded_friend()
	if(friend && friend.stat != DEAD)
		if(get_dist(src, friend) > 2)
			step_towards(src, friend)
		return

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H.stat != DEAD && !H.SCP)
			if(prob(10))
				step_towards(src, H)
			break

/mob/living/simple_animal/scp131/proc/stare_down_scp173()
	for(var/mob/living/scp/scp173/scp in view(observation_range, src))
		if(scp.stat != DEAD)
			if(!(src in scp.scp173_observers))
				scp.scp173_observers += src
			scp.is_being_observed = TRUE
			scp173_stared = TRUE
			return
	scp173_stared = FALSE

/mob/living/simple_animal/scp131/proc/process_bond_decay()
	if(!bonded_friend_ref)
		return
	bond_strength = max(0, bond_strength - bond_decay_rate)
	if(bond_strength <= 0)
		bonded_friend_ref = null

/mob/living/simple_animal/scp131/proc/get_bonded_friend()
	if(!bonded_friend_ref)
		return null
	var/datum/weakref/ref = bonded_friend_ref
	var/mob/M = ref.resolve()
	if(!M || M.stat == DEAD)
		bonded_friend_ref = null
		bond_strength = 0
		return null
	return M

/mob/living/simple_animal/scp131/proc/bond_with(mob/living/carbon/human/H)
	if(!H || H.SCP)
		return
	bonded_friend_ref = WEAKREF(H)
	bond_strength = min(max_bond, bond_strength + bond_gain_per_interact)

/mob/living/simple_animal/scp131/proc/process_panic()
	if(client || stat == DEAD)
		return

	if(is_panicking)
		var/mob/living/carbon/human/friend = get_bonded_friend()
		if(!friend || friend.stat == DEAD || get_dist(src, friend) > 10)
			if(world.time > panic_cooldown)
				panic_cooldown = world.time + 3 SECONDS
				playsound(src, pick(panic_sounds), 30, TRUE)
				var/turf/T = get_step(src, pick(GLOB.alldirs))
				if(T)
					Move(T)
		else
			is_panicking = FALSE
		return

	var/mob/living/carbon/human/friend = get_bonded_friend()
	if(!friend || friend.stat == DEAD)
		return

	if(friend.health < friend.maxHealth * 0.5)
		is_panicking = TRUE
		visible_message(span_warning("[src] starts chirping frantically!"))

/mob/living/simple_animal/scp131/attack_hand(mob/living/carbon/human/user)
	. = ..()

	if(!user.combat_mode)
		say(get_babble())
		bond_with(user)
		hook_scp_interaction(user, "SCP-131", INTERACTION_TYPE_CARE)
		if(user.reagents)
			user.reagents.add_reagent(/datum/reagent/medicine/anomalous_happiness, 1)
		to_chat(user, span_notice("[src] seems happy to see you!"))

/mob/living/simple_animal/scp131/death(gibbed, cause_of_death = "Unknown")
	scp173_stared = FALSE
	visible_message("<span class='danger'>[src] closes its eye and goes still!</span>")
	hook_scp_recontainment("SCP-131", list())
	..()

/mob/living/simple_animal/scp131/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A teardrop-shaped creature with a single large eye. Its gaze is intense and unwavering."))
	var/mob/living/carbon/human/friend = get_bonded_friend()
	if(friend)
		to_chat(user, span_notice("It seems particularly attached to [friend]."))

/mob/living/simple_animal/scp131/get_status_tab_items()
	. = ..()
	var/mob/living/carbon/human/friend = get_bonded_friend()
	. += "Bonded Friend: [friend ? friend.name : "None"]"
	. += "Bond Strength: [bond_strength]/[max_bond]"
	. += "SCP-173 Stared: [scp173_stared]"

/mob/living/simple_animal/scp131/a
	name = "SCP-131-A"
	desc = "A small, teardrop-shaped creature with a single large blue eye. It is orange in color and makes soft babbling noises."
	icon_state = "scp131a"
	icon_living = "scp131a"
	icon_dead = "scp131a_dead"
	speak_emote = list("babbles", "coos", "burbles")
	emote_hear = list("babbles softly", "coos", "makes baby-like sounds")
	emote_see = list("looks around curiously", "blinks its large eye", "wobbles slightly")
	babble_cooldown_time = 10 SECONDS

/mob/living/simple_animal/scp131/a/get_babble()
	return pick("Babu!", "Bah!", "Bwee!", "Mmu?")

/mob/living/simple_animal/scp131/b
	name = "SCP-131-B"
	desc = "A small, teardrop-shaped creature with a single large green eye. It is brownish-green in color and slightly larger than its partner."
	icon_state = "scp131b"
	icon_living = "scp131b"
	icon_dead = "scp131b_dead"
	health = 60
	maxHealth = 60
	speak_emote = list("babbles", "murmurs", "chirps")
	emote_hear = list("babbles softly", "murmurs", "makes baby-like sounds")
	emote_see = list("looks around alertly", "blinks its large eye", "shifts its weight")
	babble_cooldown_time = 12 SECONDS
	observation_range = 7

/mob/living/simple_animal/scp131/b/get_babble()
	return pick("Bweh!", "Mrrp!", "Bah!", "Wuu?")
