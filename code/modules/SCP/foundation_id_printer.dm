/obj/machinery/id_card_printer
	name = "Foundation ID Card Printer"
	desc = "A machine used to print and modify Foundation keycards with appropriate access levels."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	circuit = /obj/item/circuitboard/machine/id_card_printer

/obj/machinery/id_card_printer/attack_hand(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/machinery/id_card_printer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationIDPrinter", name)
		ui.open()

/obj/machinery/id_card_printer/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H?.get_idcard(TRUE)
	if(!id_card)
		data["has_card"] = FALSE
		return data

	data["has_card"] = TRUE
	data["card_name"] = id_card.registered_name
	data["card_rank"] = id_card.assignment
	data["card_access"] = list()
	data["available_access"] = list()

	var/list/all_access = list(
		"Security" = list(ACCESS_SECURITY, ACCESS_SECURITY_LVL1, ACCESS_SECURITY_LVL2, ACCESS_SECURITY_LVL3, ACCESS_SECURITY_LVL4, ACCESS_SECURITY_LVL5),
		"Command" = list(ACCESS_ADMIN, ACCESS_ADMIN_LVL1, ACCESS_ADMIN_LVL2, ACCESS_ADMIN_LVL3, ACCESS_ADMIN_LVL4, ACCESS_ADMIN_LVL5),
		"Science" = list(ACCESS_SCIENCE, ACCESS_SCIENCE_LVL1, ACCESS_SCIENCE_LVL2, ACCESS_SCIENCE_LVL3, ACCESS_SCIENCE_LVL4, ACCESS_SCIENCE_LVL5),
		"Medical" = list(ACCESS_MEDICAL, ACCESS_MEDICAL_LVL1, ACCESS_MEDICAL_LVL2, ACCESS_MEDICAL_LVL3, ACCESS_MEDICAL_LVL4, ACCESS_MEDICAL_LVL5),
		"Engineering" = list(ACCESS_ENGINEERING, ACCESS_ENGINEERING_LVL1, ACCESS_ENGINEERING_LVL2, ACCESS_ENGINEERING_LVL3, ACCESS_ENGINEERING_LVL4, ACCESS_ENGINEERING_LVL5),
		"Logistics" = list(ACCESS_LOGISTICS, ACCESS_LOGISTICS_LVL1, ACCESS_LOGISTICS_LVL2, ACCESS_LOGISTICS_LVL3, ACCESS_LOGISTICS_LVL4, ACCESS_LOGISTICS_LVL5),
		"Service" = list(ACCESS_SERVICE),
		"D-Class" = list(ACCESS_DCLASS, ACCESS_DCLASS_MINING, ACCESS_DCLASS_BOTANY, ACCESS_DCLASS_JANITORIAL, ACCESS_DCLASS_KITCHEN),
		"SCP-LCZ" = list(ACCESS_LCZ),
		"SCP-HCZ" = list(ACCESS_HCZ),
		"SCP-EZ" = list(ACCESS_EZ),
		"MTF" = list(ACCESS_MTF),
		"Containment" = list(ACCESS_CONTAINMENT_SCP_173, ACCESS_CONTAINMENT_SCP_049, ACCESS_CONTAINMENT_SCP_106, ACCESS_CONTAINMENT_SCP_096),
	)

	for(var/category in all_access)
		var/list/cat_access = all_access[category]
		var/list/cat_data = list()
		cat_data["category"] = category
		cat_data["entries"] = list()
		for(var/acc in cat_access)
			cat_data["entries"] += list(list(
				"access" = acc,
				"name" = get_access_name(acc),
				"granted" = (acc in id_card.access),
			))
		data["available_access"] += list(cat_data)

	return data

/obj/machinery/id_card_printer/proc/get_access_name(access_num)
	switch(access_num)
		if(ACCESS_SECURITY)
			return "Security"
		if(ACCESS_SECURITY_LVL1)
			return "Security L1"
		if(ACCESS_SECURITY_LVL2)
			return "Security L2"
		if(ACCESS_SECURITY_LVL3)
			return "Security L3"
		if(ACCESS_SECURITY_LVL4)
			return "Security L4"
		if(ACCESS_SECURITY_LVL5)
			return "Security L5"
		if(ACCESS_ADMIN)
			return "O5 Admin"
		if(ACCESS_ADMIN_LVL1)
			return "Admin L1"
		if(ACCESS_ADMIN_LVL2)
			return "Admin L2"
		if(ACCESS_ADMIN_LVL3)
			return "Admin L3"
		if(ACCESS_ADMIN_LVL4)
			return "Admin L4"
		if(ACCESS_ADMIN_LVL5)
			return "Admin L5"
		if(ACCESS_SCIENCE)
			return "Science"
		if(ACCESS_SCIENCE_LVL1)
			return "Science L1"
		if(ACCESS_SCIENCE_LVL2)
			return "Science L2"
		if(ACCESS_SCIENCE_LVL3)
			return "Science L3"
		if(ACCESS_SCIENCE_LVL4)
			return "Science L4"
		if(ACCESS_SCIENCE_LVL5)
			return "Science L5"
		if(ACCESS_MEDICAL)
			return "Medical"
		if(ACCESS_MEDICAL_LVL1)
			return "Medical L1"
		if(ACCESS_MEDICAL_LVL2)
			return "Medical L2"
		if(ACCESS_MEDICAL_LVL3)
			return "Medical L3"
		if(ACCESS_MEDICAL_LVL4)
			return "Medical L4"
		if(ACCESS_MEDICAL_LVL5)
			return "Medical L5"
		if(ACCESS_ENGINEERING)
			return "Engineering"
		if(ACCESS_ENGINEERING_LVL1)
			return "Engineering L1"
		if(ACCESS_ENGINEERING_LVL2)
			return "Engineering L2"
		if(ACCESS_ENGINEERING_LVL3)
			return "Engineering L3"
		if(ACCESS_ENGINEERING_LVL4)
			return "Engineering L4"
		if(ACCESS_ENGINEERING_LVL5)
			return "Engineering L5"
		if(ACCESS_LOGISTICS)
			return "Logistics"
		if(ACCESS_LOGISTICS_LVL1)
			return "Logistics L1"
		if(ACCESS_LOGISTICS_LVL2)
			return "Logistics L2"
		if(ACCESS_LOGISTICS_LVL3)
			return "Logistics L3"
		if(ACCESS_LOGISTICS_LVL4)
			return "Logistics L4"
		if(ACCESS_LOGISTICS_LVL5)
			return "Logistics L5"
		if(ACCESS_SERVICE)
			return "Service"
		if(ACCESS_DCLASS)
			return "D-Class"
		if(ACCESS_DCLASS_MINING)
			return "D-Class Mining"
		if(ACCESS_DCLASS_BOTANY)
			return "D-Class Botany"
		if(ACCESS_DCLASS_JANITORIAL)
			return "D-Class Janitorial"
		if(ACCESS_DCLASS_KITCHEN)
			return "D-Class Kitchen"
		if(ACCESS_LCZ)
			return "LCZ"
		if(ACCESS_HCZ)
			return "HCZ"
		if(ACCESS_EZ)
			return "EZ"
		if(ACCESS_MTF)
			return "MTF"
		if(ACCESS_CONTAINMENT_SCP_173)
			return "SCP-173"
		if(ACCESS_CONTAINMENT_SCP_049)
			return "SCP-049"
		if(ACCESS_CONTAINMENT_SCP_106)
			return "SCP-106"
		if(ACCESS_CONTAINMENT_SCP_096)
			return "SCP-096"
		else
			return "Clearance #[access_num]"

/obj/machinery/id_card_printer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/H = ui.user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card)
		return

	var/obj/item/card/id/admin_card = H.get_idcard(TRUE)
	if(!(ACCESS_ADMIN in admin_card.access))
		to_chat(H, span_warning("You need Administrator access to modify cards."))
		return

	switch(action)
		if("grant_access")
			var/access_num = text2num(params["access"])
			if(access_num && !(access_num in id_card.access))
				id_card.access += access_num
				id_card.update_label()
				playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		if("revoke_access")
			var/access_num = text2num(params["access"])
			if(access_num && (access_num in id_card.access))
				id_card.access -= access_num
				id_card.update_label()
				playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		if("set_rank")
			var/new_rank = params["rank"]
			if(new_rank)
				id_card.assignment = new_rank
				id_card.update_label()
		if("print_new")
			var/obj/item/card/id/advanced/new_card = new(get_turf(src))
			new_card.registered_name = id_card.registered_name
			new_card.assignment = "Unassigned"
			H.put_in_hands(new_card)
			playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
