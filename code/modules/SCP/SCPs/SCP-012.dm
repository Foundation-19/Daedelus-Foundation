/obj/item/paper/scp012
	name = "SCP-012"
	desc = "A sheet of paper with an incomplete musical composition that seems to drive those who read it to complete it with their own blood."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp012"
	var/completion_progress = 0
	var/max_completion = 100
	var/list/affected_composers = list()
	var/list/composition_notes = list()
	var/sanity_drain_radius = 4
	var/composition_cooldown = 0
	var/composition_cooldown_time = 60 SECONDS
	var/max_obsession = 100
	var/persistence_cooldown = 0
	var/message_cooldown = 30 SECONDS

	// Persistence tracking
	var/composers_affected = 0
	var/completion_attempts = 0
	var/sanity_drained = 0
	var/containment_status = "contained"
	var/total_blood_used = 0
	var/composer_deaths = 0

/obj/item/paper/scp012/Initialize()
	. = ..()

	// Initialize SCP datum
	SCP = new /datum/scp(
		src,
		"SCP-012",
		SCP_EUCLID,
		"012",

	)

	SCP.min_playercount = 15
	SCP.min_time = 20 MINUTES

	START_PROCESSING(SSobj, src)

	// Register with SCP persistence system
/obj/item/paper/scp012/Destroy()
	STOP_PROCESSING(SSobj, src)
	affected_composers = list()
	composition_notes = list()
	return ..()

// Core mechanics
/obj/item/paper/scp012/process()
	if(world.time < composition_cooldown + 20)
		return
	composition_cooldown = world.time
	drain_nearby_sanity()

// Drain sanity from nearby targets
/obj/item/paper/scp012/proc/drain_nearby_sanity()
	var/list/stale_keys = list()
	for(var/ckey in affected_composers)
		var/list/data = affected_composers[ckey]
		var/mob/living/carbon/human/stored_mob = data["mob"]
		if(QDELETED(stored_mob) || stored_mob.stat == DEAD)
			stale_keys += ckey
	for(var/ckey in stale_keys)
		affected_composers -= ckey

	for(var/mob/living/carbon/human/H in range(sanity_drain_radius, src))
		if(H.SCP || H.stat == DEAD)
			continue
		apply_sanity_drain(H)

// Apply sanity drain effect
/obj/item/paper/scp012/proc/apply_sanity_drain(mob/living/carbon/human/target)
	if(!target)
		return

	var/ckey = target.ckey || REF(target)

	// Initialize obsession level if not present
	if(!affected_composers[ckey])
		affected_composers[ckey] = list("mob" = target, "obsession" = 0, "last_message" = 0)

	var/list/data = affected_composers[ckey]

	// Update mob ref in case of re-login
	data["mob"] = target

	// Increase obsession level
	data["obsession"] = min(max_obsession, data["obsession"] + 2)
	sanity_drained++

	// Apply sanity effects based on obsession level
	var/obsession_level = data["obsession"]
	var/last_message = data["last_message"]
	var/can_message = (world.time > last_message + message_cooldown)

	if(obsession_level >= 20)
		if(can_message)
			to_chat(target, span_warning("You feel drawn to the musical composition..."))
			data["last_message"] = world.time
		target.adjustToxLoss(1)

	if(obsession_level >= 40)
		if(can_message)
			to_chat(target, span_danger("The composition is calling to you! You must complete it!"))
			data["last_message"] = world.time
		target.adjustToxLoss(3)
		if(target.stamina)
			target.stamina.adjust(-10)

	if(obsession_level >= 60)
		if(can_message)
			to_chat(target, span_danger("The music is overwhelming! You can't think of anything else!"))
			data["last_message"] = world.time
		target.adjustToxLoss(5)
		if(target.stamina)
			target.stamina.adjust(-20)

		// Random movement towards the composition
		if(prob(30))
			step_towards(target, src)
			if(can_message)
				to_chat(target, span_danger("You move closer to the composition!"))

	if(obsession_level >= 80)
		if(can_message)
			to_chat(target, span_danger("You're completely obsessed! You must complete the composition with your blood!"))
			data["last_message"] = world.time
		target.adjustToxLoss(8)
		if(target.stamina)
			target.stamina.adjust(-30)

		// Force attempt to complete
		if(prob(50))
			attempt_completion(target)

	if(obsession_level >= 100)
		if(can_message)
			to_chat(target, span_danger("The obsession has consumed you! You will complete the composition or die trying!"))
			data["last_message"] = world.time
		target.adjustToxLoss(15)
		if(target.stamina)
			target.stamina.adjust(-50)

		// Immediate completion attempt
		attempt_completion(target)

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager && world.time >= persistence_cooldown)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-012"]
		if(instance)
			instance.add_interaction_record(target, "sanity_drain")
		persistence_cooldown = world.time + 30 SECONDS

