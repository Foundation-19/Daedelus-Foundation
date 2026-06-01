/datum/ritual_execution
	var/list/components = list()
	var/list/active_components = list()
	var/mob/invoker
	var/list/ritual_rvars = list()

	New(list/component_paths, mob/invoker)
		src.invoker = invoker
		for(var/path in component_paths)
			var/datum/ritual_component/comp = new path()
			components |= comp

/datum/ritual_execution/proc/execute()
	for(var/datum/ritual_component/comp as anything in components)
		comp.try_activate(invoker, comp.name)
		if(comp.active)
			active_components |= comp

/datum/ritual_execution/proc/complete()
	for(var/datum/ritual_component/comp as anything in active_components)
		comp.deactivate()
	active_components.Cut()

/datum/ritual_execution/proc/fail()
	for(var/datum/ritual_component/comp as anything in active_components)
		comp.deactivate()
	active_components.Cut()
	to_chat(invoker, span_warning("The ritual fails!"))
