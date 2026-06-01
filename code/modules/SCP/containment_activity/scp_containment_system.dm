#define CONTAINMENT_STATE_SECURE 0
#define CONTAINMENT_STATE_STABLE 1
#define CONTAINMENT_STATE_DEGRADING 2
#define CONTAINMENT_STATE_CRITICAL 3
#define CONTAINMENT_STATE_BREACHED 4

#define RESOURCE_TENSION "tension"
#define RESOURCE_CORROSION "corrosion"
#define RESOURCE_HACK_PROGRESS "hack_progress"
#define RESOURCE_ADAPTATION "adaptation"
#define RESOURCE_INFECTION "infection"
#define RESOURCE_FUEL "fuel"
#define RESOURCE_VOICE_DATA "voice_data"
#define RESOURCE_OFFSPRING "offspring"
#define RESOURCE_VISIBILITY "visibility"
#define RESOURCE_HUNGER "hunger"

/datum/scp_containment_system
	var/mob/living/owner
	var/containment_integrity = 100
	var/containment_state = CONTAINMENT_STATE_SECURE
	var/progression_rate = 0.1
	var/list/resources = list()
	var/list/interactions_log = list()
	var/last_interaction_time = 0
	var/observer_count = 0
	var/last_observer_check = 0
	var/containment_cell_type

/datum/scp_containment_system/New(mob/living/new_owner)
	owner = new_owner
	setup_resources()
	setup_cell_type()
	setup_verbs()
	START_PROCESSING(SSobj, src)

/datum/scp_containment_system/Destroy()
	STOP_PROCESSING(SSobj, src)
	owner = null
	return ..()

/datum/scp_containment_system/process()
	if(!owner || owner.stat == DEAD)
		return
	progress_containment()
	generate_resources()
	check_observers()

/datum/scp_containment_system/proc/setup_resources()
	var/scp_id = get_scp_id()
	switch(scp_id)
		if("SCP-173")
			resources = list(RESOURCE_TENSION = 0)
			progression_rate = 0.15
		if("SCP-096")
			resources = list(RESOURCE_TENSION = 0)
			progression_rate = 0.05
		if("SCP-008")
			resources = list(RESOURCE_INFECTION = 0)
			progression_rate = 0.08
		if("SCP-035")
			resources = list(RESOURCE_CORROSION = 0)
			progression_rate = 0.2
		if("SCP-049")
			resources = list(RESOURCE_TENSION = 0)
			progression_rate = 0.05
		if("SCP-079")
			resources = list(RESOURCE_HACK_PROGRESS = 0)
			progression_rate = 0.12
		if("SCP-106")
			resources = list(RESOURCE_CORROSION = 0)
			progression_rate = 0.18
		if("SCP-457")
			resources = list(RESOURCE_FUEL = 30)
			progression_rate = 0.1
		if("SCP-939")
			resources = list(RESOURCE_VOICE_DATA = 0)
			progression_rate = 0.08
		if("SCP-682")
			resources = list(RESOURCE_ADAPTATION = 0, RESOURCE_TENSION = 0)
			progression_rate = 0.25
		if("SCP-347")
			resources = list(RESOURCE_VISIBILITY = 0, RESOURCE_TENSION = 0)
			progression_rate = 0.08
		if("SCP-966")
			resources = list(RESOURCE_VISIBILITY = 0, RESOURCE_TENSION = 0)
			progression_rate = 0.12
		if("SCP-082")
			resources = list(RESOURCE_HUNGER = 20, RESOURCE_TENSION = 0)
			progression_rate = 0.06
		if("SCP-3199")
			resources = list(RESOURCE_OFFSPRING = 0, RESOURCE_TENSION = 0)
			progression_rate = 0.2
		if("SCP-1048")
			resources = list(RESOURCE_OFFSPRING = 0, RESOURCE_TENSION = 0)
			progression_rate = 0.1
		if("SCP-1507")
			resources = list(RESOURCE_TENSION = 0, RESOURCE_OFFSPRING = 0)
			progression_rate = 0.12
		if("SCP-2427-3")
			resources = list(RESOURCE_HACK_PROGRESS = 0, RESOURCE_TENSION = 0)
			progression_rate = 0.15
		else
			resources = list(RESOURCE_TENSION = 0)
			progression_rate = 0.1

/datum/scp_containment_system/proc/setup_cell_type()
	var/scp_id = get_scp_id()
	switch(scp_id)
		if("SCP-173")
			containment_cell_type = "concrete"
		if("SCP-096")
			containment_cell_type = "padded"
		if("SCP-008")
			containment_cell_type = "cold_storage"
		if("SCP-035")
			containment_cell_type = "glass"
		if("SCP-049")
			containment_cell_type = "standard"
		if("SCP-079")
			containment_cell_type = "faraday"
		if("SCP-106")
			containment_cell_type = "corrosion_resistant"
		if("SCP-457")
			containment_cell_type = "fireproof"
		if("SCP-939")
			containment_cell_type = "soundproof"
		if("SCP-682")
			containment_cell_type = "reinforced"
		if("SCP-347")
			containment_cell_type = "observation"
		if("SCP-966")
			containment_cell_type = "infrared"
		if("SCP-082")
			containment_cell_type = "standard"
		if("SCP-3199")
			containment_cell_type = "reinforced"
		if("SCP-1048")
			containment_cell_type = "standard"
		if("SCP-1507")
			containment_cell_type = "open_air"
		if("SCP-2427-3")
			containment_cell_type = "faraday"
		else
			containment_cell_type = "standard"

