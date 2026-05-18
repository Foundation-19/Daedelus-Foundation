/mob/living/simple_animal/hostile/anomalous_fauna
	name = "anomalous entity"
	desc = "A strange creature of unknown origin."
	icon = 'icons/mob/carp.dmi'
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/food/meat/slab/anomalous = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	harm_intent_damage = 8
	obj_damage = 50
	faction = list("anomalous")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	var/scp_designation = ""

/obj/item/food/meat/slab/anomalous
	name = "anomalous meat"
	desc = "Meat from an anomalous creature. Consuming it is not recommended."
	icon_state = "meat"
	slab_color = "#8020C0"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/medicine/tricordrazine = 2)

/mob/living/simple_animal/hostile/anomalous_fauna/void_crawler
	name = "void crawler"
	desc = "A pale, eyeless creature that seems to phase in and out of visibility. Its mandibles drip with an unknown substance."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	maxHealth = 40
	health = 40
	melee_damage_lower = 15
	melee_damage_upper = 22
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	speak_emote = list("chitters")
	scp_designation = "FAUNA-001"
	color = "#c0c0e0"
	alpha = 200
	move_to_delay = 2
	butcher_results = list(/obj/item/food/meat/slab/anomalous = 2, /obj/item/stack/sheet/bone = 1)

/mob/living/simple_animal/hostile/anomalous_fauna/void_crawler/Life(delta_time, times_fired)
	. = ..()
	if(prob(10))
		alpha = rand(100, 255)

/mob/living/simple_animal/hostile/anomalous_fauna/thermal_wraith
	name = "thermal wraith"
	desc = "A shimmering humanoid figure wreathed in heat distortion. The air around it warps and burns."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	maxHealth = 80
	health = 80
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_verb_continuous = "burns"
	attack_verb_simple = "burn"
	attack_sound = 'sound/items/welder.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	speak_emote = list("crackles")
	scp_designation = "FAUNA-002"
	color = "#ff6633"
	move_to_delay = 4
	butcher_results = list(/obj/item/food/meat/slab/anomalous = 3, /obj/item/stack/sheet/mineral/plasma = 1)
	resistance_flags = FIRE_PROOF

/mob/living/simple_animal/hostile/anomalous_fauna/thermal_wraith/AttackingTarget(atom/attacked_target)
	. = ..()
	if(iscarbon(attacked_target))
		var/mob/living/carbon/C = attacked_target
		C.adjust_fire_stacks(2)
		C.ignite_mob()

/mob/living/simple_animal/hostile/anomalous_fauna/shadow_stalker
	name = "shadow stalker"
	desc = "A mass of darkness with too many limbs. It seems to absorb the light around it."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	maxHealth = 60
	health = 60
	melee_damage_lower = 18
	melee_damage_upper = 25
	attack_verb_continuous = "rends"
	attack_verb_simple = "rend"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	speak_emote = list("whispers")
	scp_designation = "FAUNA-003"
	color = "#222222"
	move_to_delay = 2
	butcher_results = list(/obj/item/food/meat/slab/anomalous = 2)

/mob/living/simple_animal/hostile/anomalous_fauna/shadow_stalker/Life(delta_time, times_fired)
	. = ..()
	if(prob(5) && length(GLOB.mob_living_list))
		var/list/turfs = list()
		for(var/turf/open/floor/T in orange(5, src))
			var/dark = TRUE
			for(var/obj/machinery/light/L in range(3, T))
				if(L.on)
					dark = FALSE
					break
			if(dark)
				turfs += T
		if(length(turfs))
			var/turf/target = pick(turfs)
			forceMove(target)

/mob/living/simple_animal/hostile/anomalous_fauna/crystal_geode
	name = "crystal geode"
	desc = "A living formation of anomalous crystals. It pulses with an inner light and its edges are razor-sharp."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 25
	melee_damage_upper = 35
	attack_verb_continuous = "impales"
	attack_verb_simple = "impale"
	attack_sound = 'sound/weapons/pierce.ogg'
	attack_vis_effect = ATTACK_EFFECT_DISARM
	speak_emote = list("resonates")
	scp_designation = "FAUNA-004"
	color = "#7744cc"
	move_to_delay = 5
	butcher_results = list(/obj/item/food/meat/slab/anomalous = 2, /obj/item/stack/sheet/mineral/diamond = 1)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 40, BULLET = 40, LASER = 20, ENERGY = 20, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)

/mob/living/simple_animal/hostile/anomalous_fauna/aberrant_hound
	name = "aberrant hound"
	desc = "A quadrupedal creature with too many eyes and a jaw that splits in three. It drools a glowing viscous fluid."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	attack_verb_continuous = "mauls"
	attack_verb_simple = "maul"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("growls")
	scp_designation = "FAUNA-005"
	color = "#446633"
	move_to_delay = 2
	butcher_results = list(/obj/item/food/meat/slab/anomalous = 3)

/mob/living/simple_animal/hostile/anomalous_fauna/aberrant_hound/Initialize(mapload)
	. = ..()
	name = "[pick(list("Shadow", "Rot", "Blight", "Gnash", "Venom", "Fester", "Rift", "Grisk"))] [pick(list("Hound", "Maw", "Fang", "Lurker"))]"

/mob/living/simple_animal/hostile/anomalous_fauna/mass_aberrant_hound
	name = "massive aberrant hound"
	desc = "An enormous version of the aberrant hound. Its three jaws snap independently and its many eyes track multiple targets."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	maxHealth = 150
	health = 150
	melee_damage_lower = 30
	melee_damage_upper = 40
	attack_verb_continuous = "savages"
	attack_verb_simple = "savage"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("roars")
	scp_designation = "FAUNA-005-ALPHA"
	color = "#335522"
	move_to_delay = 3
	pixel_x = -16
	butcher_results = list(/obj/item/food/meat/slab/anomalous = 5, /obj/item/stack/sheet/bone = 2)
	armor = list(MELEE = 30, BULLET = 30, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 0, ACID = 0)

/obj/structure/spawner/anomalous_nest
	name = "anomalous rift"
	desc = "A shimmering tear in reality. Something keeps crawling out of it."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"
	max_integrity = 150
	max_mobs = 4
	spawn_time = 300
	mob_types = list(/mob/living/simple_animal/hostile/anomalous_fauna/void_crawler)
	spawn_text = "crawls out of"
	faction = list("anomalous")
