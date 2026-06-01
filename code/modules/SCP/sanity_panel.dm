

/obj/effect/vgui_proxy
	name = ""
	desc = ""
	var/tgui_id = ""
	var/window_title = ""

/obj/effect/vgui_proxy/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, tgui_id, window_title)
		ui.open()

/obj/effect/vgui_proxy/ui_data(mob/user)
	if(!ishuman(user))
		return list()
	var/mob/living/carbon/human/H = user
	if(!H.sanity)
		return list()
	var/datum/sanity/S = H.sanity
	var/list/data = list()
	data["sanity_level"] = S.sanity_level
	data["max_sanity"] = S.max_sanity
	data["sanity_state"] = S.current_sanity_state
	data["sanity_percentage"] = round((S.sanity_level / S.max_sanity) * 100, 0.1)
	data["hallucination_level"] = S.hallucination_level
	data["episode_active"] = S.episode_active
	data["episode_type"] = S.episode_type
	data["recommendations"] = S.get_medical_recommendations()
	data["prognosis"] = S.get_medical_prognosis()
	data["is_admin"] = check_rights_for(user?.client, R_ADMIN)
	return data

/obj/effect/vgui_proxy/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(ui.user))
		return
	var/mob/living/carbon/human/H = ui.user
	if(!H.sanity)
		return
	var/datum/sanity/S = H.sanity
	switch(action)
		if("admin_set_sanity")
			if(!check_rights_for(H.client, R_ADMIN))
				return
			var/amount = text2num(params["amount"])
			if(!isnull(amount))
				S.sanity_level = clamp(amount, S.min_sanity, S.max_sanity)
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
		if("medicate_antipsychotic")
			S.add_medication(new /datum/medication/antipsychotic())
			. = TRUE
		if("medicate_antianxiety")
			S.add_medication(new /datum/medication/antianxiety())
			. = TRUE
		if("medicate_sedative")
			S.add_medication(new /datum/medication/sedative())
			. = TRUE
		if("dismiss_episode")
			if(S.episode_active)
				S.end_episode()
			. = TRUE

/client/proc/open_sanity_panel()
	set name = "Sanity Monitor"
	set category = "Admin"
	set desc = "Open the sanity monitoring panel"
	if(!check_rights(R_ADMIN))
		return
	var/obj/effect/vgui_proxy/proxy = new()
	proxy.tgui_id = "SanityPanel"
	proxy.window_title = "Sanity Monitor"
	proxy.ui_interact(mob)
