/datum/skill/chemistry
	name = "Chemistry"
	title = "Chemist"
	desc = "Your ability to mix chemicals, create compounds, and understand chemical reactions."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/chemistry

/datum/skill/chemistry/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("I'm learning the basics of chemistry...")
	levelUpMessages[4] = span_nicegreen("I'm becoming quite skilled at mixing chemicals!")
	levelUpMessages[6] = span_nicegreen("I've mastered chemistry. I can create any compound!")

