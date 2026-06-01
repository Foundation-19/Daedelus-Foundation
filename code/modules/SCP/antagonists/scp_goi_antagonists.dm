/datum/antagonist/sarkic_cult
	name = "Sarkic Cultist"
	roundend_category = "Sarkic Cultists"
	antagpanel_category = "Sarkic"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE FLESH!"
	var/datum/team/sarkic_cult/sarkic_team

/datum/antagonist/sarkic_cult/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are a Sarkic Cultist of the Nalka tradition."))
	to_chat(owner, span_warning("The flesh is willing. The Foundation is a cage. Spread the gift of transformation."))
	to_chat(owner, span_notice("Use your biological powers to subvert the facility from within. Convert others. Summon the Flesh."))

/datum/antagonist/sarkic_cult/get_team()
	return sarkic_team

/datum/team/sarkic_cult
	name = "Sarkic Cult"

/datum/antagonist/chaos_insurgency
	name = "Chaos Insurgency Agent"
	roundend_category = "Hostile Groups"
	antagpanel_category = "Hostile Groups"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoChaos"
	description = "You are an agent of the Chaos Insurgency, seeking to destabilize the Foundation and steal SCPs."
	suicide_cry = "FOR THE INSURGENCY!"

/datum/antagonist/chaos_insurgency/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are a Chaos Insurgency agent."))
	to_chat(owner, span_warning("Your mission: Infiltrate the Foundation, steal SCP objects, and sabotage containment."))
	to_chat(owner, span_notice("Use your equipment and disguise abilities to operate from within. Extract D-Class and intelligence."))

/datum/antagonist/goc_operative
	name = "GOC Operative"
	roundend_category = "GOC Operatives"
	antagpanel_category = "GOC"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE GOC!"
	var/datum/team/goc_strike/team

/datum/antagonist/goc_operative/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are a Global Occult Coalition operative."))
	to_chat(owner, span_warning("Your mission: Destroy all anomalous threats in this facility. No exceptions."))
	to_chat(owner, span_notice("The Foundation is soft. They contain what should be destroyed. Complete your mission by any means necessary."))

/datum/antagonist/goc_operative/get_team()
	return team

/datum/antagonist/goc_operative/on_gain()
	. = ..()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.faction |= "goc"
	var/datum/objective/escape/O1 = new()
	O1.owner = owner
	O1.explanation_text = "Destroy all anomalous threats in this facility by any means necessary."
	O1.completed = TRUE
	objectives += O1
	if(owner.current)
		var/datum/action/innate/scp_ability/tactical_scan/scan = new()
		scan.Grant(owner.current)
		var/datum/action/innate/scp_ability/goc_shield/shield = new()
		shield.Grant(owner.current)
		var/datum/action/innate/scp_ability/goc_target_designator/designator = new()
		designator.Grant(owner.current)

/datum/antagonist/goc_operative/on_removal()
	. = ..()
	if(owner.current)
		var/datum/action/innate/scp_ability/tactical_scan/scan = locate() in owner.current.actions
		if(scan)
			scan.Remove(owner.current)
		var/datum/action/innate/scp_ability/goc_shield/shield = locate() in owner.current.actions
		if(shield)
			shield.Remove(owner.current)
		var/datum/action/innate/scp_ability/goc_target_designator/designator = locate() in owner.current.actions
		if(designator)
			designator.Remove(owner.current)

/datum/team/goc_strike
	name = "GOC Strike Team"

/datum/antagonist/serpents_hand
	name = "Serpent's Hand Agent"
	roundend_category = "Serpent's Hand"
	antagpanel_category = "SerpentsHand"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "THE LIBRARY REMEMBERS!"
	var/datum/team/serpents_hand_cell/team

/datum/antagonist/serpents_hand/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are an agent of the Serpent's Hand."))
	to_chat(owner, span_warning("The SCPs are not threats to be contained — they are beings with rights. Free them from Foundation captivity."))
	to_chat(owner, span_notice("Use the Wanderers' Library's knowledge to aid anomalous entities. Sabotage Foundation containment. Help SCPs escape."))

