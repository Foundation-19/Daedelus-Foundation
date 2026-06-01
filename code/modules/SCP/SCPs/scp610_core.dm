// SCP-610 - The Hideous Without (Overhaul)
// Port of DS13-2.0 Marker/Corruption/Biomass systems adapted for SCP-610
// Core object acts as hive mind, ghost players control via camera mobs,
// corruption spreads as flesh creep, biomass economy drives growth

// ============================================================================
// TURF VAR
// ============================================================================

/turf
	var/scp610_corrupted = FALSE

/turf/proc/is_scp610_corrupted()
	return scp610_corrupted

// ============================================================================
// ITEM VAR
// ============================================================================

/obj/item
	var/biomass_value = 0

/obj/item/food/biomass_value = 5
/obj/item/food/meat/biomass_value = 10
/obj/item/food/grown/biomass_value = 3
/obj/item/organ/biomass_value = 15
/obj/item/bodypart/biomass_value = 12

/proc/item_is_hot(obj/item/I)
	if(!I)
		return 0
	if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/W = I
		return W.welding ? 1 : 0
	if(istype(I, /obj/item/lighter))
		var/obj/item/lighter/L = I
		return L.lit ? 1 : 0
	if(istype(I, /obj/item/match))
		var/obj/item/match/M = I
		return M.burnt ? 0 : (M.lit ? 1 : 0)
	if(I.resistance_flags & ON_FIRE)
		return 1
	return 0

// ============================================================================
// SIGNALS
// ============================================================================

#define COMSIG_TURF_SCP610_CORRUPTED "comsig_turf_scp610_corrupted"
#define COMSIG_TURF_SCP610_UNCORRUPTED "comsig_turf_scp610_uncorrupted"

// ============================================================================
// DEFINES
// ============================================================================

#define SCP610_CREEP_GROW    1
#define SCP610_CREEP_SPREAD  2
#define SCP610_CREEP_DECAY   3
#define SCP610_CREEP_IDLE    4

#define SCP610_CORE_INACTIVE   0
#define SCP610_CORE_DORMANT    1
#define SCP610_CORE_ACTIVE     2
#define SCP610_CORE_EXPANDED   3
#define SCP610_CORE_CRITICAL   4

#define SCP610_CREEP_INTEGRITY_PER_SECOND 3
#define SCP610_CREEP_MAX_INTEGRITY 20
#define SCP610_CREEP_MIN_ALPHA 20
#define SCP610_CREEP_MAX_ALPHA 185
#define SCP610_CREEP_SPREAD_INTERVAL 2 SECONDS

#define SCP610_BIOMASS_BASELINE_INCOME 0.3
#define SCP610_BIOMASS_START_CORE 250
#define SCP610_BIOMASS_START_GHOST 50
#define SCP610_BIOMASS_SIGNAL_PERCENT 0.1

#define SCP610_HIVE_WILL_MAX 900
#define SCP610_HIVE_WILL_MAX_MASTER 4500
#define SCP610_HIVE_WILL_REGEN 1.5
#define SCP610_HIVE_WILL_REGEN_MASTER 3

#define SCP610_GHOST_JOIN_RANGE 7

// ============================================================================
// SUBSYSTEM
// ============================================================================

SUBSYSTEM_DEF(scp610)
	name = "SCP-610 Processing"
	wait = 2 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	flags = SS_NO_INIT

	var/list/cores = list()
	var/list/creep_to_process = list()
	var/list/structures_to_process = list()

/datum/controller/subsystem/scp610/stat_entry(msg)
	msg = "C:[length(cores)] Cr:[length(creep_to_process)] St:[length(structures_to_process)]"
	return ..()

/datum/controller/subsystem/scp610/fire(resumed = FALSE)
	var/current_tick = world.time

	for(var/obj/structure/scp610_core/core in cores)
		if(QDELETED(core))
			cores -= core
			continue
		core.process_biomass()

	var/list/current_creep = creep_to_process.Copy()
	creep_to_process.Cut()
	for(var/obj/structure/scp610_creep/creep in current_creep)
		if(QDELETED(creep))
			continue
		creep.process_spread(current_tick)

	var/list/current_structures = structures_to_process.Copy()
	structures_to_process.Cut()
	for(var/obj/structure/scp610_flesh_structure/structure in current_structures)
		if(QDELETED(structure))
			continue
		structure.process_growth()

// ============================================================================
// BIOMASS SOURCE DATUM
// ============================================================================

/datum/scp610_biomass_source
	var/remaining_mass = -1
	var/mass_per_tick = 1
	var/datum/source_datum = null
	var/obj/structure/scp610_core/master

/datum/scp610_biomass_source/New(obj/structure/scp610_core/core)
	master = core

/datum/scp610_biomass_source/proc/absorb_biomass(delta_time)
	var/amount = mass_per_tick * delta_time
	if(remaining_mass >= 0)
		amount = min(amount, remaining_mass)
		remaining_mass -= amount
		if(remaining_mass <= 0 && remaining_mass > -1)
			on_biomass_depletion()
	return amount

/datum/scp610_biomass_source/proc/on_biomass_depletion()
	if(master)
		master.remove_biomass_source(src)

/datum/scp610_biomass_source/Destroy()
	if(master)
		master.remove_biomass_source(src)
	master = null
	source_datum = null
	return ..()

/datum/scp610_biomass_source/baseline
	mass_per_tick = SCP610_BIOMASS_BASELINE_INCOME
	remaining_mass = -1

/datum/scp610_biomass_source/harvester
	mass_per_tick = 0
	remaining_mass = -1
	var/range = 7
	var/activated = FALSE
	var/activation_delay = 60 SECONDS
	var/activation_time = 0

/datum/scp610_biomass_source/harvester/New(obj/structure/scp610_core/core)
	..()
	activation_time = world.time + activation_delay

/datum/scp610_biomass_source/harvester/absorb_biomass(delta_time)
	if(!activated)
		if(world.time >= activation_time)
			activated = TRUE
		else
			return 0
	mass_per_tick = 0
	if(master && !QDELETED(master))
		var/turf/T = get_turf(master)
		if(T)
			for(var/obj/item/I in range(range, T))
				if(I.biomass_value > 0)
					mass_per_tick += I.biomass_value * 0.1
	return ..()

/datum/scp610_biomass_source/maw
	mass_per_tick = 0
	remaining_mass = -1
	var/accumulated_biomass = 0
	var/consumption_rate = 0.05

/datum/scp610_biomass_source/maw/absorb_biomass(delta_time)
	if(accumulated_biomass <= 0)
		return 0
	var/amount = min(accumulated_biomass * consumption_rate * delta_time, accumulated_biomass)
	accumulated_biomass -= amount
	return amount

/datum/scp610_biomass_source/maw/proc/add_biomass(amount)
	accumulated_biomass += amount

// ============================================================================
// FLESH NODE DATUM
// ============================================================================

/datum/scp610_flesh_node
	var/remaining_weed_amount = 25
	var/control_range = 5
	var/atom/parent = null
	var/obj/structure/scp610_core/core = null
	var/list/controlled_creep = list()

/datum/scp610_flesh_node/New(atom/parent_atom, obj/structure/scp610_core/marker)
	parent = parent_atom
	core = marker
	if(core)
		core.register_node(src)
	var/turf/T = get_turf(parent)
	if(T)
		core?.place_creep(T, src)

