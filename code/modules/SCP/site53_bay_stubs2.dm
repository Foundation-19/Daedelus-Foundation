// Site53 Bay stubs batch 2 - ONLY types with functional logic
// Name-only stubs removed; BYOND creates parent-type instances from map data

/obj/machinery/button/blast_door
	name = "blast door button"
	skin = "doorctrl"
	device_type = /obj/item/assembly/control

/obj/machinery/camera/network
	name = "security camera"
	network = list("ss13")

/obj/machinery/camera/network/lcz
	name = "LCZ camera"
	network = list("lcz")

/obj/machinery/camera/network/hcz
	name = "HCZ camera"
	network = list("hcz")

/obj/machinery/camera/network/entrance
	name = "entrance camera"
	network = list("entrance")

/obj/machinery/camera/network/reswing
	name = "research wing camera"
	network = list("research")

/obj/machinery/camera/network/scp106
	name = "SCP-106 camera"
	network = list("scp106")

/obj/machinery/camera/network/scp049
	name = "SCP-049 camera"
	network = list("scp049")

/obj/machinery/camera/network/scp173
	name = "SCP-173 camera"
	network = list("scp173")

/obj/machinery/camera/network/scp513
	name = "SCP-513 camera"
	network = list("scp513")

/obj/machinery/camera/network/scp035
	name = "SCP-035 camera"
	network = list("scp035")

/obj/machinery/camera/network/scp343
	name = "SCP-343 camera"
	network = list("scp343")

/obj/machinery/camera/network/scp012
	name = "SCP-012 camera"
	network = list("scp012")

/obj/item/card/id/dassignment
	name = "D-Class Assignment ID"
	desc = "A D-Class personnel identification card with specific work assignment access."
	icon_state = "card_orange"
	trim = /datum/id_trim/job/prisoner

/obj/item/card/id/dassignment/dkitchen
	name = "Kitchen D-Class ID"
	trim = /datum/id_trim/job/prisoner/cook

/obj/item/card/id/dassignment/dmining
	name = "Mining D-Class ID"
	trim = /datum/id_trim/job/prisoner/miner

/obj/item/card/id/dassignment/djanitorial
	name = "Janitorial D-Class ID"
	trim = /datum/id_trim/job/prisoner/janitor

/obj/item/card/id/dassignment/dbotany
	name = "Botany D-Class ID"
	trim = /datum/id_trim/job/prisoner/botanist

/obj/item/card/id/dassignment/dmedical
	name = "Medical D-Class ID"
	trim = /datum/id_trim/job/prisoner/medic

/obj/item/card/id/classd
	name = "D-Class ID"
	desc = "A standard D-Class personnel identification card."
	icon_state = "card_orange"
	trim = /datum/id_trim/job/prisoner

/obj/item/storage/mre
	name = "MRE"
	desc = "A Meal Ready to Eat. Foundation-issue field ration."
	icon_state = "mre"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/mre/PopulateContents()
	new /obj/item/food/breadslice/plain(src)
	new /obj/item/reagent_containers/food/drinks/waterbottle(src)

/obj/item/storage/mre/random
	name = "random MRE"
	desc = "A Meal Ready to Eat. Contents may vary."