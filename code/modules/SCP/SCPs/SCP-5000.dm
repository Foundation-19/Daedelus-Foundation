#ifndef TRAIT_SCP5000_WORN
#define TRAIT_SCP5000_WORN "scp5000_worn"
#endif

/obj/item/clothing/suit/scp5000
	name = "strange suit"
	desc = "A suit of unknown origin and composition. It appears to be designed for full-body protection. Something about it feels deeply wrong."
	icon_state = "scp5000"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor = list(BLUNT = 40, PUNCTURE = 30, SLASH = 0, LASER = 30, ENERGY = 20, BOMB = 20, BIO = 100, FIRE = 0, ACID = 0)

	var/active = FALSE
	var/foundation_hostile = FALSE
	var/mob/living/carbon/human/wearer

/obj/item/clothing/suit/scp5000/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Why?", SCP_KETER, "5000")
/obj/item/clothing/suit/scp5000/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == ITEM_SLOT_OCLOTHING)
		wearer = user
		active = TRUE
		foundation_hostile = TRUE
		to_chat(user, span_warning("As you don the suit, a profound sense of isolation washes over you. The Foundation's memetic safeguards feel distant now, like they were never real."))
		hook_scp_breach("SCP-5000", src)
		START_PROCESSING(SSobj, src)
		apply_foundation_hostility(user)

/obj/item/clothing/suit/scp5000/unequipped(mob/user)
	..()
	if(wearer == user)
		remove_foundation_hostility(wearer)
		wearer = null
		active = FALSE
		foundation_hostile = FALSE
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/scp5000/process()
	if(!active || !wearer)
		return

	if(wearer.wear_suit != src)
		remove_foundation_hostility(wearer)
		wearer = null
		active = FALSE
		foundation_hostile = FALSE
		return

	if(prob(5))
		var/list/messages = list(
			"You remember something that never happened.",
			"The Foundation's directive echoes in your mind, twisted beyond recognition.",
			"You feel the weight of a truth that should not exist.",
			"Something is very wrong with the world. Or maybe with you.",
			"The suit whispers of a timeline where mercy was the anomaly."
		)
		to_chat(wearer, "<i>[pick(messages)]</i>")

	if(prob(3))
		for(var/mob/living/carbon/human/H in view(7, wearer))
			if(H == wearer)
				continue
			if(is_facility_personnel(H))
				if(prob(15))
					H.visible_message(span_warning("[H] looks at [wearer] with sudden hostility!"), span_warning("You feel an inexplicable urge to neutralize [wearer]... Something about them is WRONG."))
					H.set_combat_mode(TRUE)

/obj/item/clothing/suit/scp5000/proc/apply_foundation_hostility(mob/living/carbon/human/W)
	if(!W)
		return

	ADD_TRAIT(W, TRAIT_SCP5000_WORN, "scp5000")
	W.add_filter("scp5000_distortion", 1, gauss_blur_filter(1))

/obj/item/clothing/suit/scp5000/proc/remove_foundation_hostility(mob/living/carbon/human/W)
	if(!W)
		return

	REMOVE_TRAIT(W, TRAIT_SCP5000_WORN, "scp5000")
	W.remove_filter("scp5000_distortion")

/obj/item/clothing/suit/scp5000/proc/is_facility_personnel(mob/living/carbon/human/H)
	if(!H || !H.mind)
		return FALSE
	var/datum/job/J = SSjob.GetJob(H.job)
	if(J && J.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY|DEPARTMENT_BITFLAG_COMPANY_LEADER|DEPARTMENT_BITFLAG_SCIENCE|DEPARTMENT_BITFLAG_MEDICAL|DEPARTMENT_BITFLAG_ENGINEERING))
		return TRUE
	return FALSE

/obj/item/clothing/suit/scp5000/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A suit of unknown origin. When worn, it shields the wearer from memetic kill agents and antimemes."))
	to_chat(user, span_warning("Foundation personnel seem to become hostile toward anyone wearing this suit."))
	if(active)
		to_chat(user, "<i>The suit hums faintly, as if remembering something terrible.</i>")
