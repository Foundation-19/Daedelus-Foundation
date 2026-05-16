/datum/language/english
	name = "English"
	desc = "A West Germanic language originating from England."
	key = "0"
	flags = parent_type::flags | (LANGUAGE_SELECTABLE_SPEAK | LANGUAGE_SELECTABLE_UNDERSTAND)

	syllables = list(
		"a", "e", "i", "o", "u", "y", "an", "en", "in", "on", "un", "ar", "er", "ir", "or", "ur",
		"al", "el", "il", "ol", "ul", "as", "es", "is", "os", "us", "at", "et", "it", "ot", "ut",
		"ba", "be", "bi", "bo", "bu", "by", "ca", "ce", "ci", "co", "cu", "cy", "da", "de", "di", "do", "du", "dy",
		"fa", "fe", "fi", "fo", "fu", "fy", "ga", "ge", "gi", "go", "gu", "gy", "ha", "he", "hi", "ho", "hu", "hy",
		"ja", "je", "ji", "jo", "ju", "jy", "ka", "ke", "ki", "ko", "ku", "ky", "la", "le", "li", "lo", "lu", "ly",
		"ma", "me", "mi", "mo", "mu", "my", "na", "ne", "ni", "no", "nu", "ny", "pa", "pe", "pi", "po", "pu", "py",
		"qa", "qe", "qi", "qo", "qu", "qy", "ra", "re", "ri", "ro", "ru", "ry", "sa", "se", "si", "so", "su", "sy",
		"ta", "te", "ti", "to", "tu", "ty", "va", "ve", "vi", "vo", "vu", "vy", "wa", "we", "wi", "wo", "wu", "wy",
		"xa", "xe", "xi", "xo", "xu", "xy", "ya", "ye", "yi", "yo", "yu", "yy", "za", "ze", "zi", "zo", "zu", "zy",
		"the", "and", "for", "are", "but", "not", "you", "all", "can", "had", "her", "was", "one", "our", "out", "day",
		"get", "has", "him", "his", "how", "man", "new", "now", "old", "see", "two", "way", "who", "boy", "did", "its",
		"let", "put", "say", "she", "too", "use", "that", "with", "have", "this", "will", "your", "from", "they", "know",
		"want", "been", "good", "much", "some", "time", "very", "when", "come", "just", "like", "long", "make", "many",
		"over", "such", "take", "than", "them", "well", "were", "what", "word", "work", "year", "about", "after", "again",
		"could", "first", "great", "other", "should", "their", "there", "think", "three", "under", "water", "where", "which",
		"world", "would", "write", "because", "between", "through", "without", "something", "everything", "anything"
	)
	icon_state = "english"
	default_priority = 100
