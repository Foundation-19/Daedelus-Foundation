#define SCP408_STATE_DORMANT "dormant"
#define SCP408_STATE_AWARE "aware"
#define SCP408_STATE_ACTIVE "active"
#define SCP408_STATE_SWARM "swarm"

/mob/living/scp/scp408
	ai_enabled = TRUE
	name = "SCP-408"
	desc = "A swarm of iridescent butterflies that can become invisible and disrupt visual perception."
	icon = 'icons/mob/animal.dmi'
	icon_state = "butterfly"
	real_name = "SCP-408"
	persistence_id = "SCP-408"

	var/swarm_state = SCP408_STATE_DORMANT
	var/invisibility_active = FALSE
	var/invisibility_cooldown = 0
	var/disruption_range = 5
	var/disruption_cooldown = 0
	var/swarm_size = 100
	var/max_swarm_size = 500
	var/healing_aura_active = FALSE
	var/list/affected_mobs = list()

/mob/living/scp/scp408/Initialize(mapload)
	. = ..()
	SCP = new /datum/scp(src, "SCP-408", SCP_EUCLID, "408", SCP_SENTIENT)
	maxHealth = 200
	health = maxHealth
	alpha = 200

	add_verb(src, list(
		/mob/living/scp/scp408/proc/toggle_invisibility,
		/mob/living/scp/scp408/proc/disrupt_vision,
	))

/mob/living/scp/scp408/Destroy()
	deactivate_invisibility()
	deactivate_disruption()
	return ..()

/mob/living/scp/scp408/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		return

	if(invisibility_cooldown > 0)
		invisibility_cooldown -= delta_time

	if(disruption_cooldown > 0)
		disruption_cooldown -= delta_time

	update_swarm_state()
	process_swarm_effects()
	affect_perception_sanity()

	if(prob(3) && !invisibility_active)
		flick("butterfly_flutter", src)

/mob/living/scp/scp408/proc/update_swarm_state()
	if(swarm_size < 50)
		swarm_state = SCP408_STATE_DORMANT
	else if(swarm_size < 150)
		swarm_state = SCP408_STATE_AWARE
	else if(swarm_size < 350)
		swarm_state = SCP408_STATE_ACTIVE
	else
		swarm_state = SCP408_STATE_SWARM

/mob/living/scp/scp408/proc/process_swarm_effects()
	switch(swarm_state)
		if(SCP408_STATE_DORMANT)
			return
		if(SCP408_STATE_AWARE)
			if(prob(5))
				for(var/mob/living/carbon/human/H in range(3, src))
					if(H.sanity)
						H.sanity.hallucination_level = min(H.sanity.hallucination_level + 1, H.sanity.max_hallucination)
		if(SCP408_STATE_ACTIVE)
			if(!invisibility_active && prob(10))
				activate_invisibility()
			if(prob(8))
				for(var/mob/living/carbon/human/H in range(disruption_range, src))
					if(H.sanity)
						H.sanity.hallucination_level = min(H.sanity.hallucination_level + 3, H.sanity.max_hallucination)
						if(prob(20))
							H.sanity.add_trauma(TRAUMA_PSYCHOLOGICAL, 2)
		if(SCP408_STATE_SWARM)
			if(!invisibility_active && prob(15))
				activate_invisibility()
			if(prob(10))
				activate_disruption()
			if(prob(5))
				healing_aura()

/mob/living/scp/scp408/proc/toggle_invisibility()
	set name = "Toggle Invisibility"
	set category = "SCP-408"
	set desc = "Become invisible to the naked eye."

	if(invisibility_active)
		deactivate_invisibility()
	else
		activate_invisibility()

/mob/living/scp/scp408/proc/activate_invisibility()
	if(invisibility_active || invisibility_cooldown > 0)
		return
	invisibility_active = TRUE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 0
	visible_message(span_notice("The swarm of butterflies fades from view!"))
	playsound(src, 'sound/effects/bamf.ogg', 20, TRUE)

