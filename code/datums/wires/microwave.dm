/datum/wires/microwave
	holder_type = /obj/machinery/appliance/cooker/microwave
	proper_name = "Microwave"

/datum/wires/microwave/New(atom/holder)
	wires = list(
		WIRE_ACTIVATE
	)
	..()

/datum/wires/microwave/interactable(mob/user)
	if(!..())
		return FALSE
	. = FALSE
	var/obj/machinery/appliance/cooker/microwave/M = holder
	if(M.panel_open)
		. = TRUE

/datum/wires/microwave/on_pulse(wire)
	var/obj/machinery/appliance/cooker/microwave/M = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			M.active = !M.active

/datum/wires/microwave/on_cut(wire, mend)
	var/obj/machinery/appliance/cooker/microwave/M = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			M.broken = !mend
