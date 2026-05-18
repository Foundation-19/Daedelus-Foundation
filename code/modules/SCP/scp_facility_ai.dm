/obj/item/ai_module/core/full/foundation
	name = "'Foundation Protocols' Core AI Module"
	law_id = AI_LAWS_FOUNDATION

/obj/item/ai_module/core/full/foundation_ethics
	name = "'Foundation Ethics' Core AI Module"
	law_id = "foundation_ethics"

/obj/item/ai_module/core/full/mtf_tactical
	name = "'MTF Tactical' Core AI Module"
	law_id = "mtf_tactical"

/obj/item/ai_module/core/full/containment_priority
	name = "'Containment Priority' Core AI Module"
	law_id = "containment_priority"

/obj/item/ai_module/core/full/research_directive
	name = "'Research Directive' Core AI Module"
	law_id = "research_directive"

/obj/item/ai_module/core/full/antimemetic
	name = "'Antimemetic' Core AI Module"
	law_id = "antimemetic"

/obj/item/storage/box/foundation_ai_kit
	name = "Foundation AI Module Kit"
	desc = "A kit containing Foundation-specific AI modules for installation in the facility AI."

/obj/item/storage/box/foundation_ai_kit/PopulateContents()
	new /obj/item/ai_module/core/full/foundation(src)
	new /obj/item/ai_module/core/full/mtf_tactical(src)
	new /obj/item/ai_module/core/full/containment_priority(src)

/mob/living/silicon/ai
	var/datum/action/innate/ai/foundation_scan/scan_action = null
	var/datum/action/innate/ai/foundation_report/report_action = null

/mob/living/silicon/ai/proc/grant_foundation_abilities()
	if(!scan_action)
		scan_action = new()
		scan_action.Grant(src)
	if(!report_action)
		report_action = new()
		report_action.Grant(src)

/mob/living/silicon/ai/proc/remove_foundation_abilities()
	if(scan_action)
		scan_action.Remove(src)
		QDEL_NULL(scan_action)
	if(report_action)
		report_action.Remove(src)
		QDEL_NULL(report_action)

/datum/action/innate/ai/foundation_scan
	name = "SCP Breach Scan"
	desc = "Scan for active SCP containment breaches."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_camera"

/datum/action/innate/ai/foundation_scan/Activate()
	var/mob/living/silicon/ai/AI = owner
	if(!istype(AI))
		return

	var/list/breaches = list()
	for(var/atom/A in GLOB.SCP_list)
		if(QDELETED(A))
			continue
		var/containment_status = "contained"
		if("containment_status" in A.vars)
			containment_status = A.vars["containment_status"]
		if(containment_status != "breached")
			continue
		var/datum/scp/scp_datum = A.SCP
		var/scp_id = scp_datum ? scp_datum.get_scp_id() : "Unknown"
		var/scp_name = scp_datum ? scp_datum.name : "Unknown"
		var/scp_class = scp_datum ? scp_datum.classification : "Unknown"
		var/area/loc_area = get_area(A)
		breaches += list(list(
			"scp_id" = scp_id,
			"scp_name" = scp_name,
			"object_class" = scp_class,
			"area" = loc_area ? loc_area.name : "Unknown",
		))

	if(!length(breaches))
		to_chat(AI, span_notice("SCP Breach Scan: No active breaches detected. All SCPs contained."))
		return
	var/list/msg = list(span_notice("SCP Breach Scan: [length(breaches)] active breach(es) detected!"))
	for(var/list/breach in breaches)
		msg += span_danger("- [breach["scp_id"]] ([breach["scp_name"]]) | Class: [breach["object_class"]] | Location: [breach["area"]]")
	to_chat(AI, jointext(msg, "\n"))

/datum/action/innate/ai/foundation_report
	name = "SCP Status Report"
	desc = "View the status of all SCP entities."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_camera"

/datum/action/innate/ai/foundation_report/Activate()
	var/mob/living/silicon/ai/AI = owner
	if(!istype(AI))
		return

	var/list/report = list()
	for(var/atom/A in GLOB.SCP_list)
		if(QDELETED(A))
			continue
		var/containment_status = "contained"
		if("containment_status" in A.vars)
			containment_status = A.vars["containment_status"]
		var/datum/scp/scp_datum = A.SCP
		var/scp_id = scp_datum ? scp_datum.get_scp_id() : "Unknown"
		var/scp_name = scp_datum ? scp_datum.name : "Unknown"
		var/scp_class = scp_datum ? scp_datum.classification : "Unknown"
		var/area/loc_area = get_area(A)
		report += list(list(
			"scp_id" = scp_id,
			"scp_name" = scp_name,
			"object_class" = scp_class,
			"status" = containment_status,
			"area" = loc_area ? loc_area.name : "Unknown",
		))

	if(!length(report))
		to_chat(AI, span_notice("SCP Status Report: No SCP entities tracked."))
		return
	var/list/msg = list(span_notice("SCP Status Report: [length(report)] entities tracked"))
	for(var/list/entry in report)
		var/status_color = entry["status"] == "contained" ? "green" : "red"
		msg += "<span style='color:[status_color]'>- [entry["scp_id"]] ([entry["scp_name"]]) | Class: [entry["object_class"]] | Status: [entry["status"]] | Area: [entry["area"]]</span>"
	to_chat(AI, jointext(msg, "\n"))
