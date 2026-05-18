#define AMNESTIC_CLASS_A "Class-A"
#define AMNESTIC_CLASS_B "Class-B"
#define AMNESTIC_CLASS_C "Class-C"
#define AMNESTIC_CLASS_E "Class-E"

/obj/machinery/amnestic_dispenser
	name = "Amnestic Dispenser"
	desc = "A Foundation medical device that administers targeted amnestics to subjects. Used for post-breach protocol compliance."
	icon = 'icons/obj/machines/medipen_refiller.dmi'
	icon_state = "medipen_refiller"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

	var/selected_class = AMNESTIC_CLASS_A
	var/dispense_cooldown = 0
	var/dispense_cooldown_time = 30 SECONDS
	var/amnestic_stock_a = 10
	var/amnestic_stock_b = 5
	var/amnestic_stock_c = 3
	var/amnestic_stock_e = 1

/obj/machinery/amnestic_dispenser/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpAmnesticDispenser", "SCP FOUNDATION — AMNESTIC DISPENSER")
		ui.open()

/obj/machinery/amnestic_dispenser/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/amnestic_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["selected_class"] = selected_class
	data["stock_a"] = amnestic_stock_a
	data["stock_b"] = amnestic_stock_b
	data["stock_c"] = amnestic_stock_c
	data["stock_e"] = amnestic_stock_e
	data["cooldown_active"] = (dispense_cooldown > world.time)
	data["cooldown_remaining"] = max(0, dispense_cooldown - world.time)
	return data

/obj/machinery/amnestic_dispenser/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		to_chat(H, span_warning("Requires Medical access to operate amnestic dispenser."))
		return

	switch(action)
		if("select_class")
			var/choice = params["class"]
			if(choice in list(AMNESTIC_CLASS_A, AMNESTIC_CLASS_B, AMNESTIC_CLASS_C, AMNESTIC_CLASS_E))
				selected_class = choice
			. = TRUE
		if("administer")
			administer_amnestic(H, user)
			. = TRUE
		if("dispense_injector")
			dispense_injector(H)
			. = TRUE

/obj/machinery/amnestic_dispenser/proc/administer_amnestic(mob/living/carbon/human/target, mob/user)
	if(dispense_cooldown > world.time)
		to_chat(user, span_warning("Amnestic dispenser recharging."))
		return

	var/stock
	switch(selected_class)
		if(AMNESTIC_CLASS_A)
			stock = amnestic_stock_a
		if(AMNESTIC_CLASS_B)
			stock = amnestic_stock_b
		if(AMNESTIC_CLASS_C)
			stock = amnestic_stock_c
		if(AMNESTIC_CLASS_E)
			stock = amnestic_stock_e

	if(stock <= 0)
		to_chat(user, span_warning("No [selected_class] amnestics remaining."))
		return

	if(target.stat == DEAD)
		to_chat(user, span_warning("Subject is deceased."))
		return

	dispense_cooldown = world.time + dispense_cooldown_time

	switch(selected_class)
		if(AMNESTIC_CLASS_A)
			amnestic_stock_a--
		if(AMNESTIC_CLASS_B)
			amnestic_stock_b--
		if(AMNESTIC_CLASS_C)
			amnestic_stock_c--
		if(AMNESTIC_CLASS_E)
			amnestic_stock_e--

	apply_amnestic_effects(target, selected_class)
	visible_message(span_notice("[user] administers [selected_class] amnestics to [target] from [src]."))
	playsound(src, 'sound/machines/defib_zap.ogg', 50, TRUE)
	log_game("[key_name(user)] administered [selected_class] amnestics to [key_name(target)]")

