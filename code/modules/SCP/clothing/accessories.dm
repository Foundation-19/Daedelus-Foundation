// SCP Foundation Accessories and Armor Plates - Adapted for Daedalus Dock

// Armor Plates
/obj/item/clothing/accessory/armorplate
	name = "armor plate"
	desc = "A basic armor plate that can be attached to armor carriers."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "vest_black"
	w_class = 2
	var/armor_bonus = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/accessory/armorplate/medium
	name = "medium armor plate"
	desc = "A medium armor plate providing balanced protection."
	armor_bonus = list(BLUNT = 15, PUNCTURE = 15, SLASH = 0, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 5, FIRE = 0, ACID = 0)

/obj/item/clothing/accessory/armorplate/tactical
	name = "tactical armor plate"
	desc = "A tactical armor plate designed for combat situations."
	armor_bonus = list(BLUNT = 20, PUNCTURE = 20, SLASH = 0, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/accessory/armorplate/tactical/mtf
	name = "MTF tactical armor plate"
	desc = "A specialized tactical armor plate designed for Mobile Task Force operations."
	armor_bonus = list(BLUNT = 25, PUNCTURE = 25, SLASH = 0, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 15, FIRE = 0, ACID = 0)

// Storage Pouches
/obj/item/clothing/accessory/storage/pouches
	name = "storage pouches"
	desc = "A set of pouches for carrying equipment."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "cargo"
	var/storage_slots = 3

/obj/item/clothing/accessory/storage/pouches/green
	name = "green storage pouches"
	desc = "A set of green pouches for carrying equipment."
	icon_state = "cargo"

// Armor Tags
/obj/item/clothing/accessory/armor/tag
	name = "armor tag"
	desc = "A tag that can be attached to armor."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "lawyerbadge"

/obj/item/clothing/accessory/armor/tag/scp
	name = "SCP Foundation tag"
	desc = "A tag bearing the SCP Foundation logo."
	icon_state = "lawyerbadge"

// Armor Guards
/obj/item/clothing/accessory/armguards
	name = "arm guards"
	desc = "Protective guards for the arms."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "vest_sheriff"
	var/armor_bonus = list(BLUNT = 10, PUNCTURE = 5, SLASH = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/accessory/legguards
	name = "leg guards"
	desc = "Protective guards for the legs."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "vest_sheriff"
	var/armor_bonus = list(BLUNT = 10, PUNCTURE = 5, SLASH = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
