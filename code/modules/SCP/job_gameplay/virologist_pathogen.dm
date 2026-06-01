#define PATHOGEN_BSL1 1
#define PATHOGEN_BSL2 2
#define PATHOGEN_BSL3 3
#define PATHOGEN_BSL4 4

SUBSYSTEM_DEF(foundation_pathogens)
	name = "Foundation Pathogens"
	wait = 30 SECONDS
	flags = SS_NO_FIRE

	var/list/active_infections = list()
	var/list/research_projects = list()
	var/list/countermeasures = list()
	var/list/infection_log = list()
	var/total_infections_tracked = 0
	var/total_countermeasures_developed = 0
	var/total_research_points = 0

/datum/controller/subsystem/foundation_pathogens/proc/register_infection(mob/living/carbon/human/host, pathogen_type, bsl_level)
	if(!host)
		return
	total_infections_tracked++
	active_infections += list(list(
		"host_name" = host.real_name,
		"host_job" = host.job || "Unknown",
		"host_ref" = REF(host),
		"pathogen_type" = pathogen_type,
		"bsl" = bsl_level,
		"progress" = 0,
		"countermeasure" = "",
		"treated" = FALSE,
		"time_detected" = world.time,
	))
	if(bsl_level >= PATHOGEN_BSL3)
		priority_announce("BSL-[bsl_level] pathogen detected: [pathogen_type] in [get_area_name(host, TRUE) || "unknown"]. Virology staff respond immediately.", "BIOHAZARD ALERT", null, ANNOUNCER_ALERT)
	if(SSraisa)
		var/datum/intel_report/R = new(host, "biohazard", host.real_name, host.job, "CONFIDENTIAL", "BSL-[bsl_level] pathogen [pathogen_type] detected in [host.real_name].", "Quarantine and countermeasure development recommended.")
		SSraisa.file_report(R)

/datum/controller/subsystem/foundation_pathogens/proc/start_research_project(pathogen_type, mob/living/carbon/human/researcher)
	if(!pathogen_type || !researcher)
		return
	var/project_id = "pathogen_[world.time]_[rand(100,999)]"
	research_projects += list(list(
		"project_id" = project_id,
		"pathogen" = pathogen_type,
		"researcher" = researcher.real_name,
		"progress" = 0,
		"stage" = "sample_collection",
		"points_contributed" = 0,
		"time_started" = world.time,
	))
	to_chat(researcher, span_notice("Pathogen research project started: [pathogen_type]. Begin by collecting samples from infected subjects."))
	return project_id

/datum/controller/subsystem/foundation_pathogens/proc/contribute_research(project_id, amount, mob/living/carbon/human/contributor)
	for(var/list/P in research_projects)
		if(P["project_id"] == project_id)
			P["progress"] = min(100, P["progress"] + amount)
			P["points_contributed"] += amount
			total_research_points += amount
			if(P["progress"] >= 25 && P["stage"] == "sample_collection")
				P["stage"] = "analysis"
				to_chat(contributor, span_notice("Sample analysis phase begun for [P["pathogen"]]."))
			if(P["progress"] >= 50 && P["stage"] == "analysis")
				P["stage"] = "countermeasure_dev"
				to_chat(contributor, span_notice("Countermeasure development phase begun for [P["pathogen"]]."))
			if(P["progress"] >= 100 && P["stage"] == "countermeasure_dev")
				P["stage"] = "complete"
				complete_countermeasure(P["pathogen"], contributor)
			return TRUE
	return FALSE

/datum/controller/subsystem/foundation_pathogens/proc/complete_countermeasure(pathogen_type, mob/living/carbon/human/developer)
	total_countermeasures_developed++
	countermeasures += list(list(
		"pathogen" = pathogen_type,
		"developer" = developer.real_name,
		"effective" = TRUE,
		"time_developed" = world.time,
	))
	priority_announce("Countermeasure developed for [pathogen_type] by [developer.real_name]. Distribution to medical staff authorized.", "VIROLOGY BREAKTHROUGH", null, ANNOUNCER_DEFAULT)
	if(SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(50, "pathogen_countermeasure:[developer.ckey]")
	if(SSfoundation_budget)
		SSfoundation_budget.adjust_department_budget("medical", 100)
	for(var/list/I in active_infections)
		if(I["pathogen_type"] == pathogen_type && !I["treated"])
			I["countermeasure"] = "developed"
	log_pathogen_event("Countermeasure developed: [pathogen_type]", developer.real_name)

/datum/controller/subsystem/foundation_pathogens/proc/treat_infection(host_name, countermeasure_pathogen)
	for(var/list/I in active_infections)
		if(I["host_name"] == host_name && !I["treated"])
			if(countermeasure_pathogen == I["pathogen_type"])
				I["treated"] = TRUE
				return "effective"
			else
				return "ineffective"
	return "not_found"

/datum/controller/subsystem/foundation_pathogens/proc/log_pathogen_event(event_text, source)
	infection_log += list(list("event" = event_text, "source" = source, "time" = world.time))
	if(length(infection_log) > 100)
		infection_log.Cut(1, 2)

/obj/item/paper/foundation/pathogen_analysis_report
	name = "Pathogen Analysis Report"

/obj/item/paper/foundation/countermeasure_documentation
	name = "Countermeasure Documentation"
