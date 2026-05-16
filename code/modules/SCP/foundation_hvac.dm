/obj/machinery/atmospherics/components/unary/vent_pump/foundation_hvac
	name = "Foundation HVAC Vent"
	desc = "A heavy-duty ventilation pump for the underground facility's HVAC system."
	icon_state = "vent_map-1"

/obj/machinery/atmospherics/components/unary/vent_pump/foundation_hvac/on
	use_power = IDLE_POWER_USE
	icon_state = "vent_map-1"
	pump_direction = 1

/obj/machinery/atmospherics/components/unary/vent_scrubber/foundation_hvac
	name = "Foundation HVAC Scrubber"
	desc = "A filtration scrubber for the facility's HVAC system. Removes contaminants and biohazards."
	icon_state = "scrub_map-1"
	scrubbing = TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/foundation_hvac/on
	use_power = IDLE_POWER_USE
	icon_state = "scrub_map-1"
	scrubbing = TRUE

/obj/machinery/hvac_control_console
	name = "HVAC Control Console"
	desc = "A console for monitoring and controlling the facility's ventilation systems."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30

/obj/machinery/hvac_control_console/attack_hand(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/machinery/hvac_control_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HVACControl", name)
		ui.open()

/obj/machinery/hvac_control_console/ui_data(mob/user)
	var/list/data = list()
	data["zones"] = list()
	var/list/zones = list(
		"Light Containment Zone" = /area/scp/lcz,
		"Heavy Containment Zone" = /area/scp/hcz,
		"Entrance Zone" = /area/scp/ez,
		"D-Class Block" = /area/scp/dclass,
		"Surface" = /area/scp/surface,
	)
	for(var/zone_name in zones)
		var/list/zone_data = list()
		zone_data["name"] = zone_name
		zone_data["vents_active"] = 0
		zone_data["scrubbers_active"] = 0
		zone_data["vents_total"] = 0
		zone_data["scrubbers_total"] = 0
		var/area/zone_type = zones[zone_name]
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/V in INSTANCES_OF(/obj/machinery/atmospherics/components/unary/vent_pump))
			var/area/A = get_area(V)
			if(istype(A, zone_type))
				zone_data["vents_total"]++
				if(V.on)
					zone_data["vents_active"]++
		for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/S in INSTANCES_OF(/obj/machinery/atmospherics/components/unary/vent_scrubber))
			var/area/A = get_area(S)
			if(istype(A, zone_type))
				zone_data["scrubbers_total"]++
				if(S.on)
					zone_data["scrubbers_active"]++
		data["zones"] += list(zone_data)
	return data

/obj/machinery/hvac_control_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ENGINEERING in id_card.access))
		to_chat(H, span_warning("Engineering access required."))
		return

	switch(action)
		if("toggle_vents")
			var/zone_name = params["zone"]
			var/area/zone_type
			switch(zone_name)
				if("Light Containment Zone")
					zone_type = /area/scp/lcz
				if("Heavy Containment Zone")
					zone_type = /area/scp/hcz
				if("Entrance Zone")
					zone_type = /area/scp/ez
				if("D-Class Block")
					zone_type = /area/scp/dclass
				if("Surface")
					zone_type = /area/scp/surface
			if(!zone_type)
				return
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/V in INSTANCES_OF(/obj/machinery/atmospherics/components/unary/vent_pump))
				var/area/A = get_area(V)
				if(istype(A, zone_type))
					V.on = !V.on
			log_game("[key_name(H)] toggled vents in [zone_name].")
		if("toggle_scrubbers")
			var/zone_name = params["zone"]
			var/area/zone_type
			switch(zone_name)
				if("Light Containment Zone")
					zone_type = /area/scp/lcz
				if("Heavy Containment Zone")
					zone_type = /area/scp/hcz
				if("Entrance Zone")
					zone_type = /area/scp/ez
				if("D-Class Block")
					zone_type = /area/scp/dclass
				if("Surface")
					zone_type = /area/scp/surface
			if(!zone_type)
				return
			for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/S in INSTANCES_OF(/obj/machinery/atmospherics/components/unary/vent_scrubber))
				var/area/A = get_area(S)
				if(istype(A, zone_type))
					S.on = !S.on
			log_game("[key_name(H)] toggled scrubbers in [zone_name].")
