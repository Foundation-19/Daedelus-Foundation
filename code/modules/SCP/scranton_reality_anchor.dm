#define TRAIT_REALITY_SUPPRESSED "reality_suppressed"

/datum/movespeed_modifier/reality_suppressed
	id = "reality_suppressed"
	slowdown = 3

/obj/machinery/scranton_reality_anchor
	name = "Scranton Reality Anchor"
	desc = "A humming cylindrical device that stabilizes local reality. Essential for containing reality-bending anomalies."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/scranton_reality_anchor

	var/active = FALSE
	var/range = 7
	var/hume_level = 100
	var/fuel_level = 100
	var/max_fuel = 100
	var/list/suppressed_mobs = list()
	var/vent_cooldown = 0

/obj/machinery/scranton_reality_anchor/process(delta_time)
	if(!active)
		hume_level = max(hume_level - 0.5, 0)
		update_icon()
		return

	if(fuel_level <= 0)
		visible_message(span_warning("[src] sputters and powers down! Out of fuel!"))
		deactivate()
		return

	fuel_level = max(0, fuel_level - 0.5)
	hume_level = min(100, hume_level + 2)

	suppressed_mobs = list()
	for(var/mob/living/L in range(range, src))
		if(L.stat == DEAD)
			continue
		if(!HAS_TRAIT(L, TRAIT_REALITY_MANIPULATION))
			continue
		suppressed_mobs += L
		if(!HAS_TRAIT(L, TRAIT_REALITY_SUPPRESSED))
			ADD_TRAIT(L, TRAIT_REALITY_SUPPRESSED, "scranton_anchor")
			L.add_movespeed_modifier(/datum/movespeed_modifier/reality_suppressed)
			visible_message(span_notice("[src] hums louder as it suppresses [L]!"))

	for(var/mob/living/L in suppressed_mobs)
		if(get_dist(src, L) > range || L.stat == DEAD)
			release_mob(L)

	update_icon()

/obj/machinery/scranton_reality_anchor/proc/release_mob(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_REALITY_SUPPRESSED, "scranton_anchor")
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reality_suppressed)
	suppressed_mobs -= L

/obj/machinery/scranton_reality_anchor/proc/deactivate()
	active = FALSE
	hume_level = max(hume_level - 20, 0)
	use_power = IDLE_POWER_USE
	for(var/mob/living/L in suppressed_mobs)
		release_mob(L)
	suppressed_mobs = list()
	update_icon()

/obj/machinery/scranton_reality_anchor/proc/activate()
	if(fuel_level <= 0)
		visible_message(span_warning("[src] has no fuel to activate!"))
		return
	active = TRUE
	use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/scranton_reality_anchor/update_icon()
	. = ..()
	if(active)
		icon_state = "hub_o"
		set_light(range, 2, LIGHT_COLOR_BLUE)
	else
		icon_state = "hub"
		set_light(0)

/obj/machinery/scranton_reality_anchor/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(!do_after(user, 3 SECONDS, src))
		return
	if(active)
		deactivate()
		to_chat(user, span_notice("You deactivate [src]. The Hume field dissipates."))
	else
		activate()
		to_chat(user, span_notice("You activate [src]. Reality stabilizes around you."))

/obj/machinery/scranton_reality_anchor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		if(fuel_level >= max_fuel)
			to_chat(user, span_notice("[src]'s fuel reservoir is full."))
			return
		var/obj/item/stack/sheet/mineral/plasma/P = I
		var/fuel_needed = max_fuel - fuel_level
		var/sheets_needed = ceil(fuel_needed / 20)
		var/sheets_used = min(P.amount, sheets_needed)
		P.use(sheets_used)
		fuel_level = min(max_fuel, fuel_level + (sheets_used * 20))
		to_chat(user, span_notice("You insert [sheets_used] plasma sheet\s into [src]. Fuel level: [fuel_level]%."))
		return
	return ..()

/obj/machinery/scranton_reality_anchor/examine(mob/user)
	. = ..()
	. += span_notice("Status: [active ? "ACTIVE" : "INACTIVE"]")
	. += span_notice("Fuel Level: [fuel_level]/[max_fuel]")
	. += span_notice("Hume Level: [hume_level]")
	. += span_notice("Range: [range] tiles")
	. += span_notice("Suppressed Entities: [length(suppressed_mobs)]")

/obj/machinery/scranton_reality_anchor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScrantonRealityAnchor", "Scranton Reality Anchor")
		ui.open()

/obj/machinery/scranton_reality_anchor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scranton_reality_anchor/ui_data(mob/user)
	var/list/data = list()
	data["active"] = active
	data["fuel_level"] = fuel_level
	data["max_fuel"] = max_fuel
	data["hume_level"] = hume_level
	data["range"] = range
	data["vent_cooldown"] = vent_cooldown > 0
	var/list/suppressed = list()
	for(var/mob/living/L in suppressed_mobs)
		suppressed += list(list(
			"name" = L.name,
			"health" = L.stat == DEAD ? 0 : round((L.health / L.maxHealth) * 100),
		))
	data["suppressed_entities"] = suppressed
	return data

/obj/machinery/scranton_reality_anchor/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_power")
			if(active)
				deactivate()
			else
				activate()
			. = TRUE
		if("set_range")
			var/new_range = text2num(params["range"])
			if(new_range in list(3, 5, 7, 10))
				range = new_range
				. = TRUE
		if("emergency_vent")
			if(vent_cooldown > world.time)
				return
			if(fuel_level <= 0)
				return
			var/vent_range = range * 2
			for(var/mob/living/L in range(vent_range, src))
				if(L.stat == DEAD)
					continue
				if(!HAS_TRAIT(L, TRAIT_REALITY_MANIPULATION))
					continue
				ADD_TRAIT(L, TRAIT_REALITY_SUPPRESSED, "scranton_anchor_vent")
				L.add_movespeed_modifier(/datum/movespeed_modifier/reality_suppressed)
				L.apply_damage(30, BURN)
				to_chat(L, span_userdanger("A wave of Hume energy sears your reality-bending essence!"))
			fuel_level = 0
			hume_level = 100
			vent_cooldown = world.time + 5 MINUTES
			visible_message(span_danger("[src] vents its entire fuel reserve in a massive Hume burst!"))
			empulse(get_turf(src), 2, 4)
			deactivate()
			. = TRUE

/obj/machinery/scranton_reality_anchor/Destroy()
	for(var/mob/living/L in suppressed_mobs)
		REMOVE_TRAIT(L, TRAIT_REALITY_SUPPRESSED, "scranton_anchor")
		L.remove_movespeed_modifier(/datum/movespeed_modifier/reality_suppressed)
	suppressed_mobs = null
	return ..()

/obj/item/circuitboard/machine/scranton_reality_anchor
	name = "Scranton Reality Anchor (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/scranton_reality_anchor
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stack/sheet/mineral/plasma = 5,
		/obj/item/stack/cable_coil = 2)
