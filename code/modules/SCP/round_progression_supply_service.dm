// Foundation Round Progression Subsystem
// Unified phase system with cross-department objectives

#define ROUND_PHASE_STARTUP 0
#define ROUND_PHASE_ROUTINE 1
#define ROUND_PHASE_ELEVATED 2
#define ROUND_PHASE_CRISIS 3
#define ROUND_PHASE_RESOLUTION 4
#define ROUND_PHASE_DEBRIEF 5

SUBSYSTEM_DEF(foundation_round)
	name = "Foundation Round Progression"
	wait = 600
	flags = NONE
	var/current_phase = ROUND_PHASE_STARTUP
	var/phase_start_time = 0
	var/list/phase_objectives = list()
	var/list/completed_objectives = list()
	var/total_objectives_issued = 0
	var/total_objectives_completed = 0
	var/crisis_trigger_threshold = 3
	var/breach_count = 0
	var/cross_dept_bonus_issued = FALSE

/datum/controller/subsystem/foundation_round/Initialize(start_time)
	. = ..()
	phase_start_time = world.time
	advance_phase(ROUND_PHASE_ROUTINE)

/datum/controller/subsystem/foundation_round/fire()
	var/elapsed = world.time - phase_start_time
	switch(current_phase)
		if(ROUND_PHASE_ROUTINE)
			if(elapsed > 15 MINUTES)
				advance_phase(ROUND_PHASE_ELEVATED)
			generate_routine_objectives()
		if(ROUND_PHASE_ELEVATED)
			if(breach_count >= crisis_trigger_threshold || elapsed > 35 MINUTES)
				advance_phase(ROUND_PHASE_CRISIS)
			else if(elapsed > 25 MINUTES && !cross_dept_bonus_issued)
				issue_cross_department_objective()
			if(prob(3))
				trigger_power_failure_cascade()
		if(ROUND_PHASE_CRISIS)
			if(elapsed > 50 MINUTES)
				advance_phase(ROUND_PHASE_RESOLUTION)
			if(prob(5))
				trigger_power_failure_cascade()
			if(prob(2))
				trigger_goi_breach_sabotage(pick("ci", "sarkic", "serpents"))
			if(prob(1))
				trigger_goi_midround_spawn(pick("ci", "sarkic", "serpents"))
		if(ROUND_PHASE_RESOLUTION)
			if(elapsed > 60 MINUTES)
				advance_phase(ROUND_PHASE_DEBRIEF)

/datum/controller/subsystem/foundation_round/proc/advance_phase(new_phase)
	current_phase = new_phase
	phase_start_time = world.time
	switch(new_phase)
		if(ROUND_PHASE_ROUTINE)
			priority_announce("All departments: Routine operations period has begun. Standard containment and research protocols in effect. Department heads: Review your assigned objectives.", "Foundation Operations", null, ANNOUNCER_ALERT)
		if(ROUND_PHASE_ELEVATED)
			priority_announce("Attention all personnel: Facility status elevated. Increased anomalous activity detected. All departments increase vigilance. Security: Enhance patrol coverage. Research: Prioritize containment research.", "Foundation Operations", null, ANNOUNCER_ALERT)
			adjust_global_research_points(50, "round_phase_elevated")
			generate_elevated_objectives()
		if(ROUND_PHASE_CRISIS)
			priority_announce("CRISIS PROTOCOL ACTIVATED. Multiple containment anomalies detected. All personnel report to emergency stations. MTF deployment authorized. Research: Emergency containment protocols. Medical: Prepare for mass casualties. Engineering: Critical infrastructure preservation.", "FOUNDATION CRISIS", null, ANNOUNCER_ALERT)
			adjust_global_research_points(100, "round_phase_crisis")
			generate_crisis_objectives()
		if(ROUND_PHASE_RESOLUTION)
			priority_announce("Crisis resolution phase initiated. All departments: Report current status. Prioritize recontainment and recovery. Medical: Triage and treatment. Engineering: Infrastructure repair. Security: Perimeter consolidation.", "Foundation Operations", null, ANNOUNCER_ALERT)
			generate_resolution_objectives()
		if(ROUND_PHASE_DEBRIEF)
			priority_announce("End of shift debrief commencing. All department heads: Submit operational reports. Personnel: Return to designated areas. Foundation thanks you for your service.", "Foundation Operations", null, ANNOUNCER_ALERT)

