// Dedicated Breach Sirens
// Physical siren objects placed in facility that activate on containment breach
// Different tones for different breach severity
// Also handles visual breach indicators: lights flash red, zone bulkheads auto-lock

/obj/machinery/breach_siren
	name = "containment breach siren"
	desc = "A heavy-duty siren that activates during containment breach events. Do not tamper."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 200
	max_integrity = 200
	integrity_failure = 0.5

	var/active = FALSE
	var/siren_type = "breach"
	var/sound_range = 25
	var/cycle_cooldown = 0
	var/cycle_interval = 8 SECONDS
	var/cycle_timerid
	var/zone_type = ""

/obj/machinery/breach_siren/Initialize()
	. = ..()
	detect_zone()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_changed))

/obj/machinery/breach_siren/Destroy()
	if(active)
		deactivate()
	return ..()

/obj/machinery/breach_siren/proc/detect_zone()
	var/area/A = get_area(src)
	if(!A)
		return
	if(istype(A, /area/scp/lcz))
		zone_type = "lcz"
	else if(istype(A, /area/scp/hcz))
		zone_type = "hcz"
	else if(istype(A, /area/scp/ez))
		zone_type = "ez"
	else if(istype(A, /area/scp/dclass))
		zone_type = "dclass"
	else if(istype(A, /area/scp/surface))
		zone_type = "surface"

/obj/machinery/breach_siren/proc/on_security_level_changed(datum/source, new_level)
	SIGNAL_HANDLER
	if(machine_stat & BROKEN)
		return
	switch(new_level)
		if(SEC_LEVEL_GREEN)
			if(active)
				deactivate()
		if(SEC_LEVEL_BLUE)
			if(active)
				deactivate()
			activate_yellow()
		if(SEC_LEVEL_RED)
			activate("breach")
			trigger_visual_breach_indicators()
		if(SEC_LEVEL_DELTA)
			activate("critical")
			trigger_visual_breach_indicators()

/obj/machinery/breach_siren/proc/activate(new_type)
	if(active || (machine_stat & BROKEN) || !powered())
		return
	active = TRUE
	siren_type = new_type
	use_power = ACTIVE_POWER_USE
	update_icon()
	begin_cycle()

/obj/machinery/breach_siren/proc/activate_yellow()
	if(machine_stat & BROKEN || !powered())
		return
	playsound(src, 'sound/machines/twobeep.ogg', 60, FALSE, sound_range)
	set_light(3, 2, LIGHT_COLOR_DIM_YELLOW)
	addtimer(CALLBACK(src, PROC_REF(clear_yellow_light)), 3 SECONDS)

/obj/machinery/breach_siren/proc/clear_yellow_light()
	set_light(0)

/obj/machinery/breach_siren/proc/deactivate()
	active = FALSE
	use_power = IDLE_POWER_USE
	cycle_cooldown = 0
	deltimer(cycle_timerid)
	cycle_timerid = null
	update_icon()

/obj/machinery/breach_siren/proc/begin_cycle()
	if(!active)
		return
	play_siren_sound()
	cycle_cooldown = world.time + cycle_interval
	cycle_timerid = addtimer(CALLBACK(src, PROC_REF(begin_cycle)), cycle_interval, TIMER_STOPPABLE)

/obj/machinery/breach_siren/proc/play_siren_sound()
	if(!active || (machine_stat & BROKEN) || !powered())
		deactivate()
		return
	var/sound_file = 'sound/machines/alarm.ogg'
	switch(siren_type)
		if("breach")
			sound_file = 'sound/machines/alarm.ogg'
		if("critical")
			sound_file = 'sound/machines/alarm.ogg'
	playsound(src, sound_file, 80, FALSE, sound_range)

/obj/machinery/breach_siren/update_icon()
	. = ..()
	if(active && powered())
		icon_state = "flasher_on"
		set_light(3, 2, LIGHT_COLOR_INTENSE_RED)
	else
		icon_state = "flasher"
		set_light(0)

/obj/machinery/breach_siren/attack_hand(mob/user)
	if(!active)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(H, span_warning("You cannot silence the breach siren without command authorization."))
		return
	deactivate()
	to_chat(H, span_notice("You silence the breach siren."))

/obj/machinery/breach_siren/emp_act(severity)
	. = ..()
	if(active)
		deactivate()

/obj/machinery/breach_siren/proc/trigger_visual_breach_indicators()
	set waitfor = FALSE
	var/area/my_area = get_area(src)
	if(!my_area)
		return
	for(var/obj/machinery/light/L in my_area)
		if(QDELETED(L) || !L.on)
			continue
		if(prob(60))
			L.on = TRUE
			L.color = LIGHT_COLOR_INTENSE_RED
			L.update()
	for(var/obj/machinery/door/airlock/D in my_area)
		if(QDELETED(D) || D.density)
			continue
		if(prob(40))
			D.close()
			D.bolt()
	for(var/obj/machinery/door/airlock/D in my_area)
		if(QDELETED(D) || !istype(D))
			continue
		if(prob(30) && (zone_type == "hcz" || zone_type == "lcz"))
			D.req_access = list(ACCESS_SECURITY)

/obj/machinery/breach_siren/lcz
	zone_type = "lcz"

/obj/machinery/breach_siren/hcz
	zone_type = "hcz"

/obj/machinery/breach_siren/ez
	zone_type = "ez"

/obj/machinery/breach_siren/dclass
	zone_type = "dclass"
