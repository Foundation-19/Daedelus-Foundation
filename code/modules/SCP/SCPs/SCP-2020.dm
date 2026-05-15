// SCP-2020 - Cliche, Right?
// A green humanoid that believes it is a character in a science fiction story
// Behaves according to sci-fi cliches, narrates events as story beats
// Completely harmless - just talks about being in a story

/mob/living/scp/scp2020
	name = "SCP-2020"
	desc = "A green-skinned humanoid with an earnest expression. It seems convinced it is a character in a science fiction narrative."
	icon = 'icons/scp/scp-2020.dmi'
	icon_state = "scp2020"
	real_name = "SCP-2020"
	status_flags = 0

	var/narrative_phase = "introduction"
	var/narrative_cooldown = 0
	var/narrative_cooldown_time = 20 SECONDS
	var/cliche_count = 0
	var/plot_developments = 0
	var/conversations_held = 0
	var/dramatic_speeches = 0

	var/list/narrative_phrases = list(
		"Ah, this must be the part where the plot thickens!",
		"I sense a dramatic twist incoming...",
		"This is classic character development!",
		"The author wouldn't let anything bad happen to me. I'm a main character!",
		"Clearly this is a rising action sequence.",
		"Is this the part where I give my inspiring speech?",
		"A plot device! I recognize one when I see one!",
		"The narrative demands I investigate further.",
		"This has all the hallmarks of a second act complication.",
		"Don't worry, the story always finds a way.",
		"I wonder what genre we're in today...",
		"That felt like foreshadowing. Important foreshadowing.",
		"If I were a betting alien, I'd say we're approaching the climax.",
		"The tension is building - classic storytelling technique!",
		"Every good story needs conflict. This must be ours."
	)

	var/list/dramatic_speeches_list = list(
		"Listen up, everyone! I know things look bad, but this is just the dark moment before the triumph! Every hero's journey has one!",
		"We may be outnumbered, but we have something they don't - the power of narrative convenience!",
		"I've read enough stories to know: the good guys always win in the end. Unless this is a tragedy. Is this a tragedy?",
		"The plot demands action! And I, for one, will not disappoint the audience!",
		"According to every sci-fi I've ever experienced, this is exactly the moment where the tide turns!"
	)

	var/list/reaction_phrases = list(
		"A twist! The narrative subverts expectations!",
		"Character motivation revealed! Excellent writing!",
		"This must be the mentor figure. Or perhaps... the betrayer?",
		"Side character introduction! I wonder what arc they'll get.",
		"A red herring, surely. The real threat is yet to come.",
		"Environmental storytelling at its finest!",
		"Rising stakes! This is how you build tension!"
	)

/mob/living/scp/scp2020/Initialize(mapload)
	. = ..()
	set_species(/datum/species/scp2020)
	SCP = new /datum/scp(src, "Cliche, Right?", SCP_SAFE, "2020", SCP_PLAYABLE|SCP_ROLEPLAY)
	SCP.min_playercount = 30
	SCP.min_time = 15 MINUTES

	grant_language(/datum/language/common, TRUE, TRUE)

/mob/living/scp/scp2020/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD)
		return

	process_narrative()

/mob/living/scp/scp2020/proc/process_narrative()
	if(world.time < narrative_cooldown)
		return

	narrative_cooldown = world.time + narrative_cooldown_time

	if(prob(15))
		var/phrase = pick(narrative_phrases)
		say(phrase)
		cliche_count++

	update_narrative_phase()

/mob/living/scp/scp2020/proc/update_narrative_phase()
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H != src && H.stat != DEAD)
			nearby_people++

	switch(nearby_people)
		if(0)
			narrative_phase = "solo_scene"
		if(1 to 2)
			narrative_phase = "dialogue"
		if(3 to 5)
			narrative_phase = "group_scene"
		else
			narrative_phase = "climax"

/mob/living/scp/scp2020/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, range = 7)
	. = ..()
	if(.)
		for(var/mob/living/carbon/human/H in range(5, src))
			if(H.stat != DEAD && H != src)
				hook_scp_interaction(H, "SCP-2020", INTERACTION_TYPE_COMMUNICATION)
				conversations_held++

/mob/living/scp/scp2020/proc/say_reaction(reaction)
	say(reaction)