/datum/scp610_flesh_node/Destroy()
	if(core)
		core.unregister_node(src)
	for(var/obj/structure/scp610_creep/creep in controlled_creep)
		creep.on_master_delete()
	controlled_creep.Cut()
	parent = null
	core = null
	return ..()

/datum/scp610_flesh_node/proc/can_support_new_creep()
	return remaining_weed_amount > 0

/datum/scp610_flesh_node/proc/on_creep_created(obj/structure/scp610_creep/creep)
	remaining_weed_amount--
	controlled_creep += creep

/datum/scp610_flesh_node/proc/on_creep_destroyed(obj/structure/scp610_creep/creep)
	remaining_weed_amount++
	controlled_creep -= creep

/datum/scp610_flesh_node/proc/is_in_range(turf/T)
	if(!parent || !T)
		return FALSE
	return get_dist(get_turf(parent), T) <= control_range

/datum/scp610_flesh_node/atom_node
	remaining_weed_amount = 49
	control_range = 7

/datum/scp610_flesh_node/atom_node/core
	remaining_weed_amount = 49
	control_range = 7

// ============================================================================
// SCP-610 CORE (The Heart of the Flesh)
// ============================================================================

/obj/structure/scp610_core
	name = "SCP-610 Mass"
	desc = "A pulsating mass of flesh and bone. It radiates an aura of malice and disease. The heart of the infection."
	icon = 'icons/scp/newscp610/scp_610_structure_128x128.dmi'
	icon_state = "static"
	pixel_x = -48
	pixel_y = -48
	density = TRUE
	anchored = TRUE
	plane = GAME_PLANE
	layer = ABOVE_MOB_LAYER
	max_integrity = 500
	armor = list(BLUNT = 50, PUNCTURE = 50, SLASH = 50, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 100, FIRE = -50, ACID = 100)

	var/core_state = SCP610_CORE_INACTIVE
	var/obj/item/reagent_containers/glass/bottle/scp610/source_bottle = null

	var/core_biomass = 0
	var/ghost_biomass = 0
	var/biomass_invested = 0
	var/signal_biomass_percent = SCP610_BIOMASS_SIGNAL_PERCENT
	var/last_biomass_income = 0
	var/list/datum/scp610_biomass_source/biomass_sources = list()

	var/list/ghosts = list()
	var/list/flesh_mobs = list()
	var/list/datum/scp610_flesh_node/nodes = list()
	var/list/spawn_atoms = list()
	var/list/flesh_structures = list()

	var/datum/scp610_flesh_node/core_node = null
	var/last_process_time = 0
	var/spread_timer = 0

	var/hive_will = 0
	var/hive_will_max = SCP610_HIVE_WILL_MAX
	var/hive_will_regen = SCP610_HIVE_WILL_REGEN

	var/list/infected_mobs = list()
	var/total_infections = 0
	var/session_start_time = 0
	var/signal_biomass = 0
	var/cognitohazard_cost = 2
	var/cognitohazard_range = 10

/obj/structure/scp610_core/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "SCP-610", SCP_KETER, "610")
	session_start_time = world.time
	SSscp610.cores += src
	update_appearance()

/obj/structure/scp610_core/Destroy()
	SSscp610.cores -= src
	if(!length(SSscp610.cores))
		for(var/mob/dead/observer/O in GLOB.player_list)
			remove_verb(O, /mob/dead/observer/proc/join_scp610_hive)
	for(var/datum/scp610_flesh_node/node as anything in nodes)
		qdel(node)
	nodes.Cut()
	for(var/datum/scp610_biomass_source/source as anything in biomass_sources)
		qdel(source)
	biomass_sources.Cut()
	for(var/mob/camera/scp610_ghost/ghost as anything in ghosts)
		ghost.on_core_destroyed()
	ghosts.Cut()
	QDEL_NULL(core_node)
	QDEL_NULL(SCP)
	source_bottle = null
	return ..()

/obj/structure/scp610_core/update_appearance(updates=ALL)
	. = ..()
	switch(core_state)
		if(SCP610_CORE_INACTIVE)
			icon_state = "static"
			set_light(0)
		if(SCP610_CORE_DORMANT)
			icon_state = "static"
			set_light(2, 1, 1, 2, COLOR_RED)
		if(SCP610_CORE_ACTIVE)
			icon_state = "pulsing"
			set_light(4, 2, 2, 2, COLOR_RED)
		if(SCP610_CORE_EXPANDED)
			icon_state = "bursting"
			set_light(6, 3, 3, 2, COLOR_RED)
		if(SCP610_CORE_CRITICAL)
			icon_state = "burst"
			set_light(8, 4, 4, 2, COLOR_RED)

/obj/structure/scp610_core/proc/activate()
	if(core_state != SCP610_CORE_INACTIVE && core_state != SCP610_CORE_DORMANT)
		return
	core_state = SCP610_CORE_ACTIVE
	core_biomass = SCP610_BIOMASS_START_CORE
	ghost_biomass = SCP610_BIOMASS_START_GHOST
	add_biomass_source(/datum/scp610_biomass_source/baseline)
	add_biomass_source(/datum/scp610_biomass_source/harvester)
	core_node = new /datum/scp610_flesh_node/atom_node/core(src, src)
	spawn_atoms += src
	hook_scp_breach("SCP-610", src)
	update_appearance()
	notify_ghosts("SCP-610 has activated! The flesh hungers!", source = src, action = NOTIFY_JUMP)
	for(var/mob/dead/observer/O in GLOB.player_list)
		add_verb(O, /mob/dead/observer/proc/join_scp610_hive)

/obj/structure/scp610_core/proc/process_biomass()
	if(core_state < SCP610_CORE_ACTIVE)
		return
	last_biomass_income = 0
	for(var/datum/scp610_biomass_source/source as anything in biomass_sources)
		if(QDELETED(source))
			biomass_sources -= source
			continue
		var/income = source.absorb_biomass(2)
		last_biomass_income += income
		var/ghost_share = income * signal_biomass_percent
		var/core_share = income - ghost_share
		core_biomass += core_share
		ghost_biomass += ghost_share
		biomass_invested += income
	check_core_evolution()
	heal_nearby_flesh()
	regen_hive_will()
	tick_cognitohazard()

/obj/structure/scp610_core/proc/check_core_evolution()
	var/flesh_count = length(flesh_mobs) + length(flesh_structures)
	switch(core_state)
		if(SCP610_CORE_ACTIVE)
			if(biomass_invested >= 500 || flesh_count >= 5)
				core_state = SCP610_CORE_EXPANDED
				update_appearance()
				// Automated announcements removed - dispatch should announce SCP-610 expansions
				// priority_announce("SCP-610 biomass expansion detected in [get_area_name(src)]. Infection spreading.", "SCP Foundation Alert", null, ANNOUNCER_ALERT)
		if(SCP610_CORE_EXPANDED)
			if(biomass_invested >= 1500 || flesh_count >= 15)
				core_state = SCP610_CORE_CRITICAL
				update_appearance()
				// Automated announcements removed - dispatch should announce SCP-610 critical mass
				// priority_announce("SCP-610 has reached CRITICAL mass in [get_area_name(src)]. Full breach protocols authorized.", "SCP Foundation Alert", null, ANNOUNCER_ALERT)

/obj/structure/scp610_core/proc/heal_nearby_flesh()
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(7, src))
		if(F.stat != DEAD)
			F.adjustHealth(-5)
	for(var/mob/living/simple_animal/hostile/scp610_flesh_walker/W in range(7, src))
		if(W.stat != DEAD)
			W.adjustHealth(-5)

