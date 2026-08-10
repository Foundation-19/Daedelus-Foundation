/area/station/hallway/ez/hub
	name = "EZ Hub"
	icon_state = "centralhall"

/area/station/service/ez/bar
	name = "EZ Bar"
	icon_state = "bar"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/service/ez/bar/backroom
	name = "EZ Bar Backroom"
	icon_state = "bar"

/area/station/service/ez/kitchen
	name = "EZ Kitchen"
	icon_state = "kitchen"

/area/station/service/ez/chapel
	name = "EZ Chapel"
	icon_state = "chapel"
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/service/ez/library
	name = "EZ Public Library"
	icon_state = "library"
	area_flags = parent_type::area_flags &~ VALID_TERRITORY
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR

/area/station/service/ez/janitor
	name = "EZ Custodial Closet"
	icon_state = "janitor"
	area_flags = parent_type::area_flags &~ VALID_TERRITORY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/service/ez/chapel/office
	name = "EZ Chapel Office"
	icon_state = "chapeloffice"

/area/station/commons/ez/lounge
	name = "EZ Lounge"
	icon_state = "lounge"

/area/station/commons/ez/cryo
	name = "EZ Cryogenics"
	icon_state = "cryo"

/area/station/commons/cdcz/cryo
	name = "CDCZ Staff Cryogenics"
	icon_state = "cryo"

/area/station/maintenance/ez
	name = "Lower EZ Maintenance"
	icon_state = "lowerezmaint"

/area/station/maintenance/lcz
	name = "LCZ Maintenance"
	icon_state = "lczmaint"

/area/station/engineering/lcz/emergency
	name = "LCZ Emergency Power Room"
	icon_state = "maint_electrical"

/area/station/maintenance/lcz/entrance
	name = "LCZ Entrance Maintenance"

/area/station/engineering/lcz/entrance/substation
	name = "LCZ Substation Control Room"
	icon_state = "maint_electrical"

/area/station/maintenance/cdcz
	name = "CDCZ South Maintenance"
	icon_state = "cdczmaint"

/area/station/maintenance/cdcz/east
	name = "CDCZ East Maintenance"

/area/station/maintenance/cdcz/upper
	name = "CDCZ Upper Maintenance"
	icon_state = "uppercdczmaint"

/area/station/maintenance/cdcz/mining
	name = "CDCZ Mining Maintenance"
	icon_state = "cdczminemaint"

/area/station/engineering/cdcz/substation
	name = "CDCZ Substation Control Room"
	icon_state = "maint_electrical"

/area/station/engineering/cdcz/storage
	name = "CDCZ Engineering Storage"
	icon_state = "engine_storage"

/area/station/engineering/cdcz/atmos
	name = "CDCZ Emergency Atmospherics"
	icon_state = "atmos"

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

/area/station/lcz/restroom
	name = "\improper LCZ Restroom"
	icon_state = "lcz_restroom"

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
	name = "\improper CDCZ Hallway"
	icon_state = "cdcz_hall"

/area/station/cdcz/hallway/entrance
	name = "\improper CDCZ Entrance Hallway"
	icon_state = "cdcz_enthall"

/area/station/cdcz/hallway/mining
	name = "\improper CDCZ Mining Hallway"
	icon_state = "cdcz_minehall"

/area/station/cdcz/custodial
	name = "\improper CDCZ Custodial Closet"
	icon_state = "cdcz_custodial"

/area/station/cdcz/showers
	name = "\improper CDCZ Showers"
	icon_state = "cdcz_showers"

/area/station/cdcz/gym
	name = "\improper CDCZ Gym"
	icon_state = "cdcz_gym"

/area/station/cdcz/art
	name = "\improper CDCZ Art Studio"
	icon_state = "cdcz_art"

/area/station/cdcz/basketball
	name = "\improper CDCZ Basketball Court"
	icon_state = "cdcz_basketball"

