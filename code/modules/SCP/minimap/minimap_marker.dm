/datum/minimap_marker
	var/atom/target
	var/layers
	var/color
	var/id

/datum/minimap_marker/New(atom/target, layers, color, id)
	src.target = target
	src.layers = layers
	src.color = color
	src.id = id
