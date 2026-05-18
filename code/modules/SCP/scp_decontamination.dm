/obj/machinery/decontamination_chamber
	name = "Decontamination Chamber"
	desc = "A sealed chamber that neutralizes biological and anomalous contaminants."
	icon = 'icons/obj/machines/stasis.dmi'
	icon_state = "stasis"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 500
	var/active = FALSE
	var/cycle_time = 100
	var/radiation_strength = 5
	var/cooldown = 0

/obj/machinery/decontamination_chamber/examine(mob/user)
	. = ..()
	. += "Status: [active ? "ACTIVE — Decontamination in progress" : "STANDBY"]"

/obj/machinery/decontamination_chamber/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You [anchored ? "unsecure" : "secure"] [src]."))
		anchored = !anchored
		I.play_tool_sound(src)
		return
	if(I.tool_behaviour == TOOL_MULTITOOL)
		radiation_strength = input(user, "Set radiation strength (1-15):", "Decontamination Settings", radiation_strength) as num|null
		radiation_strength = clamp(radiation_strength, 1, 15)
		to_chat(user, span_notice("Radiation strength set to [radiation_strength]."))
		return
	return ..()

/obj/machinery/decontamination_chamber/attack_hand(mob/user)
	if(active)
		to_chat(user, span_warning("Decontamination is already in progress!"))
		return

	if(cooldown > world.time)
		to_chat(user, span_warning("The chamber is recharging. Please wait."))
		return

	if(!powered())
		to_chat(user, span_warning("The chamber has no power!"))
		return

	start_decontamination(user)

/obj/machinery/decontamination_chamber/proc/start_decontamination(mob/user)
	active = TRUE
	set_light(3, 2, COLOR_RED)
	visible_message(span_warning("[src] activates! Decontamination cycle starting!"))

	var/list/targets = list()
	for(var/mob/living/L in range(1, src))
		targets += L

	for(var/mob/living/L in targets)
		to_chat(L, span_warning("You are engulfed in decontamination radiation!"))

	addtimer(CALLBACK(src, .proc/apply_decontamination, targets), cycle_time / 2)
	addtimer(CALLBACK(src, .proc/finish_decontamination), cycle_time)

/obj/machinery/decontamination_chamber/proc/apply_decontamination(list/targets)
	for(var/mob/living/L in targets)
		if(QDELETED(L))
			continue

		if(ishuman(L))
			var/mob/living/carbon/human/H = L

			for(var/datum/status_effect/effect in H.status_effects)
				if(istype(effect, /datum/status_effect/bsl4_contagion))
					qdel(effect)
					to_chat(H, span_notice("The decontamination radiation neutralizes the contagion!"))

			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, radiation_strength * 2)

		to_chat(L, span_notice("Decontamination radiation sears through you."))

	for(var/obj/item/scp_anomalous/A in range(1, src))
		if(!A.contained)
			A.contain()
			visible_message(span_notice("[A] is contained by the decontamination field!"))

/obj/machinery/decontamination_chamber/proc/finish_decontamination()
	active = FALSE
	set_light(0)
	cooldown = world.time + 200
	visible_message(span_notice("[src] finishes its decontamination cycle."))

/obj/machinery/decontamination_chamber/update_icon()
	. = ..()
	if(active)
		icon_state = "stasis"
	else
		icon_state = "stasis"

/obj/machinery/decontamination_shower
	name = "emergency decontamination shower"
	desc = "An emergency shower that sprays decontaminant. Not as thorough as a full chamber cycle."
	icon = 'icons/obj/machines/medipen_refiller.dmi'
	icon_state = "medipen_refiller"
	density = FALSE
	anchored = TRUE
	var/uses = 5

/obj/machinery/decontamination_shower/attack_hand(mob/user)
	if(uses <= 0)
		to_chat(user, span_warning("The shower has run out of decontaminant!"))
		return

	uses--
	visible_message(span_warning("[src] activates, spraying decontaminant!"))
	playsound(loc, 'sound/effects/spray.ogg', 50, TRUE)

	for(var/mob/living/L in range(1, src))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			for(var/datum/status_effect/effect in H.status_effects)
				if(istype(effect, /datum/status_effect/bsl4_contagion))
					if(prob(60))
						qdel(effect)
						to_chat(H, span_notice("The decontaminant neutralizes the contagion!"))

			H.adjust_fire_stacks(-5)

		to_chat(L, span_notice("Decontaminant washes over you."))

	if(uses <= 0)
		icon_state = "medipen_refiller"
