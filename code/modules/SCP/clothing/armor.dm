// SCP Foundation Armor - Complete for Daedalus Dock compatibility

// Standard Armor Vests
/obj/item/clothing/suit/armor/vest/scp/lightarmor
	name = "light armored vest"
	desc = "A light synthetic armor vest."
	icon_state = "guard-armor"
	w_class = 3
	body_parts_covered = 15
	cold_protection = 15
	armor = list(BLUNT = 25, PUNCTURE = 15, SLASH = 0, LASER = 20, ENERGY = 30, BOMB = 10, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor
	name = "foundation security vest"
	desc = "A heavy armored vest. Worn by facility security, it has some durathread plating in it to make it durable against melee, sadly not much else though."
	icon_state = "guard-armor"
	body_parts_covered = 3
	cold_protection = 3
	armor = list(BLUNT = 35, PUNCTURE = 25, SLASH = 0, LASER = 30, ENERGY = 15, BOMB = 10, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor/ruined
	name = "ruined foundation security vest"
	desc = "A heavy, wrecked armored vest. Worn by facility security, it has some durathread plating in it to make it durable against melee, which of itself has degraded due to age. Not to mention the two massive holes in the vest, whoever wore this definitely isn't alive anymore."
	icon_state = "forgotten-guard-armor"
	body_parts_covered = 3
	cold_protection = 3
	armor = list(BLUNT = 30, PUNCTURE = 5, SLASH = 0, LASER = 8, ENERGY = 5, BOMB = 5, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor/medic
	name = "foundation security medical vest"
	desc = "A light armored vest, with a medical pauldron. Worn by facility security in the Combat Medic division. This one's armor padding has been lessened to cope with faster response."
	icon_state = "combatmedic"
	body_parts_covered = 3
	cold_protection = 3
	armor = list(BLUNT = 40, PUNCTURE = 30, SLASH = 0, LASER = 35, ENERGY = 30, BOMB = 5, BIO = 30, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor/recontain
	name = "foundation security response vest"
	desc = "A heavy armored vest, with added kneepads. It has a Recontainment Unit insignia on the chest. Worn by facility security in the Riot Control Unit division. Universally defensive."
	icon_state = "reconguard"
	body_parts_covered = 7
	cold_protection = 7
	armor = list(BLUNT = 40, PUNCTURE = 35, SLASH = 0, LASER = 40, ENERGY = 15, BOMB = 10, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor/riot
	name = "foundation security riot vest"
	desc = "A heavy armored vest, with added arm armor, and kneepads for full body coverage. Worn by facility security in the Riot Control Unit division, it has some durathread plating in it to make it durable against melee, sadly not much else though. It looks extremely durable from impacts, but in return is fragile towards bullets."
	icon_state = "riotguard"
	body_parts_covered = 15
	cold_protection = 15
	armor = list(BLUNT = 50, PUNCTURE = 5, SLASH = 0, LASER = 15, ENERGY = 15, BOMB = 30, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor/cadet
	name = "foundation security trainee rig"
	desc = "A lightly armored rig. Worn by facility security in training, it's nimble plating, and defensive properties make it faster to maneuver in than a normal ol' vest."
	icon_state = "cadetarmor"
	body_parts_covered = 3
	cold_protection = 3
	armor = list(BLUNT = 40, PUNCTURE = 8, SLASH = 0, LASER = 20, ENERGY = 5, BOMB = 5, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/isd
	name = "Internal Security trenchcoat"
	desc = "A durable coat used by the Internal Security Department, there isn't much to note about it except for the golden SCP logo on the shoulder, and wrist designs."
	icon_state = "isd_trenchcoat"
	body_parts_covered = 3
	cold_protection = 3
	armor = list(BLUNT = 45, PUNCTURE = 35, SLASH = 0, LASER = 25, ENERGY = 15, BOMB = 10, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/lczcomm
	name = "heavy-plated foundation security armored vest"
	desc = "A heavy armored vest, with added arm armor, and kneepads for full body coverage. Worn by the facility's LCZ Lieutenant, it has some durathread plating in it to make it durable against melee, and slightly in some other damage types."
	icon_state = "heavy-guard-armor"
	body_parts_covered = 15
	cold_protection = 15
	armor = list(BLUNT = 40, PUNCTURE = 35, SLASH = 0, LASER = 25, ENERGY = 30, BOMB = 10, BIO = 5, FIRE = 0, ACID = 0)

// Chaos Insurgency Armor
/obj/item/clothing/suit/armor/vest/scp/medarmor/chaos
	name = "Chaos Insurgency armored vest"
	desc = "A heavy tan russian type ballistic vest, mainly protecting against bullets, and not much else. It's usually used by russian military forces, but is used by the Chaos Insurgency."
	icon_state = "ci_vest"
	body_parts_covered = 3
	cold_protection = 3
	armor = list(BLUNT = 20, PUNCTURE = 40, SLASH = 0, LASER = 10, ENERGY = 5, BOMB = 5, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor/chaos/pilot
	name = "Chaos Insurgency pilot vest"
	desc = "A light, agile-purposed vest with barely any plating, meant for pilots who need the maneuverability, but also need protection. It's usually used by russian military forces, but is used by the Chaos Insurgency."
	icon_state = "ci_pilot_vest"
	body_parts_covered = 3
	cold_protection = 3
	armor = list(BLUNT = 15, PUNCTURE = 15, SLASH = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

// MTF Specialized Armor
/obj/item/clothing/suit/armor/vest/scp/medarmor/eta
	name = "Eta-10 armored vest"
	desc = "A synthetic armor vest designed for MTF unit Eta-10."
	icon_state = "eta-armor"
	body_parts_covered = 63
	cold_protection = 63
	armor = list(BLUNT = 45, PUNCTURE = 45, SLASH = 0, LASER = 40, ENERGY = 35, BOMB = 10, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/vest/scp/medarmor/beta
	name = "Beta-7 armored suit"
	desc = "A synthetic armor vest designed for MTF unit Beta-7. Provides heavy protection against biologic and radioactive threats."
	icon_state = "beta-armor"
	body_parts_covered = 63
	cold_protection = 63
	permeability_coefficient = 0.5
	armor = list(BLUNT = 55, PUNCTURE = 50, SLASH = 0, LASER = 35, ENERGY = 15, BOMB = 10, BIO = 50, FIRE = 0, ACID = 0)

// Hazmat Suits
/obj/item/clothing/head/hcz_hazmat
	name = "combat hazmat helmet"
	icon_state = "hcz-hazard-helmet"
	desc = "A helmet that protects the head and face from biological contaminants, heavy acids, high temperatures, and bullets."
	permeability_coefficient = 0
	armor = list(BLUNT = 30, PUNCTURE = 35, SLASH = 0, LASER = 35, ENERGY = 30, BOMB = 30, BIO = 50, FIRE = 0, ACID = 0)
	body_parts_covered = 1
	siemens_coefficient = 0.5

/obj/item/clothing/suit/hcz_hazmat
	name = "combat hazmat suit"
	desc = "An armored suit that protects against biological contamination, heavy acids, and high temperatures."
	icon_state = "hcz-hazard"
	w_class = 4
	permeability_coefficient = 0
	body_parts_covered = 63
	armor = list(BLUNT = 30, PUNCTURE = 35, SLASH = 0, LASER = 35, ENERGY = 30, BOMB = 30, BIO = 50, FIRE = 0, ACID = 0)
	siemens_coefficient = 0.5
