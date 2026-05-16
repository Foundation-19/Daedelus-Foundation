// End-of-Round SCP Report
// Generates a comprehensive summary of breaches, recontainments, casualties, and research

/datum/scp_round_report
	var/list/breach_log = list()
	var/list/recontainment_log = list()
	var/list/casualty_log = list()
	var/list/research_log = list()
	var/list/lockdown_log = list()
	var/total_breaches = 0
	var/total_recontainments = 0
	var/total_casualties = 0
	var/total_research_points = 0
	var/round_duration = 0
	var/facility_stability_peak = 100
	var/facility_stability_low = 100
	var/final_stability = 100
	var/list/story_log = list()

/datum/scp_round_report/proc/log_breach(scp_id, zone, time)
	breach_log += list(list("scp_id" = scp_id, "zone" = zone, "time" = time))
	total_breaches++

/datum/scp_round_report/proc/log_recontainment(scp_id, list/participants, time)
	var/list/names = list()
	for(var/mob/living/carbon/human/H in participants)
		names += H.name ? H.name : "Unknown"
	recontainment_log += list(list("scp_id" = scp_id, "participants" = names, "time" = time))
	total_recontainments++

/datum/scp_round_report/proc/log_casualty(victim_name, cause, zone, time)
	casualty_log += list(list("victim" = victim_name, "cause" = cause, "zone" = zone, "time" = time))
	total_casualties++

/datum/scp_round_report/proc/log_research(experiment_name, scp_id, points, researcher, time)
	research_log += list(list("experiment" = experiment_name, "scp_id" = scp_id, "points" = points, "researcher" = researcher, "time" = time))
	total_research_points += points

/datum/scp_round_report/proc/log_lockdown(reason, duration, time)
	lockdown_log += list(list("reason" = reason, "duration" = duration, "time" = time))

/datum/scp_round_report/proc/update_stability(value)
	if(value > facility_stability_peak)
		facility_stability_peak = value
	if(value < facility_stability_low)
		facility_stability_low = value
	final_stability = value

/datum/scp_round_report/proc/generate_report()
	round_duration = SSticker.round_start_time ? (world.time - SSticker.round_start_time) : 0

	var/list/report = list()
	report += "<div style='font-family: monospace; border: 2px solid #ff4444; padding: 15px; background: #1a1a1a; color: #cccccc;'>"
	report += "<h1 style='color: #ff4444; text-align: center; border-bottom: 2px solid #ff4444; padding-bottom: 10px;'>SCP FOUNDATION - SITE-53 ROUND REPORT</h1>"
	report += "<h2 style='color: #ffaa00; text-align: center;'>Classification: [get_classification()]</h2>"
	report += "<hr style='border-color: #ff4444;'>"

	report += "<h3 style='color: #44aaff;'>ROUND SUMMARY</h3>"
	report += "<table style='width: 100%; color: #cccccc;'>"
	report += "<tr><td style='color: #888;'>Duration:</td><td>[DisplayTimeText(round_duration)]</td></tr>"
	report += "<tr><td style='color: #888;'>Total Breaches:</td><td style='color: #ff4444;'>[total_breaches]</td></tr>"
	report += "<tr><td style='color: #888;'>Recontainments:</td><td style='color: #44ff44;'>[total_recontainments]</td></tr>"
	report += "<tr><td style='color: #888;'>Casualties:</td><td style='color: #ff8844;'>[total_casualties]</td></tr>"
	report += "<tr><td style='color: #888;'>Research Points Earned:</td><td style='color: #44aaff;'>[total_research_points]</td></tr>"
	report += "<tr><td style='color: #888;'>Facility Stability:</td><td style='color: [final_stability >= 70 ? "#44ff44" : final_stability >= 40 ? "#ffaa00" : "#ff4444"];'>[final_stability]% (Peak: [facility_stability_peak]%, Low: [facility_stability_low]%)</td></tr>"
	report += "<tr><td style='color: #888;'>Containment Rate:</td><td style='color: [get_containment_rate() >= 80 ? "#44ff44" : get_containment_rate() >= 50 ? "#ffaa00" : "#ff4444"];'>[get_containment_rate()]%</td></tr>"
	report += "</table>"

	if(length(breach_log))
		report += "<hr style='border-color: #ff4444;'>"
		report += "<h3 style='color: #ff4444;'>CONTAINMENT BREACHES</h3>"
		for(var/list/breach in breach_log)
			report += "<div style='margin: 5px 0; padding: 5px; border-left: 3px solid #ff4444;'>"
			report += "<span style='color: #ff4444;'>[breach["scp_id"]]</span> - Zone: <span style='color: #ffaa00;'>[breach["zone"]]</span> at [time2text(breach["time"], "hh:mm:ss")]"
			report += "</div>"

	if(length(recontainment_log))
		report += "<hr style='border-color: #ff4444;'>"
		report += "<h3 style='color: #44ff44;'>SUCCESSFUL RECONTAINMENTS</h3>"
		for(var/list/rc in recontainment_log)
			report += "<div style='margin: 5px 0; padding: 5px; border-left: 3px solid #44ff44;'>"
			report += "<span style='color: #44ff44;'>[rc["scp_id"]]</span> by [english_list(rc["participants"])] at [time2text(rc["time"], "hh:mm:ss")]"
			report += "</div>"

	if(length(casualty_log))
		report += "<hr style='border-color: #ff4444;'>"
		report += "<h3 style='color: #ff8844;'>CASUALTIES</h3>"
		for(var/list/cas in casualty_log)
			report += "<div style='margin: 5px 0; padding: 5px; border-left: 3px solid #ff8844;'>"
			report += "<span style='color: #ff8844;'>[cas["victim"]]</span> - Cause: [cas["cause"]] in [cas["zone"]] at [time2text(cas["time"], "hh:mm:ss")]"
			report += "</div>"

	if(length(research_log))
		report += "<hr style='border-color: #ff4444;'>"
		report += "<h3 style='color: #44aaff;'>RESEARCH COMPLETED</h3>"
		for(var/list/res in research_log)
			report += "<div style='margin: 5px 0; padding: 5px; border-left: 3px solid #44aaff;'>"
			report += "<span style='color: #44aaff;'>[res["experiment"]]</span> ([res["scp_id"]]) - [res["points"]] pts by [res["researcher"]] at [time2text(res["time"], "hh:mm:ss")]"
			report += "</div>"

	if(length(lockdown_log))
		report += "<hr style='border-color: #ff4444;'>"
		report += "<h3 style='color: #ffaa00;'>LOCKDOWNS ENACTED</h3>"
		for(var/list/ld in lockdown_log)
			report += "<div style='margin: 5px 0; padding: 5px; border-left: 3px solid #ffaa00;'>"
			report += "<span style='color: #ffaa00;'>[ld["reason"]]</span> at [time2text(ld["time"], "hh:mm:ss")]"
			report += "</div>"

	report += "<hr style='border-color: #ff4444;'>"
	report += "<p style='text-align: center; color: #666; font-size: 0.9em;'>SCP Foundation - Site-53 - Report ID: [GLOB.round_id || "N/A"]</p>"
	report += "</div>"

	return jointext(report, "")

