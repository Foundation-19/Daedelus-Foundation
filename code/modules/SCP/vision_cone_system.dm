// Vision Cone System - Complete Vanderlin-main implementation

// Missing defines that need to be added
#ifndef FOV_DEFAULT
#define FOV_DEFAULT 1
#endif
#ifndef FOV_LEFT
#define FOV_LEFT 2
#endif
#ifndef FOV_RIGHT
#define FOV_RIGHT 4
#endif
#ifndef FOV_BEHIND
#define FOV_BEHIND 8
#endif
#ifndef FIELD_OF_VISION_BLOCKER_PLANE
#define FIELD_OF_VISION_BLOCKER_PLANE 102
#endif

// Missing subsystem - moved to proper location

/client
	var/list/hidden_atoms = list()
	var/list/hidden_mobs = list()
	var/list/hidden_objs = list()
	var/list/hidden_images = list()

/mob
	var/fovangle

//Procs
/atom/proc/InCone(atom/center = usr, dir = NORTH)
	if(get_dist(center, src) == 0 || src == center) return 0
	var/d = get_dir(center, src)
	if(!d || d == dir) return 1
	if(dir & (dir-1))
		return (d & ~dir) ? 0 : 1
	if(!(d & dir)) return 0
	var/dx = abs(x - center.x)
	var/dy = abs(y - center.y)
	if(dx == dy) return 1
	if(dy > dx)
		return (dir & (NORTH|SOUTH)) ? 1 : 0
	return (dir & (EAST|WEST)) ? 1 : 0

