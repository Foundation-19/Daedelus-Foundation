/datum/foundation_politics_ui
	var/mob/user
	var/datum/department/selected_department
	var/datum/faction/selected_faction

/datum/foundation_politics_ui/New(mob/user)
	src.user = user

/datum/foundation_politics_ui/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "FoundationPolitics", "SCP Foundation - Politics & Hierarchy", 800, 600)
		ui.open()

/datum/foundation_politics_ui/ui_state(mob/user)
	if(check_rights(R_ADMIN, FALSE, user))
		return GLOB.admin_state
	return GLOB.default_state

/datum/foundation_politics_ui/ui_data(mob/user)
	var/list/data = list()
	data["departments"] = get_departments()
	data["factions"] = get_factions()
	data["political_events"] = get_political_events()
	data["alliances"] = get_alliances()
	data["conflicts"] = get_conflicts()
	data["metrics"] = get_politics_metrics()
	data["is_admin"] = check_rights(R_ADMIN, FALSE, user)
	data["user_ckey"] = user ? user.ckey : ""
	var/user_dept = SSfoundation_politics?.manager?.get_player_department(user?.ckey)
	var/user_faction = SSfoundation_politics?.manager?.get_player_faction(user?.ckey)
	data["user_department"] = user_dept || ""
	data["user_faction"] = user_faction || ""
	data["is_department_head"] = FALSE
	if(user_dept)
		var/datum/department/dept = SSfoundation_politics?.manager?.departments?[user_dept]
		if(dept && dept.department_head == user?.ckey)
			data["is_department_head"] = TRUE
	data["user_budget"] = 0
	if(user_dept)
		var/datum/department/dept = SSfoundation_politics?.manager?.departments?[user_dept]
		if(dept)
			data["user_budget"] = dept.department_budget
	data["available_policies"] = list()
	data["available_purchases"] = list()
	data["active_policies_data"] = list()
	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/policy_id in SSfoundation_politics.manager.policy_effects)
			var/list/pdata = SSfoundation_politics.manager.policy_effects[policy_id]
			data["available_policies"] += list(list(
				"id" = policy_id,
				"dept_type" = pdata["dept_type"],
				"effect_type" = pdata["effect_type"],
				"magnitude" = pdata["magnitude"],
				"duration" = pdata["duration"],
				"active" = !!(policy_id in SSfoundation_politics.manager.active_policies),
			))
		for(var/purchase_id in SSfoundation_politics.manager.budget_purchase_registry)
			var/list/pdata = SSfoundation_politics.manager.budget_purchase_registry[purchase_id]
			data["available_purchases"] += list(list(
				"id" = purchase_id,
				"cost" = pdata["cost"],
				"dept_types" = pdata["dept_type"],
				"effect" = pdata["effect"],
			))
		for(var/policy_id in SSfoundation_politics.manager.active_policies)
			var/list/policy = SSfoundation_politics.manager.active_policies[policy_id]
			data["active_policies_data"] += list(list(
				"id" = policy_id,
				"dept_id" = policy["dept_id"],
				"expiry" = policy["expiry"],
				"enacted_time" = policy["enacted_time"],
			))
	return data

/datum/foundation_politics_ui/proc/get_departments()
	var/list/departments = list()
	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/dept_id in SSfoundation_politics.manager.departments)
			var/datum/department/dept = SSfoundation_politics.manager.departments[dept_id]
			if(dept)
				var/list/member_list = list()
				for(var/ckey in dept.department_members)
					member_list += list(list("ckey" = ckey, "job" = dept.department_members[ckey]))
				departments[dept_id] = list(
					"department_id" = dept.department_id,
					"name" = dept.department_name,
					"type" = dept.department_type,
					"head" = dept.department_head,
					"head_online" = dept.is_head_online(),
					"budget" = dept.department_budget,
					"influence" = dept.department_influence,
					"status" = dept.department_status,
					"members" = member_list,
					"member_count" = length(dept.department_members),
					"policies" = dept.department_policies,
					"allies" = dept.department_allies,
					"rivals" = dept.department_rivals,
					"goals" = dept.department_goals,
					"achievements" = dept.department_achievements,
					"influence_metric" = dept.influence_metric_value,
					"creation_date" = dept.department_creation_date,
					"last_updated" = dept.department_last_updated
				)
	return departments

