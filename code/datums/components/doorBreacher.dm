// Door Breacher Component from Foundation-19 PR #13
// Allows entities to breach through doors with special effects

/datum/component/doorBreacher
	/// The range at which doors can be breached
	var/breach_range = 5
	/// The power/force of the breach
	var/breach_power = 50
	/// Cooldown between breaches
	var/breach_cooldown_time = 120 SECONDS
	/// Current cooldown
	var/breach_cooldown = 0
	/// Sound to play when breaching
	var/breach_sound = 'sound/effects/meteorimpact.ogg'
	/// Message to display when breaching
	var/breach_message = "breaches through the doors!"

/datum/component/doorBreacher/Initialize(range = 5, power = 50, cooldown = 120 SECONDS, sound = null, message = null)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	breach_range = range
	breach_power = power
	breach_cooldown_time = cooldown
	if(sound)
		breach_sound = sound
	if(message)
		breach_message = message

	// Register signal for door breaching
	RegisterSignal(parent, COMSIG_MOB_BREACH_DOORS, PROC_REF(breach_doors))

/datum/component/doorBreacher/proc/breach_doors()
	SIGNAL_HANDLER

	var/mob/living/breacher = parent

	// Check cooldown
	if(world.time < breach_cooldown)
		to_chat(breacher, "<span class='warning'>You need to wait before breaching again...</span>")
		return

	breach_cooldown = world.time + breach_cooldown_time

	// Find doors in range
	var/list/doors_to_breach = list()
	for(var/obj/machinery/door/D in range(breach_range, breacher))
		if(D.density && !D.welded) // Only breach closed, non-welded doors
			doors_to_breach += D

	if(!length(doors_to_breach))
		to_chat(breacher, "<span class='warning'>No doors in range to breach.</span>")
		breach_cooldown = world.time // Reset cooldown if no doors found
		return

	// Breach all doors
	breacher.visible_message("<span class='danger'>[breacher] [breach_message]</span>")
	playsound(breacher, breach_sound, 80, TRUE)

	for(var/obj/machinery/door/D in doors_to_breach)
		breach_single_door(D, breacher)

	// Update any persistence tracking
	if(istype(breacher, /mob/living/scp/scp049))
		var/mob/living/scp/scp049/scp = breacher
		scp.save_persistence_data()

/datum/component/doorBreacher/proc/breach_single_door(obj/machinery/door/door, mob/living/breacher)
	// Force open the door
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open), 1) // Force open

	// Apply damage to the door
	door.take_damage(breach_power)

	// Special effects
	playsound(door, 'sound/effects/bang.ogg', 50, TRUE)

	// Spark effect
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(3, 1, door)
	sparks.start()

	// If door is weak enough, break it
	if(door.get_integrity() <= breach_power)
		door.deconstruct(FALSE)


