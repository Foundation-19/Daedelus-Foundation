/datum/zone_lighting_controller
	var/zone_id
	var/current_color
	var/target_color
	var/list/color_sequence
	var/transition_speed = 1
	var/sequence_index = 1
	var/sequence_delay = 10
	var/next_sequence_step = 0
	var/list/managed_lights
	var/active = FALSE

/datum/zone_lighting_controller/New(zone)
	zone_id = zone
	current_color = get_default_color()
	target_color = current_color

/datum/zone_lighting_controller/proc/get_default_color()
	switch(zone_id)
		if("lcz")
			return "#d4e4ff"
		if("hcz")
			return "#8a7a5a"
		if("ez")
			return LIGHTBULB_COLOR_SLIGHTLY_WARM
		if("surface")
			return LIGHTBULB_COLOR_WHITE
		else
			return LIGHTBULB_COLOR_WHITE

/datum/zone_lighting_controller/proc/set_color(new_color)
	target_color = new_color
	if(!active)
		active = TRUE
		START_PROCESSING(SSprocessing, src)

/datum/zone_lighting_controller/proc/animate_color_sequence(list/sequence, speed, delay)
	color_sequence = sequence
	transition_speed = speed
	sequence_delay = delay
	sequence_index = 1
	next_sequence_step = world.time
	target_color = color_sequence[1]
	if(!active)
		active = TRUE
		START_PROCESSING(SSprocessing, src)

/datum/zone_lighting_controller/process(delta_time)
	if(current_color != target_color)
		current_color = transition_color(current_color, target_color, transition_speed)
		apply_color_to_lights()
	if(color_sequence && length(color_sequence))
		if(world.time >= next_sequence_step)
			sequence_index = (sequence_index % length(color_sequence)) + 1
			target_color = color_sequence[sequence_index]
			next_sequence_step = world.time + sequence_delay
	if(current_color == target_color && (!color_sequence || !length(color_sequence)))
		active = FALSE
		return PROCESS_KILL

/datum/zone_lighting_controller/proc/transition_color(from_color, to_color, steps)
	var/list/from_rgb = rgb2num(from_color)
	var/list/to_rgb = rgb2num(to_color)
	var/list/result = list()
	for(var/i = 1 to 3)
		result += round(from_rgb[i] + ((to_rgb[i] - from_rgb[i]) / max(steps, 1)))
	return rgb(result[1], result[2], result[3])

/datum/zone_lighting_controller/proc/get_area_type()
	switch(zone_id)
		if("lcz")
			return /area/scp/lcz
		if("hcz")
			return /area/scp/hcz
		if("ez")
			return /area/scp/ez
		if("dclass")
			return /area/scp/dclass
		if("surface")
			return /area/scp/surface

/datum/zone_lighting_controller/proc/apply_color_to_lights()
	var/area_type = get_area_type()
	if(!area_type)
		return
	var/list/matching_types = typesof(area_type)
	for(var/area/A in GLOB.areas)
		if(!(A.type in matching_types))
			continue
		for(var/obj/machinery/light/L in A)
			if(QDELETED(L) || !L.has_power())
				continue
			L.bulb_colour = current_color
			L.update(TRUE)

/datum/zone_lighting_controller/proc/restore_default()
	color_sequence = null
	target_color = get_default_color()
	if(current_color == target_color)
		apply_color_to_lights()
		if(active)
			active = FALSE
			STOP_PROCESSING(SSprocessing, src)
	else
		if(!active)
			active = TRUE
			START_PROCESSING(SSprocessing, src)

/datum/zone_lighting_controller/lcz
	zone_id = "lcz"
	current_color = "#d4e4ff"

/datum/zone_lighting_controller/hcz
	zone_id = "hcz"
	current_color = "#8a7a5a"

/datum/zone_lighting_controller/entrance
	zone_id = "ez"
	current_color = LIGHTBULB_COLOR_SLIGHTLY_WARM

/datum/zone_lighting_controller/breach/New(zone)
	zone_id = zone
	current_color = get_default_color()
	target_color = current_color
	animate_color_sequence(list("#8b0000", "#4a0000", "#8b0000"), 2, 15)
