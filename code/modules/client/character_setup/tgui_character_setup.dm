/datum/character_setup_ui
	var/datum/preferences/prefs
	var/list/faction_to_classes
	var/list/faction_lore
	var/list/class_lore

/datum/character_setup_ui/New(mob/user)
	. = ..()
	if(user?.client?.prefs)
		prefs = user.client.prefs
		var/list/fcstate = prefs.read_preference(/datum/preference/blob/faction_class_state)
		if (isnull(fcstate) || !islist(fcstate))
			prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/faction_class_state], list("locked" = FALSE, "tokens" = 1))

/datum/character_setup_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_setup_ui/ui_status(mob/user, datum/ui_state/state)
	return user?.client == prefs?.parent ? UI_INTERACTIVE : UI_CLOSE

/datum/character_setup_ui/ui_interact(mob/user, datum/tgui/ui)
	if (!prefs)
		if (user?.client?.prefs)
			prefs = user.client.prefs
		else
			return FALSE
	if (isnull(prefs.character_preview_view))
		prefs.create_character_preview_view(user)
	else if (!(prefs.character_preview_view in user.client?.screen))
		user.client?.register_map_obj(prefs.character_preview_view)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterSetup")
		ui.set_autoupdate(FALSE)
		ui.open()
		if (prefs?.character_preview_view)
			addtimer(CALLBACK(prefs.character_preview_view, TYPE_PROC_REF(/atom/movable/screen/character_preview_view, update_body)), 1 SECONDS)
	return TRUE

/datum/character_setup_ui/ui_static_data(mob/user)
	var/list/data = list()
	if (!prefs)
		return data
	if (!faction_to_classes)
		faction_to_classes = get_faction_to_classes()
	if (!faction_lore)
		faction_lore = get_faction_lore()
	if (!class_lore)
		class_lore = get_class_lore()
	data["faction_to_classes"] = faction_to_classes
	data["faction_lore"] = faction_lore
	data["class_lore"] = class_lore
	if (isnull(prefs.character_preview_view))
		prefs.create_character_preview_view(user)
	else if (prefs.character_preview_view.client != prefs.parent)
		prefs.character_preview_view.register_to_client(prefs.parent)
	data["character_preview_view"] = prefs.character_preview_view.assigned_map
	var/list/species_choices = list(SPECIES_HUMAN)
	var/list/species_names = list()
	var/datum/species/human_species = GLOB.species_list[SPECIES_HUMAN]
	species_names[SPECIES_HUMAN] = initial(human_species.name)
	data["species_choices"] = species_choices
	data["species_names"] = species_names
	data["gender_choices"] = list("male", "female", "plural")
	return data

/datum/character_setup_ui/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet/preferences),
		get_asset_datum(/datum/asset/json/preferences),
		get_asset_datum(/datum/asset/json/keybindings),
	)
	return assets

/datum/character_setup_ui/proc/get_scp_roles()
	return list(
		"SCP-173", "SCP-096", "SCP-049", "SCP-106", "SCP-939",
		"SCP-035", "SCP-682", "SCP-999", "SCP-131"
	)

