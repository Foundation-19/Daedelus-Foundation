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

/obj/machinery/door/poddoor
	var/begins_closed = TRUE

/obj/machinery/atmospherics/unary/vent_pump
	var/external_pressure_bound = ONE_ATMOSPHERE

/obj/machinery/atmospherics/omni/mixer
	var/tag_south_con

/obj/machinery/shieldwallgen
	var/active = FALSE

/obj/machinery/power/breakerbox
	var/RCon_tag

/obj/machinery/power/smes
	var/RCon_tag

/obj/structure/closet/secure
	var/icon_closed

/obj/effect/decal/cleanable/blood/writing
	var/message
