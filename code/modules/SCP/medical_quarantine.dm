// Medical Quarantine Zone
// Physical quarantine area for SCP-008/049 infection treatment with airlock, decontamination, and treatment bays

/area/scp/medical/quarantine
	name = "Medical Quarantine Zone"
	icon_state = "medbay_quar"

/area/scp/medical/quarantine/lobby
	name = "Quarantine Lobby"
	icon_state = "medbay_quar_lobby"

/area/scp/medical/quarantine/airlock
	name = "Quarantine Airlock"
	icon_state = "medbay_quar_air"

/area/scp/medical/quarantine/decontamination
	name = "Decontamination Chamber"
	icon_state = "medbay_quar_decon"

/area/scp/medical/quarantine/treatment_a
	name = "Quarantine Treatment Bay A"
	icon_state = "medbay_quar_a"

/area/scp/medical/quarantine/treatment_b
	name = "Quarantine Treatment Bay B"
	icon_state = "medbay_quar_b"

/area/scp/medical/quarantine/observation
	name = "Quarantine Observation"
	icon_state = "medbay_quar_obs"

/obj/machinery/quarantine_console
	name = "Quarantine Control Console"
	desc = "Controls the medical quarantine zone airlocks, decontamination, and containment protocols."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "rdserver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

	var/quarantine_active = FALSE
	var/decon_active = FALSE
	var/list/quarantined_patients = list()
	var/treatment_progress = list()
	var/infection_types = list("scp008", "scp049_pestilence")

/obj/machinery/quarantine_console/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		to_chat(H, span_warning("Requires Medical access to operate quarantine systems."))
		return

	if(quarantine_active)
		var/choice = alert(H, "Quarantine is ACTIVE. Options:", "Quarantine Control", "Run Decontamination", "Lift Quarantine", "Cancel")
		if(choice == "Run Decontamination")
			run_decontamination(H)
		else if(choice == "Lift Quarantine")
			lift_quarantine(H)
		return

	var/choice = alert(H, "Quarantine is INACTIVE. Options:", "Quarantine Control", "Activate Quarantine", "Cancel")
	if(choice == "Activate Quarantine")
		activate_quarantine(H)

/obj/machinery/quarantine_console/proc/activate_quarantine(mob/user)
	quarantine_active = TRUE
	priority_announce("MEDICAL ALERT: Quarantine protocols activated in Medical Quarantine Zone. All infected personnel report to quarantine immediately.", "QUARANTINE", null, ANNOUNCER_ALERT)

	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/medical/quarantine/airlock))
			A.lock()

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/medical/quarantine/treatment_a) || istype(A, /area/scp/medical/quarantine/treatment_b))
			quarantined_patients += H.ckey
			to_chat(H, span_warning("Quarantine protocols activated. You are now under medical quarantine. Do not leave the treatment bay."))

	report_lockdown_to_round_log("Medical quarantine activated", 0)
	to_chat(user, span_notice("Quarantine protocols activated. Airlocks sealed."))

/obj/machinery/quarantine_console/proc/lift_quarantine(mob/user)
	quarantine_active = FALSE
	quarantined_patients.Cut()
	treatment_progress = list()

	for(var/obj/machinery/door/airlock/A in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/area = get_area(A)
		if(istype(area, /area/scp/medical/quarantine/airlock))
			A.unlock()

	priority_announce("Medical quarantine has been lifted. All quarantine patients cleared for release.", "QUARANTINE LIFTED", null, ANNOUNCER_DEFAULT)
	to_chat(user, span_notice("Quarantine lifted. Airlocks unlocked."))

/obj/machinery/quarantine_console/proc/run_decontamination(mob/user)
	if(decon_active)
		to_chat(user, span_warning("Decontamination already in progress."))
		return

	decon_active = TRUE
	to_chat(user, span_notice("Decontamination sequence initiated."))

	var/list/patients = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/medical/quarantine/decontamination))
			patients += H

	if(!length(patients))
		to_chat(user, span_warning("No patients in decontamination chamber."))
		decon_active = FALSE
		return

	for(var/mob/living/carbon/human/H in patients)
		to_chat(H, span_warning("Decontamination spray activated! The chamber fills with sterilizing agents."))
		H.adjustFireLoss(5)

		if(H.sanity)
			H.sanity.adjust_sanity(-10, "decontamination")

		var/cured = FALSE
		for(var/datum/pathogen/P in H.diseases.Copy())
			if(istype(P, /datum/pathogen/foundation))
				qdel(P)
				cured = TRUE
				break

		if(cured)
			to_chat(H, span_nicegreen("You feel the infection receding... Treatment appears effective!"))
		else
			to_chat(H, span_warning("The decontamination stings but doesn't seem to help your condition."))

	addtimer(CALLBACK(src, .proc/finish_decontamination), 100)

