/obj/effect/landmark/goc_spawn
	name = "GOC spawn point"

/obj/effect/landmark/uiu_spawn
	name = "UIU spawn point"

/obj/effect/landmark/isd_spawn
	name = "ISD spawn point"

/datum/team/goc
	name = "Global Occult Coalition"

/datum/team/uiu
	name = "Unusual Incidents Unit"

/datum/antagonist/goc
	name = "GOC Operative"
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR HUMANITY!!"
	var/datum/team/goc/goc_team
	var/datum/outfit/outfit = /datum/outfit/mtf/goc
	var/role = "Operative"
	var/forge_objectives_for_goc = TRUE

/datum/antagonist/goc/on_gain()
	update_name()
	if(forge_objectives_for_goc)
		forge_objectives()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.equipOutfit(outfit)
	. = ..()

/datum/antagonist/goc/get_team()
	return goc_team

/datum/antagonist/goc/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(GLOB.last_names)]")

/datum/antagonist/goc/proc/forge_objectives()
	if(goc_team)
		return
	var/datum/objective/missionobj = new()
	missionobj.owner = owner
	missionobj.explanation_text = "Assist in neutralizing hostile anomalous threats. Protect civilian witnesses. Coordinate with Foundation personnel when possible."
	missionobj.completed = TRUE
	objectives |= missionobj

/datum/antagonist/goc/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are a Global Occult Coalition operative."))
	to_chat(owner, "<span class='warningplain'>The GOC operates under the UN to neutralize paranormal threats. The Foundation is an ally, but your mission takes priority.</span>")

/datum/antagonist/goc/commander
	role = "GOC Commander"
	outfit = /datum/outfit/mtf/goc/commander

/datum/antagonist/uiu
	name = "UIU Agent"
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE BUREAU!!"
	var/datum/team/uiu/uiu_team
	var/datum/outfit/outfit = /datum/outfit/uiu
	var/role = "Agent"
	var/forge_objectives_for_uiu = TRUE

/datum/antagonist/uiu/on_gain()
	update_name()
	if(forge_objectives_for_uiu)
		forge_objectives()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.equipOutfit(outfit)
	. = ..()

/datum/antagonist/uiu/get_team()
	return uiu_team

/datum/antagonist/uiu/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(GLOB.last_names)]")

/datum/antagonist/uiu/proc/forge_objectives()
	var/datum/objective/missionobj = new()
	missionobj.owner = owner
	missionobj.explanation_text = "Investigate anomalous activity at Site-53. Report findings to FBI Headquarters. Assist Foundation personnel when it serves US interests."
	missionobj.completed = TRUE
	objectives |= missionobj

/datum/antagonist/uiu/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are an FBI Unusual Incidents Unit agent."))
	to_chat(owner, "<span class='warningplain'>The UIU investigates paranormal activity on US soil. You're here to observe and report.</span>")

/datum/outfit/uiu
	name = "UIU Agent"
	uniform = /obj/item/clothing/under/scp/civilian/uiu
	suit = /obj/item/clothing/suit/jacket
	shoes = /obj/item/clothing/shoes/laceup
	ears = /obj/item/radio/headset/scp_security
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/advanced

/datum/antagonist/isd
	name = "ISD Agent"
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE DEPARTMENT!!"
	var/datum/outfit/outfit = /datum/outfit/isd
	var/role = "Agent"

/datum/antagonist/isd/on_gain()
	update_name()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.equipOutfit(outfit)
	. = ..()

/datum/antagonist/isd/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(GLOB.last_names)]")

/datum/antagonist/isd/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are an Internal Security Department agent."))
	to_chat(owner, "<span class='warningplain'>The ISD monitors Foundation personnel for corruption, sabotage, and unauthorized activity. Your identity is classified.</span>")

/datum/antagonist/isd/proc/forge_objectives()
	var/datum/objective/missionobj = new()
	missionobj.owner = owner
	missionobj.explanation_text = "Monitor Foundation personnel for unauthorized activity. Investigate suspected security breaches. Report directly to O5 Council."
	missionobj.completed = TRUE
	objectives |= missionobj

/datum/outfit/isd
	name = "ISD Agent"
	uniform = /obj/item/clothing/under/scp/security/isd
	suit = /obj/item/clothing/suit/jacket
	shoes = /obj/item/clothing/shoes/laceup
	ears = /obj/item/radio/headset/scp_command
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/advanced
