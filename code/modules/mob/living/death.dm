/**
 * Blow up the mob into giblets
 *
 * Arguments:
 * * no_brain - Should the mob NOT drop a brain?
 * * no_organs - Should the mob NOT drop organs?
 * * no_bodyparts - Should the mob NOT drop bodyparts?
*/
/mob/living/proc/gib(no_brain, no_organs, no_bodyparts)
	var/prev_lying = lying_angle
	if(stat != DEAD)
		death(TRUE)

	if(!prev_lying)
		gib_animation()

	spill_organs(no_brain, no_organs, no_bodyparts)

	if(!no_bodyparts)
		spread_bodyparts(no_brain, no_organs)

	spawn_gibs(no_bodyparts)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/mob/living/proc/spawn_gibs()
	new /obj/effect/gibspawner/generic(drop_location(), src, get_static_viruses())

/mob/living/proc/spill_organs()
	return

/mob/living/proc/spread_bodyparts()
	return

/**
 * This is the proc for turning a mob into ash.
 * Dusting robots does not eject the MMI, so it's a bit more powerful than gib()
 *
 * Arguments:
 * * just_ash - If TRUE, ash will spawn where the mob was, as opposed to remains
 * * drop_items - Should the mob drop their items before dusting?
 * * force - Should this mob be FORCABLY dusted?
*/
/mob/living/proc/dust(just_ash, drop_items, force)
	death(TRUE)

	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	dust_animation()
	spawn_dust(just_ash)
	QDEL_IN(src,5) // since this is sometimes called in the middle of movement, allow half a second for movement to finish, ghosting to happen and animation to play. Looks much nicer and doesn't cause multiple runtimes.

/mob/living/proc/dust_animation()
	return

/mob/living/proc/spawn_dust(just_ash = FALSE)
	new /obj/effect/decal/cleanable/ash(loc)

/*
 * Called when the mob dies. Can also be called manually to kill a mob.
 *
 * Arguments:
 * * gibbed - Was the mob gibbed?
 * * cod (cause of death) - A string that plainly describes how the mob died.
*/
/mob/living/proc/death(gibbed, cause_of_death = "Unknown")
	set_stat(DEAD)
	unset_machine()

	died_as_name = name
	timeofdeath = world.time
	timeofdeath_as_ingame = stationtime2text()

	var/turf/T = get_turf(src)

	var/list/death_message = list(
		"<div style='background: #0a0a0c; border: 2px solid #8b0000; padding: 12px; margin: 8px 0; font-family: Consolas, Courier New, monospace; text-align: center;'>",
		"<div style='color: #8b0000; font-size: 24px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.2em; text-shadow: 0 0 0.5em #8b0000;'>// CONNECTION TERMINATED //</div>",
		"<hr style='border: 1px solid #2a2a30; margin: 8px 0;'>",
		"<div style='color: #cc4444; font-size: 16px;'>CAUSE OF DEATH: <span style='color: #d4a017'>[cause_of_death]</span></div>",
		"<div style='color: #6a6a70; font-size: 11px; margin-top: 4px;'>TIME: [stationtime2text()] | LOCATION: [get_area_name(T, TRUE)]</div>",
		"<hr style='border: 1px solid #2a2a30; margin: 8px 0;'>",
		"<div style='color: #6a6a70; font-size: 11px;'>Resuscitation possible if brain intact and death time &lt; 10 minutes.</div>",
	)

	if(ishuman(src))
		death_message += "<div style='margin-top: 6px;'>[button_element(src, "// VIEW TERMIN STATS //", "show_death_stats=1")]</div>"
		var/mob/living/carbon/human/H = src
		H.time_of_death_stats = H.get_bodyscanner_data()

	death_message += "</div>"

	death_message = jointext(death_message, "")
	to_chat(src, death_message)

	playsound_local(src, 'goon/sounds/revfocus.ogg', 50, vary = FALSE, pressure_affected = FALSE)

	if(mind && mind.name && mind.active)
		if(!istype(T.loc, /area/centcom/ctf))
			deadchat_broadcast(" has died at <b>[get_area_name(T)]</b>.", "<b>[mind.name]</b>", follow_target = src, turf_target = T, message_type=DEADCHAT_DEATHRATTLE)

		if(SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] && !client?.holder)
			to_chat(src, span_deadsay(span_big("Observer freelook is disabled.\nPlease use Orbit, Teleport, and Jump to look around.")))
			ghostize(TRUE)

	set_disgust(0)
	SetSleeping(0, 0)

	reset_perspective(null)
	reload_fullscreen()
	update_mob_action_buttons()
	update_damage_hud()
	update_health_hud()
	update_med_hud()

	release_all_grabs()

	set_typing_indicator(FALSE)

	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src, gibbed)

	if (client)
		client.move_delay = initial(client.move_delay)

	if(!gibbed && !QDELETED(src))
		AddComponent(/datum/component/spook_factor, SPOOK_AMT_CORPSE)
	return TRUE
