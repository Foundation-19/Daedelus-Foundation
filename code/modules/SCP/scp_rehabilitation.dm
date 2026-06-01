/datum/antagonist/rehabilitated
	name = "Rehabilitated Operative"
	antagpanel_category = "Rehabilitated"
	show_in_antagpanel = TRUE
	var/rehab_stage = 0
	var/rehab_progress = 0
	var/custody_time = 0
	var/required_progress = 100

/datum/antagonist/rehabilitated/on_gain()
	. = ..()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		to_chat(H, span_notice("You have been taken into Foundation custody. Your rehabilitation process will now begin."))
		ADD_TRAIT(H, TRAIT_PACIFISM, "rehabilitation")

/datum/antagonist/rehabilitated/on_removal()
	. = ..()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		REMOVE_TRAIT(H, TRAIT_PACIFISM, "rehabilitation")
		to_chat(H, span_notice("Your rehabilitation is complete. You have been cleared of all charges."))

/datum/antagonist/rehabilitated/proc/advance_rehabilitation(amount)
	rehab_progress += amount
	if(rehab_progress >= required_progress)
		rehab_stage++
		rehab_progress = 0
		if(rehab_stage >= 3)
			complete_rehabilitation()

/datum/antagonist/rehabilitated/proc/complete_rehabilitation()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		to_chat(H, span_greenannounce("Your rehabilitation is complete. You have been cleared of all charges and reinstated as Foundation personnel."))

		var/datum/mind/M = H.mind
		for(var/datum/antagonist/A in M.antag_datums)
			if(A == src)
				continue
			M.remove_antag_datum(A.type)

		M.special_role = null

		var/datum/job/new_job = SSjob.GetJob(JOB_DCLASS)
		if(new_job)
			M.set_assigned_role(new_job)
			H.job = new_job.title

	owner.remove_antag_datum(type)



/obj/structure/fluff/foundation_cell
	name = "Foundation Holding Cell"
	desc = "A reinforced holding cell for captured operatives."
	icon = 'icons/obj/structures.dmi'
	icon_state = "wall"
	anchored = TRUE
	density = TRUE
