/obj/structure/scp_archive_shelf
	name = "SCP Archive Shelf"
	desc = "A secure shelf containing classified SCP documentation and containment records."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookshelf"
	density = TRUE
	anchored = TRUE
	var/list/archived_documents = list()

/obj/structure/scp_archive_shelf/attack_hand(mob/user)
	if(!archived_documents.len)
		to_chat(user, span_notice("The shelf is empty. File documents here by clicking it with a paper item."))
		return
	to_chat(user, span_notice("The shelf contains [archived_documents.len] archived document(s):"))
	for(var/doc in archived_documents)
		to_chat(user, span_notice("- [doc]"))

/obj/structure/scp_archive_shelf/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/paper))
		var/obj/item/paper/paper = P
		var/title = paper.name || "Untitled Document"
		archived_documents += title
		qdel(paper)
		to_chat(user, span_notice("You file '[title]' in the archive shelf."))
		return
	return ..()

/obj/machinery/scp_document_scanner
	name = "SCP Document Scanner"
	desc = "A scanner for digitizing and cataloguing SCP documentation into the Foundation archive."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "scanner"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	var/scans_completed = 0
	var/list/catalogued_scp = list()

/obj/machinery/scp_document_scanner/attackby(obj/item/P, mob/user, params)
	if(!istype(P, /obj/item/paper))
		return ..()
	var/obj/item/paper/paper = P
	var/title = paper.name || "Untitled Document"
	if(title in catalogued_scp)
		to_chat(user, span_warning("[title] is already in the archive."))
		return
	catalogued_scp += title
	scans_completed++
	qdel(paper)
	to_chat(user, span_notice("You scan '[title]' into the Foundation archive. Total catalogued: [catalogued_scp.len]"))
	if(SSscp_research && SSscp_research.manager)
		SSscp_research?.manager?.adjust_research_points(25, "document_archival")
		to_chat(user, span_notice("+25 research points from document archival."))
	if(SSraisa && ishuman(user))
		var/datum/intel_report/R = new(user, "document_scan", title, "", "UNCLASSIFIED", "Document '[title]' scanned and archived by [user].", "Automated archival")
		SSraisa.file_report(R)

/obj/item/reagent_containers/food/snacks/dclass_ration
	name = "D-Class Food Ration"
	desc = "A bland, nutritionally adequate food ration for D-Class personnel."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "ration"
	var/quality_bonus = 0

/obj/item/reagent_containers/food/snacks/dclass_ration/premade
	name = "Standard D-Class Ration"
	desc = "A mass-produced, tasteless food ration. Meets minimum nutritional requirements."

/obj/item/reagent_containers/food/snacks/dclass_ration/improved
	name = "Improved D-Class Ration"
	desc = "A slightly better food ration with some actual flavor. D-Class seem to appreciate it."
	quality_bonus = 1

/obj/item/reagent_containers/food/snacks/dclass_ration/premium
	name = "Premium D-Class Ration"
	desc = "A genuinely decent meal prepared with care. D-Class will definitely notice the difference."
	quality_bonus = 2

/obj/machinery/dclass_ration_dispenser
	name = "D-Class Ration Dispenser"
	desc = "A vending machine that dispenses D-Class food rations. The cook can load improved rations into it."
	icon = 'icons/obj/vending.dmi'
	icon_state = "snack"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	var/standard_rations = 20
	var/improved_rations = 0
	var/premium_rations = 0
	var/total_dispensed = 0

/obj/machinery/dclass_ration_dispenser/attackby(obj/item/F, mob/user, params)
	if(istype(F, /obj/item/reagent_containers/food/snacks))
		var/quality = 0
		if(istype(F, /obj/item/reagent_containers/food/snacks/dclass_ration/improved))
			improved_rations++
			quality = 1
		else if(istype(F, /obj/item/reagent_containers/food/snacks/dclass_ration/premium))
			premium_rations++
			quality = 2
		else
			improved_rations++
			quality = 1
		qdel(F)
		to_chat(user, span_notice("You load [F] into the dispenser. [quality > 0 ? "D-Class will appreciate the better food." : ""]"))
		return
	return ..()

/obj/item/janitor_decon_kit
	name = "Anomalous Decontamination Kit"
	desc = "A kit containing specialized cleaning agents for anomalous residues, SCP-106 corrosion, and biohazard spills."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleanade"
	w_class = WEIGHT_CLASS_NORMAL
	var/uses_left = 10

/obj/item/janitor_decon_kit/attack_self(mob/user)
	if(uses_left <= 0)
		to_chat(user, span_warning("The decontamination kit is empty."))
		return
	to_chat(user, span_notice("The kit has [uses_left] uses remaining. Use it on contaminated surfaces to clean anomalous residue."))

