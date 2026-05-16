/client/proc/debug_variables(datum/thing in world)
	set category = "Debug"
	set name = "View Variables"

	if(!usr.client || !usr.client.holder)
		to_chat(usr, span_danger("You need to be an administrator to access this."), confidential = TRUE)
		return

	if(!thing)
		return

	var/islist = islist(thing) || (!isdatum(thing) && hascall(thing, "Cut"))
	if(!islist && !isdatum(thing))
		return

	var/datum/admin_view_variables_ui/vv_ui = new(thing)
	vv_ui.ui_interact(usr)

/client/proc/vv_update_display(datum/thing, span, content)
	src << output("[span]:[content]", "variables[REF(thing)].browser:replace_span")
