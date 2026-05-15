/obj/item/card/id/advanced/centcom/o5_override
	name = "O5 Override Card"
	desc = "A special identification card with universal facility access. O5 Council only."
	registered_name = "O5 OVERRIDE"
	registered_age = 0
	assigned_icon_state = "assigned_centcom"

/obj/item/card/id/advanced/centcom/o5_override/Initialize()
	. = ..()
	access = list(
		1, 2, 3, 4, 5, 6,
		7, 8, 9, 10, 11, 12,
		13, 14, 15, 16, 17, 18,
		19, 20, 21, 22, 23, 24,
		25, 26, 27, 28, 29, 30,
		31, 32, 33, 34, 35, 36,
		37, 38,
		96,
		100, 101, 102, 103,
		50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
		71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
	)
	trim = /datum/id_trim/centcom

/obj/item/card/id/advanced/centcom/o5_override/examine(mob/user)
	. = ..()
	. += span_danger("This card has UNLIMITED facility access. Use with extreme discretion.")

/obj/item/storage/box/o5_override_kit
	name = "O5 Override Kit"
	desc = "A secure box containing an O5 Override Card."

/obj/item/storage/box/o5_override_kit/PopulateContents()
	new /obj/item/card/id/advanced/centcom/o5_override(src)

/obj/item/card/id/advanced/centcom/admin_override
	name = "Administrator Override Card"
	desc = "A high-clearance override card for the Facility Administrator."
	registered_name = "ADMIN OVERRIDE"
	registered_age = 0

/obj/item/card/id/advanced/centcom/admin_override/Initialize()
	. = ..()
	access = list(
		1, 2, 3, 4, 5, 6,
		7, 8, 9, 10, 11, 12,
		13, 14, 15, 16, 17, 18,
		19, 20, 21, 22, 23, 24,
		25, 26, 27, 28, 29, 30,
		31, 32, 33, 34, 35, 36,
		37, 38,
		96,
		100, 101, 102, 103,
		50, 51, 52, 53, 54, 61
	)

/obj/item/card/id/advanced/centcom/mtf_commander
	name = "MTF Commander Card"
	desc = "An identification card for Mobile Task Force commanders."
	registered_name = "MTF COMMANDER"
	registered_age = 0

/obj/item/card/id/advanced/centcom/mtf_commander/Initialize()
	. = ..()
	access = list(
		1, 2, 3, 4, 5, 6,
		7, 8, 9,
		19, 20, 21,
		25, 26, 27,
		96,
		100, 101, 102, 103,
		50, 51, 52, 53, 54, 60, 61
	)
