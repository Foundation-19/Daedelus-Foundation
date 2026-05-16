// Personnel Persistence System
// Tracks staff records, assignments, performance, and personnel management

SUBSYSTEM_DEF(personnel_persistence)
	name = "Personnel Persistence"
	wait = 600 // 1 minute
	priority = FIRE_PRIORITY_INPUT

	var/datum/personnel_persistence_manager/manager

/datum/personnel_persistence_manager
	var/list/personnel_records = list() // ckey -> personnel_record
	var/list/assignments = list() // assignment_id -> assignment
	var/list/performance_reviews = list() // review_id -> performance_review
	var/list/training_records = list() // training_id -> training_record
	var/list/promotions = list() // promotion_id -> promotion
	var/list/personnel_statistics = list() // stat_name -> value

	// Global personnel metrics
	var/total_staff = 0
	var/active_staff = 0
	var/personnel_budget = 3000000
	var/staff_satisfaction = 75
	var/turnover_rate = 0.05
	var/average_performance = 80
	var/training_completion_rate = 0.85

/datum/personnel_record
	var/ckey
	var/real_name
	var/employee_id
	var/department
	var/position
	var/hire_date
	var/clearance_level = 1
	var/performance_rating = 80
	var/salary = 50000
	var/status = "ACTIVE" // ACTIVE, SUSPENDED, TERMINATED, RETIRED
	var/list/assignments = list()
	var/list/performance_reviews = list()
	var/list/training_records = list()
	var/list/promotions = list()
	var/list/skills = list()
	var/list/certifications = list()
	var/emergency_contact = ""
	var/last_updated

/datum/personnel_record/New(var/ckey, var/real_name, var/department, var/position)
		src.ckey = ckey
		src.real_name = real_name
		src.department = department
		src.position = position
		src.hire_date = world.time
		src.last_updated = world.time

/datum/assignment
	var/assignment_id
	var/employee_ckey
	var/assignment_type
	var/assignment_description
	var/start_date
	var/end_date
	var/status = "ACTIVE" // ACTIVE, COMPLETED, CANCELLED
	var/priority = 1
	var/completion_rating = 0
	var/supervisor_ckey
	var/notes = ""

/datum/assignment/New(var/assignment_id, var/employee_ckey, var/assignment_type, var/assignment_description, var/supervisor_ckey)
		src.assignment_id = assignment_id
		src.employee_ckey = employee_ckey
		src.assignment_type = assignment_type
		src.assignment_description = assignment_description
		src.supervisor_ckey = supervisor_ckey
		src.start_date = world.time

/datum/performance_review
	var/review_id
	var/employee_ckey
	var/reviewer_ckey
	var/review_date
	var/performance_rating = 80
	var/strengths = list()
	var/weaknesses = list()
	var/goals = list()
	var/overall_assessment = ""
	var/next_review_date

/datum/performance_review/New(var/review_id, var/employee_ckey, var/reviewer_ckey)
		src.review_id = review_id
		src.employee_ckey = employee_ckey
		src.reviewer_ckey = reviewer_ckey
		src.review_date = world.time

/datum/training_record
	var/training_id
	var/employee_ckey
	var/training_type
	var/training_name
	var/training_date
	var/completion_date
	var/status = "PENDING" // PENDING, IN_PROGRESS, COMPLETED, FAILED
	var/score = 0
	var/certification_expiry
	var/trainer_ckey
	var/notes = ""

/datum/training_record/New(var/training_id, var/employee_ckey, var/training_type, var/training_name, var/trainer_ckey)
		src.training_id = training_id
		src.employee_ckey = employee_ckey
		src.training_type = training_type
		src.training_name = training_name
		src.trainer_ckey = trainer_ckey
		src.training_date = world.time

/datum/promotion
	var/promotion_id
	var/employee_ckey
	var/old_position
	var/new_position
	var/promotion_date
	var/reason
	var/approver_ckey
	var/salary_increase = 0
	var/clearance_increase = 0

/datum/promotion/New(var/promotion_id, var/employee_ckey, var/old_position, var/new_position, var/approver_ckey)
		src.promotion_id = promotion_id
		src.employee_ckey = employee_ckey
		src.old_position = old_position
		src.new_position = new_position
		src.approver_ckey = approver_ckey
		src.promotion_date = world.time

// Personnel Persistence Manager Methods
/datum/personnel_persistence_manager/proc/process_personnel()
	// Process advanced personnel management
	process_promotions()
	process_training_completion()
	process_attrition()
	update_staff_satisfaction()
	calculate_average_performance()
	calculate_training_completion_rate()

	// Update personnel statistics
	update_personnel_statistics()

	// Process assignments
	process_assignments()

	// Update training records
	update_training_records()

	// Process performance reviews
	process_performance_reviews()

	// Simulate personnel changes over time
	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		if(record.status == "ACTIVE")
			// Calculate real performance based on actual game data
			record.performance_rating = calculate_real_performance(record.ckey)

			// Calculate real salary based on position and performance
			record.salary = calculate_real_salary(record.position, record.performance_rating)

			// Calculate real clearance level based on position and performance
			record.clearance_level = calculate_real_clearance(record.position, record.performance_rating)

			record.last_updated = world.time

	// Save data periodically
	if(world.time % 3000 == 0) // Every 5 minutes
		save_personnel_data()

/datum/personnel_persistence_manager/proc/add_personnel_record(var/ckey, var/real_name, var/department, var/position, var/salary = 50000, var/clearance_level = 1)
	if(!(ckey in personnel_records))
		var/datum/personnel_record/record = new /datum/personnel_record(ckey, real_name, department, position)
		record.salary = salary
		record.clearance_level = clearance_level
		personnel_records[ckey] = record
		total_staff++
		active_staff++

		// Sync with existing crew records system
		sync_with_crew_records(ckey, real_name, department, position)
		return record
	return personnel_records[ckey]

/datum/personnel_persistence_manager/proc/add_assignment(var/employee_ckey, var/assignment_type, var/assignment_description, var/supervisor_ckey, var/priority = 1)
	var/assignment_id = "assignment_[world.time]"
	var/datum/assignment/assignment = new /datum/assignment(assignment_id, employee_ckey, assignment_type, assignment_description, supervisor_ckey)
	assignment.priority = priority

	assignments[assignment_id] = assignment

	// Add to employee record
	var/datum/personnel_record/record = personnel_records[employee_ckey]
	if(record)
		record.assignments += assignment
		record.last_updated = world.time

	return assignment

