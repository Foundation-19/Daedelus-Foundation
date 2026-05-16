// Round Report TGUI Backend
// Opens the SCP round report as a terminal-styled TGUI window

/datum/scp_round_report_ui
	var/mob/recipient
	var/datum/scp_round_report/report

/datum/scp_round_report_ui/New(mob/recipient)
	src.recipient = recipient
	src.report = GLOB.scp_round_report || new()

/datum/scp_round_report_ui/ui_state(mob/user)
	return GLOB.default_state

/datum/scp_round_report_ui/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPRoundReport", "Site-53 Round Report")
		ui.open()

/datum/scp_round_report_ui/ui_data(mob/user)
	var/list/data = list()

	data["round_id"] = GLOB.round_id || "N/A"
	data["round_duration"] = report ? DisplayTimeText(report.round_duration) : "N/A"
	data["total_breaches"] = report ? report.total_breaches : 0
	data["total_recontainments"] = report ? report.total_recontainments : 0
	data["total_casualties"] = report ? report.total_casualties : 0
	data["total_research_points"] = report ? report.total_research_points : 0
	data["final_stability"] = report ? report.final_stability : 100
	data["facility_stability_peak"] = report ? report.facility_stability_peak : 100
	data["facility_stability_low"] = report ? report.facility_stability_low : 100
	data["classification"] = report ? report.get_classification() : "UNKNOWN"
	data["containment_rate"] = report ? report.get_containment_rate() : 100
	data["breach_log"] = report ? report.breach_log : list()
	data["recontainment_log"] = report ? report.recontainment_log : list()
	data["casualty_log"] = report ? report.casualty_log : list()
	data["research_log"] = report ? report.research_log : list()
	data["lockdown_log"] = report ? report.lockdown_log : list()

	var/datum/facility_damage_tracker/tracker = GLOB.facility_damage_tracker
	data["damage_rating"] = tracker ? tracker.get_damage_rating() : "INTACT"
	data["damage_score"] = tracker ? tracker.get_damage_score() : 0
	data["walls_destroyed"] = tracker ? tracker.total_walls_destroyed : 0
	data["floors_destroyed"] = tracker ? tracker.total_floors_destroyed : 0
	data["windows_broken"] = tracker ? tracker.total_windows_broken : 0
	data["doors_destroyed"] = tracker ? tracker.total_doors_destroyed : 0
	data["machines_destroyed"] = tracker ? tracker.total_machines_destroyed : 0
	data["worst_areas"] = tracker ? tracker.get_worst_areas() : list()

	return data

/datum/scp_round_report_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("close")
			qdel(src)
			return
