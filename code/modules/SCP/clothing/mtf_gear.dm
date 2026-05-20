// SCP Foundation - MTF, GOC, CI Combat Equipment
// Upgrades from name-only stubs to functional gear with armor values

// ================================================================
// MTF UNIFORMS
// ================================================================

/obj/item/clothing/under/mtf
	name = "MTF tactical uniform"
	desc = "A black tactical uniform worn by Mobile Task Force operatives."
	icon_state = "syndicate"
	armor = list(MELEE = 20, BULLET = 15, LASER = 10, ENERGY = 5, BOMB = 5, BIO = 0, RAD = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/mtf/epsilon11
	name = "Epsilon-11 tactical uniform"
	desc = "A dark tactical uniform with red accents, worn by MTF Epsilon-11 'Nine-Tailed Fox' operatives."
	icon_state = "syndicate_commander"
	armor = list(MELEE = 25, BULLET = 20, LASER = 15, ENERGY = 10, BOMB = 10, BIO = 5, RAD = 5)
	siemens_coefficient = 0.8

// ================================================================
// GOC UNIFORMS
// ================================================================

/obj/item/clothing/under/rank/security/goc
	name = "GOC tactical uniform"
	desc = "A blue-grey tactical uniform worn by Global Occult Coalition operatives."
	icon_state = "tactifool"
	armor = list(MELEE = 20, BULLET = 15, LASER = 10, ENERGY = 5, BOMB = 5, BIO = 0, RAD = 0)
	siemens_coefficient = 0.9

// ================================================================
// UIU UNIFORMS
// ================================================================

/obj/item/clothing/under/rank/civilian/uiu
	name = "UIU agent suit"
	desc = "A federal-issue suit worn by Unusual Incidents Unit agents."
	icon_state = "black_suit"
	armor = list(MELEE = 10, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0)

// ================================================================
// MTF ARMOR
// ================================================================

/obj/item/clothing/suit/armor/mtftactical
	name = "MTF tactical armor"
	desc = "A set of tactical armor plates worn by Mobile Task Force operatives."
	icon_state = "armoralt"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list(MELEE = 40, BULLET = 35, LASER = 30, ENERGY = 20, BOMB = 15, BIO = 5, RAD = 5)
	siemens_coefficient = 0.6

/obj/item/clothing/suit/armor/mtftactical/epsilon11
	name = "Epsilon-11 heavy tactical armor"
	desc = "Heavy tactical armor with reinforced plating, worn by MTF Epsilon-11 'Nine-Tailed Fox'."
	icon_state = "heavyarmor"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|FEET
	armor = list(MELEE = 50, BULLET = 45, LASER = 35, ENERGY = 25, BOMB = 25, BIO = 10, RAD = 10)
	slowdown = 0.3

// ================================================================
// GOC ARMOR
// ================================================================

/obj/item/clothing/suit/armor/goc
	name = "GOC tactical armor"
	desc = "A set of lightweight tactical armor used by the Global Occult Coalition."
	icon_state = "armor"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list(MELEE = 35, BULLET = 40, LASER = 25, ENERGY = 15, BOMB = 15, BIO = 5, RAD = 5)
	siemens_coefficient = 0.6

// ================================================================
// MTF HELMETS
// ================================================================

/obj/item/clothing/head/helmet/mtftactical
	name = "MTF tactical helmet"
	desc = "A tactical helmet with built-in comms, worn by Mobile Task Force operatives."
	icon_state = "helmetalt"
	armor = list(MELEE = 40, BULLET = 35, LASER = 30, ENERGY = 15, BOMB = 10, BIO = 5, RAD = 5)
	body_parts_covered = HEAD

/obj/item/clothing/head/helmet/mtftactical/epsilon11
	name = "Epsilon-11 heavy tactical helmet"
	desc = "A heavy tactical helmet with reinforced faceplate, worn by MTF Epsilon-11."
	icon_state = "syndicate"
	armor = list(MELEE = 50, BULLET = 45, LASER = 35, ENERGY = 25, BOMB = 15, BIO = 10, RAD = 10)

// ================================================================
// MTF BERETS
// ================================================================

/obj/item/clothing/head/beret/mtf
	name = "MTF beret"
	desc = "A black beret with the MTF insignia."
	icon_state = "beret_black"

/obj/item/clothing/head/beret/mtf/epsilon11
	name = "Epsilon-11 beret"
	desc = "A dark red beret with the Epsilon-11 insignia."
	icon_state = "beret_red"

/obj/item/clothing/head/beret/scp/alpha
	name = "Alpha-1 beret"
	desc = "A crimson beret with the Alpha-1 'Red Right Hand' insignia."
	icon_state = "beret_centcom"

// ================================================================
// GAS MASKS
// ================================================================

/obj/item/clothing/mask/gas/mtf
	name = "MTF gas mask"
	desc = "A tactical gas mask worn by Mobile Task Force operatives."
	icon_state = "gas_mtf"
	visor_flags = BLOCK_GAS_SMOKE_EFFECT
	visor_flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	visor_vars_to_toggle = list(darkness_view = 2)

/obj/item/clothing/mask/gas/goc
	name = "GOC gas mask"
	desc = "A tactical gas mask used by the Global Occult Coalition."
	icon_state = "gas_goc"
	visor_flags = BLOCK_GAS_SMOKE_EFFECT
	visor_flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	visor_vars_to_toggle = list(darkness_view = 2)

// ================================================================
// GLOVES & SHOES
// ================================================================

/obj/item/clothing/gloves/tactical/alpha
	name = "Alpha-1 combat gloves"
	desc = "Form-fitting combat gloves with knuckle reinforcement."
	icon_state = "black"
	siemens_coefficient = 0.5

/obj/item/clothing/gloves/thick
	name = "thick gloves"
	desc = "A pair of thick gloves."

/obj/item/clothing/gloves/thick/swat
	name = "SWAT gloves"
	desc = "Heavy-duty tactical gloves."
	icon_state = "black"
	siemens_coefficient = 0.5

/obj/item/clothing/shoes/swat
	name = "SWAT boots"
	desc = "Heavy-duty tactical boots."
	icon_state = "swat"
	armor = list(MELEE = 25, BULLET = 15, LASER = 15, ENERGY = 10, BOMB = 10, BIO = 5, RAD = 5)

// ================================================================
// VESTS
// ================================================================

/obj/item/clothing/suit/storage/vest/nt/isd
	name = "ISD armored vest"
	desc = "An armored vest worn by the Internal Security Department."
	icon_state = "armoralt"
	body_parts_covered = CHEST|GROIN
	armor = list(MELEE = 45, BULLET = 35, LASER = 25, ENERGY = 15, BOMB = 10, BIO = 5, RAD = 5)

// ================================================================
// HUD GLASSES
// ================================================================

/obj/item/clothing/glasses/hud/scramble
	name = "SCRAMBLE Goggles"
	desc = "Specialized goggles that filter memetic hazards and anomalous visual cognitohazards from the wearer's vision. Standard issue for MTF Eta-10."
	icon_state = "scramble"
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

/obj/item/clothing/glasses/hud/scramble/proc/protects_against(scp_id)
	return TRUE

/obj/item/clothing/glasses/hud/scramble/experimental
	name = "Experimental SCRAMBLE Goggles"
	desc = "An advanced prototype of SCRAMBLE goggles with enhanced memetic filtering. Still prone to occasional visual glitches."
	icon_state = "scramble"