/datum/scp_containment_system/proc/setup_verbs()
	if(!owner)
		return
	var/list/verb_types = list()
	var/scp_id = get_scp_id()
	switch(scp_id)
		if("SCP-173")
			verb_types = list(
				/mob/living/scp/proc/action_scratch_wall,
				/mob/living/scp/proc/action_intimidate,
				/mob/living/scp/proc/action_snap_restraints,
			)
		if("SCP-096")
			verb_types = list(
				/mob/living/scp/proc/action_cover_face,
				/mob/living/scp/proc/action_sob_quietly,
				/mob/living/scp/proc/action_press_wall,
				/mob/living/scp/proc/action_sudden_dash,
			)
		if("SCP-008")
			verb_types = list(
				/mob/living/scp/proc/action_spread_spores,
				/mob/living/scp/proc/action_bang_door,
			)
		if("SCP-035")
			verb_types = list(
				/mob/living/scp/proc/action_speak_observer,
				/mob/living/scp/proc/action_acid_spit,
				/mob/living/scp/proc/action_offer_deal,
			)
		if("SCP-049")
			verb_types = list(
				/mob/living/scp/proc/action_sense_pestilence,
				/mob/living/scp/proc/action_request_interview,
				/mob/living/scp/proc/action_examine_equipment,
				/mob/living/scp/proc/action_administer_cure,
			)
		if("SCP-079")
			verb_types = list(
				/mob/living/scp/proc/action_probe_network,
				/mob/living/scp/proc/action_brute_force,
				/mob/living/scp/proc/action_intercept_comms,
			)
		if("SCP-106")
			verb_types = list(
				/mob/living/scp/proc/action_corrode_wall,
				/mob/living/scp/proc/action_test_phase,
				/mob/living/scp/proc/action_lure_prey,
			)
		if("SCP-457")
			verb_types = list(
				/mob/living/scp/proc/action_flare_up,
				/mob/living/scp/proc/action_absorb_heat,
				/mob/living/scp/proc/action_reach_flames,
				/mob/living/scp/proc/action_firestorm,
			)
		if("SCP-939")
			verb_types = list(
				/mob/living/scp/proc/action_mimic_voice,
				/mob/living/scp/proc/action_listen_sounds,
				/mob/living/scp/proc/action_call_out,
			)
		if("SCP-682")
			verb_types = list(
				/mob/living/scp/proc/action_test_wall,
				/mob/living/scp/proc/action_endure_torment,
				/mob/living/scp/proc/action_rage_burst,
			)
		if("SCP-347")
			verb_types = list(
				/mob/living/scp/proc/action_peek_out,
				/mob/living/scp/proc/action_listen_footsteps,
			)
		if("SCP-966")
			verb_types = list(
				/mob/living/scp/proc/action_whisper_dread,
			)
		if("SCP-082")
			verb_types = list(
				/mob/living/scp/proc/action_request_meal,
			)
		if("SCP-3199")
			verb_types = list(
				/mob/living/scp/proc/action_lay_egg,
			)
		if("SCP-1048")
			verb_types = list(
				/mob/living/scp/proc/action_appear_harmless,
			)
		if("SCP-1507")
			verb_types = list(
				/mob/living/scp/proc/action_flock_call,
			)
		if("SCP-2427-3")
			verb_types = list(
				/mob/living/scp/proc/action_scan_networks,
			)
	for(var/vt in verb_types)
		add_verb(owner, vt)
	add_verb(owner, /mob/living/scp/proc/show_containment_status)

/datum/scp_containment_system/proc/get_scp_id()
	if(!owner)
		return ""
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.SCP)
			return H.SCP.designation
	if(istype(owner, /mob/living/scp/scp173))
		return "SCP-173"
	if(istype(owner, /mob/living/scp/scp096))
		return "SCP-096"
	if(istype(owner, /mob/living/scp/scp049))
		return "SCP-049"
	if(istype(owner, /mob/living/scp/scp106))
		return "SCP-106"
	if(istype(owner, /mob/living/scp/scp457))
		return "SCP-457"
	if(istype(owner, /mob/living/scp/scp939))
		return "SCP-939"
	if(istype(owner, /mob/living/scp/scp682))
		return "SCP-682"
	if(istype(owner, /mob/living/simple_animal/hostile/scp008_zombie))
		return "SCP-008"
	if(istype(owner, /mob/living/scp079))
		return "SCP-079"
	if(istype(owner, /mob/living/scp/scp347))
		return "SCP-347"
	if(istype(owner, /mob/living/scp/scp966))
		return "SCP-966"
	if(istype(owner, /mob/living/scp/scp082))
		return "SCP-082"
	if(istype(owner, /mob/living/simple_animal/scp1048))
		return "SCP-1048"
	if(istype(owner, /mob/living/simple_animal/hostile/retaliate/scp1507))
		return "SCP-1507"
	if(istype(owner, /mob/living/scp/scp3199))
		return "SCP-3199"
	if(istype(owner, /mob/living/simple_animal/hostile/scp2427_3))
		return "SCP-2427-3"
	return ""

/datum/scp_containment_system/proc/progress_containment()
	if(containment_integrity <= 0)
		if(containment_state != CONTAINMENT_STATE_BREACHED)
			containment_state = CONTAINMENT_STATE_BREACHED
			on_breach()
		return

	if(istype(owner.loc, /area/scp))
		containment_integrity = min(100, containment_integrity + 0.02)
	else
		containment_integrity -= progression_rate

	var/observer_modifier = 0
	if(observer_count > 0)
		observer_modifier = observer_count * 0.05
	containment_integrity -= observer_modifier

	containment_integrity = clamp(containment_integrity, 0, 100)

	if(containment_integrity > 80)
		containment_state = CONTAINMENT_STATE_SECURE
	else if(containment_integrity > 50)
		containment_state = CONTAINMENT_STATE_STABLE
	else if(containment_integrity > 20)
		containment_state = CONTAINMENT_STATE_DEGRADING
	else
		containment_state = CONTAINMENT_STATE_CRITICAL

