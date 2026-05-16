#define ESCAPE_ROUTE_INACTIVE 0
#define ESCAPE_ROUTE_ACTIVE 1
#define ESCAPE_ROUTE_BLOCKED 2
#define ESCAPE_ROUTE_COMPROMISED 3

/datum/dclass_escape_route
	var/route_id
	var/name
	var/desc
	var/difficulty = 3
	var/status = ESCAPE_ROUTE_INACTIVE
	var/obj/structure/dclass_escape_point/entry_point
	var/list/route_segments = list()
	var/current_segment = 0
	var/discovery_difficulty = 40
	var/completion_xp = 300
	var/trust_change = -40
	var/suspicion_change = 50

/datum/dclass_escape_route/proc/can_attempt(mob/living/carbon/human/H)
	if(status == ESCAPE_ROUTE_BLOCKED)
		return FALSE
	if(!SSdclass || !SSdclass.manager)
		return FALSE
	var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
	if(!player)
		return FALSE
	return TRUE

/datum/dclass_escape_route/proc/get_success_chance(mob/living/carbon/human/H)
	var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
	if(!player)
		return 0

	var/chance = 25
	chance += (player.skills["escape_planning"] || 0) * 5
	chance -= (player.trust_level || 0) * 3
	chance -= (difficulty - 3) * 10
	chance -= ((SSdclass.manager.current_security_level || 1) - 1) * 8
	if(player.has_contraband("lockpick"))
		chance += 15
	if(player.has_contraband("improvised_tool"))
		chance += 10

	return clamp(chance, 5, 85)

/datum/dclass_escape_route/proc/attempt_escape(mob/living/carbon/human/H)
	if(!can_attempt(H))
		return FALSE

	var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
	var/chance = get_success_chance(H)

	player.escape_attempts++
	hook_scp_interaction(H, "D-Class Escape", 9)

	if(prob(chance))
		player.successful_escapes++
		player.gain_experience(completion_xp, "escape")
		player.adjust_trust(trust_change, "Escaped")
		player.add_incident("escape_success", "Successful escape via [name]", "critical")
		complete_escape(H)
		return TRUE
	else
		player.increase_suspicion(suspicion_change)
		player.add_incident("escape_attempt", "Failed escape at [name]", "major")
		if(SSdclass.manager)
			SSdclass.manager.set_security_level(min(5, (SSdclass.manager.current_security_level || 1) + 1))
		fail_escape(H)
		return FALSE

/datum/dclass_escape_route/proc/complete_escape(mob/living/carbon/human/H)
	to_chat(H, "<span class='greenannounce big'>You escape through [name]!</span>")

	hook_scp_interaction(H, "D-Class Escape", 9)
	log_game("D-Class [H.name] escaped via [src.name]")

	var/list/escape_turfs = list()
	for(var/area/A in get_sorted_areas())
		if(istype(A, /area/scp/ez) || istype(A, /area/scp/surface))
			for(var/turf/open/T in A)
				if(!T.density)
					escape_turfs += T
					if(length(escape_turfs) > 50)
						break
		if(length(escape_turfs) > 50)
			break

	if(length(escape_turfs))
		var/turf/target = pick(escape_turfs)
		H.forceMove(target)

	if(SSpersistent_progression)
		SSpersistent_progression.award_experience(H.ckey, "scp_survival", 50, "D-Class Escape")

/datum/dclass_escape_route/proc/fail_escape(mob/living/carbon/human/H)
	to_chat(H, "<span class='danger'>You fail to get through [name]!</span>")
	H.Paralyze(30)
	H.adjustBruteLoss(5)

/obj/structure/dclass_escape_point
	name = "loose vent grate"
	desc = "A vent grate that seems looser than the others..."
	icon = 'icons/obj/structures.dmi'
	icon_state = "vent"
	anchored = TRUE
	density = FALSE
	var/route_id = "vent"
	var/difficulty = 3
	var/cooldown = 0
	var/escape_route_type = /datum/dclass_escape_route
	var/datum/dclass_escape_route/route
	var/discovered = FALSE
	var/discovery_chance = 40

