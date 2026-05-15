/datum/cooking_recipe/boiledspaghetti
	name = "boiled spaghetti"
	items = list(/obj/item/food/spaghetti/raw = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/spaghetti/boiledspaghetti
	time = 120
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/boiled_egg
	name = "boiled egg"
	items = list(/obj/item/food/egg = 1)
	reagents = list(/datum/reagent/water = 5)
	result = /obj/item/food/boiledegg
	time = 90
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_meatball_soup
	name = "meatball soup"
	items = list(/obj/item/food/meatball = 1, /obj/item/food/grown/carrot = 1, /obj/item/food/grown/potato = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/meatball
	time = 200
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_vegetable_soup
	name = "vegetable soup"
	items = list(/obj/item/food/grown/carrot = 1, /obj/item/food/grown/corn = 1, /obj/item/food/grown/eggplant = 1, /obj/item/food/grown/potato = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/vegetable
	time = 200
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_nettle_soup
	name = "nettle soup"
	items = list(/obj/item/food/grown/nettle = 1, /obj/item/food/grown/potato = 1, /obj/item/food/boiledegg = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/nettle
	time = 180
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_tomato_soup
	name = "tomato soup"
	items = list(/obj/item/food/grown/tomato = 2)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/tomato
	time = 150
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_mushroom_soup
	name = "mushroom soup"
	items = list(/obj/item/food/grown/mushroom = 2)
	reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/milk = 5)
	result = /obj/item/food/soup/mushroom
	time = 160
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_beet_soup
	name = "beet soup"
	items = list(/obj/item/food/grown/whitebeet = 2)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/beet
	time = 160
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_miso_soup
	name = "miso soup"
	items = list(/obj/item/food/soydope = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/miso
	time = 140
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_stew
	name = "stew"
	items = list(/obj/item/food/grown/tomato = 1, /obj/item/food/meat/cutlet/plain = 1, /obj/item/food/grown/carrot = 1, /obj/item/food/grown/potato = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/stew
	time = 250
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_hot_chili
	name = "hot chili"
	items = list(/obj/item/food/meat/cutlet/plain = 1, /obj/item/food/grown/chili = 1, /obj/item/food/grown/tomato = 1)
	reagents = list(/datum/reagent/water = 5)
	result = /obj/item/food/soup/hotchili
	time = 200
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_onion_soup
	name = "french onion soup"
	items = list(/obj/item/food/grown/onion = 2)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/onion
	time = 180
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_pea_soup
	name = "pea soup"
	items = list(/obj/item/food/grown/peas = 2)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/peasoup
	time = 160
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_oatmeal
	name = "oatmeal"
	items = list(/obj/item/food/grown/oat = 1)
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/milk = 5)
	result = /obj/item/food/soup/oatmeal
	time = 120
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_sweet_potato_soup
	name = "sweet potato soup"
	items = list(/obj/item/food/grown/potato/sweet = 2)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/sweetpotato
	time = 160
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_bisque
	name = "bisque"
	items = list(/obj/item/food/meat/crab = 1, /obj/item/food/grown/tomato = 1)
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/cream = 5)
	result = /obj/item/food/soup/bisque
	time = 200
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_monkeys_delight
	name = "monkey's delight"
	items = list(/obj/item/food/meat/slab/monkey = 1, /obj/item/food/grown/banana = 1, /obj/item/food/dough = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/food/soup/monkeysdelight
	time = 220
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_clown_chili
	name = "chili con carnival"
	items = list(/obj/item/food/meat/cutlet/plain = 1, /obj/item/food/grown/chili = 1, /obj/item/food/grown/banana = 1, /obj/item/food/grown/tomato = 1)
	reagents = list(/datum/reagent/water = 5)
	result = /obj/item/food/soup/clownchili
	time = 200
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_bungo_curry
	name = "bungo curry"
	items = list(/obj/item/food/grown/bungofruit = 1, /obj/item/food/grown/chili = 1)
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/cream = 5)
	result = /obj/item/food/soup/bungocurry
	time = 180
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_indian_curry
	name = "indian chicken curry"
	items = list(/obj/item/food/meat/slab/chicken = 1, /obj/item/food/grown/chili = 1)
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/cream = 5)
	result = /obj/item/food/soup/indian_curry
	time = 200
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_electron_soup
	name = "electron soup"
	items = list(/obj/item/food/grown/mushroom/glowshroom = 2)
	reagents = list(/datum/reagent/consumable/liquidelectricity = 5)
	result = /obj/item/food/soup/electron
	time = 180
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/pot_wing_fang_chu
	name = "wing fang chu"
	items = list(/obj/item/food/meat/cutlet/xeno = 2)
	reagents = list(/datum/reagent/consumable/soysauce = 5)
	result = /obj/item/food/soup/wingfangchu
	time = 180
	appliance = APPLIANCE_POT
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/saucepan_pasta_tomato
	name = "pasta with tomato sauce"
	items = list(/obj/item/food/spaghetti/boiledspaghetti = 1, /obj/item/food/grown/tomato = 1)
	result = /obj/item/food/spaghetti/pastatomato
	time = 120
	appliance = APPLIANCE_SAUCEPAN

/datum/cooking_recipe/saucepan_meatball_spaghetti
	name = "spaghetti and meatballs"
	items = list(/obj/item/food/spaghetti/boiledspaghetti = 1, /obj/item/food/meatball = 1)
	result = /obj/item/food/spaghetti/meatballspaghetti
	time = 130
	appliance = APPLIANCE_SAUCEPAN

/datum/cooking_recipe/saucepan_spesslaw
	name = "spesslaw"
	items = list(/obj/item/food/spaghetti/boiledspaghetti = 1, /obj/item/food/meatball = 4)
	result = /obj/item/food/spaghetti/spesslaw
	time = 150
	appliance = APPLIANCE_SAUCEPAN

/datum/cooking_recipe/saucepan_chow_mein
	name = "chow mein"
	items = list(/obj/item/food/spaghetti/boiledspaghetti = 1, /obj/item/food/grown/carrot = 1, /obj/item/food/grown/corn = 1)
	reagents = list(/datum/reagent/consumable/soysauce = 5)
	result = /obj/item/food/spaghetti/chowmein
	time = 140
	appliance = APPLIANCE_SAUCEPAN

/datum/cooking_recipe/saucepan_beef_noodle
	name = "beef noodle"
	items = list(/obj/item/food/spaghetti/boiledspaghetti = 1, /obj/item/food/meat/cutlet/plain = 1, /obj/item/food/grown/carrot = 1)
	result = /obj/item/food/spaghetti/beefnoodle
	time = 140
	appliance = APPLIANCE_SAUCEPAN

/datum/cooking_recipe/saucepan_butter_noodles
	name = "butter noodles"
	items = list(/obj/item/food/spaghetti/boiledspaghetti = 1)
	reagents = list(/datum/reagent/consumable/cooking_oil = 2)
	result = /obj/item/food/spaghetti/butternoodles
	time = 80
	appliance = APPLIANCE_SAUCEPAN

/datum/cooking_recipe/saucepan_mac_n_cheese
	name = "mac and cheese"
	items = list(/obj/item/food/spaghetti/boiledspaghetti = 1)
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/cream = 2)
	result = /obj/item/food/spaghetti/mac_n_cheese
	time = 120
	appliance = APPLIANCE_SAUCEPAN

/datum/cooking_recipe/skillet_egg
	name = "fried egg (skillet)"
	items = list(/obj/item/food/egg = 1)
	reagents = list(/datum/reagent/consumable/cooking_oil = 2)
	result = /obj/item/food/friedegg
	time = 60
	appliance = APPLIANCE_SKILLET
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/skillet_bacon
	name = "fried bacon (skillet)"
	items = list(/obj/item/food/meat/rawbacon = 1)
	reagents = list(/datum/reagent/consumable/cooking_oil = 1)
	result = /obj/item/food/meat/bacon
	time = 80
	appliance = APPLIANCE_SKILLET
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/skillet_cutlet
	name = "fried cutlet (skillet)"
	items = list(/obj/item/food/meat/rawcutlet = 1)
	reagents = list(/datum/reagent/consumable/cooking_oil = 1)
	result = /obj/item/food/meat/cutlet/plain
	time = 90
	appliance = APPLIANCE_SKILLET
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/skillet_patty
	name = "fried patty (skillet)"
	items = list(/obj/item/food/raw_patty = 1)
	reagents = list(/datum/reagent/consumable/cooking_oil = 1)
	result = /obj/item/food/patty/plain
	time = 90
	appliance = APPLIANCE_SKILLET
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/skillet_pancake
	name = "pancake"
	items = list(/obj/item/food/pancakes/raw = 1)
	reagents = list(/datum/reagent/consumable/cooking_oil = 2)
	result = /obj/item/food/pancakes
	time = 100
	appliance = APPLIANCE_SKILLET
	reagent_mix = RECIPE_REAGENT_MIN

/datum/cooking_recipe/saucepan_scrambled
	name = "scrambled egg"
	items = list(/obj/item/food/egg = 1)
	reagents = list(/datum/reagent/consumable/cooking_oil = 1)
	result = /obj/item/food/friedegg
	time = 50
	appliance = APPLIANCE_SAUCEPAN
	reagent_mix = RECIPE_REAGENT_MIN

