SUBSYSTEM_DEF(scp_service)
	name = "SCP Service"
	wait = 30 SECONDS
	flags = SS_NO_FIRE

	var/list/morale_events = list()
	var/list/informant_meetings = list()
	var/list/decontamination_routes = list()
	var/list/anomalous_flora = list()
	var/list/classified_documents = list()
	var/total_morale_events = 0
	var/total_informant_meetings = 0
	var/total_decon_routes_completed = 0
	var/total_flora_samples = 0
	var/total_documents_classified = 0

/datum/controller/subsystem/scp_service/proc/log_morale_event(event_type, source, morale_change)
	total_morale_events++
	morale_events += list(list(
		"type" = event_type,
		"source" = source,
		"morale_change" = morale_change,
		"time" = world.time,
	))
	if(length(morale_events) > 100)
		morale_events.Cut(1, 2)

/datum/controller/subsystem/scp_service/proc/bartender_serve_drink(mob/living/carbon/human/customer, drink_name, sanity_effect)
	if(!customer || !customer.sanity)
		return
	if(sanity_effect != 0)
		customer.sanity.adjust_sanity(sanity_effect, "bartender_drink")
	log_morale_event("drink_served", drink_name, sanity_effect)
	if(prob(10))
		informant_meetings += list(list(
			"location" = "Bar",
			"contact" = customer.real_name,
			"type" = "casual_intel",
			"reported" = FALSE,
			"time" = world.time,
		))
		total_informant_meetings++

/datum/controller/subsystem/scp_service/proc/janitor_log_decontamination(mob/living/carbon/human/janitor, area_name, is_anomalous)
	total_decon_routes_completed++
	decontamination_routes += list(list(
		"area" = area_name,
		"janitor" = janitor.real_name,
		"anomalous" = is_anomalous,
		"time" = world.time,
	))
	if(is_anomalous)
		if(SSscp_research?.manager)
			SSscp_research?.manager?.adjust_research_points(5, "janitor_decon:[janitor.ckey]")
		if(SSraisa)
			var/datum/intel_report/R = new(janitor, "facility_maintenance", janitor.real_name, janitor.job, "ROUTINE", "Anomalous decontamination completed in [area_name] by [janitor.real_name].", "Update facility status.")
			SSraisa.file_report(R)

/datum/controller/subsystem/scp_service/proc/botanist_log_sample(mob/living/carbon/human/botanist, flora_name, is_anomalous)
	total_flora_samples++
	anomalous_flora += list(list(
		"flora" = flora_name,
		"botanist" = botanist.real_name,
		"anomalous" = is_anomalous,
		"research_value" = is_anomalous ? 15 : 5,
		"time" = world.time,
	))
	if(is_anomalous && SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(15, "botany_sample:[botanist.ckey]")

/datum/controller/subsystem/scp_service/proc/curator_classify_document(mob/living/carbon/human/curator, document_name, classification_level)
	total_documents_classified++
	classified_documents += list(list(
		"document" = document_name,
		"curator" = curator.real_name,
		"classification" = classification_level,
		"time" = world.time,
	))
	if(classification_level >= 3 && SSraisa)
		var/datum/intel_report/R = new(curator, "document_security", curator.real_name, curator.job, "CONFIDENTIAL", "Document [document_name] classified at level [classification_level] by [curator.real_name].", "Verify classification level.")
		SSraisa.file_report(R)
	if(SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(5, "document_classification:[curator.ckey]")

/datum/controller/subsystem/scp_service/proc/cook_serve_ration(mob/living/carbon/human/dclass, ration_tier)
	if(!dclass)
		return
	var/trust_bonus = 0
	var/sanity_bonus = 0
	switch(ration_tier)
		if("premium")
			trust_bonus = 5
			sanity_bonus = 3
		if("improved")
			trust_bonus = 2
			sanity_bonus = 1
		else
			trust_bonus = 0
	if(trust_bonus > 0 && SSdclass?.manager)
		var/datum/dclass_player/P = SSdclass?.manager?.get_dclass_player(dclass.ckey)
		if(P)
			P.trust_level = min(100, P.trust_level + trust_bonus)
	if(sanity_bonus > 0 && dclass.sanity)
		dclass.sanity.adjust_sanity(sanity_bonus, "good_food")

/datum/controller/subsystem/scp_service/proc/clown_morale_boost(mob/living/carbon/human/clown, mob/living/carbon/human/audience)
	if(!clown || !audience)
		return
	if(audience.sanity)
		audience.sanity.adjust_sanity(2, "clown_entertainment")
	log_morale_event("clown_performance", clown.real_name, 2)
	if(SSbudget_system?.manager)
		SSbudget_system?.manager?.add_transaction("service", "REVENUE", 10, "personnel", "Clown morale boost")
