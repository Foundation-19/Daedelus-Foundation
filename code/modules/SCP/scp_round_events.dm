/datum/round_event_control/scp_containment_breach
	name = "SCP Containment Breach"
	typepath = /datum/round_event/scp_containment_breach
	max_occurrences = 5
	weight = 20
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_containment_breach
	var/breached_scp

/datum/round_event/scp_containment_breach/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 50

/datum/round_event/scp_containment_breach/announce(fake)
	priority_announce("ALERT: Containment failure detected in secure storage. All security personnel respond immediately.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_containment_breach/start()
	var/list/breachable_scps = list("SCP-173", "SCP-049", "SCP-096", "SCP-106", "SCP-939", "SCP-457", "SCP-035", "SCP-682")
	var/list/valid_scps = list()
	for(var/scp_id in breachable_scps)
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(instance && instance.containment_status != "breached")
				valid_scps += scp_id
	if(!length(valid_scps))
		valid_scps = breachable_scps
	breached_scp = pick(valid_scps)
	var/atom/scp_atom = null
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[breached_scp]
		if(instance)
			for(var/mob/living/scp/S in GLOB.mob_list)
				if(!QDELETED(S) && S.persistence_id == breached_scp)
					scp_atom = S
					break
	hook_scp_breach(breached_scp, scp_atom)

/datum/round_event/scp_containment_breach/tick()
	if(activeFor == 30)
		priority_announce("ALERT: [breached_scp] containment status: BREACHED. Enact recontainment protocol immediately.", null, null, ANNOUNCER_ALERT)

/datum/round_event_control/scp_power_fluctuation
	name = "SCP Facility Power Fluctuation"
	typepath = /datum/round_event/scp_power_fluctuation
	max_occurrences = 4
	weight = 20
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_power_fluctuation

/datum/round_event/scp_power_fluctuation/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 30

/datum/round_event/scp_power_fluctuation/announce(fake)
	priority_announce("WARNING: Power grid instability detected in containment wing. Backup generators standing by.", null, null, ANNOUNCER_POWEROFF)

/datum/round_event/scp_power_fluctuation/start()
	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		if(prob(30))
			A.energy_fail(rand(30, 120))
	if(SSscp_persistence && SSscp_persistence.manager && length(SSscp_persistence.manager.scp_instances) > 0)
		var/list/breached = list()
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(instance && instance.containment_status == "breached")
				breached += scp_id
		if(length(breached) && prob(25))
			var/breached_id = pick(breached)
			var/atom/scp_atom = null
			if(SSscp_persistence && SSscp_persistence.manager)
				var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[breached_id]
				if(instance)
					for(var/mob/living/scp/S in GLOB.mob_list)
						if(!QDELETED(S) && S.persistence_id == breached_id)
							scp_atom = S
							break
			hook_scp_breach(breached_id, scp_atom)

/datum/round_event_control/scp_memetic_hazard
	name = "SCP Memetic Hazard"
	typepath = /datum/round_event/scp_memetic_hazard
	max_occurrences = 2
	weight = 10
	earliest_start = 25 MINUTES
	min_players = 15

/datum/round_event/scp_memetic_hazard

/datum/round_event/scp_memetic_hazard/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 20

/datum/round_event/scp_memetic_hazard/announce(fake)
	priority_announce("WARNING: Memetic hazard detected in facility. Avoid unauthorized visual contact with anomalous objects.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_memetic_hazard/start()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		var/zone = get_containment_zone(A)
		if(zone == "lcz" || zone == "hcz")
			if(H.sanity && prob(40))
				H.sanity.adjust_sanity(-15, "memetic_hazard_event")
				to_chat(H, "<span class='warning'>Your mind feels violated by an unseen force!</span>")

/datum/round_event_control/scp_cascade_warning
	name = "SCP Cascade Warning"
	typepath = /datum/round_event/scp_cascade_warning
	max_occurrences = 1
	weight = 5
	earliest_start = 40 MINUTES
	min_players = 20

/datum/round_event/scp_cascade_warning

/datum/round_event/scp_cascade_warning/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 40

/datum/round_event/scp_cascade_warning/announce(fake)
	priority_announce("CRITICAL: Multiple SCP containment anomalies detected. Facility-wide cascade event possible. All personnel brace for impact.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_cascade_warning/start()
	var/list/breachable = list("SCP-173", "SCP-106", "SCP-049", "SCP-682", "SCP-096")
	var/list/valid = list()
	for(var/scp_id in breachable)
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(!instance || instance.containment_status != "breached")
				valid += scp_id
	if(!length(valid))
		valid = breachable
	var/first_scp = pick(valid)
	var/atom/first_atom = null
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/fi = SSscp_persistence.manager.scp_instances[first_scp]
		if(fi)
			for(var/mob/living/scp/S in GLOB.mob_list)
				if(!QDELETED(S) && S.persistence_id == first_scp)
					first_atom = S
					break
	hook_scp_breach(first_scp, first_atom)
	var/list/remaining = valid - list(first_scp)
	if(length(remaining))
		var/second_scp = pick(remaining)
		var/atom/second_atom = null
		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/si = SSscp_persistence.manager.scp_instances[second_scp]
			if(si)
				for(var/mob/living/scp/S in GLOB.mob_list)
					if(!QDELETED(S) && S.persistence_id == second_scp)
						second_atom = S
						break
		addtimer(CALLBACK(GLOBAL_PROC, /proc/hook_scp_breach, second_scp, second_atom), 30 SECONDS)
	else
		addtimer(CALLBACK(GLOBAL_PROC, /proc/hook_scp_breach, first_scp, first_atom), 30 SECONDS)
	addtimer(CALLBACK(src, .proc/escalate_cascade), 60 SECONDS)

/datum/round_event/scp_cascade_warning/proc/escalate_cascade()
	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		if(prob(50))
			A.energy_fail(rand(60, 180))
	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/dept_id in SSfoundation_politics.manager.departments)
			var/datum/department/dept = SSfoundation_politics.manager.departments[dept_id]
			if(dept)
				dept.department_budget = max(0, dept.department_budget - 5000)
	if(SSstorytelling && SSstorytelling.manager)
		SSstorytelling.manager.log_timeline("breach", "CASCADE: Power systems failing, budgets depleted by emergency expenditures!", null)

/datum/round_event_control/scp_research_breakthrough
	name = "SCP Research Breakthrough"
	typepath = /datum/round_event/scp_research_breakthrough
	max_occurrences = 3
	weight = 15
	earliest_start = 10 MINUTES
	min_players = 5

/datum/round_event/scp_research_breakthrough

/datum/round_event/scp_research_breakthrough/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 10

/datum/round_event/scp_research_breakthrough/announce(fake)
	priority_announce("NOTICE: Anomalous research data spike detected. Research personnel review new findings.", null, null, ANNOUNCER_DEFAULT)

/datum/round_event/scp_research_breakthrough/start()
	if(SSscp_research && SSscp_research.manager)
		var/bonus_points = rand(100, 500)
		adjust_global_research_points(bonus_points, "round_event_breakthrough")
		if(SSscp_research.manager.research_breakthroughs < 99)
			SSscp_research.manager.research_breakthroughs++
		var/list/researchers_notified = list()
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat == DEAD || !H.client)
				continue
			if(H.job && (H.job == JOB_RESEARCH_DIRECTOR || H.job == JOB_SENIOR_RESEARCHER || H.job == JOB_RESEARCHER || H.job == JOB_JUNIOR_RESEARCHER))
				to_chat(H, "<span class='notice'>Research breakthrough detected! +[bonus_points] research points allocated to your department.</span>")
				researchers_notified += H
				if(SSpersistent_progression && H.ckey)
					SSpersistent_progression.award_experience(H.ckey, "scp_research_contribution", 50, "Research Breakthrough Event")

/datum/round_event_control/scp_security_alert
	name = "SCP Security Alert"
	typepath = /datum/round_event/scp_security_alert
	max_occurrences = 6
	weight = 25
	earliest_start = 5 MINUTES
	min_players = 8

/datum/round_event/scp_security_alert

/datum/round_event/scp_security_alert/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 25

/datum/round_event/scp_security_alert/announce(fake)
	var/alert_type = pick("unauthorized access", "intrusion detection", "suspicious activity", "contraband detection")
	priority_announce("SECURITY ALERT: [alert_type] reported in containment wing. Security personnel investigate.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_security_alert/start()
	var/list/contraband_types = list("improvised_tool", "contraband_note", "hidden_keycard")
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card && (ACCESS_SECURITY in id_card.access))
			to_chat(H, "<span class='danger'>Your security headset crackles: Priority alert in effect. Report to containment wing.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(-5, "security_alert_stress")
		if(findtext(H.job, "D-Class") && SSdclass && SSdclass.manager)
			var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
			if(player && prob(30))
				player.add_contraband(pick(contraband_types), 1)

/datum/round_event_control/scp_dclass_uprising
	name = "D-Class Incident"
	typepath = /datum/round_event/scp_dclass_uprising
	max_occurrences = 2
	weight = 10
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_dclass_uprising

/datum/round_event/scp_dclass_uprising/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 30

/datum/round_event/scp_dclass_uprising/announce(fake)
	priority_announce("ALERT: D-Class disturbance reported in cell block. Security personnel respond to D-Class areas.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_dclass_uprising/start()
	var/dclass_count = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/dclass))
			dclass_count++
			to_chat(H, "<span class='warning'>The air of tension in the cell block is palpable. Something is about to happen.</span>")
			if(SSdclass && SSdclass.manager)
				var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
				if(player)
					player.adjust_trust(5, "dclass_incident")
					player.add_contraband("improvised_tool", 1)
	if(dclass_count >= 3 && SSdclass_riot && !SSdclass_riot.current_riot)
		var/datum/dclass_riot/riot = new()
		SSdclass_riot.current_riot = riot
		riot.start_riot()
		SSdclass_riot.flags &= ~SS_NO_FIRE

/datum/round_event_control/scp_ci_raid
	name = "Chaos Insurgency Raid"
	typepath = /datum/round_event/scp_ci_raid
	max_occurrences = 2
	weight = 15
	earliest_start = 20 MINUTES
	min_players = 15

/datum/round_event/scp_ci_raid
	var/list/spawned_mobs = list()

/datum/round_event/scp_ci_raid/setup()
	startWhen = 1
	announceWhen = 3
	endWhen = 600

/datum/round_event/scp_ci_raid/announce(fake)
	priority_announce("SECURITY BREACH: Unidentified hostiles have breached the facility perimeter. All security personnel engage hostile forces.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_ci_raid/start()
	var/list/entry_points = list()
	for(var/turf/T in GLOB.station_turfs)
		var/area/A = get_area(T)
		if(istype(A, /area/scp/surface) || istype(A, /area/scp/lcz))
			entry_points += T
	if(!length(entry_points))
		entry_points = GLOB.station_turfs.Copy()
	if(!length(entry_points))
		return

	var/raider_count = min(4, max(2, round(length(GLOB.clients) / 10)))
	var/list/raider_names = list("Marcus Webb", "Elena Vasquez", "Dmitri Volkov", "Sarah Chen", "James Okafor", "Anya Petrov", "Carlos Mendez", "Yuki Tanaka", "Ibrahim Hassan", "Katrin Mueller", "Rafael Ortiz", "Nadia Kozlov")

	for(var/i in 1 to raider_count)
		var/turf/spawn_loc = pick(entry_points)
		var/mob/living/carbon/human/raider = new(spawn_loc)
		raider.set_species(/datum/species/human)
		raider.real_name = pick(raider_names)
		grant_raider_antag(raider)
		spawned_mobs += raider
		var/list/candidates = poll_candidates_for_mob("Do you want to play as a Chaos Insurgency Operative?", ROLE_TRAITOR, null, 10 SECONDS, raider)
		if(length(candidates))
			var/mob/dead/observer/picked = candidates[1]
			raider.key = picked.key
			to_chat(raider, span_danger("You are a member of the Chaos Insurgency. Infiltrate the facility and complete your mission."))

/datum/round_event/scp_ci_raid/proc/grant_raider_antag(mob/living/carbon/human/raider)
	if(!raider || !raider.mind)
		return
	var/datum/antagonist/chaos_insurgency/ci_antag = new()
	raider.mind.add_antag_datum(ci_antag)
	ci_antag.equip_ci_operative()
	to_chat(raider, span_danger("You are a member of the Chaos Insurgency. Infiltrate the facility and complete your mission."))

/datum/round_event/scp_ci_raid/tick()
	if(activeFor == 50)
		priority_announce("INTEL UPDATE: Hostile operatives detected near containment areas. Security status: ORANGE.", null, null, ANNOUNCER_DEFAULT)

/datum/round_event/scp_ci_raid/end()
	var/survivors = 0
	var/primary_completed = FALSE
	for(var/mob/living/M in spawned_mobs)
		if(QDELETED(M))
			continue
		if(M.stat != DEAD)
			survivors++
		if(M.mind)
			var/datum/antagonist/chaos_insurgency/ci = M.mind.has_antag_datum(/datum/antagonist/chaos_insurgency)
			if(ci && ci.objectives && length(ci.objectives))
				var/datum/objective/O = ci.objectives[1]
				if(O.check_completion() == TRUE)
					primary_completed = TRUE

	if(primary_completed && survivors > 0)
		priority_announce("CRITICAL FAILURE: Chaos Insurgency operatives completed primary objective. Containment breach confirmed.", null, null, ANNOUNCER_ALERT)
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat != DEAD && H.client && (ACCESS_SECURITY in H.get_idcard(TRUE)?.access))
				to_chat(H, span_userdanger("Mission failed. Chaos Insurgency won."))
		if(SSfoundation_politics && SSfoundation_politics.manager)
			SSfoundation_politics.manager.spend_budget("security", 10000, "CI Raid Damages")
			SSfoundation_politics.manager.spend_budget("administrative", 5000, "CI Raid Response")
	else if(survivors == 0)
		priority_announce("THREAT NEUTRALIZED: All hostile operatives eliminated. Security forces triumphant.", null, null, ANNOUNCER_DEFAULT)
	else
		priority_announce("ALERT: Hostile operatives withdrew. Containment maintained.", null, null, ANNOUNCER_DEFAULT)
	spawned_mobs.Cut()

/datum/round_event_control/scp_pathogen_outbreak
	name = "Pathogen Outbreak"
	typepath = /datum/round_event/scp_pathogen_outbreak
	max_occurrences = 2
	weight = 10
	earliest_start = 20 MINUTES
	min_players = 10

/datum/round_event/scp_pathogen_outbreak
	var/pathogen_type
	var/infection_count = 0

/datum/round_event/scp_pathogen_outbreak/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 40

/datum/round_event/scp_pathogen_outbreak/announce(fake)
	priority_announce("MEDICAL ALERT: Pathogen contamination detected in the facility. Medical personnel enact containment protocols immediately.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_pathogen_outbreak/start()
	var/list/candidate_pathogens = list(
		/datum/pathogen/foundation/mrsa,
		/datum/pathogen/foundation/malaria,
		/datum/pathogen/foundation/tuberculosis,
	)
	if(SSfoundation_pathogens && length(SSfoundation_pathogens.pathogen_research_data) > 0)
		var/list/available = list()
		for(var/pkey in SSfoundation_pathogens.pathogen_research_data)
			var/list/pdata = SSfoundation_pathogens.pathogen_research_data[pkey]
			if(pdata["bsl"] == BSL_2 || pdata["bsl"] == BSL_3)
				if(pdata["research_stage"] < RESEARCH_STAGE_CURED)
					var/T = text2path(pkey)
					if(T)
						available += T
		if(length(available))
			candidate_pathogens = available
	pathogen_type = pick(candidate_pathogens)
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz) || istype(A, /area/scp/dclass))
			targets += H
	if(!length(targets))
		return
	var/infect_count = min(length(targets), rand(2, 4))
	for(var/i in 1 to infect_count)
		var/mob/living/carbon/human/H = pick(targets)
		targets -= H
		var/datum/pathogen/foundation/F = new pathogen_type()
		F.force_infect(H, FALSE)
		infection_count++
		to_chat(H, span_warning("You feel a sudden wave of illness wash over you..."))

