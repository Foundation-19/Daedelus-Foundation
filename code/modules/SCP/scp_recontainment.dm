/obj/machinery/scp_femur_breaker
	name = "Femur Breaker"
	desc = "A containment device used to lure SCP-106 back to its cell. Requires a human subject."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "centrifuge"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/occupied = FALSE
	var/activation_progress = 0
	var/activation_threshold = 100
	var/lure_active = FALSE
	var/mob/living/carbon/human/victim

/obj/machinery/scp_femur_breaker/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpFemurBreaker", "SCP-106 FEMUR BREAKER")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/scp_femur_breaker/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp_femur_breaker/ui_data(mob/user)
	var/list/data = list()
	data["occupied"] = occupied
	data["activation_progress"] = activation_progress
	data["activation_threshold"] = activation_threshold
	data["lure_active"] = lure_active
	data["completed"] = (activation_progress >= activation_threshold)

	data["victim_name"] = victim ? victim.real_name : "None"
	data["victim_health"] = 0
	if(victim)
		data["victim_health"] = round((victim.health / victim.maxHealth) * 100)

	var/scp106_status = "unknown"
	if(SSscp_persistence?.manager?.scp_instances?["SCP-106"])
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-106"]
		scp106_status = instance.containment_status
	data["scp106_status"] = scp106_status

	return data

/obj/machinery/scp_femur_breaker/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	switch(action)
		if("enter")
			if(occupied)
				return
			occupied = TRUE
			victim = H
			H.forceMove(src)
			H.visible_message(span_danger("[H] enters the Femur Breaker!"))
			. = TRUE
		if("activate")
			if(!occupied || !victim || lure_active)
				return
			activate(H)
			. = TRUE

/obj/machinery/scp_femur_breaker/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/scp_femur_breaker/proc/activate(mob/activator)
	if(!occupied)
		to_chat(activator, "<span class='warning'>The Femur Breaker requires a subject.</span>")
		return

	for(var/mob/living/carbon/human/H in src)
		H.adjustBruteLoss(80)
		H.emote("scream")
		visible_message("<span class='danger'>The Femur Breaker activates! [H] screams in agony!</span>")

		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-106"]
			if(instance && instance.containment_status == "breached")
				priority_announce("ATTENTION: Femur Breaker protocol activated. SCP-106 is being lured back to containment.", null, null, ANNOUNCER_ALERT)
				addtimer(CALLBACK(src, .proc/complete_femur_breaker, H), 300)

		H.forceMove(get_turf(src))
		occupied = FALSE
		return

/obj/machinery/scp_femur_breaker/proc/complete_femur_breaker(mob/living/carbon/human/victim)
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-106"]
	if(instance)
		instance.containment_status = "contained"
		instance.containment_health = 100
		if(!QDELETED(victim))
			instance.add_interaction_record(victim, "femur_breaker_recontainment")
		else
			instance.add_interaction_record(null, "femur_breaker_recontainment")
		SSscp_persistence.manager.active_breaches = max(0, SSscp_persistence.manager.active_breaches - 1)
		SSscp_persistence.manager.global_containment_stability = min(100, SSscp_persistence.manager.global_containment_stability + 5)

	var/list/recontain_list = !QDELETED(victim) ? list(victim) : list()
	hook_scp_recontainment("SCP-106", recontain_list)
	priority_announce("SCP-106 has been recontained via Femur Breaker protocol.", null, null, ANNOUNCER_DEFAULT)

/obj/item/scp096_bag
	name = "SCP-096 Containment Bag"
	desc = "A reinforced bag designed to be placed over SCP-096's head to prevent further enrage triggers."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "muzzle"