/datum/character_setup_ui/ui_data(mob/user)
	var/list/data = list()
	if (!prefs)
		return data
	if (!faction_to_classes)
		faction_to_classes = get_faction_to_classes()
	if (!faction_lore)
		faction_lore = get_faction_lore()
	if (!class_lore)
		class_lore = get_class_lore()
	data["faction_to_classes"] = faction_to_classes
	data["faction_lore"] = faction_lore
	data["class_lore"] = class_lore
	if (isnull(prefs.character_preview_view))
		prefs.create_character_preview_view(user)
	else if (prefs.character_preview_view.client != prefs.parent)
		prefs.character_preview_view.register_to_client(prefs.parent)
	if (prefs.character_preview_view)
		prefs.character_preview_view.update_appearance()
		data["character_preview_view"] = prefs.character_preview_view.assigned_map
	else
		data["character_preview_view"] = null
	data["active_slot"] = prefs.default_slot
	data["name_to_use"] = prefs.read_preference(/datum/preference/name/real_name)
	data["real_name"] = data["name_to_use"]
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/species_id
	for (var/id in GLOB.species_list)
		if (GLOB.species_list[id] == species_type)
			species_id = id
			break
	data["species_id"] = species_id
	data["age"] = prefs.read_preference(/datum/preference/numeric/age)
	data["gender"] = prefs.read_preference(/datum/preference/choiced/gender)
	data["gender_choices"] = list("male", "female", "plural")
	data["eye_color"] = prefs.read_preference(/datum/preference/color/eye_color)
	data["hair_color"] = prefs.read_preference(/datum/preference/color/hair_color)
	data["faction"] = prefs.read_preference(/datum/preference/choiced/faction)
	data["class"] = prefs.read_preference(/datum/preference/choiced/class)
	var/player_rank = 0
	var/player_class_id = ""
	if (user?.ckey && istype(SSpersistent_progression))
		var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(user.ckey)
		if (pdata)
			player_rank = pdata.current_rank
			player_class_id = pdata.current_class_id
	data["persistent_rank"] = player_rank
	data["persistent_class"] = player_class_id
	var/list/fcstate = prefs.read_preference(/datum/preference/blob/faction_class_state)
	data["faction_class_locked"] = !!fcstate?["locked"]
	data["faction_class_reset_tokens"] = fcstate?["tokens"] || 0
	data["can_admin_override"] = !!user?.client?.holder
	var/list/available = list()
	if (data["faction"] && data["class"]) {
		var/list/jobs = get_faction_class_jobs(data["faction"], data["class"], player_rank, player_class_id)
		for (var/job_title in jobs)
			var/desc = get_job_description(job_title)
			var/required = get_required_rank_for_job(data["class"], job_title)
			available += list(list("title" = job_title, "description" = desc, "required_rank" = required))
	}
	data["available_jobs"] = available
	data["job_preferences"] = prefs.read_preference(/datum/preference/blob/job_priority) || list()
	var/list/user_antags = prefs.read_preference(/datum/preference/blob/antagonists) || list()
	var/list/scp_only = list()
	for (var/role in get_scp_roles())
		scp_only[role] = !!user_antags[role]
	data["antagonists"] = scp_only
	data["quirks"] = prefs.read_preference(/datum/preference/blob/quirks) || list()
	var/list/all_quirks = list()
	var/list/quirk_info = list()
	if (SSquirks)
		var/list/allq = SSquirks.get_quirks()
		for (var/quirk_name in allq)
			var/datum/quirk/Q = allq[quirk_name]
			all_quirks += quirk_name
			quirk_info[quirk_name] = list("description" = initial(Q.desc))
	data["all_quirks"] = all_quirks
	data["quirk_info"] = quirk_info
	data["languages"] = prefs.read_preference(/datum/preference/blob/languages) || list()
	var/list/lang_catalog = list()
	for (var/datum/language/path as anything in GLOB.preference_language_types)
		var/datum/language/L = GET_LANGUAGE_DATUM(path)
		lang_catalog["[path]"] = L?.name || "Unknown"
	data["languages_catalog"] = lang_catalog
	var/list/loadout = prefs.read_preference(/datum/preference/blob/loadout) || list()
	var/list/loadout_serialized = list()
	for (var/datum/loadout_entry/E as anything in loadout)
		var/datum/loadout_item/LI = locate(E.path) in GLOB.loadout_items
		if(!LI)
			continue
		var/item_name = E.custom_name || LI.name
		var/item_desc = E.custom_desc || LI.description
		loadout_serialized += list(list("path" = "[E.path]", "name" = item_name, "desc" = item_desc))
	data["loadout_entries"] = loadout_serialized
	data["appearance_mods"] = prefs.read_preference(/datum/preference/appearance_mods) || list()
	data["augments"] = prefs.read_preference(/datum/preference/blob/augments) || list()
	data["character_preferences"] = prefs.compile_character_preferences(user)
	data["character_profiles"] = prefs.create_character_profiles()
	data["content_unlocked"] = prefs.unlock_content
	data["preview_options"] = list(PREVIEW_PREF_JOB, PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR)
	data["preview_selection"] = prefs.preview_pref
	data["overflow_role"] = SSjob.GetJobType(SSjob.overflow_role).title
	for (var/datum/preference_middleware/preference_middleware as anything in prefs.middleware)
		data += preference_middleware.get_ui_data(user)
	data["keybindings"] = prefs.key_bindings
	return data

