// Persistence Backup and Restore System
// Provides backup, restore, and migration capabilities for persistence data

/datum/persistence_backup_manager
	var/name = "Persistence Backup Manager"
	var/backup_directory = "data/backups/persistence/"
	var/max_backups = 10
	var/backup_interval = 3600
	var/last_backup = 0
	var/auto_backup_enabled = TRUE
	var/compression_enabled = TRUE
	var/backup_version = 1

/datum/persistence_backup_manager/New()
	if(!fexists(backup_directory))
		rustg_file_write("", "[backup_directory].gitkeep")

/datum/persistence_backup_manager/proc/should_backup()
	if(!auto_backup_enabled)
		return FALSE

	return world.time >= last_backup + backup_interval

/datum/persistence_backup_manager/proc/create_backup(backup_name = null)
	if(!backup_name)
		backup_name = "backup_[time2text(world.time, "YYYY-MM-DD_HH-MM-SS")]"

	var/backup_path = "[backup_directory][backup_name]/"

	if(fexists(backup_path))
		world.log << "Persistence Backup: Backup [backup_name] already exists"
		return FALSE

	var/list/backup_data = list()
	backup_data["version"] = backup_version
	backup_data["timestamp"] = world.time
	backup_data["real_time"] = time2text(world.timeofday, "YYYY-MM-DD HH:MM:SS")
	backup_data["round_id"] = GLOB.round_id

	backup_data["persistence_data"] = collect_persistence_data()
	backup_data["progression_data"] = collect_progression_data()
	backup_data["security_data"] = collect_security_data()
	backup_data["medical_data"] = collect_medical_data()
	backup_data["research_data"] = collect_research_data()
	backup_data["personnel_data"] = collect_personnel_data()

	var/json_data = json_encode(backup_data)

	if(compression_enabled)
		json_data = compress_backup(json_data)

	rustg_file_write(json_data, "[backup_path]backup.json")

	world.log << "Persistence Backup: Created backup [backup_name]"
	last_backup = world.time

	cleanup_old_backups()

	return TRUE

/datum/persistence_backup_manager/proc/collect_persistence_data()
	var/list/data = list()

	data["wall_engravings"] = SSpersistence?.wall_engravings
	data["saved_trophies"] = SSpersistence?.saved_trophies
	data["saved_maps"] = SSpersistence?.saved_maps
	data["displaced_scp216_items"] = SSpersistence?.displaced_scp216_items

	return data

/datum/persistence_backup_manager/proc/collect_progression_data()
	var/list/data = list()

	data["player_data"] = list()
	for(var/ckey in SSpersistent_progression?.player_data)
		var/datum/persistent_player_data/player = SSpersistent_progression.player_data[ckey]
		if(player)
			data["player_data"][ckey] = player.export_to_json()

	data["classes"] = list()
	for(var/class_id in SSpersistent_progression?.classes)
		var/datum/persistent_class/class = SSpersistent_progression.classes[class_id]
		if(class)
			data["classes"][class_id] = class.export_to_json()

	data["factions"] = list()
	for(var/faction_id in SSpersistent_progression?.factions)
		var/datum/persistent_faction/faction = SSpersistent_progression.factions[faction_id]
		if(faction)
			data["factions"][faction_id] = faction.export_to_json()

	return data

/datum/persistence_backup_manager/proc/collect_security_data()
	var/list/data = list()

	if(SSsecurity_persistence?.manager)
		data["security_records"] = list()
		for(var/ckey in SSsecurity_persistence.manager.security_records)
			var/datum/security_record/record = SSsecurity_persistence.manager.security_records[ckey]
			if(record)
				data["security_records"][ckey] = list(
					"real_name" = record.real_name,
					"security_clearance" = record.security_clearance,
					"security_rating" = record.security_rating,
					"security_status" = record.security_status
				)

		data["global_stats"] = list(
			"total_security_incidents" = SSsecurity_persistence.manager.total_security_incidents,
			"active_threats" = SSsecurity_persistence.manager.active_threats,
			"containment_breaches" = SSsecurity_persistence.manager.containment_breaches
		)

	return data

