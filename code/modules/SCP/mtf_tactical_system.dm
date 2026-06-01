#define FORMATION_LINE "line"
#define FORMATION_WEDGE "wedge"
#define FORMATION_COLUMN "column"
#define FORMATION_SURROUND "surround"

#define ENGAGE_STANDARD "standard"
#define ENGAGE_LETHAL "lethal"
#define ENGAGE_CAPTURE "capture"
#define ENGAGE_OBSERVE "observe"

#define SQUAD_STANDBY "standby"
#define SQUAD_DEPLOYED "deployed"
#define SQUAD_ENGAGED "engaged"
#define SQUAD_EXTRACTING "extracting"

/datum/mtf_squad
	var/squad_name
	var/squad_leader
	var/list/squad_members = list()
	var/formation = FORMATION_LINE
	var/current_objective
	var/target_scp
	var/engagement_protocol = ENGAGE_STANDARD
	var/squad_status = SQUAD_STANDBY
	var/list/move_targets = list()

/datum/mtf_squad/proc/set_formation(new_formation)
	formation = new_formation
	update_formation_positions()

/datum/mtf_squad/proc/set_objective(objective)
	current_objective = objective
	switch(objective)
		if("sweep")
			engagement_protocol = ENGAGE_STANDARD
		if("contain")
			engagement_protocol = ENGAGE_CAPTURE
		if("escort")
			engagement_protocol = ENGAGE_OBSERVE
		if("guard")
			engagement_protocol = ENGAGE_STANDARD
	notify_squad("Objective updated: [objective]. Protocol: [engagement_protocol].")

/datum/mtf_squad/proc/deploy()
	squad_status = SQUAD_DEPLOYED
	notify_squad("Squad [squad_name] deployed. Formation: [formation]. Objective: [current_objective || "pending"].")

/datum/mtf_squad/proc/engage_target()
	squad_status = SQUAD_ENGAGED
	notify_squad("Squad [squad_name] engaging. Protocol: [engagement_protocol].")

/datum/mtf_squad/proc/extract()
	squad_status = SQUAD_EXTRACTING
	engagement_protocol = ENGAGE_OBSERVE
	notify_squad("Squad [squad_name] extracting. Fall back to extraction point.")

/datum/mtf_squad/proc/notify_squad(message)
	for(var/mob/living/carbon/human/H as anything in squad_members)
		if(H && H.client)
			to_chat(H, span_notice("[squad_name] COMMS: [message]"))

/datum/mtf_squad/proc/update_formation_positions()
	if(!squad_leader || !isturf(get_turf(squad_leader)))
		return
	var/turf/leader_turf = get_turf(squad_leader)
	var/datum/mtf_formation/formation_obj = new /datum/mtf_formation()
	var/list/positions = formation_obj.get_formation_positions(formation, leader_turf)
	var/i = 1
	for(var/mob/living/carbon/human/H as anything in squad_members)
		if(H == squad_leader)
			continue
		if(i > length(positions))
			break
		var/turf/target = positions[i]
		if(target)
			move_targets[H] = target
		i++

/datum/mtf_formation/proc/get_formation_positions(formation_type, turf/leader_turf)
	if(!leader_turf)
		return list()
	var/list/positions = list()
	var/leader_dir = leader_turf.dir
	switch(formation_type)
		if(FORMATION_LINE)
			var/turf/behind = get_step(leader_turf, turn(leader_dir, 180))
			if(behind)
				positions += behind
				var/turf/left = get_step(behind, turn(leader_dir, 90))
				var/turf/right = get_step(behind, turn(leader_dir, -90))
				if(left)
					positions += left
				if(right)
					positions += right
				var/turf/far_left = get_step(left, turn(leader_dir, 90))
				var/turf/far_right = get_step(right, turn(leader_dir, -90))
				if(far_left)
					positions += far_left
				if(far_right)
					positions += far_right
		if(FORMATION_WEDGE)
			var/turf/left_back = get_step(get_step(leader_turf, turn(leader_dir, 180)), turn(leader_dir, 90))
			var/turf/right_back = get_step(get_step(leader_turf, turn(leader_dir, 180)), turn(leader_dir, -90))
			if(left_back)
				positions += left_back
			if(right_back)
				positions += right_back
			var/turf/left_far = get_step(get_step(left_back, turn(leader_dir, 180)), turn(leader_dir, 90))
			var/turf/right_far = get_step(get_step(right_back, turn(leader_dir, 180)), turn(leader_dir, -90))
			if(left_far)
				positions += left_far
			if(right_far)
				positions += right_far
		if(FORMATION_COLUMN)
			var/turf/current = leader_turf
			for(var/i in 1 to 5)
				current = get_step(current, turn(leader_dir, 180))
				if(current)
					positions += current
		if(FORMATION_SURROUND)
			var/list/dirs = list(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST)
			for(var/d in dirs)
				var/turf/T = get_step(leader_turf, d)
				if(T)
					positions += T
	return positions