/datum/character_setup_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/result = FALSE
	switch(action)
		if ("reset_all_keybinds")
			for (var/datum/preference_middleware/keybindings/kb_mw in prefs.middleware)
				result = kb_mw.reset_all_keybinds(params, usr)
		if ("reset_keybinds_to_defaults")
			for (var/datum/preference_middleware/keybindings/kb_mw2 in prefs.middleware)
				result = kb_mw2.reset_keybinds_to_defaults(params, usr)
		if ("set_keybindings")
			for (var/datum/preference_middleware/keybindings/kb_mw3 in prefs.middleware)
				result = kb_mw3.set_keybindings(params)
		if ("loadout_toggle")
			var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/loadout]
			result = P.button_act(usr, prefs, params)
		if ("appearance_mods_act")
			var/datum/preference/mod_pref = GLOB.preference_entries[/datum/preference/appearance_mods]
			result = mod_pref.button_act(usr, prefs, params)
		if ("augments_act")
			var/datum/preference/aug_pref = GLOB.preference_entries[/datum/preference/blob/augments]
			result = aug_pref.user_edit(usr, prefs, params)
		if ("quirk_toggle")
			var/quirk = params["quirk"]
			var/list/user_quirks = prefs.read_preference(/datum/preference/blob/quirks) || list()
			if (quirk in user_quirks)
				user_quirks -= quirk
			else
				user_quirks += quirk
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/quirks], user_quirks)
		if ("language_toggle_understand")
			var/datum/language/path = text2path(params["language"])
			if (!path) return FALSE
			if (!(path in GLOB.preference_language_types)) return FALSE
			var/list/user_languages = prefs.read_preference(/datum/preference/blob/languages) || list()
			var/value = user_languages[path]
			if (value & LANGUAGE_UNDERSTAND)
				value = NONE
			else
				value |= LANGUAGE_UNDERSTAND
			if (value == NONE)
				user_languages -= path
			else
				user_languages[path] = value
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/languages], user_languages)
		if ("rotate")
			if (prefs.character_preview_view)
				prefs.character_preview_view.dir = turn(prefs.character_preview_view.dir, -90)
			result = TRUE
		if ("language_toggle_speak")
			var/datum/language/path2 = text2path(params["language"])
			if (!path2) return FALSE
			if (!(path2 in GLOB.preference_language_types)) return FALSE
			var/list/user_languages2 = prefs.read_preference(/datum/preference/blob/languages) || list()
			var/value2 = user_languages2[path2]
			if (value2 & LANGUAGE_SPEAK)
				value2 &= ~(LANGUAGE_SPEAK)
			else
				value2 |= (LANGUAGE_UNDERSTAND|LANGUAGE_SPEAK)
			if (value2 == NONE)
				user_languages2 -= path2
			else
				user_languages2[path2] = value2
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/languages], user_languages2)
		if ("open_preferences")
			prefs.ui_interact(usr)
			return TRUE
		if ("open_loadout")
			new /datum/loadout_ui(usr.client)
			return TRUE
		if ("open_appearance_mods")
			prefs.ui_act("appearance_mods", list(), ui, state)
			return TRUE
		if ("antag_select_all")
			var/list/ant = prefs.read_preference(/datum/preference/blob/antagonists) || list()
			for (var/role in ant)
				ant[role] = TRUE
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/antagonists], ant)
		if ("antag_select_all_available")
			var/list/ant2 = prefs.read_preference(/datum/preference/blob/antagonists) || list()
			for (var/role2 in get_scp_roles())
				ant2[role2] = TRUE
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/antagonists], ant2)
		if ("antag_deselect_all")
			var/list/ant3 = prefs.read_preference(/datum/preference/blob/antagonists) || list()
			for (var/role3 in ant3)
				ant3[role3] = FALSE
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/antagonists], ant3)
		if ("antag_toggle")
			var/role4 = params["role"]
			var/list/ant4 = prefs.read_preference(/datum/preference/blob/antagonists) || list()
			if (role4 in ant4)
				ant4[role4] = !ant4[role4]
				result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/antagonists], ant4)
		if ("set_preference")
			var/key = params["preference"]
			var/value = params["value"]
			result = prefs.ui_act("set_preference", list("preference" = key, "value" = value), ui, state)
			if (result)
				if(key == "real_name")
					to_chat(usr, span_notice("Name updated to: [prefs.read_preference(/datum/preference/name/real_name)]"))
			else
				if (key == "real_name")
					to_chat(usr, span_warning("Invalid name. Must be at least 2 alphanumeric characters, no prohibited words."))
				else
					to_chat(usr, span_warning("Failed to update [key]."))
		if ("finalize")
			var/list/job_prefs = prefs.read_preference(/datum/preference/blob/job_priority) || list()
			var/selected_job
			for (var/J in job_prefs)
				if (job_prefs[J] == JP_HIGH)
					selected_job = J
					break
			if (!selected_job)
				for (var/J2 in job_prefs)
					if (job_prefs[J2] == JP_MEDIUM)
						selected_job = J2
						break
			if (!selected_job)
				for (var/J3 in job_prefs)
					if (job_prefs[J3] == JP_LOW)
						selected_job = J3
						break
			if (selected_job)
				var/class_id = prefs.read_preference(/datum/preference/choiced/class)
				var/required = get_required_rank_for_job(class_id, selected_job)
				if (required > 0)
					var/finalize_rank = 0
					if (usr?.ckey && istype(SSpersistent_progression))
						var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(usr.ckey)
						if (pdata)
							finalize_rank = pdata.current_rank
					if (finalize_rank < required)
						to_chat(usr, span_warning("Insufficient rank for [selected_job]. Required: rank [required], Current: rank [finalize_rank]."))
						return FALSE
			SYNC_PERSONNEL_RECORD(selected_job)
			prefs.save_character()
			prefs.save_preferences()
			to_chat(usr, span_notice("Character setup saved."))
			result = TRUE
		if ("set_faction")
			if (!prefs) return FALSE
			var/locked = !!(prefs.read_preference(/datum/preference/blob/faction_class_state)?["locked"])
			if (locked) return FALSE
			var/value2 = params["value"]
			if (!(value2 in get_faction_to_classes())) return FALSE
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/faction], value2)
		if ("set_class")
			if (!prefs) return FALSE
			var/locked2 = !!(prefs.read_preference(/datum/preference/blob/faction_class_state)?["locked"])
			if (locked2) return FALSE
			var/f = prefs.read_preference(/datum/preference/choiced/faction)
			var/value3 = params["value"]
			var/list/classes = get_faction_to_classes()[f]
			if (!classes || !(value3 in classes)) return FALSE
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/class], value3)
		if ("commit_faction_class")
			var/list/lock_state = prefs.read_preference(/datum/preference/blob/faction_class_state) || list()
			lock_state["locked"] = TRUE
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/faction_class_state], lock_state)
			if (result)
				SYNC_PERSONNEL_RECORD()
		if ("request_reset_faction_class")
			var/list/state2 = prefs.read_preference(/datum/preference/blob/faction_class_state) || list()
			var/tokens = state2?["tokens"] || 0
			if (tokens <= 0) return FALSE
			state2["tokens"] = tokens - 1
			state2["locked"] = FALSE
			prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/faction], null)
			prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/class], null)
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/faction_class_state], state2)
		if ("admin_override_unlock")
			if (!usr?.client?.holder) return FALSE
			var/list/astate = prefs.read_preference(/datum/preference/blob/faction_class_state) || list()
			astate["locked"] = FALSE
			astate["tokens"] = (astate["tokens"] || 0) + 1
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/faction_class_state], astate)
		if ("set_job_priority")
			var/job = params["job"]
			var/level = text2num(params["level"])
			if (!job)
				return FALSE
			var/list/job_prefs = prefs.read_preference(/datum/preference/blob/job_priority) || list()
			if (isnull(level) || level <= 0)
				job_prefs[job] = null
			else
				if (level == JP_HIGH)
					var/datum/job/overflow_role = SSjob.overflow_role
					var/overflow_role_title = initial(overflow_role.title)
					for (var/other_job in job_prefs)
						if (job_prefs[other_job] == JP_HIGH)
							if (other_job == overflow_role_title)
								job_prefs[other_job] = null
							else
								job_prefs[other_job] = JP_MEDIUM
				job_prefs[job] = level
			result = prefs.update_preference(GLOB.preference_entries[/datum/preference/blob/job_priority], job_prefs)
			if (result && level == JP_HIGH)
				SYNC_PERSONNEL_RECORD(job)
		if ("close")
			return TRUE
		if ("change_slot")
			prefs.save_character()
			if (!prefs.load_character(params["slot"]))
				prefs.tainted_character_profiles = TRUE
				prefs.randomise_appearance_prefs()
				prefs.save_character()
			for (var/datum/preference_middleware/preference_middleware as anything in prefs.middleware)
				preference_middleware.on_new_character(usr)
			if (prefs.character_preview_view)
				prefs.character_preview_view.update_body()
			result = TRUE
		if ("randomize_name")
			var/name_key = params["preference"] || "real_name"
			var/datum/preference/name/P = GLOB.preference_entries_by_key[name_key]
			if (!P)
				return FALSE
			var/species_type = prefs.read_preference(/datum/preference/choiced/species)
			var/datum/species/S = GLOB.species_list[species_type]
			var/gender = prefs.read_preference(/datum/preference/choiced/gender)
			var/new_name = S?.random_name(gender, TRUE) || random_unique_name(gender)
			result = prefs.update_preference(P, new_name)
		if ("randomize_character")
			prefs.randomise_appearance_prefs()
			prefs.save_character()
			if (prefs.character_preview_view)
				prefs.character_preview_view.update_body()
			result = TRUE
		if ("set_color_preference")
			var/color_key = params["preference"]
			var/new_color = input(usr, "Choose color", "Character Preference") as color|null
			if (new_color)
				result = prefs.ui_act("set_preference", list("preference" = color_key, "value" = new_color), ui, state)
		if ("set_random_preference")
			var/rand_key = params["preference"]
			var/rand_value = params["value"]
			result = prefs.ui_act("set_preference", list("preference" = rand_key, "value" = rand_value), ui, state)
		if ("set_preview_pref")
			var/preview_val = params["value"]
			if (preview_val in list(PREVIEW_PREF_JOB, PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR))
				prefs.preview_pref = preview_val
				if (prefs.character_preview_view)
					prefs.character_preview_view.update_body()
				result = TRUE
	if (result)
		SStgui.update_uis(src)
	return result

