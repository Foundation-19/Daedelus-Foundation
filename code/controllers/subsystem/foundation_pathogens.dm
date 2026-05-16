SUBSYSTEM_DEF(foundation_pathogens)
	name = "Foundation Pathogens"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DCLASS

	var/list/active_infections = list()
	var/list/cure_log = list()
	var/list/bsl_zones = list()
	var/list/pathogen_research_data = list()
	var/list/active_research = list()

/datum/controller/subsystem/foundation_pathogens/Initialize(timeofday)
	setup_bsl_zones()
	setup_research_data()
	return ..()

/datum/controller/subsystem/foundation_pathogens/proc/setup_bsl_zones()
	bsl_zones = list(
		BSL_1 = list(
			"name" = "Low Containment",
			"required_access" = ACCESS_MEDICAL,
			"suit_required" = FALSE,
			"decon_required" = FALSE,
		),
		BSL_2 = list(
			"name" = "Standard Containment",
			"required_access" = ACCESS_SCIENCE,
			"suit_required" = FALSE,
			"decon_required" = TRUE,
		),
		BSL_3 = list(
			"name" = "High Containment",
			"required_access" = ACCESS_SECURITY_LVL3,
			"suit_required" = TRUE,
			"decon_required" = TRUE,
		),
		BSL_4 = list(
			"name" = "Maximum Containment",
			"required_access" = ACCESS_SECURITY_LVL5,
			"suit_required" = TRUE,
			"decon_required" = TRUE,
			"double_door" = TRUE,
		),
	)

/datum/controller/subsystem/foundation_pathogens/proc/setup_research_data()
	for(var/T in subtypesof(/datum/pathogen/foundation))
		var/datum/pathogen/foundation/F = T
		pathogen_research_data["[T]"] = list(
			"name" = initial(F.name),
			"bsl" = initial(F.bsl_level),
			"anomalous" = initial(F.is_anomalous),
			"research_stage" = initial(F.research_stage),
			"transmission" = initial(F.transmission_types),
			"cure_reagent" = initial(F.cures),
		)

/datum/controller/subsystem/foundation_pathogens/proc/register_infection(datum/pathogen/foundation/F)
	var/key = "[F.type]_[F.affected_mob?.ckey]"
	active_infections[key] = list(
		"pathogen_type" = "[F.type]",
		"host" = F.affected_mob,
		"bsl" = F.bsl_level,
		"time" = world.time,
	)

/datum/controller/subsystem/foundation_pathogens/proc/register_cure(datum/pathogen/foundation/F)
	var/key = "[F.type]_[F.affected_mob?.ckey]"
	active_infections -= key
	cure_log += list(list(
		"pathogen_type" = "[F.type]",
		"host_ckey" = F.affected_mob?.ckey,
		"bsl" = F.bsl_level,
		"time" = world.time,
	))
	award_pathogen_research_points(F, "cure")

/datum/controller/subsystem/foundation_pathogens/proc/get_infections_by_bsl(bsl)
	var/list/result = list()
	for(var/key in active_infections)
		if(active_infections[key]["bsl"] == bsl)
			result += active_infections[key]
	return result

/datum/controller/subsystem/foundation_pathogens/proc/get_research_progress(pathogen_type)
	if(!pathogen_research_data["[pathogen_type]"])
		return 0
	return pathogen_research_data["[pathogen_type]"]["research_stage"]

/datum/controller/subsystem/foundation_pathogens/proc/can_research(pathogen_type, mob/living/carbon/human/researcher)
	var/pkey = "[pathogen_type]"
	if(!pathogen_research_data[pkey])
		return FALSE
	var/list/pdata = pathogen_research_data[pkey]
	var/required_stage = pdata["research_stage"]
	if(required_stage >= RESEARCH_STAGE_CURED)
		return FALSE
	if(active_research[pkey])
		return FALSE
	var/bsl = pdata["bsl"]
	if(!check_bsl_access(bsl, researcher))
		return FALSE
	return TRUE

/datum/controller/subsystem/foundation_pathogens/proc/check_bsl_access(bsl, mob/living/carbon/human/researcher)
	if(!istype(researcher))
		return FALSE
	var/obj/item/card/id/id_card = researcher.get_idcard(TRUE)
	if(!id_card)
		return FALSE
	switch(bsl)
		if(BSL_1)
			return (ACCESS_MEDICAL in id_card.access)
		if(BSL_2)
			return (ACCESS_SCIENCE in id_card.access)
		if(BSL_3)
			return (ACCESS_SECURITY_LVL3 in id_card.access)
		if(BSL_4)
			return (ACCESS_SECURITY_LVL5 in id_card.access)
	return FALSE

