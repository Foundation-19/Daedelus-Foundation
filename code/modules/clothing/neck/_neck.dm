/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	fallback_colors = list(list(15, 19))
	fallback_icon_state = "scarf"
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	strip_delay = 40
	equip_delay_other = 40

/obj/item/clothing/neck/worn_overlays(mob/living/carbon/human/wearer, mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(body_parts_covered & HEAD)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")
		var/list/dna = return_blood_DNA()
		if(length(dna))
			if(istype(wearer))
				var/obj/item/bodypart/head = wearer.get_bodypart(BODY_ZONE_HEAD)
				if(!head?.icon_bloodycover)
					return
				var/image/bloody_overlay = image(head.icon_bloodycover, "maskblood")
				bloody_overlay.color = get_blood_dna_color(dna)
				. += bloody_overlay
			else
				. += mutable_appearance('icons/effects/blood.dmi', "maskblood")

/obj/item/clothing/neck/tie
	name = "slick tie"
	desc = "A neosilk tie."
	inhand_icon_state = "" //no inhands
	icon_state = "tie_greyscale_tied"
	alternate_worn_layer = LOW_NECK_LAYER
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_ASSISTANT * 1.4
	greyscale_config = /datum/greyscale_config/ties
	greyscale_config_worn = /datum/greyscale_config/ties/worn
	greyscale_colors = "#4d4e4e"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/tie/blue
	name = "blue tie"
	icon_state = "/obj/item/clothing/neck/tie/blue"
	greyscale_colors = "#5275b6ff"

/obj/item/clothing/neck/tie/red
	name = "red tie"
	icon_state = "/obj/item/clothing/neck/tie/red"
	greyscale_colors = "#c23838ff"

/obj/item/clothing/neck/tie/black
	name = "black tie"
	icon_state = "/obj/item/clothing/neck/tie/black"
	greyscale_colors = "#151516ff"

/obj/item/clothing/neck/tie/horrible
	name = "horrible tie"
	desc = "A neosilk tie. This one is disgusting."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "horribletie"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/maid
	name = "maid neck cover"
	desc = "A neckpiece for a maid costume, it smells faintly of disappointment."
	icon_state = "maid_neck"

/obj/item/clothing/neck/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"

/obj/item/clothing/neck/stethoscope/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts \the [src] to [user.p_their()] chest! It looks like [user.p_they()] won't hear much!"))
	return OXYLOSS

/obj/item/clothing/neck/stethoscope/attack(mob/living/M, mob/living/user)
	if(!ishuman(M) || !isliving(user))
		return ..()
	if(user.combat_mode)
		return

	var/mob/living/carbon/carbon_patient = M
	var/body_part = parse_zone(user.zone_selected)

	var/heart_strength = span_danger("no")
	var/lung_strength = span_danger("no")

	var/obj/item/organ/heart/heart = carbon_patient.getorganslot(ORGAN_SLOT_HEART)
	var/obj/item/organ/lungs/lungs = carbon_patient.getorganslot(ORGAN_SLOT_LUNGS)

	if(carbon_patient.stat != DEAD && !(HAS_TRAIT(carbon_patient, TRAIT_FAKEDEATH)))
		if(istype(heart))
			heart_strength = (heart.pulse == PULSE_NORM ? "a healthy" : span_danger("an unstable"))
		if(istype(lungs))
			lung_strength = ((carbon_patient.failed_last_breath || carbon_patient.losebreath) ? span_danger("strained") : "healthy")

	user.visible_message(span_notice("[user] places [src] against [carbon_patient]'s [body_part] and listens attentively."), ignored_mobs = user)

	var/diagnosis = (body_part == BODY_ZONE_CHEST ? "You hear [heart_strength] pulse and [lung_strength] respiration" : "You faintly hear [heart_strength] pulse")
	if(!user.can_hear())
		diagnosis = "You don't hear anything."

	to_chat(user, span_notice("You place [src] against [carbon_patient]'s [body_part]. [diagnosis]."))

///////////
//SCARVES//
///////////

/obj/item/clothing/neck/scarf //Default white color, same functionality as beanies.
	name = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon_state = "scarf"
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_ASSISTANT * 1.6
	greyscale_colors = "#EEEEEE#EEEEEE"
	greyscale_config = /datum/greyscale_config/scarf
	greyscale_config_worn = /datum/greyscale_config/scarf/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/scarf/black
	name = "black scarf"
	icon_state = "/obj/item/clothing/neck/scarf/black"
	greyscale_colors = "#4A4A4B#4A4A4B"

/obj/item/clothing/neck/scarf/pink
	name = "pink scarf"
	icon_state = "/obj/item/clothing/neck/scarf/pink"
	greyscale_colors = "#F699CD#F699CD"

/obj/item/clothing/neck/scarf/red
	name = "red scarf"
	icon_state = "/obj/item/clothing/neck/scarf/red"
	greyscale_colors = "#D91414#D91414"

/obj/item/clothing/neck/scarf/green
	name = "green scarf"
	icon_state = "/obj/item/clothing/neck/scarf/green"
	greyscale_colors = "#5C9E54#5C9E54"

/obj/item/clothing/neck/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "/obj/item/clothing/neck/scarf/darkblue"
	greyscale_colors = "#1E85BC#1E85BC"

/obj/item/clothing/neck/scarf/purple
	name = "purple scarf"
	icon_state = "/obj/item/clothing/neck/scarf/purple"
	greyscale_colors = "#9557C5#9557C5"

/obj/item/clothing/neck/scarf/yellow
	name = "yellow scarf"
	icon_state = "/obj/item/clothing/neck/scarf/yellow"
	greyscale_colors = "#E0C14F#E0C14F"

/obj/item/clothing/neck/scarf/orange
	name = "orange scarf"
	icon_state = "/obj/item/clothing/neck/scarf/orange"
	greyscale_colors = "#C67A4B#C67A4B"

/obj/item/clothing/neck/scarf/cyan
	name = "cyan scarf"
	icon_state = "/obj/item/clothing/neck/scarf/cyan"
	greyscale_colors = "#54A3CE#54A3CE"

/obj/item/clothing/neck/scarf/zebra
	name = "zebra scarf"
	icon_state = "/obj/item/clothing/neck/scarf/zebra"
	greyscale_colors = "#333333#EEEEEE"

/obj/item/clothing/neck/scarf/christmas
	name = "christmas scarf"
	icon_state = "/obj/item/clothing/neck/scarf/christmas"
	greyscale_colors = "#038000#960000"

/obj/item/clothing/neck/large_scarf
	name = "large scarf"
	icon_state = "large_scarf"
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_ASSISTANT * 1.6
	greyscale_config = /datum/greyscale_config/scarf
	greyscale_config_worn = /datum/greyscale_config/scarf/worn
	greyscale_colors = "#C6C6C6#EEEEEE"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/large_scarf/red
	name = "large red scarf"
	icon_state = "/obj/item/clothing/neck/large_scarf/red"
	greyscale_colors = "#8A2908#A06D66"

/obj/item/clothing/neck/large_scarf/green
	name = "large green scarf"
	icon_state = "/obj/item/clothing/neck/large_scarf/green"
	greyscale_colors = "#525629#888674"

/obj/item/clothing/neck/large_scarf/blue
	name = "large blue scarf"
	icon_state = "/obj/item/clothing/neck/large_scarf/blue"
	greyscale_colors = "#20396C#6F7F91"

/obj/item/clothing/neck/large_scarf/chaos
	name = "suspicious looking striped scarf"
	desc = "Ready to operate."
	greyscale_colors = "#255629#51472A"
	armor = list(FIRE = 50, ACID = 40)

/obj/item/clothing/neck/large_scarf/security
	name = "security striped scarf"
	desc = "Ready to protect."
	greyscale_colors = "#CBCCD3#272728"
	armor = list(FIRE = 50, ACID = 40)

/obj/item/clothing/neck/petcollar
	name = "pet collar"
	desc = "It's for pets."
	icon_state = "petcollar"
	fallback_colors = list(list(16, 21), list(16, 19))
	fallback_icon_state = "collar" //Blame (or thank) Kapu
	var/tagname = null

/obj/item/clothing/neck/petcollar/attack_self(mob/user)
	tagname = sanitize_name(tgui_input_text(user, "Would you like to change the name on the tag?", "Pet Naming", "Spot", MAX_NAME_LEN))
	name = "[initial(name)] - [tagname]"

//////////////
//DOPE BLING//
//////////////

/obj/item/clothing/neck/necklace/dope
	name = "gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bling"

/obj/item/clothing/neck/necklace/dope/merchant
	desc = "Don't ask how it works, the proof is in the holochips!"
	/// scales the amount received in case an admin wants to emulate taxes/fees.
	var/profit_scaling = 1
	/// toggles between sell (TRUE) and get price post-fees (FALSE)
	var/selling = FALSE

/obj/item/clothing/neck/necklace/dope/merchant/attack_self(mob/user)
	. = ..()
	selling = !selling
	to_chat(user, span_notice("[src] has been set to [selling ? "'Sell'" : "'Get Price'"] mode."))

/obj/item/clothing/neck/necklace/dope/merchant/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/datum/export_report/ex = export_item_and_contents(I, delete_unsold = selling, dry_run = !selling)
	var/price = 0
	for(var/x in ex.total_amount)
		price += ex.total_value[x]

	if(price)
		var/true_price = round(price*profit_scaling)
		to_chat(user, span_notice("[selling ? "Sold" : "Getting the price of"] [I], value: <b>[true_price]</b> credits[I.contents.len ? " (exportable contents included)" : ""].[profit_scaling < 1 && selling ? "<b>[round(price-true_price)]</b> credit\s taken as processing fee\s." : ""]"))
		if(selling)
			SSeconomy.spawn_ones_for_amount(true_price, get_turf(user))
	else
		to_chat(user, span_warning("There is no export value for [I] or any items within it."))

/obj/item/clothing/neck/beads
	name = "plastic bead necklace"
	desc = "A cheap, plastic bead necklace. Show team spirit! Collect them! Throw them away! The possibilites are endless!"
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "beads"
	color = "#ffffff"
	custom_price = PAYCHECK_ASSISTANT * 0.2
	custom_materials = (list(/datum/material/plastic = 500))

/obj/item/clothing/neck/beads/Initialize(mapload)
	. = ..()
	color = color = pick("#ff0077","#d400ff","#2600ff","#00ccff","#00ff2a","#e5ff00","#ffae00","#ff0000", "#ffffff")

/obj/item/clothing/neck/tie/disco
	name = "horrific necktie"
	icon_state = "eldritch_tie"
	desc = "The necktie is adorned with a garish pattern. It's disturbingly vivid. Somehow you feel as if it would be wrong to ever take it off. It's your friend now. You will betray it if you change it for some boring scarf."
