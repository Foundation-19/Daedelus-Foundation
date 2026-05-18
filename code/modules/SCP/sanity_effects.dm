// Sanity Visual & Behavioral Effects System
// Integrates with the core sanity system to provide immersive feedback

// ── Visual Effect Defines ──

#define SANITY_VFX_UPDATE_INTERVAL 2 SECONDS

#define SANITY_VFX_COLOR_DISTORTION "color_distortion"
#define SANITY_VFX_BLUR "blur"
#define SANITY_VFX_VIGNETTE "vignette"
#define SANITY_VFX_JITTER "jitter"
#define SANITY_VFX_WAVE "wave"
#define SANITY_VFX_STATIC "static"

// ── Behavioral Effect Defines ──

#define SANITY_BEHAVIOR_SCREAM "scream"
#define SANITY_BEHAVIOR_DROP "drop_item"
#define SANITY_BEHAVIOR_FLEE "flee"
#define SANITY_BEHAVIOR_FREEZE "freeze"
#define SANITY_BEHAVIOR_STAGGER "stagger"
#define SANITY_BEHAVIOR_HALLUCINATE "hallucinate"

// ── Panic Attack / Episode Defines ──

#define EPISODE_PANIC "panic_attack"
#define EPISODE_DISSOCIATIVE "dissociative_episode"
#define EPISODE_FLASHBACK "flashback"
#define EPISODE_CATATONIC "catatonic_state"

/datum/sanity
	var/last_vfx_update = 0
	var/list/active_vfx = list()
	var/list/active_fake_mobs = list()
	var/behavior_cooldown = 0
	var/episode_active = FALSE
	var/episode_type = ""
	var/episode_end_time = 0
	var/last_episode_time = 0
	var/next_hallucination_mob_time = 0
	var/job_sanity_profile = SANITY_PROFILE_DEFAULT
	var/conditioning_resistance = 0
	var/memetic_vulnerability = 1.0
	var/combat_stress_resistance = 0
	var/medical_horror_resistance = 0
	var/isolation_tolerance = 1.0

/datum/sanity/proc/update_visual_effects()
	if(world.time < last_vfx_update + SANITY_VFX_UPDATE_INTERVAL)
		return
	last_vfx_update = world.time

	if(!owner || !owner.client)
		return

	var/atom/movable/plane_master_controller/game/pmc = owner.hud_used?.plane_master_controllers?[PLANE_MASTERS_GAME]
	if(!pmc)
		return

	var/severity = (max_sanity - sanity_level) / max_sanity

	update_color_distortion(pmc, severity)
	update_blur_effect(pmc, severity)
	update_vignette_effect(severity)
	update_jitter_effect(severity)
	update_wave_effect(pmc, severity)
	update_static_effect(severity)
	update_fake_mobs(severity)

/datum/sanity/proc/update_color_distortion(atom/movable/plane_master_controller/game/pmc, severity)
	if(severity < 0.3)
		pmc.remove_filter("sanity_color_distortion")
		remove_vfx(SANITY_VFX_COLOR_DISTORTION)
		return

	add_vfx(SANITY_VFX_COLOR_DISTORTION)

	var/saturation = 1.0 - (severity - 0.3) * 0.8
	saturation = clamp(saturation, 0.2, 1.0)

	var/list/matrix = color_matrix_saturation(saturation)

	if(severity > 0.7)
		var/hue_shift = (severity - 0.7) * 30
		matrix = color_matrix_multiply(matrix, color_matrix_rotate_hue(hue_shift))

	pmc.add_filter("sanity_color_distortion", 10, color_matrix_filter(matrix, FILTER_COLOR_RGB))

/datum/sanity/proc/update_blur_effect(atom/movable/plane_master_controller/game/pmc, severity)
	if(severity < 0.5)
		pmc.remove_filter("sanity_blur")
		owner.clear_fullscreen("sanity_dither")
		remove_vfx(SANITY_VFX_BLUR)
		return

	add_vfx(SANITY_VFX_BLUR)

	var/blur_amount = clamp((severity - 0.5) * 6, 0.6, 3.0)
	pmc.add_filter("sanity_blur", 1, gauss_blur_filter(blur_amount))

	if(severity > 0.7)
		owner.overlay_fullscreen("sanity_dither", /atom/movable/screen/fullscreen/dither)
	else
		owner.clear_fullscreen("sanity_dither")

