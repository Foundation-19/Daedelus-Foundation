/obj/structure/foundation_gate
	name = "Facility Gate"
	desc = "A heavy reinforced gate controlling surface access to the facility."
	icon = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	icon_state = "closed"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/gate_id = "gate_a"
	var/locked = FALSE
	var/open = FALSE

/obj/structure/foundation_gate/attack_hand(mob/user)
	if(locked)
		to_chat(user, span_warning("The gate is locked."))
		return
	toggle()

/obj/structure/foundation_gate/proc/toggle()
	open = !open
	if(open)
		density = FALSE
		opacity = FALSE
		icon_state = "open"
	else
		density = TRUE
		opacity = TRUE
		icon_state = "closed"

/obj/structure/foundation_gate/gate_a
	name = "Gate A"
	desc = "Gate A - Primary surface entrance. Main personnel entry and exit point."
	gate_id = "gate_a"

/obj/structure/foundation_gate/gate_b
	name = "Gate B"
	desc = "Gate B - Emergency exit and MTF deployment gate. Restricted access."
	gate_id = "gate_b"

/obj/structure/foundation_gate/gate_a/Initialize(mapload)
	. = ..()
	GLOB.foundation_gates["gate_a"] = src

/obj/structure/foundation_gate/gate_b/Initialize(mapload)
	. = ..()
	GLOB.foundation_gates["gate_b"] = src

/obj/structure/foundation_gate/Destroy()
	GLOB.foundation_gates -= gate_id
	return ..()

/obj/effect/landmark/gate_a
	name = "Gate A spawn point"

/obj/effect/landmark/gate_b
	name = "Gate B spawn point"

/obj/machinery/foundation_gate_control
	name = "Gate Control Console"
	desc = "A console for controlling the facility's surface gates."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50

/obj/machinery/foundation_gate_control/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		to_chat(H, span_warning("Command access required."))
		return
	ui_interact(H)

/obj/machinery/foundation_gate_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationGateControl", name)
		ui.open()

/obj/machinery/foundation_gate_control/ui_data(mob/user)
	var/list/data = list()
	data["gates"] = list()
	for(var/gate_id in GLOB.foundation_gates)
		var/obj/structure/foundation_gate/G = GLOB.foundation_gates[gate_id]
		data["gates"] += list(list(
			"id" = gate_id,
			"name" = G.name,
			"open" = G.open,
			"locked" = G.locked,
		))
	return data

/obj/machinery/foundation_gate_control/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/H = usr
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_ADMIN in id_card.access))
		return

	switch(action)
		if("toggle_gate")
			var/gate_id = params["gate_id"]
			var/obj/structure/foundation_gate/G = GLOB.foundation_gates[gate_id]
			if(G)
				G.toggle()
				log_game("[key_name(H)] toggled [G.name] via gate control console.")
		if("lock_gate")
			var/gate_id = params["gate_id"]
			var/obj/structure/foundation_gate/G = GLOB.foundation_gates[gate_id]
			if(G)
				G.locked = !G.locked
				if(G.locked && G.open)
					G.toggle()
				log_game("[key_name(H)] [G.locked ? "locked" : "unlocked"] [G.name] via gate control console.")

/obj/structure/helipad
	name = "Helipad"
	desc = "A marked helipad for VTOL aircraft operations."
	icon = 'icons/turf/decals.dmi'
	icon_state = "helipad"
	anchored = TRUE
	layer = TURF_DECAL_LAYER
	var/helipad_id = "main"

/obj/structure/helipad/mtf
	name = "MTF Deployment Helipad"
	desc = "A helipad designated for Mobile Task Force deployments."
	helipad_id = "mtf"

GLOBAL_LIST_EMPTY(foundation_gates)
