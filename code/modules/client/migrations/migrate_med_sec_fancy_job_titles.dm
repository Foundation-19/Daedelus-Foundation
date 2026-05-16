/datum/preferences/proc/migrate_med_sec_fancy_job_titles()
	var/list/migrate_jobs = list(
		"Head of Security" = JOB_GUARD_COMMANDER,
		"Detective" = JOB_INVESTIGATIONS_AGENT,
		"Medical Doctor" = JOB_MEDICAL_DOCTOR,
		"Cargo Technician" = JOB_LOGISTICS_TECHNICIAN,
	)

	var/list/job_prefs = read_preference(/datum/preference/blob/job_priority)
	for(var/job in job_prefs)
		if(job in migrate_jobs)
			var/old_value = job_prefs[job]
			job_prefs -= job
			job_prefs[migrate_jobs[job]] = old_value
	var/datum/preference/blob/job_priority/actual_datum = GLOB.preference_entries[/datum/preference/blob/job_priority]
	write_preference(/datum/preference/blob/job_priority, actual_datum.serialize(job_prefs))
