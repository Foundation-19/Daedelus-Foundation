/mob/living/scp/scp106/proc/leave_corrosion_trail()
	if(stat == DEAD || containment_status != "breached")
		return
	var/turf/T = get_turf(src)
	if(!T)
		return
	if(!istype(T, /turf/open/floor) && !istype(T, /turf/closed/wall))
		return
	var/obj/effect/decal/cleanable/scp106_corrosion/trail = locate() in T
	if(!trail)
		new /obj/effect/decal/cleanable/scp106_corrosion(T)

/obj/effect/decal/cleanable/scp106_corrosion
	name = "strange corrosion"
	desc = "A dark, viscous substance eating into the surface. It smells of decay."
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	color = "#1a1a2e"
	var/damage_amount = 3
	var/lifetime = 120 SECONDS

/obj/effect/decal/cleanable/scp106_corrosion/Initialize()
	. = ..()
	QDEL_IN(src, lifetime)
	RegisterSignal(src, COMSIG_ATOM_ENTERED, .proc/handle_corrosion_crossing)

/obj/effect/decal/cleanable/scp106_corrosion/proc/handle_corrosion_crossing(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		H.adjustBruteLoss(damage_amount)
		if(prob(20))
			to_chat(H, span_warning("The dark substance burns your feet!"))

/mob/living/scp/scp939/proc/share_target_with_pack(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return
	for(var/mob/living/scp/scp939/pack_member in view(15, src))
		if(pack_member == src || pack_member.stat == DEAD)
			continue
		if(!pack_member.ai_target)
			continue
		var/mob/living/L = pack_member.ai_target
		if(istype(L) && L.stat == DEAD)
			pack_member.ai_target = target
			pack_member.ai_state = "pursuing"

/mob/living/scp/scp049/proc/scale_zombie_intelligence(mob/living/simple_animal/hostile/zombie/scp049_1/zombie)
	if(!zombie)
		return
	var/age = world.time - zombie.timeofdeath
	if(age < 0)
		age = 0
	switch(age)
		if(0 to 120 SECONDS)
			zombie.move_to_delay = 10
			zombie.melee_damage_lower = 10
			zombie.melee_damage_upper = 15
		if(120 SECONDS to 300 SECONDS)
			zombie.move_to_delay = 7
			zombie.melee_damage_lower = 15
			zombie.melee_damage_upper = 20
		if(300 SECONDS to 600 SECONDS)
			zombie.move_to_delay = 5
			zombie.melee_damage_lower = 20
			zombie.melee_damage_upper = 25
			zombie.environment_smash = ENVIRONMENT_SMASH_WALLS
		if(600 SECONDS to INFINITY)
			zombie.move_to_delay = 4
			zombie.melee_damage_lower = 25
			zombie.melee_damage_upper = 30
			zombie.environment_smash = ENVIRONMENT_SMASH_WALLS
			if(prob(5))
				zombie.say("The Pestilence... must be... cured...", forced = "scp049_zombie")

/mob/living/scp/scp999/proc/apply_mood_aura()
	if(stat == DEAD || containment_status != "breached")
		return
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H.stat == DEAD)
			continue
		if(!H.sanity)
			continue
		to_chat(H, span_notice("You feel warmth and comfort emanating from SCP-999!"))

/mob/living/scp/scp173/proc/attempt_pry_door()
	if(stat == DEAD || containment_status != "breached")
		return
	if(prob(15))
		for(var/obj/machinery/door/airlock/D in range(1, src))
			if(D.density && !D.welded && !D.locked)
				if(is_being_observed)
					continue
				D.open()
				visible_message(span_danger("[src] pries open [D]!"))
				break

/proc/trigger_goi_midround_spawn(goi_type)
	var/list/spawn_areas = list()
	for(var/area/A in GLOB.areas)
		if(!istype(A, /area/site53/surface) && !istype(A, /area/scp/surface))
			continue
		spawn_areas += A
	if(!length(spawn_areas))
		return
	var/area/spawn_area = pick(spawn_areas)
	var/list/spawn_turfs = list()
	for(var/turf/T in spawn_area)
		if(!T.is_blocked_turf(TRUE))
			spawn_turfs += T
	if(!length(spawn_turfs))
		return
	var/announce_text
	switch(goi_type)
		if("ci")
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.stat != DEAD || !H.client)
					continue
				if(H.job && findtext(H.job, "Chaos"))
					var/turf/T = pick(spawn_turfs)
					H.forceMove(T)
			announce_text = "Unidentified aircraft detected on facility radar. Potential Chaos Insurgency incursion. All security personnel respond."
		if("sarkic")
			announce_text = "Anomalous biological signature detected on facility perimeter. Potential Sarkic cultist activity. Exercise extreme caution."
		if("serpents")
			announce_text = "Spatial anomaly detected near facility. Potential Serpent's Hand incursion. Monitor all anomalous signatures."
	if(announce_text)
		priority_announce(announce_text, "THREAT ALERT", null, ANNOUNCER_ALERT)
		log_round_event("goi_spawn", "[goi_type] mid-round spawn triggered", goi_type)

/mob/living/scp/scp999/proc/calm_enraged_096()
	if(stat == DEAD || containment_status != "breached")
		return
	for(var/mob/living/scp/scp096/S in view(7, src))
		if(S.stat == DEAD || S.containment_status != "breached")
			continue
		if(length(S.target_queue) == 0)
			continue
		if(prob(15))
			S.target_queue.Cut()
			S.state = "docile"
			S.docile_grace_until = world.time + 60 SECONDS
			visible_message(span_notice("SCP-999 approaches SCP-096, which seems to calm down slightly..."))
			if(S.key)
				to_chat(S, span_notice("SCP-999's presence soothes your rage. You feel... calm."))
			return
