// SCP Containment Wall System
// Breachable walls with integrity tracking, SCP damage, and welding repair

#define CONTAINMENT_WALL_INTEGRITY 300
#define CONTAINMENT_WALL_REINFORCED_INTEGRITY 600
#define CONTAINMENT_WALL_WELD_REPAIR 50
#define CONTAINMENT_WALL_WELD_TIME 30
#define CONTAINMENT_WALL_DECAY_INTERVAL 600
#define CONTAINMENT_WALL_DECAY_AMOUNT 1
#define CONTAINMENT_WALL_DECAY_POWERLESS 5

/turf/closed/wall/scp_containment
	name = "containment wall"
	desc = "A heavy reinforced wall designed to contain anomalous entities. Shows signs of reinforced plating."
	icon = 'icons/turf/walls/solid_wall_reinforced.dmi'
	hardness = 5
	explosion_block = 8
	reinf_material = /datum/material/iron
	plating_material = /datum/material/alloy/plasteel
	rad_insulation = RAD_HEAVY_INSULATION

	var/containment_integrity = CONTAINMENT_WALL_INTEGRITY
	var/max_containment_integrity = CONTAINMENT_WALL_INTEGRITY
	var/last_damage_time = 0
	var/damage_overlay = 0
	var/containment_zone = "unknown"
	var/last_decay_tick = 0

/turf/closed/wall/scp_containment/lcz
	containment_zone = "lcz"

/turf/closed/wall/scp_containment/hcz
	name = "heavy containment wall"
	containment_integrity = CONTAINMENT_WALL_REINFORCED_INTEGRITY
	max_containment_integrity = CONTAINMENT_WALL_REINFORCED_INTEGRITY
	containment_zone = "hcz"
	explosion_block = 12

/turf/closed/wall/scp_containment/Initialize()
	. = ..()
	SET_TRACKING(__TYPE__)
	update_damage_overlay()
	last_decay_tick = world.time
	START_PROCESSING(SSobj, src)

/turf/closed/wall/scp_containment/Destroy()
	STOP_PROCESSING(SSobj, src)
	UNSET_TRACKING(__TYPE__)
	return ..()

/turf/closed/wall/scp_containment/process()
	if(world.time < last_decay_tick + CONTAINMENT_WALL_DECAY_INTERVAL)
		return
	last_decay_tick = world.time
	if(containment_integrity <= 0)
		return
	var/area/A = get_area(src)
	var/decay = CONTAINMENT_WALL_DECAY_AMOUNT
	if(A && !A.powered(AREA_USAGE_ENVIRON))
		decay = CONTAINMENT_WALL_DECAY_POWERLESS
	if(decay > 0 && containment_integrity > 0)
		damage_containment(decay, "structural decay")

/turf/closed/wall/scp_containment/examine(mob/user)
	. = ..()
	var/integrity_pct = round((containment_integrity / max_containment_integrity) * 100)
	switch(integrity_pct)
		if(80 to 100)
			. += span_notice("The containment wall appears intact. Integrity: [integrity_pct]%")
		if(50 to 79)
			. += span_warning("The containment wall shows signs of stress. Integrity: [integrity_pct]%")
		if(25 to 49)
			. += span_danger("The containment wall is heavily damaged! Integrity: [integrity_pct]%")
		if(1 to 24)
			. += span_userdanger("The containment wall is on the verge of breaching! Integrity: [integrity_pct]%")

/turf/closed/wall/scp_containment/proc/damage_containment(amount, source)
	if(containment_integrity <= 0)
		return FALSE
	containment_integrity = max(0, containment_integrity - amount)
	last_damage_time = world.time
	update_damage_overlay()

	if(containment_integrity <= 0)
		breach_containment(source)
		return TRUE
	return FALSE

/turf/closed/wall/scp_containment/proc/update_damage_overlay()
	var/integrity_pct = (containment_integrity / max_containment_integrity) * 100
	var/new_overlay = 0
	if(integrity_pct < 25)
		new_overlay = 3
	else if(integrity_pct < 50)
		new_overlay = 2
	else if(integrity_pct < 75)
		new_overlay = 1

	if(new_overlay != damage_overlay)
		damage_overlay = new_overlay
		update_appearance()

/turf/closed/wall/scp_containment/update_overlays()
	. = ..()
	switch(damage_overlay)
		if(1)
			. += mutable_appearance('icons/effects/rust_overlay.dmi', "rust1", layer = EDGED_TURF_LAYER)
		if(2)
			. += mutable_appearance('icons/effects/rust_overlay.dmi', "rust2", layer = EDGED_TURF_LAYER)
		if(3)
			. += mutable_appearance('icons/effects/rust_overlay.dmi', "rust3", layer = EDGED_TURF_LAYER)

