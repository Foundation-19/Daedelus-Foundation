/obj/item/storage/fancy/cigarettes/scp420j
	name = "bag of mysterious herb"
	desc = "A small bag containing a green, herb-like substance. It smells incredibly potent. Man, this is some good ████."
	icon_state = "scp420j"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/fancy/cigarettes/scp420j/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "The Best ████ in the World", SCP_SAFE, "420-J")
/obj/item/storage/fancy/cigarettes/scp420j/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/scp420j(src)

/obj/item/storage/fancy/cigarettes/scp420j/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("A bag of what appears to be marijuana of extraordinary quality."))
	to_chat(user, span_warning("WARNING: Consumption results in extreme euphoria, impaired motor function, and insatiable hunger."))

/obj/item/clothing/mask/cigarette/scp420j
	name = "joint of SCP-420-J"
	desc = "A hand-rolled joint of the best ████ in the world. Just looking at it makes you want to chill."
	icon_state = "spliff"
	smoketime = 300
	chem_volume = 40

/obj/item/clothing/mask/cigarette/scp420j/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/drug/space_drugs, 10)
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 5)

/obj/item/clothing/mask/cigarette/scp420j/use_reagents(mob/living/carbon/human/smoker, drag)
	if(!istype(smoker) || !lit)
		return ..()

	if(prob(20))
		var/list/giggles = list(
			"hehehehe...",
			"huh huh... huh huh huh...",
			"hee hee hee...",
			"*snicker*",
			"man... that's deep...",
			"haha... woah...",
		)
		smoker.say(pick(giggles))

	if(prob(10))
		if(smoker.stamina)
			smoker.stamina.adjust(-5)
		smoker.adjust_drugginess(15)

	if(prob(8))
		smoker.overeatduration += 100
		to_chat(smoker, span_warning("You get the munchies REALLY bad."))

	if(prob(5))
		smoker.add_movespeed_modifier(/datum/movespeed_modifier/scp420j_slowdown)

	return ..()

/obj/item/clothing/mask/cigarette/scp420j/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !lit)
		return

	if(istype(target, /obj/item/reagent_containers/food) || istype(target, /obj/item/reagent_containers/glass))
		return

/obj/item/clothing/mask/cigarette/scp420j/attack_self(mob/living/carbon/human/user)
	if(!lit)
		light()
	else
		..()

/datum/movespeed_modifier/scp420j_slowdown
	slowdown = 1
	id = "scp420j_slowdown"