/datum/controller/subsystem/foundation_round/proc/generate_routine_objectives()
	if(length(phase_objectives) >= 5)
		return
	var/list/possible = list(
		"Medical: Treat at least 3 patients this shift.",
		"Research: Complete at least 1 SCP experiment.",
		"Engineering: Ensure all APCs in LCZ are functional.",
		"Security: Complete 2 patrol circuits of assigned zone.",
		"Supply: Deliver requested supplies to 2 departments.",
		"Service: Serve meals to at least 10 personnel.",
		"D-Class: Complete 2 assigned work tasks.",
	)
	for(var/i in 1 to min(3, length(possible)))
		var/obj_text = pick_n_take(possible)
		if(!(obj_text in phase_objectives))
			phase_objectives += obj_text
			total_objectives_issued++

/datum/controller/subsystem/foundation_round/proc/generate_elevated_objectives()
	var/list/possible = list(
		"Research: Develop a containment improvement for any breached SCP.",
		"Security: Recontain at least 1 SCP or prevent a secondary breach.",
		"Medical: Treat at least 5 patients including any SCP-related injuries.",
		"Engineering: Repair all critical infrastructure in containment zones.",
		"All Departments: Maintain facility integrity above 70%.",
	)
	for(var/i in 1 to min(3, length(possible)))
		var/obj_text = pick_n_take(possible)
		if(!(obj_text in phase_objectives))
			phase_objectives += obj_text
			total_objectives_issued++

/datum/controller/subsystem/foundation_round/proc/generate_crisis_objectives()
	var/list/possible = list(
		"Security: Recontain all breached SCPs within 15 minutes.",
		"Medical: Keep civilian casualties below 5.",
		"Engineering: Prevent total power failure across the facility.",
		"Research: Identify containment weakness contributing to current crisis.",
		"Command: Authorize and coordinate MTF deployment.",
		"All Departments: Survive the crisis with less than 30% personnel loss.",
	)
	for(var/i in 1 to min(4, length(possible)))
		var/obj_text = pick_n_take(possible)
		if(!(obj_text in phase_objectives))
			phase_objectives += obj_text
			total_objectives_issued++

/datum/controller/subsystem/foundation_round/proc/generate_resolution_objectives()
	var/list/possible = list(
		"All Departments: Complete all outstanding objectives before shift end.",
		"Medical: Ensure all injured personnel are treated.",
		"Engineering: Restore all critical systems to operational status.",
		"Research: Submit final research reports for the shift.",
		"Security: Secure all containment zones and report final status.",
	)
	for(var/i in 1 to min(2, length(possible)))
		var/obj_text = pick_n_take(possible)
		if(!(obj_text in phase_objectives))
			phase_objectives += obj_text
			total_objectives_issued++

/datum/controller/subsystem/foundation_round/proc/issue_cross_department_objective()
	cross_dept_bonus_issued = TRUE
	var/list/objectives = list(
		"Medical & Research: Collaborate on an SCP medical experiment — Medical provides test subjects, Research conducts the experiment.",
		"Engineering & Security: Joint sweep of HCZ — Engineering checks containment integrity, Security provides escort.",
		"Supply & Research: Supply acquires anomalous materials, Research catalogs them for study.",
		"Service & Medical: Service provides nutrition support for Medical during high-casualty events.",
	)
	var/chosen = pick(objectives)
	phase_objectives += chosen
	total_objectives_issued++
	priority_announce("Cross-department cooperation objective issued: [chosen]", "Foundation Operations", null, ANNOUNCER_ALERT)
	adjust_global_research_points(75, "cross_dept_objective")

/datum/controller/subsystem/foundation_round/proc/complete_objective(objective_text)
	if(!(objective_text in phase_objectives))
		return
	phase_objectives -= objective_text
	completed_objectives += objective_text
	total_objectives_completed++
	adjust_global_research_points(25, "objective_completed")

/datum/controller/subsystem/foundation_round/proc/register_breach()
	breach_count++

/datum/controller/subsystem/foundation_round/proc/get_phase_name()
	switch(current_phase)
		if(ROUND_PHASE_STARTUP)
			return "Startup"
		if(ROUND_PHASE_ROUTINE)
			return "Routine Operations"
		if(ROUND_PHASE_ELEVATED)
			return "Elevated Alert"
		if(ROUND_PHASE_CRISIS)
			return "Crisis"
		if(ROUND_PHASE_RESOLUTION)
			return "Resolution"
		if(ROUND_PHASE_DEBRIEF)
			return "Debrief"
	return "Unknown"

