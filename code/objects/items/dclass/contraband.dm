// D-Class Contraband Items
// Items that D-Class can find and use for escape attempts

// Contraband Item Base Class
/obj/item/dclass_contraband
	var/contraband_type = "basic"
	var/contraband_key = "basic"
	var/risk_level = 1 // 1-5, higher = more dangerous
	var/legal_use = FALSE // Can this item be used legally?
	var/detection_chance = 20 // Base chance of being detected by guards
	var/uses = 0 // Number of uses remaining
	var/cleanliness = 100 // For disguise items
	var/quality = 50 // For items that need quality rating

// Basic Tools
/obj/item/dclass_contraband/wire
	contraband_key = "wire"
	name = "metal wire"
	desc = "A length of metal wire. Useful for crafting and electrical work."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "wire"
	w_class = WEIGHT_CLASS_TINY
	uses = 3

/obj/item/dclass_contraband/screwdriver
	contraband_key = "screwdriver"
	name = "screwdriver"
	desc = "A basic screwdriver. Can be used for various tasks."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "screwdriver"
	w_class = WEIGHT_CLASS_TINY
	uses = 5

/obj/item/dclass_contraband/wrench
	contraband_key = "wrench"
	name = "wrench"
	desc = "A sturdy wrench. Useful for mechanical work."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "wrench"
	w_class = WEIGHT_CLASS_SMALL
	uses = 4

/obj/item/dclass_contraband/knife
	contraband_key = "knife"
	name = "kitchen knife"
	desc = "A sharp kitchen knife. Handle with care."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "knife"
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	uses = 6

// Disguise Items
/obj/item/dclass_contraband/staff_uniform
	contraband_key = "staff_uniform"
	name = "staff uniform"
	desc = "A clean staff uniform. Could be useful for disguise."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "uniform"
	w_class = WEIGHT_CLASS_SMALL
	cleanliness = 100 // 0-100, affects disguise effectiveness
	contraband_type = "disguise"

/obj/item/dclass_contraband/fake_id
	contraband_key = "fake_id"
	name = "fake ID card"
	desc = "A poorly made fake ID card. Might fool someone in a hurry."
	icon = 'icons/obj/card.dmi'
	icon_state = "id"
	w_class = WEIGHT_CLASS_TINY
	quality = 50 // 0-100, affects success chance
	contraband_type = "disguise"

/obj/item/dclass_contraband/mask
	contraband_key = "mask"
	name = "disguise mask"
	desc = "A simple mask to hide your identity."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_mask"
	w_class = WEIGHT_CLASS_SMALL
	var/effectiveness = 30 // 0-100, affects detection chance
	contraband_type = "disguise"

// Materials
/obj/item/dclass_contraband/metal_pipe
	contraband_key = "metal_pipe"
	name = "metal pipe"
	desc = "A sturdy metal pipe. Could be used for various purposes."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pipe"
	w_class = WEIGHT_CLASS_NORMAL
	force = 15

/obj/item/dclass_contraband/fabric_scraps
	contraband_key = "fabric_scraps"
	name = "fabric scraps"
	desc = "Various pieces of fabric. Useful for crafting disguises."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "fabric"
	w_class = WEIGHT_CLASS_TINY
	var/amount = 3

/obj/item/dclass_contraband/thread
	contraband_key = "thread"
	name = "thread"
	desc = "Strong thread for sewing and crafting."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "thread"
	w_class = WEIGHT_CLASS_TINY
	var/amount = 5

// Chemicals and Medical
/obj/item/dclass_contraband/medicine
	contraband_key = "medicine"
	name = "medicine"
	desc = "Various medical supplies. Could be useful or dangerous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	w_class = WEIGHT_CLASS_TINY
	var/potency = 50

/obj/item/dclass_contraband/bandages
	contraband_key = "bandages"
	name = "bandages"
	desc = "Clean bandages. Useful for medical purposes or crafting."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bandage"
	w_class = WEIGHT_CLASS_TINY
	var/amount = 4

/obj/item/dclass_contraband/chemicals
	contraband_key = "chemicals"
	name = "chemicals"
	desc = "Various chemical compounds. Handle with extreme care."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	w_class = WEIGHT_CLASS_SMALL
	var/toxicity = 70

