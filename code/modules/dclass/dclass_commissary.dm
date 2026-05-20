/obj/machinery/vending/dclass_commissary
	name = "D-Class Commissary"
	desc = "A vending machine where D-Class personnel can spend their earned credits on privileges and items."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = TRUE
	anchored = TRUE
	var/linked_ckey = null

/obj/machinery/vending/dclass_commissary/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DclassCommissary", "D-Class Commissary")
		ui.open()

/obj/machinery/vending/dclass_commissary/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/vending/dclass_commissary/ui_data(mob/user)
	var/list/data = list()
	var/list/products = list()

	var/datum/dclass_player/player = SSdclass.manager?.get_dclass_player(user.ckey)
	var/credits = player ? player.credits : 0
	data["credits"] = credits

	products += list(list("name" = "Cigarette Pack", "cost" = 20, "id" = "cigarettes", "desc" = "A pack of cheap cigarettes."))
	products += list(list("name" = "Lighter", "cost" = 10, "id" = "lighter", "desc" = "A cheap lighter."))
	products += list(list("name" = "Candy Bar", "cost" = 15, "id" = "candy", "desc" = "A chocolate bar."))
	products += list(list("name" = "Cola Can", "cost" = 10, "id" = "cola", "desc" = "A can of cola. Refreshing."))
	products += list(list("name" = "Better Meal Voucher", "cost" = 30, "id" = "meal_voucher", "desc" = "Redeemable for a hot meal."))
	products += list(list("name" = "Book", "cost" = 25, "id" = "book", "desc" = "A worn paperback novel."))
	products += list(list("name" = "Deck of Cards", "cost" = 35, "id" = "cards", "desc" = "A standard deck of playing cards."))
	products += list(list("name" = "Extra Blanket", "cost" = 40, "id" = "blanket", "desc" = "A thin but warm blanket."))
	products += list(list("name" = "Medical Kit", "cost" = 100, "id" = "medkit", "desc" = "A basic first aid kit."))
	products += list(list("name" = "Shower Token", "cost" = 20, "id" = "shower", "desc" = "Grants 5 minutes of hot water."))
	products += list(list("name" = "Writing Kit", "cost" = 30, "id" = "writing", "desc" = "Paper and pencil."))

	data["products"] = products
	return data

/obj/machinery/vending/dclass_commissary/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "purchase")
		var/item_id = params["id"]
		var/cost = text2num(params["cost"])
		if(!item_id || !cost)
			return

		var/mob/living/carbon/human/H = usr
		if(!istype(H))
			return

		var/datum/dclass_player/player = SSdclass.manager?.get_dclass_player(H.ckey)
		if(!player)
			to_chat(H, span_warning("No D-Class record found."))
			return

		if(player.credits < cost)
			to_chat(H, span_warning("Insufficient credits. You have [player.credits], need [cost]."))
			return

		player.adjust_credits(-cost, "Commissary purchase: [item_id]")

		var/obj/item/purchased = create_purchase_item(item_id, H)
		if(purchased)
			H.put_in_hands(purchased)
			to_chat(H, span_notice("You purchased [purchased.name] for [cost] credits. Remaining: [player.credits]."))
		else
			to_chat(H, span_notice("Service redeemed for [cost] credits. Remaining: [player.credits]."))

		. = TRUE

/obj/machinery/vending/dclass_commissary/proc/create_purchase_item(item_id, mob/living/carbon/human/H)
	switch(item_id)
		if("cigarettes")
			return new /obj/item/storage/fancy/cigarettes(H)
		if("lighter")
			return new /obj/item/lighter/greyscale(H)
		if("candy")
			return new /obj/item/food/candy(H)
		if("cola")
			return new /obj/item/reagent_containers/cup/glass/bottle/cola(H)
		if("meal_voucher")
			var/obj/item/paper/P = new(H)
			P.name = "Meal Voucher"
			P.info = "This voucher entitles the bearer to one hot meal from the D-Class kitchen."
			return P
		if("book")
			var/obj/item/book/B = new(H)
			B.starting_title = "Worn Novel"
			B.starting_author = "Unknown"
			B.starting_content = "The pages are yellowed and the spine cracked, but the story within offers a brief escape from confinement."
			return B
		if("cards")
			return new /obj/item/toy/cards/deck(H)
		if("blanket")
			var/obj/item/bedsheet/BS = new(H)
			BS.name = "D-Class blanket"
			return BS
		if("medkit")
			return new /obj/item/storage/medkit/regular(H)
		if("shower")
			var/obj/item/paper/P = new(H)
			P.name = "Shower Token"
			P.info = "Grants 5 minutes of hot water. Present to the guard on duty."
			return P
		if("writing")
			return new /obj/item/pen(H)
	return null