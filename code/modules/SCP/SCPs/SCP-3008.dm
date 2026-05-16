/obj/structure/scp3008
	name = "SCP-3008"
	desc = "An entrance to an infinite IKEA store. The interior seems to stretch on forever."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp113"
	density = TRUE
	anchored = TRUE

	var/obj/effect/landmark/ikea_entrance/entrance_landmark
	var/list/ikea_interiors = list()
	var/max_interiors = 10
	var/current_interior_id = 0
/obj/structure/scp3008/Initialize()
	. = ..()
	GLOB.scp3008_entrances += src

	SCP = new /datum/scp(
		src,
		"SCP-3008",
		SCP_EUCLID,
		"3008",

	)

	SCP.min_playercount = 25
	SCP.min_time = 45 MINUTES

	if(!entrance_landmark)
		entrance_landmark = new /obj/effect/landmark/ikea_entrance(get_turf(src))

	addtimer(CALLBACK(src, PROC_REF(create_ikea_interior)), 0)
	START_PROCESSING(SSobj, src)

/obj/structure/scp3008/Destroy()
	GLOB.scp3008_entrances -= src
	STOP_PROCESSING(SSobj, src)
	if(entrance_landmark)
		qdel(entrance_landmark)

	for(var/datum/ikea_interior/interior in ikea_interiors)
		qdel(interior)
	ikea_interiors = list()

	return ..()

/obj/structure/scp3008/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return

	to_chat(user, "<span class='notice'>You approach the entrance to the infinite IKEA...</span>")
	if(alert(user, "Enter SCP-3008 - The Infinite IKEA? You may become lost inside.", "Enter IKEA", "Yes", "No") == "Yes")
		enter_ikea(user)

/obj/structure/scp3008/proc/enter_ikea(mob/living/carbon/human/user)
	if(!user || !istype(user))
		return

	var/datum/ikea_interior/interior = get_available_interior()
	if(!interior)
		to_chat(user, "<span class='warning'>The IKEA is currently full. Please try again later.</span>")
		return

	var/turf/entry_point = interior.get_entry_point()
	if(!entry_point || !istype(entry_point, /turf/open))
		var/turf/fallback = pick(GLOB.station_turfs)
		if(fallback)
			user.forceMove(fallback)
		to_chat(user, "<span class='warning'>The IKEA dimension is unstable. You were ejected.</span>")
		return

	user.forceMove(entry_point)
	to_chat(user, "<span class='danger'>You enter the infinite IKEA. The store stretches on forever in all directions...</span>")
	to_chat(user, "<span class='warning'>You hear the sound of IKEA staff approaching. They are not friendly.</span>")
	interior.add_occupant(user)
	hook_scp_exploration(user, "SCP-3008", 0)
	on_ikea_entry(user)

/obj/structure/scp3008/proc/get_available_interior()
	for(var/datum/ikea_interior/interior in ikea_interiors)
		if(length(interior.occupants) < interior.max_occupants)
			return interior

	if(length(ikea_interiors) < max_interiors)
		return create_ikea_interior()

	return null

/obj/structure/scp3008/proc/create_ikea_interior()
	current_interior_id++
	var/datum/ikea_interior/interior = new /datum/ikea_interior(current_interior_id, src)
	ikea_interiors += interior
	return interior

/obj/structure/scp3008/process()
	. = ..()

	for(var/datum/ikea_interior/interior in ikea_interiors)
		interior.process_day_night()

/obj/structure/scp3008/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-3008, an infinite IKEA store with hostile staff entities.</span>")
		else
			to_chat(user, "<span class='danger'>An entrance to an IKEA store that seems to stretch on infinitely into the distance.</span>")
			to_chat(user, "<span class='notice'>You can click on this to enter the IKEA.</span>")

/obj/structure/scp3008/proc/on_ikea_entry(mob/living/carbon/human/entrant)
	if(!entrant)
		return
	hook_scp_breach("SCP-3008", src)

/datum/ikea_interior
	var/id
	var/obj/structure/scp3008/parent_entrance
	var/list/occupants = list()
	var/max_occupants = 20
	var/turf/entry_point
	var/list/ikea_turfs = list()
	var/staff_entities = list()
	var/resource_spawns = list()
	var/is_night = FALSE
	var/cycle_timer = 0
	var/cycle_duration = 120 SECONDS
	var/night_warning_given = FALSE
	var/list/landmarks_placed = list()
	var/list/settlement_signs = list()
	var/area/scp/ikea/interior_area

/datum/ikea_interior/New(interior_id, obj/structure/scp3008/entrance)
	id = interior_id
	parent_entrance = entrance
	generate_interior()

/datum/ikea_interior/Destroy()
	for(var/mob/living/carbon/human/occupant in occupants)
		if(occupant && occupant.loc)
			if(parent_entrance && parent_entrance.loc)
				occupant.forceMove(get_turf(parent_entrance))
				to_chat(occupant, "<span class='notice'>You are ejected from the IKEA.</span>")
			else
				var/turf/safe_turf = pick(GLOB.station_turfs)
				if(safe_turf)
					occupant.forceMove(safe_turf)
					to_chat(occupant, "<span class='notice'>You are teleported to safety.</span>")

	for(var/mob/living/simple_animal/hostile/ikea_staff/staff in staff_entities)
		qdel(staff)

	for(var/obj/item/resource in resource_spawns)
		qdel(resource)

	occupants = list()
	staff_entities = list()
	resource_spawns = list()

	return ..()

/datum/ikea_interior/proc/generate_interior()
	var/new_z
	var/datum/space_level/new_level = SSmapping.add_new_zlevel("IKEA Interior [id]", list(ZTRAIT_STATION = TRUE, ZTRAIT_GRAVITY = TRUE))
	if(new_level)
		new_z = new_level.z_value
	else if(SSmapping.station_start)
		new_z = SSmapping.station_start
	else
		new_z = 2
	generate_ikea_labyrinth(new_z)

	if(!entry_point)
		world.log << "IKEA interior [id]: Entry point is null after generation, using fallback"
		entry_point = locate(50, 50, new_z)
		if(entry_point)
			entry_point.ChangeTurf(/turf/open/floor/wood)

	world.log << "IKEA interior [id]: Entry point at [entry_point ? "[entry_point.x],[entry_point.y],[entry_point.z]" : "NULL"]"

