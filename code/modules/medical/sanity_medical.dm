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

/obj/machinery/sanity_monitor
	name = "sanity monitor"
	desc = "A device that monitors and displays mental health information."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sanity_monitor"
	density = TRUE
	anchored = TRUE
	var/mob/living/carbon/human/patient = null
	var/scanning = FALSE

/obj/machinery/sanity_monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SanityPanel", "Sanity Monitor")
		ui.open()

/obj/machinery/sanity_monitor/ui_data(mob/user)
	var/list/data = list()

	if(!patient || !patient.sanity)
		data["has_patient"] = FALSE
		return data

	data["has_patient"] = TRUE
	var/datum/sanity/S = patient.sanity

	data["sanity_level"] = S.sanity_level
	data["max_sanity"] = S.max_sanity
	data["sanity_state"] = S.current_sanity_state
	data["previous_state"] = S.previous_sanity_state
	data["sanity_percentage"] = round((S.sanity_level / S.max_sanity) * 100, 0.1)
	data["hallucination_level"] = S.hallucination_level
	data["max_hallucination"] = S.max_hallucination
	data["insanity_level"] = S.insanity_level
	data["max_insanity"] = S.max_insanity
	data["social_isolation"] = S.social_isolation
	data["max_social_isolation"] = S.max_social_isolation
	data["environmental_drain"] = S.environmental_sanity_drain
	data["recovery_rate"] = S.sanity_recovery_rate
	data["treatment_effectiveness"] = S.treatment_effectiveness
	data["episode_active"] = S.episode_active
	data["episode_type"] = S.episode_type
	data["episode_time_remaining"] = S.episode_active ? max(0, S.episode_end_time - world.time) : 0
	data["is_admin"] = check_rights_for(user?.client, R_ADMIN)
	data["patient_name"] = patient.name

	data["traumas"] = list()
	for(var/datum/trauma/T as anything in S.traumas)
		data["traumas"] += list(list(
			"type" = T.trauma_type,
			"severity" = T.severity,
			"drain" = T.sanity_drain,
			"age" = world.time - T.time_created,
		))

	data["scp_exposures"] = list()
	for(var/scp_id in S.scp_exposures)
		data["scp_exposures"] += list(list(
			"scp_id" = scp_id,
			"last_exposure" = S.scp_exposures[scp_id],
			"time_since" = world.time - S.scp_exposures[scp_id],
		))

	data["medications"] = list()
	for(var/datum/medication/M as anything in S.active_medications)
		data["medications"] += list(list(
			"name" = M.name,
			"effectiveness" = M.effectiveness,
			"time_remaining" = M.duration > 0 ? max(0, (M.time_applied + M.duration) - world.time) : -1,
		))

	data["insanity_effects"] = S.insanity_effects.Copy()
	data["active_vfx"] = list()
	for(var/vfx_type in S.active_vfx)
		data["active_vfx"] += vfx_type
	data["profile"] = S.get_profile_data()
	data["recommendations"] = S.get_medical_recommendations()
	data["prognosis"] = S.get_medical_prognosis()
	data["statistics"] = list(
		"total_lost" = S.total_sanity_lost,
		"total_gained" = S.total_sanity_gained,
		"breakdowns" = S.sanity_breakdowns,
		"stable_ticks" = S.longest_stable_period,
	)

	data["environmental_factors"] = list()
	for(var/factor in S.environmental_factors)
		data["environmental_factors"] += list(list(
			"name" = factor,
			"value" = S.environmental_factors[factor],
		))

	data["effectiveness_modifiers"] = list(
		"containment" = S.get_containment_effectiveness(),
		"research" = S.get_research_effectiveness(),
		"communication" = S.get_communication_effectiveness(),
		"combat" = S.get_combat_effectiveness(),
		"medical" = S.get_medical_effectiveness(),
		"engineering" = S.get_engineering_effectiveness(),
		"security" = S.get_security_effectiveness(),
		"administrative" = S.get_administrative_effectiveness(),
		"scientific" = S.get_scientific_effectiveness(),
		"psychological" = S.get_psychological_effectiveness(),
	)

	data["active_hallucinations"] = list()
	for(var/hallucination in S.active_hallucinations)
		data["active_hallucinations"] += hallucination

	data["trauma_resistances"] = list()
	for(var/trauma_type in S.trauma_resistances)
		data["trauma_resistances"] += list(list(
			"type" = trauma_type,
			"resistance" = S.trauma_resistances[trauma_type],
		))

	data["scp_resistance"] = S.check_scp_resistance("")
	data["scp_vulnerability"] = S.check_scp_vulnerability("")
	data["scp_interaction_modifier"] = S.get_scp_interaction_modifier("")

	return data

/obj/machinery/sanity_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("scan")
			var/mob/user = usr
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user
			if(patient == H)
				patient = null
				scanning = FALSE
			else
				patient = H
				scanning = TRUE
			. = TRUE

		if("clear_patient")
			patient = null
			scanning = FALSE
			. = TRUE

