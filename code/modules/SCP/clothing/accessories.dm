// SCP Foundation Accessories and Armor Plates - Adapted for Daedalus Dock

// Armor Plates
/obj/item/clothing/accessory/armorplate
	name = "armor plate"
	desc = "A basic armor plate that can be attached to armor carriers."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "vest_black"
	w_class = 2
	var/armor_bonus = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 5, bio = 0, rad = 0)

/obj/item/clothing/accessory/armorplate/medium
	name = "medium armor plate"
	desc = "A medium armor plate providing balanced protection."
	armor_bonus = list(melee = 15, bullet = 15, laser = 10, energy = 10, bomb = 10, bio = 5, rad = 5)

/obj/item/clothing/accessory/armorplate/tactical
	name = "tactical armor plate"
	desc = "A tactical armor plate designed for combat situations."
	armor_bonus = list(melee = 20, bullet = 20, laser = 15, energy = 15, bomb = 15, bio = 10, rad = 10)

/obj/item/clothing/accessory/armorplate/tactical/mtf
	name = "MTF tactical armor plate"
	desc = "A specialized tactical armor plate designed for Mobile Task Force operations."
	armor_bonus = list(melee = 25, bullet = 25, laser = 20, energy = 20, bomb = 20, bio = 15, rad = 15)

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
	var/armor_bonus = list(melee = 10, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/accessory/legguards
	name = "leg guards"
	desc = "Protective guards for the legs."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "vest_sheriff"
	var/armor_bonus = list(melee = 10, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0, rad = 0)