/area/scp/ikea
	name = "SCP-3008 Interior"
	icon = 'icons/area/areas_away_missions.dmi'
	icon_state = "away"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_lighting = AREA_LIGHTING_STATIC
	base_lighting_color = "#e8dcc4"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	area_flags = UNIQUE_AREA|NO_ALERTS
	ambience_index = AMBIENCE_AWAY
	ambientsounds = list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg','sound/ambience/ambigen12.ogg')

/datum/ikea_interior/proc/generate_ikea_labyrinth(z_level)
	world.log << "IKEA interior: Starting BSP generation for z-level [z_level]"

	var/area/scp/ikea/ikea_area = new /area/scp/ikea()
	interior_area = ikea_area

	for(var/x in 1 to 100)
		for(var/y in 1 to 100)
			var/turf/T = locate(x, y, z_level)
			if(T)
				if(x == 1 || x == 100 || y == 1 || y == 100)
					T.ChangeTurf(/turf/closed/wall/mineral/wood)
				else
					T.ChangeTurf(/turf/closed/wall/mineral/wood)
				T.change_area(T.loc, ikea_area)
				ikea_turfs += T

	var/list/datum/ikea_room/rooms = list()
	var/list/datum/ikea_sector/sectors = generate_bsp_sectors(3, 5, 96, 5, 5, z_level)

	for(var/datum/ikea_sector/sector as anything in sectors)
		var/datum/ikea_room/room = carve_room_in_sector(sector, z_level)
		if(room)
			rooms += room

	for(var/i in 1 to length(rooms))
		var/datum/ikea_room/A = rooms[i]
		for(var/j in i + 1 to length(rooms))
			var/datum/ikea_room/B = rooms[j]
			if(rooms_are_adjacent(A, B))
				carve_corridor_between(A, B, z_level)

	var/list/themed_rooms = list(
		"showroom" = 4,
		"bedroom_display" = 3,
		"kitchen_display" = 3,
		"office_display" = 2,
		"bathroom_display" = 2,
		"storage_room" = 3,
		"dining_display" = 2,
		"staff_room" = 2,
		"survivor_camp" = 2,
		"checkout" = 1,
	)

	var/room_idx = 1
	for(var/datum/ikea_room/room as anything in rooms)
		var/theme
		if(room_idx <= length(rooms) / 2)
			theme = "showroom"
		else
			var/list/available = list()
			for(var/t in themed_rooms)
				if(themed_rooms[t] > 0)
					available += t
			if(length(available))
				theme = pick(available)
				themed_rooms[theme]--
			else
				theme = "showroom"

		furnish_themed_room(room, theme, z_level)
		place_room_sign(room, theme, z_level)

		var/door_count = room.width > 10 || room.height > 10 ? 2 : 1
		for(var/d in 1 to door_count)
			place_room_door(room, z_level)

		new /obj/machinery/light/small(locate(room.cx, room.cy, z_level))
		room_idx++

	for(var/datum/ikea_room/room as anything in rooms)
		if(prob(40))
			spawn_loot_in_room(room, z_level)

	spawn_ikea_staff(z_level)
	spawn_enhanced_loot(z_level)

	var/datum/ikea_room/entry_room = rooms[1]
	if(entry_room)
		entry_point = locate(entry_room.cx, entry_room.cy, z_level)
		if(!istype(entry_point, /turf/open/floor/wood))
			entry_point.ChangeTurf(/turf/open/floor/wood)
	else
		entry_point = locate(50, 50, z_level)
		if(entry_point)
			entry_point.ChangeTurf(/turf/open/floor/wood)

	world.log << "IKEA interior: BSP generation completed - [length(rooms)] rooms on z-level [z_level]"

/datum/ikea_sector
	var/x1
	var/y1
	var/x2
	var/y2

/datum/ikea_sector/New(x1, y1, x2, y2)
	src.x1 = x1
	src.y1 = y1
	src.x2 = x2
	src.y2 = y2

/datum/ikea_sector/proc/width()
	return x2 - x1

/datum/ikea_sector/proc/height()
	return y2 - y1

/datum/ikea_sector/proc/area()
	return width() * height()

/datum/ikea_room
	var/x1
	var/y1
	var/x2
	var/y2
	var/cx
	var/cy
	var/width
	var/height

/datum/ikea_room/New(x1, y1, x2, y2)
	src.x1 = x1
	src.y1 = y1
	src.x2 = x2
	src.y2 = y2
	src.width = x2 - x1
	src.height = y2 - y1
	src.cx = round((x1 + x2) / 2)
	src.cy = round((y1 + y2) / 2)

/datum/ikea_interior/proc/generate_bsp_sectors(split_depth, min_sector_w, max_w, min_sector_h, start_offset, z_level)
	var/datum/ikea_sector/root = new(start_offset, start_offset, start_offset + max_w, start_offset + max_w)
	var/list/leaves = list(root)

	for(var/d in 1 to split_depth)
		var/list/new_leaves = list()
		for(var/datum/ikea_sector/leaf as anything in leaves)
			if(leaf.area() < min_sector_w * min_sector_h * 4)
				new_leaves += leaf
				continue

			var/split_horz = leaf.width() > leaf.height() ? FALSE : leaf.height() > leaf.width() ? TRUE : prob(50)

			if(split_horz)
				if(leaf.height() < min_sector_h * 2)
					new_leaves += leaf
					continue
				var/split_at = leaf.y1 + rand(min_sector_h, leaf.height() - min_sector_h)
				new_leaves += new /datum/ikea_sector(leaf.x1, leaf.y1, leaf.x2, split_at)
				new_leaves += new /datum/ikea_sector(leaf.x1, split_at, leaf.x2, leaf.y2)
			else
				if(leaf.width() < min_sector_w * 2)
					new_leaves += leaf
					continue
				var/split_at = leaf.x1 + rand(min_sector_w, leaf.width() - min_sector_w)
				new_leaves += new /datum/ikea_sector(leaf.x1, leaf.y1, split_at, leaf.y2)
				new_leaves += new /datum/ikea_sector(split_at, leaf.y1, leaf.x2, leaf.y2)

		leaves = new_leaves

	return leaves