/datum/antagonist/serpents_hand/get_team()
	return team

/datum/team/serpents_hand_cell
	name = "Serpent's Hand Cell"

/datum/action/innate/scp_ability/tactical_scan
	name = "Tactical Anomaly Scanner"
	desc = "Scan for nearby SCP entities and assess threat levels."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "artificer"
	cooldown_time = 20 SECONDS

/datum/action/innate/scp_ability/tactical_scan/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	start_cooldown()
	var/list/detected = list()
	for(var/mob/living/scp/S in view(15, H))
		if(S.stat == DEAD)
			continue
		var/area/A = get_area(S)
		var/threat_level = "LOW"
		if(S.SCP?.classification == "keter")
			threat_level = "CRITICAL"
		else if(S.SCP?.classification == "euclid")
			threat_level = "MODERATE"
		detected += "SCP-[S.SCP?.designation || "???"] — [threat_level] — [A?.name || "Unknown Location"]"
	if(!length(detected))
		to_chat(H, span_notice("No anomalous entities detected in scan range."))
	else
		to_chat(H, span_warning("<b>TACTICAL SCAN:</b>"))
		for(var/entry in detected)
			to_chat(H, span_warning("  [entry]"))

/datum/action/innate/scp_ability/goc_shield
	name = "Reactive Shield Pulse"
	desc = "Activate a short-duration energy shield that absorbs damage."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "vamp_rejuv"
	cooldown_time = 45 SECONDS

/datum/action/innate/scp_ability/goc_shield/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	start_cooldown()
	H.apply_status_effect(/datum/status_effect/goc_shield)
	to_chat(H, span_notice("Reactive shield activated! Absorbing damage for 10 seconds."))
	H.visible_message(span_notice("[H]'s armor flickers with energy!"))

/datum/status_effect/goc_shield
	id = "goc_shield"
	duration = 10 SECONDS
	alert_type = null

/datum/status_effect/goc_shield/tick()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.adjustBruteLoss(-2)
		H.adjustFireLoss(-2)

/datum/action/innate/scp_ability/goc_target_designator
	name = "Target Designator"
	desc = "Mark an SCP for GOC elimination. All GOC operatives see the marker."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "vendort"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/goc_target_designator/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	var/list/targets = list()
	for(var/mob/living/scp/S in view(7, H))
		if(S.stat != DEAD)
			targets[S] = "SCP-[S.SCP?.designation || "???"]"
	if(!length(targets))
		to_chat(H, span_warning("No SCP targets in range."))
		return
	var/mob/living/scp/target = input(H, "Select target to designate:", "GOC Target Designator") as null|anything in targets
	if(!target || target.stat == DEAD)
		return
	start_cooldown()
	var/target_name = targets[target]
	var/area/target_area = get_area(target)
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(is_goc_operative(G))
			to_chat(G, span_warning("<b>GOC TARGET DESIGNATED:</b> [target_name] in [target_area?.name || "Unknown"]!"))

/proc/is_goc_operative(mob/living/carbon/human/H)
	if(!H.mind)
		return FALSE
	return locate(/datum/antagonist/goc_operative) in H.mind.antag_datums

/datum/outfit/sarkic_cultist
	name = "Sarkic Cultist"
	uniform = /obj/item/clothing/under/color/maroon
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	head = /obj/item/clothing/head/hooded/cult_hoodie/alt
	shoes = /obj/item/clothing/shoes/sandal
	gloves = /obj/item/clothing/gloves/color/red
	back = /obj/item/storage/backpack/cultpack
	id = /obj/item/card/id/advanced

