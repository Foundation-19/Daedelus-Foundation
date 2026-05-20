// D-Class Craftable Items
// Simple items D-Class can craft

/obj/item/dclass_crafting_kit
	name = "Improvised Crafting Kit"
	desc = "Materials for crafting."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dclass_crafting_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(H.ckey)
	if(!player)
		return

	var/list/recipes = list(
		"Shiv (1 metal_pipe)" = "shiv",
		"Lockpick (2 wire)" = "lockpick",
		"Pouch (2 fabric_scraps)" = "pouch",
		"Bandage (2 bandages)" = "bandage",
		"EMP Grenade (1 wire + 5u welding_fuel)" = "emp",
		"Smoke Bomb (5u potassium + 1 fabric_scraps)" = "smoke",
		"Improvised Tool (1 wire + 1 metal_pipe)" = "improvised_tool",
		"Disguise Kit (1 staff_uniform + 1 fabric_scraps)" = "disguise",
		"Tourniquet (1 fabric_scraps + 1 thread)" = "tourniquet",
		"Signal Flare (5u fuel + 1 metal_pipe)" = "flare",
		"Restraint Cutter (1 wire + 1 thread)" = "cutter",
		"Makeshift Armor (2 metal_pipe + 1 fabric_scraps)" = "armor",
		"Poisoned Shiv (1 knife + 5u toxin)" = "poison_shiv",
		"Stimulant Syringe (1 syringe + 5u epinephrine)" = "stimulant",
		"Improvised Explosive (10u fuel + 1 metal_pipe)" = "ied",
		"Grapple Hook (1 metal_pipe + 1 thread + 1 wire)" = "grapple",
		"Noise Maker (1 metal_utensils + 1 thread)" = "noisemaker",
		"Acid Bomb (10u sulphuric_acid + 5u fluacid)" = "acid_bomb",
		"Skeleton Key (1 screwdriver + 1 wire + 1 metal_pipe)" = "skeleton_key",
		"Medical Kit (1 medicine + 1 bandages + 1 fabric_scraps)" = "medkit",
		"Bolas (2 thread + 1 metal_utensils)" = "bolas",
		"Flashbang (5u potassium + 1 metal_pipe + 1 fabric_scraps)" = "flashbang",
	)
	var/choice = input(H, "Craft:", "Crafting") as null|anything in recipes
	if(!choice)
		return

	var/item_id = recipes[choice]
	var/has_materials = FALSE

	switch(item_id)
		if("shiv")
			if(player.has_contraband("metal_pipe"))
				player.remove_contraband("metal_pipe", 1)
				has_materials = TRUE
		if("lockpick")
			if(player.has_contraband("wire") && player.get_contraband_count("wire") >= 2)
				player.remove_contraband("wire", 2)
				has_materials = TRUE
		if("pouch")
			if(player.has_contraband("fabric_scraps") && player.get_contraband_count("fabric_scraps") >= 2)
				player.remove_contraband("fabric_scraps", 2)
				has_materials = TRUE
		if("bandage")
			if(player.has_contraband("bandages") && player.get_contraband_count("bandages") >= 2)
				player.remove_contraband("bandages", 2)
				has_materials = TRUE
		if("emp")
			if(player.has_contraband("wire") && has_reagent_in_inventory(H, /datum/reagent/fuel, 5))
				player.remove_contraband("wire", 1)
				consume_reagent_from_inventory(H, /datum/reagent/fuel, 5)
				has_materials = TRUE
		if("smoke")
			if(has_reagent_in_inventory(H, /datum/reagent/potassium, 5) && player.has_contraband("fabric_scraps"))
				consume_reagent_from_inventory(H, /datum/reagent/potassium, 5)
				player.remove_contraband("fabric_scraps", 1)
				has_materials = TRUE
		if("improvised_tool")
			if(player.has_contraband("wire") && player.has_contraband("metal_pipe"))
				player.remove_contraband("wire", 1)
				player.remove_contraband("metal_pipe", 1)
				has_materials = TRUE
		if("disguise")
			if(player.has_contraband("staff_uniform") && player.has_contraband("fabric_scraps"))
				player.remove_contraband("staff_uniform", 1)
				player.remove_contraband("fabric_scraps", 1)
				has_materials = TRUE
		if("tourniquet")
			if(player.has_contraband("fabric_scraps") && player.has_contraband("thread"))
				player.remove_contraband("fabric_scraps", 1)
				player.remove_contraband("thread", 1)
				has_materials = TRUE
		if("flare")
			if(has_reagent_in_inventory(H, /datum/reagent/fuel, 5) && player.has_contraband("metal_pipe"))
				consume_reagent_from_inventory(H, /datum/reagent/fuel, 5)
				player.remove_contraband("metal_pipe", 1)
				has_materials = TRUE
		if("cutter")
			if(player.has_contraband("wire") && player.has_contraband("thread"))
				player.remove_contraband("wire", 1)
				player.remove_contraband("thread", 1)
				has_materials = TRUE
		if("armor")
			if(player.has_contraband("metal_pipe") && player.get_contraband_count("metal_pipe") >= 2 && player.has_contraband("fabric_scraps"))
				player.remove_contraband("metal_pipe", 2)
				player.remove_contraband("fabric_scraps", 1)
				has_materials = TRUE
		if("poison_shiv")
			if(player.has_contraband("knife") && has_reagent_in_inventory(H, /datum/reagent/toxin, 5))
				player.remove_contraband("knife", 1)
				consume_reagent_from_inventory(H, /datum/reagent/toxin, 5)
				has_materials = TRUE
		if("stimulant")
			if(player.has_contraband("syringe") && has_reagent_in_inventory(H, /datum/reagent/medicine/epinephrine, 5))
				player.remove_contraband("syringe", 1)
				consume_reagent_from_inventory(H, /datum/reagent/medicine/epinephrine, 5)
				has_materials = TRUE
		if("ied")
			if(has_reagent_in_inventory(H, /datum/reagent/fuel, 10) && player.has_contraband("metal_pipe"))
				consume_reagent_from_inventory(H, /datum/reagent/fuel, 10)
				player.remove_contraband("metal_pipe", 1)
				has_materials = TRUE
		if("grapple")
			if(player.has_contraband("metal_pipe") && player.has_contraband("thread") && player.has_contraband("wire"))
				player.remove_contraband("metal_pipe", 1)
				player.remove_contraband("thread", 1)
				player.remove_contraband("wire", 1)
				has_materials = TRUE
		if("noisemaker")
			if(player.has_contraband("metal_utensils") && player.has_contraband("thread"))
				player.remove_contraband("metal_utensils", 1)
				player.remove_contraband("thread", 1)
				has_materials = TRUE
		if("acid_bomb")
			if(has_reagent_in_inventory(H, /datum/reagent/toxin/acid, 10) && has_reagent_in_inventory(H, /datum/reagent/toxin/acid/fluacid, 5))
				consume_reagent_from_inventory(H, /datum/reagent/toxin/acid, 10)
				consume_reagent_from_inventory(H, /datum/reagent/toxin/acid/fluacid, 5)
				has_materials = TRUE
		if("skeleton_key")
			if(player.has_contraband("screwdriver") && player.has_contraband("wire") && player.has_contraband("metal_pipe"))
				player.remove_contraband("screwdriver", 1)
				player.remove_contraband("wire", 1)
				player.remove_contraband("metal_pipe", 1)
				has_materials = TRUE
		if("medkit")
			if(player.has_contraband("medicine") && player.has_contraband("bandages") && player.has_contraband("fabric_scraps"))
				player.remove_contraband("medicine", 1)
				player.remove_contraband("bandages", 1)
				player.remove_contraband("fabric_scraps", 1)
				has_materials = TRUE
		if("bolas")
			if(player.has_contraband("thread") && player.get_contraband_count("thread") >= 2 && player.has_contraband("metal_utensils"))
				player.remove_contraband("thread", 2)
				player.remove_contraband("metal_utensils", 1)
				has_materials = TRUE
		if("flashbang")
			if(has_reagent_in_inventory(H, /datum/reagent/potassium, 5) && player.has_contraband("metal_pipe") && player.has_contraband("fabric_scraps"))
				consume_reagent_from_inventory(H, /datum/reagent/potassium, 5)
				player.remove_contraband("metal_pipe", 1)
				player.remove_contraband("fabric_scraps", 1)
				has_materials = TRUE

	if(has_materials)
		var/craft_xp = 15
		var/craft_suspicion = 5
		if(!prob(80))
			to_chat(H, span_warning("Your crafting attempt fails! The materials are wasted."))
			player.increase_suspicion(craft_suspicion)
			return
		var/obj/item/I
		switch(item_id)
			if("shiv")
				I = new /obj/item/knife/kitchen/shiv(get_turf(H))
			if("lockpick")
				I = new /obj/item/dclass_contraband/lockpick/improvised(get_turf(H))
			if("pouch")
				I = new /obj/item/storage/dclass_pouch(get_turf(H))
			if("bandage")
				I = new /obj/item/stack/medical/gauze/improvised(get_turf(H))
				craft_xp = 10
				craft_suspicion = 3
			if("emp")
				I = new /obj/item/grenade/empgrenade/improvised(get_turf(H))
				craft_xp = 30
				craft_suspicion = 15
			if("smoke")
				I = new /obj/item/grenade/smokebomb/improvised(get_turf(H))
				craft_xp = 20
				craft_suspicion = 10
			if("improvised_tool")
				I = new /obj/item/dclass_contraband/improvised_tool(get_turf(H))
				craft_xp = 20
				craft_suspicion = 8
			if("disguise")
				I = new /obj/item/dclass_contraband/disguise_kit(get_turf(H))
				craft_xp = 25
				craft_suspicion = 12
			if("tourniquet")
				I = new /obj/item/dclass_contraband/tourniquet(get_turf(H))
				craft_xp = 15
				craft_suspicion = 3
			if("flare")
				I = new /obj/item/flashlight/flare/improvised(get_turf(H))
				craft_xp = 15
				craft_suspicion = 5
			if("cutter")
				I = new /obj/item/dclass_contraband/restraint_cutter(get_turf(H))
				craft_xp = 20
				craft_suspicion = 8
			if("armor")
				I = new /obj/item/clothing/suit/makeshift_armor(get_turf(H))
				craft_xp = 25
				craft_suspicion = 10
			if("poison_shiv")
				I = new /obj/item/dclass_contraband/poison_shiv(get_turf(H))
				craft_xp = 30
				craft_suspicion = 18
			if("stimulant")
				I = new /obj/item/dclass_contraband/stimulant_syringe(get_turf(H))
				craft_xp = 25
				craft_suspicion = 12
			if("ied")
				I = new /obj/item/grenade/ied/improvised(get_turf(H))
				craft_xp = 35
				craft_suspicion = 20
			if("grapple")
				I = new /obj/item/dclass_contraband/grapple_hook(get_turf(H))
				craft_xp = 30
				craft_suspicion = 14
			if("noisemaker")
				I = new /obj/item/dclass_contraband/noise_maker(get_turf(H))
				craft_xp = 15
				craft_suspicion = 5
			if("acid_bomb")
				I = new /obj/item/grenade/acid/improvised(get_turf(H))
				craft_xp = 30
				craft_suspicion = 18
			if("skeleton_key")
				I = new /obj/item/dclass_contraband/skeleton_key(get_turf(H))
				craft_xp = 35
				craft_suspicion = 15
			if("medkit")
				I = new /obj/item/dclass_contraband/improvised_medkit(get_turf(H))
				craft_xp = 20
				craft_suspicion = 5
			if("bolas")
				I = new /obj/item/dclass_contraband/bolas(get_turf(H))
				craft_xp = 20
				craft_suspicion = 8
			if("flashbang")
				I = new /obj/item/grenade/flashbang/improvised(get_turf(H))
				craft_xp = 30
				craft_suspicion = 16
		if(I)
			H.put_in_hands(I)
			player.gain_experience(craft_xp, "crafting")
			player.increase_suspicion(craft_suspicion)
			to_chat(H, span_notice("You craft [choice]."))
	else
		to_chat(H, span_warning("You don't have materials for that."))

/obj/item/knife/kitchen/shiv
	name = "improvised blade"
	desc = "A crude weapon."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "knife"
	force = 12

/proc/has_reagent_in_inventory(mob/living/carbon/human/H, reagent_type, amount = 1)
	for(var/obj/item/reagent_containers/C in H.contents)
		if(C.reagents && C.reagents.has_reagent(reagent_type, amount))
			return TRUE
	for(var/obj/item/storage/S in H.contents)
		for(var/obj/item/reagent_containers/C in S.contents)
			if(C.reagents && C.reagents.has_reagent(reagent_type, amount))
				return TRUE
	return FALSE

/proc/consume_reagent_from_inventory(mob/living/carbon/human/H, reagent_type, amount = 1)
	for(var/obj/item/reagent_containers/C in H.contents)
		if(C.reagents && C.reagents.has_reagent(reagent_type, amount))
			C.reagents.remove_reagent(reagent_type, amount)
			return TRUE
	for(var/obj/item/storage/S in H.contents)
		for(var/obj/item/reagent_containers/C in S.contents)
			if(C.reagents && C.reagents.has_reagent(reagent_type, amount))
				C.reagents.remove_reagent(reagent_type, amount)
				return TRUE
	return FALSE
