/datum/cooking_item
	var/obj/item/target
	var/cookwork = 0
	var/max_cookwork = 100
	var/overcook_mult = 1.5
	var/cook_type = ""
	var/started = FALSE
	var/obj/machinery/appliance/holder
	var/obj/item/reagent_containers/cooking_container/container

/datum/cooking_item/New(obj/item/T, obj/machinery/appliance/A, obj/item/reagent_containers/cooking_container/C)
	target = T
	holder = A
	container = C
	cook_type = A.cook_type
	var/list/avail_reagents = collect_available_reagents()
	var/datum/cooking_recipe/R = select_cooking_recipe(avail_reagents, list(target), A.appliance_flags)
	if(R)
		max_cookwork = R.time
	else
		max_cookwork = A.default_cookwork

/datum/cooking_item/proc/collect_available_reagents()
	. = list()
	if(container && container.reagents)
		for(var/datum/reagent/R in container.reagents.reagent_list)
			.[R.type] += R.volume
	if(target && target.reagents)
		for(var/datum/reagent/R in target.reagents.reagent_list)
			.[R.type] += R.volume

/datum/cooking_item/proc/finish_cooking()
	if(!target || QDELETED(target))
		return
	var/list/avail_reagents = collect_available_reagents()
	var/datum/cooking_recipe/R = select_cooking_recipe(
		avail_reagents,
		list(target),
		holder.appliance_flags
	)
	if(R)
		var/atom/loc = container || target.drop_location()
		var/obj/item/result = new R.result(loc)
		merge_reagents(R, target, result, avail_reagents)
		if(istype(target, /obj/item/food) && istype(result, /obj/item/food))
			var/obj/item/food/old_food = target
			var/obj/item/food/new_food = result
			if(old_food.tastes)
				LAZYINITLIST(new_food.tastes)
				new_food.tastes += old_food.tastes
		consume_recipe_reagents(R, avail_reagents)
		qdel(target)
		target = result
		apply_cooking_bonuses(result)
		return
	target.AddElement(/datum/element/food_cooked, cook_type)
	merge_input_reagents(target, target)
	if(holder.appliance_flags & APPLIANCE_FRYER)
		apply_oil_coating(target)

/datum/cooking_item/proc/merge_reagents(datum/cooking_recipe/R, obj/item/input, obj/item/result, list/avail_reagents)
	if(!result.reagents)
		return
	switch(R.reagent_mix)
		if(RECIPE_REAGENT_REPLACE)
			if(input.reagents)
				result.reagents.add_reagent_list(input.reagents.reagent_list)
		if(RECIPE_REAGENT_MAX)
			result.reagents.clear_reagents()
			if(input.reagents)
				for(var/datum/reagent/IR in input.reagents.reagent_list)
					var/existing = result.reagents.get_reagent_amount(IR.type)
					if(IR.volume > existing)
						result.reagents.add_reagent(IR.type, IR.volume - existing)
		if(RECIPE_REAGENT_SUM)
			result.reagents.clear_reagents()
			if(input.reagents)
				result.reagents.add_reagent_list(input.reagents.reagent_list)
			if(container && container.reagents)
				for(var/datum/reagent/CR in container.reagents.reagent_list)
					if(!(CR.type in R.reagents))
						result.reagents.add_reagent(CR.type, CR.volume)
		if(RECIPE_REAGENT_MIN)
			result.reagents.clear_reagents()
			if(input.reagents)
				for(var/datum/reagent/IR in input.reagents.reagent_list)
					var/has_in_recipe = FALSE
					for(var/rtype in R.reagents)
						if(IR.type == rtype)
							has_in_recipe = TRUE
							break
					if(!has_in_recipe)
						result.reagents.add_reagent(IR.type, min(5, IR.volume))

/datum/cooking_item/proc/consume_recipe_reagents(datum/cooking_recipe/R, list/avail_reagents)
	if(!length(R.reagents) || !container || !container.reagents)
		return
	for(var/rid in R.reagents)
		var/needed = R.reagents[rid]
		container.reagents.remove_reagent(rid, needed)

/datum/cooking_item/proc/merge_input_reagents(obj/item/input, obj/item/result)
	if(input.reagents && result.reagents && input != result)
		result.reagents.add_reagent_list(input.reagents.reagent_list)

/datum/cooking_item/proc/apply_oil_coating(obj/item/result)
	if(!result.reagents)
		return
	result.reagents.add_reagent(/datum/reagent/consumable/cooking_oil, 3)

/datum/cooking_item/proc/apply_cooking_bonuses(obj/item/result)
	if(!istype(result, /obj/item/food))
		return
	if(holder.appliance_flags & APPLIANCE_FRYER)
		apply_oil_coating(result)
		var/obj/item/food/F = result
		F.foodtypes |= FRIED

/datum/cooking_item/proc/burn()
	if(!target || QDELETED(target))
		return
	var/atom/loc = container || target.drop_location()
	var/obj/item/food/badrecipe/burnt = new(loc)
	qdel(target)
	target = burnt

/datum/cooking_item/Destroy()
	target = null
	holder = null
	container = null
	return ..()
