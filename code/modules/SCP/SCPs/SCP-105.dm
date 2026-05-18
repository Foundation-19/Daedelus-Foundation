/mob/living/scp/scp105
	name = "SCP-105"
	desc = "A young woman with blonde hair. She possesses the ability to manipulate photographs of locations she can see through cameras."
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	real_name = "SCP-105"
	persistence_id = "SCP-105"

	var/portal_cooldown = 0
	var/portal_cooldown_duration = 300
	var/max_active_portals = 3
	var/list/active_portals = list()
	var/camera_range = 30
	var/portal_duration = 600

/mob/living/scp/scp105/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "SCP-105", SCP_SAFE, "105", SCP_SENTIENT)
	maxHealth = 100
	health = maxHealth

/mob/living/scp/scp105/Destroy()
	for(var/obj/effect/portal/scp105_portal/P in active_portals)
		qdel(P)
	active_portals.Cut()
	return ..()

/mob/living/scp/scp105/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	if(portal_cooldown > 0)
		portal_cooldown -= delta_time

	affect_nearby_sanity()

	var/stale = list()
	for(var/obj/effect/portal/scp105_portal/P in active_portals)
		if(QDELETED(P))
			stale += P
	for(var/S in stale)
		active_portals -= S

/mob/living/scp/scp105/verb/create_portal()
	set name = "Open Iris Portal"
	set category = "SCP-105"
	set desc = "Create a portal through a camera feed you can see."

	if(portal_cooldown > 0)
		to_chat(src, "<span class='warning'>Your portal ability is still recharging. Wait [ceil(portal_cooldown / 10)] seconds.</span>")
		return

	if(length(active_portals) >= max_active_portals)
		to_chat(src, "<span class='warning'>You have too many active portals. Close one first.</span>")
		return

	var/obj/machinery/camera/target_cam = select_camera()
	if(!target_cam)
		to_chat(src, "<span class='warning'>No suitable camera found.</span>")
		return

	var/turf/origin_turf = get_turf(src)
	var/turf/dest_turf = get_turf(target_cam)

	if(!origin_turf || !dest_turf)
		return

	var/obj/effect/portal/scp105_portal/portal = new /obj/effect/portal/scp105_portal(origin_turf, src, dest_turf, portal_duration)
	active_portals += portal

	portal_cooldown = portal_cooldown_duration

	visible_message("<span class='notice'>A shimmering portal opens near [src]!</span>")
	playsound(src, 'sound/effects/sparks1.ogg', 30, TRUE)

/mob/living/scp/scp105/proc/select_camera()
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if(!C.can_use())
			continue
		var/dist = get_dist(src, C)
		if(dist > camera_range)
			continue
		cameras += C

	if(!length(cameras))
		return null

	var/cam_name = input(src, "Select a camera to open a portal to:", "Iris Portal") as null|anything in cameras
	if(!cam_name)
		return null

	return cam_name

/mob/living/scp/scp105/verb/close_all_portals()
	set name = "Close All Portals"
	set category = "SCP-105"
	set desc = "Close all active Iris portals."

	for(var/obj/effect/portal/scp105_portal/P in active_portals)
		qdel(P)
	active_portals.Cut()
	to_chat(src, "<span class='notice'>All portals closed.</span>")

/mob/living/scp/scp105/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, "<span class='notice'>This is SCP-105, 'Iris'. She can create portals through camera feeds.</span>")

/mob/living/scp/scp105/get_status_tab_items()
	. = ..()
	. += "Active Portals: [length(active_portals)]/[max_active_portals]"
	. += "Portal Cooldown: [portal_cooldown > 0 ? "[ceil(portal_cooldown / 10)]s" : "Ready"]"

/obj/effect/portal/scp105_portal
	name = "Iris Portal"
	desc = "A shimmering portal created by SCP-105. It connects two points through a camera feed."
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed"
	density = FALSE
	var/mob/living/scp/scp105/owner
	var/duration_left
	var/turf/destination

/obj/effect/portal/scp105_portal/New(loc, mob/living/scp/scp105/creator, turf/dest, duration)
	. = ..()
	owner = creator
	destination = dest
	duration_left = duration
	START_PROCESSING(SSobj, src)

/obj/effect/portal/scp105_portal/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(owner)
		owner.active_portals -= src
	return ..()

/obj/effect/portal/scp105_portal/process()
	duration_left -= 20
	if(duration_left <= 0)
		visible_message("<span class='notice'>The Iris Portal fades away.</span>")
		qdel(src)
		return

/obj/effect/portal/scp105_portal/Crossed(atom/movable/AM)
	if(!destination)
		return

	if(ismob(AM))
		var/mob/M = AM
		if(M == owner)
			to_chat(M, "<span class='notice'>You step through your own portal.</span>")
		else
			to_chat(M, "<span class='notice'>You step through the shimmering portal.</span>")

	AM.forceMove(destination)
	playsound(destination, 'sound/effects/sparks1.ogg', 30, TRUE)

/obj/effect/portal/scp105_portal/attack_hand(mob/user)
	if(user == owner)
		qdel(src)
	else
		return ..()
