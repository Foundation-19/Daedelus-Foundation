/datum/round_event_control/scp_memetic_outbreak
	name = "SCP Memetic Outbreak"
	typepath = /datum/round_event/scp_memetic_outbreak
	max_occurrences = 2
	weight = 15
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_memetic_outbreak
	var/zone_affected

/datum/round_event/scp_memetic_outbreak/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 30
	var/list/zones = list("LCZ", "HCZ", "EZ")
	zone_affected = pick(zones)

/datum/round_event/scp_memetic_outbreak/announce(fake)
	priority_announce("WARNING: Memetic hazard detected in [zone_affected]. All personnel avoid visual contact with unverified screens and documents. Research personnel deploy countermeasures.", "MEMETIC HAZARD", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_memetic_outbreak/tick()
	if(activeFor % 5 != 0)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		var/zone = get_containment_zone(A)
		if(zone != lowertext(zone_affected))
			continue
		if(H.sanity && prob(25))
			H.sanity.adjust_sanity(-8, "memetic_outbreak_event")
			to_chat(H, span_warning("Your mind feels violated by an unseen memetic force!"))
			if(prob(10))
				H.hallucination += 15

/datum/round_event_control/scp_containment_degradation
	name = "SCP Containment Degradation"
	typepath = /datum/round_event/scp_containment_degradation
	max_occurrences = 3
	weight = 15
	earliest_start = 10 MINUTES
	min_players = 5

/datum/round_event/scp_containment_degradation

/datum/round_event/scp_containment_degradation/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 20

/datum/round_event/scp_containment_degradation/announce(fake)
	priority_announce("NOTICE: Containment integrity monitoring detected degradation in structural elements. Engineering personnel inspect containment walls.", "CONTAINMENT WARNING", sound_type = ANNOUNCER_DEFAULT)

/datum/round_event/scp_containment_degradation/start()
	var/damaged = 0
	for(var/turf/closed/wall/scp_containment/W in world)
		if(prob(20))
			W.damage_containment(rand(15, 40), "containment_degradation_event")
			damaged++
	if(damaged > 0)
		log_game("Containment Degradation event damaged [damaged] containment walls")

/datum/round_event_control/scp_cognito_hazard
	name = "SCP Cognito Hazard"
	typepath = /datum/round_event/scp_cognito_hazard
	max_occurrences = 2
	weight = 10
	earliest_start = 20 MINUTES
	min_players = 15

/datum/round_event/scp_cognito_hazard

/datum/round_event/scp_cognito_hazard/setup()
	startWhen = 1
	announceWhen = 5
	endWhen = 25

/datum/round_event/scp_cognito_hazard/announce(fake)
	priority_announce("ALERT: Cognitohazardous signal detected in facility communication systems. Disable visual displays if symptoms occur.", "COGNIHAZARD", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_cognito_hazard/tick()
	if(activeFor % 8 != 0)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/lcz) && !istype(A, /area/scp/hcz))
			continue
		if(prob(15))
			to_chat(H, span_warning("A sharp pain lances through your skull! Something is wrong with the air..."))
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
			if(prob(30))
				H.drowsyness += 10

/datum/round_event_control/scp_dclass_uprising
	name = "SCP D-Class Uprising"
	typepath = /datum/round_event/scp_dclass_uprising
	max_occurrences = 1
	weight = 10
	earliest_start = 25 MINUTES
	min_players = 15

/datum/round_event/scp_dclass_uprising

/datum/round_event/scp_dclass_uprising/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 30

