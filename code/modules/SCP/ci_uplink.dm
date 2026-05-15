/obj/item/uplink/ci
	name = "strange device"
	desc = "A compact communications device linked to Chaos Insurgency command."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"

/obj/item/uplink/ci/Initialize(mapload)
	. = ..()

/obj/item/storage/box/syndie_kit/ci_starter
	name = "Chaos Insurgency Field Kit"

/obj/effect/spawner/random/ci_uplink
	name = "Chaos Insurgency Uplink Spawner"
	loot = list(/obj/item/uplink/ci)

/obj/item/ci_supply_beacon
	name = "CI Supply Beacon"
	desc = "A beacon that signals Chaos Insurgency forces to airdrop supplies. Single use."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "signaller"
	var/used = FALSE

/obj/item/ci_supply_beacon/attack_self(mob/user)
	if(used)
		to_chat(user, span_warning("This beacon has already been used."))
		return
	var/confirm = alert(user, "Activate CI supply beacon? This will airdrop a supply crate at your location.", "Supply Beacon", "Activate", "Cancel")
	if(confirm != "Activate")
		return
	used = TRUE
	user.visible_message(span_warning("[user] activates the supply beacon!"))
	playsound(src, 'sound/machines/triple_beep.ogg', 50, TRUE)
	priority_announce("ALERT: Unauthorized supply signal detected at [get_area_name(src)]. Possible hostile resupply operation.", "SECURITY ALERT", null, ANNOUNCER_ALERT)

	var/turf/T = get_turf(src)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/spawn_ci_crate, T), 10 SECONDS)

/proc/spawn_ci_crate(turf/T)
	if(!T)
		return
	var/obj/structure/closet/crate/C = new(T)
	new /obj/item/storage/medkit/regular(C)
	new /obj/item/reagent_containers/syringe(C)
	new /obj/item/flashlight(C)
	new /obj/item/radio/off(C)

/obj/item/ci_document
	name = "stolen Foundation document"
	desc = "A classified Foundation document stolen by Chaos Insurgency operatives."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_words"
	var/document_type = "generic"

/obj/item/ci_document/attack_self(mob/user)
	to_chat(user, span_notice("You read the classified document: [document_type] intelligence report."))
