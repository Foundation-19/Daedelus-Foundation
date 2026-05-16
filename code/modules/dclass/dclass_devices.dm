// D-Class Management Console
// In-game device for researchers managing D-Class

/obj/machinery/computer/dclass_management
	name = "D-Class Management Console"
	desc = "Console for managing D-Class."
	icon = 'icons/obj/computer.dmi'
	icon_state = "research"
	anchored = TRUE

/obj/machinery/computer/dclass_management/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/list/authorized = list("Research Director", "Scientist", "Senior Researcher", "Containment Specialist")
	if(!(H.job in authorized))
		to_chat(H, span_warning("Access denied."))
		return

	var/info = "<h3>D-CLASS MANAGEMENT</h3>"
	info += "<b>Total D-Class:</b> [length(SSdclass?.manager?.dclass_players || list())]<br>"
	info += "<b>Active Tests:</b> [length(SSdclass_experiments?.active_test_subjects || list())]<br>"

	if(SSdclass?.manager)
		info += "<b>Security:</b> [SSdclass.manager.current_security_level]/4<br>"
		info += "<b>Time:</b> [SSdclass.manager.current_time_slot]<br>"

	to_chat(H, span_notice(info))

	for(var/ckey in SSdclass?.manager?.dclass_players)
		var/datum/dclass_player/player = SSdclass.manager.dclass_players[ckey]
		if(!player) continue
		info = "[player.dclass_number || ckey] - Trust: [player.get_trust_name(player.trust_level)], Tests: [player.tests_completed]"
		to_chat(H, span_notice(info))
