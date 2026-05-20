// D-Class Faction Splits
// Rival D-Class groups with competing objectives - The Rebels vs The Collaborators

/datum/dclass_faction
	var/name = ""
	var/description = ""
	var/list/members = list()
	var/list/objectives = list()
	var/list/perks = list()
	var/alignment = DCLASS_FACTION_NONE
	var/faction_score = 0
	var/territory_count = 0

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

/datum/dclass_faction/rebels/proc/smuggle_contraband()
	if(!length(members))
		return
	var/datum/dclass_player/smuggler = null
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob && player.mob.stat != DEAD)
			smuggler = player
			break
	if(!smuggler)
		return
	var/mob/living/carbon/human/H = smuggler.mob
	var/list/contraband_types = list("wire", "screwdriver", "lockpick", "knife", "medicine")
	var/smuggled_type = pick(contraband_types)
	smuggler.add_physical_contraband(smuggled_type, 1)
	var/obj/item/dclass_contraband/item_type = smuggler.get_contraband_item_type(smuggled_type)
	if(item_type)
		var/obj/item/dclass_contraband/item = new item_type(get_turf(H))
		H.put_in_hands(item)
		to_chat(H, span_notice("A contact slips you some contraband: [item.name]."))
	else
		to_chat(H, span_notice("Your contact couldn't get anything through this time."))
	faction_score += 2

/datum/dclass_faction/rebels/proc/violent_escape_bonus()
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob || player.mob.stat == DEAD)
			continue
		var/mob/living/carbon/human/H = player.mob
		for(var/obj/machinery/dclass_escape_point/E in range(5, H))
			E.difficulty = max(1, E.difficulty - 1)
			to_chat(H, span_notice("Your rebel training makes this escape route easier!"))
			break
	faction_score += 3

/datum/dclass_faction/collaborators/proc/medical_privileges()
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob || player.mob.stat == DEAD)
			continue
		var/mob/living/carbon/human/H = player.mob
		if(H.health < H.maxHealth * 0.5)
			H.adjustBruteLoss(-10)
			H.adjustFireLoss(-10)
			H.adjustToxLoss(-5)
			to_chat(H, span_notice("Medical staff treat your injuries as a Collaborator privilege."))
	faction_score += 2

/datum/dclass_faction/collaborators/proc/early_release_check()
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob || player.mob.stat == DEAD)
			continue
		if(player.trust_level >= DCLASS_TRUST_TRUSTED && player.good_behavior_points >= 20 && player.strikes == 0)
			player.adjust_credits(200, "early_release_bonus")
			to_chat(player.mob, span_greenannounce("Your early release review is positive! Bonus compensation granted. Your cooperation is appreciated."))
			faction_score += 10

/datum/dclass_faction/survivors/proc/establish_safe_zone()
	if(!length(members))
		return
	var/list/zone_data = list()
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player || !player.mob || player.mob.stat == DEAD)
			continue
		var/mob/living/carbon/human/H = player.mob
		var/area/A = get_area(H)
		if(A)
			zone_data[A.name] = (zone_data[A.name] || 0) + 1
	if(!length(zone_data))
		return
	var/safest_zone = ""
	var/safest_count = 0
	for(var/zone in zone_data)
		if(zone_data[zone] > safest_count)
			safest_count = zone_data[zone]
			safest_zone = zone
	if(safest_count >= 2)
		do_announce("Safe zone established in [safest_zone]! Stay close to each other for safety.")
		territory_count++
		for(var/ckey in members)
			var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
			if(player && player.mob)
				var/mob/living/carbon/human/H = player.mob
				var/area/A = get_area(H)
				if(A && A.name == safest_zone)
					H.adjustBruteLoss(-5)
					if(H.sanity)
						H.sanity.adjust_sanity(5, "safe_zone")
		faction_score += 3

