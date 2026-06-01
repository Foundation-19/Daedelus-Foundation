// SCP-066 signals
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/attack_target(): ()
#define COMSIG_SCP066_ATTACK_TARGET "scp066_attack_target"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/handle_autohiss(): ()
#define COMSIG_SCP066_AUTOHISS "scp066_autohiss"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/proc/Noise(): ()
#define COMSIG_SCP066_NOISE_EMOTE "scp066_noise_emote"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/proc/Eric(): ()
#define COMSIG_SCP066_ERIC_EMOTE "scp066_eric_emote"
/// From base of /mob/living/simple_animal/hostile/retaliate/scp066/proc/LoudNoise(): ()
#define COMSIG_SCP066_LOUD_NOISE_EMOTE "scp066_loud_noise_emote"

// SCP-216 signals
/// Sent when the safe is opened.
#define COMSIG_SCP216_OPEN "scp216_open"
/// Sent when the safe is closed.
#define COMSIG_SCP216_CLOSE "scp216_close"
/// Sent when a mob falls out of the safe upon opening. (mob/living/mob_released)
#define COMSIG_SCP216_MOB_RELEASED "scp216_mob_released"
/// Sent after an item is successfully inserted into the safe. (atom/movable/inserted_item, mob/user)
#define COMSIG_SCP216_ITEM_INSERTED "scp216_item_inserted"
/// Sent after an item is successfully retrieved from the safe. (atom/movable/retrieved_item, mob/user)
#define COMSIG_SCP216_ITEM_RETRIEVED "scp216_item_retrieved"
/// Sent when the safe's combination code is successfully changed. (int/new_code)
#define COMSIG_SCP216_CODE_CHANGED "scp216_code_changed"
/// Sent after random items are generated for a new code. (int/code)
#define COMSIG_SCP216_ITEMS_GENERATED "scp216_items_generated"
/// Sent when an item is temporally displaced by SCP-216. (atom/movable/displaced_item, mob/user)
#define COMSIG_SCP216_TEMPORAL_DISPLACEMENT "scp216_temporal_displacement"

// SCP-151 signals
/// from /obj/structure/scp151/proc/effect(): (mob/living/carbon/human/H, obj/structure/scp151/source_scp)
#define COMSIG_SCP151_EFFECT_APPLIED "scp151_effect_applied"

// SCP-113 signals
#define COMSIG_SCP113_EFFECT_STAGE_1 "scp113_effect_stage_1"
#define COMSIG_SCP113_EFFECT_STAGE_2 "scp113_effect_stage_2"
#define COMSIG_SCP113_EFFECT_STAGE_3 "scp113_effect_stage_3"
#define COMSIG_SCP113_EFFECT_STAGE_4 "scp113_effect_stage_4"

// SCP-294 signals
#define COMSIG_SCP294_DISPENSE_ATTEMPT "scp294_dispense_attempt"

// SCP-610 breach/recontainment signals
#define COMSIG_SCP_BREACH "comsig_scp_breach"
#define COMSIG_SCP_RECONTAINED "comsig_scp_recontained"