/obj/item/scp096_bag/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/found_scp = FALSE
	for(var/mob/living/scp/scp096/S in oview(1, H))

		user.visible_message("<span class='danger'>[user] attempts to place the containment bag over SCP-096's head!</span>")
		if(do_after(user, 30, target = S))
			var/hood = new /obj/item/clothing/head/scp096_hood()
			S.equip_to_slot_or_del(hood, ITEM_SLOT_HEAD)
			S.emote("scream")
			to_chat(user, "<span class='notice'>You place the containment bag over SCP-096's head!</span>")
			qdel(src)
		found_scp = TRUE
		break
	if(!found_scp)
		to_chat(user, "<span class='warning'>No nearby SCP-096 without head covering.</span>")

/obj/item/clothing/head/scp096_hood
	name = "SCP-096 Containment Hood"
	desc = "A reinforced hood placed over SCP-096's head to prevent enrage triggers."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "muzzle"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	var/can_trigger = FALSE

/obj/item/clothing/head/scp096_hood/equipped(mob/living/carbon/human/H, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD && istype(H, /mob/living/scp/scp096))
		can_trigger = FALSE
		H.visible_message("<span class='notice'>SCP-096's face is now covered.</span>")

/obj/item/scp173_blink_kit
	name = "SCP-173 Observation Kit"
	desc = "A kit containing eye drops and stimulants to help maintain visual contact with SCP-173."
	var/uses = 5

/obj/item/scp173_blink_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(uses <= 0)
		to_chat(user, "<span class='warning'>The kit is empty.</span>")
		return

	uses--
	var/mob/living/carbon/human/H = user
	if(H.stamina)
		H.stamina.adjust(30)
	to_chat(H, "<span class='notice'>You apply the eye drops and stimulants. Your eyes feel refreshed!</span>")
	H.set_drugginess(10)

/obj/machinery/scp457_suppression
	name = "SCP-457 Fire Suppression Unit"
	desc = "A specialized fire suppression system designed for recontaining SCP-457."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "mass_driver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/suppression_charge = 100
	var/max_charge = 100
	var/recharge_rate = 0.5

/obj/machinery/scp457_suppression/process()
	if(suppression_charge < max_charge)
		suppression_charge = min(max_charge, suppression_charge + recharge_rate)

/obj/machinery/scp457_suppression/attack_hand(mob/user)
	if(!ishuman(user))
		return

	if(suppression_charge < 30)
		to_chat(user, "<span class='warning'>Insufficient charge. Current: [round(suppression_charge)]%</span>")
		return

	var/confirm = alert(user, "Activate fire suppression? Charge: [round(suppression_charge)]%", "Suppression", "Activate", "Cancel")
	if(confirm != "Activate")
		return

	suppression_charge -= 30
	visible_message("<span class='notice'>[src] discharges a massive blast of fire retardant!</span>")

	for(var/mob/living/L in range(5, src))
		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			if(H.on_fire)
				H.extinguish_mob()

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-457"]
		if(instance && instance.containment_status == "breached")
			hook_scp_recontainment("SCP-457", list(user))
			priority_announce("SCP-457 has been suppressed via fire containment system.", null, null, ANNOUNCER_DEFAULT)

/obj/machinery/scp049_cure_station
	name = "SCP-049 Containment Lure"
	desc = "A device that broadcasts a signal designed to lure SCP-049 back to containment."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "cellcharger"
	density = TRUE
	anchored = TRUE
	var/lure_active = FALSE
	var/lure_duration = 300
	var/lure_cooldown = 0

/obj/machinery/scp049_cure_station/attack_hand(mob/user)
	if(!ishuman(user))
		return

	if(lure_active)
		to_chat(user, span_warning("The lure is already active."))
		return

	if(world.time < lure_cooldown)
		to_chat(user, span_warning("The lure is recharging. Ready in [round((lure_cooldown - world.time) / 10)] seconds."))
		return

	if(!ishuman(user))
		to_chat(user, span_warning("Requires Science access."))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(user, span_warning("Requires Science access."))
		return

	lure_active = TRUE
	lure_cooldown = world.time + 600
	visible_message(span_notice("[src] begins broadcasting the containment lure signal."))
	priority_announce("SCP-049 containment lure protocol activated. The Doctor is being called back.", null, null, ANNOUNCER_DEFAULT)

	lure_scp049()

	addtimer(CALLBACK(src, .proc/deactivate_lure), lure_duration)

