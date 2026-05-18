/datum/antagonist/sarkic
	name = "Sarkic Cultist"
	roundend_category = "Sarkic Cultists"
	antagpanel_category = "Sarkic"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE FLESH!"
	var/datum/team/sarkic_cult/sarkic_team

/datum/antagonist/sarkic/greet()
	. = ..()
	to_chat(owner, span_boldannounce("You are a Sarkic Cultist of the Nalka tradition."))
	to_chat(owner, span_warning("The flesh is willing. The Foundation is a cage. Spread the gift of transformation."))
	to_chat(owner, span_notice("Use your biological powers to subvert the facility from within. Convert others. Summon the Flesh."))

/datum/antagonist/sarkic/get_team()
	return sarkic_team

/datum/antagonist/sarkic/on_gain()
	. = ..()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.faction |= "sarkic"
	var/datum/objective/escape/O1 = new()
	O1.owner = owner
	O1.explanation_text = "Spread the Sarkic faith. Facilitate chaos within the Foundation."
	O1.completed = TRUE
	objectives += O1

/datum/team/sarkic_cult
	name = "Sarkic Cult"

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

/datum/antagonist/serpents_hand/on_gain()
	. = ..()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.faction |= "serpents_hand"
	var/datum/objective/escape/O1 = new()
	O1.owner = owner
	O1.explanation_text = "Free the anomalous. Sabotage Foundation containment. Help SCPs escape captivity."
	O1.completed = TRUE
	objectives += O1

/datum/team/serpents_hand_cell
	name = "Serpent's Hand Cell"

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
	var/turf/spawn_turf = get_safe_random_station_turf()
	if(!spawn_turf)
		return
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a Sarkic Cultist?", ROLE_CULTIST, null, 10 SECONDS, spawn_turf)
	if(!length(candidates))
		return
	var/mob/dead/observer/candidate = pick(candidates)
	var/mob/living/carbon/human/H = new(spawn_turf)
	H.key = candidate.key
	var/datum/antagonist/sarkic/A = new()
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
	for(var/turf/T in get_area_turfs(/area/site53/surface))
		if(!T.density)
			spawn_turfs += T
	if(!length(spawn_turfs))
		var/turf/fallback = get_safe_random_station_turf()
		if(fallback)
			spawn_turfs += fallback
	if(!length(spawn_turfs))
		return
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
	var/turf/spawn_turf = get_safe_random_station_turf()
	if(!spawn_turf)
		return
	var/mob/living/carbon/human/temp_mob = new(spawn_turf)
	var/list/candidates = poll_candidates_for_mob("Do you want to play as a Serpent's Hand Agent?", ROLE_WIZARD, null, 10 SECONDS, temp_mob)
	qdel(temp_mob)
	if(!length(candidates))
		return
	var/mob/dead/observer/candidate = pick(candidates)
	var/mob/living/carbon/human/H = new(spawn_turf)
	H.key = candidate.key
	var/datum/antagonist/serpents_hand/A = new()
	H.mind.add_antag_datum(A)
	priority_announce("Multiple security badge anomalies detected. Possible unauthorized infiltration. All personnel verify credentials at checkpoints.", "SECURITY ALERT", null, ANNOUNCER_ALERT)
