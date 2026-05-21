// Global list to store pending 294-Clarity prompts for admin responses.
GLOBAL_LIST_EMPTY(pending_clarity_prompts)

/obj/machinery/scp294
	name = "coffee machine"
	desc = "A standard coffee vending machine. This one seems to have a QWERTY keyboard."
	icon = 'icons/scp/scp294.dmi'
	icon_state = "coffee_294"
	anchored = TRUE
	density = TRUE

	//Config

	///How long to wait until we can use again
	var/usage_cooldown = 15 MINUTES
	///How many times we can use the machine before it needs to cooldown
	var/max_uses = 30

	//Mechanical

	///Tracks our usage cooldown
	var/usage_cooldown_tracker
	///Tracks our uses
	var/uses_tracker
	///Have we started restock?
	var/started_restock = FALSE
	///Reagent types

	///Shortcut names for things like "poision" or "death" where it dosent match a reagent name exactly
	var/list/shortcut_chems = list(
		"spider" = /datum/reagent/toxin/venom,
		"death" = /datum/reagent/toxin/cyanide,
		"joe" = /datum/reagent/blood,
		"hair dye" = /datum/reagent/hair_dye,
		"plant nutriment" = /datum/reagent/plantnutriment,
		"ez nutriment" = /datum/reagent/plantnutriment/eznutriment,
		"fungal tuberculosis vaccine" = /datum/reagent/vaccine/fungal_tb,
		"tubercle bacillus cosmosis microbes" = /datum/reagent/fungalspores,
		"toxin" = /datum/reagent/toxin,
		"hot ice" = /datum/reagent/toxin/hot_ice,
		"fake beer" = /datum/reagent/toxin/fakebeer,
		"tirizene" = /datum/reagent/toxin/staminatoxin,
		"pump up" = /datum/reagent/drug/pumpup,
		"class a amnestics" = /datum/reagent/medicine/amnestics/classa,
		"class b amnestics" = /datum/reagent/medicine/amnestics/classb,
		"class c amnestics" = /datum/reagent/medicine/amnestics/classc,
		"class e amnestics" = /datum/reagent/medicine/amnestics/classe,
		"class f amnestics" = /datum/reagent/medicine/amnestics/classf,
		"class g amnestics" = /datum/reagent/medicine/amnestics/classg,
		"class h amnestics" = /datum/reagent/medicine/amnestics/classh,
		"class i amnestics" = /datum/reagent/medicine/amnestics/classi
	)

	///Blacklisted reagents DO NOT USE THIS UNLESS ABSOLUTLEY NECCESARY, I DISLIKE PEOPLE IDIOT PROOFING SCPS - Dark
	var/list/blacklist = list(
	)

	///Custom effect definitions
	var/list/custom_effect_definitions = list(
		new /datum/scp294_custom_effect/music(),
		new /datum/scp294_custom_effect/clarity(),
		new /datum/scp294_custom_effect/purity()
	)

/* TD: Need to be readded to the above blacklist once implemented.
		/datum/reagent/scp008,
		/datum/reagent/scp500

*/

/obj/machinery/scp294/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"coffee machine", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE,
		"294", //Numerical Designation
	)
//Mechanics

///Cycles through all reagents datums and picks out ones that contain the chemical we are looking for
/obj/machinery/scp294/proc/find_reagents_to_fill_from(input_path)
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE
	var/list/z_level_stack = SSmapping.get_zstack(current_turf.z, include_lateral = TRUE)
	if(!z_level_stack)
		return FALSE
	return SSreagents.get_reagent_sources_by_type(input_path, z_level_stack)

///Adds reagent we want to pass to cup from list made in find_reagents_to_fill_from
/obj/machinery/scp294/proc/add_reagent_to_cup(input_path, D, reagents_to_fill_from)
	var/obj/item/reagent_containers/food/drinks/sillycup/cup = D
	var/amount_need_filled = cup.volume
	if(!ispath(input_path) || !istype(cup) || !islist(reagents_to_fill_from))
		return
	for(var/datum/reagents/reagent_container in reagents_to_fill_from)
		var/amount_contained = reagent_container.get_reagent_amount(input_path)

		amount_contained = clamp(amount_contained, 0, amount_need_filled)
		cup.reagents.add_reagent(input_path, amount_contained)
		reagent_container.remove_reagent(input_path, amount_contained)

		amount_need_filled -= amount_contained

		if(amount_need_filled <= 0)
			break

	cup.reagents.update_total()
	cup.on_reagent_change()

