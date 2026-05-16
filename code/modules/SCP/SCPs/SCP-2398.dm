/obj/item/material/twohanded/baseballbat/scp2398
	name = "wooden bat"
	desc = "A generic wooden bat. The letters 'K.O.' are branded into the wood, just above the handle."
	icon = 'icons/scp/scp-2398.dmi'
	icon_state = null
	var/swing_time = 4 SECONDS
	var/explosion_power = 3
	var/hand_fracture_chance = 75

/obj/item/material/twohanded/baseballbat/scp2398/Initialize()
	. = ..()
	SCP = new /datum/scp(src, "wooden bat", SCP_SAFE, "2398")
/obj/item/material/twohanded/baseballbat/scp2398/attack(mob/living/M, mob/living/carbon/human/user, target_zone, animate)
	if(!M || !user)
		return

	// Check if user is holding the bat with both hands
	if(!user.is_holding(src))
		to_chat(user, "<span class='danger'>You need both hands to swing this bat!</span>")
		return

	if(!do_after(user, swing_time))
		to_chat(user, "<span class='danger'>You were interrupted!</span>")
		return

	hook_scp_interaction(user, "SCP-2398", "bat_swing_attempt")

	// Damage user's hands
	if(prob(hand_fracture_chance))
		user.adjustBruteLoss(10)
		to_chat(user, "<span class='danger'>The force of the swing damages your hands!</span>")

	// Calculate explosion size based on target size
	var/explosion_size = max(1, min(5, round(M.mob_size / 20)))

	// Explosion effect
	explosion(get_turf(M), explosion_size * 0.5, explosion_size, explosion_size * 1.5, explosion_size * 2, TRUE)

	// Gib the target
	if(M)
		hook_scp_combat(user, "SCP-2398", 0, 100)
		M.gib()

	hook_scp_interaction(user, "SCP-2398", "bat_swing_complete")
	// Admin logging
	to_chat(user, "<span class='notice'>You swing the bat with incredible force!</span>")

/obj/item/material/twohanded/baseballbat/scp2398/ex_act(severity) //We shouldent explode ourselves as a result
	return
