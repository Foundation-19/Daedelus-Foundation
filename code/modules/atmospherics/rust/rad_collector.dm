/obj/machinery/power/rad_collector
	name = "radiation collector"
	desc = "A device that captures radiation and converts it into electrical power."
	icon = 'icons/obj/power.dmi'
	icon_state = "rtg"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE

	var/power_generation = 0
	var/max_power_generation = 75000
	var/efficiency = 0.3
	var/active = TRUE
	var/detected_radiation = 0
	var/obj/effect/reactor_em_field/nearby_field

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()
	connect_to_network()

/obj/machinery/power/rad_collector/process()
	if(!anchored || machine_stat & BROKEN)
		return

	if(!active)
		power_generation = 0
		return

	nearby_field = null
	for(var/obj/effect/reactor_em_field/field in range(7, src))
		nearby_field = field
		break

	if(!nearby_field)
		detected_radiation = 0
		power_generation = 0
		return

	detected_radiation = nearby_field.radiation + (nearby_field.plasma_temperature * 0.01)
	var/distance = get_dist(src, nearby_field)
	if(distance > 0)
		detected_radiation /= distance

	power_generation = min(detected_radiation * efficiency * 100, max_power_generation)

	if(power_generation > 0)
		add_avail(power_generation)

/obj/machinery/power/rad_collector/attack_hand(mob/user)
	active = !active
	visible_message(span_notice("[user] [active ? "activates" : "deactivates"] [src]."))
	if(!active)
		power_generation = 0

/obj/machinery/power/rad_collector/examine(mob/user)
	. = ..()
	. += "Status: [active ? "ACTIVE" : "INACTIVE"]"
	. += "Detected Radiation: [round(detected_radiation, 0.1)]"
	. += "Power Output: [round(power_generation)] W"
