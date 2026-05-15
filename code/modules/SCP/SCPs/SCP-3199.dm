// SCP-3199: Sapient Biological Entity
// A Keter-class entity with unique reproductive capabilities and hunting behavior
// Based on SCP Wiki: https://scp-wiki.wikidot.com/scp-3199

/mob/living/scp/scp3199
	name = "SCP-3199"
	desc = "A hairless, 2.9-meter tall entity stained with albumen-like excretion. Its neck can twist 340° in either direction."
	icon = 'icons/scp/scp-3199.dmi'
	icon_state = "scp-3199-grown"
	status_flags = 0
	maxHealth = 100
	health = 100
	persistence_id = "SCP-3199"

	// Modular systems
	var/datum/scp3199_reproduction_system/reproduction_system
	var/datum/scp3199_containment_system/containment_system
	var/datum/scp3199_environment_system/environment_system
	var/datum/scp3199_research_system/research_system

/mob/living/scp/scp3199/Initialize()
	. = ..()
	set_species(/datum/species/scp3199)
	SCP = new /datum/scp(src, "sapient biological entity", SCP_KETER, "3199")
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	// Remove bodypart overlays to prevent covering the SCP icon

/mob/living/scp/scp3199/proc/initialize_systems()
	reproduction_system = new /datum/scp3199_reproduction_system(src)
	containment_system = new /datum/scp3199_containment_system(src)
	environment_system = new /datum/scp3199_environment_system(src)
	research_system = new /datum/scp3199_research_system(src)

/mob/living/scp/scp3199/Destroy()
	QDEL_NULL(reproduction_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(environment_system)
	QDEL_NULL(research_system)
	return ..()

/mob/living/scp/scp3199/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	reproduction_system?.process_reproduction()
	containment_system?.process_containment()
	environment_system?.process_environment()
	research_system?.process_research()

/mob/living/scp/scp3199/UnarmedAttack(atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.adjustBruteLoss(25)
		L.adjustToxLoss(15)
		visible_message("<span class='danger'>[src] liquefies [L]'s internal structure!</span>")
		SCP?.log_interaction(L, "liquefaction_attack")
		SCP?.award_research(L, "combat", 25)

/mob/living/scp/scp3199/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This entity appears to be a sapient biological organism with unusual reproductive capabilities.</span>"

// SCP-3199 Egg
/obj/item/scp3199_egg
	name = "SCP-3199 egg"
	desc = "A large off-white egg with a rubbery appearance. Extremely resilient to damage."
	icon = 'icons/scp/scp-3199.dmi'
	icon_state = "3199_egg_cluster"
	w_class = 4
	var/mob/living/scp/scp3199/parent_entity
	var/hatching_cooldown = 0
	var/hatching_time = 18000 // 30 minutes
	var/heat_sensitivity = TRUE

/obj/item/scp3199_egg/Initialize()
	. = ..()
	hatching_cooldown = hatching_time
	START_PROCESSING(SSobj, src)

/obj/item/scp3199_egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scp3199_egg/process()
	// Check for heat exposure
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/air = T?.return_air()
	if(air && air.temperature > 350)
		src.accelerated_hatching()

	// Normal hatching countdown
	if(hatching_cooldown > 0)
		hatching_cooldown--
		if(hatching_cooldown <= 0)
			src.hatch()

/obj/item/scp3199_egg/proc/accelerated_hatching()
	if(hatching_cooldown > 0)
		hatching_cooldown = max(0, hatching_cooldown - 600) // Reduce by 10 minutes
		// Visual indication of heat exposure
		icon_state = "egg_hot"
		desc = "A large off-white egg with a rubbery appearance. It's getting hot!"

/obj/item/scp3199_egg/proc/hatch()
	var/turf/egg_turf = get_turf(src)
	// Create hatchling (human type variant)
	var/mob/living/scp/scp3199/hatchling = new /mob/living/scp/scp3199(egg_turf)
	hatchling.name = "SCP-3199 hatchling"
	hatchling.desc = "A juvenile instance of SCP-3199."
	hatchling.maxHealth = 50
	hatchling.health = 50
	// Log hatching
	if(parent_entity)
		parent_entity.SCP?.log_interaction(hatchling, "egg_hatching")
		parent_entity.SCP?.award_research(hatchling, "reproduction", 50)
	// Visual and audio effects
	playsound(egg_turf, 'sound/effects/explosion1.ogg', 75, TRUE, 5)
	visible_message("<span class='danger'>The SCP-3199 egg ruptures violently, producing a hatchling!</span>")
	qdel(src)

/obj/item/scp3199_egg/attackby(obj/item/I, mob/user)
	// Eggs are extremely resilient
	if(I.force > 0)
		to_chat(user, "<span class='notice'>The egg is extremely resilient and resists damage.</span>")
		return
	return ..()

/obj/item/scp3199_egg/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This egg appears to be extremely resilient to damage.</span>"
	if(hatching_cooldown > 0)
		var/time_remaining = round(hatching_cooldown / 600, 1) // Convert to minutes
		. += "<span class='warning'>The egg will hatch in approximately [time_remaining] minutes.</span>"
	if(icon_state == "egg_hot")
		. += "<span class='danger'>The egg is being affected by heat exposure!</span>"

/mob/living/scp/scp3199/proc/on_egg_laid(obj/item/scp3199_egg/egg)
	hook_scp_breach("SCP-3199", src)
	hook_facility_damage_near_scp("SCP-3199", 2)

/mob/living/scp/scp3199/proc/on_hatch(mob/living/scp/scp3199/hatchling)
	if(!hatchling)
		return
	hook_scp_breach("SCP-3199", hatchling)

/mob/living/scp/scp3199/proc/on_liquefaction_attack(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-3199", 25, 0)
	if(victim.stat == DEAD)
		hook_player_death_near_scp(victim, "SCP-3199")
