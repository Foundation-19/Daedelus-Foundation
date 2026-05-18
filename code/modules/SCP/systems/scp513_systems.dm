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

	var/total_phase = 0
	for(var/mob/living/carbon/human/H in owner.affected_mobs)
		if(QDELETED(H))
			continue
		var/datum/element/scp513_stalked/ele = H.scp513_stalked_ref
		if(ele)
			total_phase += ele.phase

	if(total_phase > 0)
		owner.SCP?.award_research(null, "stalker_progression_data", total_phase * 3)

/proc/can_amnestic_cure_513(mob/living/carbon/human/H, amnestic_class)
	if(!istype(H))
		return FALSE
	var/datum/element/scp513_stalked/ele = H.scp513_stalked_ref
	if(!ele)
		return FALSE

	if(amnestic_class == "Class-A")
		if(ele.phase <= SCP513_PHASE_WHISPER)
			H.RemoveElement(/datum/element/scp513_stalked)
			to_chat(H, span_notice("The foggy feeling in your mind clears... and the presence is gone. You can't quite remember what you were so worried about."))
			return TRUE
		else
			to_chat(H, span_warning("The amnestic dulls the presence briefly, but it returns. Class-A is not strong enough."))
			ele.stalk_duration = max(0, ele.stalk_duration - 600)
			if(H.sanity)
				H.sanity.adjust_sanity(10, "amnestic_partial")
			return FALSE

	if(amnestic_class == "Class-B")
		if(ele.phase <= SCP513_PHASE_STALK)
			H.RemoveElement(/datum/element/scp513_stalked)
			to_chat(H, span_notice("Your mind goes blank for a moment. When the fog lifts, the watching presence is completely gone."))
			return TRUE
		else
			to_chat(H, span_warning("The presence fights against the amnestic! It recedes significantly but isn't fully banished."))
			ele.phase = max(SCP513_PHASE_WHISPER, ele.phase - 1)
			ele.stalk_duration = max(0, ele.stalk_duration - 1800)
			if(H.sanity)
				H.sanity.adjust_sanity(25, "amnestic_partial")
			return FALSE

	if(amnestic_class == "Class-C")
		H.RemoveElement(/datum/element/scp513_stalked)
		to_chat(H, span_notice("A massive void opens in your mind. Everything about the figure, the cowbell, the watching — all of it dissolves into nothing. The presence is gone."))
		return TRUE

	if(amnestic_class == "Class-E")
		H.RemoveElement(/datum/element/scp513_stalked)
		to_chat(H, span_notice("Your entire memory is wiped clean. The presence, whatever it was, no longer exists in your mind. You don't even remember being afraid."))
		return TRUE

	return FALSE
