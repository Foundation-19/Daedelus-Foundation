GLOBAL_LIST_EMPTY(fusion_reactions)

/datum/fusion_reaction
	var/p_react = ""
	var/s_react = ""
	var/minimum_energy_level = 1
	var/energy_consumption = 0
	var/energy_production = 0
	var/radiation = 0
	var/instability = 0
	var/list/products = list()
	var/minimum_reaction_temperature = 100
	var/priority = 100

/datum/fusion_reaction/proc/handle_reaction_special(obj/effect/reactor_em_field/holder)
	return FALSE

/proc/get_fusion_reaction(p_react, s_react)
	return GLOB.fusion_reactions[p_react]?[s_react]

// ============================================================
// PRIMARY FUSION REACTIONS
// Ordered by real-world ignition temperature (ascending)
// ============================================================

// Deuterium-Tritium: Easiest fusion reaction, lowest ignition temp
// Real: ~4.5 x 10^7 K -> game scale ~10,000
/datum/fusion_reaction/deuterium_tritium
	p_react = GAS_DEUTERIUM
	s_react = GAS_TRITIUM
	energy_consumption = 1
	energy_production = 5
	radiation = 2
	products = list(GAS_HELIUM = 1)
	instability = 0.5
	minimum_reaction_temperature = 10000
	priority = 10

// Deuterium-Helium-3: Aneutronic fusion, cleaner
// Real: ~5 x 10^8 K -> game scale ~50,000
/datum/fusion_reaction/deuterium_helium
	p_react = GAS_DEUTERIUM
	s_react = GAS_HELIUM
	energy_consumption = 2
	energy_production = 8
	radiation = 1
	products = list(GAS_HYDROGEN = 1)
	instability = 1
	minimum_reaction_temperature = 50000
	priority = 20

// Deuterium-Deuterium: Moderate difficulty, produces tritium
// Real: ~4 x 10^8 K -> game scale ~40,000
/datum/fusion_reaction/deuterium_deuterium
	p_react = GAS_DEUTERIUM
	s_react = GAS_DEUTERIUM
	energy_consumption = 1
	energy_production = 3
	radiation = 4
	products = list(GAS_TRITIUM = 1, GAS_HELIUM = 1)
	instability = 2
	minimum_reaction_temperature = 40000
	priority = 50

// Hydrogen-Hydrogen: Proton-proton chain, very difficult
// Real: ~1.5 x 10^7 K (stars) but extremely slow -> game scale ~15,000
/datum/fusion_reaction/hydrogen_hydrogen
	p_react = GAS_HYDROGEN
	s_react = GAS_HYDROGEN
	energy_consumption = 3
	energy_production = 10
	radiation = 3
	products = list(GAS_DEUTERIUM = 1)
	instability = 3
	minimum_reaction_temperature = 15000
	priority = 80

// Hydrogen-Deuterium: Intermediate step
/datum/fusion_reaction/hydrogen_deuterium
	p_react = GAS_HYDROGEN
	s_react = GAS_DEUTERIUM
	energy_consumption = 2
	energy_production = 4
	radiation = 2
	products = list(GAS_HELIUM = 1)
	instability = 1.5
	minimum_reaction_temperature = 20000
	priority = 30

// Hydrogen-Tritium: Another intermediate reaction
/datum/fusion_reaction/hydrogen_tritium
	p_react = GAS_HYDROGEN
	s_react = GAS_TRITIUM
	energy_consumption = 1
	energy_production = 4
	radiation = 3
	products = list(GAS_HELIUM = 1)
	instability = 1
	minimum_reaction_temperature = 12000
	priority = 15

// Boron-Hydrogen: p-B11 aneutronic fusion, very high temperature
// Real: ~3 x 10^9 K -> game scale ~100,000
/datum/fusion_reaction/boron_hydrogen
	p_react = GAS_BORON
	s_react = GAS_HYDROGEN
	energy_consumption = 5
	energy_production = 20
	radiation = 0.5
	products = list(GAS_HELIUM = 3)
	instability = 5
	minimum_reaction_temperature = 100000
	priority = 90

// Tritium-Helium: Breeding reaction
/datum/fusion_reaction/tritium_helium
	p_react = GAS_TRITIUM
	s_react = GAS_HELIUM
	energy_consumption = 2
	energy_production = 6
	radiation = 2
	products = list(GAS_HYDROGEN = 1)
	instability = 2
	minimum_reaction_temperature = 30000
	priority = 40

// Oxygen-Deuterium: Exotic reaction using oxygen as fusion fuel
/datum/fusion_reaction/oxygen_deuterium
	p_react = GAS_OXYGEN
	s_react = GAS_DEUTERIUM
	energy_consumption = 4
	energy_production = 6
	radiation = 5
	products = list(GAS_HELIUM = 1, GAS_TRITIUM = 1)
	instability = 4
	minimum_reaction_temperature = 60000
	priority = 60

// Plasma-Hydrogen: Phoron catalyzed fusion (very hot, very productive)
/datum/fusion_reaction/plasma_hydrogen
	p_react = GAS_PLASMA
	s_react = GAS_HYDROGEN
	energy_consumption = 6
	energy_production = 15
	radiation = 8
	products = list(GAS_DEUTERIUM = 1, GAS_TRITIUM = 1)
	instability = 6
	minimum_reaction_temperature = 80000
	priority = 70
