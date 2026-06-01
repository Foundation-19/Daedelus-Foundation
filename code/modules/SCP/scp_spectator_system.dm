/datum/action/ghost/scp_follow
	name = "Follow SCP Activity"
	desc = "Observe SCP-related activity across the facility."
	button_icon = 'icons/obj/objects.dmi'
	button_icon_state = "camera"

/datum/action/ghost/scp_follow/IsAvailable(feedback = FALSE)
	if(!istype(owner, /mob/dead/observer))
		return FALSE
	return TRUE

/datum/action/ghost/scp_follow/Trigger(trigger_flags)
	. = ..()
	if(!IsAvailable())
		return
	var/mob/dead/observer/O = owner
	var/list/categories = list("SCPs", "MTF", "D-Class", "Events")
	var/chosen_category = input(O, "Select a category to follow:", "SCP Activity") as null|anything in categories
	if(!chosen_category)
		return
	var/list/targets = list()
	switch(chosen_category)
		if("SCPs")
			targets = get_scp_targets()
		if("MTF")
			targets = get_mtf_targets()
		if("D-Class")
			targets = get_dclass_targets()
		if("Events")
			targets = get_event_targets()
	if(!length(targets))
		to_chat(O, span_warning("No targets available in this category."))
		return
	var/chosen = input(O, "Select a target to follow:", "Follow [chosen_category]") as null|anything in targets
	if(!chosen)
		return
	var/atom/movable/target = targets[chosen]
	if(!target || QDELETED(target))
		to_chat(O, span_warning("Target is no longer available."))
		return
	O.ManualFollow(target)
	if(istype(target, /mob/living))
		var/mob/living/L = target
		if(L.SCP)
			START_PROCESSING(SSprocessing, src)
			RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
			RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))

/datum/action/ghost/scp_follow/proc/get_scp_targets()
	var/list/targets = list()
	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(M.SCP)
			var/datum/scp/SCP = M.SCP
			var/label = "[M.name] ([SCP.designation])"
			targets[label] = M
	return targets

/datum/action/ghost/scp_follow/proc/get_mtf_targets()
	var/list/targets = list()
	if(GLOB.mtf_squads)
		for(var/datum/mtf_squad/squad as anything in GLOB.mtf_squads)
			for(var/mob/living/M in squad.squad_members)
				var/label = "[M.name] ([squad.squad_name])"
				targets[label] = M
	return targets

/datum/action/ghost/scp_follow/proc/get_dclass_targets()
	var/list/targets = list()
	if(SSdclass && SSdclass.manager)
		for(var/ckey in SSdclass?.manager?.dclass_players)
			var/mob/M = SSdclass?.manager?.dclass_players[ckey]
			if(M && !QDELETED(M))
				var/label = "[M.name] (D-Class)"
				targets[label] = M
	return targets

/datum/action/ghost/scp_follow/proc/get_event_targets()
	var/list/targets = list()
	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(M.SCP)
			var/datum/scp/SCP = M.SCP
			var/area/A = get_area(M)
			var/label = "[SCP.designation] Activity - [A ? A.name : "Unknown"]"
			targets[label] = M
	return targets

/datum/action/ghost/scp_follow/proc/on_target_deleted(datum/source)
	SIGNAL_HANDLER
	stop_following()

/datum/action/ghost/scp_follow/proc/on_target_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(!istype(owner, /mob/dead/observer))
		stop_following()
		return
	var/mob/dead/observer/O = owner
	to_chat(O, span_danger("Your follow target has died. Switching to next available SCP..."))
	var/list/targets = get_scp_targets()
	targets -= source
	if(length(targets))
		var/atom/movable/new_target = targets[pick(targets)]
		O.ManualFollow(new_target)
		if(istype(new_target, /mob/living))
			var/mob/living/L = new_target
			if(L.SCP)
				UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
				RegisterSignal(new_target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
				RegisterSignal(new_target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	else
		to_chat(O, span_warning("No other SCP targets available."))
		stop_following()

/datum/action/ghost/scp_follow/proc/stop_following()
	STOP_PROCESSING(SSprocessing, src)
	var/mob/dead/observer/O = owner
	if(istype(O) && O.following)
		UnregisterSignal(O.following, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))

/datum/action/ghost/scp_follow/process()
	if(!istype(owner, /mob/dead/observer))
		stop_following()
		return
	var/mob/dead/observer/O = owner
	var/atom/movable/target = O.following
	if(!target || !istype(target, /mob/living))
		stop_following()
		return
	var/mob/living/M = target
	if(!M.SCP)
		return
	var/datum/scp/SCP = M.SCP
	var/health_pct = round((M.health / M.maxHealth) * 100)
	var/status_text = span_notice("[SCP.designation] Status: Health [health_pct]%")
	if(health_pct <= 25)
		status_text = span_danger("[SCP.designation] Status: Health [health_pct]% | CRITICAL")
	else if(health_pct <= 50)
		status_text = span_warning("[SCP.designation] Status: Health [health_pct]% | DAMAGED")
	to_chat(O, status_text)

/mob/dead/observer/proc/grant_scp_follow_action()
	var/datum/action/ghost/scp_follow/A = new(src)
	A.Grant(src)
