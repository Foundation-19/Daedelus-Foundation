/obj/machinery/fusion_fuel_injector
	name = "fuel injector"
	desc = "Injects fusion fuel gases into the nearby environment for uptake by an electromagnetic field."
	icon = 'icons/obj/machines/rust/fusion_core.dmi'
	icon_state = "core0"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 500

	var/inject_rate = 10
	var/active = FALSE
	var/initial_id_tag

/obj/machinery/fusion_fuel_injector/mapped
	initial_id_tag = ""

/obj/machinery/fusion_fuel_injector/Initialize(mapload)
	. = ..()
	if(initial_id_tag)
		name = "[name] ([initial_id_tag])"

/obj/machinery/fusion_fuel_injector/process()
	if(!active)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		active = FALSE
		update_icon()
		return

	var/datum/gas_mixture/env = loc.return_air()
	if(!env)
		return

	var/datum/gas_mixture/to_inject = new
	to_inject.adjustGas(GAS_DEUTERIUM, inject_rate)
	to_inject.temperature = T20C

	env.merge(to_inject)
	use_power(active_power_usage)

/obj/machinery/fusion_fuel_injector/attack_hand(mob/user)
	if(machine_stat & BROKEN)
		return
	active = !active
	if(active)
		START_PROCESSING(SSobj, src)
		visible_message(span_notice("[src] hums to life."))
	else
		visible_message(span_notice("[src] winds down."))
	update_icon()

/obj/machinery/fusion_fuel_injector/update_icon()
	. = ..()
	if(active)
		icon_state = "core1"
	else
		icon_state = "core0"