/datum/character_setup_ui/proc/SYNC_PERSONNEL_RECORD(job_title)
	if (!SSpersonnel_persistence || !SSpersonnel_persistence.manager)
		return
	var/datum/personnel_persistence_manager/M = SSpersonnel_persistence.manager
	var/ck = prefs.parent?.ckey
	if (!ck)
		return
	var/realname = prefs.read_preference(/datum/preference/name/real_name)
	var/faction = prefs.read_preference(/datum/preference/choiced/faction)
	var/class_id = prefs.read_preference(/datum/preference/choiced/class)
	var/department = class_id
	var/position = job_title || faction
	var/datum/personnel_record/record = M.personnel_records[ck]
	if (!record)
		record = M.add_personnel_record(ck, realname, department, position)
	else
		record.real_name = realname
		record.department = department
		record.position = position
		record.last_updated = world.time

/datum/character_setup_ui/proc/get_faction_to_classes()
	return list(
		"foundation" = list("administrative", "security", "research", "medical", "engineering", "intelligence"),
		"goc" = list("administrative", "intelligence"),
		"uiu" = list("administrative", "intelligence"),
		"mcd" = list("administrative"),
		"serpents_hand" = list("intelligence"),
		"chaos_insurgency" = list("intelligence")
	)

/datum/character_setup_ui/proc/get_faction_lore()
	return list(
		"foundation" = "SCP Foundation: Secure, Contain, Protect.",
		"goc" = "Global Occult Coalition: Militarized anti-anomalous operations.",
		"uiu" = "UIU: FBI's anomalous incidents unit.",
		"mcd" = "Marshall, Carter & Dark: Elite anomalous commerce.",
		"serpents_hand" = "Serpent's Hand: Anomalous liberation movement.",
		"chaos_insurgency" = "Chaos Insurgency: Paramilitary splinter group."
	)

