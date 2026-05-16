#define DCLASS_SECURITY_NORMAL 1
#define DCLASS_SECURITY_ELEVATED 2
#define DCLASS_SECURITY_HIGH 3
#define DCLASS_SECURITY_LOCKDOWN 4

/proc/set_facility_security_level(new_level)
	if(!SSsecurity_level)
		return
	var/current = SSsecurity_level.current_level
	if(new_level == current)
		return

	SSsecurity_level.set_level(new_level)

	var/list/dclass_players = SSdclass?.manager?.dclass_players
	if(dclass_players)
		for(var/ckey in dclass_players)
			var/datum/dclass_player/player = dclass_players[ckey]
			if(!player)
				continue
			switch(new_level)
				if(SEC_LEVEL_GREEN)
					player.adjust_trust(5, "security_green")
				if(SEC_LEVEL_BLUE)
					player.adjust_trust(-5, "security_blue")
				if(SEC_LEVEL_RED)
					player.adjust_trust(-15, "security_red")
					player.increase_suspicion(20)
				if(SEC_LEVEL_DELTA)
					player.adjust_trust(-30, "security_delta")
					player.increase_suspicion(40)

	switch(new_level)
		if(SEC_LEVEL_RED, SEC_LEVEL_DELTA)
			lockdown_dclass_areas()
			if(SSdclass?.manager)
				SSdclass.manager.set_security_level(4)
		if(SEC_LEVEL_BLUE)
			if(SSdclass?.manager)
				SSdclass.manager.set_security_level(2)
		if(SEC_LEVEL_GREEN)
			unlock_dclass_areas()
			if(SSdclass?.manager)
				SSdclass.manager.set_security_level(1)

/proc/lockdown_dclass_areas()
	for(var/obj/machinery/door/airlock/A as anything in INSTANCES_OF(/obj/machinery/door/airlock))
		if(!A.density)
			continue
		var/area/A_area = get_area(A)
		if(istype(A_area, /area/scp/dclass))
			A.lock()

/proc/unlock_dclass_areas()
	for(var/obj/machinery/door/airlock/A as anything in INSTANCES_OF(/obj/machinery/door/airlock))
		var/area/A_area = get_area(A)
		if(istype(A_area, /area/scp/dclass))
			A.unlock()

/obj/item/storage/box/survival/dclass
	name = "D-Class survival kit"

/obj/item/storage/box/survival/dclass/PopulateContents()
	..()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/flashlight(src)

/datum/outfit/job/dclass_test
	name = "D-Class Test Subject"
	jobtype = /datum/job/dclass
	id = /obj/item/card/id/advanced/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	box = /obj/item/storage/box/survival/dclass

/datum/outfit/job/dclass_test/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	if(SSdclass?.manager)
		if(!SSdclass.manager.dclass_players[H.ckey])
			SSdclass.manager.dclass_players[H.ckey] = new /datum/dclass_player(H.ckey)

/mob/living/carbon/human/proc/register_dclass()
	if(!ckey)
		return
	if(!SSdclass?.manager)
		return
	if(!SSdclass.manager.dclass_players[ckey])
		SSdclass.manager.dclass_players[ckey] = new /datum/dclass_player(ckey)

/hook/roundstart/proc/init_facility_security()
	if(SSsecurity_level)
		SSsecurity_level.set_level(SEC_LEVEL_GREEN)
	return TRUE
