/obj/item/book/guidebook/on_read(mob/user)
	if(book_data?.content)
		var/page = book_data.content
		var/credit = "<TT><I>Penned by [book_data.author].</I></TT> <BR>"
		page = replacetext(page, "<body>", "<body>[credit]")
		user << browse(page, "window=book[window_size != null ? ";size=[window_size]" : ""]")
		onclose(user, "book")
	else
		to_chat(user, span_notice("This book is completely blank!"))

/obj/item/book/guidebook/foundation
	name = "Foundation Personnel Handbook"
	desc = "A compact handbook for all Foundation personnel. Required reading."
	icon_state = "book1"
	starting_title = "Foundation Personnel Handbook"
	starting_author = "The SCP Foundation"
	starting_content = {"<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<style>
body{font-family:Courier New;font-size:12px;color:#222;}
h1{font-size:16px;margin:15px 0px 5px;}
h2{font-size:14px;margin:10px 0px 5px;}
hr{border:1px solid #444;}
</style>
</head>
<body>
<hr><center><b>SCP FOUNDATION<br>PERSONNEL HANDBOOK</b><br>Edition 47.2</center><hr>
<br>
<b>I. WELCOME</b><br>
You have been selected to serve the Foundation. Our mission: Secure, Contain, Protect. You are expected to uphold this mission at all times.<br>
<br>
<b>II. CLEARANCE LEVELS</b><br>
Level 0 &mdash; Public/general knowledge only.<br>
Level 1 &mdash; Basic SCP awareness for support staff.<br>
Level 2 &mdash; Detail access for most researchers and guards.<br>
Level 3 &mdash; In-depth access for senior researchers and security.<br>
Level 4 &mdash; Command-level access for department heads.<br>
Level 5 &mdash; O5 Council and designated personnel only.<br>
<br>
<b>III. OBJECT CLASSES</b><br>
Safe &mdash; Easily and safely contained. Not necessarily harmless.<br>
Euclid &mdash; Unpredictable. Requires more resources or discretion.<br>
Keter &mdash; Difficult to contain reliably. May cause loss of life.<br>
Thaumiel &mdash; Used to contain other SCPs. Need-to-know basis.<br>
Apollyon &mdash; Cannot be contained. Inevitable catastrophic effect.<br>
<br>
<b>IV. SECURITY CODES</b><br>
Code White &mdash; Normal operations. No active threats.<br>
Code Yellow &mdash; Minor anomaly detected. Heightened awareness.<br>
Code Orange &mdash; Significant threat. Security teams on standby.<br>
Code Red &mdash; Containment breach active. All security respond.<br>
Code Omega &mdash; Facility-wide emergency. Total lockdown. Evacuation authorized.<br>
<br>
<b>V. FACILITY ZONES</b><br>
Surface &mdash; Primary access, external operations, helicopter pad.<br>
Entrance Zone (EZ) &mdash; Administrative offices, main corridors, cafeteria.<br>
Light Containment Zone (LCZ) &mdash; Safe/Euclid containment, D-Class housing.<br>
Heavy Containment Zone (HCZ) &mdash; Keter containment, high-security operations.<br>
<br>
<b>VI. D-CLASS PROTOCOLS</b><br>
D-Class personnel are drawn from death row populations worldwide. They are assigned to SCP testing under supervision. D-Class are NOT expendable &mdash; they are valuable assets. Treat them as such until testing requires otherwise.<br>
<br>
<b>VII. CONTAINMENT BREACH PROTOCOL</b><br>
1. Remain calm. Do not panic.<br>
2. Follow evacuation routes to designated shelters.<br>
3. Security personnel: proceed to breach site per containment procedures.<br>
4. Researchers: secure all documentation and lock your labs.<br>
5. Do NOT interact with breached SCPs unless trained to do so.<br>
6. Await MTF deployment if recontainment fails.<br>
<br>
<b>VIII. AMNESTIC PROTOCOLS</b><br>
Class A &mdash; Total memory wipe. Used for civilian witnesses.<br>
Class B &mdash; Targeted memory removal. Partial recall preserved.<br>
Class C &mdash; Memory revision. False memories implanted.<br>
Class E &mdash; Emergency use. Temporary suppression only.<br>
<br>
<b>IX. ANOMALOUS ITEM REPORTING</b><br>
Any object exhibiting anomalous properties must be reported immediately to your supervisor or the Containment Department. Do NOT test anomalous items without authorization. Use the SCP Testing Console for formal testing requests.<br>
<br>
<b>X. EMERGENCY SHELTERS</b><br>
Shelter Alpha and Shelter Bravo are located throughout the facility. Proceed to the nearest shelter during Code Red or Code Omega situations. Shelter beacons emit a red light to guide you. Supply caches inside contain basic medical supplies, radios, and gas masks.<br>
<br>
<b>XI. MEMETIC HAZARDS</b><br>
If you experience unexplained thoughts, compulsions, or sensory distortions after exposure to an SCP, report to Medical immediately. Telekill alloy equipment is available for memetic protection. Do NOT spread memetic content through radio or intercom.<br>
<br>
<b>XII. TELEKILL ALLOY</b><br>
Telekill (SCP-148) provides passive resistance to memetic and telepathic effects. Available as helmets, vests, and barrier units. The anti-memetic kit provides emergency protection. Prolonged exposure to Telekill dust causes organ damage.<br>
<br>
<hr><center>REMEMBER: Secure. Contain. Protect.</center><hr>
</body>
</html>
"}

/obj/item/book/guidebook/foundation_security
	name = "Foundation Security Field Manual"
	desc = "A field manual for Foundation security personnel. Covers containment response and breach protocols."
	icon_state = "book2"
	starting_title = "Foundation Security Field Manual"
	starting_author = "Foundation Security Command"
	starting_content = {"<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<style>
body{font-family:Courier New;font-size:12px;color:#222;}
hr{border:1px solid #444;}
</style>
</head>
<body>
<hr><center><b>SCP FOUNDATION<br>SECURITY FIELD MANUAL</b></center><hr>
<br>
<b>I. USE OF FORCE</b><br>
Non-lethal force is preferred. Lethal force authorized when:<br>
- Your life or the life of another is in immediate danger.<br>
- A breached Keter-class entity cannot be recontained by other means.<br>
- D-Class personnel are fleeing the facility during a breach.<br>
<br>
<b>II. CONTAINMENT RESPONSE</b><br>
- Secure the breach perimeter. No unauthorized entry or exit.<br>
- Establish communication with the containment team.<br>
- Follow the specific containment procedures for the breached SCP.<br>
- Request MTF deployment through the MTF Deployment Console if needed.<br>
<br>
<b>III. SCP-SPECIFIC RESPONSE</b><br>
SCP-173: Maintain eye contact at all times. Never blink simultaneously. Approach in teams of 3+.<br>
SCP-049: Do not allow physical contact. If contact occurs, isolate the victim immediately.<br>
SCP-096: DO NOT LOOK AT ITS FACE. If triggered, evacuate the area. MTF Zulu-9 deployment required.<br>
SCP-106: Lure with sound. Femur Breaker protocol for recontainment. Do NOT pursue into pocket dimension.<br>
SCP-939: Do not respond to voices. Track by thermal signature only. Approach in armed pairs.<br>
<br>
<b>IV. D-CLASS ESCORT</b><br>
- Maintain a distance of 2 meters from D-Class at all times.<br>
- D-Class are not to be left unattended in containment areas.<br>
- Terminate D-Class only if they become a threat to containment or personnel.<br>
<br>
<b>V. MTF COORDINATION</b><br>
- MTF teams have operational authority during breach response.<br>
- Security personnel are to assist MTF as directed.<br>
- Report all findings to the MTF commander via the MTF radio frequency.<br>
<hr><center>Secure. Contain. Protect.</center><hr>
</body>
</html>
"}

/obj/item/book/guidebook/foundation_research
	name = "Foundation Researcher's Guide"
	desc = "A guide for Foundation researchers on proper SCP testing methodology."
	icon_state = "book3"
	starting_title = "Foundation Researcher's Guide"
	starting_author = "Foundation Research Command"
	starting_content = {"<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<style>
body{font-family:Courier New;font-size:12px;color:#222;}
hr{border:1px solid #444;}
</style>
</head>
<body>
<hr><center><b>SCP FOUNDATION<br>RESEARCHER'S GUIDE</b></center><hr>
<br>
<b>I. TESTING PROTOCOL</b><br>
All SCP testing must be formally submitted through the SCP Testing Console. Unauthorized testing is a Level 2 disciplinary offense.<br>
<br>
<b>II. TEST SUBMISSION</b><br>
1. Select the SCP to be tested.<br>
2. Assign a D-Class subject.<br>
3. Select the test type and risk level.<br>
4. Await approval from the Containment Department.<br>
5. Conduct the test under observation.<br>
6. Log observations and set outcome on the Testing Console.<br>
<br>
<b>III. SCP-914 EXPERIMENTS</b><br>
SCP-914 is a primary testing resource. Submit all items through the intake booth. Document all input/output combinations. Discovery of new recipes earns research commendations.<br>
<br>
<b>IV. ANOMALOUS ITEM HANDLING</b><br>
- Report all anomalous items immediately.<br>
- Do not test items outside the lab.<br>
- Contained items must be stored in the LCZ item storage.<br>
<br>
<b>V. SAFETY PROCEDURES</b><br>
- Always wear appropriate PPE when handling SCPs.<br>
- Memetic hazards: Telekill helmet required.<br>
- Biological hazards: Full hazmat suit required.<br>
- Thermal hazards: Heat-resistant gloves and apron required.<br>
- NEVER enter a containment chamber alone.<br>
<hr><center>Secure. Contain. Protect.</center><hr>
</body>
</html>
"}
