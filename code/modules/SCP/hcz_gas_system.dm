// HCZ Gas Release System
// Allows command staff to release various gas agents into Heavy Containment Zone
// Used for containment of SCP-008, SCP-457, and biological breaches

#define HCZ_GAS_NONE 0
#define HCZ_GAS_SLEEPING 1
#define HCZ_GAS_SUPPRESSANT 2
#define HCZ_GAS_NEUROTOXIN 3
#define HCZ_GAS_MEMETIC_SCRUBBER 4
#define HCZ_GAS_AMNESTIC_VAPOR 5

/obj/machinery/computer/hcz_gas_console
	name = "HCZ Gas Control Console"
	desc = "A secure console for releasing gas agents into Heavy Containment Zone corridors."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ADMIN_LVL3)
	circuit = /obj/item/circuitboard/computer/hcz_gas
	density = TRUE
	anchored = TRUE

	var/gas_type = HCZ_GAS_NONE
	var/gas_active = FALSE
	var/gas_remaining = 0
	var/max_gas = 300
	var/vent_cooldown = 0
	var/list/affected_areas = list()
	var/gas_tick_timerid

/obj/machinery/computer/hcz_gas_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HCZGasConsole", "SCP FOUNDATION — HCZ GAS CONTROL")
		ui.open()

/obj/machinery/computer/hcz_gas_console/ui_data(mob/user)
	var/list/data = list()
	data["gasActive"] = gas_active
	data["gasType"] = gas_type
	data["gasTypeName"] = get_gas_name(gas_type)
	data["gasRemaining"] = gas_remaining
	data["maxGas"] = max_gas
	data["ventCooldown"] = vent_cooldown > world.time
	data["affectedAreaCount"] = length(affected_areas)

	var/obj/item/card/id/id_card
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		id_card = H.get_idcard(TRUE)
	data["hasAccess"] = id_card && (ACCESS_ADMIN in id_card.access)

	return data

/obj/machinery/computer/hcz_gas_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	var/obj/item/card/id/id_card
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(user, span_warning("Access denied."))
		return

	switch(action)
		if("selectGas")
			var/new_type = text2num(params["gasType"])
			if(isnull(new_type) || new_type < HCZ_GAS_NONE || new_type > HCZ_GAS_AMNESTIC_VAPOR)
				return
			if(gas_active)
				return
			gas_type = new_type
			. = TRUE
		if("releaseGas")
			if(gas_active || gas_type == HCZ_GAS_NONE)
				return
			if(vent_cooldown > world.time)
				return
			if(gas_remaining <= 0)
				gas_remaining = max_gas
			release_gas()
			. = TRUE
		if("stopGas")
			if(!gas_active)
				return
			stop_gas()
			. = TRUE

/obj/machinery/computer/hcz_gas_console/proc/get_gas_name(type)
	switch(type)
		if(HCZ_GAS_NONE)
			return "None"
		if(HCZ_GAS_SLEEPING)
			return "Sleeping Agent"
		if(HCZ_GAS_SUPPRESSANT)
			return "Fire Suppressant"
		if(HCZ_GAS_NEUROTOXIN)
			return "Neurotoxin"
		if(HCZ_GAS_MEMETIC_SCRUBBER)
			return "Memetic Scrubber"
		if(HCZ_GAS_AMNESTIC_VAPOR)
			return "Class-A Amnestic Vapor"

/obj/machinery/computer/hcz_gas_console/proc/release_gas()
	gas_active = TRUE
	affected_areas = list()

	for(var/area/A in get_sorted_areas())
		if(!istype(A, /area/scp/hcz))
			continue
		affected_areas += A

	priority_announce("GAS RELEASE INITIATED in Heavy Containment Zone — [get_gas_name(gas_type)] active. All personnel don breathing apparatus immediately.", null, "HCZ GAS ALERT", ANNOUNCER_ALERT)

	apply_gas_effects()
	gas_tick_timerid = addtimer(CALLBACK(src, PROC_REF(gas_tick)), 5 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/obj/machinery/computer/hcz_gas_console/proc/gas_tick()
	if(!gas_active)
		return
	if(gas_remaining <= 0)
		stop_gas()
		return

	gas_remaining = max(0, gas_remaining - 5)
	apply_gas_effects()

/obj/machinery/computer/hcz_gas_console/proc/apply_gas_effects()
	for(var/area/A in affected_areas)
		for(var/mob/living/L in A)
			if(QDELETED(L))
				continue
			if(L.stat == DEAD)
				continue
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(!C.wear_mask || !istype(C.wear_mask, /obj/item/clothing/mask/gas))
					apply_gas_to_mob(C)

/obj/machinery/computer/hcz_gas_console/proc/apply_gas_to_mob(mob/living/carbon/C)
	switch(gas_type)
		if(HCZ_GAS_SLEEPING)
			C.Sleeping(40)
		if(HCZ_GAS_SUPPRESSANT)
			C.adjust_fire_stacks(-5)
			if(C.on_fire)
				C.extinguish_mob()
		if(HCZ_GAS_NEUROTOXIN)
			C.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
			C.adjustToxLoss(2)
			if(prob(20))
				C.emote("cough")
		if(HCZ_GAS_MEMETIC_SCRUBBER)
			if(C.has_status_effect(/datum/status_effect/memetic_shield))
				return
			C.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
			if(prob(30))
				C.emote("cough")
		if(HCZ_GAS_AMNESTIC_VAPOR)
			C.blur_eyes(10)
			C.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
			C.drowsyness += 10
			if(prob(15))
				C.emote("cough")

/obj/machinery/computer/hcz_gas_console/proc/stop_gas()
	gas_active = FALSE
	gas_type = HCZ_GAS_NONE
	vent_cooldown = world.time + 2 MINUTES
	deltimer(gas_tick_timerid)
	gas_tick_timerid = null
	priority_announce("Gas release in Heavy Containment Zone has been terminated. Ventilation systems clearing residual agents.", null, "HCZ GAS CLEAR")

/obj/machinery/computer/hcz_gas_console/Destroy()
	if(gas_active)
		stop_gas()
	return ..()

/obj/item/circuitboard/computer/hcz_gas
	name = "HCZ Gas Control Console (Circuit Board)"
	build_path = /obj/machinery/computer/hcz_gas_console

#undef HCZ_GAS_NONE
#undef HCZ_GAS_SLEEPING
#undef HCZ_GAS_SUPPRESSANT
#undef HCZ_GAS_NEUROTOXIN
#undef HCZ_GAS_MEMETIC_SCRUBBER
#undef HCZ_GAS_AMNESTIC_VAPOR
