// Reward Manager System
// Manages rewards, unlocks, and items for the persistence system

/datum/reward_manager
	var/name = "Reward Manager"
	var/list/rewards = list()
	var/list/reward_categories = list()
	var/list/unlockable_items = list()
	var/list/unlockable_titles = list()
	var/list/unlockable_cosmetics = list()
	var/list/special_rewards = list()

/datum/reward_manager/New()
	initialize_reward_categories()
	initialize_unlockable_items()
	initialize_unlockable_titles()
	initialize_unlockable_cosmetics()
	initialize_special_rewards()

/datum/reward_manager/proc/initialize_reward_categories()
	reward_categories = list(
		"equipment" = list(
			"name" = "Equipment",
			"description" = "Gear and equipment unlocks",
			"icon" = "equipment",
			"color" = "#4169E1"
		),
		"cosmetic" = list(
			"name" = "Cosmetics",
			"description" = "Visual customization options",
			"icon" = "cosmetic",
			"color" = "#FF69B4"
		),
		"title" = list(
			"name" = "Titles",
			"description" = "Display titles and prefixes",
			"icon" = "title",
			"color" = "#FFD700"
		),
		"ability" = list(
			"name" = "Abilities",
			"description" = "Special abilities and perks",
			"icon" = "ability",
			"color" = "#32CD32"
		),
		"currency" = list(
			"name" = "Currency",
			"description" = "Credits and tokens",
			"icon" = "currency",
			"color" = "#00CED1"
		),
		"experience" = list(
			"name" = "Experience",
			"description" = "Experience point bonuses",
			"icon" = "experience",
			"color" = "#9370DB"
		),
		"special" = list(
			"name" = "Special",
			"description" = "Unique and rare rewards",
			"icon" = "special",
			"color" = "#FF4500"
		)
	)

/datum/reward
	var/reward_id
	var/reward_name
	var/reward_description
	var/reward_category = "equipment"
	var/reward_type = "item"
	var/reward_value = 1
	var/reward_rarity = "common"
	var/reward_icon = "default"
	var/reward_color = "#FFFFFF"
	var/reward_cost = 0
	var/list/reward_requirements = list()
	var/reward_one_time = TRUE
	var/reward_stackable = FALSE

/datum/reward/New(id, name, description, category = "equipment", type = "item")
	reward_id = id
	reward_name = name
	reward_description = description
	reward_category = category
	reward_type = type

/datum/reward_manager/proc/initialize_unlockable_items()
	register_equipment_items()
	register_weapons()
	register_tools()
	register_consumables()
	register_accessories()

/datum/reward_manager/proc/register_equipment_items()
	register_item("security_vest_tactical", "Tactical Security Vest", "An advanced tactical vest for security personnel", "equipment", "uncommon", list("experience" = 5000, "class" = "security"))
	register_item("security_helmet_advanced", "Advanced Security Helmet", "A reinforced security helmet with enhanced protection", "equipment", "rare", list("experience" = 15000, "class" = "security"))
	register_item("medical_suit_advanced", "Advanced Medical Suit", "A state-of-the-art medical suit with built-in sensors", "equipment", "rare", list("experience" = 15000, "class" = "medical"))
	register_item("research_labcoat_enhanced", "Enhanced Research Labcoat", "A labcoat with integrated protection systems", "equipment", "uncommon", list("experience" = 5000, "class" = "research"))
	register_item("engineering_hardsuit_light", "Light Engineering Hardsuit", "A lightweight hardsuit for engineering work", "equipment", "rare", list("experience" = 15000, "class" = "engineering"))
	register_item("containment_suit_heavy", "Heavy Containment Suit", "A heavily armored suit for SCP containment", "equipment", "epic", list("experience" = 50000, "rank" = 5))
	register_item("mtf_armor_elite", "Elite MTF Armor", "Elite armor for Mobile Task Force members", "equipment", "legendary", list("experience" = 100000, "rank" = 8))
	register_item("foundation_coat_formal", "Formal Foundation Coat", "A formal coat for Foundation personnel", "equipment", "common", list("experience" = 500))

