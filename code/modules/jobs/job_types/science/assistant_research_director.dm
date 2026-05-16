/datum/job/assistant_research_director
	title = JOB_ASSISTANT_RESEARCH_DIRECTOR
	description = "Research new technology, create explosives, experiment with strange objects, or synthesize dangerous chemicals."
	department_head = list(JOB_MEDICAL_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Research Director"
	selection_color = "#281E2D"
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/assistant_research_director,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/science,
		)

	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom)

	mail_goodies = list()
	rpg_title = "Corpse Runner"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/assistant_research_director
	name = "Assistant Research Director"
	jobtype = /datum/job/assistant_research_director

	id = /obj/item/card/id/advanced/black_blank
	id_trim = /datum/id_trim/job/assistant_research_director
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat
	suit_store = /obj/item/flashlight/pen
	backpack_contents = list(
		/obj/item/roller = 1,
		/obj/item/bodybag/stasis = 1,
	)
	belt = /obj/item/storage/belt/medical/paramedic
	ears = /obj/item/radio/headset/headset_med
	head = /obj/item/clothing/head/soft/paramedic
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/modular_computer/tablet/pda/science

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
	pda_slot = ITEM_SLOT_LPOCKET