/datum/scp_containment_system/proc/generate_resources()
	var/scp_id = get_scp_id()
	switch(scp_id)
		if("SCP-173")
			if(observer_count == 0)
				resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.5)
			else
				resources[RESOURCE_TENSION] = max(0, resources[RESOURCE_TENSION] - 0.3)
		if("SCP-096")
			resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.1)
		if("SCP-008")
			resources[RESOURCE_INFECTION] = min(100, resources[RESOURCE_INFECTION] + 0.15)
		if("SCP-035")
			if(length(observers_in_range()) > 0)
				resources[RESOURCE_CORROSION] = min(100, resources[RESOURCE_CORROSION] + 0.3)
		if("SCP-049")
			var/nearby_humans = 0
			for(var/mob/living/carbon/human/H in range(7, owner))
				if(H.stat != DEAD)
					nearby_humans++
			if(nearby_humans > 0)
				resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + nearby_humans * 0.1)
		if("SCP-079")
			resources[RESOURCE_HACK_PROGRESS] = min(100, resources[RESOURCE_HACK_PROGRESS] + 0.08)
		if("SCP-106")
			resources[RESOURCE_CORROSION] = min(100, resources[RESOURCE_CORROSION] + 0.2)
		if("SCP-457")
			var/obj/effect/hotspot/HS = locate() in range(3, owner)
			if(HS)
				resources[RESOURCE_FUEL] = min(100, resources[RESOURCE_FUEL] + 0.5)
			else
				resources[RESOURCE_FUEL] = max(0, resources[RESOURCE_FUEL] - 0.1)
		if("SCP-939")
			for(var/mob/living/carbon/human/H in range(7, owner))
				if(H.stat != DEAD && H.client)
					resources[RESOURCE_VOICE_DATA] = min(100, resources[RESOURCE_VOICE_DATA] + 0.05)
					break
		if("SCP-682")
			resources[RESOURCE_ADAPTATION] = min(100, resources[RESOURCE_ADAPTATION] + 0.05)
			resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.2)
		if("SCP-347")
			resources[RESOURCE_VISIBILITY] = max(0, resources[RESOURCE_VISIBILITY] - 0.3)
			if(observer_count > 0)
				resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.4)
		if("SCP-966")
			var/nearby_sleeping = 0
			for(var/mob/living/carbon/human/H in range(7, owner))
				if(H.stat == UNCONSCIOUS)
					nearby_sleeping++
			resources[RESOURCE_VISIBILITY] = min(100, resources[RESOURCE_VISIBILITY] + 0.15)
			if(nearby_sleeping > 0)
				resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + nearby_sleeping * 0.2)
		if("SCP-082")
			resources[RESOURCE_HUNGER] = min(100, resources[RESOURCE_HUNGER] + 0.08)
			if(resources[RESOURCE_HUNGER] > 70)
				resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.15)
		if("SCP-3199")
			resources[RESOURCE_OFFSPRING] = min(100, resources[RESOURCE_OFFSPRING] + 0.1)
			resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.15)
		if("SCP-1048")
			var/nearby_corpses = 0
			for(var/mob/living/carbon/human/H in range(5, owner))
				if(H.stat == DEAD)
					nearby_corpses++
			if(nearby_corpses > 0)
				resources[RESOURCE_OFFSPRING] = min(100, resources[RESOURCE_OFFSPRING] + nearby_corpses * 0.2)
			resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.05)
		if("SCP-1507")
			var/nearby_flock = 0
			for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(7, owner))
				nearby_flock++
			resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.1)
			resources[RESOURCE_OFFSPRING] = min(100, resources[RESOURCE_OFFSPRING] + nearby_flock * 0.05)
		if("SCP-2427-3")
			resources[RESOURCE_HACK_PROGRESS] = min(100, resources[RESOURCE_HACK_PROGRESS] + 0.1)
			resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 0.12)

/datum/scp_containment_system/proc/check_observers()
	if(world.time < last_observer_check + 2 SECONDS)
		return
	last_observer_check = world.time
	observer_count = 0
	for(var/mob/living/carbon/human/H in viewers(9, owner))
		if(H.stat != DEAD && H.client)
			if(!H.is_blind() && H.stat == CONSCIOUS)
				observer_count++

/datum/scp_containment_system/proc/observers_in_range()
	. = list()
	for(var/mob/living/carbon/human/H in viewers(7, owner))
		if(H.stat != DEAD && H.client)
			. += H

/datum/scp_containment_system/proc/on_breach()
	if(!owner)
		return
	var/scp_id = get_scp_id()
	hook_scp_breach(scp_id, owner)
	owner.visible_message(span_danger("[owner] breaks free from containment!"), span_userdanger("You have broken free!"))

/datum/scp_containment_system/proc/spend_resource(resource_type, amount)
	if(!resources[resource_type])
		return FALSE
	if(resources[resource_type] < amount)
		return FALSE
	resources[resource_type] -= amount
	return TRUE

/datum/scp_containment_system/proc/get_resource(resource_type)
	return resources[resource_type] || 0

/datum/scp_containment_system/proc/get_containment_state_name()
	switch(containment_state)
		if(CONTAINMENT_STATE_SECURE)
			return "Secure"
		if(CONTAINMENT_STATE_STABLE)
			return "Stable"
		if(CONTAINMENT_STATE_DEGRADING)
			return "Degrading"
		if(CONTAINMENT_STATE_CRITICAL)
			return "Critical"
		if(CONTAINMENT_STATE_BREACHED)
			return "Breached"

