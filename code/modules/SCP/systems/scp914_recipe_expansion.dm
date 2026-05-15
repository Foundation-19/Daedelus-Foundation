/datum/scp914_recipe_discovery
	var/list/known_recipes = list()
	var/list/hidden_recipes = list()
	var/list/discovered_recipes = list()

/datum/scp914_recipe_discovery/New()
	..()
	setup_hidden_recipes()

/datum/scp914_recipe_discovery/proc/setup_hidden_recipes()
	hidden_recipes = list(
		"bucket_infinite_water" = list("input" = /obj/item/reagent_containers, "setting" = SCP914_VERY_FINE, "output" = /obj/item/reagent_containers/glass/scp914_infinite_water, "discovery_chance" = 20, "name" = "Bucket of Infinite Water"),
		"uv_flashlight" = list("input" = /obj/item/flashlight, "setting" = SCP914_FINE, "output" = /obj/item/flashlight/scp914_uv, "discovery_chance" = 25, "name" = "UV Flashlight"),
		"slime_soap" = list("input" = /obj/item/soap, "setting" = SCP914_ONE_TO_ONE, "output" = /obj/item/soap/scp914_slime, "discovery_chance" = 20, "name" = "Slime Soap"),
		"spatial_crowbar" = list("input" = /obj/item/crowbar, "setting" = SCP914_VERY_FINE, "output" = /obj/item/crowbar/scp914_spatial, "discovery_chance" = 10, "name" = "Spatial Crowbar"),
		"molecular_scalpel" = list("input" = /obj/item/scalpel, "setting" = SCP914_VERY_FINE, "output" = /obj/item/scalpel/scp914_molecular, "discovery_chance" = 15, "name" = "Molecular Scalpel"),
		"blank_id" = list("input" = /obj/item/card/id, "setting" = SCP914_FINE, "output" = /obj/item/card/id/scp914_blank, "discovery_chance" = 30, "name" = "Blank ID"),
		"scp079_tap" = list("input" = /obj/item/radio, "setting" = SCP914_VERY_FINE, "output" = /obj/item/radio/scp914_079_tap, "discovery_chance" = 10, "name" = "SCP-079 Tap Device"),
		"broken_camera" = list("input" = /obj/item/camera, "setting" = SCP914_ONE_TO_ONE, "output" = /obj/item/camera/scp914_broken, "discovery_chance" = 25, "name" = "Broken Camera"),
		"mesmerizing_pen" = list("input" = /obj/item/pen, "setting" = SCP914_VERY_FINE, "output" = /obj/item/pen/scp914_mesmerizing, "discovery_chance" = 15, "name" = "Mesmerizing Pen"),
		"soundless_shoes" = list("input" = /obj/item/clothing/shoes, "setting" = SCP914_VERY_FINE, "output" = /obj/item/clothing/shoes/scp914_soundless, "discovery_chance" = 20, "name" = "Soundless Shoes"),
		"confetti" = list("input" = /obj/item/paper, "setting" = SCP914_ROUGH, "output" = /obj/item/scp914_confetti, "discovery_chance" = 30, "name" = "Confetti"),
		"scp500_pill" = list("input" = /obj/item/stack/sheet/mineral/gold, "setting" = SCP914_FINE, "output" = /obj/item/reagent_containers/pill/scp500, "discovery_chance" = 10, "name" = "SCP-500 Pill"),
		"cold_welding" = list("input" = /obj/item/weldingtool, "setting" = SCP914_VERY_FINE, "output" = /obj/item/weldingtool/scp914_cold, "discovery_chance" = 15, "name" = "Cold Welding Tool"),
		"scalpel_from_knife" = list("input" = /obj/item/knife/kitchen, "setting" = SCP914_FINE, "output" = /obj/item/scalpel, "discovery_chance" = 25, "name" = "Scalpel"),
		"scp_document" = list("input" = /obj/item/book, "setting" = SCP914_ONE_TO_ONE, "output" = /obj/item/paper/scp914_document, "discovery_chance" = 20, "name" = "SCP Document")
	)

