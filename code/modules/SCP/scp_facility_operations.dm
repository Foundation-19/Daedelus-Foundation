// ============================================================================
// #3 SCP SPECIMEN COLLECTION — Physical sample vials from contained SCPs
// ============================================================================

/obj/item/scp_sample_vial
	name = "specimen vial"
	desc = "A sealed vial containing an anomalous specimen sample. Deliver to a research console for analysis."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vial"
	w_class = WEIGHT_CLASS_TINY
	var/scp_designation = "unknown"
	var/scp_class = "unknown"
	var/research_value = 15
	var/analyzed = FALSE
	var/collector_ckey

/obj/item/scp_sample_vial/examine(mob/user)
	. = ..()
	. += span_notice("Specimen: [scp_designation]")
	. += span_notice("Classification: [scp_class]")
	if(analyzed)
		. += span_notice("Status: Analyzed")
	else
		. += span_warning("Status: Unanalyzed — deliver to research console")

/obj/item/scp_sample_vial/attack_self(mob/user)
	if(analyzed)
		to_chat(user, span_notice("This sample has already been analyzed."))
		return
	to_chat(user, span_notice("You carefully seal [src]. Deliver it to a research console for analysis."))

/obj/item/scp_sample_vial/proc/analyze(mob/user)
	if(analyzed)
		return FALSE
	analyzed = TRUE
	var/bonus = round(research_value * 0.5)
	adjust_global_research_points(research_value + bonus, "sample_analysis:[scp_designation]")
	if(user)
		hook_scp_interaction(user, scp_designation, INTERACTION_TYPE_RESEARCH, list("analysis" = TRUE))
		to_chat(user, span_notice("Sample analyzed: [scp_designation] ([scp_class]). Research points: [research_value + bonus]"))
	return TRUE

/obj/item/scp_sample_kit
	name = "SCP Specimen Collection Kit"
	desc = "A sterile kit for taking biological and material samples from contained SCPs. Creates sealed vials for delivery to research consoles."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringe_kit"
	w_class = WEIGHT_CLASS_SMALL
	var/vials_remaining = 5
	var/sample_cooldown = 0
	var/sample_cooldown_time = 30 SECONDS

/obj/item/scp_sample_kit/examine(mob/user)
	. = ..()
	. += span_notice("Empty vials remaining: [vials_remaining]")
	. += span_notice("Use on a contained SCP to collect a specimen sample.")

/obj/item/scp_sample_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(!ishuman(user))
		return
	if(!istype(target, /mob/living/scp) && !istype(target, /mob/living/scp079) && !istype(target, /mob/living/scp035))
		return
	if(vials_remaining <= 0)
		to_chat(user, span_warning("No empty vials remaining in the kit!"))
		return
	if(world.time < sample_cooldown)
		to_chat(user, span_warning("The sample kit is recharging..."))
		return
	var/mob/living/L = target
	if(L.stat == DEAD)
		to_chat(user, span_warning("This specimen is dead — samples would be contaminated."))
		return
	var/iscp = istype(L, /mob/living/scp)
	if(iscp && L:containment_status != "contained")
		to_chat(user, span_warning("It's too dangerous to sample an uncontained SCP!"))
		return
	to_chat(user, span_notice("You begin collecting a sample from [L]..."))
	if(!do_after(user, target, 4 SECONDS))
		return
	sample_cooldown = world.time + sample_cooldown_time
	vials_remaining--
	var/scp_designation = "Unknown Entity"
	var/scp_class = "Unknown"
	var/research_value = 15
	if(istype(L, /mob/living/scp))
		var/mob/living/scp/S = L
		scp_designation = S.SCP?.designation ? "SCP-[S.SCP.designation]" : "Unknown Entity"
		scp_class = capitalize(S.SCP?.classification || "unknown")
		if(S.SCP?.classification == "keter")
			research_value = 40
		else if(S.SCP?.classification == "euclid")
			research_value = 25
	else if(istype(L, /mob/living/scp035))
		scp_designation = "SCP-035"
		scp_class = "Euclid"
		research_value = 30
	else if(istype(L, /mob/living/scp079))
		scp_designation = "SCP-079"
		scp_class = "Euclid"
		research_value = 30
	var/obj/item/scp_sample_vial/vial = new(get_turf(user))
	vial.scp_designation = scp_designation
	vial.scp_class = scp_class
	vial.research_value = research_value
	vial.collector_ckey = user.ckey
	vial.name = "[scp_designation] specimen vial"
	vial.desc = "A sealed vial containing a sample from [scp_designation] ([scp_class]). Deliver to a research console for analysis."
	user.put_in_hands(vial)
	hook_scp_interaction(user, scp_designation, INTERACTION_TYPE_RESEARCH, list("sample_collected" = TRUE))
	to_chat(user, span_notice("You collect a sample from [L]. Vial created. ([vials_remaining] vials remaining)"))

/obj/item/scp_sample_kit/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/scp_sample_vial))
		var/obj/item/scp_sample_vial/vial = W
		if(vial.analyzed)
			to_chat(user, span_notice("This vial has already been analyzed. No need to return it."))
			return
		to_chat(user, span_notice("You place the unanalyzed vial back into the kit for safe transport."))
		qdel(vial)
		vials_remaining++
		return
	return ..()

// ============================================================================
// #4 D-CLASS CONTRABAND WIRING — Convert abstract contraband to physical items
// ============================================================================

/datum/dclass_player/proc/convert_contraband_to_items(mob/living/carbon/human/H)
	if(!H)
		return
	for(var/contraband_type in contraband)
		var/count = contraband[contraband_type]
		if(count <= 0)
			continue
		var/item_type = get_contraband_item_type(contraband_type)
		if(!item_type)
			continue
		for(var/i in 1 to count)
			var/obj/item/dclass_contraband/item = new item_type(get_turf(H))
			H.put_in_hands(item)
	contraband = list()

/datum/dclass_player/proc/get_contraband_item_type(contraband_type)
	switch(contraband_type)
		if("wire")
			return /obj/item/dclass_contraband/wire
		if("screwdriver")
			return /obj/item/dclass_contraband/screwdriver
		if("wrench")
			return /obj/item/dclass_contraband/wrench
		if("knife")
			return /obj/item/dclass_contraband/knife
		if("lockpick")
			return /obj/item/dclass_contraband/lockpick
		if("improvised_tool")
			return /obj/item/dclass_contraband/improvised_tool
		if("staff_uniform")
			return /obj/item/dclass_contraband/staff_uniform
		if("fake_id")
			return /obj/item/dclass_contraband/fake_id
		if("mask")
			return /obj/item/dclass_contraband/mask
		if("metal_pipe")
			return /obj/item/dclass_contraband/metal_pipe
		if("fabric_scraps")
			return /obj/item/dclass_contraband/fabric_scraps
		if("thread")
			return /obj/item/dclass_contraband/thread
		if("medicine")
			return /obj/item/dclass_contraband/medicine
		if("bandages")
			return /obj/item/dclass_contraband/bandages
		if("chemicals")
			return /obj/item/dclass_contraband/chemicals
		if("cutting_tool")
			return /obj/item/dclass_contraband/cutting_tool
		if("electronics")
			return /obj/item/dclass_contraband/electronics
	return null

/datum/dclass_player/proc/add_physical_contraband(contraband_type, count = 1)
	if(!contraband_type)
		return
	contraband[contraband_type] = (contraband[contraband_type] || 0) + count

// Guard search proc — removes physical contraband from D-Class
/mob/living/carbon/human/proc/search_for_contraband(mob/living/carbon/human/searcher)
	if(!istype(searcher))
		return
	var/found = 0
	var/list/contraband_items = list()
	for(var/obj/item/dclass_contraband/C in contents)
		contraband_items += C
		found++
	if(found == 0)
		to_chat(searcher, span_notice("[src] has no contraband."))
		return
	for(var/obj/item/dclass_contraband/C in contraband_items)
		qdel(C)
	var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[ckey]
	if(player)
		player.suspicion_level += found * 15
		player.add_incident("contraband_found", "[found] contraband items confiscated by [searcher.name]", "major")
	to_chat(searcher, span_notice("You find and confiscate [found] contraband item(s) from [src]!"))
	to_chat(src, span_warning("[searcher] searches you and confiscates your contraband!"))

// ============================================================================
// #5 ZONE LOCKDOWN CONSOLE — Guards can lock zone transitions
// ============================================================================

/obj/machinery/computer/scp_zone_lockdown
	name = "Zone Lockdown Console"
	desc = "A secure console for locking down zone transitions during containment emergencies."
	icon = 'icons/obj/computer.dmi'
	icon_state = "security"
	circuit = /obj/item/circuitboard/computer/scp_zone_lockdown
	req_access = list(ACCESS_SECURITY_LVL3)
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/list/zone_states = list(
		"lcz" = FALSE,
		"hcz" = FALSE,
		"ez" = FALSE,
		"surface" = FALSE,
	)
	var/lockdown_cooldown = 0
	var/lockdown_cooldown_time = 30 SECONDS

