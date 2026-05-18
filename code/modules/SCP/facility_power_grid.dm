#define POWER_STATUS_ACTIVE "active"
#define POWER_STATUS_FAILING "failing"
#define POWER_STATUS_CRITICAL "critical"
#define POWER_STATUS_OFFLINE "offline"

/datum/facility_power_zone
	var/name
	var/zone_tag
	var/list/zone_apcs = list()
	var/list/zone_areas = list()
	var/power_status = POWER_STATUS_ACTIVE
	var/power_integrity = 100
	var/emergency_generator = FALSE
	var/emergency_fuel = 0

/datum/facility_power_zone/proc/update_status()
	var/functional_apcs = 0
	var/total_apcs = length(zone_apcs)
	if(!total_apcs)
		power_status = POWER_STATUS_OFFLINE
		power_integrity = 0
		return
	for(var/obj/machinery/power/apc/A as anything in zone_apcs)
		if(A && !QDELETED(A) && !(A.machine_stat & NOPOWER))
			functional_apcs++
	var/ratio = functional_apcs / total_apcs
	power_integrity = round(ratio * 100)
	if(ratio >= 0.9)
		power_status = POWER_STATUS_ACTIVE
	else if(ratio >= 0.5)
		power_status = POWER_STATUS_FAILING
	else if(ratio > 0)
		power_status = POWER_STATUS_CRITICAL
	else
		power_status = POWER_STATUS_OFFLINE

/datum/facility_power_zone/proc/get_living_mobs()
	var/list/mobs = list()
	for(var/obj/machinery/power/apc/A as anything in zone_apcs)
		if(!A || QDELETED(A))
			continue
		var/area/apc_area = A.area
		if(!apc_area)
			continue
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat == DEAD || !H.client)
				continue
			var/area/mob_area = get_area(H)
			if(istype(mob_area, apc_area.type))
				mobs += H
	return mobs

SUBSYSTEM_DEF(facility_power)
	name = "Facility Power"
	wait = 200
	var/list/power_zones = list()
	var/total_grid_integrity = 100
	var/cascade_failure_active = FALSE

/datum/controller/subsystem/facility_power/Initialize()
	initialize_power_zones()
	return ..()

/datum/controller/subsystem/facility_power/fire()
	if(cascade_failure_active)
		process_cascade_failure()
	for(var/zone_key in power_zones)
		var/datum/facility_power_zone/zone = power_zones[zone_key]
		zone.update_status()
		if(zone.emergency_generator && zone.emergency_fuel > 0)
			zone.emergency_fuel = max(0, zone.emergency_fuel - 0.5)
			if(zone.emergency_fuel <= 0)
				zone.emergency_generator = FALSE
				for(var/obj/machinery/power/apc/A as anything in zone.zone_apcs)
					if(A && !QDELETED(A))
						A.energy_fail(rand(30, 60))
	update_grid_integrity()

/datum/controller/subsystem/facility_power/proc/initialize_power_zones()
	var/list/zone_defs = list(
		"lcz" = list("name" = "Light Containment", "areas" = list(/area/scp/lcz)),
		"hcz" = list("name" = "Heavy Containment", "areas" = list(/area/scp/hcz)),
		"ez" = list("name" = "Entrance Zone", "areas" = list(/area/scp/ez)),
		"administrative" = list("name" = "Administrative", "areas" = list(/area/scp/ez/offices)),
		"medical" = list("name" = "Medical", "areas" = list(/area/scp/lcz/medical_bay)),
		"security" = list("name" = "Security", "areas" = list(/area/scp/hcz/armory)),
		"engineering" = list("name" = "Engineering", "areas" = list(/area/scp/hcz/generator)),
		"surface" = list("name" = "Surface", "areas" = list(/area/scp/surface)),
	)
	for(var/tag in zone_defs)
		var/list/def = zone_defs[tag]
		var/datum/facility_power_zone/zone = new()
		zone.name = def["name"]
		zone.zone_tag = tag
		zone.zone_areas = def["areas"]
		power_zones[tag] = zone
	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		var/datum/facility_power_zone/Z = get_zone_for_apc(A)
		if(Z)
			Z.zone_apcs += A
	flags &= ~SS_NO_FIRE

/datum/controller/subsystem/facility_power/proc/get_zone_for_apc(obj/machinery/power/apc/apc)
	if(!apc || !apc.area)
		return null
	var/area/apc_area = apc.area
	for(var/zone_key in power_zones)
		var/datum/facility_power_zone/zone = power_zones[zone_key]
		for(var/area_type in zone.zone_areas)
			if(istype(apc_area, area_type))
				return zone
	return null

/datum/controller/subsystem/facility_power/proc/check_zone_status(zone_tag)
	var/datum/facility_power_zone/zone = power_zones[zone_tag]
	if(!zone)
		return POWER_STATUS_OFFLINE
	return zone.power_status

