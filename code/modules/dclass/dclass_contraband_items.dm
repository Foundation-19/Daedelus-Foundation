/obj/item/dclass_contraband/lockpick/improvised
	name = "improvised lockpick"
	desc = "A crude but functional lockpick fashioned from wire."
	icon_state = "lockpick"
	force = 3
	var/lockpick_chance = 35

/obj/item/dclass_contraband/lockpick/improvised/attack_self(mob/user)
	to_chat(user, span_notice("You examine the lockpick. It has a [lockpick_chance]% chance of success on standard locks."))

/obj/item/dclass_contraband/improvised_tool
	contraband_key = "improvised_tool"
	name = "improvised tool"
	desc = "A multi-purpose tool cobbled together from wire and pipe. Ugly but functional."
	icon_state = "screwdriver"
	force = 8
	var/tool_efficiency = 0.6

/obj/item/dclass_contraband/improvised_tool/examine(mob/user)
	. = ..()
	. += span_notice("Works at [tool_efficiency * 100]% efficiency compared to standard tools.")

/obj/item/dclass_contraband/disguise_kit
	contraband_key = "disguise_kit"
	name = "improvised disguise kit"
	desc = "A hastily assembled kit for altering one's appearance. Not very convincing up close."
	icon_state = "id"
	var/disguise_quality = 30
	uses = 3

/obj/item/dclass_contraband/disguise_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(uses <= 0)
		to_chat(user, span_warning("The disguise kit is spent."))
		return
	uses--
	var/mob/living/carbon/human/H = user
	var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(H.ckey)
	if(player)
		player.increase_suspicion(8)
	to_chat(H, span_notice("You quickly alter your appearance. Disguise quality: [disguise_quality]%. [uses] uses remaining."))

/obj/item/dclass_contraband/tourniquet
	contraband_key = "tourniquet"
	name = "improvised tourniquet"
	desc = "A strip of fabric and cord that can stop bleeding in an emergency."
	icon_state = "tourniquet"
	var/heal_amount = 15

/obj/item/dclass_contraband/tourniquet/attack(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(H.stat == DEAD)
		to_chat(user, span_warning("It's too late for [H]."))
		return
	H.adjustBruteLoss(-heal_amount)
	H.visible_message(span_notice("[user] applies a tourniquet to [H]."), span_notice("You apply a tourniquet to [H]."))
	qdel(src)

/obj/item/dclass_contraband/restraint_cutter
	contraband_key = "restraint_cutter"
	name = "improvised restraint cutter"
	desc = "A sharpened piece of wire that can cut through restraints."
	icon_state = "wirecutters"
	force = 5
	var/cut_chance = 50

/obj/item/dclass_contraband/restraint_cutter/attack(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(!H.handcuffed)
		to_chat(user, span_warning("[H] is not restrained."))
		return
	if(prob(cut_chance))
		H.clear_cuffs(H.handcuffed)
		H.visible_message(span_notice("[user] cuts [H]'s restraints!"), span_notice("Your restraints are cut!"))
	else
		to_chat(user, span_warning("The cutter slips! The restraints hold."))

/obj/item/grenade/empgrenade/improvised
	name = "improvised EMP device"
	desc = "A crude electromagnetic pulse device. Unreliable but effective."
	icon_state = "emp"
	var/emp_range = 3

/obj/item/grenade/empgrenade/improvised/detonate(mob/living/lanced_by)
	empulse(src, emp_range, emp_range)
	qdel(src)

/obj/item/grenade/smokebomb/improvised
	name = "improvised smoke bomb"
	desc = "A homemade smoke bomb. Shorter duration than commercial models."
	icon_state = "smoke"
	var/smoke_radius = 3

/obj/item/grenade/smokebomb/improvised/detonate(mob/living/lanced_by)
	var/datum/effect_system/fluid_spread/smoke/S = new
	S.set_up(smoke_radius, src)
	S.start()
	qdel(src)

/obj/item/flashlight/flare/improvised
	name = "improvised signal flare"
	desc = "A homemade flare. Burns bright but short."
	icon_state = "flare"
	light_outer_range = 5
	light_power = 2

/obj/item/stack/medical/gauze/improvised
	name = "improvised bandage"
	desc = "Strips of fabric that can be wrapped around wounds. Not sterile."
	singular_name = "improvised bandage"
	heal_brute = 5
	amount = 3
	max_amount = 3
