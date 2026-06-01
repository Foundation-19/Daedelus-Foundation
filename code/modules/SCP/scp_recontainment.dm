/obj/machinery/scp_femur_breaker
	name = "Femur Breaker"
	desc = "A containment device used to lure SCP-106 back to its cell. Requires a human subject."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
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
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-106"]
		scp106_status = instance.containment_status
	data["scp106_status"] = scp106_status

	return data

/obj/machinery/scp_femur_breaker/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
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
		to_chat(activator, span_warning("The Femur Breaker requires a subject."))
		return

	for(var/mob/living/carbon/human/H in src)
		H.adjustBruteLoss(80)
		H.emote("scream")
		visible_message(span_danger("The Femur Breaker activates! [H] screams in agony!"))

		if(SSscp_persistence && SSscp_persistence.manager)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-106"]
			if(instance && instance.containment_status == "breached")
				priority_announce("ATTENTION: Femur Breaker protocol activated. SCP-106 is being lured back to containment.", null, null, ANNOUNCER_ALERT)
				addtimer(CALLBACK(src, .proc/complete_femur_breaker, H), 300)

		H.forceMove(get_turf(src))
		occupied = FALSE
		return

/obj/machinery/scp_femur_breaker/proc/complete_femur_breaker(mob/living/carbon/human/victim)
	if(!SSscp_persistence || !SSscp_persistence.manager)
		return
	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-106"]
	if(instance)
		instance.containment_status = "contained"
		instance.containment_health = 100
		if(!QDELETED(victim))
			instance.add_interaction_record(victim, "femur_breaker_recontainment")
		else
			instance.add_interaction_record(null, "femur_breaker_recontainment")
		SSscp_persistence?.manager?.active_breaches = max(0, SSscp_persistence?.manager?.active_breaches - 1)
		SSscp_persistence?.manager?.global_containment_stability = min(100, SSscp_persistence?.manager?.global_containment_stability + 5)

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

		user.visible_message(span_danger("[user] attempts to place the containment bag over SCP-096's head!"))
		if(do_after(user, 30, target = S))
			var/hood = new /obj/item/clothing/head/scp096_hood()
			S.equip_to_slot_or_del(hood, ITEM_SLOT_HEAD)
			S.emote("scream")
			to_chat(user, span_notice("You place the containment bag over SCP-096's head!"))
			qdel(src)
		found_scp = TRUE
		break
	if(!found_scp)
		to_chat(user, span_warning("No nearby SCP-096 without head covering."))

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
		H.visible_message(span_notice("SCP-096's face is now covered."))

/obj/item/scp173_blink_kit
	name = "SCP-173 Observation Kit"
	desc = "A kit containing eye drops and stimulants to help maintain visual contact with SCP-173."
	var/uses = 5

/obj/item/scp173_blink_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(uses <= 0)
		to_chat(user, span_warning("The kit is empty."))
		return

	uses--
	var/mob/living/carbon/human/H = user
	if(H.stamina)
		H.stamina.adjust(30)
	to_chat(H, span_notice("You apply the eye drops and stimulants. Your eyes feel refreshed!"))
	H.set_drugginess(10)

/obj/machinery/scp457_suppression
	name = "SCP-457 Fire Suppression Unit"
	desc = "A specialized fire suppression system designed for recontaining SCP-457."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "bluespace-prison"
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
		to_chat(user, span_warning("Insufficient charge. Current: [round(suppression_charge)]%"))
		return

	var/confirm = alert(user, "Activate fire suppression? Charge: [round(suppression_charge)]%", "Suppression", "Activate", "Cancel")
	if(confirm != "Activate")
		return

	suppression_charge -= 30
	visible_message(span_notice("[src] discharges a massive blast of fire retardant!"))
	playsound(src, 'sound/effects/spray.ogg', 50, TRUE, extrarange = 5)

	for(var/mob/living/L in range(5, src))
		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			if(H.on_fire)
				H.extinguish_mob()
		else if(istype(L, /mob/living/scp/scp457))
			var/mob/living/scp/scp457/scp = L
			if(scp) scp.current_heat = max(0, scp.current_heat - 50)
			scp.Stun(60)
			scp.visible_message(span_danger("The retardant blasts SCP-457, suppressing its flames!"))
			var/turf/target_turf = get_turf(src)
			for(var/turf/T in range(2, src))
				if(istype(T.loc, /area/scp/hcz) || istype(T.loc, /area/scp/hcz))
					target_turf = T
					break
			if(target_turf != get_turf(scp))
				scp.forceMove(target_turf)
			if(SSscp_persistence?.manager?.scp_instances?["SCP-457"])
				var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-457"]
				if(instance.containment_status == "breached")
					instance.containment_status = "contained"
					instance.containment_health = 100
					SSscp_persistence?.manager?.active_breaches = max(0, SSscp_persistence?.manager?.active_breaches - 1)
			hook_scp_recontainment("SCP-457", list(user))
			priority_announce("SCP-457 has been suppressed and returned to containment.", null, null, ANNOUNCER_DEFAULT)

