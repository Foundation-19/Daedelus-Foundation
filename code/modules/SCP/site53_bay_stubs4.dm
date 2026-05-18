// Site53 Bay stubs batch 4 - ONLY types with functional logic
// Name-only stubs removed; BYOND creates parent-type instances from map data

// ================================================================
// CLOSET STUBS - only those with req_access or special logic
// ================================================================

/obj/structure/closet/coffin/scp895
	name = "SCP-895 coffin"
	desc = "An ornate coffin with a camera feed warning label."

// ================================================================
// AIRLOCK DOOR STUBS - only those with req_access or glass/bound
// ================================================================

/obj/machinery/door/airlock/multi_tile
	name = "wide airlock"
	desc = "A large airlock spanning multiple tiles."
	normal_integrity = 450
	bound_width = 64

/obj/machinery/door/airlock/multi_tile/command
	name = "command airlock"
	normal_integrity = 450
	req_access = list(ACCESS_ADMIN)

/obj/machinery/door/airlock/multi_tile/glass
	name = "wide glass airlock"
	opacity = FALSE
	glass = TRUE
	normal_integrity = 300

/obj/machinery/door/airlock/multi_tile/glass/command
	name = "glass command airlock"
	req_access = list(ACCESS_ADMIN)

/obj/machinery/door/airlock/multi_tile/glass/medical
	name = "glass medical airlock"
	req_access = list(ACCESS_MEDICAL)

/obj/machinery/door/airlock/multi_tile/glass/mining
	name = "glass mining airlock"
	req_access = list(ACCESS_LOGISTICS)

/obj/machinery/door/airlock/multi_tile/glass/research
	name = "glass research airlock"
	req_access = list(ACCESS_SCIENCE)

/obj/machinery/door/airlock/multi_tile/glass/science
	name = "glass science airlock"
	req_access = list(ACCESS_SCIENCE)

/obj/machinery/door/airlock/multi_tile/glass/security
	name = "glass security airlock"
	req_access = list(ACCESS_SECURITY)

/obj/machinery/door/airlock/multi_tile/research
	name = "research airlock"
	req_access = list(ACCESS_SCIENCE)

/obj/machinery/door/airlock/multi_tile/security
	name = "security airlock"
	req_access = list(ACCESS_SECURITY)

/obj/machinery/door/airlock/highsecurity/bolted
	name = "bolted high-security airlock"

/obj/machinery/door/airlock/vault/bolted
	name = "bolted vault door"

// ================================================================
// VENDING MACHINE STUBS - with product lists
// ================================================================

/obj/machinery/vending/wallmed1
	name = "\improper NanoMed Mini"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	panel_type = "panel-wall"
	density = FALSE
	products = list(
		/obj/item/reagent_containers/syringe = 2,
		/obj/item/reagent_containers/pill/bicaridine = 4,
		/obj/item/reagent_containers/pill/kelotane = 4,
		/obj/item/stack/medical/bone_gel/twelve = 1,
	)
	contraband = list(
		/obj/item/reagent_containers/pill/tox = 1,
	)
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = PAYCHECK_ASSISTANT * 4
	extra_price = PAYCHECK_ASSISTANT * 6
	payment_department = ACCOUNT_MED
	tiltable = FALSE
	light_mask = "wallmed-light-mask"
	discount_access = ACCESS_MEDICAL

/obj/machinery/vending/wallmed2
	name = "\improper NanoMed Plus"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	panel_type = "panel-wall"
	density = FALSE
	products = list(
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/reagent_containers/pill/bicaridine = 7,
		/obj/item/reagent_containers/pill/kelotane = 7,
		/obj/item/reagent_containers/pill/dylovene = 4,
		/obj/item/stack/medical/bone_gel/twelve = 3,
		/obj/item/healthanalyzer = 2,
	)
	contraband = list(
		/obj/item/reagent_containers/pill/tox = 3,
		/obj/item/reagent_containers/pill/morphine = 3,
	)
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = PAYCHECK_ASSISTANT * 4
	extra_price = PAYCHECK_ASSISTANT * 6
	payment_department = ACCOUNT_MED
	tiltable = FALSE
	light_mask = "wallmed-light-mask"
	discount_access = ACCESS_MEDICAL