// Old procedure removed - using updated version below

/datum/personnel_persistence_manager/proc/add_training_record(var/employee_ckey, var/training_type, var/training_name, var/trainer_ckey)
	var/training_id = "training_[world.time]"
	var/datum/training_record/training = new /datum/training_record(training_id, employee_ckey, training_type, training_name, trainer_ckey)

	training_records[training_id] = training

	// Add to employee record
	var/datum/personnel_record/record = personnel_records[employee_ckey]
	if(record)
		record.training_records += training
		record.last_updated = world.time

	return training

/datum/personnel_persistence_manager/proc/add_promotion(var/employee_ckey, var/new_position, var/approver_ckey, var/salary_increase = 0, var/clearance_increase = 0)
	var/promotion_id = "promotion_[world.time]"
	var/datum/personnel_record/record = personnel_records[employee_ckey]
	if(!record)
		return null

	var/old_position = record.position
	var/datum/promotion/promotion = new /datum/promotion(promotion_id, employee_ckey, old_position, new_position, approver_ckey)
	promotion.salary_increase = salary_increase
	promotion.clearance_increase = clearance_increase

	promotions[promotion_id] = promotion

	// Update employee record
	record.position = new_position
	record.salary += salary_increase
	record.clearance_level += clearance_increase
	record.promotions += promotion
	record.last_updated = world.time

	return promotion

// Calculate real performance based on actual game data
/datum/personnel_persistence_manager/proc/calculate_real_performance(ckey)
	var/datum/personnel_record/record = personnel_records[ckey]
	if(!record)
		return 75 // Default performance

	// Base performance on position and activity
	var/base_performance = 75

	// Adjust based on position
	switch(record.position)
		if("Security Officer", "Security Guard")
			base_performance = 80
		if("Medical Doctor", "Chief Medical Officer")
			base_performance = 85
		if("Scientist", "Research Director")
			base_performance = 80
		if("Engineer", "Chief Engineer")
			base_performance = 80
		if("Janitor", "Assistant")
			base_performance = 70

	// Adjust based on training completion
	if(length(record.training_records) > 0)
		base_performance += 5

	// Adjust based on assignments completed
	if(length(record.assignments) > 0)
		base_performance += min(10, length(record.assignments) * 2)

	return max(0, min(100, base_performance))

// Calculate real salary based on position and performance
/datum/personnel_persistence_manager/proc/calculate_real_salary(position, performance_rating)
	var/base_salary = 50000 // Default salary

	// Adjust based on position
	switch(position)
		if("Security Officer", "Security Guard")
			base_salary = 55000
		if("Medical Doctor")
			base_salary = 65000
		if("Chief Medical Officer")
			base_salary = 85000
		if("Scientist")
			base_salary = 60000
		if("Research Director")
			base_salary = 90000
		if("Engineer")
			base_salary = 58000
		if("Chief Engineer")
			base_salary = 80000
		if("Janitor", "Assistant")
			base_salary = 40000

	// Adjust based on performance
	var/performance_bonus = (performance_rating - 75) * 200
	base_salary += performance_bonus

	return max(30000, base_salary) // Minimum salary

// Calculate real clearance level based on position and performance
/datum/personnel_persistence_manager/proc/calculate_real_clearance(position, performance_rating)
	var/base_clearance = 1 // Default clearance

	// Adjust based on position
	switch(position)
		if("Security Officer", "Security Guard")
			base_clearance = 2
		if("Medical Doctor")
			base_clearance = 2
		if("Chief Medical Officer")
			base_clearance = 3
		if("Scientist")
			base_clearance = 3
		if("Research Director")
			base_clearance = 4
		if("Engineer")
			base_clearance = 2
		if("Chief Engineer")
			base_clearance = 3
		if("Janitor", "Assistant")
			base_clearance = 1

	// Adjust based on performance
	if(performance_rating >= 90)
		base_clearance = min(5, base_clearance + 1)
	else if(performance_rating < 60)
		base_clearance = max(1, base_clearance - 1)

	return base_clearance

/datum/personnel_persistence_manager/proc/update_personnel_statistics()
	personnel_statistics["total_staff"] = total_staff
	personnel_statistics["active_staff"] = active_staff
	personnel_statistics["personnel_budget"] = personnel_budget
	personnel_statistics["staff_satisfaction"] = staff_satisfaction
	personnel_statistics["turnover_rate"] = turnover_rate
	personnel_statistics["average_performance"] = average_performance
	personnel_statistics["training_completion"] = training_completion_rate
	personnel_statistics["active_assignments"] = length(assignments)
	personnel_statistics["pending_reviews"] = length(performance_reviews)
	personnel_statistics["active_training"] = length(training_records)

/datum/personnel_persistence_manager/proc/process_assignments()
	for(var/assignment_id in assignments)
		var/datum/assignment/assignment = assignments[assignment_id]
		if(assignment.status == "ACTIVE")
			// Simulate assignment completion
			if(prob(10)) // 10% chance to complete
				assignment.status = "COMPLETED"
				assignment.end_date = world.time
				assignment.completion_rating = rand(60, 100)

				// Update employee performance
				var/datum/personnel_record/record = personnel_records[assignment.employee_ckey]
				if(record)
					record.performance_rating = min(100, record.performance_rating + (assignment.completion_rating - 80) / 10)

/datum/personnel_persistence_manager/proc/update_training_records()
	for(var/training_id in training_records)
		var/datum/training_record/training = training_records[training_id]
		if(training.status == "IN_PROGRESS")
			// Simulate training completion
			if(prob(15)) // 15% chance to complete
				training.status = "COMPLETED"
				training.completion_date = world.time
				training.score = rand(70, 100)

				// Add certification if score is high enough
				if(training.score >= 80)
					var/datum/personnel_record/record = personnel_records[training.employee_ckey]
					if(record)
						record.certifications += training.training_name

/datum/personnel_persistence_manager/proc/process_performance_reviews()
	// Simulate automatic performance reviews
	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		if(record.status == "ACTIVE" && prob(5)) // 5% chance per cycle
			// Generate automatic review
			var/reviewer_ckey = "SYSTEM"
			var/performance_rating = record.performance_rating + rand(-10, 10)
			performance_rating = max(0, min(100, performance_rating))

			add_performance_review(ckey, reviewer_ckey, performance_rating, "Automatic performance review")