/mob/dead/InCone(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/proc/cone(atom/center = usr, dirs, list/list = oview(center))
	for(var/atom/A in list)
		var/fou
		for(var/D in dirs)
			if(A.InCone(center, D))
				fou = TRUE
				break
		if(!fou)
			list -= A
	return list

/mob/dead/BehindAtom(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/atom/proc/BehindAtom(atom/center = usr, dir = NORTH)
	switch(dir)
		if(NORTH)
			if(y > center.y)
				return 1
		if(SOUTH)
			if(y < center.y)
				return 1
		if(EAST)
			if(x > center.x)
				return 1
		if(WEST)
			if(x < center.x)
				return 1

/proc/behind(atom/center = usr, dirs, list/list = oview(center))
	for(var/atom/A in list)
		var/fou
		for(var/D in dirs)
			if(A.BehindAtom(center, D))
				fou = TRUE
				break
		if(!fou)
			list -= A
	return list

/mob/proc/update_vision_cone()
	return

/mob/proc/update_cone()
	return

/mob/living/proc/get_fov_dirlist()
	var/list/dirlist = list()
	if(fovangle & FOV_RIGHT)
		if(fovangle & FOV_LEFT)
			dirlist = list(turn(src.dir, 180), turn(src.dir, -90), turn(src.dir, 90))
		else
			if(fovangle & FOV_BEHIND)
				dirlist = list(turn(src.dir, -90))
			else
				dirlist = list(turn(src.dir, 180), turn(src.dir, -90))
	else
		if(fovangle & FOV_LEFT)
			if(fovangle & FOV_BEHIND)
				dirlist = list(turn(src.dir, 90))
			else
				dirlist = list(turn(src.dir, 180), turn(src.dir, 90))
		else
			if(fovangle & FOV_BEHIND)
				dirlist = list()
			else
				dirlist = list(turn(src.dir, 180))
	return dirlist

/mob/living/proc/get_visible_objs()
	var/list/result = list()
	for(var/obj/O in oview(client.view, src))
		if(O.invisibility >= INVISIBILITY_ABSTRACT)
			continue
		if(O == src)
			continue
		result += O
	return result

/mob/living/update_vision_cone()
	if(!client)
		return
	if(isobserver(client.eye))
		return
	if(hud_used && hud_used.fov)
		hud_used.fov.dir = src.dir
		hud_used.fov_blocker.dir = src.dir
	START_PROCESSING(SSincone, client)

/client/proc/update_cone()
	if(mob)
		mob.update_cone()

/mob/living/update_cone()
	if(!client)
		return
	if(isobserver(client.eye))
		hide_cone()
		return

	for(var/image/old_img in client.hidden_atoms)
		old_img.override = FALSE
		client.images -= old_img
	client.hidden_atoms.Cut()
	client.hidden_mobs.Cut()
	client.hidden_objs.Cut()

	for(var/image/old_hud in client.hidden_images)
		client.images -= old_hud
	client.hidden_images.Cut()

	if(!hud_used || !hud_used.fov || hud_used.fov.alpha == 0)
		return

	hud_used.fov.dir = src.dir

	var/list/dirlist = get_fov_dirlist()
	var/list/mobs2hide = list()
	var/list/objs2hide = list()

	if(fovangle & FOV_RIGHT)
		if(fovangle & FOV_LEFT)
			mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
			objs2hide |= cone(src, dirlist, get_visible_objs())
		else
			if(fovangle & FOV_BEHIND)
				mobs2hide |= behind(src, list(turn(src.dir, 180)), GLOB.mob_living_list.Copy())
				mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
				objs2hide |= behind(src, list(turn(src.dir, 180)), get_visible_objs())
				objs2hide |= cone(src, dirlist, get_visible_objs())
			else
				mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
				objs2hide |= cone(src, dirlist, get_visible_objs())
	else
		if(fovangle & FOV_LEFT)
			if(fovangle & FOV_BEHIND)
				mobs2hide |= behind(src, list(turn(src.dir, 180)), GLOB.mob_living_list.Copy())
				mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
				objs2hide |= behind(src, list(turn(src.dir, 180)), get_visible_objs())
				objs2hide |= cone(src, dirlist, get_visible_objs())
			else
				mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
				objs2hide |= cone(src, dirlist, get_visible_objs())
		else
			if(fovangle & FOV_BEHIND)
				mobs2hide |= behind(src, list(turn(src.dir, 180)), GLOB.mob_living_list.Copy())
				objs2hide |= behind(src, list(turn(src.dir, 180)), get_visible_objs())
			else
				mobs2hide |= cone(src, dirlist, GLOB.mob_living_list.Copy())
				objs2hide |= cone(src, dirlist, get_visible_objs())

	for(var/mob/living/M in mobs2hide)
		var/image/MI = image(loc = M)
		MI.override = TRUE
		MI.appearance = null
		client.images += MI
		client.hidden_atoms += MI
		client.hidden_mobs += M

	for(var/obj/O in objs2hide)
		if(O.invisibility >= INVISIBILITY_ABSTRACT)
			continue
		if(O == src)
			continue
		var/image/OI = image(loc = O)
		OI.override = TRUE
		OI.appearance = null
		client.images += OI
		client.hidden_atoms += OI
		client.hidden_objs += O

	for(var/image/HUD_img in client.images)
		if(HUD_img.icon != 'icons/mob/hud.dmi')
			continue
		for(var/mob/living/M in client.hidden_mobs)
			if(HUD_img.loc == M)
				client.hidden_images += HUD_img
				client.images -= HUD_img
				break

/mob/proc/can_see_cone(atom/L)
	if(!isliving(src))
		return TRUE
	if(!client)
		return TRUE
	if(hud_used && hud_used.fov)
		if(hud_used.fov.alpha != 0)
			var/list/mobs2hide = list()

			if(fovangle & FOV_RIGHT)
				if(fovangle & FOV_LEFT)
					var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90),turn(src.dir, 90))
					mobs2hide |= cone(src, dirlist, list(L))
				else
					if(fovangle & FOV_BEHIND)
						var/dirlist = list(turn(src.dir, -90))
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
						mobs2hide |= cone(src, dirlist, list(L))
					else
						var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90))
						mobs2hide |= cone(src, dirlist, list(L))
			else
				if(fovangle & FOV_LEFT)
					if(fovangle & FOV_BEHIND)
						var/dirlist = list(turn(src.dir, 90))
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
						mobs2hide |= cone(src, dirlist, list(L))
					else
						var/dirlist = list(turn(src.dir, 180),turn(src.dir, 90))
						mobs2hide |= cone(src, dirlist, list(L))
				else
					if(fovangle & FOV_BEHIND)
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
					else
						mobs2hide |= cone(src, list(turn(src.dir, 180)), list(L))

			if(L in mobs2hide)
				return FALSE
	return TRUE

/mob/proc/update_cone_show()
	if(!client)
		return
	if(isobserver(src))
		return hide_cone()
	if(client.perspective != MOB_PERSPECTIVE)
		return hide_cone()
	if(client.eye != src)
		return hide_cone()
	if(client.pixel_x || client.pixel_y)
		return hide_cone()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.resting || H.body_position == LYING_DOWN)
			return hide_cone()
	return show_cone()

