/datum/minimap_renderer
	var/list/z_level_icons
	var/list/area_color_map
	var/icon_size = MINIMAP_ICON_SIZE
	var/list/dynamic_overlays
	var/last_render_time

/datum/minimap_renderer/New()
	z_level_icons = list()
	dynamic_overlays = list()
	setup_area_colors()
	render_all_levels()

/datum/minimap_renderer/proc/setup_area_colors()
	area_color_map = list()
	area_color_map[/area/scp/lcz] = "#b0c4de"
	area_color_map[/area/scp/hcz] = "#8b7d6b"
	area_color_map[/area/scp/ez] = "#f5deb3"
	area_color_map[/area/scp/dclass] = "#a09060"
	area_color_map[/area/scp/surface] = "#98fb98"
	area_color_map[/area/scp/medical] = "#e0f0ff"

/datum/minimap_renderer/proc/render_all_levels()
	for(var/z in 1 to world.maxz)
		render_z_level(z)

/datum/minimap_renderer/proc/render_z_level(z)
	var/icon/map_icon = icon('icons/effects/effects.dmi', "nothing")
	map_icon.Scale(world.maxx * icon_size, world.maxy * icon_size)
	for(var/turf/T as anything in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
		var/turf_color = get_turf_color(T, get_area(T))
		if(turf_color)
			var/x_pos = (T.x - 1) * icon_size + 1
			var/y_pos = (T.y - 1) * icon_size + 1
			map_icon.DrawBox(turf_color, x_pos, y_pos, x_pos + icon_size - 1, y_pos + icon_size - 1)
	z_level_icons["[z]"] = map_icon
	last_render_time = world.time

/datum/minimap_renderer/proc/get_turf_color(turf/T, area/A)
	if(!A)
		return COLOR_WHITE
	for(var/area_type in area_color_map)
		if(istype(A, area_type))
			return area_color_map[area_type]
	if(istype(T, /turf/open))
		return "#808080"
	if(istype(T, /turf/closed))
		return "#404040"
	return "#606060"

/datum/minimap_renderer/proc/get_icon(z)
	if(!("[z]" in z_level_icons))
		render_z_level(z)
	return z_level_icons["[z]"]

/datum/minimap_renderer/proc/add_dynamic_overlay(id, list/turf_positions, color)
	dynamic_overlays[id] = list("positions" = turf_positions, "color" = color)

/datum/minimap_renderer/proc/remove_dynamic_overlay(id)
	dynamic_overlays -= id

/datum/minimap_renderer/proc/render_overlay(z, overlay_id)
	var/icon/base = get_icon(z)
	if(!base)
		return null
	var/overlay_data = dynamic_overlays[overlay_id]
	if(!overlay_data)
		return null
	var/icon/overlay_icon = icon(base)
	var/list/positions = overlay_data["positions"]
	var/overlay_color = overlay_data["color"]
	for(var/turf/T in positions)
		if(T.z != z)
			continue
		var/x_pos = (T.x - 1) * icon_size + 1
		var/y_pos = (T.y - 1) * icon_size + 1
		overlay_icon.DrawBox(overlay_color, x_pos, y_pos, x_pos + icon_size - 1, y_pos + icon_size - 1)
	return overlay_icon
