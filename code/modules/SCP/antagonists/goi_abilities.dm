// GOI Antagonist Abilities — Real Mechanics
// Replaces stub actions with functional gameplay abilities
// Uses /datum/action/innate/scp_ability as base for cooldown support

// ================================================================
// SARKIC CULTIST — Fleshcraft & Biomancy
// ================================================================

/datum/action/innate/scp_ability/sarkic_fleshcraft
	name = "Fleshcraft"
	desc = "Shape flesh to heal yourself or convert a willing victim."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"
	cooldown_time = 30 SECONDS

/datum/action/innate/scp_ability/sarkic_fleshcraft/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	var/list/choices = list("Heal Self", "Convert Target", "Flesh Shield")
	var/choice = input(H, "Choose a ritual:", "Sarkic Fleshcraft") as null|anything in choices
	if(!choice)
		return
	switch(choice)
		if("Heal Self")
			H.adjustBruteLoss(-25)
			H.adjustFireLoss(-25)
			H.adjustToxLoss(-15)
			H.visible_message(span_warning("[H]'s flesh writhes and mends!"), span_notice("Your flesh knits itself back together."))
			hook_scp_interaction(H, "SARKIC", INTERACTION_TYPE_MEDICAL)
		if("Convert Target")
			var/mob/living/carbon/human/target = null
			for(var/mob/living/carbon/human/T in view(1, H))
				if(T != H && T.stat != DEAD)
					target = T
					break
			if(!target)
				to_chat(H, span_warning("No valid target in range."))
				return
			if(target.stat == DEAD)
				to_chat(H, span_warning("The flesh is cold — they are beyond conversion."))
				return
			if("sarkic" in target.faction)
				to_chat(H, span_notice("[target] is already one with the flesh."))
				return
			if(do_after(H, 5 SECONDS, target))
				target.faction |= "sarkic"
				var/datum/antagonist/sarkic_cult/A = new()
				target.mind.add_antag_datum(A)
				target.adjustBruteLoss(-15)
				target.adjustFireLoss(-15)
				target.visible_message(span_warning("[target]'s skin ripples as dark veins spread across their body!"), span_boldannounce("The flesh accepts you. You are Sarkic now."))
				hook_scp_interaction(H, "SARKIC", INTERACTION_TYPE_RESEARCH)
		if("Flesh Shield")
			H.apply_status_effect(/datum/status_effect/sarkic_flesh_shield)
			H.visible_message(span_warning("[H]'s flesh hardens into a protective carapace!"), span_notice("Your flesh hardens into armor."))

/datum/action/innate/scp_ability/sarkic_blood_heal
	name = "Blood Healing"
	desc = "Use your own blood to rapidly heal over time."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "sacredflame"
	cooldown_time = 45 SECONDS

/datum/action/innate/scp_ability/sarkic_blood_heal/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	if(H.blood_volume < 300)
		to_chat(H, span_warning("Not enough blood to perform this ritual."))
		return
	start_cooldown()
	H.blood_volume -= 100
	H.apply_status_effect(/datum/status_effect/sarkic_regen)
	H.visible_message(span_warning("[H] tears open their own palm, dark blood dripping to the floor!"), span_notice("Your blood fuels the regeneration."))

/datum/action/innate/scp_ability/sarkic_flesh_mold
	name = "Flesh Mold"
	desc = "Create a flesh wall obstacle from biological material."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "shield"
	cooldown_time = 25 SECONDS

/datum/action/innate/scp_ability/sarkic_flesh_mold/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	var/turf/T = get_turf(H)
	var/obj/structure/sarkic_fleshwall/W = new(T)
	W.visible_message(span_warning("Flesh erupts from the ground, forming a grotesque barrier!"))

/datum/status_effect/sarkic_flesh_shield
	id = "sarkic_flesh_shield"
	duration = 20 SECONDS
	alert_type = /atom/movable/screen/status_effect/flesh_shield

/atom/movable/screen/status_effect/flesh_shield
	name = "Flesh Shield"

/datum/status_effect/sarkic_flesh_shield/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.damage_resistance += 30

/datum/status_effect/sarkic_flesh_shield/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.damage_resistance -= 30

/datum/status_effect/sarkic_regen
	id = "sarkic_regen"
	duration = 30 SECONDS
	tick_interval = 2 SECONDS

/datum/status_effect/sarkic_regen/tick()
	. = ..()
	if(ishuman(owner))
		owner.adjustBruteLoss(-5)
		owner.adjustFireLoss(-3)
		owner.adjustToxLoss(-2)

