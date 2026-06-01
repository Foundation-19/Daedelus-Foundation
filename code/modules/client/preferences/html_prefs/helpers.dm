/datum/preferences/proc/update_html()
	usr << output(url_encode(html_create_window()), "preferences_window.preferences_browser:update_content")

/proc/get_job_name(job_title)
	// Job titles are already human-readable via JOB_ defines
	return job_title

/proc/get_faction_class_jobs(faction_id, class_id, player_rank = 0, player_class_id = "")
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
			jobs += list()
		if("chaos_insurgency")
			jobs += list()

	if (player_rank <= 0 || !player_class_id || player_class_id != class_id)
		return jobs

	var/list/filtered = list()
	for (var/job in jobs)
		var/required = get_required_rank_for_job(class_id, job)
		if (player_rank >= required)
			filtered += job
	return filtered

/proc/get_required_rank_for_job(class_id, job_title)
	switch(class_id)
		if("administrative")
			switch(job_title)
				if(JOB_COMMUNICATIONS_DIRECTOR)
					return 0
				if(JOB_ETHICS_COMMITTEE_LIAISON)
					return 1
				if(JOB_HUMAN_RESOURCES_DIRECTOR)
					return 3
				if(JOB_SITE_DIRECTOR)
					return 5
		if("security")
			switch(job_title)
				if(JOB_JUNIOR_LCZ_GUARD, JOB_JUNIOR_HCZ_GUARD, JOB_JUNIOR_EZ_GUARD)
					return 0
				if(JOB_LCZ_GUARD, JOB_HCZ_GUARD, JOB_EZ_GUARD)
					return 1
				if(JOB_SENIOR_LCZ_GUARD, JOB_SENIOR_HCZ_GUARD, JOB_SENIOR_EZ_GUARD)
					return 2
				if(JOB_LCZ_ZONE_JUNIOR_LIEUTENANT, JOB_HCZ_ZONE_SENIOR_LIEUTENANT, JOB_EZ_ZONE_SUPERVISOR, JOB_INVESTIGATIONS_AGENT)
					return 3
				if(JOB_GUARD_COMMANDER, JOB_RAISA_AGENT)
					return 4
		if("research")
			switch(job_title)
				if(JOB_JUNIOR_RESEARCHER)
					return 0
				if(JOB_RESEARCHER)
					return 1
				if(JOB_SENIOR_RESEARCHER)
					return 2
				if(JOB_ASSISTANT_RESEARCH_DIRECTOR)
					return 3
				if(JOB_RESEARCH_DIRECTOR)
					return 5
		if("medical")
			switch(job_title)
				if(JOB_TRAINEE_DOCTOR)
					return 0
				if(JOB_CHEMIST, JOB_PSYCHOLOGIST)
					return 1
				if(JOB_MEDICAL_DOCTOR, JOB_PARAMEDIC)
					return 2
				if(JOB_SURGEON, JOB_VIROLOGIST)
					return 3
				if(JOB_ASSISTANT_MEDICAL_DIRECTOR)
					return 4
				if(JOB_MEDICAL_DIRECTOR)
					return 5
		if("engineering")
			switch(job_title)
				if(JOB_JUNIOR_ENGINEER, JOB_LOGISTICS_TECHNICIAN)
					return 0
				if(JOB_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_IT_TECHNICIAN)
					return 1
				if(JOB_SENIOR_ENGINEER, JOB_CONTAINMENT_ENGINEER, JOB_LOGISTICS_OFFICER)
					return 2
				if(JOB_ASSISTANT_ENGINEERING_DIRECTOR)
					return 4
				if(JOB_ENGINEERING_DIRECTOR)
					return 5
		if("intelligence")
			switch(job_title)
				if(JOB_INVESTIGATIONS_AGENT)
					return 0
				if(JOB_RAISA_AGENT)
					return 3
	return 0

/proc/get_job_description(job_title)
	var/datum/job/J = SSjob.GetJob(job_title)
	if(J)
		if(istext(J.description))
			return J.description
	return "No description available."
