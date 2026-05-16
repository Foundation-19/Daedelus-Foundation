/datum/preferences/proc/update_html()
	usr << output(url_encode(html_create_window()), "preferences_window.preferences_browser:update_content")

/proc/get_job_name(job_title)
	// Job titles are already human-readable via JOB_ defines
	return job_title

/proc/get_faction_class_jobs(faction_id, class_id)
	var/list/jobs = list()
	if(!faction_id || !class_id)
		return jobs

	switch(faction_id)
		if("foundation")
			switch(class_id)
				if("administrative")
					jobs += list(
						JOB_SITE_DIRECTOR,
						JOB_HUMAN_RESOURCES_DIRECTOR,
						JOB_ETHICS_COMMITTEE_LIAISON,
						JOB_COMMUNICATIONS_DIRECTOR,
					)
				if("security")
					jobs += list(
						JOB_GUARD_COMMANDER,
						JOB_EZ_ZONE_SUPERVISOR, JOB_SENIOR_EZ_GUARD, JOB_EZ_GUARD, JOB_JUNIOR_EZ_GUARD,
						JOB_LCZ_ZONE_JUNIOR_LIEUTENANT, JOB_SENIOR_LCZ_GUARD, JOB_LCZ_GUARD, JOB_JUNIOR_LCZ_GUARD,
						JOB_HCZ_ZONE_SENIOR_LIEUTENANT, JOB_SENIOR_HCZ_GUARD, JOB_HCZ_GUARD, JOB_JUNIOR_HCZ_GUARD,
						JOB_INVESTIGATIONS_AGENT, JOB_RAISA_AGENT,
					)
				if("research")
					jobs += list(
						JOB_RESEARCH_DIRECTOR,
						JOB_ASSISTANT_RESEARCH_DIRECTOR,
						JOB_SENIOR_RESEARCHER, JOB_RESEARCHER, JOB_JUNIOR_RESEARCHER,
					)
				if("medical")
					jobs += list(
						JOB_MEDICAL_DIRECTOR,
						JOB_ASSISTANT_MEDICAL_DIRECTOR,
						JOB_MEDICAL_DOCTOR, JOB_SURGEON, JOB_PARAMEDIC,
						JOB_CHEMIST, JOB_TRAINEE_DOCTOR, JOB_VIROLOGIST, JOB_PSYCHOLOGIST,
					)
				if("engineering")
					jobs += list(
						JOB_ENGINEERING_DIRECTOR,
						JOB_ASSISTANT_ENGINEERING_DIRECTOR,
						JOB_CONTAINMENT_ENGINEER, JOB_SENIOR_ENGINEER, JOB_ENGINEER, JOB_JUNIOR_ENGINEER,
						JOB_ATMOSPHERIC_TECHNICIAN, JOB_IT_TECHNICIAN,
						JOB_LOGISTICS_OFFICER, JOB_LOGISTICS_TECHNICIAN,
					)
				if("intelligence")
					jobs += list(
						JOB_INVESTIGATIONS_AGENT, JOB_RAISA_AGENT,
					)
		if("goc")
			jobs += list(JOB_GOC_REP)
		if("uiu")
			jobs += list(JOB_UIU_REP)
		if("mcd")
			jobs += list(JOB_MCD_REP)
		if("serpents_hand")
			jobs += list() // no station jobs defined; reserved for future
		if("chaos_insurgency")
			jobs += list() // no station jobs defined; reserved for future

	return jobs

/proc/get_job_description(job_title)
	var/datum/job/J = SSjob.GetJob(job_title)
	if(J)
		if(istext(J.description))
			return J.description
	return "No description available."
