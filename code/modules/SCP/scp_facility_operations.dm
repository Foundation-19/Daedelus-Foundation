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
// #5 REDIRECTED — Zone lockdown is handled by /obj/machinery/facility_lockdown_console in facility_lockdown.dm
// ============================================================================

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
// #7 REDIRECTED — D-Class work tasks are handled by /obj/machinery/dclass_work_terminal in dclass_work_assignments.dm
// ============================================================================

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
				SSscp_research?.manager?.cognitive_bonus += sanity_resist
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
				O.current_progress = (SSscp_persistence?.manager?.global_containment_stability >= 50) ? 1 : 0

/datum/controller/subsystem/round_objectives/proc/report_objective_progress(obj_id, amount = 1)
	var/datum/round_objective/O = objectives[obj_id]
	if(!O || O.completed)
		return
	O.make_progress(amount)
	if(O.completed)
		priority_announce("ROUND OBJECTIVE COMPLETE: [O.title] — [O.description]", "OBJECTIVE UPDATE", null, ANNOUNCER_ALERT)

// ============================================================================
// #11 REDIRECTED — PA announcements are handled by /obj/machinery/computer/scp_intercom_console in scp_intercom_console.dm
// ============================================================================

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
			to_chat(ui.user, span_warning("Evacuation requires Code Red or higher security level."))
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

/mob/living/scp/proc/action_scratch_wall()
	set name = "Scratch Wall"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("scratch_wall"); return; }

/mob/living/scp/proc/action_intimidate()
	set name = "Intimidate Observer"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("intimidate"); return; }

/mob/living/scp/proc/action_snap_restraints()
	set name = "Snap Restraints"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("snap_restraints"); return; }

/mob/living/scp/proc/action_cover_face()
	set name = "Cover Face"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("cover_face"); return; }

/mob/living/scp/proc/action_sob_quietly()
	set name = "Sob Quietly"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("sob_quietly"); return; }

/mob/living/scp/proc/action_press_wall()
	set name = "Press Against Wall"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("press_against_wall"); return; }

/mob/living/scp/proc/action_sudden_dash()
	set name = "Sudden Dash"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("sudden_dash"); return; }

/mob/living/scp/proc/action_sense_pestilence()
	set name = "Sense Pestilence"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("sense_pestilence"); return; }

/mob/living/scp/proc/action_request_interview()
	set name = "Request Interview"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("request_interview"); return; }

/mob/living/scp/proc/action_examine_equipment()
	set name = "Examine Equipment"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("examine_equipment"); return; }

/mob/living/scp/proc/action_corrode_wall()
	set name = "Corrode Wall"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("corrode_wall"); return; }

/mob/living/scp/proc/action_test_phase()
	set name = "Test Phase"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("phase_test"); return; }

/mob/living/scp/proc/action_mimic_voice()
	set name = "Mimic Voice"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("mimic_voice"); return; }

/mob/living/scp/proc/action_listen_sounds()
	set name = "Listen to Sounds"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("listen_sounds"); return; }

/mob/living/scp/proc/action_probe_network()
	set name = "Probe Network"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("probe_network"); return; }

/mob/living/scp/proc/action_brute_force()
	set name = "Brute Force Lock"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("brute_force"); return; }

/mob/living/scp/proc/action_test_wall()
	set name = "Ram Wall"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("ram_wall"); return; }

/mob/living/scp/proc/action_acid_spit()
	set name = "Acid Spit"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("secrete_acid"); return; }

/mob/living/scp/proc/action_endure_torment()
	set name = "Endure Torment"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("resist_damage"); return; }

/mob/living/scp/proc/action_rage_burst()
	set name = "Terrifying Roar"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("roar"); return; }

/mob/living/scp/proc/action_flare_up()
	set name = "Ignite Object"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("ignite_object"); return; }

/mob/living/scp/proc/action_reach_flames()
	set name = "Melt Barrier"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("melt_barrier"); return; }

/mob/living/scp/proc/action_absorb_heat()
	set name = "Absorb Heat"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("absorb_heat"); return; }

/mob/living/scp/proc/action_firestorm()
	set name = "Inferno Burst"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("inferno_burst"); return; }

/mob/living/scp/proc/action_speak_observer()
	set name = "Speak to Observer"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("speak_to_observer"); return; }