/obj/structure/sarkic_fleshwall
	name = "flesh wall"
	desc = "A wall of hardened, pulsating flesh. Revolting."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodtable"
	max_integrity = 150
	opacity = TRUE
	density = TRUE
	color = "#8B0000"

// Update Sarkic Cultist to grant all abilities
/datum/antagonist/sarkic_cult/on_gain()
	. = ..()
	if(owner.current)
		var/datum/action/innate/scp_ability/sarkic_fleshcraft/ritual = new()
		ritual.Grant(owner.current)
		var/datum/action/innate/scp_ability/sarkic_blood_heal/blood = new()
		blood.Grant(owner.current)
		var/datum/action/innate/scp_ability/sarkic_flesh_mold/mold = new()
		mold.Grant(owner.current)
		var/mob/living/carbon/human/H = owner.current
		if(istype(H))
			H.faction |= "sarkic"
	var/datum/objective/escape/O1 = new()
	O1.owner = owner
	O1.explanation_text = "Spread the Sarkic faith. Convert others to the flesh. Facilitate chaos within the Foundation."
	O1.completed = TRUE
	objectives += O1

/datum/antagonist/sarkic_cult/on_removal()
	. = ..()
	if(owner.current)
		var/datum/action/innate/scp_ability/sarkic_fleshcraft/ritual = locate() in owner.current.actions
		if(ritual)
			ritual.Remove(owner.current)
		var/datum/action/innate/scp_ability/sarkic_blood_heal/blood = locate() in owner.current.actions
		if(blood)
			blood.Remove(owner.current)
		var/datum/action/innate/scp_ability/sarkic_flesh_mold/mold = locate() in owner.current.actions
		if(mold)
			mold.Remove(owner.current)

// ================================================================
// CHAOS INSURGENCY — Equipment Request & Sabotage Tools
// ================================================================

/datum/action/innate/scp_ability/insurgency_equipment
	name = "Request Equipment"
	desc = "Request a supply drop from the Insurgency."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"
	cooldown_time = 120 SECONDS

/datum/action/innate/scp_ability/insurgency_equipment/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	var/list/choices = list("Combat Kit", "Sabotage Kit", "Medical Kit", "Intel Kit")
	var/choice = input(H, "Select equipment package:", "CI Supply Drop") as null|anything in choices
	if(!choice)
		return
	var/obj/item/storage/box/box = new(get_turf(H))
	switch(choice)
		if("Combat Kit")
			new /obj/item/gun/ballistic/automatic/pistol(box)
			new /obj/item/ammo_box/magazine/m10mm(box)
			new /obj/item/knife/combat(box)
		if("Sabotage Kit")
			new /obj/item/ci_breach_device(box)
			new /obj/item/crowbar(box)
			new /obj/item/wirecutters(box)
			new /obj/item/multitool(box)
		if("Medical Kit")
			new /obj/item/storage/medkit/regular(box)
			new /obj/item/reagent_containers/hypospray/medipen/survival(box)
			new /obj/item/reagent_containers/hypospray/medipen/survival(box)
		if("Intel Kit")
			new /obj/item/camera/ci_intel_camera(box)
			new /obj/item/binoculars(box)
			new /obj/item/pen(box)
	H.visible_message(span_notice("A supply crate materializes at [H]'s feet!"), span_notice("Insurgency supply drop received."))

/datum/action/innate/scp_ability/ci_disguise
	name = "Forge Disguise"
	desc = "Disguise your ID card as Foundation personnel."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "mindswap"
	cooldown_time = 60 SECONDS

/datum/action/innate/scp_ability/ci_disguise/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	var/obj/item/card/id/id_card = H.wear_id
	if(!id_card)
		to_chat(H, span_warning("You need an ID card to forge."))
		return
	var/list/roles = list("Janitor", "Cook", "Cargo Technician", "Medical Doctor", "Engineer", "Researcher")
	var/role = input(H, "Choose a cover identity:", "CI Disguise") as null|anything in roles
	if(!role)
		return
	id_card.registered_name = H.real_name
	id_card.assignment = role
	to_chat(H, span_notice("Your ID now identifies you as [role]. Security HUDs will display this role."))

/datum/action/innate/scp_ability/ci_safehouse
	name = "Deploy Safehouse Beacon"
	desc = "Deploy a beacon that creates a hidden compartment for stashing items."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "teleport"
	cooldown_time = 180 SECONDS

