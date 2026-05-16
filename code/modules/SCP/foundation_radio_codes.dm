// Foundation Radio Codes
// Standardized 10-code and brevity code system for Foundation radio communications
// Replaces SS13 radio jargon with SCP Foundation equivalents

// ===== FOUNDATION 10-CODES =====
// Used on radio channels for brevity and clarity

/datum/radio_code
	var/code = ""
	var/meaning = ""
	var/category = "general"
	var/severity = 0

/datum/radio_code/New(code, meaning, category, severity)
	src.code = code
	src.meaning = meaning
	src.category = category
	src.severity = severity

/proc/get_foundation_radio_codes()
	var/static/list/codes
	if(!codes)
		codes = list(
			"10-1" = new /datum/radio_code("10-1", "Poor signal", "general", 0),
			"10-4" = new /datum/radio_code("10-4", "Acknowledged", "general", 0),
			"10-7" = new /datum/radio_code("10-7", "Out of service", "general", 0),
			"10-8" = new /datum/radio_code("10-8", "In service", "general", 0),
			"10-9" = new /datum/radio_code("10-9", "Repeat message", "general", 0),
			"10-20" = new /datum/radio_code("10-20", "Location", "general", 0),
			"10-33" = new /datum/radio_code("10-33", "Emergency traffic", "general", 3),
			"10-70" = new /datum/radio_code("10-70", "Fire alarm", "emergency", 2),
			"10-91" = new /datum/radio_code("10-91", "Anomalous object/person", "scp", 1),
			"10-92" = new /datum/radio_code("10-92", "Containment breach", "scp", 3),
			"10-93" = new /datum/radio_code("10-93", "Keter-class event", "scp", 4),
			"10-94" = new /datum/radio_code("10-94", "MTF deployment authorized", "scp", 2),
			"10-95" = new /datum/radio_code("10-95", "Entity recontained", "scp", 1),
			"10-96" = new /datum/radio_code("10-96", "Hostile entity engaged", "scp", 3),
			"10-97" = new /datum/radio_code("10-97", "Civilian contact", "security", 1),
			"10-98" = new /datum/radio_code("10-98", "Prisoner/D-Class escape", "security", 2),
		)
	return codes

// ===== FOUNDATION BREVITY CODES =====
// Short phrases for common situations

/proc/get_foundation_brevity_codes()
	var/static/list/brevity
	if(!brevity)
		brevity = list(
			"SIERRA" = "Security incident in progress",
			"ALPHA" = "All clear / Area secured",
			"BRAVO" = "Breach confirmed",
			"CHARLIE" = "Containment team needed",
			"DELTA" = "D-Class situation",
			"ECHO" = "Evacuation required",
			"FOXTROT" = "Fire / SCP-457 related",
			"GOLF" = "Go ahead / Permission granted",
			"HOTEL" = "Hostile entity sighted",
			"INDIA" = "Injured personnel",
			"JULIET" = "Justified use of force",
			"KILO" = "Keter-class entity",
			"LIMA" = "Lockdown in effect",
			"MIKE" = "Medical emergency",
			"NOVEMBER" = "Negative / No",
			"OSCAR" = "Object/SCP located",
			"PAPA" = "Protocol activated",
			"ROMEO" = "Recontainment successful",
			"SIERRA-TANGO" = "Stand by",
			"TANGO" = "Target acquired",
			"UNIFORM" = "Unauthorized access",
			"VICTOR" = "Visual contact",
			"WHISKEY" = "Weapon discharge",
			"XRAY" = "Reality-bending anomaly",
			"YANKEE" = "Yes / Affirmative",
			"ZULU" = "Zone clear",
		)
	return brevity

// Radio code reference item — a pocket guide
/obj/item/paper/foundation_radio_codes
	name = "Foundation Radio Code Reference"
	info = "<b>FOUNDATION RADIO CODES — POCKET REFERENCE</b><br><br><b>10-CODES:</b><br>10-4: Acknowledged<br>10-7: Out of service<br>10-8: In service<br>10-20: Location<br>10-33: Emergency traffic<br>10-70: Fire alarm<br>10-91: Anomalous object/person<br>10-92: Containment breach<br>10-93: Keter-class event<br>10-94: MTF deployment authorized<br>10-95: Entity recontained<br>10-96: Hostile entity engaged<br>10-97: Civilian contact<br>10-98: Prisoner/D-Class escape<br><br><b>BREVITY CODES:</b><br>BRAVO: Breach confirmed<br>CHARLIE: Containment team needed<br>ECHO: Evacuation required<br>HOTEL: Hostile entity sighted<br>KILO: Keter-class entity<br>LIMA: Lockdown in effect<br>OSCAR: Object/SCP located<br>ROMEO: Recontainment successful<br>TANGO: Target acquired<br>VICTOR: Visual contact<br>XRAY: Reality-bending anomaly"