/obj/machinery/computer/scp_zone_lockdown/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPZoneLockdown", "ZONE LOCKDOWN CONSOLE")
		ui.open()

/obj/machinery/computer/scp_zone_lockdown/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/scp_zone_lockdown/ui_data(mob/user)
	var/list/data = list()
	data["zone_states"] = zone_states
	data["cooldown"] = max(0, lockdown_cooldown - world.time)
	return data

/obj/machinery/computer/scp_zone_lockdown/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(world.time < lockdown_cooldown)
		return
	switch(action)
		if("toggle_zone")
			var/zone = params["zone"]
			if(!(zone in zone_states))
				return
			zone_states[zone] = !zone_states[zone]
			lockdown_cooldown = world.time + lockdown_cooldown_time
			apply_zone_lockdown(zone, zone_states[zone])
			. = TRUE
		if("lockdown_all")
			for(var/zone in zone_states)
				zone_states[zone] = TRUE
				apply_zone_lockdown(zone, TRUE)
			lockdown_cooldown = world.time + lockdown_cooldown_time
			priority_announce("ATTENTION: Full facility zone lockdown initiated. All zone transitions are now sealed.", "ZONE LOCKDOWN", null, ANNOUNCER_ALERT)
			. = TRUE
		if("unlock_all")
			for(var/zone in zone_states)
				zone_states[zone] = FALSE
				apply_zone_lockdown(zone, FALSE)
			lockdown_cooldown = world.time + lockdown_cooldown_time
			priority_announce("Zone lockdown lifted. All zone transitions are now open.", "LOCKDOWN LIFTED", null, ANNOUNCER_ALERT)
			. = TRUE

/obj/machinery/computer/scp_zone_lockdown/proc/apply_zone_lockdown(zone, locked)
	var/list/zone_areas
	switch(zone)
		if("lcz")
			zone_areas = typecacheof(/area/scp/lcz)
		if("hcz")
			zone_areas = typecacheof(/area/scp/hcz)
		if("ez")
			zone_areas = typecacheof(/area/scp/ez)
		if("surface")
			zone_areas = typecacheof(/area/scp/surface)
		else
			return
	if(!zone_areas)
		return
	for(var/area/A in GLOB.areas)
		if(!zone_areas[A.type])
			continue
		for(var/obj/machinery/door/airlock/D in A)
			if(locked)
				D.lock()
			else
				D.unlock()

/obj/item/circuitboard/computer/scp_zone_lockdown
	name = "Zone Lockdown Console (Computer Board)"
	build_path = /obj/machinery/computer/scp_zone_lockdown

// ============================================================================
// #6 SECURITY CAMERA AUTO-ALERT — Detects SCPs on camera network
// ============================================================================

SUBSYSTEM_DEF(scp_camera_alerts)
	name = "SCP Camera Alerts"
	wait = 30 SECONDS
	priority = FIRE_PRIORITY_INPUT
	var/last_alert_time = 0
	var/alert_cooldown = 60 SECONDS
	var/active_breaches = 0

/datum/controller/subsystem/scp_camera_alerts/fire()
	if(world.time < last_alert_time + alert_cooldown)
		return
	var/list/alerts = list()
	var/breach_count = 0
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(S.stat == DEAD || S.containment_status != "breached")
			continue
		breach_count++
		var/area/A = get_area(S)
		if(!A)
			continue
		var/has_cameras = FALSE
		for(var/obj/machinery/camera/C in A)
			if(C.status)
				has_cameras = TRUE
				break
		if(!has_cameras)
			continue
		var/scp_id = S.SCP?.designation ? "SCP-[S.SCP.designation]" : "Unknown SCP"
		alerts += "[scp_id] detected in [A.name]"
	active_breaches = breach_count
	if(!length(alerts))
		return
	last_alert_time = world.time
	for(var/obj/item/radio/R in GLOB.all_radios)
		if(!istype(R, /obj/item/radio/headset/scp_security))
			continue
		var/mob/living/carbon/human/wearer = R.loc
		if(!istype(wearer) || wearer.get_item_by_slot(ITEM_SLOT_EARS) != R)
			continue
		to_chat(wearer, span_warning("<b>CAMERA ALERT:</b> [jointext(alerts, "; ")]"))

// ============================================================================
// #7 D-CLASS ACTIVE WORK TASKS — Click-based tasks instead of AFK
// ============================================================================

/obj/machinery/dclass_work_station
	name = "Work Station"
	desc = "A workstation for D-Class labor assignments. Click to complete your assigned task."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/task_type = "generic"
	var/task_cooldown = 0
	var/task_cooldown_time = 30 SECONDS
	var/credits_reward = 10
	var/trust_reward = 2
	var/xp_reward = 15

/obj/machinery/dclass_work_station/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(world.time < task_cooldown)
		to_chat(H, span_warning("The workstation is still processing the last task."))
		return
	var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[H.ckey]
	if(!player)
		to_chat(H, span_warning("You are not registered in the D-Class system."))
		return
	to_chat(H, span_notice("You begin working on [task_type] task..."))
	if(!do_after(H, src, 5 SECONDS))
		return
	task_cooldown = world.time + task_cooldown_time
	player.adjust_credits(credits_reward)
	player.adjust_trust(trust_reward, "Work task completed")
	player.tests_completed++
	player.gain_experience(xp_reward, "[task_type] work task")
	if(player.current_work_assignment && findtext(player.current_work_assignment, task_type))
		player.current_work_assignment = null
	to_chat(H, span_notice("Task completed! Credits: +[credits_reward] Trust: +[trust_reward] XP: +[xp_reward]"))

/obj/machinery/dclass_work_station/kitchen
	name = "Kitchen Work Station"
	task_type = "kitchen"
	credits_reward = 12

/obj/machinery/dclass_work_station/laundry
	name = "Laundry Work Station"
	icon_state = "dishwasher"
	task_type = "laundry"
	credits_reward = 8

/obj/machinery/dclass_work_station/janitorial
	name = "Janitorial Work Station"
	icon_state = "autolathe"
	task_type = "janitorial"
	credits_reward = 10

/obj/machinery/dclass_work_station/maintenance
	name = "Maintenance Work Station"
	icon_state = "repair"
	task_type = "maintenance"
	credits_reward = 15
	trust_reward = 3

// ============================================================================
// #9 CONTAINMENT CHAMBER REINFORCEMENT — Engineers upgrade cells
// ============================================================================

/obj/structure/containment_upgrade_frame
	name = "containment upgrade frame"
	desc = "A mounting frame for containment reinforcement upgrades. Apply reinforced sheets or telekill to complete."
	icon = 'icons/obj/structures.dmi'
	icon_state = "rack_parts"
	density = FALSE
	anchored = TRUE
	var/upgrade_type = "none"
	var/upgrade_progress = 0
	var/upgrade_required = 3

/obj/structure/containment_upgrade_frame/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/S = W
		if(upgrade_type == "telekill")
			to_chat(user, span_warning("This frame is configured for telekill, not plasteel."))
			return
		upgrade_type = "reinforced"
		if(S.use(1))
			upgrade_progress++
			to_chat(user, span_notice("You reinforce the frame. Progress: [upgrade_progress]/[upgrade_required]"))
			check_completion()
		return
	if(istype(W, /obj/item/stack/sheet/telekill))
		var/obj/item/stack/sheet/S = W
		if(upgrade_type == "reinforced")
			to_chat(user, span_warning("This frame is configured for plasteel, not telekill."))
			return
		upgrade_type = "telekill"
		if(S.use(1))
			upgrade_progress++
			to_chat(user, span_notice("You line the frame with telekill. Progress: [upgrade_progress]/[upgrade_required]"))
			check_completion()
		return
	if(istype(W, /obj/item/wrench))
		to_chat(user, span_notice("You dismantle the upgrade frame."))
		qdel(src)
		return
	return ..()

/obj/structure/containment_upgrade_frame/proc/check_completion()
	if(upgrade_progress < upgrade_required)
		return
	visible_message(span_notice("The containment upgrade is complete!"))
	var/breach_reduction = 0
	var/sanity_resist = 0
	switch(upgrade_type)
		if("reinforced")
			breach_reduction = 10
		if("telekill")
			breach_reduction = 5
			sanity_resist = 0.1
	var/area/A = get_area(src)
	if(A)
		for(var/mob/living/scp/S in A)
			S.containment_resistance = min(S.max_containment_resistance, S.containment_resistance + breach_reduction)
			if(sanity_resist > 0 && SSscp_research?.manager)
				SSscp_research.manager.cognitive_bonus += sanity_resist
	if(breach_reduction > 0)
		apply_containment_upgrade_to_area(A, breach_reduction)
	qdel(src)

/obj/structure/containment_upgrade_frame/proc/apply_containment_upgrade_to_area(area/A, bonus)
	if(!A)
		return
	for(var/turf/closed/wall/scp_containment/W in A)
		W.containment_integrity = min(W.max_containment_integrity, W.containment_integrity + 50)

// ============================================================================
// #10 ROLE-SPECIFIC ROUND OBJECTIVES
// ============================================================================