/datum/round_event/scp_pathogen_outbreak/tick()
	if(activeFor == 20)
		if(infection_count > 0)
			priority_announce("MEDICAL UPDATE: Pathogen outbreak confirmed. [infection_count] case(s) identified. Contagion tracking active.", null, null, ANNOUNCER_DEFAULT)
			if(GLOB.contagion_tracker)
				for(var/list/contagion in GLOB.contagion_tracker.active_contagions)
					contagion["spread_count"] = 0

/datum/round_event_control/scp_anomalous_pathogen_release
	name = "Anomalous Pathogen Release"
	typepath = /datum/round_event/scp_anomalous_pathogen_release
	max_occurrences = 1
	weight = 5
	earliest_start = 35 MINUTES
	min_players = 15

/datum/round_event/scp_anomalous_pathogen_release
	var/anomalous_type
	var/infection_count = 0

/datum/round_event/scp_anomalous_pathogen_release/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 60

/datum/round_event/scp_anomalous_pathogen_release/announce(fake)
	priority_announce("CRITICAL MEDICAL ALERT: Anomalous pathogen containment failure! BSL-4 protocols enacted immediately. All personnel avoid medical wing.", null, null, ANNOUNCER_ALERT)

/datum/round_event/scp_anomalous_pathogen_release/start()
	var/list/anomalous_candidates = list(
		/datum/pathogen/foundation/scp008,
	)
	for(var/T in subtypesof(/datum/pathogen/foundation))
		var/datum/pathogen/foundation/prototype = new T()
		if(prototype.is_anomalous)
			anomalous_candidates += T
		qdel(prototype)
	if(!length(anomalous_candidates))
		return
	anomalous_type = pick(anomalous_candidates)
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		if(H.job && (H.job == JOB_MEDICAL_DOCTOR || H.job == JOB_VIROLOGIST || H.job == JOB_SURGEON || H.job == JOB_PARAMEDIC || H.job == JOB_JUNIOR_RESEARCHER || H.job == JOB_RESEARCHER))
			targets += H
	if(!length(targets))
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(QDELETED(H))
				continue
			if(H.stat == DEAD || !H.client)
				continue
			targets += H
	if(!length(targets))
		return
	var/infect_count = min(length(targets), rand(1, 2))
	for(var/i in 1 to infect_count)
		var/mob/living/carbon/human/H = pick(targets)
		targets -= H
		var/datum/pathogen/foundation/F = new anomalous_type()
		F.force_infect(H, FALSE)
		infection_count++
		to_chat(H, span_userdanger("Something is very wrong. Your body begins to change..."))
	if(SSfoundation_pathogens)
		SSfoundation_pathogens.advance_research("[anomalous_type]", RESEARCH_STAGE_MAPPED - RESEARCH_STAGE_IDENTIFIED)

