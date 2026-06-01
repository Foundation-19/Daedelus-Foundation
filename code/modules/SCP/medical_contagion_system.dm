/datum/contagion_tracker
	var/list/active_contagions = list()
	var/list/quarantine_zones = list()
	var/list/exposed_personnel = list()
	var/processing = FALSE

/datum/contagion_tracker/proc/register_contagion(mob/living/carbon/human/carrier, contagion_type)
	if(!carrier || !contagion_type)
		return

	var/entry = list(
		"carrier" = carrier,
		"ckey" = carrier.ckey,
		"contagion_type" = contagion_type,
		"registered_time" = world.time,
		"spread_count" = 0
	)

	active_contagions += list(entry)

	if(!processing)
		processing = TRUE
		addtimer(CALLBACK(src, PROC_REF(tick)), 5 SECONDS)

	if(!exposed_personnel[carrier.ckey])
		exposed_personnel[carrier.ckey] = list()
	exposed_personnel[carrier.ckey] += list(list(
		"contagion_type" = contagion_type,
		"exposure_time" = world.time,
		"source" = "initial_carrier"
	))

/datum/contagion_tracker/proc/track_exposure(mob/living/carbon/human/carrier, mob/living/carbon/human/exposed)
	if(!carrier || !exposed || carrier == exposed)
		return

	var/contagion_type = null
	for(var/list/contagion in active_contagions)
		if(contagion["carrier"] == carrier)
			contagion_type = contagion["contagion_type"]
			contagion["spread_count"] += 1
			break

	if(!contagion_type)
		return

	if(!exposed_personnel[exposed.ckey])
		exposed_personnel[exposed.ckey] = list()
	exposed_personnel[exposed.ckey] += list(list(
		"contagion_type" = contagion_type,
		"exposure_time" = world.time,
		"source" = carrier.ckey
	))

/datum/contagion_tracker/proc/check_contagion_spread(mob/living/carbon/human/carrier, range)
	var/list/nearby = list()
	if(!carrier)
		return nearby

	var/contagion_type = null
	for(var/list/contagion in active_contagions)
		if(contagion["carrier"] == carrier)
			contagion_type = contagion["contagion_type"]
			break

	if(!contagion_type)
		return nearby

	for(var/mob/living/carbon/human/H in range(range, carrier))
		if(H == carrier || H.stat == DEAD)
			continue
		nearby += H
		track_exposure(carrier, H)

	return nearby

/datum/contagion_tracker/proc/declare_quarantine(area/target_area, reason)
	if(!target_area)
		return

	for(var/list/zone in quarantine_zones)
		if(zone["area"] == target_area)
			return

	quarantine_zones += list(list(
		"area" = target_area,
		"reason" = reason,
		"declared_time" = world.time
	))

	priority_announce("QUARANTINE DECLARED: [target_area.name] has been placed under quarantine. Reason: [reason]. All personnel must evacuate immediately.", null, null, ANNOUNCER_ALERT)

/datum/contagion_tracker/proc/lift_quarantine(area/target_area)
	if(!target_area)
		return

	for(var/i = length(quarantine_zones); i >= 1; i--)
		var/list/zone = quarantine_zones[i]
		if(zone["area"] == target_area)
			quarantine_zones.Cut(i, i + 1)
			priority_announce("QUARANTINE LIFTED: [target_area.name] is no longer under quarantine.", null, null, ANNOUNCER_DEFAULT)
			return

/datum/contagion_tracker/proc/get_contagion_report()
	var/list/report = list()
	report["total_active"] = length(active_contagions)
	report["quarantine_zones"] = length(quarantine_zones)

	var/list/contagion_entries = list()
	for(var/list/contagion in active_contagions)
		var/mob/living/carbon/human/carrier = contagion["carrier"]
		contagion_entries += list(list(
			"carrier_name" = carrier ? carrier.name : "Unknown",
			"carrier_ckey" = contagion["ckey"],
			"contagion_type" = contagion["contagion_type"],
			"spread_count" = contagion["spread_count"],
			"active" = carrier && carrier.stat != DEAD
		))
	report["contagions"] = contagion_entries

	var/list/exposure_chains = list()
	for(var/ckey in exposed_personnel)
		var/list/exposures = exposed_personnel[ckey]
		exposure_chains[ckey] = exposures
	report["exposure_chains"] = exposure_chains

	return report

/datum/contagion_tracker/proc/tick()
	for(var/i = length(active_contagions); i >= 1; i--)
		var/list/contagion = active_contagions[i]
		var/mob/living/carbon/human/carrier = contagion["carrier"]
		if(!carrier || QDELETED(carrier) || carrier.stat == DEAD)
			active_contagions.Cut(i, i + 1)
			continue
		check_contagion_spread(carrier, 3)
	if(length(active_contagions) > 0)
		addtimer(CALLBACK(src, PROC_REF(tick)), 5 SECONDS)
	else
		processing = FALSE

GLOBAL_DATUM_INIT(contagion_tracker, /datum/contagion_tracker, new())

/obj/item/healthanalyzer/scp_medical_scanner
	name = "SCP medical scanner"
	desc = "An advanced health analyzer capable of detecting anomalous diseases, pestilence, and contagion risk."
	icon_state = "health"

/obj/item/healthanalyzer/scp_medical_scanner/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	show_extended_readout(H, user)

/obj/item/healthanalyzer/scp_medical_scanner/attack(mob/living/M, mob/living/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	show_extended_readout(H, user)

/obj/item/healthanalyzer/scp_medical_scanner/proc/show_extended_readout(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return

	var/list/readout = list()

	readout += span_notice("<b>SCP Medical Scanner Report — [H.name]</b>")
	readout += span_notice("Health: [round(H.health / H.maxHealth * 100)]%")

	if(HAS_TRAIT(H, TRAIT_PESTILENCE))
		readout += span_danger("PESTILENCE DETECTED: Subject carries the Pestilence (SCP-049 signature).")
	else
		readout += span_notice("Pestilence: Not detected.")

	var/contagion_risk = "LOW"
	if(GLOB.contagion_tracker)
		for(var/list/contagion in GLOB.contagion_tracker.active_contagions)
			if(contagion["carrier"] == H)
				contagion_risk = "ACTIVE_CARRIER"
				break
		if(contagion_risk == "LOW")
			if(GLOB.contagion_tracker.exposed_personnel[H.ckey])
				contagion_risk = "EXPOSED"
	readout += span_notice("Contagion Risk: [contagion_risk]")

	var/area/A = get_area(H)
	var/quarantine_status = "CLEAR"
	if(GLOB.contagion_tracker)
		for(var/list/zone in GLOB.contagion_tracker.quarantine_zones)
			if(zone["area"] == A)
				quarantine_status = "QUARANTINED"
				break
	readout += span_notice("Area Quarantine Status: [quarantine_status]")

	for(var/line in readout)
		to_chat(user, line)