/obj/item/janitor_decon_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || uses_left <= 0)
		return
	var/cleaned = FALSE
	if(istype(target, /obj/effect/decal/cleanable))
		qdel(target)
		cleaned = TRUE
	else
		target.wash(CLEAN_SCRUB)
		cleaned = TRUE
	if(cleaned)
		uses_left--
		user.visible_message(span_notice("[user] decontaminates [target]."), span_notice("You decontaminate [target]. [uses_left] uses remaining."))
		if(SSscp_persistence?.manager)
			SSscp_persistence?.manager?.environmental_changes += list(list("type" = "decontamination", "area" = get_area_name(target), "time" = world.time))

/obj/item/botany_scp_sample_kit
	name = "Anomalous Botany Sample Kit"
	desc = "A kit for collecting and preserving anomalous plant specimens and pollen samples from SCP-affected flora."
	icon = 'icons/obj/storage.dmi'
	icon_state = "plantbag"
	w_class = WEIGHT_CLASS_SMALL
	var/list/collected_samples = list()

/obj/item/botany_scp_sample_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(istype(target, /obj/machinery/hydroponics))
		var/sample_name = target.name || "Hydroponics Tray"
		if(sample_name in collected_samples)
			to_chat(user, span_warning("You already have a sample from [sample_name]."))
			return
		collected_samples += sample_name
		user.visible_message(span_notice("[user] collects a botany sample from [target]."), span_notice("You collect a sample from [sample_name]. Samples: [collected_samples.len]"))
		if(SSscp_research?.manager)
			SSscp_research?.manager?.adjust_research_points(10, "botany_sample")
			to_chat(user, span_notice("+10 research points from anomalous botany sample."))
	else if(istype(target, /obj/structure/flora))
		var/sample_name = target.name || "Wild Flora"
		if(sample_name in collected_samples)
			to_chat(user, span_warning("You already have a sample of [sample_name]."))
			return
		collected_samples += sample_name
		user.visible_message(span_notice("[user] collects a wild flora sample from [target]."), span_notice("You collect a sample of [sample_name]. Samples: [collected_samples.len]"))
		if(SSscp_research?.manager)
			SSscp_research?.manager?.adjust_research_points(5, "wild_flora_sample")

/obj/item/botany_scp_sample_kit/attack_self(mob/user)
	if(!collected_samples.len)
		to_chat(user, span_notice("The sample kit is empty. Use it on hydroponics trays or wild flora to collect anomalous specimens."))
		return
	to_chat(user, span_notice("Collected samples ([collected_samples.len]):"))
	for(var/sample in collected_samples)
		to_chat(user, span_notice("- [sample]"))

/obj/item/storage/box/scp_holy_kit
	name = "Foundation Chaplain Kit"
	desc = "A kit containing items for spiritual guidance and anomalous entity interaction."

/obj/item/storage/box/scp_holy_kit/PopulateContents()
	new /obj/item/soap(src)
	new /obj/item/razor(src)
	new /obj/item/clipboard(src)
	new /obj/item/scp_calming_incense(src)

/obj/item/scp_calming_incense
	name = "Anomalous Calming Incense"
	desc = "Specially formulated incense with mild memetic calming properties. Burn near agitated SCP entities to reduce hostility. Single use."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1_lit"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/burn_time = 30 SECONDS

/obj/item/scp_calming_incense/attack_self(mob/user)
	if(active)
		return
	if(!ishuman(user))
		return
	active = TRUE
	user.visible_message(span_notice("[user] lights the calming incense. A soothing fragrance fills the air."), span_notice("You light the calming incense. SCP entities nearby may become less aggressive."))
	var/mob/living/carbon/human/H = user
	if(H.sanity)
		H.sanity.adjust_sanity(3, "calming_incense")
	var/calmed = 0
	for(var/mob/living/scp/S in range(5, H))
		if(S.stat == DEAD)
			continue
		S.set_combat_mode(FALSE)
		calmed++
		if(SSraisa)
			SSraisa.record_observation(H)
	if(calmed > 0 && SSpsychology)
		SSpsychology.counseling_sessions += calmed
	addtimer(CALLBACK(src, PROC_REF(burn_out)), burn_time)

/obj/item/scp_calming_incense/proc/burn_out()
	visible_message(span_notice("The calming incense burns out completely."))
	qdel(src)

/obj/structure/scp_altar
	name = "Foundation Meditation Altar"
	desc = "A serene altar used by the Foundation chaplain for spiritual guidance, meditation, and anomalous entity calming rituals."
	icon = 'icons/obj/structures.dmi'
	icon_state = "altar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	var/meditation_progress = 0
	var/last_meditator
	var/blessing_cooldown = 0

/obj/structure/scp_altar/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.stat != CONSCIOUS)
		return
	ui_interact(H)

