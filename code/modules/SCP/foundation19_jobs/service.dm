// Foundation-19 Service Jobs

/datum/job/janitor
	title = "Janitor"
	description = "Maintain cleanliness and hygiene throughout the facility. Clean containment areas and research labs. Ensure proper waste disposal."
	department_head = list()
	head_announce = list("Service")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Head of Personnel"
	selection_color = "#515151"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/janitor))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/janitor
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	belt = /obj/item/modular_computer/tablet/pda/janitor
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/galoshes
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/cook
	title = "Cook"
	description = "Prepare meals for site personnel. Maintain kitchen facilities and food safety standards. Provide nutrition for long shifts."
	department_head = list()
	head_announce = list("Service")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Head of Personnel"
	selection_color = "#515151"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/cook))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/cook
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/toggle/chef
	head = /obj/item/clothing/head/chefhat
	belt = /obj/item/modular_computer/tablet/pda/botanist
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/sneakers/black
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/bartender
	title = "Bartender"
	description = "Provide refreshments and social space for personnel. Maintain bar facilities and inventory. Offer a place for relaxation and conversation."
	department_head = list()
	head_announce = list("Service")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Personnel"
	selection_color = "#515151"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/bartender))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/bartender
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/modular_computer/tablet/pda/bartender
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/laceup
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/botanist
	title = "Botanist"
	description = "Maintain hydroponics and grow food for the facility. Study anomalous plant life. Provide fresh produce and medicinal herbs."
	department_head = list()
	head_announce = list("Service")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Personnel"
	selection_color = "#515151"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/botanist))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/botanist
	name = "Botanist"
	jobtype = /datum/job/botanist
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/botanist
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	suit = /obj/item/clothing/suit/apron
	belt = /obj/item/modular_computer/tablet/pda/botanist
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/botanic_leather
	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel/hyd
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/chaplain
	title = "Chaplain"
	description = "Provide spiritual support and counseling to personnel. Help cope with the psychological stress of SCP work. Maintain chapel facilities."
	department_head = list()
	head_announce = list("Service")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Personnel"
	selection_color = "#515151"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/chaplain))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/chaplain
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	belt = /obj/item/modular_computer/tablet/pda/chaplain
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/sneakers/black
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/curator
	title = "Curator"
	description = "Maintain library and archive facilities. Preserve historical records and SCP documentation. Provide research assistance."
	department_head = list()
	head_announce = list("Service")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Personnel"
	selection_color = "#515151"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/curator))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/curator
	name = "Curator"
	jobtype = /datum/job/curator
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/curator
	uniform = /obj/item/clothing/under/rank/civilian/curator
	belt = /obj/item/modular_computer/tablet/pda/curator
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/regular
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/lawyer
	title = "Lawyer"
	description = "Provide legal counsel and representation. Handle Foundation legal matters and compliance issues. Ensure proper legal procedures."
	department_head = list()
	head_announce = list("Service")
	faction = FACTION_FOUNDATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Personnel"
	selection_color = "#515151"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/lawyer))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/outfit/job/lawyer
	name = "Lawyer"
	jobtype = /datum/job/lawyer
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/lawyer
	uniform = /obj/item/clothing/under/rank/civilian/lawyer
	suit = /obj/item/clothing/suit/toggle/lawyer
	belt = /obj/item/modular_computer/tablet/pda/lawyer
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/laceup
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
