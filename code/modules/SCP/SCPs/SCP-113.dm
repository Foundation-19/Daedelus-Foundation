// SCP-113 - The Gender-Switching Stone
// A red quartz that changes the biological sex of anyone who touches it with bare skin

/obj/item/scp113
	name = "red piece of quartz"
	desc = "A red piece of quartz that gleams with unnatural smoothness. It feels warm to the touch."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "scp113"

	force = 10.0
	throwforce = 10.0
	throw_range = 15
	throw_speed = 3

	var/list/victims = list()
	var/transformation_count = 0
	var/rejection_count = 0
	var/cooldown_time = 0

	var/datum/scp113_transformation_system/transformation_system
	var/datum/scp113_rejection_system/rejection_system
	var/datum/scp113_research_system/research_system

/obj/item/scp113/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "red piece of quartz", SCP_SAFE, "113")

	transformation_system = new /datum/scp113_transformation_system(src)
	rejection_system = new /datum/scp113_rejection_system(src)
	research_system = new /datum/scp113_research_system(src)

	RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(handle_item_pickup))
	RegisterSignal(src, COMSIG_ITEM_UNEQUIPPED, PROC_REF(handle_item_unequipped))

/obj/item/scp113/Destroy()
	REMOVE_TRAIT(src, TRAIT_NODROP, SCP113_TRAIT)
	return ..()

/obj/item/scp113/proc/handle_item_pickup(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/hand_covered = H.active_hand_index == LEFT_HANDS ? HAND_LEFT : HAND_RIGHT

	ADD_TRAIT(src, TRAIT_NODROP, SCP113_TRAIT)

	for(var/obj/item/clothing/C in H.get_equipped_items())
		if(C.body_parts_covered & hand_covered)
			return

	hook_scp_interaction(H, "SCP-113", INTERACTION_TYPE_MEDICAL)

	if(H.humanStageHandler.getStage("113_conversions") >= 1)
		if(rejection_system)
			if(rejection_system.check_rejection(H))
				return

	H.humanStageHandler.setStage("113_effect", 0)
	H.AddComponent(/datum/component/scp113_effect_handler, H, src)
	SEND_SIGNAL(H, COMSIG_SCP113_EFFECT_STAGE_1, H)

	transformation_count++
	var/list/victim_data = victims[H.ckey]
	var/current_count = 0
	if(victim_data)
		current_count = victim_data["count"] || 0
	victims[H.ckey] = list("time" = world.time, "count" = current_count + 1)

/obj/item/scp113/proc/handle_item_unequipped(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	REMOVE_TRAIT(src, TRAIT_NODROP, SCP113_TRAIT)
	qdel(H.GetComponent(/datum/component/scp113_effect_handler))
	SEND_SIGNAL(H, COMSIG_SCP113_EFFECT_STAGE_1, H, 0)

/obj/item/scp113/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A smooth red quartz that affects the biology of those who touch it."))
	to_chat(user, span_notice("Transformations recorded: [transformation_count]"))

/obj/item/scp113/attack(mob/living/M, mob/living/carbon/human/user, target_zone)
	. = ..()
	if(ishuman(M) && user.combat_mode == FALSE)
		var/mob/living/carbon/human/H = M
		hook_scp_interaction(user, "SCP-113", INTERACTION_TYPE_MEDICAL)
		to_chat(user, span_notice("You offer [src] to [H]."))
		to_chat(H, span_notice("[user] offers you [src]. Touch it to receive its effects."))

/datum/scp113_transformation_system
	var/obj/item/parent
	var/transformation_duration = 60 SECONDS
	var/transformation_stages = 5
	var/pain_level = 10

/datum/scp113_transformation_system/New(obj/item/P)
	parent = P

/datum/scp113_transformation_system/proc/begin_transformation(mob/living/carbon/human/target)
	if(!target)
		return FALSE

	to_chat(target, span_warning("You feel a strange sensation spread through your body..."))
	hook_scp_combat(target, "SCP-113", 0, pain_level)

	return TRUE

/datum/scp113_transformation_system/proc/complete_transformation(mob/living/carbon/human/target)
	if(!target)
		return FALSE

	var/original_gender = target.gender
	target.gender = original_gender == MALE ? FEMALE : MALE
	target.visible_message(span_warning("[target]'s body shifts and changes!"), span_notice("Your body has changed. You feel different now."))

	hook_scp_interaction(target, "SCP-113", INTERACTION_TYPE_MEDICAL)

	return TRUE

/datum/scp113_rejection_system
	var/obj/item/parent
	var/rejection_chance_base = 20
	var/rejection_chance_per_use = 15
	var/fatality_chance = 5

/datum/scp113_rejection_system/New(obj/item/P)
	parent = P

/datum/scp113_rejection_system/proc/check_rejection(mob/living/carbon/human/victim)
	if(!victim)
		return FALSE

	var/uses = victim.humanStageHandler.getStage("113_conversions") || 0
	var/rejection_chance = rejection_chance_base + (uses * rejection_chance_per_use)

	if(prob(rejection_chance))
		trigger_rejection(victim, uses)
		return TRUE

	return FALSE

/datum/scp113_rejection_system/proc/trigger_rejection(mob/living/carbon/human/victim, use_count)
	if(!victim)
		return

	victim.visible_message(span_danger("[victim]'s body violently rejects the transformation!"), span_danger("Your body feels like it's tearing itself apart!"))

	if(use_count >= 3 && prob(fatality_chance * use_count))
		victim.gib()
		hook_scp_combat(victim, "SCP-113", 0, 100)
		if(parent)
			var/obj/item/scp113/P = parent
			P.rejection_count++
	else
		victim.apply_damage(100, BRUTE, GROIN)
		victim.apply_damage(50, TOX)
		hook_scp_combat(victim, "SCP-113", 0, 50)

/datum/scp113_research_system
	var/obj/item/parent
	var/list/transformation_log = list()
	var/total_subjects = 0

/datum/scp113_research_system/New(obj/item/P)
	parent = P

/datum/scp113_research_system/proc/log_transformation(mob/living/carbon/human/subject, success)
	total_subjects++
	transformation_log["[world.time]"] = list(
		"subject" = subject?.ckey,
		"original_gender" = subject?.gender,
		"success" = success
	)
