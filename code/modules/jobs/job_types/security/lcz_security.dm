/datum/job/junior_lcz_guard
	title = JOB_JUNIOR_LCZ_GUARD
	description = "Ensure the security of Euclid anomalies in the LCZ, alongside maintaining the CDZ, and the Class D population. "
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the LCZ Zone Junior Lieutenant"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/junior_lcz_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/junior_lcz_guard
	name = "LCZ Cadet"
	jobtype = /datum/job/junior_lcz_guard
	id_trim = /datum/id_trim/job/junior_lcz_guard
	uniform = /obj/item/clothing/under/scp/security/lcz/cadet
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/cadet
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(/obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/head/helmet, /obj/item/gun/energy/disabler)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/junior_lcz_guard/mod
	name = "LCZ Cadet (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// LCZ Guard

/datum/job/lcz_guard
	title = JOB_LCZ_GUARD
	description = "Ensure the security of Euclid anomalies in the LCZ, alongside maintaining the CDZ, and the Class D population. "
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the LCZ Zone Junior Lieutenant"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/lcz_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/lcz_guard
	name = "LCZ Guard"
	jobtype = /datum/job/lcz_guard
	id_trim = /datum/id_trim/job/lcz_guard
	uniform = /obj/item/clothing/under/scp/security/lcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/security
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

/datum/outfit/job/lcz_guard/mod
	name = "LCZ Guard (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// LCZ Sergeant

/datum/job/senior_lcz_guard
	title = JOB_SENIOR_LCZ_GUARD
	description = "Ensure the security of Euclid anomalies in the LCZ, alongside maintaining the CDZ, and the Class D population. "
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the LCZ Zone Junior Lieutenant"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/senior_lcz_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/senior_lcz_guard
	name = "LCZ Sergeant"
	jobtype = /datum/job/senior_lcz_guard
	id_trim = /datum/id_trim/job/senior_lcz_guard
	uniform = /obj/item/clothing/under/scp/warden/lcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/security
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

/datum/outfit/job/senior_lcz_guard/mod
	name = "LCZ Sergeant (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// LCZ Zone Junior Lieutenant

/datum/job/lcz_commander
	title = JOB_LCZ_ZONE_JUNIOR_LIEUTENANT
	description = "Ensure the security of Euclid anomalies in the LCZ, alongside maintaining the CDZ, and the Class D population. "
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
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/lcz_commander))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/telescopic = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/lcz_commander
	name = "LCZ Zone Junior Lieutenant"
	jobtype = /datum/job/lcz_commander
	id_trim = /datum/id_trim/job/lcz_commander
	uniform = /obj/item/clothing/under/scp/hos/lcz
	suit = /obj/item/clothing/suit/armor/vest/scp/lczcomm
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/security/lczcom
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

/datum/outfit/job/lcz_commander/mod
	name = "LCZ Zone Junior Lieutenant (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null