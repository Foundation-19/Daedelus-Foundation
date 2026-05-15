/obj/machinery/power/foundation_reactor
	name = "Foundation Fusion Reactor"
	desc = "A compact fusion reactor that powers the entire facility. Handle with extreme care."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "reactor"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/active = FALSE
	var/power_output = 0
	var/max_output = 5000000
	var/temperature = 300
	var/max_temperature = 15000
	var/meltdown_threshold = 12000
	var/cooling_rate = 10
	var/decay_rate = 5
	var/destabilization = 0
	var/max_destabilization = 100
	var/meltdown_active = FALSE
	var/meltdown_timer = 0
	var/meltdown_warning_sent = FALSE

/obj/machinery/power/foundation_reactor/Initialize()
	. = ..()
	connect_to_network()

/obj/machinery/power/foundation_reactor/process()
	if(!active)
		temperature = max(temperature - cooling_rate, 300)
		power_output = 0
		update_icon()
		return

	if(meltdown_active)
		meltdown_timer--
		if(meltdown_timer <= 0)
			trigger_meltdown_explosion()
		return

	temperature = min(temperature + 15, max_temperature)
	power_output = (temperature / max_temperature) * max_output
	add_avail(power_output)

	destabilization = max(destabilization - decay_rate, 0)

	if(destabilization > 0)
		temperature += destabilization * 2

	if(temperature > meltdown_threshold)
		destabilization += 3

		if(!meltdown_warning_sent && temperature > meltdown_threshold * 1.1)
			meltdown_warning_sent = TRUE
			priority_announce("WARNING: Reactor core temperature exceeding safe limits. Meltdown imminent. All personnel evacuate immediately.", "REACTOR WARNING", "Critical Alert", ANNOUNCER_ALERT)

		if(destabilization >= max_destabilization)
			initiate_meltdown()

	update_icon()

/obj/machinery/power/foundation_reactor/proc/initiate_meltdown()
	if(meltdown_active)
		return

	meltdown_active = TRUE
	meltdown_timer = 300

	priority_announce("CRITICAL: Foundation Reactor MELTDOWN IN PROGRESS. Estimated time to core breach: 30 seconds. All personnel proceed to emergency shelters immediately. This is NOT a drill.", "REACTOR MELTDOWN", "EMERGENCY", ANNOUNCER_ALERT)

	if(GLOB.scp_admin_log)
		GLOB.scp_admin_log.log_event("reactor_meltdown", "N/A", "SYSTEM", "REACTOR", "Reactor meltdown initiated", 5)

	for(var/obj/machinery/light/L in range(50, src))
		if(prob(30))
			L.on = FALSE
			L.update()

/obj/machinery/power/foundation_reactor/proc/trigger_meltdown_explosion()
	meltdown_active = FALSE
	explosion(src, 10, 15, 25, 40)
	temperature = max_temperature
	power_output = 0
	active = FALSE

	radiation_pulse(src, 30, 0.5)

	for(var/obj/machinery/light/L in range(80, src))
		L.on = FALSE
		L.update()

	priority_announce("REACTOR CORE BREACH. Catastrophic failure confirmed. Facility structural integrity compromised.", "REACTOR FAILURE", "CRITICAL", ANNOUNCER_ALERT)

/obj/machinery/power/foundation_reactor/proc/cool_reactor(amount)
	temperature = max(temperature - amount, 300)
	destabilization = max(destabilization - amount / 5, 0)
	if(temperature < meltdown_threshold)
		meltdown_warning_sent = FALSE