/mob/living/scp/proc/action_offer_deal()
	set name = "Offer Deal"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("offer_deal"); return; }

/mob/living/scp/proc/action_dominate_mind()
	set name = "Dominate Mind"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("dominate_mind"); return; }

/mob/living/scp/proc/action_spread_spores()
	set name = "Release Spores"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("spread_spores"); return; }

/mob/living/scp/proc/action_bang_door()
	set name = "Bang on Door"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("bang_door"); return; }

/mob/living/scp/proc/action_flood_contagion()
	set name = "Flood Contagion"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("flood_contagion"); return; }

/mob/living/scp/proc/action_intercept_comms()
	set name = "Intercept Comms"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("intercept_comms"); return; }

/mob/living/scp/proc/action_override_systems()
	set name = "Override Systems"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("override_systems"); return; }

/mob/living/scp/proc/action_lure_prey()
	set name = "Lure Prey"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("lure_prey"); return; }

/mob/living/scp/proc/action_pocket_dimension()
	set name = "Pocket Dimension"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("pocket_dimension"); return; }

/mob/living/scp/proc/action_administer_cure()
	set name = "Administer the Cure"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("administer_cure"); return; }

/mob/living/scp/proc/action_adaptive_breach()
	set name = "Adaptive Breach"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("adaptive_breach"); return; }

/mob/living/scp/proc/action_call_out()
	set name = "Call Out"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("call_out"); return; }

/mob/living/scp/proc/action_perfect_deception()
	set name = "Perfect Deception"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("perfect_deception"); return; }

/mob/living/scp/proc/action_test_movement()
	set name = "Test Movement"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("test_movement"); return; }

/mob/living/scp/proc/action_peek_out()
	set name = "Peek Through Door"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("peek_out"); return; }

/mob/living/scp/proc/action_listen_footsteps()
	set name = "Listen for Footsteps"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("listen_footsteps"); return; }

/mob/living/scp/proc/action_whisper_dread()
	set name = "Whisper Dread"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("whisper_dread"); return; }

/mob/living/scp/proc/action_lay_egg()
	set name = "Lay Egg"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("lay_egg"); return; }

/mob/living/scp/proc/action_appear_harmless()
	set name = "Appear Harmless"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("appear_harmless"); return; }

/mob/living/scp/proc/action_flock_call()
	set name = "Flock Call"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("flock_call"); return; }

/mob/living/scp/proc/action_request_meal()
	set name = "Request a Meal"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("request_meal"); return; }

/mob/living/scp/proc/action_scan_networks()
	set name = "Scan Networks"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("scan_networks"); return; }

/mob/living/scp/proc/action_test_invisibility()
	set name = "Test Invisibility"
	set category = "SCP Contained"
	set hidden = TRUE
	if(scp_containment_system) { scp_containment_system.perform_interaction("test_invisibility"); return; }

/mob/living/scp/proc/show_containment_status()
	set name = "Show Containment Status"
	set category = "SCP Contained"
	set hidden = TRUE
	set desc = "View your containment tension and available actions."
	if(!scp_containment_system)
		to_chat(src, span_notice("<b>--- CONTAINMENT STATUS ---</b>"))
		to_chat(src, span_notice("Status: [capitalize(containment_status)]"))
		to_chat(src, span_notice("Tension: [round(containment_tension)]/100"))
		to_chat(src, span_notice("Integrity: [round(containment_integrity)]/100"))
		return
	var/datum/scp_containment_system/CS = scp_containment_system
	var/msg = span_notice("<b>--- CONTAINMENT STATUS ---</b>")
	msg += "\n[span_notice("Status: [capitalize(containment_status)]")]"
	msg += "\n[span_notice("Integrity: [round(CS.containment_integrity)]%")]"
	msg += "\n[span_notice("State: [CS.containment_state || "Unknown"]")]"
	msg += "\n[span_notice("Observers: [CS.observer_count]")]"
	to_chat(src, msg)

