/datum/offsite
	abstract_type = /datum/offsite
	var/name = "Unset - contact a coder!"
	var/list/received_faxes = list()
	var/list/sent_faxes = list()
	var/list/history = list()
	var/current_history_id = 0

/datum/offsite/proc/receive_fax(obj/item/paper/ref, origin_department = "Unknown", mob/sender)
	origin_department = (origin_department || "Unknown")
	current_history_id++
	var/list/to_add = list(list(
		"id" = current_history_id,
		"time" = world.time,
		"dept" = origin_department,
		"user" = key_name(sender),
		"user_key" = sender?.ckey
	))
	received_faxes += to_add
	history += to_add

	var/adjusted_message = span_notice("<b><font color=darkgreen>FAX TO [name] FROM [origin_department] BY [key_name(sender)]</b></font> - <a href='?src=[REF(src)];send_message=[current_history_id]'>Reply with Message</a>, <a href='?src=[REF(src)];send_fax=[current_history_id]'>Reply with Fax</a>")
	for(var/client/C in GLOB.admins)
		if(check_rights_for(C, R_ADMIN, FALSE))
			to_chat(C, adjusted_message)

/datum/offsite/proc/send_message(client/admin, mob/living/recipient = null)
	if(!check_rights_for(admin, R_ADMIN))
		return
	if(!recipient)
		var/list/choices = list()
		for(var/mob/living/L in GLOB.player_list)
			if(L.stat != DEAD)
				choices += L
		recipient = tgui_input_list(admin, "Choose the recipient of your message.", "Choose Recipient", choices)
	if(!istype(recipient))
		return
	var/message = tgui_input_text(admin, message = "Enter a message to be sent to the recipient.", title = "Message Input", multiline = TRUE)
	if(!message)
		return
	current_history_id++
	sent_faxes += list(list(
		"id" = current_history_id,
		"time" = world.time,
		"user" = key_name(recipient),
		"admin" = admin.ckey
	))
	log_admin("[admin] sent a message from [name] to [key_name(recipient)]: \"[message]\"")
	message_admins("[key_name_admin(admin)] has sent a message from [name] to [key_name(recipient)]: \"[message]\"")
	to_chat(recipient, span_info("You hear something crackle in your headset for a moment before a voice speaks."))
	to_chat(recipient, span_info("Please stand by for a message from [name]."))
	to_chat(recipient, span_info("Message as follows."))
	to_chat(recipient, span_notice("[message]"))
	to_chat(recipient, span_info("Message ends."))

/datum/offsite/proc/get_fax_machines_by_department(department)
	var/list/machines = list()
	for(var/obj/machinery/fax_machine/machine as anything in GLOB.fax_machines)
		if(machine.room_tag == department)
			machines += machine
	return machines

/datum/offsite/Topic(href, href_list)
	if(..())
		return
	var/client/admin = usr?.client
	if(!check_rights_for(admin, R_ADMIN))
		return
	if(href_list["send_message"])
		var/id = text2num(href_list["send_message"])
		var/list/target_item
		for(var/L in history)
			if(L["id"] == id)
				target_item = L
				break
		if(!target_item)
			return
		var/client/target_client = GLOB.directory[target_item["user_key"]]
		if(!target_client || !target_client.mob)
			to_chat(admin, span_warning("That client or mob no longer exist!"))
			return
		var/mob/living/target = target_client.mob
		if(istype(target))
			send_message(admin, target)
		else
			to_chat(admin, span_warning("That mob is not living!"))
		return
	if(href_list["send_fax"])
		var/id = text2num(href_list["send_fax"])
		var/list/target_item
		for(var/L in history)
			if(L["id"] == id)
				target_item = L
				break
		if(!target_item)
			return
		var/fax_target = target_item["dept"]
		var/list/target_machines = get_fax_machines_by_department(fax_target)
		if(length(target_machines))
			var/obj/machinery/fax_machine/target_machine = target_machines[1]
			target_machine.admin_create_fax(admin)
		else
			to_chat(admin, span_warning("No fax machine found for department [fax_target]!"))
		return

GLOBAL_LIST_EMPTY(scp_offsites)

/proc/get_scp_offsite(name)
	for(var/datum/offsite/O in GLOB.scp_offsites)
		if(O.name == name)
			return O
	return null

/proc/init_scp_offsites()
	GLOB.scp_offsites = list()
	for(var/offsite_type in subtypesof(/datum/offsite))
		GLOB.scp_offsites += new offsite_type
