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
		"EMP Grenade (1 wire + 1 chemicals)" = "emp",
		"Smoke Bomb (1 chemicals + 1 fabric_scraps)" = "smoke",
		"Improvised Tool (1 wire + 1 metal_pipe)" = "improvised_tool",
		"Disguise Kit (1 staff_uniform + 1 fabric_scraps)" = "disguise",
		"Tourniquet (1 fabric_scraps + 1 thread)" = "tourniquet",
		"Signal Flare (1 chemicals + 1 metal_pipe)" = "flare",
		"Restraint Cutter (1 wire + 1 thread)" = "cutter",
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
			if(player.has_contraband("wire") && player.has_contraband("chemicals"))
				player.remove_contraband("wire", 1)
				player.remove_contraband("chemicals", 1)
				has_materials = TRUE
		if("smoke")
			if(player.has_contraband("chemicals") && player.has_contraband("fabric_scraps"))
				player.remove_contraband("chemicals", 1)
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
			if(player.has_contraband("chemicals") && player.has_contraband("metal_pipe"))
				player.remove_contraband("chemicals", 1)
				player.remove_contraband("metal_pipe", 1)
				has_materials = TRUE
		if("cutter")
			if(player.has_contraband("wire") && player.has_contraband("thread"))
				player.remove_contraband("wire", 1)
				player.remove_contraband("thread", 1)
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