/datum/ikea_interior/proc/carve_room_in_sector(datum/ikea_sector/sector, z_level)
	var/pad_x = rand(1, 2)
	var/pad_y = rand(1, 2)
	var/rx1 = sector.x1 + pad_x
	var/ry1 = sector.y1 + pad_y
	var/rx2 = sector.x2 - rand(1, 2)
	var/ry2 = sector.y2 - rand(1, 2)

	if(rx2 - rx1 < 3 || ry2 - ry1 < 3)
		return null

	var/area/scp/ikea/ikea_area = interior_area
	for(var/x in rx1 to rx2)
		for(var/y in ry1 to ry2)
			var/turf/T = locate(x, y, z_level)
			if(T && istype(T, /turf/closed/wall))
				T.ChangeTurf(/turf/open/floor/wood)
				if(ikea_area)
					T.change_area(T.loc, ikea_area)

	return new /datum/ikea_room(rx1, ry1, rx2, ry2)

/datum/ikea_interior/proc/rooms_are_adjacent(datum/ikea_room/A, datum/ikea_room/B)
	var/gap = 3
	if(A.x2 + gap >= B.x1 && B.x2 + gap >= A.x1 && A.y2 + gap >= B.y1 && B.y2 + gap >= A.y1)
		return TRUE
	return FALSE

/datum/ikea_interior/proc/carve_corridor_between(datum/ikea_room/A, datum/ikea_room/B, z_level)
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

/datum/ikea_interior/proc/carve_h_corridor(x1, x2, y, z_level)
	var/low = min(x1, x2)
	var/high = max(x1, x2)
	var/area/scp/ikea/ikea_area = interior_area
	for(var/x in low to high)
		var/turf/T = locate(x, y, z_level)
		if(T && istype(T, /turf/closed/wall/mineral/wood))
			T.ChangeTurf(/turf/open/floor/wood)
			if(ikea_area)
				T.change_area(T.loc, ikea_area)
		var/turf/T2 = locate(x, y + 1, z_level)
		if(T2 && istype(T2, /turf/closed/wall/mineral/wood))
			T2.ChangeTurf(/turf/open/floor/wood)
			if(ikea_area)
				T2.change_area(T2.loc, ikea_area)

/datum/ikea_interior/proc/carve_v_corridor(y1, y2, x, z_level)
	var/low = min(y1, y2)
	var/high = max(y1, y2)
	var/area/scp/ikea/ikea_area = interior_area
	for(var/y in low to high)
		var/turf/T = locate(x, y, z_level)
		if(T && istype(T, /turf/closed/wall/mineral/wood))
			T.ChangeTurf(/turf/open/floor/wood)
			if(ikea_area)
				T.change_area(T.loc, ikea_area)
		var/turf/T2 = locate(x + 1, y, z_level)
		if(T2 && istype(T2, /turf/closed/wall/mineral/wood))
			T2.ChangeTurf(/turf/open/floor/wood)
			if(ikea_area)
				T2.change_area(T2.loc, ikea_area)

/datum/ikea_interior/proc/place_room_door(datum/ikea_room/room, z_level)
	var/list/candidates = list()

	for(var/x in room.x1 + 1 to room.x2 - 1)
		var/turf/wall_s = locate(x, room.y1, z_level)
		if(wall_s && istype(wall_s, /turf/closed/wall/mineral/wood))
			var/turf/below = locate(x, room.y1 - 1, z_level)
			if(below && istype(below, /turf/open/floor/wood))
				candidates += list(list("x" = x, "y" = room.y1))
		var/turf/wall_n = locate(x, room.y2, z_level)
		if(wall_n && istype(wall_n, /turf/closed/wall/mineral/wood))
			var/turf/above = locate(x, room.y2 + 1, z_level)
			if(above && istype(above, /turf/open/floor/wood))
				candidates += list(list("x" = x, "y" = room.y2))

	for(var/y in room.y1 + 1 to room.y2 - 1)
		var/turf/wall_w = locate(room.x1, y, z_level)
		if(wall_w && istype(wall_w, /turf/closed/wall/mineral/wood))
			var/turf/left = locate(room.x1 - 1, y, z_level)
			if(left && istype(left, /turf/open/floor/wood))
				candidates += list(list("x" = room.x1, "y" = y))
		var/turf/wall_e = locate(room.x2, y, z_level)
		if(wall_e && istype(wall_e, /turf/closed/wall/mineral/wood))
			var/turf/right = locate(room.x2 + 1, y, z_level)
			if(right && istype(right, /turf/open/floor/wood))
				candidates += list(list("x" = room.x2, "y" = y))

	if(!length(candidates))
		return

	var/list/pick = pick(candidates)
	var/turf/door_turf = locate(pick["x"], pick["y"], z_level)
	if(door_turf)
		door_turf.ChangeTurf(/turf/open/floor/wood)
		var/area/scp/ikea/ikea_area = interior_area
		if(ikea_area)
			door_turf.change_area(door_turf.loc, ikea_area)
		new /obj/structure/mineral_door/wood(door_turf)

/datum/ikea_interior/proc/place_room_sign(datum/ikea_room/room, theme, z_level)
	var/turf/sign_turf = locate(room.x1 + 1, room.y1 + 1, z_level)
	if(sign_turf && istype(sign_turf, /turf/open/floor/wood))
		new /obj/structure/sign/ikea(sign_turf, replace_text(theme))

/proc/replace_text(theme)
	switch(theme)
		if("showroom")
			return "Furniture Display"
		if("bedroom_display")
			return "Bedroom Display"
		if("kitchen_display")
			return "Kitchen Display"
		if("office_display")
			return "Office Display"
		if("bathroom_display")
			return "Bathroom Display"
		if("storage_room")
			return "Storage Area"
		if("dining_display")
			return "Dining Display"
		if("staff_room")
			return "Staff Only"
		if("survivor_camp")
			return "Survivor Shelter"
		if("checkout")
			return "Checkout"
	return "IKEA Section"