// Advanced Tools
/obj/item/dclass_contraband/lockpick
	contraband_key = "lockpick"
	name = "lockpick"
	desc = "A crude but effective lockpick. Use carefully."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "lockpick"
	w_class = WEIGHT_CLASS_TINY
	quality = 60
	uses = 3

/obj/item/dclass_contraband/cutting_tool
	contraband_key = "cutting_tool"
	name = "cutting tool"
	desc = "A sharp cutting implement. Useful for various tasks."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "scissors"
	w_class = WEIGHT_CLASS_SMALL
	force = 8
	uses = 4

/obj/item/dclass_contraband/electronics
	contraband_key = "electronics"
	name = "electronic components"
	desc = "Various electronic parts. Could be used for hacking or crafting."
	icon = 'icons/obj/module.dmi'
	icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	var/complexity = 40

/obj/item/dclass_contraband/Initialize()
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(M.ckey && SSdclass && SSdclass.manager)
			var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(M.ckey)
			if(player)
				player.add_contraband(contraband_key)

/obj/item/dclass_contraband/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(findtext(H.job, "D-Class"))
			add_verb(user, list(
				/obj/item/dclass_contraband/proc/examine_contraband,
				/obj/item/dclass_contraband/proc/hide_contraband,
			))

// Use contraband item
/obj/item/dclass_contraband/attack_self(mob/user)
	if(!user.ckey)
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(user.ckey)
	if(!player)
		return

	// Check if item can be used
	if(!can_use(user, player))
		return

	// Use the item
	use_item(user, player)

/obj/item/dclass_contraband/proc/can_use(mob/user, datum/dclass_player/player)
	// Check if player has required skills
	if(risk_level > player.level)
		to_chat(user, "<span class='warning'>You need to be level [risk_level] to use this item safely.</span>")
		return FALSE

	// Check if item has uses remaining
	if(uses && uses <= 0)
		to_chat(user, "<span class='warning'>This item is broken or used up.</span>")
		return FALSE

	return TRUE

/obj/item/dclass_contraband/proc/use_item(mob/user, datum/dclass_player/player)
	// Base implementation - reduce uses
	if(uses)
		uses--
		if(uses <= 0)
			to_chat(user, "<span class='notice'>The [name] breaks or is used up.</span>")
			qdel(src)

	// Increase suspicion
	player.increase_suspicion(risk_level * 5)

// Specific item use implementations
/obj/item/dclass_contraband/lockpick/use_item(mob/user, datum/dclass_player/player)
	. = ..()

	// Attempt to pick a nearby lock
	var/list/nearby_doors = list()
	for(var/obj/machinery/door/D in view(1, user))
		if(D.density) // Only locked doors
			nearby_doors += D

	if(nearby_doors.len > 0)
		var/obj/machinery/door/target_door = pick(nearby_doors)
		var/success_chance = quality + (player.skills["stealth"] - 1) * 10

		if(prob(success_chance))
			target_door.open()
			to_chat(user, "<span class='notice'>You successfully pick the lock!</span>")
			player.gain_experience(10, "successful lockpicking")
		else
			to_chat(user, "<span class='warning'>You fail to pick the lock.</span>")
			player.increase_suspicion(15)
	else
		to_chat(user, "<span class='warning'>No locked doors nearby.</span>")