/datum/reward_manager/proc/register_weapons()
	register_item("security_baton_advanced", "Advanced Stun Baton", "An improved stun baton with extended range", "equipment", "uncommon", list("experience" = 5000, "class" = "security"))
	register_item("security_pistol_enhanced", "Enhanced Sidearm", "An enhanced sidearm with improved accuracy", "equipment", "rare", list("experience" = 15000, "class" = "security"))
	register_item("security_rifle_tactical", "Tactical Rifle", "A tactical rifle for security operations", "equipment", "rare", list("experience" = 25000, "rank" = 3))
	register_item("mtf_rifle_specialized", "Specialized MTF Rifle", "A specialized rifle for MTF operations", "equipment", "epic", list("experience" = 75000, "rank" = 6))
	register_item("containment_tool_advanced", "Advanced Containment Tool", "A multi-purpose containment tool", "equipment", "rare", list("experience" = 20000, "class" = "containment"))

/datum/reward_manager/proc/register_tools()
	register_item("engineering_toolkit_advanced", "Advanced Engineering Toolkit", "A comprehensive toolkit for engineers", "equipment", "uncommon", list("experience" = 5000, "class" = "engineering"))
	register_item("medical_scanner_enhanced", "Enhanced Medical Scanner", "An advanced medical scanner with detailed analysis", "equipment", "rare", list("experience" = 15000, "class" = "medical"))
	register_item("research_scanner_portable", "Portable Research Scanner", "A portable scanner for field research", "equipment", "uncommon", list("experience" = 5000, "class" = "research"))
	register_item("containment_scanner_handheld", "Handheld Containment Scanner", "A scanner for detecting containment breaches", "equipment", "rare", list("experience" = 20000, "class" = "containment"))

/datum/reward_manager/proc/register_consumables()
	register_item("medical_kit_advanced", "Advanced Medical Kit", "An advanced first aid kit", "equipment", "common", list("experience" = 1000))
	register_item("stimulant_injector", "Stimulant Injector", "A combat stimulant injector", "equipment", "uncommon", list("experience" = 5000, "class" = "security"))
	register_item("ration_pack_enhanced", "Enhanced Ration Pack", "A nutritious ration pack", "equipment", "common", list("experience" = 500))

/datum/reward_manager/proc/register_accessories()
	register_item("badge_golden", "Golden Security Badge", "A prestigious golden badge", "equipment", "rare", list("experience" = 25000, "rank" = 5))
	register_item("pin_foundation", "Foundation Pin", "A lapel pin showing Foundation membership", "equipment", "common", list("experience" = 500))
	register_item("watch_tactical", "Tactical Watch", "A tactical watch with multiple functions", "equipment", "uncommon", list("experience" = 5000))

/datum/reward_manager/proc/register_item(id, name, description, category, rarity, list/requirements = list())
	var/datum/reward/reward = new /datum/reward(id, name, description, category, "item")
	reward.reward_rarity = rarity
	if(length(requirements))
		reward.reward_requirements = requirements
	rewards[id] = reward
	unlockable_items[id] = reward

/datum/reward_manager/proc/initialize_unlockable_titles()
	register_title("rookie", "Rookie", "A new recruit", "common", list("experience" = 500))
	register_title("veteran", "Veteran", "An experienced operative", "uncommon", list("experience" = 5000))
	register_title("expert", "Expert", "A highly skilled professional", "rare", list("experience" = 15000))
	register_title("master", "Master", "A master of their craft", "epic", list("experience" = 50000))
	register_title("legend", "Legend", "A legendary figure", "legendary", list("experience" = 100000))
	register_title("foundation_loyalist", "Foundation Loyalist", "Dedicated to the Foundation", "rare", list("faction" = "foundation", "experience" = 10000))
	register_title("scp_hunter", "SCP Hunter", "Specialist in SCP containment", "rare", list("experience" = 15000, "class" = "containment"))
	register_title("research_pioneer", "Research Pioneer", "A leader in SCP research", "rare", list("experience" = 15000, "class" = "research"))
	register_title("medical_savior", "Medical Savior", "A lifesaver in the field", "rare", list("experience" = 15000, "class" = "medical"))
	register_title("engineering_genius", "Engineering Genius", "A master engineer", "rare", list("experience" = 15000, "class" = "engineering"))
	register_title("containment_specialist", "Containment Specialist", "Expert in containment procedures", "rare", list("experience" = 20000, "class" = "containment"))
	register_title("mtf_operator", "MTF Operator", "Mobile Task Force member", "epic", list("experience" = 50000, "rank" = 5))
	register_title("site_director", "Site Director", "A site leadership title", "legendary", list("experience" = 100000, "rank" = 8))
	register_title("o5_observer", "O5 Observer", "An extremely rare title", "legendary", list("experience" = 200000, "rank" = 10))

