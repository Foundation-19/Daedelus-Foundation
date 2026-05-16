// Foundation-19 Medical Jobs

/datum/job/medical_doctor
	title = "Medical Doctor"
	description = "Provide medical care to all personnel. Diagnose and treat injuries and illnesses. Work with other departments during medical emergencies."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/medical_doctor))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/medical_doctor
	name = "Medical Doctor"
	jobtype = /datum/job/medical_doctor
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/medical_doctor
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/toggle/labcoat
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/white
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical
	chameleon_extras = list(/obj/item/clothing/glasses/hud/health)

/datum/job/surgeon
	title = "Surgeon"
	description = "Perform surgical procedures and complex medical treatments. Handle emergency surgeries and trauma cases. Train other medical staff."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/surgeon))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/surgeon
	name = "Surgeon"
	jobtype = /datum/job/surgeon
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/surgeon
	uniform = /obj/item/clothing/under/rank/medical/doctor/blue
	suit = /obj/item/clothing/suit/toggle/labcoat
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	head = /obj/item/clothing/head/surgerycap
	mask = /obj/item/clothing/mask/surgical
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical
	chameleon_extras = list(/obj/item/clothing/glasses/hud/health)

/datum/job/paramedic
	title = "Paramedic"
	description = "Provide emergency medical care in the field. Respond to medical emergencies and containment breaches. Transport patients to medical facilities."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/paramedic))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/paramedic
	name = "Paramedic"
	jobtype = /datum/job/paramedic
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/paramedic
	uniform = /obj/item/clothing/under/rank/medical/paramedic
	suit = /obj/item/clothing/suit/toggle/labcoat/emt
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical
	chameleon_extras = list(/obj/item/clothing/glasses/hud/health)

/datum/job/chemist
	title = "Chemist"
	description = "Create and manage pharmaceuticals and medical compounds. Develop treatments for SCP-related injuries. Maintain medical supply inventory."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/chemist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/chemist
	uniform = /obj/item/clothing/under/rank/medical/chemist
	suit = /obj/item/clothing/suit/toggle/labcoat/chemist
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical

/datum/job/virologist
	title = "Virologist"
	description = "Study and contain biological threats. Develop treatments for viral infections. Work with dangerous pathogens and SCPs."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/virologist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/virologist
	name = "Virologist"
	jobtype = /datum/job/virologist
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/virologist
	uniform = /obj/item/clothing/under/rank/medical/virologist
	suit = /obj/item/clothing/suit/toggle/labcoat/virologist
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical

/datum/job/psychiatrist
	title = "Psychiatrist"
	description = "Provide mental health care to personnel. Treat psychological trauma from SCP encounters. Conduct psychological evaluations."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/psychiatrist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/psychiatrist
	name = "Psychiatrist"
	jobtype = /datum/job/psychiatrist
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/psychologist
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/toggle/labcoat
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	glasses = /obj/item/clothing/glasses/regular
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical

/datum/job/medical_intern
	title = "Medical Intern"
	description = "Learn medical procedures under supervision. Assist doctors and nurses. Gain experience in Foundation medical protocols."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/medical_intern))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS|JOB_CAN_BE_INTERN

/datum/outfit/job/medical_intern
	name = "Medical Intern"
	jobtype = /datum/job/medical_intern
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/trainee_doctor
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/toggle/labcoat
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical

/datum/job/coroner
	title = "Coroner"
	description = "Examine deceased personnel and SCP victims. Determine causes of death. Maintain morgue facilities and records."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	head_announce = list("Medical")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Medical Officer"
	selection_color = "#013d3b"
	minimal_player_age = 5
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_MEDICAL
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_MED
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/coroner))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/coroner
	name = "Coroner"
	jobtype = /datum/job/coroner
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/medical_doctor
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/toggle/labcoat/mortician
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical
