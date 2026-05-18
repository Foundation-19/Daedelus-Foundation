// Site53 Bay stubs batch 3 - ONLY types with functional logic
// Name-only stubs removed; BYOND creates parent-type instances from map data

// ================================================================
// TURF STUBS - needed because Bay map references these paths
// ================================================================

/turf/flooring
	name = "flooring"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/flooring/linoleum
	name = "linoleum floor"
	icon_state = "wood"

/turf/flooring/misc
	name = "miscellaneous floor"
	icon_state = "dark"

/turf/flooring/tiles
	name = "tiled floor"
	icon_state = "floor"

/turf/flooring/wood
	name = "wooden floor"
	icon_state = "wood"

/turf/floors
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/jungle
	name = "jungle floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass"

/turf/unsimulated
	name = "unsimulated floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/unsimulated/beach
	name = "beach"

/turf/unsimulated/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/unsimulated/beach/coastline
	name = "coastline"
	icon_state = "sand"

/turf/unsimulated/beach/water
	name = "water"
	icon_state = "water"

/turf/closed/mineral/animated
	name = "animated mineral wall"

/turf/closed/wall/fakeglass
	name = "reinforced wall"
	icon_state = "rglass"

/turf/closed/wall/lobby_background
	name = "lobby wall"

/turf/closed/wall/scp106
	name = "SCP-106 containment wall"

/turf/open/floor/asteroid
	name = "asteroid floor"
	icon_state = "asteroid"

/turf/open/floor/engine
	name = "engine floor"

/turf/open/floor/engine/airmix
	name = "airmix floor"

/turf/open/floor/engine/carbon_dioxide
	name = "carbon dioxide floor"

/turf/open/floor/engine/hydrogen
	name = "hydrogen floor"

/turf/open/floor/engine/nitrogen
	name = "nitrogen floor"

/turf/open/floor/engine/oxygen
	name = "oxygen floor"

/turf/open/floor/iron/airless/ceiling
	name = "ceiling"

/turf/open/floor/iron/cult
	name = "cult floor"

/turf/open/floor/iron/grass
	name = "grass floor"

/turf/open/floor/iron/kafel_full
	name = "tiled floor"

/turf/open/floor/iron/plating
	name = "plating"
	icon_state = "plating"

/turf/open/floor/iron/plating_animated
	name = "animated plating"

/turf/open/floor/iron/reinforced
	name = "reinforced floor"
	icon_state = "reinforced"

/turf/open/floor/iron/reinforced_animated
	name = "animated reinforced floor"

/turf/open/floor/iron/reinforced/road
	name = "road"

/turf/open/floor/iron/scp106
	name = "SCP-106 floor"

/turf/open/floor/iron/scp1102
	name = "SCP-1102 floor"

/turf/open/floor/iron/shuttle/white
	name = "white shuttle floor"

/turf/open/floor/iron/sky_impassable
	name = "sky boundary"

/turf/open/floor/iron/techfloor
	name = "techfloor"

/turf/open/floor/iron/techfloor_grid
	name = "techfloor grid"

/turf/open/floor/shuttle
	name = "shuttle floor"

/mob/living/carbon/slime
	name = "slime"

// ================================================================
// AREA STUBS - areas need proper definitions for power/atmos
// ================================================================

/area/beach
	name = "Beach"
	icon_state = "beach"

/area/centcom/chaos
	name = "Chaos Insurgency Base"
	icon_state = "centcom"

/area/centcom/goc
	name = "GOC Base"
	icon_state = "centcom"

/area/chapel
	name = "Chapel"
	icon_state = "chapel"

/area/pocketdimension
	name = "Pocket Dimension"
	icon_state = "space"

/area/quartermaster/hangar
	name = "Hangar"
	icon_state = "hangar"

/area/supply/dock
	name = "Supply Dock"
	icon_state = "supply"

/area/vacant
	name = "Vacant Area"
	icon_state = "vacant"

