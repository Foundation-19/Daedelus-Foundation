/obj/item/storage/pill_bottle/scp500
	name = "small plastic jar"
	desc = "A small plastic jar labeled 'SCP-500'. It contains a limited supply of red pills that can cure any disease or affliction."
	icon = 'icons/scp/scpstructures(32x32).dmi'
	icon_state = "great_wave"
	var/initial_pill_count = 47
	var/authorized_jobs = list("Medical Doctor", "Chief Medical Officer", "Research Director", "Site Director", "O5 Council Member")
	var/list/logged_usage = list()

/obj/item/storage/pill_bottle/scp500/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "Panacea", SCP_SAFE, "500")

/obj/item/storage/pill_bottle/scp500/PopulateContents()
	for(var/i in 1 to initial_pill_count)
		new /obj/item/reagent_containers/pill/scp500(src)

/obj/item/storage/pill_bottle/scp500/examine(mob/user)
	. = ..()
	var/pill_count = 0
	for(var/obj/item/reagent_containers/pill/scp500/P in src)
		pill_count++
	to_chat(user, span_notice("The jar contains [pill_count] red pill\s. Each one can cure any known disease or affliction. They are irreplaceable."))
	if(pill_count == 0)
		to_chat(user, span_warning("The jar is empty. There are no more pills."))
	else if(pill_count <= 5)
		to_chat(user, span_warning("Only [pill_count] pills remain. Extreme rationing is advised."))
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, span_notice("Authorization required: [jointext(authorized_jobs, ", ")]. All usage is logged."))

