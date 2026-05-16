SUBSYSTEM_DEF(facility_announcements)
	name = "Facility Announcements"
	wait = 120 SECONDS
	var/list/routine_messages = list()
	var/list/shift_messages = list()
	var/list/breach_messages = list()
	var/last_announcement_time = 0
	var/announcement_interval = 90 SECONDS
	var/current_shift_phase = "morning"
	var/shift_announced = FALSE

/datum/controller/subsystem/facility_announcements/Initialize(start_timeofday)
	. = ..()
	routine_messages = list(
		"All personnel are reminded to keep their keycards visible at all times.",
		"Remember: If you see something anomalous, report it to your supervisor immediately.",
		"The Foundation reminds all staff: We die in the dark so that you may live in the light.",
		"Personnel are advised to maintain awareness of their surroundings at all times.",
		"Regular maintenance checks are in progress. Please report any malfunctioning equipment.",
		"All D-Class personnel are to remain in designated areas unless accompanied by Foundation staff.",
		"The cafeteria is now serving meals for the current shift. Nutrient paste is on today's menu.",
		"Remember: Secure. Contain. Protect. The Foundation's mission depends on each of you.",
		"Staff are reminded that unauthorized access to restricted areas is grounds for immediate termination.",
		"Scheduled equipment calibration will begin shortly. Please stand clear of containment cell corridors.",
		"All research logs must be submitted by end of shift. No exceptions.",
		"The Foundation thanks you for your continued dedication to our mission.",
		"Personnel are reminded that fraternization with D-Class is strictly prohibited.",
		"Security personnel: Your scheduled patrol routes are available at checkpoint terminals.",
		"Research staff: Experiment proposals for next shift are due within the hour.",
		"Medical staff: Routine psychological evaluations are mandatory. No exemptions.",
		"All personnel are to familiarize themselves with emergency evacuation routes.",
		"The Foundation is not responsible for loss of personal belongings during containment events.",
		"Report any unusual behavior in colleagues to your immediate supervisor. Trust no one.",
		"Staff are reminded that SCP documentation is classified. Do not discuss specifics in common areas."
	)
	shift_messages = list(
		"morning" = list(
			"Good morning, Foundation personnel. Begin your assigned duties promptly.",
			"Morning shift has begun. All night shift personnel, report to your supervisors for debriefing.",
			"Rise and shine, staff. Another day of securing, containing, and protecting awaits."
		),
		"afternoon" = list(
			"Afternoon, Foundation staff. Maintain vigilance throughout the remainder of your shift.",
			"Mid-shift reminder: Stay alert. Complacency is the enemy of containment.",
			"Afternoon shift in progress. All personnel are to remain at their assigned posts."
		),
		"evening" = list(
			"Evening, Foundation personnel. Night shift preparations should be underway.",
			"As the day winds down, remember: the anomalies never sleep. Neither should your vigilance.",
			"Evening shift transition in 30 minutes. All departments, prepare shift change reports."
		),
		"night" = list(
			"Night shift personnel, you are now on duty. Maintain awareness. The darkness favors the anomalies.",
			"Good night, Foundation staff. Remember: the walls are thinner at night.",
			"Night shift has begun. All non-essential personnel should return to residential quarters."
		)
	)
	breach_messages = list(
		"All personnel are to remain calm and follow established emergency procedures.",
		"Security teams are responding to the situation. Do not interfere with containment operations.",
		"This is not a drill. Repeat: This is not a drill. Follow evacuation protocols immediately.",
		"Emergency responders are en route. Barricade yourselves in the nearest secure room.",
		"Remain where you are unless directed to evacuate. Do not approach the breach zone.",
		"All non-essential personnel: Evacuate to the nearest safe zone immediately.",
		"Security teams have the situation under control. Stay away from restricted corridors.",
		"This facility is under lockdown. All blast doors have been sealed. Remain where you are."
	)

/datum/controller/subsystem/facility_announcements/fire()
	if(world.time < last_announcement_time + announcement_interval)
		return

	var/is_breach = FALSE
	var/breach_count = 0
	if(SSscp_persistence?.manager)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(instance?.containment_status == "breached")
				is_breach = TRUE
				breach_count++

	var/announcement = null
	if(is_breach)
		announcement = pick(breach_messages)
		if(prob(30) && breach_count > 1)
			announcement = "Multiple containment breaches confirmed. [announcement]"
	else
		var/shift = get_shift_phase()
		if(shift != current_shift_phase)
			current_shift_phase = shift
			if(!shift_announced)
				announcement = pick(shift_messages[shift])
				shift_announced = TRUE
				addtimer(VARSET_CALLBACK(src, shift_announced, FALSE), 5 MINUTES)
		else
			announcement = pick(routine_messages)

	if(announcement)
		priority_announce(announcement, "Facility Automated Announcement System", sound_type = null)
		last_announcement_time = world.time

/datum/controller/subsystem/facility_announcements/proc/get_shift_phase()
	var/hour = text2num(time2text(world.time, "hh"))
	if(hour >= 6 && hour < 12)
		return "morning"
	else if(hour >= 12 && hour < 18)
		return "afternoon"
	else if(hour >= 18 && hour < 22)
		return "evening"
	else
		return "night"

/datum/controller/subsystem/facility_announcements/proc/announce_breach(scp_id, zone_name)
	var/message = "CONTAINMENT BREACH DETECTED: [scp_id] has breached containment in [zone_name]. All security personnel respond immediately. Research staff, seal your laboratories. D-Class personnel, return to your cells."
	priority_announce(message, "Foundation Emergency Alert System", sound_type = ANNOUNCER_ALERT)
	last_announcement_time = world.time
