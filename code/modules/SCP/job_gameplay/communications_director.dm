#define DISPATCH_SECURITY 1
#define DISPATCH_MEDICAL 2
#define DISPATCH_ENGINEERING 3
#define DISPATCH_MTF 4

#define THREAT_LEVEL_GREEN 0
#define THREAT_LEVEL_YELLOW 1
#define THREAT_LEVEL_ORANGE 2
#define THREAT_LEVEL_RED 3

/datum/comm_dispatch
	var/dispatch_id = ""
	var/dispatch_type = DISPATCH_SECURITY
	var/caller_name = ""
	var/caller_job = ""
	var/caller_location = ""
	var/message = ""
	var/priority = 0
	var/time_created = 0
	var/responded = FALSE
	var/responders = list()

/datum/comm_dispatch/New(caller, dtype, msg, prio)
	dispatch_id = "DSP-[world.time]-[rand(10,99)]"
	time_created = world.time
	caller_name = "Automated"
	caller_location = "Facility"
	if(istype(caller, /mob/living/carbon/human))
		var/mob/living/carbon/human/C = caller
		caller_name = C.real_name
		caller_job = C.job
		var/area/A = get_area(C)
		caller_location = A ? A.name : "Unknown"
	dispatch_type = dtype
	message = msg
	priority = prio

/datum/comm_dispatch/proc/get_type_text()
	switch(dispatch_type)
		if(DISPATCH_SECURITY)
			return "Security"
		if(DISPATCH_MEDICAL)
			return "Medical"
		if(DISPATCH_ENGINEERING)
			return "Engineering"
		if(DISPATCH_MTF)
			return "MTF"

/datum/comm_dispatch/proc/respond(mob/responder)
	if(responder in responders)
		return FALSE
	responders += responder
	responded = TRUE
	to_chat(responder, span_notice("You have responded to dispatch [dispatch_id]. Proceed to [caller_location]."))
	return TRUE

/datum/facility_threat
	var/threat_id = ""
	var/threat_name = ""
	var/threat_type = ""
	var/threat_level = THREAT_LEVEL_YELLOW
	var/location = ""
	var/description = ""
	var/time_detected = 0
	var/resolved = FALSE
	var/resolved_by = ""

/datum/facility_threat/New(tname, ttype, tlevel, loc, desc)
	threat_id = "THR-[world.time]-[rand(10,99)]"
	threat_name = tname
	threat_type = ttype
	threat_level = tlevel
	location = loc
	description = desc
	time_detected = world.time

/datum/facility_threat/proc/get_level_text()
	switch(threat_level)
		if(THREAT_LEVEL_GREEN)
			return "Green"
		if(THREAT_LEVEL_YELLOW)
			return "Yellow"
		if(THREAT_LEVEL_ORANGE)
			return "Orange"
		if(THREAT_LEVEL_RED)
			return "Red"

/datum/facility_threat/proc/resolve(resolver)
	resolved = TRUE
	resolved_by = resolver

SUBSYSTEM_DEF(foundation_comms)
	name = "Foundation Communications"
	wait = 5 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/comm_dispatch/dispatches = list()
	var/list/datum/facility_threat/threats = list()
	var/facility_threat_level = THREAT_LEVEL_GREEN
	var/last_threat_change = 0
	var/active_dispatches = 0
	var/resolved_dispatches = 0
	var/total_announcements = 0

/datum/controller/subsystem/foundation_comms/fire()
	recalculate_threat_level()

/datum/controller/subsystem/foundation_comms/proc/create_dispatch(mob/caller, dispatch_type, message, priority)
	var/datum/comm_dispatch/D = new(caller, dispatch_type, message, priority)
	dispatches += D
	active_dispatches++
	var/channel = D.get_type_text()
	priority_announce("Dispatch [D.dispatch_id]: [channel] - [D.caller_name] at [D.caller_location]: [message]", "Communications Dispatch", null, priority > 1 ? ANNOUNCER_ALERT : ANNOUNCER_DEFAULT)
	return D.dispatch_id

/datum/controller/subsystem/foundation_comms/proc/respond_dispatch(dispatch_id, mob/responder)
	for(var/datum/comm_dispatch/D in dispatches)
		if(D.dispatch_id == dispatch_id && !D.responded)
			D.respond(responder)
			active_dispatches--
			resolved_dispatches++
			return TRUE
	return FALSE

/datum/controller/subsystem/foundation_comms/proc/register_threat(threat_name, threat_type, threat_level, location, description)
	for(var/datum/facility_threat/T in threats)
		if(!T.resolved && T.threat_type == threat_type && T.location == location)
			return T.threat_id
	var/datum/facility_threat/T = new(threat_name, threat_type, threat_level, location, description)
	threats += T
	recalculate_threat_level()
	return T.threat_id

/datum/controller/subsystem/foundation_comms/proc/resolve_threat(threat_id, resolver)
	for(var/datum/facility_threat/T in threats)
		if(T.threat_id == threat_id)
			T.resolve(resolver)
			recalculate_threat_level()
			return TRUE
	return FALSE

/datum/controller/subsystem/foundation_comms/proc/recalculate_threat_level()
	var/highest = THREAT_LEVEL_GREEN
	for(var/datum/facility_threat/T in threats)
		if(!T.resolved && T.threat_level > highest)
			highest = T.threat_level
	if(highest != facility_threat_level)
		facility_threat_level = highest
		last_threat_change = world.time
		check_threat_escalation()