/obj/structure/scp610_core/proc/regen_hive_will()
	if(core_state < SCP610_CORE_ACTIVE)
		return
	var/regen = hive_will_regen
	if(length(ghosts) > 0)
		for(var/mob/camera/scp610_ghost/ghost as anything in ghosts)
			if(ghost.is_master)
				regen += SCP610_HIVE_WILL_REGEN_MASTER
				break
	hive_will = min(hive_will + regen, hive_will_max)
	if(core_state >= SCP610_CORE_EXPANDED)
		hive_will_max = SCP610_HIVE_WILL_MAX_MASTER

/obj/structure/scp610_core/proc/tick_cognitohazard()
	if(core_state < SCP610_CORE_ACTIVE)
		return
	if(signal_biomass < cognitohazard_cost)
		return
	var/strength_multiplier = clamp(core_biomass / 50, 0.1, 1.0)
	for(var/mob/living/carbon/human/H in range(cognitohazard_range, src))
		if(H.stat == DEAD)
			continue
		if(H.SCP)
			continue
		if(HAS_TRAIT(H, TRAIT_SCP610_IMMUNE))
			continue
		if(H.has_status_effect(/datum/status_effect/scp610_infection))
			continue
		var/distance = get_dist(src, get_turf(H))
		if(distance > cognitohazard_range || distance < 1)
			continue
		var/distance_ratio = distance / cognitohazard_range
		var/effective_chance = (1 - distance_ratio) * 15 * strength_multiplier
		if(!prob(effective_chance))
			continue
		if(signal_biomass < cognitohazard_cost)
			break
		var/accumulation_amount = 0
		if(distance <= 3)
			accumulation_amount = 8 * strength_multiplier
		else if(distance <= 7)
			accumulation_amount = 4 * strength_multiplier
		else
			accumulation_amount = 2 * strength_multiplier
		if(accumulation_amount > 0)
			H.apply_status_effect(/datum/status_effect/cognitohazard_exposure, accumulation_amount)
			signal_biomass -= cognitohazard_cost

/obj/structure/scp610_core/proc/use_hive_will(amount)
	if(hive_will < amount)
		return FALSE
	hive_will -= amount
	return TRUE

/obj/structure/scp610_core/proc/ability_flesh_mend()
	var/cost = 200
	if(!use_hive_will(cost))
		return FALSE
	visible_message(span_danger("[src] pulses with regenerative energy!"))
	for(var/mob/living/simple_animal/hostile/scp610_fleshman/F in range(10, src))
		if(F.stat != DEAD)
			F.adjustHealth(-50)
	for(var/mob/living/simple_animal/hostile/scp610_flesh_walker/W in range(10, src))
		if(W.stat != DEAD)
			W.adjustHealth(-50)
	for(var/obj/structure/scp610_flesh_structure/S in range(10, src))
		if(S != src)
			S.repair_damage(50)
	hive_mind_message("Hive Will", "Flesh Mend invoked. The flesh is restored.")
	return TRUE

/obj/structure/scp610_core/proc/ability_devouring_wave()
	var/cost = 300
	if(!use_hive_will(cost))
		return FALSE
	visible_message(span_danger("[src] unleashes a wave of grasping tendrils!"))
	for(var/mob/living/L in range(5, src))
		if(L.stat == DEAD || L.faction.Find("scp610"))
			continue
		L.adjustBruteLoss(15)
		L.Immobilize(3 SECONDS)
		L.visible_message(span_danger("[L] is grasped by tendrils from [src]!"), span_userdanger("Fleshy tendrils grip and tear at you!"))
	hive_mind_message("Hive Will", "Devouring Wave invoked. The flesh consumes.")
	return TRUE

/obj/structure/scp610_core/proc/ability_infest_burst()
	var/cost = 150
	if(!use_hive_will(cost))
		return FALSE
	visible_message(span_danger("[src] bursts with infectious spores!"))
	var/spread_count = 0
	for(var/turf/T in RANGE_TURFS(4, src))
		if(T.density || isspaceturf(T) || ischasm(T) || islava(T))
			continue
		var/obj/structure/scp610_creep/existing = locate() in T
		if(!existing)
			if(place_creep(T))
				spread_count++
			if(spread_count >= 12)
				break
	hive_mind_message("Hive Will", "Infest Burst invoked. The corruption spreads.")
	return TRUE

/obj/structure/scp610_core/proc/change_core_biomass(amount)
	core_biomass = max(0, core_biomass + amount)

/obj/structure/scp610_core/proc/change_ghost_biomass(amount)
	ghost_biomass = max(0, ghost_biomass + amount)

/obj/structure/scp610_core/proc/add_biomass_source(source_type, datum/source)
	var/datum/scp610_biomass_source/source_datum = new source_type(src)
	if(source)
		source_datum.source_datum = source
	biomass_sources += source_datum
	return source_datum

/obj/structure/scp610_core/proc/remove_biomass_source(datum/scp610_biomass_source/source)
	biomass_sources -= source
	qdel(source)

/obj/structure/scp610_core/proc/register_node(datum/scp610_flesh_node/node)
	nodes += node

/obj/structure/scp610_core/proc/unregister_node(datum/scp610_flesh_node/node)
	nodes -= node

/obj/structure/scp610_core/proc/find_node_for_turf(turf/T)
	var/datum/scp610_flesh_node/best_node = null
	var/best_dist = 999
	for(var/datum/scp610_flesh_node/node as anything in nodes)
		if(QDELETED(node) || !node.can_support_new_creep())
			continue
		if(node.is_in_range(T))
			var/d = get_dist(get_turf(node.parent), T)
			if(d < best_dist)
				best_dist = d
				best_node = node
	return best_node

/obj/structure/scp610_core/proc/place_creep(turf/T, datum/scp610_flesh_node/node)
	if(!istype(T) || T.density)
		return FALSE
	if(isspaceturf(T) || ischasm(T) || islava(T))
		return FALSE
	var/obj/structure/scp610_creep/existing = locate() in T
	if(existing)
		return FALSE
	if(!node)
		node = find_node_for_turf(T)
	if(!node || !node.can_support_new_creep())
		return FALSE
	var/obj/structure/scp610_creep/creep = new(T)
	creep.assign_master(node)
	SSscp610.creep_to_process += creep
	return TRUE

/obj/structure/scp610_core/proc/place_structure(structure_type, turf/T, mob/camera/scp610_ghost/placer)
	if(!istype(T))
		return FALSE
	var/obj/structure/scp610_creep/creep = locate() in T
	if(!creep)
		return FALSE
	var/static/list/structure_costs = list(
		/obj/structure/scp610_flesh_structure/nest = 110,
		/obj/structure/scp610_flesh_structure/growth_node = 40,
		/obj/structure/scp610_flesh_structure/eye = 15,
		/obj/structure/scp610_flesh_structure/cyst = 15,
		/obj/structure/scp610_flesh_structure/maw = 40,
		/obj/structure/scp610_flesh_structure/snare = 20,
		/obj/structure/scp610_flesh_structure/cluster = 60,
	)
	var/cost = structure_costs[structure_type] || 0
	if(placer?.is_master)
		if(core_biomass < cost)
			return FALSE
		core_biomass -= cost
	else
		if(ghost_biomass < cost)
			return FALSE
		ghost_biomass -= cost
	var/obj/structure/scp610_flesh_structure/structure = new structure_type(T)
	structure.core = src
	flesh_structures += structure
	SSscp610.structures_to_process += structure
	return TRUE

