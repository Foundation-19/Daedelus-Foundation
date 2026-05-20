/obj/effect/spinning_light/self_destruct_variant
	spin_rate = 1.5 SECONDS // Faster rotation for self-destruct
	_color = "#FF0000" // Pure red

/obj/machinery/rotating_alarm/self_destruct_alarm
	name = "self-destruct rotating alarm"
	desc = "A specialized rotating alarm light for self-destruct sequences."
	icon = 'icons/obj/rotating_alarm.dmi' // Re-use existing icon
	icon_state = "alarm"
	alarm_light_color = "#FF0000" // Pure red

/obj/machinery/rotating_alarm/self_destruct_alarm
	var/spin_rate = 1.5 SECONDS // Faster rotation for self-destruct

/obj/machinery/rotating_alarm/self_destruct_alarm/Initialize()
	. = ..()
	// The base rotating_alarm's Initialize will set up spin_effect.
	// We just need to ensure its spin_rate is set.
	if(spin_effect)
		spin_effect.spin_rate = spin_rate

/datum/self_destruct_profile/self_destruct_light_profile
	var/datum/self_destruct_controller/controller // Reference to the controller
	var/list/active_small_light_spinning_lights // Tracks self_destruct_variant spinning lights created for small lights
	var/list/active_alarm_spinning_lights // Tracks self_destruct_variant spinning lights created for rotating alarms
	var/list/affected_lights // To track lights whose properties were changed by this profile

	// Batching variables
	var/light_update_batch_size = 20 // Number of lights to update per batch
	var/light_update_delay = 1 // Delay between batches in deciseconds
	var/current_light_index = 1
	var/current_alarm_index = 1
	var/list/all_lights_to_update // Stores all lights to be updated
	var/list/all_alarms_to_update // Stores all rotating alarms to be updated
	var/datum/callback/light_batch_timer // Timer for batch processing

/datum/self_destruct_profile/self_destruct_light_profile/New(datum/self_destruct_controller/new_controller)
	. = ..()
	controller = new_controller
	active_small_light_spinning_lights = list()
	active_alarm_spinning_lights = list()
	affected_lights = list()
	all_lights_to_update = list()
	all_alarms_to_update = list()

	// Register for signals from the controller
	RegisterSignal(controller, SD_SIGNAL_START, PROC_REF(on_start_signal))
	RegisterSignal(controller, list(SD_SIGNAL_CANCEL, SD_SIGNAL_PAUSE), PROC_REF(on_cancel_or_pause_signal))
	RegisterSignal(controller, SD_SIGNAL_FINAL, PROC_REF(on_final_signal))
	RegisterSignal(controller, SD_SIGNAL_RESUME, PROC_REF(on_resume_signal))

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_start_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Light Profile: On Start Signal received.")
	// Collect all lights and alarms for batched processing
	all_lights_to_update.Cut()
	all_alarms_to_update.Cut()
	current_light_index = 1
	current_alarm_index = 1

	for(var/obj/machinery/light/L in INSTANCES_OF(/obj/machinery/light))
		if(istype(L) && is_station_level(L.z))
			if(!affected_lights[L])
				affected_lights[L] = list(L.bulb_colour, L.on, L.emergency_mode)
			all_lights_to_update += L

	for(var/obj/machinery/rotating_alarm/R in INSTANCES_OF(/obj/machinery/rotating_alarm))
		if(istype(R) && is_station_level(R.z))
			if(!affected_lights[R])
				affected_lights[R] = list(R.on, R.alarm_light_color, R.spin_effect?.spin_rate)
			all_alarms_to_update += R

	// Start batched processing
	light_batch_timer = addtimer(CALLBACK(src, PROC_REF(process_light_batch)), light_update_delay, 0)

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_final_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER

/datum/self_destruct_profile/self_destruct_light_profile/proc/on_cancel_or_pause_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Light Profile: On Cancel/Pause Signal received.")
	// Stop any ongoing batch processing
	if(light_batch_timer)
		qdel(light_batch_timer) // Explicitly delete the timer
		light_batch_timer = null
	all_lights_to_update.Cut()
	all_alarms_to_update.Cut()
	current_light_index = 1
	current_alarm_index = 1

	// Deactivate spinning effect and revert emergency lights for small lights
	for(var/obj/effect/spinning_light/self_destruct_variant/S in active_small_light_spinning_lights)
		qdel(S) // Delete the self-destruct variant spinning light
	active_small_light_spinning_lights.Cut()

	for(var/obj/machinery/light/L in affected_lights)
		if(L) // Check if light still exists
			if(istype(L, /obj/machinery/light))
				var/list/original_states = affected_lights[L]
				L.bulb_colour = original_states[1] // Restore original color
				L.on = original_states[2] // Restore original on state
				L.emergency_mode = original_states[3] // Restore original emergency_mode state
				L.update_appearance() // Update icon state
				L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour) // Update luminosity
	for(var/obj/machinery/rotating_alarm/R_alarm in affected_lights)
		var/list/original_states = affected_lights[R_alarm]
		R_alarm.set_color(original_states[2]) // Restore original color
		R_alarm.set_off() // Explicitly turn off to clear any self-destruct spinning effect
		if(R_alarm.spin_effect) // Always reset spin_rate to default for the internal spin_effect
			R_alarm.spin_effect.spin_rate = 1 SECONDS // Default spin rate for /obj/effect/spinning_light
	affected_lights.Cut()