/obj/machinery/scp049_cure_station/proc/lure_scp049()
	for(var/mob/living/scp/scp049/scp in GLOB.mob_list)
		if(QDELETED(scp))
			continue
		if(scp.stat == DEAD)
			continue
		to_chat(scp, span_danger("You sense the call of the Pestilence... something draws you toward containment."))
		scp.lure_target = get_turf(src)
		addtimer(CALLBACK(src, .proc/guide_scp049, scp), 2 SECONDS)

/obj/machinery/scp049_cure_station/proc/guide_scp049(mob/living/scp/scp049/scp)
	if(!lure_active || !scp || scp.stat == DEAD)
		return
	if(get_dist(scp, src) <= 2)
		scp.lure_target = null
		return
	if(scp.lure_target != get_turf(src))
		return
	var/turf/T = get_step_towards(scp, src)
	if(T)
		scp.Move(T)
	addtimer(CALLBACK(src, .proc/guide_scp049, scp), 0.5 SECONDS)

/obj/machinery/scp049_cure_station/proc/deactivate_lure()
	lure_active = FALSE
	visible_message(span_notice("[src] stops broadcasting."))

	for(var/mob/living/scp/scp049/scp in GLOB.mob_list)
		if(QDELETED(scp))
			continue
		scp.lure_target = null

	if(SSscp_persistence && SSscp_persistence.manager)
		var/datum/scp_instance/instance = SSscp_persistence.manager.scp_instances["SCP-049"]
		if(instance && instance.containment_status == "breached")
			hook_scp_recontainment("SCP-049", list())

/obj/machinery/scp008_incinerator
	name = "SCP-008 Biohazard Incinerator"
	desc = "A specialized incinerator for neutralizing SCP-008 infected material and zombies."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "incinerator"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/active = FALSE
	var/burn_duration = 300

/obj/machinery/scp008_incinerator/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(active)
		to_chat(user, span_warning("The incinerator is already running."))
		return
	var/confirm = alert(user, "Activate the biohazard incinerator? This will destroy all SCP-008 instances in range.", "Incinerator", "Activate", "Cancel")
	if(confirm != "Activate")
		return
	active = TRUE
	visible_message(span_danger("[src] roars to life! Intense heat washes over the area!"))
	addtimer(CALLBACK(src, .proc/complete_incineration), burn_duration)

/obj/machinery/scp008_incinerator/proc/complete_incineration()
	active = FALSE
	var/zombies_destroyed = 0
	for(var/mob/living/simple_animal/hostile/scp008_zombie/Z in range(7, src))
		Z.visible_message(span_danger("[Z] is consumed by the incinerator's flames!"))
		Z.ghostize()
		qdel(Z)
		zombies_destroyed++
	if(zombies_destroyed > 0)
		hook_scp_recontainment("SCP-008", list())
		priority_announce("SCP-008 biohazard incineration complete. [zombies_destroyed] instances neutralized.", null, null, ANNOUNCER_DEFAULT)
	else
		visible_message(span_notice("The incinerator shuts down. No SCP-008 instances detected."))

/obj/machinery/scp1507_speaker
	name = "SCP-1507 Pacification Speaker"
	desc = "A speaker system that broadcasts calming sounds to pacify SCP-1507 flocks."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "speaker"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	var/active = FALSE
	var/pacification_duration = 600