/obj/structure/dclass_escape_point/Initialize()
	. = ..()
	route = new escape_route_type()
	route.route_id = route_id
	route.name = name
	route.difficulty = difficulty
	route.entry_point = src

/obj/structure/dclass_escape_point/Destroy()
	if(route)
		QDEL_NULL(route)
	return ..()

/obj/structure/dclass_escape_point/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(!SSdclass || !SSdclass.manager)
		return

	var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
	if(!player)
		return

	if(!discovered)
		var/detect_chance = discovery_chance + (player.skills["escape_planning"] || 0) * 3
		if(prob(detect_chance))
			discovered = TRUE
			to_chat(H, "<span class='notice'>You notice something unusual about this [name]... It could be a way out.</span>")
		else
			to_chat(H, "<span class='notice'>Just a regular [name].</span>")
	else
		var/chance = route ? route.get_success_chance(H) : 0
		to_chat(H, "<span class='notice'>Escape chance: [chance]% (Difficulty: [difficulty])</span>")

/obj/structure/dclass_escape_point/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(!discovered)
		var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[H.ckey]
		if(!player)
			to_chat(H, "<span class='notice'>Just a regular [name].</span>")
			return
		var/detect_chance = discovery_chance + (player.skills["escape_planning"] || 0) * 3
		if(prob(detect_chance))
			discovered = TRUE
			to_chat(H, "<span class='notice'>You notice something unusual about this [name]... It could be a way out!</span>")
		else
			to_chat(H, "<span class='notice'>Just a regular [name].</span>")
		return

	if(world.time < cooldown)
		to_chat(H, "<span class='warning'>Already attempted recently. Wait a moment.</span>")
		return

	if(!route || !route.can_attempt(H))
		to_chat(H, "<span class='warning'>This route is blocked.</span>")
		return

	var/chance = route.get_success_chance(H)
	var/confirm = alert(H, "Attempt escape via [name]?\nSuccess chance: [chance]%\nDifficulty: [difficulty]", "Escape Attempt", "Try", "Cancel")
	if(confirm != "Try")
		return

	cooldown = world.time + 6000
	route.attempt_escape(H)

/obj/structure/dclass_escape_point/vent
	name = "loose vent grate"
	desc = "A vent grate that seems looser than the others..."
	icon_state = "vent"
	route_id = "vent"
	difficulty = 3
	discovery_chance = 40
	escape_route_type = /datum/dclass_escape_route/vent

/obj/structure/dclass_escape_point/wall
	name = "cracked wall"
	desc = "A wall with cracks that might be widened..."
	icon_state = "wall_damaged"
	route_id = "wall_crack"
	difficulty = 4
	discovery_chance = 30
	escape_route_type = /datum/dclass_escape_route/wall

/obj/structure/dclass_escape_point/maintenance
	name = "maintenance hatch"
	desc = "A maintenance hatch with a questionable lock..."
	icon_state = "maintenance"
	route_id = "maintenance"
	difficulty = 4
	discovery_chance = 35
	escape_route_type = /datum/dclass_escape_route/maintenance

/obj/structure/dclass_escape_point/drain
	name = "storm drain"
	desc = "A large drain that leads into darkness..."
	icon_state = "drain"
	route_id = "drain"
	difficulty = 5
	discovery_chance = 20
	escape_route_type = /datum/dclass_escape_route/drain

/obj/structure/dclass_escape_point/supply_conveyor
	name = "supply conveyor"
	desc = "A conveyor belt that carries supplies into the facility..."
	icon_state = "conveyor"
	route_id = "supply"
	difficulty = 5
	discovery_chance = 25
	escape_route_type = /datum/dclass_escape_route/supply

