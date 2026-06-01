/datum/scp
	///SCP name
	var/name
	///SCP Designation (i.e 173 or 096)
	var/designation
	///SCP Class (SAFE, EUCLID, ETC.)
	var/classification

	///Meta Flags for the SCP
	var/metaFlags

	///Datum Parent
	var/atom/parent

	//Playable SCP vars

	///How many players do we need on for this SCP to be playable
	var/min_playercount = 0
	///How much time has to have passed for this SCP to become playable
	var/min_time = 0

	//Components

	///Memetic Component
	var/datum/component/memetic/meme_comp

	//Memetic Comp Vars

	///Proc called as an effect from memetic scps
	var/memetic_proc
	///Flags that determine how a memetic scp is detected
	var/memeticFlags
	///Sounds that are considered memetic
	var/list/memetic_sounds

	/// If this SCP can still be examined as normal
	var/regular_examine = FALSE

/datum/scp/New(atom/creation, vName, vClass = SCP_SAFE, vDesg, vMetaFlags)
	GLOB.SCP_list += creation

	name = vName //names are now usually captalized improper descriptors to fit the theme of SCP since people dont just know the scp desg off the bat. As such we need to improper it. Mental mechanics for foundation personnel recognition are implemented in the SCP recognition system.dation workers to see desg instead of name.
	designation = vDesg
	classification = vClass
	metaFlags = vMetaFlags

	parent = creation

	if(LAZYLEN(name))
		parent.name = name
		if(ismob(parent))
			var/mob/parentMob = parent
			parentMob.set_real_name(name)

	// if(classification == SCP_SAFE)
	// 	set_faction(parent, MOB_FACTION_NEUTRAL)
	// else
	// 	set_faction(parent, FACTION_SCPS)

	if(ismob(parent))
		var/mob/pMob = parent
		if(LAZYLEN(name))
			pMob.fully_replace_character_name(name)
		//pMob.status_flags += NO_ANTAG --- We need to rimplement no antag///

	if(metaFlags & SCP_DISABLED)
		message_admins(span_notice("Disabled SCP-[designation] spawned and subsequently deleted! Do not spawn disabled SCPs!"))
		qdel(parent)
		return

	// Auto-register with persistence system
	register_with_persistence()

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(OnExamine))

/datum/scp/Destroy()
	. = ..()
	if(parent)
		GLOB.SCP_list -= parent
		parent.SCP = null
	if(meme_comp)
		meme_comp = null
	if(advanced_components)
		qdel(advanced_components)
		advanced_components = null
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	parent = null

///Run only after adding appropriate flags for components.
/datum/scp/proc/compInit() //if more comps are added for SCPs, they can be put here
	if(metaFlags & SCP_DISABLED)
		return
	if(metaFlags & SCP_MEMETIC)
		meme_comp = parent.AddComponent(/datum/component/memetic, memeticFlags, memetic_proc, memetic_sounds)

///For when an SCP object is examined, we send the examinee a message about the SCP's designation if they should know what SCP it is.
/datum/scp/proc/OnExamine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/datum/job/job = SSjob.GetJob(H.job)
	if(job)
		examine_list += span_obviousnotice("You know this is SCP-[designation]!")
		// Award small observation research for examining
		if(SSscp_research && SSscp_research.manager)
			award_research_points("[designation]", "observation", 5, H.ckey)

///Returns the canonical SCP id string like "SCP-173"
/datum/scp/proc/get_scp_id()
	return "SCP-[designation]"

///Registers this SCP's parent atom with the persistence manager
/datum/scp/proc/register_with_persistence()
	if(!parent)
		return
	if(SSscp_persistence && SSscp_persistence.manager)
		var/id = get_scp_id()
		SSscp_persistence?.manager?.scp_instances[id] = new /datum/scp_instance(id, parent)
		if(istype(parent, /mob/living/scp))
			var/mob/living/scp/S = parent
			S.persistence_id = id

///Helper to record an interaction in persistence
/datum/scp/proc/log_interaction(mob/user, interaction_type)
	if(!(SSscp_persistence && SSscp_persistence.manager))
		return
	var/id = get_scp_id()
	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[id]
	if(instance)
		instance.add_interaction_record(user, interaction_type)
	if(uses_advanced_components)
		trigger_component_event(COMPONENT_EVENT_INTERACT, list("user" = user, "type" = interaction_type))

///Helper to record a breach event
/datum/scp/proc/log_breach()
	if(!(SSscp_persistence && SSscp_persistence.manager))
		return
	var/id = get_scp_id()
	var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[id]
	if(instance)
		instance.add_breach_record()

///Simple hook for SCPs to award research points
/datum/scp/proc/award_research(mob/user, research_type, points)
	if(user && user.ckey)
		award_research_points("[designation]", research_type, points, user.ckey)

///Check the minimum player requirement
/datum/scp/proc/has_minimum_players()
	return length(GLOB.clients) >= min_playercount
