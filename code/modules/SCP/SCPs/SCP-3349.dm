// SCP-3349 - Cardiac Arrhythmia
// A communicable cardiac arrhythmia that produces EKG waveforms resembling human vocalizations
// The heart's electrical activity produces sounds resembling laughter, wailing, or speech
// Keter because it is communicable and hard to contain

/obj/item/reagent_containers/glass/bottle/scp3349
	name = "SCP-3349"
	desc = "A sealed medical container holding a strange amber fluid. The liquid seems to pulse faintly, as if in rhythm with a heartbeat."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "bottle"
	var/containment_breached = FALSE
	var/infection_strength = 30
	var/list/infected_targets = list()
	var/list/vocalization_log = list()
	var/total_infections = 0
	var/total_vocalizations = 0
	var/session_start_time = 0

/obj/item/reagent_containers/glass/bottle/scp3349/Initialize()
	. = ..()

	SCP = new /datum/scp(
		src,
		"SCP-3349",
		SCP_KETER,
		"3349"
	)

	session_start_time = world.time

	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/glass/bottle/scp3349/Destroy()
	infected_targets = list()
	vocalization_log = list()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/glass/bottle/scp3349/process()
	if(!containment_breached)
		return

	process_infection_spread()
	process_vocalizations()

/obj/item/reagent_containers/glass/bottle/scp3349/proc/process_infection_spread()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.stat == DEAD || H.SCP)
			continue

		if(!(H in infected_targets))
			attempt_infection(H)

/obj/item/reagent_containers/glass/bottle/scp3349/proc/attempt_infection(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	if(target in infected_targets)
		return

	if(prob(infection_strength / 3))
		infect_target(target)

/obj/item/reagent_containers/glass/bottle/scp3349/proc/infect_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD)
		return

	infected_targets += target
	total_infections++
	containment_breached = TRUE

	to_chat(target, "<span class='warning'>You feel an odd flutter in your chest... Your heartbeat seems irregular.</span>")

	visible_message("<span class='notice'>[target] clutches their chest briefly.</span>")

	addtimer(CALLBACK(src, PROC_REF(begin_arrhythmia), target), 30 SECONDS)

/obj/item/reagent_containers/glass/bottle/scp3349/proc/begin_arrhythmia(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD || QDELETED(target))
		infected_targets -= target
		return

	to_chat(target, "<span class='warning'>Your heart is beating strangely... You can hear something in its rhythm.</span>")

	process_affected_target(target)

/obj/item/reagent_containers/glass/bottle/scp3349/proc/process_affected_target(mob/living/carbon/human/target)
	if(!target || target.stat == DEAD || QDELETED(target))
		infected_targets -= target
		return

	if(!(target in infected_targets))
		return

	var/vocalization_type = pick("laughter", "wailing", "whispering", "murmuring", "speech")

	var/vocalization = ""
	switch(vocalization_type)
		if("laughter")
			vocalization = pick(list(
				"A faint chuckling seems to emanate from [target]'s chest.",
				"Soft laughter pulses from [target]'s heartbeat.",
				"[target]'s heart produces a rhythm that sounds disturbingly like giggling."
			))
		if("wailing")
			vocalization = pick(list(
				"A mournful wailing rises from [target]'s chest.",
				"[target]'s heartbeat produces a sound like distant crying.",
				"The rhythm of [target]'s heart forms a low, keening wail."
			))
		if("whispering")
			vocalization = pick(list(
				"Whispers seem to pulse from [target]'s heartbeat.",
				"[target]'s heart murmurs something unintelligible.",
				"A faint whispering rhythm emanates from [target]'s chest."
			))
		if("murmuring")
			vocalization = pick(list(
				"[target]'s heartbeat produces a murmuring cadence, like someone speaking softly.",
				"A low murmuring seems to come from [target]'s chest in time with their pulse.",
				"The electrical pattern of [target]'s heart forms quiet, murmuring sounds."
			))
		if("speech")
			var/phrases = list(
				"help me",
				"it beats",
				"can you hear",
				"listen",
				"it speaks",
				"don't stop",
				"the rhythm",
				"it knows"
			)
			var/phrase = pick(phrases)
			vocalization = "[target]'s heartbeat distinctly forms words: '[phrase]'."

	visible_message("<span class='warning'>[vocalization]</span>")
	total_vocalizations++

	vocalization_log += list(list("time" = world.time, "type" = vocalization_type, "target" = target.ckey))

	if(prob(40))
		target.adjustBruteLoss(3)
		to_chat(target, "<span class='warning'>The irregular heartbeat causes you chest pain!</span>")

	if(prob(20))
		if(target.stamina)
			target.stamina.adjust(-15)
		to_chat(target, "<span class='warning'>The arrhythmia leaves you feeling weak and lightheaded!</span>")

	if(target.stat != DEAD && (target in infected_targets))
		addtimer(CALLBACK(src, PROC_REF(process_affected_target), target), rand(20 SECONDS, 45 SECONDS))

/obj/item/reagent_containers/glass/bottle/scp3349/proc/process_vocalizations()
	for(var/mob/living/carbon/human/H in infected_targets)
		if(H.stat == DEAD)
			infected_targets -= H
			continue

		if(prob(10))
			audible_message("<span class='notice'>A faint, rhythmic sound emanates from [H]...</span>")

/obj/item/reagent_containers/glass/bottle/scp3349/attack(mob/living/target, mob/living/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target

		containment_breached = TRUE
		infect_target(H)

		visible_message("<span class='danger'>[user] exposes [H] to SCP-3349!</span>")

		hook_scp_combat(H, "SCP-3349", 0, infection_strength)
		return

	return ..()

/obj/item/reagent_containers/glass/bottle/scp3349/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, "<span class='warning'>This is SCP-3349, a communicable cardiac arrhythmia that produces vocalizations from the heart's electrical activity.</span>")
			to_chat(user, "<span class='warning'>Infected targets: [length(infected_targets)]</span>")
		else
			to_chat(user, "<span class='notice'>A sealed medical container. The fluid inside pulses faintly.</span>")

/obj/item/reagent_containers/glass/bottle/scp3349/proc/is_spreading()
	return length(infected_targets) > 0
