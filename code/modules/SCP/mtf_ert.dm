/datum/team/mtf
	name = "Mobile Task Force"
	var/datum/objective/mission
	var/team_designation = "MTF"

/datum/antagonist/mtf
	name = "MTF Operative"
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE FOUNDATION!!"
	var/datum/team/mtf/mtf_team
	var/leader = FALSE
	var/datum/outfit/outfit = /datum/outfit/mtf/security
	var/role = "Operative"
	var/list/name_source
	var/random_names = TRUE
	var/rip_and_tear = FALSE
	var/equip_mtf = TRUE
	var/forge_objectives_for_mtf = TRUE
	var/ert_job_path = /datum/job/ert_generic

/datum/antagonist/mtf/on_gain()
	if(random_names)
		update_name()
	if(forge_objectives_for_mtf)
		forge_objectives()
	if(equip_mtf)
		equipMTF()
	. = ..()

/datum/antagonist/mtf/get_team()
	return mtf_team

/datum/antagonist/mtf/New()
	. = ..()
	name_source = GLOB.last_names

/datum/antagonist/mtf/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(name_source)]")

/datum/antagonist/mtf/proc/forge_objectives()
	if(mtf_team && mtf_team.mission)
		objectives |= mtf_team.mission
		return
	var/datum/objective/missionobj = new()
	missionobj.owner = owner
	missionobj.explanation_text = "Recontain any breached SCPs and secure the facility."
	missionobj.completed = TRUE
	objectives |= missionobj

/datum/antagonist/mtf/proc/equipMTF()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.equipOutfit(outfit)

/datum/antagonist/mtf/greet()
	. = ..()
	to_chat(owner, "<span class='boldannounce'>You are a Mobile Task Force operative of the SCP Foundation.</span>")
	to_chat(owner, "<span class='warningplain'>Secure. Contain. Protect.</span>")
	if(mtf_team && mtf_team.mission)
		to_chat(owner, "<span class='warningplain'>Mission: [mtf_team.mission.explanation_text]</span>")

/datum/antagonist/mtf/security
	role = "MTF Security"

/datum/antagonist/mtf/security/red
	outfit = /datum/outfit/mtf/security/alert

/datum/antagonist/mtf/engineer
	role = "MTF Engineer"
	outfit = /datum/outfit/mtf/engineer

/datum/antagonist/mtf/engineer/red
	outfit = /datum/outfit/mtf/engineer/alert

/datum/antagonist/mtf/medic
	role = "MTF Medical Officer"
	outfit = /datum/outfit/mtf/medic

/datum/antagonist/mtf/medic/red
	outfit = /datum/outfit/mtf/medic/alert

/datum/antagonist/mtf/commander
	role = "MTF Commander"
	outfit = /datum/outfit/mtf/commander
	leader = TRUE

/datum/antagonist/mtf/commander/red
	outfit = /datum/outfit/mtf/commander/alert
	leader = TRUE

/datum/antagonist/mtf/nu7
	name = "MTF Nu-7 Hammer Down"
	role = "Nu-7 Operative"
	outfit = /datum/outfit/mtf/nu7

/datum/antagonist/mtf/nu7/commander
	role = "Nu-7 Commander"
	outfit = /datum/outfit/mtf/nu7/commander
	leader = TRUE

/datum/antagonist/mtf/epsilon11
	name = "MTF Epsilon-11 Nine-Tailed Fox"
	role = "Epsilon-11 Operative"
	outfit = /datum/outfit/mtf/epsilon11

/datum/antagonist/mtf/epsilon11/commander
	role = "Epsilon-11 Commander"
	outfit = /datum/outfit/mtf/epsilon11/commander
	leader = TRUE

/datum/antagonist/mtf/epsilon9
	name = "MTF Epsilon-9 Fire Eaters"
	role = "Epsilon-9 Operative"
	outfit = /datum/outfit/mtf/epsilon9

/datum/antagonist/mtf/beta7
	name = "MTF Beta-7 Maz Hatters"
	role = "Beta-7 Operative"
	outfit = /datum/outfit/mtf/beta7

/datum/antagonist/mtf/eta10
	name = "MTF Eta-10 See No Evil"
	role = "Eta-10 Operative"
	outfit = /datum/outfit/mtf/eta10

/datum/antagonist/mtf/deathsquad
	name = "O5 Death Squad"
	role = "Death Squad Operative"
	outfit = /datum/outfit/mtf/deathsquad
	rip_and_tear = TRUE

/datum/antagonist/mtf/deathsquad/leader
	role = "Death Squad Commander"
	outfit = /datum/outfit/mtf/deathsquad
	leader = TRUE

/datum/antagonist/mtf/goc
	name = "GOC Operative"
	role = "GOC Operative"
	outfit = /datum/outfit/mtf/goc

/datum/antagonist/mtf/goc/commander
	role = "GOC Commander"
	outfit = /datum/outfit/mtf/goc/commander
	leader = TRUE

/datum/outfit/mtf
	name = "MTF Base Outfit"

/datum/outfit/mtf/security
	name = "MTF Security"
	uniform = /obj/item/clothing/under/scp/security/lcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_security
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/security/alert
	name = "MTF Security Alert"
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/riot

/datum/outfit/mtf/engineer
	name = "MTF Engineer"
	uniform = /obj/item/clothing/under/scp/cargotech/utility
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_engineering
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/yellow
	back = /obj/item/storage/backpack/industrial
	belt = /obj/item/storage/belt/utility/full
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/engineer/alert
	name = "MTF Engineer Alert"
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/riot

/datum/outfit/mtf/medic
	name = "MTF Medical"
	uniform = /obj/item/clothing/under/scp/security/lcz/medic
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/medic
	head = /obj/item/clothing/head/helmet/scp/security/medic
	ears = /obj/item/radio/headset/scp_medical
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/latex
	back = /obj/item/storage/backpack/medic
	belt = /obj/item/storage/belt/medical
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/medic/alert
	name = "MTF Medical Alert"
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/riot

/datum/outfit/mtf/commander
	name = "MTF Commander"
	uniform = /obj/item/clothing/under/scp/warden/lcz
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_command
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/commander/alert
	name = "MTF Commander Alert"
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/riot

/datum/outfit/mtf/nu7
	name = "MTF Nu-7"
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_mtf
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/nu7/commander
	name = "MTF Nu-7 Commander"
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor

/datum/outfit/mtf/epsilon11
	name = "MTF Epsilon-11"
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_mtf
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/epsilon11/commander
	name = "MTF Epsilon-11 Commander"
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor

/datum/outfit/mtf/epsilon9
	name = "MTF Epsilon-9"
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/eta
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_mtf
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/beta7
	name = "MTF Beta-7"
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/beta
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_mtf
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/eta10
	name = "MTF Eta-10"
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor/eta
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_mtf
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/deathsquad
	name = "O5 Death Squad"
	uniform = /obj/item/clothing/under/scp/alpha
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_command
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced
	r_hand = /obj/item/gun/ballistic/automatic/scp/p90

/datum/outfit/mtf/goc
	name = "GOC Operative"
	uniform = /obj/item/clothing/under/scp/civilian/goc
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	ears = /obj/item/radio/headset/scp_security
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced

/datum/outfit/mtf/goc/commander
	name = "GOC Commander"
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