/obj/machinery/power/foundation_reactor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		if(active)
			to_chat(user, span_warning("Cannot insert fuel rod while reactor is active!"))
			return
		var/obj/item/stack/S = I
		S.use(1)
		temperature += 500
		to_chat(user, span_notice("You insert the uranium fuel into the reactor."))
		return

	if(istype(I, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/G = I
		if(G.reagents?.has_reagent(/datum/reagent/water, 50))
			G.reagents.remove_reagent(/datum/reagent/water, 50)
			cool_reactor(2000)
			to_chat(user, span_notice("You pour water into the emergency coolant port. Temperature reduced."))
			return

	return ..()

/obj/machinery/power/foundation_reactor/attack_hand(mob/user)
	if(meltdown_active)
		to_chat(user, span_danger("The reactor is in meltdown! Evacuate immediately!"))
		return

	if(active)
		active = FALSE
		to_chat(user, span_notice("You shut down the reactor."))
		visible_message(span_warning("[src] powers down."))
		return

	active = TRUE
	to_chat(user, span_notice("You start up the reactor."))
	visible_message(span_warning("[src] hums to life!"))

/obj/machinery/power/foundation_reactor/examine(mob/user)
	. = ..()
	. += "Status: [active ? "ONLINE" : "OFFLINE"]"
	. += "Temperature: [temperature]K [temperature > meltdown_threshold ? " — CRITICAL!" : ""]"
	. += "Power Output: [power_output]W"
	. += "Destabilization: [destabilization]%"
	if(meltdown_active)
		. += span_danger("MELTDOWN IN PROGRESS — [meltdown_timer / 10] SECONDS TO CORE BREACH!")

/obj/machinery/power/foundation_reactor/update_icon()
	. = ..()
	if(meltdown_active)
		icon_state = "reactor_meltdown"
	else if(active)
		if(temperature > meltdown_threshold)
			icon_state = "reactor_critical"
		else
			icon_state = "reactor_active"
	else
		icon_state = "reactor"

/obj/machinery/computer/reactor_control
	name = "Reactor Control Console"
	desc = "A console for monitoring and controlling the Foundation fusion reactor."
	icon_screen = "power"
	icon_keyboard = "power_key"
	circuit = /obj/item/circuitboard/computer/reactor_control

/obj/machinery/computer/reactor_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReactorControl", "Reactor Control Console")
		ui.open()

/obj/machinery/computer/reactor_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/reactor_control/ui_data(mob/user)
	var/obj/machinery/power/foundation_reactor/reactor = null
	for(var/obj/machinery/power/foundation_reactor/R)
		if(get_dist(R, src) <= 20)
			reactor = R
			break
	var/list/data = list()

	if(!reactor)
		data["reactor_found"] = FALSE
		return data

	data["reactor_found"] = TRUE
	data["active"] = reactor.active
	data["temperature"] = reactor.temperature
	data["max_temperature"] = reactor.max_temperature
	data["meltdown_threshold"] = reactor.meltdown_threshold
	data["power_output"] = reactor.power_output
	data["max_output"] = reactor.max_output
	data["destabilization"] = reactor.destabilization
	data["max_destabilization"] = reactor.max_destabilization
	data["meltdown_active"] = reactor.meltdown_active
	data["meltdown_timer"] = reactor.meltdown_timer

	return data

/obj/machinery/computer/reactor_control/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/machinery/power/foundation_reactor/reactor = null
	for(var/obj/machinery/power/foundation_reactor/R)
		if(get_dist(R, src) <= 20)
			reactor = R
			break
	if(!reactor)
		return

	switch(action)
		if("toggle_reactor")
			if(reactor.meltdown_active)
				return
			reactor.active = !reactor.active
			return TRUE

		if("emergency_coolant")
			reactor.cool_reactor(3000)
			visible_message(span_danger("[src] injects emergency coolant into the reactor!"))
			playsound(loc, 'sound/machines/hiss.ogg', 50, TRUE)
			return TRUE

		if("scram")
			if(!reactor.active)
				return
			reactor.active = FALSE
			reactor.cool_reactor(1000)
			reactor.destabilization = max(reactor.destabilization - 30, 0)
			visible_message(span_danger("[src] initiates an emergency SCRAM of the reactor!"))
			playsound(loc, 'sound/machines/alarm.ogg', 100, TRUE)
			return TRUE

/obj/item/circuitboard/computer/reactor_control
	name = "Reactor Control Console (Computer Board)"
	build_path = /obj/machinery/computer/reactor_control
