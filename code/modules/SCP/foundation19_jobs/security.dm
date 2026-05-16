// Foundation-19 Security Jobs
// These are the security and containment personnel

/datum/job/lcz_zone_commander
	title = "LCZ Zone Junior Lieutenant"
	description = "Manage Light Containment Zone security operations. Oversee LCZ guards and containment protocols. Coordinate with research staff for SCP testing."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Guard Commander"
	selection_color = "#8e2929"
	minimal_player_age = 10
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/lcz_zone_commander,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "LCZ Commander"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/lcz_zone_commander
	name = "LCZ Zone Junior Lieutenant"
	jobtype = /datum/job/lcz_zone_commander

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/head_of_security
	uniform = /obj/item/clothing/under/scp/hos/lcz
	suit = /obj/item/clothing/suit/armor/vest/scp/lczcomm
	suit_store = /obj/item/gun/energy/e_gun/advtaser
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/heads/hos
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/security/lczcom
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
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

/datum/job/hcz_zone_commander
	title = "HCZ Zone Senior Lieutenant"
	description = "Manage Heavy Containment Zone security operations. Oversee HCZ guards and high-security containment protocols. Coordinate with MTF for breach responses."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Guard Commander"
	selection_color = "#8e2929"
	minimal_player_age = 10
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/hcz_zone_commander,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "HCZ Commander"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/hcz_zone_commander
	name = "HCZ Zone Senior Lieutenant"
	jobtype = /datum/job/hcz_zone_commander

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/head_of_security
	uniform = /obj/item/clothing/under/scp/hos/hcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/e_gun/advtaser
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/heads/hos
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
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

/datum/job/ez_zone_commander
	title = "EZ Zone Supervisor"
	description = "Manage Entrance Zone security operations. Oversee EZ guards and visitor protocols. Coordinate with other departments for access control."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Guard Commander"
	selection_color = "#8e2929"
	minimal_player_age = 10
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/ez_zone_commander,
		),
	)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "EZ Commander"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/ez_zone_commander
	name = "EZ Zone Supervisor"
	jobtype = /datum/job/ez_zone_commander

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/head_of_security
	uniform = /obj/item/clothing/under/scp/hos/ez
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/e_gun/advtaser
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/heads/hos
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
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

/datum/job/lcz_guard
	title = "LCZ Guard"
	description = "Maintain security in Light Containment Zone. Patrol assigned areas and respond to containment breaches. Assist researchers with SCP testing."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_LCZ_ZONE_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the LCZ Zone Commander"
	selection_color = "#8e2929"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/lcz_guard,
		),
	)

	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/lcz_guard
	name = "LCZ Guard"
	jobtype = /datum/job/lcz_guard

	id_trim = /datum/id_trim/job/security_officer
	uniform = /obj/item/clothing/under/scp/security/lcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/security
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/gun/energy/disabler,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/job/hcz_guard
	title = "HCZ Guard"
	description = "Maintain security in Heavy Containment Zone. Patrol high-security areas and respond to containment breaches. Coordinate with MTF for emergency responses."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HCZ_ZONE_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the HCZ Zone Commander"
	selection_color = "#8e2929"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/hcz_guard,
		),
	)

	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/hcz_guard
	name = "HCZ Guard"
	jobtype = /datum/job/hcz_guard

	id_trim = /datum/id_trim/job/security_officer
	uniform = /obj/item/clothing/under/scp/security/hcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/gun/energy/disabler,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/job/ez_guard
	title = "EZ Guard"
	description = "Maintain security in Entrance Zone. Patrol visitor areas and control access to the facility. Assist with visitor protocols and security checks."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_EZ_ZONE_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the EZ Zone Commander"
	selection_color = "#8e2929"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/ez_guard,
		),
	)

	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "Guard"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/ez_guard
	name = "EZ Guard"
	jobtype = /datum/job/ez_guard

	id_trim = /datum/id_trim/job/security_officer
	uniform = /obj/item/clothing/under/scp/security/ez
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	mask = /obj/item/clothing/mask/balaclava
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/gun/energy/disabler,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/job/mtf_commander
	title = "MTF Commander"
	description = "Command Mobile Task Force operations. Lead specialized containment and response teams. Coordinate with security for emergency situations."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_GUARD_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Guard Commander"
	selection_color = "#8e2929"
	minimal_player_age = 15
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/mtf_commander,
		),
	)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "MTF Commander"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/mtf_commander
	name = "MTF Commander"
	jobtype = /datum/job/mtf_commander

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/head_of_security
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/e_gun/advtaser
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/heads/hos
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
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

/datum/job/mtf_operative
	title = "MTF Operative"
	description = "Execute Mobile Task Force operations. Respond to containment breaches and emergency situations. Provide specialized security support."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_MTF_COMMANDER)
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the MTF Commander"
	selection_color = "#8e2929"
	minimal_player_age = 10
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/foundation_security,
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/mtf_operative,
		),
	)

	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DONUT_LOVER)
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "MTF Operative"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/mtf_operative
	name = "MTF Operative"
	jobtype = /datum/job/mtf_operative

	id_trim = /datum/id_trim/job/security_officer
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/storage/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/security
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/scp/hczsecurityguard
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/gun/energy/disabler,
		)
	implants = list(/obj/item/implant/mindshield)