/datum/personnel_persistence_manager/proc/save_personnel_data()
	var/list/data = list()

	// Save personnel records
	data["personnel_records"] = list()
	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		data["personnel_records"][ckey] = list(
			"real_name" = record.real_name,
			"employee_id" = record.employee_id,
			"department" = record.department,
			"position" = record.position,
			"hire_date" = record.hire_date,
			"clearance_level" = record.clearance_level,
			"performance_rating" = record.performance_rating,
			"salary" = record.salary,
			"status" = record.status,
			"skills" = record.skills,
			"certifications" = record.certifications,
			"emergency_contact" = record.emergency_contact,
			"last_updated" = record.last_updated
		)

	// Save assignments
	data["assignments"] = list()
	for(var/assignment_id in assignments)
		var/datum/assignment/assignment = assignments[assignment_id]
		data["assignments"][assignment_id] = list(
			"employee_ckey" = assignment.employee_ckey,
			"assignment_type" = assignment.assignment_type,
			"assignment_description" = assignment.assignment_description,
			"start_date" = assignment.start_date,
			"end_date" = assignment.end_date,
			"status" = assignment.status,
			"priority" = assignment.priority,
			"completion_rating" = assignment.completion_rating,
			"supervisor_ckey" = assignment.supervisor_ckey,
			"notes" = assignment.notes
		)

	// Save performance reviews
	data["performance_reviews"] = list()
	for(var/review_id in performance_reviews)
		var/datum/performance_review/review = performance_reviews[review_id]
		data["performance_reviews"][review_id] = list(
			"employee_ckey" = review.employee_ckey,
			"reviewer_ckey" = review.reviewer_ckey,
			"review_date" = review.review_date,
			"performance_rating" = review.performance_rating,
			"strengths" = review.strengths,
			"weaknesses" = review.weaknesses,
			"goals" = review.goals,
			"overall_assessment" = review.overall_assessment,
			"next_review_date" = review.next_review_date
		)

	// Save training records
	data["training_records"] = list()
	for(var/training_id in training_records)
		var/datum/training_record/training = training_records[training_id]
		data["training_records"][training_id] = list(
			"employee_ckey" = training.employee_ckey,
			"training_type" = training.training_type,
			"training_name" = training.training_name,
			"training_date" = training.training_date,
			"completion_date" = training.completion_date,
			"status" = training.status,
			"score" = training.score,
			"certification_expiry" = training.certification_expiry,
			"trainer_ckey" = training.trainer_ckey,
			"notes" = training.notes
		)

	// Save promotions
	data["promotions"] = list()
	for(var/promotion_id in promotions)
		var/datum/promotion/promotion = promotions[promotion_id]
		data["promotions"][promotion_id] = list(
			"employee_ckey" = promotion.employee_ckey,
			"old_position" = promotion.old_position,
			"new_position" = promotion.new_position,
			"promotion_date" = promotion.promotion_date,
			"reason" = promotion.reason,
			"approver_ckey" = promotion.approver_ckey,
			"salary_increase" = promotion.salary_increase,
			"clearance_increase" = promotion.clearance_increase
		)

	// Save global statistics
	data["global_stats"] = list(
		"total_staff" = total_staff,
		"active_staff" = active_staff,
		"personnel_budget" = personnel_budget,
		"staff_satisfaction" = staff_satisfaction,
		"turnover_rate" = turnover_rate,
		"average_performance" = average_performance,
		"training_completion_rate" = training_completion_rate
	)

	// Write to JSON file
	var/json_data = json_encode(data)
	var/savefile/S = new /savefile("data/personnel_persistence.json")
	S["data"] << json_data

	// Save to database
	save_personnel_data_to_database()

