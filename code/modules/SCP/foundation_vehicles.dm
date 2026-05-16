/obj/vehicle/ridden/foundation_transport
	name = "Foundation Transport Vehicle"
	desc = "A rugged Foundation-branded transport vehicle for surface operations."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "atv"
	max_integrity = 200
	armor = list("melee" = 50, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 40)
	var/vehicle_id = "foundation_1"
	key_type = /obj/item/key/foundation

/obj/item/key/foundation
	name = "Foundation vehicle key"
	desc = "A key for Foundation surface vehicles."
	icon_state = "key"

/obj/vehicle/ridden/foundation_transport/Initialize(mapload)
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list(0, 4)))
	D.vehicle_move_delay = 2

/obj/vehicle/ridden/foundation_transport/bike
	name = "Foundation Scout Bike"
	desc = "A lightweight motorcycle used for rapid surface patrol."
	icon_state = "bike"
	max_integrity = 150

/obj/vehicle/ridden/foundation_transport/bike/Initialize(mapload)
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list(0, 4)))
	D.vehicle_move_delay = 1
