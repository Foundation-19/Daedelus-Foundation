/datum/controller/subsystem/ticker/proc/setup_foundation_identity()
	GLOB.command_name = "SCP Foundation O5 Council"
	change_command_name(GLOB.command_name)
	if(!CONFIG_GET(string/stationname))
		set_station_name("Site-53")
