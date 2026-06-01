/datum/scp_log_entry
	var/timestamp
	var/log_type
	var/scp_id
	var/actor_ckey
	var/target_ckey
	var/description
	var/location
	var/severity = 1

/datum/scp_log_entry/New(log_type, scp_id, actor_ckey, target_ckey, description, severity)
	src.timestamp = time2text(world.time, "hh:mm:ss")
	src.log_type = log_type
	src.scp_id = scp_id
	src.actor_ckey = actor_ckey
	src.target_ckey = target_ckey
	src.description = description
	src.severity = severity
	var/atom/A = usr
	if(istype(A))
		var/area/ar = get_area(A)
		if(ar)
			src.location = ar.name

/datum/scp_admin_logger
	var/list/log_entries = list()
	var/max_entries = 1000

/datum/scp_admin_logger/proc/log_event(log_type, scp_id, actor_ckey, target_ckey, description, severity)
	var/datum/scp_log_entry/entry = new(log_type, scp_id, actor_ckey, target_ckey, description, severity)
	log_entries += entry
	if(length(log_entries) > max_entries)
		log_entries.Cut(1, length(log_entries) - max_entries + 1)
	return entry

/datum/scp_admin_logger/proc/get_entries(filter_type, filter_scp, filter_ckey, filter_severity)
	var/list/results = list()
	for(var/datum/scp_log_entry/entry in log_entries)
		if(filter_type && entry.log_type != filter_type)
			continue
		if(filter_scp && entry.scp_id != filter_scp)
			continue
		if(filter_ckey && entry.actor_ckey != filter_ckey && entry.target_ckey != filter_ckey)
			continue
		if(filter_severity && entry.severity < filter_severity)
			continue
		results += entry
	return results

/datum/scp_admin_logger/proc/get_recent(count)
	if(!count)
		count = 10
	var/list/results = list()
	var/start = length(log_entries) - count + 1
	if(start < 1)
		start = 1
	for(var/i in start to length(log_entries))
		results += log_entries[i]
	return results

/datum/scp_admin_logger/proc/clear_logs()
	log_entries.Cut()
	return TRUE

GLOBAL_DATUM_INIT(scp_admin_log, /datum/scp_admin_logger, new())

/proc/scp_log_breach(scp_id, actor_ckey)
	return GLOB.scp_admin_log.log_event("breach", scp_id, actor_ckey, null, "[scp_id] containment breach initiated by [actor_ckey].", 3)

/proc/scp_log_recontainment(scp_id, actor_ckey)
	return GLOB.scp_admin_log.log_event("recontainment", scp_id, actor_ckey, null, "[scp_id] recontained by [actor_ckey].", 2)

/proc/scp_log_experiment(scp_id, actor_ckey, target_ckey)
	return GLOB.scp_admin_log.log_event("experiment", scp_id, actor_ckey, target_ckey, "Experiment on [scp_id] by [actor_ckey] on subject [target_ckey].", 1)

/proc/scp_log_interaction(scp_id, actor_ckey, target_ckey, desc)
	return GLOB.scp_admin_log.log_event("interaction", scp_id, actor_ckey, target_ckey, desc, 1)

/proc/scp_log_death(scp_id, target_ckey)
	return GLOB.scp_admin_log.log_event("death", scp_id, null, target_ckey, "Fatality involving [scp_id]: [target_ckey].", 3)

/proc/scp_log_riot(stage, actor_ckey)
	var/severity = stage >= 2 ? 3 : 2
	return GLOB.scp_admin_log.log_event("riot", null, actor_ckey, null, "D-Class riot (Stage [stage]) initiated by [actor_ckey].", severity)

/proc/scp_log_power(zone, event)
	return GLOB.scp_admin_log.log_event("power", null, null, null, "Power event in [zone]: [event].", 2)

/obj/machinery/computer/scp_admin_log_console
	name = "SCP Admin Log Console"
	desc = "A secure terminal for reviewing SCP incident logs."
	icon_screen = "security"
	icon_keyboard = "sec_key"
	circuit = null

/obj/machinery/computer/scp_admin_log_console/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN, FALSE, user))
		to_chat(user, span_warning("Access denied."))
		return
	ui_interact(user)

/obj/machinery/computer/scp_admin_log_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPAdminLogConsole", name)
		ui.open()

/obj/machinery/computer/scp_admin_log_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/scp_admin_log_console/ui_data(mob/user)
	var/list/data = list()
	var/list/entries = list()
	var/datum/scp_admin_logger/logger = GLOB.scp_admin_log
	for(var/datum/scp_log_entry/entry in logger.log_entries)
		entries += list(list(
			"timestamp" = entry.timestamp,
			"log_type" = entry.log_type,
			"scp_id" = entry.scp_id,
			"actor_ckey" = entry.actor_ckey,
			"target_ckey" = entry.target_ckey,
			"description" = entry.description,
			"location" = entry.location,
			"severity" = entry.severity,
		))
	data["entries"] = entries
	data["log_types"] = list("breach", "recontainment", "experiment", "interaction", "death", "achievement", "riot", "power")
	return data

/obj/machinery/computer/scp_admin_log_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN, FALSE, ui.user))
		return
	switch(action)
		if("clear")
			GLOB.scp_admin_log.clear_logs()
			. = TRUE