//Overrides

/obj/machinery/scp294/attack_hand(mob/living/user)
	if(user.combat_mode)
		return ..()

	if(((world.time - usage_cooldown_tracker) > usage_cooldown) && uses_tracker >= max_uses)
		uses_tracker = 0
		started_restock = FALSE

	if(uses_tracker >= max_uses)
		balloon_alert(user, "RESTOCKING...")
		if(!started_restock)
			usage_cooldown_tracker = world.time
			started_restock = TRUE
		return

	playsound(src, 'sound/machines/cb_button.ogg', 35, TRUE)
	var/chosen_reagen_text = tgui_input_text(user, "Please type in your preferred beverage.", "[src] Keyboard")
	if(!chosen_reagen_text)
		return

	var/datum/scp294_custom_effect/chosen_custom_effect

	for(var/datum/scp294_custom_effect/effect in custom_effect_definitions)
		if(findtext(chosen_reagen_text, effect.name, 1, length(chosen_reagen_text) + 1))
			chosen_custom_effect = effect
			break

	if(chosen_custom_effect)
		uses_tracker++
		playsound(src, 'sound/scp/scp294/dispense1.ogg', 35, FALSE)
		visible_message(span_notice("[src] dispenses a small paper cup and starts filling it with a liquid."))
		log_admin("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_custom_effect.name] (custom effect)", user, get_turf(src))
		message_admins(span_notice("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_custom_effect.name] (custom effect)"))

		SEND_SIGNAL(src, COMSIG_SCP294_DISPENSE_ATTEMPT, user, chosen_custom_effect)

		var/obj/item/reagent_containers/food/drinks/sillycup/D = new /obj/item/reagent_containers/food/drinks/sillycup(get_turf(src))
		D.anchored = TRUE
		D.desc = chosen_custom_effect.description
		D.icon_state = chosen_custom_effect.icon_state
		D.custom_scp294_effect = chosen_custom_effect // Attach the custom effect datum to the cup
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/scp294, finish_dispensing_cup), D, chosen_custom_effect.reagent_to_add, find_reagents_to_fill_from(chosen_custom_effect.reagent_to_add)), 3 SECONDS)
		return

	var/datum/reagent/chosen_reagent

	for(var/reagent_name in shortcut_chems)
		if(findtext(chosen_reagen_text, reagent_name, 1, length(chosen_reagen_text) + 1))
			chosen_reagent = shortcut_chems[reagent_name]
			break

	if(!chosen_reagent)
		for(var/datum/reagent/possible as anything in subtypesof(/datum/reagent))
			if(isabstract(possible) || !initial(possible.name))
				continue
			var/chem_name = initial(possible.name) //It dosent work if we dont do this black magic
			if(findtext(chosen_reagen_text, chem_name))
				chosen_reagent = possible
				break

	if(!chosen_reagent || (chosen_reagent in blacklist))
		balloon_alert(user, "OUT OF RANGE")
		playsound(src, 'sound/machines/cb_button_fail.ogg', 35, TRUE)
		return

	var/list/reagents_to_fill_from = find_reagents_to_fill_from(chosen_reagent)
	if(!LAZYLEN(reagents_to_fill_from))
		balloon_alert(user, "OUT OF RANGE")
		playsound(src, 'sound/machines/cb_button_fail.ogg', 35, TRUE)
		return

	uses_tracker++
	playsound(src, 'sound/scp/scp294/dispense1.ogg', 35, FALSE)
	visible_message(span_notice("[src] dispenses a small paper cup and starts filling it with a liquid."))
	log_admin("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_reagent]", user, get_turf(src))
	message_admins(span_notice("[user.ckey]/[user.real_name] used SCP-[SCP.designation], dispensing [chosen_reagent]"))

	SEND_SIGNAL(src, COMSIG_SCP294_DISPENSE_ATTEMPT, user, chosen_reagent)

	var/obj/item/reagent_containers/food/drinks/sillycup/D = new /obj/item/reagent_containers/food/drinks/sillycup(get_turf(src))
	D.anchored = TRUE
	D.desc = "A strange paper cup."
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/scp294, finish_dispensing_cup), D, chosen_reagent, reagents_to_fill_from), 3 SECONDS)

/obj/machinery/scp294/proc/finish_dispensing_cup(obj/item/reagent_containers/food/drinks/sillycup/D, datum/reagent/chosen_reagent, list/reagents_to_fill_from)
	add_reagent_to_cup(chosen_reagent, D, reagents_to_fill_from)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/scp294, finalize_cup_unanchoring), D), 10) // Increased delay to 10 ticks