/datum/sanity/proc/update_vignette_effect(severity)
	if(severity < 0.2)
		owner.clear_fullscreen("sanity_vignette")
		remove_vfx(SANITY_VFX_VIGNETTE)
		return

	add_vfx(SANITY_VFX_VIGNETTE)

	var/vignette_type
	if(severity >= 0.8)
		vignette_type = /atom/movable/screen/fullscreen/sanity_vignette/heavy
	else if(severity >= 0.5)
		vignette_type = /atom/movable/screen/fullscreen/sanity_vignette/medium
	else
		vignette_type = /atom/movable/screen/fullscreen/sanity_vignette/light

	owner.overlay_fullscreen("sanity_vignette", vignette_type)

/datum/sanity/proc/update_jitter_effect(severity)
	if(severity < 0.4)
		remove_vfx(SANITY_VFX_JITTER)
		return

	add_vfx(SANITY_VFX_JITTER)

	if(prob(severity * 15))
		shake_camera(owner, 1 + severity * 2, severity * 2)

/datum/sanity/proc/update_wave_effect(atom/movable/plane_master_controller/game/pmc, severity)
	if(severity < 0.6)
		pmc.remove_filter("sanity_wave")
		remove_vfx(SANITY_VFX_WAVE)
		return

	add_vfx(SANITY_VFX_WAVE)

	var/wave_size = clamp((severity - 0.6) * 5, 1, 4)
	pmc.add_filter("sanity_wave", 1, list("type" = "wave", "size" = wave_size, "x" = 16, "y" = 16))

	for(var/filter in pmc.get_filters("sanity_wave"))
		animate(filter, time = 30 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 16, flags = ANIMATION_PARALLEL)

/datum/sanity/proc/update_static_effect(severity)
	if(severity < 0.8)
		owner.clear_fullscreen("sanity_static")
		remove_vfx(SANITY_VFX_STATIC)
		return

	add_vfx(SANITY_VFX_STATIC)

	if(prob(15))
		owner.overlay_fullscreen("sanity_static", /atom/movable/screen/fullscreen/flash/static)
		addtimer(CALLBACK(owner, /mob/proc/clear_fullscreen, "sanity_static", 5), rand(5, 15))
	else
		owner.clear_fullscreen("sanity_static")

/datum/sanity/proc/update_fake_mobs(severity)
	if(world.time < next_hallucination_mob_time)
		return

	if(severity < 0.4)
		clear_fake_mobs()
		return

	var/max_fakes = round(severity * 3)
	if(length(active_fake_mobs) >= max_fakes)
		return

	if(prob(severity * 20))
		spawn_fake_mob()
		next_hallucination_mob_time = world.time + rand(200, 600) / (severity + 0.1)

/datum/sanity/proc/spawn_fake_mob()
	if(!owner || !owner.client)
		return

	var/list/candidates = list(
		/obj/effect/hallucination/simple/xeno,
		/obj/effect/hallucination/simple/clown,
		/obj/effect/hallucination/simple/shadow,
	)

	var/spawn_type = pick(candidates)
	var/turf/T = get_turf(owner)

	var/list/valid_turfs = list()
	for(var/turf/candidate in range(7, T))
		if(!candidate.density && get_dist(candidate, T) >= 3)
			valid_turfs += candidate

	if(!length(valid_turfs))
		return

	var/turf/spawn_turf = pick(valid_turfs)
	var/obj/effect/hallucination/fake = new spawn_type(spawn_turf, owner)
	active_fake_mobs += fake

/datum/sanity/proc/clear_fake_mobs()
	for(var/obj/effect/hallucination/fake in active_fake_mobs)
		qdel(fake)
	active_fake_mobs.Cut()

/datum/sanity/proc/clear_all_visual_effects()
	if(!owner || !owner.client)
		return

	var/atom/movable/plane_master_controller/game/pmc = owner.hud_used?.plane_master_controllers?[PLANE_MASTERS_GAME]
	if(pmc)
		pmc.remove_filter("sanity_color_distortion")
		pmc.remove_filter("sanity_blur")
		pmc.remove_filter("sanity_wave")

	owner.clear_fullscreen("sanity_vignette")
	owner.clear_fullscreen("sanity_dither")
	owner.clear_fullscreen("sanity_static")

	clear_fake_mobs()
	active_vfx.Cut()

