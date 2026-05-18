/area/scp/shelter_alpha
	name = "Emergency Shelter Alpha"
	icon_state = "shelter"

/area/scp/shelter_bravo
	name = "Emergency Shelter Bravo"
	icon_state = "shelter"

/obj/structure/shelter_beacon
	name = "Emergency Shelter Beacon"
	desc = "A beacon marking the location of an emergency shelter. Follow the red light."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	density = FALSE
	anchored = TRUE
	var/beacon_range = 10

/obj/structure/shelter_beacon/Initialize()
	. = ..()
	set_light(beacon_range, 2, COLOR_RED)

/obj/structure/shelter_supply_cache
	name = "Emergency Supply Cache"
	desc = "A sealed emergency supply cache. Pry it open to access the contents."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrate"
	density = FALSE
	anchored = TRUE
	var/opened = FALSE

/obj/structure/shelter_supply_cache/attack_hand(mob/user)
	if(opened)
		to_chat(user, span_warning("The cache has already been opened."))
		return

	opened = TRUE
	icon_state = "sec"
	to_chat(user, span_notice("You pry open the supply cache!"))

	new /obj/item/storage/medkit/regular(get_turf(src))
	new /obj/item/radio(get_turf(src))
	new /obj/item/clothing/mask/gas(get_turf(src))
	new /obj/item/flashlight(get_turf(src))

/obj/machinery/shelter_lockdown_panel
	name = "Shelter Lockdown Panel"
	desc = "Activates the emergency lockdown for this shelter area."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	var/lockdown_active = FALSE

/obj/machinery/shelter_lockdown_panel/attack_hand(mob/user)
	if(!powered())
		to_chat(user, span_warning("No power!"))
		return

	lockdown_active = !lockdown_active

	var/area/scp/shelter_area = get_area(src)
	if(!istype(shelter_area, /area/scp/shelter_alpha) && !istype(shelter_area, /area/scp/shelter_bravo))
		shelter_area = null

	if(!shelter_area)
		to_chat(user, span_warning("No shelter area detected!"))
		return

	if(lockdown_active)
		to_chat(user, span_warning("You activate the shelter lockdown! All doors in the shelter area are now sealed."))
		for(var/obj/machinery/door/airlock/A in shelter_area)
			A.close()
			A.lock()
	else
		to_chat(user, span_notice("You release the shelter lockdown."))
		for(var/obj/machinery/door/airlock/A in shelter_area)
			A.unlock()
