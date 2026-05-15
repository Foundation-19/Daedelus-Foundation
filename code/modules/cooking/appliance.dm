/obj/machinery/appliance
	name = "cooking appliance"
	desc = "A cooking appliance."
	icon = 'icons/obj/kitchen.dmi'
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/appliance_board
	var/appliance_flags = NONE
	var/cook_type = ""
	var/cooking_power = 1.0
	var/max_contents = 6
	var/list/cooking_contents = list()
	var/can_cook_mobs = FALSE
	var/can_burn_food = TRUE
	var/burn_chance = 5
	var/active = FALSE
	var/efficiency = 1.0
	var/list/cooking_items = list()
	var/recipe_cookwork = 100
	var/default_cookwork = 100

/obj/machinery/appliance/examine(mob/user)
	. = ..()
	if(length(cooking_items))
		. += span_notice("It has [length(cooking_items)] item\s inside.")
	else
		. += span_notice("It is empty.")
	if(length(cooking_contents))
		. += span_notice("Containers: [length(cooking_contents)]")

/obj/machinery/appliance/Initialize()
	. = ..()
	START_PROCESSING(SSmachines, src)

/obj/machinery/appliance/Destroy()
	STOP_PROCESSING(SSmachines, src)
	. = ..()

/obj/machinery/appliance/process(delta_time)
	if(!powered())
		active = FALSE
		return
	if(!active)
		return
	for(var/datum/cooking_item/CI as anything in cooking_items)
		if(QDELETED(CI.target))
			cooking_items -= CI
			qdel(CI)
			continue
		CI.cookwork += cooking_power * efficiency * delta_time * 10
		if(CI.cookwork >= CI.max_cookwork)
			if(can_burn_food && CI.cookwork >= CI.max_cookwork * CI.overcook_mult)
				CI.burn()
				cooking_items -= CI
				qdel(CI)
			else if(!CI.started)
				CI.started = TRUE
				CI.finish_cooking()
				cooking_items -= CI
				qdel(CI)

/obj/machinery/appliance/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return
	if(default_pry_open(I))
		return
	if(panel_open)
		if(is_refillable() && istype(I, /obj/item/stock_parts))
			user.transferItemToLoc(I, src)
			return
	if(istype(I, /obj/item/reagent_containers/cooking_container))
		var/obj/item/reagent_containers/cooking_container/C = I
		if(can_accept_container(C, user))
			if(user.transferItemToLoc(I, src))
				add_container(C, user)
				return
		return
	if(can_add_item(I, user))
		if(user.transferItemToLoc(I, src))
			add_item(I, user)
			return
	return ..()

/obj/machinery/appliance/proc/can_add_item(obj/item/I, mob/user)
	if(length(cooking_items) >= max_contents)
		to_chat(user, span_warning("[src] is full!"))
		return FALSE
	return TRUE

/obj/machinery/appliance/proc/add_item(obj/item/I, mob/user)
	var/datum/cooking_item/CI = new(I, src)
	cooking_items += CI
	if(!active)
		active = TRUE

/obj/machinery/appliance/proc/can_accept_container(obj/item/reagent_containers/cooking_container/C, mob/user)
	if(!(C.appliancetype & appliance_flags))
		to_chat(user, span_warning("[C] doesn't fit on [src]!"))
		return FALSE
	if(length(cooking_items) >= max_contents)
		to_chat(user, span_warning("[src] is full!"))
		return FALSE
	return TRUE

/obj/machinery/appliance/proc/add_container(obj/item/reagent_containers/cooking_container/C, mob/user)
	cooking_contents += C
	for(var/obj/item/I in C.contents)
		var/datum/cooking_item/CI = new(I, src, C)
		cooking_items += CI
	if(!active)
		active = TRUE

/obj/machinery/appliance/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(length(cooking_contents))
		var/obj/item/reagent_containers/cooking_container/C = cooking_contents[length(cooking_contents)]
		C.forceMove(drop_location())
		user.put_in_hands(C)
		cooking_contents -= C
		for(var/datum/cooking_item/CI as anything in cooking_items)
			if(C && CI.target && CI.target.loc == C)
				cooking_items -= CI
				qdel(CI)
		to_chat(user, span_notice("You remove [C] from [src]."))
	else if(length(cooking_items))
		var/datum/cooking_item/CI = cooking_items[length(cooking_items)]
		var/obj/item/I = CI.target
		I.forceMove(drop_location())
		user.put_in_hands(I)
		cooking_items -= CI
		qdel(CI)
		to_chat(user, span_notice("You remove [I] from [src]."))
	else
		to_chat(user, span_warning("[src] is empty."))

/obj/machinery/appliance/verb/eject_all()
	set name = "Eject All Contents"
	set category = "Object"
	set src in view(1)
	if(usr.incapacitated())
		return
	var/ejected = 0
	for(var/obj/item/reagent_containers/cooking_container/C as anything in cooking_contents)
		C.forceMove(drop_location())
		cooking_contents -= C
		ejected++
	for(var/datum/cooking_item/CI as anything in cooking_items)
		if(CI.target && !(CI.target.loc in cooking_contents))
			CI.target.forceMove(drop_location())
			ejected++
		qdel(CI)
	cooking_items = list()
	if(ejected)
		to_chat(usr, span_notice("You eject [ejected] item\s from [src]."))
	else
		to_chat(usr, span_warning("[src] is empty."))

/obj/machinery/appliance/proc/set_cooking_power(new_power)
	cooking_power = new_power

/obj/machinery/appliance/RefreshParts()
	..()
	var/new_cooking_power = 1.0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		new_cooking_power += C.rating * 0.25
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		new_cooking_power += S.rating * 0.15
	set_cooking_power(new_cooking_power)

/obj/item/circuitboard/machine/appliance_board
	name = "cooking appliance (circuit board)"
	build_path = /obj/machinery/appliance
