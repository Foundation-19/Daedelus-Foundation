/datum/language/italian
	name = "Italian"
	desc = "A Romance language of the Indo-European family."
	key = "8"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "e", "i", "o", "u", "ia", "ie", "io", "iu", "ai", "ei", "oi", "ui", "au", "eu", "ou",
		"ba", "be", "bi", "bo", "bu", "ca", "ce", "ci", "co", "cu", "da", "de", "di", "do", "du",
		"fa", "fe", "fi", "fo", "fu", "ga", "ge", "gi", "go", "gu", "ha", "he", "hi", "ho", "hu",
		"la", "le", "li", "lo", "lu", "ma", "me", "mi", "mo", "mu", "na", "ne", "ni", "no", "nu",
		"pa", "pe", "pi", "po", "pu", "ra", "re", "ri", "ro", "ru", "sa", "se", "si", "so", "su",
		"ta", "te", "ti", "to", "tu", "va", "ve", "vi", "vo", "vu", "za", "ze", "zi", "zo", "zu",
		"bra", "bre", "bri", "bro", "bru", "cra", "cre", "cri", "cro", "cru", "dra", "dre", "dri", "dro", "dru",
		"fra", "fre", "fri", "fro", "fru", "gra", "gre", "gri", "gro", "gru", "pra", "pre", "pri", "pro", "pru",
		"tra", "tre", "tri", "tro", "tru", "bla", "ble", "bli", "blo", "blu", "cla", "cle", "cli", "clo", "clu",
		"fla", "fle", "fli", "flo", "flu", "gla", "gle", "gli", "glo", "glu", "pla", "ple", "pli", "plo", "plu",
		"cha", "che", "chi", "cho", "chu", "gha", "ghe", "ghi", "gho", "ghu", "sca", "sce", "sci", "sco", "scu",
		"spa", "spe", "spi", "spo", "spu", "sta", "ste", "sti", "sto", "stu", "zione", "sione", "mente", "ando", "endo",
		"are", "ere", "ire", "ato", "uto", "ita", "iva", "oso", "osa", "ano", "ino", "ona", "ina"
	)
	icon_state = "italian"
	default_priority = 85