/obj/item/dclass_contraband/staff_uniform/use_item(mob/user, datum/dclass_player/player)
	. = ..()

	// Apply disguise effect
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.w_uniform)
			H.dropItemToGround(H.w_uniform)

		H.equip_to_slot_if_possible(src, ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
		to_chat(user, "<span class='notice'>You put on the staff uniform as a disguise.</span>")

/obj/item/dclass_contraband/knife/use_item(mob/user, datum/dclass_player/player)
	. = ..()

	// Can be used as a weapon or tool
	var/choice = input(user, "How do you want to use the knife?", "Use Knife") as null|anything in list("Weapon", "Tool", "Cancel")

	switch(choice)
		if("Weapon")
			// Equip as weapon
			if(user.put_in_hands(src))
				to_chat(user, "<span class='notice'>You ready the knife as a weapon.</span>")
		if("Tool")
			// Use for crafting or cutting
			to_chat(user, "<span class='notice'>You use the knife for precise cutting work.</span>")
			player.gain_experience(5, "using knife as tool")
		if("Cancel")
			return

// Contraband detection by guards
/obj/item/dclass_contraband/proc/check_detection(mob/user, datum/dclass_player/player)
	if(!user || !player)
		return

	// Check if guards are nearby
	var/list/nearby_guards = list()
	for(var/mob/living/carbon/human/H in view(3, user))
		if(H.job && findtext(H.job, "Guard"))
			nearby_guards += H

	if(nearby_guards.len > 0)
		var/current_detection_chance = detection_chance
		current_detection_chance -= (player.skills["stealth"] - 1) * 5 // Skill reduces detection

		if(prob(current_detection_chance))
			// Guard detects contraband
			var/mob/living/carbon/human/guard = pick(nearby_guards)
			player.detect_contraband(guard)
			to_chat(user, "<span class='danger'>A guard has spotted your [name]!</span>")
			return TRUE

	return FALSE

// Contraband item verbs
/obj/item/dclass_contraband/proc/examine_contraband()
	set name = "Examine Contraband"
	set category = "D-Class"
	set hidden = TRUE
	set src in usr

	if(!usr.ckey)
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(usr.ckey)
	if(!player)
		return

	var/info = "<h3>[name]</h3>"
	info += "<b>Description:</b> [desc]<br>"
	info += "<b>Risk Level:</b> [risk_level]/5<br>"
	info += "<b>Detection Chance:</b> [detection_chance]%<br>"

	if(uses)
		info += "<b>Uses Remaining:</b> [uses]<br>"

	if(contraband_type == "disguise")
		info += "<b>Disguise Effectiveness:</b> [cleanliness]%<br>"

	to_chat(usr, "<span class='notice'>[info]</span>")

/obj/item/dclass_contraband/proc/hide_contraband()
	set name = "Hide Contraband"
	set category = "D-Class"
	set hidden = TRUE
	set src in usr

	if(!usr.ckey)
		return

	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(usr.ckey)
	if(!player)
		return

	// Hide the item in player's hidden items
	player.hidden_items[name] = src
	usr.dropItemToGround(src)

	to_chat(usr, "<span class='notice'>You hide the [name] in your secret stash.</span>")
	player.increase_suspicion(2)

// Credit Chip
/obj/item/dclass_credit_chip
	name = "D-Class Credit Chip"
	desc = "A small chip containing D-Class credits."
	icon = 'icons/obj/economy.dmi'
	icon_state = "credit_chip"
	w_class = WEIGHT_CLASS_TINY
	var/credits = 0
	var/owner_ckey

/obj/item/dclass_credit_chip/attack_self(mob/user)
	if(!user.ckey)
		return
	var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(user.ckey)
	if(!player)
		to_chat(user, span_warning("This chip is not registered to you."))
		return
	if(owner_ckey && owner_ckey != user.ckey)
		to_chat(user, span_warning("This chip belongs to someone else."))
		return
	if(!owner_ckey)
		owner_ckey = user.ckey
		to_chat(user, span_notice("You claim this credit chip."))
	player.adjust_credits(credits, "Found credit chip")
	to_chat(user, span_notice("You claim [credits] credits from the chip."))
	credits = 0
	qdel(src)

// Hidden Pouch
/obj/item/storage/dclass_pouch
	name = "D-Class Pouch"
	desc = "A small pouch for hiding contraband."
	icon = 'icons/obj/storage.dmi'
	icon_state = "pouch"
	w_class = WEIGHT_CLASS_SMALL
	max_integrity = 50
	var/hidden_compartment = FALSE
	var/list/compartment_items = list()
	var/detection_difficulty = 20

/obj/item/storage/dclass_pouch/proc/hide_item(obj/item/I)
	if(hidden_compartment && length(compartment_items) < 2)
		compartment_items += I
		I.forceMove(src)
		return TRUE
	return FALSE

/obj/item/storage/dclass_pouch/proc/reveal_hidden_items()
	. = compartment_items.Copy()
	for(var/obj/item/I in compartment_items)
		I.forceMove(get_turf(src))
	compartment_items = list()

/obj/item/storage/dclass_pouch/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/dclass_credit_chip))
		var/obj/item/dclass_credit_chip/chip = I
		if(hidden_compartment)
			hide_item(chip)
			to_chat(user, span_notice("You hide the credit chip in the secret compartment."))
			return
	return ..()

