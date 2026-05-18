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
	var/damage_tick = 0
	var/damage_interval = 30 SECONDS

/turf/open/pocket_dimension/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/turf/open/pocket_dimension/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/pocket_dimension/process()
	damage_tick++
	if(damage_tick >= damage_interval)
		damage_tick = 0
		apply_dimension_damage()

/turf/open/pocket_dimension/proc/apply_dimension_damage()
	for(var/mob/living/carbon/human/H in src)
		if(H.health > 0)
			H.adjustBruteLoss(2)
			H.adjustToxLoss(1)
			if(H.sanity)
				H.sanity.adjust_sanity(-5, "pocket_dimension_decay")

/turf/closed/pocket_dimension
	name = "impossible wall"
	desc = "A wall that shouldn't exist. It shifts and writhes."
	icon = 'icons/turf/walls.dmi'
	icon_state = "icerock"

/datum/pocket_dimension_generator
	var/dimension_size = 15
	var/min_room_size = 3
	var/max_room_size = 7
	var/min_sector_size = 5
	var/split_depth = 3
	var/list/dimension_turfs = list()
	var/list/dimension_rooms = list()
	var/area/scp/pocket_dimension/dimension_area = null
	var/dimension_z = 0
	var/list/exit_portals = list()
	var/list/hazards = list()

/datum/pocket_dimension_generator/proc/generate_pocket_dimension(dimension_type, owner)
	var/new_z
	var/datum/space_level/new_level = SSmapping.add_new_zlevel("SCP-106 Pocket Dimension [world.time]", list(ZTRAIT_STATION = TRUE))
	if(new_level)
		new_z = new_level.z_value
	else if(SSmapping.station_start)
		new_z = SSmapping.station_start
	else
		new_z = 2

	dimension_z = new_z
	dimension_area = new /area/scp/pocket_dimension()
	dimension_turfs = list()
	dimension_rooms = list()
	exit_portals = list()
	hazards = list()

	for(var/x in 1 to dimension_size)
		for(var/y in 1 to dimension_size)
			var/turf/T = locate(x, y, new_z)
			if(T)
				T.ChangeTurf(/turf/closed/pocket_dimension)
				T.change_area(T.loc, dimension_area)
				dimension_turfs += T

	var/list/datum/pocket_dimension_sector/sectors = generate_bsp_sectors(split_depth, min_sector_size, dimension_size - 1, 1, 1)

	for(var/datum/pocket_dimension_sector/sector as anything in sectors)
		var/datum/pocket_dimension_room/room = carve_room_in_sector(sector, new_z)
		if(room)
			dimension_rooms += room

	for(var/i in 1 to length(dimension_rooms))
		var/datum/pocket_dimension_room/A = dimension_rooms[i]
		for(var/j in i + 1 to length(dimension_rooms))
			var/datum/pocket_dimension_room/B = dimension_rooms[j]
			if(rooms_are_adjacent(A, B))
				carve_corridor_between(A, B, new_z)

	place_hazards(dimension_type, new_z)
	place_exit_portals(new_z)

	return dimension_area

/datum/pocket_dimension_generator/proc/generate_bsp_sectors(current_depth, min_sector, max_w, start_x, start_y)
	var/datum/pocket_dimension_sector/root = new(start_x, start_y, start_x + max_w, start_y + max_w)
	var/list/leaves = list(root)

	for(var/d in 1 to current_depth)
		var/list/new_leaves = list()
		for(var/datum/pocket_dimension_sector/leaf as anything in leaves)
			if(leaf.area_size() < min_sector * min_sector * 4)
				new_leaves += leaf
				continue

			var/split_horz = leaf.width() > leaf.height() ? FALSE : leaf.height() > leaf.width() ? TRUE : prob(50)

			if(split_horz)
				if(leaf.height() < min_sector * 2)
					new_leaves += leaf
					continue
				var/split_at = leaf.y1 + rand(min_sector, leaf.height() - min_sector)
				new_leaves += new /datum/pocket_dimension_sector(leaf.x1, leaf.y1, leaf.x2, split_at)
				new_leaves += new /datum/pocket_dimension_sector(leaf.x1, split_at, leaf.x2, leaf.y2)
			else
				if(leaf.width() < min_sector * 2)
					new_leaves += leaf
					continue
				var/split_at = leaf.x1 + rand(min_sector, leaf.width() - min_sector)
				new_leaves += new /datum/pocket_dimension_sector(leaf.x1, leaf.y1, split_at, leaf.y2)
				new_leaves += new /datum/pocket_dimension_sector(split_at, leaf.y1, leaf.x2, leaf.y2)

		leaves = new_leaves

	return leaves