/datum/scp_engagement_protocol
	var/scp_type
	var/protocol_name
	var/list/directives = list()
	var/list/required_equipment = list()
	var/lethality_level = 0
	var/special_instructions

/proc/get_scp_engagement_protocol(scp_type)
	var/datum/scp_engagement_protocol/protocol = new()
	switch(scp_type)
		if("SCP-173")
			protocol.scp_type = "SCP-173"
			protocol.protocol_name = "SCP-173 Containment Protocol"
			protocol.directives = list(
				"Maintain direct observation at all times",
				"Minimum 3 personnel with line of sight",
				"Rotate observers every 30 seconds",
				"Report any blinking simultaneously",
			)
			protocol.required_equipment = list("flashlight", "restraint harness")
			protocol.lethality_level = 0
			protocol.special_instructions = "Maintain direct observation at all times. Minimum 3 personnel with line of sight. Rotate observers every 30 seconds. Report any blinking simultaneously."
		if("SCP-096")
			protocol.scp_type = "SCP-096"
			protocol.protocol_name = "SCP-096 Containment Protocol"
			protocol.directives = list(
				"DO NOT look at its face",
				"Approach from behind only",
				"Use bag/cover",
				"If triggered, evacuate area immediately",
				"Do not engage triggered 096",
			)
			protocol.required_equipment = list("blindfold", "containment bag")
			protocol.lethality_level = 0
			protocol.special_instructions = "DO NOT look at its face. Approach from behind only. Use bag/cover. If triggered, evacuate area immediately. Do not engage triggered 096."
		if("SCP-106")
			protocol.scp_type = "SCP-106"
			protocol.protocol_name = "SCP-106 Containment Protocol"
			protocol.directives = list(
				"Use magnetic restraint protocol",
				"Lure with femur breaker if available",
				"Do not pursue into walls",
				"Report corrosion immediately",
			)
			protocol.required_equipment = list("magnetic restraints", "femur breaker")
			protocol.lethality_level = 1
			protocol.special_instructions = "Use magnetic restraint protocol. Lure with femur breaker if available. Do not pursue into walls. Report corrosion immediately."
		if("SCP-049")
			protocol.scp_type = "SCP-049"
			protocol.protocol_name = "SCP-049 Containment Protocol"
			protocol.directives = list(
				"Maintain 5m distance",
				"Do not allow physical contact",
				"If contact made, quarantine subject immediately",
				"Monitor for pestilence signs",
			)
			protocol.required_equipment = list("hazmat suit", "quarantine supplies")
			protocol.lethality_level = 1
			protocol.special_instructions = "Maintain 5m distance. Do not allow physical contact. If contact made, quarantine subject immediately. Monitor for pestilence signs."
		if("SCP-079")
			protocol.scp_type = "SCP-079"
			protocol.protocol_name = "SCP-079 Containment Protocol"
			protocol.directives = list(
				"Isolate from network",
				"Use analog backup systems",
				"Do not connect any digital equipment",
				"Report any door/light anomalies",
			)
			protocol.required_equipment = list("analog tools", "faraday cage materials")
			protocol.lethality_level = 0
			protocol.special_instructions = "Isolate from network. Use analog backup systems. Do not connect any digital equipment. Report any door/light anomalies."
		if("SCP-457")
			protocol.scp_type = "SCP-457"
			protocol.protocol_name = "SCP-457 Containment Protocol"
			protocol.directives = list(
				"Use Class A foam extinguishers",
				"Maintain 10m distance",
				"Do not use flammable materials",
				"Ventilate area if possible",
			)
			protocol.required_equipment = list("Class A foam extinguisher", "fire suit")
			protocol.lethality_level = 1
			protocol.special_instructions = "Use Class A foam extinguishers. Maintain 10m distance. Do not use flammable materials. Ventilate area if possible."
		if("SCP-939")
			protocol.scp_type = "SCP-939"
			protocol.protocol_name = "SCP-939 Containment Protocol"
			protocol.directives = list(
				"Approach silently",
				"No verbal communication near target",
				"Use visual hand signals only",
				"Attack from multiple angles simultaneously",
			)
			protocol.required_equipment = list("suppressed weapons", "flashbangs")
			protocol.lethality_level = 2
			protocol.special_instructions = "Approach silently. No verbal communication near target. Use visual hand signals only. Attack from multiple angles simultaneously."
		if("SCP-682")
			protocol.scp_type = "SCP-682"
			protocol.protocol_name = "SCP-682 Containment Protocol"
			protocol.directives = list(
				"Lethal force authorized",
				"Use heavy weapons only",
				"Maintain maximum distance",
				"Do not approach wounded 682",
				"Call for reinforcement",
			)
			protocol.required_equipment = list("heavy weapons", "explosive ordnance")
			protocol.lethality_level = 2
			protocol.special_instructions = "Lethal force authorized. Use heavy weapons only. Maintain maximum distance. Do not approach wounded 682. Call for reinforcement."
		if("SCP-008")
			protocol.scp_type = "SCP-008"
			protocol.protocol_name = "SCP-008 Containment Protocol"
			protocol.directives = list(
				"Full biohazard protocol",
				"Wear Class B hazmat suits",
				"Incinerate all contaminated materials",
				"Quarantine all exposed personnel",
			)
			protocol.required_equipment = list("Class B hazmat suit", "incinerator access")
			protocol.lethality_level = 2
			protocol.special_instructions = "Full biohazard protocol. Wear Class B hazmat suits. Incinerate all contaminated materials. Quarantine all exposed personnel."
		else
			protocol.scp_type = scp_type
			protocol.protocol_name = "[scp_type] Standard Protocol"
			protocol.directives = list("Assess threat level", "Establish perimeter", "Await specialist team")
			protocol.lethality_level = 0
			protocol.special_instructions = "Standard containment procedures apply."
	return protocol