/obj/machinery/vending/weaponry
	name = "\improper Foundation Armory Vendor"
	desc = "A secure vending machine containing Foundation-issued weaponry and ammunition."
	icon_state = "sec"
	icon_deny = "sec-deny"
	product_slogans = "Foundation equipment at your fingertips.;Only the best for containment personnel."
	products = list(
		/obj/item/gun/ballistic/automatic/scp/p90 = 4,
		/obj/item/ammo_box/magazine/scp/p90_mag = 8,
		/obj/item/ammo_box/magazine/scp/p90_mag/rubber = 4,
		/obj/item/gun/ballistic/shotgun/lethal = 2,
		/obj/item/storage/box/lethalshot = 4,
		/obj/item/melee/baton/security/loaded = 4,
		/obj/item/shield/riot = 2,
		/obj/item/grenade/flashbang = 2,
	)
	contraband = list(
		/obj/item/gun/ballistic/automatic/scp/ak74 = 1,
		/obj/item/ammo_box/magazine/scp/ak = 2,
	)
	default_price = PAYCHECK_COMMAND * 2
	extra_price = PAYCHECK_COMMAND * 4
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/weaponry/chaos
	name = "\improper Insurgency Armory Vendor"
	desc = "A rugged vending machine stocked with Chaos Insurgency weaponry."
	icon_state = "syndicate"
	product_slogans = "For the Insurgency!;Overthrow the Foundation today."
	products = list(
		/obj/item/gun/ballistic/automatic/scp/ak74 = 4,
		/obj/item/ammo_box/magazine/scp/ak = 8,
		/obj/item/gun/ballistic/automatic/scp/ak742 = 2,
		/obj/item/gun/ballistic/automatic/pistol = 4,
		/obj/item/ammo_box/magazine/m9mm = 8,
		/obj/item/grenade/frag = 3,
		/obj/item/clothing/under/scp/syndicate/chaos = 4,
		/obj/item/clothing/suit/armor/vest = 4,
	)
	contraband = list(
		/obj/item/gun/ballistic/automatic/scp/rpk = 1,
		/obj/item/grenade/syndieminibomb = 2,
	)
	default_price = 0
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/weaponry/chaos/specialized
	name = "\improper Insurgency Specialist Vendor"
	desc = "Specialized equipment for Chaos Insurgency operatives."
	products = list(
		/obj/item/gun/ballistic/automatic/scp/svd = 2,
		/obj/item/ammo_box/magazine/scp/svd = 4,
		/obj/item/gun/ballistic/automatic/scp/rpk = 2,
		/obj/item/ammo_box/magazine/scp/ak/big = 4,
		/obj/item/implanter/explosive = 2,
		/obj/item/clothing/glasses/thermal = 2,
	)
	default_price = 0
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/weaponry/goc
	name = "\improper GOC Armory Vendor"
	desc = "A high-tech vending machine stocked with GOC-issue weaponry."
	icon_state = "syndicate"
	product_slogans = "Protecting humanity from the anomalous."
	products = list(
		/obj/item/gun/ballistic/automatic/scp/p90 = 4,
		/obj/item/ammo_box/magazine/scp/p90_mag = 10,
		/obj/item/gun/ballistic/shotgun/lethal = 2,
		/obj/item/storage/box/lethalshot = 4,
		/obj/item/melee/baton/security/loaded = 4,
		/obj/item/shield/riot = 2,
		/obj/item/clothing/suit/armor/vest = 4,
		/obj/item/clothing/head/helmet = 4,
	)
	contraband = list(
		/obj/item/gun/energy/laser = 1,
	)
	default_price = 0
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/security/nonlethal
	name = "non-lethal equipment vendor"
	products = list(
		/obj/item/melee/baton/security/loaded = 4,
		/obj/item/reagent_containers/spray/pepper = 4,
		/obj/item/grenade/flashbang = 4,
		/obj/item/restraints/legcuffs/bola = 6,
	)
	default_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/security/sergeant
	name = "sergeant equipment vendor"
	products = list(
		/obj/item/gun/ballistic/automatic/scp/p90 = 2,
		/obj/item/ammo_box/magazine/scp/p90_mag = 4,
		/obj/item/melee/baton/security/loaded = 2,
		/obj/item/storage/belt/security = 2,
	)
	default_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SEC