/datum/foundation_politics_ui/proc/get_factions()
	var/list/factions = list()
	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/faction_id in SSfoundation_politics.manager.factions)
			var/datum/faction/faction = SSfoundation_politics.manager.factions[faction_id]
			if(faction)
				var/list/member_list = list()
				for(var/ckey in faction.faction_members)
					member_list += list(list("ckey" = ckey, "department" = faction.faction_members[ckey]))
				factions[faction_id] = list(
					"faction_id" = faction.faction_id,
					"name" = faction.faction_name,
					"type" = faction.faction_type,
					"leader" = faction.faction_leader,
					"influence" = faction.faction_influence,
					"membership" = faction.faction_membership,
					"members" = member_list,
					"goals" = faction.faction_goals,
					"ideology" = faction.faction_ideology,
					"allies" = faction.faction_allies,
					"enemies" = faction.faction_enemies,
					"achievements" = faction.faction_achievements,
					"creation_date" = faction.faction_creation_date,
					"last_updated" = faction.faction_last_updated
				)
	return factions

/datum/foundation_politics_ui/proc/get_political_events()
	var/list/events = list()
	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/event_id in SSfoundation_politics.manager.political_events)
			var/datum/political_event/event = SSfoundation_politics.manager.political_events[event_id]
			if(event)
				events += list(list(
					"event_id" = event.event_id,
					"event_type" = event.event_type,
					"event_title" = event.event_title,
					"event_description" = event.event_description,
					"event_participants" = event.event_participants,
					"event_outcome" = event.event_outcome,
					"event_impact" = event.event_impact,
					"event_creation_date" = event.event_creation_date,
					"event_resolution_date" = event.event_resolution_date
				))
	return events

/datum/foundation_politics_ui/proc/get_alliances()
	var/list/alliances = list()
	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/alliance_id in SSfoundation_politics.manager.alliances)
			var/list/alliance = SSfoundation_politics.manager.alliances[alliance_id]
			if(alliance)
				alliances += list(list(
					"alliance_id" = alliance["id"] || alliance_id,
					"alliance_name" = alliance["name"],
					"alliance_type" = alliance["type"],
					"alliance_description" = alliance["description"],
					"alliance_strength" = alliance["strength"],
					"alliance_members" = alliance["members"]
				))
	return alliances

/datum/foundation_politics_ui/proc/get_conflicts()
	var/list/conflicts = list()
	if(SSfoundation_politics && SSfoundation_politics.manager)
		for(var/conflict_id in SSfoundation_politics.manager.conflicts)
			var/list/conflict = SSfoundation_politics.manager.conflicts[conflict_id]
			if(conflict)
				conflicts += list(list(
					"conflict_id" = conflict["id"] || conflict_id,
					"conflict_title" = conflict["title"],
					"conflict_type" = conflict["type"],
					"conflict_description" = conflict["description"],
					"conflict_severity" = conflict["severity"],
					"conflict_parties" = conflict["parties"]
				))
	return conflicts

/datum/foundation_politics_ui/proc/get_politics_metrics()
	var/list/metrics = list()
	if(SSfoundation_politics && SSfoundation_politics.manager)
		metrics["total_departments"] = SSfoundation_politics.manager.total_departments
		metrics["active_factions"] = SSfoundation_politics.manager.active_factions
		metrics["political_tensions"] = SSfoundation_politics.manager.political_tensions
		metrics["power_balance_score"] = SSfoundation_politics.manager.power_balance_score
		metrics["alliance_network_size"] = SSfoundation_politics.manager.alliance_network_size
		metrics["conflict_resolution_rate"] = SSfoundation_politics.manager.conflict_resolution_rate
	return metrics

