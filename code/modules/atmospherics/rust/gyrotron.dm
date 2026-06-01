/obj/machinery/power/emitter/gyrotron
	name = "gyrotron"
	desc = "A high-powered microwave emitter designed to inject energy into an electromagnetic containment field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	base_icon_state = "emitter"
	req_access = list(ACCESS_ENGINEERING_LVL2)
	circuit = /obj/item/circuitboard/machine/gyrotron
	projectile_type = /obj/projectile/beam/emitter/hitscan
	projectile_sound = 'sound/weapons/emitter2.ogg'
	active = FALSE
	welded = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	density = TRUE

	var/mega_energy = 0
	var/last_projectile_damage = 0

/obj/machinery/power/emitter/gyrotron/anchored
	anchored = TRUE
	welded = TRUE
	var/initial_id_tag

/obj/machinery/power/emitter/gyrotron/RefreshParts()
	. = ..()
	var/obj/item/stock_parts/micro_laser/L = locate(/obj/item/stock_parts/micro_laser) in component_parts
	var/obj/item/stock_parts/capacitor/C = locate(/obj/item/stock_parts/capacitor) in component_parts
	if(L)
		mega_energy = L.rating * 5
	if(C)
		fire_delay = max(2 SECONDS, 10 SECONDS - C.rating * 2 SECONDS)
	else
		fire_delay = 10 SECONDS
	maximum_fire_delay = fire_delay
	minimum_fire_delay = 2 SECONDS

/obj/machinery/power/emitter/gyrotron/set_anchored(anchorvalue)
	. = ..()
	if(anchorvalue)
		connect_to_network()

/obj/machinery/power/emitter/gyrotron/fire_beam()
	if(!powered())
		if(powered)
			powered = FALSE
		return
	if(!powered)
		powered = TRUE

	if(!welded)
		return

	if(!active)
		return

	var/obj/projectile/P = new projectile_type(loc)
	playsound(loc, projectile_sound, 50, TRUE)
	P.damage = mega_energy + 10
	last_projectile_damage = P.damage

	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		var/pressure = environment.returnPressure()
		if(pressure > 50)
			P.damage *= 0.5

	if(dir == NORTH)
		P.fire(NORTH)
	else if(dir == SOUTH)
		P.fire(SOUTH)
	else if(dir == EAST)
		P.fire(EAST)
	else if(dir == WEST)
		P.fire(WEST)
	else
		P.fire(dir)

	if(prob(5))
		visible_message(span_warning("[src] crackles with energy!"))

	if(!machine_stat)
		use_power(mega_energy * 20)

/obj/machinery/power/emitter/gyrotron/attack_hand(mob/user)
	if(machine_stat & BROKEN)
		return
	if(!welded)
		to_chat(user, span_warning("[src] must be welded down first!"))
		return
	if(!allowed(user))
		to_chat(user, span_warning("Access denied."))
		return
	active = !active
	if(active)
		START_PROCESSING(SSobj, src)
		visible_message(span_notice("[user] activates [src]."), span_notice("You activate [src]."))
	else
		visible_message(span_notice("[user] deactivates [src]."), span_notice("You deactivate [src]."))
	update_icon()

/obj/machinery/power/emitter/gyrotron/update_icon()
	. = ..()
	if(active)
		icon_state = "[base_icon_state]_+a"
	else
		icon_state = base_icon_state
