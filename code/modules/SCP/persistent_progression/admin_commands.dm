/client/proc/award_experience()
	set name = "Award Experience"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Award Experience") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/amount = input("Enter experience amount", "Award Experience") as num
	if(amount <= 0)
		to_chat(src, span_warning("Experience amount must be positive."))
		return

	var/reason = input("Enter reason for award", "Award Experience") as text
	if(!reason)
		reason = "Admin Award"

	var/awarded = SSpersistent_progression.award_experience(target.ckey, "admin_award", amount, reason)

	if(awarded > 0)
		to_chat(src, span_notice("Successfully awarded [awarded] experience to [target.name] for: [reason]"))
		to_chat(target, span_notice("You received [awarded] experience for: [reason]"))
		log_admin("[key_name(usr)] awarded [amount] experience to [key_name(target)] for: [reason]")
		message_admins("[key_name(usr)] awarded [amount] experience to [key_name(target)] for: [reason]")
	else
		to_chat(src, span_warning("Failed to award experience."))

/client/proc/set_player_rank()
	set name = "Set Player Rank"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Set Rank") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(!data)
		to_chat(src, span_warning("No persistent data found for this player."))
		return

	var/list/available_classes = list()
	for(var/class_id in SSpersistent_progression.classes)
		var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)
		available_classes["[class.class_name] ([class_id])"] = class_id

	var/selected_class = input("Select class", "Set Rank") as null|anything in available_classes
	if(!selected_class)
		return

	var/class_id = available_classes[selected_class]
	var/datum/persistent_class/class = SSpersistent_progression.get_class(class_id)

	var/rank_level = input("Select rank level (0-[class.max_rank])", "Set Rank") as num
	if(rank_level < 0 || rank_level > class.max_rank)
		to_chat(src, span_warning("Invalid rank level."))
		return

	// Set the rank by giving enough experience
	var/required_exp = class.get_rank_requirement(rank_level)
	var/exp_needed = required_exp - data.total_experience

	if(exp_needed > 0)
		SSpersistent_progression.award_experience(target.ckey, "admin_award", exp_needed, "Admin Rank Set")

	to_chat(src, span_notice("Set [target.name]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]"))
	log_admin("[key_name(usr)] set [key_name(target)]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")
	message_admins("[key_name(usr)] set [key_name(target)]'s rank to [class.get_rank_name(rank_level)] in [class.class_name]")

/client/proc/reset_player_progress()
	set name = "Reset Player Progress"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "Reset Progress") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/confirm = alert("Are you sure you want to reset [target.name]'s persistent progress? This cannot be undone.", "Confirm Reset", "Yes", "No")
	if(confirm != "Yes")
		return

	var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
	if(data)
		data.initialize_default_data()
		SSpersistent_progression.save_player_data(target.ckey)

	to_chat(src, span_notice("Reset [target.name]'s persistent progress."))
	to_chat(target, span_warning("Your persistent progress has been reset by an administrator."))
	log_admin("[key_name(usr)] reset [key_name(target)]'s persistent progress")
	message_admins("[key_name(usr)] reset [key_name(target)]'s persistent progress")

/client/proc/view_player_progress()
	set name = "View Player Progress"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/carbon/human/target = input("Select target player", "View Progress") as null|anything in GLOB.player_list
	if(!target || !target.mind)
		to_chat(src, span_warning("Invalid target selected."))
		return

	var/datum/persistent_progression_player_view_ui/player_view = new(target.ckey)
	player_view.ui_interact(src)

// Master Persistence Panel - Now uses TGUI interface
// The TGUI version is defined in tgui_master_panel.dm