/area/vacant/prototype
	name = "Vacant Prototype"
	icon_state = "vacant"

/area/vacant/prototype/control
	name = "Prototype Control"
	icon_state = "vacant"

/area/vacant/prototype/engine
	name = "Prototype Engine"
	icon_state = "vacant"

/area/site53/lhcz/scp1102entrance
	name = "SCP-1102 Entrance"
	icon_state = "SCP"

/area/site53/tram
	name = "Tram"
	icon_state = "hallA"

/area/site53/tram/ci
	name = "CI Transport"
	icon_state = "hallA"

/area/site53/tram/goc1
	name = "GOC Transport 1"
	icon_state = "hallA"

/area/site53/tram/goc2
	name = "GOC Transport 2"
	icon_state = "hallA"

/area/site53/tram/maintrain
	name = "Main Train"
	icon_state = "hallA"

/area/site53/tram/maintrain/Tunnel
	name = "Train Tunnel"
	icon_state = "hallA"

/area/site53/tram/mtf
	name = "MTF Transport"
	icon_state = "hallA"

// ================================================================
// MACHINERY - functional implementations only
// ================================================================

/obj/machinery/acting
	name = "acting machine"
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen"
	density = TRUE
	anchored = TRUE

/obj/machinery/acting/changer
	name = "identity changer"
	desc = "A machine that can alter one's appearance."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/airlock_controller
	name = "airlock controller"
	desc = "A control panel for managing airlock cycling."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.5

/obj/machinery/airlock_controller/airlock_controller
	name = "airlock controller"

/obj/machinery/alarm
	name = "air alarm"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.1

/obj/machinery/artifact
	name = "artifact"
	desc = "A strange object of unknown origin."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "artifact"
	density = TRUE

/obj/machinery/artifact_analyser
	name = "artifact analyser"
	desc = "A machine for analysing alien artifacts."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "datamass"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/artifact_harvester
	name = "artifact harvester"
	desc = "A machine for harvesting energy from artifacts."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "datamass"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/contraband_detector
	name = "contraband detector"
	desc = "Scans for illegal items."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "portgen"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.5

/obj/machinery/field_generator
	name = "field generator"
	desc = "Generates a containment field."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "shieldgen"
	density = TRUE
	anchored = TRUE
	use_power = ACTIVE_POWER_USE
	active_power_usage = 20000

/obj/machinery/floodlight
	name = "floodlight"
	desc = "A powerful area light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floodlight1"
	density = TRUE
	anchored = TRUE
	use_power = ACTIVE_POWER_USE
	active_power_usage = 100

/obj/machinery/hologram/holopad
	name = "holopad"
	desc = "A holographic communication pad."
	icon = 'icons/obj/computer.dmi'
	icon_state = "holopad0"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/hologram/holopad/longrange
	name = "long-range holopad"
	desc = "A long-range holographic communication pad."
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2

/obj/machinery/mech_recharger
	name = "mech recharger"
	desc = "A charging station for exosuits."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "recharge"
	density = TRUE
	anchored = TRUE
	use_power = ACTIVE_POWER_USE
	active_power_usage = 25000

/obj/machinery/nuke_cylinder_dispenser
	name = "warhead dispenser"
	desc = "Dispenses nuclear warhead cylinders."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/organ_printer
	name = "organ printer"
	desc = "A machine for synthesizing organic organs."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/papershredder
	name = "paper shredder"
	desc = "A machine for destroying sensitive documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "shredder"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.5

/obj/machinery/papershredder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper))
		qdel(I)
		to_chat(user, span_notice("You shred the paper."))
	else
		return ..()