/area/station/cdcz/cafeteria
	name = "\improper CDCZ Cafeteria"
	icon_state = "cdcz_cafeteria"

/area/station/cdcz/cryo
	name = "CDCZ Cryogenics"
	icon_state = "cdcz_cryo"

/area/station/cdcz/laundry
	name = "CDCZ Laundry Room"
	icon_state = "cdcz_laundry"

/area/station/cdcz/kitchen
	name = "\improper CDCZ Kitchen"
	icon_state = "cdcz_kitchen"

/area/station/cdcz/hydroponics
	name = "\improper CDCZ Hydroponics"
	icon_state = "cdcz_hydro"

/area/station/cdcz/assembly
	name = "\improper CDCZ Assembly Hall"
	icon_state = "cdcz_assembly"

/area/station/cdcz/mining
	name = "\improper CDCZ Mining Foyer"
	icon_state = "cdcz_mining"

/area/station/cdcz/mining/processing
	name = "\improper CDCZ Mining Processing"
	icon_state = "cdcz_mineproduce"

/area/station/cdcz/mining/equipment
	name = "\improper CDCZ Mining Equipment Room"
	icon_state = "cdcz_minestorage"

/area/station/cdcz/luxury
	name = "\improper CDCZ Luxury Hallway"
	icon_state = "cdcz_luxhall"

/area/station/cdcz/luxury/commissary
	name = "\improper CDCZ Commissary"
	icon_state = "cdcz_commissary"

/area/station/cdcz/luxury/library
	name = "\improper CDCZ Library"
	icon_state = "cdcz_library"

/area/station/cdcz/luxury/lounge
	name = "\improper CDCZ Lounge"
	icon_state = "cdcz_lounge"

/area/station/security/cdcz/checkpoint
	name = "\improper CDCZ Security Checkpoint"
	icon_state = "checkpoint"

/area/station/security/cdcz/post
	name = "\improper CDCZ Security Post"
	icon_state = "checkpoint"

/area/station/security/cdcz/control
	name = "\improper CDCZ Control Room"
	icon_state = "security"

/area/station/security/cdcz/control/armory
	name = "\improper CDCZ Armory"
	icon_state = "armory"

/area/station/security/cdcz/mining_post
	name = "\improper CDCZ Mining Security Post"
	icon_state = "checkpoint"

/area/station/ai_monitored/security/cdcz_armory
	name = "\improper CDCZ Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security

/area/station/medical/cdcz/medical
	name = "\improper CDCZ Medical Lobby"
	icon_state = "cdcz_medical"

/area/station/medical/cdcz/medical/treatment
	name = "\improper CDCZ Medical Treatment Center"

/area/station/medical/cdcz/medical/reception
	name = "\improper CDCZ Medical Reception"

/area/station/medical/cdcz/medical/pharmacy
	name = "\improper CDCZ Medical Pharmacy"

/area/station/medical/cdcz/medical/storage
	name = "\improper CDCZ Medical Storage"

/area/station/medical/cdcz/medical/morgue
	name = "\improper CDCZ Medical Morgue"

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

/area/station/euclid_scp/scp_513
	name = "SCP-513 Containment"

/area/station/euclid_scp/scp_173
	name = "SCP-173 Containment"

/area/station/euclid_scp/scp_066
	name = "SCP-066 Containment"

/area/station/safe_scp/scp_914
	name = "SCP-914 Containment"

/area/station/safe_scp/scp_999
	name = "SCP-999 Containment"

/area/station/safe_scp/scp_216
	name = "SCP-216 Containment"

/area/station/safe_scp/scp_529
	name = "SCP-529 Containment"

/area/station/safe_scp/scp_294
	name = "SCP-294 Containment"

/area/station/safe_scp/scp_263
	name = "SCP-263 Containment"

/area/station/safe_scp/scp_storage
	name = "LCZ Anomalous Item Storage"

/area/station/security/lcz/scp_914
	name = "\improper SCP-914 Security Post"
	icon_state = "checkpoint"
