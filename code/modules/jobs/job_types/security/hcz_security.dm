/datum/job/junior_hcz_guard
	title = JOB_JUNIOR_HCZ_GUARD
	description = "Patrol HCZ containment corridors under supervision. Monitor Keter-level \
		SCP containment, report containment integrity changes, and assist with recontainment \
		operations. Learn HCZ-specific protocols from senior guards."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the HCZ Zone Senior Lieutenant"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/junior_hcz_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/junior_hcz_guard
	name = "HCZ Private"
	jobtype = /datum/job/junior_hcz_guard
	id_trim = /datum/id_trim/job/junior_hcz_guard
	uniform = /obj/item/clothing/under/scp/security/hcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/foundation_guard
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(/obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/head/helmet, /obj/item/gun/energy/disabler)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/junior_hcz_guard/mod
	name = "HCZ Private (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// HCZ Guard

/datum/job/hcz_guard
	title = JOB_HCZ_GUARD
	description = "Maintain Keter SCP containment security. Operate the HCZ gas system, \
		respond to containment breaches, run recontainment protocols from the Recontainment \
		Terminal, and coordinate with MTF during major breaches."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the HCZ Zone Senior Lieutenant"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/hcz_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/hcz_guard
	name = "HCZ Guard"
	jobtype = /datum/job/hcz_guard
	id_trim = /datum/id_trim/job/hcz_guard
	uniform = /obj/item/clothing/under/scp/security/hcz
	suit = /obj/item/clothing/suit/armor/vest/scp/lczcomm
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/foundation_guard
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(/obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/head/helmet, /obj/item/gun/energy/disabler)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/hcz_guard/mod
	name = "HCZ Guard (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// HCZ Sergeant

/datum/job/senior_hcz_guard
	title = JOB_SENIOR_HCZ_GUARD
	description = "Lead HCZ guard squads and coordinate recontainment operations. Train \
		privates, manage containment breach responses, operate the HCZ gas system, and \
		authorize lethal force during Keter-level breaches."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the HCZ Zone Senior Lieutenant"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/senior_hcz_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/senior_hcz_guard
	name = "HCZ Sergeant"
	jobtype = /datum/job/senior_hcz_guard
	id_trim = /datum/id_trim/job/senior_hcz_guard
	uniform = /obj/item/clothing/under/scp/warden/hcz
	suit = /obj/item/clothing/suit/armor/vest/scp/lczcomm
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/foundation_guard
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(/obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/head/helmet, /obj/item/gun/energy/disabler)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/senior_hcz_guard/mod
	name = "HCZ Sergeant (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// HCZ Zone Senior Lieutenant

/datum/job/hcz_commander
	title = JOB_HCZ_ZONE_SENIOR_LIEUTENANT
	description = "Command all HCZ security operations. Authorize recontainment protocols, \
		coordinate MTF deployments, manage the HCZ patrol and gas consoles, and liaise \
		with the Guard Commander on Keter-level threats."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the Guard Commander"
	selection_color = "#FF0000"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/hcz_commander))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/hcz_commander
	name = "HCZ Zone Senior Lieutenant"
	jobtype = /datum/job/hcz_commander
	id_trim = /datum/id_trim/job/hcz_commander
	uniform = /obj/item/clothing/under/scp/hos/hcz
	suit = /obj/item/clothing/suit/armor/vest/scp/lczcomm
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/foundation_guard
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(/obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/head/helmet, /obj/item/gun/energy/disabler)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/hcz_commander/mod
	name = "HCZ Zone Senior Lieutenant (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null