/datum/controller/subsystem/foundation_pathogens/proc/get_research_time(pathogen_type)
	var/pkey = "[pathogen_type]"
	if(!pathogen_research_data[pkey])
		return 0
	var/bsl = pathogen_research_data[pkey]["bsl"]
	var/anomalous = pathogen_research_data[pkey]["anomalous"]
	var/base_time = 30 SECONDS
	switch(bsl)
		if(BSL_2)
			base_time = 45 SECONDS
		if(BSL_3)
			base_time = 75 SECONDS
		if(BSL_4)
			base_time = 120 SECONDS
	if(anomalous)
		base_time *= 1.5
	var/current = pathogen_research_data[pkey]["research_stage"]
	base_time += (current * 10 SECONDS)
	return base_time

/datum/controller/subsystem/foundation_pathogens/proc/get_research_cost(pathogen_type)
	var/pkey = "[pathogen_type]"
	if(!pathogen_research_data[pkey])
		return list()
	var/bsl = pathogen_research_data[pkey]["bsl"]
	var/anomalous = pathogen_research_data[pkey]["anomalous"]
	var/current = pathogen_research_data[pkey]["research_stage"]
	var/list/costs = list()

	var/point_cost = 50
	switch(bsl)
		if(BSL_2)
			point_cost = 100
		if(BSL_3)
			point_cost = 200
		if(BSL_4)
			point_cost = 400
	if(anomalous)
		point_cost *= 2
	point_cost += (current * 30)

	costs["points"] = point_cost

	switch(current)
		if(RESEARCH_STAGE_IDENTIFIED)
			costs["reagent"] = /datum/reagent/medicine/spaceacillin
			costs["reagent_amount"] = 5
		if(RESEARCH_STAGE_CATALOGUED)
			costs["reagent"] = /datum/reagent/medicine/spaceacillin
			costs["reagent_amount"] = 10
		if(RESEARCH_STAGE_MAPPED)
			costs["reagent"] = /datum/reagent/medicine/dylovene
			costs["reagent_amount"] = 5
		if(RESEARCH_STAGE_COUNTERMEASURE)
			costs["reagent"] = /datum/reagent/medicine/epinephrine
			costs["reagent_amount"] = 10

	return costs

/datum/controller/subsystem/foundation_pathogens/proc/start_research(pathogen_type, mob/living/carbon/human/researcher)
	var/pkey = "[pathogen_type]"
	if(!can_research(pathogen_type, researcher))
		return FALSE

	var/list/costs = get_research_cost(pathogen_type)
	var/point_cost = costs["points"]

	if(SSscp_research?.manager)
		if(SSscp_research.manager.total_research_points < point_cost)
			return FALSE
		adjust_global_research_points(-point_cost, "pathogen_research_start")

	var/research_time = get_research_time(pathogen_type)

	active_research[pkey] = list(
		"researcher" = researcher,
		"start_time" = world.time,
		"end_time" = world.time + research_time,
		"stage_result" = pathogen_research_data[pkey]["research_stage"] + 1,
	)

	addtimer(CALLBACK(src, PROC_REF(complete_research), pkey), research_time)
	return TRUE

/datum/controller/subsystem/foundation_pathogens/proc/complete_research(pkey)
	if(!active_research[pkey])
		return

	var/list/rdata = active_research[pkey]
	var/new_stage = rdata["stage_result"]
	var/mob/researcher = rdata["researcher"]

	active_research -= pkey

	if(!pathogen_research_data[pkey])
		return

	pathogen_research_data[pkey]["research_stage"] = new_stage

	var/datum/pathogen/foundation/F = text2path(pkey)
	if(F)
		award_pathogen_research_points_by_type(F, new_stage, "research")

	if(researcher)
		to_chat(researcher, span_notice("Research complete! [pathogen_research_data[pkey]["name"]] is now at stage [new_stage]."))

	if(new_stage == RESEARCH_STAGE_CURED)
		produce_cure(pkey)

/datum/controller/subsystem/foundation_pathogens/proc/produce_cure(pkey)
	if(!pathogen_research_data[pkey])
		return
	var/pathogen_type = text2path(pkey)
	if(!pathogen_type)
		return

	var/datum/pathogen/foundation/prototype = new pathogen_type()
	qdel(prototype)

	var/cure_name = "Synthesized Cure: [pathogen_research_data[pkey]["name"]]"
	var/obj/item/reagent_containers/glass/bottle/cure_bottle = new()
	cure_bottle.name = cure_name
	cure_bottle.desc = "A synthesized cure for [pathogen_research_data[pkey]["name"]]. Handle with care."
	cure_bottle.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, 30)

	var/list/cure_data = list()
	var/datum/pathogen/cure_pathogen = new pathogen_type()
	cure_pathogen.cure_chance = 100
	cure_data["viruses"] = list(cure_pathogen)
	cure_bottle.reagents.add_reagent(/datum/reagent/blood, 10, cure_data)

	var/found_console = FALSE
	for(var/obj/machinery/computer/pathogen_research_console/console as anything in INSTANCES_OF(/obj/machinery/computer/pathogen_research_console))
		if(!(console.machine_stat & NOPOWER) && !(console.machine_stat & BROKEN))
			cure_bottle.forceMove(get_turf(console))
			console.visible_message(span_notice("[console] dispenses a cure vial!"))
			found_console = TRUE
			break
	if(!found_console)
		qdel(cure_bottle)

