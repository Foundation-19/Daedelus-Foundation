/obj/machinery/appliance/cooker/oven
	name = "oven"
	desc = "A temperature-controlled oven for baking and roasting."
	icon_state = "grill"
	appliance_flags = APPLIANCE_OVEN
	cook_type = "baked"
	min_temp = 100
	optimal_temp = 350
	max_temp = 500
	set_temp = 350
	heating_power = 15
	max_contents = 6
	circuit = /obj/item/circuitboard/machine/oven

/obj/machinery/appliance/cooker/oven/RefreshParts()
	. = ..()

/obj/item/circuitboard/machine/oven
	name = "Oven (Machine Board)"
	build_path = /obj/machinery/appliance/cooker/oven
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/machinery/appliance/cooker/grill
	name = "grill"
	desc = "A fuel-powered grill for cooking meats and vegetables."
	icon_state = "grill"
	appliance_flags = APPLIANCE_GRILL
	cook_type = "grilled"
	min_temp = 150
	optimal_temp = 400
	max_temp = 600
	set_temp = 400
	heating_power = 12
	max_contents = 4
	can_cook_mobs = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	var/grill_fuel = 0
	var/max_fuel = 100
	var/fuel_idle_drain = 0.5
	var/fuel_active_drain = 5

/obj/machinery/appliance/cooker/grill/examine(mob/user)
	. = ..()
	. += span_notice("Fuel: [round(grill_fuel)]/[max_fuel]")
	if(grill_fuel <= 0)
		. += span_warning("The grill has no fuel! Add coal or wood.")

/obj/machinery/appliance/cooker/grill/process(delta_time)
	if(grill_fuel <= 0)
		active = FALSE
		return
	if(active)
		grill_fuel = max(0, grill_fuel - fuel_active_drain * delta_time)
	else
		grill_fuel = max(0, grill_fuel - fuel_idle_drain * delta_time)
	current_temp = active ? set_temp : max(T20C, current_temp - 3 * delta_time)
	return ..()

/obj/machinery/appliance/cooker/grill/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/coal) || istype(I, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/S = I
		var/amount = min(S.amount, ceil((max_fuel - grill_fuel) / 10))
		if(amount > 0)
			S.use(amount)
			grill_fuel = min(max_fuel, grill_fuel + amount * 10)
			to_chat(user, span_notice("You add fuel to [src]. Fuel: [round(grill_fuel)]%"))
			return
	return ..()

/obj/machinery/appliance/cooker/grill/powered()
	return grill_fuel > 0

/obj/item/circuitboard/machine/grill
	name = "Grill (Machine Board)"
	build_path = /obj/machinery/appliance/cooker/grill
	req_components = list()

/obj/machinery/appliance/cooker/fryer
	name = "deep fryer"
	desc = "A deep fryer for cooking food in hot oil."
	icon_state = "fryer_off"
	appliance_flags = APPLIANCE_FRYER
	cook_type = "fried"
	min_temp = 150
	optimal_temp = 190
	max_temp = 250
	set_temp = 190
	heating_power = 20
	max_contents = 3
	var/oil_level = 100
	var/oil_use_rate = 0.2

/obj/machinery/appliance/cooker/fryer/examine(mob/user)
	. = ..()
	. += span_notice("Oil level: [round(oil_level)]%")
	if(oil_level <= 0)
		. += span_warning("The fryer has no cooking oil! Add oil to use it.")

/obj/machinery/appliance/cooker/fryer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers) && !istype(I, /obj/item/reagent_containers/cooking_container))
		var/obj/item/reagent_containers/RC = I
		if(RC.reagents && RC.reagents.has_reagent(/datum/reagent/consumable/cooking_oil))
			var/amount = min(RC.reagents.get_reagent_amount(/datum/reagent/consumable/cooking_oil), 100 - oil_level)
			if(amount <= 0)
				to_chat(user, span_warning("[src] is already full of oil!"))
				return
			RC.reagents.remove_reagent(/datum/reagent/consumable/cooking_oil, amount)
			oil_level = min(100, oil_level + amount)
			to_chat(user, span_notice("You add cooking oil to [src]. Oil level: [round(oil_level)]%"))
			return
	return ..()

