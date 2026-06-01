/mob/living/scp/scp049/proc/apply_stage_5_abilities()
	if(evolution_stage < 5)
		return
	pestilence_detect_radius += 3
	cure_range += 2
	cure_effectiveness += 25
	melee_damage_lower += 15
	melee_damage_upper += 20
	maxHealth += 200
	health = min(health + 200, maxHealth)
	to_chat(src, span_userdanger("You have achieved perfect understanding. The Pestilence shall be cured. ALL of it."))
	visible_message(span_danger("[src] radiates an aura of terrible purpose!"))
	playsound(src, 'sound/scp/scp049/SCP049_5.ogg', 100, 0, extrarange = 30)

/datum/scp682_acid_bath
	var/mob/living/scp/scp682/owner
	var/acid_level = 0
	var/max_acid = 100
	var/acid_degradation_rate = 1
	var/acid_application_rate = 5
	var/bath_active = FALSE
	var/damage_per_tick = 25
	var/containment_progress = 0
	var/containment_threshold = 100
	var/datum/weakref/bath_structure

/datum/scp682_acid_bath/New(mob/living/scp/scp682/new_owner)
	owner = new_owner

/datum/scp682_acid_bath/proc/process_acid()
	if(!owner || owner.stat == DEAD)
		return
	if(!bath_active)
		if(containment_progress > 0)
			containment_progress = max(0, containment_progress - 0.5)
		return
	if(acid_level <= 0)
		bath_active = FALSE
		return
	acid_level = max(0, acid_level - acid_degradation_rate)
	owner.apply_damage(damage_per_tick * (acid_level / max_acid), BURN)
	if(owner.evolution_system)
		owner.evolution_system.add_adaptation("acid", 2)
	containment_progress = min(containment_threshold, containment_progress + (acid_level / max_acid) * 3)
	if(containment_progress >= containment_threshold && owner.containment_status == "breached")
		owner.containment_status = "contained"
		owner.forceMove(pick(GLOB.scp_spawn_turfs))
		hook_scp_recontainment("SCP-682", list("method" = "acid_bath"))
		bath_active = FALSE
		containment_progress = 0
		if(owner.evolution_system)
			owner.evolution_system.active_adaptations = list()
		to_chat(owner, span_userdanger("The acid overwhelms you! You are pulled back into containment!"))

/datum/scp682_acid_bath/proc/add_acid(amount)
	acid_level = min(max_acid, acid_level + amount)
	if(!bath_active && acid_level > 20)
		bath_active = TRUE

/datum/scp682_acid_bath/proc/get_status_text()
	return "Acid: [round(acid_level)]% | Containment Progress: [round(containment_progress)]/[containment_threshold] | Bath: [bath_active ? "ACTIVE" : "INACTIVE"]"

/obj/machinery/scp682_acid_bath_console
	name = "SCP-682 Acid Bath Console"
	desc = "A console for controlling the acid bath containment system for SCP-682. Requires direct line of sight to SCP-682 to function."
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndicam"
	circuit = /obj/item/circuitboard/computer/scp682_acid_bath_console
	req_access = list(ACCESS_SECURITY)
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/flood_cooldown = 0
	var/flood_cooldown_time = 30 SECONDS

/obj/machinery/scp682_acid_bath_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCP682AcidBath", "SCP-682 ACID BATH")
		ui.open()

/obj/machinery/scp682_acid_bath_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp682_acid_bath_console/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/scp/scp682/target
	for(var/mob/living/scp/scp682/S in GLOB.mob_list)
		if(S.stat != DEAD)
			target = S
			break
	data["has_target"] = !!target
	if(target)
		data["target_health"] = round((target.health / target.maxHealth) * 100)
		data["target_evolution"] = target.evolution_stage
		data["containment_status"] = target.containment_status
		if(target.acid_bath)
			var/datum/scp682_acid_bath/bath = target.acid_bath
			data["acid_level"] = round(bath.acid_level)
			data["bath_active"] = bath.bath_active
			data["containment_progress"] = round(bath.containment_progress)
			data["containment_threshold"] = bath.containment_threshold
	data["flood_cooldown"] = max(0, flood_cooldown - world.time)
	return data

