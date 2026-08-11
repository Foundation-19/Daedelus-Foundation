#define BREACH_PHASE_SETUP 0
#define BREACH_PHASE_PREGAME 1
#define BREACH_PHASE_ACTIVE 2
#define BREACH_PHASE_RESPONSE 3
#define BREACH_PHASE_RECONTAINMENT 4
#define BREACH_PHASE_DEBRIEF 5

#define SCP_ROUND_MIN_BREACH_TIME 5 MINUTES
#define SCP_ROUND_MAX_BREACH_TIME 20 MINUTES
#define SCP_ROUND_MTF_RESPONSE_DELAY 3 MINUTES
#define SCP_ROUND_DEBRIEF_TIME 2 MINUTES

/datum/game_mode/scp_containment_breach
	name = "Containment Breach"
	weight = GAMEMODE_WEIGHT_COMMON
	votable = TRUE

	min_pop = 1
	required_enemies = 0
	max_pop = INFINITY

	var/breach_phase = BREACH_PHASE_SETUP
	var/breach_timer_id
	var/breach_trigger_time
	var/list/breached_scps = list()
	var/list/contained_scps = list()
	var/list/mtf_deployed = list()
	var/mtf_called = FALSE
	var/evacuation_called = FALSE
	var/round_start_time
	var/breach_announced = FALSE
	var/cascade_triggered = FALSE
	var/civilian_casualties = 0
	var/total_civilian_count = 0
	var/facility_integrity = 100

/datum/game_mode/scp_containment_breach/pre_setup()
	..()
	return TRUE

/datum/game_mode/scp_containment_breach/post_setup(report)
	. = ..()
	round_start_time = world.time
	breach_phase = BREACH_PHASE_PREGAME
	SSticker.setup_foundation_identity()

	var/breach_delay = rand(SCP_ROUND_MIN_BREACH_TIME, SCP_ROUND_MAX_BREACH_TIME)
	breach_timer_id = addtimer(CALLBACK(src, .proc/trigger_breach), breach_delay, TIMER_STOPPABLE)

	priority_announce("Welcome to Site-53. All personnel report to your assigned stations. Standard containment protocols in effect.", "SITE-53 COMMAND", sound_type = ANNOUNCER_DEFAULT)

/datum/game_mode/scp_containment_breach/process(delta_time)
	if(breach_phase == BREACH_PHASE_ACTIVE || breach_phase == BREACH_PHASE_RESPONSE)
		check_breach_status()
		check_cascade_conditions()

/datum/game_mode/scp_containment_breach/proc/trigger_breach()
	breach_phase = BREACH_PHASE_ACTIVE
	breach_trigger_time = world.time

	var/list/breachable = list("SCP-173", "SCP-049", "SCP-096", "SCP-106", "SCP-682", "SCP-939", "SCP-457", "SCP-035", "SCP-079")
	var/list/valid = list()
	for(var/scp_id in breachable)
		if(SSscp_persistence?.manager?.scp_instances?[scp_id])
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(instance.containment_status != "breached")
				valid += scp_id
	if(!length(valid))
		valid = breachable

	var/num_to_breach = 1
	if(length(SSticker.ready_players) >= 20)
		num_to_breach = 2
	if(length(SSticker.ready_players) >= 40)
		num_to_breach = 3

	for(var/i in 1 to min(num_to_breach, length(valid)))
		var/scp_id = pick_n_take(valid)
		var/atom/scp_atom = find_scp_mob(scp_id)
		hook_scp_breach(scp_id, scp_atom)
		breached_scps += scp_id

	breach_announced = TRUE
	priority_announce("ALERT: CONTAINMENT FAILURE DETECTED. [english_list(breached_scps)] STATUS: BREACHED. ALL SECURITY PERSONNEL RESPOND IMMEDIATELY.", "CONTAINMENT ALERT", sound_type = ANNOUNCER_ALERT)

	addtimer(CALLBACK(src, .proc/mtf_response_check), SCP_ROUND_MTF_RESPONSE_DELAY)

