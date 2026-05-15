/datum/scp966_sleep_system
	var/mob/living/scp/scp966/owner
	var/next_drain = 0
	var/drain_interval = 10 SECONDS
	var/effect_radius = 5
	var/intensity = 1
	var/max_intensity = 5

/datum/scp966_sleep_system/New(mob/living/scp/scp966/new_owner)
	owner = new_owner

/datum/scp966_sleep_system/proc/process_sleep()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_drain)
		return
	next_drain = world.time + drain_interval
	for(var/mob/living/carbon/human/H in range(effect_radius, owner))
		if(H == owner || H.stat == DEAD)
			continue
		H.adjust_drowsyness(intensity * 2)
		if(prob(30))
			to_chat(H, "<span class='warning'>An oppressive exhaustion presses upon you. Your eyelids feel heavy.</span>")
		if(H.drowsyness >= 60 && prob(15))
			H.AdjustSleeping(20)
			to_chat(H, "<span class='warning'>You can't keep your eyes open any longer...</span>")
			owner.victims_sleep_deprived++

/datum/scp966_stealth_system
	var/mob/living/scp/scp966/owner
	var/next_toggle = 0
	var/toggle_interval = 20 SECONDS
	var/active = TRUE

/datum/scp966_stealth_system/New(mob/living/scp/scp966/new_owner)
	owner = new_owner

/datum/scp966_stealth_system/proc/process_stealth()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time > next_toggle && prob(10))
		next_toggle = world.time + toggle_interval
		active = !active
		if(!active && prob(30))
			owner.visible_message("<span class='notice'>A shimmer reveals something in the air, then fades.</span>")

/datum/scp966_stalk_system
	var/mob/living/scp/scp966/owner
	var/list/stalked = list()
	var/next_scan = 0
	var/scan_interval = 15 SECONDS

/datum/scp966_stalk_system/New(mob/living/scp/scp966/new_owner)
	owner = new_owner

/datum/scp966_stalk_system/proc/process_stalk()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_scan)
		return
	next_scan = world.time + scan_interval
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in view(6, owner))
		if(H != owner && H.stat != DEAD)
			candidates += H
	if(length(candidates))
		var/mob/living/carbon/human/choice = pick(candidates)
		if(!(choice in stalked))
			stalked += choice
			to_chat(choice, "<span class='danger'>You feel an unseen gaze upon you...</span>")

/datum/scp966_nightmare_system
	var/mob/living/scp/scp966/owner
	var/next_event = 0
	var/event_interval = 30 SECONDS

/datum/scp966_nightmare_system/New(mob/living/scp/scp966/new_owner)
	owner = new_owner

/datum/scp966_nightmare_system/proc/process_nightmares()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_event)
		return
	next_event = world.time + event_interval
	if(prob(15))
		var/list/victims = list()
		for(var/mob/living/carbon/human/H in view(4, owner))
			if(H != owner && H.stat != DEAD)
				victims += H
		if(length(victims))
			var/mob/living/carbon/human/v = pick(victims)
			to_chat(v, "<span class='danger'>A waking nightmare grips you with dread.</span>")
			v.adjust_drowsyness(8)
			v.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
			owner.nightmares_caused++

/datum/scp966_research_system
	var/mob/living/scp/scp966/owner
	var/last = 0
	var/gap = 40 SECONDS

/datum/scp966_research_system/New(mob/living/scp/scp966/new_owner)
	owner = new_owner

/datum/scp966_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "sleep_deprivation_phenomena", 8)
