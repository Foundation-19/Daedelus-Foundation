/obj/item/implant/amnestic
	name = "amnestic implant"
	desc = "A subdermal implant that releases amnestic compounds on remote trigger."
	actions_types = list(/datum/action/item_action/trigger_amnestic)
	var/amnestic_class = "A"
	var/activated = FALSE

/obj/item/implant/amnestic/activate()
	if(activated)
		return
	activated = TRUE
	var/mob/living/carbon/human/H = imp_in
	if(!istype(H))
		return
	switch(amnestic_class)
		if("A")
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15)
			to_chat(H, "<span class='warning'>You feel a sudden haze wash over your mind...</span>")
		if("B")
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)
			to_chat(H, "<span class='warning'>Your memories begin to blur and fade...</span>")
		if("C")
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
			to_chat(H, "<span class='warning'>Everything goes white as your mind is wiped clean...</span>")
		if("E")
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
			to_chat(H, "<span class='notice'>You feel a gentle calm as recent events fade...</span>")
	qdel(src)

/datum/action/item_action/trigger_amnestic
	name = "Trigger Amnestic Implant"

/obj/item/implantcase/amnestic
	name = "amnestic implant case"
	desc = "A glass case containing an amnestic implant."
	imp = /obj/item/implant/amnestic

/obj/item/implant/containment
	name = "containment tracking chip"
	desc = "A subdermal tracking chip used to monitor D-Class and SCP-exposed personnel."
	actions_types = list(/datum/action/item_action/track_containment_chip)

/obj/item/implantcase/containment
	name = "containment chip case"
	desc = "A glass case containing a containment tracking chip."
	imp = /obj/item/implant/containment

/datum/action/item_action/track_containment_chip
	name = "Track Containment Chip"
