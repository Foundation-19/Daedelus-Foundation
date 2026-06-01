#define CONTAINMENT_INTEGRITY_CRITICAL 25
#define CONTAINMENT_INTEGRITY_LOW 50
#define CONTAINMENT_INTEGRITY_MODERATE 75
#define CONTAINMENT_INTEGRITY_OPTIMAL 100

#define MAINT_NONE 0
#define MAINT_SCHEDULED 1
#define MAINT_IN_PROGRESS 2
#define MAINT_COMPLETE 3
#define MAINT_OVERDUE 4

SUBSYSTEM_DEF(containment_integrity)
	name = "Containment Integrity"
	init_order = INIT_ORDER_DEFAULT
	wait = 30 SECONDS

	var/list/containment_zones = list()
	var/list/maintenance_tasks = list()
	var/list/integrity_log = list()
	var/overall_integrity = 100
	var/total_breach_repairs = 0
	var/total_maintenance_done = 0
	var/overdue_tasks = 0

/datum/controller/subsystem/containment_integrity/Initialize(time)
	. = ..()
	build_containment_zones()

/datum/controller/subsystem/containment_integrity/proc/build_containment_zones()
	containment_zones = list()
	var/list/zone_defs = list(
		list("name" = "SCP-173 Containment", "area" = /area/scp/lcz/safe_containment, "base_integrity" = 100, "decay_rate" = 0.5),
		list("name" = "SCP-049 Containment", "area" = /area/scp/lcz/euclid_containment, "base_integrity" = 100, "decay_rate" = 0.4),
		list("name" = "SCP-079 Server Room", "area" = /area/scp/hcz/server_room, "base_integrity" = 100, "decay_rate" = 0.3),
		list("name" = "SCP-106 Containment", "area" = /area/scp/hcz/keter_containment, "base_integrity" = 100, "decay_rate" = 0.6),
		list("name" = "SCP-096 Containment", "area" = /area/scp/hcz/euclid_containment, "base_integrity" = 100, "decay_rate" = 0.4),
		list("name" = "LCZ Corridor Alpha", "area" = /area/scp/lcz, "base_integrity" = 100, "decay_rate" = 0.2),
		list("name" = "HCZ Corridor Bravo", "area" = /area/scp/hcz, "base_integrity" = 100, "decay_rate" = 0.2),
	)
	for(var/list/Z in zone_defs)
		containment_zones += list(list(
			"name" = Z["name"],
			"area_type" = Z["area"],
			"integrity" = Z["base_integrity"],
			"decay_rate" = Z["decay_rate"],
			"last_maintained" = world.time,
			"maintenance_status" = MAINT_NONE,
			"breached" = FALSE,
			"reinforced" = FALSE,
		))

/datum/controller/subsystem/containment_integrity/fire()
	var/total_integrity = 0
	var/zone_count = 0
	for(var/list/Z in containment_zones)
		if(Z["breached"])
			total_integrity += 0
			zone_count++
			continue
		var/decay = Z["decay_rate"]
		if(SSscp_persistence?.manager?.active_breaches > 0)
			decay *= 2
		Z["integrity"] = max(0, Z["integrity"] - decay)
		if(Z["integrity"] <= CONTAINMENT_INTEGRITY_CRITICAL && !Z["breached"])
			Z["breached"] = TRUE
			priority_announce("CONTAINMENT INTEGRITY CRITICAL: [Z["name"]] integrity at [round(Z["integrity"])]%. Immediate maintenance required.", "CONTAINMENT ALERT", null, ANNOUNCER_ALERT)
			if(SSfoundation_comms)
				SSfoundation_comms.register_threat("Structural Failure: [Z["name"]]", "structural_failure", THREAT_LEVEL_ORANGE, Z["name"], "Containment integrity failure in [Z["name"]]. Immediate engineering response required.")
				SSfoundation_comms.create_dispatch(null, DISPATCH_ENGINEERING, "Structural failure in [Z["name"]]. Engineering teams respond immediately for repairs.", 2)
			if(SSanomalous_investigations)
				SSanomalous_investigations.open_case("Structural Failure: [Z["name"]]", "Automatic case opened due to containment integrity failure in [Z["name"]].")
		if(Z["integrity"] <= CONTAINMENT_INTEGRITY_LOW)
			if(prob(10))
				generate_maintenance_task(Z["name"], "low_integrity")
		if(Z["integrity"] > CONTAINMENT_INTEGRITY_MODERATE)
			if((world.time - Z["last_maintained"]) > 15 MINUTES)
				if(prob(5))
					generate_maintenance_task(Z["name"], "scheduled")
		total_integrity += Z["integrity"]
		zone_count++
	if(zone_count > 0)
		overall_integrity = round(total_integrity / zone_count)
	check_overdue_tasks()

