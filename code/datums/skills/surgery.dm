/datum/skill/surgery
	name = "Surgery"
	title = "Surgeon"
	desc = "Your proficiency in performing surgical procedures and complex medical operations."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/surgery

/datum/skill/surgery/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("I'm learning the basics of surgical procedures...")
	levelUpMessages[4] = span_nicegreen("I'm becoming quite skilled at performing surgery!")
	levelUpMessages[6] = span_nicegreen("I've mastered surgery. I can perform any medical procedure!")

