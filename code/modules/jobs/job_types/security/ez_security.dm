/datum/job/junior_ez_guard
	title = JOB_JUNIOR_EZ_GUARD
	description = "Oversee EZ security, protect members of Command, assist the Containment Areas when required."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the EZ Zone Supervisor"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/junior_ez_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/junior_ez_guard
	name = "EZ Probationary Agent"
	jobtype = /datum/job/junior_ez_guard
	id_trim = /datum/id_trim/job/junior_ez_guard
	uniform = /obj/item/clothing/under/scp/security/ez
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/cadet
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/helmet/scp/security/cadet/hat
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

/datum/outfit/job/junior_ez_guard/mod
	name = "EZ Probationary Agent (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// EZ Agent

/datum/job/ez_guard
	title = JOB_EZ_GUARD
	description = "Oversee EZ security, protect members of Command, assist the Containment Areas when required."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the EZ Zone Supervisor"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/ez_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/ez_guard
	name = "EZ Agent"
	jobtype = /datum/job/ez_guard
	id_trim = /datum/id_trim/job/ez_guard
	uniform = /obj/item/clothing/under/scp/security/ez
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
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

/datum/outfit/job/ez_guard/mod
	name = "EZ Agent (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// EZ Senior Agent

/datum/job/senior_ez_guard
	title = JOB_SENIOR_EZ_GUARD
	description = "Oversee EZ security, protect members of Command, assist the Containment Areas when required."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "the EZ Zone Supervisor"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	employers = list(/datum/employer/scp)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/senior_ez_guard))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/senior_ez_guard
	name = "EZ Senior Agent"
	jobtype = /datum/job/senior_ez_guard
	id_trim = /datum/id_trim/job/senior_ez_guard
	uniform = /obj/item/clothing/under/scp/warden/ez
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
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

/datum/outfit/job/senior_ez_guard/mod
	name = "EZ Senior Agent (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null

// EZ Zone Supervisor

/datum/job/ez_commander
	title = JOB_EZ_ZONE_SUPERVISOR
	description = "Oversee EZ security, protect members of Command, assist the Containment Areas when required."
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
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/ez_commander))
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)
	departments_list = list(/datum/job_department/security)
	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
	mail_goodies = list(/obj/item/food/donut/caramel = 10, /obj/item/food/donut/matcha = 10, /obj/item/food/donut/blumpkin = 5, /obj/item/clothing/mask/whistle = 5, /obj/item/melee/baton/security/boomerang/loaded = 1)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/ez_commander
	name = "EZ Zone Supervisor"
	jobtype = /datum/job/ez_commander
	id_trim = /datum/id_trim/job/ez_commander
	uniform = /obj/item/clothing/under/scp/hos/ez
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(/obj/item/storage/evidencebag = 1)
	belt = /obj/item/modular_computer/tablet/pda/security
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

/datum/outfit/job/ez_commander/mod
	name = "EZ Zone Supervisor (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = null
	box = null