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

/obj/machinery/computer/rehabilitation_console
	name = "Rehabilitation Console"
	desc = "A console for managing the rehabilitation of captured operatives."
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/rehabilitation_console

/obj/machinery/computer/rehabilitation_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RehabilitationConsole", "Rehabilitation Console")
		ui.open()

/obj/machinery/computer/rehabilitation_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/rehabilitation_console/ui_data(mob/user)
	var/list/data = list()
	var/list/prisoners = list()

	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		if(!H.mind)
			continue
		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(!rehab)
			continue
		prisoners += list(list(
			"name" = H.real_name,
			"job" = H.job || "Unknown",
			"stage" = rehab.rehab_stage,
			"progress" = rehab.rehab_progress,
			"required" = rehab.required_progress,
			"ref" = REF(H)
		))

	data["prisoners"] = prisoners
	return data

/obj/machinery/computer/rehabilitation_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "advance_rehab")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || !H.mind)
			return

		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(!rehab)
			return

		var/amount = params["amount"] || 25
		rehab.advance_rehabilitation(amount)
		to_chat(usr, span_notice("Rehabilitation progress advanced for [H.real_name]."))
		return TRUE

	if(action == "administer_amnestic")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || !H.mind)
			return

		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(!rehab)
			return

		for(var/datum/antagonist/A in H.mind.antag_datums)
			if(A != rehab)
				H.mind.remove_antag_datum(A.type)

		rehab.rehab_stage = max(rehab.rehab_stage, 2)
		rehab.rehab_progress = 0
		to_chat(H, span_warning("A powerful amnestic is administered. Your memories of your former allegiance fade..."))
		to_chat(usr, span_notice("Amnestic administered to [H.real_name]. Previous antagonist allegiances erased."))
		playsound(loc, 'sound/effects/spray.ogg', 30, TRUE)
		return TRUE

	if(action == "release")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || !H.mind)
			return

		var/datum/antagonist/rehabilitated/rehab = H.mind.has_antag_datum(/datum/antagonist/rehabilitated)
		if(!rehab)
			return

		if(rehab.rehab_stage < 3)
			to_chat(usr, span_warning("Subject has not completed rehabilitation!"))
			return

		rehab.complete_rehabilitation()
		return TRUE

	if(action == "terminate")
		var/mob/living/carbon/human/H = locate(params["ref"]) in GLOB.mob_living_list
		if(!H || !H.mind)
			return

		H.death()
		to_chat(usr, span_danger("Subject [H.real_name] has been terminated."))
		return TRUE

/obj/item/circuitboard/computer/rehabilitation_console
	name = "Rehabilitation Console (Computer Board)"
	build_path = /obj/machinery/computer/rehabilitation_console

/obj/item/restraints/handcuffs/foundation
	name = "Foundation restraints"
	desc = "High-security restraints used by the Foundation for containing hostile operatives."

/obj/structure/fluff/foundation_cell
	name = "Foundation Holding Cell"
	desc = "A reinforced holding cell for captured operatives."
	icon = 'icons/obj/structures.dmi'
	icon_state = "wall"
	anchored = TRUE
	density = TRUE
