/datum/anomalous_evidence
	var/evidence_id = ""
	var/evidence_type = ""
	var/collector_name = ""
	var/location_found = ""
	var/scp_related = ""
	var/description = ""
	var/analysis_result = ""
	var/analyzed = FALSE
	var/time_collected = 0

/datum/anomalous_evidence/New(collector, etype, location, scp, desc)
	evidence_id = "EVID-[world.time]-[rand(100,999)]"
	time_collected = world.time
	if(istype(collector, /mob/living/carbon/human))
		var/mob/living/carbon/human/C = collector
		collector_name = C.real_name
	evidence_type = etype
	location_found = location
	scp_related = scp
	description = desc

/datum/anomalous_evidence/proc/analyze(result)
	analyzed = TRUE
	analysis_result = result

SUBSYSTEM_DEF(anomalous_investigations)
	name = "Anomalous Investigations"
	flags = SS_NO_FIRE
	var/list/datum/anomalous_evidence/evidence_log = list()
	var/list/active_cases = list()
	var/total_evidence = 0
	var/analyzed_evidence = 0

/datum/controller/subsystem/anomalous_investigations/proc/log_evidence(datum/anomalous_evidence/E)
	evidence_log += E
	total_evidence++
	return E.evidence_id

/datum/controller/subsystem/anomalous_investigations/proc/analyze_evidence(evidence_id, result)
	for(var/datum/anomalous_evidence/E in evidence_log)
		if(E.evidence_id == evidence_id && !E.analyzed)
			E.analyze(result)
			analyzed_evidence++
			return TRUE
	return FALSE

/datum/controller/subsystem/anomalous_investigations/proc/open_case(scp_name, description)
	var/list/case = list(
		"case_name" = scp_name,
		"description" = description,
		"status" = "open",
		"time_opened" = world.time,
		"evidence_count" = 0,
	)
	active_cases[scp_name] = case
	priority_announce("Anomalous investigation case opened: [scp_name]. Investigations Agents should collect evidence.", "Investigations", null, ANNOUNCER_DEFAULT)
	return TRUE

/datum/controller/subsystem/anomalous_investigations/proc/close_case(scp_name)
	if(active_cases[scp_name])
		active_cases[scp_name]["status"] = "closed"
		return TRUE
	return FALSE

/obj/item/anomalous_evidence_bag
	name = "Anomalous Evidence Bag"
	desc = "A sterile bag for collecting and preserving anomalous evidence."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidence"
	w_class = WEIGHT_CLASS_SMALL
	var/datum/anomalous_evidence/stored_evidence

/obj/item/anomalous_evidence_bag/attack_self(mob/user)
	if(stored_evidence)
		to_chat(user, span_notice("Evidence: [stored_evidence.evidence_type] - [stored_evidence.description] [stored_evidence.analyzed ? "(Analyzed: [stored_evidence.analysis_result])" : "(Unanalyzed)"]"))
	else
		to_chat(user, span_notice("The evidence bag is empty. Use it on a crime scene or anomalous location to collect evidence."))

/obj/item/anomalous_evidence_bag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || stored_evidence)
		return
	var/area/A = get_area(target)
	var/location = A ? A.name : "Unknown"
	var/evidence_type = "Physical"
	var/scp_hint = ""
	if(istype(target, /mob/living/scp))
		evidence_type = "Biological"
		var/mob/living/scp/S = target
		scp_hint = S.name
	else if(istype(target, /obj/effect))
		evidence_type = "Environmental"
	else if(istype(target, /obj/item))
		evidence_type = "Material"
	stored_evidence = new(user, evidence_type, location, scp_hint, "Collected from [target.name] in [location]")
	SSanomalous_investigations.log_evidence(stored_evidence)
	user.visible_message(span_notice("[user] collects evidence from [target]."), span_notice("You collect evidence from [target] and seal it in the bag. Evidence ID: [stored_evidence.evidence_id]"))


