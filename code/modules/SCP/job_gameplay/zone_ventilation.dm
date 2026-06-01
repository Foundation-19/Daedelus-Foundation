#define VENT_ZONE_LCZ 1
#define VENT_ZONE_HCZ 2
#define VENT_ZONE_EZ 3
#define VENT_ZONE_DCLASS 4

SUBSYSTEM_DEF(zone_ventilation)
	name = "Zone Ventilation"
	wait = 25 SECONDS
	flags = SS_NO_FIRE

	var/list/ventilation_zones = list()
	var/list/air_quality_alerts = list()
	var/total_purge_cycles = 0
	var/total_filters_replaced = 0
	var/total_emergency_vents = 0

/datum/controller/subsystem/zone_ventilation/Initialize(time)
	. = ..()
	initialize_zones()

/datum/controller/subsystem/zone_ventilation/proc/initialize_zones()
	ventilation_zones = list(
		list("name" = "Light Containment", "zone" = VENT_ZONE_LCZ, "air_quality" = 100, "contamination" = 0, "filter_integrity" = 100, "purge_active" = FALSE, "emergency_vent" = FALSE),
		list("name" = "Heavy Containment", "zone" = VENT_ZONE_HCZ, "air_quality" = 100, "contamination" = 0, "filter_integrity" = 100, "purge_active" = FALSE, "emergency_vent" = FALSE),
		list("name" = "Entrance Zone", "zone" = VENT_ZONE_EZ, "air_quality" = 100, "contamination" = 0, "filter_integrity" = 100, "purge_active" = FALSE, "emergency_vent" = FALSE),
		list("name" = "D-Class Block", "zone" = VENT_ZONE_DCLASS, "air_quality" = 95, "contamination" = 5, "filter_integrity" = 90, "purge_active" = FALSE, "emergency_vent" = FALSE),
	)

/datum/controller/subsystem/zone_ventilation/fire()
	for(var/list/Z in ventilation_zones)
		Z["filter_integrity"] = max(0, Z["filter_integrity"] - 0.1)
		if(Z["filter_integrity"] < 50)
			Z["air_quality"] = max(0, Z["air_quality"] - 1)
			Z["contamination"] = min(100, Z["contamination"] + 0.5)
		if(Z["purge_active"])
			Z["contamination"] = max(0, Z["contamination"] - 5)
			Z["air_quality"] = min(100, Z["air_quality"] + 2)
			if(Z["contamination"] <= 0)
				Z["purge_active"] = FALSE
		if(Z["contamination"] > 30 && !Z["purge_active"])
			if(prob(5))
				air_quality_alerts += list(list("zone" = Z["name"], "contamination" = Z["contamination"], "time" = world.time))
				if(length(air_quality_alerts) > 50)
					air_quality_alerts.Cut(1, 2)
		if(Z["emergency_vent"])
			Z["contamination"] = max(0, Z["contamination"] - 15)
			Z["air_quality"] = min(100, Z["air_quality"] + 5)

/datum/controller/subsystem/zone_ventilation/proc/start_purge(zone_id)
	for(var/list/Z in ventilation_zones)
		if(Z["zone"] == zone_id)
			Z["purge_active"] = TRUE
			total_purge_cycles++
			return TRUE
	return FALSE

/datum/controller/subsystem/zone_ventilation/proc/emergency_vent(zone_id)
	for(var/list/Z in ventilation_zones)
		if(Z["zone"] == zone_id)
			Z["emergency_vent"] = TRUE
			Z["purge_active"] = TRUE
			total_emergency_vents++
			priority_announce("Emergency ventilation activated in [Z["name"]]. All personnel should don breathing apparatus.", "VENTILATION ALERT", null, ANNOUNCER_ALERT)
			addtimer(CALLBACK(src, PROC_REF(end_emergency_vent), zone_id), 30 SECONDS)
			return TRUE
	return FALSE

/datum/controller/subsystem/zone_ventilation/proc/end_emergency_vent(zone_id)
	for(var/list/Z in ventilation_zones)
		if(Z["zone"] == zone_id)
			Z["emergency_vent"] = FALSE
			return

/datum/controller/subsystem/zone_ventilation/proc/replace_filter(zone_id, amount)
	for(var/list/Z in ventilation_zones)
		if(Z["zone"] == zone_id)
			Z["filter_integrity"] = min(100, Z["filter_integrity"] + amount)
			Z["air_quality"] = min(100, Z["air_quality"] + amount / 2)
			total_filters_replaced++
			return TRUE
	return FALSE

/datum/controller/subsystem/zone_ventilation/proc/report_contamination(zone_id, amount, source)
	for(var/list/Z in ventilation_zones)
		if(Z["zone"] == zone_id)
			Z["contamination"] = min(100, Z["contamination"] + amount)
			Z["air_quality"] = max(0, Z["air_quality"] - amount)
			if(Z["contamination"] > 50)
				air_quality_alerts += list(list("zone" = Z["name"], "contamination" = Z["contamination"], "source" = source, "time" = world.time))
			return TRUE
	return FALSE
