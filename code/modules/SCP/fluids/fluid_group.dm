/datum/fluid_group
	var/list/members = list()
	var/contained_amt = 0
	var/required_to_spread = FLUID_SPREAD_THRESHOLD
	var/fluid_type = FLUID_TYPE_WATER
	var/color = "#4488cc"
	var/viscosity = 1
	var/datum/reagents/fluid_reagents
	var/processing = FALSE

	New(fluid_type, color, viscosity)
		src.fluid_type = fluid_type || FLUID_TYPE_WATER
		if(color)
			src.color = color
		src.viscosity = viscosity || 1
		fluid_reagents = new(1000)

	Destroy()
		stop_processing()
		for(var/obj/fluid/F as anything in members)
			F.group = null
			qdel(F)
		members.Cut()
		QDEL_NULL(fluid_reagents)
		return ..()

/datum/fluid_group/proc/add_member(obj/fluid/new_member)
	members |= new_member
	new_member.group = src
	new_member.color = color
	if(!fluid_reagents.my_atom)
		fluid_reagents.my_atom = new_member
	update_fluids()

/datum/fluid_group/proc/remove_member(obj/fluid/member)
	members -= member
	member.group = null
	if(!length(members))
		qdel(src)
		return
	update_fluids()

/datum/fluid_group/proc/update_fluids()
	if(!length(members))
		qdel(src)
		return
	contained_amt = fluid_reagents.total_volume
	if(contained_amt <= 0)
		qdel(src)
		return
	var/amt_per_tile = contained_amt / length(members)
	var/depth_level = 1
	for(var/threshold in FLUID_DEPTH_THRESHOLDS)
		if(amt_per_tile >= threshold)
			depth_level++
		else
			break
	depth_level = min(depth_level, FLUID_DEPTH_DROWN)
	for(var/obj/fluid/F as anything in members)
		F.amt = amt_per_tile
		F.depth_level = depth_level
		F.update_icon_state()
	if(contained_amt >= required_to_spread)
		start_processing()
	else
		stop_processing()

/datum/fluid_group/proc/try_spread()
	var/list/edge_members = list()
	for(var/obj/fluid/F as anything in members)
		if(get_blocked_dirs(F) != (NORTH|SOUTH|EAST|WEST))
			edge_members |= F
	if(!length(edge_members))
		return
	var/obj/fluid/edge = pick(edge_members)
	var/blocked = get_blocked_dirs(edge)
	var/list/valid_dirs = list()
	for(var/dir in list(NORTH, SOUTH, EAST, WEST))
		if(!(blocked & dir))
			valid_dirs |= dir
	if(!length(valid_dirs))
		return
	var/spread_dir = pick(valid_dirs)
	var/turf/T = get_step(edge, spread_dir)
	if(!T || T.density)
		return
	var/obj/fluid/existing = locate(/obj/fluid) in T
	if(existing)
		return
	var/obj/fluid/new_fluid = new /obj/fluid(T, fluid_type, color, viscosity)
	if(new_fluid && !new_fluid.group)
		add_member(new_fluid)

/datum/fluid_group/proc/get_blocked_dirs(obj/fluid/F)
	var/blocked = NONE
	var/turf/T = get_turf(F)
	if(!T)
		return NORTH|SOUTH|EAST|WEST
	for(var/dir in list(NORTH, SOUTH, EAST, WEST))
		var/turf/neighbor = get_step(T, dir)
		if(!neighbor || neighbor.density)
			blocked |= dir
			continue
		var/obj/fluid/other = locate(/obj/fluid) in neighbor
		if(other)
			blocked |= dir
	return blocked

/datum/fluid_group/proc/drain(amount)
	if(amount <= 0)
		return 0
	contained_amt = fluid_reagents.total_volume
	var/drained = min(amount, contained_amt)
	fluid_reagents.remove_all(drained)
	update_fluids()
	return drained

/datum/fluid_group/proc/start_processing()
	if(processing)
		return
	processing = TRUE
	START_PROCESSING(SSobj, src)

/datum/fluid_group/proc/stop_processing()
	if(!processing)
		return
	processing = FALSE
	STOP_PROCESSING(SSobj, src)

/datum/fluid_group/process(delta_time)
	try_spread()
	contained_amt = fluid_reagents.total_volume
	if(contained_amt <= 0)
		qdel(src)
		return
	update_fluids()
