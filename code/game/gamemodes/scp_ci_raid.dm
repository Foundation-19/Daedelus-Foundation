/datum/game_mode/scp_ci_raid
	name = "Chaos Insurgency Raid"
	weight = GAMEMODE_WEIGHT_UNCOMMON
	votable = TRUE

	min_pop = 15
	required_enemies = 0
	max_pop = INFINITY

	var/raid_phase = 0
	var/list/ci_operatives = list()
	var/ci_objective = ""
	var/raid_start_time
	var/ci_extracted = FALSE
	var/scp_stolen = FALSE

/datum/game_mode/scp_ci_raid/pre_setup()
	..()
	return TRUE

/datum/game_mode/scp_ci_raid/post_setup(report)
	. = ..()
	raid_start_time = world.time
	raid_phase = 1

	var/list/objectives = list("Steal an SCP object", "Extract a D-Class personnel", "Sabotage containment systems", "Assassinate the Site Director")
	ci_objective = pick(objectives)

	priority_announce("ATTENTION: Anomalous readings detected at Site-53 perimeter. All security personnel remain vigilant.", "SITE-53 COMMAND", sound_type = ANNOUNCER_DEFAULT)

	addtimer(CALLBACK(src, .proc/begin_raid), rand(10 MINUTES, 15 MINUTES))

/datum/game_mode/scp_ci_raid/proc/begin_raid()
	raid_phase = 2
	priority_announce("ALERT: Unauthorized armed intrusion detected. Chaos Insurgency forces have breached the facility perimeter. Objective: [ci_objective]", "SECURITY ALERT", sound_type = ANNOUNCER_ALERT)

	var/max_ci = clamp(round(length(SSticker.ready_players) / 12), 2, 6)
	var/list/spawn_turfs = list()
	for(var/turf/T in get_area_turfs(/area/scp/surface/gate_b))
		if(!T.density)
			spawn_turfs += T
	if(!length(spawn_turfs))
		for(var/turf/T in get_area_turfs(/area/scp/surface))
			if(!T.density)
				spawn_turfs += T
	if(!length(spawn_turfs))
		return

	for(var/i in 1 to max_ci)
		if(!length(spawn_turfs))
			break
		var/turf/T = pick(spawn_turfs)
		var/mob/living/carbon/human/H = new(T)
		H.equipOutfit(/datum/outfit/ci_operative)
		var/datum/mind/M = new /datum/mind("")
		M.transfer_to(H)
		var/datum/antagonist/ci_operative/ci_antag = new()
		ci_antag.objective = ci_objective
		M.add_antag_datum(ci_antag)
		ci_operatives += H

/datum/game_mode/scp_ci_raid/process(delta_time)
	if(raid_phase >= 2)
		check_raid_status()

/datum/game_mode/scp_ci_raid/proc/check_raid_status()
	var/alive_ci = 0
	for(var/mob/living/carbon/human/H in ci_operatives)
		if(H.stat != DEAD)
			alive_ci++
	if(alive_ci == 0 && length(ci_operatives) > 0)
		raid_phase = 3
		priority_announce("NOTICE: Chaos Insurgency forces neutralized. Facility security restored.", "SECURITY UPDATE", sound_type = ANNOUNCER_DEFAULT)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/end_ci_raid), 2 MINUTES)

/datum/game_mode/scp_ci_raid/check_finished()
	..()
	if(!SSticker.setup_done)
		return FALSE
	if(raid_phase >= 3)
		return TRUE
	var/time_elapsed = world.time - raid_start_time
	if(time_elapsed > 90 MINUTES)
		return TRUE
	return FALSE

/datum/game_mode/scp_ci_raid/set_round_result()
	if(ci_extracted || scp_stolen)
		SSticker.mode_result = "Chaos Insurgency Victory"
	else if(length(ci_operatives) > 0)
		var/alive = 0
		for(var/mob/living/carbon/human/H in ci_operatives)
			if(H.stat != DEAD)
				alive++
		if(alive == 0)
			SSticker.mode_result = "Foundation Victory - CI Neutralized"
		else
			SSticker.mode_result = "Stalemate"
	else
		SSticker.mode_result = "Foundation Victory"

/datum/antagonist/ci_operative
	name = "Chaos Insurgency Operative"
	roundend_category = "Chaos Insurgency"
	antagpanel_category = "Chaos Insurgency"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSCP"
	var/objective = ""

/datum/antagonist/ci_operative/on_gain()
	. = ..()
	if(owner.current)
		to_chat(owner.current, span_warning("<B>You are a Chaos Insurgency Operative!</B>"))
		to_chat(owner.current, span_notice("Objective: [objective]"))
		to_chat(owner.current, span_notice("Use your equipment to complete the mission. Avoid detection."))
	var/datum/objective/ci_obj/obj = new()
	obj.explanation_text = objective
	obj.owner = owner
	objectives += obj
	var/datum/objective/scp_survive/survive = new()
	survive.owner = owner
	objectives += survive

/datum/objective/ci_obj
	name = "CI Objective"

/datum/outfit/ci_operative
	name = "Chaos Insurgency Operative"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/night
	ears = /obj/item/radio/headset/syndicate
	back = /obj/item/storage/backpack/duffelbag/syndie
	belt = /obj/item/storage/belt/military
	l_pocket = /obj/item/flashlight/emp
	r_pocket = /obj/item/knife/combat
	id = /obj/item/card/id/advanced/chameleon

/proc/end_ci_raid()
	SSticker.set_force_ending(TRUE)
