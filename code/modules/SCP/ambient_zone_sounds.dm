// Ambient Zone Sounds
// Looping atmospheric sounds that play in different facility zones
// Different ambience for LCZ, HCZ, EZ, Surface, and D-Class areas

/obj/machinery/ambient_generator
	name = "ambient sound projector"
	desc = "A concealed speaker system that projects atmospheric audio throughout the area."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	density = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 50

	var/zone_type = "lcz"
	var/sound_file = 'sound/ambience/ambimaint.ogg'
	var/sound_volume = 30
	var/sound_range = 12
	var/loop_interval = 180 SECONDS
	var/list/tracked_mobs = list()
	var/last_play = 0
	var/loop_timerid

/obj/machinery/ambient_generator/Initialize()
	. = ..()
	detect_zone_type()
	start_ambient_loop()

/obj/machinery/ambient_generator/Destroy()
	stop_ambient()
	deltimer(loop_timerid)
	tracked_mobs = null
	return ..()

/obj/machinery/ambient_generator/proc/detect_zone_type()
	var/area/A = get_area(src)
	if(!A)
		return
	if(istype(A, /area/scp/lcz))
		zone_type = "lcz"
		sound_file = 'sound/ambience/ambimaint.ogg'
		sound_volume = 25
	else if(istype(A, /area/scp/hcz))
		zone_type = "hcz"
		sound_file = 'sound/ambience/ambicha1.ogg'
		sound_volume = 20
	else if(istype(A, /area/scp/ez))
		zone_type = "ez"
		sound_file = 'sound/ambience/ambigen1.ogg'
		sound_volume = 30
	else if(istype(A, /area/scp/surface))
		zone_type = "surface"
		sound_file = 'sound/ambience/ambinice.ogg'
		sound_volume = 30
	else if(istype(A, /area/scp/dclass))
		zone_type = "dclass"
		sound_file = 'sound/ambience/ambimaint.ogg'
		sound_volume = 20

/obj/machinery/ambient_generator/proc/start_ambient_loop()
	if(machine_stat & BROKEN)
		return
	if(!powered())
		return
	if(world.time < last_play + loop_interval)
		addtimer(CALLBACK(src, PROC_REF(start_ambient_loop)), loop_interval - (world.time - last_play), TIMER_STOPPABLE)
		return
	play_ambient()
	last_play = world.time
	loop_timerid = addtimer(CALLBACK(src, PROC_REF(start_ambient_loop)), loop_interval, TIMER_STOPPABLE)

/obj/machinery/ambient_generator/proc/play_ambient()
	if(!powered() || (machine_stat & BROKEN))
		return
	var/sound/S = sound(sound_file, repeat = FALSE, wait = 0, volume = sound_volume, channel = CHANNEL_AMBIENCE)
	S.status = SOUND_UPDATE
	for(var/mob/M in hearers(sound_range, src))
		if(M.client && M.client.prefs && !(M.client.prefs.toggles & SOUND_AMBIENCE))
			continue
		SEND_SOUND(M, S)
	tracked_mobs = list()
	for(var/mob/M in hearers(sound_range, src))
		if(M.client)
			tracked_mobs += M

/obj/machinery/ambient_generator/proc/stop_ambient()
	for(var/mob/M in tracked_mobs)
		if(!QDELETED(M) && M.client)
			var/sound/S = sound(null, repeat = FALSE, channel = CHANNEL_AMBIENCE)
			S.status = SOUND_UPDATE
			SEND_SOUND(M, S)
	tracked_mobs = list()

/obj/machinery/ambient_generator/lcz
	zone_type = "lcz"
	sound_file = 'sound/ambience/ambimaint.ogg'
	sound_volume = 25

/obj/machinery/ambient_generator/hcz
	zone_type = "hcz"
	sound_file = 'sound/ambience/ambicha1.ogg'
	sound_volume = 20

/obj/machinery/ambient_generator/ez
	zone_type = "ez"
	sound_file = 'sound/ambience/ambigen1.ogg'
	sound_volume = 30

/obj/machinery/ambient_generator/surface
	zone_type = "surface"
	sound_file = 'sound/ambience/ambinice.ogg'
	sound_volume = 30

/obj/machinery/ambient_generator/dclass
	zone_type = "dclass"
	sound_file = 'sound/ambience/ambimaint.ogg'
	sound_volume = 20