/datum/reward_manager/proc/register_title(id, name, description, rarity, list/requirements = list())
	var/datum/reward/reward = new /datum/reward(id, name, description, "title", "title")
	reward.reward_rarity = rarity
	if(length(requirements))
		reward.reward_requirements = requirements
	rewards[id] = reward
	unlockable_titles[id] = reward

/datum/reward_manager/proc/initialize_unlockable_cosmetics()
	register_cosmetic("hair_dye_blue", "Blue Hair Dye", "Dye your hair blue", "common")
	register_cosmetic("hair_dye_red", "Red Hair Dye", "Dye your hair red", "common")
	register_cosmetic("hair_dye_green", "Green Hair Dye", "Dye your hair green", "common")
	register_cosmetic("contact_lenses_red", "Red Contact Lenses", "Change your eye color to red", "uncommon")
	register_cosmetic("contact_lenses_gold", "Golden Contact Lenses", "Change your eye color to gold", "rare")
	register_cosmetic("skin_pattern_tactical", "Tactical Skin Pattern", "Apply a tactical pattern to your skin", "rare")
	register_cosmetic("glow_effect_blue", "Blue Glow Effect", "A subtle blue glow around your character", "epic")
	register_cosmetic("glow_effect_gold", "Golden Glow Effect", "A golden glow around your character", "legendary")

/datum/reward_manager/proc/register_cosmetic(id, name, description, rarity)
	var/datum/reward/reward = new /datum/reward(id, name, description, "cosmetic", "cosmetic")
	reward.reward_rarity = rarity
	rewards[id] = reward
	unlockable_cosmetics[id] = reward

/datum/reward_manager/proc/initialize_special_rewards()
	register_special_reward("beta_tester_badge", "Beta Tester Badge", "A special badge for beta testers", "legendary")
	register_special_reward("event_winner_trophy", "Event Winner Trophy", "A trophy for winning a special event", "legendary")
	register_special_reward("yearly_veteran_medal", "Yearly Veteran Medal", "A medal for playing for a year", "legendary")
	register_special_reward("top_contributor", "Top Contributor", "Recognition for outstanding contributions", "legendary")

/datum/reward_manager/proc/register_special_reward(id, name, description, rarity)
	var/datum/reward/reward = new /datum/reward(id, name, description, "special", "special")
	reward.reward_rarity = rarity
	rewards[id] = reward
	special_rewards[id] = reward

/datum/reward_manager/proc/get_reward(reward_id)
	return rewards[reward_id]

/datum/reward_manager/proc/get_rewards_by_category(category)
	var/list/category_rewards = list()
	for(var/id in rewards)
		var/datum/reward/reward = rewards[id]
		if(reward.reward_category == category)
			category_rewards[id] = reward
	return category_rewards

/datum/reward_manager/proc/get_rewards_by_rarity(rarity)
	var/list/rarity_rewards = list()
	for(var/id in rewards)
		var/datum/reward/reward = rewards[id]
		if(reward.reward_rarity == rarity)
			rarity_rewards[id] = reward
	return rarity_rewards

/datum/reward_manager/proc/can_unlock_reward(ckey, reward_id)
	var/datum/reward/reward = rewards[reward_id]
	if(!reward)
		return FALSE

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return FALSE

	if(reward.reward_one_time && (reward_id in player_data.unlocked_items))
		return FALSE

	for(var/requirement in reward.reward_requirements)
		if(!check_requirement(player_data, requirement, reward.reward_requirements[requirement]))
			return FALSE

	return TRUE

/datum/reward_manager/proc/check_requirement(datum/persistent_player_data/player_data, requirement_type, requirement_value)
	switch(requirement_type)
		if("experience")
			return player_data.total_experience >= requirement_value
		if("rounds_played")
			return player_data.rounds_played >= requirement_value
		if("rank")
			return player_data.current_rank >= requirement_value
		if("achievement")
			return requirement_value in player_data.achievements
		if("class")
			return player_data.current_class_id == requirement_value
		if("faction")
			return player_data.current_faction_id == requirement_value
	return FALSE

/datum/reward_manager/proc/unlock_reward(ckey, reward_id, silent = FALSE)
	var/datum/reward/reward = rewards[reward_id]
	if(!reward)
		return FALSE

	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return FALSE

	if(!can_unlock_reward(ckey, reward_id))
		return FALSE

	switch(reward.reward_type)
		if("item")
			player_data.unlocked_items += reward_id
		if("title")
			player_data.unlocked_titles += reward_id
		if("cosmetic")
			if(!player_data.unlocked_cosmetics)
				player_data.unlocked_cosmetics = list()
			player_data.unlocked_cosmetics += reward_id

	if(!silent)
		notify_reward_unlock(ckey, reward)

	SSpersistent_progression.save_player_data(ckey)
	return TRUE

