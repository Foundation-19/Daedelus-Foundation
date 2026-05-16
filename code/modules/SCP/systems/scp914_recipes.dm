/datum/scp914_recipe
	var/input_type
	var/input_name
	var/list/outputs = list()

/datum/scp914_recipe/New(input_type, input_name, rough, coarse, one_to_one, fine, very_fine)
	src.input_type = input_type
	src.input_name = input_name
	if(rough)
		outputs[SCP914_ROUGH] = rough
	if(coarse)
		outputs[SCP914_COARSE] = coarse
	if(one_to_one)
		outputs[SCP914_ONE_TO_ONE] = one_to_one
	if(fine)
		outputs[SCP914_FINE] = fine
	if(very_fine)
		outputs[SCP914_VERY_FINE] = very_fine

GLOBAL_LIST_INIT(scp914_recipes, init_scp914_recipes())

/proc/init_scp914_recipes()
	var/list/recipes = list()
	var/T

	// ===== TOOLS =====
	recipes += new /datum/scp914_recipe(/obj/item/crowbar, "crowbar",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/wrench, /obj/item/wrench, /obj/item/crowbar)

	recipes += new /datum/scp914_recipe(/obj/item/wrench, "wrench",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/crowbar, /obj/item/crowbar, /obj/item/wrench)

	recipes += new /datum/scp914_recipe(/obj/item/screwdriver, "screwdriver",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/wirecutters, /obj/item/wirecutters, /obj/item/screwdriver)

	recipes += new /datum/scp914_recipe(/obj/item/wirecutters, "wirecutters",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/screwdriver, /obj/item/screwdriver, /obj/item/wirecutters)

	recipes += new /datum/scp914_recipe(/obj/item/weldingtool, "welding tool",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/weldingtool, /obj/item/weldingtool/experimental, /obj/item/weldingtool/experimental)

	recipes += new /datum/scp914_recipe(/obj/item/multitool, "multitool",\
		/obj/item/stack/cable_coil, /obj/item/stack/cable_coil,\
		/obj/item/analyzer, /obj/item/multitool, /obj/item/multitool)

	// ===== FLASHLIGHTS & DEVICES =====
	recipes += new /datum/scp914_recipe(/obj/item/flashlight, "flashlight",\
		/obj/item/stack/cable_coil, /obj/item/stack/cable_coil,\
		/obj/item/flashlight, /obj/item/flashlight, /obj/item/flashlight)

	recipes += new /datum/scp914_recipe(/obj/item/analyzer, "analyzer",\
		/obj/item/stack/cable_coil, /obj/item/stack/cable_coil,\
		/obj/item/multitool, /obj/item/multitool, /obj/item/multitool)

	recipes += new /datum/scp914_recipe(/obj/item/extinguisher, "fire extinguisher",\
		/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron,\
		/obj/item/extinguisher, /obj/item/extinguisher, /obj/item/extinguisher)

	// ===== MEDICAL =====
	recipes += new /datum/scp914_recipe(/obj/item/reagent_containers/syringe, "syringe",\
		null, /obj/item/stack/rods,\
		/obj/item/reagent_containers/pill, /obj/item/reagent_containers/pill, /obj/item/reagent_containers/pill)

	recipes += new /datum/scp914_recipe(/obj/item/reagent_containers/pill, "pill",\
		null, /obj/item/stack/rods,\
		/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/syringe)

	recipes += new /datum/scp914_recipe(/obj/item/stack/medical/bruise_pack, "bruise pack",\
		null, null,\
		/obj/item/stack/medical/suture, null, null)

	recipes += new /datum/scp914_recipe(/obj/item/stack/medical/ointment, "ointment",\
		null, null,\
		/obj/item/stack/medical/mesh, null, null)

	recipes += new /datum/scp914_recipe(/obj/item/stack/medical/suture, "suture",\
		null, null,\
		/obj/item/stack/medical/bruise_pack, null, null)

	recipes += new /datum/scp914_recipe(/obj/item/stack/medical/mesh, "mesh",\
		null, null,\
		/obj/item/stack/medical/ointment, null, null)

	// ===== MATERIALS / STACKS =====
	recipes += new /datum/scp914_recipe(/obj/item/stack/sheet/iron, "iron sheet",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/plasteel)

	recipes += new /datum/scp914_recipe(/obj/item/stack/sheet/glass, "glass sheet",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/stack/sheet/rglass, /obj/item/stack/sheet/rglass, /obj/item/stack/sheet/rglass)

	recipes += new /datum/scp914_recipe(/obj/item/stack/sheet/plasteel, "plasteel sheet",\
		/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron,\
		/obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/mineral/diamond, /obj/item/stack/sheet/mineral/diamond)

	recipes += new /datum/scp914_recipe(/obj/item/stack/rods, "metal rods",\
		null, null,\
		/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron, /obj/item/stack/sheet/plasteel)

	recipes += new /datum/scp914_recipe(/obj/item/stack/cable_coil, "cable coil",\
		null, null,\
		/obj/item/stack/cable_coil, /obj/item/stack/sheet/iron, /obj/item/stack/sheet/glass)

	recipes += new /datum/scp914_recipe(/obj/item/stack/sheet/rglass, "reinforced glass",\
		/obj/item/stack/sheet/glass, /obj/item/stack/sheet/glass,\
		/obj/item/stack/sheet/rglass, /obj/item/stack/sheet/rglass, /obj/item/stack/sheet/rglass)

	// ===== WEAPONS =====
	recipes += new /datum/scp914_recipe(/obj/item/knife, "knife",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/knife, /obj/item/knife/combat, /obj/item/knife/combat)

	recipes += new /datum/scp914_recipe(/obj/item/spear, "spear",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/knife, /obj/item/knife/combat, /obj/item/knife/combat)

	// ===== FOOD =====
	recipes += new /datum/scp914_recipe(/obj/item/food/bread, "bread",\
		null, null,\
		/obj/item/food/bread, /obj/item/food/bread, /obj/item/food/bread)

	recipes += new /datum/scp914_recipe(/obj/item/food/meat/slab, "meat slab",\
		null, null,\
		/obj/item/food/meat/slab, /obj/item/food/meat/slab, /obj/item/food/meat/slab)

	// ===== CLOTHING =====
	recipes += new /datum/scp914_recipe(/obj/item/clothing/head/helmet, "helmet",\
		/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron,\
		/obj/item/clothing/head/helmet, /obj/item/clothing/head/helmet, /obj/item/clothing/head/helmet)

	recipes += new /datum/scp914_recipe(/obj/item/clothing/suit/armor/vest, "armor vest",\
		/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron,\
		/obj/item/clothing/suit/armor/vest, /obj/item/clothing/suit/armor/vest, /obj/item/clothing/suit/armor/vest)

	recipes += new /datum/scp914_recipe(/obj/item/clothing/gloves/color/yellow, "insulated gloves",\
		/obj/item/stack/cable_coil, /obj/item/stack/cable_coil,\
		/obj/item/clothing/gloves/color/yellow, /obj/item/clothing/gloves/color/yellow, /obj/item/clothing/gloves/color/yellow)

	recipes += new /datum/scp914_recipe(/obj/item/clothing/shoes/sneakers/black, "black shoes",\
		null, null,\
		/obj/item/clothing/shoes/sneakers/black, /obj/item/clothing/shoes/sneakers/black, /obj/item/clothing/shoes/sneakers/black)

	recipes += new /datum/scp914_recipe(/obj/item/clothing/under/color/black, "black jumpsuit",\
		null, null,\
		/obj/item/clothing/under/color/black, /obj/item/clothing/under/color/black, /obj/item/clothing/under/color/black)

	// ===== STORAGE =====
	recipes += new /datum/scp914_recipe(/obj/item/storage/backpack, "backpack",\
		null, null,\
		/obj/item/storage/backpack, /obj/item/storage/backpack, /obj/item/storage/backpack)

	recipes += new /datum/scp914_recipe(/obj/item/storage/toolbox, "toolbox",\
		/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron,\
		/obj/item/storage/toolbox, /obj/item/storage/toolbox, /obj/item/storage/toolbox)

	recipes += new /datum/scp914_recipe(/obj/item/storage/belt, "belt",\
		null, null,\
		/obj/item/storage/belt, /obj/item/storage/belt, /obj/item/storage/belt)

	// ===== MISC =====
	recipes += new /datum/scp914_recipe(/obj/item/pen, "pen",\
		null, null,\
		/obj/item/pen, /obj/item/pen, /obj/item/pen)

	recipes += new /datum/scp914_recipe(/obj/item/paper, "paper",\
		null, null,\
		/obj/item/paper, /obj/item/paper, /obj/item/paper)

	recipes += new /datum/scp914_recipe(/obj/item/book, "book",\
		null, null,\
		/obj/item/book, /obj/item/book, /obj/item/book)

	recipes += new /datum/scp914_recipe(/obj/item/shovel, "shovel",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/pickaxe, /obj/item/pickaxe, /obj/item/pickaxe)

	recipes += new /datum/scp914_recipe(/obj/item/pickaxe, "pickaxe",\
		/obj/item/stack/rods, /obj/item/stack/rods,\
		/obj/item/shovel, /obj/item/shovel, /obj/item/shovel)

	recipes += new /datum/scp914_recipe(/obj/item/coin, "coin",\
		null, null,\
		/obj/item/coin, /obj/item/coin, /obj/item/coin)

	// ===== DYNAMIC RECIPES (text2path for types that may not be compiled) =====

	T = text2path("/obj/item/stack/sheet/mineral/diamond")
	if(T)
		recipes += new /datum/scp914_recipe(T, "diamond sheet",\
			/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron,\
			/obj/item/stack/sheet/plasteel, T, T)

	T = text2path("/obj/item/stack/sheet/mineral/plasma")
	if(T)
		recipes += new /datum/scp914_recipe(T, "plasma sheet",\
			/obj/item/stack/sheet/glass, /obj/item/stack/sheet/glass,\
			/obj/item/stack/sheet/plasmaglass, /obj/item/stack/sheet/plasmarglass, null)

	T = text2path("/obj/item/reagent_containers/hypospray/medipen")
	if(T)
		recipes += new /datum/scp914_recipe(T, "medipen",\
			/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/syringe,\
			/obj/item/reagent_containers/pill, null, null)

	T = text2path("/obj/item/healthanalyzer")
	if(T)
		recipes += new /datum/scp914_recipe(T, "health analyzer",\
			/obj/item/stack/cable_coil, /obj/item/stack/cable_coil,\
			null, null, null)

	T = text2path("/obj/item/restraints/handcuffs")
	if(T)
		recipes += new /datum/scp914_recipe(T, "handcuffs",\
			/obj/item/stack/rods, /obj/item/stack/rods,\
			null, null, null)

	T = text2path("/obj/item/modular_computer/tablet/pda")
	if(T)
		recipes += new /datum/scp914_recipe(T, "PDA",\
			/obj/item/stack/cable_coil, /obj/item/stack/cable_coil,\
			null, null, null)

	T = text2path("/obj/item/card/id")
	if(T)
		recipes += new /datum/scp914_recipe(T, "ID card",\
			/obj/item/stack/sheet/iron, /obj/item/stack/sheet/iron,\
			null, null, null)

	T = text2path("/obj/item/melee/baton")
	if(T)
		recipes += new /datum/scp914_recipe(T, "stunbaton",\
			/obj/item/stack/rods, /obj/item/stack/rods,\
			null, null, null)

	T = text2path("/obj/item/stack/spacecash")
	if(T)
		recipes += new /datum/scp914_recipe(T, "cash",\
			null, null,\
			null, null, null)

	T = text2path("/obj/item/storage/medkit")
	if(T)
		recipes += new /datum/scp914_recipe(T, "first aid kit",\
			null, null,\
			null, null, null)

	T = text2path("/obj/item/food/donut")
	if(T)
		recipes += new /datum/scp914_recipe(T, "donut",\
			null, null,\
			null, null, null)

	return recipes

/proc/scp914_find_recipe(obj/item/input)
	if(!input)
		return null

	for(var/datum/scp914_recipe/recipe in GLOB.scp914_recipes)
		if(istype(input, recipe.input_type))
			return recipe

	return null

/proc/scp914_process_item(obj/item/input, setting)
	if(!input || !setting)
		return null

	var/datum/scp914_recipe/recipe = scp914_find_recipe(input)
	if(recipe)
		var/result_type = recipe.outputs[setting]
		if(result_type)
			return result_type

	if(setting == SCP914_ROUGH)
		if(prob(60))
			return /obj/item/stack/rods
		return null

	if(setting == SCP914_COARSE)
		if(prob(40))
			return /obj/item/stack/rods
		if(prob(30))
			return /obj/item/stack/cable_coil
		return null

	if(setting == SCP914_ONE_TO_ONE)
		return input.type

	if(setting == SCP914_FINE)
		if(prob(70))
			return input.type
		return null

	if(setting == SCP914_VERY_FINE)
		if(prob(85))
			return input.type
		return null

	return input.type
