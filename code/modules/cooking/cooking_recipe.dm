/datum/cooking_recipe
	var/name = "unnamed recipe"
	var/list/reagents = list()
	var/list/items = list()
	var/obj/item/result
	var/result_quantity = 1
	var/time = 100
	var/appliance = NONE
	var/reagent_mix = RECIPE_REAGENT_REPLACE
	var/finished_temperature = T20C

/datum/cooking_recipe/proc/check_reagents(list/available_reagents)
	if(!length(reagents))
		return COOK_CHECK_EXACT
	for(var/rid in reagents)
		var/needed = reagents[rid]
		if(!available_reagents[rid] || available_reagents[rid] < needed)
			return COOK_CHECK_FAIL
	return COOK_CHECK_EXACT

/datum/cooking_recipe/proc/check_items(list/available_items)
	if(!length(items))
		return COOK_CHECK_EXACT
	var/list/temp_items = available_items.Copy()
	for(var/itype in items)
		var/needed = items[itype]
		var/found = 0
		for(var/i = 1 to length(temp_items))
			if(istype(temp_items[i], itype))
				found++
				if(found >= needed)
					break
		if(found < needed)
			return COOK_CHECK_FAIL
	return COOK_CHECK_EXACT

/datum/cooking_recipe/proc/check_appliance(flag)
	if(appliance & flag)
		return TRUE
	return FALSE

var/global/list/datum/cooking_recipe/cooking_recipe_cache

/proc/get_cooking_recipes()
	if(!cooking_recipe_cache)
		cooking_recipe_cache = list()
		for(var/datum/cooking_recipe/R as anything in subtypesof(/datum/cooking_recipe))
			cooking_recipe_cache += R
	return cooking_recipe_cache

/proc/select_cooking_recipe(list/reagent_list, list/item_list, appliance_flag)
	var/datum/cooking_recipe/winner = null
	var/winner_score = -1
	for(var/datum/cooking_recipe/R as anything in get_cooking_recipes())
		if(!R.check_appliance(appliance_flag))
			continue
		if(R.check_reagents(reagent_list) == COOK_CHECK_FAIL)
			continue
		if(R.check_items(item_list) == COOK_CHECK_FAIL)
			continue
		var/score = length(R.reagents) + length(R.items)
		if(score > winner_score)
			winner_score = score
			winner = R
	return winner
