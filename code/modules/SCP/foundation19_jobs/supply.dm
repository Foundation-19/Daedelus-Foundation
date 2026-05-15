// Foundation-19 Supply Jobs

/datum/job/quartermaster
	title = "Quartermaster"
	description = "Manage site supplies and logistics. Coordinate with other departments for resource needs. Maintain inventory and distribution systems."
	department_head = list(JOB_SITE_DIRECTOR)
	head_announce = list("Supply")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Site Director"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/quartermaster))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/quartermaster
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/logistics_officer
	uniform = /obj/item/clothing/under/rank/cargo/quartermaster
	belt = /obj/item/modular_computer/tablet/pda/quartermaster
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

/datum/job/cargo_technician
	title = "Cargo Technician"
	description = "Handle cargo shipments and deliveries. Process supply requests from departments. Maintain cargo bay operations."
	department_head = list(JOB_QUARTERMASTER)
	head_announce = list("Supply")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/cargo_technician))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/cargo_technician
	name = "Cargo Technician"
	jobtype = /datum/job/cargo_technician
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/cargo_technician
	uniform = /obj/item/clothing/under/rank/cargo/tech
	belt = /obj/item/modular_computer/tablet/pda/cargo
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/sneakers/black
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

/datum/job/shaft_miner
	title = "Shaft Miner"
	description = "Extract resources from mining operations. Supply materials for construction and research. Maintain mining equipment and safety protocols."
	department_head = list(JOB_QUARTERMASTER)
	head_announce = list("Supply")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/shaft_miner))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/shaft_miner
	name = "Shaft Miner"
	jobtype = /datum/job/shaft_miner
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/shaft_miner
	uniform = /obj/item/clothing/under/rank/cargo/miner
	suit = /obj/item/clothing/suit/hooded/wintercoat/miner
	belt = /obj/item/modular_computer/tablet/pda/shaftminer
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/black
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

/datum/job/logistics_officer
	title = "Logistics Officer"
	description = "Coordinate supply chains and resource distribution. Plan and execute logistics operations. Ensure efficient resource allocation."
	department_head = list(JOB_QUARTERMASTER)
	head_announce = list("Supply")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/logistics_officer))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/logistics_officer
	name = "Logistics Officer"
	jobtype = /datum/job/logistics_officer
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/logistics_officer
	uniform = /obj/item/clothing/under/rank/cargo/quartermaster
	belt = /obj/item/modular_computer/tablet/pda/quartermaster
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/laceup
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

/datum/job/supply_specialist
	title = "Supply Specialist"
	description = "Handle specialized supply requests and equipment. Manage hazardous materials and SCP-related supplies. Ensure proper handling protocols."
	department_head = list(JOB_QUARTERMASTER)
	head_announce = list("Supply")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Quartermaster"
	selection_color = "#d7b088"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SUPPLY
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/supply_specialist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/supply_specialist
	name = "Supply Specialist"
	jobtype = /datum/job/supply_specialist
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/logistics_technician
	uniform = /obj/item/clothing/under/rank/cargo/tech
	belt = /obj/item/modular_computer/tablet/pda/cargo
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
