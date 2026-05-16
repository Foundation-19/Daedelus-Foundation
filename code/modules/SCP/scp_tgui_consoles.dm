/obj/machinery/scp_monitoring_console
	name = "SCP Monitoring Console"
	desc = "A console that displays real-time status of all contained SCPs."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200

/obj/machinery/scp_monitoring_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPMonitoringConsole", "SCP Monitoring")
		ui.open()

/obj/machinery/scp_monitoring_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp_monitoring_console/ui_data(mob/user)
	var/list/data = list()
	var/list/scp_list = list()

	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
			if(!instance)
				continue
			scp_list += list(list(
				"id" = scp_id,
				"status" = instance.containment_status || "unknown",
				"health" = instance.containment_health,
				"last_breach" = instance.last_breach ? round((world.time - instance.last_breach) / 600) : -1,
				"breach_count" = length(instance.breach_history),
				"interaction_count" = length(instance.interaction_history),
			))

		data["global_stability"] = SSscp_persistence.manager.global_containment_stability
		data["active_breaches"] = SSscp_persistence.manager.active_breaches
	else
		data["global_stability"] = 100
		data["active_breaches"] = 0

	data["scps"] = scp_list
	data["time"] = world.time
	data["alert_level"] = SSdclass ? (SSdclass.manager ? SSdclass.manager.current_security_level : 1) : 1

	return data

/obj/machinery/scp_monitoring_console/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("view_scp")
			var/scp_id = params["scp_id"]
			if(scp_id && SSscp_persistence && SSscp_persistence.manager)
				var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances[scp_id]
				if(instance)
					var/msg = "<b>[scp_id]</b><br>"
					msg += "Status: [instance.containment_status]<br>"
					msg += "Health: [instance.containment_health]%<br>"
					msg += "Breach History: [length(instance.breach_history)] records<br>"
					msg += "Interaction History: [length(instance.interaction_history)] records<br>"
					to_chat(usr, "<span class='notice'>[msg]</span>")
		if("acknowledge_breach")
			if(SSscp_persistence && SSscp_persistence.manager)
				SSscp_persistence.manager.global_containment_stability = min(100, SSscp_persistence.manager.global_containment_stability + 5)
				to_chat(usr, "<span class='notice'>Breach acknowledged. Stability protocols engaged.</span>")

/obj/machinery/scp_monitoring_console/examine(mob/user)
	. = ..()
	if(SSscp_persistence && SSscp_persistence.manager)
		to_chat(user, "<span class='notice'>Global Containment Stability: [SSscp_persistence.manager.global_containment_stability]%</span>")
		to_chat(user, "<span class='notice'>Active Breaches: [SSscp_persistence.manager.active_breaches]</span>")

/obj/machinery/scp_research_terminal
	name = "SCP Research Terminal"
	desc = "A terminal for managing SCP research projects and experiments."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300

/obj/machinery/scp_research_terminal/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPResearchTerminal", "SCP Research")
		ui.open()

/obj/machinery/scp_research_terminal/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp_research_terminal/ui_data(mob/user)
	var/list/data = list()
	var/list/experiments = list()

	if(SSpersistent_progression)
		var/datum/persistent_player_data/pdata = SSpersistent_progression.get_player_data(user.ckey)
		if(pdata)
			data["research_points"] = pdata.total_research_completed * 10
			data["experiments_completed"] = pdata.total_research_completed

	if(SSscp_persistence && SSscp_persistence.manager)
		data["total_scps"] = length(SSscp_persistence.manager.scp_instances)
		for(var/scp_id in SSscp_persistence.manager.scp_instances)
			experiments += list(list(
				"id" = scp_id,
				"name" = scp_id,
				"type" = "general",
				"risk" = 1,
				"reward" = 50,
			))

	data["experiments"] = experiments
	return data

/obj/machinery/scp_research_terminal/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("start_experiment")
			var/exp_id = params["experiment_id"]
			if(!exp_id || !ishuman(usr))
				return
			var/mob/living/carbon/human/H = usr
			hook_scp_experiment(H, "Research Terminal", exp_id)
			to_chat(H, "<span class='notice'>Experiment [exp_id] initiated.</span>")
