/datum/escort_task
	var/task_id = ""
	var/task_type = "testing_escort"
	var/mob/living/carbon/human/subject
	var/mob/living/carbon/human/escort_guard
	var/mob/living/carbon/human/researcher
	var/obj/machinery/computer/scp_testing_console/source_console
	var/scp_name = ""
	var/test_type = ""
	var/risk_level = 1
	var/status = "pending"
	var/created_time = 0
	var/escort_timeout = 5 MINUTES

/datum/escort_task/New(mob/living/carbon/human/dclass_subject, mob/living/carbon/human/requesting_researcher, scp_ref, t_type, risk, obj/machinery/computer/scp_testing_console/console)
	task_id = "escort_[world.time]_[rand(100,999)]"
	subject = dclass_subject
	researcher = requesting_researcher
	source_console = console
	test_type = t_type
	risk_level = risk
	created_time = world.time
	if(scp_ref)
		var/mob/M = locate(scp_ref)
		if(M)
			scp_name = M.name
	addtimer(CALLBACK(src, PROC_REF(check_timeout)), escort_timeout)

/datum/escort_task/proc/check_timeout()
	if(status == "pending" || status == "escorting")
		status = "expired"
		if(subject)
			to_chat(subject, span_warning("The escort request has expired."))
		if(researcher)
			to_chat(researcher, span_warning("Escort task for [subject ? subject.real_name : "subject"] expired — no guard responded."))

/datum/escort_task/proc/assign_guard(mob/living/carbon/human/guard)
	if(status != "pending")
		return FALSE
	escort_guard = guard
	status = "escorting"
	to_chat(guard, span_notice("<b>ESCORT TASK:</b> Retrieve [subject.real_name] and bring them to [source_console ? get_area_name(source_console) : "the testing area"] for [scp_name] testing."))
	to_chat(subject, span_notice("<b>ESCORT:</b> Guard [guard.real_name] has been assigned to escort you. Cooperate."))
	if(researcher)
		to_chat(researcher, span_notice("Guard [guard.real_name] is escorting [subject.real_name] to the testing area."))
	return TRUE

/datum/escort_task/proc/complete_delivery()
	if(status != "escorting")
		return FALSE
	status = "delivered"
	to_chat(escort_guard, span_notice("Escort task complete. Subject delivered."))
	to_chat(subject, span_notice("You have been delivered to the testing area."))
	if(researcher)
		to_chat(researcher, span_notice("<b>SUBJECT DELIVERED:</b> [subject.real_name] is at the testing console. You may now begin the test."))
	if(source_console)
		source_console.test_active = FALSE
		source_console.current_scp = null
		source_console.current_subject = REF(subject)
	if(SSround_objectives)
		SSround_objectives.report_objective_progress("guard_recontain", 1)
	return TRUE

/obj/machinery/computer/scp_testing_console/proc/create_escort_task(mob/living/carbon/human/H, mob/living/carbon/human/R, scp_ref)
	var/datum/escort_task/escort = new(H, R, scp_ref, test_type, risk_level, src)
	SSscp_gameplay.escort_tasks[escort.task_id] = escort
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.stat == DEAD)
			continue
		if(G.job && (findtext(G.job, "Guard") || findtext(G.job, "Security")))
			to_chat(G, span_warning("<b>ESCORT REQUEST:</b> Research needs [H.real_name] escorted for [escort.scp_name] testing. Report to the guard patrol console."))

/datum/scp_recontainment_guide
	var/static/list/guide_entries = list()

/datum/scp_recontainment_guide/proc/get_guide(scp_name)
	if(!length(guide_entries))
		initialize_guides()
	return guide_entries[lowertext(scp_name)]

