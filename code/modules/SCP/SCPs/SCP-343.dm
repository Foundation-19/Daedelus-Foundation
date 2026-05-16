/mob/living/scp/scp343
	name = "SCP-343"
	desc = "An elderly man who claims to be God. He radiates an aura of divine power and benevolence."
	icon = 'icons/scp/scp-343.dmi'
	icon_state = "scp343"
	real_name = "SCP-343"

	var/divine_energy = 100
	var/max_divine_energy = 100
	var/comfort_range = 5
	var/divine_zone_cooldown = 0
	var/divine_heal_cooldown = 0

/mob/living/scp/scp343/Initialize()
	. = ..()

	set_species(/datum/species/scp343)

	SCP = new /datum/scp(src, "God", SCP_SAFE, "343", SCP_PLAYABLE)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	START_PROCESSING(SSobj, src)


/mob/living/scp/scp343/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/scp/scp343/process()
	. = ..()

	if(stat == DEAD)
		return

	update_divine_presence()
	passive_healing_aura()

	if(divine_energy < max_divine_energy)
		divine_energy = min(max_divine_energy, divine_energy + 1)

/mob/living/scp/scp343/proc/update_divine_presence()
	if(prob(5))
		var/obj/effect/temp_visual/divine_presence/presence = new(loc)
		presence.color = "#FFD700"

/mob/living/scp/scp343/proc/passive_healing_aura()
	for(var/mob/living/carbon/human/H in range(comfort_range, src))
		if(H == src || H.SCP)
			continue

		if(H.sanity)
			H.sanity.adjust_sanity(2, "scp343_presence")

		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-1)
			H.adjustFireLoss(-1)

/mob/living/scp/scp343/proc/divine_heal_ability(mob/living/carbon/human/target)
	if(!target || target == src)
		return

	if(world.time < divine_heal_cooldown)
		to_chat(src, "<span class='warning'>You need to wait before healing again.</span>")
		return

	if(divine_energy < 30)
		to_chat(src, "<span class='warning'>Not enough divine energy.</span>")
		return

	divine_heal_cooldown = world.time + 30 SECONDS
	divine_energy -= 30

	target.adjustBruteLoss(-50)
	target.adjustFireLoss(-50)
	target.adjustToxLoss(-25)
	if(target.sanity)
		target.sanity.adjust_sanity(25, "scp343_healing")

	visible_message("<span class='notice'>[src] channels divine energy, healing [target]!</span>")

	on_divine_healing(target)

/mob/living/scp/scp343/proc/divine_zone_ability()
	if(world.time < divine_zone_cooldown)
		to_chat(src, "<span class='warning'>You need to wait before creating another divine zone.</span>")
		return

	if(divine_energy < 50)
		to_chat(src, "<span class='warning'>Not enough divine energy.</span>")
		return

	divine_zone_cooldown = world.time + 60 SECONDS
	divine_energy -= 50

	var/turf/T = get_turf(src)
	new /obj/effect/divine_zone(T)

	visible_message("<span class='notice'>[src] creates a divine zone of healing!</span>")

	for(var/mob/living/carbon/human/H in range(comfort_range, src))
		if(H != src && !H.SCP)
			on_divine_protection(H)

/mob/living/scp/scp343/proc/divine_heal_verb()
	var/mob/living/carbon/human/target = null
	for(var/mob/living/carbon/human/H in range(2, src))
		if(H != src && H.stat != DEAD)
			target = H
			break

	if(!target)
		to_chat(src, "<span class='warning'>No valid targets nearby.</span>")
		return

	divine_heal_ability(target)

/mob/living/scp/scp343/proc/divine_zone_verb()
	divine_zone_ability()

/mob/living/scp/scp343/examine(mob/user)
	. = ..()

	if(user == src)
		. += "<span class='notice'>You radiate divine power and benevolence.</span>"
		. += "<span class='notice'>Divine Energy: [divine_energy]/[max_divine_energy]</span>"
	else
		. += "<span class='notice'>This elderly man radiates an aura of divine power and benevolence.</span>"
		. += "<span class='notice'>You feel a sense of peace and protection in his presence.</span>"

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.sanity)
				H.sanity.adjust_sanity(5, "scp343_examine")
				. += "<span class='notice'>His presence soothes your mind.</span>"

/mob/living/scp/scp343/proc/on_divine_protection(mob/living/carbon/human/protected)
	if(!protected)
		return
	hook_scp_care(protected, "SCP-343", "protection")

/mob/living/scp/scp343/proc/on_divine_healing(mob/living/carbon/human/healed)
	if(!healed)
		return
	hook_scp_care(healed, "SCP-343", "healing")

/obj/effect/temp_visual/divine_presence
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparkles"
	duration = 20
	color = "#FFD700"

/obj/effect/divine_zone
	name = "divine zone"
	desc = "An area radiating divine comfort and healing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield"
	color = "#FFD700"
	anchored = TRUE
	var/duration = 30 SECONDS
	var/heal_amount = 5
	var/sanity_amount = 5

/obj/effect/divine_zone/Initialize()
	. = ..()
	QDEL_IN(src, duration)
	START_PROCESSING(SSobj, src)

/obj/effect/divine_zone/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/divine_zone/process()
	for(var/mob/living/carbon/human/H in range(3, src))
		if(H.SCP)
			continue
		if(H.health < H.maxHealth)
			H.adjustBruteLoss(-heal_amount)
			H.adjustFireLoss(-heal_amount)
		if(H.sanity)
			H.sanity.adjust_sanity(sanity_amount, "scp343_divine_zone")
