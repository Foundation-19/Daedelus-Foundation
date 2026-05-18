/obj/machinery/fusion_fuel_compressor
	name = "fuel compressor"
	desc = "Compresses gases into fuel rods for use in the R-UST fusion reactor."
	icon = 'icons/obj/machines/rust/fusion_core.dmi'
	icon_state = "core0"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 1000
	circuit = /obj/item/circuitboard/machine/fusion_fuel_compressor

	var/processing = FALSE
	var/compression_time = 10 SECONDS
	var/gas_type = GAS_DEUTERIUM
	var/gas_amount = FUEL_ROD_GAS_VOLUME

/obj/machinery/fusion_fuel_compressor/attack_hand(mob/user)
	if(processing)
		to_chat(user, span_warning("[src] is currently compressing fuel."))
		return

	var/list/choices = list(
		"Deuterium" = GAS_DEUTERIUM,
		"Tritium" = GAS_TRITIUM,
		"Hydrogen" = GAS_HYDROGEN,
		"Helium" = GAS_HELIUM,
		"Boron" = GAS_BORON,
		"Oxygen" = GAS_OXYGEN,
		"Plasma" = GAS_PLASMA
	)

	var/choice = input(user, "Select fuel gas type:", "Fuel Compressor") as null|anything in choices
	if(!choice || !Adjacent(user))
		return

	gas_type = choices[choice]
	processing = TRUE
	update_icon()
	visible_message(span_notice("[src] begins compressing [choice] gas into a fuel rod..."))
	addtimer(CALLBACK(src, PROC_REF(complete_compression), user), compression_time)

/obj/machinery/fusion_fuel_compressor/proc/complete_compression(mob/user)
	processing = FALSE
	update_icon()

	var/obj/item/fuel_rod/gas/rod = new(get_turf(src))
	rod.name = "fuel rod ([gas_type])"
	rod.rod_type = ROD_FUEL
	rod.air_contents.adjustGas(gas_type, gas_amount)
	rod.exposure_rate = 0.05

	visible_message(span_notice("[src] dispenses a [gas_type] fuel rod."))
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)

/obj/machinery/fusion_fuel_compressor/update_icon()
	if(processing)
		icon_state = "core1"
	else
		icon_state = "core0"