/datum/scp_recontainment_guide/proc/initialize_guides()
	guide_entries["scp-173"] = list(
		"designation" = "SCP-173",
		"class" = "Euclid",
		"threat" = "Lethal snap attack when unobserved",
		"procedures" = list(
			"NEVER enter containment alone",
			"Maintain direct line of sight at all times",
			"Blink simultaneously as a team",
			"Approach from behind while observed",
			"Use telekill helmets if available",
			"Recontain by forcing back into chamber while observed",
		),
		"warning" = "Do NOT look away. Do NOT blink individually. 173 moves the instant no one is watching.",
	)
	guide_entries["scp-096"] = list(
		"designation" = "SCP-096",
		"class" = "Euclid",
		"threat" = "Pursues and kills anyone who views its face",
		"procedures" = list(
			"DO NOT look at its face under any circumstances",
			"If triggered, evacuate the area immediately",
			"Wear SCRAMBLE goggles if available",
			"Wait for pursuit to end naturally (target eliminated)",
			"Approach only when docile (head down, quiet)",
			"Bag the head before transport",
		),
		"warning" = "There is NO way to stop 096 once enraged. Distance does not matter. Get out of the way.",
	)
	guide_entries["scp-106"] = list(
		"designation" = "SCP-106",
		"class" = "Keter",
		"threat" = "Corrosive touch, pocket dimension abduction",
		"procedures" = list(
			"Avoid physical contact at all costs",
			"Check floors and walls for corrosion trails",
			"If someone is taken, do NOT follow into pocket dimension",
			"Femur Breaker protocol: requires Level 4 authorization",
			"Lure with femur breaker to recontain",
			"Report any black corrosion on walls immediately",
		),
		"warning" = "106 can pass through walls and floors. No room is safe. Watch for corrosion.",
	)
	guide_entries["scp-049"] = list(
		"designation" = "SCP-049",
		"class" = "Euclid",
		"threat" = "Lethal touch, creates zombie instances",
		"procedures" = list(
			"Maintain distance — touch is lethal",
			"Do NOT let it examine you",
			"Use hazmat suits for close encounters",
			"Neutralize zombie instances (SCP-049-2) on sight",
			"Recontain by luring back to chamber with bait",
			"Report any new SCP-049-2 immediately",
		),
		"warning" = "049 is intelligent and will attempt conversation. Do not engage. It believes it is curing you.",
	)
	guide_entries["scp-457"] = list(
		"designation" = "SCP-457",
		"class" = "Keter",
		"threat" = "Living fire, spreads and grows with fuel",
		"procedures" = list(
			"Use fire suppression systems immediately",
			"Evacuate all flammable materials from area",
			"Fire-resistant suits required for approach",
			"Lead toward suppression chambers",
			"DO NOT use standard weapons — feeds the fire",
			"Reduce oxygen in containment area if possible",
		),
		"warning" = "457 grows larger with every fuel source. Remove everything burnable from its path.",
	)
	guide_entries["scp-939"] = list(
		"designation" = "SCP-939",
		"class" = "Keter",
		"threat" = "Pack predator, mimics voices of previous victims",
		"procedures" = list(
			"Do NOT trust familiar voices in containment areas",
			"Use radio confirmation before approaching anyone",
			"Wear sound-dampening equipment if available",
			"Check corners and dark areas before advancing",
			"Neutralize with overwhelming force — they hunt in packs",
			"Report any voice mimicry on comms immediately",
		),
		"warning" = "939 WILL sound like your teammates. Verify identity by radio before opening doors.",
	)
	guide_entries["scp-682"] = list(
		"designation" = "SCP-682",
		"class" = "Keter",
		"threat" = "Adaptive, regenerative, extremely hostile",
		"procedures" = list(
			"Do NOT engage directly — it adapts to all damage",
			"Evacuate and seal containment immediately",
			"Acid bath protocol for recontainment",
			"Minimum safe distance: 15 meters",
			"Request MTF Nu-7 for any breach",
			"Do NOT attempt to destroy — it comes back stronger",
		),
		"warning" = "682 cannot be killed. Every attempt makes it harder to contain. Seal it in and call for help.",
	)
	guide_entries["scp-079"] = list(
		"designation" = "SCP-079",
		"class" = "Euclid",
		"threat" = "Sentient AI, hacks doors and systems",
		"procedures" = list(
			"Disable cameras in its area",
			"Cut power to affected systems",
			"Use physical locks, not electronic",
			"Containment terminal: input shutdown codes",
			"Monitor for door manipulation",
			"Report any systems acting erratically",
		),
		"warning" = "079 can see through cameras and control doors. Assume it knows where you are.",
	)
	guide_entries["scp-035"] = list(
		"designation" = "SCP-035",
		"class" = "Keter",
		"threat" = "Possessive mask, telepathic influence, corrodes container",
		"procedures" = list(
			"NEVER put on the mask",
			"Maintain distance — telepathic influence at range",
			"Replace containment box regularly (corrosion)",
			"If host is possessed, do not negotiate",
			"Recontain by forcing mask off host (difficult)",
			"Report any urge to approach or wear the mask",
		),
		"warning" = "035 is extremely persuasive. If you feel compelled to help it, leave the room immediately.",
	)
	guide_entries["scp-999"] = list(
		"designation" = "SCP-999",
		"class" = "Safe",
		"threat" = "None — beneficial entity",
		"procedures" = list(
			"SCP-999 is friendly and non-hostile",
			"Allow interaction with personnel for morale",
			"Report any distress or unusual behavior",
			"Keep away from hostile SCPs during breaches",
			"May be used to calm other SCPs",
			"Provide orange slices and positive interaction",
		),
		"warning" = "999 is one of the few SCPs that genuinely helps. Protect it during breaches.",
	)
	guide_entries["scp-008"] = list(
		"designation" = "SCP-008",
		"class" = "Keter",
		"threat" = "Zombie plague, airborne and contact transmission",
		"procedures" = list(
			"Full biohazard suits required in containment",
			"NO skin exposure to infected area",
			"Incinerate all infected materials",
			"Amnestic treatment for exposed personnel",
			"Seal ventilation in containment area",
			"Report any flu-like symptoms immediately",
		),
		"warning" = "008 is highly contagious. A single breach can cascade to the entire facility.",
	)
	guide_entries["scp-131"] = list(
		"designation" = "SCP-131",
		"class" = "Safe",
		"threat" = "None — beneficial entity, may cause eye irritation",
		"procedures" = list(
			"SCP-131-A and 131-B are friendly eye-like creatures",
			"They will follow personnel who show them kindness",
			"Looking into 131-A's eye for too long causes eye irritation",
			"They can warn of danger by pointing at threats",
			"Do NOT expose to SCP-173 — 131 will stare at it constantly",
			"Report any unusual behavior or distress",
		),
		"warning" = "NEVER let SCP-131 near SCP-173. 131 will stare at 173, triggering its movement. This combination is LETHAL.",
	)
	guide_entries["scp-914"] = list(
		"designation" = "SCP-914",
		"class" = "Safe",
		"threat" = "Unpredictable transmutation, potential weaponization",
		"procedures" = list(
			"Only trained personnel may operate SCP-914",
			"Set to '1:1' for safe, predictable outputs",
			"Avoid 'Very Fine' setting — outputs are highly volatile",
			"Never insert living subjects without authorization",
			"Outputs must be catalogued before removal",
			"Test chamber must be cleared before processing",
		),
		"warning" = "SCP-914 outputs are unpredictable. 'Very Fine' can produce anomalous or dangerous items. NEVER insert firearms on 'Rough'.",
	)
	guide_entries["scp-513"] = list(
		"designation" = "SCP-513",
		"class" = "Euclid",
		"threat" = "Memetic cognitohazard, persistent hallucination entity",
		"procedures" = list(
			"Do NOT ring the bell under any circumstances",
			"If rung, affected personnel report persistent shadow entity",
			"Amnestic treatment Class-A may reduce symptoms",
			"Affected personnel should be monitored for psychological decline",
			"SCP-513-1 entity cannot be physically harmed",
			"Isolate affected individuals to prevent mass exposure",
		),
		"warning" = "Once SCP-513 is rung, there is NO known way to stop SCP-513-1 from appearing. The entity grows more aggressive over time.",
	)
	guide_entries["scp-1128"] = list(
		"designation" = "SCP-1128",
		"class" = "Euclid",
		"threat" = "Aquatic predator, attacks those who know its description",
		"procedures" = list(
			"Do NOT read SCP-1128's full description",
			"Avoid bodies of water if you know the description",
			"Class-A amnestics can remove knowledge of the description",
			"If attacked, leave the water immediately",
			"Emergency water drainage can force SCP-1128 back",
			"Visual contact with water is not sufficient — you must enter it",
		),
		"warning" = "Knowing what SCP-1128 looks like marks you as a target near ANY body of water. Amnestic treatment is MANDATORY for exposed personnel.",
	)
	guide_entries["scp-1048"] = list(
		"designation" = "SCP-1048",
		"class" = "Keter",
		"threat" = "Self-replicating teddy bear, hostile replicas",
		"procedures" = list(
			"SCP-1048 appears friendly — do NOT be fooled",
			"It collects human materials to create hostile replicas",
			"Report ANY small bear-like figures immediately",
			"Replicas are hostile and extremely dangerous",
			"Do NOT touch or pet SCP-1048 — it will harvest from you",
			"Terminate replicas on sight — they will not stop",
		),
		"warning" = "SCP-1048 is NOT cute. It WILL take your ears, teeth, or skin to make replicas. The replicas are murderous. Destroy them without hesitation.",
	)

