/obj/machinery/appliance/cooker
	name = "cooker"
	desc = "A temperature-based cooking appliance."
	var/min_temp = 100
	var/optimal_temp = 300
	var/max_temp = 500
	var/set_temp = 300
	var/heating_power = 10
	var/current_temp = T20C
	var/cooking_coeff = 1.0
	appliance_flags = NONE

/obj/machinery/appliance/cooker/process(delta_time)
	if(!powered())
		if(current_temp > T20C)
			current_temp = max(T20C, current_temp - 5 * delta_time)
		active = FALSE
		return
	if(active)
		var/target_temp = set_temp
		if(current_temp < target_temp)
			current_temp = min(target_temp, current_temp + heating_power * delta_time)
		else if(current_temp > target_temp)
			current_temp = max(target_temp, current_temp - heating_power * 0.5 * delta_time)
		efficiency = get_efficiency()
		if(efficiency <= 0)
			return
	else
		if(current_temp > T20C)
			current_temp = max(T20C, current_temp - 3 * delta_time)
		return
	for(var/datum/cooking_item/CI as anything in cooking_items)
		if(QDELETED(CI.target))
			cooking_items -= CI
			qdel(CI)
			continue
		var/cook_increment = cooking_power * efficiency * delta_time * 10
		CI.cookwork += cook_increment
		if(CI.target.reagents)
			CI.target.reagents.expose_temperature(current_temp)
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

/obj/machinery/appliance/cooker/proc/get_efficiency()
	if(current_temp < min_temp)
		return 0
	var/distance = abs(current_temp - optimal_temp)
	var/range = max_temp - min_temp
	return max(0, 1 - (distance / range) * 0.8) * cooking_coeff

/obj/machinery/appliance/cooker/examine(mob/user)
	. = ..()
	. += span_notice("Temperature: [round(current_temp)]K (optimal: [optimal_temp]K)")
	if(length(cooking_items))
		. += span_notice("Cooking [length(cooking_items)] item\s.")
		for(var/datum/cooking_item/CI as anything in cooking_items)
			if(CI.target)
				var/progress = min(100, round(CI.cookwork / CI.max_cookwork * 100))
				. += span_notice("  [CI.target]: [progress]% done")
	else
		. += span_notice("No items cooking.")

/obj/machinery/appliance/cooker/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/appliance/cooker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApplianceCooker", name)
		ui.open()

/obj/machinery/appliance/cooker/ui_data(mob/user)
	var/list/data = list()
	data["active"] = active
	data["current_temp"] = round(current_temp, 1)
	data["set_temp"] = set_temp
	data["min_temp"] = min_temp
	data["max_temp"] = max_temp
	data["optimal_temp"] = optimal_temp
	data["efficiency"] = round(efficiency * 100)
	var/list/contents_data = list()
	for(var/datum/cooking_item/CI as anything in cooking_items)
		if(CI.target)
			var/progress = min(100, round(CI.cookwork / CI.max_cookwork * 100))
			var/overcook_progress = CI.cookwork >= CI.max_cookwork ? round((CI.cookwork - CI.max_cookwork) / (CI.max_cookwork * CI.overcook_mult - CI.max_cookwork) * 100) : 0
			contents_data += list(list(
				"name" = CI.target.name,
				"progress" = progress,
				"overcook" = overcook_progress,
			))
	data["contents"] = contents_data
	return data

/obj/machinery/appliance/cooker/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle")
			active = !active
			. = TRUE
		if("set_temp")
			var/new_temp = text2num(params["temperature"])
			if(new_temp != null)
				set_temp = clamp(new_temp, min_temp, max_temp)
				. = TRUE

/obj/machinery/appliance/cooker/RefreshParts()
	. = ..()
	var/new_coeff = 1.0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		new_coeff += M.rating * 0.1
	cooking_coeff = new_coeff