/datum/game_mode/scp_containment_breach/proc/mtf_response_check()
	if(breach_phase != BREACH_PHASE_ACTIVE)
		return
	breach_phase = BREACH_PHASE_RESPONSE
	if(!mtf_called)
		mtf_called = TRUE
		priority_announce("ATTENTION: Mobile Task Force deployment authorized. MTF units en route to Site-53. Estimated arrival: 5 minutes.", "MTF DISPATCH", sound_type = ANNOUNCER_ALERT)
		addtimer(CALLBACK(src, .proc/deploy_mtf), 5 MINUTES)

/datum/game_mode/scp_containment_breach/proc/deploy_mtf()
	if(breach_phase < BREACH_PHASE_ACTIVE)
		return
	var/spawned = 0
	var/max_mtf = clamp(round(length(SSticker.ready_players) / 10), 2, 8)
	var/list/spawn_turfs = list()
	for(var/turf/T in get_area_turfs(/area/scp/surface/gate_a))
		if(!T.density)
			spawn_turfs += T
	if(!length(spawn_turfs))
		for(var/turf/T in get_area_turfs(/area/scp/surface))
			if(!T.density)
				spawn_turfs += T
	if(!length(spawn_turfs))
		return

	var/list/mtf_names = list("Nine-Tailed Fox", "Epsilon-11", "Nu-7", "Eta-10")
	var/squad_name = pick(mtf_names)

	for(var/i in 1 to max_mtf)
		if(!length(spawn_turfs))
			break
		var/turf/T = pick(spawn_turfs)
		var/mob/living/carbon/human/H = new(T)
		H.equipOutfit(/datum/outfit/mtf_operative)
		var/datum/mind/M = new /datum/mind("")
		M.transfer_to(H)
		var/datum/antagonist/scp_mtf/mtf_antag = new()
		mtf_antag.squad_name = squad_name
		M.add_antag_datum(mtf_antag)
		mtf_deployed += H
		spawned++

	if(spawned)
		priority_announce("MTF [squad_name] has arrived on site. [spawned] operatives deployed. Recontainment operations commencing.", "MTF DEPLOYMENT", sound_type = ANNOUNCER_DEFAULT)

/datum/game_mode/scp_containment_breach/proc/check_breach_status()
	var/still_breached = 0
	for(var/scp_id in breached_scps)
		if(SSscp_persistence?.manager?.scp_instances?[scp_id])
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(instance.containment_status == "breached")
				still_breached++
			else if(instance.containment_status == "contained" || instance.containment_status == "neutralized")
				if(!(scp_id in contained_scps))
					contained_scps += scp_id
					priority_announce("NOTICE: [scp_id] has been [instance.containment_status]. Recontainment progress: [length(contained_scps)]/[length(breached_scps)]", "RECONTAINMENT UPDATE", sound_type = ANNOUNCER_DEFAULT)

	if(still_breached == 0 && length(breached_scps) > 0)
		begin_debrief()

/datum/game_mode/scp_containment_breach/proc/check_cascade_conditions()
	if(cascade_triggered)
		return
	if(breach_phase < BREACH_PHASE_ACTIVE)
		return
	var/time_since_breach = world.time - breach_trigger_time
	if(time_since_breach > 30 MINUTES && length(breached_scps) - length(contained_scps) >= 3)
		trigger_cascade()
	else if(time_since_breach > 45 MINUTES && length(breached_scps) - length(contained_scps) >= 2)
		trigger_cascade()

/datum/game_mode/scp_containment_breach/proc/trigger_cascade()
	cascade_triggered = TRUE
	priority_announce("CRITICAL: UNCONTROLLED CASCADE EVENT. MULTIPLE SCP BREACHES. FACILITY INTEGRITY COMPROMISED. INITIATE EMERGENCY EVACUATION PROTOCOLS.", "CASCADE ALERT", sound_type = ANNOUNCER_ALERT)
	trigger_facility_lockdown("Uncontrolled cascade event")