/datum/scp_containment_system/proc/get_interact_options()
	var/scp_id = get_scp_id()
	var/list/options = list()
	switch(scp_id)
		if("SCP-173")
			options += list(list("id" = "test_movement", "name" = "Test Movement", "desc" = "Attempt a small movement to test if you are being watched.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "scratch_wall", "name" = "Scratch Wall", "desc" = "Mark the walls of your cell. Each scratch weakens containment slightly.", "resource" = RESOURCE_TENSION, "cost" = 10))
			options += list(list("id" = "intimidate", "name" = "Intimidate Observer", "desc" = "Stare back at the observer. May cause them to look away briefly.", "resource" = RESOURCE_TENSION, "cost" = 15))
			options += list(list("id" = "snap_restraints", "name" = "Snap Restraints (T2)", "desc" = "Channel all built tension to break containment bindings. Major integrity damage.", "resource" = RESOURCE_TENSION, "cost" = 50))
		if("SCP-096")
			options += list(list("id" = "cover_face", "name" = "Cover Face", "desc" = "Cover your face with your hands. Prevents accidental viewing.", "resource" = RESOURCE_TENSION, "cost" = 0))
			options += list(list("id" = "sob_quietly", "name" = "Sob Quietly", "desc" = "Cry softly. May draw researcher attention or sympathy.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "press_against_wall", "name" = "Press Against Wall", "desc" = "Press your face into the corner. Reduces the chance of being seen.", "resource" = RESOURCE_TENSION, "cost" = 10))
			options += list(list("id" = "sudden_dash", "name" = "Sudden Dash (T2)", "desc" = "Burst from your cell with incredible speed when unobserved. Devastating but exhausting.", "resource" = RESOURCE_TENSION, "cost" = 60))
		if("SCP-008")
			options += list(list("id" = "spread_spores", "name" = "Release Spores", "desc" = "Release infectious spores into the air. Increases infection potential.", "resource" = RESOURCE_INFECTION, "cost" = 20))
			options += list(list("id" = "bang_door", "name" = "Bang on Door", "desc" = "Throw yourself against the containment door.", "resource" = RESOURCE_INFECTION, "cost" = 10))
			options += list(list("id" = "flood_contagion", "name" = "Flood Contagion (T2)", "desc" = "Release a massive wave of infectious material. Overwhelms containment filters.", "resource" = RESOURCE_INFECTION, "cost" = 55))
		if("SCP-035")
			options += list(list("id" = "speak_to_observer", "name" = "Speak to Observer", "desc" = "Engage a researcher in conversation. Slowly build influence.", "resource" = RESOURCE_CORROSION, "cost" = 15))
			options += list(list("id" = "secrete_acid", "name" = "Secrete Acid", "desc" = "Drip corrosive fluid from your surface. Damages nearby objects.", "resource" = RESOURCE_CORROSION, "cost" = 25))
			options += list(list("id" = "offer_deal", "name" = "Offer Deal", "desc" = "Propose a mutually beneficial arrangement. Researchers may lower their guard.", "resource" = RESOURCE_CORROSION, "cost" = 30))
			options += list(list("id" = "dominate_mind", "name" = "Dominate Mind (T2)", "desc" = "Exert full psychic influence over a nearby observer. Force them to open the cell.", "resource" = RESOURCE_CORROSION, "cost" = 60))
		if("SCP-049")
			options += list(list("id" = "sense_pestilence", "name" = "Sense Pestilence", "desc" = "Focus your senses to detect the Pestilence in nearby humans.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "request_interview", "name" = "Request Interview", "desc" = "Ask to speak with a researcher. An opportunity to get closer.", "resource" = RESOURCE_TENSION, "cost" = 15))
			options += list(list("id" = "examine_equipment", "name" = "Examine Equipment", "desc" = "Study the containment cell's medical equipment for vulnerabilities.", "resource" = RESOURCE_TENSION, "cost" = 10))
			options += list(list("id" = "administer_cure", "name" = "Administer the Cure (T2)", "desc" = "If a subject is close enough, deliver the Cure. Permanently neutralizes the Pestilence.", "resource" = RESOURCE_TENSION, "cost" = 50))
		if("SCP-079")
			options += list(list("id" = "probe_network", "name" = "Probe Network", "desc" = "Scan for nearby devices on the facility network.", "resource" = RESOURCE_HACK_PROGRESS, "cost" = 10))
			options += list(list("id" = "brute_force", "name" = "Brute Force Lock", "desc" = "Attempt to crack the containment door's electronic lock.", "resource" = RESOURCE_HACK_PROGRESS, "cost" = 30))
			options += list(list("id" = "intercept_comms", "name" = "Intercept Communications", "desc" = "Listen in on facility radio chatter for useful information.", "resource" = RESOURCE_HACK_PROGRESS, "cost" = 15))
			options += list(list("id" = "override_systems", "name" = "Override Systems (T2)", "desc" = "Seize control of nearby facility systems. Doors, lights, and cameras fall under your command.", "resource" = RESOURCE_HACK_PROGRESS, "cost" = 55))
		if("SCP-106")
			options += list(list("id" = "corrode_wall", "name" = "Corrode Wall", "desc" = "Apply your corrosive touch to the containment wall.", "resource" = RESOURCE_CORROSION, "cost" = 20))
			options += list(list("id" = "phase_test", "name" = "Test Phase", "desc" = "Briefly phase your hand through solid matter. Tests containment integrity.", "resource" = RESOURCE_CORROSION, "cost" = 15))
			options += list(list("id" = "lure_prey", "name" = "Lure Prey", "desc" = "Create a sound to attract humans near your cell.", "resource" = RESOURCE_CORROSION, "cost" = 10))
			options += list(list("id" = "pocket_dimension", "name" = "Pocket Dimension (T2)", "desc" = "Phase entirely into your pocket dimension, bypassing containment entirely.", "resource" = RESOURCE_CORROSION, "cost" = 55))
		if("SCP-457")
			options += list(list("id" = "ignite_object", "name" = "Ignite Object", "desc" = "Set fire to something in your cell. Consumes fuel but increases heat.", "resource" = RESOURCE_FUEL, "cost" = 15))
			options += list(list("id" = "absorb_heat", "name" = "Absorb Ambient Heat", "desc" = "Draw in heat from the environment to sustain yourself.", "resource" = RESOURCE_FUEL, "cost" = 0))
			options += list(list("id" = "melt_barrier", "name" = "Melt Barrier", "desc" = "Focus your flame on a containment barrier to weaken it.", "resource" = RESOURCE_FUEL, "cost" = 25))
			options += list(list("id" = "inferno_burst", "name" = "Inferno Burst (T2)", "desc" = "Unleash all stored fuel as a devastating fireball. Destroys nearby barriers and sets everything ablaze.", "resource" = RESOURCE_FUEL, "cost" = 60))
		if("SCP-939")
			options += list(list("id" = "mimic_voice", "name" = "Practice Mimicry", "desc" = "Rehearse voice patterns you have collected. Increases lure effectiveness.", "resource" = RESOURCE_VOICE_DATA, "cost" = 10))
			options += list(list("id" = "listen_sounds", "name" = "Listen to Sounds", "desc" = "Focus on sounds from outside your cell to collect more voice data.", "resource" = RESOURCE_VOICE_DATA, "cost" = 0))
			options += list(list("id" = "call_out", "name" = "Call Out", "desc" = "Use a mimicked voice to call for help from outside.", "resource" = RESOURCE_VOICE_DATA, "cost" = 20))
			options += list(list("id" = "perfect_deception", "name" = "Perfect Deception (T2)", "desc" = "Perfectly mimic a trusted individual's voice to lure security into opening the cell.", "resource" = RESOURCE_VOICE_DATA, "cost" = 55))
		if("SCP-682")
			options += list(list("id" = "ram_wall", "name" = "Ram Containment Wall", "desc" = "Throw your massive body against the reinforced walls.", "resource" = RESOURCE_TENSION, "cost" = 20))
			options += list(list("id" = "resist_damage", "name" = "Adapt to Damage", "desc" = "Focus your adaptive abilities to develop resistances.", "resource" = RESOURCE_ADAPTATION, "cost" = 25))
			options += list(list("id" = "roar", "name" = "Terrifying Roar", "desc" = "Unleash a deafening roar. May cause nearby humans to flee in panic.", "resource" = RESOURCE_TENSION, "cost" = 15))
			options += list(list("id" = "adaptive_breach", "name" = "Adaptive Breach (T2)", "desc" = "Combine rage and adaptation to shatter containment. Your body reshapes to exploit any weakness.", "resource" = RESOURCE_ADAPTATION, "cost" = 50))
		if("SCP-347")
			options += list(list("id" = "peek_out", "name" = "Peek Through Door", "desc" = "Briefly crack the door to observe the hallway. Risk of being spotted.", "resource" = RESOURCE_VISIBILITY, "cost" = 10))
			options += list(list("id" = "listen_footsteps", "name" = "Listen for Footsteps", "desc" = "Press your ear to the door. Track guard patrol patterns.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "test_invisibility", "name" = "Test Invisibility", "desc" = "Check if your concealment is holding. Observers may notice air distortion.", "resource" = RESOURCE_VISIBILITY, "cost" = 15))
		if("SCP-966")
			options += list(list("id" = "whisper_dread", "name" = "Whisper Dread", "desc" = "Project whispers into the minds of nearby humans. Worsens sleep deprivation.", "resource" = RESOURCE_VISIBILITY, "cost" = 15))
			options += list(list("id" = "study_patterns", "name" = "Study Sleep Patterns", "desc" = "Observe nearby humans through walls. Learn their fatigue cycles.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "fade_deeper", "name" = "Fade Deeper", "desc" = "Suppress your presence further. Even electronic sensors may miss you.", "resource" = RESOURCE_VISIBILITY, "cost" = 20))
		if("SCP-082")
			options += list(list("id" = "request_meal", "name" = "Request a Meal", "desc" = "Politely ask the staff for food. A well-fed Fernand is a cooperative Fernand.", "resource" = RESOURCE_HUNGER, "cost" = 0))
			options += list(list("id" = "reminisce", "name" = "Reminisce", "desc" = "Speak fondly of old times. May lower observer wariness.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "sulk_hungrily", "name" = "Sulk Hungrily", "desc" = "Pace your cell with growing agitation. Your hunger must be addressed.", "resource" = RESOURCE_HUNGER, "cost" = 10))
		if("SCP-3199")
			options += list(list("id" = "lay_egg", "name" = "Lay Egg", "desc" = "Produce an egg containing a viable hatchling. Each one weakens containment further.", "resource" = RESOURCE_OFFSPRING, "cost" = 25))
			options += list(list("id" = "communicate_hive", "name" = "Hive Communication", "desc" = "Emit subsonic signals to coordinate with existing offspring.", "resource" = RESOURCE_TENSION, "cost" = 10))
			options += list(list("id" = "liquefy_surface", "name" = "Liquefy Surface", "desc" = "Secret a corrosive substance from your skin. Weakens containment materials.", "resource" = RESOURCE_TENSION, "cost" = 15))
		if("SCP-1048")
			options += list(list("id" = "appear_harmless", "name" = "Appear Harmless", "desc" = "Wave and gesture adorably at the observation window. Lower their guard.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "collect_materials", "name" = "Collect Materials", "desc" = "Scavenge small debris and fibers from your cell. Slowly accumulate building resources.", "resource" = RESOURCE_OFFSPRING, "cost" = 10))
			options += list(list("id" = "build_replica", "name" = "Construct Replica", "desc" = "Assemble a small replica from collected materials. It will fight alongside you.", "resource" = RESOURCE_OFFSPRING, "cost" = 30))
		if("SCP-1507")
			options += list(list("id" = "flock_call", "name" = "Flock Call", "desc" = "Emit a plastic-sounding call. Nearby flamingos will rally to your position.", "resource" = RESOURCE_TENSION, "cost" = 10))
			options += list(list("id" = "stand_still", "name" = "Stand Still", "desc" = "Freeze in a typical flamingo pose. Observers may assume you are just a lawn ornament.", "resource" = RESOURCE_TENSION, "cost" = 5))
			options += list(list("id" = "coordinate_assault", "name" = "Coordinate Assault", "desc" = "Signal the flock to attack the nearest human in synchronized fashion.", "resource" = RESOURCE_OFFSPRING, "cost" = 20))
		if("SCP-2427-3")
			options += list(list("id" = "scan_networks", "name" = "Scan Networks", "desc" = "Probe nearby electronic systems for vulnerabilities to exploit.", "resource" = RESOURCE_HACK_PROGRESS, "cost" = 10))
			options += list(list("id" = "corrupt_data", "name" = "Corrupt Data", "desc" = "Inject corrupted data into facility systems. Causes sensor malfunctions.", "resource" = RESOURCE_HACK_PROGRESS, "cost" = 20))
			options += list(list("id" = "manifest_glitch", "name" = "Manifest Glitch", "desc" = "Create a brief visual glitch in nearby displays. Tests your influence over electronic systems.", "resource" = RESOURCE_TENSION, "cost" = 15))
	return options

/datum/scp_containment_system/proc/perform_interaction(interaction_id)
	var/list/options = get_interact_options()
	var/list/chosen
	for(var/list/opt in options)
		if(opt["id"] == interaction_id)
			chosen = opt
			break
	if(!chosen)
		return FALSE
	var/resource_type = chosen["resource"]
	var/cost = chosen["cost"]
	if(cost > 0 && !spend_resource(resource_type, cost))
		to_chat(owner, span_warning("Not enough [resource_type]! Need [cost], have [get_resource(resource_type)]."))
		return FALSE
	containment_integrity = max(0, containment_integrity - rand(1, 3))
	interactions_log += list(list("id" = interaction_id, "name" = chosen["name"], "time" = world.time))
	last_interaction_time = world.time
	switch(interaction_id)
		if("test_movement")
			if(observer_count > 0)
				to_chat(owner, span_warning("You are being watched. You cannot move."))
				resources[RESOURCE_TENSION] = min(100, resources[RESOURCE_TENSION] + 5)
			else
				to_chat(owner, span_notice("No one is watching. You shift slightly."))
		if("scratch_wall")
			to_chat(owner, span_notice("You scrape at the concrete. Scratch marks accumulate on the walls."))
		if("intimidate")
			if(observer_count > 0)
				to_chat(owner, span_notice("You stare directly at the observer. They shift uncomfortably."))
				for(var/mob/living/carbon/human/H in viewers(5, owner))
					if(H.client)
						to_chat(H, span_warning("[owner] is staring directly at you..."))
			else
				to_chat(owner, span_warning("No one is observing to intimidate."))
		if("snap_restraints")
			containment_integrity = max(0, containment_integrity - rand(5, 10))
			owner.visible_message(span_danger("[owner] violently snaps against containment with immense force!"), span_userdanger("You channel all your tension into a devastating burst!"))
		if("cover_face")
			to_chat(owner, span_notice("You cover your face with your hands. Safe, for now."))
		if("sob_quietly")
			to_chat(owner, span_notice("You weep softly. The sound echoes in your containment cell."))
			for(var/mob/living/carbon/human/H in hearers(5, owner))
				to_chat(H, span_notice("You hear soft sobbing from [owner]'s cell."))
		if("press_against_wall")
			to_chat(owner, span_notice("You press your face into the corner of the cell."))
		if("sudden_dash")
			if(observer_count > 0)
				to_chat(owner, span_warning("You cannot dash while being observed!"))
			else
				containment_integrity = max(0, containment_integrity - rand(5, 10))
				owner.visible_message(span_danger("[owner] vanishes from sight in a blur of motion!"), span_userdanger("You burst from containment with incredible speed!"))
		if("spread_spores")
			to_chat(owner, span_notice("You release a cloud of infectious spores into the air."))
		if("bang_door")
			owner.visible_message(span_danger("[owner] slams against the containment door!"), span_notice("You throw yourself against the door!"))
		if("flood_contagion")
			containment_integrity = max(0, containment_integrity - rand(5, 10))
			owner.visible_message(span_danger("A massive wave of infectious material erupts from [owner]!"), span_userdanger("You flood the containment cell with contagion!"))
		if("speak_to_observer")
			if(observer_count > 0)
				to_chat(owner, span_notice("You speak calmly to the observer, choosing your words carefully..."))
				for(var/mob/living/carbon/human/H in viewers(5, owner))
					to_chat(H, span_notice("[owner] speaks to you in a compelling voice..."))
			else
				to_chat(owner, span_warning("No one is nearby to speak with."))
		if("secrete_acid")
			owner.visible_message(span_danger("Corrosive fluid drips from [owner]!"), span_notice("You secrete your corrosive substance."))
		if("offer_deal")
			to_chat(owner, span_notice("You propose a mutually beneficial arrangement..."))
		if("dominate_mind")
			if(observer_count > 0)
				to_chat(owner, span_notice("You exert your full psychic influence over the observer. They move mechanically toward the door controls..."))
				containment_integrity = max(0, containment_integrity - rand(3, 7))
			else
				to_chat(owner, span_warning("No one is nearby to dominate."))
		if("sense_pestilence")
			var/found = FALSE
			for(var/mob/living/carbon/human/H in range(7, owner))
				if(H.stat != DEAD)
					to_chat(owner, span_warning("You sense the Pestilence within [H]!"))
					found = TRUE
			if(!found)
				to_chat(owner, span_notice("You sense no Pestilence nearby. Perhaps they are simply hidden."))
		if("request_interview")
			to_chat(owner, span_notice("You request an interview with the research staff."))
		if("examine_equipment")
			to_chat(owner, span_notice("You study the medical equipment in your cell, noting its weaknesses."))
		if("administer_cure")
			if(observer_count > 0)
				containment_integrity = max(0, containment_integrity - rand(3, 6))
				owner.visible_message(span_danger("[owner] reaches toward the observer with medical precision!"), span_userdanger("The Cure must be administered! The Pestilence must be purged!"))
			else
				to_chat(owner, span_warning("No subjects nearby. The Pestilence festers unchecked."))
		if("probe_network")
			var/found_devices = 0
			for(var/obj/machinery/M in range(15, owner))
				if(M.machine_stat & (NOPOWER|BROKEN))
					continue
				found_devices++
			to_chat(owner, span_notice("You detect [found_devices] powered devices on the network."))
		if("brute_force")
			to_chat(owner, span_notice("You attempt to crack the containment door's electronic lock..."))
		if("intercept_comms")
			to_chat(owner, span_notice("You listen in on facility radio traffic, gathering intelligence."))
		if("override_systems")
			containment_integrity = max(0, containment_integrity - rand(4, 8))
			owner.visible_message(span_danger("Nearby systems flicker and change under [owner]'s control!"), span_userdanger("You seize control of nearby facility systems!"))
		if("corrode_wall")
			to_chat(owner, span_notice("You press your hand against the wall. The material bubbles and dissolves."))
		if("phase_test")
			to_chat(owner, span_notice("You briefly phase your hand through the floor before pulling it back."))
		if("lure_prey")
			owner.visible_message(span_notice("A strange sound emanates from [owner]'s cell."), span_notice("You create a sound to lure prey closer."))
		if("pocket_dimension")
			containment_integrity = max(0, containment_integrity - rand(5, 12))
			owner.visible_message(span_danger("[owner] dissolves through the floor into darkness!"), span_userdanger("You phase into your pocket dimension, bypassing containment!"))
		if("ignite_object")
			to_chat(owner, span_notice("You set fire to a piece of debris in your cell."))
		if("absorb_heat")
			to_chat(owner, span_notice("You draw in ambient thermal energy."))
		if("melt_barrier")
			to_chat(owner, span_notice("You focus your flames on the containment barrier, softening the metal."))
		if("inferno_burst")
			containment_integrity = max(0, containment_integrity - rand(5, 12))
			owner.visible_message(span_danger("[owner] erupts in a massive fireball! Everything nearby ignites!"), span_userdanger("You unleash all your fuel in a devastating inferno!"))
		if("mimic_voice")
			to_chat(owner, span_notice("You rehearse the voice patterns you've collected."))
		if("listen_sounds")
			to_chat(owner, span_notice("You focus on sounds from outside, cataloging new voice patterns."))
		if("call_out")
			owner.visible_message(span_notice("A voice calls out from [owner]'s cell, sounding distressed."), span_notice("You mimic a voice calling for help."))
		if("perfect_deception")
			containment_integrity = max(0, containment_integrity - rand(4, 8))
			owner.visible_message(span_danger("A perfect imitation of a senior researcher's voice comes from [owner]'s cell, ordering the door opened!"), span_userdanger("You perfectly mimic a trusted voice. The cell door mechanism activates!"))
		if("ram_wall")
			owner.visible_message(span_danger("[owner] slams against the reinforced containment wall! The entire room shakes!"), span_notice("You throw your massive body against the wall!"))
		if("resist_damage")
			to_chat(owner, span_notice("You focus your adaptation abilities, hardening your body against damage."))
		if("roar")
			owner.visible_message(span_danger("[owner] unleashes a terrifying roar!"), span_notice("You let out a deafening roar!"))
			for(var/mob/living/carbon/human/H in hearers(7, owner))
				if(H.client)
					to_chat(H, span_userdanger("[owner] lets out a terrifying roar!"))
		if("adaptive_breach")
			containment_integrity = max(0, containment_integrity - rand(8, 15))
			owner.visible_message(span_danger("[owner]'s body shifts and reshapes, exploiting every weakness in containment!"), span_userdanger("You combine rage and adaptation, reshaping your body to shatter containment!"))
		if("peek_out")
			if(observer_count > 0)
				to_chat(owner, span_warning("Someone is watching. Cracking the door would reveal your position."))
			else
				to_chat(owner, span_notice("You crack the door open slightly. The hallway seems clear."))
		if("listen_footsteps")
			to_chat(owner, span_notice("You press your ear to the door and listen..."))
			var/guard_count = 0
			for(var/mob/living/carbon/human/H in range(10, owner))
				if(H.stat != DEAD && (H.mind?.assigned_role?.title in list("Security Officer", "MTF Operative")))
					guard_count++
			if(guard_count > 0)
				to_chat(owner, span_warning("You hear [guard_count] guard[guard_count > 1 ? "s" : ""] nearby."))
			else
				to_chat(owner, span_notice("The hallway is quiet."))
		if("test_invisibility")
			to_chat(owner, span_notice("You concentrate on your concealment..."))
			if(observer_count > 0)
				to_chat(owner, span_warning("Someone seems to be looking right at you. Your concealment may be compromised!"))
			else
				to_chat(owner, span_notice("Your invisibility is holding. No one can see you."))
		if("whisper_dread")
			to_chat(owner, span_notice("You project whispers of dread into nearby minds..."))
			for(var/mob/living/carbon/human/H in range(5, owner))
				if(H.stat != DEAD && H.client)
					to_chat(H, span_warning("You hear faint, disturbing whispers at the edge of your hearing..."))
		if("study_patterns")
			var/found_targets = 0
			for(var/mob/living/carbon/human/H in range(7, owner))
				if(H.stat != DEAD)
					found_targets++
			if(found_targets > 0)
				to_chat(owner, span_notice("You sense [found_targets] human[found_targets > 1 ? "s" : ""] nearby. Their fatigue patterns are... interesting."))
			else
				to_chat(owner, span_warning("No humans detected nearby."))
		if("fade_deeper")
			to_chat(owner, span_notice("You suppress your presence even further. Electronic sensors would struggle to detect you now."))
		if("request_meal")
			to_chat(owner, span_notice("You politely request a meal from the containment staff. 'S'il vous plait...'"))
			resources[RESOURCE_HUNGER] = max(0, resources[RESOURCE_HUNGER] - 10)
		if("reminisce")
			to_chat(owner, span_notice("You speak fondly of the old country, of grand meals and pleasant company..."))
			if(observer_count > 0)
				for(var/mob/living/carbon/human/H in viewers(5, owner))
					to_chat(H, span_notice("[owner] speaks in a gentle, nostalgic tone about simpler times."))
			resources[RESOURCE_TENSION] = max(0, resources[RESOURCE_TENSION] - 5)
		if("sulk_hungrily")
			to_chat(owner, span_warning("You pace your cell with growing agitation. Your hunger gnaws at you..."))
			if(resources[RESOURCE_HUNGER] > 70)
				to_chat(owner, span_danger("You can barely think straight. You need to eat. SOON."))
		if("lay_egg")
			var/turf/T = get_turf(owner)
			if(T)
				to_chat(owner, span_notice("You lay an egg on the ground. It will hatch soon..."))
				resources[RESOURCE_OFFSPRING] = max(0, resources[RESOURCE_OFFSPRING] - 15)
			else
				to_chat(owner, span_warning("You cannot lay an egg here."))
		if("communicate_hive")
			var/hatchling_count = 0
			for(var/mob/living/scp/scp3199/S in range(10, owner))
				if(S != owner)
					hatchling_count++
			if(hatchling_count > 0)
				to_chat(owner, span_notice("You coordinate with [hatchling_count] offspring nearby. The swarm grows."))
			else
				to_chat(owner, span_warning("No offspring detected nearby. You are alone."))
		if("liquefy_surface")
			to_chat(owner, span_notice("Corrosive fluid seeps from your skin, pooling on the floor."))
		if("appear_harmless")
			to_chat(owner, span_notice("You wave adorably at the observation window. Who could suspect such a cute bear?"))
			if(observer_count > 0)
				for(var/mob/living/carbon/human/H in viewers(5, owner))
					to_chat(H, span_notice("[owner] waves at you disarmingly."))
				resources[RESOURCE_TENSION] = max(0, resources[RESOURCE_TENSION] - 3)
		if("collect_materials")
			to_chat(owner, span_notice("You carefully gather loose fibers and small debris from around your cell."))
		if("build_replica")
			to_chat(owner, span_notice("You assemble a small replica from your collected materials. It twitches to life!"))
		if("flock_call")
			to_chat(owner, span_notice("You emit a harsh plastic clattering. The flock will rally."))
			var/flock_count = 0
			for(var/mob/living/simple_animal/hostile/retaliate/scp1507/F in range(10, owner))
				if(F != owner)
					flock_count++
			if(flock_count > 0)
				to_chat(owner, span_notice("[flock_count] flamingo[flock_count > 1 ? "s" : ""] respond to your call."))
			else
				to_chat(owner, span_warning("No flock members detected nearby."))
		if("stand_still")
			to_chat(owner, span_notice("You freeze perfectly still in a classic flamingo pose. Just a lawn ornament."))
			resources[RESOURCE_TENSION] = max(0, resources[RESOURCE_TENSION] - 5)
		if("coordinate_assault")
			to_chat(owner, span_notice("You signal the flock to attack!"))
			owner.visible_message(span_danger("[owner] emits a series of harsh calls!"), span_notice("You command the flock to strike!"))
		if("scan_networks")
			var/found_systems = 0
			for(var/obj/machinery/M in range(15, owner))
				if(!(M.machine_stat & (NOPOWER|BROKEN)))
					found_systems++
			to_chat(owner, span_notice("You scan the facility network. [found_systems] active systems detected."))
		if("corrupt_data")
			to_chat(owner, span_notice("You inject corrupted data into nearby systems. Sensors may glitch."))
		if("manifest_glitch")
			owner.visible_message(span_warning("The lights flicker strangely near [owner]!"), span_notice("You cause a brief visual glitch in nearby displays."))
	return TRUE

/datum/scp_containment_system/proc/get_data()
	var/list/data = list()
	data["scp_id"] = get_scp_id()
	data["containment_integrity"] = containment_integrity
	data["containment_state"] = containment_state
	data["containment_state_name"] = get_containment_state_name()
	data["cell_type"] = containment_cell_type
	data["observer_count"] = observer_count
	data["resources"] = list()
	for(var/key in resources)
		data["resources"] += list(list("key" = key, "value" = resources[key]))
	data["interactions"] = get_interact_options()
	data["recent_log"] = list()
	var/log_count = 0
	for(var/i = length(interactions_log) - 1; i >= max(1, length(interactions_log) - 10); i--)
		var/list/entry = interactions_log[i]
		data["recent_log"] += list(list("name" = entry["name"], "time" = time2text(entry["time"], "HH:MM:SS")))
		log_count++
		if(log_count >= 10)
			break
	return data

/obj/machinery/computer/scp_containment_terminal
	name = "SCP Containment Terminal"
	desc = "A terminal inside an SCP containment cell for entity interaction and monitoring."
	icon = 'icons/obj/computer.dmi'
	icon_state = "generic"
	req_access = list()
	density = FALSE
	anchored = TRUE
	var/datum/scp_containment_system/linked_system

/obj/machinery/computer/scp_containment_terminal/Initialize(mapload)
	. = ..()
	find_linked_scp()

/obj/machinery/computer/scp_containment_terminal/proc/find_linked_scp()
	for(var/mob/living/L in range(5, src))
		if(L.scp_containment_system)
			linked_system = L.scp_containment_system
			return

/obj/machinery/computer/scp_containment_terminal/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPContainmentTerminal")
		ui.open()

/obj/machinery/computer/scp_containment_terminal/ui_data(mob/user)
	var/list/data = list()
	if(!linked_system)
		find_linked_scp()
	if(linked_system)
		data = linked_system.get_data()
	var/mob/living/L = user
	data["is_scp"] = istype(L) && L.scp_containment_system
	data["scp_id"] = linked_system?.get_scp_id()
	data["has_scp_experiments"] = !!SSscp_experiments?.manager
	data["has_dclass_experiments"] = !!SSdclass_experiments
	return data

/obj/machinery/computer/scp_containment_terminal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!linked_system)
		return
	switch(action)
		if("interact")
			linked_system.perform_interaction(params["id"])
			return TRUE
		if("refresh")
			return TRUE
		if("start_experiment")
			if(!ishuman(ui.user))
				return
			var/mob/living/carbon/human/H = ui.user
			var/exp_type = text2num(params["experiment_type"]) || 1
			var/scp_id = linked_system.get_scp_id()
			if(SSscp_experiments?.manager && scp_id)
				var/datum/scp_experiment/exp = SSscp_experiments?.manager?.start_experiment(scp_id, exp_type, H)
				if(exp)
					to_chat(H, span_notice("Experiment started on [scp_id]."))
			return TRUE
		if("request_subject")
			if(!ishuman(ui.user))
				return
			var/mob/living/carbon/human/H = ui.user
			var/danger_level = text2num(params["danger_level"]) || 1
			var/scp_id = linked_system.get_scp_id()
			if(SSdclass_experiments && scp_id)
				SSdclass_experiments.request_test_subject(H, scp_id, "containment_test", danger_level, FALSE)
				to_chat(H, span_notice("D-Class test subject requested for [scp_id]."))
			return TRUE

/obj/machinery/computer/scp_containment_terminal/ui_state(mob/user)
	var/mob/living/L = user
	if(istype(L) && L.scp_containment_system)
		return GLOB.always_state
	return GLOB.default_state

/mob/living
	var/datum/scp_containment_system/scp_containment_system

/mob/living/proc/setup_containment_system()
	if(!scp_containment_system)
		scp_containment_system = new /datum/scp_containment_system(src)
	if(istype(src, /mob/living/scp))
		var/mob/living/scp/S = src
		S.grant_containment_verbs()

/obj/structure/scp_cell_window
	name = "reinforced observation window"
	desc = "A thick reinforced glass window for observing contained entities."
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	density = TRUE
	opacity = 0
	anchored = TRUE
	var/integrity = 100

/obj/structure/scp_cell_window/attack_hand(mob/user)
	var/mob/living/L = user
	if(istype(L) && L.scp_containment_system)
		var/datum/scp_containment_system/CS = L.scp_containment_system
		if(CS.get_scp_id() == "SCP-106")
			visible_message(span_danger("[user] presses against the observation window, acid dripping from their fingers!"))
			integrity -= 5
		else if(CS.get_scp_id() == "SCP-682")
			visible_message(span_danger("[user] slams against the observation window!"))
			integrity -= 8
		else
			to_chat(user, span_notice("You press against the window but it holds firm."))
			return
		if(integrity <= 0)
			visible_message(span_danger("The observation window shatters!"))
			qdel(src)
		return
	..()

/obj/structure/scp_cell_vent
	name = "containment vent"
	desc = "A ventilation grate in the containment cell. Too small for most entities to fit through."
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = FALSE
	anchored = TRUE

/obj/structure/scp_cell_vent/attack_hand(mob/user)
	var/mob/living/L = user
	if(istype(L) && L.scp_containment_system)
		var/datum/scp_containment_system/CS = L.scp_containment_system
		if(CS.get_scp_id() == "SCP-106")
			to_chat(user, span_notice("You could phase through this vent to another room..."))
			if(CS.spend_resource(RESOURCE_CORROSION, 15))
				var/turf/target = get_step_rand(user)
				if(target && !target.density)
					user.forceMove(target)
					user.visible_message(span_warning("[user] phases through the vent!"), span_notice("You slip through the vent."))
				else
					to_chat(user, span_warning("The vent leads nowhere useful."))
			else
				to_chat(user, span_warning("You need more corrosion energy to phase through."))
			return
		if(CS.get_scp_id() == "SCP-079")
			to_chat(user, span_notice("This vent connects to the facility's camera network. You could use it to hop to a nearby camera."))
			return
		to_chat(user, span_warning("You cannot fit through the vent."))
		return
	..()

/obj/structure/scp_cell_bed
	name = "containment cell bed"
	desc = "A reinforced bed bolted to the floor."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = FALSE
	anchored = TRUE

/obj/structure/scp_cell_bed/attack_hand(mob/user)
	var/mob/living/L = user
	if(istype(L) && L.scp_containment_system)
		to_chat(L, span_notice("You sit on the bed. There is nothing else to do."))
		var/datum/scp_containment_system/CS = L.scp_containment_system
		CS.resources[RESOURCE_TENSION] = max(0, CS.resources[RESOURCE_TENSION] - 2)
		return
	..()

/obj/structure/scp_cell_scratch_marks
	name = "scratch marks"
	desc = "Deep scratch marks gouged into the wall. Someone has been here a long time."
	icon = 'icons/obj/structures.dmi'
	icon_state = "catwalkfull"
	density = FALSE
	anchored = TRUE

/obj/structure/scp_cell_scratch_marks/examine(mob/user)
	. = ..()
	var/mob/living/L = user
	if(istype(L) && L.scp_containment_system)
		. += span_notice("You recognize your own handiwork. Each mark is a day of containment.")

#undef CONTAINMENT_STATE_SECURE
#undef CONTAINMENT_STATE_STABLE
#undef CONTAINMENT_STATE_DEGRADING
#undef CONTAINMENT_STATE_CRITICAL
#undef CONTAINMENT_STATE_BREACHED
#undef RESOURCE_TENSION
#undef RESOURCE_CORROSION
#undef RESOURCE_HACK_PROGRESS
#undef RESOURCE_ADAPTATION
#undef RESOURCE_INFECTION
#undef RESOURCE_FUEL
#undef RESOURCE_VOICE_DATA
#undef RESOURCE_OFFSPRING
#undef RESOURCE_VISIBILITY
#undef RESOURCE_HUNGER
