/datum/loadout_ui
	var/client/owner

/datum/loadout_ui/New(client/C)
	. = ..()
	owner = C
	ui_interact(C.mob)

/datum/loadout_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/loadout_ui/ui_status(mob/user, datum/ui_state/state)
	return user?.client == owner ? UI_INTERACTIVE : UI_CLOSE

/datum/loadout_ui/ui_static_data(mob/user)
	return list("loadout_entries" = list())

/datum/loadout_ui/ui_interact(mob/user, datum/tgui/ui)
	var/datum/preferences/prefs = user?.client?.prefs
	if (!prefs)
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutPanel")
		ui.set_autoupdate(TRUE)
		ui.open()
	return TRUE

/datum/loadout_ui/ui_data(mob/user)
	var/datum/preferences/prefs = user?.client?.prefs
	var/list/data = list()

	var/list/loadout = prefs?.read_preference(/datum/preference/blob/loadout) || list()
	var/list/current_items = list()
	for (var/datum/loadout_entry/E as anything in loadout)
		var/datum/loadout_item/LI = locate(E.path) in GLOB.loadout_items
		if(!LI)
			continue
		current_items += list(list(
			"path" = "[E.path]",
			"name" = E.custom_name || LI.name,
			"desc" = E.custom_desc || LI.description,
			"cost" = LI.cost,
			"equipped" = TRUE
		))
	data["current_loadout"] = current_items

	data["categories"] = list()
	for(var/category in GLOB.loadout_category_to_subcategory_to_items)
		data["categories"] += category
	data["current_category"] = prefs.loadout_category || LOADOUT_CATEGORY_BACKPACK

	data["subcategories"] = list()
	if(data["current_category"] in GLOB.loadout_category_to_subcategory_to_items)
		for(var/subcategory in GLOB.loadout_category_to_subcategory_to_items[data["current_category"]])
			data["subcategories"] += subcategory
	data["current_subcategory"] = prefs.loadout_subcategory || LOADOUT_SUBCATEGORY_MISC

	var/list/available_items = list()
	var/list/items_in_subcat = GLOB.loadout_category_to_subcategory_to_items[data["current_category"]]?[data["current_subcategory"]]
	for(var/datum/loadout_item/LI as anything in items_in_subcat)
		var/datum/loadout_entry/entry = prefs.get_loadout_entry_for_loadout_item(LI, loadout)
		available_items += list(list(
			"path" = "[LI.type]",
			"name" = LI.name,
			"desc" = LI.description,
			"cost" = LI.cost,
			"equipped" = !!entry
		))
	data["available_items"] = available_items

	data["remaining_points"] = prefs.calculate_loadout_points()
	data["max_points"] = LOADOUT_POINTS_MAX

	return data

/datum/loadout_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/datum/preferences/prefs = owner?.prefs
	switch(action)
		if ("loadout_toggle")
			var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/loadout]
			var/result = P.button_act(owner.mob, prefs, list("item" = params["item"], "change_loadout" = 1))
			if(result)
				SStgui.update_uis(src)
				for(var/datum/tgui/char_ui in SStgui.open_uis)
					if(char_ui.interface == "CharacterSetup" && char_ui.user?.client == owner)
						char_ui.update_static_data()
			return result
		if ("set_category")
			var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/loadout]
			var/result = P.button_act(owner.mob, prefs, list("category_set" = params["category"]))
			if(result)
				SStgui.update_uis(src)
			return result
		if ("set_subcategory")
			var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/loadout]
			var/result = P.button_act(owner.mob, prefs, list("subcategory_set" = params["subcategory"]))
			if(result)
				SStgui.update_uis(src)
			return result
		if ("close")
			return TRUE
	return FALSE