/datum/ikea_interior/proc/furnish_themed_room(datum/ikea_room/room, theme, z_level)
	switch(theme)
		if("showroom")
			furnish_showroom(room, z_level)
		if("bedroom_display")
			furnish_bedroom_display(room, z_level)
		if("kitchen_display")
			furnish_kitchen_display(room, z_level)
		if("office_display")
			furnish_office_display(room, z_level)
		if("bathroom_display")
			furnish_bathroom_display(room, z_level)
		if("storage_room")
			furnish_storage(room, z_level)
		if("dining_display")
			furnish_dining_display(room, z_level)
		if("staff_room")
			furnish_staff_room(room, z_level)
		if("survivor_camp")
			furnish_survivor_camp(room, z_level)
		if("checkout")
			furnish_checkout(room, z_level)

/datum/ikea_interior/proc/try_place(atom/type, x, y, z_level)
	var/turf/T = locate(x, y, z_level)
	if(T && istype(T, /turf/open/floor/wood))
		new type(T)
		return TRUE
	return FALSE

/datum/ikea_interior/proc/furnish_showroom(datum/ikea_room/room, z_level)
	for(var/y in room.y1 + 2 to room.y2 - 2 step 3)
		for(var/x in room.x1 + 2 to room.x2 - 2 step 3)
			var/turf/T = locate(x, y, z_level)
			if(!T || !istype(T, /turf/open/floor/wood))
				continue
			var/pick_furniture = pick(
				/obj/structure/chair,
				/obj/structure/table/wood,
				/obj/structure/bed/ikea,
				/obj/structure/closet,
				/obj/structure/rack,
				/obj/structure/chair,
				/obj/structure/table/wood,
			)
			new pick_furniture(T)
			if(prob(50))
				var/turf/T2 = locate(x + 1, y, z_level)
				if(T2 && istype(T2, /turf/open/floor/wood))
					new /obj/structure/chair(T2)
			if(prob(40))
				var/turf/T2 = locate(x, y + 1, z_level)
				if(T2 && istype(T2, /turf/open/floor/wood))
					new /obj/structure/display_case(T2)

/datum/ikea_interior/proc/furnish_bedroom_display(datum/ikea_room/room, z_level)
	var/y_offset = room.y1 + 2
	while(y_offset <= room.y2 - 3)
		try_place(/obj/structure/bed/ikea, room.x1 + 2, y_offset, z_level)
		try_place(/obj/structure/table/wood, room.x1 + 3, y_offset, z_level)
		if(prob(70))
			try_place(/obj/structure/closet/wardrobe/ikea, room.x2 - 2, y_offset, z_level)
		if(prob(60))
			try_place(/obj/structure/closet/wardrobe/ikea, room.x2 - 3, y_offset, z_level)
		try_place(/obj/structure/chair, room.x1 + 2, y_offset + 1, z_level)
		try_place(/obj/structure/rack, room.x2 - 2, y_offset + 1, z_level)
		if(prob(50))
			try_place(/obj/structure/bed/ikea, room.x1 + 5, y_offset, z_level)
			try_place(/obj/structure/table/wood, room.x1 + 6, y_offset, z_level)
		y_offset += 3

/datum/ikea_interior/proc/furnish_kitchen_display(datum/ikea_room/room, z_level)
	for(var/y in room.y1 + 2 to room.y2 - 2 step 2)
		try_place(/obj/structure/table/wood, room.x1 + 2, y, z_level)
		try_place(/obj/structure/table/wood, room.x1 + 3, y, z_level)
		if(prob(50))
			try_place(/obj/structure/table/wood, room.x1 + 4, y, z_level)
		if(prob(40))
			try_place(/obj/structure/sink, room.x2 - 2, y, z_level)
		if(prob(35))
			try_place(/obj/structure/rack, room.x2 - 3, y, z_level)
	try_place(/obj/structure/sink, room.x1 + 2, room.y1 + 2, z_level)
	var/turf/fridge_turf = locate(room.x2 - 2, room.y2 - 2, z_level)
	if(fridge_turf && istype(fridge_turf, /turf/open/floor/wood))
		var/obj/structure/closet/fridge = new(fridge_turf)
		fridge.name = "Refrigerator"
		new /obj/item/food/ikea_meatball(fridge)
		new /obj/item/food/ikea_meatball(fridge)
		new /obj/item/reagent_containers/food/drinks/waterbottle(fridge)
	for(var/col in 0 to min(2, room.width - 5))
		try_place(/obj/structure/rack, room.x1 + 2 + col * 2, room.y2 - 2, z_level)

/datum/ikea_interior/proc/furnish_office_display(datum/ikea_room/room, z_level)
	var/y_offset = room.y1 + 2
	while(y_offset <= room.y2 - 3)
		for(var/col in 0 to 1)
			try_place(/obj/structure/table/wood, room.x1 + 2 + col * 2, y_offset, z_level)
		try_place(/obj/structure/chair, room.x1 + 3, y_offset + 1, z_level)
		try_place(/obj/structure/closet, room.x2 - 2, y_offset, z_level)
		if(prob(60))
			try_place(/obj/structure/rack, room.x2 - 2, y_offset + 1, z_level)
		if(prob(50))
			try_place(/obj/structure/rack, room.x2 - 3, y_offset + 1, z_level)
		try_place(/obj/structure/chair, room.x1 + 5, y_offset + 1, z_level)
		y_offset += 3

/datum/ikea_interior/proc/furnish_bathroom_display(datum/ikea_room/room, z_level)
	for(var/y in room.y1 + 2 to room.y2 - 2 step 2)
		try_place(/obj/structure/toilet, room.x1 + 2, y, z_level)
		try_place(/obj/structure/sink, room.x2 - 2, y, z_level)
		if(prob(50) && room.width > 8)
			try_place(/obj/structure/sink, room.x1 + 4, y, z_level)
			try_place(/obj/structure/toilet, room.x2 - 4, y, z_level)
		if(prob(40))
			try_place(/obj/structure/chair, room.x1 + 3, y, z_level)

