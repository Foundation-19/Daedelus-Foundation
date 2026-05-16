/datum/skill/engineering
	name = "Engineering"
	title = "Engineering Specialist"
	desc = "Your ability to repair equipment, construct systems, and maintain facility infrastructure."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/engineering

/datum/skill/engineering/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("I'm learning the basics of engineering...")
	levelUpMessages[4] = span_nicegreen("I'm becoming quite skilled at system maintenance!")
	levelUpMessages[6] = span_nicegreen("I've mastered engineering. I can optimize any system!")