/obj/machinery/scp049_cure_station
	name = "SCP-049 Containment Lure"
	desc = "A device that broadcasts a signal designed to lure SCP-049 back to containment."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
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
		var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-049"]
		if(instance && instance.containment_status == "breached")
			hook_scp_recontainment("SCP-049", list())

/obj/machinery/scp008_incinerator
	name = "SCP-008 Biohazard Incinerator"
	desc = "A specialized incinerator for neutralizing SCP-008 infected material and zombies."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "explosive_compressor"
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
		if(SSscp_persistence?.manager?.scp_instances?["SCP-008"])
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-008"]
			if(instance.containment_status == "breached")
				instance.containment_status = "contained"
				instance.containment_health = 100
				SSscp_persistence?.manager?.active_breaches = max(0, SSscp_persistence?.manager?.active_breaches - 1)
		hook_scp_recontainment("SCP-008", list())
		priority_announce("SCP-008 biohazard incineration complete. [zombies_destroyed] instances neutralized.", null, null, ANNOUNCER_DEFAULT)
	else
		visible_message(span_notice("The incinerator shuts down. No SCP-008 instances detected."))

/obj/machinery/scp1507_speaker
	name = "SCP-1507 Pacification Speaker"
	desc = "A speaker system that broadcasts calming sounds to pacify SCP-1507 flocks."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
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
	icon_state = "server"
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
	icon_state = "bluespace-prison"
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
	icon_state = "bluespace-prison"
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
		reptile.Stun(80)
		reptile.visible_message(span_danger("Acid sprays over SCP-682! It thrashes in pain and is driven back!"))
		var/turf/target_turf = get_turf(src)
		for(var/turf/T in range(2, src))
			if(istype(T.loc, /area/scp/hcz) || istype(T.loc, /area/scp/hcz))
				target_turf = T
				break
		if(target_turf != get_turf(reptile))
			reptile.forceMove(target_turf)
		if(SSscp_persistence?.manager?.scp_instances?["SCP-682"])
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-682"]
			if(instance.containment_status == "breached")
				instance.containment_status = "contained"
				instance.containment_health = 100
				SSscp_persistence?.manager?.active_breaches = max(0, SSscp_persistence?.manager?.active_breaches - 1)
	hook_scp_recontainment("SCP-682", list(user))
	priority_announce("SCP-682 has been driven back to containment via acid deployment.", null, null, ANNOUNCER_DEFAULT)

/obj/machinery/scp939_dampener
	name = "SCP-939 Sonic Dampener"
	desc = "A device that emits a counter-frequency to disorient SCP-939, preventing its voice mimicry and pack coordination."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "ecto_sniffer"
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
	playsound(src, 'sound/machines/defib_zap.ogg', 50, TRUE, extrarange = 5)
	for(var/mob/living/scp/scp939/target in range(10, src))
		target.Stun(60)
		target.Stun(40)
		to_chat(target, span_warning("A piercing frequency disrupts your senses! Your voice mimicry is impaired!"))
		var/turf/target_turf = get_turf(src)
		for(var/turf/T in range(2, src))
			if(istype(T.loc, /area/scp/hcz))
				target_turf = T
				break
		if(target_turf != get_turf(target))
			target.forceMove(target_turf)
		if(SSscp_persistence?.manager?.scp_instances?["SCP-939"])
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances["SCP-939"]
			if(instance.containment_status == "breached")
				instance.containment_status = "contained"
				instance.containment_health = 100
				SSscp_persistence?.manager?.active_breaches = max(0, SSscp_persistence?.manager?.active_breaches - 1)
	hook_scp_recontainment("SCP-939", list(user))
	priority_announce("SCP-939 has been neutralized via sonic dampener and returned to containment.", null, null, ANNOUNCER_DEFAULT)
	addtimer(CALLBACK(src, .proc/deactivate_dampener), dampen_duration)

/obj/machinery/scp939_dampener/proc/deactivate_dampener()
	active = FALSE
	visible_message(span_notice("[src] powers down."))

/obj/machinery/scp1471_memory_wipe
	name = "SCP-1471 Memetic Cleanser"
	desc = "A device that performs targeted memory alteration to remove SCP-1471's influence from affected subjects."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "d_analyzer"
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
	icon_state = "d_analyzer"
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

