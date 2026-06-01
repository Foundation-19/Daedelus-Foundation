SUBSYSTEM_DEF(anomalous_chemistry)
	name = "Anomalous Chemistry"
	wait = 15 SECONDS
	flags = SS_NO_FIRE

	var/list/compound_registry = list()
	var/list/synthesis_queue = list()
	var/list/test_results = list()
	var/total_compounds_synthesized = 0
	var/total_research_contributions = 0
	var/total_containment_chemicals = 0

/datum/controller/subsystem/anomalous_chemistry/proc/register_compound(compound_name, properties, scp_origin)
	compound_registry += list(list(
		"name" = compound_name,
		"properties" = properties,
		"scp_origin" = scp_origin,
		"stability" = 100,
		"researched" = FALSE,
		"time_registered" = world.time,
	))

/datum/controller/subsystem/anomalous_chemistry/proc/start_synthesis(compound_name, amount, mob/living/carbon/human/chemist)
	if(!compound_name || !chemist)
		return
	synthesis_queue += list(list(
		"compound" = compound_name,
		"amount" = amount,
		"chemist" = chemist.real_name,
		"progress" = 0,
		"stability_risk" = 0,
		"status" = "synthesizing",
		"time_started" = world.time,
	))
	to_chat(chemist, span_notice("Synthesis begun: [compound_name] x[amount]. Monitor stability carefully."))

/datum/controller/subsystem/anomalous_chemistry/proc/advance_synthesis(idx, progress_amount, stability_modifier)
	if(idx < 1 || idx > length(synthesis_queue))
		return
	var/list/S = synthesis_queue[idx]
	if(S["status"] != "synthesizing")
		return
	S["progress"] = min(100, S["progress"] + progress_amount)
	S["stability_risk"] = max(0, S["stability_risk"] + stability_modifier)
	if(S["stability_risk"] > 80)
		S["status"] = "unstable"
		if(prob(30))
			S["status"] = "failed"
			return
	if(S["progress"] >= 100)
		complete_synthesis(idx)

/datum/controller/subsystem/anomalous_chemistry/proc/complete_synthesis(idx)
	if(idx < 1 || idx > length(synthesis_queue))
		return
	var/list/S = synthesis_queue[idx]
	S["status"] = "complete"
	total_compounds_synthesized++
	if(S["stability_risk"] < 30)
		total_containment_chemicals++
		if(SSscp_research?.manager)
			SSscp_research?.manager?.adjust_research_points(10, "anomalous_chemistry:[S["chemist"]]")
		total_research_contributions++
	test_results += list(list(
		"compound" = S["compound"],
		"chemist" = S["chemist"],
		"stability" = 100 - S["stability_risk"],
		"success" = S["stability_risk"] < 30,
		"time" = world.time,
	))
	if(length(test_results) > 100)
		test_results.Cut(1, 2)

/datum/controller/subsystem/anomalous_chemistry/proc/stabilize_compound(idx, amount)
	if(idx < 1 || idx > length(synthesis_queue))
		return
	var/list/S = synthesis_queue[idx]
	S["stability_risk"] = max(0, S["stability_risk"] - amount)
	if(S["status"] == "unstable" && S["stability_risk"] < 50)
		S["status"] = "synthesizing"

/obj/item/paper/foundation/compound_analysis
	name = "Compound Analysis Report"

/obj/item/paper/foundation/synthesis_work_order
	name = "Synthesis Work Order"