/datum/controller/subsystem/foundation_round/proc/get_status_report()
	. = list()
	.["phase"] = get_phase_name()
	.["breaches"] = breach_count
	.["objectives_active"] = length(phase_objectives)
	.["objectives_completed"] = total_objectives_completed
	.["time_in_phase"] = round((world.time - phase_start_time) / 600, 1)

// ================================================================
// ANOMALOUS SUPPLY EVENTS & SCP SUPPLY CRATES
// ================================================================

/datum/round_event_control/anomalous_cargo
	name = "Anomalous Cargo Delivery"
	typepath = /datum/round_event/anomalous_cargo
	weight = 10
	min_players = 5
	earliest_start = 10 MINUTES
	max_occurrences = 3

/datum/round_event/anomalous_cargo
	var/list/possible_crates = list(
		/obj/structure/closet/crate/scp_supply/basic_research,
		/obj/structure/closet/crate/scp_supply/containment_equipment,
		/obj/structure/closet/crate/scp_supply/medical_anomalous,
		/obj/structure/closet/crate/scp_supply/anomalous_sample,
	)

/datum/round_event/anomalous_cargo/start()
	var/crate_type = pick(possible_crates)
	var/list/delivery_turfs = list()
	for(var/turf/T in get_area_turfs(/area/scp/surface))
		if(!T.density)
			delivery_turfs += T
	if(!length(delivery_turfs))
		delivery_turfs += list(pick(GLOB.station_turfs))
	new crate_type(pick(delivery_turfs))
	priority_announce("Anomalous cargo delivery received at surface level. Contents flagged for Foundation research personnel.", "Supply Department", null, ANNOUNCER_ALERT)

/obj/structure/closet/crate/scp_supply
	name = "Foundation supply crate"
	desc = "A heavy-duty crate bearing Foundation markings."

/obj/structure/closet/crate/scp_supply/basic_research
	name = "basic research supplies"

/obj/structure/closet/crate/scp_supply/basic_research/PopulateContents()
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clipboard(src)
	new /obj/item/pen(src)
	new /obj/item/storage/box/beakers(src)

/obj/structure/closet/crate/scp_supply/containment_equipment
	name = "containment equipment"

/obj/structure/closet/crate/scp_supply/containment_equipment/PopulateContents()
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/stack/sheet/iron{amount = 10}(src)
	new /obj/item/stack/sheet/plasteel{amount = 5}(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)

/obj/structure/closet/crate/scp_supply/medical_anomalous
	name = "anomalous medical supplies"

