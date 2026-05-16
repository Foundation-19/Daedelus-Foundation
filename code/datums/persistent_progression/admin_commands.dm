/client/proc/award_experience()
    set name = "Award Experience"
    set category = "Admin.Persistent"

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
    set category = "Admin.Persistent"

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
    set category = "Admin.Persistent"

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
    set category = "Admin.Persistent"

    if(!check_rights(R_ADMIN))
        return

    var/mob/living/carbon/human/target = input("Select target player", "View Progress") as null|anything in GLOB.player_list
    if(!target || !target.mind)
        to_chat(src, span_warning("Invalid target selected."))
        return

    var/datum/persistent_player_data/data = SSpersistent_progression.get_player_data(target.ckey)
    if(!data)
        to_chat(src, span_warning("No persistent data found for this player."))
        return

    var/datum/persistent_class/class = SSpersistent_progression.get_class(data.current_class_id)
    var/datum/persistent_faction/faction = SSpersistent_progression.get_faction(data.current_faction_id)

    var/dat = "<h2>Persistent Progress for [target.name] ([target.ckey])</h2>"
    dat += "<h3>Current Status</h3>"
    dat += "<b>Class:</b> [class ? class.class_name : "Unknown"]<br>"
    dat += "<b>Faction:</b> [faction ? faction.faction_name : "Unknown"]<br>"
    dat += "<b>Rank:</b> [data.current_rank_name] (Level [data.current_rank])<br>"
    dat += "<b>Total Experience:</b> [data.total_experience]<br>"
    dat += "<b>Rounds Played:</b> [data.rounds_played]<br>"
    dat += "<b>Last Login:</b> [time2text(data.last_login, "YYYY-MM-DD hh:mm:ss")]<br>"

    if(class)
        var/progress = data.get_progress_to_next_rank()
        var/exp_needed = data.get_experience_needed_for_next_rank()
        dat += "<b>Progress to Next Rank:</b> [progress]%<br>"
        dat += "<b>Experience Needed:</b> [exp_needed]<br>"

    dat += "<h3>Unlocked Items</h3>"
    if(data.unlocked_items.len > 0)
        for(var/item in data.unlocked_items)
            dat += "- [item]<br>"
    else
        dat += "No items unlocked<br>"

    dat += "<h3>Unlocked Titles</h3>"
    if(data.unlocked_titles.len > 0)
        for(var/title in data.unlocked_titles)
            dat += "- [title]<br>"
    else
        dat += "No titles unlocked<br>"

    dat += "<h3>Achievements</h3>"
    if(data.achievements.len > 0)
        for(var/achievement in data.achievements)
            dat += "- [achievement]<br>"
    else
        dat += "No achievements unlocked<br>"

    dat += "<h3>Recent Experience Sources</h3>"
    var/count = 0
    for(var/list/source_data in data.experience_sources)
        if(count >= 10) // Show last 10
            break
        dat += "- [source_data["reason"]]: [source_data["amount"]] exp ([time2text(source_data["timestamp"], "hh:mm:ss")])<br>"
        count++

    var/datum/browser/popup = new(usr, "player_progress_[target.ckey]", "Player Progress", 600, 800)
    popup.set_content(dat)
    popup.open()