/obj/structure/scp610_core/proc/register_flesh_mob(mob/living/M)
	flesh_mobs += M

/obj/structure/scp610_core/proc/unregister_flesh_mob(mob/living/M)
	flesh_mobs -= M

/obj/structure/scp610_core/proc/register_ghost(mob/camera/scp610_ghost/ghost)
	ghosts += ghost

/obj/structure/scp610_core/proc/unregister_ghost(mob/camera/scp610_ghost/ghost)
	ghosts -= ghost

/obj/structure/scp610_core/proc/hive_mind_message(sender, message)
	var/formatted = span_deadsay("<b>\[SCP-610 Hive\] [sender]:</b> [message]")
	for(var/mob/camera/scp610_ghost/ghost as anything in ghosts)
		to_chat(ghost, formatted)
	for(var/mob/living/M as anything in flesh_mobs)
		if(M.client)
			to_chat(M, formatted)
	for(var/mob/dead/observer/O in GLOB.player_list)
		to_chat(O, formatted)

/obj/structure/scp610_core/attackby(obj/item/I, mob/living/user, params)
	if(item_is_hot(I) > 0)
		take_damage(30, BURN, FIRE)
		to_chat(user, span_danger("You burn [src]! The flesh recoils!"))
		return
	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = I
		if(RC.reagents?.has_reagent(/datum/reagent/water/holywater, 10))
			take_damage(50, BURN, FIRE)
			to_chat(user, span_danger("You splash holy water on [src]! It burns intensely!"))
			return
	return ..()

/obj/structure/scp610_core/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)
		playsound(src, 'sound/items/welder.ogg', 50, TRUE)
	else
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

/obj/structure/scp610_core/atom_break(damage_flag)
	..()
	core_state = SCP610_CORE_INACTIVE
	hook_scp_recontainment("SCP-610", list("method" = "destruction", "core_destroyed" = TRUE))
	visible_message(span_danger("[src] collapses into a pile of inert, decaying flesh!"))
	for(var/datum/scp610_flesh_node/node as anything in nodes)
		qdel(node)
	nodes.Cut()
	for(var/obj/structure/scp610_flesh_structure/structure as anything in flesh_structures)
		structure.enter_decay()
	for(var/mob/camera/scp610_ghost/ghost as anything in ghosts)
		to_chat(ghost, span_deadsay("The core has been destroyed! You are released."))
		ghost.on_core_destroyed()
	ghosts.Cut()
	if(source_bottle)
		source_bottle.containment_status = "contained"
	qdel(src)

/obj/structure/scp610_core/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	. += span_notice("Current state: ")
	switch(core_state)
		if(SCP610_CORE_INACTIVE)
			. += span_notice("Dormant. No active spread detected.")
		if(SCP610_CORE_DORMANT)
			. += span_warning("Stirring. The flesh is beginning to awaken.")
		if(SCP610_CORE_ACTIVE)
			. += span_danger("ACTIVE. The flesh is spreading!")
		if(SCP610_CORE_EXPANDED)
			. += span_userdanger("EXPANDED. Biomass is growing rapidly!")
		if(SCP610_CORE_CRITICAL)
			. += span_userdanger("CRITICAL MASS. Full breach protocols required!")
	. += span_notice("Core biomass: [round(core_biomass)] | Ghost biomass: [round(ghost_biomass)]")
	. += span_notice("Flesh creatures: [length(flesh_mobs)] | Structures: [length(flesh_structures)]")

// ============================================================================
// FLESH CREEP (Spreading Corruption)
// ============================================================================

/obj/structure/scp610_creep
	name = "flesh creep"
	desc = "A creeping mass of flesh and sinew. It pulses with unnatural life."
	icon = 'icons/scp/newscp610/flesh_tile.dmi'
	icon_state = "flesh_tile-0"
	layer = TURF_LAYER
	plane = GAME_PLANE
	density = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = SCP610_CREEP_MIN_ALPHA
	max_integrity = SCP610_CREEP_MAX_INTEGRITY
	armor = list(BLUNT = 75, PUNCTURE = 75, SLASH = 75, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = -100, ACID = 100)
	resistance_flags = UNACIDABLE

	var/datum/scp610_flesh_node/master_node = null
	var/state = SCP610_CREEP_GROW
	var/dirs_to_spread = 0
	var/last_spread_time = 0
	var/turf/my_turf = null

/obj/structure/scp610_creep/Initialize()
	. = ..()
	my_turf = get_turf(src)
	if(my_turf)
		my_turf.scp610_corrupted = TRUE
		SEND_SIGNAL(my_turf, COMSIG_TURF_SCP610_CORRUPTED)
	update_dirs_to_spread()
	update_appearance()

/obj/structure/scp610_creep/Destroy()
	if(master_node)
		master_node.on_creep_destroyed(src)
		master_node = null
	if(my_turf)
		var/obj/structure/scp610_creep/other = locate() in my_turf
		if(!other || other == src)
			my_turf.scp610_corrupted = FALSE
			SEND_SIGNAL(my_turf, COMSIG_TURF_SCP610_UNCORRUPTED)
	my_turf = null
	return ..()

/obj/structure/scp610_creep/proc/assign_master(datum/scp610_flesh_node/new_node)
	if(master_node == new_node)
		return
	if(master_node)
		master_node.on_creep_destroyed(src)
	master_node = new_node
	if(master_node)
		master_node.on_creep_created(src)
	if(!master_node)
		state = SCP610_CREEP_DECAY

/obj/structure/scp610_creep/proc/on_master_delete()
	master_node = null
	if(!find_new_master())
		state = SCP610_CREEP_DECAY

/obj/structure/scp610_creep/proc/find_new_master()
	if(!my_turf)
		return FALSE
	var/obj/structure/scp610_core/core = locate() in range(20, src)
	if(!core)
		return FALSE
	var/datum/scp610_flesh_node/node = core.find_node_for_turf(my_turf)
	if(node)
		assign_master(node)
		state = SCP610_CREEP_GROW
		return TRUE
	return FALSE

/obj/structure/scp610_creep/proc/update_dirs_to_spread()
	dirs_to_spread = 0
	if(!my_turf)
		return
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(my_turf, dir)
		if(!neighbor || !istype(neighbor) || neighbor.density)
			continue
		if(isspaceturf(neighbor) || ischasm(neighbor) || islava(neighbor))
			continue
		if(locate(/obj/structure/scp610_creep) in neighbor)
			continue
		dirs_to_spread |= dir

