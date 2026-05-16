// Sanity Medical Integration
// Medical treatments and procedures for sanity management

// Sanity-related medical items
/obj/item/reagent_containers/pill/sanity
	name = "sanity pill"
	desc = "A pill designed to help with mental health issues."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	list_reagents = list(/datum/reagent/medicine/sanity_restore = 1)

/obj/item/reagent_containers/pill/antipsychotic
	name = "antipsychotic"
	desc = "A medication used to treat psychosis and severe mental disorders."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	list_reagents = list(/datum/reagent/medicine/antipsychotic = 1)

/obj/item/reagent_containers/pill/antianxiety
	name = "anti-anxiety medication"
	desc = "A medication used to treat anxiety and panic disorders."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	list_reagents = list(/datum/reagent/medicine/antianxiety = 1)

/obj/item/reagent_containers/pill/sedative
	name = "sedative"
	desc = "A medication used to calm and relax patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	list_reagents = list(/datum/reagent/medicine/sedative = 1)

// Sanity-related reagents
/datum/reagent/medicine/sanity_restore
	name = "Sanity Restore"
	description = "A medication that helps restore mental stability."
	color = "#87CEEB"
	metabolization_rate = 0.5
	overdose_threshold = 30

/datum/reagent/medicine/sanity_restore/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(2)
			H.sanity.hallucination_level = max(0, H.sanity.hallucination_level - 1)
			H.sanity.insanity_level = max(0, H.sanity.insanity_level - 0.5)

/datum/reagent/medicine/antipsychotic
	name = "Antipsychotic"
	description = "A medication that helps treat psychosis and severe mental disorders."
	color = "#FF6B6B"
	metabolization_rate = 0.3
	overdose_threshold = 25

/datum/reagent/medicine/antipsychotic/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(3)
			H.sanity.hallucination_level = max(0, H.sanity.hallucination_level - 2)
			H.sanity.insanity_level = max(0, H.sanity.insanity_level - 1)

			// Remove some insanity effects
			if(H.sanity.insanity_level < 30)
				H.sanity.insanity_effects.Cut()

/datum/reagent/medicine/antianxiety
	name = "Anti-anxiety"
	description = "A medication that helps treat anxiety and panic disorders."
	color = "#98FB98"
	metabolization_rate = 0.4
	overdose_threshold = 35

/datum/reagent/medicine/antianxiety/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(2)
			H.sanity.social_isolation = max(0, H.sanity.social_isolation - 1)

			// Remove anxiety effects
			if(INSANITY_ANXIETY in H.sanity.insanity_effects)
				H.sanity.insanity_effects -= INSANITY_ANXIETY

/datum/reagent/medicine/sedative
	name = "Sedative"
	description = "A medication that calms and relaxes patients."
	color = "#DDA0DD"
	metabolization_rate = 0.6
	overdose_threshold = 40

/datum/reagent/medicine/sedative/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(1)
			H.sanity.hallucination_level = max(0, H.sanity.hallucination_level - 0.5)

			// Calm aggressive effects
			if(INSANITY_AGGRESSION in H.sanity.insanity_effects)
				H.sanity.insanity_effects -= INSANITY_AGGRESSION

// Sanity medical procedures - simplified version
/obj/item/sanity_treatment_kit
	name = "sanity treatment kit"
	desc = "A medical kit for treating mental health issues."
	icon = 'icons/obj/storage.dmi'
	icon_state = "medkit"

/obj/item/sanity_treatment_kit/attack(mob/living/carbon/target, mob/user)
	if(!ishuman(target))
		to_chat(user, "<span class='warning'>This can only be used on humans.</span>")
		return

	var/mob/living/carbon/human/H = target
	if(!H.sanity)
		to_chat(user, "<span class='warning'>[H] doesn't have a sanity system.</span>")
		return

	to_chat(user, "<span class='notice'>You begin treating [H]'s mental health...</span>")
	to_chat(H, "<span class='notice'>[user] begins a sanity treatment on you.</span>")

	if(do_after(user, 50, target = H))
		H.sanity.adjust_sanity(15)
		H.sanity.hallucination_level = max(0, H.sanity.hallucination_level - 10)
		H.sanity.insanity_level = max(0, H.sanity.insanity_level - 5)

		// Remove some traumas
		if(H.sanity.traumas.len > 0)
			var/datum/trauma/removed_trauma = pick(H.sanity.traumas)
			H.sanity.traumas -= removed_trauma
			qdel(removed_trauma)

		to_chat(user, "<span class='notice'>The sanity treatment is successful!</span>")
		to_chat(H, "<span class='notice'>You feel more mentally stable after the treatment.</span>")
	else
		to_chat(user, "<span class='warning'>The treatment was interrupted!</span>")
		H.sanity.adjust_sanity(-5)
		H.sanity.add_trauma(TRAUMA_PHYSICAL, 10)

