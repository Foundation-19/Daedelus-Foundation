/datum/language/russian
	name = "Russian"
	desc = "An East Slavic language primarily spoken in Russia."
	key = "4"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "e", "i", "o", "u", "y", "ya", "ye", "yo", "yu", "ay", "ey", "oy", "uy", "yy",
		"ba", "be", "bi", "bo", "bu", "by", "va", "ve", "vi", "vo", "vu", "vy", "ga", "ge", "gi", "go", "gu", "gy",
		"da", "de", "di", "do", "du", "dy", "zha", "zhe", "zhi", "zho", "zhu", "zhy", "za", "ze", "zi", "zo", "zu", "zy",
		"ka", "ke", "ki", "ko", "ku", "ky", "la", "le", "li", "lo", "lu", "ly", "ma", "me", "mi", "mo", "mu", "my",
		"na", "ne", "ni", "no", "nu", "ny", "pa", "pe", "pi", "po", "pu", "py", "ra", "re", "ri", "ro", "ru", "ry",
		"sa", "se", "si", "so", "su", "sy", "ta", "te", "ti", "to", "tu", "ty", "fa", "fe", "fi", "fo", "fu", "fy",
		"kha", "khe", "khi", "kho", "khu", "khy", "tsa", "tse", "tsi", "tso", "tsu", "tsy",
		"cha", "che", "chi", "cho", "chu", "chy", "sha", "she", "shi", "sho", "shu", "shy",
		"shcha", "shche", "shchi", "shcho", "shchu", "shchy", "ost", "est", "ist", "nost", "tost"
	)
	icon_state = "russian"
	default_priority = 85