/mob/living/scp/proc/grant_containment_verbs()
	var/list/interaction_ids = list()
	if(scp_containment_system)
		var/list/options = scp_containment_system.get_interact_options()
		for(var/list/opt in options)
			interaction_ids += opt["id"]
	var/static/list/verb_map = list(
		"scratch_wall" = /mob/living/scp/proc/action_scratch_wall,
		"intimidate" = /mob/living/scp/proc/action_intimidate,
		"snap_restraints" = /mob/living/scp/proc/action_snap_restraints,
		"cover_face" = /mob/living/scp/proc/action_cover_face,
		"sob_quietly" = /mob/living/scp/proc/action_sob_quietly,
		"press_against_wall" = /mob/living/scp/proc/action_press_wall,
		"sudden_dash" = /mob/living/scp/proc/action_sudden_dash,
		"sense_pestilence" = /mob/living/scp/proc/action_sense_pestilence,
		"request_interview" = /mob/living/scp/proc/action_request_interview,
		"examine_equipment" = /mob/living/scp/proc/action_examine_equipment,
		"corrode_wall" = /mob/living/scp/proc/action_corrode_wall,
		"test_phase" = /mob/living/scp/proc/action_test_phase,
		"mimic_voice" = /mob/living/scp/proc/action_mimic_voice,
		"listen_sounds" = /mob/living/scp/proc/action_listen_sounds,
		"probe_network" = /mob/living/scp/proc/action_probe_network,
		"brute_force" = /mob/living/scp/proc/action_brute_force,
		"test_wall" = /mob/living/scp/proc/action_test_wall,
		"acid_spit" = /mob/living/scp/proc/action_acid_spit,
		"endure_torment" = /mob/living/scp/proc/action_endure_torment,
		"rage_burst" = /mob/living/scp/proc/action_rage_burst,
		"flare_up" = /mob/living/scp/proc/action_flare_up,
		"reach_flames" = /mob/living/scp/proc/action_reach_flames,
		"absorb_heat" = /mob/living/scp/proc/action_absorb_heat,
		"firestorm" = /mob/living/scp/proc/action_firestorm,
	)
	for(var/id in interaction_ids)
		if(verb_map[id])
			add_verb(src, verb_map[id])
	add_verb(src, /mob/living/scp/proc/show_containment_status)

