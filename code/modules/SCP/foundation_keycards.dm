/obj/item/card/id/foundation
	name = "foundation keycard"
	desc = "A standardized Foundation keycard used to authenticate personnel and determine access across the facility."
	icon_state = "card_grey"
	worn_icon_state = "card_grey"

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
	new /obj/item/card/id/foundation(src)