/obj/machinery/radiocarbon_spectrometer
	name = "radiocarbon spectrometer"
	desc = "Analyses the age and composition of materials."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "spectrometer"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/reagent_temperature
	name = "reagent heater"
	desc = "Heats or cools reagent containers."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "reagent_heater"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/robotics_fabricator
	name = "robotics fabricator"
	desc = "Fabricates robotic parts and prosthetics."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "fab-idle"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/shieldwallgen
	name = "shield wall generator"
	desc = "Generates an energy shield wall."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "shieldgen"
	density = TRUE
	anchored = TRUE
	use_power = ACTIVE_POWER_USE
	active_power_usage = 20000

/obj/machinery/suit_cycler
	name = "suit cycler"
	desc = "A machine for changing and decontaminating suits."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/suit_cycler/engineering
	name = "engineering suit cycler"

// ================================================================
// STRUCTURES - functional implementations only
// ================================================================

/obj/structure/femur_breaker
	name = "femur breaker"
	desc = "A device used to break a subject's femur for SCP-106 recontainment."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "femur_breaker"
	density = TRUE
	anchored = TRUE

/obj/structure/femur_breaker/Initialize(mapload)
	. = ..()
	var/obj/machinery/scp_femur_breaker/real_breaker = new(loc)
	real_breaker.setDir(dir)
	return INITIALIZE_HINT_QDEL

/obj/structure/stasis_cage
	name = "stasis cage"
	desc = "A cage for safely transporting anomalous entities."
	icon = 'icons/obj/structures.dmi'
	icon_state = "stasis_cage"
	density = TRUE
	anchored = TRUE
	var/mob/living/caged_entity = null
	var/cage_open = FALSE

/obj/structure/stasis_cage/attack_hand(mob/user)
	if(cage_open && caged_entity)
		caged_entity.forceMove(get_turf(src))
		caged_entity = null
		cage_open = FALSE
		icon_state = "stasis_cage"
		to_chat(user, span_notice("You release the entity from the stasis cage."))
	else if(!cage_open)
		cage_open = TRUE
		icon_state = "stasis_cage_open"
		to_chat(user, span_notice("You open the stasis cage."))

/obj/structure/synthesized_instrument/synthesizer/piano
	name = "piano"
	desc = "A grand piano."
	icon = 'icons/obj/musician.dmi'
	icon_state = "piano"
	density = TRUE
	anchored = TRUE

/obj/structure/morgue
	name = "morgue"
	desc = "A refrigerated storage unit for bodies."
	icon = 'icons/obj/structures.dmi'
	icon_state = "morgue1"
	density = TRUE
	anchored = TRUE

/obj/structure/AIcore
	name = "AI core"
	desc = "The physical housing for a facility AI unit."
	icon = 'icons/obj/computer.dmi'
	icon_state = "ai-fixer"
	density = TRUE
	anchored = TRUE
	max_integrity = 200

/obj/structure/virology
	name = "virology equipment"
	icon = 'icons/obj/machines/research.dmi'

/obj/structure/virology/analyser
	name = "pathogen analyser"
	icon_state = "analyser"
	density = TRUE
	anchored = TRUE

/obj/structure/virology/centrifuge
	name = "centrifuge"
	icon_state = "centrifuge"
	density = TRUE
	anchored = TRUE

/obj/structure/virology/centrifuge_on
	name = "centrifuge"
	icon_state = "centrifuge_on"
	density = TRUE
	anchored = TRUE

/obj/structure/virology/cryogenics
	name = "cryogenics freezer"
	icon_state = "cryo"
	density = TRUE
	anchored = TRUE

/obj/structure/virology/cryogenics_occupied
	name = "cryogenics freezer"
	icon_state = "cryo_occupied"
	density = TRUE
	anchored = TRUE

/obj/structure/virology/incubator_on
	name = "pathogen incubator"
	icon_state = "incubator_on"
	density = TRUE
	anchored = TRUE

/obj/structure/virology/iso
	name = "isolation container"
	icon_state = "iso"
	density = TRUE
	anchored = TRUE

/obj/structure/virology/iso_on
	name = "isolation container"
	icon_state = "iso_on"
	density = TRUE
	anchored = TRUE

