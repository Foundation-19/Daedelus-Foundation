/obj/fluid
	name = "fluid"
	desc = "A pool of some liquid."
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	layer = BELOW_MOB_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = UNACIDABLE
	pass_flags = PASSTABLE | PASSGRILLE
	var/datum/fluid_group/group
	var/amt = 0
	var/depth_level = FLUID_DEPTH_SHALLOW
	var/fluid_type = FLUID_TYPE_WATER
	var/viscosity = 1

/obj/fluid/Initialize(mapload, fluid_type, color, viscosity)
	. = ..()
	src.fluid_type = fluid_type || FLUID_TYPE_WATER
	if(color)
		src.color = color
	src.viscosity = viscosity || 1
	update_icon_state()

/obj/fluid/Destroy()
	if(group)
		group.remove_member(src)
	group = null
	return ..()

/obj/fluid/update_icon_state()
	icon_state = "extinguish"
	switch(depth_level)
		if(FLUID_DEPTH_SHALLOW)
			alpha = 100
		if(FLUID_DEPTH_WADE)
			alpha = 150
		if(FLUID_DEPTH_SWIM)
			alpha = 200
		if(FLUID_DEPTH_DROWN)
			alpha = 230

/obj/fluid/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	handle_mob_interaction(L)

/obj/fluid/proc/handle_mob_interaction(mob/living/L)
	if(depth_level >= FLUID_DEPTH_WADE && viscosity > 3)
		L.add_movespeed_modifier(/datum/movespeed_modifier/flesh_corruption)
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/flesh_corruption), 3 SECONDS)

	if(depth_level >= FLUID_DEPTH_SHALLOW && prob(max(0, 50 - viscosity * 5)))
		L.slip(4 SECONDS, src, NO_SLIP_WHEN_WALKING)

	if(group?.fluid_reagents && depth_level >= FLUID_DEPTH_WADE)
		var/react_volume = min(5, group.fluid_reagents.total_volume * 0.01)
		group.fluid_reagents.expose(L, TOUCH, react_volume)

	if(fluid_type == FLUID_TYPE_BIOMASS && ishuman(L))
		var/mob/living/carbon/human/H = L
		if(!HAS_TRAIT(H, TRAIT_SCP610_IMMUNE) && !H.SCP && prob(5))
			scp610_infect(H, 10)

	if(fluid_type == FLUID_TYPE_DECON)
		L.wash(CLEAN_WASH)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.clean_forensic()
