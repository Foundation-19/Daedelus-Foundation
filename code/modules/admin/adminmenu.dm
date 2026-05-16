/datum/verbs/menu/Admin/Generate_list(client/C)
	if (C.holder)
		. = ..()

/datum/verbs/menu/Admin/verb/playerpanel()
	set name = "Player Panel"
	set desc = "Player Panel"
	set category = "Admin.Game"
	if(usr.client.holder)
		var/datum/admin_player_panel_ui/panel = new(usr.client.holder)
		panel.ui_interact(usr)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel New")
