// SCP-263 - The Television
// A TV that plays deadly game shows

/obj/machinery/scp263
	name = "old television"
	desc = "An antique television set from the 1950s. It seems to turn on by itself sometimes."
	icon = 'icons/scp/scp-263.dmi'
	icon_state = "scp263_off"
	density = TRUE
	anchored = TRUE

	var/active = FALSE
	var/viewers = list()
	var/game_active = FALSE
	var/game_cooldown = 0
	var/games_played = 0
	var/interaction_cooldown = 0

	var/datum/scp263_game_system/game_system
	var/datum/scp263_effect_system/effect_system
	var/datum/scp263_research_system/research_system

/obj/machinery/scp263/Initialize()
	. = ..()

	SCP = new /datum/scp(src, "television", SCP_EUCLID, "263")

	game_system = new /datum/scp263_game_system(src)
	effect_system = new /datum/scp263_effect_system(src)
	research_system = new /datum/scp263_research_system(src)

	START_PROCESSING(SSobj, src)

/obj/machinery/scp263/Destroy()
	QDEL_NULL(game_system)
	QDEL_NULL(effect_system)
	QDEL_NULL(research_system)
	QDEL_NULL(SCP)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/scp263/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(!active && prob(5))
		activate()

	if(active && !game_active && game_cooldown <= world.time)
		if(length(viewers) > 0 && prob(10))
			start_game()

	update_viewers()

/obj/machinery/scp263/proc/activate()
	active = TRUE
	icon_state = "scp263_on"
	hook_scp_breach("SCP-263", src)
	visible_message(span_warning("[src] flickers to life!"))

/obj/machinery/scp263/proc/deactivate()
	active = FALSE
	game_active = FALSE
	icon_state = "scp263_off"
	viewers = list()

/obj/machinery/scp263/proc/update_viewers()
	viewers = list()
	for(var/mob/living/carbon/human/H in view(5, src))
		if(H.stat != DEAD)
			viewers += H
			if(world.time >= interaction_cooldown)
				hook_scp_interaction(H, "SCP-263", INTERACTION_TYPE_OBSERVATION)
				interaction_cooldown = world.time + 30 SECONDS

/obj/machinery/scp263/proc/start_game()
	if(!active || game_active || game_cooldown > world.time)
		return

	game_active = TRUE
	games_played++

	if(game_system)
		game_system.begin_game(pick(viewers))

	game_cooldown = world.time + 5 MINUTES

/obj/machinery/scp263/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return

	if(active)
		deactivate()
		to_chat(user, span_notice("You turn off [src]."))
	else
		activate()
		to_chat(user, span_warning("[src] turns on!"))

/obj/machinery/scp263/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("An old television that sometimes shows strange game shows."))
	if(active)
		to_chat(user, span_warning("It's currently on."))

/datum/scp263_game_system
	var/obj/machinery/parent
	var/list/games = list("quiz", "lucky_number", "truth_or_die")
	var/current_game
	var/mob/living/carbon/human/current_contestant
	var/game_phase = 0

/datum/scp263_game_system/New(obj/machinery/P)
	parent = P

/datum/scp263_game_system/proc/begin_game(mob/living/carbon/human/contestant)
	if(!contestant)
		return

	current_contestant = contestant
	current_game = pick(games)
	game_phase = 0

	parent.audible_message(span_warning("A cheerful game show tune plays from [parent]!"))
	parent.audible_message(span_bold("WELCOME TO THE SHOW! Our contestant tonight is... [contestant.name]!"))

	hook_scp_interaction(contestant, "SCP-263", INTERACTION_TYPE_COMBAT)

	switch(current_game)
		if("quiz")
			run_quiz(contestant)
		if("lucky_number")
			run_lucky_number(contestant)
		if("truth_or_die")
			run_truth_or_die(contestant)

/datum/scp263_game_system/proc/run_quiz(mob/living/carbon/human/contestant)
	var/list/questions = list(
		"What is the airspeed velocity of an unladen swallow?" = "african_or_european",
		"What color is the sky?" = "blue",
		"How many fingers am I holding up?" = "zero"
	)

	var/question = pick(questions)
	spawn()
		var/answer = input(contestant, question, "SCP-263 Quiz") as null|text

		if(!answer || lowertext(answer) != lowertext(questions[question]))
			parent.audible_message(span_danger("WRONG! You must be PUNISHED!"))
			contestant.adjustBruteLoss(30)
			hook_scp_combat(contestant, "SCP-263", 0, 30)
		else
			parent.audible_message(span_notice("CORRECT! You live... for now."))

		end_game()

/datum/scp263_game_system/proc/run_lucky_number(mob/living/carbon/human/contestant)
	var/lucky_number = rand(1, 10)
	spawn()
		var/guess = input(contestant, "Pick a number between 1 and 10!", "SCP-263 Lucky Number") as null|num

		if(!guess || guess != lucky_number)
			parent.audible_message(span_danger("The lucky number was [lucky_number]! TOO BAD!"))
			contestant.adjustFireLoss(20)
			hook_scp_combat(contestant, "SCP-263", 0, 20)
		else
			parent.audible_message(span_notice("LUCKY YOU! Literally!"))
			contestant.adjustBruteLoss(-20)

		end_game()

/datum/scp263_game_system/proc/run_truth_or_die(mob/living/carbon/human/contestant)
	parent.audible_message(span_warning("Tell me your DARKEST SECRET or SUFFER!"))

	spawn()
		var/secret = input(contestant, "What is your darkest secret?", "SCP-263: Truth or Die") as null|text

		if(!secret || length(secret) < 10)
			parent.audible_message(span_danger("LIES! SUFFER!"))
			contestant.adjustBruteLoss(25)
			hook_scp_combat(contestant, "SCP-263", 0, 25)
		else
			parent.audible_message(span_notice("HOW ENTERTAINING! You may live."))

		end_game()

/datum/scp263_game_system/proc/end_game()
	current_game = null
	current_contestant = null
	game_phase = 0
	if(parent)
		var/obj/machinery/scp263/P = parent
		P.game_active = FALSE

/datum/scp263_effect_system
	var/obj/machinery/parent
	var/static_effect = 0
	var/effect_radius = 7

/datum/scp263_effect_system/New(obj/machinery/P)
	parent = P

/datum/scp263_research_system
	var/obj/machinery/parent
	var/list/game_log = list()
	var/total_games = 0

/datum/scp263_research_system/New(obj/machinery/P)
	parent = P

/datum/scp263_research_system/proc/log_game(mob/contestant, game_type, survived)
	total_games++
	game_log["[world.time]"] = list("contestant" = contestant?.ckey, "type" = game_type, "survived" = survived)
