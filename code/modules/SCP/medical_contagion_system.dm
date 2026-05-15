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

/obj/item/reagent_containers/pill/scp500
	name = "SCP-500 pill"
	desc = "A small red pill. It is said to cure any disease, poison, or affliction when consumed."
	icon_state = "pill4"
	color = "#ff0000"

/obj/item/reagent_containers/pill/scp500/Initialize()
	. = ..()

/obj/item/reagent_containers/pill/scp500/on_consumption(mob/M, mob/user)
	. = ..()

	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

	H.adjustBruteLoss(-H.getBruteLoss())
	H.adjustFireLoss(-H.getFireLoss())
	H.setToxLoss(0)
	H.setOxyLoss(0)
	H.setCloneLoss(0)
	if(H.stamina)
		H.stamina.adjust(H.stamina.maximum - H.stamina.current)
	H.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
	H.reagents?.remove_all()
	H.SetUnconscious(0)
	H.SetStun(0)
	H.SetParalyzed(0)
	H.SetImmobilized(0)
	H.SetSleeping(0)
	H.hallucination = 0

	if(HAS_TRAIT(H, TRAIT_PESTILENCE))
		REMOVE_TRAIT(H, TRAIT_PESTILENCE, "scp049")

	H.adjustBruteLoss(-50)
	if(H.sanity)
		H.sanity.adjust_sanity(30, "scp500_cure")

	H.visible_message(span_notice("[H] swallows a small red pill and immediately looks completely revitalized!"), span_notice("You swallow the red pill. Every ache, every illness, every affliction vanishes instantly. You feel perfect."))

/obj/item/reagent_containers/pill/scp500/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A small red pill from SCP-500. One dose cures any disease or affliction. There are only 47 of these in existence."))

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

/obj/machinery/computer/contagion_console
	name = "contagion monitoring console"
	desc = "A console for tracking active contagions, quarantine zones, and exposure chains."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200

/obj/machinery/computer/contagion_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ContagionConsole", "Contagion Monitor")
		ui.open()

/obj/machinery/computer/contagion_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/contagion_console/ui_data(mob/user)
	var/list/data = list()

	var/list/contagions = list()
	var/list/zones = list()
	var/list/chains = list()

	if(GLOB.contagion_tracker)
		for(var/list/contagion in GLOB.contagion_tracker.active_contagions)
			var/mob/living/carbon/human/carrier = contagion["carrier"]
			contagions += list(list(
				"carrier_name" = carrier ? carrier.name : "Unknown",
				"carrier_ckey" = contagion["ckey"],
				"contagion_type" = contagion["contagion_type"],
				"spread_count" = contagion["spread_count"],
				"active" = carrier && carrier.stat != DEAD
			))

		for(var/list/zone in GLOB.contagion_tracker.quarantine_zones)
			var/area/A = zone["area"]
			zones += list(list(
				"area_name" = A ? A.name : "Unknown",
				"reason" = zone["reason"],
				"declared_time" = zone["declared_time"]
			))

		for(var/ckey in GLOB.contagion_tracker.exposed_personnel)
			var/list/exposures = GLOB.contagion_tracker.exposed_personnel[ckey]
			var/list/exposure_data = list()
			for(var/list/exposure in exposures)
				exposure_data += list(list(
					"contagion_type" = exposure["contagion_type"],
					"exposure_time" = exposure["exposure_time"],
					"source" = exposure["source"]
				))
			chains += list(list(
				"ckey" = ckey,
				"exposures" = exposure_data
			))

	data["contagions"] = contagions
	data["quarantine_zones"] = zones
	data["exposure_chains"] = chains
	data["time"] = world.time

	return data

/obj/machinery/computer/contagion_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		to_chat(usr, span_warning("Access denied. Requires Medical access."))
		return

	switch(action)
		if("declare_quarantine")
			var/area/A = get_area(usr)
			if(!A)
				return
			var/reason = params["reason"] || "Contagion risk detected"
			if(GLOB.contagion_tracker)
				GLOB.contagion_tracker.declare_quarantine(A, reason)
		if("lift_quarantine")
			var/area/A = get_area(usr)
			if(!A)
				return
			if(GLOB.contagion_tracker)
				GLOB.contagion_tracker.lift_quarantine(A)
		if("view_exposure_chain")
			var/ckey = params["ckey"]
			if(!ckey || !GLOB.contagion_tracker)
				return
			var/list/exposures = GLOB.contagion_tracker.exposed_personnel[ckey]
			if(!length(exposures))
				to_chat(usr, span_notice("No exposure data for [ckey]."))
				return
			to_chat(usr, span_notice("<b>Exposure Chain for [ckey]:</b>"))
			for(var/list/exposure in exposures)
				to_chat(usr, span_notice("- [exposure["contagion_type"]] from [exposure["source"]] at [time2text(exposure["exposure_time"], "hh:mm:ss")]"))
		if("order_scp500")
			to_chat(usr, span_notice("SCP-500 requisition submitted. Pills are admin-spawnable only."))
