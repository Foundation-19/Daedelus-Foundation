// That code allows us to spawn shit, like rooms, coridors or you know storages or another stuff with like
// like at secret lab, like modules, like on lavaland

// /datum/modular_map_generator
// 	name = "some generator"

// /datum/modular_map_generator/base_room
// 	name = "Standart Room"

// /datum/modular_map_generator
// 	name = "modular map generator"

// 	var/list/templates = (
// 		/datum/room_template/room = 0.6,
// 		/datum/room_template/corridor = 0.4
// 	)


// that proc is like making SCHEME for our SCP SECRET LAB map
// /datum/modular_map_generator/proc/generate()
	// empty assoc list for "return stuff", "return stuff" will be used for spawn of stuff
	// var/list/layout = list()

	// return layout

// that proce is spawning the generate map, with help of SCHEME
// /datum/modular_map_generator/proc/spawn_the_map()
