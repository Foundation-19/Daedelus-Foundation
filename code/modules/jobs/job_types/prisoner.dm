/datum/job/dclass
	title = JOB_DCLASS
	description = "Perform testing procedures for SCPs under supervision. Follow containment protocols and safety procedures."
	department_head = list()
	faction = FACTION_STATION
	total_positions = 8
	spawn_positions = 8
	selection_color = "#bd630a"
	exp_granted_type = "D-Class"
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/prisoner,
		),
	)

	department_for_prefs = /datum/job_department/security

	exclusive_mail_goodies = TRUE
	mail_goodies = list (
		/obj/effect/spawner/random/contraband/prison = 1
	)

	family_heirlooms = list(/obj/item/pen/blue)
	rpg_title = "D-Boy"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_ASSIGN_QUIRKS


/datum/outfit/job/prisoner
	name = "D-Class Personnel"
	jobtype = /datum/job/dclass

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/scp/dclass
	shoes = /obj/item/clothing/shoes/workboots
	l_pocket = /obj/item/modular_computer/tablet/pda/dclass

/datum/outfit/job/prisoner/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(1)) // D BOYYYYSSSSS
		head = /obj/item/clothing/head/beanie/black/dboy
