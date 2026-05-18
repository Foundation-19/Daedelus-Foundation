/obj/item/fuel_rod/gas/deuterium
	name = "fuel rod (deuterium)"
	desc = "A fuel rod pre-filled with deuterium gas for fusion reactions."
	rod_type = ROD_FUEL
	exposure_rate = 0.05

/obj/item/fuel_rod/gas/deuterium/Initialize(mapload)
	. = ..()
	air_contents.adjustGas(GAS_DEUTERIUM, FUEL_ROD_GAS_VOLUME)

/obj/item/fuel_rod/gas/tritium
	name = "fuel rod (tritium)"
	desc = "A fuel rod pre-filled with tritium gas for fusion reactions."
	rod_type = ROD_FUEL
	exposure_rate = 0.05

/obj/item/fuel_rod/gas/tritium/Initialize(mapload)
	. = ..()
	air_contents.adjustGas(GAS_TRITIUM, FUEL_ROD_GAS_VOLUME)

/obj/item/fuel_rod/gas/hydrogen
	name = "fuel rod (hydrogen)"
	desc = "A fuel rod pre-filled with hydrogen gas for fusion reactions."
	rod_type = ROD_FUEL
	exposure_rate = 0.05

/obj/item/fuel_rod/gas/hydrogen/Initialize(mapload)
	. = ..()
	air_contents.adjustGas(GAS_HYDROGEN, FUEL_ROD_GAS_VOLUME)

/obj/item/fuel_rod/gas/helium
	name = "fuel rod (helium)"
	desc = "A fuel rod pre-filled with helium gas. Useful as a fusion product or reactant."
	rod_type = ROD_MODERATOR
	exposure_rate = 0.02

/obj/item/fuel_rod/gas/helium/Initialize(mapload)
	. = ..()
	air_contents.adjustGas(GAS_HELIUM, FUEL_ROD_GAS_VOLUME)

/obj/item/fuel_rod/gas/boron
	name = "fuel rod (boron)"
	desc = "A fuel rod pre-filled with boron gas for high-temperature aneutronic fusion."
	rod_type = ROD_FUEL
	exposure_rate = 0.03

/obj/item/fuel_rod/gas/boron/Initialize(mapload)
	. = ..()
	air_contents.adjustGas(GAS_BORON, FUEL_ROD_GAS_VOLUME)

/obj/item/fuel_rod/gas/plasma
	name = "fuel rod (plasma)"
	desc = "A fuel rod pre-filled with plasma. Very high energy yield but extremely unstable."
	rod_type = ROD_FUEL
	exposure_rate = 0.08

/obj/item/fuel_rod/gas/plasma/Initialize(mapload)
	. = ..()
	air_contents.adjustGas(GAS_PLASMA, FUEL_ROD_GAS_VOLUME)

/obj/item/fuel_rod/gas/oxygen
	name = "fuel rod (oxygen)"
	desc = "A fuel rod pre-filled with oxygen. Can serve as a fusion fuel in exotic reactions."
	rod_type = ROD_MODERATOR
	exposure_rate = 0.02

/obj/item/fuel_rod/gas/oxygen/Initialize(mapload)
	. = ..()
	air_contents.adjustGas(GAS_OXYGEN, FUEL_ROD_GAS_VOLUME)

/obj/item/fuel_rod/control
	name = "control rod"
	desc = "A heavy rod made of neutron-absorbing material. Used to control reaction rates."
	icon_state = "generic"
	rod_type = ROD_CONTROL
	exposure_rate = 0

/obj/item/fuel_rod/moderator
	name = "moderator rod"
	desc = "A rod that moderates reaction speed, reducing instability."
	icon_state = "generic"
	rod_type = ROD_MODERATOR
	exposure_rate = 0
