/* Chunk management system for weather; We essentially cache a list of atoms in an area (obj or mobs)
 * that we can then reference with a key. This is better than checking them all at once.
 * I believe Mobs/items are generally more extensive to iterate than areas.
*/


#define CHUNK_SIZE 8 //8x8 is considered a chunk.

/datum/weather/chunking
	name = "Chunk System"


	var/list/chunks = list()  /// Chunk keys and atoms contained, Ex. [4_6_1], [x_y_z]

//Registering/Deregistering

/datum/weather/chunking/proc/register(atom/movable/Q)
	var/area/A = get_area(Q)
	if(!Q || !A.outdoors) //We only want outdoor atoms and atoms that exist.
		return
	var/key = get_chunk_key(Q) //What's the key for this atoms location?
	if(!(key in src.chunks)) //If the key doesn't exist, we create the list and mark it.
		src.chunks[key] = list()
	src.chunks[key] += Q //Adding the atom to the list.

//Similar to above but removing atoms from chunks, and deleting chunks from list if empty.
/datum/weather/chunking/proc/unregister(atom/movable/Q) //Keep Q for clarity
	var/key = get_chunk_key(Q)
	if(key in src.chunks)
		src.chunks[key] - = Q
		if(!src.chunks[key].len)
			src.chunks -= key

//Keys and Coords

/datum/weather/chunking/proc/get_chunk_coords(atom/movable/Q) //Maybe misleading name, gets the chunk based on coords and chunk size.
	return list(
		round(Q.x / CHUNK_SIZE),
		round(Q.y / CHUNK_SIZE),
		Q.z
	)

/datum/weather/chunking/proc/get_chunk_key(atm/movable/Q) //Converts coordinates into key.
	var/list/coords = src.get_chunk_coords(Q)
	return "[coords[1]]_[coords[2]]_[coords[3]]"

//Utilities

/datum/weather/chunking/proc/update_atom_location(atom/movable/Q) //Detecting when atom moves between chunks, unregisters old, registers new.
	var/area/A = get_area(Q)
	if(!Q || !A.outdoors)
		return

	var/key_now = get_chunk_key(Q)
	if(key_now != Q.last_weather_chunk_key)
		if(Q.last_weather_chunk_key)
			unregister(Q)
		register(Q)
		Q.last_weather_chunk_key = key_now //defined where?

/datum/weather/chunking/proc/get_nearby_atoms(atom/origin, radius_in_chunks = 1) //Returns combined list of atoms in square of surrounding chunks
	var/list/center = get_chunk_coords(origin)
	var/list/results = list()

	for(var/dx = -radius_in_chunks to radius_in_chunks)
		for(var/dy = -radius_in_chunks to radius_in_chunks)
			var/x = center[1] + dx
			var/y = center[2] + dy
			var/z = center[3]
			var/key = "[x]_[y]_[z]"
			if(key in src.chunks)
				results += src.chunks[key]

	return results

// 3 by 3 grid around executed chunk, so 9 chunks total. * = chunk, x = center (also chunk)
/*

* * *
* x *
* * *

*/

/datum/weather/chunking/proc/get_mobs_in_chunks(list/chunk_keys)
	var/list/results = list()
	for(var/key in chunk_keys)
		if(key in src.chunks)
			for(var/atom/movable/Q in src.chunks[key])
				if(ismob(Q))
					results += Q

	return results


/datum/weather/chunking/proc/get_objects_in_chunks(list/chunk_keys)
	var/list/results = list()
	for(var/key in chunk_keys)
		if(key in src.chunks)
			for(var/atom/movable/Q in src.chunks[key])
				if(isobj(Q))
					results += Q

	return results

