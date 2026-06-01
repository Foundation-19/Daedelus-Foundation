// D-Class Areas and Landmarks
// Basic area definitions for D-Class gameplay

/area/scp/dclass
	name = "D-Class Block"
	icon_state = "dclass"

/area/scp/dclass/cell_block
	name = "D-Class Cell Block"
	icon_state = "dclass_cells"

/area/scp/dclass/testing_chamber
	name = "D-Class Testing Chamber"
	icon_state = "dclass_test"

/area/scp/dclass/recreation
	name = "D-Class Recreation Yard"
	icon_state = "dclass_rec"

/area/scp/dclass/cafeteria
	name = "D-Class Cafeteria"
	icon_state = "dclass_cafe"

// SCP Containment Zones
// Light Containment Zone (LCZ) - Safe/Euclid SCPs, D-Class testing
/area/scp/lcz
	name = "Light Containment Zone"
	icon_state = "lcz"

/area/scp/lcz/corridor
	name = "LCZ Corridor"
	icon_state = "lcz_hall"

/area/scp/lcz/safe_containment
	name = "Safe Containment Chamber"
	icon_state = "lcz_safe"

/area/scp/lcz/euclid_containment
	name = "Euclid Containment Chamber"
	icon_state = "lcz_euclid"

/area/scp/lcz/testing_lab
	name = "LCZ Testing Laboratory"
	icon_state = "lcz_test"

/area/scp/lcz/observation
	name = "LCZ Observation Room"
	icon_state = "lcz_obs"

/area/scp/lcz/checkpoint
	name = "LCZ Security Checkpoint"
	icon_state = "lcz_check"

/area/scp/lcz/medical_bay
	name = "LCZ Medical Bay"
	icon_state = "lcz_med"

/area/scp/lcz/storage
	name = "LCZ Storage"
	icon_state = "lcz_store"

// Heavy Containment Zone (HCZ) - Keter SCPs, high-security
/area/scp/hcz
	name = "Heavy Containment Zone"
	icon_state = "hcz"

/area/scp/hcz/corridor
	name = "HCZ Corridor"
	icon_state = "hcz_hall"

/area/scp/hcz/keter_containment
	name = "Keter Containment Chamber"
	icon_state = "hcz_keter"

/area/scp/hcz/euclid_containment
	name = "HCZ Euclid Containment Chamber"
	icon_state = "hcz_euclid"

/area/scp/hcz/airlock
	name = "HCZ Airlock"
	icon_state = "hcz_airlock"

/area/scp/hcz/checkpoint
	name = "HCZ Security Checkpoint"
	icon_state = "hcz_check"

/area/scp/hcz/observation
	name = "HCZ Observation Room"
	icon_state = "hcz_obs"

/area/scp/hcz/server_room
	name = "HCZ Server Room"
	icon_state = "hcz_server"

/area/scp/hcz/generator
	name = "HCZ Generator Room"
	icon_state = "hcz_gen"

/area/scp/hcz/armory
	name = "HCZ Armory"
	icon_state = "hcz_arm"

// Entrance Zone (EZ) - Administrative, public areas
/area/scp/ez
	name = "Entrance Zone"
	icon_state = "ez"

/area/scp/ez/corridor
	name = "EZ Corridor"
	icon_state = "ez_hall"

/area/scp/ez/lobby
	name = "EZ Lobby"
	icon_state = "ez_lobby"

/area/scp/ez/offices
	name = "EZ Offices"
	icon_state = "ez_office"

/area/scp/ez/briefing
	name = "EZ Briefing Room"
	icon_state = "ez_brief"

/area/scp/ez/checkpoint
	name = "EZ Security Checkpoint"
	icon_state = "ez_check"

/area/scp/ez/locker_room
	name = "EZ Locker Room"
	icon_state = "ez_locker"

/area/scp/ez/break_room
	name = "EZ Break Room"
	icon_state = "ez_break"

// Surface Zone
/area/scp/surface
	name = "Surface Zone"
	icon_state = "surface"

/area/scp/surface/parking
	name = "Surface Parking"
	icon_state = "surface_park"

/area/scp/surface/helipad
	name = "Surface Helipad"
	icon_state = "surface_heli"

/area/scp/surface/gate_a
	name = "Gate A"
	icon_state = "gate_a"

/area/scp/surface/gate_b
	name = "Gate B"
	icon_state = "gate_b"

// Helper proc: determine containment zone for an area
/proc/get_containment_zone(area/A)
	if(!A)
		return null
	if(istype(A, /area/scp/lcz) || istype(A, /area/scp/dclass))
		return "lcz"
	if(istype(A, /area/scp/hcz))
		return "hcz"
	if(istype(A, /area/scp/ez))
		return "ez"
	if(istype(A, /area/scp/surface))
		return "surface"
	return null

// Helper proc: check if an SCP is outside its containment zone
/proc/is_scp_outside_containment(obj/scp_obj)
	if(!scp_obj)
		return FALSE
	var/area/A = get_area(scp_obj)
	var/zone = get_containment_zone(A)
	if(!zone)
		return TRUE
	var/datum/scp/SCP = scp_obj.SCP
	if(!SCP)
		return FALSE
	var/obj_class = SCP.classification
	if(obj_class == SCP_KETER && zone != "hcz")
		return TRUE
	if(obj_class == SCP_EUCLID && zone == "surface")
		return TRUE
	if(obj_class == SCP_SAFE && (zone == "surface" || zone == "ez"))
		return TRUE
	return FALSE

/obj/effect/landmark/dclass_escape_route
	name = "Escape Route Point"
	var/route_difficulty = 3

/obj/machinery/dclass_announcement
	name = "D-Class Announcement Panel"
	desc = "Announcements for D-Class."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "research"
	anchored = TRUE

/obj/machinery/dclass_announcement/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/list/authorized = list("Scientist", "Research Director", "Senior Researcher", "Research Assistant")
	if(!(H.job in authorized))
		to_chat(H, span_warning("Only research staff can announce."))
		return

	var/message = input(user, "Enter announcement:", "D-Class Announcement") as text|null
	if(!message)
		return

	for(var/mob/living/carbon/human/dclass in GLOB.player_list)
		if(dclass.ckey && SSdclass?.manager?.get_dclass_player(dclass.ckey))
			to_chat(dclass, span_boldnotice("ANNOUNCEMENT: [message]"))