/datum/personnel_persistence_manager/proc/save_personnel_data_to_database()
	if(!SSdbcore.Connect())
		world.log << "Personnel Persistence: Database connection failed, skipping database save"
		return

	// Save personnel records to database
	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		var/datum/db_query/query_save_personnel = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("personnel_records")]
			(ckey, real_name, employee_id, department, position, hire_date, clearance_level, performance_rating, salary, status, skills, certifications, emergency_contact, last_updated)
			VALUES (:ckey, :real_name, :employee_id, :department, :position, :hire_date, :clearance_level, :performance_rating, :salary, :status, :skills, :certifications, :emergency_contact, :last_updated)
			ON DUPLICATE KEY UPDATE
			real_name = VALUES(real_name), employee_id = VALUES(employee_id), department = VALUES(department), position = VALUES(position),
			hire_date = VALUES(hire_date), clearance_level = VALUES(clearance_level), performance_rating = VALUES(performance_rating),
			salary = VALUES(salary), status = VALUES(status), skills = VALUES(skills), certifications = VALUES(certifications),
			emergency_contact = VALUES(emergency_contact), last_updated = VALUES(last_updated)
		"}, list(
			"ckey" = ckey,
			"real_name" = record.real_name,
			"employee_id" = record.employee_id,
			"department" = record.department,
			"position" = record.position,
			"hire_date" = record.hire_date,
			"clearance_level" = record.clearance_level,
			"performance_rating" = record.performance_rating,
			"salary" = record.salary,
			"status" = record.status,
			"skills" = json_encode(record.skills),
			"certifications" = json_encode(record.certifications),
			"emergency_contact" = record.emergency_contact,
			"last_updated" = record.last_updated
		))

		if(!query_save_personnel.warn_execute())
			world.log << "Personnel Persistence: Failed to save personnel record for [ckey]"
		qdel(query_save_personnel)

	// Save assignments to database
	for(var/assignment_id in assignments)
		var/datum/assignment/assignment = assignments[assignment_id]
		var/datum/db_query/query_save_assignment = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("personnel_assignments")]
			(assignment_id, employee_ckey, assignment_type, assignment_description, start_date, end_date, status, priority, completion_rating, supervisor_ckey, notes)
			VALUES (:assignment_id, :employee_ckey, :assignment_type, :assignment_description, :start_date, :end_date, :status, :priority, :completion_rating, :supervisor_ckey, :notes)
			ON DUPLICATE KEY UPDATE
			employee_ckey = VALUES(employee_ckey), assignment_type = VALUES(assignment_type), assignment_description = VALUES(assignment_description),
			start_date = VALUES(start_date), end_date = VALUES(end_date), status = VALUES(status), priority = VALUES(priority),
			completion_rating = VALUES(completion_rating), supervisor_ckey = VALUES(supervisor_ckey), notes = VALUES(notes)
		"}, list(
			"assignment_id" = assignment_id,
			"employee_ckey" = assignment.employee_ckey,
			"assignment_type" = assignment.assignment_type,
			"assignment_description" = assignment.assignment_description,
			"start_date" = assignment.start_date,
			"end_date" = assignment.end_date,
			"status" = assignment.status,
			"priority" = assignment.priority,
			"completion_rating" = assignment.completion_rating,
			"supervisor_ckey" = assignment.supervisor_ckey,
			"notes" = assignment.notes
		))

		if(!query_save_assignment.warn_execute())
			world.log << "Personnel Persistence: Failed to save assignment [assignment_id]"
		qdel(query_save_assignment)

	// Save performance reviews to database
	for(var/review_id in performance_reviews)
		var/datum/performance_review/review = performance_reviews[review_id]
		var/datum/db_query/query_save_review = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("personnel_performance_reviews")]
			(review_id, employee_ckey, reviewer_ckey, review_date, performance_rating, strengths, weaknesses, goals, overall_assessment, next_review_date)
			VALUES (:review_id, :employee_ckey, :reviewer_ckey, :review_date, :performance_rating, :strengths, :weaknesses, :goals, :overall_assessment, :next_review_date)
			ON DUPLICATE KEY UPDATE
			employee_ckey = VALUES(employee_ckey), reviewer_ckey = VALUES(reviewer_ckey), review_date = VALUES(review_date),
			performance_rating = VALUES(performance_rating), strengths = VALUES(strengths), weaknesses = VALUES(weaknesses),
			goals = VALUES(goals), overall_assessment = VALUES(overall_assessment), next_review_date = VALUES(next_review_date)
		"}, list(
			"review_id" = review_id,
			"employee_ckey" = review.employee_ckey,
			"reviewer_ckey" = review.reviewer_ckey,
			"review_date" = review.review_date,
			"performance_rating" = review.performance_rating,
			"strengths" = review.strengths,
			"weaknesses" = review.weaknesses,
			"goals" = review.goals,
			"overall_assessment" = review.overall_assessment,
			"next_review_date" = review.next_review_date
		))

		if(!query_save_review.warn_execute())
			world.log << "Personnel Persistence: Failed to save performance review [review_id]"
		qdel(query_save_review)

	// Save training records to database
	for(var/training_id in training_records)
		var/datum/training_record/training = training_records[training_id]
		var/datum/db_query/query_save_training = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("personnel_training_records")]
			(training_id, employee_ckey, training_type, training_name, training_date, completion_date, status, score, certification_expiry, trainer_ckey, notes)
			VALUES (:training_id, :employee_ckey, :training_type, :training_name, :training_date, :completion_date, :status, :score, :certification_expiry, :trainer_ckey, :notes)
			ON DUPLICATE KEY UPDATE
			employee_ckey = VALUES(employee_ckey), training_type = VALUES(training_type), training_name = VALUES(training_name),
			training_date = VALUES(training_date), completion_date = VALUES(completion_date), status = VALUES(status),
			score = VALUES(score), certification_expiry = VALUES(certification_expiry), trainer_ckey = VALUES(trainer_ckey), notes = VALUES(notes)
		"}, list(
			"training_id" = training_id,
			"employee_ckey" = training.employee_ckey,
			"training_type" = training.training_type,
			"training_name" = training.training_name,
			"training_date" = training.training_date,
			"completion_date" = training.completion_date,
			"status" = training.status,
			"score" = training.score,
			"certification_expiry" = training.certification_expiry,
			"trainer_ckey" = training.trainer_ckey,
			"notes" = training.notes
		))

		if(!query_save_training.warn_execute())
			world.log << "Personnel Persistence: Failed to save training record [training_id]"
		qdel(query_save_training)

	// Save promotions to database
	for(var/promotion_id in promotions)
		var/datum/promotion/promotion = promotions[promotion_id]
		var/datum/db_query/query_save_promotion = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("personnel_promotions")]
			(promotion_id, employee_ckey, old_position, new_position, promotion_date, reason, approver_ckey, salary_increase, clearance_increase)
			VALUES (:promotion_id, :employee_ckey, :old_position, :new_position, :promotion_date, :reason, :approver_ckey, :salary_increase, :clearance_increase)
			ON DUPLICATE KEY UPDATE
			employee_ckey = VALUES(employee_ckey), old_position = VALUES(old_position), new_position = VALUES(new_position),
			promotion_date = VALUES(promotion_date), reason = VALUES(reason), approver_ckey = VALUES(approver_ckey),
			salary_increase = VALUES(salary_increase), clearance_increase = VALUES(clearance_increase)
		"}, list(
			"promotion_id" = promotion_id,
			"employee_ckey" = promotion.employee_ckey,
			"old_position" = promotion.old_position,
			"new_position" = promotion.new_position,
			"promotion_date" = promotion.promotion_date,
			"reason" = promotion.reason,
			"approver_ckey" = promotion.approver_ckey,
			"salary_increase" = promotion.salary_increase,
			"clearance_increase" = promotion.clearance_increase
		))

		if(!query_save_promotion.warn_execute())
			world.log << "Personnel Persistence: Failed to save promotion [promotion_id]"
		qdel(query_save_promotion)

	world.log << "Personnel Persistence: Saved [length(personnel_records)] personnel records, [length(assignments)] assignments, [length(performance_reviews)] reviews, [length(training_records)] training records, and [length(promotions)] promotions to database"