/datum/round_event/scp_dclass_uprising/announce(fake)
	priority_announce("ALERT: Unauthorized D-Class assembly detected. Security personnel respond to D-Class areas. Elevate security protocols.", "D-CLASS ALERT", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_dclass_uprising/start()
	if(SSdclass?.manager)
		SSdclass.manager.current_security_level = max(SSdclass.manager.current_security_level, 3)

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		if(!findtext(H.job, "D-Class"))
			continue
		to_chat(H, span_warning("A call goes out among the D-Class — this is our chance! The guards are distracted!"))
		if(H.sanity)
			H.sanity.adjust_sanity(-15, "dclass_uprising")
		H.add_client_colour(/datum/client_colour/monochrome)

	addtimer(CALLBACK(GLOBAL_PROC, /proc/dclass_uprising_cleanup), 2 MINUTES)

/proc/dclass_uprising_cleanup()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		H.remove_client_colour(/datum/client_colour/monochrome)

/datum/round_event_control/scp_power_surge
	name = "SCP Power Surge"
	typepath = /datum/round_event/scp_power_surge
	max_occurrences = 3
	weight = 20
	earliest_start = 10 MINUTES
	min_players = 5

/datum/round_event/scp_power_surge

/datum/round_event/scp_power_surge/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 20

/datum/round_event/scp_power_surge/announce(fake)
	priority_announce("WARNING: Anomalous power surge detected in containment grid. Backup generators standing by.", "POWER SURGE", sound_type = ANNOUNCER_POWEROFF)

/datum/round_event/scp_power_surge/start()
	var/list/surge_apcs = list()
	for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
		var/area/A_area = get_area(A)
		if(istype(A_area, /area/scp/lcz) || istype(A_area, /area/scp/hcz))
			if(prob(40))
				A.energy_fail(rand(20, 80))
				surge_apcs += A
	if(length(surge_apcs) && prob(30))
		var/list/breached = list()
		if(SSscp_persistence?.manager)
			for(var/scp_id in SSscp_persistence.manager.scp_instances)
				var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
				if(instance.containment_status == "breached")
					breached += scp_id
		if(length(breached))
			var/scp_id = pick(breached)
			var/atom/scp_atom = find_scp_mob(scp_id)
			addtimer(CALLBACK(GLOBAL_PROC, /proc/hook_scp_breach, scp_id, scp_atom), 30 SECONDS)

/datum/round_event_control/scp_vent_contamination
	name = "SCP Vent Contamination"
	typepath = /datum/round_event/scp_vent_contamination
	max_occurrences = 2
	weight = 15
	earliest_start = 15 MINUTES
	min_players = 10

/datum/round_event/scp_vent_contamination
	var/contaminant_type

/datum/round_event/scp_vent_contamination/setup()
	startWhen = 1
	announceWhen = 1
	endWhen = 25
	contaminant_type = pick("unknown particulate", "anomalous gas", "biohazardous vapor")

/datum/round_event/scp_vent_contamination/announce(fake)
	priority_announce("WARNING: [capitalize(contaminant_type)] detected in ventilation system. Affected zones: LCZ corridors. Personnel don breathing protection.", "VENT CONTAMINATION", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_vent_contamination/tick()
	if(activeFor % 6 != 0)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/lcz))
			continue
		var/obj/item/clothing/mask/M = H.wear_mask
		if(M && (M.flags_cover & MASKCOVERSMOUTH))
			continue
		if(prob(20))
			H.adjustOxyLoss(5)
			to_chat(H, span_warning("You inhale [contaminant_type] from the vents! Your lungs burn!"))
			H.emote("cough")

/datum/round_event_control/scp_anomalous_fauna_migration
	name = "Anomalous Fauna Incursion"
	typepath = /datum/round_event/scp_anomalous_fauna_migration
	weight = 10
	min_players = 5
	earliest_start = 15 MINUTES
	max_occurrences = 3

/datum/round_event/scp_anomalous_fauna_migration
	announceWhen = 3
	startWhen = 50
	var/hasAnnounced = FALSE

/datum/round_event/scp_anomalous_fauna_migration/setup()
	startWhen = rand(40, 60)

/datum/round_event/scp_anomalous_fauna_migration/announce(fake)
	priority_announce("Anomalous biological entities detected in facility perimeter. Security personnel respond immediately.", "BREACH ALERT", sound_type = ANNOUNCER_ALERT)

/datum/round_event/scp_anomalous_fauna_migration/start()
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		spawn_locs += C.loc
	if(!length(spawn_locs))
		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(istype(get_area(L), /area/scp/lcz) || istype(get_area(L), /area/scp/hcz))
				spawn_locs += L.loc
	if(!length(spawn_locs))
		return
	var/list/fauna_types = list(
		/mob/living/simple_animal/hostile/anomalous_fauna/void_crawler,
		/mob/living/simple_animal/hostile/anomalous_fauna/void_crawler,
		/mob/living/simple_animal/hostile/anomalous_fauna/void_crawler,
		/mob/living/simple_animal/hostile/anomalous_fauna/aberrant_hound,
		/mob/living/simple_animal/hostile/anomalous_fauna/aberrant_hound,
		/mob/living/simple_animal/hostile/anomalous_fauna/shadow_stalker,
		/mob/living/simple_animal/hostile/anomalous_fauna/thermal_wraith,
		/mob/living/simple_animal/hostile/anomalous_fauna/crystal_geode,
	)
	for(var/i in 1 to rand(3, 6))
		var/turf/T = pick(spawn_locs)
		var/fauna_type = pick(fauna_types)
		var/mob/living/simple_animal/hostile/anomalous_fauna/F = new fauna_type(T)
		if(!hasAnnounced)
			announce_to_ghosts(F)
			hasAnnounced = TRUE
