/datum/language/hindi
	name = "Hindi"
	desc = "An Indo-European language spoken primarily in Northern India."
	key = "9"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "aa", "i", "ii", "u", "uu", "e", "ai", "o", "au", "am", "ah",
		"ka", "kha", "ga", "gha", "nga", "cha", "chha", "ja", "jha", "nya",
		"ta", "tha", "da", "dha", "na", "pa", "pha", "ba", "bha", "ma",
		"ya", "ra", "la", "va", "sha", "sa", "ha", "ksha", "tra", "gya",
		"ki", "khi", "gi", "ghi", "ngi", "chi", "chhi", "ji", "jhi", "nyi",
		"ti", "thi", "di", "dhi", "ni", "pi", "phi", "bi", "bhi", "mi",
		"yi", "ri", "li", "vi", "shi", "si", "hi", "kshi", "tri", "gyi",
		"ku", "khu", "gu", "ghu", "ngu", "chu", "chhu", "ju", "jhu", "nyu",
		"tu", "thu", "du", "dhu", "nu", "pu", "phu", "bu", "bhu", "mu",
		"yu", "ru", "lu", "vu", "shu", "su", "hu", "kshu", "tru", "gyu",
		"ke", "khe", "ge", "ghe", "nge", "che", "chhe", "je", "jhe", "nye",
		"te", "the", "de", "dhe", "ne", "pe", "phe", "be", "bhe", "me",
		"ye", "re", "le", "ve", "she", "se", "he", "kshe", "tre", "gye",
		"ko", "kho", "go", "gho", "ngo", "cho", "chho", "jo", "jho", "nyo",
		"to", "tho", "do", "dho", "no", "po", "pho", "bo", "bho", "mo",
		"yo", "ro", "lo", "vo", "sho", "so", "ho", "ksho", "tro", "gyo",
		"kar", "khar", "gar", "ghar", "ngar", "char", "chhar", "jar", "jhar", "nyar",
		"tar", "thar", "dar", "dhar", "nar", "par", "phar", "bar", "bhar", "mar"
	)
	icon_state = "hindi"
	default_priority = 85