/datum/ikea_interior/proc/furnish_storage(datum/ikea_room/room, z_level)
	for(var/col in 1 to room.width - 2)
		if(prob(50))
			try_place(/obj/structure/rack, room.x1 + col, room.y1 + 2, z_level)
		if(prob(50))
			try_place(/obj/structure/rack, room.x1 + col, room.y2 - 2, z_level)
	for(var/row in 2 to room.height - 2)
		if(prob(40))
			try_place(/obj/structure/closet, room.x1 + 2, room.y1 + row, z_level)
		if(prob(40))
			try_place(/obj/structure/closet, room.x2 - 2, room.y1 + row, z_level)
	for(var/i in 1 to min(3, room.width * room.height / 20))
		var/bx = rand(room.x1 + 3, room.x2 - 3)
		var/by = rand(room.y1 + 3, room.y2 - 3)
		var/turf/T = locate(bx, by, z_level)
		if(T && istype(T, /turf/open/floor/wood) && !locate(/obj/structure) in T)
			new /obj/structure/closet(T)

/datum/ikea_interior/proc/furnish_dining_display(datum/ikea_room/room, z_level)
	var/y_offset = room.y1 + 2
	while(y_offset <= room.y2 - 4)
		for(var/dx in -1 to min(1, room.width - 5))
			try_place(/obj/structure/table/wood, room.cx + dx, y_offset, z_level)
		try_place(/obj/structure/chair, room.cx - 2, y_offset, z_level)
		try_place(/obj/structure/chair, room.cx + 2, y_offset, z_level)
		try_place(/obj/structure/chair, room.cx - 1, y_offset + 1, z_level)
		try_place(/obj/structure/chair, room.cx + 1, y_offset + 1, z_level)
		if(room.width > 10)
			for(var/dx in -1 to 1)
				try_place(/obj/structure/table/wood, room.cx + dx, y_offset + 3, z_level)
			try_place(/obj/structure/chair, room.cx - 2, y_offset + 3, z_level)
			try_place(/obj/structure/chair, room.cx + 2, y_offset + 3, z_level)
		y_offset += 5

