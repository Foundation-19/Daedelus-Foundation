/datum/self_destruct_config
    // This datum holds the default configuration for self-destruct milestones and profiles.
    // It can be extended or overridden to provide different self-destruct presets.
	// We validate that only one time type is set (relative or absolute), and if both are, we force absolute.
	// We assume a default countdown minimum of 300 seconds (5m), but this might change in the future, so be careful with absolutes.

    var/list/default_milestones
    var/list/default_profiles

/datum/self_destruct_config/New()
	. = ..()
	default_milestones = list()
	var/datum/self_destruct_milestone/milestone_alarm_5 = new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_5), relative_percentage = 1)
	var/datum/self_destruct_milestone/milestone_delta_alert = new /datum/self_destruct_milestone(list(SD_EFFECT_DELTAALERT), relative_percentage = 0.98) // 294s in 5m countdown, just enough for Alarm5 to finish.
	var/datum/self_destruct_milestone/milestone_alarm_4 = new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_4), relative_percentage = 0.8)
	var/datum/self_destruct_milestone/milestone_alarm_3 = new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_3), relative_percentage = 0.6)
	var/datum/self_destruct_milestone/milestone_alarm_2 = new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_2), relative_percentage = 0.4)
	var/datum/self_destruct_milestone/milestone_alarm_1 = new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_1), relative_percentage = 0.2, absolute_minimum = 20) // Takes about 17 seconds to play, alarm.ogg plays at 0.
	var/datum/self_destruct_milestone/milestone_final = new /datum/self_destruct_milestone(list(SD_EFFECT_FINAL_DESTRUCTION), absolute_offset = 0)

	default_milestones += milestone_alarm_5
	default_milestones += milestone_delta_alert
	default_milestones += milestone_alarm_4
	default_milestones += milestone_alarm_3
	default_milestones += milestone_alarm_2
	default_milestones += milestone_alarm_1
	default_milestones += milestone_final

	default_profiles = list(
		/datum/self_destruct_profile/self_destruct_light_profile,
		/datum/self_destruct_profile/self_destruct_mechanical_profile,
		/datum/self_destruct_profile/self_destruct_sound_profile,
		/datum/self_destruct_profile/self_destruct_explosion_profile
	)

/*
// Example of a custom self-destruct configuration:
/datum/self_destruct_config/my_custom_preset
    default_milestones = list(
        new /datum/self_destruct_milestone(list(SD_EFFECT_LIGHTS_RED, SD_EFFECT_INTENSE_ALARM), relative_percentage = 1.0),
        new /datum/self_destruct_milestone(list(SD_EFFECT_HULL_BREACH), absolute_offset = 120),
        new /datum/self_destruct_milestone(list(SD_EFFECT_ALARM_5), relative_percentage = 0.8, absolute_minimum = 60), 90 * .8 = 72, effect triggers at 72 seconds with 90 second countdown.
        new /datum/self_destruct_milestone(list(SD_EFFECT_FINAL_DESTRUCTION), absolute_offset = 0)
    )
    default_profiles = list(
        /datum/self_destruct_light_profile,
        /datum/self_destruct_sound_profile // Only sound and light profiles
		/datum/self_destruct_custom_explosion_profile
		Etc..
    )

// You should /probably/ include some type of Final Destruction event in a self_destruct sequence..we won't handhold though.
*/

/datum/self_destruct_config/proc/get_default_milestones()
    return default_milestones

/datum/self_destruct_config/proc/get_default_profiles()
    return default_profiles
