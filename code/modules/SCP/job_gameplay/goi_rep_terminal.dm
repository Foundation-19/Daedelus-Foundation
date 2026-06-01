/obj/item/paper/goi_intelligence_brief
	name = "GOI Intelligence Brief"
	info = "<b>GROUP OF INTEREST INTELLIGENCE BRIEF</b><br><br>Classification: ___________<br>GOI: ___________<br>Assessment: ___________<br>Recommended Action: ___________<br>Analyst: ___________"

/datum/goi_intel
	var/intel_id = ""
	var/goi_name = ""
	var/intel_type = ""
	var/classification = ""
	var/findings = ""
	var/recommendations = ""
	var/time_filed = 0
	var/analyst_name = ""
	var/verified = FALSE

/datum/goi_intel/New(goi, itype, class, findings_text, recs, analyst)
	intel_id = "GOI-[world.time]-[rand(100,999)]"
	time_filed = world.time
	goi_name = goi
	intel_type = itype
	classification = class
	findings = findings_text
	recommendations = recs
	if(istype(analyst, /mob/living/carbon/human))
		var/mob/living/carbon/human/A = analyst
		analyst_name = A.real_name

/datum/goi_communique
	var/communique_id = ""
	var/goi_name = ""
	var/sender_name = ""
	var/sender_job = ""
	var/message = ""
	var/response = ""
	var/time_sent = 0
	var/time_responded = 0
	var/priority = 0
	var/responded = FALSE

/datum/goi_communique/New(goi, sender, msg, prio)
	communique_id = "COM-[world.time]-[rand(10,99)]"
	time_sent = world.time
	goi_name = goi
	if(istype(sender, /mob/living/carbon/human))
		var/mob/living/carbon/human/S = sender
		sender_name = S.real_name
		sender_job = S.job
	message = msg
	priority = prio

/datum/goi_communique/proc/respond(response_text)
	response = response_text
	responded = TRUE
	time_responded = world.time

SUBSYSTEM_DEF(goi_relations)
	name = "GOI Relations"
	flags = SS_NO_FIRE
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/goi_intel/intel_database = list()
	var/list/datum/goi_communique/communiques = list()
	var/list/goi_standing = list()
	var/total_intel = 0
	var/total_communiques = 0

/datum/controller/subsystem/goi_relations/Initialize(start_timeofday)
	. = ..()
	goi_standing = list(
		"GOC" = 50,
		"Goldbaker-Reinz" = 50,
		"UIU" = 50,
		"MCD" = 30,
		"Chaos Insurgency" = 0,
		"Sarkic Cult" = 0,
		"Church of the Broken God" = 20,
		"Serpent's Hand" = 25,
	)

/datum/controller/subsystem/goi_relations/proc/file_intel(datum/goi_intel/I)
	intel_database += I
	total_intel++
	return I.intel_id

/datum/controller/subsystem/goi_relations/proc/verify_intel(intel_id)
	for(var/datum/goi_intel/I in intel_database)
		if(I.intel_id == intel_id)
			I.verified = TRUE
			return TRUE
	return FALSE

/datum/controller/subsystem/goi_relations/proc/send_communique(datum/goi_communique/C)
	communiques += C
	total_communiques++
	var/standing = goi_standing[C.goi_name] || 0
	if(standing < 20)
		priority_announce("GOI Communique sent to [C.goi_name]. Relations are POOR — response unlikely.", "GOI Relations", null, ANNOUNCER_DEFAULT)
	else if(standing < 50)
		priority_announce("GOI Communique sent to [C.goi_name]. Relations are NEUTRAL — response possible.", "GOI Relations", null, ANNOUNCER_DEFAULT)
		if(prob(30))
			C.respond("Message acknowledged. No further response at this time.")
			process_goi_response(C.goi_name, standing)
	else if(standing < 75)
		priority_announce("GOI Communique sent to [C.goi_name]. Relations are GOOD — response likely.", "GOI Relations", null, ANNOUNCER_DEFAULT)
		if(prob(60))
			C.respond("Message received. We will consider your proposal and respond in kind.")
			process_goi_response(C.goi_name, standing)
	else
		priority_announce("GOI Communique sent to [C.goi_name]. Relations are EXCELLENT — swift response expected.", "GOI Relations", null, ANNOUNCER_DEFAULT)
		if(prob(85))
			C.respond("Allied communique received. We are prepared to cooperate. Resources incoming.")
			process_goi_response(C.goi_name, standing)
	return C.communique_id

/datum/controller/subsystem/goi_relations/proc/process_goi_response(goi_name, standing)
	if(SSfoundation_budget)
		var/budget_bonus = round(standing * 5)
		var/datum/department_budget/cmd_budget = SSfoundation_budget.department_budgets["command"]
		if(cmd_budget && budget_bonus > 0)
			cmd_budget.allocate(budget_bonus)
	if(SSscp_research?.manager && standing >= 50)
		SSscp_research?.manager?.adjust_research_points(round(standing * 2), "goi_cooperation:[goi_name]")
	if(standing >= 75 && SSit_network)
		for(var/datum/server_rack/R in SSit_network.server_racks)
			R.firewall_strength = min(100, R.firewall_strength + 5)

/datum/controller/subsystem/goi_relations/proc/adjust_standing(goi_name, amount)
	if(goi_name in goi_standing)
		goi_standing[goi_name] = clamp(goi_standing[goi_name] + amount, 0, 100)