/datum/ikea_interior/proc/furnish_staff_room(datum/ikea_room/room, z_level)
	for(var/col in 0 to min(2, room.width - 5))
		try_place(/obj/structure/table/wood, room.x1 + 2 + col, room.y1 + 2, z_level)
	try_place(/obj/structure/chair, room.x1 + 3, room.y1 + 3, z_level)
	try_place(/obj/structure/chair, room.x1 + 4, room.y1 + 3, z_level)
	try_place(/obj/structure/closet, room.x2 - 2, room.y1 + 2, z_level)
	try_place(/obj/structure/closet, room.x2 - 3, room.y1 + 2, z_level)
	for(var/col in 0 to min(1, room.width - 5))
		try_place(/obj/structure/bed/ikea, room.x1 + 2 + col * 3, room.y2 - 2, z_level)
		try_place(/obj/structure/table/wood, room.x1 + 3 + col * 3, room.y2 - 2, z_level)
	if(prob(70))
		var/turf/T = locate(room.cx, room.cy, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			var/mob/living/simple_animal/hostile/ikea_staff/staff = new(T)
			staff_entities += staff

/datum/ikea_interior/proc/furnish_survivor_camp(datum/ikea_room/room, z_level)
	var/bed_count = max(1, round(room.width / 4))
	for(var/i in 0 to bed_count - 1)
		try_place(/obj/structure/bed/ikea, room.x1 + 2 + i * 3, room.y1 + 2, z_level)
	try_place(/obj/structure/table/wood, room.x2 - 3, room.y1 + 2, z_level)
	var/turf/T = locate(room.x2 - 2, room.y1 + 2, z_level)
	if(T && istype(T, /turf/open/floor/wood))
		var/obj/structure/closet/supply = new(T)
		supply.name = "Survival Supplies"
		new /obj/item/food/ikea_meatball(supply)
		new /obj/item/food/ikea_meatball(supply)
		new /obj/item/food/ikea_meatball(supply)
		new /obj/item/reagent_containers/food/drinks/waterbottle(supply)
		new /obj/item/reagent_containers/food/drinks/waterbottle(supply)
		new /obj/item/flashlight/ikea(supply)
		new /obj/item/stack/medical/bruise_pack(supply)
		new /obj/item/healthanalyzer(supply)
	try_place(/obj/structure/rack, room.x1 + 2, room.y2 - 2, z_level)
	try_place(/obj/structure/rack, room.x1 + 3, room.y2 - 2, z_level)
	var/turf/clock_turf = locate(room.x1 + 1, room.y2 - 2, z_level)
	if(clock_turf && istype(clock_turf, /turf/open/floor/wood))
		var/obj/structure/ikea_clock/clock = new(clock_turf)
		clock.linked_interior = src
	try_place(/obj/structure/chair, room.cx, room.y2 - 2, z_level)
	try_place(/obj/structure/chair, room.cx + 1, room.y2 - 2, z_level)

/datum/ikea_interior/proc/furnish_checkout(datum/ikea_room/room, z_level)
	var/mid_x = room.cx
	for(var/dy in 0 to min(1, room.height - 4))
		try_place(/obj/structure/table/wood, mid_x, room.y1 + 2 + dy, z_level)
		try_place(/obj/structure/table/wood, mid_x + 2, room.y1 + 2 + dy, z_level)
	try_place(/obj/structure/chair, mid_x + 1, room.y1 + 3, z_level)
	for(var/col in 0 to min(2, room.width - 5))
		try_place(/obj/structure/rack, room.x1 + 2 + col, room.y2 - 2, z_level)
		if(prob(40))
			try_place(/obj/structure/closet, room.x1 + 2 + col, room.y2 - 3, z_level)

/datum/ikea_interior/proc/spawn_loot_in_room(datum/ikea_room/room, z_level)
	var/loot_kind = pick("food", "food", "tools", "medical")
	var/turf/T = locate(room.cx, room.cy, z_level)
	if(T && istype(T, /turf/open/floor/wood))
		switch(loot_kind)
			if("food")
				spawn_loot_cache(T)
			if("tools")
				spawn_tool_cache(T)
			if("medical")
				spawn_medical_cache(T)

/datum/ikea_interior/proc/spawn_loot_cache(turf/T)
	var/obj/structure/closet/crate = new /obj/structure/closet(T)
	crate.name = "IKEA Supply Crate"
	for(var/i in 1 to rand(2, 4))
		var/food_choice = pick(1, 2, 3, 4, 5)
		switch(food_choice)
			if(1)
				new /obj/item/food/bread(crate)
			if(2)
				new /obj/item/food/cheese(crate)
			if(3)
				new /obj/item/food/meat(crate)
			if(4)
				new /obj/item/food/candy(crate)
			if(5)
				new /obj/item/food/chips(crate)
	for(var/i in 1 to rand(1, 3))
		new /obj/item/reagent_containers/food/drinks/waterbottle(crate)

/datum/ikea_interior/proc/spawn_tool_cache(turf/T)
	var/obj/structure/closet/crate = new /obj/structure/closet(T)
	crate.name = "IKEA Tool Crate"
	for(var/i in 1 to rand(2, 4))
		var/tool_choice = pick(1, 2, 3, 4, 5)
		switch(tool_choice)
			if(1)
				new /obj/item/crowbar(crate)
			if(2)
				new /obj/item/wrench(crate)
			if(3)
				new /obj/item/screwdriver(crate)
			if(4)
				new /obj/item/wirecutters(crate)
			if(5)
				new /obj/item/multitool(crate)

/datum/ikea_interior/proc/spawn_medical_cache(turf/T)
	var/obj/structure/closet/crate = new /obj/structure/closet(T)
	crate.name = "IKEA Medical Crate"
	for(var/i in 1 to rand(2, 4))
		var/medical_choice = pick(1, 2, 3, 4)
		switch(medical_choice)
			if(1)
				new /obj/item/stack/medical/bruise_pack(crate)
			if(2)
				new /obj/item/stack/medical/ointment(crate)
			if(3)
				new /obj/item/reagent_containers/hypospray/medipen(crate)
			if(4)
				new /obj/item/healthanalyzer(crate)

/datum/ikea_interior/proc/spawn_ikea_staff(z_level)
	for(var/i in 1 to 3)
		var/turf/spawn_turf = locate(rand(10, 90), rand(10, 90), z_level)
		if(spawn_turf && istype(spawn_turf, /turf/open/floor/wood))
			var/mob/living/simple_animal/hostile/ikea_staff/staff = new(spawn_turf)
			staff_entities += staff
	for(var/i in 1 to 2)
		var/turf/spawn_turf = locate(rand(10, 90), rand(10, 90), z_level)
		if(spawn_turf && istype(spawn_turf, /turf/open/floor/wood))
			var/mob/living/simple_animal/hostile/ikea_security/security = new(spawn_turf)
			staff_entities += security
	var/turf/manager_turf = locate(rand(10, 90), rand(10, 90), z_level)
	if(manager_turf && istype(manager_turf, /turf/open/floor/wood))
		var/mob/living/simple_animal/hostile/ikea_manager/manager = new(manager_turf)
		staff_entities += manager

/datum/ikea_interior/proc/get_entry_point()
	return entry_point

/mob/living/simple_animal/hostile/ikea_staff
	name = "IKEA Staff"
	desc = "A hostile IKEA staff member. They don't seem friendly."
	icon = 'icons/scp/ikea.dmi'
	icon_state = "staff"
	icon_living = "staff"
	icon_dead = "staff_dead"
	health = 100
	maxHealth = 100
	melee_damage_lower = 15
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("ikea_staff")

/mob/living/simple_animal/hostile/ikea_staff/Initialize()
	. = ..()
	icon_state = pick("staff", "staff_heavy")

/mob/living/simple_animal/hostile/ikea_staff/AttackingTarget(atom/attacked_target)
	. = ..()
	if(ishuman(attacked_target))
		hook_scp_combat(attacked_target, "SCP-3008", 20, 0)

/mob/living/simple_animal/hostile/ikea_staff/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.faction == faction)
			return FALSE
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/ikea_security
	name = "IKEA Security"
	desc = "A hostile IKEA security guard. They're armed and dangerous."
	icon = 'icons/scp/ikea.dmi'
	icon_state = "security"
	icon_living = "security"
	icon_dead = "security_dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("ikea_staff")

/mob/living/simple_animal/hostile/ikea_security/AttackingTarget(atom/attacked_target)
	. = ..()
	if(ishuman(attacked_target))
		hook_scp_combat(attacked_target, "SCP-3008", 20, 0)

/mob/living/simple_animal/hostile/ikea_security/Initialize()
	. = ..()
	icon_state = pick("security", "security2", "security_armed")

/mob/living/simple_animal/hostile/ikea_manager
	name = "IKEA Manager"
	desc = "A hostile IKEA manager. They seem to be in charge and very aggressive."
	icon = 'icons/scp/ikea.dmi'
	icon_state = "manager"
	icon_living = "manager"
	icon_dead = "manager_dead"
	health = 200
	maxHealth = 200
	melee_damage_lower = 25
	melee_damage_upper = 35
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("ikea_staff")

/mob/living/simple_animal/hostile/ikea_manager/AttackingTarget(atom/attacked_target)
	. = ..()
	if(ishuman(attacked_target))
		hook_scp_combat(attacked_target, "SCP-3008", 20, 0)

/mob/living/simple_animal/hostile/ikea_manager/Initialize()
	. = ..()
	icon_state = "manager"

/obj/effect/landmark/ikea_entrance
	name = "IKEA Entrance"
	desc = "A landmark marking the entrance to SCP-3008."
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"