/datum/controller/subsystem/foundation_pathogens/proc/advance_research(pathogen_type, stages = 1)
	if(!pathogen_research_data["[pathogen_type]"])
		return FALSE
	var/current = pathogen_research_data["[pathogen_type]"]["research_stage"]
	var/new_stage = min(current + stages, RESEARCH_STAGE_CURED)
	pathogen_research_data["[pathogen_type]"]["research_stage"] = new_stage
	if(new_stage > current)
		var/datum/pathogen/foundation/F = text2path(pathogen_type)
		if(F)
			award_pathogen_research_points_by_type(F, new_stage, "research")
	return TRUE

/datum/controller/subsystem/foundation_pathogens/proc/award_pathogen_research_points(datum/pathogen/foundation/F, reason)
	if(!F)
		return
	var/points = 0
	switch(F.bsl_level)
		if(BSL_1)
			points = 25
		if(BSL_2)
			points = 50
		if(BSL_3)
			points = 150
		if(BSL_4)
			points = 500
	if(F.is_anomalous)
		points *= 2
	if(reason == "cure")
		points *= 2
	if(SSscp_research && SSscp_research.manager)
		adjust_global_research_points(points, "pathogen_research")

/datum/controller/subsystem/foundation_pathogens/proc/award_pathogen_research_points_by_type(pathogen_type, research_stage, reason)
	var/points = 0
	var/datum/pathogen/foundation/prototype = new pathogen_type()
	var/bsl = prototype.bsl_level
	var/is_anom = prototype.is_anomalous
	qdel(prototype)
	switch(bsl)
		if(BSL_1)
			points = 25
		if(BSL_2)
			points = 50
		if(BSL_3)
			points = 150
		if(BSL_4)
			points = 500
	if(is_anom)
		points *= 2
	if(research_stage >= RESEARCH_STAGE_CURED)
		points *= 3
	else if(research_stage >= RESEARCH_STAGE_COUNTERMEASURE)
		points *= 2
	if(SSscp_research && SSscp_research.manager)
		adjust_global_research_points(points, "pathogen_research")

/datum/controller/subsystem/foundation_pathogens/proc/process_cross_scp_interactions(datum/pathogen/foundation/F)
	if(!F || !F.affected_mob || QDELETED(F.affected_mob))
		return
	var/mob/living/carbon/human/H = F.affected_mob
	if(!istype(H))
		return
	for(var/scp_id in F.cross_scp_interactions)
		var/interaction_type = F.cross_scp_interactions[scp_id]
		switch(interaction_type)
			if("instant_cure")
				var/mob/living/scp/nearest = find_nearest_scp(scp_id, H)
				if(nearest && get_dist(H, nearest) <= 3)
					F.force_cure()
					to_chat(H, span_notice("The proximity of [nearest] neutralizes the pathogen instantly!"))
					return
			if("possible_cure")
				var/mob/living/scp/nearest = find_nearest_scp(scp_id, H)
				if(nearest && get_dist(H, nearest) <= 3 && prob(15))
					F.force_cure()
					to_chat(H, span_notice("The presence of [nearest] cures your affliction!"))
					return
			if("halts_progression")
				var/mob/living/scp/nearest = find_nearest_scp(scp_id, H)
				if(nearest && get_dist(H, nearest) <= 5)
					F.stage = max(1, F.stage - 1)
			if("symbiotic_with_049")
				var/mob/living/scp/scp049/nearest = find_nearest_scp("SCP-049", H)
				if(nearest && get_dist(H, nearest) <= 7)
					H.adjustBruteLoss(-2)
					H.adjustToxLoss(-2, TRUE)
			if("sentient_adaptation")
				var/mob/living/scp/nearest = find_nearest_scp(scp_id, H)
				if(nearest && get_dist(H, nearest) <= 5)
					F.cure_chance = max(0.01, F.cure_chance * 0.8)
			if("counteractive")
				var/mob/living/scp/nearest = find_nearest_scp(scp_id, H)
				if(nearest && get_dist(H, nearest) <= 5)
					F.stage = max(1, F.stage - 1)

/datum/controller/subsystem/foundation_pathogens/proc/find_nearest_scp(scp_id, mob/living/carbon/human/H)
	if(!H)
		return null
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(QDELETED(S))
			continue
		if(S.SCP == scp_id || findtext("[S.type]", scp_id))
			if(get_dist(H, S) <= 10)
				return S
	return null