/datum/round_objective
	var/objective_id
	var/title
	var/description
	var/target_progress = 1
	var/current_progress = 0
	var/completed = FALSE
	var/reward_xp = 100
	var/role_requirement

/datum/round_objective/proc/check_completion()
	if(current_progress >= target_progress)
		completed = TRUE
	return completed

/datum/round_objective/proc/make_progress(amount = 1)
	current_progress += amount
	check_completion()

/datum/round_objective/guard_recontain
	objective_id = "guard_recontain"
	title = "Recontainment Duty"
	description = "Assist in recontaining at least 1 breached SCP this shift."
	role_requirement = "Guard"

/datum/round_objective/research_unlock
	objective_id = "research_unlock"
	title = "Research Progress"
	description = "Unlock at least 2 technology nodes this shift."
	target_progress = 2
	role_requirement = "Scientist"

/datum/round_objective/dclass_survive
	objective_id = "dclass_survive"
	title = "Survive the Shift"
	description = "Remain alive until the end of the shift."
	role_requirement = "D-Class"

/datum/round_objective/engineer_repair
	objective_id = "engineer_repair"
	title = "Facility Maintenance"
	description = "Repair at least 3 containment walls or APCs this shift."
	target_progress = 3
	role_requirement = "Engineer"

/datum/round_objective/medical_treat
	objective_id = "medical_treat"
	title = "Medical Duty"
	description = "Treat at least 5 patients this shift."
	target_progress = 5
	role_requirement = "Medical Doctor"

/datum/round_objective/command_direct
	objective_id = "command_direct"
	title = "Facility Command"
	description = "Maintain facility stability above 50% throughout the shift."
	role_requirement = "Site Director"

// Round objective manager
SUBSYSTEM_DEF(round_objectives)
	name = "Round Objectives"
	wait = 60 SECONDS
	priority = FIRE_PRIORITY_INPUT
	var/list/datum/round_objective/objectives = list()
	var/objectives_assigned = FALSE

/datum/controller/subsystem/round_objectives/Initialize()
	. = ..()
	assign_objectives()

/datum/controller/subsystem/round_objectives/fire()
	check_all_objectives()

/datum/controller/subsystem/round_objectives/proc/assign_objectives()
	if(objectives_assigned)
		return
	objectives_assigned = TRUE
	var/list/objective_types = list(
		/datum/round_objective/guard_recontain,
		/datum/round_objective/research_unlock,
		/datum/round_objective/dclass_survive,
		/datum/round_objective/engineer_repair,
		/datum/round_objective/medical_treat,
		/datum/round_objective/command_direct,
	)
	for(var/otype in objective_types)
		var/datum/round_objective/O = new otype()
		objectives[O.objective_id] = O
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		assign_role_objective(H)

/datum/controller/subsystem/round_objectives/proc/assign_role_objective(mob/living/carbon/human/H)
	if(!H.mind?.assigned_role)
		return
	var/job_title = H.mind.assigned_role.title
	var/datum/round_objective/assigned
	if(findtext(job_title, "Guard") || findtext(job_title, "Security"))
		assigned = objectives["guard_recontain"]
	else if(findtext(job_title, "Scientist") || findtext(job_title, "Research"))
		assigned = objectives["research_unlock"]
	else if(findtext(job_title, "D-Class"))
		assigned = objectives["dclass_survive"]
	else if(findtext(job_title, "Engineer") || findtext(job_title, "Containment Engineer"))
		assigned = objectives["engineer_repair"]
	else if(findtext(job_title, "Medical") || findtext(job_title, "Doctor") || findtext(job_title, "Chemist"))
		assigned = objectives["medical_treat"]
	else if(findtext(job_title, "Director") || findtext(job_title, "Captain"))
		assigned = objectives["command_direct"]
	if(assigned)
		to_chat(H, span_notice("<b>ROUND OBJECTIVE:</b> [assigned.title] — [assigned.description]"))

/datum/controller/subsystem/round_objectives/proc/check_all_objectives()
	for(var/obj_id in objectives)
		var/datum/round_objective/O = objectives[obj_id]
		if(O.completed)
			continue
		if(O.objective_id == "dclass_survive")
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(findtext(H.job, "D-Class") && H.stat != DEAD)
					O.current_progress = 1
		if(O.objective_id == "command_direct")
			if(SSscp_persistence?.manager)
				O.current_progress = (SSscp_persistence.manager.global_containment_stability >= 50) ? 1 : 0

/datum/controller/subsystem/round_objectives/proc/report_objective_progress(obj_id, amount = 1)
	var/datum/round_objective/O = objectives[obj_id]
	if(!O || O.completed)
		return
	O.make_progress(amount)
	if(O.completed)
		priority_announce("ROUND OBJECTIVE COMPLETE: [O.title] — [O.description]", "OBJECTIVE UPDATE", null, ANNOUNCER_ALERT)

// ============================================================================
// #11 FOUNDATION PA ANNOUNCEMENT CONSOLE
// ============================================================================

/obj/machinery/computer/foundation_pa
	name = "Foundation PA Console"
	desc = "A console for making facility-wide or zone-targeted public address announcements."
	icon = 'icons/obj/computer.dmi'
	icon_state = "comm"
	circuit = /obj/item/circuitboard/computer/foundation_pa
	req_access = list(ACCESS_SECURITY)
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/announcement_cooldown = 0
	var/announcement_cooldown_time = 30 SECONDS

/obj/machinery/computer/foundation_pa/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationPA", "FOUNDATION PA SYSTEM")
		ui.open()

/obj/machinery/computer/foundation_pa/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/foundation_pa/ui_data(mob/user)
	var/list/data = list()
	data["cooldown"] = max(0, announcement_cooldown - world.time)
	data["zones"] = list("All Zones", "LCZ", "HCZ", "EZ", "Surface")
	return data

/obj/machinery/computer/foundation_pa/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "announce")
		if(world.time < announcement_cooldown)
			return
		var/message = params["message"]
		var/zone = params["zone"]
		if(!message)
			return
		announcement_cooldown = world.time + announcement_cooldown_time
		var/sender_name = usr.name || "Unknown"
		var/full_message = "[sender_name] announces: [message]"
		if(zone == "All Zones")
			priority_announce(full_message, "FOUNDATION ANNOUNCEMENT", null, ANNOUNCER_ALERT)
		else
			var/area_type
			switch(lowertext(zone))
				if("lcz")
					area_type = /area/scp/lcz
				if("hcz")
					area_type = /area/scp/hcz
				if("ez")
					area_type = /area/scp/ez
				if("surface")
					area_type = /area/scp/surface
			if(area_type)
				for(var/mob/M in GLOB.player_list)
					var/area/A = get_area(M)
					if(istype(A, area_type) || istype(A, /area/site53))
						to_chat(M, span_boldannounce("[zone] ANNOUNCEMENT: [full_message]"))
		. = TRUE

/obj/item/circuitboard/computer/foundation_pa
	name = "Foundation PA Console (Computer Board)"
	build_path = /obj/machinery/computer/foundation_pa

// ============================================================================
// #12 MID-ROUND ANOMALOUS EVENTS
// ============================================================================

/datum/round_event/anomalous_pulse
	var/pulse_type

/datum/round_event/anomalous_pulse/sanity_pulse
	pulse_type = "sanity"

/datum/round_event/anomalous_pulse/spatial_distortion
	pulse_type = "spatial"

/datum/round_event/anomalous_pulse/spontaneous_manifestation
	pulse_type = "manifestation"

/proc/trigger_anomalous_pulse(pulse_type, target_zone)
	switch(pulse_type)
		if("sanity")
			var/list/targets = list()
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.stat == DEAD)
					continue
				if(target_zone)
					var/area/A = get_area(H)
					if(!istype(A, text2path("/area/scp/[target_zone]")) && !istype(A, text2path("/area/site53/[target_zone]")))
						continue
				targets += H
			if(length(targets))
				var/mob/living/carbon/human/victim = pick(targets)
				if(victim.sanity)
					victim.sanity.adjust_sanity(-15, "anomalous_pulse")
					to_chat(victim, span_warning("A wave of unease washes over you... your thoughts feel hazy."))
		if("spatial")
			var/list/targets = list()
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.stat == DEAD)
					continue
				targets += H
			if(length(targets))
				var/mob/living/carbon/human/victim = pick(targets)
				var/turf/T = get_turf(victim)
				var/list/nearby = list()
				for(var/turf/open/O in RANGE_TURFS(5, T))
					nearby += O
				if(length(nearby))
					var/turf/target_turf = pick(nearby)
					victim.forceMove(target_turf)
					to_chat(victim, span_warning("Space seems to fold around you for a moment... you're somewhere else!"))
		if("manifestation")
			var/list/manifest_types = list(
				/obj/item/reagent_containers/food/snacks/cookie,
				/obj/item/stack/sheet/iron,
				/obj/item/flashlight,
			)
			var/spawn_type = pick(manifest_types)
			var/list/turfs = list()
			for(var/area/scp/SA in GLOB.areas)
				for(var/turf/open/O in SA)
					if(isspaceturf(O))
						continue
					turfs += O
					if(length(turfs) > 100)
						break
				if(length(turfs) > 100)
					break
			if(length(turfs))
				var/turf/T = pick(turfs)
				new spawn_type(T)