/obj/machinery/scp682_acid_bath_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!allowed(ui.user))
		to_chat(ui.user, span_warning("Access denied."))
		return
	switch(action)
		if("flood_acid")
			if(world.time < flood_cooldown)
				to_chat(ui.user, span_warning("Acid systems are recharging."))
				return
			var/mob/living/scp/scp682/target
			for(var/mob/living/scp/scp682/S in GLOB.mob_list)
				if(S.stat != DEAD)
					target = S
					break
			if(!target)
				to_chat(ui.user, span_warning("No SCP-682 detected."))
				return
			if(!target.acid_bath)
				target.acid_bath = new /datum/scp682_acid_bath(target)
			var/datum/scp682_acid_bath/bath = target.acid_bath
			bath.add_acid(30)
			flood_cooldown = world.time + flood_cooldown_time
			to_chat(ui.user, span_notice("Acid flood released. Level: [round(bath.acid_level)]%"))
			priority_announce("SCP-682 acid bath containment protocol activated. All personnel clear the chamber.", "ACID BATH", null, ANNOUNCER_ALERT)
			. = TRUE
		if("emergency_flood")
			if(world.time < flood_cooldown)
				return
			var/mob/living/scp/scp682/target
			for(var/mob/living/scp/scp682/S in GLOB.mob_list)
				if(S.stat != DEAD)
					target = S
					break
			if(!target)
				return
			if(!target.acid_bath)
				target.acid_bath = new /datum/scp682_acid_bath(target)
			var/datum/scp682_acid_bath/bath = target.acid_bath
			bath.add_acid(60)
			flood_cooldown = world.time + flood_cooldown_time * 2
			to_chat(ui.user, span_danger("EMERGENCY ACID FLOOD. Maximum concentration deployed."))
			priority_announce("SCP-682 EMERGENCY acid bath deployed. Maximum concentration. Chamber sealed.", "EMERGENCY ACID", null, ANNOUNCER_ALERT)
			. = TRUE

/obj/item/circuitboard/computer/scp682_acid_bath_console
	name = "SCP-682 Acid Bath Console (Computer Board)"
	build_path = /obj/machinery/scp682_acid_bath_console



/proc/trigger_power_failure_cascade()
	var/list/failure_areas = list()
	for(var/area/A in GLOB.areas)
		if(!istype(A, /area/scp) && !istype(A, /area/site53))
			continue
		if(prob(30))
			failure_areas += A
	var/failed = 0
	for(var/area/A in failure_areas)
		for(var/obj/machinery/power/apc/APC in A)
			if(APC)
				APC.energy_fail(rand(60, 180))
				failed++
				break
	if(failed > 0)
		priority_announce("Power grid instability detected in [failed] sectors. Engineering response required.", "POWER FAILURE", null, ANNOUNCER_ALERT)
		log_round_event("power_failure", "Power cascade failed [failed] APCs", "system")
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.stat == DEAD)
				continue
			if(H.job && (findtext(H.job, "Engineer") || findtext(H.job, "Containment")))
				to_chat(H, span_warning("<b>POWER ALERT:</b> Multiple APC failures detected. Containment systems at risk."))

/proc/trigger_goi_breach_sabotage(goi_type)
	var/mob/living/scp/target
	var/list/candidates = list()
	for(var/mob/living/scp/S in GLOB.mob_list)
		if(S.stat == DEAD || S.containment_status == "breached")
			continue
		candidates += S
	if(!length(candidates))
		return
	target = pick(candidates)
	var/area/A = get_area(target)
	if(!A)
		return
	for(var/obj/machinery/power/apc/APC in A)
		APC.energy_fail(rand(120, 300))
		break
	target.containment_status = "breached"
	hook_scp_breach("SCP-[target.SCP?.designation || "Unknown"]", target)
	var/goi_name = "Unknown Hostile"
	switch(goi_type)
		if("ci")
			goi_name = "Chaos Insurgency"
		if("sarkic")
			goi_name = "Sarkic Cult"
		if("serpents")
			goi_name = "Serpent's Hand"
	priority_announce("Security breach detected. Potential [goi_name] sabotage. SCP containment compromised in [A.name].", "SABOTAGE ALERT", null, ANNOUNCER_ALERT)
	log_round_event("goi_sabotage", "[goi_name] sabotaged containment for SCP-[target.SCP?.designation || "Unknown"]", goi_type)
