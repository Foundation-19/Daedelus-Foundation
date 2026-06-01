// SCP-2343 Modular Systems (trickster reality effects)

/datum/scp2343_benevolence_system
	var/mob/living/scp/scp2343/owner
	var/next_tick = 0
	var/tick_interval = 6 SECONDS
	var/effect_radius = 5

/datum/scp2343_benevolence_system/New(mob/living/scp/scp2343/new_owner)
	owner = new_owner

/datum/scp2343_benevolence_system/proc/process_benevolence()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_tick)
		return
	next_tick = world.time + tick_interval

	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(effect_radius, owner))
		if(H != owner && H.stat != DEAD)
			targets += H
	if(!length(targets))
		return

	var/mob/living/carbon/human/target = pick(targets)
	var/roll = rand(1, 4)
	switch(roll)
		if(1)
			to_chat(target, span_notice("A calming warmth soothes you."))
			target.adjustBruteLoss(-5)
		if(2)
			to_chat(target, span_notice("A gentle light eases your mind."))
			target.sanity?.adjust_sanity(1)
		if(3)
			to_chat(target, span_notice("Ambient noise fades; you feel focused."))
		if(4)
			to_chat(target, span_notice("A refreshing coolness revitalizes you."))
			target.adjustToxLoss(-2)

/datum/scp2343_research_system
	var/mob/living/scp/scp2343/owner
	var/last = 0
	var/gap = 30 SECONDS

/datum/scp2343_research_system/New(mob/living/scp/scp2343/new_owner)
	owner = new_owner

/datum/scp2343_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "benevolent_reality", 6)