/proc/scp_execute_test_outcome(mob/living/carbon/human/test_subject, scp_id, test_type, risk_level)
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
		if("scp-682")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-682 through reinforced containment. It stared back with palpable hatred."
					outcome["research_points"] = base_points
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(-3 * risk_level, "scp682_observation")
				if("physical", "interaction")
					outcome["message"] = "Subject was placed in SCP-682's containment area. HIGH RISK."
					outcome["research_points"] = base_points + 15
					if(prob(danger_chance + 20))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-682 ATTACKED THE SUBJECT!"
						test_subject.adjustBruteLoss(50 + risk_level * 15)
				if("acid", "chemical")
					outcome["message"] = "Acid bath protocols were tested on SCP-682. Regeneration rate observed."
					outcome["research_points"] = base_points + 20
					if(prob(danger_chance))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-682 adapted to the acid! Reduced effectiveness on subsequent applications."
		if("scp-457")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-457 through fire-resistant containment glass."
					outcome["research_points"] = base_points
					if(prob(danger_chance * 0.5))
						test_subject.adjustFireLoss(5 * risk_level)
						outcome["message"] += " Heat radiation caused minor burns through the barrier."
				if("physical", "interaction")
					outcome["message"] = "Subject was placed in proximity to SCP-457 with fire-resistant equipment."
					outcome["research_points"] = base_points + 10
					if(prob(danger_chance + 15))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-457 flared and engulfed the subject!"
						test_subject.adjustFireLoss(40 + risk_level * 15)
				if("suppression", "fire_fighting")
					outcome["message"] = "Fire suppression protocols were tested against SCP-457."
					outcome["research_points"] = base_points + 15
					if(prob(danger_chance + 5))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-457 resisted suppression and grew larger!"
		if("scp-131")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject spent time near SCP-131. The eye creature followed them curiously."
					outcome["research_points"] = base_points
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(3, "scp131_company")
				if("physical", "interaction")
					outcome["message"] = "Subject petted SCP-131. It babbled happily and bonded with the subject."
					outcome["research_points"] = base_points + 5
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(5, "scp131_pet")
				if("scp173", "anti_173")
					outcome["message"] = "SCP-131 was placed near SCP-173 containment. 131's constant observation prevented 173 movement."
					outcome["research_points"] = base_points + 20
					outcome["danger_triggered"] = FALSE
		if("scp-513")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-513 through protective barrier. Compulsion to ring noted but resisted."
					outcome["research_points"] = base_points
				if("audio", "sound")
					outcome["message"] = "Subject listened to recordings of SCP-513's bell. No anomalous effect from recordings."
					outcome["research_points"] = base_points + 5
				if("physical", "interaction")
					outcome["message"] = "Subject was allowed to hold SCP-513 under controlled conditions."
					outcome["research_points"] = base_points + 10
					if(prob(danger_chance + 30))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SUBJECT RANG SCP-513! SCP-513-1 NOW STALKS SUBJECT."
						if(test_subject.sanity)
							test_subject.sanity.adjust_sanity(-20, "scp513_rung")
		if("scp-914")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-914's clockwork mechanism in operation."
					outcome["research_points"] = base_points
				if("refinement", "1:1")
					outcome["message"] = "Subject operated SCP-914 on the 1:1 setting. Predictable output achieved."
					outcome["research_points"] = base_points + 10
				if("refinement", "very_fine")
					outcome["message"] = "Subject operated SCP-914 on Very Fine setting. OUTPUT UNPREDICTABLE."
					outcome["research_points"] = base_points + 20
					if(prob(danger_chance + 15))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-914 produced an anomalous or dangerous output!"
		if("scp-1048")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-1048. The bear appeared friendly and approached the observation window."
					outcome["research_points"] = base_points
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(2, "scp1048_cute")
				if("physical", "interaction")
					outcome["message"] = "Subject interacted with SCP-1048 in a controlled setting. It hugged them."
					outcome["research_points"] = base_points + 5
					if(prob(danger_chance + 10))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-1048 attempted to harvest material from the subject!"
						test_subject.adjustBruteLoss(10 + risk_level * 5)
				if("replication", "copy_analysis")
					outcome["message"] = "SCP-1048's replication behavior was studied. DANGER: body part collection observed."
					outcome["research_points"] = base_points + 25
		if("scp-1128")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject viewed SCP-1128 documentation under controlled conditions. Awareness established."
					outcome["research_points"] = base_points
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(-3, "scp1128_awareness")
				if("aquatic", "water_test")
					outcome["message"] = "Subject with SCP-1128 awareness was exposed to a controlled water environment."
					outcome["research_points"] = base_points + 15
					if(prob(danger_chance + 20))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-1128 MANIFESTED! Subject attacked!"
						test_subject.adjustBruteLoss(30 + risk_level * 10)
						test_subject.adjustOxyLoss(20)
				if("amnestic", "treatment")
					outcome["message"] = "Amnestic treatment administered to remove SCP-1128 awareness."
					outcome["research_points"] = base_points + 10
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(10, "scp1128_amnestic")
		if("scp-008")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-008 containment through biohazard glass. No exposure."
					outcome["research_points"] = base_points
				if("biological", "sample_analysis")
					outcome["message"] = "SCP-008 samples were analyzed under maximum biocontainment."
					outcome["research_points"] = base_points + 15
				if("exposure", "contact")
					outcome["message"] = "Subject was exposed to SCP-008 under controlled conditions. EXTREME DANGER."
					outcome["research_points"] = base_points + 30
					if(prob(danger_chance + 35))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SUBJECT INFECTED WITH SCP-008! INITIATING CONTAINMENT PROTOCOL!"
						test_subject.adjustToxLoss(30 + risk_level * 10)
						test_subject.adjustBruteLoss(15 + risk_level * 5)
		if("scp-087")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-087 entrance. Dread and unease reported."
					outcome["research_points"] = base_points
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(-5, "scp087_observation")
				if("descent", "exploration")
					outcome["message"] = "Subject descended SCP-087 for a controlled period. Psychological effects noted."
					outcome["research_points"] = base_points + 20
					if(prob(danger_chance + 15))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " SCP-087-1 ENTITY ENCOUNTERED! Subject fled in terror!"
						test_subject.adjustBruteLoss(20 + risk_level * 5)
						if(test_subject.sanity)
							test_subject.sanity.adjust_sanity(-20, "scp087_entity")
				if("audio", "sound")
					outcome["message"] = "Subject listened to audio recordings from inside SCP-087. Crying heard."
					outcome["research_points"] = base_points + 10
					if(test_subject.sanity)
						test_subject.sanity.adjust_sanity(-3 * risk_level, "scp087_audio")
		if("scp-3008")
			switch(test_type)
				if("observation", "visual")
					outcome["message"] = "Subject observed SCP-3008 entrance. The interior appears to be an IKEA store."
					outcome["research_points"] = base_points
				if("exploration", "interior")
					outcome["message"] = "Subject entered SCP-3008 for controlled exploration. Spatial distortion confirmed."
					outcome["research_points"] = base_points + 15
					if(prob(danger_chance + 10))
						outcome["danger_triggered"] = TRUE
						outcome["message"] += " Subject encountered hostile IKEA staff during night phase!"
						test_subject.adjustBruteLoss(25 + risk_level * 10)
				if("temporal", "day_night")
					outcome["message"] = "SCP-3008's day/night cycle was studied. Staff behavior shifts dramatically at night."
					outcome["research_points"] = base_points + 20
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