/datum/foundation_politics_ui/proc/is_admin_user()
	return user && check_rights(R_ADMIN, FALSE, user)

/datum/foundation_politics_ui/proc/is_dept_head_for(dept_id)
	if(!user || !user.ckey || !dept_id)
		return FALSE
	if(!SSfoundation_politics || !SSfoundation_politics.manager)
		return FALSE
	var/datum/department/dept = SSfoundation_politics.manager.departments[dept_id]
	if(!dept)
		return FALSE
	return dept.department_head == user.ckey

/datum/foundation_politics_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(!user || !user.ckey)
		return
	var/is_admin = is_admin_user()
	switch(action)
		if("create_department")
			if(!is_admin)
				return
			var/name = params["name"]
			if(!name)
				return
			var/dept_type = params["dept_type"]
			if(!dept_type || !(dept_type in list("research", "security", "medical", "engineering", "administrative")))
				return
			var/head = params["head"]
			if(!head)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/datum/department/new_dept = SSfoundation_politics.manager.create_department(name, dept_type, head)
				if(new_dept)
					to_chat(user, span_notice("Department '[name]' created successfully!"))
					. = TRUE
		if("create_faction")
			if(!is_admin)
				return
			var/name = params["name"]
			if(!name)
				return
			var/faction_type = params["faction_type"]
			if(!faction_type || !(faction_type in list("conservative", "progressive", "militant", "scientific", "bureaucratic")))
				return
			var/leader = params["leader"]
			if(!leader)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/datum/faction/new_faction = SSfoundation_politics.manager.create_faction(name, faction_type, leader)
				if(new_faction)
					to_chat(user, span_notice("Faction '[name]' created successfully!"))
					. = TRUE
		if("spend_budget")
			var/dept_id = params["dept_id"]
			var/amount = text2num(params["amount"])
			if(!dept_id || !isnum(amount) || amount <= 0)
				return
			var/reason = params["reason"]
			if(!reason)
				return
			if(!is_admin && !is_dept_head_for(dept_id))
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				if(SSfoundation_politics.manager.spend_budget(dept_id, amount, reason))
					to_chat(user, span_notice("Spent [amount] from department budget on: [reason]"))
					. = TRUE
				else
					to_chat(user, span_warning("Insufficient budget or invalid request."))
		if("set_department_head")
			var/dept_id = params["dept_id"]
			if(!dept_id)
				return
			if(!is_admin && !is_dept_head_for(dept_id))
				return
			var/ckey = params["ckey"]
			if(!ckey)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				if(SSfoundation_politics.manager.admin_set_department_head(dept_id, ckey))
					to_chat(user, span_notice("Department head set to [ckey]."))
					. = TRUE
		if("adjust_budget")
			if(!is_admin)
				return
			var/dept_id = params["dept_id"]
			var/amount = text2num(params["amount"])
			if(!dept_id || !isnum(amount))
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				if(SSfoundation_politics.manager.admin_adjust_budget(dept_id, amount))
					to_chat(user, span_notice("Budget adjusted by [amount]."))
					. = TRUE
		if("add_goal")
			var/dept_id = params["dept_id"]
			if(!dept_id)
				return
			if(!is_admin && !is_dept_head_for(dept_id))
				return
			var/goal = params["goal"]
			if(!goal)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				if(SSfoundation_politics.manager.admin_add_goal(dept_id, goal))
					to_chat(user, span_notice("Goal '[goal]' added."))
					. = TRUE
		if("remove_goal")
			var/dept_id = params["dept_id"]
			var/goal = params["goal"]
			if(!dept_id || !goal)
				return
			if(!is_admin && !is_dept_head_for(dept_id))
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				if(SSfoundation_politics.manager.admin_remove_goal(dept_id, goal))
					to_chat(user, span_notice("Goal '[goal]' removed."))
					. = TRUE
		if("form_alliance")
			var/dept_id_a = params["dept_id_a"]
			var/dept_id_b = params["dept_id_b"]
			if(!dept_id_a || !dept_id_b)
				return
			if(!is_admin && !is_dept_head_for(dept_id_a) && !is_dept_head_for(dept_id_b))
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				var/result = SSfoundation_politics.manager.form_alliance(dept_id_a, dept_id_b)
				if(result)
					to_chat(user, span_notice("Alliance formed!"))
					. = TRUE
		if("break_alliance")
			var/alliance_id = params["alliance_id"]
			if(!alliance_id)
				return
			if(!is_admin)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				SSfoundation_politics.manager.break_alliance(alliance_id)
				to_chat(user, span_notice("Alliance dissolved."))
				. = TRUE
		if("create_rivalry")
			if(!is_admin)
				return
			var/dept_id_a = params["dept_id_a"]
			var/dept_id_b = params["dept_id_b"]
			if(!dept_id_a || !dept_id_b)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				SSfoundation_politics.manager.create_rivalry(dept_id_a, dept_id_b)
				to_chat(user, span_notice("Rivalry created."))
				. = TRUE
		if("create_political_event")
			if(!is_admin)
				return
			var/event_type = params["event_type"]
			if(!event_type || !(event_type in list("election", "scandal", "alliance", "conflict", "policy_change")))
				return
			var/title = params["title"]
			if(!title)
				return
			var/description = params["description"]
			if(!description)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				SSfoundation_politics.manager.create_political_event(event_type, title, description, list(), 0)
				to_chat(user, span_notice("Political event '[title]' created successfully!"))
				. = TRUE
		if("resolve_conflict")
			var/conflict_id = params["conflict_id"]
			if(!conflict_id)
				return
			if(!is_admin)
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				SSfoundation_politics.manager.admin_resolve_conflict(conflict_id)
				to_chat(user, span_notice("Conflict resolved successfully!"))
				. = TRUE
		if("enact_policy")
			var/dept_id = params["dept_id"]
			var/policy_type = params["policy_type"]
			if(!dept_id || !policy_type)
				return
			if(!is_admin && !is_dept_head_for(dept_id))
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				if(SSfoundation_politics.manager.enact_policy(dept_id, policy_type))
					to_chat(user, span_notice("Policy [policy_type] enacted for [dept_id]!"))
					. = TRUE
				else
					to_chat(user, span_warning("Failed to enact policy. Check budget, prerequisites, and department head status."))
		if("execute_budget_purchase")
			var/dept_id = params["dept_id"]
			var/purchase_type = params["purchase_type"]
			if(!dept_id || !purchase_type)
				return
			if(!is_admin && !is_dept_head_for(dept_id))
				return
			if(SSfoundation_politics && SSfoundation_politics.manager)
				if(SSfoundation_politics.manager.execute_budget_purchase(dept_id, purchase_type))
					to_chat(user, span_notice("Budget purchase [purchase_type] executed for [dept_id]!"))
					. = TRUE
				else
					to_chat(user, span_warning("Failed to execute budget purchase. Check budget and department eligibility."))

/mob/verb/open_foundation_politics()
	set name = "Open Foundation Politics"
	set category = "Roleplay"
	set desc = "Open the Foundation politics and hierarchy system"
	var/datum/foundation_politics_ui/ui = new /datum/foundation_politics_ui(src)
	ui.ui_interact(src)

/mob/proc/manage_foundation_politics()
	set name = "Manage Foundation Politics"
	set category = "Admin"
	set desc = "Manage the Foundation politics system"
	if(!check_rights(R_ADMIN))
		return
	var/datum/foundation_politics_ui/ui = new /datum/foundation_politics_ui(src)
	ui.ui_interact(src)