/datum/persistence_backup_manager/proc/collect_medical_data()
	var/list/data = list()

	if(SSmedical_persistence?.manager)
		data["medical_records"] = list()
		for(var/ckey in SSmedical_persistence.manager.medical_records)
			var/datum/medical_record/record = SSmedical_persistence.manager.medical_records[ckey]
			if(record)
				data["medical_records"][ckey] = list(
					"real_name" = record.real_name,
					"blood_type" = record.blood_type,
					"health_rating" = record.health_rating
				)

		data["global_stats"] = list(
			"total_patients_treated" = SSmedical_persistence.manager.total_patients_treated,
			"active_outbreaks" = SSmedical_persistence.manager.active_outbreaks
		)

	return data

/datum/persistence_backup_manager/proc/collect_research_data()
	var/list/data = list()

	if(SSresearch_persistence?.manager)
		data["global_stats"] = list(
			"total_research_projects" = SSresearch_persistence.manager.total_research_projects,
			"completed_projects" = SSresearch_persistence.manager.completed_projects,
			"scientific_breakthroughs" = SSresearch_persistence.manager.scientific_breakthroughs
		)

	return data

/datum/persistence_backup_manager/proc/collect_personnel_data()
	var/list/data = list()

	if(SSpersonnel_persistence?.manager)
		data["global_stats"] = list(
			"total_staff" = SSpersonnel_persistence.manager.total_staff,
			"active_staff" = SSpersonnel_persistence.manager.active_staff,
			"average_performance" = SSpersonnel_persistence.manager.average_performance
		)

	return data

/datum/persistence_backup_manager/proc/restore_backup(backup_name)
	var/backup_path = "[backup_directory][backup_name]/backup.json"

	if(!fexists(backup_path))
		world.log << "Persistence Backup: Backup [backup_name] not found"
		return FALSE

	var/json_data = rustg_file_read(backup_path)
	if(!json_data)
		return FALSE

	if(compression_enabled)
		json_data = decompress_backup(json_data)

	var/list/backup_data = json_decode(json_data)
	if(!backup_data)
		return FALSE

	world.log << "Persistence Backup: Restoring backup [backup_name]..."

	restore_persistence_data(backup_data["persistence_data"])
	restore_progression_data(backup_data["progression_data"])
	restore_security_data(backup_data["security_data"])
	restore_medical_data(backup_data["medical_data"])
	restore_research_data(backup_data["research_data"])
	restore_personnel_data(backup_data["personnel_data"])

	world.log << "Persistence Backup: Restore complete"
	return TRUE

/datum/persistence_backup_manager/proc/restore_persistence_data(data)
	if(!data)
		return

	if(SSpersistence)
		SSpersistence.wall_engravings = data["wall_engravings"] || list()
		SSpersistence.saved_trophies = data["saved_trophies"] || list()
		SSpersistence.saved_maps = data["saved_maps"] || list()
		SSpersistence.displaced_scp216_items = data["displaced_scp216_items"] || list()

/datum/persistence_backup_manager/proc/restore_progression_data(data)
	if(!data)
		return

	if(SSpersistent_progression)
		SSpersistent_progression.player_data = list()

		for(var/ckey in data["player_data"])
			var/player_json = data["player_data"][ckey]
			if(player_json)
				var/list/player_list = json_decode(player_json)
				if(player_list)
					var/datum/persistent_player_data/player = new /datum/persistent_player_data(ckey)
					player.total_experience = player_list["total_experience"] || 0
					player.rounds_played = player_list["rounds_played"] || 0
					player.rounds_survived = player_list["rounds_survived"] || 0
					player.rounds_died = player_list["rounds_died"] || 0
					player.current_class_id = player_list["current_class_id"] || "security"
					player.current_faction_id = player_list["current_faction_id"] || "foundation"
					player.current_rank = player_list["current_rank"] || 0
					player.current_rank_name = player_list["current_rank_name"] || "Recruit"
					player.achievements = player_list["achievements"] || list()
					player.unlocked_items = player_list["unlocked_items"] || list()
					player.unlocked_titles = player_list["unlocked_titles"] || list()
					SSpersistent_progression.player_data[ckey] = player