/datum/round_event/scp_anomalous_pathogen_release/tick()
	if(activeFor == 15)
		priority_announce("BIOSAFETY WARNING: Anomalous pathogen spreading. Decontamination showers active. BSL-4 quarantine in effect.", null, null, ANNOUNCER_ALERT)
		for(var/obj/machinery/decon_shower/D in INSTANCES_OF(/obj/machinery/decon_shower))
			if(!QDELETED(D) && !D.active && world.time >= D.cooldown)
				D.activate_decon()
	if(activeFor == 30)
		if(infection_count > 0 && GLOB.contagion_tracker)
			var/total_exposed = 0
			for(var/ckey in GLOB.contagion_tracker.exposed_personnel)
				total_exposed += length(GLOB.contagion_tracker.exposed_personnel[ckey])
			if(total_exposed > 3)
				priority_announce("CRITICAL: Anomalous contagion is spreading rapidly. Facility-wide quarantine considered.", null, null, ANNOUNCER_ALERT)
				for(var/mob/living/carbon/human/H in GLOB.player_list)
					if(QDELETED(H) || H.stat == DEAD || !H.client)
						continue
					var/area/A = get_area(H)
					if(istype(A, /area/scp/medical))
						if(GLOB.contagion_tracker)
							GLOB.contagion_tracker.declare_quarantine(A, "Anomalous Pathogen Release")

