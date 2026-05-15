// Foundation-19 Engineering Jobs

/datum/job/senior_engineer
	title = "Senior Engineer"
	description = "Lead engineering projects and maintenance operations. Design containment systems for SCPs. Mentor junior engineers."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 10
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/senior_engineer))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/senior_engineer
	name = "Senior Engineer"
	jobtype = /datum/job/senior_engineer
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/senior_engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	suit = /obj/item/clothing/suit/hazardvest
	belt = /obj/item/modular_computer/tablet/pda/engineering
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	head = /obj/item/clothing/head/hardhat/white
	glasses = /obj/item/clothing/glasses/meson/engine
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

/datum/job/engineer
	title = "Engineer"
	description = "Maintain site infrastructure and systems. Repair equipment and machinery. Ensure proper functioning of containment facilities."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/engineer))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/engineer
	name = "Engineer"
	jobtype = /datum/job/engineer
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	suit = /obj/item/clothing/suit/hazardvest
	belt = /obj/item/modular_computer/tablet/pda/engineering
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	head = /obj/item/clothing/head/hardhat
	glasses = /obj/item/clothing/glasses/meson/engine
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

/datum/job/junior_engineer
	title = "Junior Engineer"
	description = "Learn engineering procedures under supervision. Assist senior engineers with maintenance tasks. Gain experience in Foundation engineering protocols."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/junior_engineer))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS|JOB_CAN_BE_INTERN

/datum/outfit/job/junior_engineer
	name = "Junior Engineer"
	jobtype = /datum/job/junior_engineer
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/junior_engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	belt = /obj/item/modular_computer/tablet/pda/engineering
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	head = /obj/item/clothing/head/hardhat
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

/datum/job/atmospheric_technician
	title = "Atmospheric Technician"
	description = "Maintain atmospheric systems and environmental controls. Monitor air quality and pressure. Ensure proper ventilation in containment areas."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/atmospheric_technician))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/atmospheric_technician
	name = "Atmospheric Technician"
	jobtype = /datum/job/atmospheric_technician
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/atmospheric_technician
	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	belt = /obj/item/modular_computer/tablet/pda/atmos
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

/datum/job/containment_engineer
	title = "Containment Engineer"
	description = "Design and maintain SCP containment systems. Develop specialized containment protocols. Ensure structural integrity of containment facilities."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 10
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/containment_engineer))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/containment_engineer
	name = "Containment Engineer"
	jobtype = /datum/job/containment_engineer
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/containment_engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	suit = /obj/item/clothing/suit/hazardvest
	belt = /obj/item/modular_computer/tablet/pda/engineering
	ears = /obj/item/radio/headset/scp_containment
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	head = /obj/item/clothing/head/hardhat/white
	glasses = /obj/item/clothing/glasses/meson/engine
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

/datum/job/electrical_engineer
	title = "Electrical Engineer"
	description = "Maintain electrical systems and power distribution. Design electrical containment systems. Ensure reliable power supply to all facilities."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/electrical_engineer))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/electrical_engineer
	name = "Electrical Engineer"
	jobtype = /datum/job/electrical_engineer
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	suit = /obj/item/clothing/suit/hazardvest
	belt = /obj/item/modular_computer/tablet/pda/engineering
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	glasses = /obj/item/clothing/glasses/meson/engine
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

/datum/job/communications_technician
	title = "Communications Technician"
	description = "Maintain communication systems and networks. Ensure secure communications between departments. Monitor and repair communication equipment."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/communications_technician))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/communications_technician
	name = "Communications Technician"
	jobtype = /datum/job/communications_technician
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/it_technician
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	belt = /obj/item/modular_computer/tablet/pda/engineering
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

/datum/job/maintenance_technician
	title = "Maintenance Technician"
	description = "Perform routine maintenance and repairs. Keep facilities in working order. Respond to equipment failures and emergencies."
	department_head = list(JOB_CHIEF_ENGINEER)
	head_announce = list("Engineering")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Engineer"
	selection_color = "#ffa500"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_ENGINEERING
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_ENG
	liver_traits = list(TRAIT_ENGINEER_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/maintenance_technician))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/maintenance_technician
	name = "Maintenance Technician"
	jobtype = /datum/job/maintenance_technician
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/junior_engineer
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	suit = /obj/item/clothing/suit/hazardvest
	belt = /obj/item/modular_computer/tablet/pda/engineering
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/yellow
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer
