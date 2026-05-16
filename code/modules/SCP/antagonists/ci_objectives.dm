// Chaos Insurgency Infiltration Objectives
// Expands the CI antagonist with SCP theft objectives, sabotage goals, and infiltration mechanics

/datum/objective/ci_scp_theft
	name = "steal an SCP object"
	var/target_scp_id
	var/target_scp_name

/datum/objective/ci_scp_theft/New()
	..()
	var/list/stealable_scps = list(
		"SCP-035" = "SCP-035 (Possessive Mask)",
		"SCP-500" = "SCP-500 (Panacea)",
		"SCP-914" = "SCP-914 (The Clockworks)",
		"SCP-013" = "SCP-013 (Blue Lady Cigarettes)",
		"SCP-113" = "SCP-113 (Gender-Switching Stone)",
		"SCP-714" = "SCP-714 (Jade Ring)",
		"SCP-012" = "SCP-012 (A Bad Composition)",
	)
	var/chosen = pick(stealable_scps)
	target_scp_id = chosen
	target_scp_name = stealable_scps[chosen]
	explanation_text = "Steal [target_scp_name] and extract it from the facility via Gate A or Gate B."

/datum/objective/ci_scp_theft/check_completion()
	if(!owner.current)
		return FALSE
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return FALSE

	var/area/A = get_area(H)
	if(!istype(A, /area/scp/surface/gate_a) && !istype(A, /area/scp/surface/gate_b))
		return FALSE

	var/found = FALSE
	for(var/obj/item/I in H.get_all_contents())
		if(findtext(I.name, target_scp_id) || findtext("[I.type]", target_scp_id))
			found = TRUE
			break

	return found

/datum/objective/ci_sabotage
	name = "sabotage facility systems"
	var/sabotage_type
	var/sabotage_target
	var/sabotage_count = 0
	var/sabotage_required = 3

/datum/objective/ci_sabotage/New()
	..()
	var/list/sabotage_types = list(
		"apc" = list("name" = "Destroy APCs", "desc" = "Destroy [sabotage_required] APC units in containment zones"),
		"camera" = list("name" = "Disable Cameras", "desc" = "Disable [sabotage_required] security cameras in containment zones"),
		"door" = list("name" = "Bypass Airlocks", "desc" = "Bypass [sabotage_required] containment zone airlocks"),
		"power" = list("name" = "Disrupt Power", "desc" = "Cause power failures in [sabotage_required] containment areas"),
	)
	sabotage_type = pick(sabotage_types)
	var/list/data = sabotage_types[sabotage_type]
	sabotage_target = data["name"]
	explanation_text = data["desc"]

/datum/objective/ci_sabotage/check_completion()
	if(sabotage_count >= sabotage_required)
		return TRUE
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return FALSE
	var/list/containment_area_types = list(/area/scp/lcz, /area/scp/hcz)
	var/destroyed_count = 0
	switch(sabotage_type)
		if("apc")
			for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
				if(QDELETED(A))
					continue
				var/area/A_area = get_area(A)
				var/in_zone = FALSE
				for(var/area_type in containment_area_types)
					if(istype(A_area, area_type))
						in_zone = TRUE
						break
				if(in_zone && (A.machine_stat & BROKEN))
					destroyed_count++
			sabotage_count = destroyed_count
		if("camera")
			for(var/obj/machinery/camera/C as anything in INSTANCES_OF(/obj/machinery/camera))
				if(QDELETED(C))
					continue
				if(!C.status)
					var/area/C_area = get_area(C)
					var/in_zone = FALSE
					for(var/area_type in containment_area_types)
						if(istype(C_area, area_type))
							in_zone = TRUE
							break
					if(in_zone)
						destroyed_count++
			sabotage_count = destroyed_count
		if("door")
			for(var/obj/machinery/door/airlock/D as anything in INSTANCES_OF(/obj/machinery/door/airlock))
				if(QDELETED(D))
					continue
				var/area/D_area = get_area(D)
				var/in_zone = FALSE
				for(var/area_type in containment_area_types)
					if(istype(D_area, area_type))
						in_zone = TRUE
						break
				if(in_zone && D.welded)
					destroyed_count++
			sabotage_count = destroyed_count
		if("power")
			for(var/obj/machinery/power/apc/A as anything in INSTANCES_OF(/obj/machinery/power/apc))
				if(QDELETED(A))
					continue
				var/area/A_area = get_area(A)
				var/in_zone = FALSE
				for(var/area_type in containment_area_types)
					if(istype(A_area, area_type))
						in_zone = TRUE
						break
				if(in_zone && (A.machine_stat & NOPOWER))
					destroyed_count++
			sabotage_count = destroyed_count
	return sabotage_count >= sabotage_required

/datum/objective/ci_breach_assist
	name = "cause a containment breach"
	explanation_text = "Cause or assist in a containment breach of at least one SCP."

/datum/objective/ci_breach_assist/check_completion()
	if(SSscp_persistence && SSscp_persistence.manager)
		return SSscp_persistence.manager.active_breaches > 0 || SSscp_persistence.manager.global_containment_stability < 80
	return FALSE

/datum/objective/ci_extract_dclass
	name = "extract D-Class personnel"
	var/extracted_count = 0
	var/extract_required = 2

/datum/objective/ci_extract_dclass/New()
	..()
	explanation_text = "Extract [extract_required] D-Class personnel from the facility alive."

/datum/objective/ci_extract_dclass/check_completion()
	if(extracted_count >= extract_required)
		return TRUE
	var/found = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(QDELETED(H) || H.stat == DEAD)
			continue
		if(!findtext(H.job, "D-Class"))
			continue
		var/area/A = get_area(H)
		if(istype(A, /area/scp/surface/gate_a) || istype(A, /area/scp/surface/gate_b) || istype(A, /area/scp/surface))
			found++
	extracted_count = found
	return extracted_count >= extract_required

/datum/objective/ci_intel_gather
	name = "gather intelligence"
	var/intel_collected = 0
	var/intel_required = 3

/datum/objective/ci_intel_gather/New()
	..()
	explanation_text = "Photograph or retrieve intelligence on [intel_required] SCP objects using the camera."

/datum/objective/ci_intel_gather/check_completion()
	return intel_collected >= intel_required

// Expanded Chaos Insurgency Antagonist
/datum/antagonist/chaos_insurgency/proc/generate_ci_objectives()
	var/num_objectives = rand(2, 4)
	var/list/obj_types = list(
		/datum/objective/ci_scp_theft,
		/datum/objective/ci_sabotage,
		/datum/objective/ci_breach_assist,
		/datum/objective/ci_extract_dclass,
		/datum/objective/ci_intel_gather,
	)

	for(var/i in 1 to num_objectives)
		var/obj_type = pick(obj_types)
		var/datum/objective/O = new obj_type
		O.owner = owner
		objectives += O
		O.update_explanation_text()

/datum/antagonist/chaos_insurgency/on_gain()
	. = ..()
	generate_ci_objectives()
	if(owner.current)
		var/datum/action/innate/insurgency_equipment/equipment = new()
		equipment.Grant(owner.current)
		equip_ci_operative()

/datum/antagonist/chaos_insurgency/proc/equip_ci_operative()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	var/obj/item/card/id/id_card = new /obj/item/card/id/advanced()
	id_card.registered_name = H.real_name
	id_card.assignment = "Facility Staff"
	id_card.access = list(ACCESS_DCLASS, ACCESS_SECURITY_LVL1)
	H.equip_to_slot_or_del(id_card, ITEM_SLOT_ID)

	var/obj/item/uplink_device = new /obj/item/radio/headset()
	H.equip_to_slot_or_del(uplink_device, ITEM_SLOT_EARS)

	var/obj/item/weapon = new /obj/item/gun/ballistic/automatic/pistol()
	H.equip_to_slot_or_del(weapon, ITEM_SLOT_SUITSTORE)

	var/obj/item/storage/belt/belt = new /obj/item/storage/belt()
	H.equip_to_slot_or_del(belt, ITEM_SLOT_BELT)

// CI Intelligence Camera
/obj/item/camera/ci_intel_camera
	name = "disposable camera"
	desc = "A cheap disposable camera. It seems to be modified with anomalous scanning technology."
	var/list/captured_intel = list()
	var/intel_capacity = 5

/obj/item/camera/ci_intel_camera/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/datum/antagonist/chaos_insurgency/ci = H.mind?.has_antag_datum(/datum/antagonist/chaos_insurgency)
	if(!ci)
		to_chat(H, "<span class='warning'>You don't know how to use this device.</span>")
		return

	if(length(captured_intel) >= intel_capacity)
		to_chat(H, "<span class='warning'>Camera memory full. [length(captured_intel)]/[intel_capacity] intel gathered.</span>")
		return

	var/list/nearby_scps = list()
	for(var/mob/living/M in view(7, H))
		if(M.SCP)
			nearby_scps += M

	if(!length(nearby_scps))
		to_chat(H, "<span class='warning'>No SCP entities in view to document.</span>")
		return

	var/mob/living/target_scp = pick(nearby_scps)
	var/scp_name = target_scp.SCP.designation ? "SCP-[target_scp.SCP.designation]" : target_scp.name
	captured_intel += scp_name
	to_chat(H, "<span class='notice'>Intelligence captured on [scp_name]. ([length(captured_intel)]/[intel_capacity])</span>")

	for(var/datum/objective/ci_intel_gather/O in ci.objectives)
		O.intel_collected++
		if(O.intel_collected >= O.intel_required)
			to_chat(H, "<span class='green'>Intelligence objective complete!</span>")

// CI Breach Assist Device
/obj/item/ci_breach_device
	name = "containment override device"
	desc = "A small electronic device that can disrupt containment field generators."
	icon = 'icons/obj/module.dmi'
	icon_state = "card_mod"
	var/uses = 3

/obj/item/ci_breach_device/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(uses <= 0)
		to_chat(user, "<span class='warning'>Device depleted.</span>")
		return

	var/mob/living/carbon/human/H = user
	var/datum/antagonist/chaos_insurgency/ci = H.mind?.has_antag_datum(/datum/antagonist/chaos_insurgency)
	if(!ci)
		to_chat(H, "<span class='warning'>You don't know how to use this device.</span>")
		return

	uses--
	to_chat(H, "<span class='notice'>Containment override activated! [uses] uses remaining.</span>")

	var/list/breachable_scps = list("SCP-173", "SCP-049", "SCP-096", "SCP-035", "SCP-939")
	hook_scp_breach(pick(breachable_scps), H)

	for(var/datum/objective/ci_breach_assist/O in ci.objectives)
		to_chat(H, "<span class='notice'>Breach assist objective progress updated.</span>")

/obj/item/ci_breach_device/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[uses] uses remaining.</span>"
