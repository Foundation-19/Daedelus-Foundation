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