/datum/sanity/proc/add_vfx(vfx_type)
	active_vfx[vfx_type] = world.time

/datum/sanity/proc/remove_vfx(vfx_type)
	active_vfx -= vfx_type

// ── Vignette Fullscreen Overlays ──

/atom/movable/screen/fullscreen/sanity_vignette
	icon = 'icons/hud/screen_full.dmi'
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/sanity_vignette/light
	icon_state = "passage3"
	alpha = 120

/atom/movable/screen/fullscreen/sanity_vignette/medium
	icon_state = "passage5"
	alpha = 160

/atom/movable/screen/fullscreen/sanity_vignette/heavy
	icon_state = "passage8"
	alpha = 200

// ── Shadow Hallucination Mob ──

/obj/effect/hallucination/simple/shadow
	name = "shadow figure"
	image_icon = 'icons/mob/mob.dmi'
	image_state = "shade"
	var/wander_range = 7
	var/wander_cooldown = 0
	var/lifetime = 300

/obj/effect/hallucination/simple/shadow/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	name = "shadow figure"
	current_image.name = "shadow figure"
	addtimer(CALLBACK(src, /obj/effect/hallucination/simple/shadow/proc/fade_out), lifetime)

/obj/effect/hallucination/simple/shadow/proc/fade_out()
	if(current_image && target?.client)
		animate(current_image, alpha = 0, time = 20)
		target.client.images -= current_image
	QDEL_IN(src, 30)

// ── Behavioral Effects ──

/datum/sanity/proc/update_behavioral_effects()
	if(!owner || QDELETED(owner) || owner.stat == DEAD)
		return

	if(episode_active)
		update_episode()
		return

	if(world.time < behavior_cooldown)
		return

	var/severity = (max_sanity - sanity_level) / max_sanity
	if(severity < 0.4)
		return

	var/list/possible_behaviors = list()

	if(severity >= 0.4 && prob(5))
		possible_behaviors += SANITY_BEHAVIOR_SCREAM

	if(severity >= 0.5 && prob(4))
		possible_behaviors += SANITY_BEHAVIOR_DROP

	if(severity >= 0.6 && prob(3))
		possible_behaviors += SANITY_BEHAVIOR_FLEE

	if(severity >= 0.7 && prob(4))
		possible_behaviors += SANITY_BEHAVIOR_FREEZE

	if(severity >= 0.5 && prob(3))
		possible_behaviors += SANITY_BEHAVIOR_STAGGER

	if(severity >= 0.6 && prob(5))
		possible_behaviors += SANITY_BEHAVIOR_HALLUCINATE

	if(!length(possible_behaviors))
		return

	var/behavior = pick(possible_behaviors)
	behavior_cooldown = world.time + rand(80, 200)

	execute_behavior(behavior)

/datum/sanity/proc/execute_behavior(behavior)
	if(!owner || QDELETED(owner) || owner.stat == DEAD)
		return

	switch(behavior)
		if(SANITY_BEHAVIOR_SCREAM)
			owner.emote("scream")
			owner.stamina?.adjust(-5)
			owner.visible_message(
				"<span class='warning'>[owner] screams in terror!</span>",
				"<span class='danger'>You can't contain your terror any longer!</span>"
			)

		if(SANITY_BEHAVIOR_DROP)
			var/obj/item/I = owner.get_active_held_item()
			if(I)
				owner.dropItemToGround(I)
				owner.visible_message(
					"<span class='warning'>[owner] drops [I] with shaking hands!</span>",
					"<span class='danger'>Your hands shake uncontrollably and you drop [I]!</span>"
				)

		if(SANITY_BEHAVIOR_FLEE)
			var/dir_flee = pick(GLOB.cardinals)
			var/turf/target_turf = get_step(owner, dir_flee)
			if(target_turf && !target_turf.density)
				owner.Move(target_turf, dir_flee)
				owner.visible_message(
					"<span class='warning'>[owner] stumbles away in panic!</span>",
					"<span class='danger'>You scramble away without thinking!</span>"
				)
				owner.stamina?.adjust(-8)

		if(SANITY_BEHAVIOR_FREEZE)
			owner.Stun(30)
			owner.visible_message(
				"<span class='warning'>[owner] freezes in place, staring into nothing!</span>",
				"<span class='danger'>Your body locks up as terror grips you!</span>"
			)

		if(SANITY_BEHAVIOR_STAGGER)
			owner.Stun(10)
			owner.Knockdown(15)
			owner.visible_message(
				"<span class='warning'>[owner] staggers, barely able to stand!</span>",
				"<span class='danger'>The world spins around you!</span>"
			)

		if(SANITY_BEHAVIOR_HALLUCINATE)
			trigger_behavioral_hallucination()