/datum/pocket_dimension_sector
	var/x1
	var/y1
	var/x2
	var/y2

/datum/pocket_dimension_sector/New(nx1, ny1, nx2, ny2)
	x1 = nx1
	y1 = ny1
	x2 = nx2
	y2 = ny2

/datum/pocket_dimension_sector/proc/width()
	return x2 - x1

/datum/pocket_dimension_sector/proc/height()
	return y2 - y1

/datum/pocket_dimension_sector/proc/area_size()
	return width() * height()

/datum/pocket_dimension_room
	var/x1
	var/y1
	var/x2
	var/y2
	var/cx
	var/cy
	var/room_width
	var/room_height

/datum/pocket_dimension_room/New(nx1, ny1, nx2, ny2)
	x1 = nx1
	y1 = ny1
	x2 = nx2
	y2 = ny2
	room_width = x2 - x1
	room_height = y2 - y1
	cx = round((x1 + x2) / 2)
	cy = round((y1 + y2) / 2)

/datum/pocket_dimension_generator/proc/carve_room_in_sector(datum/pocket_dimension_sector/sector, z_level)
	var/pad_x = rand(1, 2)
	var/pad_y = rand(1, 2)
	var/rx1 = sector.x1 + pad_x
	var/ry1 = sector.y1 + pad_y
	var/rx2 = sector.x2 - rand(1, 2)
	var/ry2 = sector.y2 - rand(1, 2)

	if(rx2 - rx1 < min_room_size || ry2 - ry1 < min_room_size)
		return null

	for(var/x in rx1 to rx2)
		for(var/y in ry1 to ry2)
			var/turf/T = locate(x, y, z_level)
			if(T && istype(T, /turf/closed/pocket_dimension))
				T.ChangeTurf(/turf/open/pocket_dimension)
				if(dimension_area)
					T.change_area(T.loc, dimension_area)

	return new /datum/pocket_dimension_room(rx1, ry1, rx2, ry2)

/datum/pocket_dimension_generator/proc/rooms_are_adjacent(datum/pocket_dimension_room/A, datum/pocket_dimension_room/B)
	var/gap = 3
	if(A.x2 + gap >= B.x1 && B.x2 + gap >= A.x1 && A.y2 + gap >= B.y1 && B.y2 + gap >= A.y1)
		return TRUE
	return FALSE

/datum/pocket_dimension_generator/proc/carve_corridor_between(datum/pocket_dimension_room/A, datum/pocket_dimension_room/B, z_level)
	var/start_x = A.cx
	var/start_y = A.cy
	var/end_x = B.cx
	var/end_y = B.cy

	if(prob(50))
		carve_h_corridor(start_x, end_x, start_y, z_level)
		carve_v_corridor(start_y, end_y, end_x, z_level)
	else
		carve_v_corridor(start_y, end_y, start_x, z_level)
		carve_h_corridor(start_x, end_x, end_y, z_level)

/datum/pocket_dimension_generator/proc/carve_h_corridor(x1, x2, y, z_level)
	var/low = min(x1, x2)
	var/high = max(x1, x2)
	for(var/x in low to high)
		var/turf/T = locate(x, y, z_level)
		if(T && istype(T, /turf/closed/pocket_dimension))
			T.ChangeTurf(/turf/open/pocket_dimension)
			if(dimension_area)
				T.change_area(T.loc, dimension_area)

/datum/pocket_dimension_generator/proc/carve_v_corridor(y1, y2, x, z_level)
	var/low = min(y1, y2)
	var/high = max(y1, y2)
	for(var/y in low to high)
		var/turf/T = locate(x, y, z_level)
		if(T && istype(T, /turf/closed/pocket_dimension))
			T.ChangeTurf(/turf/open/pocket_dimension)
			if(dimension_area)
				T.change_area(T.loc, dimension_area)

/datum/pocket_dimension_generator/proc/place_hazards(dimension_type, z_level)
	var/list/open_turfs = list()
	for(var/turf/T in dimension_turfs)
		if(istype(T, /turf/open/pocket_dimension))
			open_turfs += T

	if(length(open_turfs) == 0)
		return

	switch(dimension_type)
		if("decay_chamber")
			var/acid_count = rand(3, 6)
			for(var/i in 1 to acid_count)
				var/turf/T = pick(open_turfs)
				var/obj/effect/pocket_dimension_hazard/acid_pool/pool = new(T)
				hazards += pool
		if("horror_maze")
			var/sanity_count = rand(4, 8)
			for(var/i in 1 to sanity_count)
				var/turf/T = pick(open_turfs)
				var/obj/effect/pocket_dimension_hazard/sanity_drain/shadow = new(T)
				hazards += shadow
		if("memory_loop")
			var/mixed_count = rand(2, 4)
			for(var/i in 1 to mixed_count)
				var/turf/T = pick(open_turfs)
				if(prob(50))
					var/obj/effect/pocket_dimension_hazard/sanity_drain/shadow = new(T)
					hazards += shadow
				else
					var/obj/effect/pocket_dimension_hazard/acid_pool/pool = new(T)
					hazards += pool
		if("sensory_deprivation")
			var/sanity_count = rand(1, 2)
			for(var/i in 1 to sanity_count)
				var/turf/T = pick(open_turfs)
				var/obj/effect/pocket_dimension_hazard/sanity_drain/shadow = new(T)
				hazards += shadow

