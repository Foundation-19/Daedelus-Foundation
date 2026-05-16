// SCP Zone Lighting Profiles
// Light fixture subtypes for thematic zone lighting and D-Class flicker system

// ============================================================================
// LCZ - Clinical bright blue-white lighting
// ============================================================================

/obj/machinery/light/lcz
	bulb_colour = "#d4e4ff"
	bulb_power = 0.7
	bulb_outer_range = 9
	bulb_falloff = 1.8

/obj/machinery/light/lcz/corridor
	bulb_colour = "#d4e4ff"
	bulb_power = 0.65

/obj/machinery/light/lcz/containment
	bulb_colour = "#c8d8f0"
	bulb_power = 0.6
	bulb_outer_range = 7

/obj/machinery/light/lcz/observation
	bulb_colour = "#e0ecff"
	bulb_power = 0.75
	bulb_outer_range = 10

/obj/machinery/light/lcz/medical
	bulb_colour = "#e8f0ff"
	bulb_power = 0.8
	bulb_outer_range = 10

// ============================================================================
// HCZ - Dim industrial amber lighting
// ============================================================================

/obj/machinery/light/hcz
	bulb_colour = "#8a7a5a"
	bulb_power = 0.45
	bulb_outer_range = 7
	bulb_falloff = 2.0

/obj/machinery/light/hcz/corridor
	bulb_colour = "#7a6a4a"
	bulb_power = 0.4
	bulb_outer_range = 6

/obj/machinery/light/hcz/keter_containment
	bulb_colour = "#6a5a3a"
	bulb_power = 0.35
	bulb_outer_range = 6

/obj/machinery/light/hcz/observation
	bulb_colour = "#8a7a5a"
	bulb_power = 0.5
	bulb_outer_range = 8

/obj/machinery/light/hcz/server_room
	bulb_colour = "#4a5a6a"
	bulb_power = 0.35
	bulb_outer_range = 6

// ============================================================================
// EZ - Standard warm office lighting
// ============================================================================

/obj/machinery/light/ez
	bulb_colour = LIGHTBULB_COLOR_SLIGHTLY_WARM
	bulb_power = 0.65
	bulb_outer_range = 9
	bulb_falloff = 1.85

/obj/machinery/light/ez/lobby
	bulb_colour = "#fffee0"
	bulb_power = 0.7
	bulb_outer_range = 10

/obj/machinery/light/ez/offices
	bulb_colour = LIGHTBULB_COLOR_WARM
	bulb_power = 0.6

// ============================================================================
// D-Class - Flickering cold yellow light
// ============================================================================

/obj/machinery/light/dclass
	bulb_colour = "#a09060"
	bulb_power = 0.4
	bulb_outer_range = 6
	bulb_falloff = 2.2
	var/flicker_chance = 4
	var/next_flicker_check = 0
	var/flicker_check_interval = 5 SECONDS

/obj/machinery/light/dclass/process()
	. = ..()
	if(world.time < next_flicker_check)
		return
	next_flicker_check = world.time + flicker_check_interval
	if(on && prob(flicker_chance))
		flicker(rand(2, 6))

/obj/machinery/light/dclass/cell_block
	bulb_colour = "#8a7a50"
	bulb_power = 0.3
	bulb_outer_range = 5
	flicker_chance = 8

/obj/machinery/light/dclass/recreation
	bulb_colour = "#b0a070"
	bulb_power = 0.5
	bulb_outer_range = 7
	flicker_chance = 2

// ============================================================================
// Surface - Natural outdoor lighting
// ============================================================================

/obj/machinery/light/surface
	bulb_colour = LIGHTBULB_COLOR_WHITE
	bulb_power = 0.7
	bulb_outer_range = 9
	bulb_falloff = 1.8

// ============================================================================
// Emergency - Red warning lighting (for breach lockdown)
// ============================================================================

/obj/machinery/light/emergency_red
	bulb_colour = "#8b0000"
	bulb_power = 0.3
	bulb_outer_range = 5
	bulb_falloff = 2.5

// ============================================================================
// Zone lighting control proc
// ============================================================================

/proc/set_zone_emergency_lighting(zone_name, enable = TRUE)
	var/list/target_areas = list()
	switch(zone_name)
		if("lcz")
			target_areas = typesof(/area/scp/lcz)
		if("hcz")
			target_areas = typesof(/area/scp/hcz)
		if("ez")
			target_areas = typesof(/area/scp/ez)
		if("dclass")
			target_areas = typesof(/area/scp/dclass)
		if("surface")
			target_areas = typesof(/area/scp/surface)
		else
			return

	for(var/area_type in target_areas)
		for(var/area/A in GLOB.areas)
			if(!istype(A, area_type))
				continue
			for(var/obj/machinery/light/L in A)
				if(QDELETED(L) || !L.has_power())
					continue
				if(enable)
					L.bulb_colour = "#8b0000"
					L.bulb_power = 0.3
					L.bulb_outer_range = 5
				else
					L.bulb_colour = initial(L.bulb_colour)
					L.bulb_power = initial(L.bulb_power)
					L.bulb_outer_range = initial(L.bulb_outer_range)
				L.update(TRUE)