/datum/scp914_recipe_discovery/proc/discover_recipe(ckey, recipe_id)
	if(!ckey || !recipe_id)
		return FALSE

	if(!(recipe_id in hidden_recipes))
		return FALSE

	if(!known_recipes[ckey])
		known_recipes[ckey] = list()

	if(recipe_id in known_recipes[ckey])
		return FALSE

	known_recipes[ckey] += recipe_id

	if(!(recipe_id in discovered_recipes))
		discovered_recipes += recipe_id

	return TRUE

/datum/scp914_recipe_discovery/proc/is_recipe_known(ckey, recipe_id)
	if(!ckey || !recipe_id)
		return FALSE

	if(!known_recipes[ckey])
		return FALSE

	return (recipe_id in known_recipes[ckey])

/datum/scp914_recipe_discovery/proc/get_discovery_chance(recipe_id)
	if(!recipe_id || !(recipe_id in hidden_recipes))
		return 0

	var/list/recipe = hidden_recipes[recipe_id]
	return recipe["discovery_chance"] || 15

/datum/scp914_recipe_discovery/proc/process_discovery(ckey, input_type, setting)
	if(!ckey || !input_type || !setting)
		return null

	for(var/recipe_id in hidden_recipes)
		var/list/recipe = hidden_recipes[recipe_id]

		if(recipe["input"] != input_type)
			continue
		if(recipe["setting"] != setting)
			continue

		if(is_recipe_known(ckey, recipe_id))
			continue

		var/chance = get_discovery_chance(recipe_id)
		if(prob(chance))
			discover_recipe(ckey, recipe_id)
			return recipe_id

	return null

GLOBAL_DATUM_INIT(scp914_discovery, /datum/scp914_recipe_discovery, new())

/obj/item/reagent_containers/glass/scp914_infinite_water
	name = "bucket of infinite water"
	desc = "A bucket that never runs out of water. The water seems to refill on its own."
	icon_state = "beaker"

/obj/item/reagent_containers/glass/scp914_infinite_water/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/water, 100)

/obj/item/reagent_containers/glass/scp914_infinite_water/on_reagent_change()
	if(reagents.total_volume < 100)
		reagents.add_reagent(/datum/reagent/water, 100 - reagents.total_volume)

/obj/item/flashlight/scp914_uv
	name = "UV flashlight"
	desc = "A flashlight that emits ultraviolet light, capable of revealing invisible things."
	icon_state = "flashlight"
	var/is_uv = TRUE
	var/uv_range = 5

/obj/item/flashlight/scp914_uv/attack_self(mob/user)
	. = ..()
	if(on && is_uv)
		for(var/mob/living/L in range(uv_range, user))
			if(istype(L, /mob/living/scp/scp347) || istype(L, /mob/living/scp/scp966))
				L.alpha = initial(L.alpha)
				L.visible_message(span_warning("[L] is revealed by the UV light!"))
				addtimer(CALLBACK(L, /mob/living/proc/reset_alpha), 50)

/mob/living/proc/reset_alpha()
	alpha = initial(alpha)

/obj/item/soap/scp914_slime
	name = "slime soap"
	desc = "A bar of soap that seems... slicker than normal. People who step on it seem to slip for much longer."
	icon_state = "soap"

/obj/item/soap/scp914_slime/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80, NO_SLIP_WHEN_WALKING)

/obj/item/crowbar/scp914_spatial
	name = "spatial crowbar"
	desc = "A crowbar that seems to phase through solid matter. It can pry open bolted airlocks, but only once."
	icon_state = "crowbar"
	var/uses = 1

/obj/item/crowbar/scp914_spatial/afterattack(atom/target, mob/user, proximity)
	if(!proximity || uses <= 0)
		return ..()

	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if(A.locked)
			A.unlock()
			A.open()
			uses--
			user.visible_message(span_notice("[user] pries open the bolted airlock with [src]!"), span_notice("The spatial crowbar phases through the bolts and forces the airlock open!"))
			if(uses <= 0)
				name = "spent spatial crowbar"
				desc = "A crowbar that has expended its spatial energy. It is just a regular crowbar now."
			return

	return ..()

