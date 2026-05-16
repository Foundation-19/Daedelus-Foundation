/datum/pathogen/foundation
	form = "Foundation Pathogen"
	viable_mobtypes = list(/mob/living/carbon/human)
	var/bsl_level = BSL_1
	var/list/transmission_types = list()
	var/research_stage = RESEARCH_STAGE_IDENTIFIED
	var/is_anomalous = FALSE
	var/list/cross_scp_interactions = list()
	var/last_cross_scp_check = 0

/datum/pathogen/foundation/on_infect_mob()
	. = ..()
	if(affected_mob)
		SSfoundation_pathogens.register_infection(src)

/datum/pathogen/foundation/force_cure(add_resistance = TRUE)
	if(affected_mob)
		SSfoundation_pathogens.register_cure(src)
	return ..()

/datum/pathogen/foundation/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return
	if(length(cross_scp_interactions) && world.time > last_cross_scp_check + 30 SECONDS)
		last_cross_scp_check = world.time
		SSfoundation_pathogens.process_cross_scp_interactions(src)

/datum/pathogen/foundation/proc/get_bsl_display()
	switch(bsl_level)
		if(BSL_1)
			return span_nicegreen("BSL-1")
		if(BSL_2)
			return span_warning("BSL-2")
		if(BSL_3)
			return span_danger("BSL-3")
		if(BSL_4)
			return span_boldannounce("BSL-4")
	return span_notice("Unknown")

/datum/pathogen/foundation/proc/get_transmission_display()
	if(!length(transmission_types))
		return "Unknown"
	return english_list(transmission_types)

/datum/pathogen/foundation/proc/check_scp_interaction(scp_id)
	if(cross_scp_interactions[scp_id])
		return cross_scp_interactions[scp_id]
	return null

/datum/pathogen/foundation/Copy()
	. = ..()
	var/datum/pathogen/foundation/F = .
	F.bsl_level = bsl_level
	F.transmission_types = transmission_types.Copy()
	F.research_stage = research_stage
	F.is_anomalous = is_anomalous
	F.cross_scp_interactions = cross_scp_interactions ? cross_scp_interactions.Copy() : list()
	return F