/obj/machinery/amnestic_dispenser/proc/dispense_injector(mob/user)
	var/stock
	switch(selected_class)
		if(AMNESTIC_CLASS_A)
			stock = amnestic_stock_a
		if(AMNESTIC_CLASS_B)
			stock = amnestic_stock_b
		if(AMNESTIC_CLASS_C)
			stock = amnestic_stock_c
		if(AMNESTIC_CLASS_E)
			stock = amnestic_stock_e

	if(stock <= 0)
		to_chat(user, span_warning("No [selected_class] amnestics remaining."))
		return

	switch(selected_class)
		if(AMNESTIC_CLASS_A)
			amnestic_stock_a--
		if(AMNESTIC_CLASS_B)
			amnestic_stock_b--
		if(AMNESTIC_CLASS_C)
			amnestic_stock_c--
		if(AMNESTIC_CLASS_E)
			amnestic_stock_e--

	var/obj/item/reagent_containers/syringe/amnestic/S = new(get_turf(user))
	S.amnestic_class = selected_class
	user.put_in_hands(S)
	to_chat(user, span_notice("You dispense a [selected_class] amnestic injector."))
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/proc/apply_amnestic_effects(mob/living/carbon/human/target, amnestic_class)
	if(!istype(target))
		return

	switch(amnestic_class)
		if(AMNESTIC_CLASS_A)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
			target.drowsyness += 20
			to_chat(target, span_warning("Your mind feels foggy... recent memories become hazy."))
			target.hallucination = max(target.hallucination, 15)
		if(AMNESTIC_CLASS_B)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15)
			target.drowsyness += 40
			target.hallucination = max(target.hallucination, 30)
			to_chat(target, span_warning("A wave of disorientation washes over you! You can't remember what you were just doing..."))
			if(target.sanity)
				target.sanity.adjust_sanity(20, "amnestic_class_b")
			for(var/datum/brain_trauma/mild/phobia/P in target.get_traumas())
				qdel(P)
		if(AMNESTIC_CLASS_C)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)
			target.drowsyness += 80
			target.hallucination = max(target.hallucination, 60)
			to_chat(target, span_userdanger("Your mind is RIPPED apart! Hours of memory dissolve like smoke!"))
			target.Unconscious(100)
			if(target.sanity)
				target.sanity.adjust_sanity(40, "amnestic_class_c")
			for(var/datum/brain_trauma/T in target.get_traumas())
				if(!istype(T, /datum/brain_trauma/special))
					qdel(T)
		if(AMNESTIC_CLASS_E)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50)
			target.drowsyness += 120
			target.hallucination = max(target.hallucination, 100)
			to_chat(target, span_userdanger("EVERYTHING IS GONE. Your mind is a blank void. You don't even remember your own name."))
			target.Unconscious(200)
			if(target.sanity)
				target.sanity.adjust_sanity(60, "amnestic_class_e")
			for(var/datum/brain_trauma/T in target.get_traumas())
				qdel(T)

/obj/item/reagent_containers/syringe/amnestic
	name = "amnestic injector"
	desc = "A pre-loaded syringe containing Foundation amnestic compounds."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "syringe_0"
	volume = 15
	list_reagents = list(/datum/reagent/medicine/morphine = 5)
	var/amnestic_class = AMNESTIC_CLASS_A

/obj/item/reagent_containers/syringe/amnestic/attack(mob/living/target, mob/user)
	if(!istype(target, /mob/living/carbon/human))
		return ..()
	if(!ishuman(user))
		return ..()

	var/mob/living/carbon/human/H = target
	user.visible_message(span_warning("[user] injects [H] with [amnestic_class] amnestics!"), span_notice("You administer [amnestic_class] amnestics to [H]."))
	apply_amnestic_effects(H, amnestic_class)
	log_game("[key_name(user)] injected [key_name(H)] with [amnestic_class] amnestics")
	qdel(src)

/obj/machinery/amnestic_gas_vent
	name = "Amnestic Gas Vent"
	desc = "A ventilation system that can release Class-A amnestic gas into the surrounding area for mass memory suppression."
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20

	var/vent_active = FALSE
	var/gas_duration = 30 SECONDS
	var/gas_range = 7
	var/cooldown = 0
	var/cooldown_time = 5 MINUTES

/obj/machinery/amnestic_gas_vent/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		to_chat(H, span_warning("Requires Medical access."))
		return

	if(vent_active)
		to_chat(H, span_warning("Gas vent already active."))
		return
	if(cooldown > world.time)
		to_chat(H, span_warning("Vent recharging. Ready in [round((cooldown - world.time) / 10)] seconds."))
		return

	var/confirm = alert(H, "Release Class-A amnestic gas? This will affect all personnel in range.", "Amnestic Gas", "Release", "Cancel")
	if(confirm != "Release")
		return

	vent_active = TRUE
	cooldown = world.time + cooldown_time
	visible_message(span_warning("[src] hisses as amnestic gas begins to fill the area!"))
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE)
	priority_announce("NOTICE: Class-A amnestic gas release in [get_area_name(src)]. Personnel may experience mild disorientation.", "AMNESTIC RELEASE", null, ANNOUNCER_DEFAULT)

	release_gas()
	addtimer(CALLBACK(src, .proc/stop_gas), gas_duration)

/obj/machinery/amnestic_gas_vent/proc/release_gas()
	for(var/mob/living/carbon/human/H in range(gas_range, src))
		if(H.stat == DEAD)
			continue
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card && (ACCESS_MEDICAL in id_card.access))
			continue
		apply_amnestic_effects(H, AMNESTIC_CLASS_A)

/obj/machinery/amnestic_gas_vent/proc/stop_gas()
	vent_active = FALSE
	visible_message(span_notice("[src] stops releasing gas."))