/obj/machinery/scp294/proc/finalize_cup_unanchoring(obj/item/reagent_containers/food/drinks/sillycup/D)
	D.anchored = FALSE
	return

// Custom Liquids - This is for more Abstract liquids that aren't in the shortcuts list or a definable "reagent"

/datum/scp294_custom_effect
	var/name = "Abstract Liquid"
	var/description = "A strange, unidentifiable liquid."
	var/icon_state = "coffee" // Default icon state for the cup
	var/reagent_to_add = /datum/reagent/water // Default reagent to add to the cup

/datum/scp294_custom_effect/proc/apply_effect(mob/living/user)
	// This proc will be overridden by specific custom effects
	// It will contain the logic for what happens when the drink is consumed.
	return

/datum/scp294_custom_effect/music
	name = "Music"
	reagent_to_add = /datum/reagent/water

/datum/scp294_custom_effect/music/apply_effect(mob/living/user)
	. = ..()
	to_chat(user, span_notice("You feel a continuous rhythm pulsating through your body, and a sudden urge to dance!"))
	to_chat(user, span_notice("Your movements become more fluid and energetic!"))

	user.add_movespeed_modifier(/datum/movespeed_modifier/music_buff) // Add the modifier first

	var/datum/movespeed_modifier/music_buff/M = user.has_movespeed_modifier(/datum/movespeed_modifier/music_buff) // Get the actual instance

	if(M)
		var/sound_path = 'sound/scp/scp294/SCP294song.ogg'
		var/max_volume = 30 // Max volume for the music

		user.playsound_local(user, sound_path, max_volume, channel = CHANNEL_294_MUSIC)
		M.stamina_holder_ref = user.stamina
		M.start_music_stamina_effect()

	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/music_buff), 990) // Remove buff after 1 minute and 39 seconds
	return

/datum/movespeed_modifier/music_buff
	variable = TRUE
	slowdown = -0.5 // Speed buff
	priority = 10
	var/is_music_stamina_active = FALSE
	var/is_burnt_out = FALSE
	var/burnout_timer_id
	var/datum/stamina_container/stamina_holder_ref


/datum/movespeed_modifier/music_buff/proc/start_music_stamina_effect()
	is_music_stamina_active = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_music_stamina_effect)), 990) // End high regen after music duration
	return

/datum/movespeed_modifier/music_buff/proc/end_music_stamina_effect()
	is_music_stamina_active = FALSE
	is_burnt_out = TRUE
	if(stamina_holder_ref)
		stamina_holder_ref.adjust(-STAMINA_BURNOUT_HIT)
	burnout_timer_id = addtimer(CALLBACK(src, PROC_REF(end_burnout_effect)), STAMINA_BURNOUT_DURATION)
	return

/datum/movespeed_modifier/music_buff/proc/end_burnout_effect()
	is_burnt_out = FALSE
	if(burnout_timer_id)
		deltimer(burnout_timer_id)
		burnout_timer_id = null
	return