/datum/game_mode/scp_containment_breach/proc/begin_debrief()
	breach_phase = BREACH_PHASE_DEBRIEF
	priority_announce("ATTENTION: All SCP entities have been recontained or neutralized. Facility returning to standard operations. Debrief in [DisplayTimeText(SCP_ROUND_DEBRIEF_TIME)].", "BREACH RESOLVED", sound_type = ANNOUNCER_DEFAULT)
	addtimer(CALLBACK(src, .proc/end_round), SCP_ROUND_DEBRIEF_TIME)

/datum/game_mode/scp_containment_breach/proc/end_round()
	SSticker.set_force_ending(TRUE)

/datum/game_mode/scp_containment_breach/check_finished()
	..()
	if(!SSticker.setup_done)
		return FALSE
	if(GLOB.station_was_nuked)
		return TRUE
	if(breach_phase == BREACH_PHASE_DEBRIEF)
		return TRUE
	if(breach_phase >= BREACH_PHASE_ACTIVE)
		var/time_elapsed = world.time - round_start_time
		if(time_elapsed > 90 MINUTES)
			return TRUE
	return FALSE

/datum/game_mode/scp_containment_breach/set_round_result()
	if(length(contained_scps) >= length(breached_scps) && length(breached_scps) > 0)
		SSticker.mode_result = "Foundation Victory - All SCPs Recontained"
	else if(cascade_triggered)
		SSticker.mode_result = "Facility Lost - Cascade Event"
	else if(length(contained_scps) > 0)
		SSticker.mode_result = "Partial Victory - Some SCPs Recontained"
	else
		SSticker.mode_result = "Containment Failure"

/datum/game_mode/scp_containment_breach/generate_station_goal_report()
	. = "<hr><b>SCP Containment Report:</b><BR>"
	. += "Breached SCPs: [english_list(breached_scps)]<BR>"
	. += "Recontained: [english_list(contained_scps)]<BR>"
	. += "MTF Deployed: [length(mtf_deployed)] operatives<BR>"
	. += "Cascade Event: [cascade_triggered ? "YES" : "NO"]<BR>"
	. += "Facility Integrity: [facility_integrity]%<BR>"
	. += "Round Duration: [DisplayTimeText(world.time - round_start_time)]<BR>"
	return .

/proc/find_scp_mob(scp_id)
	for(var/atom/A in GLOB.SCP_list)
		var/datum/scp/scp_datum = A.SCP
		if(scp_datum && scp_datum.get_scp_id() == scp_id)
			return A
	return null

/datum/outfit/mtf_operative
	name = "MTF Operative"
	uniform = /obj/item/clothing/under/rank/security/guard
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/headset_sec/alt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full
	l_pocket = /obj/item/flashlight/seclite
	r_pocket = /obj/item/knife/combat
	id = /obj/item/card/id/advanced/gold

/datum/antagonist/scp_mtf
	name = "MTF Operative"
	roundend_category = "Mobile Task Force"
	antagpanel_category = "MTF"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoSCP"
	var/squad_name = "Nine-Tailed Fox"

/datum/antagonist/scp_mtf/on_gain()
	. = ..()
	if(owner.current)
		to_chat(owner.current, span_notice("<B>You are a Mobile Task Force Operative — [squad_name]!</B>"))
		to_chat(owner.current, span_notice("Mission: Recontain all breached SCP entities. Protect Foundation personnel. Neutralize hostile threats."))
	var/datum/objective/mtf_recontain/obj = new()
	obj.owner = owner
	objectives += obj
	var/datum/objective/scp_survive/survive = new()
	survive.owner = owner
	objectives += survive

/datum/objective/mtf_recontain
	name = "recontain SCPs"
	explanation_text = "Recontain or neutralize all breached SCP entities."

/datum/objective/mtf_recontain/check_completion()
	for(var/scp_id in SSticker.mode.antagonists)
		var/datum/mind/M = SSticker.mode.antagonists[scp_id]
		if(M && M.current && M.current.stat != DEAD)
			var/area/A = get_area(M.current)
			if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
				continue
			return FALSE
	return TRUE