/datum/dclass_escape_route/vent
	name = "Ventilation Route"
	desc = "Navigate through the ventilation system."
	difficulty = 3
	discovery_difficulty = 40
	completion_xp = 250
	trust_change = -35
	suspicion_change = 40

/datum/dclass_escape_route/wall
	name = "Wall Breach"
	desc = "Squeeze through a crack in the containment wall."
	difficulty = 4
	discovery_difficulty = 30
	completion_xp = 350
	trust_change = -45
	suspicion_change = 55

/datum/dclass_escape_route/maintenance
	name = "Maintenance Tunnel"
	desc = "Navigate the maintenance access tunnels."
	difficulty = 4
	discovery_difficulty = 35
	completion_xp = 300
	trust_change = -40
	suspicion_change = 45

/datum/dclass_escape_route/drain
	name = "Storm Drain"
	desc = "Wade through the facility's drainage system."
	difficulty = 5
	discovery_difficulty = 20
	completion_xp = 400
	trust_change = -50
	suspicion_change = 60

/datum/dclass_escape_route/supply
	name = "Supply Conveyor"
	desc = "Ride the supply conveyor out of the facility."
	difficulty = 5
	discovery_difficulty = 25
	completion_xp = 400
	trust_change = -50
	suspicion_change = 55

/obj/structure/dclass_maintenance_tunnel
	name = "maintenance tunnel entrance"
	desc = "A dark tunnel leading into the facility's maintenance spaces."
	icon = 'icons/obj/structures.dmi'
	icon_state = "tunnel"
	anchored = TRUE
	density = TRUE
	var/obj/structure/dclass_maintenance_tunnel/connected
	var/tunnel_id

/obj/structure/dclass_maintenance_tunnel/Initialize()
	. = ..()
	if(tunnel_id)
		for(var/obj/structure/dclass_maintenance_tunnel/T as anything in INSTANCES_OF(/obj/structure/dclass_maintenance_tunnel))
			if(T != src && T.tunnel_id == tunnel_id)
				connected = T
				T.connected = src
				break

/obj/structure/dclass_maintenance_tunnel/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(!connected)
		to_chat(H, "<span class='notice'>The tunnel is collapsed. There's no way through.</span>")
		return

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	if(id_card && (ACCESS_SECURITY in id_card.access))
		to_chat(H, "<span class='notice'>You open the maintenance hatch.</span>")
		H.forceMove(get_turf(connected))
		return

	var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[H.ckey]
	if(!player)
		to_chat(H, "<span class='warning'>The hatch is locked tight.</span>")
		return

	var/has_access = player.has_contraband("lockpick") || player.has_contraband("improvised_tool")
	if(!has_access)
		var/break_chance = 15 + (player.skills["escape_planning"] || 0) * 3
		if(prob(break_chance))
			to_chat(H, "<span class='notice'>You manage to pry the hatch open!</span>")
		else
			to_chat(H, "<span class='warning'>The hatch won't budge.</span>")
			return

	to_chat(H, "<span class='notice'>You slip into the maintenance tunnel...</span>")
	H.forceMove(get_turf(connected))

	if(SSdclass?.manager)
		player.increase_suspicion(20)
		player.add_incident("unauthorized_access", "Entered maintenance tunnel", "minor")

/obj/structure/dclass_maintenance_tunnel/cargo
	name = "cargo bay tunnel"
	tunnel_id = "cargo_maint"

/obj/structure/dclass_maintenance_tunnel/engineering
	name = "engineering tunnel"
	tunnel_id = "eng_maint"

/obj/structure/dclass_maintenance_tunnel/medical
	name = "medical tunnel"
	tunnel_id = "med_maint"

/obj/structure/dclass_maintenance_tunnel/science
	name = "science tunnel"
	tunnel_id = "sci_maint"