/obj/structure/scp610_creep/proc/process_spread(current_tick)
	switch(state)
		if(SCP610_CREEP_GROW)
			var/integrity_percent = atom_integrity / max_integrity
			alpha = SCP610_CREEP_MIN_ALPHA + (SCP610_CREEP_MAX_ALPHA - SCP610_CREEP_MIN_ALPHA) * integrity_percent
			repair_damage(SCP610_CREEP_INTEGRITY_PER_SECOND * 2)
			if(atom_integrity >= max_integrity)
				state = SCP610_CREEP_SPREAD
				update_dirs_to_spread()
		if(SCP610_CREEP_SPREAD)
			if(!master_node || !master_node.core)
				state = SCP610_CREEP_DECAY
				return
			if(current_tick < last_spread_time + SCP610_CREEP_SPREAD_INTERVAL)
				return
			if(!dirs_to_spread)
				state = SCP610_CREEP_IDLE
				return
			if(!master_node.can_support_new_creep())
				return
			var/list/possible_dirs = list()
			for(var/dir in GLOB.cardinals)
				if(dirs_to_spread & dir)
					possible_dirs += dir
			if(!length(possible_dirs))
				state = SCP610_CREEP_IDLE
				return
			var/spread_dir = pick(possible_dirs)
			var/turf/target = get_step(my_turf, spread_dir)
			if(target && master_node.is_in_range(target))
				master_node.core.place_creep(target, master_node)
			last_spread_time = current_tick
			update_dirs_to_spread()
		if(SCP610_CREEP_DECAY)
			take_damage(SCP610_CREEP_INTEGRITY_PER_SECOND * 2, BURN, FIRE)
			if(atom_integrity <= 0)
				qdel(src)
				return
			var/integrity_percent = atom_integrity / max_integrity
			alpha = SCP610_CREEP_MIN_ALPHA * integrity_percent
		if(SCP610_CREEP_IDLE)
			update_dirs_to_spread()
			if(dirs_to_spread)
				state = SCP610_CREEP_SPREAD

/obj/structure/scp610_creep/update_appearance(updates=ALL)
	. = ..()
	if(!my_turf)
		return
	var/connections = 0
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(my_turf, dir)
		if(neighbor && (locate(/obj/structure/scp610_creep) in neighbor))
			connections |= dir
	switch(connections)
		if(0)
			icon_state = "flesh_tile-0"
		if(NORTH)
			icon_state = "flesh_tile-1"
		if(SOUTH)
			icon_state = "flesh_tile-4"
		if(EAST)
			icon_state = "flesh_tile-16"
		if(WEST)
			icon_state = "flesh_tile-64"
		if(NORTH|SOUTH)
			icon_state = "flesh_tile-5"
		if(EAST|WEST)
			icon_state = "flesh_tile-80"
		if(NORTH|EAST)
			icon_state = "flesh_tile-17"
		if(NORTH|WEST)
			icon_state = "flesh_tile-65"
		if(SOUTH|EAST)
			icon_state = "flesh_tile-20"
		if(SOUTH|WEST)
			icon_state = "flesh_tile-68"
		if(NORTH|SOUTH|EAST)
			icon_state = "flesh_tile-21"
		if(NORTH|SOUTH|WEST)
			icon_state = "flesh_tile-69"
		if(NORTH|EAST|WEST)
			icon_state = "flesh_tile-81"
		if(SOUTH|EAST|WEST)
			icon_state = "flesh_tile-84"
		if(NORTH|SOUTH|EAST|WEST)
			icon_state = "flesh_tile-85"
		else
			icon_state = "flesh_tile-[connections]"

/obj/structure/scp610_creep/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(L.stat == DEAD)
		return
	if(L.faction.Find("scp610"))
		return
	if(istype(L, /mob/living/simple_animal/hostile/scp610_fleshman) || istype(L, /mob/living/simple_animal/hostile/scp610_flesh_walker))
		return
	if(prob(5))
		scp610_infect(L, 5)

/obj/structure/scp610_creep/attackby(obj/item/I, mob/living/user, params)
	if(item_is_hot(I) > 0)
		take_damage(50, BURN, FIRE)
		to_chat(user, span_danger("You burn the flesh away!"))
		return TRUE
	return ..()

/obj/structure/scp610_creep/bullet_act(obj/projectile/P)
	if(P.damage_type == BURN)
		take_damage(P.damage * 2, BURN, FIRE)
	else
		take_damage(P.damage * 0.25, P.damage_type)
	return BULLET_ACT_HIT

// ============================================================================
// FLESH STRUCTURES (Base + Subtypes)
// ============================================================================

/obj/structure/scp610_flesh_structure
	name = "flesh structure"
	desc = "An organic structure grown from SCP-610 biomass."
	icon = 'icons/scp/newscp610/structure.dmi'
	density = FALSE
	anchored = TRUE
	max_integrity = 100
	armor = list(BLUNT = 75, PUNCTURE = 75, SLASH = 75, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = -100, ACID = 100)

	var/obj/structure/scp610_core/core = null
	var/state = SCP610_CREEP_GROW
	var/cost = 0
	var/marker_only = FALSE
	var/can_place_in_sight = FALSE
	var/require_wall = FALSE
	var/same_distance = 0

/obj/structure/scp610_flesh_structure/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	var/obj/structure/scp610_creep/creep = locate() in T
	if(creep)
		state = SCP610_CREEP_GROW
	else
		state = SCP610_CREEP_DECAY

/obj/structure/scp610_flesh_structure/Destroy()
	if(core)
		core.flesh_structures -= src
	core = null
	return ..()

/obj/structure/scp610_creep/proc/enter_decay()
	state = SCP610_CREEP_DECAY

/obj/structure/scp610_flesh_structure/proc/enter_decay()
	state = SCP610_CREEP_DECAY

/obj/structure/scp610_flesh_structure/proc/process_growth()
	switch(state)
		if(SCP610_CREEP_GROW)
			repair_damage(3)
		if(SCP610_CREEP_DECAY)
			take_damage(3, BURN, FIRE)
			if(atom_integrity <= 0)
				qdel(src)

/obj/structure/scp610_flesh_structure/attackby(obj/item/I, mob/living/user, params)
	if(item_is_hot(I) > 0)
		take_damage(40, BURN, FIRE)
		to_chat(user, span_danger("You burn the flesh structure!"))
		return TRUE
	return ..()

// --- Flesh Nest (Spawner) ---
/obj/structure/scp610_flesh_structure/nest
	name = "flesh nest"
	desc = "A pulsating organic mass that seems to birth flesh creatures."
	icon_state = "nest"
	density = TRUE
	max_integrity = 200
	cost = 110
	marker_only = TRUE
	var/spawn_timer = null
	var/spawn_cooldown = 300 SECONDS
	var/max_spawned = 2
	var/list/spawned_mobs = list()

/obj/structure/scp610_flesh_structure/nest/Initialize()
	. = ..()
	start_spawning()

/obj/structure/scp610_flesh_structure/nest/Destroy()
	deltimer(spawn_timer)
	for(var/mob/M as anything in spawned_mobs)
		if(!QDELETED(M))
			unregister_spawned(M)
	return ..()

/obj/structure/scp610_flesh_structure/nest/proc/start_spawning()
	spawn_timer = addtimer(CALLBACK(src, PROC_REF(try_spawn)), spawn_cooldown, TIMER_LOOP | TIMER_UNIQUE)

/obj/structure/scp610_flesh_structure/nest/proc/try_spawn()
	if(state == SCP610_CREEP_DECAY || !core || QDELETED(core))
		return
	clean_spawned_list()
	if(length(spawned_mobs) >= max_spawned)
		return
	var/turf/T = get_turf(src)
	var/mob/living/spawned
	if(prob(60))
		spawned = new /mob/living/simple_animal/hostile/scp610_fleshman(T)
	else
		spawned = new /mob/living/simple_animal/hostile/scp610_flesh_walker(T)
	if(spawned && core)
		core.register_flesh_mob(spawned)
		spawned_mobs += spawned
		RegisterSignal(spawned, COMSIG_PARENT_QDELETING, PROC_REF(on_spawned_deleted))

/obj/structure/scp610_flesh_structure/nest/proc/clean_spawned_list()
	for(var/mob/M as anything in spawned_mobs)
		if(QDELETED(M))
			spawned_mobs -= M

