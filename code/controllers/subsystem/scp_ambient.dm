SUBSYSTEM_DEF(scp_ambient)
	name = "SCP Ambient Events"
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME

	var/list/active_effects = list()
	var/next_event_time = 0
	var/min_delay = 60 SECONDS
	var/max_delay = 300 SECONDS
	var/intensity_modifier = 1.0

/datum/controller/subsystem/scp_ambient/Initialize(time)
	next_event_time = world.time + rand(min_delay, max_delay)
	return ..()

/datum/controller/subsystem/scp_ambient/fire(resumed)
	if(world.time < next_event_time)
		return

	next_event_time = world.time + rand(min_delay, max_delay)
	trigger_random_ambient()

/datum/controller/subsystem/scp_ambient/proc/get_intensity()
	intensity_modifier = 1.0
	var/breached_count = 0
	if(SSscp_persistence?.manager?.scp_instances)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/SI = SSscp_persistence.manager.scp_instances[scp_id]
			if(SI && SI.containment_status == "breached")
				breached_count++
	if(breached_count >= 3)
		intensity_modifier = 2.0
	else if(breached_count >= 1)
		intensity_modifier = 1.5
	if(SSsecurity_level)
		switch(SSsecurity_level.current_level)
			if(SEC_LEVEL_RED)
				intensity_modifier *= 1.5
			if(SEC_LEVEL_BLUE)
				intensity_modifier *= 1.2
	return intensity_modifier

/datum/controller/subsystem/scp_ambient/proc/trigger_random_ambient()
	var/intensity = get_intensity()
	var/list/possible_events = list(
		/proc/scp_ambient_895_camera,
		/proc/scp_ambient_173_shifting,
		/proc/scp_ambient_049_distant_call,
		/proc/scp_ambient_096_crying,
		/proc/scp_ambient_106_corrosion,
		/proc/scp_ambient_939_echoing,
		/proc/scp_ambient_035_whisper,
		/proc/scp_ambient_513_bell,
		/proc/scp_ambient_1499_dimension_breach,
		/proc/scp_ambient_general_flicker,
		/proc/scp_ambient_distant_screams,
		/proc/scp_ambient_hum_change,
		/proc/scp_ambient_pa_static,
		/proc/scp_ambient_shadow_movement,
		/proc/scp_ambient_containment_rumble,
		/proc/scp_ambient_breach_alarm,
		/proc/scp_ambient_temperature_drop,
		/proc/scp_ambient_anomalous_reading,
	)

	var/event_type = pick(possible_events)
	call(event_type)(intensity)

