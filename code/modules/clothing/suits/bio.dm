//Biosuit complete with shoes (in the item sprite)
/obj/item/clothing/head/bio_hood
	name = "bio hood"
	desc = "A hood that protects the head and face from biological contaminants."
	icon = 'icons/obj/clothing/head/bio.dmi'
	worn_icon = 'icons/mob/clothing/head/bio.dmi'
	icon_state = "bio"
	inhand_icon_state = "bio_hood"
	permeability_coefficient = 0.01
	clothing_flags = THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT | SNUG_FIT | STACKABLE_HELMET_EXEMPT | HEADINTERNALS | FIBERLESS
	armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 30, ACID = 100)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT
	resistance_flags = ACID_PROOF
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon = 'icons/obj/clothing/suits/bio.dmi'
	worn_icon = 'icons/mob/clothing/suits/bio.dmi'
	icon_state = "bio"
	inhand_icon_state = "bio_suit"
	w_class = WEIGHT_CLASS_BULKY
	permeability_coefficient = 0.01
	clothing_flags = THICKMATERIAL | FIBERLESS
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 0.5
	allowed = list(/obj/item/tank/internals, /obj/item/reagent_containers/dropper, /obj/item/flashlight/pen, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/glass/beaker, /obj/item/gun/syringe)
	armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 30, ACID = 100)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = ACID_PROOF
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

//Standard biosuit, orange stripe
/obj/item/clothing/head/bio_hood/general
	name = "medical bio hood"
	desc = "A hood that protects the head and face from biological contaminants, this one is painted for the Medical Department."
	icon_state = "bio_general"

/obj/item/clothing/suit/bio_suit/general
	name = "medical bio suit"
	desc = "A suit that protects against biological contamination, this one is painted for the Medical Department."
	icon_state = "bio_general"


//Virology biosuit, green stripe
/obj/item/clothing/head/bio_hood/virology
	name = "virology bio hood"
	desc = "A hood that protects the head and face from biological contaminants, this one is painted for Virological use."
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	name = "virology bio suit"
	desc = "A suit that protects against biological contamination, this one is painted for Virological use."
	icon_state = "bio_virology"


//Security biosuit, grey with red stripe across the chest
/obj/item/clothing/head/bio_hood/security
	name = "security bio hood"
	desc = "A hood that protects the head and face from biological contaminants, this one is painted for the Security Department, pretty heavily padded with armor."
	armor = list(BLUNT = 25, PUNCTURE = 15, SLASH = 0, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 100, FIRE = 30, ACID = 100)
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security
	name = "security bio suit"
	desc = "A suit that protects against biological contamination, this one is painted for the Security Department, it's dawned with a vest for optimal protection both pathogen-wise, and defense-wise."
	armor = list(BLUNT = 25, PUNCTURE = 15, SLASH = 0, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 100, FIRE = 30, ACID = 100)
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_vest_allowed

//Janitor's biosuit, grey with purple arms
/obj/item/clothing/head/bio_hood/janitor
	name = "janitor bio hood"
	desc = "A hood that protects the head and face from biological contaminants, this one is painted for custodial use."
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	name = "janitor bio suit"
	desc = "A suit that protects against biological contamination, this one is painted for custodial use."
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor/Initialize(mapload)
	. = ..()
	allowed += list(/obj/item/storage/bag/trash, /obj/item/reagent_containers/spray)

//Class-D's biosuit, orange with grey stripes
/obj/item/clothing/head/bio_hood/classd
	name = "Class-D bio hood"
	desc = "A hood that protects the head and face from biological contaminants, this one is painted for the Class-D."
	icon_state = "bio_classd"

/obj/item/clothing/suit/bio_suit/classd
	name = "Class-D bio suit"
	desc = "A suit that protects against biological contamination, this one is painted for the Class-D."
	icon_state = "bio_classd"

/obj/item/clothing/suit/bio_suit/classd/Initialize(mapload)
	. = ..()
	allowed += list(/obj/item/storage/bag/trash, /obj/item/reagent_containers/spray)

//Scientist's biosuit, white with a pink-ish hue
/obj/item/clothing/head/bio_hood/scientist
	name = "scientist bio hood"
	desc = "A hood that protects the head and face from biological contaminants, this one is painted for the Science Department."
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	name = "scientist bio suit"
	desc = "A suit that protects against biological contamination, this one is painted for the Science Department."
	icon_state = "bio_scientist"

//CMO's biosuit, blue stripe
/obj/item/clothing/head/bio_hood/cmo
	name = "medical director's bio hood"
	desc = "A hood that protects the head and face from biological contaminants, this one is painted for the Medical Department's head officer."
	icon_state = "bio_cmo"

/obj/item/clothing/suit/bio_suit/cmo
	name = "medical director's bio suit"
	desc = "A suit that protects against biological contamination, this one is painted for the Medical Department's head officer."
	icon_state = "bio_cmo"

/obj/item/clothing/suit/bio_suit/cmo/Initialize(mapload)
	. = ..()
	allowed += /obj/item/assembly/flash/handheld

//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	inhand_icon_state = "bio_suit"
	strip_delay = 40
	equip_delay_other = 20
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/bio_suit/plaguedoctorsuit/Initialize(mapload)
	. = ..()
	allowed += list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/cane)
