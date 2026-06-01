/datum/escort_task
	var/task_id = ""
	var/task_type = "testing_escort"
	var/mob/living/carbon/human/subject
	var/mob/living/carbon/human/escort_guard
	var/mob/living/carbon/human/researcher
	var/scp_name = ""
	var/test_type = ""
	var/risk_level = 1
	var/status = "pending"
	var/created_time = 0
	var/escort_timeout = 5 MINUTES

/datum/escort_task/New(mob/living/carbon/human/dclass_subject, mob/living/carbon/human/requesting_researcher, scp_ref, t_type, risk)
	task_id = "escort_[world.time]_[rand(100,999)]"
	subject = dclass_subject
	researcher = requesting_researcher
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
	to_chat(guard, span_notice("<b>ESCORT TASK:</b> Retrieve [subject.real_name] and bring them to the testing area for [scp_name] testing."))
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
	if(SSround_objectives)
		SSround_objectives.report_objective_progress("guard_recontain", 1)
	return TRUE

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
	guide_entries["scp-087"] = list(
		"designation" = "SCP-087",
		"class" = "Euclid",
		"threat" = "Endless stairwell, psychological horror, hostile entity (SCP-087-1)",
		"procedures" = list(
			"Do NOT enter SCP-087 without authorization",
			"Descent causes progressive psychological deterioration",
			"SCP-087-1 entity stalks and attacks descenders",
			"Maximum recommended descent depth: 4 floors",
			"Always maintain voice contact with surface team",
			"Amnestic treatment recommended for all who descend",
		),
		"warning" = "SCP-087's depths are seemingly infinite. Those who descend too far do not return. The crying you hear is a lure.",
	)
	guide_entries["scp-3008"] = list(
		"designation" = "SCP-3008",
		"class" = "Euclid",
		"threat" = "Infinite IKEA dimension, hostile staff at night, temporal distortion",
		"procedures" = list(
			"SCP-3008 is an entrance to an apparently infinite IKEA store",
			"Day/night cycle inside — staff become hostile at night",
			"Personnel inside during night phase MUST find shelter",
			"Navigation is extremely difficult — spatial distortion",
			"Rescue operations require GPS tethering equipment",
			"Do NOT engage IKEA staff during night phase — flee and hide",
		),
		"warning" = "Once inside SCP-3008, finding the exit is nearly impossible. The staff are not human. They WILL attack at night. Survive until morning.",
	)
	guide_entries["scp-076"] = list(
		"designation" = "SCP-076",
		"class" = "Keter",
		"threat" = "Hostile humanoid, respawns from stone cube upon death",
		"procedures" = list(
			"SCP-076-2 is a highly skilled hostile combatant",
			"Upon death, it reforms inside SCP-076-1 (the stone cube)",
			"Monitor SCP-076-1 for signs of awakening — vibration, humming",
			"Mobile Task Force Omega-7 for containment operations only",
			"Kill on sight if breached — it will not negotiate",
			"Cube containment must be sealed at all times",
		),
		"warning" = "SCP-076-2 is faster, stronger, and more skilled than any human. It treats combat as sport. Killing it is temporary — it always comes back.",
	)
	guide_entries["scp-500"] = list(
		"designation" = "SCP-500",
		"class" = "Safe",
		"threat" = "None — beneficial item, limited supply",
		"procedures" = list(
			"SCP-500 is a bottle of 47 red pills that cure any disease",
			"Each pill is irreplaceable — use ONLY with Level 4 authorization",
			"Pills have been confirmed to cure SCP-008 infection",
			"Remaining pill count must be logged after each use",
			"Replication attempts via SCP-914 have been denied",
			"Report any unauthorized access to the SCP-500 storage",
		),
		"warning" = "There are a finite number of SCP-500 pills. Once they are gone, they are gone forever. Do NOT waste them on minor ailments.",
	)
	guide_entries["scp-427"] = list(
		"designation" = "SCP-427",
		"class" = "Safe",
		"threat" = "Beneficial healing object, prolonged use causes horrific mutation (SCP-427-1)",
		"procedures" = list(
			"SCP-427 is a small locket that rapidly heals injuries when held",
			"LIMITED USE ONLY — 30 seconds maximum exposure",
			"Prolonged exposure causes uncontrolled biological mutation",
			"Subjects who overuse become SCP-427-1 — flesh monsters",
			"SCP-427-1 instances are hostile and must be terminated",
			"Return SCP-427 to secure storage after each authorized use",
		),
		"warning" = "SCP-427 will heal you — and then it will change you. The mutation is irreversible. Use for 30 seconds ONLY. Set a timer.",
	)
	guide_entries["scp-1499"] = list(
		"designation" = "SCP-1499",
		"class" = "Safe",
		"threat" = "Dimensional displacement helmet, hostile entities in alternate dimension",
		"procedures" = list(
			"SCP-1499 is a gas mask that transports the wearer to an alternate dimension",
			"Removing the mask returns the wearer to their original location",
			"Entities in the dimension are hostile — avoid contact",
			"Use ONLY in secure areas with a spotter present",
			"If the wearer does not return after 5 minutes, assume containment breach",
			"Never use SCP-1499 near other SCPs",
		),
		"warning" = "If SCP-1499 is removed while in the alternate dimension, the wearer is stranded. Always have a buddy system. The entities there are NOT friendly.",
	)
	guide_entries["scp-012"] = list(
		"designation" = "SCP-012",
		"class" = "Euclid",
		"threat" = "Compulsive score completion, self-mutilation",
		"procedures" = list(
			"SCP-012 is a musical score that compels viewers to complete it",
			"Viewers will use their own blood to finish writing the score",
			"NEVER view SCP-012 directly — use camera feeds only",
			"Personnel affected must be physically restrained immediately",
			"Amnestic treatment required for exposed personnel",
			"Containment room must have no sharp objects",
		),
		"warning" = "SCP-012 will make you want to complete it — with your own blood. By the time you realize what you're doing, it may be too late. Do NOT look at it.",
	)
	guide_entries["scp-895"] = list(
		"designation" = "SCP-895",
		"class" = "Euclid",
		"threat" = "Camera-disrupting coffin, causes cardiac arrest via video feed",
		"procedures" = list(
			"SCP-895 disrupts any camera feed that observes it",
			"Viewing SCP-895 through a camera causes psychological disturbance",
			"Prolonged camera observation causes cardiac arrest",
			"Remove all camera coverage of SCP-895's containment area",
			"Direct visual observation is safe — camera observation is NOT",
			"Report any 'ghostly' images on camera feeds near 895",
		),
		"warning" = "SCP-895 is safe to look at directly. It is LETHAL to observe through cameras. The disturbing images you see on the feed will kill you.",
	)
	guide_entries["scp-066"] = list(
		"designation" = "SCP-066",
		"class" = "Safe",
		"threat" = "Unpredictable anomalous effects, aggressive when provoked",
		"procedures" = list(
			"SCP-066 is a small mass of intertwined wires",
			"It responds to verbal stimuli with unpredictable anomalous effects",
			"Do NOT say 'Eric' in its presence — it becomes aggressive",
			"Effects range from harmless to dangerous with no pattern",
			"Observe from behind safety glass when testing",
			"Report any unusual phenomena near SCP-066 containment",
		),
		"warning" = "SCP-066 is unpredictable. It might do nothing, or it might blind everyone in the room. Never say 'Eric' near it. Ever.",
	)