/turf/closed/wall/scp_containment/proc/breach_containment(source)
	visible_message(span_userdanger("The containment wall COLLAPSES! Debris flies everywhere!"))
	playsound(src, 'sound/effects/explosion1.ogg', 80, TRUE)

	var/zone_name = containment_zone
	if(zone_name == "unknown")
		var/area/A = get_area(src)
		zone_name = get_containment_zone(A) || "unknown"

	log_game("Containment Breach: Wall at [get_area_name(src)] breached by [source || "unknown"]")

	if(SSfacility_announcements)
		SSfacility_announcements.announce_breach("STRUCTURAL BREACH", zone_name)

	dismantle_wall(TRUE, TRUE)

	new /obj/effect/particle_effect/sparks(get_turf(src))

/turf/closed/wall/scp_containment/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = W
		if(!welder.isOn())
			return ..()
		if(containment_integrity >= max_containment_integrity)
			to_chat(user, span_notice("This containment wall is already at full integrity."))
			return
		if(!welder.use(1))
			to_chat(user, span_warning("Not enough fuel!"))
			return
		to_chat(user, span_notice("You begin repairing the containment wall..."))
		playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		if(do_after(user, src, CONTAINMENT_WALL_WELD_TIME))
			var/repair = min(CONTAINMENT_WALL_WELD_REPAIR, max_containment_integrity - containment_integrity)
			containment_integrity += repair
			to_chat(user, span_notice("You repair the containment wall. Integrity: [round((containment_integrity / max_containment_integrity) * 100)]%"))
			if(SSround_objectives)
				SSround_objectives.report_objective_progress("engineer_repair", 1)
			update_damage_overlay()
			welder.use(2)
		return
	return ..()

/turf/closed/wall/scp_containment/ex_act(severity, target)
	if(target == src)
		damage_containment(150, "explosion")
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			damage_containment(200, "explosion")
		if(EXPLODE_HEAVY)
			damage_containment(80, "explosion")
		if(EXPLODE_LIGHT)
			damage_containment(30, "explosion")

/turf/closed/wall/scp_containment/dismantle_wall(devastated, explode)
	..()

/turf/closed/wall/scp_containment/break_wall(drop_mats)
	if(drop_mats)
		drop_materials_used()
	return new /obj/structure/girder/scp_containment(src, reinf_material, wall_paint, stripe_paint, containment_zone)

// Containment girder — can be rebuilt into containment walls
/obj/structure/girder/scp_containment
	name = "containment girder"
	desc = "A structural girder from a breached containment wall. It can be rebuilt with reinforced materials."
	var/containment_zone = "unknown"

/obj/structure/girder/scp_containment/New(turf/loc, reinf_mat, w_paint, s_paint, zone)
	. = ..(loc, reinf_mat, w_paint, s_paint)
	containment_zone = zone || "unknown"

/obj/structure/girder/scp_containment/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = W
		if(S.get_amount() < 2)
			to_chat(user, span_warning("You need two sheets of [S]!"))
			return
		if(!anchored)
			return ..()
		if(iswallturf(loc))
			to_chat(user, span_warning("There is already a wall present!"))
			return
		to_chat(user, span_notice("You begin reconstructing the containment wall..."))
		if(do_after(user, src, 60, DO_PUBLIC, display = W))
			if(S.get_amount() < 2)
				return
			S.use(2)
			var/turf/T = get_turf(src)
			T.PlaceOnTop(/turf/closed/wall/scp_containment)
			var/turf/closed/wall/scp_containment/placed_wall = T
			placed_wall.set_wall_information(S.material_type, reinforced_material, wall_paint, stripe_paint)
			placed_wall.containment_zone = containment_zone
			transfer_fingerprints_to(placed_wall)
			visible_message(span_notice("[user] reconstructs the containment wall."))
			qdel(src)
			return
	return ..()

// ============================================================================
// SCP Wall Damage Procs — called by SCP mob abilities
// ============================================================================

/proc/try_scp_breach_wall(mob/living/scp_mob, turf/closed/wall/scp_containment/target, damage, source)
	if(!istype(target))
		return FALSE
	if(!scp_mob || scp_mob.stat == DEAD)
		return FALSE
	var/breached = target.damage_containment(damage, source)
	if(breached)
		scp_mob.visible_message(span_userdanger("[scp_mob] SMASHES through the containment wall!"), span_notice("You break through the containment wall!"))
	return breached

/proc/try_scp_corrode_wall(mob/living/scp/scp106/scp_mob, turf/closed/wall/scp_containment/target, damage)
	if(!istype(target))
		return FALSE
	if(!istype(scp_mob) || scp_mob.stat == DEAD)
		return FALSE
	scp_mob.visible_message(span_danger("[target] begins to corrode where [scp_mob] touches it!"), span_notice("You corrode the containment wall..."))
	var/breached = target.damage_containment(damage, "SCP-106 corrosion")
	if(breached)
		scp_mob.visible_message(span_userdanger("[target] collapses into rust and decay!"), span_notice("The containment wall dissolves before you."))
	return breached
