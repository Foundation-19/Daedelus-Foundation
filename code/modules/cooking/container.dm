/obj/item/reagent_containers/cooking_container
	name = "cooking container"
	desc = "A container for cooking."
	icon = 'icons/obj/kitchen.dmi'
	volume = 100
	reagent_flags = OPENCONTAINER
	var/appliancetype = NONE
	var/container_type = "container"
	var/max_items = 5

/obj/item/reagent_containers/cooking_container/Initialize()
	. = ..()

/obj/item/reagent_containers/cooking_container/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food))
		if(length(contents) >= max_items)
			to_chat(user, span_warning("[src] is full!"))
			return
		if(user.transferItemToLoc(I, src))
			to_chat(user, span_notice("You put [I] in [src]."))
			return
	return ..()

/obj/item/reagent_containers/cooking_container/attack_self(mob/user)
	if(length(contents))
		var/obj/item/I = contents[length(contents)]
		I.forceMove(user.drop_location())
		user.put_in_hands(I)
		to_chat(user, span_notice("You remove [I] from [src]."))
	else
		to_chat(user, span_warning("[src] is empty."))

/obj/item/reagent_containers/cooking_container/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Contains [length(contents)] item\s:")
		for(var/obj/item/I in contents)
			. += span_notice("  [I]")
	else
		. += span_notice("It is empty.")

/obj/item/reagent_containers/cooking_container/baking_sheet
	name = "baking sheet"
	desc = "A metal baking sheet for oven use."
	icon_state = "oven_tray"
	appliancetype = APPLIANCE_OVEN
	container_type = "sheet"
	max_items = 6

/obj/item/reagent_containers/cooking_container/pot
	name = "cooking pot"
	desc = "A large cooking pot."
	icon_state = "serving"
	volume = 200
	appliancetype = APPLIANCE_POT | APPLIANCE_SAUCEPAN
	container_type = "pot"
	max_items = 5

/obj/item/reagent_containers/cooking_container/skillet
	name = "cast iron skillet"
	desc = "A heavy cast iron skillet."
	icon_state = "spatula"
	volume = 80
	appliancetype = APPLIANCE_SKILLET
	container_type = "skillet"
	max_items = 3

/obj/item/reagent_containers/cooking_container/saucepan
	name = "saucepan"
	desc = "A saucepan for simmering sauces."
	icon_state = "oven_tray"
	volume = 100
	appliancetype = APPLIANCE_SAUCEPAN
	container_type = "saucepan"
	max_items = 3
