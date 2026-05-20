/obj/item/dclass_contraband/lockpick/improvised
	name = "improvised lockpick"
	desc = "A crude but functional lockpick fashioned from wire."
	icon_state = "lockpick"
	force = 3
	var/lockpick_chance = 35

/obj/item/dclass_contraband/lockpick/improvised/attack_self(mob/user)
	to_chat(user, span_notice("You examine the lockpick. It has a [lockpick_chance]% chance of success on standard locks."))

/obj/item/dclass_contraband/improvised_tool
	contraband_key = "improvised_tool"
	name = "improvised tool"
	desc = "A multi-purpose tool cobbled together from wire and pipe. Ugly but functional."
	icon_state = "screwdriver"
	force = 8
	var/tool_efficiency = 0.6

/obj/item/dclass_contraband/improvised_tool/examine(mob/user)
	. = ..()
	. += span_notice("Works at [tool_efficiency * 100]% efficiency compared to standard tools.")

/obj/item/dclass_contraband/disguise_kit
	contraband_key = "disguise_kit"
	name = "improvised disguise kit"
	desc = "A hastily assembled kit for altering one's appearance. Not very convincing up close."
	icon_state = "id"
	var/disguise_quality = 30
	uses = 3

/obj/item/dclass_contraband/disguise_kit/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(uses <= 0)
		to_chat(user, span_warning("The disguise kit is spent."))
		return
	uses--
	var/mob/living/carbon/human/H = user
	var/datum/dclass_player/player = SSdclass?.manager?.get_dclass_player(H.ckey)
	if(player)
		player.increase_suspicion(8)
	to_chat(H, span_notice("You quickly alter your appearance. Disguise quality: [disguise_quality]%. [uses] uses remaining."))

/obj/item/dclass_contraband/tourniquet
	contraband_key = "tourniquet"
	name = "improvised tourniquet"
	desc = "A strip of fabric and cord that can stop bleeding in an emergency."
	icon_state = "tourniquet"
	var/heal_amount = 15