// ================================================================
// COMPUTERS - with circuit and TGUI
// ================================================================

/obj/machinery/computer/atmoscontrol
	name = "atmosphere control console"
	desc = "A console used to monitor and control the facility's atmospheric systems."
	icon_screen = "atmos"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmoscontrol

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControl", name)
		ui.open()

/obj/machinery/computer/atmoscontrol/ui_data(mob/user)
	var/list/data = list()
	data["area"] = get_area_name(src, TRUE)
	var/datum/gas_mixture/environment = loc?.return_air()
	if(environment)
		data["pressure"] = environment.returnPressure()
		data["temperature"] = environment.temperature
		data["temperature_c"] = environment.temperature - T0C
	return data

/obj/machinery/computer/cryopod
	name = "cryogenic storage console"
	desc = "A console used to monitor and manage cryogenic storage."
	icon_screen = "cryo"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cryopodcontrol

/obj/machinery/computer/drone_control
	name = "drone control console"
	desc = "A console used to control maintenance drones."
	icon_screen = "ai-fixer"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/drone_control

/obj/machinery/computer/mining
	name = "mining shuttle console"
	desc = "A console used to call and control the mining shuttle."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/mining_shuttle

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "A console used to monitor surgical operations."
	icon_screen = "med"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating

/obj/machinery/computer/rdconsole
	name = "Foundation R&D Console"
	desc = "A research terminal connected to the Foundation's SCP research database."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/rdconsole
	var/selected_tab = "overview"
	var/selected_project = null

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationRDConsole", name)
		ui.open()

/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()
	data["selected_tab"] = selected_tab
	data["selected_project"] = selected_project
	if(!SSscp_research || !SSscp_research.manager)
		data["system_online"] = FALSE
		return data
	data["system_online"] = TRUE
	var/datum/scp_research_manager/M = SSscp_research.manager
	data["total_points"] = M.total_research_points
	data["breakthroughs"] = M.research_breakthroughs
	data["containment_improvements"] = M.containment_improvements
	data["classification_updates"] = M.classification_updates
	var/list/projects = list()
	for(var/project_id in M.research_projects)
		var/datum/research_data/project = M.research_projects[project_id]
		projects += list(list(
			"id" = project.project_id,
			"scp" = project.scp_designation,
			"type" = project.research_type,
			"level" = project.research_level,
			"max_level" = project.max_research_level,
			"points" = project.research_points,
			"cost" = project.research_cost,
			"status" = project.status,
		))
	data["projects"] = projects
	if(user?.ckey)
		var/datum/researcher_data/researcher = M.get_researcher_profile(user.ckey)
		if(researcher)
			data["researcher_rank"] = researcher.research_rank
			data["researcher_points"] = researcher.research_points
			data["researcher_projects"] = researcher.total_projects
	return data

/obj/machinery/computer/rdconsole/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("switch_tab")
			selected_tab = params["tab"]
			. = TRUE
		if("select_project")
			selected_project = params["project_id"]
			. = TRUE
		if("start_project")
			if(SSscp_research?.manager && params["scp_id"])
				SSscp_research.manager.start_research_project(params["scp_id"], params["type"] || "behavioral", usr?.ckey)
				. = TRUE

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	desc = "The primary Foundation research terminal with full database access."

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	desc = "A research terminal specialized for robotic and prosthetic research."

/obj/machinery/computer/rdservercontrol
	name = "R&D Server Control"
	desc = "A console used to manage the R&D server network."
	icon_screen = "comm_log"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/rdservercontrol

/obj/machinery/computer/shuttle_control
	name = "shuttle control console"
	desc = "A console used to control shuttle movement."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/shuttle

/obj/machinery/computer/shuttle_control/emergency
	name = "emergency shuttle console"
	circuit = /obj/item/circuitboard/computer/emergency_shuttle

/obj/machinery/computer/shuttle_control/mining
	name = "mining shuttle console"
	circuit = /obj/item/circuitboard/computer/mining_shuttle

/obj/machinery/computer/station_alert
	name = "facility alert console"
	desc = "A console showing facility-wide alerts and alarms."
	icon_screen = "alert"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/stationalert

