/obj/structure/scp216
	name = "safe"
	desc = "A metalic safe with multiple-dial combination lock."
	icon = 'icons/obj/structures.dmi'

	icon_state = "safe"
	anchored = TRUE
	density = TRUE

	//Config

	///Max items 216 can contain
	var/max_items = 10
	///Chance that items are generated for a code
	var/generate_chance = 75
	///Max amount of items that can be generated for a code
	var/max_items_generated = 9
	///Chance that an item is temporally displaced when inserted
	var/temporal_displacement_chance = 3 // Staggeringly unlikely, so you might be there awhile.

	//Mechanics

	///Are we open?
	var/open = FALSE
	///Our currrent code.
	var/current_code = 0
	/// Assoc list of codes in use and items stored in them.
	var/list/all_codes = list()

	/* Note: If editing, please keep the descending order by groups. More common items should be at the top. */
	// Unsorted
	// Medicine
	// Medical/Surgery tools
	// Tools
	// Power cells
	// Hats
	// Helmets
	// Clothing
	// Armor
	// Melee weapons
	// Ranged weapons
	// Antagonist stuff
	// SCP objects
	// Mobs
	/* TODO: Fix indendation check false-alarming at comments inside lists so we can put these in there */

	/// Weight list of potential atoms that can be generated inside on spawn. Path = Chance.
	var/list/random_items = list(
		/obj/item/a_gift = 600,
		/obj/item/bikehorn = 400,
		/obj/item/bikehorn/airhorn = 300,
		/obj/item/toy/plush/beeplushie = 250,
		/obj/item/instrument/guitar = 80,
		/obj/item/paper/fluff/jobs/cargo/manifest = 100,
		/obj/item/implanter/emp = 50,
		/obj/item/gps = 100,
		/obj/item/tape/birthday_party = 100,
		/obj/item/tape/therapy_session = 80,
		/obj/item/tape/cheese_dance_97 = 15,
		/obj/item/tape/fish_funeral = 40,
		/obj/item/tape/cereal_argument = 70,
		/obj/item/tape/moms_furniture = 60,
		/obj/item/tape/scp_test_001 = 20,
		/obj/item/tape/scp_test_002 = 15,
		/obj/item/tape/scp_test_003 = 10,
//		/obj/item/boombox = 300,
		/obj/item/a_gift/anything = 30,
		/obj/item/circular_saw = 500,
		/obj/item/crowbar = 500,
		/obj/item/multitool = 450,
		/obj/item/crowbar/brace_jack = 300,
		/obj/item/multitool/circuit = 250,
		/obj/item/stock_parts/cell/high = 500,
		/obj/item/stock_parts/cell/super = 450,
		/obj/item/stock_parts/cell/hyper = 400,
		/obj/item/stock_parts/cell/infinite = 5,
		/obj/item/clothing/head/beret = 500,
		/obj/item/clothing/head/bearpelt = 500,
//		/obj/item/clothing/head/beret/sec/corporate/officer = 450,
//		/obj/item/clothing/head/beret/sec/corporate/hos = 400,
//		/obj/item/clothing/head/beret/scp/goc = 300,
		/obj/item/clothing/head/helmet = 500,
//		/obj/item/clothing/head/helmet/ballistic = 500,
		/obj/item/clothing/head/helmet/riot = 500,
		/obj/item/clothing/head/bomb_hood/security = 400,
//		/obj/item/clothing/head/helmet/merc = 300,
		/obj/item/clothing/head/helmet/swat = 250,
		/obj/item/clothing/under/pants/black = 400,
//		/obj/item/clothing/under/rank/guard = 400,
//		/obj/item/clothing/under/rank/ntwork = 400,
//		/obj/item/clothing/under/rank/guard/nanotrasen = 400,
//		/obj/item/clothing/under/rank/ntwork/nanotrasen = 400,
//		/obj/item/clothing/under/suit_jacket/corp/nanotrasen = 400,
//		/obj/item/clothing/under/rank/guard/heph = 400,
//		/obj/item/clothing/under/rank/scientist/zeng = 400,
//		/obj/item/clothing/under/rank/scientist/executive/zeng = 400,
		/obj/item/clothing/under/pants/classicjeans = 400,
		/obj/item/clothing/under/pants/blackjeans = 400,
		/obj/item/clothing/under/pants/jeans = 400,
		/obj/item/clothing/under/pants/youngfolksjeans = 400,
//		/obj/item/clothing/under/casual_pants/baggy/track = 400,
		/obj/item/clothing/under/pants/camo = 350,
//		/obj/item/clothing/under/rank/security = 300,
//		/obj/item/clothing/under/rank/dispatch = 300,
//		/obj/item/clothing/under/rank/warden = 250,
//		/obj/item/clothing/under/rank/warden/corp = 250,
		/obj/item/clothing/under/syndicate = 100,
		/obj/item/clothing/under/syndicate/combat = 100,
//		/obj/item/clothing/under/syndicate/terragov = 100,
		/obj/item/clothing/suit/armor = 500,
//		/obj/item/clothing/suit/armor/pcarrier/medium = 500,
		/obj/item/clothing/suit/armor/riot = 450,
		/obj/item/clothing/suit/armor/bulletproof = 450,
		/obj/item/clothing/suit/armor/laserproof = 450,
		/obj/item/clothing/suit/armor/vest/warden = 450,
//		/obj/item/clothing/suit/armor/swat/officer = 400,
//		/obj/item/clothing/suit/armor/vest/ert = 300,
//		/obj/item/clothing/suit/armor/vest/ert/security = 300,
//		/obj/item/clothing/suit/storage/vest/tactical = 250,
//		/obj/item/clothing/suit/storage/vest/merc = 250,
//		/obj/item/clothing/suit/armor/pcarrier/tan/tactical = 250,
//		/obj/item/excalibur = 20,
//		/obj/item/gun/projectile/pistol = 80,
//		/obj/item/gun/projectile/pistol/military = 60,
//		/obj/item/gun/projectile/automatic = 30,
//		/obj/item/gun/projectile/heavysniper = 5,
		/obj/item/market_uplink = 60,
		/obj/item/multitool/uplink = 60,
		/obj/item/soulstone = 50,
		/obj/item/chameleon = 30,
		/obj/item/assembly/flash/handheld = 20,
//		/obj/item/reagent_containers/pill/scp500 = 10,
//		/obj/item/storage/pill_bottle/scp500 = 1,
		/mob/living/simple_animal/mouse/white = 150,
		/mob/living/simple_animal/pet/dog/corgi = 100,
		/mob/living/simple_animal/slime = 80,
		/mob/living/simple_animal/hostile/carp = 50,
		/mob/living/simple_animal/hostile/asteroid/wolf = 40,
		/mob/living/simple_animal/hostile/asteroid/polarbear
		)