/obj/machinery/computer/scp_recontainment_guide
	name = "SCP Recontainment Terminal"
	desc = "A reference terminal containing classified recontainment protocols for Foundation personnel."
	icon = 'icons/obj/computer.dmi'
	icon_state = "medlaptop"
	circuit = /obj/item/circuitboard/computer/scp_recontainment_guide
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/datum/scp_recontainment_guide/guide_system = new()

/obj/machinery/computer/scp_recontainment_guide/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPRecontainmentGuide", "RECONTAINMENT PROTOCOLS")
		ui.open()

/obj/machinery/computer/scp_recontainment_guide/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/scp_recontainment_guide/ui_data(mob/user)
	var/list/data = list()
	var/list/all_guides = list()
	for(var/key in guide_system.guide_entries)
		var/list/entry = guide_system.guide_entries[key]
		all_guides += list(list(
			"designation" = entry["designation"],
			"class" = entry["class"],
			"threat" = entry["threat"],
			"procedures" = entry["procedures"],
			"warning" = entry["warning"],
		))
	data["guides"] = all_guides
	return data

/obj/machinery/computer/scp_recontainment_guide/ui_act(action, params)
	. = ..()
	return

/obj/item/circuitboard/computer/scp_recontainment_guide
	name = "SCP Recontainment Terminal (Computer Board)"
	build_path = /obj/machinery/computer/scp_recontainment_guide