/obj/structure/bed/ikea
	name = "IKEA Bed"
	desc = "A comfortable IKEA bed. It looks well-made."
	icon = 'icons/obj/structures.dmi'
	icon_state = "bed"

/obj/structure/closet/wardrobe/ikea
	name = "IKEA Wardrobe"
	desc = "A stylish IKEA wardrobe."
	icon = 'icons/obj/closet.dmi'
	icon_state = "wardrobe"

/obj/structure/table/wood/ikea
	name = "Wooden Table"
	desc = "A sturdy wooden table."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"

/obj/structure/sign/ikea
	name = "IKEA Section Sign"
	desc = "A sign indicating the IKEA section."
	icon = 'icons/obj/decals.dmi'
	icon_state = "sign"
	var/section_name = "IKEA Section"

/obj/structure/sign/ikea/New(loc, new_section_name)
	. = ..()
	if(new_section_name)
		section_name = new_section_name
		name = "[section_name] Sign"
		desc = "A sign indicating the [section_name]."

/obj/structure/display_case/ikea
	name = "Display Case"
	desc = "A glass display case for showcasing products."
	icon = 'icons/obj/structures.dmi'
	icon_state = "display_case"

/obj/structure/plant_pot
	name = "Plant Pot"
	desc = "A decorative plant pot with artificial plants."
	icon = 'icons/obj/structures.dmi'
	icon_state = "plant_pot"

/mob/living/carbon/human/proc/escape_ikea()
	set name = "Try to Escape IKEA"
	set category = "IKEA"
	set desc = "Attempt to escape from the infinite IKEA."

	var/datum/ikea_interior/current_interior = get_ikea_interior()
	if(!current_interior)
		to_chat(src, "<span class='warning'>You are not in an IKEA interior.</span>")
		return

	var/turf/current_turf = get_turf(src)
	if(current_turf && current_interior.entry_point && get_dist(current_turf, current_interior.entry_point) <= 5)
		if(current_interior.parent_entrance && current_interior.parent_entrance.loc)
			forceMove(get_turf(current_interior.parent_entrance))
			to_chat(src, "<span class='notice'>You successfully escape from the infinite IKEA!</span>")
			current_interior.remove_occupant(src)

			if(SSscp_research && SSscp_research.manager)
				award_research_points("SCP-3008", "escape", 10, ckey)
		else
			var/turf/safe_turf = pick(GLOB.station_turfs)
			if(safe_turf)
				forceMove(safe_turf)
				to_chat(src, "<span class='notice'>You are teleported to safety.</span>")
				current_interior.remove_occupant(src)
	else
		to_chat(src, "<span class='warning'>You need to be closer to the entrance to escape. The IKEA seems to be shifting around you...</span>")

/mob/living/carbon/human/proc/get_ikea_interior()
	for(var/obj/structure/scp3008/entrance in GLOB.scp3008_entrances)
		if(entrance.ikea_interiors)
			for(var/datum/ikea_interior/interior in entrance.ikea_interiors)
				if(src in interior.occupants)
					return interior
	return null

/mob/living/carbon/human/proc/ikea_survival_tips()
	set name = "IKEA Survival Tips"
	set category = "IKEA"
	set desc = "Get tips for surviving in the infinite IKEA."

	to_chat(src, "<span class='notice'><b>IKEA Survival Tips:</b></span>")
	to_chat(src, "<span class='notice'>• Avoid IKEA staff - they are hostile and will attack you</span>")
	to_chat(src, "<span class='notice'>• Look for resources like food, water, and tools</span>")
	to_chat(src, "<span class='notice'>• The labyrinth layout constantly shifts - don't rely on landmarks</span>")
	to_chat(src, "<span class='notice'>• Find the entrance area to escape (near coordinates 50,50)</span>")
	to_chat(src, "<span class='notice'>• Work with other survivors to increase your chances</span>")
	to_chat(src, "<span class='notice'>• Look for section signs to navigate the maze</span>")
	to_chat(src, "<span class='notice'>• The maze has open areas for different IKEA sections</span>")
	to_chat(src, "<span class='notice'>• Use furniture and objects as cover from staff</span>")

/datum/ikea_interior/proc/add_occupant(mob/living/carbon/human/occupant)
	if(occupant && !(occupant in occupants))
		occupants += occupant
		occupant.verbs += /mob/living/carbon/human/proc/escape_ikea
		occupant.verbs += /mob/living/carbon/human/proc/ikea_survival_tips
		occupant.verbs += /mob/living/carbon/human/proc/debug_ikea_interior
		hook_scp_interaction(occupant, "SCP-3008", INTERACTION_TYPE_EXPLORATION)

/datum/ikea_interior/proc/remove_occupant(mob/living/carbon/human/occupant)
	if(occupant in occupants)
		occupants -= occupant
		occupant.verbs -= /mob/living/carbon/human/proc/escape_ikea
		occupant.verbs -= /mob/living/carbon/human/proc/ikea_survival_tips
		occupant.verbs -= /mob/living/carbon/human/proc/debug_ikea_interior

/mob/living/carbon/human/proc/debug_ikea_interior()
	set name = "Debug IKEA Interior"
	set category = "IKEA"
	set desc = "Debug information about current IKEA interior."

	var/datum/ikea_interior/current_interior = get_ikea_interior()
	if(!current_interior)
		to_chat(src, "<span class='warning'>You are not in an IKEA interior.</span>")
		return

	var/turf/current_turf = get_turf(src)
	to_chat(src, "<span class='notice'><b>IKEA Interior Debug Info:</b></span>")
	to_chat(src, "<span class='notice'>Interior ID: [current_interior.id]</span>")
	to_chat(src, "<span class='notice'>Current Position: [current_turf.x], [current_turf.y], [current_turf.z]</span>")
	to_chat(src, "<span class='notice'>Entry Point: [current_interior.entry_point ? "[current_interior.entry_point.x], [current_interior.entry_point.y], [current_interior.entry_point.z]" : "NULL"]</span>")
	to_chat(src, "<span class='notice'>Occupants: [length(current_interior.occupants)]</span>")
	to_chat(src, "<span class='notice'>IKEA Turfs: [length(current_interior.ikea_turfs)]</span>")

