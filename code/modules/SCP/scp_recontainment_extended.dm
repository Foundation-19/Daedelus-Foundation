// Additional Recontainment Procedures
// SCP-682 Acid Bath, SCP-939 Sound Lure, SCP-017 Light Containment Chamber

// ===== SCP-682 ACID BATH =====
/obj/machinery/scp682_acid_bath
	name = "SCP-682 Acid Containment Bath"
	desc = "A massive reinforced tank filled with hydrochloric acid, used to contain SCP-682 when all else fails."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200

	var/acid_level = 100
	var/max_acid = 100
	var/acid_recharge_rate = 0.2
	var/bath_active = FALSE
	var/damage_per_tick = 15
	var/containment_progress = 0
	var/containment_threshold = 100

/obj/machinery/scp682_acid_bath/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/machinery/scp682_acid_bath/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/scp682_acid_bath/process()
	if(acid_level < max_acid)
		acid_level = min(max_acid, acid_level + acid_recharge_rate)

	if(bath_active)
		process_acid_containment()

/obj/machinery/scp682_acid_bath/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(H, "<span class='warning'>Requires Science access to operate the acid bath.</span>")
		return

	if(bath_active)
		to_chat(H, "<span class='notice'>Acid bath is active. Containment progress: [containment_progress]%. Acid: [round(acid_level)]%</span>")
		return

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-682"]
		if(!instance || instance.containment_status != "breached")
			to_chat(H, "<span class='warning'>SCP-682 is not currently breached. Acid bath not required.</span>")
			return

	var/confirm = alert(H, "Activate SCP-682 Acid Containment Bath? This will fill the chamber with concentrated acid. Acid level: [round(acid_level)]%", "Acid Bath", "Activate", "Cancel")
	if(confirm != "Activate")
		return

	bath_active = TRUE
	containment_progress = 0
	visible_message("<span class='danger'>[src] begins filling with concentrated hydrochloric acid!</span>")
	priority_announce("ATTENTION: SCP-682 acid containment protocol activated. All personnel clear the containment chamber.", null, null, ANNOUNCER_ALERT)

/obj/machinery/scp682_acid_bath/proc/process_acid_containment()
	if(acid_level <= 0)
		bath_active = FALSE
		visible_message("<span class='warning'>[src] runs out of acid. Containment protocol halted.</span>")
		return

	acid_level -= 0.5

	var/mob/living/scp/scp682/target = null
	for(var/mob/living/scp/scp682/S in range(3, src))
		target = S
		break

	if(target)
		target.adjustFireLoss(damage_per_tick)
		target.adjustBruteLoss(damage_per_tick * 0.5)
		target.visible_message("<span class='danger'>[target] thrashes in the acid, flesh dissolving and regenerating simultaneously!</span>")

		containment_progress += 2
		if(target.health <= 50)
			containment_progress += 3

		if(containment_progress >= containment_threshold)
			complete_acid_containment(target)
	else
		containment_progress = max(0, containment_progress - 1)

/obj/machinery/scp682_acid_bath/proc/complete_acid_containment(mob/living/scp/scp682/target)
	bath_active = FALSE
	containment_progress = 0

	if(target)
		target.adjustFireLoss(50)
		target.forceMove(get_turf(src))

	hook_scp_recontainment("SCP-682", list())
	priority_announce("SCP-682 has been recontained via acid bath protocol. Containment integrity being restored.", null, null, ANNOUNCER_DEFAULT)

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-682"]
		if(instance)
			instance.containment_status = "contained"
			instance.containment_health = 100

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
		to_chat(user, "<span class='warning'>Device recharging.</span>")
		return

	if(battery <= 0)
		to_chat(user, "<span class='warning'>Battery depleted.</span>")
		return

	var/mob/living/carbon/human/H = user
	active = !active
	cooldown = world.time + cooldown_time
	battery -= battery_drain

	if(active)
		to_chat(H, "<span class='notice'>You activate the sonic lure. It begins emitting a high-frequency pulse.</span>")
		attract_scp939(H)
	else
		to_chat(H, "<span class='notice'>You deactivate the sonic lure.</span>")

/obj/item/scp939_sound_lure/proc/attract_scp939(mob/user)
	var/list/attracted = list()
	for(var/mob/living/scp/scp939/S in GLOB.mob_list)
		if(QDELETED(S))
			continue
		var/dist = get_dist(user, S)
		if(dist <= lure_range)
			attracted += S
			walk_to(S, user, 1, 3)
			to_chat(S, "<span class='notice'>An irresistible sound pulls you toward its source...</span>")

	if(length(attracted))
		to_chat(user, "<span class='notice'>The lure is attracting [length(attracted)] SCP-939 instance(s)!</span>")

		for(var/mob/living/scp/scp939/S in attracted)
			var/dist = get_dist(user, S)
			if(dist <= 2)
				S.Stun(40)
				S.visible_message("<span class='warning'>[S] staggers, disoriented by the sonic frequency!</span>")
				to_chat(S, "<span class='userdanger'>The frequency overwhelms your senses!</span>")

				if(SSscp_persistence && SSscp_persistence.manager)
					var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-939"]
					if(instance && instance.containment_status == "breached")
						hook_scp_recontainment("SCP-939", list(user))
						priority_announce("SCP-939 has been neutralized via sonic lure protocol.", null, null, ANNOUNCER_DEFAULT)
	else
		to_chat(user, "<span class='warning'>No SCP-939 instances within range.</span>")

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
		to_chat(H, "<span class='warning'>Requires Science access to operate.</span>")
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
			to_chat(H, "<span class='notice'>Target light level set to [level]. Chamber adjusting...</span>")
			if(level > 2)
				to_chat(H, "<span class='warning'>WARNING: Light levels above 2 may trigger SCP-017 containment breach!</span>")

		if("Activate Emergency Lights")
			emergency_lights = !emergency_lights
			to_chat(H, "<span class='notice'>Emergency lights [emergency_lights ? "ACTIVATED" : "DEACTIVATED"].</span>")
			if(emergency_lights)
				to_chat(H, "<span class='warning'>Emergency lights will increase ambient light. SCP-017 may react.</span>")

		if("Check Containment Status")
			to_chat(H, "<span class='notice'>=== SCP-017 Containment Status ===</span>")
			to_chat(H, "<span class='notice'>Light Level: [chamber_light_level]/10</span>")
			to_chat(H, "<span class='notice'>Target Light: [target_light_level]/10</span>")
			to_chat(H, "<span class='notice'>Containment Integrity: [containment_integrity]%</span>")
			to_chat(H, "<span class='notice'>Breach Risk: [breach_risk]%</span>")
			to_chat(H, "<span class='notice'>Emergency Lights: [emergency_lights ? "ON" : "OFF"]</span>")

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
		visible_message("<span class='warning'>[src] shudders as shadows seep through the containment seams...</span>")

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
		to_chat(H, "<span class='notice'>Light suppressor activated. Nearby light sources are being dampened.</span>")
		START_PROCESSING(SSobj, src)
	else
		to_chat(H, "<span class='notice'>Light suppressor deactivated.</span>")
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
				var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-017"]
				if(instance && instance.containment_status == "breached")
					hook_scp_recontainment("SCP-017", list())
					priority_announce("SCP-017 has been recontained via light suppression protocol.", null, null, ANNOUNCER_DEFAULT)
