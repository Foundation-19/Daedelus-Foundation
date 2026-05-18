/datum/round_event/anomalous_item
	var/anomaly_name
	var/anomaly_path
	var/spawn_location

/datum/round_event/anomalous_item/announce(fake)
	priority_announce("Anomalous item detected in [anomaly_name]. Security personnel advised to investigate and contain.", null, null, 'sound/misc/notice1.ogg')

/datum/round_event/anomalous_item/start()
	var/list/valid_areas = list()
	for(var/area/A in GLOB.sortedAreas)
		if(!is_station_level(A.z))
			continue
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz) || istype(A, /area/scp/ez))
			valid_areas += A

	if(!length(valid_areas))
		return

	var/area/spawn_area = pick(valid_areas)
	var/list/turf/candidates = list()
	for(var/turf/T in get_area_turfs(spawn_area))
		if(!T.density)
			candidates += T

	if(!length(candidates))
		return

	var/turf/spawn_turf = pick(candidates)
	anomaly_name = initial(spawn_area.name)

	var/list/possible_items = list(
		/obj/item/scp_anomalous/strange_mirror,
		/obj/item/scp_anomalous/humming_pen,
		/obj/item/scp_anomalous/cold_coin,
		/obj/item/scp_anomalous/shifting_map,
		/obj/item/scp_anomalous/whispering_radio,
		/obj/item/scp_anomalous/warm_stone,
	)

	anomaly_path = pick(possible_items)
	new anomaly_path(spawn_turf)

/obj/item/scp_anomalous
	name = "anomalous object"
	desc = "An object with strange, unexplained properties."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	var/anomaly_id = "unknown"
	var/contained = FALSE

/obj/item/scp_anomalous/attack_self(mob/user)
	if(contained)
		to_chat(user, span_notice("This object has been neutralized by containment procedures."))
		return
	trigger_anomaly(user)

/obj/item/scp_anomalous/equipped(mob/user, slot, initial)
	. = ..()
	if(!contained && slot == ITEM_SLOT_HANDS)
		on_pickup_effect(user)

/obj/item/scp_anomalous/proc/trigger_anomaly(mob/user)
	return

/obj/item/scp_anomalous/proc/on_pickup_effect(mob/user)
	return

/obj/item/scp_anomalous/proc/on_drop_effect(mob/user)
	return

/obj/item/scp_anomalous/proc/contain()
	contained = TRUE
	name = "contained [name]"
	desc = "A contained anomalous object. Its effects have been neutralized."
	color = "#888888"

/obj/item/scp_anomalous/strange_mirror
	name = "strange mirror"
	desc = "A small hand mirror that doesn't reflect your face properly."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	anomaly_id = "mirror"

/obj/item/scp_anomalous/strange_mirror/trigger_anomaly(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, span_warning("You gaze into the mirror... and see someone else staring back at you."))
		if(H.sanity)
			H.sanity.adjust_sanity(-10, "anomalous mirror")

/obj/item/scp_anomalous/strange_mirror/on_pickup_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, span_notice("The mirror feels unnaturally cold in your hand."))

/obj/item/scp_anomalous/humming_pen
	name = "humming pen"
	desc = "A pen that emits a faint, melodic hum when held."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	anomaly_id = "pen"

/obj/item/scp_anomalous/humming_pen/trigger_anomaly(mob/user)
	to_chat(user, span_notice("The pen's hum grows louder... you feel compelled to write something."))

/obj/item/scp_anomalous/humming_pen/on_pickup_effect(mob/user)
	playsound(get_turf(src), 'sound/ambience/ambimo1.ogg', 30, TRUE)

/obj/item/scp_anomalous/humming_pen/on_drop_effect(mob/user)
	to_chat(user, span_notice("The humming stops."))

/obj/item/scp_anomalous/cold_coin
	name = "cold coin"
	desc = "A silver coin that is always ice-cold to the touch."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	anomaly_id = "coin"

/obj/item/scp_anomalous/cold_coin/trigger_anomaly(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, span_warning("The coin burns with cold! Your hand feels numb."))
		H.apply_damage(5, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/obj/item/scp_anomalous/cold_coin/on_pickup_effect(mob/user)
	to_chat(user, span_warning("The coin is freezing cold!"))

/obj/item/scp_anomalous/shifting_map
	name = "shifting map"
	desc = "A map of the facility that seems to change when you're not looking."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_words"
	anomaly_id = "map"

/obj/item/scp_anomalous/shifting_map/trigger_anomaly(mob/user)
	to_chat(user, span_warning("The corridors on the map shift and rearrange before your eyes..."))
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.sanity)
			H.sanity.adjust_sanity(-5, "shifting map")

/obj/item/scp_anomalous/whispering_radio
	name = "whispering radio"
	desc = "A small radio that picks up transmissions from nowhere."
	icon = 'icons/obj/radio.dmi'
	icon_state = "walkietalkie"
	anomaly_id = "radio"

/obj/item/scp_anomalous/whispering_radio/trigger_anomaly(mob/user)
	to_chat(user, span_warning("The radio whispers something you can't quite make out..."))
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.sanity)
			H.sanity.adjust_sanity(-8, "whispering radio")

/obj/item/scp_anomalous/whispering_radio/on_pickup_effect(mob/user)
	playsound(get_turf(src), 'sound/ambience/ambimo2.ogg', 20, TRUE)

/obj/item/scp_anomalous/warm_stone
	name = "warm stone"
	desc = "A smooth river stone that is always pleasantly warm."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "scrap"
	anomaly_id = "stone"

/obj/item/scp_anomalous/warm_stone/trigger_anomaly(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, span_notice("The stone radiates a comforting warmth. You feel slightly better."))
		if(H.sanity)
			H.sanity.adjust_sanity(5, "warm stone")
		H.adjustBruteLoss(-5)

/obj/item/scp_anomalous/warm_stone/on_pickup_effect(mob/user)
	to_chat(user, span_notice("The stone is warm and soothing in your hand."))
