/mob/living/scp/scp2343
	name = "strange american man"
	desc = "A brusk and wiley man of american decent."
	icon = 'icons/scp/scp_2343.dmi'
	icon_state = "americangod"
	status_flags = 0
	var/datum/scp2343_benevolence_system/benevolence_system
	var/datum/scp2343_research_system/research_system

/mob/living/scp/scp2343/Initialize(mapload)
	. = ..()
	set_species(/datum/species/scp2343)
	SCP = new /datum/scp(src, "benevolent entity", SCP_SAFE, "2343", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	// Register with SCP persistence system
	addtimer(CALLBACK(src, PROC_REF(initialize_systems)), 1)

	// Remove bodypart overlays to prevent covering the SCP icon

/mob/living/scp/scp2343/proc/initialize_systems()
	benevolence_system = new /datum/scp2343_benevolence_system(src)
	research_system = new /datum/scp2343_research_system(src)

/mob/living/scp/scp2343/Destroy()
	QDEL_NULL(benevolence_system)
	QDEL_NULL(research_system)
	return ..()

/mob/living/scp/scp2343/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	benevolence_system?.process_benevolence()
	research_system?.process_research()

/mob/living/scp/scp2343/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, range = 7)
	. = ..()
	if(.)
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD && H != src)
				hook_scp_interaction(H, "SCP-2343", INTERACTION_TYPE_COMMUNICATION)

/mob/living/scp/scp2343/proc/on_benevolent_act(mob/living/carbon/human/beneficiary)
	if(!beneficiary)
		return
	hook_scp_care(beneficiary, "SCP-2343", "benevolence")

/mob/living/scp/scp2343/examine(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>This being seems to have reality-bending powers.</span>")