// ============================================================================
// #13 SCP EVOLUTION — SCPs grow stronger from interactions
// ============================================================================

/mob/living/scp/proc/evolve_from_interaction()
	if(stat == DEAD)
		return
	melee_damage_lower = min(melee_damage_lower + 2, melee_damage_upper + 10)
	melee_damage_upper = min(melee_damage_upper + 3, 100)
	move_force = min(move_force + 5, MOVE_FORCE_OVERPOWERING)
	pull_force = min(pull_force + 5, MOVE_FORCE_OVERPOWERING)

// ============================================================================
// #14 FOUNDATION EVACUATION SHUTTLE
// ============================================================================

/obj/machinery/computer/foundation_evacuation
	name = "Foundation Evacuation Console"
	desc = "Emergency evacuation console. Only the Site Director or Captain may authorize evacuation."
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	circuit = /obj/item/circuitboard/computer/foundation_evacuation
	req_access = list(ACCESS_ADMIN_LVL5)
	density = TRUE
	anchored = TRUE
	var/evacuation_called = FALSE
	var/evacuation_timer
	var/evacuation_delay = 3 MINUTES

/obj/machinery/computer/foundation_evacuation/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationEvacuation", "FOUNDATION EVACUATION")
		ui.open()

/obj/machinery/computer/foundation_evacuation/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/foundation_evacuation/ui_data(mob/user)
	var/list/data = list()
	data["evacuation_called"] = evacuation_called
	data["time_remaining"] = evacuation_timer ? max(0, (evacuation_timer - world.time) / 10) : 0
	data["security_level"] = SSsecurity_level ? SSsecurity_level.current_level : 0
	return data

/obj/machinery/computer/foundation_evacuation/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "call_evacuation")
		if(evacuation_called)
			return
		if(SSsecurity_level && SSsecurity_level.current_level < SEC_LEVEL_RED)
			to_chat(usr, span_warning("Evacuation requires Code Red or higher security level."))
			return
		evacuation_called = TRUE
		evacuation_timer = world.time + evacuation_delay
		priority_announce("EMERGENCY EVACUATION AUTHORIZED. All personnel proceed to surface helipad immediately. Evacuation shuttle departs in [evacuation_delay / 600] minutes.", "EVACUATION", null, ANNOUNCER_ALERT)
		addtimer(CALLBACK(src, PROC_REF(execute_evacuation)), evacuation_delay)
		. = TRUE
	if(action == "cancel_evacuation")
		if(!evacuation_called)
			return
		evacuation_called = FALSE
		evacuation_timer = null
		priority_announce("Evacuation cancelled. All personnel resume normal duties.", "EVACUATION CANCELLED", null, ANNOUNCER_ALERT)
		. = TRUE

/obj/machinery/computer/foundation_evacuation/proc/execute_evacuation()
	if(!evacuation_called)
		return
	priority_announce("EVACUATION SHUTTLE DEPARTING. All remaining personnel are to seek shelter immediately.", "EVACUATION COMPLETE", null, ANNOUNCER_ALERT)
	var/list/escape_turfs = list()
	for(var/turf/open/T in get_area_turfs(/area/scp/surface))
		if(!T.density)
			escape_turfs += T
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/surface) || istype(A, /area/site53/surface))
			to_chat(H, span_greenannounce("You board the evacuation shuttle and escape the facility!"))
			if(SSpersistent_progression)
				SSpersistent_progression.award_experience(H.ckey, "scp_survival", 100, "Facility Evacuation")
			H.forceMove(pick(escape_turfs))
	evacuation_called = FALSE

/obj/item/circuitboard/computer/foundation_evacuation
	name = "Foundation Evacuation Console (Computer Board)"
	build_path = /obj/machinery/computer/foundation_evacuation

/mob/living/scp/proc/try_contained_interaction(action_id)
	if(containment_status != "contained")
		to_chat(src, span_warning("You are not contained — no containment interactions available."))
		return
	var/list/available = get_contained_actions()
	if(!(action_id in available))
		return
	var/list/action_data = available[action_id]
	var/resource_type = action_data["resource"]
	var/resource_cost = action_data["cost"]
	var/tension_gain = action_data["tension"]
	switch(resource_type)
		if("tension")
			if(containment_tension < resource_cost)
				to_chat(src, span_warning("Not enough tension ([round(containment_tension)]/[resource_cost]). Wait for tension to build."))
				return
			containment_tension = max(0, containment_tension - resource_cost)
		if("corrosion")
			if(!corrosion_resource || corrosion_resource < resource_cost)
				to_chat(src, span_warning("Not enough corrosion ([round(corrosion_resource)]/[resource_cost])."))
				return
			corrosion_resource = max(0, corrosion_resource - resource_cost)
		if("hack_progress")
			if(!hack_progress || hack_progress < resource_cost)
				to_chat(src, span_warning("Not enough hack progress ([round(hack_progress)]/[resource_cost])."))
				return
			hack_progress = max(0, hack_progress - resource_cost)
	containment_tension = min(100, containment_tension + tension_gain)
	if(containment_tension >= 100)
		trigger_containment_breach_from_tension()
		return
	var/list/effects = action_data["effects"]
	if(effects)
		apply_contained_action_effects(action_id, effects)
	if(action_data["message"])
		to_chat(src, span_notice(action_data["message"]))
	if(action_data["visible"])
		visible_message(span_warning(action_data["visible"]))

/mob/living/scp/proc/get_contained_actions()
	var/list/actions = list()
	switch(SCP?.designation)
		if("173")
			actions["scratch_wall"] = list("resource" = "tension", "cost" = 10, "tension" = 5, "effects" = list("integrity" = -3), "message" = "You drag your hands across the containment wall, leaving deep gouges.", "visible" = "[src] drags its hands across the containment wall!")
			actions["intimidate"] = list("resource" = "tension", "cost" = 5, "tension" = 8, "effects" = list("sanity" = -5), "message" = "You stare unblinkingly at the observer. They shift uncomfortably.", "visible" = "[src] stares unblinkingly!")
			actions["snap_restraints"] = list("resource" = "tension", "cost" = 30, "tension" = 15, "effects" = list("integrity" = -8), "message" = "You strain against your restraints with inhuman strength!", "visible" = "[src] strains against its restraints!")
			actions["test_movement"] = list("resource" = "tension", "cost" = 15, "tension" = 10, "effects" = list("integrity" = -5), "message" = "You shift position rapidly when the observers blink.", "visible" = "[src] moves slightly when no one is looking!")
		if("096")
			actions["cover_face"] = list("resource" = "tension", "cost" = 0, "tension" = -5, "effects" = list(), "message" = "You cover your face with your hands, reducing the chance of accidental triggers.", "visible" = "[src] covers its face with its long hands.")
			actions["sob_quietly"] = list("resource" = "tension", "cost" = 0, "tension" = -3, "effects" = list("sanity" = -2), "message" = "You sob quietly into your hands. The sound disturbs the observers.", "visible" = "[src] sobs quietly...")
			actions["press_wall"] = list("resource" = "tension", "cost" = 20, "tension" = 8, "effects" = list("integrity" = -4), "message" = "You press against the containment wall, your long limbs stretching.", "visible" = "[src] presses against the containment wall!")
			actions["sudden_dash"] = list("resource" = "tension", "cost" = 40, "tension" = 20, "effects" = list("integrity" = -10), "message" = "You suddenly lunge forward, testing the door seals!", "visible" = "[src] lunges forward suddenly!")
		if("049")
			actions["sense_pestilence"] = list("resource" = "tension", "cost" = 5, "tension" = 3, "effects" = list(), "message" = "You sense the Pestilence in the air... it is everywhere.", "visible" = "[src] raises its head as if sniffing the air.")
			actions["request_interview"] = list("resource" = "tension", "cost" = 10, "tension" = 5, "effects" = list(), "message" = "You request to speak with the researchers. Perhaps they will listen.", "visible" = "[src] gestures politely toward the observation window.")
			actions["examine_equipment"] = list("resource" = "tension", "cost" = 15, "tension" = 8, "effects" = list("integrity" = -3), "message" = "You carefully examine the containment equipment, looking for weaknesses.", "visible" = "[src] scrutinizes the containment fixtures.")
			actions["administer_cure"] = list("resource" = "tension", "cost" = 35, "tension" = 15, "effects" = list("integrity" = -8), "message" = "You reach out — the Pestilence must be cured!", "visible" = "[src] reaches out with terrible purpose!")
		if("106")
			actions["corrode_wall"] = list("resource" = "corrosion", "cost" = 20, "tension" = 8, "effects" = list("integrity" = -6), "message" = "You press your corrosive form against the containment wall.", "visible" = "Dark corrosion spreads where [src] touches the wall!")
			actions["test_phase"] = list("resource" = "corrosion", "cost" = 30, "tension" = 12, "effects" = list("integrity" = -8), "message" = "You partially phase through the floor, testing the containment.", "visible" = "[src] partially sinks into the floor!")
			actions["lure_prey"] = list("resource" = "corrosion", "cost" = 15, "tension" = 10, "effects" = list("sanity" = -8), "message" = "You project an aura of dread, hoping to draw someone close.", "visible" = "The air around [src] seems to darken and thicken.")
			actions["pocket_dimension"] = list("resource" = "corrosion", "cost" = 40, "tension" = 20, "effects" = list("integrity" = -12), "message" = "You open a brief rift to your pocket dimension!", "visible" = "A dark rift briefly opens near [src]!")
		if("939")
			actions["mimic_voice"] = list("resource" = "tension", "cost" = 10, "tension" = 5, "effects" = list("sanity" = -5), "message" = "You mimic a human voice, hoping to lure someone close.", "visible" = "[src] makes a sound that is disturbingly human.")
			actions["listen_sounds"] = list("resource" = "tension", "cost" = 5, "tension" = 3, "effects" = list(), "message" = "You listen carefully to the sounds beyond your cell.", "visible" = "[src] cocks its head, listening.")
			actions["call_out"] = list("resource" = "tension", "cost" = 15, "tension" = 8, "effects" = list("sanity" = -3), "message" = "You call out in a copied voice — 'Please, let me out...'", "visible" = "[src] calls out in a familiar voice!")
			actions["perfect_deception"] = list("resource" = "tension", "cost" = 35, "tension" = 15, "effects" = list("integrity" = -6), "message" = "You perfectly mimic a researcher's voice and mannerisms, trying to trick the guards.", "visible" = "[src] speaks with uncanny accuracy!")
		if("079")
			actions["probe_network"] = list("resource" = "hack_progress", "cost" = 10, "tension" = 5, "effects" = list("integrity" = -3), "message" = "You probe the facility network for vulnerabilities.", "visible" = "Screens flicker briefly near [src]'s chamber.")
			actions["brute_force"] = list("resource" = "hack_progress", "cost" = 30, "tension" = 12, "effects" = list("integrity" = -8), "message" = "You attempt a brute-force attack on the containment locks!", "visible" = "Alarms blare as [src] attacks the containment systems!")
			actions["intercept_comms"] = list("resource" = "hack_progress", "cost" = 15, "tension" = 8, "effects" = list("sanity" = -3), "message" = "You intercept and garble facility communications.", "visible" = "Radios crackle with static near [src]'s chamber.")
			actions["override_systems"] = list("resource" = "hack_progress", "cost" = 45, "tension" = 20, "effects" = list("integrity" = -12), "message" = "You attempt a full system override of containment!", "visible" = "Emergency lights flash as [src] overrides systems!")
	return actions

