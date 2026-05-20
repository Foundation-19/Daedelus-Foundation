/datum/self_destruct_profile/self_destruct_mechanical_profile
	var/datum/self_destruct_controller/controller // Reference to the controller
	var/list/original_light_colors
	var/list/original_area_lighting_states // Stores original area lighting states for reversion

/datum/self_destruct_profile/self_destruct_mechanical_profile/New(datum/self_destruct_controller/new_controller)
	. = ..()
	controller = new_controller
	original_light_colors = list()
	original_area_lighting_states = list()

	// Register for signals from the controller
	RegisterSignal(controller, SD_SIGNAL_START, PROC_REF(on_start_signal))
	RegisterSignal(controller, list(SD_SIGNAL_PAUSE, SD_SIGNAL_CANCEL), PROC_REF(on_stop_signal))
	RegisterSignal(controller, SD_SIGNAL_RESUME, PROC_REF(on_resume_signal))
	RegisterSignal(controller, SD_SIGNAL_FINAL, PROC_REF(on_final_destruction_signal))

/datum/self_destruct_profile/self_destruct_mechanical_profile/proc/on_start_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Mechanical Profile: On Start Signal received.")
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		to_chat(A, span_bolddanger("WARNING: Site-Wide Self-Destruct sequence initiated!"))

/datum/self_destruct_profile/self_destruct_mechanical_profile/proc/on_stop_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Mechanical Profile: On Stop Signal received.")
	// Revert red lights
	for(var/obj/machinery/light/L in original_light_colors) // Iterate through light objects directly
		if(istype(L) && !QDELETED(L)) // Check if the light object still exists
			L.bulb_colour = original_light_colors[L]
			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)
	original_light_colors = list() // Clear the list

/datum/self_destruct_profile/self_destruct_mechanical_profile/proc/on_resume_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Mechanical Profile: On Resume Signal received.")
	// Re-apply red lights (if they were active before pause)
	for(var/obj/machinery/light/L in original_light_colors)
		if(istype(L) && !QDELETED(L))
			L.bulb_colour = "#FF0000" // Re-apply red
			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)

/datum/self_destruct_profile/self_destruct_mechanical_profile/proc/on_final_destruction_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Mechanical Profile: On Final Destruction Signal received.")
	// Implement final destruction sequence (e.g., explosion)
