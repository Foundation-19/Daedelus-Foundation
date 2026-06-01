#define SCP076_STATE_DORMANT "dormant"
#define SCP076_STATE_AWAKENING "awakening"
#define SCP076_STATE_ACTIVE "active"
#define SCP076_STATE_DECEASED "deceased"

/mob/living/scp/scp076
	ai_enabled = TRUE
	name = "SCP-076"
	desc = "A muscular humanoid figure emerging from a stone sarcophagus. He carries an insatiable desire for combat."
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	real_name = "SCP-076-2"
	persistence_id = "SCP-076"

	var/current_state = SCP076_STATE_DORMANT
	var/awakening_timer = 0
	var/awakening_duration = 600
	var/dormant_duration = 3000
	var/dormant_timer = 0
	var/respawn_count = 0
	var/max_respawns = 5
	var/weapon_cooldown = 0
	var/blade_summoned = FALSE
	var/obj/item/melee/scp076_blade/summoned_blade
	var/rage_meter = 0
	var/max_rage = 100
	var/kill_count = 0
	var/speed_boost_active = FALSE

/mob/living/scp/scp076/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "SCP-076", SCP_KETER, "076", SCP_SENTIENT)
	maxHealth = 400
	health = maxHealth
	fovangle = FOV_DEFAULT
	update_fov_angles()
	update_cone_show()
	enter_dormant()

/mob/living/scp/scp076/Destroy()
	QDEL_NULL(summoned_blade)
	return ..()

/mob/living/scp/scp076/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	switch(current_state)
		if(SCP076_STATE_DORMANT)
			process_dormant()
		if(SCP076_STATE_AWAKENING)
			process_awakening()
		if(SCP076_STATE_ACTIVE)
			process_active()
		if(SCP076_STATE_DECEASED)
			process_deceased()

/mob/living/scp/scp076/proc/enter_dormant()
	current_state = SCP076_STATE_DORMANT
	dormant_timer = world.time + dormant_duration
	stat = UNCONSCIOUS
	visible_message(span_notice("[src] collapses back into the sarcophagus, becoming dormant."))
	containment_status = "contained"
	if(summoned_blade)
		QDEL_NULL(summoned_blade)
		blade_summoned = FALSE

/mob/living/scp/scp076/proc/process_dormant()
	if(world.time >= dormant_timer)
		begin_awakening()

/mob/living/scp/scp076/proc/begin_awakening()
	current_state = SCP076_STATE_AWAKENING
	awakening_timer = world.time + awakening_duration
	stat = CONSCIOUS
	visible_message(span_warning("[src] begins to stir within the sarcophagus..."))
	playsound(src, 'sound/effects/ghost.ogg', 50, TRUE, extrarange = 10)

/mob/living/scp/scp076/proc/process_awakening()
	if(world.time >= awakening_timer)
		enter_active()

/mob/living/scp/scp076/proc/enter_active()
	current_state = SCP076_STATE_ACTIVE
	stat = CONSCIOUS
	containment_status = "breached"
	health = maxHealth
	rage_meter = 0
	visible_message(span_danger("[src] fully emerges from the sarcophagus, eyes burning with battle fury!"))
	playsound(src, 'sound/effects/roar.ogg', 60, TRUE, extrarange = 20)
	hook_scp_breach("SCP-076", src)
	if(!blade_summoned)
		summon_blade()

/mob/living/scp/scp076/proc/process_active()
	if(health < maxHealth * 0.3)
		rage_meter = min(rage_meter + 2, max_rage)

	if(rage_meter > 70 && !speed_boost_active)
		activate_speed_boost()

	if(weapon_cooldown > 0)
		weapon_cooldown -= 1

	if(prob(5) && rage_meter > 30)
		playsound(src, 'sound/effects/roar.ogg', 30, TRUE, extrarange = 10)
		visible_message(span_danger("[src] roars with rage!"))

	for(var/mob/living/carbon/human/H in range(5, src))
		if(H == src || H.stat == DEAD)
			continue
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_VIOLENCE, 3)

	affect_rage_aura()

/mob/living/scp/scp076/proc/process_deceased()
	if(respawn_count < max_respawns)
		if(world.time >= dormant_timer)
			respawn_count++
			begin_awakening()
	else
		if(world.time >= dormant_timer)
			visible_message(span_notice("The sarcophagus remains silent. SCP-076-2 does not re-emerge."))

/mob/living/scp/scp076/proc/summon_blade()
	if(blade_summoned)
		return
	summoned_blade = new /obj/item/melee/scp076_blade(src)
	put_in_hands(summoned_blade)
	blade_summoned = TRUE
	visible_message(span_danger("[src] summons a blade of dark energy from thin air!"))