/datum/controller/subsystem/facility_power/proc/trigger_zone_failure(zone_tag, severity)
	var/datum/facility_power_zone/zone = power_zones[zone_tag]
	if(!zone)
		return
	switch(severity)
		if(1)
			var/list/apcs = shuffle(zone.zone_apcs.Copy())
			var/count = max(1, round(length(apcs) * 0.25))
			for(var/i in 1 to count)
				var/obj/machinery/power/apc/A = apcs[i]
				if(A && !QDELETED(A))
					A.energy_fail(rand(10, 30))
			for(var/mob/living/carbon/human/H in zone.get_living_mobs())
				if(prob(40))
					to_chat(H, "<span class='warning'>The lights flicker momentarily...</span>")
					if(H.sanity)
						H.sanity.adjust_sanity(-2, "power_flicker")
		if(2)
			var/list/apcs = shuffle(zone.zone_apcs.Copy())
			var/count = round(length(apcs) * 0.5)
			for(var/i in 1 to count)
				var/obj/machinery/power/apc/A = apcs[i]
				if(A && !QDELETED(A))
					A.energy_fail(rand(30, 90))
			for(var/mob/living/carbon/human/H in zone.get_living_mobs())
				to_chat(H, "<span class='danger'>Emergency lighting activates as power fails across the zone!</span>")
				if(H.sanity)
					H.sanity.adjust_sanity(-5, "power_failure")
		if(3)
			for(var/obj/machinery/power/apc/A as anything in zone.zone_apcs)
				if(A && !QDELETED(A))
					A.energy_fail(rand(60, 120))
			for(var/mob/living/carbon/human/H in zone.get_living_mobs())
				to_chat(H, "<span class='userdanger'>Total power failure! All systems offline!</span>")
				if(H.sanity)
					H.sanity.adjust_sanity(-10, "total_power_failure")
	zone.update_status()

/datum/controller/subsystem/facility_power/proc/trigger_cascade_failure(starting_zone)
	if(cascade_failure_active)
		return
	cascade_failure_active = TRUE
	var/datum/facility_power_zone/zone = power_zones[starting_zone]
	if(!zone)
		cascade_failure_active = FALSE
		return
	trigger_zone_failure(starting_zone, 3)
	priority_announce("CRITICAL: Cascade power failure originating in [zone.name]. Adjacent zones at risk. All engineering personnel respond immediately.", "POWER GRID CASCADE", null, ANNOUNCER_ALERT)
	var/list/adjacent_zones = get_adjacent_zones(starting_zone)
	var/delay = 200
	for(var/adj_tag in adjacent_zones)
		addtimer(CALLBACK(src, .proc/cascade_spread, adj_tag, 2), delay)
		delay += 200
	addtimer(CALLBACK(src, .proc/end_cascade_failure), delay + 100)

/datum/controller/subsystem/facility_power/proc/cascade_spread(zone_tag, severity)
	trigger_zone_failure(zone_tag, severity)
	var/datum/facility_power_zone/zone = power_zones[zone_tag]
	if(zone)
		priority_announce("Cascade failure has spread to [zone.name]. Power integrity compromised.", "POWER GRID CASCADE", null, ANNOUNCER_ALERT)

/datum/controller/subsystem/facility_power/proc/end_cascade_failure()
	cascade_failure_active = FALSE

/datum/controller/subsystem/facility_power/proc/process_cascade_failure()
	for(var/zone_key in power_zones)
		var/datum/facility_power_zone/zone = power_zones[zone_key]
		if(zone.power_status == POWER_STATUS_OFFLINE || zone.power_status == POWER_STATUS_CRITICAL)
			if(prob(5))
				var/list/adjacent = get_adjacent_zones(zone.zone_tag)
				if(length(adjacent))
					var/spread_to = pick(adjacent)
					trigger_zone_failure(spread_to, 1)

/datum/controller/subsystem/facility_power/proc/get_adjacent_zones(zone_tag)
	var/list/adjacency = list(
		"lcz" = list("hcz", "medical", "security"),
		"hcz" = list("lcz", "ez", "engineering"),
		"ez" = list("hcz", "administrative", "surface"),
		"medical" = list("lcz", "administrative"),
		"security" = list("lcz", "administrative"),
		"administrative" = list("ez", "medical", "security"),
		"engineering" = list("hcz", "surface"),
		"surface" = list("ez", "engineering"),
	)
	return adjacency[zone_tag] || list()

/datum/controller/subsystem/facility_power/proc/restore_zone(zone_tag)
	var/datum/facility_power_zone/zone = power_zones[zone_tag]
	if(!zone)
		return
	for(var/obj/machinery/power/apc/A as anything in zone.zone_apcs)
		if(A && !QDELETED(A))
			A.charging = APC_CHARGING
			A.machine_stat &= ~NOPOWER
	zone.power_status = POWER_STATUS_ACTIVE
	zone.power_integrity = 100
	zone.emergency_generator = FALSE
	zone.emergency_fuel = 0
	update_grid_integrity()
	for(var/mob/living/carbon/human/H in zone.get_living_mobs())
		to_chat(H, "<span class='notice'>Power has been restored to the zone. Systems coming back online.</span>")
		if(H.sanity)
			H.sanity.adjust_sanity(5, "power_restored")