// Contraband scanning is handled by /obj/machinery/scp_checkpoint_scanner in security_checkpoints.dm
// Guard tackle is handled by /datum/component/tackler via tackler gloves

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
	if(SSround_objectives)
		SSround_objectives.report_objective_progress("guard_recontain", 1)

// D-Class escape routes are handled by /datum/dclass_escape_route in dclass_escape_routes.dm

/obj/machinery/civilian_evac_station
	name = "Evacuation Assembly Point"
	desc = "A designated evacuation point. Civilians can register here during emergencies."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "butt"
	anchored = TRUE
	density = FALSE
	var/registered_civilians = 0
	var/list/registered_ckey_list = list()
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
	if(user.ckey in registered_ckey_list)
		to_chat(H, span_notice("You are already registered at this evacuation point. Stay calm and wait for instructions."))
		return
	registered_civilians++
	registered_ckey_list[user.ckey] = world.time
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
	if(GLOB.scp_round_report)
		for(var/list/E in GLOB.scp_round_report.breach_log)
			recent_breaches += "[E["id"]] breach in [E["zone"]]"
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

/obj/item/reagent_containers/hypospray/medipen/amnestic
	name = "Class-A Amnestic Medipen"
	desc = "A medipen containing Class-A amnestics. Reverses Sarkic conversion and removes anomalous memories."
	icon_state = "atropine"
	volume = 5
	list_reagents = list(/datum/reagent/medicine/amnestics/classa = 5)

/datum/reagent/medicine/amnestics/classa/on_mob_add(mob/living/L, amount)
	. = ..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(H.mind)
		var/list/to_remove = list()
		for(var/datum/antagonist/A in H.mind.antag_datums)
			if(istype(A, /datum/antagonist/sarkic_cult))
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

// ============================================================================
// #15 JOB-SPECIFIC SCP INTERACTIONS — Deeper role integration
// ============================================================================

/obj/machinery/scp_sample_analyzer
	name = "SCP Sample Analyzer"
	desc = "A machine for analyzing SCP specimen samples. Medical and Research personnel get bonus research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "mass_spectrometer"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/analyze_cooldown = 0
	var/analyze_cooldown_time = 20 SECONDS

/obj/machinery/scp_sample_analyzer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/scp_sample_vial))
		if(world.time < analyze_cooldown)
			to_chat(user, span_warning("The analyzer is still calibrating from the last analysis."))
			return
		var/obj/item/scp_sample_vial/vial = W
		if(vial.analyzed)
			to_chat(user, span_warning("This sample has already been analyzed."))
			return
		to_chat(user, span_notice("You insert the sample vial into the analyzer..."))
		if(!do_after(user, src, 5 SECONDS))
			return
		analyze_cooldown = world.time + analyze_cooldown_time
		var/bonus_multiplier = 1.0
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.job && (findtext(H.job, "Medical") || findtext(H.job, "Doctor") || findtext(H.job, "Chemist")))
				bonus_multiplier = 1.5
				to_chat(H, span_notice("Your medical training improves analysis efficiency!"))
			else if(H.job && (findtext(H.job, "Scientist") || findtext(H.job, "Research")))
				bonus_multiplier = 1.3
				to_chat(H, span_notice("Your research experience aids the analysis!"))
		var/bonus_points = round(vial.research_value * 0.5 * bonus_multiplier)
		vial.research_value += bonus_points
		vial.analyze(user)
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		if(SSround_objectives)
			SSround_objectives.report_objective_progress("research_unlock", 1)
		qdel(vial)
		return
	return ..()

