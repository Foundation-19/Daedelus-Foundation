/datum/persistent_faction
	var/faction_id = "foundation"
	var/faction_name = "SCP Foundation"
	var/faction_description = "Primary containment organization"
	var/faction_color = "#0066CC"
	var/list/faction_classes = list()
	var/list/faction_equipment = list()
	var/list/faction_titles = list()
	var/faction_icon = "faction_foundation"
	var/experience_multiplier = 1.0

/datum/persistent_faction/foundation
	faction_id = "foundation"
	faction_name = "SCP Foundation"
	faction_description = "Primary containment organization dedicated to securing, containing, and protecting."
	faction_color = "#0066CC"
	faction_icon = "faction_foundation"
	experience_multiplier = 1.0
	faction_classes = list("security", "research", "medical", "engineering", "administrative", "containment")

/datum/persistent_faction/goc
	faction_id = "goc"
	faction_name = "Global Occult Coalition"
	faction_description = "International organization focused on neutralizing anomalous threats."
	faction_color = "#FF6600"
	faction_icon = "faction_goc"
	experience_multiplier = 1.1
	faction_classes = list("research", "security", "administrative")

/datum/persistent_faction/serpents_hand
	faction_id = "serpents_hand"
	faction_name = "Serpent's Hand"
	faction_description = "Anomalous knowledge seekers and artifact collectors."
	faction_color = "#44FF44"
	faction_icon = "faction_serpents"
	experience_multiplier = 1.2
	faction_classes = list("research", "containment")

/datum/persistent_faction/chaos_insurgency
	faction_id = "chaos_insurgency"
	faction_name = "Chaos Insurgency"
	faction_description = "Covert organization focused on disruption and acquisition."
	faction_color = "#FF4444"
	faction_icon = "faction_chaos"
	experience_multiplier = 1.3
	faction_classes = list("security", "research", "administrative")

/datum/persistent_faction/mcd
	faction_id = "mcd"
	faction_name = "Marshall, Carter & Dark"
	faction_description = "Corporate organization focused on commercial exploitation of anomalies."
	faction_color = "#AA44FF"
	faction_icon = "faction_mcd"
	experience_multiplier = 1.1
	faction_classes = list("administrative", "research", "security")

/datum/persistent_faction/uiu
	faction_id = "uiu"
	faction_name = "Unusual Incidents Unit"
	faction_description = "Government law enforcement agency dealing with anomalous incidents."
	faction_color = "#44AAFF"
	faction_icon = "faction_uiu"
	experience_multiplier = 1.0
	faction_classes = list("security", "medical", "engineering", "administrative")

/datum/persistent_faction/proc/export_to_json()
	var/list/data = list()
	data["faction_id"] = faction_id
	data["faction_name"] = faction_name
	data["faction_description"] = faction_description
	data["faction_color"] = faction_color
	data["faction_classes"] = faction_classes
	data["faction_equipment"] = faction_equipment
	data["faction_titles"] = faction_titles
	data["faction_icon"] = faction_icon
	data["experience_multiplier"] = experience_multiplier
	return json_encode(data)
