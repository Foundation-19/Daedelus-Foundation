// Smooth HUD updates, but low priority
PROCESSING_SUBSYSTEM_DEF(incone)
	name = "incone"
	wait = 1
	priority = FIRE_PRIORITY_INCONE

/datum/controller/subsystem/processing/incone/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while (current_run.len)
		var/client/thing = current_run[current_run.len]
		current_run.len--
		if (!thing || QDELETED(thing))
			processing -= thing
			if (MC_TICK_CHECK)
				return
			continue
		thing.update_cone()
		STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