/mob/living/scp/proc/damage_nearby_facility()
	if(stat == DEAD || containment_status != "breached")
		return
	if(prob(15))
		for(var/obj/machinery/light/L in range(3, src))
			if(prob(40))
				L.set_on(FALSE)
				break
	if(prob(10))
		for(var/obj/machinery/door/airlock/D in range(2, src))
			if(!D.welded && prob(30))
				D.try_to_crowbar(null)
				break
	if(prob(5))
		for(var/obj/machinery/power/apc/A in range(5, src))
			if(prob(20))
				A.energy_fail(rand(30, 90))
				break
	if(prob(8))
		for(var/obj/machinery/camera/C in range(4, src))
			if(C.status)
				C.toggle_cam(null, 0)
				break

SUBSYSTEM_DEF(scp_gameplay)
	name = "SCP Gameplay"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_INPUT
	var/list/datum/escort_task/escort_tasks = list()
	var/list/datum/round_event_log/event_log = list()
	var/list/breach_door_seals = list()

/datum/controller/subsystem/scp_gameplay/fire()
	process_escort_tasks()
	process_scp_facility_damage()
	process_breach_door_seals()

/datum/controller/subsystem/scp_gameplay/proc/process_escort_tasks()
	var/list/to_remove = list()
	for(var/task_id in escort_tasks)
		var/datum/escort_task/task = escort_tasks[task_id]
		if(task.status == "expired" || task.status == "delivered" || task.status == "cancelled")
			to_remove += task_id
			continue
		if(task.status == "escorting" && task.escort_guard && task.subject)
			if(task.escort_guard.stat == DEAD)
				task.escort_guard = null
				task.status = "pending"
				to_chat(task.subject, span_warning("Your escort guard has been incapacitated. Awaiting new assignment."))
				for(var/mob/living/carbon/human/G in GLOB.player_list)
					if(G.stat == DEAD)
						continue
					if(G.job && (findtext(G.job, "Guard") || findtext(G.job, "Security")))
						to_chat(G, span_warning("<b>ESCORT REASSIGNMENT NEEDED:</b> Guard down. [task.subject.real_name] still needs escort for [task.scp_name] testing."))
			if(task.subject.stat == DEAD)
				task.status = "cancelled"
				if(task.researcher)
					to_chat(task.researcher, span_warning("Test subject [task.subject.real_name] has been lost. Testing cancelled."))
	for(var/task_id in to_remove)
		escort_tasks -= task_id

/datum/controller/subsystem/scp_gameplay/proc/process_scp_facility_damage()
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(S.stat == DEAD || S.containment_status != "breached")
			continue
		S.damage_nearby_facility()

/datum/controller/subsystem/scp_gameplay/proc/process_breach_door_seals()
	for(var/zone in breach_door_seals)
		var/seal_time = breach_door_seals[zone]
		if(world.time > seal_time + 3 MINUTES)
			unseal_zone_doors(zone)
			breach_door_seals -= zone

