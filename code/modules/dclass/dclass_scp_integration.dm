// SCP-D-Class Integration
// Connects D-Class test subjects to actual SCP objects during experiments
// Hooks into the existing hook_scp_interaction system via a separate call

/proc/hook_dclass_scp_interaction(mob/living/carbon/human/player, scp_id, interaction_type, list/data = null)
	if(!player || !player.ckey)
		return
	if(!SSdclass?.manager)
		return

	var/datum/dclass_player/dclass = SSdclass.manager.get_dclass_player(player.ckey)
	if(!dclass)
		return

	if(!(player.ckey in SSdclass_experiments?.active_test_subjects))
		return

	if(!SSdclass_experiments)
		return

	var/danger_level = SSdclass_experiments.active_test_subjects[player.ckey]["danger_level"] || 1

	var/outcome = "failure"
	switch(interaction_type)
		if(INTERACTION_TYPE_OBSERVATION)
			if(prob(60 + dclass.trust_level * 5))
				outcome = "success"
			else
				outcome = "partial_success"
		if(INTERACTION_TYPE_MEDICAL)
			if(prob(50 + dclass.trust_level * 5))
				outcome = "success"
			else if(prob(30))
				outcome = "partial_success"
		if(INTERACTION_TYPE_COMBAT)
			if(player.health > 50)
				outcome = "success"
			else if(player.health > 0)
				outcome = "partial_success"
			else
				outcome = "failure"
		if(INTERACTION_TYPE_CONTAINMENT)
			if(prob(65 + dclass.trust_level * 5))
				outcome = "success"
			else
				outcome = "failure"
		if(INTERACTION_TYPE_EXPERIMENT)
			if(prob(55 + dclass.trust_level * 5))
				outcome = "success"
			else if(prob(25))
				outcome = "partial_success"
		if(INTERACTION_TYPE_CARE)
			outcome = "success"
		if(INTERACTION_TYPE_EXPLORATION)
			if(prob(50))
				outcome = "success"
			else if(prob(30))
				outcome = "partial_success"
		if(INTERACTION_TYPE_SURVIVAL)
			if(player.stat != DEAD)
				outcome = "success"
			else
				outcome = "failure"
		if(INTERACTION_TYPE_COMMUNICATION)
			outcome = "success"
		if(INTERACTION_TYPE_RESEARCH)
			if(prob(55 + dclass.trust_level * 5))
				outcome = "success"
			else
				outcome = "partial_success"
		else
			outcome = "partial_success"

	if(SSdclass_experiments)
		SSdclass_experiments.complete_subject_participation(player, outcome, scp_id, danger_level)
