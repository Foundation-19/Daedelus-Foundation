/obj/item/card/id/foundation
	name = "Foundation keycard"
	desc = "A standardized Foundation keycard used to authenticate personnel and determine access across the facility."
	icon_state = "card_grey"
	worn_icon_state = "card_retro"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/card/id/foundation/level_1
	name = "Foundation Level 1 Keycard"
	desc = "A Level 1 Foundation keycard. Grants basic clearance for janitorial, culinary, logistics, and assistant staff."
	icon_state = "card_grey"
	access = list(
		ACCESS_SCIENCE,
		ACCESS_SCIENCE_LVL1,
	)

/obj/item/card/id/foundation/level_2
	name = "Foundation Level 2 Keycard"
	desc = "A Level 2 Foundation keycard. Grants junior staff clearance for guards, researchers, and medical interns."
	icon_state = "card_grey"
	access = list(
		ACCESS_SCIENCE,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_MEDICAL,
		ACCESS_MEDICAL_LVL1,
		ACCESS_ENGINEERING,
		ACCESS_ENGINEERING_LVL1,
	)

/obj/item/card/id/foundation/level_3
	name = "Foundation Level 3 Keycard"
	desc = "A Level 3 Foundation keycard. Grants standard staff clearance for guards, researchers, medical doctors, and engineers."
	icon_state = "card_silver"
	worn_icon_state = "card_silver"
	access = list(
		ACCESS_SECURITY,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SCIENCE,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_MEDICAL,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_ENGINEERING,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_LOGISTICS,
		ACCESS_LOGISTICS_LVL1,
		ACCESS_LOGISTICS_LVL2,
		ACCESS_LOGISTICS_LVL3,
		ACCESS_ADMIN,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_SERVICE,
	)

/obj/item/card/id/foundation/level_4
	name = "Foundation Level 4 Keycard"
	desc = "A Level 4 Foundation keycard. Grants senior staff clearance for zone commanders, senior researchers, and the CMO."
	icon_state = "card_silver"
	worn_icon_state = "card_silver"
	access = list(
		ACCESS_SECURITY,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SECURITY_LVL4,
		ACCESS_SCIENCE,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_MEDICAL,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_LVL4,
		ACCESS_ENGINEERING,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ENGINEERING_LVL4,
		ACCESS_LOGISTICS,
		ACCESS_LOGISTICS_LVL1,
		ACCESS_LOGISTICS_LVL2,
		ACCESS_LOGISTICS_LVL3,
		ACCESS_LOGISTICS_LVL4,
		ACCESS_ADMIN,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ADMIN_LVL4,
		ACCESS_SERVICE,
	)

/obj/item/card/id/foundation/level_5
	name = "Foundation Level 5 Keycard"
	desc = "A Level 5 Foundation keycard. Grants director-level clearance for the site director, guard commander, and research director."
	icon_state = "card_gold"
	worn_icon_state = "card_gold"
	inhand_icon_state = "gold_id"
	access = list(
		ACCESS_SECURITY,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SECURITY_LVL4,
		ACCESS_SECURITY_LVL5,
		ACCESS_SCIENCE,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_SCIENCE_LVL5,
		ACCESS_MEDICAL,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_LVL4,
		ACCESS_MEDICAL_LVL5,
		ACCESS_ENGINEERING,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ENGINEERING_LVL4,
		ACCESS_ENGINEERING_LVL5,
		ACCESS_LOGISTICS,
		ACCESS_LOGISTICS_LVL1,
		ACCESS_LOGISTICS_LVL2,
		ACCESS_LOGISTICS_LVL3,
		ACCESS_LOGISTICS_LVL4,
		ACCESS_LOGISTICS_LVL5,
		ACCESS_ADMIN,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ADMIN_LVL4,
		ACCESS_ADMIN_LVL5,
		ACCESS_SERVICE,
		ACCESS_DCLASS,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_LUXURY,
		ACCESS_DCLASS_MEDICAL,
	)

/obj/item/card/id/foundation/mtf
	name = "MTF Operative Keycard"
	desc = "A specialized keycard issued to Mobile Task Force operatives. Grants full security and containment access."
	icon_state = "card_black"
	worn_icon_state = "card_black"
	inhand_icon_state = "silver_id"
	access = list(
		ACCESS_SECURITY,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SECURITY_LVL4,
		ACCESS_SECURITY_LVL5,
		ACCESS_SCIENCE,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_SCIENCE_LVL5,
		ACCESS_MEDICAL,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_LVL4,
		ACCESS_MEDICAL_LVL5,
		ACCESS_ENGINEERING,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ENGINEERING_LVL4,
		ACCESS_ENGINEERING_LVL5,
		ACCESS_LOGISTICS,
		ACCESS_LOGISTICS_LVL1,
		ACCESS_LOGISTICS_LVL2,
		ACCESS_LOGISTICS_LVL3,
		ACCESS_LOGISTICS_LVL4,
		ACCESS_LOGISTICS_LVL5,
		ACCESS_ADMIN,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ADMIN_LVL4,
		ACCESS_DCLASS,
		ACCESS_DCLASS_MINING,
		ACCESS_DCLASS_BOTANY,
		ACCESS_DCLASS_JANITORIAL,
		ACCESS_DCLASS_LUXURY,
		ACCESS_DCLASS_MEDICAL,
		ACCESS_SERVICE,
	)

/obj/item/card/id/foundation/dclass
	name = "D-Class Identification Card"
	desc = "A simple identification card. D-Class are not trusted with real access."
	icon_state = "card_prisoner"
	worn_icon_state = "card_prisoner"
	inhand_icon_state = "orange-id"
	access = list(
		ACCESS_DCLASS,
	)

/obj/item/storage/box/foundation_keycard_kit
	name = "Foundation keycard kit"
	desc = "A box containing a full set of Foundation keycards, Levels 1 through 5, for administrative and testing use."
	illustration = "id"

/obj/item/storage/box/foundation_keycard_kit/PopulateContents()
	new /obj/item/card/id/foundation/level_1(src)
	new /obj/item/card/id/foundation/level_2(src)
	new /obj/item/card/id/foundation/level_3(src)
	new /obj/item/card/id/foundation/level_4(src)
	new /obj/item/card/id/foundation/level_5(src)
