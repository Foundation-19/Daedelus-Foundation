/datum/scp216_persistence_manager
	var/list/registered_scp216s = list() // To keep track of active SCP-216 instances

/datum/scp216_persistence_manager/New()
	. = ..()
	RegisterSignal(SSevents, COMSIG_TICKER_ROUND_STARTING, PROC_REF(OnRoundStarting))

/datum/scp216_persistence_manager/proc/OnRoundStarting()
	if(!length(SSpersistence.displaced_scp216_items))
		return

	var/list/items_to_remove = list()
	for(var/list/item_data in SSpersistence.displaced_scp216_items)
		item_data["rounds_until_reappearance"]--
		if(item_data["rounds_until_reappearance"] <= 0)
			var/item_path = text2path(item_data["path"])
			var/original_code = item_data["original_code"]

			if(prob(50)) // 50% chance for random physical appearance
				var/turf/reappearance_turf = get_safe_random_station_turf()

				if(reappearance_turf && ispath(item_path, /atom/movable))
					var/atom/movable/reappeared_item = new item_path(reappearance_turf)
					message_admins(span_warning("SCP-216: Temporally displaced item [reappeared_item.name] (Displaced Round: [item_data["displacement_round"]]) reappeared at [reappearance_turf.loc] (Code: [original_code])"))
					log_game("SCP-216: Temporally displaced item [reappeared_item.name] (Displaced Round: [item_data["displacement_round"]], Original User: [item_data["original_user_name"]] ([item_data["original_user_ckey"]])) reappeared at [reappearance_turf.loc] (Code: [original_code]) - Physical Spawn")
				else
					log_game("SCP-216: Failed to physically spawn temporally displaced item [item_path] (Displaced Round: [item_data["displacement_round"]], Original User: [item_data["original_user_name"]] ([item_data["original_user_ckey"]])) (Code: [original_code])")

			else // 50% chance for reappearance in safe's content list
				var/obj/structure/scp216/target_safe
				if(length(GLOB.all_scp216s))
					for(var/obj/structure/scp216/S in GLOB.all_scp216s)
						if(S.current_code == original_code && length(S.all_codes[num2text(original_code, 7)]) < S.max_items)
							target_safe = S
							break

				if(target_safe && ispath(item_path, /atom/movable))
					var/atom/movable/reappeared_item = new item_path(target_safe) // Create directly in safe's storage
					target_safe.all_codes[num2text(original_code, 7)] += reappeared_item
					message_admins(span_warning("SCP-216: Temporally displaced item [reappeared_item.name] (Displaced Round: [item_data["displacement_round"]]) reappeared in SCP-216 with code [original_code]."))
					log_game("SCP-216: Temporally displaced item [reappeared_item.name] (Displaced Round: [item_data["displacement_round"]], Original User: [item_data["original_user_name"]] ([item_data["original_user_ckey"]])) reappeared in SCP-216 with code [original_code] - Safe Content.")
				else
					log_game("SCP-216: Failed to re-insert temporally displaced item [item_path] (Displaced Round: [item_data["displacement_round"]], Original User: [item_data["original_user_name"]] ([item_data["original_user_ckey"]])) into SCP-216 with code [original_code] - No suitable safe found or safe full.")

			items_to_remove += list(item_data)

	for(var/item_data in items_to_remove)
		SSpersistence.displaced_scp216_items -= item_data

// Global instance of the manager
GLOBAL_DATUM_INIT(scp216_persistence_manager, /datum/scp216_persistence_manager, new)
