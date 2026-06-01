// SCP-280 - Eyes in the Dark
// A shadowy humanoid that moves through darkness and attacks in light

/mob/living/simple_animal/hostile/scp280
	name = "Eyes in the Dark"
	desc = "A shadowy humanoid figure. Its eyes glow faintly in the darkness."
	icon = 'icons/scp/scp-280.dmi'
	icon_state = "scp_280"
	icon_living = "scp280"
	icon_dead = "scp280_dead"
	health = 200
	maxHealth = 200
	density = FALSE
	anchored = FALSE
	movement_type = FLYING
	melee_damage_lower = 20
	melee_damage_upper = 35
	attack_sound = 'sound/weapons/slash.ogg'
	faction = list("SCP")
	sight = SEE_SELF

	var/datum/scp280_shadow_system/shadow_system
	var/datum/scp280_combat_system/combat_system
	var/datum/scp280_research_system/research_system

	var/kills = 0
	var/lights_destroyed = 0
	var/teleports = 0

/mob/living/simple_animal/hostile/scp280/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "Eyes in the Dark", SCP_EUCLID, "280")

	shadow_system = new /datum/scp280_shadow_system(src)
	combat_system = new /datum/scp280_combat_system(src)
	research_system = new /datum/scp280_research_system(src)

/mob/living/simple_animal/hostile/scp280/Destroy()
	QDEL_NULL(shadow_system)
	QDEL_NULL(combat_system)
	QDEL_NULL(research_system)
	return ..()

/mob/living/simple_animal/hostile/scp280/Life()
	. = ..()
	if(stat == DEAD)
		return

	if(shadow_system)
		shadow_system.process_shadow()

	if(combat_system)
		combat_system.process_combat()

/mob/living/simple_animal/hostile/scp280/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		hook_scp_combat(L, "SCP-280", melee_damage_upper, 0)

/mob/living/simple_animal/hostile/scp280/death(gibbed, cause_of_death = "Unknown")
	hook_scp_recontainment("SCP-280", list())
	return ..()

/mob/living/simple_animal/hostile/scp280/examine(mob/user)
	. = ..()
	to_chat(user, span_warning("A shadowy entity that moves through darkness. Its eyes gleam malevolently."))

/mob/living/simple_animal/hostile/scp280/proc/on_light_exposure()
	if(shadow_system)
		shadow_system.flee_from_light()

/datum/scp280_shadow_system
	var/mob/living/simple_animal/hostile/parent
	var/shadow_strength = 100
	var/light_sensitivity = 50
	var/teleport_cooldown = 0
	var/teleport_delay = 100

/datum/scp280_shadow_system/New(mob/living/simple_animal/hostile/P)
	parent = P

/datum/scp280_shadow_system/proc/process_shadow()
	if(!parent)
		return

	var/turf/T = get_turf(parent)
	var/light_level = T.get_lumcount() * 100

	if(light_level > light_sensitivity)
		if(teleport_cooldown <= world.time)
			teleport_to_darkness()
	else
		shadow_strength = min(100, shadow_strength + 1)

/datum/scp280_shadow_system/proc/teleport_to_darkness()
	if(!parent)
		return

	var/list/dark_turfs = list()
	for(var/turf/T in range(20, parent))
		if(T.get_lumcount() * 100 < 20)
			dark_turfs += T

	if(length(dark_turfs) > 0)
		var/turf/target = pick(dark_turfs)
		parent.visible_message(span_warning("[parent] dissolves into shadows!"))
		parent.forceMove(target)
		parent.visible_message(span_warning("[parent] emerges from the darkness!"))
		teleport_cooldown = world.time + teleport_delay
		hook_scp_interaction(parent, "SCP-280", INTERACTION_TYPE_CONTAINMENT)

/datum/scp280_shadow_system/proc/flee_from_light()
	if(teleport_cooldown <= world.time)
		teleport_to_darkness()

/datum/scp280_combat_system
	var/mob/living/simple_animal/hostile/parent
	var/aggression_level = 50
	var/max_aggression = 100
	var/light_damage_bonus = 1.5

/datum/scp280_combat_system/New(mob/living/simple_animal/hostile/P)
	parent = P

/datum/scp280_combat_system/proc/process_combat()
	if(!parent)
		return

	var/turf/T = get_turf(parent)
	if(T.get_lumcount() * 100 >= 20)
		parent.melee_damage_lower = initial(parent.melee_damage_lower) * light_damage_bonus
		parent.melee_damage_upper = initial(parent.melee_damage_upper) * light_damage_bonus
	else
		parent.melee_damage_lower = initial(parent.melee_damage_lower)
		parent.melee_damage_upper = initial(parent.melee_damage_upper)

	if(parent.target)
		aggression_level = min(max_aggression, aggression_level + 1)

/datum/scp280_research_system
	var/mob/living/simple_animal/hostile/parent
	var/list/attack_log = list()
	var/light_exposure_events = 0

/datum/scp280_research_system/New(mob/living/simple_animal/hostile/P)
	parent = P

/datum/scp280_research_system/proc/log_attack(mob/victim)
	attack_log["[world.time]"] = list("victim" = victim?.ckey)
