/datum/job/research_associate
	title = "Research Associate"
	description = "Assist researchers with SCP testing, manage specimen collection kits, \
		and handle sample delivery between containment chambers and the research lab. \
		Work the SCP Testing Console and deliver research data to senior staff."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Research Director and Senior Researchers"
	selection_color = "#281E2D"
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/research_associate,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
	)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
	)
	rpg_title = "Research Acolyte"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/research_associate
	name = "Research Associate"
	jobtype = /datum/job/research_associate

	id_trim = /datum/id_trim/job/research_associate
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	backpack_contents = list(
		/obj/item/scp_specimen_kit = 1,
	)
	belt = /obj/item/modular_computer/tablet/pda/foundation_science
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_BELT

/datum/job/lab_technician
	title = "Lab Technician"
	description = "Maintain laboratory equipment, prepare chemical samples for SCP testing, \
		and ensure research stations are supplied and operational. Repair broken analyzers, \
		calibrate SCP-914 for safe operation, and prepare containment sample kits."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Research Director"
	selection_color = "#281E2D"
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/lab_technician,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
	)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
	)
	rpg_title = "Lab Keeper"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/lab_technician
	name = "Lab Technician"
	jobtype = /datum/job/lab_technician

	id_trim = /datum/id_trim/job/lab_technician
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	backpack_contents = list(
		/obj/item/scp_specimen_kit = 1,
	)
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_BELT

/datum/job/xenobiologist
	title = "Xenobiologist"
	description = "Study anomalous biological specimens and SCP organisms. Extract tissue samples, \
		analyze anomalous genetics, and document biological properties of contained SCPs. \
		Work with the Research Console to contribute xenobiology research points."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#281E2D"
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/xenobiologist,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
	)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
	)
	rpg_title = "Beast Scholar"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/xenobiologist
	name = "Xenobiologist"
	jobtype = /datum/job/xenobiologist

	id_trim = /datum/id_trim/job/xenobiologist
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	backpack_contents = list(
		/obj/item/scp_specimen_kit = 1,
		/obj/item/reagent_containers/syringe = 2,
	)
	belt = /obj/item/modular_computer/tablet/pda/foundation_science
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/latex
	glasses = /obj/item/clothing/glasses/science
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_BELT

/datum/job/roboticist
	title = "Roboticist"
	description = "Build and maintain Foundation robotics and automated containment equipment. \
		Construct cybernetic implants for injured personnel, repair borgs, and develop \
		automated containment systems to assist with SCP monitoring."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#281E2D"
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/roboticist,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
	)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
	)
	rpg_title = "Artificer"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	id_trim = /datum/id_trim/job/roboticist
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat
	backpack_contents = list(
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
	)
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/laceup

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_BELT
	skillchips = list(/obj/item/skillchip/job/roboticist)

/datum/job/chemist_science
	title = "Research Chemist"
	description = "Synthesize anomalous compounds for SCP research. Develop containment \
		chemicals, analyze SCP-produced substances, and create specialized reagents for \
		testing protocols. Work with SCP-914 to refine chemical samples."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#281E2D"
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/chemist_science,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
	)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
	)
	rpg_title = "Alchemist"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/chemist_science
	name = "Research Chemist"
	jobtype = /datum/job/chemist_science

	id_trim = /datum/id_trim/job/chemist_science
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	backpack_contents = list(
		/obj/item/reagent_containers/glass/beaker/large = 2,
	)
	belt = /obj/item/modular_computer/tablet/pda/foundation_science
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/science

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_BELT

/datum/job/archaeologist
	title = "Archaeologist"
	description = "Recover and analyze anomalous artifacts. Document artifact origins, \
		classify anomalous properties, and submit findings to the Research Console. \
		Catalogue items recovered from containment operations and SCP-914 refinement."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#281E2D"
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/archaeologist,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
	)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
	)
	rpg_title = "Relic Hunter"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/archaeologist
	name = "Archaeologist"
	jobtype = /datum/job/archaeologist

	id_trim = /datum/id_trim/job/archaeologist
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	backpack_contents = list(
		/obj/item/anomaly_scanner = 1,
	)
	belt = /obj/item/modular_computer/tablet/pda/foundation_science
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/fingerless
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_BELT

