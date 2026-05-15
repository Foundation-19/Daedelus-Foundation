/obj/item/storage/pill_bottle/scp500
	name = "small plastic jar"
	desc = "A small plastic jar labeled 'SCP-500'. It contains a limited supply of red pills that can cure any disease or affliction."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "great_wave"

/obj/item/storage/pill_bottle/scp500/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Panacea", SCP_SAFE, "500")
/obj/item/storage/pill_bottle/scp500/PopulateContents()
	for(var/i in 1 to 47)
		new /obj/item/reagent_containers/pill/scp500(src)

/obj/item/storage/pill_bottle/scp500/examine(mob/user)
	. = ..()
	var/pill_count = 0
	for(var/obj/item/reagent_containers/pill/scp500/P in src)
		pill_count++
	to_chat(user, span_notice("The jar contains [pill_count] red pill\s. Each one can cure any known disease or affliction. They are irreplaceable."))
	if(pill_count == 0)
		to_chat(user, span_warning("The jar is empty. There are no more pills."))

/obj/item/reagent_containers/pill/scp500
	name = "SCP-500 pill"
	desc = "A small red pill. It is said to cure any disease, poison, or affliction when consumed."
	icon_state = "pill4"
	color = "#ff0000"

/obj/item/reagent_containers/pill/scp500/Initialize()
	. = ..()
/obj/item/reagent_containers/pill/scp500/on_consumption(mob/M, mob/user)
	. = ..()

	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

	H.adjustBruteLoss(-H.getBruteLoss())
	H.adjustFireLoss(-H.getFireLoss())
	H.setToxLoss(0)
	H.setOxyLoss(0)
	H.setCloneLoss(0)
	H.stamina.adjust(H.stamina.maximum - H.stamina.current)
	H.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
	H.reagents?.remove_all()
	H.SetUnconscious(0)
	H.SetStun(0)
	H.SetParalyzed(0)
	H.SetImmobilized(0)
	H.SetSleeping(0)
	H.hallucination = 0

	H.visible_message(span_notice("[H] swallows a small red pill and immediately looks completely revitalized!"), span_notice("You swallow the red pill. Every ache, every illness, every affliction vanishes instantly. You feel perfect."))

	hook_scp_interaction(H, "SCP-500", INTERACTION_TYPE_MEDICAL)
	if(user && user != H)
		hook_scp_interaction(user, "SCP-500", INTERACTION_TYPE_MEDICAL)

/obj/item/reagent_containers/pill/scp500/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A small red pill from SCP-500. One dose cures any disease or affliction. There are only 47 of these in existence."))