/datum/controller/subsystem/facility_power/proc/activate_emergency_generator(zone_tag)
	var/datum/facility_power_zone/zone = power_zones[zone_tag]
	if(!zone)
		return FALSE
	if(zone.emergency_generator)
		return FALSE
	if(zone.emergency_fuel <= 0)
		zone.emergency_fuel = 100
	zone.emergency_generator = TRUE
	var/list/apcs = shuffle(zone.zone_apcs.Copy())
	var/count = max(1, round(length(apcs) * 0.4))
	for(var/i in 1 to count)
		var/obj/machinery/power/apc/A = apcs[i]
		if(A && !QDELETED(A))
			A.charging = APC_CHARGING
			A.machine_stat &= ~NOPOWER
	priority_announce("Emergency generator activated in [zone.name]. Limited power restored. Fuel reserves: [zone.emergency_fuel]%.", "EMERGENCY POWER", null, ANNOUNCER_ALERT)
	return TRUE

/datum/controller/subsystem/facility_power/proc/tamper_apc(obj/machinery/power/apc/apc, mob/living/scp079/tamperer)
	if(!apc || !tamperer)
		return FALSE
	var/datum/facility_power_zone/zone = get_zone_for_apc(apc)
	if(!zone)
		return FALSE
	if(tamperer.tier < 2)
		return FALSE
	if(tamperer.processing_power < 25)
		return FALSE
	tamperer.processing_power -= 25
	apc.energy_fail(rand(30, 90))
	zone.update_status()
	if(prob(30))
		var/list/adjacent = get_adjacent_zones(zone.zone_tag)
		if(length(adjacent))
			var/spread_tag = pick(adjacent)
			trigger_zone_failure(spread_tag, 1)
	return TRUE

/datum/controller/subsystem/facility_power/proc/update_grid_integrity()
	var/total = 0
	var/count = 0
	for(var/zone_key in power_zones)
		var/datum/facility_power_zone/zone = power_zones[zone_key]
		total += zone.power_integrity
		count++
	if(count)
		total_grid_integrity = round(total / count)
	else
		total_grid_integrity = 0

/obj/machinery/computer/facility_power_console
	name = "Facility Power Console"
	desc = "A console for monitoring and managing the facility power grid."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200

/obj/machinery/computer/facility_power_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FacilityPowerConsole", "Facility Power Grid")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/facility_power_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/facility_power_console/ui_data(mob/user)
	var/list/data = list()
	data["total_grid_integrity"] = SSfacility_power.total_grid_integrity
	data["cascade_failure_active"] = SSfacility_power.cascade_failure_active
	var/list/zones = list()
	for(var/zone_tag in SSfacility_power.power_zones)
		var/datum/facility_power_zone/zone = SSfacility_power.power_zones[zone_tag]
		zones += list(list(
			"zone_tag" = zone_tag,
			"name" = zone.name,
			"power_status" = zone.power_status,
			"power_integrity" = zone.power_integrity,
			"apc_count" = length(zone.zone_apcs),
			"emergency_generator" = zone.emergency_generator,
			"emergency_fuel" = zone.emergency_fuel,
		))
	data["zones"] = zones
	return data

/obj/machinery/computer/facility_power_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ENGINEERING in id_card.access))
		to_chat(H, "<span class='warning'>Requires Engineering access.</span>")
		return
	switch(action)
		if("activate_emergency_generator")
			var/zone_tag = params["zone_tag"]
			if(!zone_tag)
				return
			SSfacility_power.activate_emergency_generator(zone_tag)
			. = TRUE
		if("request_power_restore")
			var/zone_tag = params["zone_tag"]
			if(!zone_tag)
				return
			SSfacility_power.restore_zone(zone_tag)
			. = TRUE
		if("view_zone_details")
			var/zone_tag = params["zone_tag"]
			if(!zone_tag)
				return
			var/datum/facility_power_zone/zone = SSfacility_power.power_zones[zone_tag]
			if(!zone)
				return
			var/list/details = list()
			details += "<b>[zone.name]</b>"
			details += "Status: [zone.power_status]"
			details += "Integrity: [zone.power_integrity]%"
			details += "APCs: [length(zone.zone_apcs)]"
			details += "Emergency Generator: [zone.emergency_generator ? "ACTIVE" : "OFFLINE"]"
			details += "Fuel: [zone.emergency_fuel]%"
			var/functional = 0
			for(var/obj/machinery/power/apc/A as anything in zone.zone_apcs)
				if(A && !QDELETED(A) && !(A.machine_stat & NOPOWER))
					functional++
			details += "Functional APCs: [functional]/[length(zone.zone_apcs)]"
			to_chat(H, "<span class='notice'>[details.Join("<br>")]</span>")
			. = TRUE