/obj/structure/scp_altar/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpAltar", "FOUNDATION MEDITATION ALTAR")
		ui.open()

/obj/structure/scp_altar/ui_state(mob/user)
	return GLOB.default_state

/obj/structure/scp_altar/ui_data(mob/user)
	var/list/data = list()
	data["meditation_progress"] = meditation_progress
	data["ritual_ready"] = world.time >= blessing_cooldown
	data["ritual_cooldown"] = world.time < blessing_cooldown ? max(0, round((blessing_cooldown - world.time) / 10)) : 0
	return data

/obj/structure/scp_altar/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H) || H.stat != CONSCIOUS || !(H in range(1, src)))
		return
	switch(action)
		if("meditate")
			meditation_progress = min(100, meditation_progress + 25)
			if(H.sanity)
				H.sanity.adjust_sanity(5, "meditation")
			to_chat(H, span_notice("You meditate at the altar, finding inner peace. (+5 sanity)"))
			if(SSpsychology)
				SSpsychology.conduct_counseling(H, null)
			. = TRUE
		if("seek_guidance")
			var/list/wisdom = list(
				"The Foundation endures. So must we all.",
				"In darkness, discipline is the only light.",
				"We contain the anomalous so that normalcy may persist.",
				"Every breach teaches us. Every recontainment proves our resolve.",
				"The cost of containment is paid in vigilance.",
				"We are the shield between humanity and the unknown.",
			)
			to_chat(H, span_notice("You seek guidance... \"[pick(wisdom)]\""))
			if(H.sanity)
				H.sanity.adjust_sanity(3, "spiritual_guidance")
			. = TRUE
		if("calming_ritual")
			if(world.time < blessing_cooldown)
				to_chat(H, span_warning("The altar's energies need time to recover."))
				return
			blessing_cooldown = world.time + 5 MINUTES
			var/calmed = 0
			for(var/mob/living/carbon/human/nearby_human in range(5, src))
				if(nearby_human.stat == DEAD)
					continue
				if(nearby_human.sanity)
					nearby_human.sanity.adjust_sanity(8, "calming_ritual")
				calmed++
			visible_message(span_notice("[H] performs a calming ritual at the altar, washing tension from those nearby."))
			to_chat(H, span_notice("You perform the calming ritual. [calmed] person(s) affected. (+8 sanity each)"))
			if(SSpsychology && calmed > 0)
				SSpsychology.counseling_sessions += calmed
			. = TRUE

/obj/machinery/scp_laundry
	name = "Foundation Laundry Unit"
	desc = "An industrial laundry machine capable of cleaning clothing and removing anomalous residues."
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "laundry"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 500
	var/cycle_time = 20 SECONDS
	var/cycle_end = 0
	var/running = FALSE
	var/anomalous_cleanse = FALSE
	var/list/loaded_items = list()

/obj/machinery/scp_laundry/attackby(obj/item/I, mob/user, params)
	if(running)
		to_chat(user, span_warning("The laundry unit is currently running a cycle."))
		return
	if(length(loaded_items) >= 10)
		to_chat(user, span_warning("The laundry unit is full. Start a cycle first."))
		return
	if(!istype(I, /obj/item/clothing) && !istype(I, /obj/item/bedsheet))
		to_chat(user, span_warning("The laundry unit only accepts clothing and bedding."))
		return
	if(!user.transferItemToLoc(I, src))
		return
	loaded_items += I
	to_chat(user, span_notice("You load [I] into the laundry unit. ([length(loaded_items)]/10 items)"))

/obj/machinery/scp_laundry/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpLaundry", "FOUNDATION LAUNDRY UNIT")
		ui.open()

/obj/machinery/scp_laundry/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp_laundry/ui_data(mob/user)
	var/list/data = list()
	data["running"] = running
	data["item_count"] = length(loaded_items)
	data["max_items"] = 10
	data["anomalous_cleanse"] = anomalous_cleanse
	if(running)
		data["time_remaining"] = max(0, round((cycle_end - world.time) / 10))
	return data

/obj/machinery/scp_laundry/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("start_standard")
			if(running || !length(loaded_items))
				return
			anomalous_cleanse = FALSE
			start_cycle(ui.user)
			. = TRUE
		if("start_decon")
			if(running || !length(loaded_items))
				return
			anomalous_cleanse = TRUE
			start_cycle(ui.user)
			. = TRUE
		if("eject")
			if(running)
				return
			for(var/obj/item/I in loaded_items)
				I.forceMove(get_turf(src))
			loaded_items.Cut()
			. = TRUE

