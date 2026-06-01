/datum/facility_directive
	var/directive_id = ""
	var/issuer_name = ""
	var/issuer_job = ""
	var/directive_type = ""
	var/title = ""
	var/content = ""
	var/priority = 0
	var/time_issued = 0
	var/status = "active"
	var/acknowledged_by = list()
	var/expiry_time = 0

/datum/facility_directive/New(issuer, dtype, dir_title, dir_content, prio, expiry)
	directive_id = "DIR-[world.time]-[rand(100,999)]"
	time_issued = world.time
	if(istype(issuer, /mob/living/carbon/human))
		var/mob/living/carbon/human/I = issuer
		issuer_name = I.real_name
		issuer_job = I.job
	directive_type = dtype
	title = dir_title
	content = dir_content
	priority = prio
	expiry_time = expiry ? time_issued + expiry : 0

/datum/facility_directive/proc/acknowledge(mob/M)
	if(M.real_name in acknowledged_by)
		return FALSE
	acknowledged_by += M.real_name
	return TRUE

/datum/facility_directive/proc/is_expired()
	return expiry_time && world.time > expiry_time

/datum/facility_status_report
	var/total_breaches = 0
	var/active_breaches = 0
	var/total_recontainments = 0
	var/power_status = "Nominal"
	var/comms_status = "Online"
	var/security_level = "Green"
	var/casualties = 0
	var/dclass_alive = 0
	var/dclass_escaped = 0
	var/research_points = 0
	var/time_generated = 0

/datum/facility_status_report/proc/generate()
	time_generated = world.time
	total_breaches = 0
	active_breaches = 0
	total_recontainments = 0
	if(GLOB.scp_round_report)
		total_breaches = GLOB.scp_round_report.total_breaches
		total_recontainments = GLOB.scp_round_report.total_recontainments
	for(var/mob/living/scp/S in GLOB.player_list)
		if(S.containment_status == "breached")
			active_breaches++
	var/powerless = 0
	var/total = 0
	for(var/obj/machinery/power/apc/APC as anything in INSTANCES_OF(/obj/machinery/power/apc))
		if(!QDELETED(APC))
			total++
			if(!APC.cell || APC.cell.charge <= 0)
				powerless++
	if(total > 0 && powerless > total / 3)
		power_status = "Critical"
	else if(powerless > 0)
		power_status = "Degraded"
	if(SSfoundation_comms)
		comms_status = SSfoundation_comms.facility_threat_level >= 3 ? "Compromised" : "Online"
		security_level = SSfoundation_comms.facility_threat_level
	casualties = 0
	dclass_alive = 0
	dclass_escaped = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || !H.client)
			continue
		if(H.stat == DEAD)
			casualties++
		else if(findtext(H.job, "D-Class"))
			dclass_alive++
			var/area/A = get_area(H)
			if(istype(A, /area/scp/surface) || istype(A, /area/site53/surface))
				dclass_escaped++
	if(SSscp_research && SSscp_research.manager)
		research_points = SSscp_research?.manager?.total_research_points

SUBSYSTEM_DEF(site_command)
	name = "Site Command"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/facility_directive/directives = list()
	var/last_status_report = 0
	var/datum/facility_status_report/current_report
	var/total_directives = 0

/datum/controller/subsystem/site_command/fire()
	if(world.time > last_status_report + 2 MINUTES)
		current_report = new()
		current_report.generate()
		last_status_report = world.time
	for(var/datum/facility_directive/D in directives)
		if(D.is_expired() && D.status == "active")
			D.status = "expired"

/datum/controller/subsystem/site_command/proc/issue_directive(datum/facility_directive/D)
	directives += D
	total_directives++
	priority_announce("SITE DIRECTIVE: [D.title] — [D.content]", "Site Director", null, D.priority > 1 ? ANNOUNCER_ALERT : ANNOUNCER_DEFAULT)
	return D.directive_id

/datum/controller/subsystem/site_command/proc/acknowledge_directive(directive_id, mob/M)
	for(var/datum/facility_directive/D in directives)
		if(D.directive_id == directive_id && D.status == "active")
			D.acknowledge(M)
			to_chat(M, span_notice("You have acknowledged directive: [D.title]"))
			return TRUE
	return FALSE

/datum/controller/subsystem/site_command/proc/rescind_directive(directive_id)
	for(var/datum/facility_directive/D in directives)
		if(D.directive_id == directive_id && D.status == "active")
			D.status = "rescinded"
			priority_announce("Directive '[D.title]' has been rescinded.", "Site Director", null, ANNOUNCER_DEFAULT)
			return TRUE
	return FALSE


