/datum/skill/containment
	name = "Containment"
	title = "Containment Specialist"
	desc = "Your ability to contain, monitor, and manage anomalous entities and phenomena."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7))
	skill_cape_path = /obj/item/clothing/neck/cloak/skill_reward/containment

/datum/skill/containment/New()
	. = ..()
	levelUpMessages[1] = span_nicegreen("I'm learning the basics of containment procedures...")
	levelUpMessages[4] = span_nicegreen("I'm becoming quite skilled at managing anomalies!")
	levelUpMessages[6] = span_nicegreen("I've mastered containment operations. I can secure any anomaly!")

