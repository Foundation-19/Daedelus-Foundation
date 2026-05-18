#define DCLASS_TASK_CLEANING "Cleaning"
#define DCLASS_TASK_MAINTENANCE "Maintenance"
#define DCLASS_TASK_LAUNDRY "Laundry"
#define DCLASS_TASK_COOKING "Kitchen Duty"
#define DCLASS_TASK_LOGISTICS "Logistics"
#define DCLASS_TASK_SCP_ADJACENT "SCP-Adjacent Labor"

/datum/dclass_work_assignment
	var/id
	var/task_type
	var/description
	var/required_access = ACCESS_DCLASS
	var/reward_credits = 10
	var/reward_trust = 5
	var/completion_time = 300
	var/area_type
	var/turf/target_turf
	var/mob/living/carbon/human/assigned_to
	var/started_at = 0
	var/completed = FALSE
	var/progress = 0
	var/list/completion_requirements = list()

/datum/dclass_work_assignment/New(task_id, task_desc, task_type, area_path, time_needed, credit_reward, trust_reward)
	id = task_id
	description = task_desc
	src.task_type = task_type
	area_type = area_path
	completion_time = time_needed
	reward_credits = credit_reward
	reward_trust = trust_reward

/datum/dclass_work_assignment/proc/assign_to(mob/living/carbon/human/H)
	if(!H || !ishuman(H))
		return FALSE
	assigned_to = H
	started_at = world.time
	return TRUE

/datum/dclass_work_assignment/proc/check_completion()
	if(completed)
		return TRUE

	if(!assigned_to)
		return FALSE

	var/turf/T = get_turf(assigned_to)
	if(!T)
		return FALSE

	var/area/A = get_area(T)
	if(!istype(A, area_type))
		progress = max(0, progress - 1)
		return FALSE

	progress += 1
	if(progress >= completion_time / 20)
		complete()
		return TRUE

	return FALSE

/datum/dclass_work_assignment/proc/complete()
	completed = TRUE
	if(!assigned_to)
		return

	to_chat(assigned_to, "<span class='notice'>Task complete: [description]. Reward: +[reward_credits] credits, +[reward_trust] trust.</span>")

/datum/dclass_work_assignment/proc/get_progress_percent()
	if(completed)
		return 100
	return round((progress / max(1, completion_time / 20)) * 100, 0.1)

/datum/dclass_work_assignment/proc/get_time_remaining()
	if(completed)
		return 0
	var/remaining_steps = (completion_time / 20) - progress
	return remaining_steps * 20

/obj/machinery/dclass_work_terminal
	name = "D-Class Work Terminal"
	desc = "A terminal for assigning and tracking D-Class work tasks."
	icon = 'icons/obj/computer.dmi'
	icon_state = "generic"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/dclass_work_terminal
	var/static/list/available_tasks
	var/list/active_assignments = list()

/obj/machinery/dclass_work_terminal/Initialize(mapload)
	. = ..()
	if(!available_tasks)
		build_task_list()

