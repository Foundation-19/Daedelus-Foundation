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
	name = "Cryogenics"
	icon_state = "cryo"

/area/station/maintenance/ez
	name = "Lower EZ Maintenance"
	icon_state = "lowerezmaint"

/area/station/maintenance/lcz
	name = "LCZ Maintenance"
	icon_state = "lczmaint"

/area/station/maintenance/lcz/entrance
	name = "LCZ Entrance Maintenance"
	icon_state = "lczentmaint"

/area/station/safe_scp
	name = "Safe SCP Containment"
	icon_state = "scp_safe"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/scp
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = "#1c550ecc"

/area/station/euclid_scp
	name = "Euclid SCP Containment"
	icon_state = "scp_euclid"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/scp
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = "#705b15cc"

/area/station/keter_scp
	name = "Keter SCP Containment"
	icon_state = "scp_keter"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/scp
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = "#611717cc"

/area/station/lcz
	name = "Light Containment Zone"
	icon_state = "lcz"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/lcz
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = "#cea04acc"

/area/station/cdcz
	name = "Class-D Containment Zone"
	icon_state = "cdcz"
	airlock_wires = /datum/wires/airlock/cdcz
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = "#db710dcc"

/area/station/lcz/hallway
	name = "\improper LCZ Hallway"
	icon_state = "lcz_hall"

/area/station/lcz/hallway/entrance
	name = "\improper LCZ Entrance Hallway"
	icon_state = "lcz_enthall"

/area/station/lcz/offices
	name = "\improper LCZ Offices"
	icon_state = "lcz_office"

/area/station/lcz/offices/secondary
	name = "\improper LCZ Secondary Offices"
	icon_state = "lcz_office"

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

/area/station/cdcz/hallway
	name = "\improper CDCZ Entrance Hallway"
	icon_state = "cdcz_enthall"

/area/station/security/cdcz/checkpoint
	name = "\improper CDCZ Security Checkpoint"
	icon_state = "checkpoint"

/area/station/engineering/lcz/tech_storage
	name = "\improper LCZ Technical Storage"
	icon_state = "lcz_techstorage"

/area/station/medical/lcz/med_post
	name = "\improper LCZ Medical Post"
	icon_state = "lcz_medpost"

/area/station/euclid_scp/scp_012
	name = "SCP-012 Containment"

/area/station/euclid_scp/scp_151
	name = "SCP-151 Containment"

/area/station/euclid_scp/scp_512
	name = "SCP-512 Containment"

/area/station/euclid_scp/scp_173
	name = "SCP-173 Containment"

/area/station/safe_scp/scp_914
	name = "SCP-914 Containment"

/area/station/safe_scp/scp_999
	name = "SCP-999 Containment"

/area/station/safe_scp/scp_216
	name = "SCP-216 Containment"

/area/station/safe_scp/scp_529
	name = "SCP-529 Containment"

/area/station/security/lcz/scp_914
	name = "\improper SCP-914 Security Post"
	icon_state = "checkpoint"