// SCP-073 Recontainment - Pacification Field
/obj/machinery/scp073_pacification_field
	name = "Pacification Field Emitter"
	desc = "A device that suppresses SCP-073's damage reflection, allowing safe physical contact."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "bluespace-prison"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	var/active = FALSE
	var/duration = 600
	var/cooldown = 0
	var/cooldown_time = 1200

/obj/machinery/scp073_pacification_field/attack_hand(mob/user)
	if(cooldown > world.time)
		to_chat(user, span_warning("Emitter is recharging."))
		return
	if(!active)
		active = TRUE
		cooldown = world.time + cooldown_time
		visible_message(span_notice("[src] hums to life, projecting a pacification field!"))
		addtimer(CALLBACK(src, .proc/deactivate), duration)
	else
		to_chat(user, span_warning("Already active."))
	return

/obj/machinery/scp073_pacification_field/proc/deactivate()
	active = FALSE
	visible_message(span_notice("[src] powers down, the pacification field fades."))

/obj/machinery/scp073_pacification_field/proc/is_active()
	return active

// SCP-076 Recontainment - Sarcophagus Sealing Terminal
/obj/machinery/scp076_sealing_terminal
	name = "SCP-076 Sealing Terminal"
	desc = "A terminal for remotely sealing SCP-076-1's sarcophagus and monitoring SCP-076-2's status."
	icon = 'icons/obj/computer.dmi'
	icon_state = "generic"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/scp076_sealing_terminal

/obj/machinery/scp076_sealing_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Scp076Sealing", "SCP-076 Sealing Control")
		ui.open()

/obj/machinery/scp076_sealing_terminal/ui_data(mob/user)
	var/list/data = list()
	var/obj/structure/scp076_sarcophagus/sarc = locate() in range(20, src)
	data["sarcophagus_found"] = !!sarc
	data["scp_state"] = "unknown"
	data["respawn_count"] = 0
	data["max_respawns"] = 5
	if(sarc && sarc.contained_scp)
		data["scp_state"] = sarc.contained_scp.current_state
		data["respawn_count"] = sarc.contained_scp.respawn_count
		data["max_respawns"] = sarc.contained_scp.max_respawns
	return data

/obj/machinery/scp076_sealing_terminal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("force_seal")
			var/obj/structure/scp076_sarcophagus/sarc = locate() in range(20, src)
			if(sarc && sarc.contained_scp)
				if(sarc.contained_scp.current_state == "dormant" || sarc.contained_scp.current_state == "deceased")
					sarc.contained_scp.forceMove(sarc)
					sarc.contained_scp.stat = UNCONSCIOUS
					sarc.contained_scp.current_state = "dormant"
					sarc.contained_scp.dormant_timer = world.time + sarc.contained_scp.dormant_duration
					hook_scp_recontainment("SCP-076", list(ui.user))
					priority_announce("SCP-076-1 sarcophagus has been sealed remotely. SCP-076-2 forced into dormant state.", null, null, ANNOUNCER_DEFAULT)
				else
					to_chat(ui.user, span_warning("Cannot seal while SCP-076-2 is active!"))
			. = TRUE

/obj/item/circuitboard/computer/scp076_sealing_terminal
	name = "SCP-076 Sealing Terminal (Computer Board)"
	build_path = /obj/machinery/scp076_sealing_terminal

// SCP-1128 Recontainment - Water Drainage Valve
/obj/machinery/scp1128_drain_valve
	name = "Emergency Water Drainage Valve"
	desc = "An emergency valve that drains water from the area, preventing SCP-1128 manifestation."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	var/active = FALSE
	var/drain_radius = 7
	var/cooldown = 0
	var/cooldown_time = 1800

/obj/machinery/scp1128_drain_valve/attack_hand(mob/user)
	if(cooldown > world.time)
		to_chat(user, span_warning("Drain valve is on cooldown."))
		return
	if(!active)
		active = TRUE
		cooldown = world.time + cooldown_time
		visible_message(span_notice("[src] opens, draining water from the area!"))
		playsound(src, 'sound/effects/slosh.ogg', 50, TRUE, extrarange = 10)
		drain_water()
		addtimer(CALLBACK(src, .proc/close_valve), 300)
	else
		to_chat(user, span_warning("Already draining."))

/obj/machinery/scp1128_drain_valve/proc/drain_water()
	for(var/turf/open/water/W in range(drain_radius, src))
		var/turf/open/floor/F = W.ChangeTurf(/turf/open/floor/iron)
		if(F)
			F.name = "damp floor"
			F.desc = "The floor is wet from recently drained water."
	hook_scp_recontainment("SCP-1128", list())

/obj/machinery/scp1128_drain_valve/proc/close_valve()
	active = FALSE
	visible_message(span_notice("[src] closes as the drainage completes."))
