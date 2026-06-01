/datum/surgery_step/scp008_excision
	name = "Excise SCP-008 Tissue"
	desc = "Surgically removes SCP-008 infected tissue before the prion reaches the brain."
	surgery_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_RETRACTED | SURGERY_BLOODY_GLOVES
	allowed_tools = list(
		TOOL_SCALPEL = 85,
		TOOL_SAW = 50,
	)
	min_duration = 4 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/scp008_excision/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = ..()
	if(!affected)
		return
	if(target.mind?.has_antag_datum(/datum/antagonist/scp/scp008))
		return TRUE
	return FALSE

/datum/surgery_step/scp008_excision/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(!target.mind?.has_antag_datum(/datum/antagonist/scp/scp008))
		to_chat(user, span_notice("[target] shows no signs of SCP-008 infection."))
		return TRUE

/datum/surgery_step/scp008_excision/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	user.visible_message(span_notice("[user] begins carefully excising discolored tissue from [target]'s [target_zone == BODY_ZONE_CHEST ? "chest" : "body"]."), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/scp008_excision/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/excised = FALSE
	if(target.mind?.has_antag_datum(/datum/antagonist/scp/scp008))
		target.mind.remove_antag_datum(/datum/antagonist/scp/scp008)
		to_chat(target, span_warning("The alien hunger fades from your mind. Your body aches but you feel... yourself again."))
		excised = TRUE
	target.adjustBruteLoss(15)
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(excised)
		user.visible_message(span_notice("[user] successfully excises SCP-008 infected tissue from [target]!"), vision_distance = COMBAT_MESSAGE_RANGE)
		log_game("SCP-008 excision surgery performed on [key_name(target)] by [key_name(user)]")
		hook_scp_interaction(user, "008", INTERACTION_TYPE_MEDICAL)
		if(SSpsychology)
			SSpsychology.record_exposure(target, "SCP-008", "surgical", "Underwent SCP-008 excision surgery")
	else
		user.visible_message(span_notice("[user] finds no SCP-008 tissue to remove."), vision_distance = COMBAT_MESSAGE_RANGE)
	..()

/datum/surgery_step/scp008_excision/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	target.adjustBruteLoss(25)
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
	user.visible_message(span_warning("[user]'s hand slips, spreading the infected tissue further!"), vision_distance = COMBAT_MESSAGE_RANGE)
	if(target.mind?.has_antag_datum(/datum/antagonist/scp/scp008))
		to_chat(target, span_warning("The botched surgery sends the infection deeper into your system!"))

/datum/surgery_step/scp049_cure_reversal
	name = "Extract Pestilence"
	desc = "Surgically extracts the anomalous 'Pestilence' marker from a patient's bloodstream, making them undetectable to SCP-049."
	surgery_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_DEENCASEMENT | SURGERY_BLOODY_BODY
	allowed_tools = list(
		TOOL_HEMOSTAT = 85,
		TOOL_SCREWDRIVER = 35,
	)
	min_duration = 5 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/scp049_cure_reversal/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = ..()
	if(!affected)
		return
	if(affected.body_zone == BODY_ZONE_CHEST || affected.body_zone == BODY_ZONE_HEAD)
		if(HAS_TRAIT(target, TRAIT_PESTILENCE))
			return TRUE
	return FALSE

/datum/surgery_step/scp049_cure_reversal/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(!HAS_TRAIT(target, TRAIT_PESTILENCE))
		to_chat(user, span_notice("[target] shows no signs of the Pestilence."))
	return TRUE

/datum/surgery_step/scp049_cure_reversal/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	user.visible_message(span_notice("[user] begins carefully extracting Pestilence-tainted tissue from [target]'s [target_zone == BODY_ZONE_HEAD ? "brain" : "chest cavity"]."), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/scp049_cure_reversal/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/extracted = FALSE
	if(HAS_TRAIT(target, TRAIT_PESTILENCE))
		REMOVE_TRAIT(target, TRAIT_PESTILENCE, "scp049")
		to_chat(target, span_notice("The strange weight in your body lifts. You no longer feel 'detected'."))
		extracted = TRUE
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15)
	target.adjustBruteLoss(10)
	target.adjustToxLoss(10)
	if(extracted)
		user.visible_message(span_notice("[user] successfully extracts Pestilence-tainted tissue from [target]! The patient is no longer detectable by SCP-049."), vision_distance = COMBAT_MESSAGE_RANGE)
		log_game("Pestilence extraction surgery performed on [key_name(target)] by [key_name(user)]")
		hook_scp_interaction(user, "049", INTERACTION_TYPE_MEDICAL)
		if(SSpsychology)
			SSpsychology.record_exposure(target, "SCP-049", "surgical", "Underwent Pestilence extraction surgery")
	else
		user.visible_message(span_notice("[user] completes the procedure but finds no Pestilence tissue to extract."), vision_distance = COMBAT_MESSAGE_RANGE)
	..()

/datum/surgery_step/scp049_cure_reversal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)
	target.adjustToxLoss(20)
	user.visible_message(span_warning("[user] damages [target]'s tissue during the Pestilence extraction!"), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/containment_implant_install
	name = "Install Containment Tracker"
	desc = "Implants a containment tracking chip subdermally for monitoring SCP-exposed personnel."
	surgery_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_INCISION
	allowed_tools = list(
		/obj/item/implantcase/containment = 100,
		/obj/item/implant/containment = 50,
	)
	min_duration = 3 SECONDS
	max_duration = 5 SECONDS

/datum/surgery_step/containment_implant_install/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = ..()
	if(!affected)
		return
	if(affected.body_zone != BODY_ZONE_CHEST && affected.body_zone != BODY_ZONE_HEAD)
		return FALSE
	var/obj/item/implant/containment/existing = locate(/obj/item/implant/containment) in target.implants
	if(existing)
		to_chat(user, span_warning("[target] already has a containment tracking chip installed."))
		return FALSE
	return TRUE

/datum/surgery_step/containment_implant_install/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	var/obj/item/implant/containment/existing = locate(/obj/item/implant/containment) in target.implants
	if(existing)
		to_chat(user, span_warning("[target] already has a containment chip."))
		return FALSE
	return TRUE

/datum/surgery_step/containment_implant_install/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	user.visible_message(span_notice("[user] begins implanting a containment tracking chip in [target]."), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/containment_implant_install/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/implant/containment/C = new /obj/item/implant/containment()
	C.implant(target, null, silent = TRUE)
	if(istype(tool, /obj/item/implantcase/containment))
		qdel(tool)
	else if(istype(tool, /obj/item/implant/containment))
		qdel(tool)
	user.visible_message(span_notice("[user] successfully implants a containment tracking chip in [target]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	to_chat(target, span_notice("You feel a small device inserted beneath your skin."))
	log_game("Containment tracking chip implanted in [key_name(target)] by [key_name(user)]")
	..()

/datum/surgery_step/containment_implant_install/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	target.adjustBruteLoss(10)
	user.visible_message(span_warning("[user] fumbles the implantation, damaging [target]'s tissue!"), vision_distance = COMBAT_MESSAGE_RANGE)
	if(istype(tool, /obj/item/implantcase/containment))
		qdel(tool)

/datum/surgery_step/amnestic_implant_install
	name = "Install Amnestic Implant"
	desc = "Implants a subdermal amnestic device that can be remotely triggered to administer memory-altering compounds."
	surgery_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_INCISION
	allowed_tools = list(
		/obj/item/implantcase/amnestic = 100,
		/obj/item/implant/amnestic = 50,
	)
	min_duration = 3 SECONDS
	max_duration = 5 SECONDS

/datum/surgery_step/amnestic_implant_install/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = ..()
	if(!affected)
		return
	if(affected.body_zone != BODY_ZONE_HEAD)
		return FALSE
	var/obj/item/implant/amnestic/existing = locate(/obj/item/implant/amnestic) in target.implants
	if(existing)
		to_chat(user, span_warning("[target] already has an amnestic implant."))
		return FALSE
	return TRUE

/datum/surgery_step/amnestic_implant_install/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	var/obj/item/implant/amnestic/existing = locate(/obj/item/implant/amnestic) in target.implants
	if(existing)
		to_chat(user, span_warning("[target] already has an amnestic implant."))
		return FALSE
	return TRUE

/datum/surgery_step/amnestic_implant_install/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	user.visible_message(span_notice("[user] begins implanting an amnestic device behind [target]'s ear."), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/surgery_step/amnestic_implant_install/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/implant/amnestic/A = new /obj/item/implant/amnestic()
	A.implant(target, null, silent = TRUE)
	if(istype(tool, /obj/item/implantcase/amnestic))
		qdel(tool)
	else if(istype(tool, /obj/item/implant/amnestic))
		qdel(tool)
	user.visible_message(span_notice("[user] successfully implants an amnestic device in [target]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	to_chat(target, span_notice("You feel a small device inserted behind your ear."))
	log_game("Amnestic implant installed in [key_name(target)] by [key_name(user)]")
	..()

/datum/surgery_step/amnestic_implant_install/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15)
	target.adjustBruteLoss(5)
	user.visible_message(span_warning("[user] damages [target]'s head during the implantation!"), vision_distance = COMBAT_MESSAGE_RANGE)
	if(istype(tool, /obj/item/implantcase/amnestic))
		qdel(tool)

/obj/item/storage/medkit/scp_emergency
	name = "SCP Zone Emergency Kit"
	desc = "A specialized medical kit for operating in SCP containment zones. Contains counteragents, anti-contamination supplies, and stabilization gear."
	icon_state = "medkit_advanced"
	inhand_icon_state = "medkit_advanced"
	damagetype_healed = "all"

/obj/item/storage/medkit/scp_emergency/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_slots = 14
	atom_storage.max_total_storage = 28
	atom_storage.set_holdable(list(
		/obj/item/stack/medical,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/pill,
		/obj/item/healthanalyzer,
		/obj/item/stack/gauze,
		/obj/item/bodybag,
		/obj/item/scp_decontamination_wand,
	))

/obj/item/storage/medkit/scp_emergency/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/gauze = 1,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/hypospray/medipen = 2,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 1,
		/obj/item/reagent_containers/hypospray/medipen/dylovene = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/bodybag = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/scp_decontamination_wand
	name = "Anomalous Decontamination Wand"
	desc = "A handheld device that neutralizes trace anomalous contamination on surfaces and personnel. Has 5 uses before the reagent cartridge is depleted."
	icon = 'icons/obj/device.dmi'
	icon_state = "healthanalyzer"
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 5

/obj/item/scp_decontamination_wand/attack_self(mob/user)
	if(uses <= 0)
		to_chat(user, span_warning("The decontamination wand is depleted."))
		return
	to_chat(user, span_notice("The decontamination wand has [uses] uses remaining."))

/obj/item/scp_decontamination_wand/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag || uses <= 0)
		return
	uses--
	user.visible_message(span_notice("[user] waves the decontamination wand over [target], neutralizing trace contamination."), span_notice("You decontaminate [target]. [uses] uses remaining."))
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.sanity)
			H.sanity.adjust_sanity(5, "decontamination")
		if(SSpsychology)
			for(var/datum/scp_exposure_record/R in SSpsychology.exposure_records)
				if(R.person_name == H.real_name && !R.treated && R.exposure_type == "environmental")
					R.treat("decontamination_wand")
					break
		hook_scp_interaction(user, "decontamination", INTERACTION_TYPE_CARE)
	if(uses <= 0)
		to_chat(user, span_warning("The decontamination wand is now depleted."))

/obj/item/storage/box/scp_paramedic_kit
	name = "Paramedic SCP Response Kit"
	desc = "A box containing specialized equipment for responding to medical emergencies in SCP containment zones."

/obj/item/storage/box/scp_paramedic_kit/PopulateContents()
	var/static/items_inside = list(
		/obj/item/storage/medkit/scp_emergency = 1,
		/obj/item/bodybag/stasis = 1,
		/obj/item/scp_decontamination_wand = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	generate_items_inside(items_inside, src)

/datum/outfit/paramedic_scp_response
	name = "Paramedic SCP Zone Response"
	suit = /obj/item/clothing/suit/toggle/labcoat/paramedic
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/storage/belt/medical/paramedic
	backpack_contents = list(
		/obj/item/storage/medkit/scp_emergency = 1,
		/obj/item/bodybag/stasis = 1,
		/obj/item/scp_decontamination_wand = 1,
		/obj/item/clothing/mask/gas = 1,
	)

#define GAS_DECONTAM "decontamination_gas"
#define GAS_MEMETIC_NEUTRAL "memetic_neutralizer"

/datum/xgm_gas/decontamination
	id = GAS_DECONTAM
	name = "Decontamination Gas"
	specific_heat = 30
	molar_mass = 0.048
	flags = XGM_GAS_CONTAMINANT
	symbol_html = "Dc"
	symbol = "Dc"
	purchaseable = TRUE
	base_value = 0.08
	breathed_product = /datum/reagent/decontam_gas

/datum/reagent/decontam_gas
	name = "Decontamination Gas"
	description = "A specialized gas that neutralizes anomalous biological contamination in the lungs and bloodstream."
	reagent_state = GAS
	color = "#b0e0e6"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_NO_RANDOM_RECIPE
	taste_description = "sterile cleanliness"

/datum/reagent/decontam_gas/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	if(!istype(M))
		return
	if(M.mind?.has_antag_datum(/datum/antagonist/scp/scp008))
		M.mind.remove_antag_datum(/datum/antagonist/scp/scp008)
		to_chat(M, span_notice("The infection in your body recedes as the gas takes effect."))
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(3, "decontam_gas")
	if(SSpsychology)
		for(var/datum/scp_exposure_record/R in SSpsychology.exposure_records)
			if(R.person_name == M.real_name && !R.treated && R.exposure_type == "environmental")
				R.treat("decontamination_gas_exposure")
				break

/datum/xgm_gas/memetic_neutralizer
	id = GAS_MEMETIC_NEUTRAL
	name = "Memetic Neutralizer"
	specific_heat = 25
	molar_mass = 0.052
	flags = XGM_GAS_NOBLE
	symbol_html = "Mn"
	symbol = "Mn"
	purchaseable = TRUE
	base_value = 0.12
	breathed_product = /datum/reagent/memetic_neutralizer

/datum/reagent/memetic_neutralizer
	name = "Memetic Neutralizer"
	description = "An inert gas that interferes with memetic signals in the brain, providing temporary resistance to cognitohazards."
	reagent_state = GAS
	color = "#d8bfd8"
	metabolization_rate = 0.3 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_NO_RANDOM_RECIPE
	taste_description = "static"

/datum/reagent/memetic_neutralizer/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	if(!istype(M))
		return
	M.hallucination = max(0, M.hallucination - 20)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(5, "memetic_neutralizer")

/obj/machinery/portable_atmospherics/canister/decontamination
	name = "decontamination gas canister"
	desc = "A canister of specialized gas for neutralizing anomalous biological contamination. Use with ventilation systems to purge SCP zones."
	gas_type = GAS_DECONTAM
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#e8e8d0#b0e0e6"

/obj/machinery/portable_atmospherics/canister/memetic_neutralizer
	name = "memetic neutralizer canister"
	desc = "A canister of inert gas that disrupts memetic signals. Deploy in areas affected by cognitohazards."
	gas_type = GAS_MEMETIC_NEUTRAL
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#d8bfd8#4a0080"

/datum/chemical_reaction/drink/foundation_spring
	results = list(/datum/reagent/consumable/ethanol/foundation_spring = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/vodka = 2,
		/datum/reagent/consumable/lemonjuice = 1,
		/datum/reagent/water = 1,
	)
	mix_message = "The mixture clarifies into a crisp, refreshing drink."

/datum/reagent/consumable/ethanol/foundation_spring
	name = "Foundation Spring"
	description = "A crisp, clean cocktail popular among Foundation personnel. The lemon and vodka combination is said to 'clear the mind.'"
	color = "#e8e8d0"
	boozepwr = 15
	quality = DRINK_GOOD
	taste_description = "crisp lemon and clean vodka"
	glass_icon_state = "ginandtonic"
	glass_name = "Foundation Spring"
	glass_desc = "A Foundation standard. Clean, crisp, and deceptively strong."

/datum/reagent/consumable/ethanol/foundation_spring/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(3, "foundation_spring")
	M.hallucination = max(0, M.hallucination - 5)

/datum/chemical_reaction/drink/class_cognitohazard
	results = list(/datum/reagent/consumable/ethanol/class_cognitohazard = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/absinthe = 2,
		/datum/reagent/consumable/bluecherryjelly = 1,
		/datum/reagent/consumable/ethanol/creme_de_menthe = 1,
	)
	mix_message = "The mixture swirls with an unsettling iridescence."

/datum/reagent/consumable/ethanol/class_cognitohazard
	name = "Class Cognitohazard"
	description = "A swirling, iridescent cocktail that seems to shift when you're not looking directly at it. Named by the Foundation bartender who invented it."
	color = "#4a0080"
	boozepwr = 40
	quality = DRINK_VERYGOOD
	taste_description = "shifting colors and forbidden knowledge"
	glass_icon_state = "whiskeycoladouble"
	glass_name = "Class Cognitohazard"
	glass_desc = "A swirling, iridescent drink. Looking at it too long gives you a headache."

/datum/reagent/consumable/ethanol/class_cognitohazard/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	M.hallucination += 5
	if(prob(10))
		to_chat(M, span_notice("For a moment, you could swear the glass was watching you."))
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(-3, "class_cognitohazard")

/datum/chemical_reaction/drink/containment_breach
	results = list(/datum/reagent/consumable/ethanol/containment_breach = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/rum = 2,
		/datum/reagent/consumable/ethanol/whiskey = 1,
		/datum/reagent/consumable/capsaicin = 1,
	)
	mix_message = "The mixture ignites briefly before settling into a dangerous-looking drink."

/datum/reagent/consumable/ethanol/containment_breach
	name = "Containment Breach"
	description = "An alarmingly strong drink that burns going down and coming back up. Popular with security personnel after a long shift."
	color = "#ff4500"
	boozepwr = 60
	quality = DRINK_NICE
	taste_description = "burning containment failure"
	glass_icon_state = "manhattan"
	glass_name = "Containment Breach"
	glass_desc = "A drink that looks like it could breach containment on its own. Handle with care."

/datum/chemical_reaction/drink/amnestics_kiss
	results = list(/datum/reagent/consumable/ethanol/amnestics_kiss = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/gin = 2,
		/datum/reagent/consumable/ethanol/vermouth = 1,
		/datum/reagent/consumable/lemonjuice = 1,
	)
	mix_message = "The mixture settles into a forgettably plain drink."

/datum/reagent/consumable/ethanol/amnestics_kiss
	name = "Amnestic's Kiss"
	description = "A deceptively simple martini variant. Those who drink it report feeling like they've forgotten something important."
	color = "#c0c0c0"
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "something you can't quite remember"
	glass_icon_state = "martini"
	glass_name = "Amnestic's Kiss"
	glass_desc = "A simple, elegant drink. You feel like you've had this before, but you can't remember when."

/datum/reagent/consumable/ethanol/amnestics_kiss/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	M.hallucination = max(0, M.hallucination - 15)
	if(prob(5))
		var/list/forgotten = list("what you were just thinking about", "why you came to the bar", "someone's name", "what day it is")
		to_chat(M, span_notice("You briefly forget [pick(forgotten)]."))
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(2, "amnestics_kiss")

/datum/chemical_reaction/drink/telekill_old_fashioned
	results = list(/datum/reagent/consumable/ethanol/telekill_old_fashioned = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/whiskey = 3,
		/datum/reagent/consumable/ethanol/creme_de_cacao = 1,
		/datum/reagent/medicine/amnestics/classa = 1,
	)
	mix_message = "The mixture takes on a metallic sheen."

/datum/reagent/consumable/ethanol/telekill_old_fashioned
	name = "Telekill Old Fashioned"
	description = "A robust cocktail with a metallic finish, named after the Foundation's cognitohazard-resistant alloy. Said to 'steel the mind.'"
	color = "#8b7355"
	boozepwr = 35
	quality = DRINK_FANTASTIC
	taste_description = "oak, metal, and resolve"
	glass_icon_state = "oldfashioned"
	glass_name = "Telekill Old Fashioned"
	glass_desc = "A strong, metallic drink that makes you feel like your thoughts are your own."

/datum/reagent/consumable/ethanol/telekill_old_fashioned/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	M.hallucination = max(0, M.hallucination - 30)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.sanity)
			H.sanity.adjust_sanity(8, "telekill_old_fashioned")
	if(prob(15))
		to_chat(M, span_notice("Your thoughts feel clearer, more protected."))

/obj/item/paper/foundation/bar_menu
	name = "Foundation Bar Menu"
	desc = "A stylish menu listing the Foundation's signature cocktails."

/obj/item/paper/foundation/bar_menu/Initialize(mapload)
	. = ..()
	setText({"<h2>FOUNDATION BAR - SIGNATURE COCKTAILS</h2><hr>
<b>Foundation Spring</b> - 15 cr<br>
<i>Vodka, lemon, sparkling water. Crisp and clean. Clears the mind.</i><br><hr>
<b>Class Cognitohazard</b> - 25 cr<br>
<i>Absinthe, blue cherry, creme de menthe. Swirling. Unsettling. Watch your thoughts.</i><br><hr>
<b>Containment Breach</b> - 30 cr<br>
<i>Rum, whiskey, capsaicin. Burns going down and coming up. Security favorite.</i><br><hr>
<b>Amnestic's Kiss</b> - 20 cr<br>
<i>Gin, vermouth, lemon. Forgettably elegant. You will not remember this drink.</i><br><hr>
<b>Telekill Old Fashioned</b> - 40 cr<br>
<i>Whiskey, creme de cacao, Class-A amnestics. Metallic. Resolute. Shields the mind.</i><br><hr>
<br><i>WARNING: Foundation cocktails may have anomalous effects. Drink responsibly. The Foundation is not liable for memory loss, hallucinations, or existential uncertainty.</i><br>"}, FALSE)
