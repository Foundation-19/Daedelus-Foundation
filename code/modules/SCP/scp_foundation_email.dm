/obj/machinery/foundation_email_terminal
	name = "Foundation Email Terminal"
	desc = "A terminal for sending and receiving Foundation interdepartmental messages."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	circuit = /obj/item/circuitboard/computer/foundation_email_terminal
	var/list/inbox = list()
	var/max_messages = 50

/obj/machinery/foundation_email_terminal/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoundationEmail", "Foundation Email Terminal")
		ui.open()

/obj/machinery/foundation_email_terminal/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/foundation_email_terminal/ui_data(mob/user)
	var/list/data = list()
	data["inbox"] = inbox
	data["max_messages"] = max_messages
	return data

/obj/machinery/foundation_email_terminal/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("send_message")
			var/recipient = params["recipient"] || "All Staff"
			var/subject = params["subject"] || "No Subject"
			var/body = params["body"] || ""

			if(!usr)
				return

			var/sender_name = usr?.real_name || "Unknown"
			var/sender_job = "Unknown"
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				sender_job = H.job || "Unknown"

			var/message = list(
				"sender" = sender_name,
				"sender_job" = sender_job,
				"recipient" = recipient,
				"subject" = subject,
				"body" = body,
				"time" = gameTimestamp("hh:mm"),
				"priority" = params["priority"] || "normal"
			)

			for(var/obj/machinery/foundation_email_terminal/T)
				if(T == src)
					continue
				if(T.z != z)
					continue
				if(length(T.inbox) >= T.max_messages)
					T.inbox.Cut(1, 2)
				T.inbox += list(message)
				T.visible_message(span_notice("[T] receives a new message from [sender_name]."))
				playsound(T.loc, 'sound/machines/terminal_alert.ogg', 30, TRUE)

			if(length(inbox) >= max_messages)
				inbox.Cut(1, 2)
			inbox += list(message)

			if(GLOB.scp_admin_log)
				GLOB.scp_admin_log.log_event("email", "N/A", usr?.ckey || "N/A", recipient, "[subject]: [body]", 1)

			visible_message(span_notice("[src] sends the message."))
			playsound(loc, 'sound/machines/terminal_processing.ogg', 30, TRUE)
			return TRUE

		if("delete_message")
			var/idx = params["index"]
			if(idx && idx <= length(inbox))
				inbox.Cut(idx, idx + 1)
			return TRUE

		if("print_message")
			var/idx = params["index"]
			if(!idx || idx > length(inbox))
				return

			var/msg = inbox[idx]
			var/obj/item/paper/P = new(get_turf(src))
			P.name = "Email: [msg["subject"]]"
			P.info = {"
				<center><b>SCP FOUNDATION INTERDEPARTMENTAL MEMO</b></center>
				<hr>
				<b>From:</b> [msg["sender"]] ([msg["sender_job"]])<br>
				<b>To:</b> [msg["recipient"]]<br>
				<b>Subject:</b> [msg["subject"]]<br>
				<b>Time:</b> [msg["time"]]<br>
				<b>Priority:</b> [msg["priority"]]<br>
				<hr>
				[msg["body"]]<br>
				<hr>
				<center><i>SCP Foundation Secure Communications Network</i></center>
			"}
			visible_message(span_notice("[src] prints the message."))
			playsound(loc, 'sound/machines/printer.ogg', 50, TRUE)
			return TRUE

/obj/item/circuitboard/computer/foundation_email_terminal
	name = "Foundation Email Terminal (Computer Board)"
	build_path = /obj/machinery/foundation_email_terminal