/obj/structure/closet/crate/scp_supply/medical_anomalous/PopulateContents()
	new /obj/item/storage/medkit/regular(src)
	new /obj/item/reagent_containers/hypospray/medipen/survival(src)
	new /obj/item/reagent_containers/hypospray/medipen/survival(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/glasses/hud/health(src)

/obj/structure/closet/crate/scp_supply/anomalous_sample
	name = "anomalous sample kit"

/obj/structure/closet/crate/scp_supply/anomalous_sample/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/analyzer(src)

/datum/round_event_control/scp_supply_malfunction
	name = "Supply Catalog Anomaly"
	typepath = /datum/round_event/scp_supply_malfunction
	weight = 8
	min_players = 10
	earliest_start = 15 MINUTES
	max_occurrences = 2

/datum/round_event/scp_supply_malfunction/start()
	priority_announce("Supply catalog anomaly detected. A random item has been added to the cargo ordering system. Exercise caution with unexpected shipments.", "Supply Department", null, ANNOUNCER_ALERT)
	adjust_global_research_points(-25, "supply_malfunction_data_corruption")

/datum/round_event_control/anomalous_cargo_contaminated
	name = "Contaminated Cargo"
	typepath = /datum/round_event/anomalous_cargo_contaminated
	weight = 5
	min_players = 15
	earliest_start = 25 MINUTES
	max_occurrences = 1

/datum/round_event/anomalous_cargo_contaminated/start()
	var/list/delivery_turfs = list()
	for(var/turf/T in get_area_turfs(/area/scp/surface))
		if(!T.density)
			delivery_turfs += T
	if(!length(delivery_turfs))
		return
	var/turf/delivery = pick(delivery_turfs)
	new /obj/structure/closet/crate/scp_supply/contaminated(delivery)
	priority_announce("WARNING: Contaminated cargo delivery detected at surface level. Biohazard protocols in effect. Do NOT open without proper protective equipment.", "Supply Department", null, ANNOUNCER_ALERT)

/obj/structure/closet/crate/scp_supply/contaminated
	name = "contaminated supply crate"
	desc = "A crate with biohazard warning stickers. It smells... wrong."
	color = "#8B0000"

/obj/structure/closet/crate/scp_supply/contaminated/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker/bluespace(src)
	new /obj/item/clothing/suit/bio_suit/general(src)
	new /obj/item/clothing/head/bio_hood/general(src)
	new /obj/item/storage/medkit/regular(src)

/obj/structure/closet/crate/scp_supply/contaminated/open()
	. = ..()
	for(var/mob/living/carbon/human/H in view(2, src))
		H.adjustToxLoss(5)
		to_chat(H, span_warning("A noxious gas escapes from the crate!"))

// ================================================================
// SERVICE CONTENT — Chaplain Sanity, Anomalous Botany, Curator Docs
// ================================================================

// Chaplain: Sanity Restoration Ritual
/obj/structure/chapel_altar
	name = "Foundation chapel altar"
	desc = "A simple altar for spiritual reflection and meditation."
	icon = 'icons/obj/structures.dmi'
	icon_state = "chapel_altar"
	anchored = TRUE
	density = TRUE
	var/ritual_cooldown = 0

/obj/structure/chapel_altar/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(world.time < ritual_cooldown)
		to_chat(user, span_notice("You need more time before performing another ritual."))
		return
	ritual_cooldown = world.time + 60 SECONDS
	var/mob/living/carbon/human/H = user
	H.apply_status_effect(/datum/status_effect/chapel_blessing)
	to_chat(H, span_notice("You kneel at the altar and find inner peace. Your mind clears."))
	hook_scp_interaction(H, "CHAPEL", INTERACTION_TYPE_CARE)
	var/list/nearby = list()
	for(var/mob/living/carbon/human/N in view(3, src))
		if(N != H)
			nearby += N
	if(length(nearby))
		for(var/mob/living/carbon/human/N in nearby)
			N.apply_status_effect(/datum/status_effect/chapel_blessing)
			to_chat(N, span_notice("A sense of calm washes over you from the nearby ritual."))
		to_chat(H, span_notice("Your ritual also brings peace to [length(nearby)] nearby soul\s."))

/datum/status_effect/chapel_blessing
	id = "chapel_blessing"
	duration = 120 SECONDS
	tick_interval = 10 SECONDS

/datum/status_effect/chapel_blessing/tick()
	. = ..()
	if(ishuman(owner))
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1)

// Anomalous Botany: Strange Seeds
/obj/item/seeds/anomalous
	name = "anomalous seed pack"
	desc = "Seeds of unknown origin. They seem to pulse with faint energy."
	icon_state = "seed-replicapod"

/obj/structure/flora/grown/anomalous_flora
	name = "anomalous flora"
	desc = "A strange plant that shimmers with faint light."
	icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_state = "apple_grow"
	anchored = TRUE
	density = FALSE
	var/harvest_count = 3

/obj/structure/flora/grown/anomalous_flora/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(harvest_count <= 0)
		to_chat(user, span_notice("This plant has no more fruit to harvest."))
		return
	harvest_count--
	var/mob/living/carbon/human/H = user
	var/effect_type = rand(1, 4)
	switch(effect_type)
		if(1)
			H.adjustBruteLoss(-15)
			H.adjustFireLoss(-15)
			to_chat(H, span_notice("The fruit's essence mends your wounds."))
		if(2)
			to_chat(H, span_notice("A burst of energy fills you!"))
		if(3)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, -10)
			to_chat(H, span_notice("Your mind clears and focuses."))
		if(4)
			H.adjustToxLoss(10)
			H.blur_eyes(5)
			to_chat(H, span_warning("The fruit's essence is toxic! You feel ill."))
	hook_scp_interaction(H, "ANOMALOUS_BOTANY", INTERACTION_TYPE_MEDICAL)