/datum/reward_manager/proc/notify_reward_unlock(ckey, datum/reward/reward)
	for(var/client/C in GLOB.clients)
		if(C.ckey == ckey)
			to_chat(C, "<span class='boldnotice'>REWARD UNLOCKED: [reward.reward_name]!</span>")
			to_chat(C, "<span class='notice'>[reward.reward_description]</span>")
			break

/datum/reward_manager/proc/grant_experience_reward(ckey, amount, reason)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return 0

	player_data.add_experience(amount, "reward", reason)
	SSpersistent_progression.save_player_data(ckey)

	return amount

/datum/reward_manager/proc/grant_currency_reward(ckey, amount, currency_type = "credits")
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return 0

	if(!player_data.currency)
		player_data.currency = list()

	player_data.currency[currency_type] = (player_data.currency[currency_type] || 0) + amount
	SSpersistent_progression.save_player_data(ckey)

	return amount

/datum/reward_manager/proc/get_unlockable_items_for_player(ckey)
	var/list/available = list()
	for(var/id in unlockable_items)
		if(can_unlock_reward(ckey, id))
			available[id] = unlockable_items[id]
	return available

/datum/reward_manager/proc/get_unlocked_items_for_player(ckey)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return list()

	return player_data.unlocked_items

/datum/reward_manager/proc/get_unlockable_titles_for_player(ckey)
	var/list/available = list()
	for(var/id in unlockable_titles)
		if(can_unlock_reward(ckey, id))
			available[id] = unlockable_titles[id]
	return available

/datum/reward_manager/proc/get_unlocked_titles_for_player(ckey)
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(ckey)
	if(!player_data)
		return list()

	return player_data.unlocked_titles

/datum/reward_manager/proc/export_rewards()
	var/list/data = list()
	data["total_rewards"] = length(rewards)
	data["categories"] = reward_categories
	data["rewards"] = list()

	for(var/id in rewards)
		var/datum/reward/reward = rewards[id]
		data["rewards"][id] = list(
			"name" = reward.reward_name,
			"description" = reward.reward_description,
			"category" = reward.reward_category,
			"type" = reward.reward_type,
			"rarity" = reward.reward_rarity,
			"cost" = reward.reward_cost
		)

	return json_encode(data)

/datum/reward_manager/proc/get_rarity_color(rarity)
	switch(rarity)
		if("common")
			return "#FFFFFF"
		if("uncommon")
			return "#1EFF00"
		if("rare")
			return "#0070DD"
		if("epic")
			return "#A335EE"
		if("legendary")
			return "#FF8000"
		else
			return "#FFFFFF"

/datum/reward_manager/proc/spawn_unlocked_items_for_player(mob/living/carbon/human/H)
	if(!H || !H.ckey)
		return
	var/datum/persistent_player_data/player_data = SSpersistent_progression.get_player_data(H.ckey)
	if(!player_data)
		return
	for(var/item_id in player_data.unlocked_items)
		var/datum/reward/reward = rewards[item_id]
		if(!reward)
			continue
		var/obj/item/spawned = spawn_reward_item(item_id)
		if(spawned && H.put_in_hands(spawned) || spawned && H.equip_to_appropriate_slot(spawned))
			continue
		else if(spawned)
			spawned.forceMove(H.loc)

/datum/reward_manager/proc/spawn_reward_item(item_id)
	switch(item_id)
		if("security_vest_tactical")
			return new /obj/item/clothing/suit/armor/vest()
		if("security_helmet_advanced")
			return new /obj/item/clothing/head/helmet()
		if("medical_suit_advanced")
			return new /obj/item/clothing/suit/toggle/labcoat()
		if("research_labcoat_enhanced")
			return new /obj/item/clothing/suit/toggle/labcoat()
		if("foundation_coat_formal")
			return new /obj/item/clothing/suit/toggle/labcoat()
		if("security_baton_advanced")
			return new /obj/item/melee/baton()
		if("medical_kit_advanced")
			return new /obj/item/storage/firstaid/
		if("badge_golden")
			return new /obj/item/clothing/accessory/medal/gold()
		if("pin_foundation")
			return new /obj/item/clothing/accessory/
	return null
