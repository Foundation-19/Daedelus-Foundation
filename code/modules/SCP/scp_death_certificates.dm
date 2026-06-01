/obj/item/paper/death_certificate
	name = "Death Certificate"
	desc = "An official Foundation death certificate."
	icon_state = "paper"

/obj/item/paper/death_certificate/proc/generate_certificate(mob/living/carbon/human/H, cause, time_of_death)
	if(!H)
		return

	var/cert_text = {"
		<center><b>SCP FOUNDATION — DEATH CERTIFICATE</b></center>
		<hr>
		<b>Decedent:</b> [H.real_name]<br>
		<b>Position:</b> [H.job || "Unknown"]<br>
		<b>Blood Type:</b> [H.dna?.blood_type || "Unknown"]<br>
		<b>Time of Death:</b> [time_of_death || gameTimestamp("hh:mm")]<br>
		<b>Location:</b> [get_area_name(H, TRUE) || "Unknown"]<br>
		<b>Cause of Death:</b> [cause || "Pending Autopsy"]<br>
		<br>
		<b>Circumstances:</b> [cause == "Pending Autopsy" ? "Autopsy required." : "See attached report."]<br>
		<br>
		<b>Coroner:</b> ________________<br>
		<b>Witness:</b> ________________<br>
		<b>Date:</b> [time2text(world.realtime, "YYYY-MM-DD")]<br>
		<hr>
		<center><i>This document is classified under Foundation Protocol 4000-Alpha.<br>Unauthorized distribution is grounds for immediate termination.</i></center>
	"}

	info = cert_text
	name = "Death Certificate — [H.real_name]"

/obj/structure/bodybag_rack
	name = "body bag rack"
	desc = "A rack for storing body bags."
	icon = 'icons/obj/storage.dmi'
	icon_state = "rack"
	anchored = TRUE
	density = FALSE
	var/max_bags = 5
	var/list/stored_bags = list()

/obj/structure/bodybag_rack/examine(mob/user)
	. = ..()
	. += "It contains [length(stored_bags)]/[max_bags] body bags."

/obj/structure/bodybag_rack/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/bodybag))
		if(length(stored_bags) >= max_bags)
			to_chat(user, span_warning("The rack is full!"))
			return
		stored_bags += I
		I.forceMove(src)
		to_chat(user, span_notice("You place [I] on the rack."))
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You [anchored ? "unsecure" : "secure"] [src]."))
		anchored = !anchored
		I.play_tool_sound(src)
		return
	return ..()

/obj/structure/bodybag_rack/attack_hand(mob/user)
	if(!length(stored_bags))
		to_chat(user, span_warning("The rack is empty!"))
		return

	var/obj/item/bodybag/B = stored_bags[length(stored_bags)]
	stored_bags -= B
	B.forceMove(get_turf(user))
	user.put_in_hands(B)
	to_chat(user, span_notice("You take [B] from the rack."))


