// Bay compatibility vars - dummy vars to prevent runtime errors
// when the DMM map preloader tries to set Bay-specific vars on /tg/ types
// These vars serve no functional purpose but prevent "Undefined variable" runtimes

/obj/structure/cable/green
	var/c_tag
	var/RCon_tag
	var/initial_gas
	var/health_resistances
	var/send_access
	var/magazine_type
	var/use_power
	var/aiControlDisabled
	var/caliber
	var/height

/obj/machinery/door/poddoor
	var/begins_closed = TRUE

/obj/machinery/atmospherics/unary/vent_pump
	var/external_pressure_bound = ONE_ATMOSPHERE
	var/external_pressure_bound_default

/obj/machinery/atmospherics/omni/mixer
	var/tag_south_con
	var/tag_east_con
	var/tag_west_con
	var/tag_north_con

/obj/machinery/shieldwallgen
	var/active = FALSE
	var/max_range

/obj/machinery/power/breakerbox
	var/RCon_tag

/obj/machinery/power/smes
	var/RCon_tag

/obj/structure/closet/secure
	var/icon_closed
	var/icon_locked

/obj/effect/decal/cleanable/blood/writing
	var/message

/turf/open/floor
	var/c_tag

/obj/effect/turf_decal
	var/id

/obj/effect/landmark/map_data
	var/height

/obj/machinery/door/airlock/multi_tile/glass/research
	var/secured_wires

/obj/machinery/airlock_controller
	var/tag_exterior_door
