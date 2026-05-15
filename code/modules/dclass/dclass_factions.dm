// D-Class Faction Splits
// Rival D-Class groups with competing objectives - The Rebels vs The Collaborators

/datum/dclass_faction
	var/name = ""
	var/description = ""
	var/list/members = list()
	var/list/objectives = list()
	var/list/perks = list()
	var/alignment = DCLASS_FACTION_NONE

/datum/dclass_faction/proc/add_member(datum/dclass_player/player)
	if(!player)
		return FALSE
	members += player.ckey
	return TRUE

/datum/dclass_faction/proc/remove_member(datum/dclass_player/player)
	if(!player)
		return FALSE
	members -= player.ckey
	return TRUE

/datum/dclass_faction/proc/process_faction()
	if(!length(members))
		return
	if(world.time % 300 == 0)
		evaluate_faction_strength()

/datum/dclass_faction/proc/evaluate_faction_strength()
	var/active_members = 0
	for(var/ckey in members)
		if(SSdclass && SSdclass.manager)
			var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
			if(player && player.mob && player.mob.stat != DEAD)
				active_members++

	if(active_members == 0 && length(members) > 0)
		members.Cut()

/datum/dclass_faction/proc/do_announce(message)
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[ckey]
		if(player && player.mob)
			to_chat(player.mob, "<span class='boldnotice'>FACTION MESSAGE: [message]</span>")

// Rebel Faction - Seeking escape, hostile to guards
/datum/dclass_faction/rebels
	name = "The Rebels"
	description = "D-Class who have decided they'd rather take their chances escaping than continue as test subjects. Willing to use violence."
	alignment = DCLASS_FACTION_REBELS
	perks = list("violent_escape", "smuggle_contraband", "sabotage")

/datum/dclass_faction/rebels/add_member(datum/dclass_player/player)
	. = ..()
	if(. && player)
		player.adjust_trust(-20, "joined_rebels")
		to_chat(player.mob, "<span class='danger'>You are now part of The Rebels. Find weapons, sabotage the facility, and escape at all costs.</span>")

/datum/dclass_faction/rebels/proc/recruit_rebels()
	var/list/available = list()
	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob && player.mob.stat != DEAD && player.trust_level <= DCLASS_TRUST_NEUTRAL && player.faction == DCLASS_FACTION_NONE)
			available += player

	if(length(available))
		var/datum/dclass_player/recruit = pick(available)
		add_member(recruit)

/datum/dclass_faction/rebels/proc/plan_rebel_escape()
	if(!length(members))
		return

	var/list/escape_points = list()
	for(var/obj/effect/landmark/dclass_escape_route/E in GLOB.landmarks_list)
		if(!E.z)
			continue
		var/area/A = get_area(E)
		if(istype(A, /area/scp/ez) || istype(A, /area/scp/surface))
			escape_points += E

	if(!length(escape_points))
		return

	do_announce("Escape point identified. Coordinate with faction members. Eliminate guards in your path.")

	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob)
			to_chat(player.mob, "<span class='danger'>REBEL SIGNAL: Escape route located! Move to the designated point!</span>")

/datum/dclass_faction/rebels/proc/sabotage_facility()
	do_announce("Initiating facility sabotage. Create chaos to cover our escape.")

	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob)
			var/mob/living/carbon/human/H = player.mob
			for(var/obj/machinery/power/apc/APC in range(10, H))
				if(prob(30))
					APC.energy_fail(rand(30, 120))
					break

	for(var/obj/machinery/camera/C in INSTANCES_OF(/obj/machinery/camera))
		if(prob(20))
			C.toggle_cam(null, 0)

// Collaborator Faction - Loyal to staff, earn trust for early release
/datum/dclass_faction/collaborators
	name = "The Collaborators"
	description = "D-Class who cooperate fully with Foundation staff, hoping to earn early release through good behavior."
	alignment = DCLASS_FACTION_COLLABORATORS
	perks = list("bonus_trust", "medical_privileges", "early_release")

/datum/dclass_faction/collaborators/add_member(datum/dclass_player/player)
	. = ..()
	if(. && player)
		to_chat(player.mob, "<span class='notice'>You are now a Collaborator. Your cooperation will be noted and rewarded.</span>")

/datum/dclass_faction/collaborators/proc/reward_loyalty()
	var/rewards_given = 0
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob && player.trust_level >= DCLASS_TRUST_COOPERATIVE)
			player.adjust_trust(5, "loyalty_reward")
			player.adjust_credits(100, "loyalty_reward")
			rewards_given++
			to_chat(player.mob, "<span class='green'>Your cooperation has been noted. Reward granted.</span>")

	if(rewards_given > 0)
		log_game("D-Class Collaborator faction rewarded [rewards_given] loyal members this cycle.")

/datum/dclass_faction/collaborators/proc/report_rebel_activity()
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob)
			continue

		var/mob/living/carbon/human/H = player.mob
		var/suspicious_contraband = 0
		for(var/obj/item/I in H.get_all_contents())
			if(findtext("[I.type]", "contraband"))
				suspicious_contraband++

		if(suspicious_contraband > 0)
			player.adjust_trust(-10, "suspicious_items")
			to_chat(H, "<span class='warning'>Your association with contraband has been noted. Cooperation requires full honesty.</span>")

