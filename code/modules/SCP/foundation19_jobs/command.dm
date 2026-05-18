// Foundation-19 Command Jobs
// These are the command and administrative positions

/datum/job/site_director
	title = "Site Director"
	description = "Oversee all site operations. Ensure containment protocols are followed. Coordinate with O5 Council. Manage site personnel and resources."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the O5 Council"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 20
	exp_requirements = 0
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_class_a
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/site_director,
		),
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	departments_list = list(
		/datum/job_department/command,
		/datum/job_department/company_leader
	)

	family_heirlooms = list(/obj/item/reagent_containers/food/drinks/flask/gold, /obj/item/toy/captainsaid/collector)

	mail_goodies = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 10,
		/obj/item/toy/captainsaid/collector = 20
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "Site Director"

	voice_of_god_power = 1.4

/datum/outfit/job/site_director
	name = "Site Director"
	jobtype = /datum/job/site_director
	allow_jumpskirt = FALSE

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/captain
	uniform = /obj/item/clothing/under/scp/suittie
	suit = /obj/item/clothing/suit/armor/director_coat
	backpack_contents = list(
		/obj/item/assembly/flash/handheld = 1
	)
	belt = /obj/item/modular_computer/tablet/pda/captain
	ears = /obj/item/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/laceup

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain

	chameleon_extras = list(
		/obj/item/gun/energy/e_gun,
		/obj/item/stamp/sid,
		)
	implants = list(/obj/item/implant/mindshield)
	skillchips = list(/obj/item/skillchip/disk_verifier)

/datum/job/o5_representative
	title = "O5 Representative"
	description = "Represent the O5 Council on site. Ensure compliance with O5 directives. Monitor site operations and report to the Council."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the O5 Council"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 20
	exp_requirements = 0
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_class_a
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/o5_representative,
		),
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	departments_list = list(
		/datum/job_department/command,
		/datum/job_department/company_leader
	)

	family_heirlooms = list(/obj/item/reagent_containers/food/drinks/flask/gold)

	mail_goodies = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 10
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "O5 Representative"

	voice_of_god_power = 1.4

/datum/outfit/job/o5_representative
	name = "O5 Representative"
	jobtype = /datum/job/o5_representative
	allow_jumpskirt = FALSE

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/captain
	uniform = /obj/item/clothing/under/suit/charcoal
	backpack_contents = list(
		/obj/item/assembly/flash/handheld = 1
	)
	belt = /obj/item/modular_computer/tablet/pda/captain
	ears = /obj/item/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/laceup

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain

	chameleon_extras = list(
		/obj/item/gun/energy/e_gun,
		/obj/item/stamp/sid,
		)
	implants = list(/obj/item/implant/mindshield)
	skillchips = list(/obj/item/skillchip/disk_verifier)

/datum/job/guard_commander
	title = "Guard Commander"
	description = "Command all security personnel across all zones. Coordinate security operations and containment protocols. Ensure site security."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/guard_commander,
		),
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/command,
		/datum/job_department/security
	)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "Guard Commander"

	voice_of_god_power = 1.2

/datum/outfit/job/guard_commander
	name = "Guard Commander"
	jobtype = /datum/job/guard_commander

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/head_of_security
	uniform = /obj/item/clothing/under/scp/hos/guardcom
	suit = /obj/item/clothing/suit/scp/hos/coat
	suit_store = /obj/item/gun/energy/e_gun/advtaser
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/heads/hos
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/beret/sec/guardcom
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/balaclava
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/gun/energy/e_gun/advtaser,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/job/research_director
	title = "Research Director"
	description = "Oversee all research operations and SCP studies. Coordinate with researchers and ensure proper containment protocols."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_science
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/research_director,
		),
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	departments_list = list(
		/datum/job_department/command
	)

	family_heirlooms = list(/obj/item/book/manual/wiki/research_and_development, /obj/item/clothing/head/beret/science)

	mail_goodies = list(
		/obj/item/reagent_containers/glass/beaker/large = 20,
		/obj/item/reagent_containers/glass/beaker/large = 15,
		/obj/item/reagent_containers/glass/beaker/meta = 10,
		/obj/item/reagent_containers/glass/beaker/noreact = 5
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "Research Director"

	voice_of_god_power = 1.2

/datum/outfit/job/research_director
	name = "Research Director"
	jobtype = /datum/job/research_director

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/research_director
	uniform = /obj/item/clothing/under/rank/rnd/research_director
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/heads/rd
	ears = /obj/item/radio/headset/headset_eng
	glasses = /obj/item/clothing/glasses/hud/diagnostic
	shoes = /obj/item/clothing/shoes/laceup

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/diagnostic,
		/obj/item/clothing/head/beret/science,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/job/chief_medical_officer
	title = "Chief Medical Officer"
	description = "Oversee all medical operations and personnel. Ensure proper medical care and coordinate with other departments."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_medical
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/chief_medical_officer,
		),
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	departments_list = list(
		/datum/job_department/command,
		/datum/job_department/medical
	)

	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom)

	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 20,
		/obj/item/reagent_containers/hypospray/medipen/dermaline = 10,
		/obj/item/reagent_containers/hypospray/medipen/meralyne = 10,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 10,
		/obj/item/reagent_containers/hypospray/medipen/dylovene = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival/luxury = 5
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "Chief Medical Officer"

	voice_of_god_power = 1.2

/datum/outfit/job/chief_medical_officer
	name = "Chief Medical Officer"
	jobtype = /datum/job/chief_medical_officer

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/chief_medical_officer
	uniform = /obj/item/clothing/under/rank/medical/chief_medical_officer
	suit = /obj/item/clothing/suit/toggle/labcoat/cmo
	belt = /obj/item/modular_computer/tablet/pda/heads/cmo
	ears = /obj/item/radio/headset/heads/cmo
	glasses = /obj/item/clothing/glasses/hud/health
	shoes = /obj/item/clothing/shoes/laceup

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/head/beret/medical,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/job/chief_engineer
	title = "Chief Engineer"
	description = "Oversee all engineering operations and maintenance. Ensure proper functioning of site infrastructure and containment systems."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	minimal_player_age = 15
	exp_requirements = 0
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_engineering
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/chief_engineer,
		),
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_GOV

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	departments_list = list(
		/datum/job_department/command,
		/datum/job_department/engineering
	)

	family_heirlooms = list(/obj/item/book/manual/wiki/engineering_guide, /obj/item/clothing/head/beret/engi)

	mail_goodies = list(
		/obj/item/stack/sheet/mineral/diamond = 10,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/stack/sheet/mineral/gold = 10,
		/obj/item/stack/sheet/mineral/silver = 10
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "Chief Engineer"

	voice_of_god_power = 1.2

/datum/outfit/job/chief_engineer
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/chief_engineer
	uniform = /obj/item/clothing/under/rank/engineering/chief_engineer
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/hardhat/white
	belt = /obj/item/modular_computer/tablet/pda/heads/ce
	ears = /obj/item/radio/headset/heads/ce
	glasses = /obj/item/clothing/glasses/meson/engine
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

	box = /obj/item/storage/box/survival/engineer
	chameleon_extras = list(
		/obj/item/clothing/glasses/meson/engine,
		/obj/item/clothing/head/beret/engi,
		)
	implants = list(/obj/item/implant/mindshield)
