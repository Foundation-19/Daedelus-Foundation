/obj/item/stamp
	name = "\improper GRANTED rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	inhand_icon_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 0.6
	throw_range = 7
	custom_materials = list(/datum/material/iron=60)
	//pressure_resistance = 2
	attack_verb_continuous = list("stamps")
	attack_verb_simple = list("stamp")

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead."))
	return (OXYLOSS)

/obj/item/stamp/sid
	name = "site director's rubber stamp"
	icon_state = "stamp-sid"
	dye_color = DYE_CAPTAIN

/obj/item/stamp/sm
	name = "human resources officer's rubber stamp"
	icon_state = "stamp-sm"
	dye_color = DYE_HOP

/obj/item/stamp/sc
	name = "security captain's rubber stamp"
	icon_state = "stamp-sc"
	dye_color = DYE_HOS

/obj/item/stamp/ed
	name = "engineering director's rubber stamp"
	icon_state = "stamp-ed"
	dye_color = DYE_CE

/obj/item/stamp/sd
	name = "science director's rubber stamp"
	icon_state = "stamp-sd"
	dye_color = DYE_RD

/obj/item/stamp/md
	name = "medical director's rubber stamp"
	icon_state = "stamp-md"
	dye_color = DYE_CMO

/obj/item/stamp/lo
	name = "logistics officer's rubber stamp"
	icon_state = "stamp-lo"
	dye_color = DYE_QM

/obj/item/stamp/goc
	name = "Global Occult Coalition rubber stamp"
	icon_state = "stamp-goc"
	dye_color = DYE_BLUE

/obj/item/stamp/uiu
	name = "Unusual Incidents Unit rubber stamp"
	icon_state = "stamp-uiu"
	dye_color = DYE_GREEN

/obj/item/stamp/ecl
	name = "ethics committee liaison's rubber stamp"
	icon_state = "stamp-ec"
	dye_color = DYE_LAW

/obj/item/stamp/itdo
	name = "internal tribunal department officer's rubber stamp"
	icon_state = "stamp-itd"
	dye_color = DYE_PURPLE

/obj/item/stamp/lcz_security
	name = "LCZ security rubber stamp"
	icon_state = "stamp-lcz"
	dye_color = DYE_YELLOW

/obj/item/stamp/admin_security
	name = "Administrative security rubber stamp"
	icon_state = "stamp-az"
	dye_color = DYE_BLUE

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	dye_color = DYE_REDCOAT

/obj/item/stamp/clown
	name = "morale officer's rubber stamp"
	icon_state = "stamp-clown"
	dye_color = DYE_CLOWN

/obj/item/stamp/mime
	name = "mime's rubber stamp"
	icon_state = "stamp-mime"
	dye_color = DYE_MIME

/obj/item/stamp/chap
	name = "chaplain's rubber stamp"
	icon_state = "stamp-chap"
	dye_color = DYE_CHAP

/obj/item/stamp/o5_council
	name = "O5 Council rubber stamp"
	icon_state = "stamp-centcom"
	dye_color = DYE_CENTCOM

/obj/item/stamp/chaos
	name = "Chaos Insurgency rubber stamp"
	icon_state = "stamp-syndicate"
	dye_color = DYE_SYNDICATE

/obj/item/stamp/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)