/obj/machinery/sanity_monitor/process()
	if(!patient || !scanning)
		return
	if(!patient.sanity || QDELETED(patient))
		patient = null
		scanning = FALSE
		return
	SStgui.update_uis(src)

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
	circuit = /obj/item/circuitboard/computer/sanity_console
	var/list/patient_records = list()
	var/mob/living/carbon/human/selected_patient = null

/obj/machinery/computer/sanity_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SanityPanel", "Sanity Records")
		ui.open()

/obj/machinery/computer/sanity_console/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/carbon/human/H = selected_patient
	if(!H || !H.sanity)
		data["has_patient"] = FALSE
		data["record_count"] = length(patient_records)
		return data

	data["has_patient"] = TRUE
	data["patient_name"] = H.name

	var/datum/sanity/S = H.sanity
	data["sanity_level"] = S.sanity_level
	data["max_sanity"] = S.max_sanity
	data["sanity_state"] = S.current_sanity_state
	data["previous_state"] = S.previous_sanity_state
	data["sanity_percentage"] = round((S.sanity_level / S.max_sanity) * 100, 0.1)
	data["hallucination_level"] = S.hallucination_level
	data["max_hallucination"] = S.max_hallucination
	data["insanity_level"] = S.insanity_level
	data["max_insanity"] = S.max_insanity
	data["social_isolation"] = S.social_isolation
	data["max_social_isolation"] = S.max_social_isolation
	data["environmental_drain"] = S.environmental_sanity_drain
	data["recovery_rate"] = S.sanity_recovery_rate
	data["treatment_effectiveness"] = S.treatment_effectiveness
	data["episode_active"] = S.episode_active
	data["episode_type"] = S.episode_type
	data["episode_time_remaining"] = S.episode_active ? max(0, S.episode_end_time - world.time) : 0
	data["is_admin"] = check_rights_for(user?.client, R_ADMIN)

	data["traumas"] = list()
	for(var/datum/trauma/T as anything in S.traumas)
		data["traumas"] += list(list(
			"type" = T.trauma_type,
			"severity" = T.severity,
			"drain" = T.sanity_drain,
			"age" = world.time - T.time_created,
		))

	data["scp_exposures"] = list()
	for(var/scp_id in S.scp_exposures)
		data["scp_exposures"] += list(list(
			"scp_id" = scp_id,
			"last_exposure" = S.scp_exposures[scp_id],
			"time_since" = world.time - S.scp_exposures[scp_id],
		))

	data["medications"] = list()
	for(var/datum/medication/M as anything in S.active_medications)
		data["medications"] += list(list(
			"name" = M.name,
			"effectiveness" = M.effectiveness,
			"time_remaining" = M.duration > 0 ? max(0, (M.time_applied + M.duration) - world.time) : -1,
		))

	data["insanity_effects"] = S.insanity_effects.Copy()
	data["active_vfx"] = list()
	for(var/vfx_type in S.active_vfx)
		data["active_vfx"] += vfx_type
	data["profile"] = S.get_profile_data()
	data["recommendations"] = S.get_medical_recommendations()
	data["prognosis"] = S.get_medical_prognosis()
	data["statistics"] = list(
		"total_lost" = S.total_sanity_lost,
		"total_gained" = S.total_sanity_gained,
		"breakdowns" = S.sanity_breakdowns,
		"stable_ticks" = S.longest_stable_period,
	)

	data["environmental_factors"] = list()
	for(var/factor in S.environmental_factors)
		data["environmental_factors"] += list(list(
			"name" = factor,
			"value" = S.environmental_factors[factor],
		))

	data["effectiveness_modifiers"] = list(
		"containment" = S.get_containment_effectiveness(),
		"research" = S.get_research_effectiveness(),
		"communication" = S.get_communication_effectiveness(),
		"combat" = S.get_combat_effectiveness(),
		"medical" = S.get_medical_effectiveness(),
		"engineering" = S.get_engineering_effectiveness(),
		"security" = S.get_security_effectiveness(),
		"administrative" = S.get_administrative_effectiveness(),
		"scientific" = S.get_scientific_effectiveness(),
		"psychological" = S.get_psychological_effectiveness(),
	)

	data["active_hallucinations"] = list()
	for(var/hallucination in S.active_hallucinations)
		data["active_hallucinations"] += hallucination

	data["trauma_resistances"] = list()
	for(var/trauma_type in S.trauma_resistances)
		data["trauma_resistances"] += list(list(
			"type" = trauma_type,
			"resistance" = S.trauma_resistances[trauma_type],
		))

	data["scp_resistance"] = S.check_scp_resistance("")
	data["scp_vulnerability"] = S.check_scp_vulnerability("")
	data["scp_interaction_modifier"] = S.get_scp_interaction_modifier("")

	return data

/obj/machinery/computer/sanity_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	switch(action)
		if("scan_self")
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user
			selected_patient = H
			var/datum/computer_file/data/sanity_record/record = new()
			record.update_record(H)
			patient_records[H.name] = record
			. = TRUE

		if("clear_patient")
			selected_patient = null
			. = TRUE

/obj/item/circuitboard/computer/sanity_console
	name = "Sanity Console (Computer Board)"
	build_path = /obj/machinery/computer/sanity_console

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
