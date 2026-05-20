// MTF Deployment System
// Allows mid-round deployment of Mobile Task Force teams in response to containment breaches
// Includes deployment console, loadout kits, and objectives

/obj/machinery/mtf_deployment_console
	name = "MTF Deployment Console"
	desc = "A secure console for authorizing Mobile Task Force deployment during containment emergencies."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

	var/deployment_cooldown = 0
	var/deployment_cooldown_time = 15 MINUTES
	var/last_deployment = ""
	var/available_teams = list(
		"mtf_nu7" = list("name" = "Nu-7 'Hammer Down'", "desc" = "Heavy assault team. Best for Keter-class breaches.", "specialty" = "Heavy Assault / Keter-Class", "size" = 4, "min_breach" = 2),
		"mtf_epsilon11" = list("name" = "Epsilon-11 'Nine-Tailed Fox'", "desc" = "Containment specialists. Best for Euclid breaches.", "specialty" = "Containment / Euclid-Class", "size" = 3, "min_breach" = 1),
		"mtf_epsilon9" = list("name" = "Epsilon-9 'Fire Eaters'", "desc" = "Fire/heat specialists. Best for SCP-457 breaches.", "specialty" = "Fire / Heat Suppression", "size" = 3, "min_breach" = 1),
		"mtf_beta7" = list("name" = "Beta-7 'Maz Hatters'", "desc" = "Biohazard specialists. Best for SCP-008/049 breaches.", "specialty" = "Biohazard / Quarantine", "size" = 3, "min_breach" = 1),
	)

/obj/machinery/mtf_deployment_console/Initialize(mapload)
	. = ..()
	SET_TRACKING(__TYPE__)

/obj/machinery/mtf_deployment_console/Destroy()
	UNSET_TRACKING(__TYPE__)
	return ..()

/obj/machinery/mtf_deployment_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MTFDeployment", "SCP FOUNDATION — MTF DEPLOYMENT TERMINAL")
		ui.open()

/obj/machinery/mtf_deployment_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mtf_deployment_console/ui_data(mob/user)
	var/list/data = list()

	var/cooldown_remaining = max(0, deployment_cooldown - world.time)
	data["cooldown_remaining"] = cooldown_remaining
	data["cooldown_total"] = deployment_cooldown_time
	data["on_cooldown"] = cooldown_remaining > 0

	var/list/teams = list()
	for(var/team_key in available_teams)
		var/list/team = available_teams[team_key]
		teams += list(list(
			"key" = team_key,
			"name" = team["name"],
			"desc" = team["desc"],
			"specialty" = team["specialty"],
			"size" = team["size"],
			"min_breach" = team["min_breach"],
		))
	data["available_teams"] = teams

	var/active_breaches = 0
	if(SSscp_persistence && SSscp_persistence.manager)
		active_breaches = SSscp_persistence.manager.active_breaches
	data["active_breach_count"] = active_breaches
	data["last_deployment"] = last_deployment

	return data

/obj/machinery/mtf_deployment_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("deploy")
			var/team_key = params["team_name"]
			if(!team_key || !(team_key in available_teams))
				return
			var/mob/living/carbon/human/H = usr
			if(!istype(H))
				return
			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(!id_card || !(ACCESS_ADMIN in id_card.access))
				to_chat(H, "<span class='warning'>Requires Command access to authorize MTF deployment.</span>")
				return
			if(world.time < deployment_cooldown)
				to_chat(H, "<span class='warning'>MTF deployment systems recharging. Available in [DisplayTimeText(deployment_cooldown - world.time)].</span>")
				return
			var/list/team = available_teams[team_key]
			var/active_breaches = 0
			if(SSscp_persistence && SSscp_persistence.manager)
				active_breaches = SSscp_persistence.manager.active_breaches
			if(active_breaches < team["min_breach"])
				to_chat(H, "<span class='warning'>Insufficient threat level. [team["name"]] requires at least [team["min_breach"]] active breach(es). Current: [active_breaches]</span>")
				return
			last_deployment = team["name"]
			deploy_mtf_team(team_key, team, H)

