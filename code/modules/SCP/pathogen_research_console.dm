/obj/machinery/computer/pathogen_research_console
	name = "Pathogen Research Console"
	desc = "A Foundation terminal for researching and developing countermeasures against pathogens."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/pathogen_research_console
	req_access = list(ACCESS_SCIENCE)

	light_color = LIGHT_COLOR_CYAN

	var/obj/item/reagent_containers/inserted_sample

/obj/machinery/computer/pathogen_research_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PathogenResearchConsole", name)
		ui.open()

/obj/machinery/computer/pathogen_research_console/ui_data(mob/user)
	var/list/data = list()

	data["active_infections"] = list()
	for(var/key in SSfoundation_pathogens.active_infections)
		var/list/inf = SSfoundation_pathogens.active_infections[key]
		var/mob/host_mob = inf["host"]
		data["active_infections"] += list(list(
			"pathogen_type" = inf["pathogen_type"],
			"host_name" = host_mob ? host_mob.name : "Unknown",
			"bsl" = inf["bsl"],
			"time" = inf["time"],
		))

	data["cure_log"] = SSfoundation_pathogens.cure_log

	data["bsl_summary"] = list()
	for(var/bsl in list(BSL_1, BSL_2, BSL_3, BSL_4))
		var/list/infections = SSfoundation_pathogens.get_infections_by_bsl(bsl)
		data["bsl_summary"] += list(list(
			"level" = bsl,
			"count" = length(infections),
		))

	data["research_data"] = list()
	for(var/pkey in SSfoundation_pathogens.pathogen_research_data)
		var/list/pdata = SSfoundation_pathogens.pathogen_research_data[pkey]
		var/list/active = SSfoundation_pathogens.active_research[pkey]
		var/list/costs = SSfoundation_pathogens.get_research_cost(pkey)
		var/research_time = SSfoundation_pathogens.get_research_time(pkey)
		var/progress = 0
		var/time_remaining = 0
		var/researcher_name = null
		if(active)
			var/elapsed = world.time - active["start_time"]
			var/total = active["end_time"] - active["start_time"]
			progress = min(1, elapsed / max(1, total))
			time_remaining = max(0, active["end_time"] - world.time)
			if(active["researcher"])
				var/mob/M = active["researcher"]
				researcher_name = M.name
		var/list/reagent_info = list()
		if(costs["reagent"])
			var/reagent_path = costs["reagent"]
			var/datum/reagent/prototype = new reagent_path()
			reagent_info = list(
				"type" = "[reagent_path]",
				"name" = prototype.name,
				"amount" = costs["reagent_amount"],
			)
			qdel(prototype)
		data["research_data"] += list(list(
			"type" = pkey,
			"name" = pdata["name"],
			"bsl" = pdata["bsl"],
			"anomalous" = pdata["anomalous"],
			"research_stage" = pdata["research_stage"],
			"transmission" = pdata["transmission"],
			"progress" = progress,
			"time_remaining" = time_remaining,
			"researcher" = researcher_name,
			"point_cost" = costs["points"],
			"reagent" = reagent_info,
			"research_time" = research_time,
		))

	data["inserted_sample"] = null
	if(inserted_sample)
		data["inserted_sample"] = list(
			"name" = inserted_sample.name,
		)
		if(inserted_sample.reagents)
			var/list/reagent_list = list()
			for(var/datum/reagent/R in inserted_sample.reagents.reagent_list)
				reagent_list += list(list(
					"name" = R.name,
					"volume" = R.volume,
				))
			data["inserted_sample"]["reagents"] = reagent_list

	data["research_points"] = 0
	if(SSscp_research?.manager)
		data["research_points"] = SSscp_research.manager.total_research_points

	data["has_bsl_access"] = FALSE
	if(ishuman(user))
		data["has_bsl_access"] = TRUE

	data["host_diseases"] = list()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/datum/pathogen/foundation/F in H.diseases)
			data["host_diseases"] += list(list(
				"name" = F.name,
				"bsl" = F.bsl_level,
				"stage" = F.stage,
				"max_stage" = F.max_stages,
				"anomalous" = F.is_anomalous,
				"research_stage" = F.research_stage,
			))

	return data

