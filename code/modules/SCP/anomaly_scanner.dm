/obj/item/anomaly_scanner
	name = "Anomalous Signature Scanner"
	desc = "A handheld device that detects and analyzes nearby anomalous signatures. Used by Foundation personnel to identify SCPs."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	w_class = WEIGHT_CLASS_SMALL
	var/scan_cooldown = 0
	var/scan_cooldown_duration = 100
	var/detection_range = 15
	var/last_scan_results = list()
	var/detect_breached_only = FALSE
	var/show_detailed = FALSE

/obj/item/anomaly_scanner/attack_self(mob/user)
	if(scan_cooldown > 0)
		to_chat(user, span_warning("Scanner is recharging. Wait [ceil(scan_cooldown / 10)] seconds."))
		return

	if(!ishuman(user))
		return

	scan_cooldown = scan_cooldown_duration
	last_scan_results = list()

	var/list/scan_data = list()

	for(var/atom/A in GLOB.SCP_list)
		if(QDELETED(A))
			continue

		var/dist = get_dist(user, A)
		if(dist > detection_range)
			continue

		var/scp_id = "Unknown"
		var/scp_name = "Unknown"
		var/scp_class = "Unknown"
		var/scp_status = "Unknown"
		var/scp_direction = "Unknown"

		if(A.SCP)
			var/datum/scp/scp_datum = A.SCP
			scp_id = scp_datum.get_scp_id()
			scp_name = scp_datum.name
			scp_class = scp_datum.classification
		else if(istype(A, /mob/living/scp))
			var/mob/living/scp/S = A
			if(S.SCP)
				scp_id = S.SCP.get_scp_id()
				scp_name = S.SCP.name
				scp_class = S.SCP.classification

		if(A.vars["containment_status"])
			scp_status = A.vars["containment_status"]

		if(detect_breached_only && scp_status != "breached")
			continue

		var/dir_angle = GetAngle(user, A)
		scp_direction = dir2text(angle2dir(dir_angle))

		scan_data += list(list(
			"scp_id" = scp_id,
			"scp_name" = scp_name,
			"scp_class" = scp_class,
			"status" = scp_status,
			"distance" = dist,
			"direction" = scp_direction,
		))

	last_scan_results = scan_data

	if(length(scan_data) == 0)
		to_chat(user, span_notice("No anomalous signatures detected within range."))
		playsound(src, 'sound/machines/twobeep.ogg', 20, TRUE)
	else
		to_chat(user, span_notice("[length(scan_data)] anomalous signature\s detected! Check scanner display for details."))
		playsound(src, 'sound/machines/triple_beep.ogg', 30, TRUE)

	ui_interact(user)

/obj/item/anomaly_scanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnomalyScanner", "Anomaly Scanner")
		ui.open()

/obj/item/anomaly_scanner/ui_data(mob/user)
	var/list/data = list()
	data["scan_cooldown"] = scan_cooldown
	data["scan_cooldown_max"] = scan_cooldown_duration
	data["detection_range"] = detection_range
	data["detect_breached_only"] = detect_breached_only
	data["show_detailed"] = show_detailed
	data["results"] = last_scan_results
	data["result_count"] = length(last_scan_results)
	return data

/obj/item/anomaly_scanner/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("scan")
			attack_self(ui.user)
			. = TRUE
		if("toggle_breached_only")
			detect_breached_only = !detect_breached_only
			. = TRUE
		if("toggle_detailed")
			show_detailed = !show_detailed
			. = TRUE
		if("set_range")
			var/range = text2num(params["range"])
			if(range)
				detection_range = clamp(range, 5, 30)
			. = TRUE

/obj/item/anomaly_scanner/proc/GetAngle(atom/source_atom, atom/target_atom)
	var/dx = target_atom.x - source_atom.x
	var/dy = target_atom.y - source_atom.y
	if(!dx && !dy)
		return 0
	return ATAN2(dx, dy)

/obj/item/storage/box/anomaly_scanner_kit
	name = "Anomaly Scanner Kit"
	desc = "A kit containing an anomalous signature scanner and documentation."

/obj/item/storage/box/anomaly_scanner_kit/PopulateContents()
	new /obj/item/anomaly_scanner(src)
