/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	flags_1 = CONDUCT_1

	hitsound = SFX_SWING_HIT
	throw_range = 4
	force = 8
	stamina_cost = 17
	stamina_critical_chance = 10
	stamina_damage = 40

	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	resistance_flags = FLAMMABLE
	max_integrity = 150

	storage_type = /datum/storage/latched_box

	var/folder_path = /obj/item/folder //this is the path of the folder that gets spawned in New()

/obj/item/storage/briefcase/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21

/obj/item/storage/briefcase/PopulateContents()
	new /obj/item/pen(src)
	var/obj/item/folder/folder = new folder_path(src)
	for(var/i in 1 to 6)
		new /obj/item/paper(folder)

/obj/item/storage/briefcase/lawyer
	folder_path = /obj/item/folder/blue

/obj/item/storage/briefcase/lawyer/PopulateContents()
	new /obj/item/stamp/ecl(src)
	..()

/obj/item/storage/briefcase/suicide_act(mob/user)
	var/list/papers_found = list()
	var/turf/item_loc = get_turf(src)

	if(!item_loc)
		return OXYLOSS

	for(var/obj/item/potentially_paper in contents)
		if(istype(potentially_paper, /obj/item/paper) || istype(potentially_paper, /obj/item/paperplane))
			papers_found += potentially_paper
	if(!papers_found.len || !item_loc)
		user.visible_message(span_suicide("[user] bashes [user.p_them()]self in the head with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

	user.visible_message(span_suicide("[user] opens [src] and all of [user.p_their()] papers fly out!"))
	for(var/obj/item/paper as anything in papers_found)	//Throws the papers in a random direction
		var/turf/turf_to_throw_at = prob(20) ? item_loc : get_ranged_target_turf(item_loc, pick(GLOB.alldirs))
		paper.throw_at(turf_to_throw_at, 2)

	sleep(1 SECONDS)
	user.say("ARGGHH, HOW WILL I GET THIS WORK DONE NOW?!!")
	user.visible_message(span_suicide("[user] looks overwhelmed with paperwork! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/briefcase/sniperbundle
	desc = "Its label reads \"genuine hardened Captain leather\", but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniperbundle/PopulateContents()
	..() // in case you need any paperwork done after your rampage
	new /obj/item/gun/ballistic/automatic/sniper_rifle/syndicate(src)
	new /obj/item/clothing/neck/tie/red(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/suppressor/specialoffer(src)

///Secure Briefcase
/obj/item/storage/briefcase/secure
	name = "secure briefcase"
	icon_state = "secure"
	inhand_icon_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	/// icon_state of locked safe
	var/icon_locking = "secureb"
	/// icon_state of sparking safe
	var/icon_sparking = "securespark"
	/// icon_state of opened safe
	var/icon_opened = "secure0"
	/// The code entered by the user
	var/entered_code
	/// The code that will open this safe
	var/lock_code
	/// Does this lock have a code set?
	var/lock_set = FALSE
	/// Is this lock currently being hacked?
	var/lock_hacking = FALSE
	/// Is the safe service panel open?
	var/panel_open = FALSE
	/// Is this door hackable?
	var/can_hack_open = TRUE

/obj/item/storage/briefcase/secure/examine(mob/user)
	. = ..()
	if(can_hack_open)
		. += "The service panel is currently <b>[panel_open ? "unscrewed" : "screwed shut"]</b>."

/obj/item/storage/briefcase/secure/tool_act(mob/living/user, obj/item/tool)
	if(can_hack_open && atom_storage.locked)
		return ..()
	else
		return FALSE

/obj/item/storage/briefcase/secure/wirecutter_act(mob/living/user, obj/item/tool)
	to_chat(user, span_danger("[src] is protected from this sort of tampering, yet it appears the internal memory wires can still be <b>pulsed</b>."))
	return

/obj/item/storage/briefcase/secure/screwdriver_act(mob/living/user, obj/item/tool)
	if(tool.use_tool(src, user, 20))
		panel_open = !panel_open
		to_chat(user, span_notice("You [panel_open ? "open" : "close"] the service panel."))
		return TRUE

/obj/item/storage/briefcase/secure/multitool_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(lock_hacking)
		to_chat(user, span_danger("This safe is already being hacked."))
		return
	if(panel_open == TRUE)
		to_chat(user, span_danger("Now attempting to reset internal memory, please hold."))
		lock_hacking = TRUE
		if (tool.use_tool(src, user, 400))
			to_chat(user, span_danger("Internal memory reset - lock has been disengaged."))
			lock_set = FALSE

		lock_hacking = FALSE
		return

	to_chat(user, span_warning("You must <b>unscrew</b> the service panel before you can pulse the wiring!"))

/obj/item/storage/briefcase/secure/attack_self(mob/user)
	var/locked = atom_storage.locked
	user.set_machine(src)
	var/dat = "<TT><B>[src]</B><BR>\n\nLock Status: [(locked ? "LOCKED" : "UNLOCKED")]"
	var/message = "Code"
	if (lock_set == 0)
		dat += "<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>"
	message = entered_code
	if (!locked)
		message = "*****"
	dat += {"
<HR>\n>[message]<BR>\n<A href='?src=[REF(src)];type=1'>1</A>
-<A href='?src=[REF(src)];type=2'>2</A>
-<A href='?src=[REF(src)];type=3'>3</A><BR>\n
<A href='?src=[REF(src)];type=4'>4</A>
-<A href='?src=[REF(src)];type=5'>5</A>
-<A href='?src=[REF(src)];type=6'>6</A><BR>\n
<A href='?src=[REF(src)];type=7'>7</A>
-<A href='?src=[REF(src)];type=8'>8</A>
-<A href='?src=[REF(src)];type=9'>9</A><BR>\n
<A href='?src=[REF(src)];type=R'>R</A>
-<A href='?src=[REF(src)];type=0'>0</A>
-<A href='?src=[REF(src)];type=E'>E</A><BR>\n</TT>"}

	var/datum/browser/browser = new(user, "caselock", "[name]", 300, 280)
	browser.set_content(dat)
	browser.open()

/obj/item/storage/briefcase/secure/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/briefcase/secure/Initialize()
	. = ..()
	atom_storage.max_total_storage = 21
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

///Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/briefcase/secure/syndie
	force = 15

/obj/item/storage/briefcase/secure/syndie/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/stack/spacecash/c1000(src)