/datum/personnel_persistence_manager/proc/load_personnel_data()
	// First, load existing records from datacore
	load_existing_personnel_records()

	// Load from database first (takes precedence)
	load_personnel_data_from_database()

	// Then load from persistent storage (JSON fallback)
	var/savefile/S = new /savefile("data/personnel_persistence.json")
	if(!S["data"])
		return

	var/json_data
	S["data"] >> json_data

	var/list/data = json_decode(json_data)
	if(!data)
		return

	// Load personnel records
	if(data["personnel_records"])
		for(var/ckey in data["personnel_records"])
			var/list/record_data = data["personnel_records"][ckey]
			var/datum/personnel_record/record = new /datum/personnel_record(ckey, record_data["real_name"], record_data["department"], record_data["position"])
			record.employee_id = record_data["employee_id"]
			record.hire_date = record_data["hire_date"]
			record.clearance_level = record_data["clearance_level"]
			record.performance_rating = record_data["performance_rating"]
			record.salary = record_data["salary"]
			record.status = record_data["status"]
			record.skills = record_data["skills"]
			record.certifications = record_data["certifications"]
			record.emergency_contact = record_data["emergency_contact"]
			record.last_updated = record_data["last_updated"]
			personnel_records[ckey] = record
			if(record.status == "ACTIVE")
				active_staff++

	// Load assignments
	if(data["assignments"])
		for(var/assignment_id in data["assignments"])
			var/list/assignment_data = data["assignments"][assignment_id]
			var/datum/assignment/assignment = new /datum/assignment(assignment_id, assignment_data["employee_ckey"], assignment_data["assignment_type"], assignment_data["assignment_description"], assignment_data["supervisor_ckey"])
			assignment.start_date = assignment_data["start_date"]
			assignment.end_date = assignment_data["end_date"]
			assignment.status = assignment_data["status"]
			assignment.priority = assignment_data["priority"]
			assignment.completion_rating = assignment_data["completion_rating"]
			assignment.notes = assignment_data["notes"]
			assignments[assignment_id] = assignment

	// Load performance reviews
	if(data["performance_reviews"])
		for(var/review_id in data["performance_reviews"])
			var/list/review_data = data["performance_reviews"][review_id]
			var/datum/performance_review/review = new /datum/performance_review(review_id, review_data["employee_ckey"], review_data["reviewer_ckey"])
			review.review_date = review_data["review_date"]
			review.performance_rating = review_data["performance_rating"]
			review.strengths = review_data["strengths"]
			review.weaknesses = review_data["weaknesses"]
			review.goals = review_data["goals"]
			review.overall_assessment = review_data["overall_assessment"]
			review.next_review_date = review_data["next_review_date"]
			performance_reviews[review_id] = review

	// Load training records
	if(data["training_records"])
		for(var/training_id in data["training_records"])
			var/list/training_data = data["training_records"][training_id]
			var/datum/training_record/training = new /datum/training_record(training_id, training_data["employee_ckey"], training_data["training_type"], training_data["training_name"], training_data["trainer_ckey"])
			training.training_date = training_data["training_date"]
			training.completion_date = training_data["completion_date"]
			training.status = training_data["status"]
			training.score = training_data["score"]
			training.certification_expiry = training_data["certification_expiry"]
			training.notes = training_data["notes"]
			training_records[training_id] = training

	// Load promotions
	if(data["promotions"])
		for(var/promotion_id in data["promotions"])
			var/list/promotion_data = data["promotions"][promotion_id]
			var/datum/promotion/promotion = new /datum/promotion(promotion_id, promotion_data["employee_ckey"], promotion_data["old_position"], promotion_data["new_position"], promotion_data["approver_ckey"])
			promotion.promotion_date = promotion_data["promotion_date"]
			promotion.reason = promotion_data["reason"]
			promotion.salary_increase = promotion_data["salary_increase"]
			promotion.clearance_increase = promotion_data["clearance_increase"]
			promotions[promotion_id] = promotion

	// Load global statistics
	if(data["global_stats"])
		var/list/stats = data["global_stats"]
		total_staff = stats["total_staff"]
		personnel_budget = stats["personnel_budget"]
		staff_satisfaction = stats["staff_satisfaction"]
		turnover_rate = stats["turnover_rate"]
		average_performance = stats["average_performance"]
		training_completion_rate = stats["training_completion_rate"]

