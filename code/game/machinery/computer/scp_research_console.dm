/obj/machinery/computer/scp_research_console
	name = "SCP Research Console"
	desc = "A computer console for managing SCP research projects and viewing research data."
	icon_screen = "research"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/scp_research_console
	var/list/access_required = list(ACCESS_SCIENCE)
	var/obj/item/card/id/scan = null

/obj/machinery/computer/scp_research_console/Initialize()
	. = ..()
	update_icon()

/obj/machinery/computer/scp_research_console/update_icon()
	. = ..()
	if(machine_stat & BROKEN)
		icon_screen = "research_broken"
	else if(machine_stat & NOPOWER)
		icon_screen = "research_off"
	else
		icon_screen = "research"

/obj/machinery/computer/scp_research_console/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(!scan)
			if(!user.transferItemToLoc(I, src))
				return
			scan = I
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There's already an ID card in [src].</span>")
		return
	return ..()

/obj/machinery/computer/scp_research_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpResearchConsole", name)
		ui.open()

/obj/machinery/computer/scp_research_console/ui_data(mob/user)
	var/list/data = list()

	data["has_access"] = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_id)
			var/obj/item/card/id/id_card = H.wear_id.GetID()
			if(id_card && (ACCESS_SCIENCE in id_card.access))
				data["has_access"] = TRUE
	if(scan && (ACCESS_SCIENCE in scan.access))
		data["has_access"] = TRUE

	data["inserted_id"] = null
	if(scan)
		var/id_name = scan.registered_name || "Unknown"
		var/id_assignment = scan.assignment || "Unassigned"
		data["inserted_id"] = list(
			"name" = id_name,
			"assignment" = id_assignment,
		)

	data["researcher_profile"] = null
	data["achievements"] = list()
	data["completed_research"] = list()
	data["active_projects"] = list()

	if(!SSscp_research || !SSscp_research.manager)
		data["global_metrics"] = list(
			"total_points" = 0,
			"total_funding" = 0,
			"breakthroughs" = 0,
			"containment_improvements" = 0,
		)
		data["milestones"] = list()
		data["rewards"] = list()
		return data

	var/datum/scp_research_manager/M = SSscp_research.manager

	var/datum/researcher_data/researcher = M.get_researcher_profile(user.ckey)
	if(researcher)
		data["researcher_profile"] = list(
			"research_points" = researcher.research_points,
			"research_funding" = researcher.research_funding,
			"progression_points" = researcher.progression_points,
			"research_rank" = researcher.research_rank,
			"total_projects" = researcher.total_projects,
			"completed_projects" = researcher.completed_projects,
			"failed_projects" = researcher.failed_projects,
		)

		for(var/achievement in researcher.achievements)
			data["achievements"] += list(list("name" = "[achievement]"))

		for(var/research in researcher.completed_research)
			data["completed_research"] += list(list("name" = "[research]"))

	for(var/project_id in M.research_projects)
		var/datum/research_data/project = M.research_projects[project_id]
		if(project.researcher_ckey == user.ckey && project.status == "ACTIVE")
			var/progress_percent = 0
			if(project.research_cost > 0)
				progress_percent = round((project.research_points / project.research_cost) * 100, 1)
			var/time_minutes = round((world.time - project.timestamp) / 600)
			data["active_projects"] += list(list(
				"project_id" = project_id,
				"scp_designation" = project.scp_designation,
				"research_type" = project.research_type,
				"research_level" = project.research_level,
				"max_research_level" = project.max_research_level,
				"research_points" = project.research_points,
				"research_cost" = project.research_cost,
				"progress_percent" = progress_percent,
				"time_minutes" = time_minutes,
				"discoveries" = length(project.discoveries),
			))

	data["global_metrics"] = list(
		"total_points" = M.total_research_points,
		"total_funding" = M.total_research_funding,
		"breakthroughs" = M.research_breakthroughs,
		"containment_improvements" = M.containment_improvements,
	)

	data["milestones"] = list()
	for(var/milestone_id in M.research_milestones)
		var/datum/research_milestone_data/milestone = M.research_milestones[milestone_id]
		data["milestones"] += list(list(
			"milestone_id" = milestone_id,
			"name" = milestone.milestone_name,
			"description" = milestone.milestone_description,
			"completed" = milestone.completed,
			"completed_by" = milestone.completed_by ? "[milestone.completed_by]" : null,
		))

	data["rewards"] = list()
	for(var/reward_id in M.research_rewards)
		var/datum/research_reward_data/reward = M.research_rewards[reward_id]
		data["rewards"] += list(list(
			"reward_id" = reward_id,
			"reward_type" = reward.reward_type,
			"reward_amount" = reward.reward_amount,
			"description" = reward.reward_description,
			"unlocked" = reward.unlocked,
		))

	return data

/obj/machinery/computer/scp_research_console/ui_act(action, params)
	. = ..()
	var/mob/user = usr
	if(.)
		return

	switch(action)
		if("eject_id")
			if(!scan)
				return
			scan.forceMove(get_turf(src))
			scan = null
			. = TRUE

		if("start_research")
			if(!scan)
				var/has_own_access = FALSE
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					if(H.wear_id)
						var/obj/item/card/id/id_card = H.wear_id.GetID()
						if(id_card && (ACCESS_SCIENCE in id_card.access))
							has_own_access = TRUE
				if(!has_own_access)
					return
			var/scp_designation = params["scp_designation"]
			var/research_type = params["research_type"]
			if(!scp_designation || !research_type)
				return
			if(!SSscp_research || !SSscp_research.manager)
				return
			SSscp_research.manager.start_research_project(scp_designation, research_type, user.ckey)
			to_chat(user, "<span class='notice'>Research project started on [scp_designation].</span>")
			. = TRUE

		if("cancel_research")
			var/project_id = params["project_id"]
			if(!project_id)
				return
			if(!SSscp_research || !SSscp_research.manager)
				return
			var/datum/research_data/project = SSscp_research.manager.research_projects[project_id]
			if(!project || project.researcher_ckey != user.ckey)
				return
			project.status = "CANCELLED"
			var/datum/researcher_data/researcher = SSscp_research.manager.get_researcher_profile(user.ckey)
			researcher.failed_projects++
			to_chat(user, "<span class='warning'>Research project on [project.scp_designation] cancelled.</span>")
			. = TRUE

		if("claim_reward")
			var/reward_id = params["reward_id"]
			if(!reward_id)
				return
			if(!SSscp_research || !SSscp_research.manager)
				return
			var/datum/research_reward_data/reward = SSscp_research.manager.research_rewards[reward_id]
			if(!reward || !reward.unlocked)
				return
			to_chat(user, "<span class='notice'>Reward claimed: [reward.reward_description]</span>")
			SSscp_research.manager.research_rewards -= reward_id
			. = TRUE

		if("contribute_points")
			var/project_id = params["project_id"]
			var/amount = text2num(params["amount"]) || 0
			if(!project_id || amount <= 0)
				return
			if(!SSscp_research || !SSscp_research.manager)
				return
			if(SSscp_research.manager.contribute_research_points(project_id, amount, user.ckey))
				to_chat(user, "<span class='notice'>Contributed [amount] research points to the project.</span>")
			else
				to_chat(user, "<span class='warning'>Cannot contribute points. Check available points and project status.</span>")
			. = TRUE

/obj/item/circuitboard/computer/scp_research_console
	name = "SCP Research Console (Computer Board)"
	build_path = /obj/machinery/computer/scp_research_console