/datum/sanity/proc/trigger_behavioral_hallucination()
	if(!owner || !owner.client)
		return

	var/list/possible = list(
		"You hear scratching behind the walls...",
		"Something whispers your name from the shadows...",
		"The floor feels soft and wrong beneath your feet...",
		"You smell copper and decay...",
		"Someone is standing right behind you...",
		"The walls are closing in...",
		"You feel fingers tracing down your spine...",
		"The lights are watching you...",
	)

	to_chat(owner, "<span class='warning'>[pick(possible)]</span>")

	if(prob(30))
		shake_camera(owner, 2, 1)

	if(prob(20))
		hallucination_level = min(hallucination_level + 5, max_hallucination)

// ── Panic Attacks & Episodes ──

/datum/sanity/proc/trigger_episode()
	if(episode_active)
		return
	if(world.time < last_episode_time + 600)
		return
	if(sanity_level > 25)
		return

	var/list/possible_episodes = list()

	if(sanity_level <= 25)
		possible_episodes += EPISODE_PANIC

	if(sanity_level <= 15)
		possible_episodes += EPISODE_DISSOCIATIVE
		possible_episodes += EPISODE_FLASHBACK

	if(sanity_level <= 5)
		possible_episodes += EPISODE_CATATONIC

	if(!length(possible_episodes))
		return

	episode_type = pick(possible_episodes)
	episode_active = TRUE
	episode_end_time = world.time + get_episode_duration(episode_type)
	last_episode_time = world.time

	begin_episode(episode_type)

/datum/sanity/proc/get_episode_duration(type)
	switch(type)
		if(EPISODE_PANIC)
			return rand(200, 400)
		if(EPISODE_DISSOCIATIVE)
			return rand(300, 600)
		if(EPISODE_FLASHBACK)
			return rand(150, 300)
		if(EPISODE_CATATONIC)
			return rand(400, 800)
	return 300

/datum/sanity/proc/begin_episode(type)
	if(!owner)
		return

	switch(type)
		if(EPISODE_PANIC)
			to_chat(owner, "<span class='userdanger'>PANIC ATTACK! Your chest tightens, you can't breathe!</span>")
			owner.emote("scream")
			owner.stamina?.adjust(-20)
			hallucination_level = min(hallucination_level + 15, max_hallucination)
			shake_camera(owner, 5, 3)
			owner.add_client_colour(/datum/client_colour/sanity_panic)

		if(EPISODE_DISSOCIATIVE)
			to_chat(owner, "<span class='userdanger'>You feel yourself slipping away... reality feels distant and unreal.</span>")
			owner.Stun(50)
			owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/sanity_dissociative, TRUE, 3)
			hallucination_level = min(hallucination_level + 20, max_hallucination)
			owner.add_client_colour(/datum/client_colour/sanity_dissociative)

		if(EPISODE_FLASHBACK)
			to_chat(owner, "<span class='userdanger'>FLASHBACK! The memories come flooding back!</span>")
			owner.emote("scream")
			owner.Knockdown(30)
			shake_camera(owner, 8, 4)
			hallucination_level = min(hallucination_level + 25, max_hallucination)
			insanity_level = min(insanity_level + 10, max_insanity)
			var/list/flashback_messages = list(
				"You relive the moment of your SCP exposure...",
				"The containment breach plays out before your eyes again...",
				"You hear the screaming, the alarms, the gunfire...",
				"You see them die, over and over...",
				"The creature's eyes bore into your soul once more...",
			)
			to_chat(owner, "<span class='danger'>[pick(flashback_messages)]</span>")

		if(EPISODE_CATATONIC)
			to_chat(owner, "<span class='userdanger'>Your mind shuts down completely. You can't move. You can't think.</span>")
			owner.Stun(200)
			owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/sanity_catatonic, TRUE, 5)
			owner.add_client_colour(/datum/client_colour/sanity_catatonic)

