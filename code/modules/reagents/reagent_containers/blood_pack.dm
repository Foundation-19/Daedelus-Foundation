/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	var/datum/blood/blood_type = null
	var/unique_blood = null
	var/labelled = FALSE
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)

/obj/item/reagent_containers/blood/Initialize(mapload)
	. = ..()
	if(ispath(blood_type))
		blood_type = GET_BLOOD_REF(blood_type)
		reagents.add_reagent(unique_blood || /datum/reagent/blood, 200, list("viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
		update_appearance(UPDATE_NAME)
	else if(blood_type)
		reagents.add_reagent(unique_blood, 200, list("viruses"=null,"blood_DNA"=null,"resistances"=null,"trace_chem"=null))
		update_appearance(UPDATE_NAME)

/// Handles updating the container when the reagents change.
/obj/item/reagent_containers/blood/on_reagent_change(datum/reagents/holder, ...)
	var/datum/reagent/blood/new_reagent = holder.has_reagent(/datum/reagent/blood)
	if(new_reagent && new_reagent.data && new_reagent.data["blood_type"])
		blood_type = new_reagent.data["blood_type"]
	else if(holder.has_reagent(/datum/reagent/consumable/liquidelectricity))
		blood_type = "LE"
	else
		blood_type = null
	return ..()

/obj/item/reagent_containers/blood/update_name(updates)
	. = ..()
	if(labelled)
		return
	if(istype(blood_type))
		name = "blood pack - [blood_type.name]"
	else
		name = "blood pack[blood_type ? " - [blood_type]" : null]"

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload)
	icon_state = "bloodpack"
	blood_type = pick(GLOB.blood_datums):type
	return ..()

/obj/item/reagent_containers/blood/a_plus
	blood_type = /datum/blood/human/apos

/obj/item/reagent_containers/blood/a_minus
	blood_type = /datum/blood/human/amin

/obj/item/reagent_containers/blood/b_plus
	blood_type = /datum/blood/human/bpos

/obj/item/reagent_containers/blood/b_minus
	blood_type = /datum/blood/human/bmin

/obj/item/reagent_containers/blood/o_plus
	blood_type = /datum/blood/human/opos

/obj/item/reagent_containers/blood/o_minus
	blood_type = /datum/blood/human/omin

/obj/item/reagent_containers/blood/lizard
	blood_type = /datum/blood/lizard

/obj/item/reagent_containers/blood/ethereal
	blood_type = "LE"
	unique_blood = /datum/reagent/consumable/liquidelectricity

/obj/item/reagent_containers/blood/universal
	blood_type = /datum/blood/universal

/obj/item/reagent_containers/blood/attackby(obj/item/tool, mob/user, params)
	if (istype(tool, /obj/item/pen) || istype(tool, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the label of [src]!"))
			return
		var/custom_label = tgui_input_text(user, "What would you like to label the blood pack?", "Blood Pack", name, MAX_NAME_LEN)
		if(!user.canUseTopic(src, USE_CLOSE))
			return
		if(user.get_active_held_item() != tool)
			return
		if(custom_label)
			labelled = TRUE
			name = "blood pack - [custom_label]"
			balloon_alert(user, "new label set")
		else
			labelled = FALSE
			update_appearance(UPDATE_NAME)
	else
		return ..()
