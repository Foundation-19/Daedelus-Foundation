/obj/structure/scp151
	name = "painting"
	desc = "A painting depicting a rising wave."
	icon = 'icons/scp/scpstructures(32x32).dmi'

	icon_state = "great_wave"
	anchored = TRUE
	density = TRUE

	//Config

	///How much oxygen damage we do per tick
	var/oxy_damage = 3
	///Message cooldown
	var/message_cooldown = 15 SECONDS
	///How much water is ingested per tick
	var/water_ingest = 2

	///OxyLoss threshold to start hallucinations
	var/hallucination_threshold = 20
	///How often hallucinations occur
	var/hallucination_frequency = 10 SECONDS
	///OxyLoss threshold to start movement impairment
	var/slowdown_threshold = 15
	///OxyLoss threshold to apply panic trait
	var/panic_threshold = 30
	///Unique source for the panic trait
	var/panic_trait_source = TRAIT_SCP151_PANIC
	///To keep track of active hallucinations for cleanup
	var/list/active_hallucinations = list()
	///To manage the slowdown effect
	var/datum/movespeed_modifier/scp151_slowdown_modifier = null
	///To keep track of mobs with active panic trait signals
	var/list/mobs_with_panic_signals = list()

/obj/structure/scp151/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src) // Register for processing

	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"painting", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_EUCLID, //Obj Class
		"151", //Numerical Designation
		SCP_MEMETIC
	)

	SCP.memeticFlags = MVISUAL|MPERSISTENT|MSYNCED|MINSPECT
	SCP.memetic_proc = TYPE_PROC_REF(/obj/structure/scp151, effect)
	SCP.compInit()

// Mechanics

/obj/structure/scp151/proc/effect(mob/living/carbon/human/H)
	H.apply_damage(oxy_damage, OXY)
	SEND_SIGNAL(H, COMSIG_SCP151_EFFECT_APPLIED, src)

	var/obj/item/organ/stomach/stomach_organ = H.getorganslot(ORGAN_SLOT_STOMACH)
	if(!stomach_organ)
		return

	stomach_organ.reagents.add_reagent(/datum/reagent/water, water_ingest)

	if((H.getOxyLoss() > 10))
		if((stomach_organ.reagents.maximum_volume - stomach_organ.reagents.total_volume) <= 5)
			H.vomit()
		else if(prob(H.getOxyLoss() + 15))
			H.emote("cough")
	else if(prob(10) && ((world.time - H.humanStageHandler.getStage("151_message_cooldown")) > message_cooldown))
		to_chat(H, span_notice(pick("The taste of seawater permeates your mouth...", "Your lungs feel like they are filling with water...")))
		H.humanStageHandler.setStage("151_message_cooldown", world.time)

	if(prob(H.getOxyLoss() + 30) && (H.getOxyLoss() > 25) && ((world.time - H.humanStageHandler.getStage("151_message_cooldown")) > message_cooldown))
		to_chat(H, span_warning(pick("Your lungs feel like they are filled with water!", "You try to breath but your lungs are filled with water!", "You cannot breath!")))
		H.humanStageHandler.setStage("151_message_cooldown", world.time)

	// Enhanced Hallucinations
	if(H.getOxyLoss() > hallucination_threshold && (world.time - H.humanStageHandler.getStage("151_hallucination_cooldown")) > hallucination_frequency)
		var/hal_type = pick_weight(GLOB.hallucination_list_water_related)
		var/datum/hallucination/new_hal = new hal_type(H, TRUE)
		active_hallucinations += new_hal
		H.humanStageHandler.setStage("151_hallucination_cooldown", world.time)

	// Progressive Movement Impairment
	if(H.getOxyLoss() > slowdown_threshold)
		var/slowdown_amount = round(H.getOxyLoss() / 5) // Scale slowdown with oxy loss
		if(!scp151_slowdown_modifier)
			scp151_slowdown_modifier = H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/scp151_slowdown, slowdown = slowdown_amount, update = TRUE)
		else
			scp151_slowdown_modifier.slowdown = slowdown_amount
			H.update_movespeed(TRUE)
	else if(scp151_slowdown_modifier)
		H.remove_movespeed_modifier(scp151_slowdown_modifier)
		QDEL_NULL(scp151_slowdown_modifier)

	// Psychological Panic
	if(H.getOxyLoss() > panic_threshold)
		if(!HAS_TRAIT(H, TRAIT_SCP151_PANIC))
			ADD_TRAIT(H, TRAIT_SCP151_PANIC, panic_trait_source)
			RegisterSignal(H, SIGNAL_ADDTRAIT(TRAIT_SCP151_PANIC), PROC_REF(on_mob_panic_trait_gain))
			RegisterSignal(H, SIGNAL_REMOVETRAIT(TRAIT_SCP151_PANIC), PROC_REF(on_mob_panic_trait_loss))
			mobs_with_panic_signals += H
	else if(H.getOxyLoss() <= panic_threshold)
		if(HAS_TRAIT(H, TRAIT_SCP151_PANIC))
			REMOVE_TRAIT(H, TRAIT_SCP151_PANIC, panic_trait_source)
			UnregisterSignal(H, SIGNAL_ADDTRAIT(TRAIT_SCP151_PANIC))
			UnregisterSignal(H, SIGNAL_REMOVETRAIT(TRAIT_SCP151_PANIC))
			mobs_with_panic_signals -= H

