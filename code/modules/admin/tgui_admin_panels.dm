/datum/admin_player_panel_ui
	var/datum/admins/holder

/datum/admin_player_panel_ui/New(datum/admins/holder)
	src.holder = holder

/datum/admin_player_panel_ui/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_player_panel_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminPlayerPanel", "SCP FOUNDATION — PERSONNEL DATABASE", 900, 600)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/admin_player_panel_ui/ui_data(mob/user)
	var/list/data = list()
	var/list/players = list()

	var/list/mobs = sort_mobs()
	for(var/mob/M in mobs)
		if(!M.ckey)
			continue

		var/list/pd = list()
		pd["name"] = M.name
		pd["real_name"] = M.real_name
		pd["key"] = M.key
		pd["ref"] = REF(M)
		pd["ckey"] = M.ckey

		var/job = "Unknown"
		if(isliving(M))
			if(ishuman(M))
				job = M.job
			else if(ismonkey(M))
				job = "Monkey"
			else if(isalien(M))
				job = islarva(M) ? "Alien Larva" : "Alien"
			else if(isAI(M))
				job = "AI"
			else if(iscyborg(M))
				job = "Cyborg"
			else if(ispAI(M))
				job = "pAI"
			else if(isanimal(M))
				job = isslime(M) ? "Slime" : "Animal"
			else
				job = "Living"
		else if(isnewplayer(M))
			job = "New Player"
		else if(isobserver(M))
			var/mob/dead/observer/O = M
			job = O.started_as_observer ? "Observer" : "Ghost"

		pd["job"] = job
		pd["is_antag"] = is_special_character(M)
		pd["is_observer"] = isobserver(M)
		pd["is_human"] = ishuman(M)
		pd["is_new_player"] = isnewplayer(M)
		pd["is_silicon"] = issilicon(M)
		pd["is_monkey"] = ismonkey(M)
		pd["is_ai"] = isAI(M)
		pd["is_cyborg"] = iscyborg(M)
		pd["has_mind"] = !!M.mind
		pd["has_client"] = !!M.client
		pd["mob_type"] = "[M.type]"
		pd["last_ip"] = M.lastKnownIP

		if(M.client)
			pd["admin_rank"] = M.client.holder ? M.client.holder.rank : "Player"
			pd["playtime"] = M.client.get_exp_living(FALSE)
			pd["byond_version"] = "[M.client.byond_version].[M.client.byond_build || "xxx"]"
			pd["join_date"] = M.client.player_join_date
			pd["account_date"] = M.client.account_join_date
			pd["input_mode"] = M.client.hotkeys ? "Hotkeys" : "Classic"
			var/muted = M.client.prefs.muted
			pd["muted_ic"] = !!(muted & MUTE_IC)
			pd["muted_ooc"] = !!(muted & MUTE_OOC)
			pd["muted_pray"] = !!(muted & MUTE_PRAY)
			pd["muted_ahelp"] = !!(muted & MUTE_ADMINHELP)
			pd["muted_deadchat"] = !!(muted & MUTE_DEADCHAT)
			pd["muted_all"] = !!(muted & MUTE_ALL)
			pd["discord_linked"] = !isnull(M.client.linked_discord_account)
			if(M.client.linked_discord_account)
				pd["discord_id"] = M.client.linked_discord_account.valid ? M.client.linked_discord_account.discord_id : "NONE"

		var/previous_names = ""
		if(M.ckey)
			var/datum/persistent_client/P = GLOB.persistent_clients_by_ckey[ckey(M.key)]
			if(P)
				previous_names = P.played_names.Join(", ")
		pd["previous_names"] = previous_names

		players += list(pd)

	data["players"] = players
	data["has_centcom_db"] = !!CONFIG_GET(string/centcom_ban_db)
	data["has_exp_tracking"] = !!CONFIG_GET(flag/use_exp_tracking)
	return data