/datum/scp294_custom_effect/clarity
	name = "Clarity"
	description = "A liquid that grants unsettling insights."
	icon_state = "coffee"
	reagent_to_add = /datum/reagent/water
	var/admin_custom_response_enabled = TRUE // New variable to enable/disable admin custom responses
	var/list/event_prophecies = list(
		"Meteor Wave: Normal" = "The sky weeps fire, a celestial wrath descends.",
		"Meteor Wave: Threatening" = "The sky weeps fire, a celestial wrath descends.",
		"Meteor Wave: Catastrophic" = "The sky weeps fire, a celestial wrath descends.",
		"Meteor Wave: Meaty" = "The sky weeps meat, a celestial wrath descends.",
		"Minor Space Dust" = "Minor space dust is approaching, expect minor damage.",
		"Major Space Dust" = "Major space dust is approaching, expect minor damage.",
		"Zombie Outbreak" = "A creeping, undead horror consumes all, an unstoppable tide.",
		"Fake Nuclear Explosion" = "The world shudders, a deceptive blinding light approaches.",
		"Portal Storm: Syndicate Shocktroops" = "Shadowy figures descend, their motives shrouded in mystery.",
		"Stray Syndicate Cargo Pod" = "Shadowy figures descend, their motives shrouded in mystery.",
		"Electrical Storm" = "The very fabric of the site unravels, chaos reigns.",
		"Processor Overload" = "The very fabric of the site unravels, chaos reigns.",
		"Animal Infesite: Vermin" = "Eight-legged horrors scuttle from the vents, a web of fear.",
		"Animal Infesite: Dangerous" = "Eight-legged horrors scuttle from the vents, a web of fear.",
		"Wormholes" = "Reality twists and warps, the impossible becomes real.",
		"Portal Storm: Constructs" = "Reality twists and warps, the impossible becomes real.",
		"Solar Flare" = "The sun roars, a wave of radiation washes over all.",
		"Carp Migration" = "Silent hunters of the void, their hunger knows no bounds.",
		"Magicarp" = "Silent hunters of the void, their hunger knows no bounds.",
		"Shuttle Catastrophe" = "A desperate plea, the final escape looms.",
		"Shuttle Insurance" = "A desperate plea, the final escape looms.",
		"Shuttle Loan" = "A desperate plea, the final escape looms.",
		"Aurora Caelus" = "A gentle light appears in the void, a moment of peace.",
		"Spontaneous Brain Trauma" = "A sudden, inexplicable trauma afflicts a mind.",
		"Brand Intelligence" = "Machines awaken, their purpose twisted by new directives.",
		"Bureaucratic Error" = "The system falters, leading to unexpected personnel shifts.",
		"Camera Failure" = "The eyes of the site dim, leaving blind spots.",
		"Communications Blackout" = "The airwaves fall silent, isolating the site.",
		"Obsession Awakening" = "A dark fixation takes root in a mind.",
		"Disease Outbreak" = "A silent sickness spreads, threatening all.",
		"Grid Check" = "The site's power flickers, a momentary lapse.",
		"Random Heart Attack" = "A sudden, fatal arrhythmia strikes without warning.",
		"Immovable Rod" = "An unyielding object hurtles through space, unstoppable.",
		"Ion Storm" = "Cosmic energies disrupt the site's systems and minds.",
		"Market Crash" = "The economy falters, prices soar and resources dwindle.",
		"Mass Hallucination" = "Reality bends, and illusions plague the senses.",
		"Grey Tide" = "The gates open, and a tide of chaos is unleashed.",
		"Radiation Storm" = "Invisible waves of energy wash over the site, bringing decay.",
		"RPG Titles" = "The world takes on a fantastical hue, roles are redefined.",
		"Space Vines" = "An invasive flora spreads, consuming all in its path.",
		"Stray Cargo Pod" = "A lost shipment arrives, bringing unexpected contents.",
		"Robeless Casting" = "Magic flows freely, unburdened by tradition.",
		"Improved Casting" = "Arcane power surges, spells become more potent.",
		"Cursed Items" = "Objects become imbued with strange, malevolent properties.",
		"Make Everything Embeddable" = "The world becomes a canvas for impromptu impalement.",
		"Make Everything Sticky" = "Surfaces cling, making movement a struggle.",
		"G-G-G-Ghosts!" = "The veil thins, and spectral presences become apparent.",
		"Possessing G-G-G-Ghosts!" = "Spirits seek new vessels, taking control of the living.",
		"Greentext" = "A legendary artifact appears, promising untold fortune.",
		"Mass Identity Spoof" = "Faces blur, and identities become fluid.",
		"Imposter Wizard" = "A false prophet emerges, mimicking true power.",
		"Invincibility" = "A temporary shield against all harm descends.",
		"The Floor Is LAVA!" = "The ground itself becomes a deadly inferno.",
		"Curse of Madness" = "Sanity erodes, and hidden truths are revealed.",
		"Magicarp" = "Magical aquatic creatures appear, causing chaos.",
		"Petsplosion" = "Creatures multiply exponentially, overwhelming the site.",
		"Race Swap" = "Forms shift, and identities are transformed.",
		"RPG Loot" = "The mundane becomes magical, with random enchantments.",
		"Change Places!" = "Locations shift, disorienting all within.",
		"Change Faces!" = "Appearances are swapped, leading to confusion.",
		"Change Minds!" = "Consciousnesses are exchanged, altering perceptions.",
		"Summon Guns" = "Weapons appear from thin air, arming the masses.",
		"Summon Magic" = "Arcane artifacts manifest, granting mystical abilities."
	)
//TD - More SCP related Events? We haven't ported those at this moment, and there weren't many to begin with.