/obj/machinery/mtf_deployment_console/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(H, "<span class='warning'>Requires Command access to authorize MTF deployment.</span>")
		return

	if(world.time < deployment_cooldown)
		to_chat(H, "<span class='warning'>MTF deployment systems recharging. Available in [DisplayTimeText(deployment_cooldown - world.time)].</span>")
		return

	var/list/options = list()
	for(var/team_key in available_teams)
		var/list/team = available_teams[team_key]
		options[team["name"]] = team_key

	var/choice = input(H, "Select MTF team to deploy:", "MTF Deployment") as null|anything in options
	if(!choice)
		return

	var/team_key = options[choice]
	var/list/team = available_teams[team_key]

	var/active_breaches = 0
	if(SSscp_persistence && SSscp_persistence.manager)
		active_breaches = SSscp_persistence.manager.active_breaches

	if(active_breaches < team["min_breach"])
		to_chat(H, "<span class='warning'>Insufficient threat level. [team["name"]] requires at least [team["min_breach"]] active breach(es). Current: [active_breaches]</span>")
		return

	var/confirm = alert(H, "Deploy [team["name"]]? Team size: [team["size"]]. This action cannot be undone.", "MTF Deployment", "Deploy", "Cancel")
	if(confirm != "Deploy")
		return

	deploy_mtf_team(team_key, team, H)

/obj/machinery/mtf_deployment_console/proc/deploy_mtf_team(team_key, list/team_data, mob/deployer)
	deployment_cooldown = world.time + deployment_cooldown_time

	priority_announce("ATTENTION: Mobile Task Force [team_data["name"]] has been deployed to Site-53. All personnel cooperate with MTF operations.", "MTF DEPLOYMENT", null, ANNOUNCER_ALERT)

	var/list/spawn_turfs = list()
	for(var/turf/T in get_area_turfs(/area/scp/surface/helipad))
		if(!T.density)
			spawn_turfs += T

	if(!length(spawn_turfs))
		for(var/turf/T in get_area_turfs(/area/scp/ez/lobby))
			if(!T.density)
				spawn_turfs += T

	if(!length(spawn_turfs))
		for(var/turf/T in get_area_turfs(/area/site53/surface))
			if(!T.density)
				spawn_turfs += T

	if(!length(spawn_turfs))
		var/turf/fallback = get_safe_random_station_turf()
		if(fallback)
			spawn_turfs += fallback

	var/team_size = team_data["size"]
	var/list/objectives = generate_mtf_objectives(team_key)
	var/list/deployed_members = list()

	var/list/spawn_loc = length(spawn_turfs) ? pick(spawn_turfs) : get_turf(src)
	var/mob/living/carbon/human/mtf_commander = new(spawn_loc)
	equip_mtf_member(mtf_commander, team_key, TRUE)
	deployed_members += mtf_commander

	for(var/i in 2 to team_size)
		var/turf/member_loc = length(spawn_turfs) ? pick(spawn_turfs) : get_turf(src)
		var/mob/living/carbon/human/mtf_member = new(member_loc)
		equip_mtf_member(mtf_member, team_key, FALSE)
		deployed_members += mtf_member

	var/list/candidates = poll_candidates_for_mob("Do you want to play as MTF [team_data["name"]]?", ROLE_MTF, null, 10 SECONDS, mtf_commander)
	if(length(candidates))
		var/mob/dead/observer/candidate = candidates[1]
		mtf_commander.key = candidate.key

	for(var/i in 2 to length(deployed_members))
		var/mob/living/carbon/human/mtf_member = deployed_members[i]
		var/list/more_candidates = poll_candidates_for_mob("Do you want to play as MTF [team_data["name"]]?", ROLE_MTF, null, 10 SECONDS, mtf_member)
		if(length(more_candidates))
			var/mob/dead/observer/candidate = more_candidates[1]
			mtf_member.key = candidate.key

	for(var/mob/living/carbon/human/H in deployed_members)
		for(var/obj in objectives)
			to_chat(H, "<span class='notice'>MTF Objective: [obj]</span>")

	report_lockdown_to_round_log("MTF Deployment: [team_data["name"]]", 0)