/obj/machinery/scp_laundry/proc/start_cycle(mob/user)
	running = TRUE
	cycle_end = world.time + cycle_time
	var/cycle_name = anomalous_cleanse ? "Anomalous Decontamination" : "Standard Wash"
	to_chat(user, span_notice("You start a [cycle_name] cycle. It will take [cycle_time / 10] seconds."))
	addtimer(CALLBACK(src, PROC_REF(finish_cycle)), cycle_time)

/obj/machinery/scp_laundry/proc/finish_cycle()
	running = FALSE
	for(var/obj/item/I in loaded_items)
		I.wash(CLEAN_SCRUB)
		if(anomalous_cleanse)
			I.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			if(SSscp_persistence?.manager)
				SSscp_persistence?.manager?.environmental_changes += list(list("type" = "laundry_decon", "area" = get_area_name(src), "time" = world.time))
		I.forceMove(get_turf(src))
	loaded_items.Cut()
	visible_message(span_notice("[src] finishes its wash cycle with a pleasant chime."))

/obj/machinery/scp_laundry/examine(mob/user)
	. = ..()
	if(running)
		. += span_notice("Currently running [anomalous_cleanse ? "an anomalous decontamination" : "a standard"] wash cycle.")
	else if(length(loaded_items))
		. += span_notice("Contains [length(loaded_items)] item(s) ready to wash.")

/obj/machinery/dclass_ration_dispenser/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpRationDispenser", "D-CLASS RATION DISPENSER")
		ui.open()

/obj/machinery/dclass_ration_dispenser/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/dclass_ration_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["standard_rations"] = standard_rations
	data["improved_rations"] = improved_rations
	data["premium_rations"] = premium_rations
	data["total_dispensed"] = total_dispensed
	return data

/obj/machinery/dclass_ration_dispenser/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("dispense")
			var/ration_type = params["ration_type"]
			var/obj/item/reagent_containers/food/snacks/dclass_ration/ration
			switch(ration_type)
				if("standard")
					if(standard_rations <= 0)
						return
					standard_rations--
					ration = new /obj/item/reagent_containers/food/snacks/dclass_ration/premade(get_turf(ui.user))
				if("improved")
					if(improved_rations <= 0)
						return
					improved_rations--
					ration = new /obj/item/reagent_containers/food/snacks/dclass_ration/improved(get_turf(ui.user))
				if("premium")
					if(premium_rations <= 0)
						return
					premium_rations--
					ration = new /obj/item/reagent_containers/food/snacks/dclass_ration/premium(get_turf(ui.user))
				else
					return
			if(!ration)
				return
			total_dispensed++
			ui.user.put_in_hands(ration)
			if(ration.quality_bonus > 0 && SSfoundation_politics?.manager)
				SSfoundation_politics.manager.political_tensions = max(0, SSfoundation_politics.manager.political_tensions - ration.quality_bonus)

/obj/item/scp_record_player
	name = "Foundation Record Player"
	desc = "A vintage-style record player used for music therapy sessions. The chaplain and psychologist use it for morale-boosting sessions."
	icon = 'icons/obj/musician.dmi'
	icon_state = "piano"
	w_class = WEIGHT_CLASS_BULKY
	var/song_cooldown = 0
	var/static/list/song_types = list(
		"Calming Melody" = 5,
		"Uplifting March" = 3,
		"Solemn Hymn" = 4,
		"Jazz Interlude" = 2,
	)

/obj/item/scp_record_player/attack_self(mob/user)
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/item/scp_record_player/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpRecordPlayer", "FOUNDATION RECORD PLAYER")
		ui.open()

/obj/item/scp_record_player/ui_state(mob/user)
	return GLOB.default_state

/obj/item/scp_record_player/ui_data(mob/user)
	var/list/data = list()
	var/list/songs = list()
	for(var/song_name in song_types)
		songs += list(list(
			"name" = song_name,
			"sanity_bonus" = song_types[song_name],
		))
	data["songs"] = songs
	data["cooldown_active"] = world.time < song_cooldown
	data["cooldown_remaining"] = world.time < song_cooldown ? max(0, round((song_cooldown - world.time) / 10)) : 0
	return data

/obj/item/scp_record_player/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H))
		return
	switch(action)
		if("play_song")
			if(world.time < song_cooldown)
				to_chat(H, span_warning("The record player is still resetting."))
				return
			var/choice = params["song_name"]
			if(!(choice in song_types))
				return
			song_cooldown = world.time + 2 MINUTES
			var/sanity_bonus = song_types[choice]
			H.visible_message(span_notice("[H] plays '[choice]' on the record player."))
			for(var/mob/living/carbon/human/listener in hearers(7, H))
				if(listener.stat != DEAD && listener.sanity)
					listener.sanity.adjust_sanity(sanity_bonus, "music_therapy")
			to_chat(H, span_notice("You play '[choice]'. Listeners gain [sanity_bonus] sanity."))
			. = TRUE
