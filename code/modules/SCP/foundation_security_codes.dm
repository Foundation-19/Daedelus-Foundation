// Foundation Security Codes
// SCP-canon security alert levels replacing SS13 Green/Blue/Red/Delta naming
// Maps to existing SEC_LEVEL_ defines for backward compatibility

// ===== FOUNDATION SECURITY CODE DEFINES =====
// These are semantic aliases that map to the numeric SEC_LEVEL_ constants
// Used for Foundation-themed announcements and UI display

#define FOUNDATION_CODE_WHITE 0
#define FOUNDATION_CODE_YELLOW 1
#define FOUNDATION_CODE_ORANGE 2
#define FOUNDATION_CODE_RED 2
#define FOUNDATION_CODE_BLACK 3
#define FOUNDATION_CODE_OMEGA 3

// Code color mappings for TGUI display
#define FOUNDATION_CODE_COLORS list(\
	"white" = "#cccccc",\
	"yellow" = "#d4a017",\
	"orange" = "#ff6600",\
	"red" = "#8b0000",\
	"black" = "#1a1a1a",\
	"omega" = "#5c0000"\
)

/proc/foundation_code_name(level)
	switch(level)
		if(SEC_LEVEL_GREEN)
			return "Code White"
		if(SEC_LEVEL_BLUE)
			return "Code Yellow"
		if(SEC_LEVEL_RED)
			return "Code Red"
		if(SEC_LEVEL_DELTA)
			return "Code Omega"

/proc/foundation_code_color(level)
	switch(level)
		if(SEC_LEVEL_GREEN)
			return "#cccccc"
		if(SEC_LEVEL_BLUE)
			return "#d4a017"
		if(SEC_LEVEL_RED)
			return "#8b0000"
		if(SEC_LEVEL_DELTA)
			return "#5c0000"

/proc/foundation_code_description(level)
	switch(level)
		if(SEC_LEVEL_GREEN)
			return "All clear. No anomalous activity detected. Standard operations in effect."
		if(SEC_LEVEL_BLUE)
			return "Caution. Potential anomalous activity detected. Increased surveillance and personnel awareness advised."
		if(SEC_LEVEL_RED)
			return "Active containment breach. Hostile anomalous entities detected. All personnel proceed to designated safe zones. Security personnel engage containment protocols."
		if(SEC_LEVEL_DELTA)
			return "Facility destruction imminent. All personnel evacuate immediately. On-site nuclear warhead armed. No exceptions."

/proc/foundation_code_procedures(level)
	switch(level)
		if(SEC_LEVEL_GREEN)
			return list(\
				"Standard facility operations continue",\
				"All SCP containment chambers on normal monitoring",\
				"D-Class personnel may proceed with scheduled testing",\
				"Regular patrol routes in effect"\
			)
		if(SEC_LEVEL_BLUE)
			return list(\
				"Increase monitoring of all SCP containment chambers",\
				"Security personnel maintain heightened alert",\
				"D-Class testing suspended pending review",\
				"All personnel carry identification at all times",\
				"Report any anomalous activity to command immediately"\
			)
		if(SEC_LEVEL_RED)
			return list(\
				"All SCP containment chambers on maximum monitoring",\
				"Security personnel engage breach containment protocols",\
				"D-Class personnel return to holding areas immediately",\
				"MTF teams on standby for deployment",\
				"All bulkheads between zones sealed",\
				"Non-essential personnel evacuate to Surface",\
				"Research operations suspended"\
			)
		if(SEC_LEVEL_DELTA)
			return list(\
				"ON-SITE NUCLEAR WARHEAD ARMED",\
				"All personnel evacuate to Surface immediately",\
				"MTF teams withdraw from facility",\
				"All containment protocols abandoned",\
				"Countdown initiated — no recall",\
				"Shuttle automatically dispatched"\
			)

/proc/set_foundation_security_code(new_code, reason, mob/user)
	var/numeric_level
	if(istext(new_code))
		switch(lowertext(new_code))
			if("white", "green")
				numeric_level = SEC_LEVEL_GREEN
			if("yellow", "blue")
				numeric_level = SEC_LEVEL_BLUE
			if("red", "orange", "black")
				numeric_level = SEC_LEVEL_RED
			if("omega", "delta")
				numeric_level = SEC_LEVEL_DELTA
			else
				return FALSE
	else
		numeric_level = new_code

	if(numeric_level == SSsecurity_level.current_level)
		return FALSE

	var/code_name = foundation_code_name(numeric_level)
	var/announcement_text = generate_foundation_code_announcement(numeric_level, reason)

	switch(numeric_level)
		if(SEC_LEVEL_GREEN)
			priority_announce(announcement_text, null, "SECURITY CODE: [code_name] — All Clear", ANNOUNCER_ALERT)
		if(SEC_LEVEL_BLUE)
			priority_announce(announcement_text, null, "SECURITY CODE: [code_name] — Caution", ANNOUNCER_ALERT)
		if(SEC_LEVEL_RED)
			priority_announce(announcement_text, null, "SECURITY CODE: [code_name] — Breach", ANNOUNCER_ALERT)
		if(SEC_LEVEL_DELTA)
			priority_announce(announcement_text, null, "SECURITY CODE: [code_name] — CRITICAL", ANNOUNCER_ALERT)

	set_security_level(numeric_level)

	if(GLOB.scp_admin_log)
		GLOB.scp_admin_log.log_event("security_code", "facility", user ? user.ckey : null, null, "Security code changed to [code_name] by [user ? key_name(user) : "automated system"][reason ? " — Reason: [reason]" : ""]", 3)

	return TRUE

/proc/generate_foundation_code_announcement(level, reason)
	var/list/procedures = foundation_code_procedures(level)
	var/text = "ATTENTION ALL PERSONNEL\n\n"
	text += "[foundation_code_description(level)]\n\n"
	text += "PROCEDURES IN EFFECT:\n"
	for(var/proc_text in procedures)
		text += "- [proc_text]\n"
	if(reason)
		text += "\nREASON: [reason]"
	text += "\n\nThis is not a drill. All personnel are expected to comply immediately."
	return text