/obj/structure/dclass_escape_point/disguise
	name = "staff exit checkpoint"
	desc = "A checkpoint where staff exit the facility. Maybe you could blend in..."
	icon_state = "checkpoint"
	route_id = "disguise"
	difficulty = 4
	discovery_chance = 25
	escape_route_type = /datum/dclass_escape_route/disguise

/obj/structure/dclass_escape_point/vehicle
	name = "loading dock"
	desc = "A loading dock where supply vehicles come and go. If you could stow away..."
	icon_state = "dock"
	route_id = "vehicle"
	difficulty = 5
	discovery_chance = 20
	escape_route_type = /datum/dclass_escape_route/vehicle

/obj/structure/dclass_escape_point/laundry
	name = "laundry chute"
	desc = "A large laundry chute leading to the surface level. A long, risky drop..."
	icon_state = "chute"
	route_id = "laundry"
	difficulty = 4
	discovery_chance = 30
	escape_route_type = /datum/dclass_escape_route/laundry

/obj/structure/dclass_escape_point/elevator_shaft
	name = "elevator shaft"
	desc = "An elevator shaft with maintenance ladders. Dangerous, but leads to the surface."
	icon_state = "shaft"
	route_id = "elevator"
	difficulty = 5
	discovery_chance = 15
	escape_route_type = /datum/dclass_escape_route/elevator

/datum/dclass_escape_route/disguise
	name = "Disguise Escape"
	desc = "Blend in with departing staff to walk out the front door."
	difficulty = 4
	discovery_difficulty = 25
	completion_xp = 400
	trust_change = -50
	suspicion_change = 55

/datum/dclass_escape_route/disguise/get_success_chance(mob/living/carbon/human/H)
	. = ..()
	var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
	if(player?.has_contraband("staff_uniform"))
		. += 20
	if(player?.has_contraband("fake_id"))
		. += 15
	if(player?.has_contraband("disguise_kit"))
		. += 10

/datum/dclass_escape_route/vehicle
	name = "Vehicle Stowaway"
	desc = "Hide in a departing supply vehicle."
	difficulty = 5
	discovery_difficulty = 20
	completion_xp = 450
	trust_change = -55
	suspicion_change = 60

/datum/dclass_escape_route/vehicle/get_success_chance(mob/living/carbon/human/H)
	. = ..()
	var/datum/dclass_player/player = SSdclass.manager.dclass_players[H.ckey]
	if(player?.has_contraband("lockpick"))
		. += 10
	if(player?.has_contraband("improvised_tool"))
		. += 5

/datum/dclass_escape_route/laundry
	name = "Laundry Chute"
	desc = "Slide down the laundry chute to the surface."
	difficulty = 4
	discovery_difficulty = 30
	completion_xp = 300
	trust_change = -40
	suspicion_change = 45

/datum/dclass_escape_route/laundry/complete_escape(mob/living/carbon/human/H)
	to_chat(H, "<span class='greenannounce big'>You slide down the laundry chute and land in a cart of linens on the surface!</span>")
	. = ..()

/datum/dclass_escape_route/laundry/fail_escape(mob/living/carbon/human/H)
	to_chat(H, "<span class='danger'>You get stuck halfway down the chute!</span>")
	H.Paralyze(40)
	H.adjustBruteLoss(10)

/datum/dclass_escape_route/elevator
	name = "Elevator Shaft Climb"
	desc = "Climb the maintenance ladder in the elevator shaft to reach the surface."
	difficulty = 5
	discovery_difficulty = 15
	completion_xp = 500
	trust_change = -60
	suspicion_change = 65

/datum/dclass_escape_route/elevator/complete_escape(mob/living/carbon/human/H)
	to_chat(H, "<span class='greenannounce big'>You climb the maintenance ladder and emerge on the surface!</span>")
	. = ..()

/datum/dclass_escape_route/elevator/fail_escape(mob/living/carbon/human/H)
	to_chat(H, "<span class='danger'>You lose your grip and fall down the shaft!</span>")
	H.Paralyze(50)
	H.adjustBruteLoss(25)