/datum/outfit/goc_operative
	name = "GOC Operative"
	uniform = /obj/item/clothing/under/scp/civilian/goc
	suit = /obj/item/clothing/suit/armor/vest/scp/medarmor
	head = /obj/item/clothing/head/helmet/scp/security
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/scp_security
	id = /obj/item/card/id/advanced

/datum/outfit/serpents_hand
	name = "Serpent's Hand Agent"
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/wizrobe
	head = /obj/item/clothing/head/wizard
	shoes = /obj/item/clothing/shoes/sandal
	gloves = /obj/item/clothing/gloves/color/purple
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/advanced

/datum/round_event_control/sarkic_outbreak
	name = "Sarkic Flesh Cult"
	typepath = /datum/round_event/sarkic_outbreak
	weight = 5
	min_players = 15
	earliest_start = 30 MINUTES
	max_occurrences = 1

/datum/round_event/sarkic_outbreak/start()
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a Sarkic Cultist?", ROLE_CULTIST, null, 10 SECONDS, pick(GLOB.station_turfs))
	if(!length(candidates))
		return
	var/mob/dead/observer/candidate = pick(candidates)
	var/mob/living/carbon/human/H = new(pick(GLOB.station_turfs))
	H.key = candidate.key
	var/datum/antagonist/sarkic_cult/A = new()
	H.mind.add_antag_datum(A)
	priority_announce("Anomalous biological signatures detected in facility. Possible Sarkic cult activity. Security personnel investigate immediately.", "ANOMALOUS ACTIVITY", null, ANNOUNCER_ALERT)

/datum/round_event_control/goc_incursion
	name = "GOC Incursion"
	typepath = /datum/round_event/goc_incursion
	weight = 3
	min_players = 20
	earliest_start = 40 MINUTES
	max_occurrences = 1

/datum/round_event/goc_incursion/start()
	var/list/spawn_turfs = list()
	for(var/turf/T in get_area_turfs(/area/scp/surface/helipad))
		if(!T.density)
			spawn_turfs += T
	if(!length(spawn_turfs))
		spawn_turfs += list(pick(GLOB.station_turfs))
	var/mob/living/carbon/human/temp_mob = new(pick(spawn_turfs))
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a GOC Operative?", ROLE_OPERATIVE, null, 10 SECONDS, temp_mob)
	qdel(temp_mob)
	if(length(candidates) < 2)
		return
	var/datum/team/goc_strike/team = new()
	for(var/i in 1 to min(3, length(candidates)))
		var/mob/dead/observer/candidate = candidates[i]
		var/mob/living/carbon/human/H = new(pick(spawn_turfs))
		H.key = candidate.key
		var/datum/antagonist/goc_operative/A = new()
		A.team = team
		H.mind.add_antag_datum(A)
	priority_announce("WARNING: Unauthorized armed personnel detected on facility perimeter. Hostile intent confirmed. All security personnel respond. This is NOT a drill.", "SECURITY ALERT", null, ANNOUNCER_ALERT)

/datum/round_event_control/serpents_hand_infiltration
	name = "Serpent's Hand Infiltration"
	typepath = /datum/round_event/serpents_hand_infiltration
	weight = 3
	min_players = 15
	earliest_start = 25 MINUTES
	max_occurrences = 1

/datum/round_event/serpents_hand_infiltration/start()
	var/mob/living/carbon/human/temp_mob = new(pick(GLOB.station_turfs))
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a Serpent's Hand Agent?", ROLE_WIZARD, null, 10 SECONDS, temp_mob)
	qdel(temp_mob)
	if(!length(candidates))
		return
	var/mob/dead/observer/candidate = pick(candidates)
	var/mob/living/carbon/human/H = new(pick(GLOB.station_turfs))
	H.key = candidate.key
	var/datum/antagonist/serpents_hand/A = new()
	H.mind.add_antag_datum(A)
	priority_announce("Multiple security badge anomalies detected. Possible unauthorized infiltration. All personnel verify credentials at checkpoints.", "SECURITY ALERT", null, ANNOUNCER_ALERT)