/obj/machinery/quarantine_console/proc/finish_decontamination()
	decon_active = FALSE
	visible_message(span_notice("[src] indicates decontamination cycle complete."))

// Quarantine Scanner - Detects infections
/obj/machinery/quarantine_scanner
	name = "Quarantine Bio-Scanner"
	desc = "Scans for biological anomalies and SCP-related infections."
	icon = 'icons/obj/machines/bodyscanner.dmi'
	icon_state = "body_scanner"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/scan_cooldown = 0

/obj/machinery/quarantine_scanner/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(world.time < scan_cooldown)
		to_chat(user, span_warning("Scanner recharging."))
		return

	var/mob/living/carbon/human/H = user
	scan_cooldown = world.time + 10 SECONDS

	var/list/infections = list()

	for(var/datum/pathogen/P in H.diseases)
		if(istype(P, /datum/pathogen/foundation))
			infections += P.name

	if(H.reagents)
		for(var/datum/reagent/R in H.reagents.reagent_list)
			if(findtext("[R.type]", "scp") || findtext("[R.type]", "008") || findtext("[R.type]", "049"))
				infections += R.name

	var/pestilence_level = 0
	for(var/datum/pathogen/P in H.diseases)
		if(istype(P, /datum/pathogen/foundation) && !istype(P, /datum/pathogen/foundation/scp008))
			pestilence_level = 100

	to_chat(H, span_boldnotice("=== Bio-Scan Results ==="))
	if(length(infections))
		to_chat(H, span_danger("ANOMALOUS BIOLOGICAL AGENTS DETECTED:"))
		for(var/inf in infections)
			to_chat(H, span_danger("- [inf]"))
		to_chat(H, span_warning("QUARANTINE RECOMMENDED"))
	else
		to_chat(H, span_nicegreen("No anomalous biological agents detected. Subject is clear."))

	if(pestilence_level > 0)
		to_chat(H, span_userdanger("PESTILENCE DETECTED - SCP-049 INFECTION CONFIRMED - IMMEDIATE QUARANTINE REQUIRED"))

// Treatment Bed
/obj/machinery/stasis/quarantine_bed
	name = "Quarantine Treatment Bed"
	desc = "A medical bed equipped with advanced treatment systems for anomalous infections."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/machinery/stasis/quarantine_bed/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.stat == DEAD)
		return

	var/list/options = list("Apply SCP-008 Countermeasure", "Apply SCP-049 Countermeasure", "General Treatment", "Cancel")
	var/choice = input(H, "Select treatment:", "Quarantine Bed") as null|anything in options
	if(!choice || choice == "Cancel")
		return

	switch(choice)
		if("Apply SCP-008 Countermeasure")
			H.adjustToxLoss(-20)
			H.adjustBruteLoss(-10)
			for(var/datum/pathogen/P in H.diseases.Copy())
				if(istype(P, /datum/pathogen/foundation/scp008))
					if(prob(60))
						qdel(P)
						to_chat(H, span_nicegreen("SCP-008 infection successfully treated!"))
					else
						to_chat(H, span_warning("Treatment partially effective. Infection weakened but not eliminated."))
					break
		if("Apply SCP-049 Countermeasure")
			H.adjustToxLoss(-15)
			H.adjustBruteLoss(-10)
			for(var/datum/pathogen/P in H.diseases.Copy())
				if(istype(P, /datum/pathogen/foundation))
					if(prob(40))
						qdel(P)
						to_chat(H, span_nicegreen("Pestilence successfully treated!"))
					else
						to_chat(H, span_warning("Treatment partially effective. Pestilence remains."))
					break
		if("General Treatment")
			H.adjustBruteLoss(-15)
			H.adjustFireLoss(-15)
			H.adjustToxLoss(-10)
			if(H.sanity)
				H.sanity.adjust_sanity(10, "quarantine_treatment")
			to_chat(H, span_notice("General treatment applied. You feel slightly better."))

/datum/status_effect/bsl4_contagion
	id = "bsl4_contagion"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/bsl4_contagion
	var/stage = 1
	var/max_stage = 5
	var/contagion_name = "Unknown Pathogen"
	var/stage_timer = 0
	var/stage_interval = 1200
	var/spread_range = 2
	var/contagious = TRUE