/obj/machinery/scp_containment_integrity_scanner
	name = "Containment Integrity Scanner"
	desc = "A wall-mounted scanner that evaluates containment integrity in the area. Engineers can use it to identify weak points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "body_scanner"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/scan_cooldown = 0
	var/scan_cooldown_time = 30 SECONDS

/obj/machinery/scp_containment_integrity_scanner/attack_hand(mob/user)
	if(world.time < scan_cooldown)
		to_chat(user, span_warning("Scanner recharging..."))
		return
	scan_cooldown = world.time + scan_cooldown_time
	var/area/A = get_area(src)
	if(!A)
		to_chat(user, span_warning("Unable to determine current area."))
		return
	var/list/weak_points = list()
	var/overall_integrity = 100
	for(var/obj/structure/containment_upgrade_frame/F in A)
		weak_points += "Unfinished upgrade frame at [get_area(F)]"
	for(var/mob/living/scp/S in A)
		var/integrity_pct = round(S.containment_integrity)
		overall_integrity = min(overall_integrity, integrity_pct)
		if(integrity_pct < 50)
			weak_points += "CRITICAL: SCP-[S.SCP?.designation || "???"] containment at [integrity_pct]% integrity"
		else if(integrity_pct < 80)
			weak_points += "WARNING: SCP-[S.SCP?.designation || "???"] containment at [integrity_pct]% integrity"
	var/engineer_bonus = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.job && (findtext(H.job, "Engineer") || findtext(H.job, "Containment Engineer")))
			engineer_bonus = TRUE
			for(var/turf/closed/wall/scp_containment/W in A)
				if(W.containment_integrity < W.max_containment_integrity * 0.7)
					weak_points += "Damaged containment wall at [W.x],[W.y]"
	to_chat(user, span_notice("<b>CONTAINMENT INTEGRITY REPORT — [A.name]</b>"))
	to_chat(user, span_notice("Overall Integrity: [overall_integrity]%"))
	if(length(weak_points))
		to_chat(user, span_warning("<b>Issues Found:</b>"))
		for(var/issue in weak_points)
			to_chat(user, span_warning("  - [issue]"))
		if(engineer_bonus)
			to_chat(user, span_notice("Engineer analysis: Repair damaged walls and complete upgrade frames to restore integrity."))
			if(SSround_objectives)
				SSround_objectives.report_objective_progress("engineer_repair", 1)
	else
		to_chat(user, span_green("No containment issues detected."))
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/machinery/scp_chemical_synthesizer
	name = "SCP Chemical Synthesizer"
	desc = "A specialized synthesizer for producing SCP-related chemical compounds. Chemists and Doctors can create specialized reagents."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "mass_spectrometer"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	var/synth_cooldown = 0
	var/synth_cooldown_time = 45 SECONDS

/obj/machinery/scp_chemical_synthesizer/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(world.time < synth_cooldown)
		to_chat(H, span_warning("Synthesizer recharging..."))
		return
	var/is_qualified = FALSE
	if(H.job && (findtext(H.job, "Medical") || findtext(H.job, "Doctor") || findtext(H.job, "Chemist")))
		is_qualified = TRUE
	if(!is_qualified)
		to_chat(H, span_warning("You need medical or chemical training to operate this synthesizer."))
		return
	var/list/options = list(
		"Amnestic Compound (Class-A)" = /datum/reagent/medicine/amnestics/classa,
		"SCP-008 Counteragent" = /datum/reagent/medicine/scp008_counteragent,
		"Anomalous Stabilizer" = /datum/reagent/medicine/anomalous_stabilizer,
	)
	var/choice = input(H, "Select compound to synthesize:", "SCP Chemical Synthesizer") as null|anything in options
	if(!choice || !options[choice])
		return
	synth_cooldown = world.time + synth_cooldown_time
	var/reagent_type = options[choice]
	var/obj/item/reagent_containers/glass/bottle/B = new(get_turf(H))
	B.name = "[choice] bottle"
	B.reagents.add_reagent(reagent_type, 15)
	H.put_in_hands(B)
	to_chat(H, span_notice("You synthesize a bottle of [choice]."))
	adjust_global_research_points(5, "chemical_synthesis:[choice]")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/datum/reagent/medicine/scp008_counteragent
	name = "SCP-008 Counteragent"
	description = "A counteragent that slows SCP-008 infection if administered early."
	reagent_state = LIQUID
	color = "#00FF44"

