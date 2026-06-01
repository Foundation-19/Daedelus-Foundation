/datum/forensic_holder
	var/list/fingerprints
	var/list/dna_samples
	var/list/anomaly_evidence
	var/list/trace_evidence
	var/atom/owner

/datum/forensic_holder/New(atom/owner)
	src.owner = owner

/datum/forensic_holder/Destroy()
	owner = null
	return ..()

/datum/forensic_holder/proc/add_fingerprint(mob/M)
	if(!isliving(M) || !M.ckey)
		return
	LAZYINITLIST(fingerprints)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		fingerprints[H.ckey] = H.real_name
	else if(iscarbon(M) && !ishuman(M))
		fingerprints["unknown_carbon_[M.ckey]"] = "unknown_carbon"

/datum/forensic_holder/proc/add_dna(mob/living/carbon/M)
	if(!istype(M) || !M.dna)
		return
	LAZYINITLIST(dna_samples)
	dna_samples[M.dna.unique_enzymes] = M.real_name

/datum/forensic_holder/proc/add_anomaly(evidence_type, strength, source_id)
	LAZYINITLIST(anomaly_evidence)
	anomaly_evidence += list(list("type" = evidence_type, "strength" = strength, "source_id" = source_id, "time" = world.time))

/datum/forensic_holder/proc/add_trace(evidence_type, details)
	LAZYINITLIST(trace_evidence)
	trace_evidence += list(list("type" = evidence_type, "details" = details, "time" = world.time))

/datum/forensic_holder/proc/clean()
	LAZYNULL(fingerprints)
	LAZYNULL(dna_samples)
	LAZYNULL(anomaly_evidence)
	LAZYNULL(trace_evidence)

/atom/var/datum/forensic_holder/forensic_holder

/atom/proc/ensure_forensic_holder()
	if(!forensic_holder)
		forensic_holder = new(src)
	return forensic_holder

/atom/proc/add_forensic_fingerprint(mob/M)
	ensure_forensic_holder()
	forensic_holder.add_fingerprint(M)

/atom/proc/add_forensic_dna(mob/living/carbon/M)
	ensure_forensic_holder()
	forensic_holder.add_dna(M)

/atom/proc/add_forensic_anomaly(evidence_type, strength, source_id)
	ensure_forensic_holder()
	forensic_holder.add_anomaly(evidence_type, strength, source_id)

/atom/proc/clean_forensic()
	if(forensic_holder)
		forensic_holder.clean()
