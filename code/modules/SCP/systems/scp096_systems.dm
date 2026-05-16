// SCP-096 Modular Systems
// Rage Tracking, Face Revelation, and Research Systems

/datum/scp096_rage_system
	var/mob/living/scp/scp096/owner
	var/rage_level = 0
	var/max_rage_level = 100
	var/rage_multiplier = 1.0
	var/rage_decay_rate = 0.1
	var/rage_escalation_bonus = 0
	var/rage_boost_duration = 0
	var/rage_boost_duration_time = 2 MINUTES
	var/rage_activations = 0
	var/rage_escalations = 0
	var/last_rage_time = 0
	var/total_damage_dealt = 0

/datum/scp096_rage_system/New(mob/living/scp/scp096/new_owner)
	owner = new_owner

/datum/scp096_rage_system/proc/process_rage()
	if(!owner || owner.stat == DEAD)
		return

	if(rage_level > 0)
		rage_level = max(0, rage_level - rage_decay_rate)

	if(world.time < rage_boost_duration)
		rage_multiplier = min(3.0, rage_multiplier)
	else
		rage_multiplier = max(1.0, rage_multiplier - 0.01)

	if(rage_level > 20)
		for(var/mob/living/carbon/human/H in range(3, owner))
			if(H.stat != DEAD && H != owner)
				var/damage = rage_level * 0.1 * rage_multiplier
				H.adjustBruteLoss(damage)
				total_damage_dealt += damage

/datum/scp096_rage_system/proc/trigger_rage(amount = 10)
	rage_level = min(max_rage_level, rage_level + amount + rage_escalation_bonus)
	rage_activations++
	owner.rage_activations++
	last_rage_time = world.time
	rage_escalation_bonus += 5

/datum/scp096_rage_system/proc/escalate_rage()
	rage_level = min(max_rage_level, rage_level + 25)
	rage_escalations++
	rage_multiplier += 0.2
	rage_escalation_bonus += 10
	rage_boost_duration = world.time + rage_boost_duration_time

	for(var/mob/living/carbon/human/H in range(5, owner))
		if(H != owner)
			to_chat(H, "<span class='danger'>You feel an overwhelming sense of dread as something nearby becomes enraged...</span>")

/datum/scp096_rage_system/proc/activate_rage_boost()
	rage_boost_duration = world.time + rage_boost_duration_time
	rage_multiplier += 0.3
	rage_level = min(max_rage_level, rage_level + 30)

// Face Revelation System
/datum/scp096_face_system
	var/mob/living/scp/scp096/owner
	var/face_revelation_cooldown = 0
	var/face_revelation_cooldown_time = 60 SECONDS
	var/face_revelations = 0
	var/announcement_cooldown = 0
	var/announcement_cooldown_time = 120 SECONDS
	var/last_announcement = 0
	var/list/announcement_messages = list(
		"*whimpers softly*",
		"*covers face with hands*",
		"*shakes violently*",
		"*mumbles incoherently*",
		"*tries to hide in shadows*"
	)

/datum/scp096_face_system/New(mob/living/scp/scp096/new_owner)
	owner = new_owner

/datum/scp096_face_system/proc/process_face_revelation()
	if(!owner || owner.stat == DEAD)
		return

	if(prob(2) && world.time > last_announcement + announcement_cooldown)
		announce_presence()

/datum/scp096_face_system/proc/reveal_face()
	if(world.time < face_revelation_cooldown)
		return FALSE

	face_revelation_cooldown = world.time + face_revelation_cooldown_time
	face_revelations++

	playsound(owner, 'sound/effects/ghost.ogg', 50, 0)
	owner.visible_message("<span class='danger'>[owner] reveals their face in a moment of pure terror!</span>")

	for(var/mob/living/carbon/human/H in range(7, owner))
		if(H != owner)
			to_chat(H, "<span class='danger'>You catch a glimpse of something that fills you with primal fear...</span>")

	return TRUE

/datum/scp096_face_system/proc/announce_presence()
	if(world.time < last_announcement + announcement_cooldown)
		return

	last_announcement = world.time
	var/announcement = pick(announcement_messages)

	playsound(owner, 'sound/effects/ghost.ogg', 30, 0)

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H))
			continue
		if(H.z == owner.z)
			to_chat(H, "<span class='danger'>[announcement]</span>")

// Scream System
/datum/scp096_scream_system
	var/mob/living/scp/scp096/owner
	var/scream_cooldown = 0
	var/scream_cooldown_time = 30 SECONDS
	var/scream_range = 5
	var/scream_damage = 15
	var/scream_attacks = 0

/datum/scp096_scream_system/New(mob/living/scp/scp096/new_owner)
	owner = new_owner

/datum/scp096_scream_system/proc/process_scream()
	if(!owner || owner.stat == DEAD)
		return

/datum/scp096_scream_system/proc/perform_scream_attack(mob/living/carbon/human/target)
	if(world.time < scream_cooldown || !target)
		return FALSE

	scream_cooldown = world.time + scream_cooldown_time
	scream_attacks++

	var/damage = scream_damage
	target.adjustBruteLoss(damage)

	if(prob(30))
		to_chat(target, "<span class='danger'>The scream fills you with overwhelming terror!</span>")

	playsound(owner, 'sound/effects/ghost2.ogg', 70, 0)
	owner.visible_message("<span class='danger'>[owner] lets out a blood-curdling scream at [target]!</span>")
	to_chat(target, "<span class='danger'>You hear a terrifying scream that shakes your very soul!</span>")

	return TRUE

// Hysteria System
/datum/scp096_hysteria_system
	var/mob/living/scp/scp096/owner
	var/hysteria_radius = 7
	var/hysteria_duration = 0
	var/hysteria_duration_time = 3 MINUTES
	var/hysteria_events = 0

/datum/scp096_hysteria_system/New(mob/living/scp/scp096/new_owner)
	owner = new_owner

/datum/scp096_hysteria_system/proc/process_hysteria()
	if(!owner || owner.stat == DEAD)
		return

/datum/scp096_hysteria_system/proc/trigger_mass_hysteria()
	hysteria_events++
	hysteria_duration = world.time + hysteria_duration_time

	for(var/mob/living/carbon/human/H in range(hysteria_radius, owner))
		if(H != owner)
			H.adjustBruteLoss(10)
			to_chat(H, "<span class='danger'>Mass hysteria grips the area! You feel overwhelming fear!</span>")

			if(prob(40))
				to_chat(H, "<span class='danger'>You panic and lose control!</span>")

	playsound(owner, 'sound/effects/ghost.ogg', 80, 0)
	owner.visible_message("<span class='danger'>[owner] causes mass hysteria in the area!</span>")

// Research System
/datum/scp096_research_system
	var/mob/living/scp/scp096/owner
	var/list/research_data = list()

/datum/scp096_research_system/New(mob/living/scp/scp096/new_owner)
	owner = new_owner

/datum/scp096_research_system/proc/process_research()
	if(!owner || owner.stat == DEAD)
		return

	var/list/current_data = list(
		"state" = owner.state,
		"face_viewers" = length(owner.face_viewers),
		"kills_count" = owner.kills_count,
		"rage_activations" = owner.rage_activations,
		"victims_hunted" = owner.victims_hunted,
		"containment_escapes" = owner.containment_escapes
	)

	research_data = current_data

/datum/scp096_research_system/proc/contribute_research_data()
	if(!owner || !owner.SCP)
		return