/mob/living/scp/scp076/proc/activate_speed_boost()
	speed_boost_active = TRUE
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/scp076_rage, TRUE, -1)
	visible_message(span_danger("[src] moves with blinding speed!"))
	addtimer(CALLBACK(src, .proc/deactivate_speed_boost), 300)

/mob/living/scp/scp076/proc/deactivate_speed_boost()
	speed_boost_active = FALSE
	remove_movespeed_modifier(/datum/movespeed_modifier/scp076_rage)

/mob/living/scp/scp076/process_ai()
	if(stat == DEAD)
		return
	if(current_state != SCP076_STATE_ACTIVE)
		return
	if(world.time < last_ai_tick + ai_tick_interval)
		return
	last_ai_tick = world.time

	if(containment_status != "breached")
		containment_status = "breached"

	if(health < maxHealth * 0.3)
		rage_meter = min(rage_meter + 2, max_rage)

	if(rage_meter > 70 && !speed_boost_active)
		activate_speed_boost()

	if(weapon_cooldown > 0)
		weapon_cooldown -= 1

	var/mob/living/carbon/human/prey = ai_find_combat_target()
	if(prey)
		ai_combat_pursue(prey)
	else
		ai_combat_wander()

	if(prob(5) && rage_meter > 30)
		playsound(src, 'sound/effects/roar.ogg', 30, TRUE, extrarange = 10)
		visible_message("<span class='danger'>[src] roars with rage!</span>")

	affect_rage_aura()

/mob/living/scp/scp076/proc/ai_find_combat_target()
	var/mob/living/carbon/human/best = null
	var/best_score = -INFINITY
	for(var/mob/living/carbon/human/H in view(12, src))
		if(H.stat == DEAD || H == src)
			continue
		var/score = 100 - get_dist(src, H) * 5
		if(H.health < H.maxHealth * 0.5)
			score += 20
		if(H.combat_mode)
			score += 15
		if(score > best_score)
			best_score = score
			best = H
	return best

/mob/living/scp/scp076/proc/ai_combat_pursue(mob/living/carbon/human/prey)
	if(get_dist(src, prey) <= 1)
		var/damage = 35 + (rage_meter * 0.3)
		prey.adjustBruteLoss(damage)
		if(prey.sanity)
			prey.sanity.add_trauma(TRAUMA_VIOLENCE, 15)
			affect_combat_sanity(prey)
		visible_message("<span class='danger'>[src] strikes [prey] with devastating force!</span>")
		playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
		rage_meter = min(rage_meter + 5, max_rage)
		if(prey.stat == DEAD)
			kill_count++
			rage_meter = max(rage_meter - 15, 0)
		return

	if(rage_meter > 50 && prob(20))
		scp076_ai_berserk()

	var/turf/next_turf = get_step_towards(src, prey)
	var/blocked = FALSE
	for(var/obj/O in next_turf)
		if(O.density)
			blocked = TRUE
			break
	if(next_turf && next_turf.density)
		blocked = TRUE

	if(blocked)
		var/obj/machinery/door/D = locate() in range(1, src)
		if(D && D.density)
			D.open(TRUE)
			visible_message("<span class='danger'>[src] smashes through [D]!</span>")
			playsound(D, 'sound/machines/door_open.ogg', 50, TRUE)
			return
		var/obj/structure/S = locate() in range(1, src)
		if(S && S.density)
			S.take_damage(60, BRUTE, "melee")
			visible_message("<span class='danger'>[src] destroys [S]!</span>")
			return

	step_to(src, prey)

	if(!blade_summoned && prob(10))
		summon_blade()

/mob/living/scp/scp076/proc/ai_combat_wander()
	if(prob(15))
		var/obj/machinery/door/D = locate() in range(3, src)
		if(D && D.density)
			D.open(TRUE)
			visible_message("<span class='danger'>[src] forces [D] open!</span>")
			return

	if(prob(10))
		var/obj/structure/S = locate() in range(2, src)
		if(S && S.density)
			S.take_damage(40, BRUTE, "melee")
			return

	if(ai_home_turf && get_dist(src, ai_home_turf) > ai_wander_range * 3)
		step_to(src, ai_home_turf)
	else
		step_rand(src)

	if(!blade_summoned && prob(5))
		summon_blade()

/mob/living/scp/scp076/proc/scp076_ai_berserk()
	add_movespeed_modifier(/datum/movespeed_modifier/scp076_berserk)
	visible_message("<span class='danger'>[src] enters a berserk frenzy!</span>")
	addtimer(CALLBACK(src, PROC_REF(scp076_end_berserk)), 20 SECONDS)