/datum/personnel_persistence_manager/proc/load_personnel_data_from_database()
	if(!SSdbcore.Connect())
		world.log << "Personnel Persistence: Database connection failed, skipping database load"
		return

	// Temporarily disabled database loading to fix compilation issues
	world.log << "Personnel Persistence: Database loading temporarily disabled"
	return

	/*
	// Load personnel records from database
	var/datum/db_query/query_load_personnel = SSdbcore.NewQuery(
		"SELECT ckey, real_name, employee_id, department, position, hire_date, clearance_level, performance_rating, salary, status, skills, certifications, emergency_contact, last_updated FROM [format_table_name('personnel_records')]"
	)
	if(!query_load_personnel.warn_execute())
		world.log << "Personnel Persistence: Could not load personnel records from database (table may not exist)"
		qdel(query_load_personnel)
	else
		while(query_load_personnel.NextRow())
			var/ckey = query_load_personnel.item[1]
			var/real_name = query_load_personnel.item[2]
			var/employee_id = query_load_personnel.item[3]
			var/department = query_load_personnel.item[4]
			var/position = query_load_personnel.item[5]
			var/hire_date = query_load_personnel.item[6]
			var/clearance_level = text2num(query_load_personnel.item[7])
			var/performance_rating = text2num(query_load_personnel.item[8])
			var/salary = text2num(query_load_personnel.item[9])
			var/status = query_load_personnel.item[10]
			var/skills = json_decode(query_load_personnel.item[11] || "[]")
			var/certifications = json_decode(query_load_personnel.item[12] || "[]")
			var/emergency_contact = query_load_personnel.item[13]
			var/last_updated = query_load_personnel.item[14]

			var/datum/personnel_record/record = new /datum/personnel_record(ckey, real_name, department, position)
			record.employee_id = employee_id
			record.hire_date = hire_date
			record.clearance_level = clearance_level
			record.performance_rating = performance_rating
			record.salary = salary
			record.status = status
			record.skills = skills
			record.certifications = certifications
			record.emergency_contact = emergency_contact
			record.last_updated = last_updated
			personnel_records[ckey] = record
			if(record.status == "ACTIVE")
				active_staff++
		qdel(query_load_personnel)

	// Load assignments from database
	var/datum/db_query/query_load_assignments = SSdbcore.NewQuery(
		"SELECT assignment_id, employee_ckey, assignment_type, assignment_description, start_date, end_date, status, priority, completion_rating, supervisor_ckey, notes FROM [format_table_name('personnel_assignments')]"
	)
	if(!query_load_assignments.warn_execute())
		world.log << "Personnel Persistence: Could not load assignments from database (table may not exist)"
		qdel(query_load_assignments)
	else
		while(query_load_assignments.NextRow())
			var/assignment_id = query_load_assignments.item[1]
			var/employee_ckey = query_load_assignments.item[2]
			var/assignment_type = query_load_assignments.item[3]
			var/assignment_description = query_load_assignments.item[4]
			var/start_date = query_load_assignments.item[5]
			var/end_date = query_load_assignments.item[6]
			var/status = query_load_assignments.item[7]
			var/priority = text2num(query_load_assignments.item[8])
			var/completion_rating = text2num(query_load_assignments.item[9])
			var/supervisor_ckey = query_load_assignments.item[10]
			var/notes = query_load_assignments.item[11]

			var/datum/assignment/assignment = new /datum/assignment(assignment_id, employee_ckey, assignment_type, assignment_description, supervisor_ckey)
			assignment.start_date = start_date
			assignment.end_date = end_date
			assignment.status = status
			assignment.priority = priority
			assignment.completion_rating = completion_rating
			assignment.notes = notes
			assignments[assignment_id] = assignment
		qdel(query_load_assignments)

	// Load performance reviews from database
	var/datum/db_query/query_load_reviews = SSdbcore.NewQuery(
		"SELECT review_id, employee_ckey, reviewer_ckey, review_date, performance_rating, strengths, weaknesses, goals, overall_assessment, next_review_date FROM [format_table_name('personnel_performance_reviews')]"
	)
	if(!query_load_reviews.warn_execute())
		world.log << "Personnel Persistence: Could not load performance reviews from database (table may not exist)"
		qdel(query_load_reviews)
	else
		while(query_load_reviews.NextRow())
			var/review_id = query_load_reviews.item[1]
			var/employee_ckey = query_load_reviews.item[2]
			var/reviewer_ckey = query_load_reviews.item[3]
			var/review_date = query_load_reviews.item[4]
			var/performance_rating = text2num(query_load_reviews.item[5])
			var/strengths = query_load_reviews.item[6]
			var/weaknesses = query_load_reviews.item[7]
			var/goals = query_load_reviews.item[8]
			var/overall_assessment = query_load_reviews.item[9]
			var/next_review_date = query_load_reviews.item[10]

			var/datum/performance_review/review = new /datum/performance_review(review_id, employee_ckey, reviewer_ckey)
			review.review_date = review_date
			review.performance_rating = performance_rating
			review.strengths = strengths
			review.weaknesses = weaknesses
			review.goals = goals
			review.overall_assessment = overall_assessment
			review.next_review_date = next_review_date
			performance_reviews[review_id] = review
		qdel(query_load_reviews)

	// Load training records from database
	var/datum/db_query/query_load_training = SSdbcore.NewQuery(
		"SELECT training_id, employee_ckey, training_type, training_name, training_date, completion_date, status, score, certification_expiry, trainer_ckey, notes FROM [format_table_name('personnel_training_records')]"
	)
	if(!query_load_training.warn_execute())
		world.log << "Personnel Persistence: Could not load training records from database (table may not exist)"
		qdel(query_load_training)
	else
		while(query_load_training.NextRow())
			var/training_id = query_load_training.item[1]
			var/employee_ckey = query_load_training.item[2]
			var/training_type = query_load_training.item[3]
			var/training_name = query_load_training.item[4]
			var/training_date = query_load_training.item[5]
			var/completion_date = query_load_training.item[6]
			var/status = query_load_training.item[7]
			var/score = text2num(query_load_training.item[8])
			var/certification_expiry = query_load_training.item[9]
			var/trainer_ckey = query_load_training.item[10]
			var/notes = query_load_training.item[11]

			var/datum/training_record/training = new /datum/training_record(training_id, employee_ckey, training_type, training_name, trainer_ckey)
			training.training_date = training_date
			training.completion_date = completion_date
			training.status = status
			training.score = score
			training.certification_expiry = certification_expiry
			training.notes = notes
			training_records[training_id] = training
		qdel(query_load_training)

	// Load promotions from database
	var/datum/db_query/query_load_promotions = SSdbcore.NewQuery(
		"SELECT promotion_id, employee_ckey, old_position, new_position, promotion_date, reason, approver_ckey, salary_increase, clearance_increase FROM [format_table_name('personnel_promotions')]"
	)
	if(!query_load_promotions.warn_execute())
		world.log << "Personnel Persistence: Could not load promotions from database (table may not exist)"
		qdel(query_load_promotions)
	else
		while(query_load_promotions.NextRow())
			var/promotion_id = query_load_promotions.item[1]
			var/employee_ckey = query_load_promotions.item[2]
			var/old_position = query_load_promotions.item[3]
			var/new_position = query_load_promotions.item[4]
			var/promotion_date = query_load_promotions.item[5]
			var/reason = query_load_promotions.item[6]
			var/approver_ckey = query_load_promotions.item[7]
			var/salary_increase = text2num(query_load_promotions.item[8])
			var/clearance_increase = text2num(query_load_promotions.item[9])

			var/datum/promotion/promotion = new /datum/promotion(promotion_id, employee_ckey, old_position, new_position, approver_ckey)
			promotion.promotion_date = promotion_date
			promotion.reason = reason
			promotion.salary_increase = salary_increase
			promotion.clearance_increase = clearance_increase
			promotions[promotion_id] = promotion
		qdel(query_load_promotions)

	world.log << "Personnel Persistence: Loaded [length(personnel_records)] personnel records, [length(assignments)] assignments, [length(performance_reviews)] reviews, [length(training_records)] training records, and [length(promotions)] promotions from database"
	*/

// Subsystem initialization
/datum/controller/subsystem/personnel_persistence/Initialize()
	world.log << "Personnel persistence subsystem initializing..."
	manager = new /datum/personnel_persistence_manager()
	world.log << "Personnel persistence manager created"

	// Load existing personnel records from datacore
	world.log << "Loading existing personnel records from datacore..."
	manager.load_existing_personnel_records()

	world.log << "Personnel records count at initialization: [length(manager.personnel_records)]"
	return ..()

/datum/controller/subsystem/personnel_persistence/fire()
	if(manager)
		manager.process_personnel()