/mob/proc/update_fov_angles()
	fovangle = initial(fovangle)
	if(ishuman(src) && fovangle)
		var/mob/living/carbon/human/H = src
		if(H.head)
			if(H.head.block2add)
				fovangle |= H.head.block2add
		if(H.wear_mask)
			if(H.wear_mask.block2add)
				fovangle |= H.wear_mask.block2add
		if(H.STAPER < 5)
			fovangle |= FOV_LEFT
			fovangle |= FOV_RIGHT
		else
			if(HAS_TRAIT(src, TRAIT_CYCLOPS_LEFT))
				fovangle |= FOV_LEFT
			if(HAS_TRAIT(src, TRAIT_CYCLOPS_RIGHT))
				fovangle |= FOV_RIGHT

	if(!hud_used)
		return
	if(!hud_used.fov)
		return
	if(!hud_used.fov_blocker)
		return
	if(fovangle & FOV_DEFAULT)
		if(fovangle & FOV_RIGHT)
			if(fovangle & FOV_LEFT)
				hud_used.fov.icon_state = "both"
				hud_used.fov_blocker.icon_state = "both_v"
				return
			hud_used.fov.icon_state = "right"
			hud_used.fov_blocker.icon_state = "right_v"
			if(fovangle & FOV_BEHIND)
				hud_used.fov.icon_state = "behind_r"
				hud_used.fov_blocker.icon_state = "behind_r_v"
			return
		else if(fovangle & FOV_LEFT)
			hud_used.fov.icon_state = "left"
			hud_used.fov_blocker.icon_state = "left_v"
			if(fovangle & FOV_BEHIND)
				hud_used.fov.icon_state = "behind_l"
				hud_used.fov_blocker.icon_state = "behind_l_v"
			return
		if(fovangle & FOV_BEHIND)
			hud_used.fov.icon_state = "behind"
			hud_used.fov_blocker.icon_state = "behind_v"
		else
			hud_used.fov.icon_state = "combat"
			hud_used.fov_blocker.icon_state = "combat_v"
	else
		hud_used.fov.icon_state = null
		hud_used.fov_blocker.icon_state = null
		return

//Making these generic procs so you can call them anywhere.
/mob/proc/show_cone()
	if(!client)
		return
	if(hud_used?.fov?.alpha >= 180)
		return
	if(hud_used?.fov)
		hud_used.fov.alpha = 180 // Softer, more transparent for warm glow
		hud_used.fov_blocker.alpha = 200 // Slightly more opaque for darkness
		// Add vision cone objects to client screen
		client.screen += hud_used.fov
		client.screen += hud_used.fov_blocker
	// Ensure plane master is added and backdrop is set
	var/atom/movable/screen/plane_master/game_world_fov_hidden/PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in client.screen
	if(!PM)
		PM = new /atom/movable/screen/plane_master/game_world_fov_hidden(null, hud_used)
		client.screen += PM
	PM.backdrop(src)

/mob/proc/hide_cone()
	if(!client)
		return
	if(hud_used?.fov)
		hud_used.fov.alpha = 0
		hud_used.fov_blocker.alpha = 0
		client.screen -= hud_used.fov
		client.screen -= hud_used.fov_blocker
	for(var/image/old_img in client.hidden_atoms)
		old_img.override = FALSE
		client.images -= old_img
	client.hidden_atoms.Cut()
	client.hidden_mobs.Cut()
	client.hidden_objs.Cut()
	for(var/image/old_hud in client.hidden_images)
		client.images -= old_hud
	client.hidden_images.Cut()
	var/atom/movable/screen/plane_master/game_world_fov_hidden/PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in client.screen
	if(PM)
		client.screen -= PM
		PM.backdrop(src)

/atom/movable/screen/fov_blocker
	icon = 'icons/mob/vision_cone.dmi'
	icon_state = "combat_v"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	screen_loc = "1,1"
	color = "#000000"
	alpha = 0

/atom/movable/screen/fov
	icon = 'icons/mob/vision_cone.dmi'
	icon_state = "combat"
	name = " "
	screen_loc = "1,1"
	mouse_opacity = 0
	plane = HUD_PLANE-1
	color = "#FFA500"
	blend_mode = BLEND_ADD
	alpha = 0

// Test verbs
/mob/living/verb/test_vision_cone()
	set name = "Test Vision Cone"
	set category = "Debug"

	to_chat(src, "<span class='notice'>Testing vision cone system...</span>")
	fovangle = FOV_DEFAULT
	update_cone_show()

/mob/living/verb/toggle_vision_cone()
	set name = "Toggle Vision Cone"
	set category = "Debug"

	if(fovangle)
		fovangle = 0
		hide_cone()
		to_chat(src, "<span class='notice'>Vision cone disabled.</span>")
	else
		fovangle = FOV_DEFAULT
		show_cone()
		to_chat(src, "<span class='notice'>Vision cone enabled.</span>")

/mob/living/verb/remove_vision_cone()
	set name = "Remove Vision Cone"
	set category = "Debug"

	fovangle = 0
	hide_cone()
	to_chat(src, "<span class='notice'>Vision cone removed.</span>")

/mob/living/verb/set_fov_left()
	set name = "Set FOV Left"
	set category = "Debug"

	fovangle = FOV_LEFT
	update_vision_cone()
	to_chat(src, "<span class='notice'>FOV set to left only.</span>")

/mob/living/verb/set_fov_right()
	set name = "Set FOV Right"
	set category = "Debug"

	fovangle = FOV_RIGHT
	update_vision_cone()
	to_chat(src, "<span class='notice'>FOV set to right only.</span>")

/mob/living/verb/set_fov_behind()
	set name = "Set FOV Behind"
	set category = "Debug"

	fovangle = FOV_BEHIND
	update_vision_cone()
	to_chat(src, "<span class='notice'>FOV set to behind only.</span>")