/obj/item/scalpel/scp914_molecular
	name = "molecular scalpel"
	desc = "A scalpel that cuts at the molecular level. Surgeries are completed twice as fast, but it can only be used once."
	icon_state = "scalpel"
	var/uses = 1
	var/surgery_speed_mult = 0.5

/obj/item/scalpel/scp914_molecular/attack(mob/living/M, mob/user)
	. = ..()
	if(uses <= 0)
		return
	uses--
	if(uses <= 0)
		name = "dull molecular scalpel"
		desc = "A molecular scalpel that has lost its edge. It is useless now."

/obj/item/card/id/scp914_blank
	name = "blank ID card"
	desc = "A completely blank ID card with no access. It could be reprogrammed."
	icon_state = "id"

/obj/item/card/id/scp914_blank/Initialize()
	. = ..()
	access = list()
	registered_name = ""

/obj/item/radio/scp914_079_tap
	name = "SCP-079 tap device"
	desc = "A modified radio that can intercept SCP-079's broadcasts. One use only."
	icon_state = "radio"
	var/uses = 1

/obj/item/radio/scp914_079_tap/attack_self(mob/user)
	if(uses <= 0)
		to_chat(user, span_warning("The tap device has been exhausted."))
		return

	uses--
	user.visible_message(span_notice("[user] activates [src]."), span_notice("You intercept a burst of SCP-079's network traffic..."))

	for(var/mob/living/scp079/scp in GLOB.mob_list)
		if(QDELETED(scp))
			continue
		if(scp.stat != DEAD)
			to_chat(user, span_danger("You hear fragments of SCP-079's broadcast: '[scp.name] is monitoring systems...'"))
			break

	if(uses <= 0)
		name = "depleted tap device"
		desc = "A modified radio that has exhausted its ability to intercept SCP-079's broadcasts."

/obj/item/camera/scp914_broken
	name = "broken camera"
	desc = "A broken camera. The film inside contains a photo of something... unsettling."
	icon_state = "camera"

/obj/item/camera/scp914_broken/attack_self(mob/user)
	to_chat(user, span_danger("You look at the photo inside the broken camera. It shows a casket... something is moving inside it. You feel a deep sense of dread."))
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.sanity)
			H.sanity.adjust_sanity(-10, "scp895_photo")

/obj/item/pen/scp914_mesmerizing
	name = "mesmerizing pen"
	desc = "A pen that seems to draw the eye. Clicking it puts people to sleep. One use only."
	icon_state = "pen"
	var/uses = 1

/obj/item/pen/scp914_mesmerizing/attack_self(mob/user)
	if(uses <= 0)
		to_chat(user, span_warning("The pen's mesmerizing effect has faded."))
		return

	uses--

	for(var/mob/living/carbon/human/H in range(3, user))
		if(H == user)
			continue
		H.SetSleeping(50)
		H.visible_message(span_warning("[H] suddenly falls asleep!"))

	if(uses <= 0)
		name = "dull pen"
		desc = "A pen that has lost its mesmerizing quality."

/datum/movespeed_modifier/scp914_soundless
	id = "scp914_soundless"
	slowdown = 0
	variable = TRUE

/obj/item/clothing/shoes/scp914_soundless
	name = "soundless shoes"
	desc = "Shoes that make absolutely no sound when walking. The effect lasts about 5 minutes."
	icon_state = "shoes"
	var/effect_duration = 3000
	var/effect_active = FALSE

/obj/item/clothing/shoes/scp914_soundless/equipped(mob/living/carbon/human/H, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET && !effect_active)
		effect_active = TRUE
		H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/scp914_soundless, TRUE, -0.5)
		addtimer(CALLBACK(src, .proc/expire_silence, H), effect_duration)