/datum/dclass_faction/survivors/proc/trade_network()
	if(length(members) < 2)
		return
	var/list/traders = list()
	for(var/ckey in members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob && player.mob.stat != DEAD)
			traders += player
	if(length(traders) < 2)
		return
	var/datum/dclass_player/trader1 = traders[1]
	var/datum/dclass_player/trader2 = traders[2]
	trader1.adjust_credits(25, "trade_network")
	trader2.adjust_credits(25, "trade_network")
	if(trader1.mob)
		to_chat(trader1.mob, span_notice("Survivor trade network: +25 credits from shared resources."))
	if(trader2.mob)
		to_chat(trader2.mob, span_notice("Survivor trade network: +25 credits from shared resources."))
	faction_score += 2

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
	if(world.time % 600 == 0)
		process_faction_perks()
		process_faction_conflict()
		process_faction_objectives()

/datum/dclass_faction_manager/proc/process_faction_perks()
	var/datum/dclass_faction/rebels/R = factions["rebels"]
	if(length(R.members) > 0)
		if(prob(25))
			R.smuggle_contraband()
		if(prob(15))
			R.sabotage_facility()
		if(prob(10))
			R.plan_rebel_escape()
		if(prob(8))
			R.violent_escape_bonus()

	var/datum/dclass_faction/collaborators/C = factions["collaborators"]
	if(length(C.members) > 0)
		if(prob(30))
			C.reward_loyalty()
		if(prob(20))
			C.medical_privileges()
		if(prob(10))
			C.report_rebel_activity()
		if(prob(5))
			C.early_release_check()

	var/datum/dclass_faction/survivors/S = factions["survivors"]
	if(length(S.members) > 0)
		if(prob(25))
			S.share_intel()
		if(prob(20))
			S.establish_safe_zone()
		if(prob(15))
			S.trade_network()

/datum/dclass_faction_manager/proc/process_faction_conflict()
	var/datum/dclass_faction/rebels/R = factions["rebels"]
	var/datum/dclass_faction/collaborators/C = factions["collaborators"]
	var/datum/dclass_faction/survivors/S = factions["survivors"]
	if(!length(R.members) || !length(C.members))
		return
	var/rebel_strength = 0
	var/collab_strength = 0
	for(var/ckey in R.members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob && player.mob.stat != DEAD)
			rebel_strength++
	for(var/ckey in C.members)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(player && player.mob && player.mob.stat != DEAD)
			collab_strength++
	if(rebel_strength > collab_strength + 1 && prob(20))
		R.do_announce("We outnumber the collaborators. It's time to make our move!")
		C.do_announce("WARNING: The rebels are becoming aggressive. Report any suspicious activity to guards!")
		R.faction_score += 5
		C.faction_score -= 2
	else if(collab_strength > rebel_strength + 1 && prob(20))
		C.do_announce("Our cooperation is paying off. The guards trust us more each day.")
		R.do_announce("The collaborators are gaining favor. We need to act fast.")
		C.faction_score += 5
		R.faction_score -= 2
	if(length(S.members) >= 3 && prob(15))
		S.do_announce("Stay neutral. Both sides are getting desperate — don't get caught in the crossfire.")
		S.faction_score += 3

/datum/dclass_faction_manager/proc/process_faction_objectives()
	var/datum/dclass_faction/rebels/R = factions["rebels"]
	var/datum/dclass_faction/collaborators/C = factions["collaborators"]
	var/datum/dclass_faction/survivors/S = factions["survivors"]
	if(length(R.members) > 0 && length(R.objectives) < 2)
		var/list/rebel_objs = list(
			"Acquire contraband for escape",
			"Sabotage facility systems",
			"Locate escape routes",
			"Eliminate collaborator influence",
		)
		R.objectives |= pick(rebel_objs)
		R.do_announce("New objective: [R.objectives[length(R.objectives)]]")
	if(length(C.members) > 0 && length(C.objectives) < 2)
		var/list/collab_objs = list(
			"Maintain trust above cooperative",
			"Report rebel activity to guards",
			"Complete all work assignments",
			"Volunteer for SCP testing",
		)
		C.objectives |= pick(collab_objs)
		C.do_announce("New objective: [C.objectives[length(C.objectives)]]")
	if(length(S.members) > 0 && length(S.objectives) < 2)
		var/list/surv_objs = list(
			"Keep at least 3 members alive",
			"Establish a safe zone",
			"Avoid confrontation with guards",
			"Share intel with all members",
		)
		S.objectives |= pick(surv_objs)
		S.do_announce("New objective: [S.objectives[length(S.objectives)]]")