SUBSYSTEM_DEF(scp_gameplay)
	name = "SCP Gameplay"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_INPUT
	var/list/datum/escort_task/escort_tasks = list()
	var/list/breach_door_seals = list()

/datum/controller/subsystem/scp_gameplay/fire()
	process_escort_tasks()
	process_breach_door_seals()
	process_zone_sanity_effects()
	process_emergency_shelter_sanity()

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

/datum/controller/subsystem/scp_gameplay/proc/process_zone_sanity_effects()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.sanity)
			continue
		var/area/A = get_area(H)
		if(!A)
			continue
		if(istype(A, /area/scp/lcz))
			if(prob(3))
				H.sanity.adjust_sanity(-1, "lcz_exposure")
				if(prob(10))
					to_chat(H, span_warning("The sterile containment zone atmosphere weighs on your mind..."))
		else if(istype(A, /area/scp/hcz))
			if(prob(5))
				H.sanity.adjust_sanity(-2, "hcz_exposure")
				if(prob(15))
					to_chat(H, span_warning("The heavy containment zone feels oppressive and dangerous..."))
		else if(istype(A, /area/scp/ez))
			if(prob(2))
				H.sanity.adjust_sanity(1, "ez_safety")
		if(SSscp_persistence?.manager)
			var/breach_count = SSscp_persistence?.manager?.active_breaches
			if(breach_count > 0 && (istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz)) && prob(breach_count * 2))
				H.sanity.adjust_sanity(-1, "breach_proximity")

