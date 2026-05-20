// Foundation-19 D-Class Jobs

/datum/job/dclass_general
	title = "D-Class Personnel"
	description = "Perform testing procedures for SCPs under supervision. Follow containment protocols and safety procedures. Assist with research and maintenance tasks."
	department_head = list()
	head_announce = list("Civilian")
	faction = FACTION_FOUNDATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "Security Personnel"
	selection_color = "#dddddd"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_DCLASS
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/dclass_general))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/job/dclass_general/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	register_dclass(spawned)

/datum/outfit/job/dclass_general
	name = "D-Class Personnel"
	jobtype = /datum/job/dclass_general
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/rank/classd
	belt = /obj/item/modular_computer/tablet/pda
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/sneakers/orange
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/dclass_medical
	title = "D-Class Medical"
	description = "Assist medical staff with basic procedures. Help maintain medical facilities. Participate in medical research and testing."
	department_head = list()
	head_announce = list("Civilian")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "Medical Personnel"
	selection_color = "#dddddd"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_DCLASS
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/dclass_medical))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/job/dclass_medical/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	register_dclass(spawned, DCLASS_STATUS_MEDICAL_SUBJECT)

/datum/outfit/job/dclass_medical
	name = "D-Class Medical"
	jobtype = /datum/job/dclass_medical
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/prisoner/medic
	uniform = /obj/item/clothing/under/rank/classd
	suit = /obj/item/clothing/suit/toggle/labcoat
	belt = /obj/item/modular_computer/tablet/pda
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/sneakers/orange
	gloves = /obj/item/clothing/gloves/color/latex
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/dclass_kitchen
	title = "D-Class Kitchen"
	description = "Assist kitchen staff with food preparation. Help maintain kitchen facilities. Participate in food-related testing and research."
	department_head = list()
	head_announce = list("Civilian")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "Kitchen Personnel"
	selection_color = "#dddddd"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_DCLASS
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/dclass_kitchen))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/job/dclass_kitchen/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	register_dclass(spawned)

/datum/outfit/job/dclass_kitchen
	name = "D-Class Kitchen"
	jobtype = /datum/job/dclass_kitchen
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/prisoner/cook
	uniform = /obj/item/clothing/under/rank/classd
	suit = /obj/item/clothing/suit/apron
	belt = /obj/item/modular_computer/tablet/pda
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/sneakers/orange
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/dclass_janitorial
	title = "D-Class Janitorial"
	description = "Assist janitorial staff with cleaning duties. Help maintain facility cleanliness. Participate in cleaning-related testing."
	department_head = list()
	head_announce = list("Civilian")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "Janitorial Personnel"
	selection_color = "#dddddd"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_DCLASS
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/dclass_janitorial))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/job/dclass_janitorial/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	register_dclass(spawned)

/datum/outfit/job/dclass_janitorial
	name = "D-Class Janitorial"
	jobtype = /datum/job/dclass_janitorial
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/prisoner/janitor
	uniform = /obj/item/clothing/under/rank/classd
	belt = /obj/item/modular_computer/tablet/pda
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/galoshes
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/dclass_mining
	title = "D-Class Mining"
	description = "Assist mining operations and resource extraction. Help maintain mining equipment. Participate in mining-related testing."
	department_head = list()
	head_announce = list("Civilian")
	faction = FACTION_FOUNDATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "Mining Personnel"
	selection_color = "#dddddd"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_DCLASS
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/dclass_mining))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/job/dclass_mining/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	register_dclass(spawned)

/datum/outfit/job/dclass_mining
	name = "D-Class Mining"
	jobtype = /datum/job/dclass_mining
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/prisoner/miner
	uniform = /obj/item/clothing/under/rank/classd
	suit = /obj/item/clothing/suit/hooded/wintercoat/miner
	belt = /obj/item/modular_computer/tablet/pda
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/black
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/datum/job/dclass_research
	title = "D-Class Research"
	description = "Participate in research experiments and SCP testing. Assist researchers with data collection. Follow strict testing protocols."
	department_head = list()
	head_announce = list("Civilian")
	faction = FACTION_FOUNDATION
	total_positions = 3
	spawn_positions = 3
	supervisors = "Research Personnel"
	selection_color = "#dddddd"
	minimal_player_age = 0
	exp_requirements = 0
	exp_required_type = ""
	exp_granted_type = EXP_TYPE_DCLASS
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)
	outfits = list("Default" = list(SPECIES_HUMAN = /datum/outfit/job/dclass_research))
	job_flags = JOB_ANNOUNCE_ARRIVAL|JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_NEW_PLAYER_JOINABLE|JOB_REOPEN_ON_ROUNDSTART_LOSS|JOB_ASSIGN_QUIRKS

/datum/job/dclass_research/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	register_dclass(spawned, DCLASS_STATUS_TEST_SUBJECT)

/datum/outfit/job/dclass_research
	name = "D-Class Research"
	jobtype = /datum/job/dclass_research
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/rank/classd
	belt = /obj/item/modular_computer/tablet/pda
	ears = /obj/item/radio/headset/scp_dclass
	shoes = /obj/item/clothing/shoes/sneakers/orange
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag

/proc/register_dclass(mob/living/spawned, status = DCLASS_STATUS_GENERAL)
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/H = spawned
	if(!H.ckey)
		return
	if(!SSdclass || !SSdclass.manager)
		return
	SSdclass.manager.register_dclass_player(H)
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(H.ckey)
	if(player)
		player.status = status
		if(status == DCLASS_STATUS_MEDICAL_SUBJECT)
			player.trust_points = min(player.trust_points + 10, 100)
		if(status == DCLASS_STATUS_TEST_SUBJECT)
			player.trust_points = min(player.trust_points + 5, 100)
			player.can_volunteer = TRUE
