#define TECH_TIER_1 1
#define TECH_TIER_2 2
#define TECH_TIER_3 3
#define TECH_TIER_4 4
#define TECH_TIER_5 5

#define TECH_CATEGORY_CONTAINMENT "Containment"
#define TECH_CATEGORY_MEDICAL "Medical"
#define TECH_CATEGORY_ENGINEERING "Engineering"
#define TECH_CATEGORY_COGNITIVE "Cognitive"
#define TECH_CATEGORY_ANALYTICAL "Analytical"

/datum/tech_node
	var/node_id
	var/name
	var/description
	var/category = TECH_CATEGORY_CONTAINMENT
	var/tier = TECH_TIER_1
	var/research_cost = 100
	var/list/prerequisites = list()
	var/unlocked = FALSE
	var/unlocked_by
	var/unlock_time
	var/list/unlocks = list()

/datum/tech_node/New(id, node_name, node_desc, node_category, node_tier, cost)
	node_id = id
	name = node_name
	description = node_desc
	category = node_category
	tier = node_tier
	research_cost = cost

/datum/tech_tree
	var/list/datum/tech_node/nodes = list()
	var/list/unlocked_nodes = list()
	var/research_points_available = 0
	var/total_spent = 0

/datum/tech_tree/proc/initialize()
	register_tech_nodes()

/datum/tech_tree/proc/register_tech_nodes()
	var/list/tech_defs = list(
		list("basic_containment", "Basic Containment Protocols", "Standard containment procedures for Safe-class objects.", TECH_CATEGORY_CONTAINMENT, TECH_TIER_1, 50),
		list("basic_analysis", "Basic SCP Analysis", "Preliminary anomaly analysis methodology.", TECH_CATEGORY_ANALYTICAL, TECH_TIER_1, 50),
		list("basic_medical", "Anomalous Medicine", "Treatment protocols for anomalous exposure.", TECH_CATEGORY_MEDICAL, TECH_TIER_1, 50),
		list("pathogen_identification", "Pathogen Identification", "Rapid identification and classification of Foundation pathogens.", TECH_CATEGORY_MEDICAL, TECH_TIER_1, 75),
		list("improved_containment", "Improved Containment", "Enhanced containment for Euclid-class objects.", TECH_CATEGORY_CONTAINMENT, TECH_TIER_2, 200, list("basic_containment")),
		list("advanced_analysis", "Advanced Anomaly Analysis", "Deep anomaly profiling and classification.", TECH_CATEGORY_ANALYTICAL, TECH_TIER_2, 200, list("basic_analysis")),
		list("cognitive_shielding", "Cognitive Hazard Shielding", "Basic memetic and cognitive hazard protection.", TECH_CATEGORY_COGNITIVE, TECH_TIER_2, 200, list("basic_analysis")),
		list("anomalous_surgery", "Anomalous Surgery", "Surgical techniques for anomalous conditions.", TECH_CATEGORY_MEDICAL, TECH_TIER_2, 200, list("basic_medical")),
		list("bsl3_protocols", "BSL-3 Containment Protocols", "High-containment laboratory procedures for dangerous pathogens.", TECH_CATEGORY_MEDICAL, TECH_TIER_2, 250, list("pathogen_identification")),
		list("anomalous_virology", "Anomalous Virology", "Study of SCP-derived and reality-altering pathogens.", TECH_CATEGORY_MEDICAL, TECH_TIER_2, 250, list("pathogen_identification", "basic_analysis")),
		list("containment_reinforcement", "Containment Reinforcement", "Reinforced containment for Keter-class objects.", TECH_CATEGORY_CONTAINMENT, TECH_TIER_3, 500, list("improved_containment")),
		list("amnestics_production", "Amnestics Production", "On-site amnestics manufacturing capability.", TECH_CATEGORY_MEDICAL, TECH_TIER_3, 500, list("anomalous_surgery", "cognitive_shielding")),
		list("pattern_recognition", "Anomaly Pattern Recognition", "Predictive modeling for SCP behavior.", TECH_CATEGORY_ANALYTICAL, TECH_TIER_3, 500, list("advanced_analysis")),
		list("memetic_countermeasures", "Memetic Countermeasures", "Advanced counter-memetic equipment.", TECH_CATEGORY_COGNITIVE, TECH_TIER_3, 500, list("cognitive_shielding")),
		list("containment_engineering", "Containment Engineering", "Purpose-built containment systems.", TECH_CATEGORY_ENGINEERING, TECH_TIER_3, 500, list("improved_containment")),
		list("bsl4_containment", "BSL-4 Maximum Containment", "Full biocontainment with double-door decon and isolated HVAC.", TECH_CATEGORY_MEDICAL, TECH_TIER_3, 600, list("bsl3_protocols", "anomalous_virology")),
		list("anomalous_cure_development", "Anomalous Cure Synthesis", "Targeted countermeasure development for anomalous pathogens.", TECH_CATEGORY_MEDICAL, TECH_TIER_3, 600, list("anomalous_virology", "anomalous_surgery")),
		list("keter_protocols", "Keter-Class Protocols", "Maximum security containment procedures.", TECH_CATEGORY_CONTAINMENT, TECH_TIER_4, 1500, list("containment_reinforcement")),
		list("reality_anchor_theory", "Reality Anchor Theory", "Theoretical framework for reality stabilization.", TECH_CATEGORY_ENGINEERING, TECH_TIER_4, 1500, list("containment_engineering")),
		list("telekill_alloy", "Telekill Alloy Research", "Psychic shielding alloy development.", TECH_CATEGORY_COGNITIVE, TECH_TIER_4, 1500, list("memetic_countermeasures")),
		list("scp_weaponization", "SCP Weaponization", "Offensive application of anomalous properties.", TECH_CATEGORY_CONTAINMENT, TECH_TIER_4, 1500, list("keter_protocols")),
		list("bioweapon_countermeasures", "Anomalous Bioweapon Countermeasures", "Large-scale countermeasures for weaponized anomalous pathogens.", TECH_CATEGORY_MEDICAL, TECH_TIER_4, 1500, list("bsl4_containment", "anomalous_cure_development")),
		list("apollyon_protocols", "Apollyon Containment Theory", "Theoretical XK-class prevention strategies.", TECH_CATEGORY_CONTAINMENT, TECH_TIER_5, 5000, list("keter_protocols", "reality_anchor_theory")),
		list("project_overwatch", "Project Overwatch", "Global anomaly monitoring network.", TECH_CATEGORY_ANALYTICAL, TECH_TIER_5, 5000, list("pattern_recognition", "reality_anchor_theory")),
		list("xk_biodefense", "XK-Class Biodefense Protocol", "Ultimate biodefense against existential anomalous pathogen threats.", TECH_CATEGORY_MEDICAL, TECH_TIER_5, 5000, list("bioweapon_countermeasures", "apollyon_protocols")),
	)

	for(var/list/def in tech_defs)
		var/datum/tech_node/node = new(def[1], def[2], def[3], def[4], def[5], def[6])
		if(length(def) > 6)
			node.prerequisites = def[7]
		nodes[node.node_id] = node

