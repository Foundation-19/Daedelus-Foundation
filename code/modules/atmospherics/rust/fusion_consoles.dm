/obj/machinery/computer/fusion
	name = "fusion control console"
	desc = "A console for monitoring and controlling the R-UST fusion reactor."
	icon_screen = "power"
	icon_keyboard = "power_key"
	circuit = /obj/item/circuitboard/computer/fusion

/obj/machinery/computer/fusion/core_control
	name = "fusion core control console"
	desc = "Controls the R-UST reactor core - field strength, startup, and shutdown."
	circuit = /obj/item/circuitboard/computer/fusion/core_control
	var/obj/machinery/power/reactor_core/linked_core

/obj/machinery/computer/fusion/core_control/Initialize(mapload)
	. = ..()
	find_core()

/obj/machinery/computer/fusion/core_control/proc/find_core()
	for(var/obj/machinery/power/reactor_core/C in range(20, src))
		linked_core = C
		break

/obj/machinery/computer/fusion/core_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FusionCoreControl", name)
		ui.open()

/obj/machinery/computer/fusion/core_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/fusion/core_control/ui_data(mob/user)
	var/list/data = list()
	data["core_found"] = !!linked_core

	if(!linked_core)
		return data

	data["is_on"] = linked_core.is_on
	data["field_strength"] = linked_core.field_strength
	data["max_field_strength"] = 10000

	if(linked_core.owned_field)
		var/obj/effect/reactor_em_field/field = linked_core.owned_field
		data["plasma_temperature"] = field.plasma_temperature
		data["energy"] = field.energy
		data["size"] = field.size
		data["percent_unstable"] = field.percent_unstable
		data["radiation"] = field.radiation

		var/list/reactant_data = list()
		for(var/reactant in field.reactants)
			reactant_data += list(list("name" = reactant, "amount" = field.reactants[reactant]))
		data["reactants"] = reactant_data
	else
		data["plasma_temperature"] = 0
		data["energy"] = 0
		data["size"] = 0
		data["percent_unstable"] = 0
		data["radiation"] = 0
		data["reactants"] = list()

	var/list/rod_data = list()
	for(var/slot in linked_core.rods_by_slot)
		var/obj/item/fuel_rod/rod = linked_core.rods_by_slot[slot]
		if(rod)
			rod_data += list(list("slot" = slot, "name" = rod.name, "type" = rod.rod_type))
		else
			rod_data += list(list("slot" = slot, "name" = "Empty", "type" = 0))
	data["rods"] = rod_data

	return data

/obj/machinery/computer/fusion/core_control/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!linked_core)
		find_core()
		if(!linked_core)
			return

	switch(action)
		if("toggle_core")
			if(linked_core.is_on)
				linked_core.Shutdown()
			else
				linked_core.Startup()
			return TRUE

		if("set_strength")
			var/value = text2num(params["value"])
			if(!isnull(value))
				linked_core.set_strength(round(value))
			return TRUE

		if("jumpstart")
			linked_core.Jumpstart(10000)
			return TRUE

		if("emergency_shutdown")
			linked_core.Shutdown(force_rupture = TRUE)
			return TRUE

		if("eject_rod")
			var/slot = params["slot"]
			var/obj/item/fuel_rod/rod = linked_core.rods_by_slot[slot]
			if(rod)
				rod.remove()
			return TRUE


/obj/machinery/computer/fusion/fuel_control
	name = "fuel control console"
	desc = "Controls the fuel injection system for the R-UST reactor."
	circuit = /obj/item/circuitboard/computer/fusion/fuel_control
	var/list/linked_injectors = list()

/obj/machinery/computer/fusion/fuel_control/Initialize(mapload)
	. = ..()
	find_injectors()

/obj/machinery/computer/fusion/fuel_control/proc/find_injectors()
	linked_injectors = list()
	for(var/obj/machinery/fusion_fuel_injector/I in range(15, src))
		linked_injectors += I

/obj/machinery/computer/fusion/fuel_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FusionFuelControl", name)
		ui.open()

