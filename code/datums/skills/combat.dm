/datum/skill/combat
	name = "Combat"
	title = "Fighter"
	desc = "Your proficiency in hand-to-hand combat and melee weapons."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7))

/datum/skill/combat/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("I'm starting to understand the basics of combat...")
	levelUpMessages[4] = span_nicegreen("I'm becoming quite skilled at hand-to-hand combat!")
	levelUpMessages[6] = span_nicegreen("I've mastered the art of combat. Few can match my fighting prowess!")

