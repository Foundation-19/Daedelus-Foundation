// SCP-3199 Modular Systems

/datum/scp3199_reproduction_system
	var/mob/living/scp/scp3199/owner
	var/egg_cooldown = 0
	var/egg_time = 3000 // 5 minutes

/datum/scp3199_reproduction_system/New(mob/living/scp/scp3199/new_owner)
	owner = new_owner

/datum/scp3199_reproduction_system/proc/process_reproduction()
	if(!owner || owner.stat == DEAD)
		return
	if(egg_cooldown > 0)
		egg_cooldown--
		return
	if(prob(2))
		egg_cooldown = egg_time
		owner.visible_message("<span class='danger'>[owner] convulses violently, producing a screech!</span>")
		playsound(owner, 'sound/effects/explosion1.ogg', 100, TRUE, 10)
		var/turf/T = get_turf(owner)
		if(T)
			var/obj/item/scp3199_egg/egg = new /obj/item/scp3199_egg(T)
			egg.parent_entity = owner
			owner.SCP?.log_interaction(owner, "egg_production")
			owner.SCP?.award_research(owner, "reproduction", 75)

/datum/scp3199_containment_system
	var/mob/living/scp/scp3199/owner
	var/last_check = 0
	var/check_interval = 600
	var/breached = FALSE

/datum/scp3199_containment_system/New(mob/living/scp/scp3199/new_owner)
	owner = new_owner

/datum/scp3199_containment_system/proc/process_containment()
	if(!owner)
		return
	if(world.time < last_check + check_interval)
		return
	last_check = world.time
	var/area/A = get_area(owner)
	if(!istype(A, /area))
		if(!breached)
			breached = TRUE
			owner.SCP?.log_interaction(owner, "containment_breach")
			owner.SCP?.award_research(owner, "containment", 100)
			priority_announce("SCP-3199 containment breach detected! All security personnel respond immediately!", "Security Alert", 'sound/effects/explosion1.ogg')
	else
		if(breached)
			breached = FALSE
			owner.SCP?.log_interaction(owner, "containment_restored")

/datum/scp3199_environment_system
	var/mob/living/scp/scp3199/owner
	var/next_note = 0
	var/note_interval = 12 SECONDS

/datum/scp3199_environment_system/New(mob/living/scp/scp3199/new_owner)
	owner = new_owner

/datum/scp3199_environment_system/proc/process_environment()
	if(!owner || owner.stat == DEAD)
		return
	if(world.time < next_note)
		return
	next_note = world.time + note_interval
	if(prob(8))
		owner.visible_message("<span class='notice'>An acrid, albumen-like odor lingers in the air.</span>")

/datum/scp3199_research_system
	var/mob/living/scp/scp3199/owner
	var/last = 0
	var/gap = 30 SECONDS

/datum/scp3199_research_system/New(mob/living/scp/scp3199/new_owner)
	owner = new_owner

/datum/scp3199_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "scp3199_behavior", 10)