/mob/living/scp/scp076/proc/scp076_end_berserk()
	remove_movespeed_modifier(/datum/movespeed_modifier/scp076_berserk)
	to_chat(src, "<span class='notice'>Your berserk frenzy subsides.</span>")

/datum/movespeed_modifier/scp076_berserk
	id = "scp076_berserk"
	priority = 100
	slowdown = -1.5

/mob/living/scp/scp076/death(gibbed)
	if(current_state == SCP076_STATE_ACTIVE)
		current_state = SCP076_STATE_DECEASED
		dormant_timer = world.time + dormant_duration
		kill_count = 0
		rage_meter = 0
		stat = DEAD
		visible_message(span_danger("[src] falls... but the sarcophagus begins to glow."))
		hook_scp_recontainment("SCP-076", list())
		QDEL_NULL(summoned_blade)
		blade_summoned = FALSE
		addtimer(CALLBACK(src, .proc/check_respawn), dormant_duration)
	. = ..()

/mob/living/scp/scp076/proc/check_respawn()
	if(respawn_count >= max_respawns)
		return
	if(current_state != SCP076_STATE_DECEASED)
		return
	stat = CONSCIOUS
	begin_awakening()

/mob/living/scp/scp076/UnarmedAttack(atom/A)
	if(!isliving(A) || current_state != SCP076_STATE_ACTIVE)
		return ..()

	var/mob/living/L = A
	var/damage = 35 + (rage_meter * 0.3)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.adjustBruteLoss(damage)
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_VIOLENCE, 15)
		affect_combat_sanity(H)

	visible_message(span_danger("[src] strikes [L] with devastating force!"))
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)

	rage_meter = min(rage_meter + 5, max_rage)

	if(L.stat == DEAD)
		kill_count++
		rage_meter = max(rage_meter - 15, 0)

/mob/living/scp/scp076/examine(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, span_warning("This is SCP-076-2, 'Abel'. A Keter-class hostile entity with regenerative abilities. Current state: [current_state]. Respawn count: [respawn_count]/[max_respawns]"))

/mob/living/scp/scp076/get_status_tab_items()
	. = ..()
	. += "State: [current_state]"
	. += "Rage: [rage_meter]/[max_rage]"
	. += "Kills: [kill_count]"
	. += "Respawns: [respawn_count]/[max_respawns]"

/obj/item/melee/scp076_blade
	name = "Abyssal Blade"
	desc = "A blade of dark, pulsating energy summoned by SCP-076-2. It radiates hostility."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "katana"
	force = 45
	throwforce = 20
	throw_speed = 5
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	var/datum/weakref/owner_ref

/obj/item/melee/scp076_blade/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/melee/scp076_blade/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/scp076_blade/process()
	if(!owner_ref)
		if(ismob(loc))
			owner_ref = WEAKREF(loc)
		else
			visible_message(span_notice("The abyssal blade dissipates into shadow."))
			qdel(src)
			return

	var/mob/owner = owner_ref.resolve()
	if(!owner || !istype(owner, /mob/living/scp/scp076))
		visible_message(span_notice("The abyssal blade dissipates into shadow."))
		qdel(src)

/obj/item/melee/scp076_blade/attack(mob/living/target, mob/living/user)
	if(!istype(user, /mob/living/scp/scp076))
		to_chat(user, span_warning("The blade burns your hand!"))
		user.adjustFireLoss(15)
		user.dropItemToGround(src)
		return
	..()

/datum/movespeed_modifier/scp076_rage
	blacklisted_movetypes = FLOATING
	variable = TRUE

/obj/structure/scp076_sarcophagus
	name = "SCP-076-1 Sarcophagus"
	desc = "A large stone sarcophagus with intricate carvings. SCP-076-2 emerges from within."
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	density = TRUE
	anchored = TRUE
	var/mob/living/scp/scp076/contained_scp

/obj/structure/scp076_sarcophagus/Initialize(mapload)
	. = ..()
	contained_scp = new /mob/living/scp/scp076(get_turf(src))
	contained_scp.forceMove(src)

/obj/structure/scp076_sarcophagus/Destroy()
	QDEL_NULL(contained_scp)
	return ..()

/obj/structure/scp076_sarcophagus/attack_hand(mob/user)
	. = ..()
	if(contained_scp && contained_scp.current_state == SCP076_STATE_DORMANT)
		to_chat(user, span_warning("You hear faint scratching from inside the sarcophagus..."))
