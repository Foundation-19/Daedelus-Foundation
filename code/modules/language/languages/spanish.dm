/datum/language/spanish
	name = "Spanish"
	desc = "A Romance language originating from the Iberian Peninsula."
	key = "2"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "e", "i", "o", "u", "al", "el", "la", "le", "lo", "an", "en", "in", "on", "un", "ar", "er", "ir", "or", "ur",
		"ba", "be", "bi", "bo", "bu", "ca", "ce", "ci", "co", "cu", "da", "de", "di", "do", "du", "fa", "fe", "fi", "fo", "fu",
		"ga", "ge", "gi", "go", "gu", "ha", "he", "hi", "ho", "hu", "ja", "je", "ji", "jo", "ju", "ka", "ke", "ki", "ko", "ku",
		"la", "le", "li", "lo", "lu", "ma", "me", "mi", "mo", "mu", "na", "ne", "ni", "no", "nu", "pa", "pe", "pi", "po", "pu",
		"ra", "re", "ri", "ro", "ru", "sa", "se", "si", "so", "su", "ta", "te", "ti", "to", "tu", "va", "ve", "vi", "vo", "vu",
		"za", "ze", "zi", "zo", "zu", "que", "qui", "cha", "che", "chi", "cho", "chu", "lla", "lle", "lli", "llo", "llu",
		"rra", "rre", "rri", "rro", "rru", "ción", "dad", "mente", "ado", "ada", "ido", "ida"
	)
	icon_state = "spanish"
	default_priority = 85