/obj/machinery/scp1507_speaker/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SCIENCE in id_card.access))
		to_chat(user, span_warning("Requires Science access."))
		return
	if(active)
		to_chat(user, span_warning("The speaker is already active."))
		return
	active = TRUE
	visible_message(span_notice("[src] begins playing calming ambient sounds."))
	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(10, src))
		F.melee_damage_lower = 0
		F.melee_damage_upper = 0
		F.combat_mode = FALSE
		to_chat(F, span_notice("The soothing sounds calm your aggressive instincts."))
	hook_scp_recontainment("SCP-1507", list())
	addtimer(CALLBACK(src, .proc/deactivate_speaker), pacification_duration)

/obj/machinery/scp1507_speaker/proc/deactivate_speaker()
	active = FALSE
	visible_message(span_notice("[src] stops playing."))
	for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(10, src))
		F.melee_damage_lower = initial(F.melee_damage_lower)
		F.melee_damage_upper = initial(F.melee_damage_upper)
		F.combat_mode = initial(F.combat_mode)

/obj/machinery/scp263_remote_shutoff
	name = "SCP-263 Remote Shutoff"
	desc = "A device that can remotely disable SCP-263's anomalous broadcast."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "flasher"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	var/cooldown = 0
	var/cooldown_time = 300 SECONDS

/obj/machinery/scp263_remote_shutoff/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(world.time < cooldown)
		to_chat(user, span_warning("Device recharging. Ready in [round((cooldown - world.time) / 10)] seconds."))
		return
	var/confirm = alert(user, "Transmit shutoff signal to SCP-263?", "Remote Shutoff", "Transmit", "Cancel")
	if(confirm != "Transmit")
		return
	cooldown = world.time + cooldown_time
	for(var/obj/machinery/scp263/tv in SSmachines.processing)
		if(tv.active)
			tv.deactivate()
			hook_scp_recontainment("SCP-263", list(user))
			priority_announce("SCP-263 has been remotely deactivated.", null, null, ANNOUNCER_DEFAULT)
			return
	to_chat(user, span_warning("No active SCP-263 instance detected."))

/obj/machinery/scp3199_cryo_unit
	name = "SCP-3199 Cryogenic Storage"
	desc = "A cryogenic unit capable of freezing SCP-3199 eggs to prevent hatching."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "sleeper"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

/obj/machinery/scp3199_cryo_unit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/scp3199_egg))
		if(!powered())
			to_chat(user, span_warning("The cryogenic unit has no power!"))
			return
		user.dropItemToGround(I)
		I.forceMove(src)
		visible_message(span_notice("[user] places the egg into the cryogenic storage unit."))
		var/obj/item/scp3199_egg/egg = I
		egg.hatching_cooldown = -1
		hook_scp_recontainment("SCP-3199", list(user))
		return
	return ..()

/obj/machinery/scp682_containment_chamber
	name = "SCP-682 Containment Chamber Controls"
	desc = "Controls for the specialized containment chamber holding SCP-682. Includes hydrochloric acid dispensers."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "mass_driver"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	var/acid_cooldown = 0
	var/acid_cooldown_time = 600 SECONDS

/obj/machinery/scp682_containment_chamber/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_SECURITY in id_card.access))
		to_chat(user, span_warning("Requires Security access."))
		return
	if(world.time < acid_cooldown)
		to_chat(user, span_warning("Acid dispensers recharging. Ready in [round((acid_cooldown - world.time) / 10)] seconds."))
		return
	var/confirm = alert(user, "Deploy hydrochloric acid to SCP-682's containment area?", "Containment", "Deploy", "Cancel")
	if(confirm != "Deploy")
		return
	acid_cooldown = world.time + acid_cooldown_time
	priority_announce("SCP-682 containment protocol activated. Deploying hydrochloric acid.", null, null, ANNOUNCER_ALERT)
	for(var/mob/living/scp/scp682/reptile in range(5, src))
		reptile.adjustFireLoss(150)
		reptile.visible_message(span_danger("Acid sprays over SCP-682! It thrashes in pain!"))
	hook_scp_recontainment("SCP-682", list(user))

