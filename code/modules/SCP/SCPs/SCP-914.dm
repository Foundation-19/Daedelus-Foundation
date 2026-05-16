/obj/machinery/scp914
	name = "SCP-914"
	desc = "A massive clockwork device with various settings for refining objects. It seems to be constantly ticking and whirring."
	icon = 'icons/scp/SCP-914-64x64.dmi'
	icon_state = "center"
	density = TRUE
	anchored = TRUE

	var/datum/scp914_refinement_system/refinement_system
	var/datum/scp914_reality_system/reality_system
	var/datum/scp914_temporal_system/temporal_system
	var/datum/scp914_material_system/material_system
	var/datum/scp914_containment_system/containment_system
	var/datum/scp914_environmental_system/environmental_system
	var/datum/scp914_research_integration/research_integration

	var/obj/structure/scp914_booth/input_booth
	var/obj/structure/scp914_booth/output_booth
	var/refinement_efficiency = 1.0

/obj/machinery/scp914/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-914",
		SCP_SAFE,
		"914"
	)

	SCP.min_playercount = 10
	SCP.min_time = 15 MINUTES

	// Initialize modular systems
	refinement_system = new /datum/scp914_refinement_system(src)
	reality_system = new /datum/scp914_reality_system(src)
	temporal_system = new /datum/scp914_temporal_system(src)
	material_system = new /datum/scp914_material_system(src)
	containment_system = new /datum/scp914_containment_system(src)
	environmental_system = new /datum/scp914_environmental_system(src)
	research_integration = new /datum/scp914_research_integration(src)

	// Register with SCP persistence system
	// Create input and output booths
	var/turf/input_turf = get_step(src, WEST)
	if(input_turf)
		input_booth = new /obj/structure/scp914_booth/input(input_turf)
		input_booth.linked_machine = src

	var/turf/output_turf = get_step(src, EAST)
	if(output_turf)
		output_booth = new /obj/structure/scp914_booth/output(output_turf)
		output_booth.linked_machine = src

/obj/machinery/scp914/proc/check_research_access(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(user, span_warning("You need Science access to modify SCP-914's parameters."))
		return FALSE
	return TRUE

/obj/machinery/scp914/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCP914", "SCP-914")
		ui.open()

/obj/machinery/scp914/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp914/ui_data(mob/user)
	var/list/data = list()
	if(refinement_system)
		data["setting"] = refinement_system.refinement_setting
		data["settings"] = refinement_system.refinement_settings
		data["active"] = refinement_system.active
		data["progress"] = refinement_system.refinement_progress
		data["max_progress"] = refinement_system.max_refinement_progress
		data["refinements_performed"] = refinement_system.refinements_performed
		data["objects_destroyed"] = refinement_system.objects_destroyed
		data["objects_enhanced"] = refinement_system.objects_enhanced
		data["efficiency"] = refinement_system.refinement_efficiency

		var/list/input_items = list()
		for(var/obj/item/I in refinement_system.input_objects)
			input_items += list(list("name" = I.name, "ref" = REF(I)))
		data["input_items"] = input_items

		var/list/output_items = list()
		for(var/obj/item/I in refinement_system.output_objects)
			output_items += list(list("name" = I.name, "ref" = REF(I)))
		data["output_items"] = output_items

	data["has_input"] = !!input_booth
	data["has_output"] = !!output_booth
	return data

/obj/machinery/scp914/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	switch(action)
		if("change_setting")
			if(!refinement_system || refinement_system.active)
				return
			var/new_setting = params["setting"]
			if(new_setting in refinement_system.refinement_settings)
				refinement_system.refinement_setting = new_setting
				. = TRUE
		if("start_refinement")
			if(!refinement_system || refinement_system.active)
				return
			if(!length(refinement_system.input_objects))
				return
			refinement_system.active = TRUE
			refinement_system.refinement_progress = 0
			refinement_efficiency = min(2.0, refinement_efficiency + 0.05)
			visible_message("<span class='notice'>SCP-914 begins refining on [refinement_system.refinement_setting] setting.</span>")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				hook_scp_experiment(H, "SCP-914", EXPERIMENT_TYPE_TECHNICAL)
			. = TRUE
		if("insert_item")
			if(!refinement_system || refinement_system.active)
				return
			var/obj/item/I = user.get_active_held_item()
			if(!I)
				return
			if(ismob(I.loc))
				I.forceMove(src)
			refinement_system.input_objects += I
			to_chat(user, "<span class='notice'>Added [I.name] to SCP-914 input.</span>")
			. = TRUE
		if("remove_output")
			if(!refinement_system)
				return
			var/obj/item/I = locate(params["ref"]) in refinement_system.output_objects
			if(!I)
				return
			refinement_system.output_objects -= I
			I.forceMove(get_turf(user))
			user.put_in_hands(I)
			to_chat(user, "<span class='notice'>Removed [I.name] from SCP-914 output.</span>")
			. = TRUE
		if("remove_input")
			if(!refinement_system || refinement_system.active)
				return
			var/obj/item/I = locate(params["ref"]) in refinement_system.input_objects
			if(!I)
				return
			refinement_system.input_objects -= I
			I.forceMove(get_turf(user))
			user.put_in_hands(I)
			to_chat(user, "<span class='notice'>Removed [I.name] from SCP-914 input.</span>")
			. = TRUE

/obj/machinery/scp914/Destroy()
	QDEL_NULL(input_booth)
	QDEL_NULL(output_booth)
	QDEL_NULL(refinement_system)
	QDEL_NULL(reality_system)
	QDEL_NULL(temporal_system)
	QDEL_NULL(material_system)
	QDEL_NULL(containment_system)
	QDEL_NULL(environmental_system)
	QDEL_NULL(research_integration)
	return ..()

// Core processing
/obj/machinery/scp914/process()
	. = ..()

	// Process all systems
	if(refinement_system)
		refinement_system.process_refinement()

	if(reality_system)
		reality_system.process_reality_manipulation()

	if(temporal_system)
		temporal_system.process_temporal_effects()

	if(material_system)
		material_system.process_material_synthesis()

	if(containment_system)
		containment_system.check_containment()

	if(environmental_system)
		environmental_system.process_environmental_effects()

	if(research_integration)
		research_integration.update_research_data()

	// Award research points to nearby researchers
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.SCP) // Skip SCPs
			continue
		// Award research points for observing SCP-914
	// Research data will be collected by the research integration system

