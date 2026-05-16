/obj/machinery/computer/scp5295
	name = "Macintosh LC III"
	desc = "A 1993 Apple Macintosh LC III personal computer. It has an anomalous application running on its desktop."
	icon = 'icons/scp/scp-5295.dmi'
	icon_state = "scp5295"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	circuit = null

	var/active = TRUE
	var/connected = FALSE
	var/list/accessed_files = list()
	var/scan_cooldown = 0
	var/scan_cooldown_time = 30 SECONDS

/obj/machinery/computer/scp5295/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Person-to-Personal Computer", SCP_EUCLID, "5295")
/obj/machinery/computer/scp5295/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user))
		return

	if(!active || machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("The computer is unresponsive."))
		return

	ui_interact(user)

/obj/machinery/computer/scp5295/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	var/list/dat = list()
	dat += "<h2>Macintosh LC III — Anomalous Network</h2>"
	dat += "<br>System: Mac OS 7.1<br>"
	dat += "Application: <b>P2P-Link v0.3</b> (anomalous)<br>"
	dat += "<hr>"

	if(connected)
		dat += "<b>Status:</b> Connected to remote LC III<br><br>"
		if(length(accessed_files))
			dat += "<b>Remote Files:</b><br>"
			for(var/entry in accessed_files)
				dat += "- [entry]<br>"
		else
			dat += "<i>No files retrieved yet.</i>"
		dat += "<br><br><a href='?src=[REF(src)];disconnect=1'>Disconnect</a>"
		dat += " | <a href='?src=[REF(src)];browse=1'>Browse Files</a>"
		dat += " | <a href='?src=[REF(src)];read=1'>Read File</a>"
	else
		dat += "<b>Status:</b> Disconnected<br><br>"
		dat += "<a href='?src=[REF(src)];connect=1'>Connect to Remote LC III</a>"

	dat += "<hr>"
	dat += "<a href='?src=[REF(src)];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "scp5295", "Macintosh LC III", 450, 400)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/computer/scp5295/Topic(href, href_list)
	if(!isliving(usr))
		return

	if(href_list["close"])
		usr << browse(null, "window=scp5295")
		return

	if(href_list["connect"])
		if(world.time < scan_cooldown)
			to_chat(usr, span_warning("The P2P-Link application is still searching..."))
			return
		connected = TRUE
		scan_cooldown = world.time + scan_cooldown_time
		to_chat(usr, span_notice("The P2P-Link application connects to a remote Macintosh LC III somewhere in the world."))
		hook_scp_interaction(usr, "SCP-5295", INTERACTION_TYPE_OBSERVATION)

	if(href_list["disconnect"])
		connected = FALSE
		accessed_files = list()
		to_chat(usr, span_notice("Disconnected from remote system."))

	if(href_list["browse"])
		if(!connected)
			to_chat(usr, span_warning("Not connected to any remote system."))
		else
			generate_remote_files()
			to_chat(usr, span_notice("Browsing remote file system..."))

	if(href_list["read"])
		if(!connected)
			to_chat(usr, span_warning("Not connected."))
		else if(!length(accessed_files))
			to_chat(usr, span_warning("No files to read. Browse first."))
		else
			var/choice = input(usr, "Select a file to read:", "SCP-5295") as null|anything in accessed_files
			if(choice)
				var/content = accessed_files[choice]
				if(content)
					to_chat(usr, span_notice("<b>[choice]:</b> [content]"))
				else
					to_chat(usr, span_notice("<b>[choice]:</b> <i>File contents are garbled or corrupted.</i>"))

	ui_interact(usr)

/obj/machinery/computer/scp5295/proc/generate_remote_files()
	accessed_files = list()

	var/list/file_names = list(
		"Personal_Journal.txt",
		"Budget_1993.xls",
		"Phone_Numbers.txt",
		"README.doc",
		"Family_Photo.jpg",
		"Work_Notes.txt",
		"Calendar_March_93.dat",
		"Untited_2.txt",
		"Passwords.txt",
		"System_Log.sys"
	)

	var/list/file_contents = list(
		"March 15th — Something strange happened at work today. The computers all turned on by themselves at 3 AM...",
		"Q1 expenses: $2,340.50. Note: unexplained charge of $0.00 appeared on line 47.",
		"Mom: 555-0143 | Dr. Harris: 555-8821 | Work: 555-6700",
		"Thank you for purchasing the Macintosh LC III. If you are reading this through P2P-Link, you are not alone.",
		"\[IMAGE: A family standing in front of a house. The timestamp reads 03/03/1993. One figure appears blurred.\]",
		"Meeting notes: The LC III in accounting keeps displaying files that aren't on our network. IT has no explanation.",
		"Recurring event: 'IT CHECKUP' — every Tuesday at 9:00 AM. No one remembers creating this.",
		"i cant see the screen properly anymore. the other computer is watching. its always watching.",
		"System: admin | Email: admin@site17.internal | Clearance: Level 3 — THIS SHOULD NOT BE ACCESSIBLE",
		"\[SYSTEM\] Remote connection established from unknown node. Connection origin: [pick("Site-17", "Residence-4C", "Unknown", "Coordinator Office", "████████")] at [time2text(world.time, "hh:mm:ss")]"
	)

	var/count = min(length(file_names), rand(3, 7))
	var/list/indices = list()
	for(var/i in 1 to length(file_names))
		indices += i

	shuffle(indices)

	for(var/i in 1 to count)
		var/idx = indices[i]
		accessed_files[file_names[idx]] = file_contents[idx]

/obj/machinery/computer/scp5295/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A 1993 Apple Macintosh LC III with an anomalous application that can access files on other LC III computers remotely."))
	if(active && !(machine_stat & (NOPOWER|BROKEN)))
		to_chat(user, span_notice("The screen glows faintly, the P2P-Link application running in the background."))
