/datum/skill/research
	name = "Research"
	title = "Research Specialist"
	desc = "Your ability to conduct scientific research, analyze data, and make breakthrough discoveries."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/research

/datum/skill/research/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("I'm learning the basics of scientific research...")
	levelUpMessages[4] = span_nicegreen("I'm becoming quite skilled at data analysis!")
	levelUpMessages[6] = span_nicegreen("I've mastered research methodology. I can discover breakthroughs!")