// ===== USER INTERFACE VERBS =====

/obj/machinery/scp914/proc/change_setting()
	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	var/new_setting = input(usr, "Choose refinement setting:", "SCP-914 Setting") as null|anything in refinement_system.refinement_settings
	if(new_setting)
		refinement_system.refinement_setting = new_setting
		to_chat(usr, "<span class='notice'>SCP-914 setting changed to [refinement_system.refinement_setting].</span>")

/obj/machinery/scp914/proc/start_refinement()
	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(refinement_system.active)
		to_chat(usr, "<span class='warning'>SCP-914 is already active.</span>")
		return

	if(!length(refinement_system.input_objects))
		to_chat(usr, "<span class='warning'>No objects in input to refine.</span>")
		return

	refinement_system.active = TRUE
	refinement_system.refinement_progress = 0
	visible_message("<span class='notice'>SCP-914 begins refining [length(refinement_system.input_objects)] objects on [refinement_system.refinement_setting] setting.</span>")

	// Progression integration - log experiment start
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		hook_scp_experiment(H, "SCP-914", EXPERIMENT_TYPE_TECHNICAL)
		hook_scp_interaction(H, "SCP-914", INTERACTION_TYPE_EXPERIMENT, list("type" = "refinement", "setting" = refinement_system.refinement_setting))

/obj/machinery/scp914/proc/add_to_input(obj/item/item in range(1, src))
	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(!item)
		to_chat(usr, "<span class='warning'>No item selected.</span>")
		return

	if(refinement_system.active)
		to_chat(usr, "<span class='warning'>Cannot add items while SCP-914 is active.</span>")
		return

	refinement_system.input_objects += item
	item.forceMove(src)
	to_chat(usr, "<span class='notice'>Added [item.name] to SCP-914 input.</span>")

/obj/machinery/scp914/proc/remove_from_output(obj/item/item in refinement_system.output_objects)
	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	if(!item)
		to_chat(usr, "<span class='warning'>No item selected.</span>")
		return

	refinement_system.output_objects -= item
	item.forceMove(get_turf(src))
	to_chat(usr, "<span class='notice'>Removed [item.name] from SCP-914 output.</span>")

/obj/machinery/scp914/proc/emergency_shutdown()
	if(!containment_system)
		to_chat(usr, "<span class='warning'>SCP-914 containment system not available.</span>")
		return

	containment_system.emergency_shutdown_procedure()
	to_chat(usr, "<span class='notice'>SCP-914 emergency shutdown activated.</span>")

// ===== STATUS DISPLAY VERBS =====

/obj/machinery/scp914/proc/view_status()
	if(!usr || !usr.client)
		return

	var/message = "<h2>SCP-914 Status</h2>"

	if(refinement_system)
		message += "<b>Current Setting:</b> [refinement_system.refinement_setting]<br>"
		message += "<b>Refinement Quality:</b> [refinement_system.refinement_quality]/[refinement_system.max_quality]<br>"
		message += "<b>Active:</b> [refinement_system.active ? "Yes" : "No"]<br>"
		message += "<b>Progress:</b> [refinement_system.refinement_progress]/[refinement_system.max_refinement_progress]<br>"

	if(containment_system)
		message += "<b>Containment Status:</b> [containment_system.containment_status]<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/machinery/scp914/proc/view_input_objects()
	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	var/message = "<h2>SCP-914 Input Objects</h2>"

	if(length(refinement_system.input_objects))
		message += "<b>Objects in Input:</b><br>"
		for(var/obj/item/item in refinement_system.input_objects)
			if(item)
				message += "- [item.name]<br>"
	else
		message += "<i>No objects in input.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/machinery/scp914/proc/view_output_objects()
	if(!usr || !usr.client)
		return

	if(!refinement_system)
		to_chat(usr, "<span class='warning'>SCP-914 refinement system not available.</span>")
		return

	var/message = "<h2>SCP-914 Output Objects</h2>"

	if(length(refinement_system.output_objects))
		message += "<b>Objects in Output:</b><br>"
		for(var/obj/item/item in refinement_system.output_objects)
			if(item)
				message += "- [item.name]<br>"
	else
		message += "<i>No objects in output.</i>"

	to_chat(usr, "<span class='notice'>[message]</span>")

