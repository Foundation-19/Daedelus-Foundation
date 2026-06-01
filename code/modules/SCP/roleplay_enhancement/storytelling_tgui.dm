/datum/storytelling_ui
	var/mob/user

/datum/storytelling_ui/New(mob/user)
	src.user = user

/datum/storytelling_ui/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StorytellingSystem", "SCP Foundation - Round Narrative", 800, 600)
		ui.open()

/datum/storytelling_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/storytelling_ui/ui_data(mob/user)
	var/list/data = list()
	data["active_arcs"] = get_active_arcs()
	data["timeline"] = get_timeline()
	data["my_journal"] = get_my_journal(user.ckey)
	data["round_summary"] = get_round_summary()
	return data

/datum/storytelling_ui/proc/get_active_arcs()
	var/list/arcs = list()
	if(!SSstorytelling || !SSstorytelling.manager)
		return arcs
	for(var/arc_id in SSstorytelling.manager.active_arcs)
		var/datum/story_arc/arc = SSstorytelling.manager.active_arcs[arc_id]
		if(QDELETED(arc))
			continue
		arcs += list(list(
			"arc_id" = arc.arc_id,
			"arc_type" = arc.arc_type,
			"title" = arc.arc_title,
			"scp_id" = arc.scp_id,
			"stage" = arc.stage,
			"outcome" = arc.outcome,
			"participants" = length(arc.participants),
			"creation_time" = arc.creation_time,
			"duration" = world.time - arc.creation_time,
			"xp_reward" = arc.xp_reward,
			"stages" = arc.stages
		))
	for(var/arc_id in SSstorytelling.manager.completed_arcs)
		var/datum/story_arc/arc = SSstorytelling.manager.completed_arcs[arc_id]
		if(QDELETED(arc))
			continue
		arcs += list(list(
			"arc_id" = arc.arc_id,
			"arc_type" = arc.arc_type,
			"title" = arc.arc_title,
			"scp_id" = arc.scp_id,
			"stage" = arc.stage,
			"outcome" = arc.outcome,
			"participants" = length(arc.participants),
			"creation_time" = arc.creation_time,
			"duration" = arc.completion_time ? arc.completion_time - arc.creation_time : 0,
			"xp_reward" = arc.xp_reward,
			"stages" = arc.stages,
			"completed" = TRUE
		))
	return arcs

/datum/storytelling_ui/proc/get_timeline()
	var/list/entries = list()
	if(!SSstorytelling || !SSstorytelling.manager)
		return entries
	var/list/tl = SSstorytelling.manager.timeline
	var/start = max(1, length(tl) - 49)
	for(var/i in start to length(tl))
		var/list/entry = tl[i]
		entries += list(entry)
	return entries

/datum/storytelling_ui/proc/get_my_journal(ckey)
	var/list/entries = list()
	if(!SSstorytelling || !SSstorytelling.manager)
		return entries
	return SSstorytelling.manager.get_journal_for(ckey)

/datum/storytelling_ui/proc/get_round_summary()
	if(!SSstorytelling || !SSstorytelling.manager)
		return list()
	return SSstorytelling.manager.get_round_summary()

/datum/storytelling_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(!user || !user.ckey)
		return
	switch(action)
		if("write_journal")
			var/entry_text = params["text"]
			if(!entry_text)
				return
			if(!SSstorytelling || !SSstorytelling.manager)
				return
			if(!istype(user, /mob/living/carbon/human))
				return
			var/mob/living/carbon/human/H = user
			if(SSstorytelling.manager.write_journal(H, entry_text))
				to_chat(user, span_notice("Journal entry recorded."))
				. = TRUE
			else
				var/cooldown_remaining = 0
				var/last_time = SSstorytelling.manager.journal_cooldowns[user.ckey] || 0
				cooldown_remaining = max(0, JOURNAL_COOLDOWN - (world.time - last_time))
				if(cooldown_remaining > 0)
					to_chat(user, span_warning("You must wait [round(cooldown_remaining / 10)] seconds before writing another journal entry."))
				else
					to_chat(user, span_warning("Could not record journal entry. Text may be too long (max [JOURNAL_MAX_LENGTH] chars)."))

/mob/verb/open_storytelling_system()
	set name = "Open Storytelling System"
	set category = "Roleplay"
	set desc = "View the round narrative timeline and write journal entries"

	var/datum/storytelling_ui/ui = new /datum/storytelling_ui(src)
	ui.ui_interact(src)
