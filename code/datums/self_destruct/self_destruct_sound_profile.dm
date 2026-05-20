/datum/self_destruct_profile/self_destruct_sound_profile
	var/datum/self_destruct_controller/controller // Reference to the controller
	var/siren_loop_sound_path = 'sound/effects/selfdestruct/sirenloop.ogg'

/datum/self_destruct_profile/self_destruct_sound_profile/New(datum/self_destruct_controller/new_controller)
	. = ..()
	controller = new_controller

	// Register for signals from the controller
	RegisterSignal(controller, SD_SIGNAL_START, PROC_REF(on_start_signal))
	RegisterSignal(controller, list(SD_SIGNAL_PAUSE, SD_SIGNAL_CANCEL), PROC_REF(on_stop_signal))
	RegisterSignal(controller, SD_SIGNAL_RESUME, PROC_REF(on_resume_signal))
	RegisterSignal(controller, SD_SIGNAL_FINAL, PROC_REF(on_final_destruction_signal))
	RegisterSignal(controller, SD_SIGNAL_MILESTONE, PROC_REF(on_milestone_signal))

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_start_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Sound Profile: On Start Signal received.")
	stop_all_siren_sounds() // Stop all siren-related sounds and timers

	sound_to_playing_players(siren_loop_sound_path, 30, FALSE, null, CHANNEL_SELF_DESTRUCT_AMBIENCE, loop = TRUE)

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_stop_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Sound Profile: On Stop Signal received.")
	stop_all_siren_sounds() // Stop all siren-related sounds and timers
	stop_alarm_sound() // Ensure alarm sound is stopped on pause/cancel

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_resume_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Sound Profile: On Resume Signal received.")
	stop_all_siren_sounds()
	sound_to_playing_players(siren_loop_sound_path, 30, FALSE, null, CHANNEL_SELF_DESTRUCT_AMBIENCE, loop = TRUE)

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_final_destruction_signal(datum/self_destruct_controller/controller_instance, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Sound Profile: On Final Destruction Signal received.")
	stop_all_siren_sounds()
	stop_alarm_sound()
	// Play final destruction sound
	sound_to_playing_players('sound/machines/alarm.ogg', 30, FALSE, null, CHANNEL_SELF_DESTRUCT_DETONATION) // Play alarm.ogg for final destruction

/datum/self_destruct_profile/self_destruct_sound_profile/proc/on_milestone_signal(datum/self_destruct_controller/controller_instance, effect_type, data = null)
	SIGNAL_HANDLER
	log_game("Self-destruct Sound Profile: On Milestone Signal received for effect type: [effect_type].")
	// Handle specific effects directly
	switch(effect_type)
		if(SD_EFFECT_DELTAALERT)
			sound_to_playing_players('sound/ai/default/delta.ogg', 40, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_5)
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm5Tone.ogg', 25, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_4)
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm4Tone.ogg', 30, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_3)
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm3Tone.ogg', 35, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_2)
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm2Tone.ogg', 40, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)
		if(SD_EFFECT_ALARM_1)
			sound_to_playing_players('sound/effects/selfdestruct/SelfDestructAlarm1Tone.ogg', 45, FALSE, null, CHANNEL_SELF_DESTRUCT_ALARM)



/datum/self_destruct_profile/self_destruct_sound_profile/proc/stop_all_siren_sounds()
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.stop_sound_channel(CHANNEL_SELF_DESTRUCT_AMBIENCE) // For the entrance sound

/datum/self_destruct_profile/self_destruct_sound_profile/proc/stop_alarm_sound()
	// Stop all sounds on the self-destruct alarm channel
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.stop_sound_channel(CHANNEL_SELF_DESTRUCT_ALARM)
