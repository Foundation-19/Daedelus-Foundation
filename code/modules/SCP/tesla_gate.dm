#define TESLA_GATE_INACTIVE 0
#define TESLA_GATE_ACTIVE 1
#define TESLA_GATE_OVERLOADED 2

/obj/machinery/tesla_gate
	name = "Tesla Gate"
	desc = "A high-voltage containment gate. When activated, it generates a lethal electrical arc between its coils."
	icon = 'icons/obj/machines/scangate.dmi'
	icon_state = "scangate0"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 500

	var/gate_state = TESLA_GATE_INACTIVE
	var/damage = 60
	var/stun_duration = 10 SECONDS
	var/activation_delay = 3 SECONDS
	var/warning_sound = 'sound/machines/defib_zap.ogg'
	var/cooldown = 0
	var/cooldown_time = 5 SECONDS
	var/warning_message = "WARNING: TESLA GATE ACTIVATION IN PROGRESS."
	var/linked_gate_id
	var/obj/machinery/tesla_gate/linked_gate
	var/auto_mode = FALSE
	var/auto_range = 5

/obj/machinery/tesla_gate/Initialize(mapload)
	. = ..()
	SET_TRACKING(__TYPE__)
	find_linked_gate()

/obj/machinery/tesla_gate/Destroy()
	UNSET_TRACKING(__TYPE__)
	return ..()

/obj/machinery/tesla_gate/proc/find_linked_gate()
	if(!linked_gate_id)
		return
	for(var/obj/machinery/tesla_gate/T in INSTANCES_OF(/obj/machinery/tesla_gate))
		if(T != src && T.linked_gate_id == linked_gate_id)
			linked_gate = T
			T.linked_gate = src
			break

/obj/machinery/tesla_gate/process()
	if(gate_state == TESLA_GATE_ACTIVE)
		if(!powered())
			deactivate()
			return
		for(var/mob/living/L in get_turf(src))
			if(L.stat == DEAD)
				continue
			if(istype(L, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = L
				var/obj/item/card/id/id_card = H.get_idcard(TRUE)
				if(id_card && (ACCESS_SECURITY in id_card.access))
					continue
				if(id_card && (ACCESS_MTF in id_card.access))
					continue
			tesla_shock(L)

/obj/machinery/tesla_gate/proc/tesla_shock(mob/living/target)
	if(cooldown > world.time)
		return
	cooldown = world.time + cooldown_time
	target.electrocute_act(damage, src, 1, TRUE, FALSE)
	playsound(src, 'sound/effects/electric_shock_short.ogg', 80, TRUE)
	visible_message(span_danger("[src] arcs with electricity, shocking [target]!"))

/obj/machinery/tesla_gate/proc/activate(mob/user)
	if(gate_state == TESLA_GATE_ACTIVE)
		return
	if(!powered())
		return
	visible_message(span_warning("[warning_message]"))
	playsound(src, 'sound/machines/defib_charge.ogg', 60, TRUE)
	addtimer(CALLBACK(src, .proc/complete_activation), activation_delay)

/obj/machinery/tesla_gate/proc/complete_activation()
	gate_state = TESLA_GATE_ACTIVE
	use_power = ACTIVE_POWER_USE
	playsound(src, 'sound/machines/defib_zap.ogg', 80, TRUE)
	visible_message(span_danger("[src] HUMS with lethal electrical energy!"))
	if(linked_gate && linked_gate.gate_state != TESLA_GATE_ACTIVE)
		linked_gate.complete_activation()

/obj/machinery/tesla_gate/proc/deactivate()
	gate_state = TESLA_GATE_INACTIVE
	use_power = IDLE_POWER_USE
	visible_message(span_notice("[src] powers down, the electrical arc fading."))
	if(linked_gate && linked_gate.gate_state == TESLA_GATE_ACTIVE)
		linked_gate.deactivate()

/obj/machinery/tesla_gate/proc/overload()
	if(!powered())
		return
	gate_state = TESLA_GATE_OVERLOADED
	damage = 150
	visible_message(span_userdanger("[src] OVERLOADS! The electrical arc intensifies massively!"))
	playsound(src, 'sound/effects/electric_shock_short.ogg', 100, TRUE)
	for(var/mob/living/L in range(2, src))
		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			var/obj/item/card/id/id_card = H.get_idcard(TRUE)
			if(id_card && (ACCESS_SECURITY in id_card.access))
				continue
		tesla_shock(L)
	addtimer(CALLBACK(src, .proc/deactivate), 30 SECONDS)

/obj/machinery/tesla_gate/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpTeslaGate", "SCP FOUNDATION — TESLA GATE CONTROL")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/tesla_gate/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/tesla_gate/ui_data(mob/user)
	var/list/data = list()
	data["gate_state"] = gate_state
	data["damage"] = damage
	data["cooldown_active"] = (cooldown > world.time)
	data["cooldown_remaining"] = max(0, cooldown - world.time)
	data["auto_mode"] = auto_mode
	data["has_linked"] = !!linked_gate
	data["linked_active"] = linked_gate?.gate_state == TESLA_GATE_ACTIVE
	data["power_available"] = powered()
	return data

/obj/machinery/tesla_gate/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(H, span_warning("Requires Security access."))
		return

	switch(action)
		if("activate")
			activate(H)
			. = TRUE
		if("deactivate")
			deactivate()
			. = TRUE
		if("overload")
			var/confirm = alert(H, "Overload the Tesla Gate? This will create a massively dangerous electrical arc for 30 seconds.", "OVERLOAD", "Confirm", "Cancel")
			if(confirm == "Confirm")
				overload()
			. = TRUE
		if("toggle_auto")
			auto_mode = !auto_mode
			. = TRUE

/obj/machinery/tesla_gate/attack_hand(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/machinery/tesla_gate/examine(mob/user)
	. = ..()
	switch(gate_state)
		if(TESLA_GATE_INACTIVE)
			. += span_notice("The gate is inactive. Electrical coils dormant.")
		if(TESLA_GATE_ACTIVE)
			. += span_danger("The gate is ACTIVE! Lethal electrical arc present!")
		if(TESLA_GATE_OVERLOADED)
			. += span_userdanger("The gate is OVERLOADED! EXTREMELY DANGEROUS!")