/obj/structure/scp610_flesh_structure/nest/proc/on_spawned_deleted(mob/source)
	SIGNAL_HANDLER
	unregister_spawned(source)

/obj/structure/scp610_flesh_structure/nest/proc/unregister_spawned(mob/M)
	spawned_mobs -= M
	if(core)
		core.unregister_flesh_mob(M)
	UnregisterSignal(M, COMSIG_PARENT_QDELETING)

// --- Flesh Maw (Body Consumer) ---
/obj/structure/scp610_flesh_structure/maw
	name = "flesh maw"
	desc = "A gaping maw in the floor, lined with teeth. It hungers."
	icon_state = "maw"
	density = FALSE
	max_integrity = 150
	cost = 40
	marker_only = TRUE
	same_distance = 1
	var/consume_delay = 3 SECONDS
	var/biomass_per_body = 50
	var/datum/scp610_biomass_source/maw/biomass_source = null

/obj/structure/scp610_flesh_structure/maw/Initialize()
	. = ..()
	if(core)
		biomass_source = core.add_biomass_source(/datum/scp610_biomass_source/maw)

/obj/structure/scp610_flesh_structure/maw/Crossed(atom/movable/AM)
	. = ..()
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.biomass_value > 0)
			if(biomass_source)
				biomass_source.add_biomass(I.biomass_value)
			qdel(I)
			return
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(L.faction.Find("scp610"))
		return
	if(L.stat == DEAD)
		consume_body(L)
		return
	if(!L.buckled)
		L.buckled = src
		L.visible_message(span_danger("[L] is grabbed by [src]!"), span_userdanger("[src] grabs you!"))
		addtimer(CALLBACK(src, PROC_REF(consume_victim), L), consume_delay)

/obj/structure/scp610_flesh_structure/maw/proc/consume_victim(mob/living/victim)
	if(QDELETED(victim) || QDELETED(src))
		return
	if(!victim.buckled || victim.buckled != src)
		return
	victim.adjustBruteLoss(20)
	if(victim.stat == DEAD || victim.health <= 0)
		consume_body(victim)
	else
		addtimer(CALLBACK(src, PROC_REF(consume_victim), victim), consume_delay)

/obj/structure/scp610_flesh_structure/maw/proc/consume_body(mob/living/body)
	if(QDELETED(body))
		return
	if(biomass_source)
		biomass_source.add_biomass(biomass_per_body)
	if(core)
		core.total_infections++
	body.visible_message(span_danger("[src] consumes [body]!"))
	qdel(body)

// --- Flesh Growth Node (Extends Spread) ---
/obj/structure/scp610_flesh_structure/growth_node
	name = "flesh node"
	desc = "A thick mass of flesh that pulses with energy. The corruption spreads from here."
	icon = 'icons/scp/newscp610/scp_610_structure.dmi'
	icon_state = "flesh_pillar"
	density = TRUE
	max_integrity = 150
	cost = 40
	var/datum/scp610_flesh_node/node = null

/obj/structure/scp610_flesh_structure/growth_node/Initialize()
	. = ..()
	if(core)
		node = new /datum/scp610_flesh_node/atom_node(src, core)

/obj/structure/scp610_flesh_structure/growth_node/Destroy()
	QDEL_NULL(node)
	return ..()

/obj/structure/scp610_flesh_structure/growth_node/process_growth()
	..()
	if(state == SCP610_CREEP_GROW)
		icon_state = "flesh_pillar_idle"
	else if(state == SCP610_CREEP_DECAY)
		icon_state = "flesh_pillar_attack"

// --- Flesh Eye (Surveillance) ---
/obj/structure/scp610_flesh_structure/eye
	name = "flesh eye"
	desc = "A fleshy stalk with a single unblinking eye. It watches."
	icon = 'icons/scp/newscp610/scp_610_32x32.dmi'
	icon_state = "eyeball"
	density = FALSE
	max_integrity = 50
	cost = 15
	can_place_in_sight = TRUE
	var/detection_range = 4
	var/alert_cooldown = 60 SECONDS
	var/last_alert = 0

/obj/structure/scp610_flesh_structure/eye/process_growth()
	..()
	if(state != SCP610_CREEP_GROW)
		return
	if(world.time < last_alert + alert_cooldown)
		return
	for(var/mob/living/carbon/human/H in range(detection_range, src))
		if(H.stat == DEAD || H.faction.Find("scp610"))
			continue
		if(core)
			core.hive_mind_message("Flesh Eye", "Intruder detected near [get_area_name(src)]!")
		last_alert = world.time
		icon_state = "eyeball_blink"
		addtimer(CALLBACK(src, PROC_REF(refresh_icon)), 1 SECONDS)
		break

/obj/structure/scp610_flesh_structure/eye/proc/refresh_icon()
	icon_state = "eyeball"

// --- Flesh Cyst (Trap) ---
/obj/structure/scp610_flesh_structure/cyst
	name = "flesh cyst"
	desc = "A swollen cyst on the wall. It looks ready to burst."
	icon = 'icons/scp/newscp610/scp_610_32x32.dmi'
	icon_state = "spikes_idle"
	density = FALSE
	max_integrity = 60
	cost = 15
	require_wall = TRUE
	same_distance = 2
	var/fire_cooldown = 8 SECONDS
	var/last_fire = 0
	var/damage = 25

/obj/structure/scp610_flesh_structure/cyst/process_growth()
	..()
	if(state != SCP610_CREEP_GROW)
		return
	if(world.time < last_fire + fire_cooldown)
		return
	var/list/targets = list()
	for(var/mob/living/L in range(5, src))
		if(L.stat == DEAD || L.faction.Find("scp610"))
			continue
		targets += L
	if(length(targets))
		var/mob/living/target = pick(targets)
		target.adjustFireLoss(damage)
		target.visible_message(span_danger("[src] fires a glob of acid at [target]!"), span_userdanger("You're hit by acid!"))
		last_fire = world.time
		icon_state = "spikes_stabbing"
		addtimer(CALLBACK(src, PROC_REF(refresh_icon)), 2 SECONDS)

/obj/structure/scp610_flesh_structure/cyst/proc/refresh_icon()
	icon_state = "spikes_idle"

// --- Flesh Snare (Slowing Trap) ---
/obj/structure/scp610_flesh_structure/snare
	name = "flesh snare"
	desc = "A patch of viscous flesh on the ground. It clings to anything that steps on it."
	icon = 'icons/scp/newscp610/structure.dmi'
	icon_state = "corruption-1"
	density = FALSE
	max_integrity = 40
	cost = 20
	can_place_in_sight = TRUE

/obj/structure/scp610_flesh_structure/snare/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(L.faction.Find("scp610"))
		return
	L.Immobilize(5 SECONDS)
	L.visible_message(span_danger("[L] gets stuck in [src]!"), span_userdanger("The flesh wraps around your legs!"))
	scp610_infect(L, 10)

// --- Flesh Cluster (Defensive Barrier) ---
/obj/structure/scp610_flesh_structure/cluster
	name = "flesh cluster"
	desc = "A dense mass of hardened flesh and bone. It blocks passage and lashes out at intruders."
	icon = 'icons/scp/newscp610/scp_610_structures48x48.dmi'
	icon_state = "flesh_cluster"
	density = TRUE
	max_integrity = 300
	cost = 60
	marker_only = TRUE
	var/attack_damage = 12
	var/attack_cooldown = 3 SECONDS
	var/last_attack = 0

