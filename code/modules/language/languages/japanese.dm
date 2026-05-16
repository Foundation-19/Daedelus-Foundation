/datum/language/japanese
	name = "Japanese"
	desc = "An East Asian language spoken primarily in Japan."
	key = "5"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "i", "u", "e", "o", "ka", "ki", "ku", "ke", "ko", "sa", "shi", "su", "se", "so",
		"ta", "chi", "tsu", "te", "to", "na", "ni", "nu", "ne", "no", "ha", "hi", "fu", "he", "ho",
		"ma", "mi", "mu", "me", "mo", "ya", "yu", "yo", "ra", "ri", "ru", "re", "ro", "wa", "wo", "n",
		"ga", "gi", "gu", "ge", "go", "za", "ji", "zu", "ze", "zo", "da", "di", "du", "de", "do",
		"ba", "bi", "bu", "be", "bo", "pa", "pi", "pu", "pe", "po", "kya", "kyu", "kyo", "sha", "shu", "sho",
		"cha", "chu", "cho", "nya", "nyu", "nyo", "hya", "hyu", "hyo", "mya", "myu", "myo",
		"rya", "ryu", "ryo", "gya", "gyu", "gyo", "ja", "ju", "jo", "bya", "byu", "byo", "pya", "pyu", "pyo",
		"desu", "masu", "koto", "mono", "hito", "ichi", "ni", "san", "yon", "go", "roku", "nana", "hachi", "kyuu", "juu"
	)
	icon_state = "japanese"
	default_priority = 85
