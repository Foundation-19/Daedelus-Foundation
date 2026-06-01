#define BOT_TYPE_MONITOR 1
#define BOT_TYPE_CONTAINMENT 2
#define BOT_TYPE_DECON 3
#define BOT_TYPE_REPAIR 4

SUBSYSTEM_DEF(containment_robotics)
	name = "Containment Robotics"
	wait = 20 SECONDS
	flags = SS_NO_FIRE

	var/list/registered_bots = list()
	var/list/construction_queue = list()
	var/list/maintenance_log = list()
	var/total_bots_built = 0
	var/total_maintenance_done = 0
	var/total_containment_assists = 0

/datum/controller/subsystem/containment_robotics/proc/register_bot(mob/living/simple_animal/bot/bot, bot_type, owner_name)
	if(!bot)
		return
	registered_bots += list(list(
		"bot_ref" = REF(bot),
		"bot_name" = bot.name,
		"bot_type" = bot_type,
		"owner" = owner_name,
		"integrity" = 100,
		"active" = TRUE,
		"last_maintained" = world.time,
	))
	total_bots_built++

/datum/controller/subsystem/containment_robotics/proc/submit_construction_order(order_type, mob/living/carbon/human/orderer)
	if(!order_type || !orderer)
		return
	var/list/materials_needed = list()
	var/build_time = 60 SECONDS
	var/description = ""
	switch(order_type)
		if(BOT_TYPE_MONITOR)
			materials_needed = list(/obj/item/stack/sheet/iron = 5, /obj/item/stock_parts/scanning_module = 2, /obj/item/stock_parts/capacitor = 1)
			build_time = 90 SECONDS
			description = "SCP Monitoring Drone — patrols containment zones, alerts on breach detection"
		if(BOT_TYPE_CONTAINMENT)
			materials_needed = list(/obj/item/stack/sheet/iron = 8, /obj/item/stock_parts/manipulator = 2, /obj/item/stock_parts/capacitor = 2)
			build_time = 120 SECONDS
			description = "Containment Assist Bot — helps seal breaches, reinforces doors"
		if(BOT_TYPE_DECON)
			materials_needed = list(/obj/item/stack/sheet/iron = 4, /obj/item/stock_parts/manipulator = 1, /obj/item/reagent_containers/glass/bottle/space_cleaner = 2)
			build_time = 60 SECONDS
			description = "Decontamination Drone — cleans anomalous residue, sterilizes areas"
		if(BOT_TYPE_REPAIR)
			materials_needed = list(/obj/item/stack/sheet/iron = 6, /obj/item/stock_parts/manipulator = 2, /obj/item/weldingtool = 1)
			build_time = 90 SECONDS
			description = "Repair Drone — fixes containment integrity, repairs airlocks"
	construction_queue += list(list(
		"order_type" = order_type,
		"orderer" = orderer.real_name,
		"description" = description,
		"materials" = materials_needed,
		"build_time" = build_time,
		"progress" = 0,
		"status" = "pending",
		"time_submitted" = world.time,
	))
	to_chat(orderer, span_notice("Construction order submitted: [description]. Load materials into the robotics fabricator."))

/datum/controller/subsystem/containment_robotics/proc/start_construction(idx, mob/living/carbon/human/builder)
	if(idx < 1 || idx > length(construction_queue))
		return FALSE
	var/list/O = construction_queue[idx]
	if(O["status"] != "pending")
		return FALSE
	O["status"] = "building"
	O["builder"] = builder.real_name
	to_chat(builder, span_notice("Construction begun on [O["description"]]. This will take [O["build_time"] / 600] minute(s)."))
	return TRUE

/datum/controller/subsystem/containment_robotics/proc/advance_construction(idx, progress_amount)
	if(idx < 1 || idx > length(construction_queue))
		return
	var/list/O = construction_queue[idx]
	if(O["status"] != "building")
		return
	O["progress"] = min(100, O["progress"] + progress_amount)
	if(O["progress"] >= 100)
		complete_construction(idx)

/datum/controller/subsystem/containment_robotics/proc/complete_construction(idx)
	if(idx < 1 || idx > length(construction_queue))
		return
	var/list/O = construction_queue[idx]
	O["status"] = "complete"
	total_bots_built++
	var/bot_type = O["order_type"]
	var/bot_name = "Foundation [bot_type == BOT_TYPE_MONITOR ? "Monitor" : bot_type == BOT_TYPE_CONTAINMENT ? "Containment" : bot_type == BOT_TYPE_DECON ? "Decon" : "Repair"] Bot"
	to_chat(usr, span_greenannounce("Construction complete: [bot_name] is operational."))
	if(SSscp_research?.manager)
		SSscp_research?.manager?.adjust_research_points(15, "robotic_construction:[usr?.ckey || "unknown"]")
	log_maintenance("Bot constructed: [bot_name]", O["builder"] || "Unknown")

/datum/controller/subsystem/containment_robotics/proc/report_containment_assist(bot_name, assist_type)
	total_containment_assists++
	log_maintenance("Containment assist: [bot_name] — [assist_type]", bot_name)

/datum/controller/subsystem/containment_robotics/proc/log_maintenance(event_text, source)
	maintenance_log += list(list("event" = event_text, "source" = source, "time" = world.time))
	total_maintenance_done++
	if(length(maintenance_log) > 100)
		maintenance_log.Cut(1, 2)

/obj/item/paper/foundation/robotics_work_order
	name = "Robotics Work Order"

/obj/item/paper/foundation/bot_maintenance_log
	name = "Bot Maintenance Log"