/obj/structure/scp610_flesh_structure/cluster/process_growth()
	..()
	if(state != SCP610_CREEP_GROW)
		icon_state = "flesh_cluster"
		return
	if(world.time < last_attack + attack_cooldown)
		return
	for(var/mob/living/L in range(1, src))
		if(L.stat == DEAD || L.faction.Find("scp610"))
			continue
		L.adjustBruteLoss(attack_damage)
		L.visible_message(span_danger("[src] lashes out at [L]!"), span_userdanger("[src] strikes you with bony protrusions!"))
		last_attack = world.time
		icon_state = "flesh_cluster_idle"
		addtimer(CALLBACK(src, PROC_REF(refresh_icon)), 1 SECONDS)
		break

/obj/structure/scp610_flesh_structure/cluster/proc/refresh_icon()
	icon_state = "flesh_cluster"

// ============================================================================
// SCP-610 GHOST CONTROLLER (Phase 2)
// ============================================================================

/mob/camera/scp610_ghost
	name = "SCP-610 Hive Ghost"
	desc = "A ghostly presence within the SCP-610 hive mind."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	invisibility = INVISIBILITY_OBSERVER
	sight = SEE_TURFS
	density = FALSE
	hud_type = /datum/hud
	see_in_dark = NIGHTVISION_FOV_RANGE
	see_invisible = SEE_INVISIBLE_LIVING
	layer = FLY_LAYER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	faction = list("scp610")
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE

	var/is_master = FALSE
	var/obj/structure/scp610_core/my_core = null
	var/datum/action/innate/scp610_hive_comm/comm_action
	var/datum/action/innate/scp610_place_nest/place_nest_action
	var/datum/action/innate/scp610_place_growth_node/place_growth_action
	var/datum/action/innate/scp610_place_eye/place_eye_action
	var/datum/action/innate/scp610_place_cyst/place_cyst_action
	var/datum/action/innate/scp610_place_maw/place_maw_action
	var/datum/action/innate/scp610_place_snare/place_snare_action
	var/datum/action/innate/scp610_place_cluster/place_cluster_action
	var/datum/action/innate/scp610_hive_flesh_mend/flesh_mend_action
	var/datum/action/innate/scp610_hive_devouring_wave/devouring_wave_action
	var/datum/action/innate/scp610_hive_infest_burst/infest_burst_action
	var/datum/action/innate/scp610_jump_core/jump_core_action
	var/datum/action/innate/scp610_release/release_action

/mob/camera/scp610_ghost/Initialize()
	. = ..()
	comm_action = new(src)
	comm_action.Grant(src)
	jump_core_action = new(src)
	jump_core_action.Grant(src)
	release_action = new(src)
	release_action.Grant(src)
	if(is_master)
		grant_structure_actions()

/mob/camera/scp610_ghost/proc/grant_structure_actions()
	place_nest_action = new(src)
	place_nest_action.Grant(src)
	place_growth_action = new(src)
	place_growth_action.Grant(src)
	place_eye_action = new(src)
	place_eye_action.Grant(src)
	place_cyst_action = new(src)
	place_cyst_action.Grant(src)
	place_maw_action = new(src)
	place_maw_action.Grant(src)
	place_snare_action = new(src)
	place_snare_action.Grant(src)
	place_cluster_action = new(src)
	place_cluster_action.Grant(src)
	flesh_mend_action = new(src)
	flesh_mend_action.Grant(src)
	devouring_wave_action = new(src)
	devouring_wave_action.Grant(src)
	infest_burst_action = new(src)
	infest_burst_action.Grant(src)

/mob/camera/scp610_ghost/proc/revoke_structure_actions()
	QDEL_NULL(place_nest_action)
	QDEL_NULL(place_growth_action)
	QDEL_NULL(place_eye_action)
	QDEL_NULL(place_cyst_action)
	QDEL_NULL(place_maw_action)
	QDEL_NULL(place_snare_action)
	QDEL_NULL(place_cluster_action)
	QDEL_NULL(flesh_mend_action)
	QDEL_NULL(devouring_wave_action)
	QDEL_NULL(infest_burst_action)

/mob/camera/scp610_ghost/Destroy()
	if(my_core)
		my_core.unregister_ghost(src)
		my_core = null
	QDEL_NULL(comm_action)
	QDEL_NULL(jump_core_action)
	QDEL_NULL(release_action)
	revoke_structure_actions()
	return ..()

/mob/camera/scp610_ghost/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_warning("<b>You are an SCP-610 Hive Ghost!</b>"))
	to_chat(src, span_notice("You serve the flesh. Spread the corruption, place structures on creep, and protect the core."))
	to_chat(src, span_notice("Use your action buttons to place flesh structures and communicate with the hive mind."))
	to_chat(src, span_notice("You can only move across corrupted tiles. Stay close to the flesh."))
	update_perception()

/mob/camera/scp610_ghost/proc/update_perception()
	var/turf/T = get_turf(src)
	var/obj/structure/scp610_creep/creep = locate() in T
	if(creep || is_master)
		sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
		see_in_dark = NIGHTVISION_FOV_RANGE
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else
		sight = SEE_TURFS
		see_in_dark = 2
		lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	if(client)
		client.color = null

/mob/camera/scp610_ghost/Move(NewLoc, Dir = 0)
	if(!my_core)
		return FALSE
	if(!isturf(NewLoc))
		return FALSE
	var/obj/structure/scp610_creep/creep = locate() in NewLoc
	if(!creep && !is_master)
		var/dist = get_dist(NewLoc, get_turf(my_core))
		if(dist > 20)
			return FALSE
	forceMove(NewLoc)
	update_perception()
	return TRUE

/mob/camera/scp610_ghost/proc/on_core_destroyed()
	my_core = null
	if(client)
		to_chat(src, span_deadsay("The core has been destroyed. You are released from the hive."))
		ghostize()
	qdel(src)

/mob/camera/scp610_ghost/Logout()
	..()
	if(my_core)
		my_core.unregister_ghost(src)
	qdel(src)

/mob/camera/scp610_ghost/get_status_tab_items()
	. = ..()
	if(my_core)
		. += "Core Biomass: [my_core.core_biomass]"
		. += "Ghost Biomass: [my_core.ghost_biomass]"
		. += "Hive Will: [round(my_core.hive_will)]/[my_core.hive_will_max]"
		. += "Core State: [my_core.core_state]"
		. += "Flesh Mobs: [length(my_core.flesh_mobs)]"
		. += "Structures: [length(my_core.flesh_structures)]"
	. += "Master: [is_master ? "Yes" : "No"]"

/mob/camera/scp610_ghost/proc/try_place_structure(structure_type)
	if(!my_core)
		to_chat(src, span_warning("You have no core!"))
		return FALSE
	var/turf/T = get_turf(src)
	if(!T)
		to_chat(src, span_warning("You are nowhere!"))
		return FALSE
	if(!my_core.place_structure(structure_type, T, src))
		to_chat(src, span_warning("Cannot place that structure here. Ensure you are on creep and have enough biomass."))
		return FALSE
	var/static/list/structure_names = list(
		/obj/structure/scp610_flesh_structure/nest = "Flesh Nest",
		/obj/structure/scp610_flesh_structure/growth_node = "Growth Node",
		/obj/structure/scp610_flesh_structure/eye = "Flesh Eye",
		/obj/structure/scp610_flesh_structure/cyst = "Acid Cyst",
		/obj/structure/scp610_flesh_structure/maw = "Flesh Maw",
		/obj/structure/scp610_flesh_structure/snare = "Flesh Snare",
		/obj/structure/scp610_flesh_structure/cluster = "Flesh Cluster",
	)
	var/name = structure_names[structure_type] || "structure"
	my_core.hive_mind_message(src, "placed a [name] at [get_area_name(T, TRUE)]")
	return TRUE