/datum/action/innate/scp_ability/ci_safehouse/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	var/turf/T = get_turf(H)
	new /obj/structure/closet/crate/secure(T)
	H.visible_message(span_notice("[H] deploys a small device that unfolds into a hidden compartment!"), span_notice("CI safehouse deployed. Use it to stash items and hide."))

// Update CI antag to grant all abilities
/datum/antagonist/chaos_insurgency/on_gain()
	. = ..()
	generate_ci_objectives()
	if(owner.current)
		var/datum/action/innate/scp_ability/insurgency_equipment/equipment = new()
		equipment.Grant(owner.current)
		var/datum/action/innate/scp_ability/ci_disguise/disguise = new()
		disguise.Grant(owner.current)
		var/datum/action/innate/scp_ability/ci_safehouse/safehouse = new()
		safehouse.Grant(owner.current)
		equip_ci_operative()

/datum/antagonist/chaos_insurgency/on_removal()
	. = ..()
	if(owner.current)
		var/datum/action/innate/scp_ability/insurgency_equipment/equipment = locate() in owner.current.actions
		if(equipment)
			equipment.Remove(owner.current)
		var/datum/action/innate/scp_ability/ci_disguise/disguise = locate() in owner.current.actions
		if(disguise)
			disguise.Remove(owner.current)
		var/datum/action/innate/scp_ability/ci_safehouse/safehouse = locate() in owner.current.actions
		if(safehouse)
			safehouse.Remove(owner.current)

// ================================================================
// SERPENT'S HAND — Anomalous Knowledge & Liberation
// ================================================================

/datum/action/innate/scp_ability/serpents_knowledge
	name = "Wanderers' Library"
	desc = "Consult the Library for knowledge of nearby SCPs and anomalies."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "mindread"
	cooldown_time = 20 SECONDS

/datum/action/innate/scp_ability/serpents_knowledge/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	var/list/nearby_scps = list()
	for(var/atom/A in range(15, H))
		if(A.SCP)
			var/scp_name = A.SCP.designation ? "SCP-[A.SCP.designation]" : A.name
			var/dir_text = dir2text(get_dir(H, A))
			var/dist = get_dist(H, A)
			nearby_scps += "[scp_name] - [dir_text] ([dist]m)"
	if(!length(nearby_scps))
		to_chat(H, span_notice("The Library whispers: No anomalies detected nearby."))
		return
	to_chat(H, span_notice("<b>The Wanderers' Library reveals:</b>"))
	for(var/info in nearby_scps)
		to_chat(H, span_notice("  * [info]"))
	hook_scp_interaction(H, "SERPENTS", INTERACTION_TYPE_OBSERVATION)

/datum/action/innate/scp_ability/serpents_liberate
	name = "Liberate Anomaly"
	desc = "Disrupt containment fields around an SCP to cause a breach."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	cooldown_time = 60 SECONDS

/datum/action/innate/scp_ability/serpents_liberate/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	var/list/nearby_scps = list()
	for(var/mob/living/M in view(5, H))
		if(M.SCP)
			nearby_scps += M
	if(!length(nearby_scps))
		to_chat(H, span_warning("No contained anomalies in range to liberate."))
		return
	var/mob/living/target = input(H, "Choose an anomaly to liberate:", "Serpent's Hand") as null|anything in nearby_scps
	if(!target || QDELETED(target))
		return
	start_cooldown()
	var/scp_id = target.SCP.designation ? "SCP-[target.SCP.designation]" : "Unknown"
	hook_scp_breach(scp_id, target)
	H.visible_message(span_warning("[H] channels anomalous energy toward [target]!"), span_notice("You disrupt the containment of [scp_id]!"))
	hook_scp_interaction(H, "SERPENTS", INTERACTION_TYPE_EXPLORATION)

/datum/action/innate/scp_ability/serpents_veil
	name = "Anomalous Veil"
	desc = "Cloak yourself in anomalous energy, becoming harder to detect."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"
	cooldown_time = 45 SECONDS

/datum/action/innate/scp_ability/serpents_veil/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	H.apply_status_effect(/datum/status_effect/serpents_veil)
	H.visible_message(span_warning("[H] shimmers and becomes harder to see!"), span_notice("The anomalous veil cloaks you."))

/datum/action/innate/scp_ability/serpents_empathy
	name = "Anomalous Empathy"
	desc = "Sense the health and status of nearby SCP entities."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "sacredflame"
	cooldown_time = 15 SECONDS