/datum/admin_player_panel_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/M = locate(params["ref"]) in GLOB.mob_list
	if(!M)
		return

	switch(action)
		if("pp")
			holder.show_player_panel(M)
		if("vv")
			usr.client.debug_variables(M)
		if("tp")
			if(M.mind)
				M.mind.traitor_panel()
		if("pm")
			usr.client.cmd_admin_pm(M.ckey)
		if("sm")
			usr.client.cmd_admin_subtle_message(M)
		if("flw")
			usr.client.admin_follow(M)
		if("logs")
			var/source = M.ckey ? LOGSRC_CKEY : LOGSRC_MOB
			holder.Topic("", list("individuallog" = "[REF(M)]", "log_src" = source, "admin_token" = holder.href_token))
		if("notes")
			holder.Topic("", list("showmessageckey" = M.ckey, "admin_token" = holder.href_token))
		if("kick")
			holder.Topic("", list("boot2" = "[REF(M)]", "admin_token" = holder.href_token))
		if("ban")
			if(M.client)
				holder.ban_panel(M.ckey, M.client.address, M.client.computer_id)
			else
				holder.ban_panel(M.ckey)
		if("heal")
			holder.Topic("", list("revive" = "[REF(M)]", "admin_token" = holder.href_token))
		if("send_to_lobby")
			holder.Topic("", list("sendbacktolobby" = "[REF(M)]", "admin_token" = holder.href_token))
		if("prison")
			holder.Topic("", list("sendtoprison" = "[REF(M)]", "admin_token" = holder.href_token))
		if("jump_to")
			usr.client.jumptomob(M)
		if("get")
			usr.client.Getmob(M)
		if("send")
			usr.client.sendmob(M)
		if("narrate")
			usr.client.cmd_admin_direct_narrate(M)
		if("play_sound")
			holder.Topic("", list("playsoundto" = "[REF(M)]", "admin_token" = holder.href_token))
		if("language_menu")
			holder.Topic("", list("languagemenu" = "[REF(M)]", "admin_token" = holder.href_token))
		if("make_observer")
			holder.Topic("", list("simplemake" = "observer", "mob" = "[REF(M)]", "admin_token" = holder.href_token))
		if("make_human")
			holder.Topic("", list("simplemake" = "human", "mob" = "[REF(M)]", "admin_token" = holder.href_token))
		if("make_monkey")
			holder.Topic("", list("simplemake" = "monkey", "mob" = "[REF(M)]", "admin_token" = holder.href_token))
		if("make_cyborg")
			holder.Topic("", list("simplemake" = "robot", "mob" = "[REF(M)]", "admin_token" = holder.href_token))
		if("make_ai")
			holder.Topic("", list("makeai" = "[REF(M)]", "admin_token" = holder.href_token))
		if("forcesay")
			holder.Topic("", list("forcespeech" = "[REF(M)]", "admin_token" = holder.href_token))
		if("init_mind")
			M.mind_initialize()
		if("headset_msg")
			holder.Topic("", list("HeadsetMessage" = "[REF(M)]", "admin_token" = holder.href_token))
		if("check_antags")
			holder.check_antagonists()
		if("mute_toggle")
			if(!M.client)
				return
			var/mute_type = text2num(params["mute_type"])
			if(!isnum(mute_type))
				return
			holder.Topic("", list("mute" = M.ckey, "mute_type" = "[mute_type]", "admin_token" = holder.href_token))
		if("commend")
			holder.Topic("", list("admincommend" = "[REF(M)]", "admin_token" = holder.href_token))
		if("related_accounts_cid")
			if(M.client)
				holder.Topic("", list("showrelatedacc" = "cid", "client" = "[REF(M.client)]", "admin_token" = holder.href_token))
		if("related_accounts_ip")
			if(M.client)
				holder.Topic("", list("showrelatedacc" = "ip", "client" = "[REF(M.client)]", "admin_token" = holder.href_token))
		if("centcom_lookup")
			if(M.client)
				holder.Topic("", list("centcomlookup" = M.client.ckey, "admin_token" = holder.href_token))
		if("find_updated")
			if(M.ckey)
				var/mob/updated = get_mob_by_key(M.ckey)
				if(updated)
					holder.show_player_panel(updated)
		if("edit_rights")
			if(M.client)
				holder.Topic("", list("editrights" = (GLOB.admin_datums[M.client.ckey] || GLOB.deadmins[M.client.ckey]) ? "rank" : "add", "key" = M.key, "admin_token" = holder.href_token))
		if("skills")
			if(M.mind)
				holder.show_skill_panel(M.mind)
		if("subtle_msg")
			usr.client.cmd_admin_subtle_message(M)

	return TRUE


/datum/admin_game_panel_ui
	var/datum/admins/holder

/datum/admin_game_panel_ui/New(datum/admins/holder)
	src.holder = holder

/datum/admin_game_panel_ui/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_game_panel_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminGamePanel", "SCP FOUNDATION — GAME CONTROL TERMINAL", 700, 550)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/admin_game_panel_ui/ui_data(mob/user)
	var/list/data = list()

	data["round_state"] = SSticker.current_state
	data["round_state_text"] = SSticker.current_state <= GAME_STATE_PREGAME ? "PRE-GAME" : SSticker.IsRoundInProgress() ? "IN PROGRESS" : "FINISHED"
	data["has_marked_datum"] = !!(holder.marked_datum && istype(holder.marked_datum, /atom))
	data["mode"] = SSticker.mode ? SSticker.mode.name : "Unknown"
	data["force_extended"] = GLOB.dynamic_forced_extended
	data["no_stacking"] = GLOB.dynamic_no_stacking
	data["forced_threat"] = GLOB.dynamic_forced_threat_level
	data["stacking_limit"] = GLOB.dynamic_stacking_limit

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		var/list/forced_rulesets = list()
		for(var/datum/dynamic_ruleset/roundstart/rule in GLOB.dynamic_forced_roundstart_ruleset)
			forced_rulesets += list(list("name" = rule.name, "ref" = REF(rule)))
		data["forced_rulesets"] = forced_rulesets
	else
		data["forced_rulesets"] = list()

	return data