/mob/living/scp/scp2020/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), atom/sound_loc, message_range)
	. = ..()

	if(speaker == src)
		return

	if(!ishuman(speaker))
		return

	if(world.time < narrative_cooldown)
		return

	narrative_cooldown = world.time + narrative_cooldown_time

	if(prob(40))
		var/reaction = pick(reaction_phrases)
		addtimer(CALLBACK(src, PROC_REF(say_reaction), reaction), 20)

/mob/living/scp/scp2020/UnarmedAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(world.time >= narrative_cooldown)
			narrative_cooldown = world.time + narrative_cooldown_time

			if(prob(50))
				say(pick(narrative_phrases))
				cliche_count++
			else
				say("Hello there! I don't suppose you know what chapter we're on?")

		hook_scp_interaction(H, "SCP-2020", INTERACTION_TYPE_COMMUNICATION)
		return

	return ..()

/mob/living/scp/scp2020/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>A green-skinned humanoid that seems convinced it exists within a science fiction story.</span>")
	to_chat(user, "<span class='notice'>It appears completely harmless, if rather talkative about narrative conventions.</span>")

/mob/living/scp/scp2020/proc/give_dramatic_speech()
	if(stat == DEAD)
		return

	if(world.time < narrative_cooldown)
		to_chat(src, "<span class='warning'>You need to wait for the right dramatic moment...</span>")
		return

	narrative_cooldown = world.time + narrative_cooldown_time * 2

	var/speech = pick(dramatic_speeches_list)
	say(speech)
	dramatic_speeches++
	plot_developments++

	visible_message("<span class='notice'>[src] gestures dramatically!</span>")

/mob/living/scp/scp2020/proc/narrate_events()
	if(stat == DEAD)
		return

	if(world.time < narrative_cooldown)
		to_chat(src, "<span class='warning'>The narrative needs time to breathe...</span>")
		return

	narrative_cooldown = world.time + narrative_cooldown_time

	var/nearby_count = 0
	for(var/mob/living/L in range(7, src))
		if(L != src && L.stat != DEAD)
			nearby_count++

	var/narration = ""
	if(nearby_count == 0)
		narration = pick(list(
			"A quiet scene. The protagonist contemplates. Classic introspection moment.",
			"The empty corridor stretches before me. Atmospheric! Very atmospheric.",
			"A moment of solitude. Every story needs these for pacing."
		))
	else
		narration = pick(list(
			"The cast assembles! [nearby_count] characters in one scene - this must be important!",
			"Multiple characters on screen! This can only mean one thing: plot advancement!",
			"The ensemble gathers. I can feel the subplot brewing..."
		))

	say(narration)
	cliche_count++

/mob/living/scp/scp2020/proc/identify_cliche()
	if(stat == DEAD)
		return

	if(world.time < narrative_cooldown)
		to_chat(src, "<span class='warning'>You need to observe more before identifying the trope...</span>")
		return

	narrative_cooldown = world.time + narrative_cooldown_time

	var/cliche = pick(list(
		"The mysterious facility? Classic containment fiction setup.",
		"Armed personnel? Must be the generic security forces. Every story has them.",
		"Classified documents? Standard plot hook. Nothing new under the sun.",
		"A breach? This is clearly the inciting incident!",
		"Researchers in lab coats? Typecasting, if you ask me.",
		"Anomalous objects? That's just a fancy word for plot devices!",
		"Emergency protocols? Ah, the classic 'things go wrong' moment!",
		"Keycard-restricted doors? A staple of the genre since time immemorial!"
	))

	say(cliche)
	cliche_count++

/mob/living/scp/scp2020/proc/check_narrative_status()
	var/message = "<b>=== SCP-2020 Narrative Status ===</b><br>"
	message += "<b>Current Phase:</b> [narrative_phase]<br>"
	message += "<b>Cliches Identified:</b> [cliche_count]<br>"
	message += "<b>Plot Developments:</b> [plot_developments]<br>"
	message += "<b>Dramatic Speeches:</b> [dramatic_speeches]<br>"
	message += "<b>Conversations Held:</b> [conversations_held]<br>"

	to_chat(src, "<span class='notice'>[message]</span>")

/mob/living/scp/scp2020/death(gibbed, cause_of_death = "Unknown")
	say("I... I don't think... this is how the story... was supposed to end...")
	visible_message("<span class='danger'>[src] collapses, looking genuinely surprised!</span>")
	return ..()
