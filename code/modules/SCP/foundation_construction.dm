/obj/item/containtment_construction_kit
	name = "Containment Construction Kit"
	desc = "A portable kit containing materials and tools for constructing basic containment cells."
	icon = 'icons/obj/storage.dmi'
	icon_state = "briefcase"
	w_class = WEIGHT_CLASS_BULKY
	var/uses = 5

/obj/item/containtment_construction_kit/attack_self(mob/user)
	if(uses <= 0)
		to_chat(user, span_warning("The kit has been depleted."))
		return
	ui_interact(user)

/obj/item/containtment_construction_kit/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ContainmentConstruction", name)
		ui.open()

/obj/item/containtment_construction_kit/ui_data(mob/user)
	var/list/data = list()
	data["uses"] = uses
	data["max_uses"] = 5
	data["build_options"] = list(
		list("id" = "wall", "name" = "Containment Wall", "cost" = 1, "desc" = "Reinforced wall with high structural integrity."),
		list("id" = "door", "name" = "Containment Door", "cost" = 1, "desc" = "Heavy blast door with keycard access."),
		list("id" = "window", "name" = "Observation Window", "cost" = 1, "desc" = "Reinforced glass window for observation."),
		list("id" = "airlock", "name" = "Decontamination Airlock", "cost" = 2, "desc" = "Two-door airlock with decontamination spray."),
	)
	return data

/obj/item/containtment_construction_kit/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("build")
			var/build_type = params["build_id"]
			var/cost = text2num(params["cost"])
			if(uses < cost)
				to_chat(usr, span_warning("Not enough materials remaining."))
				return
			uses -= cost
			var/turf/T = get_turf(usr)
			if(!T)
				return
			switch(build_type)
				if("wall")
					var/turf/closed/wall/W = T
					if(istype(W))
						to_chat(usr, span_warning("There's already a wall here."))
						uses += cost
						return
					var/turf/new_wall = T.ChangeTurf(/turf/closed/wall)
					if(new_wall)
						playsound(T, 'sound/items/welder.ogg', 50, TRUE)
						to_chat(usr, span_notice("Containment wall constructed."))
				if("door")
					var/obj/machinery/door/airlock/scp/containment/D = new(T)
					if(D)
						playsound(T, 'sound/machines/doors/airlock_close.ogg', 50, TRUE)
						to_chat(usr, span_notice("Containment door installed."))
				if("window")
					var/obj/structure/window/reinforced/W = new(T)
					if(W)
						playsound(T, 'sound/effects/glassbr1.ogg', 50, TRUE)
						to_chat(usr, span_notice("Observation window installed."))
				if("airlock")
					var/obj/machinery/door/airlock/scp/decon/A = new(T)
					if(A)
						playsound(T, 'sound/machines/doors/airlock_close.ogg', 50, TRUE)
						to_chat(usr, span_notice("Decontamination airlock installed."))

/obj/machinery/door/airlock/scp
	name = "Foundation airlock"
	desc = "A heavy Foundation airlock with keycard access."
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sc
	req_access = list(ACCESS_SCIENCE)
	normal_integrity = 500

/obj/machinery/door/airlock/scp/containment
	name = "Containment Door"
	desc = "A reinforced containment cell door requiring appropriate clearance."
	req_access = list(ACCESS_CONTAINMENT_SCP_173)
	normal_integrity = 800
	explosion_block = 2

/obj/machinery/door/airlock/scp/decon
	name = "Decontamination Airlock"
	desc = "An airlock with built-in decontamination systems."
	req_access = list(ACCESS_SCIENCE)
	normal_integrity = 600

/obj/structure/door_assembly/door_assembly_sc
	name = "Foundation airlock assembly"
	airlock_type = /obj/machinery/door/airlock/scp

/obj/machinery/door/airlock/scp/lcz
	name = "LCZ Airlock"
	req_access = list(ACCESS_LCZ)

/obj/machinery/door/airlock/scp/hcz
	name = "HCZ Airlock"
	req_access = list(ACCESS_HCZ)

/obj/machinery/door/airlock/scp/ez
	name = "EZ Airlock"
	req_access = list(ACCESS_EZ)