// Sync with existing crew records system
/datum/personnel_persistence_manager/proc/sync_with_crew_records(var/ckey, var/real_name, var/department, var/position)
	// Check if record already exists in datacore
	var/datum/data/record/general/existing_record = SSdatacore.find_record("name", real_name, DATACORE_RECORDS_STATION)
	if(!existing_record)
		// Create new record in datacore if it doesn't exist
		var/datum/data/record/general/new_record = new /datum/data/record/general()
		new_record.fields[DATACORE_NAME] = real_name
		new_record.fields[DATACORE_RANK] = position
		new_record.fields[DATACORE_AGE] = 30 // Default age
		new_record.fields[DATACORE_GENDER] = "Other" // Default gender
		new_record.fields[DATACORE_SPECIES] = "Human" // Default species
		new_record.fields[DATACORE_PHYSICAL_HEALTH] = "Active"
		new_record.fields[DATACORE_MENTAL_HEALTH] = "Stable"

		// Add to datacore
		SSdatacore.library[DATACORE_RECORDS_STATION].inject_record(new_record)

		// Create medical record
		var/datum/data/record/medical/medical_record = new /datum/data/record/medical()
		medical_record.fields[DATACORE_NAME] = real_name
		medical_record.fields[DATACORE_BLOOD_TYPE] = "O+"
		medical_record.fields[DATACORE_DISABILITIES] = "None"
		medical_record.fields[DATACORE_NOTES] = "No medical notes."
		SSdatacore.library[DATACORE_RECORDS_MEDICAL].inject_record(medical_record)

		// Create security record
		var/datum/data/record/security/security_record = new /datum/data/record/security()
		security_record.fields[DATACORE_NAME] = real_name
		security_record.fields[DATACORE_CRIMINAL_STATUS] = CRIMINAL_NONE
		security_record.fields[DATACORE_CITATIONS] = list()
		security_record.fields[DATACORE_CRIMES] = list()
		security_record.fields[DATACORE_NOTES] = "No security notes."
		SSdatacore.library[DATACORE_RECORDS_SECURITY].inject_record(security_record)
	else
		// Update existing record
		existing_record.fields[DATACORE_RANK] = position
		existing_record.fields[DATACORE_PHYSICAL_HEALTH] = "Active"
		existing_record.fields[DATACORE_MENTAL_HEALTH] = "Stable"

// Add department (updated)
/datum/personnel_persistence_manager/proc/add_department(var/dept_name, var/dept_head, var/budget = 1000000)
	var/datum/assignment/dept = new /datum/assignment("DEPT_[dept_name]", dept_head, "Department Management")
	dept.status = "ACTIVE"
	dept.start_date = world.time
	assignments["DEPT_[dept_name]"] = dept
	return dept

// Add training program (updated)
/datum/personnel_persistence_manager/proc/add_training_program(var/program_name, var/instructor, var/duration = 2)
	var/training_id = "TRAINING_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/training_record/program = new /datum/training_record(training_id, instructor, "ADMIN", program_name, instructor)
	program.status = "IN_PROGRESS"
	training_records[training_id] = program
	return program

// Add performance review (updated)
/datum/personnel_persistence_manager/proc/add_performance_review(var/employee_ckey, var/reviewer, var/rating = 75, var/notes = "")
	var/review_id = "PERF_[time2text(world.time, "YYYYMMDD_HHMMSS")]"
	var/datum/performance_review/review = new /datum/performance_review(review_id, employee_ckey, reviewer)
	review.performance_rating = rating
	review.overall_assessment = notes
	performance_reviews[review_id] = review
	return review

// Advanced personnel management procedures
/datum/personnel_persistence_manager/proc/process_promotions()
	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		if(record.performance_rating >= 90) // High performance for promotion
			var/promotion_chance = rand(1, 100)
			if(promotion_chance <= 10) // 10% chance for promotion
				var/new_position = get_next_position(record.position)
				if(new_position)
					add_promotion(ckey, new_position, "SYSTEM", rand(5000, 15000), 1)
					record.performance_rating = max(50, record.performance_rating - 10) // Reset rating after promotion

/datum/personnel_persistence_manager/proc/get_next_position(var/current_position)
	var/list/position_hierarchy = list(
		"Junior Researcher" = "Senior Researcher",
		"Senior Researcher" = "Lead Researcher",
		"Lead Researcher" = "Research Director",
		"Security Guard" = "Security Officer",
		"Security Officer" = "Security Sergeant",
		"Security Sergeant" = "Security Lieutenant",
		"Medical Intern" = "Medical Doctor",
		"Medical Doctor" = "Senior Doctor",
		"Senior Doctor" = "Chief Medical Officer",
		"Maintenance Technician" = "Senior Technician",
		"Senior Technician" = "Chief Engineer"
	)
	return position_hierarchy[current_position]

/datum/personnel_persistence_manager/proc/process_training_completion()
	for(var/training_id in training_records)
		var/datum/training_record/training = training_records[training_id]
		if(training.status == "IN_PROGRESS")
			var/completion_chance = rand(1, 100)
			if(completion_chance <= 15) // 15% chance to complete training
				training.status = "COMPLETED"
				training.completion_date = world.time
				training.score = rand(70, 100)

				// Update employee record
				var/datum/personnel_record/record = personnel_records[training.employee_ckey]
				if(record)
					record.certifications += training.training_name
					record.performance_rating = min(100, record.performance_rating + 5)

/datum/personnel_persistence_manager/proc/process_attrition()
	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		if(record.status == "ACTIVE")
			var/attrition_chance = rand(1, 100)
			// Higher chance of leaving if performance is low or satisfaction is low
			if(record.performance_rating < 50)
				attrition_chance += 20
			if(staff_satisfaction < 60)
				attrition_chance += 15

			if(attrition_chance <= 5) // 5% base chance, can go up to 40%
				record.status = "RESIGNED"
				record.last_updated = world.time
				active_staff = max(0, active_staff - 1)

/datum/personnel_persistence_manager/proc/update_staff_satisfaction()
	var/total_satisfaction = 0
	var/active_count = 0

	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		if(record.status == "ACTIVE")
			var/individual_satisfaction = 50 // Base satisfaction

			// Factors affecting satisfaction
			if(record.performance_rating >= 80)
				individual_satisfaction += 20
			else if(record.performance_rating < 50)
				individual_satisfaction -= 20

			if(record.salary >= 75000)
				individual_satisfaction += 10
			else if(record.salary < 40000)
				individual_satisfaction -= 10

			if(record.clearance_level >= 3)
				individual_satisfaction += 5

			// Random variation
			individual_satisfaction += rand(-10, 10)
			individual_satisfaction = max(0, min(100, individual_satisfaction))

			total_satisfaction += individual_satisfaction
			active_count++

	if(active_count > 0)
		staff_satisfaction = total_satisfaction / active_count
	else
		staff_satisfaction = 50

/datum/personnel_persistence_manager/proc/calculate_average_performance()
	var/total_performance = 0
	var/active_count = 0

	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		if(record.status == "ACTIVE")
			total_performance += record.performance_rating
			active_count++

	if(active_count > 0)
		average_performance = total_performance / active_count
	else
		average_performance = 75

