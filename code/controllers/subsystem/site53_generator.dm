SUBSYSTEM_DEF(site53_generator)
	name = "Site-53 Generator"
	init_order = INIT_ORDER_MINOR_MAPPING
	flags = SS_NO_FIRE
	var/datum/site53_builder/builder

/datum/controller/subsystem/site53_generator/Initialize(time)
	return ..()

/datum/site53_builder
	var/z_level
	var/center_x = 128
	var/center_y = 128
	var/facility_width = 60
	var/facility_height = 50

/datum/site53_builder/proc/build_site()
	if(!SSmapping)
		return

	z_level = SSmapping.station_start
	if(!z_level)
		z_level = 2

	var/sx = center_x - round(facility_width / 2)
	var/sy = center_y - round(facility_height / 2)

	build_perimeter(sx, sy)
	build_lcz(sx + 2, sy + 2)
	build_hcz(sx + 2, sy + 20)
	build_ez(sx + 20, sy + 38)
	build_dclass_block(sx + 35, sy + 2)
	build_corridors(sx, sy)
	place_equipment(sx, sy)

/datum/site53_builder/proc/build_perimeter(sx, sy)
	for(var/x = sx to sx + facility_width)
		for(var/y in list(sy, sy + facility_height))
			var/turf/T = locate(x, y, z_level)
			if(T)
				T.ChangeTurf(/turf/closed/indestructible/riveted)
	for(var/y = sy to sy + facility_height)
		for(var/x in list(sx, sx + facility_width))
			var/turf/T = locate(x, y, z_level)
			if(T)
				T.ChangeTurf(/turf/closed/indestructible/riveted)

/datum/site53_builder/proc/build_room(x1, y1, x2, y2, floor_type, wall_type, area_type, door_x, door_y)
	for(var/x = x1 to x2)
		var/turf/T_top = locate(x, y1, z_level)
		var/turf/T_bot = locate(x, y2, z_level)
		if(T_top)
			T_top.ChangeTurf(wall_type || /turf/closed/wall/r_wall)
		if(T_bot)
			T_bot.ChangeTurf(wall_type || /turf/closed/wall/r_wall)
	for(var/y = y1 to y2)
		var/turf/T_left = locate(x1, y, z_level)
		var/turf/T_right = locate(x2, y, z_level)
		if(T_left)
			T_left.ChangeTurf(wall_type || /turf/closed/wall/r_wall)
		if(T_right)
			T_right.ChangeTurf(wall_type || /turf/closed/wall/r_wall)
	for(var/x = x1 + 1 to x2 - 1)
		for(var/y = y1 + 1 to y2 - 1)
			var/turf/T = locate(x, y, z_level)
			if(T)
				T.ChangeTurf(floor_type || /turf/open/floor/iron)
				if(area_type)
					T.change_area(T.loc, new area_type)
	if(door_x && door_y)
		var/turf/door_turf = locate(door_x, door_y, z_level)
		if(door_turf)
			door_turf.ChangeTurf(/turf/open/floor/iron)
			new /obj/machinery/door/airlock/scp(door_turf)

/datum/site53_builder/proc/build_lcz(sx, sy)
	build_room(sx, sy, sx + 8, sy + 8, /turf/open/floor/iron, /turf/closed/wall/r_wall, /area/scp/lcz/safe_containment, sx + 4, sy)
	build_room(sx + 10, sy, sx + 18, sy + 8, /turf/open/floor/iron, /turf/closed/wall/r_wall, /area/scp/lcz/euclid_containment, sx + 14, sy)
	build_room(sx, sy + 10, sx + 12, sy + 17, /turf/open/floor/iron, /turf/closed/wall/r_wall, /area/scp/lcz/testing_lab, sx + 6, sy + 10)
	build_room(sx + 14, sy + 10, sx + 18, sy + 17, /turf/open/floor/iron, /turf/closed/wall/r_wall, /area/scp/lcz/observation, sx + 16, sy + 10)