/obj/machinery/appliance/cooker/fryer/process(delta_time)
	if(oil_level <= 0)
		active = FALSE
		return
	if(active)
		oil_level = max(0, oil_level - oil_use_rate * delta_time * length(cooking_items))
	return ..()

/obj/machinery/appliance/cooker/fryer/can_add_item(obj/item/I, mob/user)
	if(oil_level <= 0)
		to_chat(user, span_warning("[src] has no cooking oil!"))
		return FALSE
	if(istype(I, /obj/item/food/deepfryholder))
		to_chat(user, span_warning("You can't double-fry that!"))
		return FALSE
	return ..()

/obj/machinery/appliance/cooker/microwave
	name = "microwave"
	desc = "A microwave for quick heating and cooking."
	icon_state = "mw"
	appliance_flags = APPLIANCE_MICROWAVE
	cook_type = "microwaved"
	min_temp = 50
	optimal_temp = 100
	max_temp = 150
	set_temp = 100
	heating_power = 30
	max_contents = 10
	var/dirty = 0
	var/dirty_max = 50
	var/broken = FALSE

/obj/machinery/appliance/cooker/microwave/examine(mob/user)
	. = ..()
	if(broken)
		. += span_warning("It is broken!")
	else if(dirty >= dirty_max)
		. += span_warning("It is too dirty to use! Clean it with a spray or soap.")
	else if(dirty > dirty_max * 0.5)
		. += span_warning("It looks quite dirty.")

/obj/machinery/appliance/cooker/microwave/can_add_item(obj/item/I, mob/user)
	if(broken)
		to_chat(user, span_warning("[src] is broken!"))
		return FALSE
	if(dirty >= dirty_max)
		to_chat(user, span_warning("[src] is too dirty to use!"))
		return FALSE
	if(I.has_material_type(/datum/material/iron) || I.has_material_type(/datum/material/plasma))
		if(prob(dirty * 2))
			broken = TRUE
			visible_message(span_danger("[src] sparks and breaks!"))
			return FALSE
	return ..()

/obj/machinery/appliance/cooker/microwave/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/spray) || istype(I, /obj/item/soap))
		if(dirty > 0)
			dirty = max(0, dirty - 25)
			to_chat(user, span_notice("You clean [src]."))
			return
	return ..()

/obj/machinery/appliance/cooker/microwave/process(delta_time)
	if(broken)
		return
	if(active)
		dirty = min(dirty_max, dirty + 0.1 * delta_time * length(cooking_items))
	return ..()

/obj/item/circuitboard/machine/microwave
	name = "Microwave (Machine Board)"
	build_path = /obj/machinery/appliance/cooker/microwave
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/machinery/appliance/cooker/stove
	name = "stove"
	desc = "A multi-burner stove for cooking with pots, pans, and skillets."
	icon_state = "grill_open"
	appliance_flags = APPLIANCE_SKILLET | APPLIANCE_SAUCEPAN | APPLIANCE_POT
	cook_type = "cooked"
	min_temp = 50
	optimal_temp = 300
	max_temp = 500
	set_temp = 300
	heating_power = 15
	max_contents = 8

/obj/machinery/appliance/cooker/stove/can_add_item(obj/item/I, mob/user)
	to_chat(user, span_warning("Use a cooking container like a pot or skillet on [src]!"))
	return FALSE

/obj/item/circuitboard/machine/stove
	name = "Stove (Machine Board)"
	build_path = /obj/machinery/appliance/cooker/stove
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 2,
	)

/obj/machinery/appliance/cooker/griddle
	name = "griddle"
	desc = "A flat-top electric griddle for cooking multiple items at once."
	icon_state = "gridle"
	appliance_flags = APPLIANCE_GRILL
	cook_type = "griddled"
	min_temp = 100
	optimal_temp = 350
	max_temp = 450
	set_temp = 350
	heating_power = 18
	max_contents = 8

/obj/item/circuitboard/machine/griddle
	name = "Griddle (Machine Board)"
	build_path = /obj/machinery/appliance/cooker/griddle
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 2,
	)
