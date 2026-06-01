// Additional Recontainment Procedures
// SCP-682 Acid Bath, SCP-939 Sound Lure, SCP-017 Light Containment Chamber

// ===== SCP-939 SOUND LURE =====
/obj/item/scp939_sound_lure
	name = "SCP-939 Sonic Lure Device"
	desc = "A device that emits frequencies designed to attract and disorient SCP-939 instances."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/active = FALSE
	var/lure_range = 10
	var/battery = 100
	var/battery_drain = 5
	var/cooldown = 0
	var/cooldown_time = 30 SECONDS

/obj/item/scp939_sound_lure/attack_self(mob/user)
	if(!ishuman(user))
		return

	if(world.time < cooldown)
		to_chat(user, span_warning("Device recharging."))
		return

	if(battery <= 0)
		to_chat(user, span_warning("Battery depleted."))
		return

	var/mob/living/carbon/human/H = user
	active = !active
	cooldown = world.time + cooldown_time
	battery -= battery_drain

	if(active)
		to_chat(H, span_notice("You activate the sonic lure. It begins emitting a high-frequency pulse."))
		attract_scp939(H)
	else
		to_chat(H, span_notice("You deactivate the sonic lure."))

/obj/item/scp939_sound_lure/proc/attract_scp939(mob/user)
	var/list/attracted = list()
	for(var/mob/living/scp/scp939/S in GLOB.mob_list)
		if(QDELETED(S))
			continue
		var/dist = get_dist(user, S)
		if(dist <= lure_range)
			attracted += S
			walk_to(S, user, 1, 3)
			to_chat(S, span_notice("An irresistible sound pulls you toward its source..."))

	if(length(attracted))
		to_chat(user, span_notice("The lure is attracting [length(attracted)] SCP-939 instance(s)!"))

		for(var/mob/living/scp/scp939/S in attracted)
			var/dist = get_dist(user, S)
			if(dist <= 2)
				S.Stun(40)
				S.visible_message(span_warning("[S] staggers, disoriented by the sonic frequency!"))
				to_chat(S, span_userdanger("The frequency overwhelms your senses!"))

				if(SSscp_persistence && SSscp_persistence.manager)
					var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-939"]
					if(instance && instance.containment_status == "breached")
						hook_scp_recontainment("SCP-939", list(user))
						priority_announce("SCP-939 has been neutralized via sonic lure protocol.", null, null, ANNOUNCER_DEFAULT)
	else
		to_chat(user, span_warning("No SCP-939 instances within range."))

// ===== SCP-017 LIGHT CONTAINMENT CHAMBER =====
/obj/machinery/scp017_light_chamber
	name = "SCP-017 Light Containment Chamber"
	desc = "A reinforced containment unit with adjustable light levels, designed to contain SCP-017 by maintaining absolute darkness."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "bluespace-prison"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50

	var/chamber_light_level = 0
	var/target_light_level = 0
	var/emergency_lights = FALSE
	var/containment_integrity = 100
	var/breach_risk = 0

/obj/machinery/scp017_light_chamber/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(H, span_warning("Requires Science access to operate."))
		return

	var/list/options = list("Set Light Level", "Activate Emergency Lights", "Check Containment Status", "Cancel")
	var/choice = input(H, "SCP-017 Light Chamber Control:", "Light Containment") as null|anything in options
	if(!choice || choice == "Cancel")
		return

	switch(choice)
		if("Set Light Level")
			var/level = input(H, "Set target light level (0-10). 0 = Absolute Darkness. Higher levels are DANGEROUS.", "Light Level", 0) as num|null
			if(isnull(level))
				return
			level = clamp(round(level), 0, 10)
			target_light_level = level
			to_chat(H, span_notice("Target light level set to [level]. Chamber adjusting..."))
			if(level > 2)
				to_chat(H, span_warning("WARNING: Light levels above 2 may trigger SCP-017 containment breach!"))

		if("Activate Emergency Lights")
			emergency_lights = !emergency_lights
			to_chat(H, span_notice("Emergency lights [emergency_lights ? "ACTIVATED" : "DEACTIVATED"]."))
			if(emergency_lights)
				to_chat(H, span_warning("Emergency lights will increase ambient light. SCP-017 may react."))

		if("Check Containment Status")
			to_chat(H, span_notice("=== SCP-017 Containment Status ==="))
			to_chat(H, span_notice("Light Level: [chamber_light_level]/10"))
			to_chat(H, span_notice("Target Light: [target_light_level]/10"))
			to_chat(H, span_notice("Containment Integrity: [containment_integrity]%"))
			to_chat(H, span_notice("Breach Risk: [breach_risk]%"))
			to_chat(H, span_notice("Emergency Lights: [emergency_lights ? "ON" : "OFF"]"))

/obj/machinery/scp017_light_chamber/process()
	if(chamber_light_level < target_light_level)
		chamber_light_level++
	else if(chamber_light_level > target_light_level)
		chamber_light_level--

	if(emergency_lights)
		chamber_light_level = max(chamber_light_level, 1)

	breach_risk = chamber_light_level * 10
	if(emergency_lights)
		breach_risk += 15

	if(breach_risk > 50)
		containment_integrity = max(0, containment_integrity - 0.5)

	if(chamber_light_level == 0)
		containment_integrity = min(100, containment_integrity + 0.2)

	if(containment_integrity <= 0)
		trigger_017_breach()

	if(containment_integrity < 30 && prob(10))
		visible_message(span_warning("[src] shudders as shadows seep through the containment seams..."))

/obj/machinery/scp017_light_chamber/proc/trigger_017_breach()
	priority_announce("CRITICAL: SCP-017 containment failure! Light containment chamber compromised!", null, null, ANNOUNCER_ALERT)
	hook_scp_breach("SCP-017", src)
	containment_integrity = 100
	chamber_light_level = 0
	target_light_level = 0
	emergency_lights = FALSE

// Portable Light Suppressor for SCP-017 recontainment
/obj/item/scp017_light_suppressor
	name = "Portable Light Suppressor"
	desc = "A device that absorbs photons in a small radius, creating a zone of absolute darkness. Used for SCP-017 recontainment."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/active = FALSE
	var/range = 3
	var/battery = 100
	var/drain_rate = 2

/obj/item/scp017_light_suppressor/attack_self(mob/user)
	if(!ishuman(user))
		return

	active = !active
	var/mob/living/carbon/human/H = user

	if(active)
		to_chat(H, span_notice("Light suppressor activated. Nearby light sources are being dampened."))
		START_PROCESSING(SSobj, src)
	else
		to_chat(H, span_notice("Light suppressor deactivated."))
		STOP_PROCESSING(SSobj, src)

/obj/item/scp017_light_suppressor/process()
	if(!active || battery <= 0)
		active = FALSE
		STOP_PROCESSING(SSobj, src)
		return

	battery -= drain_rate

	var/turf/T = get_turf(src)
	if(!T)
		return

	for(var/obj/machinery/light/L in range(range, T))
		if(prob(60))
			L.set_on(FALSE)

	var/mob/living/scp/scp017/target = null
	for(var/mob/living/scp/scp017/S in range(range, T))
		target = S
		break

	if(target)
		var/turf/target_turf = get_turf(target)
		if(target_turf && target_turf.get_lumcount() < 0.15)
			if(SSscp_persistence && SSscp_persistence.manager)
				var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-017"]
				if(instance && instance.containment_status == "breached")
					hook_scp_recontainment("SCP-017", list())
					priority_announce("SCP-017 has been recontained via light suppression protocol.", null, null, ANNOUNCER_DEFAULT)