/datum/admin_game_panel_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create_object")
			var/datum/admin_create_panel_ui/panel = new(holder, "object")
			panel.ui_interact(usr)
		if("quick_create_object")
			holder.quick_create_object(usr)
		if("create_turf")
			var/datum/admin_create_panel_ui/panel = new(holder, "turf")
			panel.ui_interact(usr)
		if("create_mob")
			var/datum/admin_create_panel_ui/panel = new(holder, "mob")
			panel.ui_interact(usr)
		if("dupe_marked")
			if(holder.marked_datum && istype(holder.marked_datum, /atom))
				DuplicateObject(holder.marked_datum, perfectcopy=1, newloc=get_turf(usr))
		if("force_ruleset")
			holder.Topic("", list("f_dynamic_roundstart" = "1", "admin_token" = holder.href_token))
		if("remove_ruleset")
			var/datum/dynamic_ruleset/roundstart/rule = locate(params["ref"]) in GLOB.dynamic_forced_roundstart_ruleset
			if(rule)
				GLOB.dynamic_forced_roundstart_ruleset -= rule
		if("clear_rulesets")
			GLOB.dynamic_forced_roundstart_ruleset.Cut()
		if("dynamic_options")
			holder.dynamic_mode_options(usr)
		if("gamemode_panel")
			if(SSticker.mode)
				SSticker.mode.ui_interact(usr)
		if("toggle_force_extended")
			holder.Topic("", list("f_dynamic_force_extended" = "1", "admin_token" = holder.href_token))
		if("toggle_no_stacking")
			holder.Topic("", list("f_dynamic_no_stacking" = "1", "admin_token" = holder.href_token))
		if("set_forced_threat")
			var/value = tgui_input_number(usr, "Set forced threat level (-1 to disable)", "Threat Level", GLOB.dynamic_forced_threat_level, 100, -1)
			if(!isnull(value))
				GLOB.dynamic_forced_threat_level = value
		if("set_stacking_limit")
			var/value = tgui_input_number(usr, "Set stacking limit threshold", "Stacking Limit", GLOB.dynamic_stacking_limit, 200, 0)
			if(!isnull(value))
				GLOB.dynamic_stacking_limit = value

	return TRUE


/datum/admin_create_panel_ui
	var/datum/admins/holder
	var/panel_type = "object"

/datum/admin_create_panel_ui/New(datum/admins/holder, panel_type)
	src.holder = holder
	src.panel_type = panel_type

/datum/admin_create_panel_ui/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_create_panel_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/title = panel_type == "object" ? "SCP FOUNDATION — OBJECT MANIFESTATION" : panel_type == "mob" ? "SCP FOUNDATION — ENTITY MANIFESTATION" : "SCP FOUNDATION — TERRAIN MODIFICATION"
		ui = new(user, src, "AdminCreatePanel", title, 700, 550)
		ui.open()

/datum/admin_create_panel_ui/ui_data(mob/user)
	var/list/data = list()
	data["panel_type"] = panel_type

	var/base_type
	switch(panel_type)
		if("object")
			base_type = /obj
		if("mob")
			base_type = /mob
		if("turf")
			base_type = /turf

	if(base_type)
		var/list/paths = list()
		for(var/path in typesof(base_type))
			var/list/parts = splittext("[path]", "/")
			var/depth = min(length(parts), 5)
			var/cat = jointext(parts, "/", 1, depth)

			if(!(cat in paths))
				paths[cat] = list()
			paths[cat] += list(list("path" = "[path]", "name" = "[path]"))

		var/list/categories = list()
		for(var/cat in paths)
			categories += list(list("name" = cat, "items" = paths[cat]))
		data["categories"] = categories

	data["amount"] = 1
	return data