/obj/item/storage/pill_bottle/scp500/attack_hand(mob/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user
	var/pill_count = 0
	for(var/obj/item/reagent_containers/pill/scp500/P in src)
		pill_count++
	if(pill_count == 0)
		to_chat(H, span_warning("The jar is empty."))
		return
	if(!check_authorization(H))
		to_chat(H, span_warning("You are not authorized to access SCP-500. Required: [jointext(authorized_jobs, " OR ")]"))
		log_scp500_unauthorized(H)
		return
	return ..()

/obj/item/storage/pill_bottle/scp500/proc/check_authorization(mob/living/carbon/human/H)
	if(H.SCP)
		return TRUE
	var/job_title = H.job
	for(var/authorized in authorized_jobs)
		if(job_title == authorized)
			return TRUE
	var/obj/item/card/id/id_card = H.get_idcard()
	if(id_card)
		var/list/access = id_card.GetAccess()
		if(ACCESS_ADMIN in access)
			return TRUE
		if(ACCESS_MEDICAL in access)
			return TRUE
	return FALSE

/obj/item/storage/pill_bottle/scp500/proc/log_scp500_usage(mob/living/carbon/human/administer, mob/living/carbon/human/patient, reason)
	var/entry = list(
		"time" = gameTimestamp("hh:mm"),
		"administered_by" = administer.ckey,
		"administered_by_name" = administer.real_name,
		"patient" = patient.ckey,
		"patient_name" = patient.real_name,
		"reason" = reason || "Not specified",
	)
	logged_usage += list(entry)
	log_game("SCP-500 usage: [key_name(administer)] administered to [key_name(patient)]. Reason: [reason || "Not specified"]")
	if(GLOB.scp_admin_log)
		GLOB.scp_admin_log.log_event("medical", "SCP-500", administer.ckey, patient.ckey, "[administer.real_name] administered pill to [patient.real_name]. Reason: [reason || "Not specified"]", 2)
	hook_scp_interaction(administer, "SCP-500", INTERACTION_TYPE_MEDICAL)
	if(administer != patient)
		hook_scp_interaction(patient, "SCP-500", INTERACTION_TYPE_MEDICAL)

/obj/item/storage/pill_bottle/scp500/proc/log_scp500_unauthorized(mob/living/carbon/human/H)
	log_game("SCP-500 unauthorized access attempt by [key_name(H)]")
	if(GLOB.scp_admin_log)
		GLOB.scp_admin_log.log_event("security", "SCP-500", H.ckey, null, "Unauthorized access attempt by [H.real_name] ([H.job])", 2)

/obj/item/reagent_containers/pill/scp500
	name = "SCP-500 pill"
	desc = "A small red pill. It is said to cure any disease, poison, or affliction when consumed. Authorization and logging required."
	icon_state = "pill4"
	color = "#ff0000"
	var/usage_reason = ""
	var/authorized_user

/obj/item/reagent_containers/pill/scp500/Initialize()
	. = ..()

/obj/item/reagent_containers/pill/scp500/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/storage/pill_bottle/scp500/bottle = loc
	if(istype(bottle) && !bottle.check_authorization(H))
		to_chat(H, span_warning("You are not authorized to use SCP-500!"))
		bottle.log_scp500_unauthorized(H)
		return
	usage_reason = input(H, "Enter reason for SCP-500 usage:", "Medical Authorization") as text|null
	if(!usage_reason)
		to_chat(H, span_warning("Usage reason required for SCP-500."))
		return
	authorized_user = H
	H.visible_message(span_notice("[H] prepares to swallow a small red pill..."), span_notice("You prepare to take the SCP-500 pill. Reason: [usage_reason]"))
	. = ..()

/obj/item/reagent_containers/pill/scp500/attack(mob/living/target, mob/user)
	if(!ishuman(user) || !ishuman(target))
		return ..()
	var/mob/living/carbon/human/H = user
	var/obj/item/storage/pill_bottle/scp500/bottle = loc
	if(istype(bottle) && !bottle.check_authorization(H))
		to_chat(H, span_warning("You are not authorized to administer SCP-500!"))
		bottle.log_scp500_unauthorized(H)
		return
	usage_reason = input(H, "Enter reason for administering SCP-500 to [target]:", "Medical Authorization") as text|null
	if(!usage_reason)
		to_chat(H, span_warning("Usage reason required for SCP-500."))
		return
	authorized_user = H
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
	if(H.stamina)
		H.stamina.adjust(H.stamina.maximum - H.stamina.current)
	H.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
	H.reagents?.remove_all()
	H.SetUnconscious(0)
	H.SetStun(0)
	H.SetParalyzed(0)
	H.SetImmobilized(0)
	H.SetSleeping(0)
	H.hallucination = 0
	H.drowsyness = 0

	for(var/datum/brain_trauma/T in H.get_traumas())
		if(!istype(T, /datum/brain_trauma/special))
			qdel(T)

	if(H.sanity)
		H.sanity.adjust_sanity(30, "scp500_cure")

	H.RemoveElement(/datum/element/scp513_stalked)

	H.visible_message(span_notice("[H] swallows a small red pill and immediately looks completely revitalized!"), span_notice("You swallow the red pill. Every ache, every illness, every affliction vanishes instantly. You feel perfect."))

	if(istype(loc, /obj/item/storage/pill_bottle/scp500))
		var/obj/item/storage/pill_bottle/scp500/bottle = loc
		bottle.log_scp500_usage(user || H, H, usage_reason)
	else
		log_game("SCP-500 usage: [key_name(user || H)] administered to [key_name(H)]. Reason: [usage_reason || "Not specified"]")
		if(GLOB.scp_admin_log)
			GLOB.scp_admin_log.log_event("medical", "SCP-500", (user || H).ckey, H.ckey, "Pill administered. Reason: [usage_reason || "Not specified"]", 2)
		hook_scp_interaction(H, "SCP-500", INTERACTION_TYPE_MEDICAL)
		if(user && user != H)
			hook_scp_interaction(user, "SCP-500", INTERACTION_TYPE_MEDICAL)

/obj/item/reagent_containers/pill/scp500/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A small red pill from SCP-500. One dose cures any disease or affliction."))
	var/pills_remaining = 0
	if(istype(loc, /obj/item/storage/pill_bottle/scp500))
		var/obj/item/storage/pill_bottle/scp500/bottle = loc
		for(var/obj/item/reagent_containers/pill/scp500/P in bottle)
			pills_remaining++
		to_chat(user, span_notice("Jar contains [pills_remaining] pill\s remaining."))
	else
		to_chat(user, span_notice("This pill has been removed from its container. Use with authorization only."))
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.SCP)
			to_chat(user, span_warning("All usage must be logged with a medical reason. Unauthorized use is grounds for immediate termination."))
