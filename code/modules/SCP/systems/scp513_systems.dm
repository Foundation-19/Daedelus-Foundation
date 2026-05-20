/datum/scp513_research_system
	var/obj/item/scp513/owner
	var/last = 0
	var/gap = 30 SECONDS

/datum/scp513_research_system/New(obj/item/scp513/new_owner)
	owner = new_owner

/datum/scp513_research_system/proc/process_research()
	if(!owner)
		return
	if(world.time < last + gap)
		return
	last = world.time
	owner.SCP?.award_research(null, "acoustic_anomaly_stalker", 6)

	var/affected_count = length(owner.affected_mobs)
	if(affected_count > 0)
		owner.SCP?.award_research(null, "memetic_contagion_tracking", affected_count * 2)

/proc/can_amnestic_cure_513(mob/living/carbon/human/H, amnestic_class)
	if(!istype(H))
		return FALSE

	var/has_513 = FALSE
	for(var/datum/element/scp513_stalked/ele as anything in H.status_effects)
		if(istype(ele))
			has_513 = TRUE
			break

	if(!has_513)
		return FALSE

	if(amnestic_class == "Class-A")
		H.RemoveElement(/datum/element/scp513_stalked)
		to_chat(H, span_notice("The foggy feeling in your mind clears... and the presence is gone."))
		return TRUE

	if(amnestic_class == "Class-B")
		H.RemoveElement(/datum/element/scp513_stalked)
		to_chat(H, span_notice("Your mind goes blank for a moment. When the fog lifts, the watching presence is completely gone."))
		return TRUE

	if(amnestic_class == "Class-C" || amnestic_class == "Class-E")
		H.RemoveElement(/datum/element/scp513_stalked)
		to_chat(H, span_notice("A massive void opens in your mind. Everything about the figure, the cowbell, the watching - all of it dissolves into nothing."))
		return TRUE

	return FALSE