/datum/admin_create_panel_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create")
			var/path = text2path(params["path"])
			if(!path)
				return
			var/amount = text2num(params["amount"]) || 1
			amount = clamp(amount, 1, ADMIN_SPAWN_CAP)
			var/turf/T = get_turf(usr)

			if(ispath(path, /turf))
				T.ChangeTurf(path)
			else
				for(var/i in 1 to amount)
					var/atom/A = new path(T)
					A.flags_1 |= ADMIN_SPAWNED_1

			log_admin("[key_name(usr)] spawned [amount] x [path] at [AREACOORD(usr)]")
		if("spawn_pod")
			var/path = text2path(params["path"])
			if(!path)
				return
			var/turf/T = get_turf(usr)
			if(ispath(path, /turf))
				T.ChangeTurf(path)
			else
				var/obj/structure/closet/supplypod/pod = podspawn(list(
					"target" = T,
					"path" = /obj/structure/closet/supplypod/centcompod,
				))
				var/atom/A = new path(pod)
				A.flags_1 |= ADMIN_SPAWNED_1
			log_admin("[key_name(usr)] pod-spawned [path] at [AREACOORD(usr)]")

	return TRUE


/datum/admin_view_variables_ui
	var/datum/target

/datum/admin_view_variables_ui/New(datum/target)
	src.target = target

/datum/admin_view_variables_ui/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_view_variables_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminViewVariables", "SCP FOUNDATION — ANOMALY INSPECTOR", 750, 650)
		ui.open()

/datum/admin_view_variables_ui/ui_data(mob/user)
	var/list/data = list()

	var/is_list = islist(target) || (!isdatum(target) && hascall(target, "Cut"))
	data["is_list"] = is_list
	data["is_datum"] = !is_list && isdatum(target)
	data["ref"] = REF(target)
	data["type"] = is_list ? "/list" : "[target.type]"
	data["name"] = is_list ? "List" : "[target]"
	data["is_atom"] = !is_list && isatom(target)
	data["is_image"] = !is_list && isimage(target)
	data["is_deleted"] = !is_list && target.gc_destroyed
	data["is_marked"] = user.client?.holder.marked_datum == target
	data["is_tagged"] = user.client?.holder.tagged_datums && (target in user.client.holder.tagged_datums)
	data["is_var_edited"] = !is_list && isdatum(target) && (target.datum_flags & DF_VAR_EDITED)

	if(!is_list && isdatum(target))
		data["tag_index"] = LAZYFIND(user.client?.holder.tagged_datums, target)

	var/list/vars_list = list()
	if(is_list)
		var/list/L = target
		for(var/i in 1 to length(L))
			var/key = L[i]
			var/value
			if(IS_NORMAL_LIST(L) && IS_VALID_ASSOC_KEY(key))
				value = L[key]
			vars_list += list(list(
				"name" = "[i]",
				"value" = "[value]",
				"is_editable" = FALSE,
			))
	else
		var/list/names = list()
		for(var/varname in target.vars)
			names += varname
		names = sort_list(names)
		for(var/varname in names)
			if(!target.can_vv_get(varname))
				continue
			vars_list += list(list(
				"name" = varname,
				"value" = "[target.vars[varname]]",
				"is_editable" = TRUE,
			))

	data["vars"] = vars_list
	return data

/datum/admin_view_variables_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("edit_var")
			if(!isdatum(target) || islist(target))
				return
			var/var_name = params["var_name"]
			if(!target.can_vv_get(var_name))
				return
			var/current_value = target.vars[var_name]
			var/default_class = usr.client.vv_get_class(var_name, current_value)
			if(default_class == VV_TEXT)
				default_class = VV_MESSAGE
			var/list/L = usr.client.vv_get_value(default_class = default_class, current_value = current_value, extra_classes = list(VV_LIST), var_name = var_name)
			if(!L["class"])
				return
			if(L["class"] == VV_LIST)
				if(islist(current_value))
					usr.client.mod_list(current_value, target, "[target]", var_name)
				else
					usr.client.mod_list(list(), target, "[target]", var_name)
				return
			target.vv_edit_var(var_name, L["value"])
		if("mark")
			usr.client.holder.marked_datum = target
		if("tag")
			if(target in usr.client.holder.tagged_datums)
				usr.client.holder.tagged_datums -= target
			else
				LAZYADD(usr.client.holder.tagged_datums, target)
		if("refresh")
			ui.send_full_update()
		if("list_add")
			if(islist(target))
				var/list/L = target
				var/value = tgui_input_text(usr, "Enter value to add", "Add Item")
				if(value)
					L += value
		if("list_set_length")
			if(islist(target))
				var/list/L = target
				var/new_len = tgui_input_number(usr, "New length", "Set Length", length(L), 1000, 0)
				if(!isnull(new_len))
					L.len = new_len
		if("list_erase_nulls")
			if(islist(target))
				var/list/L = target
				L -= null
		if("list_erase_dupes")
			if(islist(target))
				var/list/L = target
				L = unique_list(L)
		if("list_shuffle")
			if(islist(target))
				var/list/L = target
				shuffle_inplace(L)
		if("expose")
			var/mob/M = usr
			M.client.debug_variables(target)

	return TRUE