/datum/job/field_agent
	title = "Field Agent"
	description = "Conduct field research and SCP reconnaissance. Investigate reported anomalies, \
		collect evidence from uncontained SCP sightings, and report findings back to the research team. \
		Use the anomaly scanner and field kit to document and recover anomalous materials."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#281E2D"
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/field_agent,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
	)

	family_heirlooms = list(/obj/item/storage/pill_bottle)

	mail_goodies = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
	)
	rpg_title = "Field Operative"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/field_agent
	name = "Field Agent"
	jobtype = /datum/job/field_agent

	id_trim = /datum/id_trim/job/field_agent
	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/toggle/labcoat
	backpack_contents = list(
		/obj/item/anomaly_scanner = 1,
		/obj/item/scp_specimen_kit = 1,
		/obj/item/camera = 1,
	)
	belt = /obj/item/modular_computer/tablet/pda/foundation_science
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/black
	l_hand = /obj/item/clipboard

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_BELT

/obj/item/scp_specimen_kit
	name = "SCP Specimen Collection Kit"
	desc = "A kit containing vials, bags, and tools for collecting samples from contained SCPs. Use it on an SCP entity to collect a specimen."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
	w_class = WEIGHT_CLASS_NORMAL
	var/vials_remaining = 5
	var/list/collected_specimens = list()

/obj/item/scp_specimen_kit/attack_self(mob/user)
	if(!length(collected_specimens))
		to_chat(user, span_notice("The specimen collection kit has [vials_remaining] vial(s) remaining. Use it on an SCP entity to collect a specimen."))
		return
	to_chat(user, span_notice("Specimen kit: [vials_remaining] vial(s) remaining. Collected specimens:"))
	for(var/specimen in collected_specimens)
		to_chat(user, span_notice("- [specimen]"))

/obj/item/scp_specimen_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || vials_remaining <= 0)
		return
	var/specimen_name
	var/specimen_type
	var/research_value = 10
	if(istype(target, /mob/living/scp))
		var/mob/living/scp/S = target
		specimen_name = "SCP specimen: [S.name]"
		specimen_type = "scp_biological"
		research_value = 50
		if(SSscp_persistence?.manager)
			var/found_id
			for(var/id in SSscp_persistence?.manager?.scp_instances)
				var/datum/scp_instance/inst = SSscp_persistence?.manager?.scp_instances[id]
				if(inst.containment_status != "breached")
					found_id = id
					break
			if(found_id)
				specimen_name = "SCP specimen: [found_id]"
				research_value = 75
	else if(istype(target, /obj/effect/decal/cleanable))
		specimen_name = "Residue sample: [target.name]"
		specimen_type = "anomalous_residue"
		research_value = 15
	else if(istype(target, /obj/structure/flora))
		specimen_name = "Flora sample: [target.name]"
		specimen_type = "botanical"
		research_value = 20
	else if(istype(target, /obj/machinery/hydroponics))
		specimen_name = "Hydroponics sample: [target.name]"
		specimen_type = "botanical"
		research_value = 20
	else
		return
	if(specimen_name in collected_specimens)
		to_chat(user, span_warning("You already have a sample of [specimen_name]."))
		return
	vials_remaining--
	collected_specimens += specimen_name
	user.visible_message(span_notice("[user] collects a specimen sample from [target] using the collection kit."), span_notice("You collect: [specimen_name]. [vials_remaining] vial(s) remaining."))
	if(SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(research_value, "specimen_collection:[specimen_type]")
		to_chat(user, span_notice("+[research_value] research points from specimen collection."))
	if(SSraisa)
		SSraisa.record_observation(user)