/datum/scp294_custom_effect/clarity/apply_effect(mob/living/user)
	. = ..()

	var/list/all_messages = list()

	// Predefined meta messages
	all_messages += span_warning("You feel someone watching over you, perhaps several people..")
	all_messages += span_warning("You only exist while the server is running.")
	all_messages += span_warning("The current simulation is running on server 'BYOND-01'.")
	all_messages += span_warning("You are a player character in a heavily modified version of a game called 'Space Station 13'.")

	// Information about potential future events
	var/players_amt = get_active_player_count(alive_check = 1,
	afk_check = 1, human_check = 1)
	for(var/datum/round_event_control/E as anything in SSevents.control)
		if(E.canSpawnEvent(players_amt))
			var/event_name = E.name
			if(event_prophecies[event_name])
				all_messages += span_info(event_prophecies[event_name])
			else
				all_messages += span_info("You glimpse threads of fate, revealing a shadow of [event_name] on the horizon.") // Fallback generic message

	// Information about currently running events
	for(var/datum/round_event/R as anything in SSevents.running)
		if(R.control && R.control.name) // Ensure control and its name exist
			var/event_name = R.control.name
			if(event_prophecies[event_name])
				all_messages += span_info(event_prophecies[event_name])
			else
				all_messages += span_info("A chilling clarity reveals the present: a shadow of [event_name] already unfolds.") // Fallback generic message

	if(length(all_messages)) // Ensure there are messages to display
		var/chosen_message = pick(all_messages) // Pick one random message

		if(admin_custom_response_enabled)
			// Store the prompt context globally and set a timer for fallback
			if(!GLOB.pending_clarity_prompts)
				GLOB.pending_clarity_prompts = list()

			var/prompt_id = REF(user) // Use player ref as unique ID for simplicity
			GLOB.pending_clarity_prompts[prompt_id] = list("user" = user, "message" = chosen_message)

			var/timer_id = addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/scp294_custom_effect/clarity, display_clarity_fallback_message), prompt_id), 10 SECONDS)
			prompt_admin_for_response(user, src, timer_id, prompt_id)
		else
			// If admin custom response is not enabled, display immediately
			to_chat(user, span_notice("You understand far too much. That can’t be good."))
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/scp294_custom_effect/clarity, display_single_clarity_message), user, chosen_message), 10)
	return

/datum/scp294_custom_effect/clarity/proc/display_clarity_fallback_message(prompt_id)
	if(!GLOB.pending_clarity_prompts || !GLOB.pending_clarity_prompts[prompt_id])
		return // Already handled by an admin or invalid prompt

	var/list/prompt_context = GLOB.pending_clarity_prompts[prompt_id]
	var/mob/living/user = prompt_context["user"]
	var/message_to_display = prompt_context["message"]

	if(user && message_to_display)
		to_chat(user, span_notice("You understand far too much. That can’t be good."))
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/scp294_custom_effect/clarity, display_single_clarity_message), user, message_to_display), 10)

	GLOB.pending_clarity_prompts -= prompt_id // Clean up the pending prompt
	return

/datum/scp294_custom_effect/clarity/proc/display_single_clarity_message(mob/living/user, message_to_display)
	if(!user || !message_to_display) // Basic checks
		return
	to_chat(user, message_to_display)
	return

/datum/scp294_custom_effect/clarity/proc/prompt_admin_for_response(mob/living/user, obj/machinery/scp294/machine, timer_id, prompt_id)
	if(!user || !machine)
		return

	var/admin_message_html = "<span class=\"admin\"><span class=\"prefix\">CLARITY ADMIN PROMPT:</span> <span class=\"message\">[key_name(user)] ([user.ckey]) drank Clarity from SCP-294). <a href='?_src_=holder;[HrefToken(TRUE)];clarity_admin_prompt=1;player_ref=[REF(user)];scp_ref=[REF(machine)];timer_id=[timer_id];prompt_id=[prompt_id]'>(Custom Response?)</a></span></span>"
	message_admins(admin_message_html)
	return

/datum/scp294_custom_effect/purity
	name = "Purity"
	description = "A cleansing liquid that purges all chemicals."
	icon_state = "coffee"
	reagent_to_add = /datum/reagent/water // We'll make it add water, and then apply the effect

/datum/scp294_custom_effect/purity/apply_effect(mob/living/user)
	. = ..()
	to_chat(user, span_notice("You feel a profound cleansing as all foreign substances are purged from your system."))
	if(user.reagents)
		user.reagents.clear_reagents()
		user.reagents.update_total()
	return
