/mob/living/scp/scp105
	ai_enabled = TRUE
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

	add_verb(src, list(
		/mob/living/scp/scp105/proc/create_portal,
		/mob/living/scp/scp105/proc/close_all_portals,
	))

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

/mob/living/scp/scp105/proc/create_portal()
	set name = "Open Iris Portal"
	set category = "SCP-105"
	set desc = "Create a portal through a camera feed you can see."

	if(portal_cooldown > 0)
		to_chat(src, span_warning("Your portal ability is still recharging. Wait [ceil(portal_cooldown / 10)] seconds."))
		return

	if(length(active_portals) >= max_active_portals)
		to_chat(src, span_warning("You have too many active portals. Close one first."))
		return

	var/obj/machinery/camera/target_cam = select_camera()
	if(!target_cam)
		to_chat(src, span_warning("No suitable camera found."))
		return

	var/turf/origin_turf = get_turf(src)
	var/turf/dest_turf = get_turf(target_cam)

	if(!origin_turf || !dest_turf)
		return

	var/obj/effect/portal/scp105_portal/portal = new /obj/effect/portal/scp105_portal(origin_turf, src, dest_turf, portal_duration)
	active_portals += portal

	portal_cooldown = portal_cooldown_duration

	visible_message(span_notice("A shimmering portal opens near [src]!"))
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

/mob/living/scp/scp105/proc/close_all_portals()
	set name = "Close All Portals"
	set category = "SCP-105"
	set desc = "Close all active Iris portals."

	for(var/obj/effect/portal/scp105_portal/P in active_portals)
		qdel(P)
	active_portals.Cut()
	to_chat(src, span_notice("All portals closed."))

/mob/living/scp/scp105/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, span_notice("This is SCP-105, 'Iris'. She can create portals through camera feeds."))

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
	RegisterSignal(src, COMSIG_ATOM_ENTERED, .proc/on_entered)

/obj/effect/portal/scp105_portal/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!destination)
		return

	if(ismob(AM))
		var/mob/M = AM
		if(M == owner)
			to_chat(M, span_notice("You step through your own portal."))
		else
			to_chat(M, span_notice("You step through the shimmering portal."))

	AM.forceMove(destination)
	playsound(destination, 'sound/effects/sparks1.ogg', 30, TRUE)

/obj/effect/portal/scp105_portal/attack_hand(mob/user)
	if(user == owner)
		qdel(src)
	else
		return ..()

/mob/living/scp/scp105/process_ai()
	if(stat == DEAD)
		return

	if(prob(8))
		var/mob/living/carbon/human/H = locate() in view(4, src)
		if(H && H.stat != DEAD)
			var/phrases = list("Hello.", "How are you?", "I can help, if you need it.", "Nice day, isn't it?")
			say(pick(phrases))

	if(prob(10))
		step_rand(src)