/obj/machinery/dclass_work_terminal/proc/build_task_list()
	available_tasks = list()

	available_tasks += new /datum/dclass_work_assignment("clean_lcz", "Clean LCZ Corridors", DCLASS_TASK_CLEANING, /area/scp/lcz, 300, 10, 5)
	available_tasks += new /datum/dclass_work_assignment("clean_hcz", "Clean HCZ Access Halls", DCLASS_TASK_CLEANING, /area/scp/hcz, 400, 15, 5)
	available_tasks += new /datum/dclass_work_assignment("mop_medbay", "Mop Medical Bay Floors", DCLASS_TASK_CLEANING, /area/station/medical, 250, 10, 5)
	available_tasks += new /datum/dclass_work_assignment("repair_lights", "Replace Burnt Light Tubes", DCLASS_TASK_MAINTENANCE, /area/station/maintenance, 350, 15, 8)
	available_tasks += new /datum/dclass_work_assignment("fix_vents", "Clear Blocked Ventilation", DCLASS_TASK_MAINTENANCE, /area/station/maintenance, 400, 20, 10)
	available_tasks += new /datum/dclass_work_assignment("collect_laundry", "Collect Laundry from Dormitories", DCLASS_TASK_LAUNDRY, /area/station/commons/dorms, 200, 8, 3)
	available_tasks += new /datum/dclass_work_assignment("fold_laundry", "Fold and Sort Laundry", DCLASS_TASK_LAUNDRY, /area/station/commons/dorms/laundry, 250, 10, 5)
	available_tasks += new /datum/dclass_work_assignment("prep_meals", "Prepare Meal Ingredients", DCLASS_TASK_COOKING, /area/station/service/kitchen, 300, 12, 5)
	available_tasks += new /datum/dclass_work_assignment("deliver_supplies", "Deliver Supplies to Engineering", DCLASS_TASK_LOGISTICS, /area/station/engineering, 350, 15, 8)
	available_tasks += new /datum/dclass_work_assignment("move_crates", "Organize Cargo Bay Crates", DCLASS_TASK_LOGISTICS, /area/station/cargo, 300, 12, 5)
	available_tasks += new /datum/dclass_work_assignment("clean_containment", "Clean SCP Containment Antechamber", DCLASS_TASK_SCP_ADJACENT, /area/scp/lcz, 500, 30, 15)
	available_tasks += new /datum/dclass_work_assignment("deliver_scp_supplies", "Deliver Supplies to HCZ Checkpoint", DCLASS_TASK_SCP_ADJACENT, /area/scp/hcz, 450, 25, 12)

/obj/machinery/dclass_work_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DclassWorkAssignments", "Work Assignments")
		ui.open()

/obj/machinery/dclass_work_terminal/ui_data(mob/user)
	var/list/data = list()

	data["is_dclass"] = FALSE
	data["is_guard"] = FALSE
	data["credits"] = 0
	data["trust"] = 0
	data["tasks_completed"] = 0

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(findtext(H.job, "D-Class"))
			data["is_dclass"] = TRUE
		if(findtext(H.job, "Guard") || findtext(H.job, "Security"))
			data["is_guard"] = TRUE

	data["available_tasks"] = list()
	if(available_tasks)
		for(var/datum/dclass_work_assignment/task in available_tasks)
			var/already_assigned = FALSE
			for(var/datum/dclass_work_assignment/active in active_assignments)
				if(active.id == task.id && active.assigned_to == user)
					already_assigned = TRUE
					break

			data["available_tasks"] += list(list(
				"id" = task.id,
				"description" = task.description,
				"type" = task.task_type,
				"reward_credits" = task.reward_credits,
				"reward_trust" = task.reward_trust,
				"duration" = task.completion_time,
				"already_assigned" = already_assigned,
			))

	data["active_tasks"] = list()
	for(var/datum/dclass_work_assignment/task in active_assignments)
		data["active_tasks"] += list(list(
			"id" = task.id,
			"description" = task.description,
			"type" = task.task_type,
			"progress" = task.get_progress_percent(),
			"time_remaining" = task.get_time_remaining(),
			"completed" = task.completed,
		))

	return data

/obj/machinery/dclass_work_terminal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	switch(action)
		if("accept_task")
			if(!ishuman(user))
				return
			var/task_id = params["id"]
			if(!available_tasks)
				return
			for(var/datum/dclass_work_assignment/task in available_tasks)
				if(task.id == task_id)
					var/datum/dclass_work_assignment/new_task = new task.type(task_id, task.description, task.task_type, task.area_type, task.completion_time, task.reward_credits, task.reward_trust)
					new_task.assign_to(user)
					active_assignments += new_task
					to_chat(user, "<span class='notice'>Task accepted: [task.description]. Proceed to the designated area.</span>")
					break
			. = TRUE

		if("abandon_task")
			var/task_id = params["id"]
			for(var/datum/dclass_work_assignment/task in active_assignments)
				if(task.id == task_id && task.assigned_to == user)
					active_assignments -= task
					qdel(task)
					to_chat(user, "<span class='warning'>Task abandoned.</span>")
					break
			. = TRUE

/obj/machinery/dclass_work_terminal/process()
	for(var/datum/dclass_work_assignment/task in active_assignments)
		if(task.completed)
			active_assignments -= task
			continue
		task.check_completion()
	SStgui.update_uis(src)

/obj/item/circuitboard/computer/dclass_work_terminal
	name = "D-Class Work Terminal (Computer Board)"
	build_path = /obj/machinery/dclass_work_terminal