/obj/item/dclass_contraband/tourniquet/attack(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(H.stat == DEAD)
		to_chat(user, span_warning("It's too late for [H]."))
		return
	H.adjustBruteLoss(-heal_amount)
	H.visible_message(span_notice("[user] applies a tourniquet to [H]."), span_notice("You apply a tourniquet to [H]."))
	qdel(src)

/obj/item/dclass_contraband/restraint_cutter
	contraband_key = "restraint_cutter"
	name = "improvised restraint cutter"
	desc = "A sharpened piece of wire that can cut through restraints."
	icon_state = "wirecutters"
	force = 5
	var/cut_chance = 50

/obj/item/dclass_contraband/restraint_cutter/attack(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(!H.handcuffed)
		to_chat(user, span_warning("[H] is not restrained."))
		return
	if(prob(cut_chance))
		H.clear_cuffs(H.handcuffed)
		H.visible_message(span_notice("[user] cuts [H]'s restraints!"), span_notice("Your restraints are cut!"))
	else
		to_chat(user, span_warning("The cutter slips! The restraints hold."))

/obj/item/grenade/empgrenade/improvised
	name = "improvised EMP device"
	desc = "A crude electromagnetic pulse device. Unreliable but effective."
	icon_state = "emp"
	var/emp_range = 3

/obj/item/grenade/empgrenade/improvised/detonate(mob/living/lanced_by)
	empulse(src, emp_range, emp_range)
	qdel(src)

/obj/item/grenade/smokebomb/improvised
	name = "improvised smoke bomb"
	desc = "A homemade smoke bomb. Shorter duration than commercial models."
	icon_state = "smoke"
	var/smoke_radius = 3

/obj/item/grenade/smokebomb/improvised/detonate(mob/living/lanced_by)
	var/datum/effect_system/fluid_spread/smoke/S = new
	S.set_up(smoke_radius, src)
	S.start()
	qdel(src)

/obj/item/flashlight/flare/improvised
	name = "improvised signal flare"
	desc = "A homemade flare. Burns bright but short."
	icon_state = "flare"
	light_outer_range = 5
	light_power = 2

/obj/item/stack/medical/gauze/improvised
	name = "improvised bandage"
	desc = "Strips of fabric that can be wrapped around wounds. Not sterile."
	singular_name = "improvised bandage"
	heal_brute = 5
	amount = 3
	max_amount = 3

/obj/item/clothing/suit/makeshift_armor
	name = "makeshift armor"
	desc = "Metal pipes and scraps tied together with fabric. Crude but better than nothing."
	icon_state = "armor"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list(BLUNT = 20, PUNCTURE = 10, SLASH = 25, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 0, ACID = 0)
	slowdown = 0.5

/obj/item/clothing/suit/makeshift_armor/Initialize()
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(M.ckey && SSdclass?.manager)
			var/datum/dclass_player/player = SSdclass.manager.get_dclass_player(M.ckey)
			if(player)
				player.add_contraband("makeshift_armor")

/obj/item/dclass_contraband/poison_shiv
	contraband_key = "poison_shiv"
	name = "poisoned shiv"
	desc = "A crude blade coated with toxic chemicals. A wound from this will fester."
	icon_state = "knife"
	force = 10
	var/poison_reagent = /datum/reagent/toxin
	var/poison_amount = 5

/obj/item/dclass_contraband/poison_shiv/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(H.reagents)
		H.reagents.add_reagent(poison_reagent, poison_amount)
		to_chat(H, span_warning("You feel a burning sensation at the wound!"))

/obj/item/dclass_contraband/stimulant_syringe
	contraband_key = "stimulant"
	name = "improvised stimulant"
	desc = "A syringe filled with a cocktail of chemicals. Provides a brief burst of energy."
	icon_state = "syringe"
	force = 3
	uses = 1
	var/stim_reagent = /datum/reagent/medicine/epinephrine
	var/stim_amount = 10
	var/stim_duration = 30 SECONDS

/obj/item/dclass_contraband/stimulant_syringe/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(uses <= 0)
		to_chat(user, span_warning("The syringe is empty."))
		return
	uses--
	var/mob/living/carbon/human/H = user
	if(H.reagents)
		H.reagents.add_reagent(stim_reagent, stim_amount)
	if(H.stamina)
		H.stamina.adjust(-50)
	to_chat(H, span_notice("You inject the stimulant! You feel a surge of energy!"))
	addtimer(CALLBACK(H, /mob/living/carbon/human.proc/adjustToxLoss, 10), stim_duration)
	if(uses <= 0)
		qdel(src)

/obj/item/dclass_contraband/grapple_hook
	contraband_key = "grapple_hook"
	name = "improvised grapple"
	desc = "A bent pipe tied to a length of cord. Can pull you to distant locations."
	icon_state = "grapple"
	force = 5
	var/grapple_range = 5
	var/grapple_cooldown = 0
	var/grapple_cooldown_time = 15 SECONDS

/obj/item/dclass_contraband/grapple_hook/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(world.time < grapple_cooldown)
		to_chat(user, span_warning("The grapple is still reeling in."))
		return
	var/mob/living/carbon/human/H = user
	var/list/targets = list()
	for(var/turf/open/T in view(grapple_range, H))
		if(!T.density && get_dist(H, T) > 2)
			targets += T
	if(!length(targets))
		to_chat(H, span_warning("No valid grapple targets in range."))
		return
	grapple_cooldown = world.time + grapple_cooldown_time
	var/turf/target = pick(targets)
	H.visible_message(span_notice("[H] fires the grapple hook!"))
	H.throw_at(target, grapple_range, 2)

/obj/item/dclass_contraband/noise_maker
	contraband_key = "noise_maker"
	name = "noise maker"
	desc = "Utensils tied to a cord that rattle loudly when pulled. Good for distractions."
	icon_state = "noisemaker"
	force = 2
	uses = 3

/obj/item/dclass_contraband/noise_maker/attack_self(mob/user)
	if(uses <= 0)
		to_chat(user, span_warning("The noise maker is broken."))
		return
	uses--
	playsound(src, 'sound/effects/clownstep2.ogg', 80, FALSE)
	visible_message(span_warning("[src] rattles and clanks loudly!"))
	for(var/mob/living/M in hearers(7, src))
		if(M != user)
			M.emote("looks")
	if(uses <= 0)
		qdel(src)

/obj/item/dclass_contraband/skeleton_key
	contraband_key = "skeleton_key"
	name = "skeleton key"
	desc = "A carefully filed key that can open many standard locks. High success rate but fragile."
	icon_state = "key"
	force = 3
	uses = 4
	var/lockpick_chance = 70

/obj/item/dclass_contraband/skeleton_key/attack_self(mob/user)
	to_chat(user, span_notice("You examine the skeleton key. [uses] uses remaining. [lockpick_chance]% success rate."))

/obj/item/dclass_contraband/skeleton_key/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(uses <= 0)
		to_chat(user, span_warning("The skeleton key is too worn to use."))
		qdel(src)
		return
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		uses--
		if(prob(lockpick_chance))
			A.open()
			user.visible_message(span_warning("[user] picks [A] open with a key!"), span_notice("The lock clicks open!"))
		else
			to_chat(user, span_warning("The key doesn't turn. The lock holds."))
			if(prob(20))
				to_chat(user, span_warning("The key bends slightly — it's weakening."))
				lockpick_chance -= 5

/obj/item/dclass_contraband/improvised_medkit
	contraband_key = "improvised_medkit"
	name = "improvised medical kit"
	desc = "A bundle of medical supplies scavenged from around the facility. Better than nothing."
	icon_state = "medkit"
	force = 3
	uses = 4
	var/heal_brute = 8
	var/heal_tox = 4

/obj/item/dclass_contraband/improvised_medkit/attack(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return
	if(uses <= 0)
		to_chat(user, span_warning("The medical kit is empty."))
		return
	var/mob/living/carbon/human/H = target
	if(H.stat == DEAD)
		to_chat(user, span_warning("It's too late for [H]."))
		return
	uses--
	H.adjustBruteLoss(-heal_brute)
	H.adjustToxLoss(-heal_tox)
	H.visible_message(span_notice("[user] treats [H] with a medical kit."), span_notice("You treat [H]'s injuries."))
	if(uses <= 0)
		qdel(src)

/obj/item/dclass_contraband/bolas
	contraband_key = "bolas"
	name = "improvised bolas"
	desc = "Weighted cords thrown to entangle legs. Slows targets significantly."
	icon_state = "bolas"
	force = 5
	var/entangle_chance = 55
	var/slow_duration = 8 SECONDS

/obj/item/dclass_contraband/bolas/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(prob(entangle_chance))
			L.Immobilize(slow_duration)
			L.visible_message(span_warning("[L] is entangled by the bolas!"), span_warning("The bolas wrap around your legs!"))
		else
			L.visible_message(span_notice("The bolas miss [L]!"))
		qdel(src)

/obj/item/grenade/ied/improvised
	name = "improvised explosive device"
	desc = "A pipe packed with volatile chemicals. Devastating but unstable."
	icon_state = "ied"
	var/ied_range = 3
	var/ied_brute = 45

/obj/item/grenade/ied/improvised/detonate(mob/living/lanced_by)
	explosion(src, light_impact_range = ied_range, flash_range = ied_range)
	for(var/mob/living/L in view(ied_range, src))
		L.adjustBruteLoss(ied_brute * (1 - (get_dist(L, src) / ied_range * 0.5)))
	qdel(src)

/obj/item/grenade/acid/improvised
	name = "improvised acid bomb"
	desc = "A container of corrosive chemicals that sprays on impact. Melts through light materials."
	icon_state = "acid"
	var/acid_range = 2

/obj/item/grenade/acid/improvised/detonate(mob/living/lanced_by)
	for(var/mob/living/L in view(acid_range, src))
		L.acid_act(30, 10)
	for(var/obj/structure/S in view(acid_range, src))
		S.acid_act(15, 5)
	qdel(src)

/obj/item/grenade/flashbang/improvised
	name = "improvised flashbang"
	desc = "A chemical flash charge wrapped in fabric. Disorients but less effective than standard issue."
	icon_state = "flashbang"
	var/flash_range = 5

/obj/item/grenade/flashbang/improvised/detonate(mob/living/lanced_by)
	for(var/mob/living/L in view(flash_range, src))
		if(L.stat == DEAD)
			continue
		L.flash_act()
		L.Knockdown(1 SECONDS)
		L.set_drugginess(20)
	qdel(src)