/datum/reagent/medicine/scp008_counteragent/on_mob_metabolize(mob/living/L)
	. = ..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	H.adjustToxLoss(-5)
	to_chat(H, span_notice("You feel the counteragent fighting off the infection..."))

/datum/reagent/medicine/anomalous_stabilizer
	name = "Anomalous Stabilizer"
	description = "A compound that helps stabilize sanity after anomalous exposure."
	reagent_state = LIQUID
	color = "#8844FF"

/datum/reagent/medicine/anomalous_stabilizer/on_mob_metabolize(mob/living/L)
	. = ..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(H.sanity)
		H.sanity.adjust_sanity(10, "anomalous_stabilizer")

/obj/machinery/scp_cooking_station
	name = "SCP Anomalous Kitchen Station"
	desc = "A cooking station designed to prepare meals for SCP-affected personnel. Chefs can create morale-boosting dishes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/cook_cooldown = 0
	var/cook_cooldown_time = 60 SECONDS

/obj/machinery/scp_cooking_station/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(world.time < cook_cooldown)
		to_chat(H, span_warning("The oven is still heating up from the last batch."))
		return
	var/is_chef = H.job && findtext(H.job, "Chef")
	var/is_kitchen = H.job && findtext(H.job, "Kitchen")
	if(!is_chef && !is_kitchen)
		to_chat(H, span_notice("You don't know how to operate this specialized kitchen equipment."))
		return
	var/list/dishes = list(
		"Morale-Boosting Stew" = 1,
		"Containment Shift Rations" = 2,
		"Anomalous Residue Analysis Meal" = 3,
	)
	var/choice = input(H, "Select dish to prepare:", "SCP Kitchen Station") as null|anything in dishes
	if(!choice)
		return
	cook_cooldown = world.time + cook_cooldown_time
	to_chat(H, span_notice("You begin preparing [choice]..."))
	if(!do_after(H, src, 10 SECONDS))
		return
	var/obj/item/reagent_containers/food/snacks/S = new /obj/item/reagent_containers/food/snacks/cookie(get_turf(H))
	S.name = choice
	switch(choice)
		if("Morale-Boosting Stew")
			S.desc = "A hearty stew that warms the soul. Popular with personnel on long containment shifts."
			S.list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/medicine/anomalous_happiness = 3)
		if("Containment Shift Rations")
			S.desc = "Dense, nutritious rations designed for guards on extended containment duty."
			S.list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/coffee = 5)
		if("Anomalous Residue Analysis Meal")
			S.desc = "A carefully prepared meal for testing anomalous residue interactions. Provides research data."
			S.list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/anomalous_stabilizer = 2)
			adjust_global_research_points(10, "chef_analysis_meal")
	H.put_in_hands(S)
	to_chat(H, span_notice("You prepare [choice]."))
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/structure/scp_janitor_supply_cabinet
	name = "SCP Janitorial Supply Cabinet"
	desc = "A cabinet stocked with specialized cleaning supplies for SCP contamination. Janitors can restock breach cleanup kits here."
	icon = 'icons/obj/structures.dmi'
	icon_state = "cabinet"
	density = TRUE
	anchored = TRUE
	var/restock_cooldown = 0
	var/restock_cooldown_time = 30 SECONDS

/obj/structure/scp_janitor_supply_cabinet/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(world.time < restock_cooldown)
		to_chat(H, span_warning("Supplies are being restocked. Please wait."))
		return
	var/is_janitor = H.job && findtext(H.job, "Janitor")
	if(!is_janitor)
		to_chat(H, span_notice("You don't have the clearance for SCP-specific janitorial supplies."))
		return
	restock_cooldown = world.time + restock_cooldown_time
	var/obj/item/breach_cleanup_kit/kit = new(get_turf(H))
	H.put_in_hands(kit)
	to_chat(H, span_notice("You retrieve a breach cleanup kit from the supply cabinet."))
	adjust_global_research_points(2, "janitor_restock")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/obj/structure/scp_janitor_supply_cabinet/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/breach_cleanup_kit))
		var/obj/item/breach_cleanup_kit/kit = W
		if(kit.uses_remaining >= 5)
			to_chat(user, span_notice("This kit is already fully stocked."))
			return
		kit.uses_remaining = 5
		to_chat(user, span_notice("You restock the breach cleanup kit from the supply cabinet."))
		return
	return ..()