/datum/site53_builder/proc/build_hcz(sx, sy)
	build_room(sx, sy, sx + 10, sy + 8, /turf/open/floor/engine, /turf/closed/wall/r_wall, /area/scp/hcz/keter_containment, sx + 5, sy)
	build_room(sx + 12, sy, sx + 20, sy + 8, /turf/open/floor/engine, /turf/closed/wall/r_wall, /area/scp/hcz/euclid_containment, sx + 16, sy)
	build_room(sx, sy + 10, sx + 8, sy + 17, /turf/open/floor/iron, /turf/closed/wall/r_wall, /area/scp/hcz/armory, sx + 4, sy + 10)
	build_room(sx + 10, sy + 10, sx + 20, sy + 17, /turf/open/floor/iron, /turf/closed/wall/r_wall, /area/scp/hcz/server_room, sx + 15, sy + 10)

/datum/site53_builder/proc/build_ez(sx, sy)
	build_room(sx, sy, sx + 15, sy + 10, /turf/open/floor/iron, /turf/closed/wall, /area/scp/ez/lobby, sx + 7, sy)
	build_room(sx + 17, sy, sx + 25, sy + 10, /turf/open/floor/iron, /turf/closed/wall, /area/scp/ez/offices, sx + 21, sy)
	build_room(sx, sy + 12, sx + 12, sy + 18, /turf/open/floor/iron, /turf/closed/wall, /area/scp/ez/briefing, sx + 6, sy + 12)

/datum/site53_builder/proc/build_dclass_block(sx, sy)
	build_room(sx, sy, sx + 10, sy + 8, /turf/open/floor/iron, /turf/closed/wall, /area/scp/dclass/cell_block, sx + 5, sy)
	build_room(sx + 12, sy, sx + 20, sy + 8, /turf/open/floor/iron, /turf/closed/wall, /area/scp/dclass/recreation, sx + 16, sy)
	build_room(sx, sy + 10, sx + 12, sy + 17, /turf/open/floor/iron, /turf/closed/wall, /area/scp/dclass/cafeteria, sx + 6, sy + 10)
	build_room(sx + 14, sy + 10, sx + 20, sy + 17, /turf/open/floor/iron, /turf/closed/wall, /area/scp/dclass/testing_chamber, sx + 17, sy + 10)
	new /obj/structure/dclass_escape_point/vent(locate(sx + 19, sy + 16, z_level))
	new /obj/structure/dclass_escape_point/maintenance(locate(sx + 1, sy + 16, z_level))

/datum/site53_builder/proc/build_corridors(sx, sy)
	for(var/x = sx + 1 to sx + facility_width - 1)
		var/turf/T1 = locate(x, sy + 18, z_level)
		var/turf/T2 = locate(x, sy + 36, z_level)
		if(T1)
			T1.ChangeTurf(/turf/open/floor/iron)
			T1.change_area(T1.loc, new /area/scp/lcz/corridor)
		if(T2)
			T2.ChangeTurf(/turf/open/floor/iron)
			T2.change_area(T2.loc, new /area/scp/hcz/corridor)
	for(var/y = sy + 1 to sy + facility_height - 1)
		var/turf/T1 = locate(sx + 30, y, z_level)
		if(T1)
			T1.ChangeTurf(/turf/open/floor/iron)
			var/area/A
			if(y < sy + 18)
				A = new /area/scp/lcz/corridor
			else if(y < sy + 36)
				A = new /area/scp/hcz/corridor
			else
				A = new /area/scp/ez/corridor
			T1.change_area(T1.loc, A)

/datum/site53_builder/proc/place_equipment(sx, sy)
	var/list/apc_positions = list(
		list(center_x - 15, center_y - 10),
		list(center_x + 15, center_y - 10),
		list(center_x - 15, center_y + 10),
		list(center_x + 15, center_y + 10),
	)
	for(var/list/pos in apc_positions)
		var/turf/T = locate(pos[1], pos[2], z_level)
		if(T)
			new /obj/machinery/power/apc(T)

/obj/machinery/door/airlock/scp
	name = "Containment Airlock"
	desc = "A heavy-duty airlock for SCP containment areas."
	icon = 'icons/obj/doors/airlocks/highsec/airlock.dmi'
	security_level = 6

/obj/machinery/door/airlock/scp/Initialize()
	. = ..()
	req_access = list(ACCESS_SCIENCE)

/obj/structure/dclass_bunk
	name = "D-Class Bunk"
	desc = "A simple metal bunk. Not very comfortable."
	icon = 'icons/obj/structures.dmi'
	icon_state = "bed"
	anchored = TRUE
	density = FALSE

/obj/structure/dclass_bunk/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	to_chat(H, "<span class='notice'>You rest on the bunk for a moment.</span>")
	H.stamina.adjust(20)