/datum/action/innate/scp_ability/serpents_empathy/Activate()
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return
	start_cooldown()
	var/list/nearby_scps = list()
	for(var/mob/living/M in view(7, H))
		if(M.SCP)
			nearby_scps += M
	if(!length(nearby_scps))
		to_chat(H, span_notice("You sense no anomalous beings nearby."))
		return
	to_chat(H, span_notice("<b>Anomalous Empathy:</b>"))
	for(var/mob/living/M in nearby_scps)
		var/health_pct = round(M.health / M.maxHealth * 100)
		var/scp_name = M.SCP.designation ? "SCP-[M.SCP.designation]" : M.name
		var/status = M.stat == DEAD ? "DECEASED" : (health_pct > 80 ? "Stable" : (health_pct > 40 ? "Injured" : "Critical"))
		to_chat(H, span_notice("  * [scp_name]: [status] ([health_pct]%)"))
	hook_scp_interaction(H, "SERPENTS", INTERACTION_TYPE_CARE)

/datum/status_effect/serpents_veil
	id = "serpents_veil"
	duration = 20 SECONDS
	alert_type = /atom/movable/screen/status_effect/serpents_veil

/atom/movable/screen/status_effect/serpents_veil
	name = "Anomalous Veil"

/datum/status_effect/serpents_veil/on_apply()
	. = ..()
	if(ishuman(owner))
		owner.alpha = 100

/datum/status_effect/serpents_veil/on_remove()
	. = ..()
	if(ishuman(owner))
		owner.alpha = initial(owner.alpha)

// Update Serpent's Hand antag to grant all abilities
/datum/antagonist/serpents_hand/on_gain()
	. = ..()
	if(owner.current)
		var/datum/action/innate/scp_ability/serpents_knowledge/knowledge = new()
		knowledge.Grant(owner.current)
		var/datum/action/innate/scp_ability/serpents_liberate/liberate = new()
		liberate.Grant(owner.current)
		var/datum/action/innate/scp_ability/serpents_veil/veil = new()
		veil.Grant(owner.current)
		var/datum/action/innate/scp_ability/serpents_empathy/empathy = new()
		empathy.Grant(owner.current)
		var/mob/living/carbon/human/H = owner.current
		if(istype(H))
			H.faction |= "serpents_hand"
	var/datum/objective/escape/O1 = new()
	O1.owner = owner
	O1.explanation_text = "Free the anomalous. Sabotage Foundation containment. Help SCPs escape captivity."
	O1.completed = TRUE
	objectives += O1

/datum/antagonist/serpents_hand/on_removal()
	. = ..()
	if(owner.current)
		var/datum/action/innate/scp_ability/serpents_knowledge/knowledge = locate() in owner.current.actions
		if(knowledge)
			knowledge.Remove(owner.current)
		var/datum/action/innate/scp_ability/serpents_liberate/liberate = locate() in owner.current.actions
		if(liberate)
			liberate.Remove(owner.current)
		var/datum/action/innate/scp_ability/serpents_veil/veil = locate() in owner.current.actions
		if(veil)
			veil.Remove(owner.current)
		var/datum/action/innate/scp_ability/serpents_empathy/empathy = locate() in owner.current.actions
		if(empathy)
			empathy.Remove(owner.current)

// ================================================================
// SCP INTERACTION RESEARCH POINT AWARDS
// Expanded research point rewards for meaningful SCP interactions
// ================================================================

/proc/award_scp_interaction_points(mob/user, scp_id, interaction_type, points = 0)
	if(!user || !scp_id)
		return
	var/award_amount = points
	if(award_amount <= 0)
		switch(interaction_type)
			if(INTERACTION_TYPE_OBSERVATION)
				award_amount = 3
			if(INTERACTION_TYPE_RESEARCH)
				award_amount = 10
			if(INTERACTION_TYPE_EXPERIMENT)
				award_amount = 15
			if(INTERACTION_TYPE_MEDICAL)
				award_amount = 8
			if(INTERACTION_TYPE_CARE)
				award_amount = 5
			if(INTERACTION_TYPE_COMMUNICATION)
				award_amount = 6
			if(INTERACTION_TYPE_EXPLORATION)
				award_amount = 7
			if(INTERACTION_TYPE_COMBAT)
				award_amount = 4
			if(INTERACTION_TYPE_CONTAINMENT)
				award_amount = 12
			else
				award_amount = 2
	if(award_amount > 0 && SSscp_research && SSscp_research.manager)
		SSscp_research.manager.adjust_research_points(award_amount, "scp_interaction:[scp_id]:[interaction_type]")
