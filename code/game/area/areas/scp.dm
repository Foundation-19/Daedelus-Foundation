/area/station/hallway/ez/hub
	name = "\improper EZ Hub"
	icon_state = "centralhall"

/area/station/service/ez/bar
	name = "\improper Bar"
	icon_state = "bar"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/ez/bar/backroom
	name = "\improper Bar Backroom"
	icon_state = "bar"

/area/station/service/ez/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/station/service/ez/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/service/ez/library
	name = "\improper Public Library"
	icon_state = "library"
	area_flags = parent_type::area_flags &~ VALID_TERRITORY
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/station/service/ez/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"
	area_flags = parent_type::area_flags &~ VALID_TERRITORY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/ez/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/station/commons/ez/lounge
	name = "\improper Lounge"
	icon_state = "lounge"

/area/station/commons/ez/cryo
	name = "\improper Cryogenics"
	icon_state = "cryo"

/area/station/maintenance/lcz/entrance
	name = "LCZ Entrance Maintenance"

/area/station/hallway/lcz/entrance
	name = "\improper LCZ Entrance Hallway"
	icon_state = "primaryhall"

/area/station/hallway/lcz
	name = "\improper LCZ Hallway"
	icon_state = "primaryhall"

/area/station/security/lcz
	name = "\improper LCZ Security Post"
	icon_state = "security"

/area/station/security/lcz/checkpoint
	name = "\improper LCZ Security Checkpoint"
	icon_state = "checkpoint"

/area/station/security/lcz/lieutenant
	name = "\improper LCZ Security Lieutenant's Office"
	icon_state = "warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/lcz/armory
	name = "\improper LCZ Armory"
	icon_state = "armory"

/area/station/ai_monitored/security/lcz_secure_armory
	name = "\improper LCZ Secure Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security