/datum/sanity/proc/update_episode()
	if(!episode_active)
		return

	if(world.time >= episode_end_time)
		end_episode()
		return

	if(!owner || QDELETED(owner) || owner.stat == DEAD)
		end_episode()
		return

	switch(episode_type)
		if(EPISODE_PANIC)
			if(prob(15))
				owner.emote("gasp")
			if(prob(10))
				shake_camera(owner, 2, 2)
			if(prob(5))
				var/obj/item/I = owner.get_active_held_item()
				if(I)
					owner.dropItemToGround(I)

		if(EPISODE_DISSOCIATIVE)
			if(prob(8))
				var/dir_rand = pick(GLOB.cardinals)
				owner.Move(get_step(owner, dir_rand), dir_rand)
			if(prob(5))
				to_chat(owner, "<span class='warning'>Where are you? What is this place?</span>")

		if(EPISODE_FLASHBACK)
			if(prob(10))
				shake_camera(owner, 3, 2)
			if(prob(5))
				owner.emote("scream")

		if(EPISODE_CATATONIC)
			owner.Stun(50)

/datum/sanity/proc/end_episode()
	episode_active = FALSE

	if(!owner)
		return

	clear_all_visual_effects()

	switch(episode_type)
		if(EPISODE_PANIC)
			to_chat(owner, "<span class='notice'>Your breathing slowly returns to normal...</span>")
			owner.remove_client_colour(/datum/client_colour/sanity_panic)

		if(EPISODE_DISSOCIATIVE)
			to_chat(owner, "<span class='notice'>Reality snaps back into focus...</span>")
			owner.remove_movespeed_modifier(/datum/movespeed_modifier/sanity_dissociative)
			owner.remove_client_colour(/datum/client_colour/sanity_dissociative)

		if(EPISODE_FLASHBACK)
			to_chat(owner, "<span class='notice'>The visions fade... but the memories remain.</span>")
			add_trauma(TRAUMA_PSYCHOLOGICAL, 5)

		if(EPISODE_CATATONIC)
			to_chat(owner, "<span class='notice'>You slowly come back to awareness...</span>")
			owner.remove_movespeed_modifier(/datum/movespeed_modifier/sanity_catatonic)
			owner.remove_client_colour(/datum/client_colour/sanity_catatonic)

	episode_type = ""

// ── Client Colour Overlays for Episodes ──

/datum/client_colour/sanity_panic
	colour = list(1.2,0,0,0, 0,0.8,0,0, 0,0,0.8,0, 0,0,0,1, 0.1,-0.05,-0.05,0)
	priority = 10
	fade_in = 10
	fade_out = 20

/datum/client_colour/sanity_dissociative
	colour = list(0.6,0.1,0.1,0, 0.1,0.6,0.1,0, 0.1,0.1,0.6,0, 0,0,0,0.8, -0.1,-0.1,-0.1,0)
	priority = 10
	fade_in = 15
	fade_out = 30

/datum/client_colour/sanity_catatonic
	colour = list(0.3,0.3,0.3,0, 0.3,0.3,0.3,0, 0.3,0.3,0.3,0, 0,0,0,0.6, -0.2,-0.2,-0.2,0)
	priority = 10
	fade_in = 20
	fade_out = 40

// ── Sanity Vignette Overlays ──
// Uses the existing passage overlay from the codebase as a vignette effect

/atom/movable/screen/fullscreen/sanity_vignette
	icon = 'icons/hud/screen_full.dmi'
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/sanity_vignette/light
	icon_state = "passage3"
	alpha = 80

/atom/movable/screen/fullscreen/sanity_vignette/medium
	icon_state = "passage5"
	alpha = 130

/atom/movable/screen/fullscreen/sanity_vignette/heavy
	icon_state = "passage8"
	alpha = 200

// ── Movespeed Modifiers for Episodes ──

/datum/movespeed_modifier/sanity_dissociative
	blacklisted_movetypes = FLOATING
	variable = TRUE

/datum/movespeed_modifier/sanity_catatonic
	blacklisted_movetypes = FLOATING
	variable = TRUE