/datum/tech_tree/proc/can_unlock(node_id, available_points)
	var/datum/tech_node/node = nodes[node_id]
	if(!node || node.unlocked)
		return FALSE
	if(available_points < node.research_cost)
		return FALSE
	for(var/prereq_id in node.prerequisites)
		var/datum/tech_node/prereq = nodes[prereq_id]
		if(!prereq || !prereq.unlocked)
			return FALSE
	return TRUE

/datum/tech_tree/proc/unlock_node(node_id, researcher_ckey)
	var/datum/tech_node/node = nodes[node_id]
	if(!node)
		return FALSE
	node.unlocked = TRUE
	node.unlocked_by = researcher_ckey
	node.unlock_time = world.time
	unlocked_nodes[node_id] = node
	total_spent += node.research_cost
	return TRUE

/datum/tech_tree/proc/get_unlocked_by_category(category)
	var/list/result = list()
	for(var/node_id in unlocked_nodes)
		var/datum/tech_node/node = unlocked_nodes[node_id]
		if(node.category == category)
			result += list(list("id" = node.node_id, "name" = node.name, "tier" = node.tier))
	return result

/datum/tech_tree/proc/get_available_nodes(available_points)
	var/list/result = list()
	for(var/node_id in nodes)
		if(can_unlock(node_id, available_points))
			var/datum/tech_node/node = nodes[node_id]
			result += list(list("id" = node.node_id, "name" = node.name, "tier" = node.tier, "cost" = node.research_cost, "category" = node.category))
	return result

/datum/tech_tree/proc/get_all_nodes_data()
	var/list/result = list()
	for(var/node_id in nodes)
		var/datum/tech_node/node = nodes[node_id]
		result[node_id] = list(
			"id" = node.node_id,
			"name" = node.name,
			"description" = node.description,
			"category" = node.category,
			"tier" = node.tier,
			"cost" = node.research_cost,
			"prerequisites" = node.prerequisites,
			"unlocked" = node.unlocked,
			"unlocked_by" = node.unlocked_by,
		)
	return result
