/obj/machinery/papershredder
	name = "paper shredder"
	desc = "For those documents you don't want seen."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperbin0"
	density = TRUE
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	var/max_paper = 10
	var/paperamount = 0

	var/list/shred_amounts = list(
		/obj/item/photo = 1,
		/obj/item/paper = 1,
		/obj/item/newspaper = 3,
		/obj/item/card/id = 3,
	)

/obj/machinery/papershredder/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage))
		empty_bin(user, W)
		return
	var/paper_result
	for(var/shred_type in shred_amounts)
		if(istype(W, shred_type))
			paper_result = shred_amounts[shred_type]
	if(paper_result)
		if(paperamount == max_paper)
			to_chat(user, span_warning("[src] is full; please empty it before you continue."))
			return
		paperamount += paper_result
		qdel(W)
		playsound(src, 'sound/items/handling/paper_drop.ogg', 75, TRUE)
		if(paperamount > max_paper)
			to_chat(user, span_danger("[src] was too full, and shredded paper goes everywhere!"))
			for(var/i in 1 to (paperamount - max_paper))
				var/obj/item/shreddedp/SP = get_shredded_paper()
				SP.forceMove(drop_location())
				SP.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), 1, 5)
			paperamount = max_paper
		update_icon_state()
		return
	return ..()

/obj/machinery/papershredder/verb/empty_contents()
	set name = "Empty bin"
	set category = "Object"
	set src in range(1)

	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(!paperamount)
		to_chat(usr, span_notice("[src] is empty."))
		return

	empty_bin(usr)

/obj/machinery/papershredder/proc/empty_bin(mob/living/user, obj/item/storage/empty_into)
	if(empty_into)
		if(paperamount == 0)
			to_chat(user, span_notice("[src] is empty."))
			return
		while(paperamount > 0)
			var/obj/item/shred_temp = get_shredded_paper()
			if(empty_into.atom_storage?.can_insert(shred_temp, user))
				shred_temp.forceMove(empty_into)
			else
				qdel(shred_temp)
				paperamount++
				break
		if(paperamount == 0)
			to_chat(user, span_notice("You empty [src] into [empty_into]."))
		if(paperamount > 0)
			to_chat(user, span_notice("[empty_into] will not fit any more shredded paper."))
	else
		while(paperamount > 0)
			get_shredded_paper()
	update_icon_state()

/obj/machinery/papershredder/proc/get_shredded_paper()
	if(paperamount)
		paperamount--
		return new /obj/item/shreddedp(drop_location())

/obj/machinery/papershredder/update_icon_state()
	icon_state = "paperbin[clamp(round(paperamount / 2), 0, 5)]"

/obj/item/shreddedp
	name = "shredded paper"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "scrap"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 3
	throw_speed = 1
	resistance_flags = FLAMMABLE

/obj/item/shreddedp/Initialize(mapload)
	. = ..()
	if(prob(65))
		color = pick("#bababa", "#7f7f7f")

/obj/item/shreddedp/fire_act(datum/source, exposed_temperature, exposed_volume)
	new /obj/effect/decal/cleanable/ash(drop_location())
	qdel(src)