// ================================================================
// EFFECTS - shuttle landmarks for shuttle system
// ================================================================

/obj/effect/shuttle_landmark
	name = "shuttle landmark"
	anchored = TRUE

/obj/effect/step_trigger/teleporter
	name = "teleporter trigger"

/obj/effect/step_trigger/teleporter/random
	name = "random teleporter trigger"

/obj/effect/step_trigger/thrower
	name = "thrower trigger"

/obj/effect/step_trigger/death
	name = "death trigger"

/obj/effect/landmark/corpse
	name = "corpse landmark"

/obj/effect/landmark/corpse/chaos
	name = "Chaos Insurgency corpse"

/obj/effect/landmark/corpse/chaos/pilot
	name = "Chaos Insurgency pilot corpse"

/obj/effect/landmark/corpse/goc
	name = "GOC corpse"

/obj/effect/landmark/corpse/classd
	name = "D-Class corpse"

/obj/effect/landmark/corpse/classdescaped
	name = "Escaped D-Class corpse"

/obj/effect/landmark/map_data
	name = "Map Data"

/obj/effect/turf_decal/borderfloor
	icon = 'icons/turf/decals-ported.dmi'
	icon_state = "borderfloor"

// ================================================================
// RANDOM SPAWNERS - decorative, no logic needed beyond existence
// ================================================================

/obj/random
	name = "random spawner"

// ================================================================
// MISC - bare path fixes
// ================================================================

/obj/item/cigarbutt
	name = "cigar butt"
	desc = "A discarded cigar butt."

/obj/item/lollibutt
	name = "lollipop stick"
	desc = "A discarded lollipop stick."

/obj/effect/decal/spitwad
	name = "spitwad"

/obj/effect/scp5295
	name = "SCP-5295"
	desc = "An anomalous entity."

/obj/doors
	name = "door"

/obj/doors/rapid_pdoor
	name = "rapid pneumatic door"

/obj/doors/vault
	name = "vault door"

/obj/doors/vault/door
	name = "vault door"
	density = TRUE

/obj/scp106_random
	name = "SCP-106 anomaly"

/obj/scp263
	name = "SCP-263"
	desc = "A cognitohazardous television set."
	density = TRUE

/obj/gun
	name = "gun"
// ================================================================
// TURF STUBS - Bay-style paths referenced by site53 map
// These inherit from /tg/ base types so they function properly
// ================================================================

/turf/open/floor/asteroid
	name = "asteroid floor"
	icon_state = "asteroid"

/turf/open/floor/engine/airmix
	name = "airmix floor"
	icon_state = "engine"

/turf/open/floor/engine/carbon_dioxide
	name = "carbon dioxide floor"
	icon_state = "engine_co2"

/turf/open/floor/engine/hydrogen
	name = "hydrogen floor"
	icon_state = "engine_h2"

/turf/open/floor/engine/nitrogen
	name = "nitrogen floor"
	icon_state = "engine_n2"

/turf/open/floor/engine/oxygen
	name = "oxygen floor"
	icon_state = "engine_o2"

/turf/open/floor/iron/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/open/floor/iron/beach/coastline
	name = "coastline"
	icon_state = "sand"

/turf/open/floor/iron/beach/water
	name = "water"
	icon_state = "water"

/turf/open/floor/iron/dark/smooth
	name = "dark smooth floor"
	icon_state = "darksmooth"

/turf/open/floor/iron/white/smooth
	name = "white smooth floor"
	icon_state = "whitesmooth"

/turf/open/floor/iron/techfloor
	name = "techfloor"
	icon_state = "techfloor"

/turf/open/floor/iron/techfloor_grid
	name = "techfloor grid"
	icon_state = "techfloor_grid"

/turf/open/floor/iron/reinforced/road
	name = "road"
	icon_state = "reinforced"

/turf/open/floor/shuttle
	name = "shuttle floor"
	icon_state = "shuttle"