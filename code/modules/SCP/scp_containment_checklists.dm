// SCP Containment Procedure Checklists
// TGUI-based containment console that displays per-SCP recontainment procedures

/obj/machinery/scp_containment_console
	name = "Containment Procedures Console"
	desc = "A terminal displaying standardized containment and recontainment procedures for Site-53 SCPs."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	circuit = /obj/item/circuitboard/machine/scp_containment_console
	var/static/list/containment_procedures

/obj/item/circuitboard/machine/scp_containment_console
	name = "Containment Procedures Console (Circuit Board)"
	build_path = /obj/machinery/scp_containment_console

/obj/machinery/scp_containment_console/proc/get_procedures()
	if(containment_procedures)
		return containment_procedures
	containment_procedures = list(
		"SCP-173" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-173 is to be kept in a locked containment chamber with at minimum two (2) personnel present at all times.",
				"Personnel must maintain direct line of sight with SCP-173 at all times when in the containment chamber.",
				"Door to containment chamber must be triple-locked and operated remotely.",
				"Personnel are to alert one another before blinking when in the presence of SCP-173.",
			),
			"recontainment" = list(
				"1. Evacuate all non-essential personnel from the breach zone.",
				"2. Deploy a minimum team of three (3) security personnel to the last known location of SCP-173.",
				"3. Maintain continuous visual contact. Use the buddy system — one blinks while the other watches.",
				"4. Approach from multiple angles simultaneously. SCP-173 cannot move while observed.",
				"5. Guide SCP-173 back to its containment chamber using coordinated visual coverage.",
				"6. Seal the chamber and verify all three (3) locks are engaged.",
				"7. Perform a headcount. Report any casualties to Medical immediately.",
			),
		),
		"SCP-096" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-096 is to be kept in a sealed containment chamber with soundproofing.",
				"No visual recording equipment is permitted within SCP-096's containment chamber.",
				"A bag or hood must be kept over SCP-096's face at all times when personnel are present.",
				"Personnel must NOT look at SCP-096's face under any circumstances.",
			),
			"recontainment" = list(
				"1. If SCP-096 is docile, approach with a bag/hood. DO NOT LOOK AT ITS FACE.",
				"2. If SCP-096 is in a screaming state, evacuate the area immediately.",
				"3. If SCP-096 is pursuing a target, do NOT interfere. Wait for the pursuit to end naturally.",
				"4. After pursuit ends, SCP-096 will enter a grace period. Approach during this window.",
				"5. Place the containment hood over SCP-096's face before the grace period expires.",
				"6. Escort SCP-096 back to containment. All personnel must face away during transit.",
				"7. Secure all cameras that may have viewed SCP-096's face during the breach.",
				"8. Administer Class-A amnestics to all personnel who viewed SCP-096's face.",
			),
		),
		"SCP-106" = list(
			"classification" = "Keter",
			"containment" = list(
				"SCP-106 is to be contained in a primary containment chamber of solid steel lined with lead.",
				"No physical interaction with SCP-106 is permitted under any circumstances.",
				"Containment chamber must be suspended above a magnetic relay system.",
				"All personnel must remain at least 5 meters from SCP-106 at all times.",
			),
			"recontainment" = list(
				"1. Activate the Facility Recall Protocol to lure SCP-106 toward the Femur Breaker.",
				"2. A D-Class personnel must be assigned as bait for the Femur Breaker protocol.",
				"3. The bait must be placed in the Femur Breaker apparatus and the femur fractured.",
				"4. SCP-106 will be drawn to the sound and distress. Maintain observation from a safe distance.",
				"5. Once SCP-106 enters the containment area, activate the magnetic suspension system.",
				"6. Seal all exits. Verify containment integrity is above 80%.",
				"7. DO NOT enter the pocket dimension to retrieve victims. They are considered lost.",
				"8. Document all personnel losses. Report to the Site Director immediately.",
			),
		),
		"SCP-049" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-049 is to be kept in a standard humanoid containment chamber.",
				"Personnel must wear full biohazard suits when in proximity to SCP-049.",
				"SCP-049 is to be sedated before any transport or interaction.",
				"No physical contact with SCP-049 is permitted without O5 approval.",
			),
			"recontainment" = list(
				"1. Deploy security personnel equipped with sedative darts.",
				"2. Maintain distance. SCP-049 will attempt to 'cure' personnel it perceives as infected.",
				"3. Administer sedatives from a distance of at least 3 meters.",
				"4. Once sedated, place SCP-049 on a stretcher and transport to containment.",
				"5. All SCP-049-1 instances must be terminated immediately.",
				"6. Decontaminate the breach area. All exposed personnel must undergo medical screening.",
				"7. Report the breach and any new SCP-049-1 instances to Research.",
			),
		),
		"SCP-079" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-079 is to be kept in a Faraday-shielded containment chamber.",
				"No network connections of any kind are permitted in the containment area.",
				"Power to the containment chamber is to be limited to a single 12V battery.",
				"Interaction with SCP-079 must be supervised by a Level 3 researcher.",
			),
			"recontainment" = list(
				"1. Proceed to the SCP-079 Recontainment Terminal in the server room.",
				"2. Initiate the countermeasure protocol via the terminal.",
				"3. Monitor progress through the five countermeasure stages:",
				"   a. Network Isolation — Cut SCP-079 from facility networks.",
				"   b. Camera Feed Block — Disable camera access.",
				"   c. Force Door Locks — Override all door controls.",
				"   d. Cut Power Loop — Sever the power tap.",
				"   e. Initiate Shutdown — Force SCP-079 back into its containment shell.",
				"4. Be aware SCP-079 will resist. Progress may be pushed back by counter-hacks.",
				"5. Once recontained, verify all network connections are severed.",
				"6. Perform a full facility system audit for backdoors.",
			),
		),
		"SCP-682" = list(
			"classification" = "Keter",
			"containment" = list(
				"SCP-682 is to be kept in a containment chamber filled with hydrochloric acid.",
				"Containment chamber must be constructed of reinforced steel with blast-resistant walls.",
				"No fewer than six (6) security personnel must be stationed outside the chamber.",
				"Any sign of adaptation or evolution must be reported to the Site Director immediately.",
			),
			"recontainment" = list(
				"1. Evacuate ALL personnel from the breach zone. This is NOT optional.",
				"2. Deploy MTF or heavy security teams with high-caliber weaponry.",
				"3. Containment priority: drive SCP-682 toward the acid bath chamber.",
				"4. Use concentrated fire to redirect SCP-682. It will adapt, so vary damage types.",
				"5. Once SCP-682 is in the acid bath chamber, flood with hydrochloric acid.",
				"6. Seal the chamber. Maintain acid levels for at minimum 2 hours.",
				"7. Monitor for adaptation signs. If SCP-682 breaches the acid bath, repeat from step 2.",
				"8. EXPECT CASUALTIES. This is a Keter-class recontainment. Minimize, do not eliminate losses.",
			),
		),
		"SCP-939" = list(
			"classification" = "Keter",
			"containment" = list(
				"SCP-939 instances are to be kept in separate soundproofed containment chambers.",
				"No verbal communication is permitted near SCP-939 containment areas.",
				"Personnel must wear noise-canceling equipment at all times in the HCZ.",
				"SCP-939 hunts by sound. Silence is your greatest defense.",
			),
			"recontainment" = list(
				"1. Maintain ABSOLUTE SILENCE. SCP-939 tracks prey by sound.",
				"2. Deploy teams with noise-canceling gear and tranquilizer weapons.",
				"3. Do NOT respond to voices calling your name. SCP-939 mimics human speech.",
				"4. Approach from behind. SCP-939 has limited visual perception.",
				"5. Administer tranquilizers. Multiple doses may be required.",
				"6. Transport the sedated instance to containment using silent methods.",
				"7. Report any additional SCP-939 instances detected during the breach.",
			),
		),
		"SCP-457" = list(
			"classification" = "Keter",
			"containment" = list(
				"SCP-457 is to be kept in a vacuum-sealed chamber with fire suppression nozzles.",
				"All materials in the containment area must be non-flammable.",
				"Oxygen levels in the chamber must be kept below 10%.",
				"Fire suppression teams must be on standby at all times.",
			),
			"recontainment" = list(
				"1. Activate fire suppression systems in the breach zone.",
				"2. Deploy teams with portable fire extinguishers and foam deployers.",
				"3. Use the SCP-457 Fire Suppression Unit if available.",
				"4. Reduce available fuel sources. Clear flammable materials from the area.",
				"5. SCP-457 weakens as its heat level drops. Sustained suppression is key.",
				"6. Once weakened, guide SCP-457 toward the containment chamber using fire breaks.",
				"7. Seal the chamber and activate vacuum suppression.",
				"8. Monitor for re-ignition for at minimum 1 hour.",
			),
		),
		"SCP-895" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-895 is to be kept in a standard containment chamber.",
				"No security cameras are permitted within 15 meters of SCP-895.",
				"Personnel must NOT view SCP-895 through camera feeds under any circumstances.",
				"Direct physical proximity within 2 meters causes mild unease but is not fatal.",
			),
			"recontainment" = list(
				"1. Disable all camera feeds within a 15-meter radius of SCP-895.",
				"2. Approach SCP-895 directly. Physical proximity is safe if brief.",
				"3. Use a forklift or pallet jack to move SCP-895. Do NOT carry it.",
				"4. Transport SCP-895 back to its containment chamber.",
				"5. Verify all nearby camera feeds are disabled or re-routed.",
				"6. Administer medical screening to any personnel who viewed SCP-895 through cameras.",
			),
		),
		"SCP-073" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-073 is to be kept in a standard humanoid containment chamber.",
				"No physical contact with SCP-073 is permitted without Level 3 authorization.",
				"Personnel must NOT attack SCP-073 under any circumstances. All damage is reflected.",
				"A 5-meter flora exclusion zone must be maintained around the containment chamber.",
			),
			"recontainment" = list(
				"1. DO NOT engage SCP-073 with force. Any damage will be reflected upon the attacker.",
				"2. Approach SCP-073 calmly. Speak in a non-threatening manner.",
				"3. Request SCP-073 to return to its containment chamber voluntarily.",
				"4. If SCP-073 refuses, offer amenities (reading material, conversation).",
				"5. Escort SCP-073 back to containment. Maintain respectful distance.",
				"6. Administer Class-B amnestics to any personnel who experienced memory disruption.",
			),
		),
		"SCP-076" = list(
			"classification" = "Keter",
			"containment" = list(
				"SCP-076-1 (sarcophagus) is to be kept in a reinforced containment chamber with 2m thick walls.",
				"Inner chamber must be equipped with a heavy blast door.",
				"A minimum of six (6) security personnel must be stationed at the containment area.",
				"When SCP-076-2 emerges, all personnel must evacuate and seal the chamber.",
			),
			"recontainment" = list(
				"1. EVACUATE. SCP-076-2 is an extremely hostile combatant.",
				"2. Deploy MTF or heavy security teams with lethal authorization.",
				"3. SCP-076-2 will respawn from its sarcophagus after death. Killing it buys time only.",
				"4. Maximum of 5 respawns per shift. After that, SCP-076-2 remains deceased.",
				"5. Use coordinated fire. SCP-076-2 becomes faster and stronger with rage.",
				"6. Once neutralized, immediately seal the sarcophagus chamber.",
				"7. Monitor for re-emergence. Each respawn takes approximately 5 minutes.",
				"8. EXPECT HEAVY CASUALTIES. This is one of the most dangerous recontainment scenarios.",
			),
		),
		"SCP-105" = list(
			"classification" = "Safe",
			"containment" = list(
				"SCP-105 is to be kept in a standard humanoid containment chamber.",
				"Access to security cameras must be restricted when SCP-105 is outside containment.",
				"SCP-105 may be allowed supervised recreational time with Level 2 authorization.",
				"Personnel should be aware SCP-105 can create portals through camera feeds.",
			),
			"recontainment" = list(
				"1. SCP-105 is generally cooperative. Verbal request is usually sufficient.",
				"2. If SCP-105 has created portals, request that they close them.",
				"3. Disable nearby camera feeds to prevent portal creation.",
				"4. Escort SCP-105 back to containment.",
				"5. Review camera logs for any unauthorized portal usage.",
			),
		),
		"SCP-408" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-408 is to be kept in a climate-controlled containment chamber with mesh screens.",
				"Containment chamber must be sealed to prevent butterflies from escaping.",
				"Personnel must wear protective eyewear when in the containment area.",
				"Visual disruption effects can cause disorientation and hallucinations.",
			),
			"recontainment" = list(
				"1. Locate the swarm. SCP-408 may be invisible — use thermal or motion sensors.",
				"2. Deploy personnel with protective eyewear and containment nets.",
				"3. Use bright flashing lights to disrupt the swarm's coordination.",
				"4. Guide the swarm toward the containment chamber using light barriers.",
				"5. Seal the chamber once the swarm has entered.",
				"6. Monitor personnel for lingering hallucination effects.",
			),
		),
		"SCP-1128" = list(
			"classification" = "Euclid",
			"containment" = list(
				"SCP-1128 is contained as information. Knowledge of SCP-1128 makes personnel vulnerable.",
				"No water sources are permitted within the containment area.",
				"Personnel must NOT be informed about SCP-1128's nature without O5 approval.",
				"Personnel who know of SCP-1128 must avoid submersion in water at all times.",
			),
			"recontainment" = list(
				"1. Evacuate all aware personnel from water sources IMMEDIATELY.",
				"2. Drain any water in the breach zone. SCP-1128 can only manifest in water.",
				"3. If SCP-1128 has manifested, it will demanifest after 30-60 seconds.",
				"4. Do NOT enter the water while SCP-1128 is manifested.",
				"5. After demanifestation, ensure all aware personnel are away from water.",
				"6. Administer Class-A amnestics to any personnel who learned of SCP-1128 during the breach.",
				"7. Remove or seal all water sources in the breach area.",
			),
		),
	)
	return containment_procedures

/obj/machinery/scp_containment_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScpContainmentChecklist", name)
		ui.open()

/obj/machinery/scp_containment_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/scp_containment_console/ui_static_data(mob/user)
	var/list/data = list()
	data["procedures"] = get_procedures()
	return data

/obj/machinery/scp_containment_console/ui_data(mob/user)
	var/list/data = list()
	var/list/breached = list()
	if(SSscp_persistence?.manager)
		for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
			if(instance?.containment_status == "breached")
				breached += scp_id
	data["breached_scps"] = breached
	return data
