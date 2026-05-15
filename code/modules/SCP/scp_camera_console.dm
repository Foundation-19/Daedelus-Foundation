/obj/machinery/computer/scp_camera_console
	name = "SCP Camera Console"
	desc = "A secure console for monitoring cameras across SCP containment zones."
	icon = 'icons/obj/computer.dmi'
	icon_state = "cameras"
	req_access = list(ACCESS_SECURITY)
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/scp_camera_console

	var/current_zone = "All Zones"
	var/list/alert_log = list()
	var/max_alerts = 50
	var/motion_detection_enabled = TRUE
	var/anomaly_detection_enabled = TRUE

/obj/machinery/computer/scp_camera_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPCameraConsole")
		ui.open()

/obj/machinery/computer/scp_camera_console/ui_data(mob/user)
	var/list/data = list()
	data["current_zone"] = current_zone
	data["motion_detection"] = motion_detection_enabled
	data["anomaly_detection"] = anomaly_detection_enabled
	data["zones"] = list("All Zones", "Light Containment", "Heavy Containment", "Entrance Zone", "D-Class Block", "Surface")

	var/list/cameras = list()
	for(var/obj/machinery/camera/C in get_zone_cameras(current_zone))
		if(C.machine_stat & NOPOWER)
			continue
		var/area/cam_area = get_area(C)
		cameras += list(list(
			"name" = C.c_tag || "Unknown",
			"area" = cam_area?.name || "Unknown",
			"status" = C.machine_stat & BROKEN ? "broken" : "active",
			"network" = length(C.network) ? C.network[1] : "unknown",
			"ref" = "\ref[C]",
		))
	data["cameras"] = cameras
	data["camera_count"] = length(cameras)
	data["broken_count"] = 0
	for(var/obj/machinery/camera/C in get_zone_cameras(current_zone))
		if(C.machine_stat & BROKEN)
			data["broken_count"]++

	data["alerts"] = list()
	var/alert_count = 0
	for(var/i = length(alert_log); i >= max(1, length(alert_log) - 15); i--)
		data["alerts"] += list(alert_log[i])
		alert_count++
		if(alert_count >= 15)
			break

	return data

/obj/machinery/computer/scp_camera_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_zone")
			current_zone = params["zone"]
			return TRUE
		if("toggle_motion")
			motion_detection_enabled = !motion_detection_enabled
			return TRUE
		if("toggle_anomaly")
			anomaly_detection_enabled = !anomaly_detection_enabled
			return TRUE
		if("view_camera")
			var/obj/machinery/camera/C = locate(params["ref"])
			if(C && !(C.machine_stat & NOPOWER))
				view_camera(usr, C)
			return TRUE
		if("log_alert")
			log_alert(params["text"] || "Manual alert")
			return TRUE

/obj/machinery/computer/scp_camera_console/proc/get_zone_cameras(zone)
	. = list()
	for(var/obj/machinery/camera/C in INSTANCES_OF(/obj/machinery/camera))
		if(!C)
			continue
		var/area/cam_area = get_area(C)
		if(!cam_area)
			continue
		if(zone == "All Zones")
			if(istype(cam_area, /area/scp))
				. += C
		else
			var/area/zone_type = camera_zone_to_area(zone)
			if(zone_type && istype(cam_area, zone_type))
				. += C

/obj/machinery/computer/scp_camera_console/proc/camera_zone_to_area(zone)
	switch(zone)
		if("Light Containment")
			return /area/scp/lcz
		if("Heavy Containment")
			return /area/scp/hcz
		if("Entrance Zone")
			return /area/scp/ez
		if("D-Class Block")
			return /area/scp/dclass
		if("Surface")
			return /area/scp/surface
	return null

/obj/machinery/computer/scp_camera_console/proc/view_camera(mob/user, obj/machinery/camera/C)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.reset_perspective(C)
	addtimer(CALLBACK(H, /mob/proc/reset_perspective), 100)

/obj/machinery/computer/scp_camera_console/proc/log_alert(alert_text)
	alert_log += list(list("text" = alert_text, "time" = time2text(world.time, "HH:MM:SS")))
	if(length(alert_log) > max_alerts)
		alert_log.Cut(1, 2)

/obj/machinery/computer/scp_camera_console/ui_state(mob/user)
	return GLOB.default_state

/obj/item/circuitboard/computer/scp_camera_console
	name = "SCP Camera Console (Computer Board)"
	build_path = /obj/machinery/computer/scp_camera_console
