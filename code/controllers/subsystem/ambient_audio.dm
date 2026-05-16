// Looping Ambient Audio System
// Zone-specific looping ambient sound tracks for the SCP facility
// Uses the BYOND sound system with area-based ambient tracks

/obj/ambient_sound_controller
	name = "Ambient Sound Controller"
	desc = "Manages zone-specific ambient audio throughout the facility."
	var/list/zone_tracks = list()
	var/list/active_listeners = list()
	var/update_interval = 30 SECONDS
	var/last_update = 0
	var/volume = 25

/obj/ambient_sound_controller/Initialize()
	. = ..()
	zone_tracks = list(
		"lcz" = list(
			"track" = 'sound/ambience/ambidet1.ogg',
			"volume" = 25,
			"areas" = list(/area/scp/lcz),
		),
		"hcz" = list(
			"track" = 'sound/ambience/ambimo1.ogg',
			"volume" = 20,
			"areas" = list(/area/scp/hcz),
		),
		"ez" = list(
			"track" = 'sound/ambience/ambigen3.ogg',
			"volume" = 15,
			"areas" = list(/area/scp/ez),
		),
		"dclass" = list(
			"track" = 'sound/ambience/ambigen4.ogg',
			"volume" = 20,
			"areas" = list(/area/scp/dclass),
		),
		"surface" = list(
			"track" = 'sound/ambience/ambiodd.ogg',
			"volume" = 10,
			"areas" = list(/area/scp/surface),
		),
		"quarantine" = list(
			"track" = 'sound/ambience/ambimo2.ogg',
			"volume" = 20,
			"areas" = list(/area/scp/medical/quarantine),
		),
	)

/obj/ambient_sound_controller/proc/update_ambient_sounds()
	if(world.time < last_update + update_interval)
		return
	last_update = world.time

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client)
			continue

		var/area/A = get_area(H)
		if(!A)
			continue

		var/zone_key = get_zone_for_area(A)
		if(!zone_key)
			continue

		var/list/zone_data = zone_tracks[zone_key]
		if(!zone_data)
			continue

		var/current_zone = active_listeners[H.ckey]
		if(current_zone == zone_key)
			continue

		active_listeners[H.ckey] = zone_key
		play_zone_ambient(H, zone_data)

/obj/ambient_sound_controller/proc/get_zone_for_area(area/A)
	for(var/zone_key in zone_tracks)
		var/list/zone_data = zone_tracks[zone_key]
		for(var/area_type in zone_data["areas"])
			if(istype(A, area_type))
				return zone_key
	return null

/obj/ambient_sound_controller/proc/play_zone_ambient(mob/living/carbon/human/H, list/zone_data)
	var/sound/S = sound(zone_data["track"], repeat = TRUE, wait = 0, volume = zone_data["volume"], channel = 200)
	S.status = SOUND_UPDATE
	SEND_SOUND(H.client, S)

/obj/ambient_sound_controller/proc/stop_ambient(mob/living/carbon/human/H)
	var/sound/S = sound(null, repeat = FALSE, wait = 0, volume = 0, channel = 200)
	S.status = SOUND_UPDATE
	if(H.client)
		SEND_SOUND(H.client, S)
	active_listeners -= H.ckey

// Ambient Sound Area Component
/datum/component/ambient_sound_area
	var/sound/ambient_track
	var/volume = 25
	var/channel = 200
	var/list/tracked_mobs = list()

/datum/component/ambient_sound_area/Initialize(track, vol = 25)
	. = ..()
	if(!istype(parent, /area))
		return COMPONENT_INCOMPATIBLE
	ambient_track = sound(track, repeat = TRUE, wait = 0, volume = vol, channel = channel)

/datum/component/ambient_sound_area/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/on_entered)
	RegisterSignal(parent, COMSIG_ATOM_EXITED, .proc/on_exited)

/datum/component/ambient_sound_area/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	UnregisterSignal(parent, COMSIG_ATOM_EXITED)
	for(var/mob/M in tracked_mobs)
		stop_ambient_for_mob(M)
	tracked_mobs.Cut()

/datum/component/ambient_sound_area/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!ismob(arrived))
		return
	var/mob/M = arrived
	if(!M.client)
		return
	if(M.stat == DEAD)
		return
	tracked_mobs[M] = TRUE
	play_ambient_for_mob(M)

/datum/component/ambient_sound_area/proc/on_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(!ismob(gone))
		return
	var/mob/M = gone
	if(M in tracked_mobs)
		tracked_mobs -= M
		stop_ambient_for_mob(M)

/datum/component/ambient_sound_area/proc/play_ambient_for_mob(mob/M)
	if(!M.client)
		return
	var/sound/S = ambient_track
	S.status = SOUND_UPDATE
	SEND_SOUND(M.client, S)

/datum/component/ambient_sound_area/proc/stop_ambient_for_mob(mob/M)
	if(!M.client)
		return
	var/sound/S = sound(null, repeat = FALSE, wait = 0, volume = 0, channel = channel)
	S.status = SOUND_UPDATE
	SEND_SOUND(M.client, S)

// Subsystem to manage the global ambient sound controller
SUBSYSTEM_DEF(ambient_audio)
	name = "Ambient Audio"
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME
	var/obj/ambient_sound_controller/controller

/datum/controller/subsystem/ambient_audio/Initialize()
	controller = new()
	return ..()

/datum/controller/subsystem/ambient_audio/fire()
	controller.update_ambient_sounds()
