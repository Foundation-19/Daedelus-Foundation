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

	to_chat(assigned_to, span_notice("Task complete: [description]. Reward: +[reward_credits] credits, +[reward_trust] trust."))

/datum/dclass_work_assignment/proc/get_progress_percent()
	if(completed)
		return 100
	return round((progress / max(1, completion_time / 20)) * 100, 0.1)

/datum/dclass_work_assignment/proc/get_time_remaining()
	if(completed)
		return 0
	var/remaining_steps = (completion_time / 20) - progress
	return remaining_steps * 20


