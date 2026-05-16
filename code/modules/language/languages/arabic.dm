/datum/language/arabic
	name = "Arabic"
	desc = "A Semitic language spoken across the Arab world."
	key = "7"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "i", "u", "aa", "ii", "uu", "ay", "aw", "ab", "ad", "af", "ag", "ah", "aj", "ak", "al", "am", "an", "ar", "as", "at", "az",
		"ba", "bi", "bu", "da", "di", "du", "fa", "fi", "fu", "ga", "gi", "gu", "ha", "hi", "hu", "ja", "ji", "ju",
		"ka", "ki", "ku", "la", "li", "lu", "ma", "mi", "mu", "na", "ni", "nu", "qa", "qi", "qu", "ra", "ri", "ru",
		"sa", "si", "su", "ta", "ti", "tu", "wa", "wi", "wu", "ya", "yi", "yu", "za", "zi", "zu",
		"kha", "khi", "khu", "dha", "dhi", "dhu", "sha", "shi", "shu", "tha", "thi", "thu", "gha", "ghi", "ghu",
		"hab", "had", "haf", "hag", "hah", "haj", "hak", "hal", "ham", "han", "har", "has", "hat", "haz",
		"lab", "lad", "laf", "lag", "lah", "laj", "lak", "lal", "lam", "lan", "lar", "las", "lat", "laz",
		"mab", "mad", "maf", "mag", "mah", "maj", "mak", "mal", "mam", "man", "mar", "mas", "mat", "maz",
		"nab", "nad", "naf", "nag", "nah", "naj", "nak", "nal", "nam", "nan", "nar", "nas", "nat", "naz",
		"rab", "rad", "raf", "rag", "rah", "raj", "rak", "ral", "ram", "ran", "rar", "ras", "rat", "raz",
		"sab", "sad", "saf", "sag", "sah", "saj", "sak", "sal", "sam", "san", "sar", "sas", "sat", "saz"
	)
	icon_state = "arabic"
	default_priority = 85