/obj/machinery/computer/fusion/fuel_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/fusion/fuel_control/ui_data(mob/user)
	var/list/data = list()

	var/list/injector_data = list()
	for(var/obj/machinery/fusion_fuel_injector/I as anything in linked_injectors)
		injector_data += list(list(
			"ref" = REF(I),
			"name" = I.name,
			"active" = I.active,
			"inject_rate" = I.inject_rate
		))
	data["injectors"] = injector_data

	var/obj/machinery/power/reactor_core/core
	for(var/obj/machinery/power/reactor_core/C in range(20, src))
		core = C
		break

	data["core_found"] = !!core
	if(core?.owned_field)
		var/obj/effect/reactor_em_field/field = core.owned_field
		var/list/reactant_data = list()
		for(var/reactant in field.reactants)
			reactant_data += list(list("name" = reactant, "amount" = field.reactants[reactant]))
		data["reactants"] = reactant_data
		data["plasma_temperature"] = field.plasma_temperature
	else
		data["reactants"] = list()
		data["plasma_temperature"] = 0

	return data

/obj/machinery/computer/fusion/fuel_control/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_injector")
			var/obj/machinery/fusion_fuel_injector/I = locate(params["ref"]) in linked_injectors
			if(I)
				I.active = !I.active
				if(I.active)
					START_PROCESSING(SSobj, I)
				I.update_icon()
			return TRUE

		if("set_rate")
			var/obj/machinery/fusion_fuel_injector/I = locate(params["ref"]) in linked_injectors
			var/rate = text2num(params["rate"])
			if(I && !isnull(rate))
				I.inject_rate = clamp(round(rate), 1, 50)
			return TRUE


/obj/machinery/computer/fusion/gyrotron
	name = "gyrotron control console"
	desc = "Controls the gyrotron emitters that inject energy into the electromagnetic field."
	circuit = /obj/item/circuitboard/computer/fusion/gyrotron
	var/list/linked_gyrotrons = list()

/obj/machinery/computer/fusion/gyrotron/Initialize(mapload)
	. = ..()
	find_gyrotrons()

/obj/machinery/computer/fusion/gyrotron/proc/find_gyrotrons()
	linked_gyrotrons = list()
	for(var/obj/machinery/power/emitter/gyrotron/G in range(15, src))
		linked_gyrotrons += G

/obj/machinery/computer/fusion/gyrotron/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FusionGyroControl", name)
		ui.open()

/obj/machinery/computer/fusion/gyrotron/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/fusion/gyrotron/ui_data(mob/user)
	var/list/data = list()

	var/list/gyro_data = list()
	for(var/obj/machinery/power/emitter/gyrotron/G as anything in linked_gyrotrons)
		gyro_data += list(list(
			"ref" = REF(G),
			"name" = G.name,
			"active" = G.active,
			"energy" = G.mega_energy,
			"fire_delay" = G.fire_delay
		))
	data["gyrotrons"] = gyro_data

	var/obj/machinery/power/reactor_core/core
	for(var/obj/machinery/power/reactor_core/C in range(20, src))
		core = C
		break

	data["core_found"] = !!core
	if(core?.owned_field)
		data["plasma_temperature"] = core.owned_field.plasma_temperature
		data["percent_unstable"] = core.owned_field.percent_unstable
	else
		data["plasma_temperature"] = 0
		data["percent_unstable"] = 0

	return data

/obj/machinery/computer/fusion/gyrotron/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_gyrotron")
			var/obj/machinery/power/emitter/gyrotron/G = locate(params["ref"]) in linked_gyrotrons
			if(G)
				G.active = !G.active
				if(G.active)
					START_PROCESSING(SSobj, G)
				G.update_icon()
			return TRUE

		if("set_energy")
			var/obj/machinery/power/emitter/gyrotron/G = locate(params["ref"]) in linked_gyrotrons
			var/val = text2num(params["value"])
			if(G && !isnull(val))
				G.mega_energy = clamp(round(val), 0, 50)
			return TRUE