// --- Ghost join verb for dead players ---

/mob/dead/observer/proc/join_scp610_hive()
	set name = "Join SCP-610 Hive"
	set category = "SCP-610"
	var/found_core = FALSE
	var/obj/structure/scp610_core/best_core
	for(var/obj/structure/scp610_core/core in SSscp610.cores)
		if(core.core_state >= SCP610_CORE_ACTIVE)
			found_core = TRUE
			best_core = core
			break
	if(!found_core)
		to_chat(usr, span_warning("No active SCP-610 cores exist."))
		return
	if(alert(usr, "Join the SCP-610 hive mind as a ghost controller?", "SCP-610", "Yes", "No") != "Yes")
		return
	var/mob/camera/scp610_ghost/ghost = new(get_turf(best_core))
	ghost.my_core = best_core
	best_core.register_ghost(ghost)
	if(length(best_core.ghosts) == 1)
		ghost.is_master = TRUE
	ghost.key = usr.key
	ghost.forceMove(get_turf(best_core))
	if(ghost.is_master)
		ghost.grant_structure_actions()
		to_chat(ghost, span_warning("<b>You are the Master Ghost of the SCP-610 hive mind!</b>"))
		to_chat(ghost, span_notice("You can place structures using core biomass. You are the primary architect of the flesh."))
	else
		to_chat(ghost, span_notice("You are a drone ghost. You can spread creep and observe. The master ghost places structures."))

// --- Action: Hive Mind Communication ---

/datum/action/innate/scp610_hive_comm
	name = "Hive Mind Communication"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_hivemind"

/datum/action/innate/scp610_hive_comm/Activate()
	var/message = input(owner, "Speak to the hive mind:", "Hive Mind") as text|null
	if(!message || !owner)
		return
	var/mob/camera/scp610_ghost/G = owner
	if(G.my_core)
		G.my_core.hive_mind_message(owner, message)

// --- Action: Place Flesh Nest ---

/datum/action/innate/scp610_place_nest
	name = "Place Flesh Nest (110 biomass)"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_construct"

/datum/action/innate/scp610_place_nest/Activate()
	var/mob/camera/scp610_ghost/G = owner
	G.try_place_structure(/obj/structure/scp610_flesh_structure/nest)

// --- Action: Place Growth Node ---

/datum/action/innate/scp610_place_growth_node
	name = "Place Growth Node (40 biomass)"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_infest"

/datum/action/innate/scp610_place_growth_node/Activate()
	var/mob/camera/scp610_ghost/G = owner
	G.try_place_structure(/obj/structure/scp610_flesh_structure/growth_node)

// --- Action: Place Flesh Eye ---

/datum/action/innate/scp610_place_eye
	name = "Place Flesh Eye (15 biomass)"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "absorb"

/datum/action/innate/scp610_place_eye/Activate()
	var/mob/camera/scp610_ghost/G = owner
	G.try_place_structure(/obj/structure/scp610_flesh_structure/eye)

// --- Action: Place Acid Cyst ---

/datum/action/innate/scp610_place_cyst
	name = "Place Acid Cyst (15 biomass)"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_regurgitate"

/datum/action/innate/scp610_place_cyst/Activate()
	var/mob/camera/scp610_ghost/G = owner
	G.try_place_structure(/obj/structure/scp610_flesh_structure/cyst)

// --- Action: Place Flesh Maw ---

/datum/action/innate/scp610_place_maw
	name = "Place Flesh Maw (40 biomass)"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "devour"

/datum/action/innate/scp610_place_maw/Activate()
	var/mob/camera/scp610_ghost/G = owner
	G.try_place_structure(/obj/structure/scp610_flesh_structure/maw)

// --- Action: Place Flesh Snare ---

/datum/action/innate/scp610_place_snare
	name = "Place Flesh Snare (20 biomass)"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_whip"

/datum/action/innate/scp610_place_snare/Activate()
	var/mob/camera/scp610_ghost/G = owner
	G.try_place_structure(/obj/structure/scp610_flesh_structure/snare)

// --- Action: Place Flesh Cluster ---

/datum/action/innate/scp610_place_cluster
	name = "Place Flesh Cluster (60 biomass)"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_mend"

/datum/action/innate/scp610_place_cluster/Activate()
	var/mob/camera/scp610_ghost/G = owner
	G.try_place_structure(/obj/structure/scp610_flesh_structure/cluster)

// --- Action: Jump to Core ---

/datum/action/innate/scp610_jump_core
	name = "Jump to Core"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_transfer"

/datum/action/innate/scp610_jump_core/Activate()
	var/mob/camera/scp610_ghost/G = owner
	if(!G.my_core || QDELETED(G.my_core))
		to_chat(owner, span_warning("No core to jump to!"))
		return
	G.forceMove(get_turf(G.my_core))
	to_chat(owner, span_notice("You shift your perspective to the core."))

// --- Action: Release from Hive ---

/datum/action/innate/scp610_release
	name = "Release from Hive"
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "button_fleshhate"

/datum/action/innate/scp610_release/Activate()
	if(alert(owner, "Leave the SCP-610 hive mind? You will become a ghost again.", "Release", "Stay", "Leave") != "Leave")
		return
	var/mob/camera/scp610_ghost/G = owner
	if(G.my_core)
		G.my_core.unregister_ghost(G)
	G.ghostize()

// --- Hive Will Ability: Flesh Mend ---

/datum/action/innate/scp610_hive_flesh_mend
	name = "Flesh Mend (200 Will)"
	desc = "Heal all flesh mobs and structures near the core."
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_mend"

/datum/action/innate/scp610_hive_flesh_mend/Activate()
	var/mob/camera/scp610_ghost/G = owner
	if(!G.my_core)
		to_chat(owner, span_warning("No core connected!"))
		return
	if(!G.my_core.ability_flesh_mend())
		to_chat(owner, span_warning("Not enough Hive Will! Need 200."))

// --- Hive Will Ability: Devouring Wave ---

/datum/action/innate/scp610_hive_devouring_wave
	name = "Devouring Wave (300 Will)"
	desc = "Damage and immobilize nearby non-610 mobs."
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "devour"

/datum/action/innate/scp610_hive_devouring_wave/Activate()
	var/mob/camera/scp610_ghost/G = owner
	if(!G.my_core)
		to_chat(owner, span_warning("No core connected!"))
		return
	if(!G.my_core.ability_devouring_wave())
		to_chat(owner, span_warning("Not enough Hive Will! Need 300."))

// --- Hive Will Ability: Infest Burst ---

/datum/action/innate/scp610_hive_infest_burst
	name = "Infest Burst (150 Will)"
	desc = "Burst creep in a radius around the core."
	button_icon = 'icons/scp/newscp610/FleshThatHatesButtons.dmi'
	button_icon_state = "flesh_infest"

/datum/action/innate/scp610_hive_infest_burst/Activate()
	var/mob/camera/scp610_ghost/G = owner
	if(!G.my_core)
		to_chat(owner, span_warning("No core connected!"))
		return
	if(!G.my_core.ability_infest_burst())
		to_chat(owner, span_warning("Not enough Hive Will! Need 150."))