/datum/scp_round_report/proc/get_classification()
	var/score = 100 - (total_casualties * 5) - (total_breaches * 10) + (total_recontainments * 5)
	score = max(0, min(100, score))
	if(score >= 80)
		return "NOMINAL - Facility Operating Within Parameters"
	if(score >= 50)
		return "ELEVATED - Minor Deviations Detected"
	if(score >= 20)
		return "CRITICAL - Significant Containment Failures"
	return "CATASTROPHIC - Total Facility Compromise"

/datum/scp_round_report/proc/get_containment_rate()
	if(total_breaches == 0)
		return 100
	var/rate = round((total_recontainments / total_breaches) * 100)
	return min(100, rate)

// Global report instance
GLOBAL_DATUM_INIT(scp_round_report, /datum/scp_round_report, new())

// Hook into round end
/proc/generate_scp_round_report()
	if(!GLOB.scp_round_report)
		GLOB.scp_round_report = new()

	for(var/mob/M in GLOB.player_list)
		if(QDELETED(M))
			continue
		if(M.client)
			var/datum/scp_round_report_ui/report_ui = new(M)
			report_ui.ui_interact(M)

// Wire into existing breach/recontainment hooks
/proc/report_breach_to_round_log(scp_id, zone)
	if(!GLOB.scp_round_report)
		return
	GLOB.scp_round_report.log_breach(scp_id, zone, world.time)

/proc/report_recontainment_to_round_log(scp_id, list/participants)
	if(!GLOB.scp_round_report)
		return
	GLOB.scp_round_report.log_recontainment(scp_id, participants, world.time)

/proc/report_casualty_to_round_log(victim_name, cause, zone)
	if(!GLOB.scp_round_report)
		return
	GLOB.scp_round_report.log_casualty(victim_name, cause, zone, world.time)

/proc/report_research_to_round_log(experiment_name, scp_id, points, researcher)
	if(!GLOB.scp_round_report)
		return
	GLOB.scp_round_report.log_research(experiment_name, scp_id, points, researcher, world.time)

/proc/report_lockdown_to_round_log(reason, duration)
	if(!GLOB.scp_round_report)
		return
	GLOB.scp_round_report.log_lockdown(reason, duration, world.time)
