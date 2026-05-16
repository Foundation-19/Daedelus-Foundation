/datum/preference/choiced/faction
	explanation = "Faction"
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "faction"
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/choiced/faction/init_possible_values()
	return list("foundation", "goc", "serpents_hand", "chaos_insurgency", "mcd", "uiu")

/datum/preference/choiced/faction/create_default_value()
	return "foundation"

/datum/preference/choiced/faction/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/class
	explanation = "Class"
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "class"
	priority = PREFERENCE_PRIORITY_DEFAULT

/datum/preference/choiced/class/init_possible_values()
	return list("administrative", "security", "research", "medical", "engineering", "intelligence")

/datum/preference/choiced/class/create_default_value()
	return "security"

/datum/preference/choiced/class/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/blob/faction_class_state
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "faction_class_state"

/datum/preference/blob/faction_class_state/create_default_value()
	return list("locked" = FALSE, "tokens" = 0)

/datum/preference/blob/faction_class_state/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return create_default_value()
	var/list/out = create_default_value()
	for (var/k in input)
		out[k] = input[k]
	return out