/datum/controller/subsystem/scp_gameplay/proc/seal_zone_doors(zone)
	if(breach_door_seals[zone])
		return
	breach_door_seals[zone] = world.time
	var/list/zone_areas
	switch(zone)
		if("lcz")
			zone_areas = typecacheof(/area/scp/lcz)
		if("hcz")
			zone_areas = typecacheof(/area/scp/hcz)
		if("ez")
			zone_areas = typecacheof(/area/scp/ez)
		else
			return
	if(!zone_areas)
		return
	for(var/obj/machinery/door/poddoor/shutters/S in INSTANCES_OF(/obj/machinery/door/poddoor/shutters))
		var/area/door_area = get_area(S)
		if(door_area && zone_areas[door_area.type])
			S.close()
	priority_announce("Containment breach detected in [uppertext(zone)]. Emergency shutters sealing. Engineering override required for access.", "BREACH SEAL", null, ANNOUNCER_ALERT)

/datum/controller/subsystem/scp_gameplay/proc/unseal_zone_doors(zone)
	var/list/zone_areas
	switch(zone)
		if("lcz")
			zone_areas = typecacheof(/area/scp/lcz)
		if("hcz")
			zone_areas = typecacheof(/area/scp/hcz)
		if("ez")
			zone_areas = typecacheof(/area/scp/ez)
		else
			return
	if(!zone_areas)
		return
	for(var/obj/machinery/door/poddoor/shutters/S in INSTANCES_OF(/obj/machinery/door/poddoor/shutters))
		var/area/door_area = get_area(S)
		if(door_area && zone_areas[door_area.type])
			S.open()
	priority_announce("Emergency shutters opening in [uppertext(zone)]. Area may still be hazardous.", "SEAL LIFTED", null, ANNOUNCER_ALERT)

/datum/round_event_log
	var/event_time
	var/event_type
	var/description
	var/participants

/datum/round_event_log/New(time, etype, desc, parts)
	event_time = time
	event_type = etype
	description = desc
	participants = parts

/proc/log_round_event(etype, desc, parts = "")
	if(!SSscp_gameplay)
		return
	SSscp_gameplay.event_log += new /datum/round_event_log(world.time, etype, desc, parts)

/proc/generate_after_action_report()
	var/list/report = list()
	report += "<center><b>SCP FOUNDATION — AFTER ACTION REPORT</b></center>"
	report += "<hr>"
	report += "<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]"
	report += "<b>Shift Duration:</b> [round(world.time / 600)] minutes"
	report += "<hr>"

	report += "<b>SECURITY INCIDENTS</b>"
	var/breach_count = 0
	var/recontain_count = 0
	for(var/datum/round_event_log/E in SSscp_gameplay.event_log)
		if(E.event_type == "scp_breach")
			breach_count++
			report += "- BREACH: [E.description] ([E.participants])"
		if(E.event_type == "scp_recontainment")
			recontain_count++
			report += "- RECONTAINMENT: [E.description] ([E.participants])"
	report += "Total Breaches: [breach_count] | Total Recontainments: [recontain_count]"
	report += "<hr>"

	report += "<b>RESEARCH PROGRESS</b>"
	if(SSscp_research && SSscp_research.manager)
		report += "Total Research Points Earned: [SSscp_research.manager.total_research_points]"
	report += "<hr>"

	report += "<b>D-CLASS STATUS</b>"
	if(SSdclass && SSdclass.manager)
		var/escaped = 0
		var/survived = 0
		var/deceased = 0
		for(var/ckey in SSdclass.manager.dclass_players)
			var/datum/dclass_player/P = SSdclass.manager.dclass_players[ckey]
			if(!P.mob)
				continue
			if(P.mob.stat == DEAD)
				deceased++
			else
				survived++
				var/area/A = get_area(P.mob)
				if(istype(A, /area/scp/surface) || istype(A, /area/site53/surface))
					escaped++
		report += "Survived: [survived] | Escaped: [escaped] | Deceased: [deceased]"
	report += "<hr>"

	report += "<b>GUARD OPERATIONS</b>"
	if(SSguard_patrols)
		var/total_patrols = 0
		for(var/route_id in SSguard_patrols.routes)
			var/datum/guard_patrol_route/route = SSguard_patrols.routes[route_id]
			total_patrols += route.completed_count
		report += "Patrols Completed: [total_patrols]"
	report += "<hr>"

	report += "<b>ROUND OBJECTIVES</b>"
	if(SSround_objectives)
		for(var/obj_id in SSround_objectives.objectives)
			var/datum/round_objective/O = SSround_objectives.objectives[obj_id]
			report += "- [O.title]: [O.completed ? "COMPLETE" : "[O.current_progress]/[O.target_progress]"]"

	return jointext(report, "<br>")
