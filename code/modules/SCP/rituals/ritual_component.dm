GLOBAL_LIST_EMPTY(ritual_components)

/datum/ritual_component
	var/name
	var/flags
	var/datum/ritual_component/linked_anchor
	var/list/linked_components = list()
	var/active = FALSE
	var/atom/owner
	var/range = 4

	New(atom/host, component_name, component_flags)
		src.owner = host
		src.name = component_name
		src.flags = component_flags
		GLOB.ritual_components |= src

	Destroy()
		if(linked_anchor)
			linked_anchor.linked_components -= src
			linked_anchor = null
		for(var/datum/ritual_component/linked as anything in linked_components)
			linked.linked_anchor = null
		linked_components.Cut()
		GLOB.ritual_components -= src
		return ..()

/datum/ritual_component/proc/try_activate(mob/invoker, spoken_text)
	if(active)
		return FALSE
	if(spoken_text != name)
		return FALSE
	if(flags & RITUAL_FLAG_ENERGY)
		var/datum/ritual_vars/rvars = new()
		rvars.invoker = invoker
		rvars.used = list()
		rvars.rvars = list()
		activate(rvars)
	else
		activate()
	return TRUE

/datum/ritual_component/proc/activate(datum/ritual_vars/rvars)
	active = TRUE
	for(var/datum/ritual_component/linked as anything in linked_components)
		if(!linked.active)
			linked.activate(rvars)

/datum/ritual_component/proc/deactivate()
	active = FALSE

/datum/ritual_component/proc/link_to_anchor(datum/ritual_component/anchor)
	linked_anchor = anchor
	anchor.linked_components |= src

/datum/ritual_component/proc/find_nearby_anchors()
	for(var/datum/ritual_component/comp as anything in GLOB.ritual_components)
		if(!(comp.flags & RITUAL_FLAG_CORE))
			continue
		if(!comp.owner || comp == src)
			continue
		if(get_dist(owner, comp.owner) <= range)
			link_to_anchor(comp)
			break
