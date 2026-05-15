/datum/element/food_cooked
	element_flags = ELEMENT_BESPOKE
	var/cook_type = ""

/datum/element/food_cooked/Attach(datum/target, _cook_type)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	cook_type = _cook_type
	var/obj/item/food/F = target
	if(istype(F))
		F.name = "[cook_type] [F.name]"
		ADD_TRAIT(F, TRAIT_FOOD_COOKED, "cooking_system")
		if(cook_type in list("grilled", "griddled"))
			F.AddComponent(/datum/component/sizzle)
		if(cook_type == "fried")
			F.foodtypes |= FRIED

/datum/element/food_cooked/Detach(datum/target)
	. = ..()
	REMOVE_TRAIT(target, TRAIT_FOOD_COOKED, "cooking_system")