/datum/character_setup_ui/proc/get_class_lore()
	return list(
		"administrative" = "Administration: command, coordination, and oversight.",
		"security" = "Security: protection, enforcement, rapid response.",
		"research" = "Research: discovery, experimentation, documentation.",
		"medical" = "Medical: care, triage, surgery, biohazards.",
		"engineering" = "Engineering: infrastructure, power, containment systems.",
		"intelligence" = "Intelligence: analysis, investigation, covert ops."
	)

/datum/character_setup_ui/proc/get_faction_class_jobs(faction_id, class_id, player_rank = 0, player_class_id = "")
	var/list/jobs = list()
	switch(faction_id)
		if ("foundation")
			switch(class_id)
				if ("administrative")
					jobs += list(JOB_SITE_DIRECTOR, JOB_HUMAN_RESOURCES_DIRECTOR, JOB_ETHICS_COMMITTEE_LIAISON, JOB_COMMUNICATIONS_DIRECTOR)
				if ("security")
					jobs += list(JOB_GUARD_COMMANDER, JOB_EZ_ZONE_SUPERVISOR, JOB_SENIOR_EZ_GUARD, JOB_EZ_GUARD, JOB_JUNIOR_EZ_GUARD, JOB_LCZ_ZONE_JUNIOR_LIEUTENANT, JOB_SENIOR_LCZ_GUARD, JOB_LCZ_GUARD, JOB_JUNIOR_LCZ_GUARD, JOB_HCZ_ZONE_SENIOR_LIEUTENANT, JOB_SENIOR_HCZ_GUARD, JOB_HCZ_GUARD, JOB_JUNIOR_HCZ_GUARD, JOB_INVESTIGATIONS_AGENT, JOB_RAISA_AGENT)
				if ("research")
					jobs += list(JOB_RESEARCH_DIRECTOR, JOB_ASSISTANT_RESEARCH_DIRECTOR, JOB_SENIOR_RESEARCHER, JOB_RESEARCHER, JOB_JUNIOR_RESEARCHER)
				if ("medical")
					jobs += list(JOB_MEDICAL_DIRECTOR, JOB_ASSISTANT_MEDICAL_DIRECTOR, JOB_MEDICAL_DOCTOR, JOB_SURGEON, JOB_PARAMEDIC, JOB_CHEMIST, JOB_TRAINEE_DOCTOR, JOB_VIROLOGIST, JOB_PSYCHOLOGIST)
				if ("engineering")
					jobs += list(JOB_ENGINEERING_DIRECTOR, JOB_ASSISTANT_ENGINEERING_DIRECTOR, JOB_CONTAINMENT_ENGINEER, JOB_SENIOR_ENGINEER, JOB_ENGINEER, JOB_JUNIOR_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_IT_TECHNICIAN, JOB_LOGISTICS_OFFICER, JOB_LOGISTICS_TECHNICIAN)
				if ("intelligence")
					jobs += list(JOB_INVESTIGATIONS_AGENT, JOB_RAISA_AGENT)
		if ("goc")
			jobs += list(JOB_GOC_REP)
		if ("uiu")
			jobs += list(JOB_UIU_REP)
		if ("mcd")
			jobs += list(JOB_MCD_REP)
		if ("serpents_hand")
			jobs += list()
		if ("chaos_insurgency")
			jobs += list()
	if (player_rank <= 0 || !player_class_id || player_class_id != class_id)
		return jobs
	var/list/filtered = list()
	for (var/job in jobs)
		var/required = get_required_rank_for_job(class_id, job)
		if (player_rank >= required)
			filtered += job
	return filtered

