/obj/machinery/computer/scp_tutorial_console
	name = "SCP Terminal"
	desc = "A Foundation terminal containing orientation and reference materials."
	icon_screen = "command"
	icon_keyboard = "tech_key"
	circuit = null
	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/scp_tutorial_console/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/computer/scp_tutorial_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPTutorial", name)
		ui.open()

/obj/machinery/computer/scp_tutorial_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/scp_tutorial_console/ui_data(mob/user)
	var/list/data = list()
	var/list/pages = list()

	pages += list(list(
		"id" = "welcome",
		"title" = "Welcome to the Foundation",
		"category" = "General",
		"content" = "<span class='notice'>SECURITY CLEARANCE: LEVEL 0 - ORIENTATION MATERIAL</span><br><br>Welcome to Site-53, a Secure Containment Facility operated under the authority of the SCP Foundation.<br><br><b>Our Mission:</b> We Secure. We Contain. We Protect. The Foundation exists to contain anomalous objects, entities, and phenomena that threaten normalcy. Every staff member plays a role in this mission.<br><br><b>Your Role:</b> Regardless of your assignment, you are expected to follow Foundation protocols at all times. Failure to comply with containment procedures can result in catastrophic loss of life.<br><br><span class='notice'>Read each section of this terminal carefully. Knowledge is your first line of defense.</span>"
	))

	pages += list(list(
		"id" = "dclass",
		"title" = "D-Class Survival Guide",
		"category" = "Personnel",
		"content" = "<span class='warning'>CLASSIFIED - D-CLASS PERSONNEL ONLY</span><br><br>As D-Class personnel, you are assigned to hazardous testing and maintenance duties. Survival requires vigilance and preparation.<br><br><b>Crafting:</b> Salvage materials from your environment. Combine items to create tools, weapons, and contraband. Improvised weapons can mean the difference between life and death during a breach.<br><br><b>Experiments:</b> Follow researcher instructions during testing. Cooperate - but stay alert for signs that containment is failing.<br><br><b>Escape Routes:</b> Maintenance tunnels, ventilation shafts, and emergency exits can provide egress during a containment failure. <span class='danger'>Do not attempt escape during normal operations.</span><br><br><b>Contraband:</b> Acquiring unauthorized items is punishable, but during a breach, survival takes priority."
	))

	pages += list(list(
		"id" = "security",
		"title" = "Security Protocol",
		"category" = "Personnel",
		"content" = "<span class='notice'>SECURITY DIVISION - OPERATIONAL MANUAL</span><br><br><b>Containment Procedures:</b> Each SCP has specific protocols. Review SCP database entries for details. Never engage an SCP without authorization and proper equipment.<br><br><b>MTF Deployment:</b> Mobile Task Forces are dispatched for breach response. Follow the chain of command. Squad leaders coordinate with Site Command.<br><br><b>Riot Response:</b> D-Class unrest must be contained swiftly. Use non-lethal measures first. Escalate to lethal force only when personnel safety is directly threatened.<br><br><b>Patrol Routes:</b> Maintain regular patrols of containment wings. Report anomalies immediately. Do not enter a breached containment chamber alone."
	))

	pages += list(list(
		"id" = "science",
		"title" = "Science Division",
		"category" = "Personnel",
		"content" = "<span class='notice'>RESEARCH DIVISION - LABORATORY PROTOCOLS</span><br><br><b>Experiment Types:</b> Behavioral observation, material exposure, and interaction analysis. Each requires specific safety protocols and documentation.<br><br><b>Research Console:</b> Use facility terminals to log experiment data, request D-Class subjects, and access SCP files. All experiments must be pre-approved.<br><br><b>SCP-914 Recipes:</b> The Clockworks can refine materials through five settings: Rough, Coarse, 1:1, Fine, and Very Fine. Results vary based on input and setting. Document all outputs for the research database.<br><br><b>Safety:</b> Maintain containment at all times during testing. Never test alone. Ensure security is present for all SCP interactions."
	))

	pages += list(list(
		"id" = "medical",
		"title" = "Medical Bay",
		"category" = "Personnel",
		"content" = "<span class='notice'>MEDICAL DIVISION - HEALTH AND QUARANTINE PROTOCOLS</span><br><br><b>Quarantine:</b> Any personnel exposed to anomalous pathogens or SCP-008 must be quarantined immediately. Do not exit quarantine without medical clearance.<br><br><b>Contagion Tracking:</b> Monitor infection vectors through facility systems. Early detection prevents outbreaks.<br><br><b>SCP-500:</b> SCP-500 (Panacea) consists of 47 red pills capable of curing any disease. Usage is restricted to Level 4 authorization or critical containment scenarios. Each use must be logged.<br><br><b>Standard Treatment:</b> Use conventional medical supplies for non-anomalous injuries."
	))

	pages += list(list(
		"id" = "scps",
		"title" = "SCP Database",
		"category" = "Reference",
		"content" = "<span class='warning'>CLASSIFIED - LEVEL 2 CLEARANCE REQUIRED</span><br><br><b>SCP-173:</b> Concrete sculpture. Moves when unobserved. <span class='danger'>MAINTAIN DIRECT EYE CONTACT AT ALL TIMES.</span><br><br><b>SCP-096:</b> Tall humanoid. Docile until its face is viewed, then pursues relentlessly. <span class='danger'>DO NOT VIEW ITS FACE.</span><br><br><b>SCP-049:</b> Plague doctor. Claims to sense the Pestilence. Touch is lethal, reanimates corpses. <span class='warning'>Do not allow physical contact.</span><br><br><b>SCP-106:</b> Corrosive humanoid. Passes through solid matter. Creates pocket dimension. <span class='danger'>Containment requires recall protocol.</span><br><br><b>SCP-079:</b> Sentient AI. Interfaces with facility systems. <span class='warning'>Do not connect to network terminals.</span><br><br><b>SCP-682:</b> Large reptilian. Extreme regeneration. Hostile to all life. <span class='danger'>Do not approach.</span><br><br><b>SCP-939:</b> Pack predators with vocal mimicry. Blind - hunt by sound. <span class='warning'>Maintain silence near containment.</span><br><br><b>SCP-457:</b> Sentient flame. Feeds on combustibles. <span class='warning'>Contain with fire suppression.</span><br><br><b>SCP-008:</b> Zombie prion. 100% infectious. <span class='danger'>Level 4 biohazard. No exceptions.</span>"
	))

	pages += list(list(
		"id" = "facility",
		"title" = "Facility Systems",
		"category" = "Reference",
		"content" = "<span class='notice'>FACILITY OPERATIONS - SYSTEMS OVERVIEW</span><br><br><b>Power Grid:</b> Powered by primary reactor with backup generators. Critical systems have UPS support. <span class='warning'>Power failure triggers automatic lockdown.</span><br><br><b>Door Control:</b> Access controlled by ID card clearance. Emergency bolt-down from Command. Blast doors seal automatically during breach events.<br><br><b>Camera Network:</b> Monitoring stations provide feeds from all zones. Report dead feeds to Engineering.<br><br><b>PA System:</b> Used for announcements, evacuation orders, and breach alerts. Only authorized personnel may access PA controls."
	))

	pages += list(list(
		"id" = "keybinds",
		"title" = "Keybinds & Controls",
		"category" = "Reference",
		"content" = "<span class='notice'>CONTROLS REFERENCE</span><br><br><b>Action Buttons:</b> Appear at the top of your screen. Click to activate abilities, use items, or trigger special actions.<br><br><b>TGUI Interfaces:</b> Many machines use TGUI windows. Interact by clicking buttons or selecting options. Close when finished.<br><br><b>Combat Mode:</b> Toggle with designated keybind or action button. In combat mode, clicks attack mobs. Outside combat mode, clicks perform intent-based actions. <span class='warning'>Keep combat mode OFF unless hostile action is required.</span><br><br><b>Intent System:</b> Set intent in the bottom-right corner - Help, Disarm, Grab, or Harm. Your intent determines interaction results.<br><br><b>Movement:</b> Use WASD or arrow keys. Click on tiles to move via pathfinding."
	))

	data["pages"] = pages
	return data

/obj/machinery/computer/scp_tutorial_console/ui_act(action, params)
	. = ..()
	if(.)
		return
