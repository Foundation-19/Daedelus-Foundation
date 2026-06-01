// Security Checkpoint Mechanics
// Zone-transition checkpoints with contraband scanning, search procedures, and access enforcement

/obj/machinery/scp_checkpoint_scanner
	name = "SCP Checkpoint Scanner"
	desc = "A security scanner that detects contraband, unauthorized items, and anomalous objects at zone transitions."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "bluespace-prison"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30

	var/list/contraband_detected = list()
	var/scan_cooldown = 0
	var/scan_cooldown_time = 5 SECONDS
	var/list/contraband_items = list(
		/obj/item/knife,
		/obj/item/gun,
		/obj/item/restraints/handcuffs,
	)
	var/alert_security = TRUE
	var/last_alert_time = 0
	var/alert_cooldown = 30 SECONDS

/obj/machinery/scp_checkpoint_scanner/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_crossed))

/obj/machinery/scp_checkpoint_scanner/proc/on_crossed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!ishuman(AM))
		return
	if(world.time < scan_cooldown)
		return

	var/mob/living/carbon/human/H = AM
	scan_cooldown = world.time + scan_cooldown_time
	scan_person(H)

/obj/machinery/scp_checkpoint_scanner/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(H, span_warning("Requires Security access to operate checkpoint scanner."))
		return

	if(length(contraband_detected))
		to_chat(H, span_notice("=== Recent Contraband Detections ==="))
		for(var/list/detection in contraband_detected)
			var/det_name = detection["name"]
			var/det_item = detection["item"]
			var/det_time = detection["time"]
			to_chat(H, span_warning("[det_name] - [det_item] at [time2text(det_time, "hh:mm:ss")]"))
	else
		to_chat(H, span_notice("No recent contraband detections."))

/obj/machinery/scp_checkpoint_scanner/proc/scan_person(mob/living/carbon/human/H)
	if(!H || H.stat == DEAD)
		return

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(id_card && (ACCESS_SECURITY in id_card.access))
		return

	var/list/found_contraband = list()

	for(var/obj/item/I in H.get_all_contents())
		var/is_contraband = FALSE

		for(var/contraband_type in contraband_items)
			if(istype(I, contraband_type))
				is_contraband = TRUE
				break

		if(!is_contraband)
			if(findtext("[I.type]", "dclass") && findtext("[I.type]", "contraband"))
				is_contraband = TRUE
			if(findtext("[I.type]", "scp") && !findtext("[I.type]", "document") && !findtext("[I.type]", "reader"))
				is_contraband = TRUE

		if(is_contraband)
			found_contraband += I.name

	if(!length(found_contraband))
		return

	contraband_detected += list(list(
		"name" = H.name,
		"item" = english_list(found_contraband),
		"time" = world.time,
	))

	if(length(contraband_detected) > 20)
		contraband_detected.Cut(1, 2)

	visible_message(span_warning("[src] flashes red as it detects contraband on [H]!"))
	to_chat(H, span_danger("The checkpoint scanner has detected unauthorized items on your person!"))

	if(alert_security && world.time > last_alert_time + alert_cooldown)
		last_alert_time = world.time
		for(var/mob/living/carbon/human/sec in GLOB.player_list)
			if(QDELETED(sec))
				continue
			if(sec.stat == DEAD || !sec.client)
				continue
			var/obj/item/card/id/sec_id = sec.get_idcard(TRUE)
			if(sec_id && (ACCESS_SECURITY in sec_id.access))
				var/area/A = get_area(src)
				var/contraband_location = A ? A.name : "unknown location"
				to_chat(sec, span_danger("CHECKPOINT ALERT: Contraband detected on [H.name] at [contraband_location]. Items: [english_list(found_contraband)]"))

		var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[H.ckey]
		if(player)
			player.adjust_trust(-10, "contraband_detected")
			player.suspicion_level = min(100, player.suspicion_level + 15)

// Checkpoint Gate - Physical barrier that can be opened/closed by security
/obj/machinery/scp_checkpoint_gate
	name = "Checkpoint Security Gate"
	desc = "A reinforced gate that controls access between facility zones. Operated by security personnel."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	density = TRUE
	anchored = TRUE
	var/open = FALSE
	var/locked = FALSE
	var/auto_close_time = 15 SECONDS
	var/require_search = TRUE