/obj/machinery/computer/station_alert/all
	name = "facility alert console"

/obj/machinery/computer/upload
	name = "AI upload console"
	desc = "A console used to upload new laws to the facility AI."
	icon_screen = "command"
	icon_keyboard = "syndie_key"
	circuit = /obj/item/circuitboard/computer/aifixer

/obj/machinery/computer/upload/robot
	name = "robot upload console"
	desc = "A console used to upload new laws to cyborgs."

// ================================================================
// CIRCUITBOARDS
// ================================================================

/obj/item/circuitboard/computer/atmoscontrol
	name = "Atmosphere Control (Computer Board)"
	build_path = /obj/machinery/computer/atmoscontrol

/obj/item/circuitboard/computer/cryopodcontrol
	name = "Cryogenic Storage (Computer Board)"
	build_path = /obj/machinery/computer/cryopod

/obj/item/circuitboard/computer/drone_control
	name = "Drone Control (Computer Board)"
	build_path = /obj/machinery/computer/drone_control

/obj/item/circuitboard/computer/mining_shuttle
	name = "Mining Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/mining

/obj/item/circuitboard/computer/operating
	name = "Operating Computer (Computer Board)"
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/rdconsole
	name = "R&D Console (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole

/obj/item/circuitboard/computer/rdservercontrol
	name = "R&D Server Control (Computer Board)"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/computer/shuttle
	name = "Shuttle Control (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_control

/obj/item/circuitboard/computer/emergency_shuttle
	name = "Emergency Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_control/emergency

/obj/item/circuitboard/computer/stationalert
	name = "Station Alert (Computer Board)"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/aifixer
	name = "AI Upload (Computer Board)"
	build_path = /obj/machinery/computer/upload

// ================================================================
// SMES PRESETS - with charge/capacity values
// ================================================================

/obj/machinery/power/smes/buildable
	name = "Buildable SMES"

/obj/machinery/power/smes/buildable/max_cap_in_out
	charge = 5e6
	capacity = 5e6
	input_level = 200000
	output_level = 200000
	input_attempt = TRUE
	output_attempt = TRUE

/obj/machinery/power/smes/buildable/preset/ds90/substation_full
	name = "Substation SMES"
	charge = 90e6
	capacity = 90e6
	input_level = 200000
	output_level = 200000
	input_attempt = TRUE
	output_attempt = TRUE

/obj/machinery/power/smes/buildable/preset/on_full
	name = "Full Output SMES"
	charge = 200e6
	capacity = 200e6
	input_level = 200000
	output_level = 200000
	input_attempt = TRUE
	output_attempt = TRUE

// ================================================================
// SIGN STUBS - only those with unique desc (containment/safety)
// ================================================================

/obj/structure/sign/scp
	name = "SCP sign"

/obj/structure/sign/scp/euclid_scp
	name = "Euclid containment sign"
	desc = "SCP Containment - Euclid class."

/obj/structure/sign/scp/keter_scp
	name = "Keter containment sign"
	desc = "SCP Containment - Keter class."

/obj/structure/sign/scp/safe_scp
	name = "Safe containment sign"
	desc = "SCP Containment - Safe class."

/obj/structure/sign/dontlook
	name = "cognitohazard sign"
	desc = "WARNING: DO NOT LOOK DIRECTLY AT ITEM."

/obj/structure/sign/memnetic
	name = "memetic hazard sign"
	desc = "WARNING: Memetic hazard. Wear appropriate protection."

/obj/structure/sign/SecureArealv4mtf
	name = "MTF secure area sign"
	desc = "Secure Area - Level 4 MTF Clearance Required."

/obj/structure/sign/SecureArealv5mtf
	name = "MTF secure area sign"
	desc = "Secure Area - Level 5 MTF Clearance Required."

/obj/structure/sign/warning/lethal_turrets
	name = "lethal turrets sign"
	desc = "WARNING: Lethal automated defenses active."

/obj/structure/sign/warning/termination
	name = "termination sign"
	desc = "WARNING: Termination authorization in effect."

/obj/structure/sign/amnesiac
	name = "amnestics sign"
	desc = "Warning: Amnestic dispensing area."