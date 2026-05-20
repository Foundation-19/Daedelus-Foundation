/datum/self_destruct_profile/self_destruct_explosion_profile
	var/datum/self_destruct_controller/controller // Reference to the controller
	// This profile handles the actual explosion logic for the self-destruct system.

/datum/self_destruct_profile/self_destruct_explosion_profile/New(datum/self_destruct_controller/new_controller)
	. = ..()
	controller = new_controller

	// Register for signals from the controller
	RegisterSignal(controller, SD_SIGNAL_FINAL, PROC_REF(on_final_destruction_signal))

/datum/self_destruct_profile/self_destruct_explosion_profile/proc/on_final_destruction_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	// The 'data' argument should be the nuclearbomb object itself
	var/obj/machinery/nuclearbomb/N = data
	if(!istype(N))
		CRASH("Self-destruct explosion profile received non-nuclearbomb data for final destruction.")

	if(N.safety)
		return

	N.exploding = TRUE
	N.yes_code = FALSE
	N.update_appearance()
	if(SSticker?.mode)
		SSticker.roundend_check_paused = TRUE
	addtimer(CALLBACK(src, PROC_REF(process_explosion_logic), N), 100)

/datum/self_destruct_profile/self_destruct_explosion_profile/proc/process_explosion_logic(obj/machinery/nuclearbomb/N)
	if(!N.core)
		Cinematic(CINEMATIC_NUKE_NO_CORE,world)
		SSticker.roundend_check_paused = FALSE
		return

	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, TRUE)

	var/off_station = 0
	var/turf/bomb_location = get_turf(N)
	var/area/A = get_area(bomb_location)

	if(bomb_location && is_station_level(bomb_location.z))
		if(istype(A, /area/space))
			off_station = NUKE_NEAR_MISS
		else if((bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)))
			off_station = NUKE_NEAR_MISS
		else // station actually nuked
			off_station = STATION_DESTROYED_NUKE
			GLOB.station_was_nuked = TRUE
	else if(bomb_location.onSyndieBase())
		off_station = NUKE_SYNDICATE_BASE
	else
		off_station = NUKE_MISS_STATION

	if(off_station < NUKE_MISS_STATION)
		SSshuttle.registerHostileEnvironment(N)
		SSshuttle.lockdown = TRUE
	//Cinematic
	GLOB.station_nuke_source = off_station
	initiate_final_explosion(off_station, N)
	SSticker.roundend_check_paused = FALSE

/datum/self_destruct_profile/self_destruct_explosion_profile/proc/initiate_final_explosion(off_station, obj/machinery/nuclearbomb/N)
	var/turf/bomb_location = get_turf(N)
	Cinematic(N.get_cinematic_type(off_station),world,CALLBACK(SSticker,TYPE_PROC_REF(/datum/controller/subsystem/ticker, station_explosion_detonation),N))
	if(istype(N, /obj/machinery/nuclearbomb/syndicate/bananium))
		var/obj/machinery/nuclearbomb/syndicate/bananium/bananium_nuke = N
		bananium_nuke.really_actually_explode(off_station)
	else if(istype(N, /obj/machinery/nuclearbomb/beer))
		var/obj/machinery/nuclearbomb/beer/beer_nuke = N
		if(is_station_level(bomb_location.z))
			beer_nuke.really_actually_explode()
		else
			beer_nuke.local_foam()
	else if(off_station == STATION_DESTROYED_NUKE)
		INVOKE_ASYNC(GLOBAL_PROC,GLOBAL_PROC_REF(KillEveryoneOnStation))
		return
	if(off_station != NUKE_NEAR_MISS) // Don't kill people in the station if the nuke missed, even if we are technically on the same z-level
		INVOKE_ASYNC(GLOBAL_PROC,GLOBAL_PROC_REF(KillEveryoneOnZLevel), bomb_location.z)
