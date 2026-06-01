/datum/forensic_scan_result
	var/target_name
	var/scan_tier
	var/list/fingerprints_found
	var/list/dna_found
	var/list/anomalies_found
	var/list/traces_found
	var/formatted_output

/datum/forensic_scan_result/New(atom/target, tier, datum/forensic_holder/holder)
	target_name = target.name
	scan_tier = tier
	if(holder)
		fingerprints_found = holder.fingerprints ? holder.fingerprints.Copy() : null
		dna_found = holder.dna_samples ? holder.dna_samples.Copy() : null
		anomalies_found = holder.anomaly_evidence ? deep_copy_list(holder.anomaly_evidence) : null
		traces_found = holder.trace_evidence ? deep_copy_list(holder.trace_evidence) : null

/datum/forensic_scan_result/proc/build_report()
	var/list/report = list()
	report += span_notice("<b>Forensic Scan Report — [target_name]</b>")
	switch(scan_tier)
		if(FORENSIC_SCAN_TIER_BASIC)
			if(LAZYLEN(fingerprints_found))
				report += span_notice("Trace evidence detected: Fingerprints present.")
			else if(LAZYLEN(dna_found))
				report += span_notice("Trace evidence detected: DNA present.")
			else if(LAZYLEN(anomalies_found))
				report += span_notice("Trace evidence detected: Anomalous residue present.")
			else if(LAZYLEN(traces_found))
				report += span_notice("Trace evidence detected: Material traces present.")
			else
				report += span_notice("No trace evidence detected.")
		if(FORENSIC_SCAN_TIER_ADVANCED)
			if(LAZYLEN(fingerprints_found))
				report += span_notice("Fingerprints: [length(fingerprints_found)] print(s) found.")
			else
				report += span_notice("Fingerprints: None detected.")
			if(LAZYLEN(dna_found))
				report += span_notice("DNA: [length(dna_found)] sample(s) found.")
			else
				report += span_notice("DNA: None detected.")
			if(LAZYLEN(anomalies_found))
				report += span_warning("Anomalous residue: [length(anomalies_found)] source(s) detected.")
			else
				report += span_notice("Anomalous residue: None detected.")
			if(LAZYLEN(traces_found))
				report += span_notice("Trace evidence: [length(traces_found)] trace(s) found.")
			else
				report += span_notice("Trace evidence: None detected.")
		if(FORENSIC_SCAN_TIER_EXPERIMENTAL)
			if(LAZYLEN(fingerprints_found))
				report += span_notice("<b>Fingerprints:</b>")
				for(var/key in fingerprints_found)
					report += span_notice("  - [fingerprints_found[key]] ([key])")
			else
				report += span_notice("Fingerprints: None detected.")
			if(LAZYLEN(dna_found))
				report += span_notice("<b>DNA Samples:</b>")
				for(var/enzyme in dna_found)
					report += span_notice("  - [dna_found[enzyme]] ([enzyme])")
			else
				report += span_notice("DNA: None detected.")
			if(LAZYLEN(anomalies_found))
				report += span_warning("<b>Anomalous Residue:</b>")
				for(var/list/anomaly in anomalies_found)
					report += span_warning("  - Type: [anomaly["type"]] | Strength: [anomaly["strength"]] | Source: [anomaly["source_id"]]")
			else
				report += span_notice("Anomalous residue: None detected.")
			if(LAZYLEN(traces_found))
				report += span_notice("<b>Trace Evidence:</b>")
				for(var/list/trace in traces_found)
					report += span_notice("  - Type: [trace["type"]] | Details: [trace["details"]]")
			else
				report += span_notice("Trace evidence: None detected.")
	return report

/datum/forensic_scan_result/proc/format_output()
	var/list/report = build_report()
	formatted_output = jointext(report, "\n")
	return formatted_output