/datum/ikea_interior/proc/process_day_night()
	cycle_timer += 2 SECONDS

	if(!is_night && cycle_timer >= cycle_duration)
		begin_night()
	else if(is_night && cycle_timer >= cycle_duration * 1.5)
		begin_day()

	if(!is_night && cycle_timer >= cycle_duration - 30 SECONDS && !night_warning_given)
		night_warning_given = TRUE
		for(var/mob/living/carbon/human/H in occupants)
			if(H.client)
				to_chat(H, "<span class='warning'>The lights in the store are beginning to flicker... Night is approaching.</span>")
				SEND_SOUND(H, sound('sound/effects/bamf.ogg'))

/datum/ikea_interior/proc/begin_night()
	is_night = TRUE
	cycle_timer = 0
	night_warning_given = FALSE

	for(var/mob/living/carbon/human/H in occupants)
		if(H.client)
			to_chat(H, "<span class='danger'>The lights go out. The IKEA staff are becoming aggressive...</span>")
			SEND_SOUND(H, sound('sound/effects/bamf.ogg'))

	for(var/mob/living/simple_animal/hostile/ikea_staff/staff in staff_entities)
		if(staff && !QDELETED(staff))
			staff.melee_damage_lower = initial(staff.melee_damage_lower) + 10
			staff.melee_damage_upper = initial(staff.melee_damage_upper) + 15
			staff.move_to_delay = max(3, staff.move_to_delay - 2)

/datum/ikea_interior/proc/begin_day()
	is_night = FALSE
	cycle_timer = 0

	for(var/mob/living/carbon/human/H in occupants)
		if(H.client)
			to_chat(H, "<span class='notice'>The lights come back on. The staff seem calmer now... but the layout has changed.</span>")

	for(var/mob/living/simple_animal/hostile/ikea_staff/staff in staff_entities)
		if(staff && !QDELETED(staff))
			staff.melee_damage_lower = initial(staff.melee_damage_lower)
			staff.melee_damage_upper = initial(staff.melee_damage_upper)
			staff.move_to_delay = initial(staff.move_to_delay)

	shift_layout()

/datum/ikea_interior/proc/shift_layout()
	if(!entry_point)
		return
	var/shift_count = rand(2, 5)
	for(var/i in 1 to shift_count)
		var/shift_x = rand(20, 80)
		var/shift_y = rand(20, 80)
		var/turf/T = locate(shift_x, shift_y, entry_point.z)
		if(!T)
			continue
		if(istype(T, /turf/closed/wall/mineral/wood))
			var/nearby_human = FALSE
			for(var/mob/living/carbon/human/H in range(5, T))
				if(H in occupants)
					nearby_human = TRUE
					break
			if(!nearby_human)
				T.ChangeTurf(/turf/open/floor/wood)
		else if(istype(T, /turf/open/floor/wood))
			var/nearby_human = FALSE
			for(var/mob/living/carbon/human/H in range(5, T))
				if(H in occupants)
					nearby_human = TRUE
					break
			if(!nearby_human)
				T.ChangeTurf(/turf/closed/wall/mineral/wood)

/mob/living/simple_animal/hostile/ikea_staff/proc/check_night_behavior()
	for(var/obj/structure/scp3008/entrance in GLOB.scp3008_entrances)
		for(var/datum/ikea_interior/interior in entrance.ikea_interiors)
			if(src in interior.staff_entities)
				if(interior.is_night)
					vision_range = 12
					aggro_vision_range = 12
				else
					vision_range = 7
					aggro_vision_range = 7
				break

/obj/item/flashlight/ikea
	name = "IKEA Flashlight"
	desc = "A flashlight from the IKEA lighting section. Essential for surviving the night."
	light_outer_range = 5
	light_power = 0.5

/obj/item/food/ikea_meatball
	name = "IKEA Meatball"
	desc = "A surprisingly satisfying Swedish meatball. Restores some health."
	icon_state = "meatball"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("swedish meatball" = 1)

/obj/structure/sign/ikea_shelter
	name = "Survivor Shelter Sign"
	desc = "A makeshift sign indicating a survivor shelter. Safe from staff during the day."
	icon = 'icons/obj/decals.dmi'
	icon_state = "sign"

/obj/structure/ikea_clock
	name = "IKEA Wall Clock"
	desc = "A large wall clock. The hands seem to move at their own pace..."
	icon = 'icons/obj/structures.dmi'
	icon_state = "clock"
	anchored = TRUE
	density = FALSE
	var/datum/ikea_interior/linked_interior

/obj/structure/ikea_clock/examine(mob/user)
	. = ..()
	if(linked_interior)
		if(linked_interior.is_night)
			to_chat(user, "<span class='danger'>It is NIGHT. The staff are hostile.</span>")
		else
			var/time_left = max(0, linked_interior.cycle_duration - linked_interior.cycle_timer)
			to_chat(user, "<span class='notice'>It is DAY. Night falls in [DisplayTimeText(time_left)].</span>")
	else
		to_chat(user, "<span class='notice'>The clock is not connected to an interior.</span>")

/datum/ikea_interior/proc/spawn_enhanced_loot(z_level)
	for(var/i in 1 to 4)
		var/loot_x = rand(20, 80)
		var/loot_y = rand(20, 80)
		var/turf/T = locate(loot_x, loot_y, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			var/loot_type = pick(
				/obj/item/flashlight/ikea,
				/obj/item/food/ikea_meatball,
				/obj/item/food/ikea_meatball,
				/obj/item/reagent_containers/food/drinks/waterbottle,
			)
			new loot_type(T)
			resource_spawns += locate(loot_type) in T

	for(var/i in 1 to 2)
		var/clock_x = rand(25, 75)
		var/clock_y = rand(25, 75)
		var/turf/T = locate(clock_x, clock_y, z_level)
		if(T && istype(T, /turf/open/floor/wood))
			var/obj/structure/ikea_clock/clock = new(T)
			clock.linked_interior = src