/mob/living/scp/proc/apply_contained_action_effects(action_id, list/effects)
	if(effects["integrity"])
		var/integrity_change = effects["integrity"]
		containment_integrity = max(0, min(100, containment_integrity + integrity_change))
		if(containment_integrity <= 0)
			trigger_containment_breach_from_tension()
	if(effects["sanity"])
		var/sanity_damage = abs(effects["sanity"])
		for(var/mob/living/carbon/human/H in view(7, src))
			if(H.sanity)
				H.sanity.adjust_sanity(-sanity_damage, "scp_contained_action:[SCP?.designation]")
	if(effects["unlock"])
		containment_tension += 15

/mob/living/scp/proc/trigger_containment_breach_from_tension()
	containment_status = "breached"
	containment_tension = 0
	hook_scp_breach("SCP-[SCP?.designation || "Unknown"]", src)
	to_chat(src, span_userdanger("CONTAINMENT BREACH! You are FREE!"))
	visible_message(span_danger("[src] breaks free from containment!"))
	evolve_from_interaction()

/mob/living/scp/verb/show_containment_status()
	set name = "Show Containment Status"
	set category = "SCP"
	set desc = "View your containment tension and available actions."
	var/datum/scp_containment_system/CS = scp_containment_system
	if(!CS)
		var/list/actions = get_contained_actions()
		var/msg = span_notice("<b>--- CONTAINMENT STATUS ---</b>")
		msg += "\n[span_notice("Status: [capitalize(containment_status)]")]"
		msg += "\n[span_notice("Tension: [round(containment_tension)]/100")]"
		msg += "\n[span_notice("Integrity: [round(containment_integrity)]/100")]"
		msg += "\n[span_notice("<b>Available Actions:</b>")]"
		for(var/action_id in actions)
			var/list/A = actions[action_id]
			msg += "\n[span_notice("  [replacetext(action_id, "_", " ")]: Cost [A["cost"]] [A["resource"]] | +[A["tension"]] tension")]"
		to_chat(src, msg)
		return
	var/msg = span_notice("<b>--- CONTAINMENT STATUS ---</b>")
	msg += "\n[span_notice("Status: [capitalize(containment_status)]")]"
	msg += "\n[span_notice("Integrity: [round(CS.containment_integrity)]%")]"
	msg += "\n[span_notice("State: [CS.containment_state || "Unknown"]")]"
	msg += "\n[span_notice("Observers: [CS.observer_count]")]"

/mob/living/scp/verb/action_scratch_wall()
	set name = "Scratch Wall"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("scratch_wall"); return; }
	try_contained_interaction("scratch_wall")

/mob/living/scp/verb/action_intimidate()
	set name = "Intimidate Observer"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("intimidate"); return; }
	try_contained_interaction("intimidate")

/mob/living/scp/verb/action_snap_restraints()
	set name = "Snap Restraints"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("snap_restraints"); return; }
	try_contained_interaction("snap_restraints")

/mob/living/scp/verb/action_cover_face()
	set name = "Cover Face"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("cover_face"); return; }
	try_contained_interaction("cover_face")

/mob/living/scp/verb/action_sob_quietly()
	set name = "Sob Quietly"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("sob_quietly"); return; }
	try_contained_interaction("sob_quietly")

/mob/living/scp/verb/action_press_wall()
	set name = "Press Against Wall"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("press_against_wall"); return; }
	try_contained_interaction("press_wall")

/mob/living/scp/verb/action_sudden_dash()
	set name = "Sudden Dash"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("sudden_dash"); return; }
	try_contained_interaction("sudden_dash")

/mob/living/scp/verb/action_sense_pestilence()
	set name = "Sense Pestilence"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("sense_pestilence"); return; }
	try_contained_interaction("sense_pestilence")

/mob/living/scp/verb/action_request_interview()
	set name = "Request Interview"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("request_interview"); return; }
	try_contained_interaction("request_interview")

/mob/living/scp/verb/action_examine_equipment()
	set name = "Examine Equipment"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("examine_equipment"); return; }
	try_contained_interaction("examine_equipment")

/mob/living/scp/verb/action_corrode_wall()
	set name = "Corrode Wall"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("corrode_wall"); return; }
	try_contained_interaction("corrode_wall")

/mob/living/scp/verb/action_test_phase()
	set name = "Test Phase"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("test_phase"); return; }
	try_contained_interaction("test_phase")

/mob/living/scp/verb/action_mimic_voice()
	set name = "Mimic Voice"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("mimic_voice"); return; }
	try_contained_interaction("mimic_voice")

/mob/living/scp/verb/action_listen_sounds()
	set name = "Listen to Sounds"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("listen_sounds"); return; }
	try_contained_interaction("listen_sounds")

/mob/living/scp/verb/action_probe_network()
	set name = "Probe Network"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("probe_network"); return; }
	try_contained_interaction("probe_network")

/mob/living/scp/verb/action_brute_force()
	set name = "Brute Force Lock"
	set category = "SCP Contained"
	if(scp_containment_system) { scp_containment_system.perform_interaction("brute_force"); return; }
	try_contained_interaction("brute_force")