// D-Class Commissary Vendor
/obj/machinery/dclass_vendor
	name = "D-Class Commissary"
	desc = "A vending machine for D-Class purchases."
	icon = 'icons/obj/vending.dmi'
	icon_state = "dclass"
	density = TRUE
	anchored = TRUE
	var/contraband_mode = FALSE
	var/hack_level = 0

	var/list/legitimate_products = list(
		"better_food" = list("price" = 50, "type" = /obj/item/food/omelette, "name" = "Better Meal"),
		"snack" = list("price" = 25, "type" = /obj/item/food/candy, "name" = "Snack"),
		"drink" = list("price" = 20, "type" = /obj/item/reagent_containers/food/drinks/soda_cans/cola, "name" = "Drink"),
		"entertainment" = list("price" = 100, "type" = /obj/item/toy/cards/deck, "name" = "Deck of Cards"),
		"extra_blanket" = list("price" = 150, "type" = /obj/item/bedsheet, "name" = "Extra Blanket"),
		"shower_time" = list("price" = 50, "name" = "Extra Shower Time", "service" = TRUE),
		"recreation_time" = list("price" = 100, "name" = "Recreation Time", "service" = TRUE)
	)

	var/list/contraband_products = list(
		"shiv" = list("price" = 200, "type" = /obj/item/knife/shiv, "name" = "Shiv"),
		"lockpick" = list("price" = 300, "type" = /obj/item/dclass_contraband/lockpick, "name" = "Lockpick"),
		"radio" = list("price" = 500, "type" = /obj/item/radio, "name" = "Radio")
	)

/obj/machinery/dclass_vendor/attack_hand(mob/user)
	if(!user.ckey)
		return
	var/datum/dclass_player/player = SSdclass.manager?.get_dclass_player(user.ckey)
	if(!player)
		to_chat(user, span_warning("Only D-Class can use this vendor."))
		return

	var/list/products = contraband_mode ? contraband_products : legitimate_products
	var/choice = input(user, "Select a product (Credits: [player.credits])", "D-Class Commissary") as null|anything in products

	if(!choice || !user.ckey)
		return

	var/list/product = products[choice]
	if(!product)
		return

	var/price = product["price"]
	if(player.credits < price)
		to_chat(user, span_warning("Insufficient credits. Need [price - player.credits] more."))
		return

	player.adjust_credits(-price, "Purchase: [product["name"]]")

	if(!product["service"])
		var/item_type = product["type"]
		var/obj/item/I = new item_type(get_turf(user))
		user.put_in_hands(I)
	else
		apply_service(choice, player, user)

	to_chat(user, span_notice("You purchase [product["name"]] for [price] credits."))

	if(contraband_mode && prob(30 - player.trust_level * 5))
		player.add_incident("contraband_purchase", "Caught buying contraband: [choice]", "major")
		to_chat(user, span_danger("Security caught you buying contraband!"))

/obj/machinery/dclass_vendor/proc/apply_service(service_id, datum/dclass_player/player, mob/user)
	switch(service_id)
		if("shower_time")
			to_chat(user, span_notice("Extra shower time granted. Report to showers."))
			player.adjust_trust(1, "Purchased shower time")
		if("recreation_time")
			to_chat(user, span_notice("Recreation time granted. Enjoy your break."))
			player.adjust_trust(2, "Purchased recreation time")

/obj/machinery/dclass_vendor/emag_act(mob/user)
	if(!hack_level)
		hack_level = 1
		contraband_mode = TRUE
		to_chat(user, span_notice("You hack the vendor. Contraband menu unlocked."))
		return TRUE
	if(hack_level < 5)
		hack_level++
		to_chat(user, span_notice("Hack level increased to [hack_level]."))
		return TRUE