// Survivor Faction - Neutral group focused on staying alive and avoiding both extremes
/datum/dclass_faction/survivors
	name = "The Survivors"
	description = "D-Class who focus purely on survival, avoiding conflict with staff while staying alert for escape opportunities."
	alignment = DCLASS_FACTION_SURVIVORS
	perks = list("shared_intel", "safe_zones", "trade_network")

/datum/dclass_faction/survivors/add_member(datum/dclass_player/player)
	. = ..()
	if(. && player)
		to_chat(player.mob, "<span class='notice'>You are now part of The Survivors. Stay neutral, gather intel, and survive.</span>")

/datum/dclass_faction/survivors/proc/share_intel()
	if(!length(members))
		return

	var/list/collected_intel = list()
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob)
			continue

		var/mob/living/carbon/human/H = player.mob
		var/area/A = get_area(H)
		var/zone = A ? get_containment_zone(A) : "unknown"

		collected_intel["Zone [zone]"] += 1

	do_announce("Intel report: [english_list(collected_intel)]")

// Faction Manager - Handles all D-Class factions
/datum/dclass_faction_manager
	var/list/datum/dclass_faction/factions = list()
	var/faction_formation_cooldown = 0
	var/faction_formation_interval = 15 MINUTES
	var/list/rivalries = list()

/datum/dclass_faction_manager/New()
	. = ..()
	factions["rebels"] = new /datum/dclass_faction/rebels()
	factions["collaborators"] = new /datum/dclass_faction/collaborators()
	factions["survivors"] = new /datum/dclass_faction/survivors()

	rivalries["rebels"] = list("collaborators")
	rivalries["collaborators"] = list("rebels")
	rivalries["survivors"] = list()

/datum/dclass_faction_manager/proc/attempt_faction_formation()
	if(world.time < faction_formation_cooldown)
		return

	faction_formation_cooldown = world.time + faction_formation_interval

	var/rebel_eligible = 0
	var/collab_eligible = 0
	var/surv_eligible = 0

	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob || player.mob.stat == DEAD)
			continue

		if(player.faction != DCLASS_FACTION_NONE)
			continue

		if(player.trust_level <= DCLASS_TRUST_SUSPICIOUS)
			rebel_eligible++
		else if(player.trust_level >= DCLASS_TRUST_COOPERATIVE)
			collab_eligible++
		else
			surv_eligible++

	if(rebel_eligible >= 2 && prob(40))
		form_rebel_faction()
	if(collab_eligible >= 2 && prob(60))
		form_collaborator_faction()
	if(surv_eligible >= 3 && prob(30))
		form_survivor_faction()

/datum/dclass_faction_manager/proc/form_rebel_faction()
	var/datum/dclass_faction/rebels/F = factions["rebels"]
	var/recruited = 0

	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(recruited >= 3)
			break
		if(player && player.mob && player.mob.stat != DEAD && player.faction == DCLASS_FACTION_NONE && player.trust_level <= DCLASS_TRUST_NEUTRAL)
			F.add_member(player)
			player.faction = DCLASS_FACTION_REBELS
			recruited++

	if(recruited >= 2)
		priority_announce("D-CLASS ALERT: Coordination detected in cell block. Security response teams report to D-Class areas.", "SECURITY ALERT", sound_type = ANNOUNCER_ALERT)

	log_game("D-Class Rebel faction formed with [recruited] members.")

/datum/dclass_faction_manager/proc/form_collaborator_faction()
	var/datum/dclass_faction/collaborators/F = factions["collaborators"]
	var/recruited = 0

	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(recruited >= 3)
			break
		if(player && player.mob && player.mob.stat != DEAD && player.faction == DCLASS_FACTION_NONE && player.trust_level >= DCLASS_TRUST_NEUTRAL)
			F.add_member(player)
			player.faction = DCLASS_FACTION_COLLABORATORS
			recruited++

	if(recruited >= 2)
		log_game("D-Class Collaborator faction formed with [recruited] members.")

/datum/dclass_faction_manager/proc/form_survivor_faction()
	var/datum/dclass_faction/survivors/F = factions["survivors"]
	var/recruited = 0

	for(var/ckey in SSdclass.manager.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(recruited >= 4)
			break
		if(player && player.mob && player.mob.stat != DEAD && player.faction == DCLASS_FACTION_NONE)
			F.add_member(player)
			player.faction = DCLASS_FACTION_SURVIVORS
			recruited++

	if(recruited >= 3)
		log_game("D-Class Survivor faction formed with [recruited] members.")

/datum/dclass_faction_manager/proc/announce_to_faction(faction_name, message)
	var/list/faction_members
	switch(faction_name)
		if("rebels")
			faction_members = factions["rebels"].members
		if("collaborators")
			faction_members = factions["collaborators"].members
		if("survivors")
			faction_members = factions["survivors"].members
		else
			return

	for(var/ckey in faction_members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob)
			to_chat(player.mob, "<span class='boldnotice'>FACTION MESSAGE: [message]</span>")

/datum/dclass_faction_manager/proc/process_factions()
	attempt_faction_formation()
	factions["rebels"].process_faction()
	factions["collaborators"].process_faction()
	factions["survivors"].process_faction()
