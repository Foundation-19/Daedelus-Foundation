// SCP-049 Species Definition from Foundation-19 PR #13
// Defines the biological traits and characteristics of SCP-049

/datum/species/scp049
	name = "\improper SCP-049"
	plural_form = "SCP-049 instances"
	id = SPECIES_SCP049

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, BODY_RESIZABLE, HAIRCOLOR, FACEHAIRCOLOR)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_NOHUNGER,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOCLONELOSS,
		TRAIT_TOXIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NO_SLIP_ALL
	)
	inherent_biotypes = MOB_HUMANOID | MOB_UNDEAD

	mutant_bodyparts = list("wings" = "None")
	use_skintones = 0 // SCP-049 doesn't use skin tones

	liked_food = JUNKFOOD | FRIED
	disliked_food = TOXIC | RAW | GROSS

	// Temperature resistance
	coldmod = 0.5
	heatmod = 0.5
	burnmod = 0.5
	brutemod = 0.8

	// Special SCP-049 characteristics
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	// Visual characteristics
	meat = /obj/item/food/meat/slab/human/mutant/skeleton
	skinned_type = /obj/item/stack/sheet/bone

	/// List of emotes with cooldowns
	var/list/emote_cooldowns = list()
	/// Default emote cooldown time
	var/emote_cooldown_time = 3 SECONDS

/datum/species/scp049/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load)
	. = ..()

	// Set up SCP-049 specific traits
	H.real_name = "SCP-049"
	H.name = "SCP-049"

	// Add pestilence HUD capability
	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.add_atom_to_hud(H)

	// Register for pestilence trait updates
	RegisterSignal(H, SIGNAL_ADDTRAIT(TRAIT_PESTILENCE), PROC_REF(on_trait_gain))
	RegisterSignal(H, SIGNAL_REMOVETRAIT(TRAIT_PESTILENCE), PROC_REF(on_trait_loss))

	// Grant cure action
	var/datum/action/scp049cure/cure_action = new()
	cure_action.Grant(H)

	// Add emote cooldown tracking
	emote_cooldowns = list()

/datum/species/scp049/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	// Remove pestilence HUD
	var/datum/atom_hud/data/human/pestilence/pestilence_hud = GLOB.huds[DATA_HUD_PESTILENCE]
	if(pestilence_hud)
		pestilence_hud.remove_atom_from_hud(H)

	// Unregister signals
	UnregisterSignal(H, SIGNAL_ADDTRAIT(TRAIT_PESTILENCE))
	UnregisterSignal(H, SIGNAL_REMOVETRAIT(TRAIT_PESTILENCE))

	// Remove cure action
	for(var/datum/action/scp049cure/cure_action in H.actions)
		cure_action.Remove(H)
		qdel(cure_action)

/datum/species/scp049/proc/on_trait_gain(mob/living/carbon/human/source, trait)
	SIGNAL_HANDLER
	if(trait == TRAIT_PESTILENCE)
		source.update_pestilence_hud()

/datum/species/scp049/proc/on_trait_loss(mob/living/carbon/human/source, trait)
	SIGNAL_HANDLER
	if(trait == TRAIT_PESTILENCE)
		source.update_pestilence_hud()

/datum/species/scp049/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()

	// SCP-049 doesn't need most life processes
	// But we can add special behaviors here

	// Slowly regenerate health when not in combat
	if(H.health < H.maxHealth && !H.has_status_effect(/datum/status_effect/incapacitating))
		H.adjustBruteLoss(-0.5 * seconds_per_tick)
		H.adjustFireLoss(-0.5 * seconds_per_tick)

// Emote system with cooldowns

/datum/species/scp049/proc/can_emote(mob/living/carbon/human/H, emote_key)
	if(emote_key in emote_cooldowns)
		if(world.time < emote_cooldowns[emote_key])
			return FALSE
	return TRUE

/datum/species/scp049/proc/set_emote_cooldown(mob/living/carbon/human/H, emote_key)
	emote_cooldowns[emote_key] = world.time + emote_cooldown_time

// SCP-049 specific outfit handling
/datum/species/scp049/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hairstyle = "Bald"
	human.hair_color = "#000000"
	human.update_body_parts()

// Constants
#ifndef SPECIES_SCP049
#define SPECIES_SCP049 "scp049"
#endif