/proc/scp_ambient_895_camera(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		if(prob(5 * intensity))
			var/area/A = get_area(H)
			if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
				to_chat(H, "<span class='warning'>The nearby camera briefly shows a coffin where you stand...</span>")
				if(H.sanity && prob(30))
					H.sanity.adjust_sanity(-5, "scp895_camera_ambient")

/proc/scp_ambient_173_shifting(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-173"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz))
			if(prob(8 * intensity))
				to_chat(H, "<span class='notice'>You hear the faint sound of stone scraping from somewhere nearby...</span>")

/proc/scp_ambient_049_distant_call(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-049"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			if(prob(5 * intensity))
				to_chat(H, "<span class='notice'>A distant, muffled voice echoes: <i>...I can cure this...</i></span>")

/proc/scp_ambient_096_crying(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-096"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/hcz) || istype(A, /area/scp/lcz))
			if(prob(4 * intensity))
				to_chat(H, "<span class='warning'>You hear faint sobbing from somewhere in the facility...</span>")
				if(H.sanity && prob(20))
					H.sanity.adjust_sanity(-3, "scp096_crying_ambient")

/proc/scp_ambient_106_corrosion(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-106"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/hcz))
			if(prob(3 * intensity))
				to_chat(H, "<span class='warning'>A dark, viscous substance seems to seep from the walls momentarily...</span>")

/proc/scp_ambient_939_echoing(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-939"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/hcz))
			if(prob(4 * intensity))
				var/list/phrases = list(
					"Is someone there?",
					"Help me...",
					"I can hear you...",
					"Don't leave me here...",
				)
				to_chat(H, "<span class='notice'>You hear a voice that sounds oddly familiar: <i>[pick(phrases)]</i></span>")

/proc/scp_ambient_035_whisper(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-035"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			if(prob(3 * intensity))
				var/list/whispers = list(
					"You could just... let me out.",
					"I know what you're thinking.",
					"We could accomplish so much together.",
				)
				to_chat(H, "<span class='italics'>A whisper crosses your mind: <i>[pick(whispers)]</i></span>")
				if(H.sanity && prob(25))
					H.sanity.adjust_sanity(-3, "scp035_whisper_ambient")

/proc/scp_ambient_513_bell(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-513"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		if(prob(2 * intensity))
			to_chat(H, "<span class='warning'>You faintly hear the sound of a bell ringing in the distance...</span>")
			if(H.sanity && prob(40))
				H.sanity.adjust_sanity(-8, "scp513_bell_ambient")
				H.sanity.hallucination_level = min(H.sanity.hallucination_level + 5, H.sanity.max_hallucination)

/proc/scp_ambient_1499_dimension_breach(intensity = 1)
	if(!SSscp_persistence?.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-1499"]
	if(!instance)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz))
			if(prob(2 * intensity))
				to_chat(H, "<span class='warning'>For a split second, the air around you seems to shift and twist...</span>")
				if(H.sanity && prob(20))
					H.sanity.adjust_sanity(-5, "scp1499_dimension_ambient")

/proc/scp_ambient_general_flicker(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/lcz) || istype(A, /area/scp/hcz))
			if(prob(10 * intensity))
				to_chat(H, "<span class='notice'>The lights flicker momentarily.</span>")
				for(var/obj/machinery/light/L in range(5, H))
					if(QDELETED(L))
						continue
					if(prob(40))
						L.flicker(2)

/proc/scp_ambient_distant_screams(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(min(100, 40 * intensity)))
			to_chat(H, "<span class='warning'>You hear distant screams echoing through the facility corridors...</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(round(-3 * intensity), "distant_screams_ambient")

/proc/scp_ambient_hum_change(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(min(100, 20 * intensity)))
			to_chat(H, "<span class='notice'>The ambient hum of the facility shifts pitch momentarily, sending a chill down your spine.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(round(-2 * intensity), "facility_hum_change_ambient")

/proc/scp_ambient_pa_static(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(min(100, 15 * intensity)))
			playsound(H, 'sound/effects/phasein.ogg', 30, TRUE)
			to_chat(H, "<span class='warning'>The PA system crackles with static... a garbled announcement fades into noise.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(round(-2 * intensity), "pa_static_ambient")

/proc/scp_ambient_shadow_movement(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(min(100, 25 * intensity)))
			to_chat(H, "<span class='warning'>You catch a shadow moving in your peripheral vision, but nothing is there when you look...</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(round(-4 * intensity), "shadow_movement_ambient")

/proc/scp_ambient_containment_rumble(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(!prob(min(100, 30 * intensity)))
			continue
		playsound(H, 'sound/effects/bamf.ogg', 40, TRUE)
		to_chat(H, "<span class='warning'>A deep rumbling reverberates through the walls from the containment areas...</span>")
		if(H.sanity)
			H.sanity.adjust_sanity(round(-2 * intensity), "containment_rumble_ambient")

/proc/scp_ambient_breach_alarm(intensity = 1)
	if(intensity < 1.5)
		return
	if(!SSscp_persistence?.manager?.scp_instances)
		return
	var/list/breached_scps = list()
	for(var/scp_id in SSscp_persistence.manager.scp_instances)
		var/datum/scp_instance/SI = SSscp_persistence.manager.scp_instances[scp_id]
		if(SI && SI.containment_status == "breached")
			breached_scps += scp_id
	if(!length(breached_scps))
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(min(100, 20 * intensity)))
			playsound(H, 'sound/effects/alert.ogg', 25, TRUE)
			to_chat(H, "<span class='warning'>The distant wail of a containment breach alarm echoes through the corridors...</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(round(-5 * intensity), "breach_alarm_ambient")

/proc/scp_ambient_temperature_drop(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(min(100, 30 * intensity)))
			to_chat(H, "<span class='warning'>A sudden chill washes over you. The temperature seems to drop without explanation.</span>")
			if(H.sanity)
				H.sanity.adjust_sanity(round(-1 * intensity), "temperature_drop_ambient")

/proc/scp_ambient_anomalous_reading(intensity = 1)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD || !H.client)
			continue
		if(!H.job)
			continue
		if(!(findtext(H.job, "Research") || findtext(H.job, "Scientist")))
			continue
		var/area/A = get_area(H)
		if(!istype(A, /area/scp/))
			continue
		if(prob(min(100, 10 * intensity)))
			to_chat(H, "<span class='notice'>Your instruments detect a brief anomalous reading... it fades before you can isolate it.</span>")