/obj/structure/scp151/Destroy()
	// Cleanup active hallucinations and movespeed modifier when SCP-151 is destroyed
	for(var/datum/hallucination/hal in active_hallucinations)
		QDEL_NULL(hal)
	active_hallucinations = list()

	if(scp151_slowdown_modifier)
		// Need to find all mobs that might have this modifier and remove it
		for(var/mob/living/carbon/H in GLOB.alive_mob_list) // Iterate through all living mobs
			if(H.has_movespeed_modifier(scp151_slowdown_modifier))
				H.remove_movespeed_modifier(scp151_slowdown_modifier)
		QDEL_NULL(scp151_slowdown_modifier)

	// Cleanup panic trait signals
	for(var/mob/living/carbon/human/H in mobs_with_panic_signals)
		if(H) // Ensure mob still exists
			UnregisterSignal(H, SIGNAL_ADDTRAIT(TRAIT_SCP151_PANIC))
			UnregisterSignal(H, SIGNAL_REMOVETRAIT(TRAIT_SCP151_PANIC))
	mobs_with_panic_signals = list() // Clear the list

	STOP_PROCESSING(SSobj, src) // Unregister from processing
	. = ..()

// Define the new movespeed modifier
/datum/movespeed_modifier/scp151_slowdown
	variable = TRUE
	id = "scp151_slowdown"
	priority = 10 // A moderate priority to ensure it applies over most base speeds
	slowdown = 0 // This will be dynamically set based on oxy loss

// Process proc for periodic updates
// TD; The Memetic handeler should really be moved to signal components, but that's out of scope for this.
/obj/structure/scp151/process(delta_Time)
	if(SCP?.meme_comp) // Check if meme_comp exists
		SCP.meme_comp.check_viewers()
		SCP.meme_comp.activate_memetic_effects()

// Signal handler procs for TRAIT_SCP151_PANIC
/obj/structure/scp151/proc/on_mob_panic_trait_gain(mob/living/carbon/human/H, signal_name, trait_string)
	SIGNAL_HANDLER
	if(trait_string == TRAIT_SCP151_PANIC)
		to_chat(H, span_warning("You feel an overwhelming sense of panic! The walls are closing in!"))
		addtimer(CALLBACK(H, TYPE_PROC_REF(/mob, emote), "scream"), 0) // Call emote in a separate thread to avoid sleeping the signal handler
		H.adjust_timed_status_effect(30 SECONDS, /datum/status_effect/jitter)

/obj/structure/scp151/proc/on_mob_panic_trait_loss(mob/living/carbon/human/H, signal_name, trait_string)
	SIGNAL_HANDLER
	if(trait_string == TRAIT_SCP151_PANIC)
		to_chat(H, span_notice("The suffocating panic begins to subside."))
		H.adjust_timed_status_effect(-30 SECONDS, /datum/status_effect/jitter)

/obj/structure/scp151/proc/on_drowning_effect(mob/living/carbon/human/victim)
	if(!victim)
		return
	hook_scp_combat(victim, "SCP-151", 0, oxy_damage)