// Sanity medical machines
/obj/machinery/sanity_monitor
	name = "sanity monitor"
	desc = "A device that monitors and displays mental health information."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sanity_monitor"
	density = TRUE
	anchored = TRUE
	var/mob/living/carbon/human/patient = null
	var/scanning = FALSE

/obj/machinery/sanity_monitor/attack_hand(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(patient == H)
		patient = null
		scanning = FALSE
		to_chat(user, "<span class='notice'>You stop the sanity monitoring.</span>")
	else
		patient = H
		scanning = TRUE
		to_chat(user, "<span class='notice'>You begin sanity monitoring.</span>")
		update_icon()

/obj/machinery/sanity_monitor/process()
	if(!patient || !scanning)
		return

	if(!patient.sanity)
		patient = null
		scanning = FALSE
		return

	// Update display
	update_display()

/obj/machinery/sanity_monitor/proc/update_display()
	if(!patient || !patient.sanity)
		return

	var/message = "<h2>Sanity Monitor - [patient.name]</h2>"
	message += "<b>Sanity Level:</b> [patient.sanity.sanity_level]/[patient.sanity.max_sanity]<br>"
	message += "<b>Mental State:</b> [patient.sanity.current_sanity_state]<br>"
	message += "<b>Hallucination Level:</b> [patient.sanity.hallucination_level]/[patient.sanity.max_hallucination]<br>"
	message += "<b>Insanity Level:</b> [patient.sanity.insanity_level]/[patient.sanity.max_insanity]<br>"
	message += "<b>Social Isolation:</b> [patient.sanity.social_isolation]/[patient.sanity.max_social_isolation]<br>"
	message += "<b>Environmental Drain:</b> [patient.sanity.environmental_sanity_drain]<br><br>"

	if(patient.sanity.traumas.len)
		message += "<h3>Active Traumas:</h3>"
		for(var/trauma in patient.sanity.traumas)
			var/datum/trauma/T = trauma
			message += "- [T.trauma_type] (Severity: [T.severity])<br>"

	if(patient.sanity.active_medications.len)
		message += "<h3>Active Medications:</h3>"
		for(var/medication in patient.sanity.active_medications)
			var/datum/medication/M = medication
			message += "- [M.name]<br>"

	if(patient.sanity.insanity_effects.len)
		message += "<h3>Insanity Effects:</h3>"
		for(var/effect in patient.sanity.insanity_effects)
			message += "- [effect]<br>"

	// Display on the machine
	visible_message("<span class='notice'>[message]</span>")

/obj/machinery/sanity_monitor/update_icon()
	. = ..()
	if(scanning && patient)
		icon_state = "sanity_monitor_on"
	else
		icon_state = "sanity_monitor"

// Sanity treatment room
/area/medical/sanity_treatment
	name = "Sanity Treatment Room"
	icon_state = "sanity_treatment"
	// Calming environment for sanity treatment

/area/medical/sanity_treatment/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(ishuman(arrived))
		var/mob/living/carbon/human/H = arrived
		if(H.sanity)
			H.sanity.sanity_recovery_rate += 0.2
			H.sanity.environmental_sanity_drain = max(0, H.sanity.environmental_sanity_drain - 0.5)

/area/medical/sanity_treatment/Exited(atom/movable/gone, direction)
	. = ..()
	if(ishuman(gone))
		var/mob/living/carbon/human/H = gone
		if(H.sanity)
			H.sanity.sanity_recovery_rate -= 0.2

// Sanity medical records
/datum/computer_file/data/sanity_record
	filename = "sanity_record"
	filetype = "SAN"
	var/list/patient_data = list()

/datum/computer_file/data/sanity_record/proc/update_record(mob/living/carbon/human/patient)
	if(!patient || !patient.sanity)
		return

	patient_data["name"] = patient.name
	patient_data["sanity_level"] = patient.sanity.sanity_level
	patient_data["mental_state"] = patient.sanity.current_sanity_state
	patient_data["hallucination_level"] = patient.sanity.hallucination_level
	patient_data["insanity_level"] = patient.sanity.insanity_level
	patient_data["social_isolation"] = patient.sanity.social_isolation
	patient_data["total_sanity_lost"] = patient.sanity.total_sanity_lost
	patient_data["total_sanity_gained"] = patient.sanity.total_sanity_gained
	patient_data["sanity_breakdowns"] = patient.sanity.sanity_breakdowns
	patient_data["longest_stable_period"] = patient.sanity.longest_stable_period
	patient_data["scp_exposures"] = patient.sanity.scp_exposures
	patient_data["traumas"] = list()

	for(var/trauma in patient.sanity.traumas)
		var/datum/trauma/T = trauma
		patient_data["traumas"] += list(list(
			"type" = T.trauma_type,
			"severity" = T.severity,
			"time_created" = T.time_created
		))

// Sanity medical console
/obj/machinery/computer/sanity_console
	name = "sanity monitoring console"
	desc = "A computer console for monitoring and managing patient sanity."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "sanity_console"
	icon_screen = "sanity_console"
	icon_keyboard = "sanity_key"
	density = TRUE
	anchored = TRUE
	var/list/patient_records = list()

/obj/machinery/computer/sanity_console/attack_hand(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	// Create or update patient record
	var/datum/computer_file/data/sanity_record/record = new()
	record.update_record(H)
	patient_records[H.name] = record

	// Display record
	var/message = "<h2>Sanity Record - [H.name]</h2>"
	message += "<b>Sanity Level:</b> [H.sanity.sanity_level]/[H.sanity.max_sanity]<br>"
	message += "<b>Mental State:</b> [H.sanity.current_sanity_state]<br>"
	message += "<b>Hallucination Level:</b> [H.sanity.hallucination_level]/[H.sanity.max_hallucination]<br>"
	message += "<b>Insanity Level:</b> [H.sanity.insanity_level]/[H.sanity.max_insanity]<br>"
	message += "<b>Social Isolation:</b> [H.sanity.social_isolation]/[H.sanity.max_social_isolation]<br>"
	message += "<b>Total Sanity Lost:</b> [H.sanity.total_sanity_lost]<br>"
	message += "<b>Total Sanity Gained:</b> [H.sanity.total_sanity_gained]<br>"
	message += "<b>Sanity Breakdowns:</b> [H.sanity.sanity_breakdowns]<br>"
	message += "<b>Longest Stable Period:</b> [H.sanity.longest_stable_period]<br><br>"

	if(H.sanity.scp_exposures.len)
		message += "<h3>SCP Exposures:</h3>"
		for(var/scp_id in H.sanity.scp_exposures)
			message += "- SCP-[scp_id]<br>"

	if(H.sanity.traumas.len)
		message += "<h3>Active Traumas:</h3>"
		for(var/trauma in H.sanity.traumas)
			var/datum/trauma/T = trauma
			message += "- [T.trauma_type] (Severity: [T.severity])<br>"

	if(H.sanity.active_medications.len)
		message += "<h3>Active Medications:</h3>"
		for(var/medication in H.sanity.active_medications)
			var/datum/medication/M = medication
			message += "- [M.name]<br>"

	if(H.sanity.insanity_effects.len)
		message += "<h3>Insanity Effects:</h3>"
		for(var/effect in H.sanity.insanity_effects)
			message += "- [effect]<br>"

	to_chat(user, "<span class='notice'>[message]</span>")

// Sanity medical recommendations
/datum/sanity/proc/get_medical_recommendations()
	var/list/recommendations = list()

	if(sanity_level < 50)
		recommendations += "Immediate psychiatric evaluation recommended"

	if(hallucination_level > 30)
		recommendations += "Antipsychotic medication may be beneficial"

	if(insanity_level > 40)
		recommendations += "Intensive psychiatric treatment required"

	if(social_isolation > 70)
		recommendations += "Social interaction therapy recommended"

	if(traumas.len > 3)
		recommendations += "Trauma counseling recommended"

	if(INSANITY_ANXIETY in insanity_effects)
		recommendations += "Anti-anxiety medication may help"

	if(INSANITY_AGGRESSION in insanity_effects)
		recommendations += "Sedative medication may be necessary"

	if(INSANITY_DELUSIONS in insanity_effects)
		recommendations += "Antipsychotic medication strongly recommended"

	return recommendations

// Sanity medical prognosis
/datum/sanity/proc/get_medical_prognosis()
	var/prognosis = "Good"

	if(sanity_level < 20)
		prognosis = "Critical"
	else if(sanity_level < 40)
		prognosis = "Poor"
	else if(sanity_level < 60)
		prognosis = "Fair"
	else if(sanity_level < 80)
		prognosis = "Good"
	else
		prognosis = "Excellent"

	return prognosis