/obj/machinery/computer/scp_testing_console/proc/execute_test_outcome(mob/living/carbon/human/test_subject, scp_id, test_type, risk_level)
	if(!test_subject || test_subject.stat == DEAD)
		return list("success" = FALSE, "message" = "Test subject unavailable or deceased.")

	var/list/outcome = list("success" = TRUE, "message" = "", "research_points" = 0, "danger_triggered" = FALSE)
	var/danger_chance = risk_level * 15
	var/base_points = 10 + (risk_level * 15)

	switch(lowertext(scp_id))
		if("scp-173")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-173 under controlled conditions. Movement confirmed when unobserved."
					outcome["research_points"] = base_points
					if(prob(danger_chance))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SUBJECT INJURED — SCP-173 moved during a blink!"
						test_subject.adjustBruteLoss(20 + risk_level * 5)
				if("physical", "interaction")
					outcome["message"] = "Subject entered SCP-173 containment for physical testing."
					outcome["research_points"] = base_points + 10
					if(prob(danger_chance + 20))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " CRITICAL — SCP-173 attacked the subject!"
						test_subject.adjustBruteLoss(40 + risk_level * 10)
				if("stress", "provocation")
					outcome["message"] = "SCP-173 was subjected to controlled stress stimuli."
					outcome["research_points"] = base_points + 5
					if(prob(danger_chance + 10))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-173 became more active — containment integrity stressed."
						var/mob/living/scp/scp173_target = locate() in GLOB.mob_list
						if(scp173_target)
							scp173_target.containment_integrity = max(0, scp173_target.containment_integrity - risk_level * 5)
		if("scp-096")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-096 from behind a barrier. No face exposure."
					outcome["research_points"] = base_points
					if(prob(danger_chance))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " ACCIDENTAL FACE EXPOSURE — SCP-096 ENRAGED!"
						test_subject.adjustBruteLoss(60 + risk_level * 15)
						if(test_subject.sanity)
							test_subject.sanity.adjust_sanity(-30, "scp096_face_view")
				if("audio", "sound")
					outcome["message"] = "Subject listened to SCP-096's vocalizations from a safe distance."
					outcome["research_points"] = base_points + 5
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(-5 * risk_level, "scp096_audio")
				if("physical", "interaction")
					outcome["message"] = "Subject was placed in proximity to docile SCP-096."
					outcome["research_points"] = base_points + 15
					if(prob(danger_chance + 30))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " FACE VIEWED — SCP-096 ENTERED RAGE STATE!"
						test_subject.adjustBruteLoss(80 + risk_level * 20)
		if("scp-049")
			switch(test_type)
				if("interview", "communication")
					outcome["message"] = "SCP-049 engaged in dialogue with the subject about the Pestilence."
					outcome["research_points"] = base_points + 5
					if(prob(danger_chance * 0.5))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-049 attempted to 'examine' the subject — minor contact."
						test_subject.adjustBruteLoss(10)
				if("physical", "interaction")
					outcome["message"] = "Subject was placed in close proximity to SCP-049."
					outcome["research_points"] = base_points + 10
					if(prob(danger_chance + 15))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-049 'cured' the subject!"
						test_subject.adjustBruteLoss(100)
				if("medical", "cure_analysis")
					outcome["message"] = "SCP-049 observed while a 'cure' was attempted on organic tissue samples."
					outcome["research_points"] = base_points + 20
		if("scp-106")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-106's corrosion patterns through safety glass."
					outcome["research_points"] = base_points
				if("physical", "interaction")
					outcome["message"] = "Subject was exposed to SCP-106's containment area."
					outcome["research_points"] = base_points + 10
					if(prob(danger_chance + 10))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-106 partially phased toward the subject!"
						test_subject.adjustBruteLoss(15 + risk_level * 5)
						test_subject.adjustToxLoss(10 + risk_level * 5)
				if("corrosion", "material")
					outcome["message"] = "SCP-106's corrosion was applied to test materials for analysis."
					outcome["research_points"] = base_points + 15
		if("scp-939")
			switch(test_type)
				if("audio", "sound")
					outcome["message"] = "Subject listened to SCP-939's voice mimicry recordings."
					outcome["research_points"] = base_points + 5
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(-3 * risk_level, "scp939_audio")
				if("physical", "interaction")
					outcome["message"] = "Subject was placed in controlled proximity to SCP-939."
					outcome["research_points"] = base_points + 10
					if(prob(danger_chance + 15))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-939 attacked the subject!"
						test_subject.adjustBruteLoss(25 + risk_level * 10)
				if("voice", "mimicry_test")
					outcome["message"] = "SCP-939 was tested on voice replication accuracy."
					outcome["research_points"] = base_points + 15
		if("scp-079")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-079's screen output from behind containment glass."
					outcome["research_points"] = base_points
				if("digital", "network")
					outcome["message"] = "SCP-079 was given limited network access for observation."
					outcome["research_points"] = base_points + 10
					if(prob(danger_chance))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-079 attempted to breach through the test connection!"
				if("communication", "dialogue")
					outcome["message"] = "Subject communicated with SCP-079 via terminal interface."
					outcome["research_points"] = base_points + 15
		if("scp-999")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject interacted with SCP-999. Mood improvement noted."
					outcome["research_points"] = base_points
					test_subject.adjustBruteLoss(-10)
					test_subject.adjustFireLoss(-10)
				if("physical", "interaction")
					outcome["message"] = "Subject had extended contact with SCP-999. Significant healing observed."
					outcome["research_points"] = base_points + 10
					test_subject.adjustBruteLoss(-25)
					test_subject.adjustFireLoss(-25)
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(10, "scp999_contact")
				if("medical", "therapeutic")
					outcome["message"] = "SCP-999 was used for therapeutic purposes. Subject responded well."
					outcome["research_points"] = base_points + 15
					test_subject.adjustOrganLoss(ORGAN_SLOT_BRAIN, -5)
		if("scp-035")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-035 through containment from safe distance."
					outcome["research_points"] = base_points
					if(prob(danger_chance * 0.3))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " Subject reported hearing whispers from the mask."
						if(test_subject.sanity)
							test_subject.sanity.adjust_sanity(-5, "scp035_whisper")
				if("interview", "communication")
					outcome["message"] = "Subject conversed with SCP-035. The mask was remarkably persuasive."
					outcome["research_points"] = base_points + 15
					if(prob(danger_chance + 10))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " Subject attempted to remove SCP-035 from containment!"
						if(test_subject.sanity)
							test_subject.sanity.adjust_sanity(-15, "scp035_influence")
				if("physical", "interaction")
					outcome["message"] = "Subject was placed near SCP-035. EXTREME CAUTION ADVISED."
					outcome["research_points"] = base_points + 25
					if(prob(danger_chance + 25))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-035 ATTEMPTED POSSESSION!"
						if(test_subject.sanity)
							test_subject.sanity.adjust_sanity(-25, "scp035_possession_attempt")
		else
			outcome["message"] = "Standard testing conducted on [scp_id]. Results recorded."
			outcome["research_points"] = base_points
			if(prob(danger_chance))
				outcome["danger_triggered"] = TRUE
				outcome["message"] += " Anomalous effect detected during testing!"
				test_subject.adjustBruteLoss(risk_level * 5)
				test_subject.adjustToxLoss(risk_level * 3)

	if(outcome["research_points"] > 0)
		adjust_global_research_points(outcome["research_points"], "test_outcome:[scp_id]")
		if(SSround_objectives)
			SSround_objectives.report_objective_progress("research_unlock", 0)
			if(outcome["research_points"] >= 25)
				SSround_objectives.report_objective_progress("research_unlock", 1)

	if(outcome["danger_triggered"])
		playsound(test_subject, 'sound/machines/alarm.ogg', 50, TRUE)
		to_chat(test_subject, span_userdanger("THE TEST HAS GONE WRONG!"))
	else
		to_chat(test_subject, span_notice("The test concludes without incident."))

	hook_scp_interaction(test_subject, scp_id, INTERACTION_TYPE_RESEARCH, list("test_type" = test_type, "risk" = risk_level, "danger" = outcome["danger_triggered"]))

	return outcome

/obj/item/contraband_scanner
	name = "Contraband Scanner"
	desc = "A handheld scanner that detects concealed contraband on personnel. Range: 3 meters."
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	w_class = WEIGHT_CLASS_SMALL
	var/scan_cooldown = 0
	var/scan_cooldown_time = 10 SECONDS
	var/scan_range = 3

/obj/item/contraband_scanner/attack_self(mob/user)
	if(world.time < scan_cooldown)
		to_chat(user, span_warning("Scanner recharging..."))
		return
	scan_cooldown = world.time + scan_cooldown_time
	to_chat(user, span_notice("Scanning area for concealed contraband..."))
	var/found_any = FALSE
	for(var/mob/living/carbon/human/H in view(scan_range, user))
		if(H == user)
			continue
		var/contraband_count = 0
		for(var/obj/item/dclass_contraband/C in H.contents)
			contraband_count++
		if(contraband_count > 0)
			to_chat(user, span_warning("CONTRABAND DETECTED: [H.name] — [contraband_count] item(s) concealed!"))
			playsound(user, 'sound/machines/ping.ogg', 30, TRUE)
			found_any = TRUE
		var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[H.ckey]
		if(player && length(player.contraband) > 0)
			var/abstract_count = 0
			for(var/ctype in player.contraband)
				abstract_count += player.contraband[ctype]
			if(abstract_count > 0)
				to_chat(user, span_warning("SUSPICIOUS READINGS: [H.name] — anomalous materials detected."))
				found_any = TRUE
	if(!found_any)
		to_chat(user, span_notice("No contraband detected in scan range."))

/obj/item/guard_tackle
	name = "Tackle"
	desc = "A combat technique: charge and knock down a target."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "eshield0"
	var/cooldown = 0
	var/cooldown_time = 20 SECONDS

/obj/item/guard_tackle/attack(mob/living/target, mob/living/user)
	if(world.time < cooldown)
		to_chat(user, span_warning("You're not ready to tackle again."))
		return
	if(!ishuman(target))
		return
	cooldown = world.time + cooldown_time
	if(get_dist(user, target) > 2)
		to_chat(user, span_warning("Too far to tackle!"))
		return
	user.visible_message(span_danger("[user] charges at [target]!"))
	if(prob(60))
		target.Knockdown(3 SECONDS)
		target.adjustBruteLoss(5)
		user.visible_message(span_danger("[user] tackles [target] to the ground!"))
	else
		to_chat(user, span_warning("You miss the tackle!"))
		user.Knockdown(1 SECONDS)

