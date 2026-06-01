// SCP-106 Pocket Dimension - Area, Turfs, Exit Portals, Captured Component
// Simplified from original: removed BSP procedural generation, uses map-placed area

/area/scp/pocket_dimension
	name = "Pocket Dimension"
	requires_power = FALSE
	has_gravity = FALSE
	area_lighting = AREA_LIGHTING_STATIC
	base_lighting_color = "#000000"
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = UNIQUE_AREA|NO_ALERTS
	ambience_index = AMBIENCE_AWAY
	ambientsounds = list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg','sound/ambience/ambigen12.ogg')

/turf/open/pocket_dimension
	name = "shifting void"
	desc = "Reality warps and bends in this impossible space."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dark"

/turf/closed/pocket_dimension
	name = "impossible wall"
	desc = "A wall that shouldn't exist. It shifts and writhes."
	icon = 'icons/turf/walls.dmi'
	icon_state = "icerock"

/obj/effect/pocket_dimension_exit
	name = "tear in reality"
	desc = "A shimmering tear in the fabric of this pocket dimension. Freedom, or a trap?"
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity"
	anchored = TRUE
	layer = OBJ_LAYER
	var/escape_chance = 10
	var/decay_escape_chance = 0

/obj/effect/pocket_dimension_exit/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/pocket_dimension_exit/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/pocket_dimension_exit/process()
	decay_escape_chance += 0.5

/obj/effect/pocket_dimension_exit/attack_hand(mob/living/carbon/human/H)
	if(!istype(H))
		return

	var/total_chance = escape_chance + decay_escape_chance
	if(prob(total_chance))
		var/datum/component/pocket_dimension_captured/captured = H.GetComponent(/datum/component/pocket_dimension_captured)
		if(captured)
			captured.return_to_reality()
		else
			var/turf/safe_turf = pick(GLOB.station_turfs)
			if(safe_turf)
				H.forceMove(safe_turf)
		to_chat(H, span_notice("You tear through the fabric of reality and escape!"))
		playsound(H, 'sound/effects/phasein.ogg', 50, FALSE)
	else
		H.adjustBruteLoss(10)
		to_chat(H, span_danger("You fail to tear through reality! The dimension fights back!"))
		var/area/scp/pocket_dimension/pd = get_area(src)
		if(pd)
			var/list/valid_turfs = list()
			for(var/turf/open/pocket_dimension/T in pd)
				valid_turfs += T
			if(length(valid_turfs))
				H.forceMove(pick(valid_turfs))

/obj/effect/pocket_dimension_hazard
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/pocket_dimension_hazard/acid_pool
	name = "pool of corrosive liquid"
	desc = "A bubbling pool of dark, corrosive liquid."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"

/obj/effect/pocket_dimension_hazard/acid_pool/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_crossed))

/obj/effect/pocket_dimension_hazard/acid_pool/proc/on_crossed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!istype(AM, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = AM
	H.adjustBruteLoss(15)
	H.adjustToxLoss(5)

/obj/effect/pocket_dimension_hazard/sanity_drain
	name = "whispering shadow"
	desc = "A dark shape that whispers impossible things."
	icon = 'icons/effects/effects.dmi'
	icon_state = "curse"

/obj/effect/pocket_dimension_hazard/sanity_drain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_crossed))

/obj/effect/pocket_dimension_hazard/sanity_drain/proc/on_crossed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!istype(AM, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = AM
	if(H.sanity)
		H.sanity.adjust_sanity(-15, "pocket_dimension_whispering_shadow")
	if(prob(30))
		H.hallucination += 20

/datum/component/pocket_dimension_captured
	var/turf/original_location
	var/dimension_id
	var/capture_time
	var/tick_damage

/datum/component/pocket_dimension_captured/Initialize(turf/origin, dim_id)
	. = ..()
	original_location = origin
	dimension_id = dim_id
	capture_time = world.time
	tick_damage = addtimer(CALLBACK(src, PROC_REF(apply_tick_damage)), 30 SECONDS, TIMER_STOPPABLE | TIMER_LOOP)

/datum/component/pocket_dimension_captured/Destroy()
	deltimer(tick_damage)
	return ..()

/datum/component/pocket_dimension_captured/proc/apply_tick_damage()
	var/mob/living/carbon/human/H = parent
	if(!istype(H) || H.health <= 0)
		return
	H.adjustBruteLoss(2)
	H.adjustToxLoss(1)

/datum/component/pocket_dimension_captured/proc/return_to_reality()
	var/mob/living/carbon/human/H = parent
	if(!istype(H))
		return
	deltimer(tick_damage)
	if(original_location)
		H.forceMove(original_location)
	else
		var/turf/safe_turf = pick(GLOB.station_turfs)
		if(safe_turf)
			H.forceMove(safe_turf)
	H.visible_message(span_notice("[H] emerges from a pocket dimension!"))
	playsound(H, 'sound/effects/phasein.ogg', 50, FALSE)
	qdel(src)

/datum/movespeed_modifier/pocket_dimension_acid_slowdown
	slowdown = 1
	priority = 100

/obj/scp106_random
	icon = 'icons/effects/effects.dmi'
	icon_state = "x2"
	anchored = TRUE
	simulated = FALSE
	invisibility = INVISIBILITY_ABSTRACT

/obj/scp106_random/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/obj/scp106_random/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!istype(arrived, /mob/living) || istype(arrived, /mob/living/scp/scp106))
		return
	var/mob/living/L = arrived
	if(prob(15))
		L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1000)
		animate(L, color = "#999999", time = 10 SECONDS)
		return
	if(prob(15))
		var/turf/T = pick(GLOB.station_turfs)
		if(T)
			visible_message(span_warning("[L] is warped away!"))
			playsound(L, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 25, TRUE)
			L.forceMove(T)
		return
	if(prob(70))
		var/area/scp/pocket_dimension/pd = locate(/area/scp/pocket_dimension) in GLOB.areas
		if(pd)
			var/list/valid_turfs = list()
			for(var/turf/open/pocket_dimension/T in pd)
				valid_turfs += T
			if(length(valid_turfs))
				visible_message(span_warning("[L] is warped away!"))
				playsound(L, pick('sound/scp/106/decay1.ogg', 'sound/scp/106/decay2.ogg', 'sound/scp/106/decay3.ogg'), 25, TRUE)
				L.alpha = 0
				L.forceMove(pick(valid_turfs))
				animate(L, alpha = 255, time = 2 SECONDS)