/datum/round_event_control/scp_biosafety_drill
	name = "Biosafety Drill"
	typepath = /datum/round_event/scp_biosafety_drill
	max_occurrences = 2
	weight = 15
	earliest_start = 10 MINUTES
	min_players = 5

/datum/round_event/scp_biosafety_drill

/datum/round_event/scp_biosafety_drill/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 20

/datum/round_event/scp_biosafety_drill/announce(fake)
	priority_announce("NOTICE: Biosafety drill commencing. All medical personnel verify decontamination equipment. This is a drill.", null, null, ANNOUNCER_DEFAULT)

/datum/round_event/scp_biosafety_drill/start()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.stat == DEAD || !H.client)
			continue
		if(H.job && (H.job == JOB_MEDICAL_DOCTOR || H.job == JOB_VIROLOGIST || H.job == JOB_MEDICAL_DIRECTOR))
			to_chat(H, span_notice("Biosafety drill in progress. Check your decontamination stations and BSL compliance."))
			if(SSpersistent_progression && H.ckey)
				SSpersistent_progression.award_experience(H.ckey, "medical_training", 25, "Biosafety Drill")
	for(var/obj/machinery/decon_shower/D in INSTANCES_OF(/obj/machinery/decon_shower))
		if(!QDELETED(D) && !D.active && prob(30))
			D.activate_decon()