/datum/persistence_backup_manager/proc/restore_security_data(data)
	if(!data || !SSsecurity_persistence?.manager)
		return

/datum/persistence_backup_manager/proc/restore_medical_data(data)
	if(!data || !SSmedical_persistence?.manager)
		return

/datum/persistence_backup_manager/proc/restore_research_data(data)
	if(!data || !SSresearch_persistence?.manager)
		return

/datum/persistence_backup_manager/proc/restore_personnel_data(data)
	if(!data || !SSpersonnel_persistence?.manager)
		return

/datum/persistence_backup_manager/proc/compress_backup(data)
	return data

/datum/persistence_backup_manager/proc/decompress_backup(data)
	return data

/datum/persistence_backup_manager/proc/cleanup_old_backups()
	var/list/backups = list()

	for(var/file in flist(backup_directory))
		if(copytext(file, -1) == "/")
			backups += copytext(file, 1, -1)

	if(length(backups) <= max_backups)
		return

	sortTim(backups, /proc/cmp_text_asc)

	while(length(backups) > max_backups)
		var/old_backup = backups[1]
		var/backup_path = "[backup_directory][old_backup]"

		for(var/file in flist(backup_path))
			fdel("[backup_path][file]")

		fdel(backup_path)
		backups.Cut(1, 2)

		world.log << "Persistence Backup: Removed old backup [old_backup]"

/datum/persistence_backup_manager/proc/list_backups()
	var/list/backups = list()

	for(var/file in flist(backup_directory))
		if(copytext(file, -1) == "/")
			var/backup_name = copytext(file, 1, -1)
			var/backup_path = "[backup_directory][file]backup.json"

			if(fexists(backup_path))
				var/json_data = rustg_file_read(backup_path)
				if(json_data)
					var/list/backup_info = json_decode(json_data)
					if(backup_info)
						backups[backup_name] = list(
							"timestamp" = backup_info["timestamp"],
							"real_time" = backup_info["real_time"],
							"round_id" = backup_info["round_id"],
							"version" = backup_info["version"]
						)

	return backups

/datum/persistence_backup_manager/proc/delete_backup(backup_name)
	var/backup_path = "[backup_directory][backup_name]/"

	if(!fexists(backup_path))
		return FALSE

	for(var/file in flist(backup_path))
		fdel("[backup_path][file]")

	fdel(backup_path)

	world.log << "Persistence Backup: Deleted backup [backup_name]"
	return TRUE

/datum/persistence_backup_manager/proc/export_backup(backup_name, export_path)
	var/backup_path = "[backup_directory][backup_name]/backup.json"

	if(!fexists(backup_path))
		return FALSE

	var/json_data = rustg_file_read(backup_path)
	if(!json_data)
		return FALSE

	rustg_file_write(json_data, export_path)
	world.log << "Persistence Backup: Exported backup [backup_name] to [export_path]"
	return TRUE

/datum/persistence_backup_manager/proc/import_backup(import_path, backup_name)
	if(!fexists(import_path))
		return FALSE

	var/json_data = rustg_file_read(import_path)
	if(!json_data)
		return FALSE

	if(!backup_name)
		backup_name = "imported_[time2text(world.time, "YYYY-MM-DD_HH-MM-SS")]"

	var/backup_path = "[backup_directory][backup_name]/backup.json"
	rustg_file_write(json_data, backup_path)

	world.log << "Persistence Backup: Imported backup to [backup_name]"
	return TRUE
