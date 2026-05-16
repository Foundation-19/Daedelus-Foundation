/datum/language/french
	name = "French"
	desc = "A Romance language of the Indo-European family."
	key = "3"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "e", "i", "o", "u", "au", "eau", "eu", "ou", "ai", "ei", "oi", "ui", "an", "en", "in", "on", "un",
		"ba", "be", "bi", "bo", "bu", "ca", "ce", "ci", "co", "cu", "da", "de", "di", "do", "du", "fa", "fe", "fi", "fo", "fu",
		"ga", "ge", "gi", "go", "gu", "ha", "he", "hi", "ho", "hu", "ja", "je", "ji", "jo", "ju", "ka", "ke", "ki", "ko", "ku",
		"la", "le", "li", "lo", "lu", "ma", "me", "mi", "mo", "mu", "na", "ne", "ni", "no", "nu", "pa", "pe", "pi", "po", "pu",
		"ra", "re", "ri", "ro", "ru", "sa", "se", "si", "so", "su", "ta", "te", "ti", "to", "tu", "va", "ve", "vi", "vo", "vu",
		"za", "ze", "zi", "zo", "zu", "cha", "che", "chi", "cho", "chu", "ja", "je", "ji", "jo", "ju",
		"que", "qui", "tion", "sion", "ment", "ique", "able", "ible", "eur", "euse", "oir", "oire"
	)
	icon_state = "french"
	default_priority = 85