/obj/structure/scp216/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"safe", //Name
		SCP_SAFE, //Obj Class
		"216", //Numerical Designation
	)
	GLOB.all_scp216s += src

/obj/structure/scp216/Destroy()
	LAZYCLEARLIST(all_codes) // Forever gone
	GLOB.all_scp216s -= src
	return ..()

/obj/structure/scp216/update_icon()
	..()
	if(open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/structure/scp216/attackby(obj/item/I, mob/user)
	if(!open)
		return ..()
	InsertItem(user, I, current_code)

/obj/structure/scp216/attack_hand(mob/user)
	if(user.stat != CONSCIOUS)
		to_chat(user, span_warning("You cannot use the safe while unconscious!"))
		return
	if(!in_range(src, user))
		to_chat(user, span_warning("You need to be next to the safe to use it!"))
		return
	var/text_code = add_leading(num2text(current_code, 7), 7, "0")
	var/dat = "<center>"
	dat += "<a href='?src=\ref[src];open=1'>[open ? "Close" : "Open"] [src]</a><br>"
	dat += "Current code: <a href='?src=\ref[src];change_code=1'>[text_code]</a><br>"
	if(open && (num2text(current_code, 7) in all_codes))
		dat += "<table>"
		for(var/atom/movable/A in all_codes[num2text(current_code, 7)])
			if(!ismob(A)) // Don't add mobs to the UI list
				dat += "<tr><td><a href='?src=\ref[src];retrieve=\ref[A]'>[A.name]</a></td></tr>"
		dat += "</table></center>"
	var/datum/browser/popup = new(user, "safe", "Safe", 350, 300)
	popup.set_content(dat)
	popup.open()

/obj/structure/scp216/proc/check_safe_conditions(mob/user_mob)
	return user_mob.stat == CONSCIOUS && in_range(src, user_mob)

/obj/structure/scp216/Topic(href, href_list)
	..()
	if(!usr.canUseTopic(src, USE_CLOSE|USE_NEED_HANDS|USE_IGNORE_TK|USE_DEXTERITY))
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr

	if(!in_range(src, user))
		to_chat(user, span_warning("You need to be next to the safe to use it!"))
		return

	if(href_list["open"])
		if(open) // Closing the safe
			if(!do_after(user, src, 20, extra_checks = CALLBACK(src, .proc/check_safe_conditions, user))) // 2 seconds delay (20 ticks)
				return
			to_chat(user, span_notice("You close [src]."))
			playsound(src, 'sound/structures/safe_toggle.ogg', 50, TRUE)
			open = FALSE
			SEND_SIGNAL(src, COMSIG_SCP216_CLOSE)
			hook_scp_interaction(user, "SCP-216", "safe_close")
			update_icon()

			// Handle temporal displacement on close
			if(num2text(current_code, 7) in all_codes)
				var/list/items_to_displace = list()
				for(var/atom/movable/A in all_codes[num2text(current_code, 7)])
					if(prob(temporal_displacement_chance))
						items_to_displace += A

				for(var/atom/movable/A in items_to_displace)
					var/list/item_data = list()
					item_data["path"] = A.type
					item_data["original_code"] = current_code
					item_data["displacement_round"] = GLOB.round_id
					item_data["rounds_until_reappearance"] = rand(1, 5) // Reappear 1-5 rounds later
					item_data["original_user_ckey"] = user.ckey
					item_data["original_user_name"] = user.name

					SSpersistence.displaced_scp216_items += list(item_data)
					SEND_SIGNAL(src, COMSIG_SCP216_TEMPORAL_DISPLACEMENT, A, user)
					all_codes[num2text(current_code, 7)] -= A // Remove from safe's current contents
					qdel(A) // Remove item from current round
					to_chat(user, span_notice("The [A.name] vanishes as you close the safe!"))

		else // Opening the safe
			playsound(src, 'sound/structures/safedial.ogg', 50, TRUE, channel = CHANNEL_SAFE_DIAL)
			if(!do_after(user, src, 20, extra_checks = CALLBACK(src, .proc/check_safe_conditions, user))) // 2 seconds delay (20 ticks)
				user.stop_sound_channel(CHANNEL_SAFE_DIAL) // Stop the sound if do_after fails
				return
			to_chat(user, span_notice("You open [src]."))
			playsound(src, 'sound/structures/safe_toggle.ogg', 50, TRUE)
			open = TRUE
			SEND_SIGNAL(src, COMSIG_SCP216_OPEN)
			hook_scp_interaction(user, "SCP-216", "safe_open")
			update_icon()
		// JUMPSCARE!!
		if(open && (num2text(current_code, 7) in all_codes))
			for(var/mob/living/L in all_codes[num2text(current_code, 7)])
				L.forceMove(get_turf(src))
				visible_message(span_danger("[L] falls out of \the [src]!"))
				SEND_SIGNAL(src, COMSIG_SCP216_MOB_RELEASED, L)
		attack_hand(user)
		return

	if(href_list["change_code"])
		if(open)
			to_chat(user, span_warning("You have to close the safe before changing the code!"))
			return
		var/temp_code = text2num(input(user, "Enter the new code.", "SCP 216") as null|text)
		if(!isnum(temp_code))
			to_chat(user, span_warning("Input a number!"))
			return
		if(temp_code > 9999999)
			to_chat(user, span_warning("The code can be no longer than 7 numbers!"))
			return
		if(temp_code < 0)
			to_chat(user, span_warning("The code can't be lower than zero!"))
			return
		current_code = temp_code
		if(!(num2text(current_code, 7) in all_codes))
			GenerateRandomItemsAt(current_code)
		SEND_SIGNAL(src, COMSIG_SCP216_CODE_CHANGED, current_code)
		hook_scp_interaction(user, "SCP-216", "code_change")
		attack_hand(user)
		return

	if(href_list["retrieve"])
		var/atom/movable/A = locate(href_list["retrieve"]) in all_codes[num2text(current_code, 7)]
		if(!A)
			to_chat(user, span_warning("Couldn't find the item."))
			return
		if(!open)
			return
		if(!in_range(src, user))
			return
		RetrieveItem(user, A, current_code)

/obj/structure/scp216/proc/GenerateRandomItemsAt(code)
	if(!(num2text(code, 7) in all_codes) || !islist(all_codes[num2text(code, 7)]))
		all_codes[num2text(code, 7)] = list()
	if(!(prob(generate_chance)))
		return
	for(var/i = 1 to rand(1, max_items_generated))
		var/chosen_atom = pick_weight(random_items)
		all_codes[num2text(code, 7)] += new chosen_atom(src)
	SEND_SIGNAL(src, COMSIG_SCP216_ITEMS_GENERATED, code)

/obj/structure/scp216/proc/InsertItem(mob/living/carbon/human/user, atom/movable/A, code_loc = 0)
	if(!(num2text(code_loc, 7) in all_codes) || !islist(all_codes[num2text(code_loc, 7)]))
		all_codes[num2text(code_loc, 7)] = list()
	if(length(all_codes[num2text(code_loc, 7)]) >= max_items)
		to_chat(user, span_warning("There is already too many things in there!"))
		return
	if(!user.transferItemToLoc(A, src))
		return

	all_codes[num2text(code_loc, 7)] += A
	SEND_SIGNAL(src, COMSIG_SCP216_ITEM_INSERTED, A, user)
	hook_scp_interaction(user, "SCP-216", "item_inserted")
	to_chat(user, span_notice("You place the [A.name] into the safe."))

	attack_hand(user)

/obj/structure/scp216/proc/RetrieveItem(mob/living/carbon/human/user, atom/movable/A, code_loc = 0)
	if(!(locate(A) in all_codes[num2text(code_loc, 7)]))
		return
	all_codes[num2text(code_loc, 7)] -= A
	if(isitem(A))
		if(!user.put_in_hands(A))
			A.forceMove(user)
	else // In case we want to get funky and put mobs into it
		A.forceMove(get_turf(src))
	SEND_SIGNAL(src, COMSIG_SCP216_ITEM_RETRIEVED, A, user)
	hook_scp_interaction(user, "SCP-216", "item_retrieved")
	attack_hand(user)
