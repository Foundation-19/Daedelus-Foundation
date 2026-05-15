// Foundation-19 Science Jobs

/datum/job/senior_researcher
	title = "Senior Researcher"
	description = "Lead research projects and SCP studies. Mentor junior researchers. Coordinate with other departments for research initiatives."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 10
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/senior_researcher))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/senior_researcher
	name = "Senior Researcher"
	jobtype = /datum/job/senior_researcher
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/senior_researcher
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/latex
	glasses = /obj/item/clothing/glasses/science
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/researcher
	title = "Researcher"
	description = "Conduct SCP research and experiments. Document findings and anomalies. Work with containment protocols."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/researcher))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/researcher
	name = "Researcher"
	jobtype = /datum/job/researcher
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/researcher
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/laceup
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/research_associate
	title = "Research Associate"
	description = "Assist researchers with experiments and data collection. Maintain laboratory equipment. Learn Foundation research protocols."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/research_associate))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS|JOB_CAN_BE_INTERN

/datum/outfit/job/research_associate
	name = "Research Associate"
	jobtype = /datum/job/research_associate
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/junior_researcher
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/laceup
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/lab_technician
	title = "Lab Technician"
	description = "Maintain laboratory equipment and facilities. Prepare samples and materials for research. Ensure safety protocols are followed."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/lab_technician))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/lab_technician
	name = "Lab Technician"
	jobtype = /datum/job/lab_technician
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/junior_researcher
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/xenobiologist
	title = "Xenobiologist"
	description = "Study alien and anomalous life forms. Analyze SCP biological specimens. Develop containment procedures for living anomalies."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/xenobiologist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/xenobiologist
	name = "Xenobiologist"
	jobtype = /datum/job/xenobiologist
	id = /obj/item/card/advanced
	id_trim = /datum/id_trim/job/researcher
	uniform = /obj/item/clothing/under/rank/rnd/geneticist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/latex
	glasses = /obj/item/clothing/glasses/science
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/roboticist
	title = "Roboticist"
	description = "Design and maintain robotic systems for SCP containment. Create automated security and research equipment. Repair damaged machinery."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/roboticist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/researcher
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/latex
	glasses = /obj/item/clothing/glasses/hud/diagnostic
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/chemist_science
	title = "Research Chemist"
	description = "Analyze chemical properties of SCPs and anomalies. Develop chemical containment methods. Study anomalous substances."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/chemist_science))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/chemist_science
	name = "Research Chemist"
	jobtype = /datum/job/chemist_science
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/chemist
	uniform = /obj/item/clothing/under/rank/medical/chemist
	suit = /obj/item/clothing/suit/toggle/labcoat/chemist
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/latex
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/archaeologist
	title = "Archaeologist"
	description = "Study ancient artifacts and SCPs of historical significance. Analyze archaeological findings. Document historical anomalies."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/archaeologist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/archaeologist
	name = "Archaeologist"
	jobtype = /datum/job/archaeologist
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/researcher
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/latex
	glasses = /obj/item/clothing/glasses/regular
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/job/field_agent
	title = "Field Agent"
	description = "Conduct field research and SCP recovery operations. Investigate anomalous events. Collect data from containment sites."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	head_announce = list("Science")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Research Director"
	selection_color = "#7f61e5"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SCIENCE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_GOV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/field_agent))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/field_agent
	name = "Field Agent"
	jobtype = /datum/job/field_agent
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/senior_researcher
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	belt = /obj/item/modular_computer/tablet/pda/science
	ears = /obj/item/radio/headset/scp_science
	shoes = /obj/item/clothing/shoes/jackboots
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science
