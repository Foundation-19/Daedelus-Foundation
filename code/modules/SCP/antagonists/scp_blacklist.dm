#define SCP_BLACKLIST_FILE "data/scp_blacklist.json"

/datum/scp_blacklist
	var/list/per_scp_blacklist = list()
	var/list/category_blacklist = list()
	var/list/global_blacklist = list()

/datum/scp_blacklist/proc/is_blacklisted(ckey, scp_type)
	if(!ckey)
		return FALSE
	var/ckey_lower = ckey(ckey)
	if(ckey_lower in global_blacklist)
		return TRUE
	if(scp_type)
		var/list/scp_bans = per_scp_blacklist[ckey_lower]
		if(scp_bans && (scp_type in scp_bans))
			return TRUE
		var/category = get_scp_category(scp_type)
		if(category && (category in category_blacklist))
			if(ckey_lower in category_blacklist[category])
				return TRUE
	return FALSE

/datum/scp_blacklist/proc/get_blacklist_reason(ckey, scp_type)
	if(!ckey)
		return null
	var/ckey_lower = ckey(ckey)
	if(ckey_lower in global_blacklist)
		var/list/entry = global_blacklist[ckey_lower]
		return entry["reason"] || "Globally blacklisted from all SCPs"
	if(scp_type)
		var/list/scp_bans = per_scp_blacklist[ckey_lower]
		if(scp_bans && (scp_type in scp_bans))
			var/list/entry = scp_bans[scp_type]
			return entry["reason"] || "Blacklisted from this SCP"
		var/category = get_scp_category(scp_type)
		if(category && (category in category_blacklist))
			if(ckey_lower in category_blacklist[category])
				var/list/entry = category_blacklist[category][ckey_lower]
				return entry["reason"] || "Blacklisted from [category]-class SCPs"
	return null

/datum/scp_blacklist/proc/add_scp_blacklist(ckey, scp_type, reason, admin_key)
	if(!ckey || !scp_type)
		return FALSE
	var/ckey_lower = ckey(ckey)
	if(!per_scp_blacklist[ckey_lower])
		per_scp_blacklist[ckey_lower] = list()
	per_scp_blacklist[ckey_lower][scp_type] = list(
		"reason" = reason || "No reason provided",
		"admin" = admin_key || "System",
		"timestamp" = world.time,
		"date" = time2text(world.timeofday, "YYYY-MM-DD HH:MM"),
	)
	save_blacklist()
	log_admin("[admin_key] blacklisted [ckey_lower] from SCP role [scp_type]. Reason: [reason]")
	message_admins("[admin_key] blacklisted [ckey_lower] from SCP role [scp_type]. Reason: [reason]")
	return TRUE

/datum/scp_blacklist/proc/remove_scp_blacklist(ckey, scp_type)
	if(!ckey)
		return FALSE
	var/ckey_lower = ckey(ckey)
	if(per_scp_blacklist[ckey_lower])
		per_scp_blacklist[ckey_lower] -= scp_type
		if(!length(per_scp_blacklist[ckey_lower]))
			per_scp_blacklist -= ckey_lower
	save_blacklist()
	return TRUE

/datum/scp_blacklist/proc/add_category_blacklist(ckey, category, reason, admin_key)
	if(!ckey || !category)
		return FALSE
	var/ckey_lower = ckey(ckey)
	if(!category_blacklist[category])
		category_blacklist[category] = list()
	category_blacklist[category][ckey_lower] = list(
		"reason" = reason || "No reason provided",
		"admin" = admin_key || "System",
		"timestamp" = world.time,
		"date" = time2text(world.timeofday, "YYYY-MM-DD HH:MM"),
	)
	save_blacklist()
	log_admin("[admin_key] blacklisted [ckey_lower] from [category]-class SCPs. Reason: [reason]")
	message_admins("[admin_key] blacklisted [ckey_lower] from [category]-class SCPs. Reason: [reason]")
	return TRUE

/datum/scp_blacklist/proc/remove_category_blacklist(ckey, category)
	if(!ckey || !category)
		return FALSE
	var/ckey_lower = ckey(ckey)
	if(category_blacklist[category])
		category_blacklist[category] -= ckey_lower
		if(!length(category_blacklist[category]))
			category_blacklist -= category
	save_blacklist()
	return TRUE

/datum/scp_blacklist/proc/add_global_blacklist(ckey, reason, admin_key)
	if(!ckey)
		return FALSE
	var/ckey_lower = ckey(ckey)
	global_blacklist[ckey_lower] = list(
		"reason" = reason || "No reason provided",
		"admin" = admin_key || "System",
		"timestamp" = world.time,
		"date" = time2text(world.timeofday, "YYYY-MM-DD HH:MM"),
	)
	save_blacklist()
	log_admin("[admin_key] globally blacklisted [ckey_lower] from all SCPs. Reason: [reason]")
	message_admins("[admin_key] globally blacklisted [ckey_lower] from all SCPs. Reason: [reason]")
	return TRUE

