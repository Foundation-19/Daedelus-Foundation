/obj/machinery/computer/sanity_panel
	name = "Sanity Monitoring Terminal"
	desc = "A terminal for monitoring and managing mental health status."
	icon = 'icons/obj/computer.dmi'
	icon_state = "medlaptop"
	circuit = /obj/item/circuitboard/computer/sanity_panel
	var/admin_virtual = FALSE

/obj/machinery/computer/sanity_panel/ui_status(mob/user, datum/ui_state/state)
	if(admin_virtual && check_rights_for(user?.client, R_ADMIN))
		return UI_INTERACTIVE
	return ..()

/obj/machinery/computer/sanity_panel/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SanityPanel", "Sanity Monitor")
		ui.open()

/obj/machinery/computer/sanity_panel/ui_close(mob/user)
	. = ..()
	if(admin_virtual)
		qdel(src)

/obj/machinery/computer/sanity_panel/ui_data(mob/user)
	var/list/data = list()

	if(!ishuman(user))
		return data

	var/mob/living/carbon/human/H = user
	if(!H.sanity)
		return data

	var/datum/sanity/S = H.sanity

	data["sanity_level"] = S.sanity_level
	data["max_sanity"] = S.max_sanity
	data["sanity_state"] = S.current_sanity_state
	data["previous_state"] = S.previous_sanity_state
	data["sanity_percentage"] = round((S.sanity_level / S.max_sanity) * 100, 0.1)

	data["hallucination_level"] = S.hallucination_level
	data["max_hallucination"] = S.max_hallucination
	data["insanity_level"] = S.insanity_level
	data["max_insanity"] = S.max_insanity
	data["social_isolation"] = S.social_isolation
	data["max_social_isolation"] = S.max_social_isolation
	data["environmental_drain"] = S.environmental_sanity_drain
	data["recovery_rate"] = S.sanity_recovery_rate
	data["treatment_effectiveness"] = S.treatment_effectiveness

	data["episode_active"] = S.episode_active
	data["episode_type"] = S.episode_type

	data["is_admin"] = check_rights_for(H.client, R_ADMIN)

	data["traumas"] = list()
	for(var/datum/trauma/T as anything in S.traumas)
		data["traumas"] += list(list(
			"type" = T.trauma_type,
			"severity" = T.severity,
			"drain" = T.sanity_drain,
			"age" = world.time - T.time_created,
		))

	data["scp_exposures"] = list()
	for(var/scp_id in S.scp_exposures)
		data["scp_exposures"] += list(list(
			"scp_id" = scp_id,
			"last_exposure" = S.scp_exposures[scp_id],
			"time_since" = world.time - S.scp_exposures[scp_id],
		))

	data["medications"] = list()
	for(var/datum/medication/M as anything in S.active_medications)
		data["medications"] += list(list(
			"name" = M.name,
			"effectiveness" = M.effectiveness,
			"time_remaining" = M.duration > 0 ? max(0, (M.time_applied + M.duration) - world.time) : -1,
		))

	data["insanity_effects"] = S.insanity_effects.Copy()

	data["active_vfx"] = list()
	for(var/vfx_type in S.active_vfx)
		data["active_vfx"] += vfx_type

	data["profile"] = S.get_profile_data()

	data["recommendations"] = S.get_medical_recommendations()
	data["prognosis"] = S.get_medical_prognosis()

	data["statistics"] = list(
		"total_lost" = S.total_sanity_lost,
		"total_gained" = S.total_sanity_gained,
		"breakdowns" = S.sanity_breakdowns,
		"stable_ticks" = S.longest_stable_period,
	)

	return data

/obj/machinery/computer/sanity_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr
	if(.)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(!H.sanity)
		return

	var/datum/sanity/S = H.sanity

	switch(action)
		if("medicate_antipsychotic")
			S.add_medication(new /datum/medication/antipsychotic())
			. = TRUE

		if("medicate_antianxiety")
			S.add_medication(new /datum/medication/antianxiety())
			. = TRUE

		if("medicate_sedative")
			S.add_medication(new /datum/medication/sedative())
			. = TRUE

		if("admin_set_sanity")
			if(!check_rights_for(H.client, R_ADMIN))
				return
			var/amount = text2num(params["amount"])
			if(!isnull(amount))
				S.sanity_level = clamp(amount, S.min_sanity, S.max_sanity)
			. = TRUE

		if("admin_clear_traumas")
			if(!check_rights_for(H.client, R_ADMIN))
				return
			S.traumas.Cut()
			. = TRUE

		if("admin_reset_sanity")
			if(!check_rights_for(H.client, R_ADMIN))
				return
			S.sanity_level = S.max_sanity
			S.hallucination_level = 0
			S.insanity_level = 0
			S.insanity_effects.Cut()
			S.social_isolation = 0
			S.traumas.Cut()
			S.clear_all_visual_effects()
			if(S.episode_active)
				S.end_episode()
			. = TRUE

		if("dismiss_episode")
			if(S.episode_active)
				S.end_episode()
			. = TRUE

/obj/item/circuitboard/computer/sanity_panel
	name = "Sanity Monitor (Computer Board)"
	build_path = /obj/machinery/computer/sanity_panel

/client/proc/open_sanity_panel()
	set name = "Sanity Monitor"
	set category = "Admin"
	set desc = "Open the sanity monitoring panel"
	if(!check_rights(R_ADMIN))
		return
	var/obj/machinery/computer/sanity_panel/virtual_panel = new()
	virtual_panel.admin_virtual = TRUE
	virtual_panel.ui_interact(mob)