/datum/character_setup_ui/proc/get_required_rank_for_job(class_id, job_title)
	switch(class_id)
		if("administrative")
			switch(job_title)
				if(JOB_COMMUNICATIONS_DIRECTOR)
					return 0
				if(JOB_ETHICS_COMMITTEE_LIAISON)
					return 1
				if(JOB_HUMAN_RESOURCES_DIRECTOR)
					return 3
				if(JOB_SITE_DIRECTOR)
					return 5
		if("security")
			switch(job_title)
				if(JOB_JUNIOR_LCZ_GUARD, JOB_JUNIOR_HCZ_GUARD, JOB_JUNIOR_EZ_GUARD)
					return 0
				if(JOB_LCZ_GUARD, JOB_HCZ_GUARD, JOB_EZ_GUARD)
					return 1
				if(JOB_SENIOR_LCZ_GUARD, JOB_SENIOR_HCZ_GUARD, JOB_SENIOR_EZ_GUARD)
					return 2
				if(JOB_LCZ_ZONE_JUNIOR_LIEUTENANT, JOB_HCZ_ZONE_SENIOR_LIEUTENANT, JOB_EZ_ZONE_SUPERVISOR, JOB_INVESTIGATIONS_AGENT)
					return 3
				if(JOB_GUARD_COMMANDER, JOB_RAISA_AGENT)
					return 4
		if("research")
			switch(job_title)
				if(JOB_JUNIOR_RESEARCHER)
					return 0
				if(JOB_RESEARCHER)
					return 1
				if(JOB_SENIOR_RESEARCHER)
					return 2
				if(JOB_ASSISTANT_RESEARCH_DIRECTOR)
					return 3
				if(JOB_RESEARCH_DIRECTOR)
					return 5
		if("medical")
			switch(job_title)
				if(JOB_TRAINEE_DOCTOR)
					return 0
				if(JOB_CHEMIST, JOB_PSYCHOLOGIST)
					return 1
				if(JOB_MEDICAL_DOCTOR, JOB_PARAMEDIC)
					return 2
				if(JOB_SURGEON, JOB_VIROLOGIST)
					return 3
				if(JOB_ASSISTANT_MEDICAL_DIRECTOR)
					return 4
				if(JOB_MEDICAL_DIRECTOR)
					return 5
		if("engineering")
			switch(job_title)
				if(JOB_JUNIOR_ENGINEER, JOB_LOGISTICS_TECHNICIAN)
					return 0
				if(JOB_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_IT_TECHNICIAN)
					return 1
				if(JOB_SENIOR_ENGINEER, JOB_CONTAINMENT_ENGINEER, JOB_LOGISTICS_OFFICER)
					return 2
				if(JOB_ASSISTANT_ENGINEERING_DIRECTOR)
					return 4
				if(JOB_ENGINEERING_DIRECTOR)
					return 5
		if("intelligence")
			switch(job_title)
				if(JOB_INVESTIGATIONS_AGENT)
					return 0
				if(JOB_RAISA_AGENT)
					return 3
	return 0

/datum/character_setup_ui/proc/get_job_description(job_title)
	var/datum/job/J = SSjob.GetJob(job_title)
	if (J && istext(J.description))
		return J.description
	return "No description available."
