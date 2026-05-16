#define LINKIFY_CONSOLE_OPTION(str, cmd) "<a class='rawLink' href='byond://?src=\ref[src];[cmd]' onmouseover='fillInput(\"[str]\");' onmouseout='fillInput(\"&#8203;\");'>[str]</a>"
#define CONSOLE_BACK "<a class='rawLink' href='byond://?src=\ref[src];main_menu=1' onmouseover='fillInput(\"cd..\");' onmouseout='fillInput(\"&#8203;\");'>Back</a>"
#define LINKIFY_READY(string, value) "<a class='cursorPointer' href='byond://?src=\ref[src];ready=[value]'>[string]</a>"

#define NPP_TAB_MAIN "main"
#define NPP_TAB_GAME "game"

/datum/new_player_panel
	var/mob/dead/new_player/parent
	var/active_tab = NPP_TAB_MAIN

/datum/new_player_panel/New(parent)
	src.parent = parent

/datum/new_player_panel/Destroy(force, ...)
	parent = null
	return ..()

/datum/new_player_panel/Topic(href, href_list[])
	if(parent != usr)
		return

	if(!parent.client)
		return


	if(href_list["verify"])
		show_otp_menu()
		return TRUE

	if(href_list["link_to_discord"])
		var/_link = CONFIG_GET(string/panic_bunker_discord_link)
		if(_link)
			parent << link(_link)
		return TRUE

	//Restricted clients can't do anything else.
	if(parent.client.restricted_mode)
		return TRUE

	if(href_list["npp_options"])
		var/datum/preferences/preferences = parent.client.prefs
		preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)
		return TRUE

	if(href_list["view_primer"])
		view_primer()
		return TRUE

	if(href_list["character_setup"])
		// Open new TGUI Character Setup
		var/datum/character_setup_ui/CS = new(usr)
		CS.ui_interact(usr)
		return TRUE

	if(href_list["ready"])
		var/tready = text2num(href_list["ready"])
		//Avoid updating ready if we're after PREGAME (they should use latejoin instead)
		//This is likely not an actual issue but I don't have time to prove that this
		//no longer is required
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			parent.ready = tready

		//if it's post initialisation and they're trying to observe we do the needful
		if(SSticker.current_state >= GAME_STATE_SETTING_UP && tready == PLAYER_READY_TO_OBSERVE)
			parent.ready = tready
			parent.make_me_an_observer()
			return

		update()
		return

	if(href_list["npp_game"])
		change_tab(NPP_TAB_GAME)
		return

	if(href_list["main_menu"])
		change_tab(NPP_TAB_MAIN)
		return

	if(href_list["refresh"])
		parent << browse(null, "window=playersetup") //closes the player setup window
		open()

	if(href_list["manifest"])
		show_crew_manifest(parent)
		return

	if(href_list["late_join"]) //This still exists for queue messages in chat
		if(!SSticker?.IsRoundInProgress())
			to_chat(usr, span_boldwarning("The round is either not ready, or has already finished..."))
			return
		LateChoices()
		return

	if(href_list["SelectedJob"])
		if(!SSticker?.IsRoundInProgress())
			to_chat(usr, span_danger("The round is either not ready, or has already finished..."))
			return

		if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
			to_chat(usr, span_notice("There is an administrative lock on entering the game!"))
			return

		//Determines Relevent Population Cap
		var/relevant_cap
		var/hpc = CONFIG_GET(number/hard_popcap)
		var/epc = CONFIG_GET(number/extreme_popcap)
		if(hpc && epc)
			relevant_cap = min(hpc, epc)
		else
			relevant_cap = max(hpc, epc)

		if(SSticker.queued_players.len && !(ckey(parent.key) in GLOB.admin_datums))
			if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
				to_chat(usr, span_warning("Server is full."))
				return

		parent.AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(href_list["SelectedSCP"])
		if(!SSticker?.IsRoundInProgress())
			to_chat(usr, span_danger("The round is either not ready, or has already finished..."))
			return

		var/scp_type = href_list["SelectedSCP"]
		var/datum/scp_role_controller/controller = GLOB.scp_role_controller
		if(!controller)
			return

		var/role_flag = controller.get_role_flag(scp_type)
		if(role_flag && parent.client?.prefs)
			var/list/client_antags = parent.client.prefs.read_preference(/datum/preference/blob/antagonists)
			if(!(client_antags?[role_flag]))
				to_chat(usr, span_warning("You do not have this role enabled in your preferences."))
				return

		if(check_scp_blacklist(parent.ckey, scp_type))
			to_chat(usr, span_warning("You are blacklisted from this SCP role."))
			return

		INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/scp_role_controller, offer_scp_role_from_lobby), parent, scp_type)
		return

	else if(!href_list["late_join"])
		open()

	if(href_list["showpoll"])
		parent.handle_player_polling()
		return

	if(href_list["viewpoll"])
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.polls
		parent.poll_player(poll)

	if(href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.polls
		parent.vote_on_poll_handler(poll, href_list)

/datum/new_player_panel/proc/update()
	change_tab(active_tab)

/datum/new_player_panel/proc/open()
	if(parent.client?.restricted_mode)
		restricted_client_panel()
		return

	active_tab = NPP_TAB_MAIN

	var/list/output = list()
	output += npp_header()
	output += "<div id='content'>"
	output += npp_main("dir")
	output += "</div>"

	var/datum/browser/popup = new(parent, "playersetup", "", 480, 360)
	popup.set_window_options("can_close=0;focus=false;can_resize=0")
	popup.set_content(output.Join())
	popup.open(FALSE)

/datum/new_player_panel/proc/change_tab(new_tab)
	var/content
	if(parent.client?.restricted_mode)
		restricted_client_panel()
		return

	switch(new_tab)
		if(NPP_TAB_MAIN)
			content = npp_main("cd..")
			active_tab = NPP_TAB_MAIN

		if(NPP_TAB_GAME)
			content = npp_game("space_station_13.exe")
			active_tab = NPP_TAB_GAME

		else
			return

	parent << output(url_encode(content), "playersetup.browser:update_content")

/datum/new_player_panel/proc/npp_header()
	return {"
		<script type='text/javascript'>
			function fillInput(text){
			const elem = document.getElementById("input");
			elem.innerHTML = text;
		}

		function update_content(data){
			document.getElementById('content').innerHTML = data;
		}

		function byondCall(cmd){
			window.location = 'byond://?src=[ref(src)];' + cmd;
		}

		</script>
	"}

/datum/new_player_panel/proc/npp_main(last_cmd)
	var/list/output = list()

	var/poll = playerpolls()
	if(!is_guest_key(parent.client.key) && poll)
		poll = "<div>>[LINKIFY_CONSOLE_OPTION(poll, "showpoll=1")]</div>"

	output += {"
		<fieldset class='computerPane' style='height:260px'>
			<legend class='computerLegend' style='margin: 0 auto'>
				<b>SCiPNet Terminal</b>
			</legend>
			<div class='computerLegend flexColumn' style='font-size: 14px; height: 80%; text-align:left; color: #c8c8c8'>
				<div style='font-size: 16px; color: #d4a017'>
					C:\\Users\\[parent.ckey]\\SCP-Link>[last_cmd]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Personnel_File.exe", "npp_game=1")]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Site_Operations.cfg", "npp_options=1")]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Foundation_Briefing (Lore).txt", "view_primer=1")]
				</div>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Secure_Comms_Link (Discord).lnk", "verify=1")]
				</div>
				[poll]
				<br>
				<div>
					<span style='color: #d4a017'>C:\\Users\\[parent.ckey]\\SCP-Link&gt</span>
					<span id='input' class='consoleInput'>&#8203;</span>
				</div>
			</div>
		</fieldset>
	"}

	output += join_or_ready()

	return jointext(output, "")

/datum/new_player_panel/proc/npp_game(last_cmd)
	var/list/output = list()
	var/name = parent.client?.prefs.read_preference(/datum/preference/name/real_name)

	var/status
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		switch(parent.ready)
			if(PLAYER_NOT_READY)
				status = "<div>>Status: <span style='color: #cc4444'>Not Ready</span></div>"
			if(PLAYER_READY_TO_PLAY)
				status = "<div>>Status: <span style='color: #3a8a3a'>Ready</span></div>"
			if(PLAYER_READY_TO_OBSERVE)
				status = "<div>>Status: <span style='color: #5a8aaa'>Ready (Observe)</span></div>"
			else
				status = "<div>>Status: <span style='color: #cc4444'>Not Ready</span></div>"

	output += {"
		<fieldset class='computerPane' style='height:260px'>
			<legend class='computerLegend' style='margin: 0 auto'>
				<b>ThinkDOS Terminal</b>
			</legend>
			<div class='computerLegend flexColumn' style='font-size: 14px; height: 80%; text-align:left; color: #c8c8c8'>
				<div style='font-size: 16px; color: #d4a017'>
					C:\\Users\\[parent.ckey]\\ss13&gt;[last_cmd]
				</div>
				<div>
					>Loaded File: <b style='color: #d4a017'>[name]</b>
				</div>
				[status]
				<br>
				<div>
					>[LINKIFY_CONSOLE_OPTION("Modify [name].txt", "character_setup=1")]
				</div>
				<div>
					>[CONSOLE_BACK]
				</div>
				<br>
				<div>
					<span style='color: #d4a017'>C:\\Users\\[parent.ckey]\\ss13&gt</span>
					<span id='input' class='consoleInput'>&#8203;</span>
				</div>
			</div>
		</fieldset>
	"}

	output += join_or_ready()

	return jointext(output, "")

/datum/new_player_panel/proc/join_or_ready()
	var/list/output = list()
	output += {"
		<div class='flexColumn' style='justify-content: center;align-items: center;width:100%;font-size: 16px;'>
	"}

	if(SSticker.current_state > GAME_STATE_PREGAME)
		output += {"
			<div class='flexRow' style='justify-content: center;align-items: center;width:100%;margin-top: 4px;'>
				<div class='flexItem'>[button_element(src, "// JOIN GAME //", "late_join=1")]</div>
				<div class='flexItem'>[LINKIFY_READY("// OBSERVE //", PLAYER_READY_TO_OBSERVE)]</div>
			</div>
		"}
		output += "<div class='flexItem' style='margin-top: 8px'>[button_element(src, "View Station Manifests", "manifest=1")]</div>"
	else
		switch(parent.ready)
			if(PLAYER_NOT_READY)
				output += "<div>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | <span class='linkOn'>Not Ready</span> | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</div>"
			if(PLAYER_READY_TO_PLAY)
				output += "<div>\[ <span class='linkOn'>Ready</span> | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</div>"
			if(PLAYER_READY_TO_OBSERVE)
				output += "<div>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | <span class='linkOn'>Observe</span> \]</div>"
		output += "</div>"

	output += "</div>"
	return jointext(output, "")

/datum/new_player_panel/proc/restricted_client_panel()
	var/content = {"
		<div style='width:100%;height: 100%'>
			<fieldset class='computerPane'>
				<div class='computerLegend' style='margin: auto;height: 70%'>
				Welcome to Daedalus Dock's Test Server<br><br>
				We require discord verification in order to play, as a measure to protect us against griefing.
				</div>
			</fieldset>
			<div style = 'text-align: center'>[button_element(src, "Verify", "verify=1")]</div>
		</div>
	"}

	var/datum/browser/popup = new(parent, "playersetup", "<center><div>Welcome, New Player!</div></center>", 660, 270)
	popup.set_window_options("can_close=0;focus=false;can_resize=0")
	popup.set_content(content)
	popup.open(FALSE)

/datum/new_player_panel/proc/show_otp_menu()
	if(!parent.client)
		return

	if(!CONFIG_GET(flag/sql_enabled))
		alert(parent.client, "No database to link to, bud. Scream at the host.", "Writing to Nowhere.")
		return

	if(isnull(parent.client.linked_discord_account))
		alert(parent.client, "You haven't fully loaded, please wait...", "Please Wait")
		return

	if(parent.client.linked_discord_account?.valid)
		alert(parent.client, "Your discord account is already linked.\nIf you believe this is in error, please contact staff.\nLinked ID: [parent.client.linked_discord_account.discord_id]", "Already Linked")
		return

	var/discord_otp = parent.client.discord_get_or_generate_one_time_token_for_ckey(parent.ckey)
	var/discord_prefix = CONFIG_GET(string/discordbotcommandprefix)
	var/browse_body = {"
		<center>
		<span style='color:red'>Your One-Time-Password is:<br> [discord_otp]</span>
		<br><br>
		To link your Discord account, head to the Discord Server and make an entry ticket if you have not already. Then, paste the following into any channel:
		<hr/>
		</center>
		<code>
			[discord_prefix]verify [discord_otp]
		</code>
		<hr/>
		<center>[button_element(src, "Discord", "link_to_discord=1")]
		<br>
	"}

	var/datum/browser/popup = new(parent, "discordauth", "<center><div>Verification</div></center>", 660, 270)
	//If we aren't in restricted mode, let them close the window.
	popup.set_window_options("can_close=[!parent.client.restricted_mode];focus=true;can_resize=0")
	popup.set_content(browse_body)
	popup.open()

/datum/new_player_panel/proc/view_primer()
	var/content = {"
		<div style='width:100%; text-align:center; font-size: 16px'>
			Welcome, Foundation Personnel. The year is 2068.
		</div>
		<br><br>
		<div style='width:100%; text-align:center'>
			You are an employee of the SCP Foundation, a clandestine organization dedicated to containing anomalous entities, objects, and phenomena that pose a threat to global normalcy. Your current assignment is to a secure Foundation site, where you will contribute to the ongoing mission of Secure, Contain, Protect.
		</div>
		<br><br>
		<div style='width:100%; text-align:center'>
		Your duties may vary, from research and containment to security and logistics. Adhere strictly to all protocols, maintain operational security, and report any unusual occurrences immediately. The safety of humanity depends on your diligence.
		</div>
	"}
	var/datum/browser/popup = new(parent, "primer", "<center><div>Foundation Briefing</div></center>", 660, 350)
	popup.set_content(content)
	popup.open()

/datum/new_player_panel/proc/playerpolls()
	if (!SSdbcore.Connect())
		return

	var/isadmin = FALSE
	if(parent.client?.holder)
		isadmin = TRUE

	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = parent.ckey))

	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		return

	if(query_get_new_polls.NextRow())
		. = "polls.exe (new!)"
	else
		. = "polls.exe"

	qdel(query_get_new_polls)
	if(QDELETED(src))
		return null

	return .

/datum/new_player_panel/proc/LateChoices()
	var/list/dat = list()

	dat += {"
	<style>
		@keyframes cursorBlink {
			0% { opacity: 1.0; }
			50% { opacity: 0.0; }
			100% { opacity: 1.0; }
		}
		.scp-latejoin {
			background: #0a0a0c;
			color: #c8c8c8;
			font-family: 'Consolas', 'Courier New', monospace;
			padding: 0;
			width: 100%;
			max-width: 100%;
			overflow-x: hidden;
			position: relative;
		}
		.scp-latejoin::before {
			content: ' ';
			display: block;
			position: fixed;
			top: 0; left: 0; bottom: 0; right: 0;
			background: repeating-linear-gradient(
				0deg,
				rgba(0, 0, 0, 0.15) 0px,
				rgba(0, 0, 0, 0.15) 1px,
				transparent 1px,
				transparent 2px
			);
			z-index: 100;
			pointer-events: none;
		}
		.scp-latejoin::after {
			content: ' ';
			display: block;
			position: fixed;
			top: 0; left: 0; bottom: 0; right: 0;
			background: radial-gradient(ellipse at center, transparent 0%, rgba(0,0,0,0.35) 100%);
			z-index: 99;
			pointer-events: none;
		}
		.scp-header {
			border-bottom: 2px solid #8b0000;
			padding: 8px 12px;
			background: #5c0000;
			color: #e8e8e8;
			font-size: 14px;
			text-transform: uppercase;
			letter-spacing: 0.15em;
			text-align: center;
			text-shadow: 0 0 0.3em #8b0000;
		}
		.scp-subheader {
			font-size: 11px;
			color: #6a6a70;
			padding: 4px 12px;
			text-align: center;
			border-bottom: 1px solid #2a2a30;
		}
		.scp-alert {
			background: rgba(139, 0, 0, 0.25);
			border: 1px solid #8b0000;
			border-left: 3px solid #8b0000;
			padding: 6px 10px;
			text-align: center;
			margin: 6px 8px;
			color: #cc4444;
			font-size: 12px;
			text-transform: uppercase;
			letter-spacing: 0.05em;
		}
		.scp-dept {
			background: #111114;
			color: #d4a017;
			font-weight: bold;
			padding: 5px 10px;
			text-align: center;
			border-bottom: 1px solid #2a2a30;
			border-top: 1px solid #2a2a30;
			text-transform: uppercase;
			letter-spacing: 0.1em;
			font-size: 11px;
		}
		.scp-job-row {
			display: flex;
			align-items: center;
			padding: 3px 10px;
			border-bottom: 1px solid rgba(42, 42, 48, 0.5);
			transition: background 0.1s;
		}
		.scp-job-row:hover {
			background: rgba(139, 0, 0, 0.2);
		}
		.scp-job-row a {
			flex: 1;
			color: #c8c8c8;
			text-decoration: none;
			font-size: 12px;
			display: block;
			padding: 2px 0;
		}
		.scp-job-row a:hover {
			color: #d4a017;
		}
		.scp-job-count {
			color: #6a6a70;
			font-size: 11px;
			min-width: 30px;
			text-align: right;
		}
		.scp-job-priority a {
			color: #3a8a3a;
			text-shadow: 0 0 0.1em #3a8a3a;
		}
		.scp-job-command a {
			color: #d4a017;
			text-shadow: 0 0 0.1em #d4a017;
		}
		.scp-empty {
			padding: 8px 10px;
			text-align: center;
			font-style: italic;
			color: #6a6a70;
			font-size: 11px;
		}
		.scp-footer {
			border-top: 1px solid #2a2a30;
			padding: 6px 12px;
			text-align: center;
			font-size: 10px;
			color: #6a6a70;
		}
		.scp-cursor {
			display: inline-block;
			width: 8px;
			height: 14px;
			background: #d4a017;
			animation: cursorBlink 1s step-end infinite;
			vertical-align: middle;
			margin-left: 4px;
		}
	</style>
	"}

	dat += "<div class='scp-latejoin'>"
	dat += "<div class='scp-header'>// SITE-53 PERSONNEL ASSIGNMENT TERMINAL //</div>"
	dat += "<div class='scp-subheader'>ROUND DURATION: [DisplayTimeText(world.time - SSticker.round_start_time)] &nbsp;|&nbsp; CLEARANCE: PENDING</div>"

	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		dat += "<div class='scp-alert'>// WARNING: PERSONNEL LOCKOUT IN EFFECT — OBSERVERS ONLY //</div>"

	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				dat += "<div class='scp-alert'>// ALERT: SITE EVACUATION COMPLETE //</div>"
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					dat += "<div class='scp-alert'>// ALERT: EVACUATION IN PROGRESS //</div>"

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	for(var/datum/job_department/department as anything in SSjob.departments)
		if(department.exclude_from_latejoin)
			continue

		dat += "<div class='scp-dept'>[department.department_name]</div>"

		var/list/dept_data = list()
		for(var/datum/job/job_datum as anything in department.department_jobs)
			if(parent.IsJobUnavailable(job_datum.title, TRUE) != JOB_AVAILABLE)
				continue

			var/row_class = "scp-job-row"
			if(job_datum in SSjob.prioritized_jobs)
				row_class = "scp-job-row scp-job-priority"
			else if(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMPANY_LEADER)
				row_class = "scp-job-row scp-job-command"

			dept_data += "<div class='[row_class]'><a href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]'>[job_datum.title]</a><span class='scp-job-count'>([job_datum.current_positions])</span></div>"

		if(!length(dept_data))
			dept_data += "<div class='scp-empty'>// NO POSITIONS AVAILABLE //</div>"

		dat += dept_data.Join()

	var/list/scp_info = GLOB.scp_role_controller?.get_scp_info_list() || list()
	if(length(scp_info))
		dat += "<div class='scp-dept' style='border-bottom-color: #8b0000; border-top-color: #8b0000;'>ANOMALOUS ENTITIES</div>"
		for(var/list/scp as anything in scp_info)
			dat += "<div class='scp-job-row'><a href='byond://?src=[REF(src)];SelectedSCP=[scp["scp_type"]]' style='color: #8b0000;'>[scp["name"]]</a></div>"

	dat += "<div class='scp-footer'>SECURE. CONTAIN. PROTECT.<span class='scp-cursor'></span></div>"
	dat += "</div>"

	var/datum/browser/popup = new(parent, "latechoices", "Personnel Assignment Terminal", 520, 520)
	popup.set_window_options("can_close=1;can_resize=0")
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE)

#undef LINKIFY_CONSOLE_OPTION
#undef NPP_TAB_MAIN
#undef NPP_TAB_GAME
#undef CONSOLE_BACK
#undef LINKIFY_READY