// Attempt to complete the composition
/obj/item/paper/scp012/proc/attempt_completion(mob/living/carbon/human/composer)
	if(world.time < composition_cooldown)
		return

	composition_cooldown = world.time + composition_cooldown_time
	completion_attempts++
	composers_affected++

	visible_message(span_danger("[composer] attempts to complete SCP-012 with their blood!"))
	to_chat(composer, span_danger("You begin writing in your own blood to complete the composition!"))

	var/blood_loss = 20
	composer.adjustBruteLoss(blood_loss)
	composer.adjustToxLoss(10)
	total_blood_used += blood_loss

	// Check for composer death
	if(composer.stat == DEAD)
		composer_deaths++
		to_chat(composer, span_danger("You have died completing the composition! Your sacrifice will be remembered!"))

	var/composition_note = generate_composition_note(composer)
	composition_notes += composition_note
	completion_progress += 10

	// Check for completion (always fails - the composition can never be completed)
	if(completion_progress >= max_completion)
		complete_composition(composer)
	else
		to_chat(composer, span_notice("You add a musical phrase to the composition. Progress: [completion_progress]/[max_completion]"))

	// Update persistence system
	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-012"]
		if(instance)
			instance.add_interaction_record(composer, "completion_attempt")

// Generate a composition note
/obj/item/paper/scp012/proc/generate_composition_note(mob/living/carbon/human/composer)
	var/timestamp = time2text(world.time, "YYYY-MM-DD hh:mm:ss")

	var/list/musical_phrases = list(
		"Allegro con brio",
		"Adagio sostenuto",
		"Scherzo: Allegro vivace",
		"Finale: Allegro ma non troppo",
		"Crescendo e diminuendo",
		"Pianissimo e fortissimo",
		"Legato e staccato",
		"Ritardando e accelerando",
		"Sonata form exposition",
		"Fugue subject and answer",
		"Rondo theme development",
		"Variation on a theme",
		"Counterpoint and harmony",
		"Modulation to relative minor",
		"Recapitulation of main theme",
		"Coda with final cadence"
	)

	var/list/composition_emotions = list(
		"with passionate intensity",
		"with melancholic beauty",
		"with dramatic flair",
		"with serene contemplation",
		"with fiery determination",
		"with gentle grace",
		"with thunderous power",
		"with delicate precision"
	)

	var/phrase = pick(musical_phrases)
	var/emotion = pick(composition_emotions)

	return "[timestamp]: [composer.name] added '[phrase]' [emotion]. Progress: +10%"

// Complete the composition
/obj/item/paper/scp012/proc/complete_composition(mob/living/carbon/human/composer)
	visible_message(span_danger("[composer] collapses, blood covering their hands. The composition remains incomplete."))
	to_chat(composer, span_danger("You pour the last of your blood onto the page, but the notes blur and fade. It will never be finished..."))

	composer.adjustBruteLoss(50)
	composer.adjustToxLoss(30)

	if(composer.stat != DEAD)
		composer.emote("scream")

	completion_progress = 0

	hook_scp_combat(composer, "SCP-012", 0, 30)
	hook_player_death_near_scp(composer, "SCP-012")

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-012"]
		if(instance)
			instance.add_interaction_record(composer, "failed_completion")

// Attack behavior - attempt completion when used
/obj/item/paper/scp012/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		attempt_completion(H)
		return TRUE
	return ..()

// Admin verb to view SCP-012 persistence data
/obj/item/paper/scp012/proc/view_persistence_data()
	if(!check_rights(R_ADMIN))
		to_chat(usr, span_warning("You don't have permission to view persistence data."))
		return

	var/message = "<h2>SCP-012 Persistence Data</h2>"
	message += "<b>Containment Status:</b> [containment_status]<br>"
	message += "<b>Completion Progress:</b> [completion_progress]/[max_completion]<br>"
	message += "<b>Composers Affected:</b> [composers_affected]<br>"
	message += "<b>Completion Attempts:</b> [completion_attempts]<br>"
	message += "<b>Sanity Drained:</b> [sanity_drained]<br>"
	message += "<b>Total Blood Used:</b> [total_blood_used] units<br>"
	message += "<b>Composer Deaths:</b> [composer_deaths]<br>"
	message += "<b>Affected Composers:</b> [length(affected_composers)]<br>"
	message += "<b>Sanity Drain Radius:</b> [sanity_drain_radius] tiles<br>"

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-012"]
		if(instance)
			message += "<b>Interaction History:</b> [length(instance.interaction_history)] records<br>"

	to_chat(usr, span_notice("[message]"))

// Override examine for SCP-012
/obj/item/paper/scp012/examine(mob/user)
	. = ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, span_warning("This is SCP-012, an incomplete musical composition that drives people to complete it with their blood."))
		else
			to_chat(user, span_danger("A sheet of paper with an incomplete musical composition. You feel strangely drawn to it..."))

			// Apply initial obsession
			var/ckey = H.ckey || REF(H)
			if(!affected_composers[ckey])
				affected_composers[ckey] = list("mob" = H, "obsession" = 10, "last_message" = 0)
				to_chat(user, span_warning("The composition begins to call to you..."))