/obj/machinery/scp_checkpoint_gate/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(H, span_warning("Requires Security access to operate the checkpoint gate."))
		return

	if(locked)
		to_chat(H, span_warning("Gate is locked during lockdown."))
		return

	toggle_gate(H)

/obj/machinery/scp_checkpoint_gate/proc/toggle_gate(mob/user)
	open = !open
	if(open)
		density = FALSE
		icon_state = "open"
		visible_message(span_notice("[src] opens."))
		addtimer(CALLBACK(src, .proc/auto_close), auto_close_time)
	else
		density = TRUE
		icon_state = "closed"
		visible_message(span_notice("[src] closes."))

/obj/machinery/scp_checkpoint_gate/proc/auto_close()
	if(open)
		open = FALSE
		density = TRUE
		icon_state = "closed"

/obj/machinery/scp_checkpoint_gate/proc/lock_gate()
	locked = TRUE
	if(open)
		open = FALSE
		density = TRUE
		icon_state = "closed"

/obj/machinery/scp_checkpoint_gate/proc/unlock_gate()
	locked = FALSE

// Search Procedure Terminal
/obj/machinery/scp_search_terminal
	name = "Checkpoint Search Terminal"
	desc = "A terminal for initiating formal search procedures on personnel passing through checkpoints."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE

	var/search_in_progress = FALSE
	var/mob/living/carbon/human/search_target
	var/search_progress = 0
	var/search_duration = 50

/obj/machinery/scp_search_terminal/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(H, span_warning("Requires Security access to perform searches."))
		return

	if(search_in_progress)
		to_chat(H, span_notice("Search in progress: [search_progress]% complete."))
		return

	var/list/nearby_targets = list()
	for(var/mob/living/carbon/human/target in view(2, H))
		if(target != H && target.stat != DEAD)
			nearby_targets += target

	if(!length(nearby_targets))
		to_chat(H, span_warning("No one nearby to search."))
		return

	var/mob/living/carbon/human/target = input(H, "Select person to search:", "Search Procedure") as null|anything in nearby_targets
	if(!target)
		return

	initiate_search(H, target)

/obj/machinery/scp_search_terminal/proc/initiate_search(mob/searcher, mob/living/carbon/human/target)
	search_in_progress = TRUE
	search_target = target
	search_progress = 0

	to_chat(searcher, span_notice("You begin searching [target]..."))
	to_chat(target, span_warning("[searcher] is performing a search on you. Stand still."))

	while(search_progress < 100)
		if(!search_target || !searcher || QDELETED(search_target) || QDELETED(searcher))
			search_in_progress = FALSE
			return

		if(get_dist(searcher, search_target) > 2)
			to_chat(searcher, span_warning("Search target moved out of range."))
			search_in_progress = FALSE
			return

		search_progress += 10
		sleep(5)

	complete_search(searcher, target)

/obj/machinery/scp_search_terminal/proc/complete_search(mob/searcher, mob/living/carbon/human/target)
	search_in_progress = FALSE

	var/list/found_items = list()
	var/list/contraband_found = list()

	for(var/obj/item/I in target.get_all_contents())
		found_items += I.name
		if(findtext("[I.type]", "dclass") && findtext("[I.type]", "contraband"))
			contraband_found += I
		if(findtext("[I.type]", "scp") && !findtext("[I.type]", "document"))
			contraband_found += I

	to_chat(searcher, span_notice("=== Search Results: [target.name] ==="))
	if(length(contraband_found))
		to_chat(searcher, span_danger("CONTRABAND FOUND:"))
		for(var/obj/item/I in contraband_found)
			to_chat(searcher, span_danger("- [I.name] ([I.type])"))
			I.forceMove(get_turf(target))

		var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[target.ckey]
		if(player)
			player.adjust_trust(-15, "contraband_confiscated")
			player.suspicion_level = min(100, player.suspicion_level + 20)
			player.strikes++
	else
		to_chat(searcher, span_nicegreen("No contraband detected. Subject is clear."))

	var/search_result_msg = length(contraband_found) ? "Contraband has been confiscated." : "You have been cleared."
	to_chat(target, span_notice("Search complete. [search_result_msg]"))