/datum/controller/subsystem/containment_integrity/proc/generate_maintenance_task(zone_name, reason)
	var/task_id = "maint_[world.time]_[rand(100,999)]"
	var/priority = reason == "low_integrity" ? 2 : 1
	maintenance_tasks += list(list(
		"task_id" = task_id,
		"zone" = zone_name,
		"reason" = reason,
		"priority" = priority,
		"status" = MAINT_SCHEDULED,
		"assigned_engineer" = "",
		"time_created" = world.time,
		"time_deadline" = world.time + (priority == 2 ? 5 MINUTES : 15 MINUTES),
	))

/datum/controller/subsystem/containment_integrity/proc/assign_maintenance_task(task_id, mob/living/carbon/human/engineer)
	for(var/list/T in maintenance_tasks)
		if(T["task_id"] == task_id && T["status"] == MAINT_SCHEDULED)
			T["assigned_engineer"] = engineer.real_name
			T["status"] = MAINT_IN_PROGRESS
			to_chat(engineer, span_notice("<b>MAINTENANCE TASK:</b> [T["zone"]] — [T["reason"] == "low_integrity" ? "Integrity critical, immediate repair required." : "Scheduled maintenance."]. Report to the area with your tools."))
			return TRUE
	return FALSE

/datum/controller/subsystem/containment_integrity/proc/complete_maintenance_task(task_id, repair_amount)
	for(var/list/T in maintenance_tasks)
		if(T["task_id"] == task_id && T["status"] == MAINT_IN_PROGRESS)
			T["status"] = MAINT_COMPLETE
			total_maintenance_done++
			for(var/list/Z in containment_zones)
				if(Z["name"] == T["zone"])
					Z["integrity"] = min(CONTAINMENT_INTEGRITY_OPTIMAL, Z["integrity"] + repair_amount)
					Z["last_maintained"] = world.time
					Z["breached"] = FALSE
					Z["reinforced"] = repair_amount >= 30
					log_integrity_event("Maintenance complete: [T["zone"]] +[repair_amount]% integrity", T["assigned_engineer"])
					break
			return TRUE
	return FALSE

/datum/controller/subsystem/containment_integrity/proc/repair_zone(zone_name, amount)
	for(var/list/Z in containment_zones)
		if(Z["name"] == zone_name)
			Z["integrity"] = min(CONTAINMENT_INTEGRITY_OPTIMAL, Z["integrity"] + amount)
			Z["breached"] = FALSE
			Z["last_maintained"] = world.time
			total_breach_repairs++
			log_integrity_event("Emergency repair: [zone_name] +[amount]% integrity", "Engineering")
			return TRUE
	return FALSE

/datum/controller/subsystem/containment_integrity/proc/damage_zone(zone_name, amount)
	for(var/list/Z in containment_zones)
		if(Z["name"] == zone_name)
			Z["integrity"] = max(0, Z["integrity"] - amount)
			if(Z["integrity"] <= 0)
				Z["breached"] = TRUE
			log_integrity_event("Damage: [zone_name] -[amount]% integrity", "System")
			return TRUE
	return FALSE

/datum/controller/subsystem/containment_integrity/proc/check_overdue_tasks()
	overdue_tasks = 0
	for(var/list/T in maintenance_tasks)
		if(T["status"] == MAINT_SCHEDULED && world.time > T["time_deadline"])
			T["status"] = MAINT_OVERDUE
			overdue_tasks++
		if(T["status"] == MAINT_OVERDUE)
			overdue_tasks++

/datum/controller/subsystem/containment_integrity/proc/log_integrity_event(event_text, source)
	integrity_log += list(list("event" = event_text, "source" = source, "time" = world.time))
	if(length(integrity_log) > 100)
		integrity_log.Cut(1, 2)

/obj/item/paper/foundation/containment_integrity_report
	name = "Containment Integrity Report"

/obj/item/paper/foundation/maintenance_work_order
	name = "Maintenance Work Order"