/datum/status_effect/bsl4_contagion/proc/advance_stage()
	if(stage >= max_stage)
		return
	stage++
	switch(stage)
		if(2)
			to_chat(owner, span_warning("You feel feverish and begin to sweat profusely."))
		if(3)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
			owner.adjustToxLoss(10)
			to_chat(owner, span_warning("Your skin breaks out in lesions. You feel violently ill."))
		if(4)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
			owner.adjustToxLoss(20)
			owner.blur_eyes(20)
			to_chat(owner, span_warning("Blood seeps from your eyes and nose. Your body is shutting down."))
		if(5)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
			owner.adjustToxLoss(40)
			contagious = TRUE
			spread_range = 4
			to_chat(owner, span_warning("You are a walking biohazard. Your body is failing."))
	if(GLOB.scp_admin_log)
		GLOB.scp_admin_log.log_event("CONTAGION", contagion_name, owner.ckey, null, "BSL-4 contagion advanced to stage [stage]", "HIGH")

/datum/status_effect/bsl4_contagion/tick()
	stage_timer++
	if(stage_timer >= stage_interval / 10)
		stage_timer = 0
		advance_stage()
	if(contagious)
		spread_contagion()
	if(stage >= 3 && prob(10))
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			C.vomit(blood = TRUE)
	if(stage >= 4 && prob(5))
		owner.adjustOxyLoss(5)

/datum/status_effect/bsl4_contagion/proc/spread_contagion()
	if(!contagious || !isliving(owner))
		return
	var/mob/living/source = owner
	if(source.stat == DEAD)
		return
	var/obj/item/clothing/mask/M = null
	if(iscarbon(source))
		var/mob/living/carbon/C = source
		M = C.wear_mask
	if(M && (M.flags_cover & MASKCOVERSMOUTH))
		return
	for(var/mob/living/carbon/human/H in hearers(spread_range, source))
		if(H == source || H.stat == DEAD)
			continue
		if(H.has_status_effect(/datum/status_effect/bsl4_contagion))
			continue
		var/obj/item/clothing/mask/HM = H.wear_mask
		if(HM && (HM.flags_cover & MASKCOVERSMOUTH))
			continue
		if(prob(15 * stage))
			H.apply_status_effect(/datum/status_effect/bsl4_contagion)

/datum/status_effect/bsl4_contagion/proc/cure()
	owner.remove_status_effect(/datum/status_effect/bsl4_contagion)
	to_chat(owner, span_notice("The contagion clears from your system."))

/atom/movable/screen/alert/status_effect/bsl4_contagion
	name = "BSL-4 Contagion"
	desc = "You are infected with a biohazardous contagion. Seek medical attention immediately."
	icon_state = "disease"

/obj/item/biohazard_scanner
	name = "biohazard scanner"
	desc = "A handheld scanner for detecting BSL-4 level contagions in personnel."
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	w_class = WEIGHT_CLASS_SMALL
	var/last_scan = 0
	var/scan_cooldown = 50

/obj/item/biohazard_scanner/attack(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return
	if(world.time < last_scan + scan_cooldown)
		to_chat(user, span_warning("Scanner is recharging."))
		return
	last_scan = world.time
	var/mob/living/carbon/human/H = target
	var/datum/status_effect/bsl4_contagion/C = H.has_status_effect(/datum/status_effect/bsl4_contagion)
	if(C)
		to_chat(user, span_warning("CONTAGION DETECTED: [C.contagion_name] - Stage [C.stage]/[C.max_stage] - [C.contagious ? "CONTAGIOUS" : "Non-contagious"]"))
		playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)
	else
		to_chat(user, span_notice("No BSL-4 contagions detected in [H.name]."))
		playsound(src, 'sound/machines/ping.ogg', 50, TRUE)

/obj/item/biohazard_sample
	name = "biohazard sample"
	desc = "A sealed container holding a BSL-4 pathogen sample. Handle with extreme caution."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vial"
	w_class = WEIGHT_CLASS_TINY
	var/contagion_name = "Unknown Pathogen"
	var/virulence = 3

/obj/item/biohazard_sample/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.wear_mask || !(H.wear_mask.flags_cover & MASKCOVERSMOUTH))
		to_chat(H, span_warning("The sample container cracks open! Pathogen exposure!"))
		var/datum/status_effect/bsl4_contagion/C = H.apply_status_effect(/datum/status_effect/bsl4_contagion)
		if(C)
			C.contagion_name = contagion_name
			C.max_stage = virulence
		qdel(src)
	else
		to_chat(H, span_notice("Your mask protects you from the sample exposure."))