/obj/machinery/mtf_deployment_console/proc/generate_mtf_objectives(team_key)
	var/list/objectives = list("Secure all containment breaches")

	switch(team_key)
		if("mtf_nu7")
			objectives += "Neutralize Keter-class threats by any means necessary"
			objectives += "Establish perimeter around HCZ"
		if("mtf_epsilon11")
			objectives += "Recontain all Euclid-class SCPs"
			objectives += "Escort researchers to safety"
		if("mtf_epsilon9")
			objectives += "Suppress SCP-457 using fire containment protocols"
			objectives += "Prevent fire spread to other zones"
		if("mtf_beta7")
			objectives += "Contain biological hazards (SCP-008, SCP-049)"
			objectives += "Establish quarantine perimeter"

	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(instance.containment_status == "breached")
				objectives += "Priority: Recontain [scp_id]"

	return objectives

/obj/machinery/mtf_deployment_console/proc/equip_mtf_member(mob/living/carbon/human/H, team_key, is_commander)
	H.set_species(/datum/species/human)

	var/obj/item/card/id/id_card = new /obj/item/card/id/advanced()
	id_card.registered_name = H.real_name
	id_card.assignment = is_commander ? "MTF Commander" : "MTF Operative"
	id_card.access = list(
		ACCESS_SECURITY, ACCESS_SECURITY_LVL1, ACCESS_SECURITY_LVL2, ACCESS_SECURITY_LVL3, ACCESS_SECURITY_LVL4, ACCESS_SECURITY_LVL5,
		ACCESS_SCIENCE, ACCESS_MEDICAL, ACCESS_ADMIN, ACCESS_DCLASS,
	)
	H.equip_to_slot_or_del(id_card, ITEM_SLOT_ID)

	var/outfit_type
	switch(team_key)
		if("mtf_nu7")
			outfit_type = /datum/outfit/mtf_nu7
		if("mtf_epsilon11")
			outfit_type = /datum/outfit/mtf_epsilon11
		if("mtf_epsilon9")
			outfit_type = /datum/outfit/mtf_epsilon9
		if("mtf_beta7")
			outfit_type = /datum/outfit/mtf_beta7
		else
			outfit_type = /datum/outfit/mtf_default

	if(outfit_type)
		var/datum/outfit/O = new outfit_type
		O.equip(H)

/datum/outfit/mtf_default
	name = "MTF Default"
	uniform = /obj/item/clothing/under/rank/security/guard
	suit = /obj/item/clothing/suit/armor/vest/sec
	head = /obj/item/clothing/head/helmet/sec
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/heads/hos
	mask = /obj/item/clothing/mask/gas/sechailer

/datum/outfit/mtf_nu7
	name = "MTF Nu-7 Hammer Down"
	uniform = /obj/item/clothing/under/rank/security/captain
	suit = /obj/item/clothing/suit/armor/vest/sec
	head = /obj/item/clothing/head/helmet/sec
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/duffelbag/sec
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/heads/hos
	mask = /obj/item/clothing/mask/gas/sechailer

/datum/outfit/mtf_epsilon11
	name = "MTF Epsilon-11 Nine-Tailed Fox"
	uniform = /obj/item/clothing/under/rank/security/guard
	suit = /obj/item/clothing/suit/armor/vest/sec
	head = /obj/item/clothing/head/helmet/sec
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/heads/hos
	mask = /obj/item/clothing/mask/gas/sechailer

/datum/outfit/mtf_epsilon9
	name = "MTF Epsilon-9 Fire Eaters"
	uniform = /obj/item/clothing/under/rank/security/guard
	suit = /obj/item/clothing/suit/fire/atmos
	head = /obj/item/clothing/head/hardhat/red
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/heads/hos
	mask = /obj/item/clothing/mask/gas

/datum/outfit/mtf_beta7
	name = "MTF Beta-7 Maz Hatters"
	uniform = /obj/item/clothing/under/rank/security/guard
	suit = /obj/item/clothing/suit/bio_suit/general
	head = /obj/item/clothing/head/bio_hood/general
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/heads/hos
	mask = /obj/item/clothing/mask/gas
