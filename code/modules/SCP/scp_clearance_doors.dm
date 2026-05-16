// SCP Area Clearance Warning System
// Adds clearance denial messages and chime sounds to airlocks in SCP zones

/obj/machinery/door/airlock/scp
	var/zone_name = "UNKNOWN"
	var/clearance_message = "Insufficient clearance for this zone."

/obj/machinery/door/airlock/scp/lcz
	zone_name = "Light Containment Zone"
	clearance_message = "ACCESS DENIED: LCZ clearance required. Report to your supervisor for access authorization."

/obj/machinery/door/airlock/scp/hcz
	zone_name = "Heavy Containment Zone"
	clearance_message = "ACCESS DENIED: HCZ Level 3+ clearance required. Unauthorized entry to Keter containment is grounds for immediate termination."

/obj/machinery/door/airlock/scp/ez
	zone_name = "Entrance Zone"
	clearance_message = "ACCESS DENIED: EZ clearance required. All visitors must be escorted by Foundation personnel."

/obj/machinery/door/airlock/scp/dclass
	zone_name = "D-Class Block"
	clearance_message = "ACCESS DENIED: D-Class personnel must remain in designated areas. Unauthorized departure is grounds for immediate termination."

/obj/machinery/door/airlock/scp/do_animate(animation)
	. = ..()
	if(animation == "deny")
		playsound(src, 'sound/machines/deniedbeep.ogg', 50, FALSE, 3)
		var/mob/user = usr
		if(user && ishuman(user))
			to_chat(user, span_warning("[clearance_message]"))