/obj/machinery/computer/pathogen_research_console/ui_act(action, params)
	. = ..()
	var/mob/user = usr
	if(.)
		return

	switch(action)
		if("insert_sample")
			if(inserted_sample)
				return
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user
			var/obj/item/reagent_containers/sample = H.get_active_held_item()
			if(!istype(sample))
				to_chat(H, span_warning("You must be holding a reagent container to insert a sample."))
				return
			if(!sample.reagents || !sample.reagents.total_volume)
				to_chat(H, span_warning("That container is empty."))
				return
			if(!H.dropItemToGround(sample))
				return
			sample.forceMove(src)
			inserted_sample = sample
			. = TRUE

		if("eject_sample")
			if(!inserted_sample)
				return
			inserted_sample.forceMove(get_turf(src))
			inserted_sample = null
			. = TRUE

		if("start_research")
			var/pkey = params["pathogen_type"]
			if(!pkey)
				return
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user
			if(!SSfoundation_pathogens.can_research(pkey, H))
				to_chat(H, span_warning("Cannot start research on this pathogen. Check BSL access, research points, and ensure no research is already in progress."))
				return
			var/list/costs = SSfoundation_pathogens.get_research_cost(pkey)
			var/required_reagent = costs["reagent"]
			var/required_amount = costs["reagent_amount"]
			var/reagent_display_name = "Unknown"
			if(required_reagent)
				var/datum/reagent/prototype = new required_reagent()
				reagent_display_name = prototype.name
				qdel(prototype)
			if(required_reagent && inserted_sample)
				if(!inserted_sample.reagents?.has_reagent(required_reagent, required_amount))
					to_chat(H, span_warning("The inserted sample does not contain the required reagent ([reagent_display_name] x[required_amount])."))
					return
				inserted_sample.reagents.remove_reagent(required_reagent, required_amount)
			else if(required_reagent && !inserted_sample)
				to_chat(H, span_warning("Research requires [reagent_display_name] x[required_amount]. Insert a sample container with the reagent."))
				return
			if(SSfoundation_pathogens.start_research(pkey, H))
				to_chat(H, span_notice("Research started on [pkey]. Estimated time: [SSfoundation_pathogens.get_research_time(pkey) / 10] seconds."))
				. = TRUE

		if("cancel_research")
			var/pkey = params["pathogen_type"]
			if(!pkey)
				return
			if(!SSfoundation_pathogens.active_research[pkey])
				return
			var/point_cost = SSfoundation_pathogens.get_research_cost(pkey)["points"]
			SSfoundation_pathogens.active_research -= pkey
			if(SSscp_research?.manager)
				adjust_global_research_points(round(point_cost * 0.5), "pathogen_research_cancel_refund")
			. = TRUE

		if("dispense_cure")
			var/pkey = params["pathogen_type"]
			if(!pkey)
				return
			var/current_stage = SSfoundation_pathogens.get_research_progress(pkey)
			if(current_stage < RESEARCH_STAGE_CURED)
				return
			SSfoundation_pathogens.produce_cure(pkey)
			. = TRUE

		if("administer_scp500")
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user
			var/obj/item/reagent_containers/pill/scp500/pill = null
			for(var/obj/item/reagent_containers/pill/scp500/P in H.get_contents())
				pill = P
				break
			if(!pill)
				to_chat(H, span_warning("You need an SCP-500 pill in your inventory to administer it."))
				return
			for(var/datum/pathogen/foundation/F in H.diseases)
				if(F.is_anomalous)
					F.force_cure()
					qdel(pill)
					. = TRUE
					break

/obj/machinery/computer/pathogen_research_console/Destroy()
	if(inserted_sample)
		QDEL_NULL(inserted_sample)
	return ..()

/obj/item/circuitboard/computer/pathogen_research_console
	name = "Pathogen Research Console (Computer Board)"
	build_path = /obj/machinery/computer/pathogen_research_console