// Curator: Foundation Documentation
/obj/item/book/manual/wiki/foundation_protocols
	starting_title = "Foundation Standard Operating Procedures"
	starting_author = "O5 Council"
	starting_content = "<center><b><font size=4>THE SCP FOUNDATION</font></b><br><i>Secure. Contain. Protect.</i></center><hr><br><b>Security Clearance Levels:</b><br>Level 0: General / Non-essential<br>Level 1: Confidential<br>Level 2: Restricted<br>Level 3: Secret<br>Level 4: Top Secret<br>Level 5: Thaumiel<br><br><b>Object Classes:</b><br>Safe: Easily and safely contained.<br>Euclid: Unpredictable; requires more resources.<br>Keter: Difficult to contain reliably.<br>Thaumiel: Used to contain other SCPs.<br>Apollyon: Cannot be contained; will inevitably cause an end-of-world scenario.<br><br><b>Security Codes:</b><br>Code White: Normal operations.<br>Code Yellow: Suspicious activity; standby.<br>Code Orange: Imminent threat; prepare for breach.<br>Code Red: Active breach; all personnel respond.<br>Code Omega: Facility-wide catastrophic event; evacuate immediately.<br><br><b>Protocol 1:</b> Do NOT make eye contact with SCP-096 under any circumstances.<br><b>Protocol 2:</b> Never enter SCP-173's containment chamber alone.<br><b>Protocol 3:</b> Report all anomalous behavior to your supervisor immediately.<br><b>Protocol 4:</b> Class-A amnestics are administered to all unauthorized witnesses of anomalous events.<br><br><i>This document is classified Level 2. Unauthorized access is grounds for immediate termination.</i>"

/obj/item/book/manual/wiki/dclass_handbook
	starting_title = "D-Class Personnel Handbook"
	starting_author = "Foundation Human Resources"
	starting_content = "<center><b><font size=4>D-CLASS PERSONNEL HANDBOOK</font></b><br><i>Your cooperation is mandatory.</i></center><hr><br><b>Welcome to the Foundation.</b> You have been assigned as D-Class personnel. Your duties include testing, maintenance, and other tasks as directed by Foundation staff.<br><br><b>Rules:</b><br>1. Follow all instructions from authorized personnel.<br>2. Do not leave designated areas without escort.<br>3. Do not touch, speak to, or approach any SCP without authorization.<br>4. Report any anomalous behavior immediately.<br>5. Attempting to escape is grounds for immediate termination.<br><br><b>Rewards:</b><br>- Complete test participation: Credits and reduced sentence.<br>- Good behavior: Additional privileges.<br>- Volunteering for high-risk testing: Bonus compensation for next of kin.<br><br><b>Emergency Procedures:</b><br>- In the event of a containment breach, proceed to the nearest safe zone.<br>- Follow security personnel instructions immediately.<br>- Do NOT attempt to interact with any breached entity.<br><br><i>Remember: Your service to the Foundation is valued. Your cooperation ensures the safety of all personnel.</i>"

/obj/item/book/manual/wiki/researcher_guide
	starting_title = "Foundation Research Methodology"
	starting_author = "Dr. ███████, Senior Researcher"
	starting_content = "<center><b><font size=4>RESEARCH METHODOLOGY</font></b><br><i>Understanding the Unknown</i></center><hr><br><b>Experiment Design:</b><br>1. Define hypothesis about SCP behavior or properties.<br>2. Design controlled experiment with measurable outcomes.<br>3. Obtain authorization from Research Director.<br>4. Request D-Class test subjects through proper channels.<br>5. Document ALL observations, no matter how insignificant.<br>6. Submit findings to the research database.<br><br><b>Risk Assessment:</b><br>- Minimal: No physical contact required.<br>- Low: Brief controlled contact under supervision.<br>- Medium: Extended contact; security presence required.<br>- High: Potential for injury or anomalous effects; MTF standby.<br>- Critical: Potential for breach or mass casualties; O5 authorization required.<br><br><b>Documentation Standards:</b><br>All research must be documented using Foundation Standard Format (FSF). Include: SCP designation, experiment ID, personnel involved, methodology, observations, conclusions, and recommendations.<br><br><b>IMPORTANT:</b> Never conduct experiments without proper authorization. Unsanctioned testing is grounds for immediate termination and amnestic treatment."