/proc/log_round_event(etype, desc, parts = "")
	if(!GLOB.scp_round_report)
		return
	switch(etype)
		if("scp_breach")
			GLOB.scp_round_report.log_breach(desc, "unknown", world.time)
		if("scp_recontainment")
			GLOB.scp_round_report.log_recontainment(desc, parts ? list(parts) : list(), world.time)
		if("power_failure")
			GLOB.scp_round_report.log_lockdown(desc, 0, world.time)
		if("goi_sabotage", "goi_spawn")
			GLOB.scp_round_report.log_casualty(etype, desc, parts, world.time)
		else
			GLOB.scp_round_report.log_casualty(etype, desc, parts, world.time)

/proc/generate_after_action_report()
	var/list/report = list()
	report += "<center><b>SCP FOUNDATION — AFTER ACTION REPORT</b></center>"
	report += "<hr>"
	report += "<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]"
	report += "<b>Shift Duration:</b> [round(world.time / 600)] minutes"
	report += "<hr>"

	report += "<b>SECURITY INCIDENTS</b>"
	if(GLOB.scp_round_report)
		report += "Total Breaches: [GLOB.scp_round_report.total_breaches] | Total Recontainments: [GLOB.scp_round_report.total_recontainments]"
		for(var/list/E in GLOB.scp_round_report.breach_log)
			report += "- BREACH: [E["id"]] in [E["zone"]]"
		for(var/list/E in GLOB.scp_round_report.recontainment_log)
			report += "- RECONTAINMENT: [E["id"]]"
	else
		report += "No round report data available."
	report += "<hr>"

	report += "<b>RESEARCH PROGRESS</b>"
	if(SSscp_research && SSscp_research.manager)
		report += "Total Research Points Earned: [SSscp_research?.manager?.total_research_points]"
	report += "<hr>"

	report += "<b>D-CLASS STATUS</b>"
	if(SSdclass && SSdclass.manager)
		var/escaped = 0
		var/survived = 0
		var/deceased = 0
		for(var/ckey in SSdclass?.manager?.dclass_players)
			var/datum/dclass_player/P = SSdclass?.manager?.dclass_players[ckey]
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
	report += "<hr>"

	report += "<b>FACILITY OPERATIONS</b>"
	if(SSfoundation_comms)
		report += "Threat Level: [SSfoundation_comms.facility_threat_level] | Active Dispatches: [SSfoundation_comms.active_dispatches] | Announcements: [SSfoundation_comms.total_announcements]"
	if(SSfoundation_budget)
		report += "Budget Spent: [SSfoundation_budget.total_spent] / [SSfoundation_budget.total_budget] credits"
	if(SSpsychology)
		report += "Psych Evaluations: [SSpsychology.completed_evals] | Counseling Sessions: [SSpsychology.counseling_sessions] | Amnestics Recommended: [SSpsychology.amnestics_recommended]"
	if(SSraisa)
		report += "Intel Reports: [SSraisa.total_reports] | Info Breaches: [SSraisa.active_breaches] active / [SSraisa.contained_breaches] contained"
	if(SSanomalous_investigations)
		report += "Evidence Collected: [SSanomalous_investigations.total_evidence] | Analyzed: [SSanomalous_investigations.analyzed_evidence]"
	if(SSit_network)
		report += "Network Integrity: [SSit_network.overall_integrity]% | SCP-079 Presence: [SSit_network.scp079_network_presence]"
	report += "<hr>"

	report += "<b>LEGAL AND ETHICS</b>"
	if(SSethics_committee)
		report += "Ethics Violations: [SSethics_committee.violations.len] | Tests Reviewed: [SSethics_committee.total_reviews]"
	if(SSinternal_tribunal)
		report += "Tribunal Cases: [SSinternal_tribunal.total_cases]"
	report += "<hr>"

	report += "<b>COMMAND AND COORDINATION</b>"
	if(SSsite_command)
		report += "Directives Issued: [SSsite_command.total_directives]"
	if(SSdepartment_coordination)
		report += "Coordination Tasks: [SSdepartment_coordination.completed_tasks]/[SSdepartment_coordination.total_tasks] completed | Memos: [SSdepartment_coordination.interdepartmental_memos.len]"
	if(SSgoi_relations)
		var/list/standing_summary = list()
		for(var/goi_name in SSgoi_relations.goi_standing)
			standing_summary += "[goi_name]: [SSgoi_relations.goi_standing[goi_name]]"
		report += "GOI Standings: [jointext(standing_summary, ", ")]"

	return jointext(report, "<br>")