/obj/machinery/scp939_dampener
	name = "SCP-939 Sonic Dampener"
	desc = "A device that emits a counter-frequency to disorient SCP-939, preventing its voice mimicry and pack coordination."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "emitter"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 150
	var/active = FALSE
	var/dampen_duration = 600

/obj/machinery/scp939_dampener/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(active)
		to_chat(user, span_warning("The dampener is already active."))
		return
	if(!powered())
		to_chat(user, span_warning("No power available."))
		return
	active = TRUE
	visible_message(span_notice("[src] emits a low hum as counter-frequencies fill the air."))
	for(var/mob/living/scp/scp939/target in range(10, src))
		target.set_confusion_if_lower(30)
		to_chat(target, span_warning("A piercing frequency disrupts your senses! Your voice mimickry is impaired!"))
	hook_scp_recontainment("SCP-939", list(user))
	addtimer(CALLBACK(src, .proc/deactivate_dampener), dampen_duration)

/obj/machinery/scp939_dampener/proc/deactivate_dampener()
	active = FALSE
	visible_message(span_notice("[src] powers down."))

/obj/machinery/scp1471_memory_wipe
	name = "SCP-1471 Memetic Cleanser"
	desc = "A device that performs targeted memory alteration to remove SCP-1471's influence from affected subjects."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "mindshelf"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	var/cooldown = 0
	var/cooldown_time = 300 SECONDS

/obj/machinery/scp1471_memory_wipe/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(world.time < cooldown)
		to_chat(user, span_warning("Device recharging."))
		return
	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in range(1, src))
		candidates += H
	if(!length(candidates))
		to_chat(user, span_warning("No subjects in range. Have them stand next to the device."))
		return
	var/mob/living/carbon/human/target = input(user, "Select subject for memetic cleansing:", "Memory Wipe") as null|anything in candidates
	if(!target)
		return
	cooldown = world.time + cooldown_time
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15)
	target.drowsyness = 0
	target.hallucination = 0
	to_chat(target, span_warning("A sharp pain lances through your skull! Your memories of... something... fade away."))
	visible_message(span_notice("[src] activates, cleansing [target]'s memetic contamination."))
	for(var/obj/item/device/scp1471/phone in target.get_all_contents())
		phone.manifestation_level = max(0, phone.manifestation_level - 50)
		phone.view_count = max(0, phone.view_count - 5)
	for(var/obj/effect/scp1471_entity/entity in range(20, src))
		if(entity.target == target)
			qdel(entity)
	hook_scp_recontainment("SCP-1471", list(user, target))

/obj/machinery/scp427_reversal
	name = "SCP-427 Cellular Stabilizer"
	desc = "A medical device that can reverse early-stage SCP-427 transformation if applied before full conversion."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "medscan"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/cooldown = 0
	var/cooldown_time = 120 SECONDS

/obj/machinery/scp427_reversal/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(world.time < cooldown)
		to_chat(user, span_warning("Device recharging."))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(!id_card || !(ACCESS_MEDICAL in id_card.access))
		to_chat(user, span_warning("Requires Medical access."))
		return
	var/list/candidates = list()
	for(var/mob/living/carbon/human/target in range(1, src))
		candidates += target
	if(!length(candidates))
		to_chat(user, span_warning("No subjects in range."))
		return
	var/mob/living/carbon/human/patient = input(user, "Select subject for cellular stabilization:", "Stabilizer") as null|anything in candidates
	if(!patient)
		return
	cooldown = world.time + cooldown_time
	patient.adjustBruteLoss(-30)
	patient.adjustToxLoss(-20)
	patient.adjustFireLoss(-20)
	to_chat(patient, span_notice("A soothing wave washes over you. Your cells feel stable again."))
	visible_message(span_notice("[src] stabilizes [patient]'s cellular structure."))
	hook_scp_recontainment("SCP-427", list(user, patient))