/datum/personnel_persistence_manager/proc/calculate_training_completion_rate()
	var/completed_training = 0
	var/total_training = length(training_records)

	for(var/training_id in training_records)
		var/datum/training_record/training = training_records[training_id]
		if(training.status == "COMPLETED")
			completed_training++

	if(total_training > 0)
		training_completion_rate = completed_training / total_training
	else
		training_completion_rate = 0

// Export personnel data
/datum/personnel_persistence_manager/proc/export_personnel_data()
	var/list/export_data = list()
	export_data["employees"] = list()
	export_data["departments"] = list()
	export_data["training"] = list()
	export_data["performance"] = list()
	export_data["promotions"] = list()

	// Export employee records
	for(var/ckey in personnel_records)
		var/datum/personnel_record/record = personnel_records[ckey]
		export_data["employees"][ckey] = list(
			"real_name" = record.real_name,
			"department" = record.department,
			"position" = record.position,
			"salary" = record.salary,
			"clearance_level" = record.clearance_level,
			"performance_rating" = record.performance_rating,
			"status" = record.status,
			"hire_date" = record.hire_date,
			"last_updated" = record.last_updated
		)

	// Export department data
	for(var/assignment_id in assignments)
		var/datum/assignment/assignment = assignments[assignment_id]
		if(findtext(assignment_id, "DEPT_"))
			var/dept_name = copytext(assignment_id, 6) // Remove "DEPT_" prefix
			export_data["departments"][dept_name] = list(
				"head" = assignment.employee_ckey,
				"status" = assignment.status,
				"start_date" = assignment.start_date
			)

	// Export training records
	for(var/training_id in training_records)
		var/datum/training_record/training = training_records[training_id]
		export_data["training"][training_id] = list(
			"employee_ckey" = training.employee_ckey,
			"training_name" = training.training_name,
			"trainer_ckey" = training.trainer_ckey,
			"status" = training.status,
			"completion_date" = training.completion_date,
			"score" = training.score
		)

	// Export performance reviews
	for(var/review_id in performance_reviews)
		var/datum/performance_review/review = performance_reviews[review_id]
		export_data["performance"][review_id] = list(
			"employee_ckey" = review.employee_ckey,
			"reviewer_ckey" = review.reviewer_ckey,
			"performance_rating" = review.performance_rating,
			"overall_assessment" = review.overall_assessment,
			"review_date" = review.review_date,
			"status" = "COMPLETED"
		)

	// Export promotions
	for(var/promotion_id in promotions)
		var/datum/promotion/promotion = promotions[promotion_id]
		export_data["promotions"][promotion_id] = list(
			"employee_ckey" = promotion.employee_ckey,
			"old_position" = promotion.old_position,
			"new_position" = promotion.new_position,
			"approver_ckey" = promotion.approver_ckey,
			"salary_increase" = promotion.salary_increase,
			"clearance_increase" = promotion.clearance_increase,
			"promotion_date" = promotion.promotion_date
		)

	return json_encode(export_data)

// Load all existing personnel records from SSdatacore
/datum/personnel_persistence_manager/proc/load_existing_personnel_records()
	if(!SSdatacore)
		return

	world.log << "Personnel: Loading existing personnel records from datacore..."

	// Load from general records (station records)
	for(var/datum/data/record/general_record in SSdatacore.get_records(DATACORE_RECORDS_STATION))
		if(general_record.fields[DATACORE_NAME])
			var/ckey = ckey(general_record.fields[DATACORE_NAME])
			if(!(ckey in personnel_records))
				var/department = "General"
				var/position = general_record.fields[DATACORE_RANK] || "Staff"
				var/clearance_level = 1
				var/performance_rating = 80

				// Determine department based on rank/position
				if(findtext(position, "Doctor") || findtext(position, "Medical") || findtext(position, "Nurse"))
					department = "Medical"
				else if(findtext(position, "Security") || findtext(position, "Guard") || findtext(position, "Agent"))
					department = "Security"
				else if(findtext(position, "Research") || findtext(position, "Scientist"))
					department = "Research"
				else if(findtext(position, "Engineer") || findtext(position, "Technician"))
					department = "Engineering"
				else if(findtext(position, "Admin") || findtext(position, "Director"))
					department = "Administration"

				// Set clearance level based on position
				if(findtext(position, "Chief") || findtext(position, "Director") || findtext(position, "Lead"))
					clearance_level = 4
				else if(findtext(position, "Senior") || findtext(position, "Sergeant"))
					clearance_level = 3
				else if(findtext(position, "Officer") || findtext(position, "Doctor"))
					clearance_level = 2
				else
					clearance_level = 1

				// Set performance rating based on health status
				if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "*Deceased*")
					performance_rating = 0
				else if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "*Unconscious*")
					performance_rating = 25
				else if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "Physically Unfit")
					performance_rating = 50
				else if(general_record.fields[DATACORE_PHYSICAL_HEALTH] == "Active")
					performance_rating = 80

				if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Insane*")
					performance_rating = max(0, performance_rating - 50)
				else if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Unstable*")
					performance_rating = max(0, performance_rating - 25)
				else if(general_record.fields[DATACORE_MENTAL_HEALTH] == "*Watch*")
					performance_rating = max(0, performance_rating - 10)

				var/datum/personnel_record/personnel_record = new /datum/personnel_record(ckey, general_record.fields[DATACORE_NAME], department, position)
				personnel_record.clearance_level = clearance_level
				personnel_record.performance_rating = performance_rating
				personnel_record.salary = 50000 + (clearance_level * 10000)
				personnel_record.status = "ACTIVE"
				personnel_record.last_updated = world.time
				personnel_records[ckey] = personnel_record

				world.log << "Personnel: Loaded record for [general_record.fields[DATACORE_NAME]] ([department] - [position])"

	// Update total staff count
	total_staff = length(personnel_records)
	active_staff = total_staff

	world.log << "Personnel: Loaded [length(personnel_records)] personnel records from datacore"

// Clear persistent storage to ensure only real data is used
/datum/personnel_persistence_manager/proc/clear_persistent_storage()
	// Clear all existing data
	personnel_records.Cut()
	assignments.Cut()
	performance_reviews.Cut()
	training_records.Cut()
	promotions.Cut()
	total_staff = 0
	active_staff = 0

	// Delete the persistent storage file
	var/savefile/S = new /savefile("data/personnel_persistence.json")
	if(S)
		S["data"] << null
		world.log << "Personnel: Cleared persistent storage file"

	world.log << "Personnel: Cleared all persistent storage data"


