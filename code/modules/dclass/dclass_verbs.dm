
/mob/living/carbon/human/proc/register_dclass_verbs()
	if(job == "D-Class" && ckey)
		if(SSdclass && SSdclass.manager)
			SSdclass.manager.register_dclass_player(src)

/mob/living/carbon/human/proc/remove_dclass_verbs()
	if(ckey && SSdclass && SSdclass.manager)
		SSdclass.manager.unregister_dclass_player(ckey)

/mob/living/carbon/human/proc/on_job_received(datum/source, datum/job/job)
	SIGNAL_HANDLER
	remove_dclass_verbs()
	if(job.title == "D-Class")
		register_dclass_verbs()

/mob/living/carbon/human/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_JOB_RECEIVED, PROC_REF(on_job_received))

/mob/living/carbon/human/Destroy()
	remove_dclass_verbs()
	return ..()