/datum/self_destruct_profile/self_destruct_light_profile/proc/on_resume_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Light Profile: On Resume Signal received.")
	// Re-collect all lights and alarms for batched processing on resume
	all_lights_to_update.Cut()
	all_alarms_to_update.Cut()
	current_light_index = 1
	current_alarm_index = 1

	for(var/obj/machinery/light/L in affected_lights)
		if(istype(L) && !QDELETED(L))
			all_lights_to_update += L

	for(var/obj/machinery/rotating_alarm/R_alarm in affected_lights)
		if(istype(R_alarm) && !QDELETED(R_alarm))
			all_alarms_to_update += R_alarm

	// Start batched processing
	light_batch_timer = addtimer(CALLBACK(src, PROC_REF(process_light_batch)), light_update_delay, 0)

/datum/self_destruct_profile/self_destruct_light_profile/proc/process_light_batch()
	var/lights_processed_in_batch = 0
	var/alarms_processed_in_batch = 0

	// Process lights
	while(lights_processed_in_batch < light_update_batch_size && current_light_index <= all_lights_to_update.len)
		var/obj/machinery/light/L = all_lights_to_update[current_light_index]
		if(L && !QDELETED(L))
			L.bulb_colour = "#FF0000" // Set to pure red
			L.on = TRUE // Ensure light is on
			L.emergency_mode = TRUE // Set to emergency mode
			L.update_appearance() // Update icon state
			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour) // Update luminosity
		current_light_index++
		lights_processed_in_batch++

	// Process rotating alarms
	while(alarms_processed_in_batch < light_update_batch_size && current_alarm_index <= all_alarms_to_update.len)
		var/obj/machinery/rotating_alarm/R = all_alarms_to_update[current_alarm_index]
		if(R && !QDELETED(R))
			R.set_color("#FF0000") // Set to pure red
			R.set_on() // Ensure alarm is on, which will activate its internal spinning light
			if(R.spin_effect)
				R.spin_effect.spin_rate = 1.5 SECONDS // Adjust the spin rate of the alarm's inherent spinning light
		current_alarm_index++
		alarms_processed_in_batch++

	// Check if all lights and alarms have been processed
	if(current_light_index > all_lights_to_update.len && current_alarm_index > all_alarms_to_update.len)
		qdel(light_batch_timer) // Explicitly delete the timer
		light_batch_timer = null
		addtimer(CALLBACK(src, PROC_REF(spawn_spinning_lights)), 40) // All lights updated, now spawn spinning lights
	else
		// Schedule next batch
		light_batch_timer = addtimer(CALLBACK(src, PROC_REF(process_light_batch)), light_update_delay, 0)

/datum/self_destruct_profile/self_destruct_light_profile/proc/spawn_spinning_lights()
	// Red Emergency Spinny Light Logic
	for(var/obj/machinery/light/small/L in INSTANCES_OF(/obj/machinery/light)) // Iterate through lights for small lights.
		if(istype(L) && is_station_level(L.z) && L.status != LIGHT_BROKEN) // Exclude broken lights
			// If there's a rotating_alarm at this location, it handles its own spinning light, so skip this light/small.
			if(locate(/obj/machinery/rotating_alarm) in L.loc)
				continue

			var/obj/effect/spinning_light/self_destruct_variant/S = new /obj/effect/spinning_light/self_destruct_variant(L.loc)
			if(istype(L, /obj/machinery/light/small/directional) || istype(L, /obj/machinery/light/small/maintenance/directional)) // Apply pixel shift for directional lights
				switch(L.dir)
					if(NORTH)
						S.pixel_y = 31
					if(SOUTH)
						S.pixel_y = -11
					if(EAST)
						S.pixel_x = 21
					if(WEST)
						S.pixel_x = -21
			L.self_destruct_spinning_light = S // Store reference on the light object
			active_small_light_spinning_lights += S
