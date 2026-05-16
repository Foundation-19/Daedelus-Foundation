/datum/language/german
	name = "German"
	desc = "A West Germanic language primarily spoken in Central Europe."
	key = "1"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"ach", "alt", "an", "auf", "aus", "bah", "bei", "bin", "das", "den", "der", "die", "du", "ein", "er", "es", "für", "hab", "ich", "ihm", "ihr", "im", "in", "ist", "mit", "nicht", "sich", "sie", "sind", "um", "und", "von", "war", "was", "wir", "zu",
		"ab", "als", "am", "auch", "aus", "bei", "bis", "da", "durch", "für", "gegen", "in", "mit", "nach", "ob", "oder", "ohne", "so", "über", "um", "und", "von", "vor", "zu",
		"ge", "be", "ver", "ent", "er", "zer", "un", "miss", "wieder", "vor", "nach", "mit", "bei", "zu", "an", "auf", "aus", "ein", "über", "unter", "durch"
	)
	icon_state = "german"
	default_priority = 85
