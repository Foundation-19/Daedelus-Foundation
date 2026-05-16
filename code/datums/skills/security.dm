/datum/skill/security
	name = "Security"
	title = "Security Specialist"
	desc = "Your ability to investigate threats, assess security risks, and implement security protocols."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/security

/datum/skill/security/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("I'm learning the basics of security protocols...")
	levelUpMessages[4] = span_nicegreen("I'm becoming quite skilled at threat assessment!")
	levelUpMessages[6] = span_nicegreen("I've mastered security. I can protect against any threat!")