/mob/living/scp/scp408/proc/deactivate_invisibility()
	if(!invisibility_active)
		return
	invisibility_active = FALSE
	invisibility = 0
	alpha = 200
	invisibility_cooldown = 200
	visible_message(span_notice("A swarm of iridescent butterflies materializes!"))

/mob/living/scp/scp408/proc/disrupt_vision()
	set name = "Visual Disruption"
	set category = "SCP-408"
	set desc = "Disrupt the vision of nearby creatures."
	activate_disruption()

/mob/living/scp/scp408/proc/activate_disruption()
	if(disruption_cooldown > 0)
		to_chat(src, span_warning("Visual disruption is still recharging."))
		return

	disruption_cooldown = 300

	for(var/mob/living/carbon/human/H in range(disruption_range, src))
		if(H == src || H.stat == DEAD)
			continue

		H.overlay_fullscreen("scp408_disrupt", /atom/movable/screen/fullscreen/flash/static)
		addtimer(CALLBACK(H, /mob/proc/clear_fullscreen, "scp408_disrupt", 10), rand(20, 60))

		if(H.sanity)
			H.sanity.hallucination_level = min(H.sanity.hallucination_level + 10, H.sanity.max_hallucination)

		to_chat(H, span_warning("Your vision blurs and distorts as colors shift around you!"))

	visible_message(span_notice("The butterflies pulse with iridescent light!"))

/mob/living/scp/scp408/proc/deactivate_disruption()
	for(var/mob/living/carbon/human/H in affected_mobs)
		if(H)
			H.clear_fullscreen("scp408_disrupt")
	affected_mobs.Cut()

/mob/living/scp/scp408/proc/healing_aura()
	healing_aura_active = TRUE

	for(var/mob/living/carbon/human/H in range(2, src))
		if(H.stat == DEAD)
			continue
		H.adjustBruteLoss(-5)
		H.adjustFireLoss(-5)
		if(H.sanity)
			H.sanity.adjust_sanity(3)

	addtimer(CALLBACK(src, .proc/end_healing_aura), 100)

/mob/living/scp/scp408/proc/end_healing_aura()
	healing_aura_active = FALSE

/mob/living/scp/scp408/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(healing_aura_active)
			H.adjustBruteLoss(-10)
			H.adjustFireLoss(-10)
			if(H.sanity)
				H.sanity.adjust_sanity(5)
			to_chat(H, span_notice("The butterflies settle on you briefly, and you feel refreshed."))
		else
			if(H.sanity)
				H.sanity.hallucination_level = min(H.sanity.hallucination_level + 5, H.sanity.max_hallucination)
			to_chat(H, span_warning("The butterflies flutter around you, making it hard to focus!"))
		return
	return ..()

/mob/living/scp/scp408/examine(mob/user)
	. = ..()
	if(invisibility_active && !isobserver(user))
		return
	if(ishuman(user))
		to_chat(user, span_notice("This is SCP-408, a swarm of illusory butterflies. They can become invisible and disrupt visual perception."))

/mob/living/scp/scp408/get_status_tab_items()
	. = ..()
	. += "Swarm State: [swarm_state]"
	. += "Swarm Size: [swarm_size]/[max_swarm_size]"
	. += "Invisible: [invisibility_active ? "Yes" : "No"]"

/mob/living/scp/scp408/process_ai()
	if(stat == DEAD)
		return

	switch(swarm_state)
		if(SCP408_STATE_DORMANT)
			if(prob(10))
				step_rand(src)
		if(SCP408_STATE_AWARE)
			if(prob(20))
				var/mob/living/carbon/human/H = locate() in view(5, src)
				if(H)
					step_towards(src, H)
				else
					step_rand(src)
		if(SCP408_STATE_ACTIVE)
			var/mob/living/carbon/human/H = locate() in view(5, src)
			if(H && prob(40))
				step_towards(src, H)
			else if(prob(15))
				step_rand(src)
		if(SCP408_STATE_SWARM)
			var/mob/living/carbon/human/H = locate() in view(5, src)
			if(H && prob(60))
				step_towards(src, H)
			else if(prob(20))
				step_rand(src)