/obj/item/clothing/shoes/scp914_soundless/proc/expire_silence(mob/living/carbon/human/H)
	effect_active = FALSE
	if(H)
		H.remove_movespeed_modifier(/datum/movespeed_modifier/scp914_soundless)
		to_chat(H, span_notice("Your soundless shoes lose their effect."))
	name = "worn soundless shoes"
	desc = "Shoes that have lost their anomalous silence."

/obj/item/scp914_confetti
	name = "confetti"
	desc = "A handful of colorful confetti. Festive!"
	icon_state = "scrap"

/obj/item/weldingtool/scp914_cold
	name = "cold welding tool"
	desc = "A welding tool that welds without heat. One use only."
	icon_state = "welder"
	var/uses = 1

/obj/item/weldingtool/scp914_cold/afterattack(atom/target, mob/user, proximity)
	if(!proximity || uses <= 0)
		return ..()

	if(istype(target, /obj/structure/grille) || istype(target, /obj/machinery/door/airlock))
		if(uses > 0)
			uses--
			user.visible_message(span_notice("[user] cold-welds [target] without any heat!"), span_notice("The cold welding tool seals [target] without a spark."))
			if(uses <= 0)
				name = "depleted cold welding tool"
				desc = "A welding tool that has lost its cold-welding ability."
			return

	return ..()

/obj/item/paper/scp914_document
	name = "SCP document"
	desc = "A document containing information about an SCP object."
	icon_state = "paper"

/obj/item/paper/scp914_document/Initialize()
	. = ..()
	var/list/possible_documents = list(
		"SCP-173", "SCP-049", "SCP-096", "SCP-106", "SCP-079",
		"SCP-682", "SCP-939", "SCP-457", "SCP-008", "SCP-500",
		"SCP-895", "SCP-914", "SCP-513", "SCP-347", "SCP-966"
	)
	var/selected = pick(possible_documents)
	name = "[selected] Document"
	desc = "A document containing information about [selected]."
	info = "<b>[selected]</b><br>Classification: [pick("Safe", "Euclid", "Keter")]<br><br>Special Containment Procedures: [pick("Standard humanoid containment", "Reinforced containment chamber", "Submerged in hydrochloric acid", "Kept in a locked box", "No special procedures required")].<br><br>Description: [pick("An anomalous entity of significant threat", "A memetic hazard requiring caution", "An object with unusual physical properties", "A biological anomaly", "An extra-dimensional phenomenon")]."

/obj/item/book/scp914_recipe_book
	name = "SCP-914 recipe book"
	desc = "A book containing discovered SCP-914 recipes."
	icon_state = "book"
	var/list/recipes_contained = list()

/obj/item/book/scp914_recipe_book/Initialize()
	. = ..()
	populate_recipes()

/obj/item/book/scp914_recipe_book/proc/populate_recipes()
	recipes_contained = list()

	if(GLOB.scp914_discovery)
		for(var/recipe_id in GLOB.scp914_discovery.discovered_recipes)
			var/list/recipe = GLOB.scp914_discovery.hidden_recipes[recipe_id]
			if(recipe)
				recipes_contained += list(list(
					"id" = recipe_id,
					"name" = recipe["name"],
					"input" = recipe["input"],
					"setting" = recipe["setting"],
					"output" = recipe["output"]
				))

/obj/item/book/scp914_recipe_book/attack_self(mob/user)
	populate_recipes()
	ui_interact(user)

/obj/item/book/scp914_recipe_book/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCP914RecipeBook", "SCP-914 Recipe Book")
		ui.open()

/obj/item/book/scp914_recipe_book/ui_state(mob/user)
	return GLOB.default_state

/obj/item/book/scp914_recipe_book/ui_data(mob/user)
	var/list/data = list()
	var/list/recipes = list()

	for(var/list/recipe in recipes_contained)
		recipes += list(list(
			"id" = recipe["id"],
			"name" = recipe["name"],
			"setting" = recipe["setting"]
		))

	data["recipes"] = recipes
	return data