/datum/scp_blacklist/proc/remove_global_blacklist(ckey)
	if(!ckey)
		return FALSE
	var/ckey_lower = ckey(ckey)
	global_blacklist -= ckey_lower
	save_blacklist()
	return TRUE

/datum/scp_blacklist/proc/remove_all_blacklists(ckey)
	if(!ckey)
		return FALSE
	var/ckey_lower = ckey(ckey)
	per_scp_blacklist -= ckey_lower
	global_blacklist -= ckey_lower
	for(var/category in category_blacklist)
		category_blacklist[category] -= ckey_lower
		if(!length(category_blacklist[category]))
			category_blacklist -= category
	save_blacklist()
	return TRUE

/datum/scp_blacklist/proc/get_all_blacklists_for(ckey)
	if(!ckey)
		return list()
	var/ckey_lower = ckey(ckey)
	var/list/result = list()
	if(ckey_lower in global_blacklist)
		result["global"] = global_blacklist[ckey_lower]
	var/list/scp_bans = per_scp_blacklist[ckey_lower]
	if(scp_bans)
		result["scp_bans"] = scp_bans
	for(var/category in category_blacklist)
		if(ckey_lower in category_blacklist[category])
			if(!result["category_bans"])
				result["category_bans"] = list()
			result["category_bans"][category] = category_blacklist[category][ckey_lower]
	return result

/datum/scp_blacklist/proc/get_all_blacklists_data()
	var/list/result = list()
	var/list/entries = list()
	for(var/ckey_lower in global_blacklist)
		var/list/entry = global_blacklist[ckey_lower]
		entries += list(list(
			"ckey" = ckey_lower,
			"type" = "global",
			"target" = "ALL SCPs",
			"reason" = entry["reason"] || "",
			"admin" = entry["admin"] || "Unknown",
			"date" = entry["date"] || "Unknown",
		))
	for(var/ckey_lower in per_scp_blacklist)
		var/list/scp_bans = per_scp_blacklist[ckey_lower]
		for(var/scp_type in scp_bans)
			var/list/entry = scp_bans[scp_type]
			var/scp_name = scp_type
			var/datum/scp_role_controller/controller = GLOB.scp_role_controller
			if(controller)
				scp_name = controller.get_role_name(scp_type) || scp_type
			entries += list(list(
				"ckey" = ckey_lower,
				"type" = "scp",
				"target" = scp_name,
				"reason" = entry["reason"] || "",
				"admin" = entry["admin"] || "Unknown",
				"date" = entry["date"] || "Unknown",
			))
	for(var/category in category_blacklist)
		for(var/ckey_lower in category_blacklist[category])
			var/list/entry = category_blacklist[category][ckey_lower]
			entries += list(list(
				"ckey" = ckey_lower,
				"type" = "category",
				"target" = "[category]-class",
				"reason" = entry["reason"] || "",
				"admin" = entry["admin"] || "Unknown",
				"date" = entry["date"] || "Unknown",
			))
	result["entries"] = entries
	return result

/datum/scp_blacklist/proc/get_scp_category(scp_type)
	var/datum/scp_role_controller/controller = GLOB.scp_role_controller
	var/role_name = controller?.get_role_name(scp_type) || ""
	var/datum/scp/SCP = controller?.get_SCP_for_type(scp_type)
	if(SCP)
		return uppertext(SCP.classification)
	var/list/scp_templates = SSscp_persistence?.manager?.scp_configurations
	if(scp_templates)
		for(var/scp_id in scp_templates)
			if(findtext(role_name, scp_id))
				var/list/config = scp_templates[scp_id]
				return uppertext(config["class"] || "EUCLID")
	return "EUCLID"

/datum/scp_blacklist/proc/save_blacklist()
	var/list/data = list(
		"per_scp_blacklist" = per_scp_blacklist,
		"category_blacklist" = category_blacklist,
		"global_blacklist" = global_blacklist,
	)
	rustg_file_write(json_encode(data), SCP_BLACKLIST_FILE)

/datum/scp_blacklist/proc/load_blacklist()
	if(!fexists(SCP_BLACKLIST_FILE))
		return
	var/json_data = file2text(SCP_BLACKLIST_FILE)
	var/list/data = json_decode(json_data)
	if(!data)
		return
	per_scp_blacklist = data["per_scp_blacklist"] || list()
	category_blacklist = data["category_blacklist"] || list()
	global_blacklist = data["global_blacklist"] || list()

GLOBAL_DATUM_INIT(scp_blacklist, /datum/scp_blacklist, new())

/datum/scp_blacklist/New()
	load_blacklist()

/proc/check_scp_blacklist(ckey, scp_type)
	if(!GLOB.scp_blacklist)
		return FALSE
	return GLOB.scp_blacklist.is_blacklisted(ckey, scp_type)

/proc/get_scp_blacklist_reason(ckey, scp_type)
	if(!GLOB.scp_blacklist)
		return null
	return GLOB.scp_blacklist.get_blacklist_reason(ckey, scp_type)
