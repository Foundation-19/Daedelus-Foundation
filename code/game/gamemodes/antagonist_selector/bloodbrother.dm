/datum/antagonist_selector/bloodbrother
	restricted_jobs = list(JOB_CYBORG, JOB_AI)
	protected_jobs = list(
		JOB_SITE_DIRECTOR,
		JOB_HUMAN_RESOURCES_DIRECTOR,
		JOB_GUARD_COMMANDER,
		JOB_ENGINEERING_DIRECTOR,
		JOB_MEDICAL_DIRECTOR,
		JOB_EZ_ZONE_SUPERVISOR,
		JOB_SENIOR_EZ_GUARD,
		JOB_EZ_GUARD,
		JOB_JUNIOR_EZ_GUARD,
		JOB_RAISA_AGENT,
		JOB_LCZ_ZONE_JUNIOR_LIEUTENANT,
		JOB_SENIOR_LCZ_GUARD,
		JOB_LCZ_GUARD,
		JOB_JUNIOR_LCZ_GUARD,
		JOB_HCZ_ZONE_SENIOR_LIEUTENANT,
		JOB_SENIOR_HCZ_GUARD,
		JOB_HCZ_GUARD,
		JOB_JUNIOR_HCZ_GUARD
	)

	antag_datum = /datum/antagonist/brother
	antag_flag = ROLE_BROTHER

	/// The smallest teams can be.
	var/minimum_team_size = 2

	var/list/datum/team/brother_team/pre_brother_teams = list()

/datum/antagonist_selector/bloodbrother/Destroy()
	pre_brother_teams = null
	return ..()

/datum/antagonist_selector/bloodbrother/decide_antagonists(num_antagonists)
	var/num_teams = max(1, round(num_antagonists / minimum_team_size))

	for(var/j in 1 to num_teams)
		if(length(candidates) < minimum_team_size) //This shouldn't ever happen but, just in case
			break

		var/datum/team/brother_team/team = new
		// 10% chance to add 1 more member
		var/team_size = prob(10) ? min(minimum_team_size + 1, candidates) : minimum_team_size

		for(var/k in 1 to team_size)
			var/mob/bro = pick_n_take(candidates)
			team.add_member(bro.mind)
			select_antagonist(bro)

		pre_brother_teams += team

/datum/antagonist_selector/bloodbrother/give_antag_datums()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(/datum/antagonist/brother, team)