/datum/pocket_dimension_generator/proc/place_exit_portals(z_level)
	var/list/open_turfs = list()
	for(var/turf/T in dimension_turfs)
		if(istype(T, /turf/open/pocket_dimension))
			open_turfs += T

	if(length(open_turfs) == 0)
		return

	var/portal_count = rand(1, 2)
	for(var/i in 1 to portal_count)
		var/turf/T = pick(open_turfs)
		var/obj/effect/pocket_dimension_exit/portal = new(T)
		exit_portals += portal

/datum/pocket_dimension_generator/proc/collapse_dimension()
	for(var/mob/living/carbon/human/H in dimension_area)
		var/datum/component/pocket_dimension_captured/captured = H.GetComponent(/datum/component/pocket_dimension_captured)
		if(captured)
			captured.return_to_reality()

	for(var/obj/effect/pocket_dimension_exit/portal in exit_portals)
		qdel(portal)
	exit_portals = list()

	for(var/obj/effect/pocket_dimension_hazard/hazard in hazards)
		qdel(hazard)
	hazards = list()

	for(var/turf/T in dimension_turfs)
		for(var/atom/movable/AM in T)
			if(ismob(AM))
				continue
			qdel(AM)
		T.ScrapeAway()

	dimension_turfs = list()
	dimension_rooms = list()
	qdel(dimension_area)
	dimension_area = null

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
		to_chat(H, "<span class='notice'>You tear through the fabric of reality and escape!</span>")
		playsound(H, 'sound/effects/phasein.ogg', 50, 0)
	else
		H.adjustBruteLoss(10)
		if(H.sanity)
			H.sanity.adjust_sanity(-5, "pocket_dimension_escape_fail")
		to_chat(H, "<span class='danger'>You fail to tear through reality! The dimension fights back!</span>")
		var/area/scp/pocket_dimension/pdim = get_area(src)
		if(pdim)
			var/list/valid_turfs = list()
			for(var/turf/T in pdim)
				if(istype(T, /turf/open/pocket_dimension))
					valid_turfs += T
			if(length(valid_turfs) > 0)
				H.forceMove(pick(valid_turfs))

/obj/effect/pocket_dimension_hazard
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/pocket_dimension_hazard/acid_pool
	name = "pool of corrosive liquid"
	desc = "A bubbling pool of dark, corrosive liquid."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"

/obj/effect/pocket_dimension_hazard/acid_pool/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_crossed))

/obj/effect/pocket_dimension_hazard/acid_pool/proc/on_crossed(datum/source, atom/movable/AM)
	if(!istype(AM, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = AM
	H.adjustBruteLoss(15)
	H.adjustToxLoss(5)
	H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/pocket_dimension_acid_slowdown, slowdown = 1, update = TRUE)
	addtimer(CALLBACK(H, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/pocket_dimension_acid_slowdown), 10 SECONDS)

/obj/effect/pocket_dimension_hazard/sanity_drain
	name = "whispering shadow"
	desc = "A dark shape that whispers impossible things."
	icon = 'icons/effects/effects.dmi'
	icon_state = "curse"

/obj/effect/pocket_dimension_hazard/sanity_drain/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_crossed))

/obj/effect/pocket_dimension_hazard/sanity_drain/proc/on_crossed(datum/source, atom/movable/AM)
	if(!istype(AM, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = AM
	if(H.sanity)
		H.sanity.adjust_sanity(-15, "pocket_dimension_whispering_shadow")
	if(prob(30))
		H.hallucination += 20

/datum/movespeed_modifier/pocket_dimension_acid_slowdown
	slowdown = 1
	priority = 100

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
	if(H.sanity)
		H.sanity.adjust_sanity(-5, "pocket_dimension_tick")

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
	H.visible_message("<span class='notice'>[H] emerges from a pocket dimension!</span>")
	playsound(H, 'sound/effects/phasein.ogg', 50, 0)
	qdel(src)