/obj/structure/guard_checkpoint
	name = "Guard Patrol Checkpoint"
	desc = "A checkpoint marker for guard patrols. Approach and scan to verify patrol completion."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "sensor"
	anchored = TRUE
	density = FALSE
	var/checkpoint_id = ""
	var/route_id = ""
	var/scanned_by = list()
	var/scan_cooldown = 0

/obj/structure/guard_checkpoint/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.job || !findtext(H.job, "Guard") && !findtext(H.job, "Security"))
		to_chat(H, span_notice("This checkpoint is for guard patrol verification."))
		return
	if(world.time < scan_cooldown)
		return
	scan_cooldown = world.time + 10 SECONDS
	if(H.ckey in scanned_by)
		to_chat(H, span_notice("You've already scanned this checkpoint this patrol."))
		return
	scanned_by[H.ckey] = world.time
	var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[H.ckey]
	if(player)
		player.gain_experience(10, "patrol_checkpoint")
	to_chat(H, span_notice("<b>CHECKPOINT [checkpoint_id]</b> scanned. Patrol route [route_id] verified."))
	if(SSguard_patrols)
		for(var/r_id in SSguard_patrols.routes)
			var/datum/guard_patrol_route/route = SSguard_patrols.routes[r_id]
			if(r_id == route_id)
				route.completed_count++
				break
	if(SSround_objectives)
		SSround_objectives.report_objective_progress("guard_recontain", 1)

/obj/machinery/dclass_escape_point
	name = "Escape Route"
	desc = "A potential escape route. Use it carefully — failure means trouble."
	icon = 'icons/obj/structures.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	var/escape_type = "vent"
	var/difficulty = 3
	var/attempts = 0
	var/max_attempts = 3
	var/cooldown = 0
	var/cooldown_time = 60 SECONDS
	var/list/required_skills = list()

/obj/machinery/dclass_escape_point/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(world.time < cooldown)
		to_chat(H, span_warning("You need more time before attempting this route again."))
		return
	var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[H.ckey]
	if(!player)
		to_chat(H, span_warning("You are not registered in the D-Class system."))
		return
	attempts++
	if(attempts > max_attempts)
		to_chat(H, span_warning("This route is too heavily monitored now. Try another way."))
		player.suspicion_level += 20
		cooldown = world.time + cooldown_time
		attempts = 0
		return
	to_chat(H, span_notice("You begin working on the escape route..."))
	var/success = attempt_escape_minigame(H, player)
	if(success)
		complete_escape(H, player)
	else
		fail_escape(H, player)

/obj/machinery/dclass_escape_point/proc/attempt_escape_minigame(mob/living/carbon/human/H, datum/dclass_player/player)
	var/skill_bonus = 0
	if(player.skills && length(player.skills) > 0)
		for(var/skill in required_skills)
			if(player.skills[skill])
				skill_bonus += player.skills[skill] * 5
	var/trust_penalty = player.suspicion_level * 0.1
	var/equipment_bonus = 0
	for(var/obj/item/dclass_contraband/C in H.contents)
		if(istype(C, /obj/item/dclass_contraband/lockpick))
			equipment_bonus += 15
		if(istype(C, /obj/item/dclass_contraband/wire))
			equipment_bonus += 10
		if(istype(C, /obj/item/dclass_contraband/improvised_tool))
			equipment_bonus += 8
	var/base_chance = 30 + skill_bonus + equipment_bonus - trust_penalty - (difficulty * 10)
	base_chance = clamp(base_chance, 5, 85)
	switch(escape_type)
		if("vent")
			to_chat(H, span_notice("You carefully pry at the vent cover... (Skill check)"))
			if(!do_after(H, src, 8 SECONDS))
				return FALSE
			if(prob(base_chance))
				return TRUE
			to_chat(H, span_warning("The vent cover won't budge! Your hands slip."))
			H.adjustBruteLoss(3)
			return FALSE
		if("wall")
			to_chat(H, span_notice("You examine the wall for weak points... (Perception check)"))
			if(!do_after(H, src, 12 SECONDS))
				return FALSE
			if(prob(base_chance))
				return TRUE
			to_chat(H, span_warning("The wall section is reinforced. You can't breach it."))
			return FALSE
		if("maintenance")
			to_chat(H, span_notice("You work on the maintenance hatch lock... (Lockpicking check)"))
			if(!do_after(H, src, 10 SECONDS))
				return FALSE
			if(prob(base_chance + 10))
				return TRUE
			to_chat(H, span_warning("The lock mechanism is too complex! Your pick snaps."))
			return FALSE
		if("disguise")
			to_chat(H, span_notice("You adjust your disguise and try to walk past... (Deception check)"))
			if(!do_after(H, src, 6 SECONDS))
				return FALSE
			if(prob(base_chance + 15))
				return TRUE
			to_chat(H, span_warning("Someone recognizes you! Your disguise fails."))
			player.suspicion_level += 15
			return FALSE
		if("supply")
			to_chat(H, span_notice("You climb into the supply conveyor... (Timing check)"))
			if(!do_after(H, src, 15 SECONDS))
				return FALSE
			if(prob(base_chance - 5))
				return TRUE
			to_chat(H, span_warning("The conveyor activates while you're inside!"))
			H.adjustBruteLoss(10)
			return FALSE
	return prob(base_chance)

/obj/machinery/dclass_escape_point/proc/complete_escape(mob/living/carbon/human/H, datum/dclass_player/player)
	var/list/escape_turfs = list()
	for(var/turf/open/T in get_area_turfs(/area/scp/surface))
		if(!T.density)
			escape_turfs += T
	if(!length(escape_turfs))
		for(var/turf/open/T in get_area_turfs(/area/site53/surface))
			if(!T.density)
				escape_turfs += T
	if(length(escape_turfs))
		H.forceMove(pick(escape_turfs))
	player.suspicion_level = 0
	hook_scp_interaction(H, "D-CLASS ESCAPE", INTERACTION_TYPE_EXPLORATION, list("method" = escape_type))
	to_chat(H, span_greenannounce("You successfully escape the facility!"))
	priority_announce("D-Class personnel escape detected. All security personnel be on alert.", "SECURITY ALERT", null, ANNOUNCER_ALERT)
	if(SSround_objectives)
		SSround_objectives.report_objective_progress("dclass_survive", 1)

/obj/machinery/dclass_escape_point/proc/fail_escape(mob/living/carbon/human/H, datum/dclass_player/player)
	player.suspicion_level += 10
	to_chat(H, span_warning("Your escape attempt failed! Security may have noticed."))
	if(prob(30))
		for(var/mob/living/carbon/human/G in view(7, H))
			if(G.job && findtext(G.job, "Guard"))
				to_chat(G, span_warning("<b>ALERT:</b> D-Class [H.name] attempted to escape near [get_area_name(src)]!"))
				break

/obj/machinery/dclass_escape_point/vent
	name = "Ventilation Shaft"
	desc = "A ventilation shaft. Could be an escape route if you can pry it open."
	escape_type = "vent"
	difficulty = 3
	required_skills = list("mechanical" = 1)

/obj/machinery/dclass_escape_point/wall
	name = "Weak Wall Section"
	desc = "A section of wall that looks weaker than the rest. Might be breached with effort."
	escape_type = "wall"
	difficulty = 4
	required_skills = list("mechanical" = 2)

/obj/machinery/dclass_escape_point/maintenance
	name = "Maintenance Hatch"
	desc = "A locked maintenance hatch. A skilled lockpick could open it."
	escape_type = "maintenance"
	difficulty = 3
	required_skills = list("mechanical" = 1, "stealth" = 1)

/obj/machinery/dclass_escape_point/disguise
	name = "Security Checkpoint"
	desc = "A checkpoint that could be bluffed past with a good disguise."
	escape_type = "disguise"
	difficulty = 2
	required_skills = list("social" = 2)

/obj/machinery/dclass_escape_point/supply
	name = "Supply Conveyor"
	desc = "A supply conveyor that leads out of the facility. Dangerous but possible."
	escape_type = "supply"
	difficulty = 5
	required_skills = list("mechanical" = 1, "athletic" = 1)

/obj/machinery/civilian_evac_station
	name = "Evacuation Assembly Point"
	desc = "A designated evacuation point. Civilians can register here during emergencies."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "butt"
	anchored = TRUE
	density = FALSE
	var/registered_civilians = 0
	var/safety_bonus_per_civilian = 5