/obj/machinery/scp914/proc/view_research_summary()
	if(!usr || !usr.client)
		return

	if(!research_integration)
		to_chat(usr, "<span class='warning'>SCP-914 research integration not available.</span>")
		return

	var/summary = research_integration.get_research_summary()
	to_chat(usr, "<span class='notice'>[summary]</span>")

// Admin verb to view SCP-914 persistence data
/obj/machinery/scp914/proc/view_persistence_data()
	if(!check_rights(R_ADMIN))
		to_chat(usr, "<span class='warning'>You don't have permission to view persistence data.</span>")
		return

	var/message = "<h2>SCP-914 Persistence Data</h2>"

	if(containment_system)
		message += "<b>Containment Status:</b> [containment_system.containment_status]<br>"

	if(refinement_system)
		message += "<b>Refinements Performed:</b> [refinement_system.refinements_performed]<br>"
		message += "<b>Objects Destroyed:</b> [refinement_system.objects_destroyed]<br>"
		message += "<b>Objects Enhanced:</b> [refinement_system.objects_enhanced]<br>"
		message += "<b>Total Materials Processed:</b> [refinement_system.total_materials_processed]<br>"
		message += "<b>Refinement Breakthroughs:</b> [refinement_system.refinement_breakthroughs]<br>"
		message += "<b>Refinement Catastrophes:</b> [refinement_system.refinement_catastrophes]<br>"

	if(material_system)
		message += "<b>Material Syntheses:</b> [material_system.material_syntheses]<br>"

	if(reality_system)
		message += "<b>Reality Manipulations:</b> [reality_system.reality_manipulations]<br>"

	if(temporal_system)
		message += "<b>Temporal Events:</b> [temporal_system.temporal_events]<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-914"]
		if(instance)
			message += "<b>Interaction History:</b> [length(instance.interaction_history)] records<br>"

	to_chat(usr, "<span class='notice'>[message]</span>")

// Override examine for SCP-914
/obj/machinery/scp914/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-914, a clockwork refinement device with multiple settings.</span>")
		else
			to_chat(user, "<span class='notice'>A massive clockwork device that seems to refine objects placed within it.</span>")

		// Show current status to users
		if(refinement_system)
			to_chat(user, "<span class='notice'>Current setting: [refinement_system.refinement_setting]</span>")
			to_chat(user, "<span class='notice'>Status: [refinement_system.active ? "Active" : "Inactive"]</span>")

/obj/structure/scp914_booth
	name = "SCP-914 Booth"
	desc = "A booth connected to SCP-914."
	icon = 'icons/scp/SCP-914-32x64.dmi'
	anchored = TRUE
	density = TRUE
	var/obj/machinery/scp914/linked_machine
	var/booth_type = "input"

/obj/structure/scp914_booth/input
	name = "SCP-914 Input Booth"
	desc = "Place items here to be refined by SCP-914."
	icon_state = "input"
	booth_type = "input"

/obj/structure/scp914_booth/input/attackby(obj/item/I, mob/user, params)
	if(!linked_machine || !linked_machine.refinement_system || linked_machine.refinement_system.active)
		to_chat(user, "<span class='warning'>Cannot add items right now.</span>")
		return
	linked_machine.refinement_system.input_objects += I
	I.forceMove(linked_machine)
	to_chat(user, "<span class='notice'>Inserted [I.name] into SCP-914.</span>")

/obj/structure/scp914_booth/output
	name = "SCP-914 Output Booth"
	desc = "Refined items will appear here."
	icon_state = "output"
	booth_type = "output"

/obj/structure/scp914_booth/output/attack_hand(mob/user)
	if(!ishuman(user) || !linked_machine || !linked_machine.refinement_system)
		return
	var/datum/scp914_refinement_system/RS = linked_machine.refinement_system
	if(!length(RS.output_objects))
		to_chat(user, "<span class='notice'>No items in output.</span>")
		return
	var/obj/item/I = RS.output_objects[length(RS.output_objects)]
	RS.output_objects.Cut(length(RS.output_objects), 0)
	if(I)
		I.forceMove(get_turf(user))
		user.put_in_hands(I)
		to_chat(user, "<span class='notice'>Retrieved [I.name] from SCP-914 output.</span>")