GLOBAL_LIST_EMPTY(mtf_squads)

/proc/create_mtf_squad(squad_name, list/members)
	var/datum/mtf_squad/squad = new()
	squad.squad_name = squad_name
	squad.squad_members = members
	if(length(members))
		squad.squad_leader = members[1]
	GLOB.mtf_squads += squad
	return squad

/obj/machinery/computer/mtf_tactical_console
	name = "MTF Tactical Console"
	desc = "A secure console for coordinating MTF squad tactics and engagement protocols."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200

/obj/machinery/computer/mtf_tactical_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MTFTacticalConsole", "MTF Tactical Command")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/mtf_tactical_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/mtf_tactical_console/ui_data(mob/user)
	var/list/data = list()
	var/list/squads = list()
	for(var/datum/mtf_squad/squad as anything in GLOB.mtf_squads)
		var/leader_name = "None"
		if(squad.squad_leader && istype(squad.squad_leader, /mob/living))
			var/mob/living/L = squad.squad_leader
			leader_name = L.real_name
		squads += list(list(
			"squad_name" = squad.squad_name,
			"leader" = leader_name,
			"member_count" = length(squad.squad_members),
			"formation" = squad.formation,
			"objective" = squad.current_objective || "none",
			"target_scp" = squad.target_scp || "none",
			"engagement_protocol" = squad.engagement_protocol,
			"status" = squad.squad_status,
		))
	data["squads"] = squads
	data["formations"] = list(FORMATION_LINE, FORMATION_WEDGE, FORMATION_COLUMN, FORMATION_SURROUND)
	data["objectives"] = list("sweep", "contain", "escort", "guard")
	data["protocols"] = list(ENGAGE_STANDARD, ENGAGE_LETHAL, ENGAGE_CAPTURE, ENGAGE_OBSERVE)
	data["scp_targets"] = list("SCP-173", "SCP-096", "SCP-106", "SCP-049", "SCP-079", "SCP-457", "SCP-939", "SCP-682", "SCP-008")
	return data

/obj/machinery/computer/mtf_tactical_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(ui.user))
		return
	var/mob/living/carbon/human/H = ui.user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(H, span_warning("Requires Security access."))
		return
	switch(action)
		if("set_formation")
			var/squad_name = params["squad_name"]
			var/new_formation = params["formation"]
			if(!squad_name || !new_formation)
				return
			var/datum/mtf_squad/squad = find_squad(squad_name)
			if(!squad)
				return
			squad.set_formation(new_formation)
			. = TRUE
		if("set_objective")
			var/squad_name = params["squad_name"]
			var/objective = params["objective"]
			if(!squad_name || !objective)
				return
			var/datum/mtf_squad/squad = find_squad(squad_name)
			if(!squad)
				return
			squad.set_objective(objective)
			. = TRUE
		if("assign_protocol")
			var/squad_name = params["squad_name"]
			var/scp_target = params["scp_target"]
			if(!squad_name || !scp_target)
				return
			var/datum/mtf_squad/squad = find_squad(squad_name)
			if(!squad)
				return
			squad.target_scp = scp_target
			var/datum/scp_engagement_protocol/protocol = get_scp_engagement_protocol(scp_target)
			squad.engagement_protocol = protocol.lethality_level >= 2 ? ENGAGE_LETHAL : (protocol.lethality_level >= 1 ? ENGAGE_CAPTURE : ENGAGE_STANDARD)
			squad.notify_squad("Engagement protocol assigned for [scp_target]: [protocol.protocol_name]. Lethality: [protocol.lethality_level]. [protocol.special_instructions]")
			. = TRUE
		if("deploy_squad")
			var/squad_name = params["squad_name"]
			if(!squad_name)
				return
			var/datum/mtf_squad/squad = find_squad(squad_name)
			if(!squad)
				return
			squad.deploy()
			. = TRUE
		if("extract_squad")
			var/squad_name = params["squad_name"]
			if(!squad_name)
				return
			var/datum/mtf_squad/squad = find_squad(squad_name)
			if(!squad)
				return
			squad.extract()
			. = TRUE

/obj/machinery/computer/mtf_tactical_console/proc/find_squad(squad_name)
	for(var/datum/mtf_squad/squad as anything in GLOB.mtf_squads)
		if(squad.squad_name == squad_name)
			return squad
	return null