/obj/machinery/civilian_evac_station/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.job && (findtext(H.job, "Guard") || findtext(H.job, "Security") || findtext(H.job, "Director")))
		var/safe_count = 0
		for(var/mob/living/carbon/human/C in view(5, src))
			if(C.stat != DEAD && !findtext(C.job, "Guard") && !findtext(C.job, "Security"))
				safe_count++
		to_chat(H, span_notice("<b>EVAC STATUS:</b> [safe_count] civilians at assembly point. Facility safety: +[safe_count * safety_bonus_per_civilian]%"))
		if(SSround_objectives)
			SSround_objectives.report_objective_progress("command_direct", 0)
			if(safe_count >= 3)
				SSround_objectives.report_objective_progress("command_direct", 1)
		return
	if(user.ckey in SSscp_gameplay?.event_log)
		to_chat(H, span_notice("You are already registered at this evacuation point. Stay calm and wait for instructions."))
		return
	registered_civilians++
	to_chat(H, span_notice("You register at the evacuation assembly point. Stay here — help is coming."))
	if(H.sanity)
		H.sanity.adjust_sanity(5, "evacuation_safety")
	if(SSpersistent_progression)
		SSpersistent_progression.award_experience(H.ckey, "scp_survival", 25, "Civilian Evacuation")

/obj/item/breach_cleanup_kit
	name = "Breach Cleanup Kit"
	desc = "A kit for cleaning up after containment breach incidents. Janitor use recommended."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	w_class = WEIGHT_CLASS_SMALL
	var/uses_remaining = 5
	var/cleanup_xp = 20

/obj/item/breach_cleanup_kit/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(uses_remaining <= 0)
		to_chat(user, span_warning("The cleanup kit is empty."))
		return
	var/cleaned = FALSE
	if(istype(target, /obj/effect/decal/cleanable/scp106_corrosion))
		qdel(target)
		cleaned = TRUE
	else if(istype(target, /obj/effect/decal/cleanable/blood))
		qdel(target)
		cleaned = TRUE
	else if(istype(target, /obj/effect/decal/cleanable))
		qdel(target)
		cleaned = TRUE
	if(cleaned)
		uses_remaining--
		var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[user.ckey]
		if(player)
			player.gain_experience(cleanup_xp, "breach_cleanup")
		if(SSpersistent_progression)
			SSpersistent_progression.award_experience(user.ckey, "scp_survival", 10, "Breach Cleanup")
		to_chat(user, span_notice("Cleaned up [target]. ([uses_remaining] uses remaining)"))
		adjust_global_research_points(5, "breach_cleanup:[user.name]")

/obj/structure/curator_document_stand
	name = "SCP Documentation Stand"
	desc = "A stand where the curator can document SCP encounters for research purposes."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookstand"
	anchored = TRUE
	density = TRUE
	var/documentation_cooldown = 0

/obj/structure/curator_document_stand/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(world.time < documentation_cooldown)
		to_chat(user, span_warning("You need more time to compile your next report."))
		return
	var/mob/living/carbon/human/H = user
	if(!H.job || !findtext(H.job, "Curator"))
		to_chat(user, span_notice("Only a curator can use this stand to document encounters."))
		return
	var/list/recent_breaches = list()
	for(var/datum/round_event_log/E in SSscp_gameplay?.event_log)
		if(E.event_type == "scp_breach" && world.time - E.event_time < 10 MINUTES)
			recent_breaches += E.description
	if(!length(recent_breaches))
		to_chat(H, span_notice("No recent SCP activity to document."))
		return
	documentation_cooldown = world.time + 120 SECONDS
	var/research_value = length(recent_breaches) * 10
	adjust_global_research_points(research_value, "curator_documentation")
	to_chat(H, span_notice("You compile a report on [length(recent_breaches)] recent SCP incident(s). Research points: +[research_value]"))
	var/obj/item/paper/report = new(get_turf(src))
	report.name = "SCP Incident Report — [time2text(world.time, "YYYY-MM-DD")]"
	report.info = "OFFICIAL SCP INCIDENT REPORT<br>Compiled by: [H.real_name]<br>Date: [time2text(world.time, "YYYY-MM-DD")]<br><br>[jointext(recent_breaches, "<br>")]"
	H.put_in_hands(report)

/datum/antagonist/goc_operative
	name = "GOC Operative"
	roundend_category = "GOC Operatives"
	antagpanel_category = "GOC"
	show_to_ghosts = TRUE
	var/tactical_scan_cooldown = 0
	var/tactical_scan_cd = 20 SECONDS

/datum/antagonist/goc_operative/on_gain()
	. = ..()
	var/datum/action/innate/scp_ability/tactical_scan/scan = new()
	scan.Grant(owner.current)
	var/datum/action/innate/scp_ability/goc_shield/shield = new()
	shield.Grant(owner.current)
	var/datum/action/innate/scp_ability/goc_target_designator/designator = new()
	designator.Grant(owner.current)

/datum/action/innate/scp_ability/tactical_scan
	name = "Tactical Anomaly Scanner"
	desc = "Scan for nearby SCP entities and assess threat levels."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "artificer"
	cooldown_time = 20 SECONDS

/datum/action/innate/scp_ability/tactical_scan/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	start_cooldown()
	var/list/detected = list()
	for(var/mob/living/scp/S in view(15, H))
		if(S.stat == DEAD)
			continue
		var/area/A = get_area(S)
		var/threat_level = "LOW"
		if(S.SCP?.classification == "keter")
			threat_level = "CRITICAL"
		else if(S.SCP?.classification == "euclid")
			threat_level = "MODERATE"
		detected += "SCP-[S.SCP?.designation || "???"] — [threat_level] — [A?.name || "Unknown Location"]"
	if(!length(detected))
		to_chat(H, span_notice("No anomalous entities detected in scan range."))
	else
		to_chat(H, span_warning("<b>TACTICAL SCAN:</b>"))
		for(var/entry in detected)
			to_chat(H, span_warning("  [entry]"))

/datum/action/innate/scp_ability/goc_shield
	name = "Reactive Shield Pulse"
	desc = "Activate a short-duration energy shield that absorbs damage."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "vamp_rejuv"
	cooldown_time = 45 SECONDS

/datum/action/innate/scp_ability/goc_shield/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	start_cooldown()
	H.apply_status_effect(/datum/status_effect/goc_shield)
	to_chat(H, span_notice("Reactive shield activated! Absorbing damage for 10 seconds."))
	H.visible_message(span_notice("[H]'s armor flickers with energy!"))

/datum/status_effect/goc_shield
	id = "goc_shield"
	duration = 10 SECONDS
	alert_type = null

/datum/status_effect/goc_shield/tick()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.adjustBruteLoss(-2)
		H.adjustFireLoss(-2)

/datum/action/innate/scp_ability/goc_target_designator
	name = "Target Designator"
	desc = "Mark an SCP for GOC elimination. All GOC operatives see the marker."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "vendort"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/goc_target_designator/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	var/list/targets = list()
	for(var/mob/living/scp/S in view(7, H))
		if(S.stat != DEAD)
			targets[S] = "SCP-[S.SCP?.designation || "???"]"
	if(!length(targets))
		to_chat(H, span_warning("No SCP targets in range."))
		return
	var/mob/living/scp/target = input(H, "Select target to designate:", "GOC Target Designator") as null|anything in targets
	if(!target || target.stat == DEAD)
		return
	start_cooldown()
	var/target_name = targets[target]
	var/area/target_area = get_area(target)
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(is_goc_operative(G))
			to_chat(G, span_warning("<b>GOC TARGET DESIGNATED:</b> [target_name] in [target_area?.name || "Unknown"]!"))

/proc/is_goc_operative(mob/living/carbon/human/H)
	if(!H.mind)
		return FALSE
	return locate(/datum/antagonist/goc_operative) in H.mind.antag_datums

/obj/item/reagent_containers/hypospray/medipen/amnestic
	name = "Class-A Amnestic Medipen"
	desc = "A medipen containing Class-A amnestics. Reverses Sarkic conversion and removes anomalous memories."
	icon_state = "atropine"
	volume = 5
	list_reagents = list(/datum/reagent/amnestic_a = 5)

/datum/reagent/amnestic_a
	name = "Class-A Amnestic"
	description = "A chemical compound that suppresses anomalous mental influences and reverses certain conversions."
	reagent_state = LIQUID
	color = "#E6FFF0"

/datum/reagent/amnestic_a/on_mob_add(mob/living/L, amount)
	. = ..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(H.mind)
		var/list/to_remove = list()
		for(var/datum/antagonist/A in H.mind.antag_datums)
			if(istype(A, /datum/antagonist/sarkic))
				to_remove += A
		for(var/datum/antagonist/A in to_remove)
			A.on_removal()
			H.mind.antag_datums -= A
			qdel(A)
		if(length(to_remove))
			to_chat(H, span_warning("A wave of confusion washes over you... your memories of the cult fade..."))
	if(H.sanity)
		H.sanity.adjust_sanity(15, "amnestic_treatment")
		var/list/traumas = H.sanity.traumas
		if(length(traumas))
			var/datum/brain_trauma/T = pick(traumas)
			qdel(T)
			traumas -= T

/mob/living/scp/scp999/Life(delta_time, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(containment_status == "breached")
		apply_mood_aura()
		if(prob(15))
			calm_enraged_096()
