#define SCP1128_PHASE_OBSERVE "observing"
#define SCP1128_PHASE_HAUNT "haunting"
#define SCP1128_PHASE_MANIFEST "manifested"

/mob/living/scp/scp1128
	ai_enabled = TRUE
	name = "SCP-1128"
	desc = "An aquatic predator that manifests when its victims are submerged in water. Those who know of its existence become vulnerable."
	icon = 'icons/mob/carp.dmi'
	icon_state = "carp"
	real_name = "SCP-1128"
	persistence_id = "SCP-1128"

	var/manifestation_phase = SCP1128_PHASE_OBSERVE
	var/list/aware_victims = list()
	var/haunt_cooldown = 0
	var/manifest_cooldown = 0
	var/grab_cooldown = 0
	var/drown_damage = 15
	var/aura_range = 7
	var/list/water_turfs = list()

/mob/living/scp/scp1128/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "SCP-1128", SCP_EUCLID, "1128", SCP_SENTIENT)
	maxHealth = 250
	health = maxHealth
	invisibility = INVISIBILITY_OBSERVER
	alpha = 0
	density = FALSE

/mob/living/scp/scp1128/Destroy()
	aware_victims.Cut()
	return ..()

/mob/living/scp/scp1128/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	if(haunt_cooldown > 0)
		haunt_cooldown -= delta_time
	if(manifest_cooldown > 0)
		manifest_cooldown -= delta_time
	if(grab_cooldown > 0)
		grab_cooldown -= delta_time

	scan_for_water()
	process_victims()
	affect_water_sanity()

/mob/living/scp/scp1128/proc/scan_for_water()
	water_turfs.Cut()
	for(var/turf/open/T in range(aura_range, src))
		if(istype(T, /turf/open/water))
			water_turfs += T

/mob/living/scp/scp1128/proc/process_victims()
	for(var/ckey in aware_victims)
		var/mob/living/carbon/human/H = get_mob_by_ckey(ckey)
		if(!H || H.stat == DEAD)
			continue

		var/in_water = FALSE
		var/turf/T = get_turf(H)
		if(T && istype(T, /turf/open/water))
			in_water = TRUE

		if(in_water && manifestation_phase == SCP1128_PHASE_OBSERVE)
			manifestation_phase = SCP1128_PHASE_HAUNT
			begin_haunting(H)

		if(in_water && manifestation_phase == SCP1128_PHASE_HAUNT && prob(15))
			attempt_grab(H)

/mob/living/scp/scp1128/proc/begin_haunting(mob/living/carbon/human/victim)
	if(haunt_cooldown > 0)
		return

	haunt_cooldown = 200

	to_chat(victim, span_danger("You feel something moving beneath the water..."))
	playsound(victim, 'sound/effects/slosh.ogg', 30, TRUE)

	if(victim.sanity)
		victim.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 8)

	addtimer(CALLBACK(src, .proc/attempt_manifest, victim), rand(100, 300))

/mob/living/scp/scp1128/proc/attempt_manifest(mob/living/carbon/human/victim)
	if(manifest_cooldown > 0)
		return
	if(manifestation_phase == SCP1128_PHASE_MANIFEST)
		return

	manifestation_phase = SCP1128_PHASE_MANIFEST
	manifest_cooldown = 600
	containment_status = "breached"

	var/turf/T = get_turf(victim)
	if(T)
		forceMove(T)

	invisibility = 0
	alpha = 255
	density = TRUE

	visible_message(span_danger("A massive aquatic horror erupts from the water!"))
	playsound(src, 'sound/effects/slosh.ogg', 60, TRUE, extrarange = 10)

	hook_scp_breach("SCP-1128", src)

	addtimer(CALLBACK(src, .proc/demanifest), rand(300, 600))

/mob/living/scp/scp1128/proc/demanifest()
	manifestation_phase = SCP1128_PHASE_OBSERVE
	containment_status = "contained"

	invisibility = INVISIBILITY_OBSERVER
	alpha = 0
	density = FALSE

	visible_message(span_notice("The aquatic horror sinks back beneath the water and vanishes."))

/mob/living/scp/scp1128/proc/attempt_grab(mob/living/carbon/human/victim)
	if(grab_cooldown > 0)
		return
	if(manifestation_phase != SCP1128_PHASE_MANIFEST)
		return

	grab_cooldown = 100

	victim.adjustBruteLoss(drown_damage)
	victim.adjustOxyLoss(20)

	victim.visible_message(
		span_danger("[src] drags [victim] beneath the water!"),
		span_userdanger("Something grabs you from below and drags you under! You can't breathe!")
	)

	if(victim.sanity)
		victim.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, 15)

/mob/living/scp/scp1128/UnarmedAttack(atom/A)
	if(!ishuman(A))
		return ..()

	var/mob/living/carbon/human/H = A

	if(manifestation_phase != SCP1128_PHASE_MANIFEST)
		return

	H.adjustBruteLoss(25)
	H.adjustOxyLoss(15)

	if(H.sanity)
		H.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, 10)

	visible_message(span_danger("[src] attacks [H] with crushing force!"))
	playsound(src, 'sound/effects/blobattack.ogg', 40, TRUE)

/mob/living/scp/scp1128/proc/add_aware_victim(mob/living/carbon/human/H)
	if(!H || !H.ckey)
		return
	if(H.ckey in aware_victims)
		return
	aware_victims[H.ckey] = world.time

/mob/living/scp/scp1128/proc/get_mob_by_ckey(ckey)
	return GLOB.directory[ckey]

/mob/living/scp/scp1128/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		add_aware_victim(H)
		to_chat(H, span_warning("This is SCP-1128, an aquatic predator. By observing it, you have become vulnerable when submerged in water..."))
		if(H.sanity)
			H.sanity.add_trauma(TRAUMA_SCP_EXPOSURE, 5)

/mob/living/scp/scp1128/get_status_tab_items()
	. = ..()
	. += "Phase: [manifestation_phase]"
	. += "Aware Victims: [length(aware_victims)]"
	. += "Water Tiles: [length(water_turfs)]"

/mob/living/scp/scp1128/process_ai()
	if(stat == DEAD)
		return

	switch(manifestation_phase)
		if(SCP1128_PHASE_OBSERVE)
			if(length(water_turfs))
				var/turf/open/water/W = pick(water_turfs)
				if(get_dist(src, W) > 3)
					step_towards(src, W)
			else if(length(aware_victims))
				var/first_ckey = aware_victims[1]
				var/mob/M = get_mob_by_ckey(first_ckey)
				if(M && get_dist(src, M) > 5)
					step_towards(src, M)
			else if(prob(8))
				step_rand(src)
		if(SCP1128_PHASE_HAUNT)
			return
		if(SCP1128_PHASE_MANIFEST)
			for(var/ckey in aware_victims)
				var/mob/living/carbon/human/H = get_mob_by_ckey(ckey)
				if(!H || H.stat == DEAD)
					continue
				if(get_dist(src, H) > 1)
					ai_step_towards(H)
				break
