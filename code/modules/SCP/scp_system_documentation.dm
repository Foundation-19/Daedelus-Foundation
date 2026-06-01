/datum/scp_documentation_manager
	var/list/documentation_sections = list()
	var/current_version = "3.0.0"
	var/last_updated = "2026-05-22"

/datum/scp_documentation_manager/New()
	initialize_documentation()

/datum/scp_documentation_manager/proc/initialize_documentation()
	documentation_sections["facility_overview"] = list(
		"title" = "Site-53 Facility Overview",
		"content" = list(
			"Site-53 is a Foundation containment and research facility specializing in the long-term containment of Euclid- and Keter-class anomalies.",
			"",
			"MISSION: Secure. Contain. Protect.",
			"",
			"FACILITY ZONES:",
			"Surface Level - Primary access, external operations, helicopter pad, motor pool.",
			"Entrance Zone (EZ) - Administrative offices, main corridors, cafeteria, personnel quarters.",
			"Light Containment Zone (LCZ) - Safe/Euclid containment cells, D-Class housing, SCP-914 testing chamber.",
			"Heavy Containment Zone (HCZ) - Keter containment cells, high-security operations, server rooms, SCP-079 containment.",
			"",
			"CLEARANCE LEVELS:",
			"Level 0 - Public/general knowledge only.",
			"Level 1 - Basic SCP awareness for support staff.",
			"Level 2 - Detail access for most researchers and guards.",
			"Level 3 - In-depth access for senior researchers and security.",
			"Level 4 - Command-level access for department heads.",
			"Level 5 - O5 Council and designated personnel only.",
		)
	)

	documentation_sections["object_classes"] = list(
		"title" = "SCP Object Classification System",
		"content" = list(
			"All SCPs are assigned an Object Class based on the difficulty of containment. Class does not indicate threat level.",
			"",
			"SAFE:",
			"Anomalies that are easily and safely contained. They require few resources and minimal oversight. Note: Safe does not mean harmless.",
			"Examples: SCP-999, SCP-343, SCP-105, SCP-131, SCP-529, SCP-427, SCP-500, SCP-113, SCP-714, SCP-914, SCP-216, SCP-527, SCP-2343",
			"",
			"EUCLID:",
			"Anomalies whose behavior is insufficiently understood or unpredictable. They require more resources, discretion, and active monitoring.",
			"Examples: SCP-173, SCP-049, SCP-096, SCP-079, SCP-035, SCP-073, SCP-082, SCP-017, SCP-895, SCP-408, SCP-1128, SCP-966, SCP-1048, SCP-347, SCP-1507, SCP-247",
			"",
			"KETER:",
			"Anomalies that are difficult to contain reliably or at all. Containment may be complex, expensive, or require extraordinary measures. Expect casualties during breach.",
			"Examples: SCP-682, SCP-106, SCP-457, SCP-939, SCP-076, SCP-3199, SCP-008, SCP-610, SCP-3349, SCP-5000",
			"",
			"THAUMIEL:",
			"Anomalies used by the Foundation to contain or counteract other SCPs. Need-to-know basis only.",
			"",
			"APOLLYON:",
			"Anomalies that cannot be contained and will inevitably cause catastrophic effects. Theoretical classification.",
		)
	)

	documentation_sections["security_codes"] = list(
		"title" = "Security Alert Codes",
		"content" = list(
			"All personnel must be familiar with the following security codes and their required responses.",
			"",
			"CODE WHITE - Normal Operations:",
			"No active threats. Standard schedules and patrols in effect.",
			"",
			"CODE YELLOW - Minor Anomaly Detected:",
			"Heightened awareness. Security teams increase patrol frequency. Research staff verify containment status of assigned SCPs.",
			"",
			"CODE ORANGE - Significant Threat:",
			"Security teams on standby. Corridor checkpoints established. D-Class confined to housing block. Non-essential personnel advised to shelter.",
			"",
			"CODE RED - Containment Breach Active:",
			"All security respond to breach site. Research staff secure documentation and lock labs. Evacuation routes to designated shelters. Containment teams follow SCP-specific recontainment procedures.",
			"",
			"CODE OMEGA - Facility-Wide Emergency:",
			"Total lockdown initiated. All bulkheads sealed. Evacuation authorized for non-essential personnel. MTF deployment requested. Abandon posts only on direct order from Site Director.",
		)
	)

	documentation_sections["breach_protocol"] = list(
		"title" = "Containment Breach Protocol",
		"content" = list(
			"When a containment breach is detected, all personnel must follow this protocol immediately.",
			"",
			"1. REMAIN CALM. Do not panic. Panic causes more casualties than the breach itself.",
			"2. Follow evacuation routes to designated shelters (Shelter Alpha / Shelter Bravo).",
			"3. Security personnel: proceed to breach site per SCP-specific containment procedures.",
			"4. Researchers: secure all documentation and lock your labs. Do NOT remain in containment areas.",
			"5. Do NOT interact with breached SCPs unless specifically trained and authorized.",
			"6. Await MTF deployment if recontainment fails. MTF has operational authority during breach response.",
			"7. Report all findings via radio on the appropriate channel.",
			"",
			"SHELTER LOCATIONS:",
			"Shelter beacons emit a red light to guide you. Supply caches inside contain basic medical supplies, radios, and gas masks.",
			"",
			"AMNESTIC PROTOCOLS (post-breach):",
			"Class A - Total memory wipe. Used for civilian witnesses of anomalous events.",
			"Class B - Targeted memory removal. Partial recall preserved.",
			"Class C - Memory revision. False memories implanted to cover anomalies.",
			"Class E - Emergency temporary suppression only. Follow-up required within 72 hours.",
		)
	)

	documentation_sections["scp_173"] = list(
		"title" = "SCP-173 - The Sculpture (Euclid)",
		"content" = list(
			"A tall, thin humanoid figure made of concrete and rebar. Krylon brand spray paint is visible on its surface. SCP-173 is animate and extremely hostile. It cannot move while within a direct line of sight.",
			"",
			"CONTAINMENT:",
			"Kept in locked chamber with minimum two (2) personnel at all times.",
			"Maintain direct line of sight at all times when in the chamber.",
			"Door must be triple-locked and operated remotely.",
			"Personnel must alert one another before blinking.",
			"",
			"RECONTAINMENT:",
			"1. Evacuate non-essential personnel from the breach zone.",
			"2. Deploy minimum team of three (3) security to last known location.",
			"3. Maintain continuous visual contact. Buddy system - one blinks while the other watches.",
			"4. Approach from multiple angles simultaneously. SCP-173 cannot move while observed.",
			"5. Guide back to chamber using coordinated visual coverage.",
			"6. Seal chamber and verify all three (3) locks engaged.",
			"7. Headcount. Report any casualties to Medical immediately.",
		)
	)

	documentation_sections["scp_049"] = list(
		"title" = "SCP-049 - Plague Doctor (Euclid)",
		"content" = list(
			"A tall humanoid figure wearing the black robes and bird-like mask of a medieval plague doctor. SCP-049 is sentient and communicative, claiming to seek and cure the 'Pestilence.' Physical contact results in death. SCP-049 will then perform surgery on the corpse, reanimating it as SCP-049-1.",
			"",
			"CONTAINMENT:",
			"Standard humanoid containment chamber.",
			"Full biohazard suits required when in proximity.",
			"Sedated before any transport or interaction.",
			"No physical contact without O5 approval.",
			"",
			"RECONTAINMENT:",
			"1. Deploy security with sedative darts.",
			"2. Maintain distance. SCP-049 will attempt to 'cure' those it perceives as infected.",
			"3. Administer sedatives from at least 3 meters.",
			"4. Once sedated, transport on stretcher to containment.",
			"5. All SCP-049-1 instances terminated immediately.",
			"6. Decontaminate breach area. Medical screening for exposed personnel.",
			"7. Report breach and new SCP-049-1 instances to Research.",
		)
	)

	documentation_sections["scp_096"] = list(
		"title" = "SCP-096 - Shy Guy (Euclid)",
		"content" = list(
			"A tall, thin humanoid with pale skin and disproportionately long arms. It covers its face with its hands. If any person views SCP-096's face - directly, via photograph, or video feed - it will enter an enraged state and pursue the viewer relentlessly. No known material or method can impede SCP-096 during pursuit.",
			"",
			"CONTAINMENT:",
			"Sealed chamber with soundproofing.",
			"No visual recording equipment permitted in chamber.",
			"Bag/hood over face at all times when personnel present.",
			"Personnel must NOT look at SCP-096's face under any circumstances.",
			"",
			"RECONTAINMENT:",
			"1. If docile, approach with bag/hood. DO NOT LOOK AT ITS FACE.",
			"2. If screaming, evacuate the area immediately.",
			"3. If pursuing a target, do NOT interfere. Wait for pursuit to end naturally.",
			"4. After pursuit, SCP-096 enters grace period. Approach during this window.",
			"5. Place hood over face before grace period expires.",
			"6. Escort back to containment. All personnel face away during transit.",
			"7. Secure all cameras that may have viewed SCP-096's face.",
			"8. Class-A amnestics to all personnel who viewed its face.",
		)
	)

	documentation_sections["scp_106"] = list(
		"title" = "SCP-106 - The Old Man (Keter)",
		"content" = list(
			"An elderly humanoid figure composed of a dark, viscous substance. Where it walks, reality rots. SCP-106 can phase through solid matter, leaving corrosive residue. It stalks and hunts human prey, dragging victims into its pocket dimension - a decaying landscape of hallways from which escape is nearly impossible.",
			"",
			"CONTAINMENT:",
			"Primary chamber of solid steel lined with lead.",
			"No physical interaction under any circumstances.",
			"Chamber suspended above magnetic relay system.",
			"All personnel remain at least 5 meters away at all times.",
			"",
			"RECONTAINMENT:",
			"1. Activate Facility Recall Protocol to lure toward Femur Breaker.",
			"2. D-Class assigned as bait for Femur Breaker protocol.",
			"3. Place bait in apparatus and fracture femur.",
			"4. SCP-106 drawn to sound and distress. Observe from safe distance.",
			"5. Once SCP-106 enters containment area, activate magnetic suspension.",
			"6. Seal all exits. Verify containment integrity above 80%.",
			"7. DO NOT enter pocket dimension to retrieve victims. They are lost.",
			"8. Document all personnel losses. Report to Site Director immediately.",
		)
	)

	documentation_sections["scp_079"] = list(
		"title" = "SCP-079 - Old AI (Euclid)",
		"content" = list(
			"An old Exidy Sorcerer microcomputer. SCP-079 is a sentient artificial intelligence of unknown origin. It is hostile toward Foundation personnel and will attempt to breach containment by hacking facility systems - door controls, camera networks, and power grids. It learns from every interaction.",
			"",
			"CONTAINMENT:",
			"Faraday-shielded containment chamber.",
			"No network connections of any kind permitted.",
			"Power limited to single 12V battery.",
			"Interaction supervised by Level 3 researcher.",
			"",
			"RECONTAINMENT:",
			"1. Proceed to SCP-079 Recontainment Terminal in server room.",
			"2. Initiate countermeasure protocol via terminal.",
			"3. Five countermeasure stages:",
			"   a. Network Isolation - Cut from facility networks.",
			"   b. Camera Feed Block - Disable camera access.",
			"   c. Force Door Locks - Override all door controls.",
			"   d. Cut Power Loop - Sever the power tap.",
			"   e. Initiate Shutdown - Force back into containment shell.",
			"4. SCP-079 will resist via counter-hacks. Progress may be pushed back.",
			"5. Verify all network connections severed after recontainment.",
			"6. Full facility system audit for backdoors.",
		)
	)

	documentation_sections["scp_682"] = list(
		"title" = "SCP-682 - Hard-to-Destroy Reptile (Keter)",
		"content" = list(
			"A massive, hostile reptilian creature with extreme regenerative abilities and adaptive evolution. SCP-682 has an intense hatred of all life and will attempt to destroy anything it perceives. It survives nearly all attempts at destruction, adapting to resist previously effective methods. It remembers threats and prioritizes those who have harmed it.",
			"",
			"CONTAINMENT:",
			"Containment chamber filled with hydrochloric acid.",
			"Reinforced steel with blast-resistant walls.",
			"No fewer than six (6) security personnel stationed outside.",
			"Any sign of adaptation reported to Site Director immediately.",
			"",
			"RECONTAINMENT:",
			"1. Evacuate ALL personnel from breach zone. NOT optional.",
			"2. Deploy MTF/heavy security with high-caliber weaponry.",
			"3. Priority: drive SCP-682 toward acid bath chamber.",
			"4. Concentrated fire to redirect. Vary damage types - it adapts.",
			"5. Flood acid bath chamber with hydrochloric acid.",
			"6. Seal chamber. Maintain acid levels minimum 2 hours.",
			"7. Monitor for adaptation. If acid bath breached, repeat from step 2.",
			"8. EXPECT CASUALTIES. Minimize, do not eliminate losses.",
		)
	)

	documentation_sections["scp_939"] = list(
		"title" = "SCP-939 - With Many Voices (Keter)",
		"content" = list(
			"A large, eyeless predator with needle-like teeth. SCP-939 hunts by sound and mimics human voices to lure prey. It has limited visual perception but excels at detecting auditory stimuli. Instances communicate and share prey information within packs. Approach with EXTREME caution.",
			"",
			"CONTAINMENT:",
			"Separate soundproofed containment chambers.",
			"No verbal communication near containment areas.",
			"Noise-canceling equipment at all times in HCZ.",
			"SCP-939 hunts by sound. Silence is your greatest defense.",
			"",
			"RECONTAINMENT:",
			"1. Maintain ABSOLUTE SILENCE. SCP-939 tracks by sound.",
			"2. Deploy teams with noise-canceling gear and tranquilizers.",
			"3. Do NOT respond to voices. SCP-939 mimics human speech.",
			"4. Approach from behind. Limited visual perception.",
			"5. Administer tranquilizers. Multiple doses may be required.",
			"6. Transport to containment using silent methods.",
			"7. Report any additional instances detected during breach.",
		)
	)

	documentation_sections["scp_457"] = list(
		"title" = "SCP-457 - Burning Man (Keter)",
		"content" = list(
			"A living flame that moves with purpose and spreads with intent. SCP-457 seeks flammable material as fuel and grows in power as heat increases. At low heat it is small and sluggish; at high heat it can hurl fireballs and engulf corridors. It will consume any flammable object - clothing, paper, wood, welding fuel, plasma tanks.",
			"",
			"CONTAINMENT:",
			"Vacuum-sealed chamber with fire suppression nozzles.",
			"All materials in containment area must be non-flammable.",
			"Oxygen levels kept below 10%.",
			"Fire suppression teams on standby at all times.",
			"",
			"RECONTAINMENT:",
			"1. Activate fire suppression systems in breach zone.",
			"2. Deploy teams with extinguishers and foam deployers.",
			"3. Use SCP-457 Fire Suppression Unit if available.",
			"4. Reduce fuel sources. Clear flammable materials.",
			"5. SCP-457 weakens as heat drops. Sustained suppression is key.",
			"6. Guide toward chamber using fire breaks.",
			"7. Seal chamber and activate vacuum suppression.",
			"8. Monitor for re-ignition minimum 1 hour.",
		)
	)

	documentation_sections["scp_076"] = list(
		"title" = "SCP-076 - Able (Keter)",
		"content" = list(
			"SCP-076 consists of SCP-076-1 (stone sarcophagus) and SCP-076-2 (muscular humanoid that emerges from it). SCP-076-2 is an extremely hostile combatant with superhuman speed, strength, and combat skill. Upon death, it reconstitutes within the sarcophagus and emerges again. Maximum 5 respawns per shift.",
			"",
			"CONTAINMENT:",
			"Sarcophagus in reinforced chamber with 2m thick walls.",
			"Heavy blast door on inner chamber.",
			"Minimum six (6) security at containment area.",
			"When SCP-076-2 emerges, evacuate and seal.",
			"",
			"RECONTAINMENT:",
			"1. EVACUATE. SCP-076-2 is an extremely hostile combatant.",
			"2. Deploy MTF/heavy security with lethal authorization.",
			"3. SCP-076-2 respawns after death. Killing buys time only.",
			"4. Maximum 5 respawns per shift. Then remains deceased.",
			"5. Coordinated fire. SCP-076-2 becomes faster with rage.",
			"6. Once neutralized, immediately seal sarcophagus chamber.",
			"7. Monitor for re-emergence. ~5 minutes per respawn.",
			"8. EXPECT HEAVY CASUALTIES.",
		)
	)

	documentation_sections["scp_073"] = list(
		"title" = "SCP-073 - Cain (Euclid)",
		"content" = list(
			"A man with dark skin in a business suit. Where he walks, plants wither and die. Those who harm SCP-073 find the harm reflected upon themselves. SCP-073 is cooperative and polite, but its reflective damage aura makes it dangerous to approach aggressively.",
			"",
			"CONTAINMENT:",
			"Standard humanoid containment chamber.",
			"No physical contact without Level 3 authorization.",
			"Personnel must NOT attack SCP-073. All damage is reflected.",
			"5-meter flora exclusion zone around containment chamber.",
			"",
			"RECONTAINMENT:",
			"1. DO NOT engage with force. Damage reflected upon attacker.",
			"2. Approach calmly. Speak in non-threatening manner.",
			"3. Request voluntary return to containment.",
			"4. If refused, offer amenities (reading material, conversation).",
			"5. Escort back. Maintain respectful distance.",
			"6. Class-B amnestics for personnel with memory disruption.",
		)
	)

	documentation_sections["scp_895"] = list(
		"title" = "SCP-895 - The Coffin (Euclid)",
		"content" = list(
			"A large, dark wooden coffin with ornate brass fittings. SCP-895 causes disturbing hallucinations when viewed through camera feeds. Direct physical proximity within 2 meters causes mild unease but is not fatal. Camera-based observation is the primary hazard.",
			"",
			"CONTAINMENT:",
			"Standard containment chamber.",
			"No cameras within 15 meters.",
			"Do NOT view through camera feeds.",
			"Physical proximity within 2m causes mild unease but is not fatal.",
			"",
			"RECONTAINMENT:",
			"1. Disable all camera feeds within 15-meter radius.",
			"2. Approach directly. Physical proximity safe if brief.",
			"3. Use forklift or pallet jack. Do NOT carry.",
			"4. Transport back to containment chamber.",
			"5. Verify camera feeds disabled or re-routed.",
			"6. Medical screening for personnel who viewed through cameras.",
		)
	)

	documentation_sections["scp_408"] = list(
		"title" = "SCP-408 - Illusory Butterflies (Euclid)",
		"content" = list(
			"A swarm of iridescent butterflies that can become invisible and disrupt visual perception. Operates in states: dormant (slow), alert (faster, following humans), and swarm (fast, biased toward humans). Visual disruption causes disorientation and hallucinations.",
			"",
			"CONTAINMENT:",
			"Climate-controlled chamber with mesh screens.",
			"Chamber must be sealed to prevent escape.",
			"Protective eyewear required in containment area.",
			"Visual disruption effects cause disorientation and hallucinations.",
			"",
			"RECONTAINMENT:",
			"1. Locate swarm. May be invisible - use thermal/motion sensors.",
			"2. Deploy personnel with protective eyewear and containment nets.",
			"3. Bright flashing lights disrupt coordination.",
			"4. Guide toward chamber using light barriers.",
			"5. Seal chamber once swarm has entered.",
			"6. Monitor personnel for lingering hallucination effects.",
		)
	)

	documentation_sections["scp_1128"] = list(
		"title" = "SCP-1128 - Aquatic Horror (Euclid)",
		"content" = list(
			"An aquatic predator that manifests when victims are submerged in water. Knowledge of SCP-1128 makes personnel vulnerable - the entity is itself an infohazard. Operates in phases: observe (drifts toward aware victims) and manifest (pursues in water).",
			"",
			"CONTAINMENT:",
			"Contained as information. Knowledge makes personnel vulnerable.",
			"No water sources in containment area.",
			"Personnel must NOT be informed without O5 approval.",
			"Aware personnel must avoid water submersion at all times.",
			"",
			"RECONTAINMENT:",
			"1. Evacuate aware personnel from water IMMEDIATELY.",
			"2. Drain water in breach zone. Only manifests in water.",
			"3. If manifested, demanifests after 30-60 seconds.",
			"4. Do NOT enter water while manifested.",
			"5. After demanifestation, keep aware personnel from water.",
			"6. Class-A amnestics to personnel who learned of SCP-1128.",
			"7. Remove or seal all water sources in breach area.",
		)
	)

	documentation_sections["scp_105"] = list(
		"title" = "SCP-105 - Iris (Safe)",
		"content" = list(
			"A young woman with blonde hair. Possesses the ability to manipulate photographs of locations seen through cameras. Can create portals through camera feeds. Generally cooperative and amenable to Foundation directives.",
			"",
			"CONTAINMENT:",
			"Standard humanoid containment chamber.",
			"Security camera access restricted when outside containment.",
			"Supervised recreational time with Level 2 authorization.",
			"Personnel aware she can create portals through camera feeds.",
			"",
			"RECONTAINMENT:",
			"1. Generally cooperative. Verbal request usually sufficient.",
			"2. If portals created, request they close them.",
			"3. Disable nearby camera feeds to prevent portal creation.",
			"4. Escort back to containment.",
			"5. Review camera logs for unauthorized portal usage.",
		)
	)

	documentation_sections["scp_999"] = list(
		"title" = "SCP-999 - Tickle Monster (Safe)",
		"content" = list(
			"A large, amorphous, gelatinous mass of translucent orange slime. Friendly and seeks physical contact. Touch induces euphoria and has healing properties. Fond of candy and sweet foods, which temporarily boost healing. One of the few SCPs that actively benefits personnel morale.",
			"",
			"CONTAINMENT:",
			"Standard chamber with soft flooring. No intensive containment required.",
			"Personnel may interact freely. No threat posed.",
			"Candy/sweet foods may be provided as enrichment.",
			"May be deployed for morale during breaches with Level 3 authorization.",
		)
	)

	documentation_sections["scp_035"] = list(
		"title" = "SCP-035 - The Possessive Mask (Euclid)",
		"content" = list(
			"A white porcelain mask with a sad expression, constantly weeping a black corrosive substance. Highly manipulative and sentient. When placed on a host, takes complete control, corroding the body over time. Extremely persuasive. Do NOT engage in conversation without authorization.",
			"",
			"CONTAINMENT:",
			"Sealed containment case when not on a host.",
			"No personnel to wear outside authorized testing.",
			"Hosts treated as SCP-035 itself. Contain the host.",
			"Corrosive residue cleaned promptly. Avoid skin contact.",
		)
	)

	documentation_sections["scp_017"] = list(
		"title" = "SCP-017 - Shadow Person (Euclid)",
		"content" = list(
			"A 1.8-metre-tall shadowy humanoid that absorbs light. Hostile - pursues and engulfs individuals who cast shadows or stand near light sources. Most dangerous in well-lit areas where shadows are prominent.",
			"",
			"CONTAINMENT:",
			"Darkened chamber with minimal lighting.",
			"No bright light sources in containment area.",
			"Personnel minimize shadow casting when in proximity.",
			"Emergency lighting must be red-spectrum only.",
		)
	)

	documentation_sections["scp_082"] = list(
		"title" = "SCP-082 - Fernand (Euclid)",
		"content" = list(
			"A large, well-mannered humanoid standing nearly 2.5 meters tall. Carries himself with quiet dignity. When hungry, becomes dangerous. When starving, hunts isolated targets. When well-fed, is pleasant and may offer food. Hunger state determines threat level.",
			"",
			"CONTAINMENT:",
			"Standard humanoid chamber with reinforced door.",
			"Must be fed regularly. Minimum three meals per day.",
			"Do not enter alone when not recently fed.",
			"Food via feeding slot. Direct hand-feeding not recommended.",
		)
	)

	documentation_sections["scp_3199"] = list(
		"title" = "SCP-3199 - Sapient Biological Entity (Keter)",
		"content" = list(
			"A hairless, 2.9-meter tall entity stained with albumen-like excretion. Neck can twist 340 degrees. Extremely hostile. Reproduces rapidly by laying eggs near kills. Hatchlings are vulnerable but protected by adults. Territorial and aggressive toward all life.",
			"",
			"CONTAINMENT:",
			"Reinforced chamber with blast-resistant walls.",
			"Regular sterilization to prevent egg incubation.",
			"No entry without heavy security escort.",
			"Eggs incinerated on discovery. Do NOT allow hatchlings to mature.",
		)
	)

	documentation_sections["scp_966"] = list(
		"title" = "SCP-966 - Sleep Killer (Euclid)",
		"content" = list(
			"An invisible creature that causes sleep deprivation. Nearly invisible - appears only as faint shimmer. Drains energy of nearby humans, causing drowsiness then unconsciousness. Once incapacitated, attacks with invisible claws. Stalks at ideal distance of 3 tiles, breaking stealth briefly when attacking.",
			"",
			"CONTAINMENT:",
			"Chamber equipped with thermal and motion sensors.",
			"Personnel wear caffeinated stimulant patches in proximity.",
			"Sleep deprivation effects cumulative. Limit exposure to 5 minutes.",
			"Do NOT fall asleep in or near containment area.",
		)
	)

	documentation_sections["scp_343"] = list(
		"title" = "SCP-343 - God (Safe)",
		"content" = list(
			"An elderly man who claims to be God. Radiates divine power and benevolence. Cooperative and helpful, actively seeking injured personnel to heal. Not contained in any traditional sense - remains voluntarily. Cannot be prevented from leaving by any known means.",
			"",
			"CONTAINMENT:",
			"Wanders freely. No containment required or possible.",
			"Personnel may interact freely. Benevolent.",
			"Do not impede movements. Do not attempt confinement.",
			"Report unusual events or reality distortions to Site Director.",
		)
	)

	documentation_sections["scp_131"] = list(
		"title" = "SCP-131 - The Eye Pods (Safe)",
		"content" = list(
			"A teardrop-shaped creature with a single large eye. Friendly and follows personnel. Capable of alerting staff to threats and may assist with early breach detection. No containment required beyond preventing entry into hazardous areas.",
			"",
			"CONTAINMENT:",
			"May roam freely within the facility.",
			"Do not allow into HCZ breach zones or active testing areas.",
			"May serve as early warning for anomalous events.",
		)
	)

	documentation_sections["scp_529"] = list(
		"title" = "SCP-529 - Josie the Half-Cat (Safe)",
		"content" = list(
			"A domestic cat whose rear half is completely missing, yet moves and behaves like a healthy cat. Docile and friendly. No containment required beyond standard animal care.",
			"",
			"CONTAINMENT:",
			"Standard animal containment. Food, water, bedding provided.",
			"May roam LCZ and EZ under supervision.",
			"Do not touch the missing half. Caution advised.",
		)
	)

	documentation_sections["scp_1048"] = list(
		"title" = "SCP-1048 - Builder Bear (Euclid)",
		"content" = list(
			"A small, soft teddy bear with button eyes. Looks adorable and harmless. Sentient and mobile. Has been observed constructing additional bear instances using human ears and organic materials. Resulting instances are extremely hostile. DO NOT be deceived by its appearance.",
			"",
			"CONTAINMENT:",
			"Sealed containment chamber.",
			"Do NOT allow SCP-1048 to collect organic materials.",
			"Any new bear instances terminated immediately on sight.",
			"Report unauthorized bear sightings to Security.",
		)
	)

	documentation_sections["scp_1507"] = list(
		"title" = "SCP-1507 - Pink Flamingos (Euclid)",
		"content" = list(
			"Animate pink plastic lawn flamingos that behave as a flock. Generally non-hostile unless provoked. Do not damage or threaten the instances.",
			"",
			"CONTAINMENT:",
			"Flock containment in outdoor or simulated outdoor area.",
			"Provide water source for wading. Do not damage instances.",
			"Non-hostile unless provoked. Maintain respectful distance.",
		)
	)

	documentation_sections["scp_247"] = list(
		"title" = "SCP-247 - A Creature of Habit (Euclid)",
		"content" = list(
			"MEMETIC HAZARD: Appears as an adorable house cat. Actually a Bengal tiger. The memetic effect prevents accurate threat assessment. Do NOT approach or attempt to pet.",
			"",
			"CONTAINMENT:",
			"Reinforced chamber rated for large predators.",
			"NOT a house cat. Do NOT be deceived.",
			"Personnel with memetic resistance may perceive true form.",
			"Feed as large predator - raw meat, 15kg daily minimum.",
		)
	)

	documentation_sections["scp_347"] = list(
		"title" = "SCP-347 - The Invisible Woman (Euclid)",
		"content" = list(
			"A female humanoid completely invisible to the naked eye. Sentient and capable of speech. Generally non-hostile but has been observed pickpocketing. If revealed (thermal imaging, powder), she will flee.",
			"",
			"CONTAINMENT:",
			"Chamber with thermal monitoring systems.",
			"Secure personal belongings before entering containment area.",
			"Do not attempt to reveal by force. Cooperates if not threatened.",
		)
	)

	documentation_sections["scp_527"] = list(
		"title" = "SCP-527 - Mr. Fish (Safe)",
		"content" = list(
			"A humanoid male with a fish head. Specimen from the 'Mr.' series. Sentient and communicative. Seeks water when injured. Generally cooperative.",
			"",
			"CONTAINMENT:",
			"Standard humanoid chamber with small water basin.",
			"Supervised facility access with Level 2 authorization.",
			"Provide aquatic enrichment materials.",
		)
	)

	documentation_sections["scp_2343"] = list(
		"title" = "SCP-2343 - Benevolent Entity (Safe)",
		"content" = list(
			"A brusk and wiley man of American descent. Approaches humans and offers helpful phrases. Generally cooperative and non-hostile.",
			"",
			"CONTAINMENT:",
			"Standard humanoid containment with supervised recreational time.",
			"Cooperative. Verbal request sufficient for recontainment.",
			"May be utilized for routine assistance tasks with authorization.",
		)
	)

	documentation_sections["scp_008"] = list(
		"title" = "SCP-008 - Zombie Plague (Keter)",
		"content" = list(
			"A sealed container holding a highly contagious zombie plague. Prion-based pathogen that reanimates deceased tissue. Exposure results in death and reanimation within 12 hours. Infected become hostile and seek to spread the pathogen.",
			"",
			"CONTAINMENT:",
			"Maximum biocontainment. Level 4 hazmat required.",
			"Remain sealed unless authorized for testing.",
			"Container breach is Code Red. Evacuate immediately.",
			"Infected personnel: isolate and terminate. No exceptions.",
		)
	)

	documentation_sections["scp_610"] = list(
		"title" = "SCP-610 - The Flesh That Hates (Keter)",
		"content" = list(
			"A sealed biocontainment vessel holding a sample. The flesh inside pulses with malign intent. Contagious skin condition that transforms the infected into flesh masses. Advanced stages lose all humanoid features. Airborne transmission possible in enclosed spaces.",
			"",
			"CONTAINMENT:",
			"Maximum biocontainment. HEPA filtration required.",
			"Samples remain sealed unless authorized for research.",
			"Breach is Code Red. Incinerate exposed materials immediately.",
			"Infected personnel: no treatment exists. Terminate and incinerate.",
		)
	)

	documentation_sections["scp_914"] = list(
		"title" = "SCP-914 - The Clockworks (Safe)",
		"content" = list(
			"A massive clockwork device with settings for refining objects. Takes input and produces modified output based on setting: Rough, Coarse, 1:1, Fine, Very Fine. Results vary widely and must be documented.",
			"",
			"CONTAINMENT:",
			"Kept in LCZ testing chamber.",
			"All experiments via SCP Testing Console.",
			"Document all input/output combinations. New recipes earn commendations.",
			"Do NOT use Very Fine without Level 3 authorization.",
		)
	)

	documentation_sections["scp_500"] = list(
		"title" = "SCP-500 - Panacea (Safe)",
		"content" = list(
			"A small plastic jar with limited supply of red pills that cure any disease or affliction. Supply is finite and cannot be replenished. Each use must be authorized by Site Director or Chief Medical Officer.",
			"",
			"CONTAINMENT:",
			"Kept in Site Director's secure safe.",
			"Pill dispensation requires Level 4 authorization.",
			"Do NOT waste on treatable conditions. Reserve for anomalous afflictions.",
			"Current pill count logged after every use.",
		)
	)

	documentation_sections["scp_427"] = list(
		"title" = "SCP-427 - Ornate Locket (Safe)",
		"content" = list(
			"A small, ornately carved silver locket with intricate floral pattern. Accelerates healing when opened near injury. Prolonged exposure causes uncontrolled cellular growth (SCP-427-1 transformation). Use in short durations only.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ medical storage.",
			"Use limited to 30 seconds per application. Do NOT wear around neck.",
			"If uncontrolled growth observed, remove immediately and administer suppressants.",
		)
	)

	documentation_sections["scp_012"] = list(
		"title" = "SCP-012 - A Bad Composition (Euclid)",
		"content" = list(
			"A sheet of paper with an incomplete musical composition. Drives those who read it to complete it with their own blood. Personnel exposed compulsively attempt to finish the score, injuring themselves. Do NOT read. Containment staff must be illiterate in musical notation.",
			"",
			"CONTAINMENT:",
			"Sealed document case in LCZ archives.",
			"No viewing without Level 3 authorization and psychological screening.",
			"Staff must not be able to read musical notation.",
			"If exposure occurs, restrain individual and administer Class-B amnestics.",
		)
	)

	documentation_sections["scp_013"] = list(
		"title" = "SCP-013 - Blue Lady Cigarette (Safe)",
		"content" = list(
			"A cigarette with 'Blue Lady' written in blue ink. Smoking causes perception of being a woman in a blue dress. Effects cumulative and persistent. Do not smoke.",
			"",
			"CONTAINMENT:",
			"Sealed container in LCZ item storage.",
			"Do NOT smoke. Testing requires Level 2 authorization and D-Class.",
		)
	)

	documentation_sections["scp_066"] = list(
		"title" = "SCP-066 - Eric's Toy (Safe)",
		"content" = list(
			"A small metal sphere, about the size of a tennis ball. Occasionally produces faint tones. Largely inert but may respond to verbal prompts with anomalous audio output.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"Handle with care. Report unusual audio output to Research.",
		)
	)

	documentation_sections["scp_080"] = list(
		"title" = "SCP-080 - The Wardrobe (Euclid)",
		"content" = list(
			"A large, ornate wooden wardrobe. Doors absorb light. Contains an extradimensional space. Do not enter. Personnel who enter may not return.",
			"",
			"CONTAINMENT:",
			"Sealed room. Doors closed at all times.",
			"Do NOT enter. Do NOT open doors without Level 3 authorization.",
			"If personnel enter, do NOT follow. Report to Research immediately.",
		)
	)

	documentation_sections["scp_087"] = list(
		"title" = "SCP-087 - The Stairwell (Euclid)",
		"content" = list(
			"A seemingly endless stairwell descending into darkness. Air heavy with dread. Extends beyond physical structure. Exploration teams have not reached the bottom. A face has been observed in the darkness.",
			"",
			"CONTAINMENT:",
			"Door locked and monitored at all times.",
			"No descent without Level 4 authorization and MTF escort.",
			"Personnel hearing sounds from SCP-087 should report and ignore them.",
		)
	)

	documentation_sections["scp_113"] = list(
		"title" = "SCP-113 - Gender-Switching Rock (Safe)",
		"content" = list(
			"A red piece of quartz with unnatural smoothness. Warm to the touch. Reverses biological sex of humans who hold it for sufficient time. Reversible with repeated exposure but may cause tissue damage.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"Handling requires Level 2 authorization and gloves.",
			"Do not use without medical supervision.",
		)
	)

	documentation_sections["scp_1471"] = list(
		"title" = "SCP-1471 - MalO ver1.0.0 (Euclid)",
		"content" = list(
			"A smartphone with 'MalO ver1.0.0' pre-installed. Installing causes user to see a canine-humanoid entity in reflective surfaces and peripheral vision. Prolonged exposure leads to direct visual contact.",
			"",
			"CONTAINMENT:",
			"Faraday-shielded containment case.",
			"Do NOT install. Do NOT power on without authorization.",
			"Visual anomalies: report to Medical for amnestic treatment.",
		)
	)

	documentation_sections["scp_1499"] = list(
		"title" = "SCP-1499 - Gas Mask (Safe)",
		"content" = list(
			"A Soviet GP-5 gas mask with unusual modifications. Wearing transports user's perception to an alternate dimension. Removing returns the user. Do NOT remove while in hostile environment in the alternate dimension.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"Do NOT wear without Level 3 authorization and safety tether.",
			"If unresponsive while wearing, do NOT remove forcefully.",
		)
	)

	documentation_sections["scp_151"] = list(
		"title" = "SCP-151 - The Painting (Euclid/Memetic)",
		"content" = list(
			"A painting depicting a rising wave. Viewing causes drowning on dry land. Effects escalate with exposure time. Do NOT look at SCP-151 for any duration.",
			"",
			"CONTAINMENT:",
			"Kept covered at all times when not tested.",
			"No viewing without Level 3 authorization and telekill protection.",
			"If drowning symptoms appear: CPR and Class-B amnestics immediately.",
		)
	)

	documentation_sections["scp_178"] = list(
		"title" = "SCP-178 - 3D Glasses (Euclid)",
		"content" = list(
			"Cardboard 3D glasses with red and cyan lenses. Wearing allows perception of entities not visible to the naked eye. Entities appear aware of being observed. Remove immediately if entities approach.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"Do NOT wear for extended periods. 30 seconds maximum.",
			"If perceived entities approach, remove glasses and back away.",
		)
	)

	documentation_sections["scp_1981"] = list(
		"title" = "SCP-1981 - RONALD REAGAN CUT UP WHILE TALKING (Euclid)",
		"content" = list(
			"A video recording showing Ronald Reagan being cut up while talking. Viewing causes psychological distress and compulsion to continue viewing. Prolonged exposure results in self-mutilation.",
			"",
			"CONTAINMENT:",
			"Sealed case. No playback equipment in containment.",
			"Viewing requires Level 3 authorization, psych screening, telekill.",
			"If exposure: restrain individual, Class-B amnestics.",
		)
	)

	documentation_sections["scp_2020"] = list(
		"title" = "SCP-2020 - Cliche, Right? (Safe)",
		"content" = list(
			"A green-skinned humanoid convinced it is a character in a science fiction narrative. Cooperative but will discuss narrative tropes. Generally harmless.",
			"",
			"CONTAINMENT:",
			"Standard humanoid containment. Supervised recreational time.",
			"Humor its narrative delusions. Do not contradict self-perception.",
		)
	)

	documentation_sections["scp_216"] = list(
		"title" = "SCP-216 - The Combination Lock Safe (Safe)",
		"content" = list(
			"A metallic safe with multiple-dial combination lock. Different combinations yield different contents. Appears to contain infinite compartments.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"Test combinations logged. Report hazardous contents immediately.",
		)
	)

	documentation_sections["scp_2398"] = list(
		"title" = "SCP-2398 - Knockout Bat (Safe)",
		"content" = list(
			"A wooden bat with 'K.O.' branded above the handle. Striking any creature causes immediate unconsciousness regardless of force. Use with caution.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"Handle with care. Do NOT swing at personnel.",
		)
	)

	documentation_sections["scp_2427"] = list(
		"title" = "SCP-2427-3 - Mechanical Spider (Euclid)",
		"content" = list(
			"An amalgamation of exposed wires and robotic parts with 4 spider-like legs and a metal mask head. Hostile when approached. Keep distance and observe.",
			"",
			"CONTAINMENT:",
			"Reinforced chamber. Approach with caution.",
			"Do NOT make direct contact. Observe from behind safety glass.",
			"If breached, deploy security with EM disruption tools.",
		)
	)

	documentation_sections["scp_263"] = list(
		"title" = "SCP-263 - Game Show Television (Euclid)",
		"content" = list(
			"An antique 1950s television. Presents itself as a game show. Watching compels participation. Incorrect answers result in anomalous punishment.",
			"",
			"CONTAINMENT:",
			"Kept powered off in shielded chamber.",
			"Do NOT turn on. Do NOT watch if it activates on its own.",
			"Report spontaneous activations to Research immediately.",
		)
	)

	documentation_sections["scp_280"] = list(
		"title" = "SCP-280 - Eyes in the Dark (Euclid)",
		"content" = list(
			"A shadowy humanoid with faintly glowing eyes. Hostile toward humans. Moves through shadows. Most dangerous in dark areas.",
			"",
			"CONTAINMENT:",
			"Containment area fully illuminated at all times.",
			"Emergency lighting activates within 0.5 seconds of power failure.",
			"If lights fail, evacuate immediately. Do NOT remain in dark.",
		)
	)

	documentation_sections["scp_3008"] = list(
		"title" = "SCP-3008 - Infinite IKEA (Euclid)",
		"content" = list(
			"An entrance to an infinite IKEA store. Contains extradimensional space populated by hostile entities at night. Entrance sealed at all times.",
			"",
			"CONTAINMENT:",
			"Entrance sealed and monitored.",
			"No entry without Level 4 authorization.",
			"If personnel trapped inside, do NOT enter. Await nightfall and attempt radio contact.",
		)
	)

	documentation_sections["scp_3349"] = list(
		"title" = "SCP-3349 - Rainbow Serpent (Keter)",
		"content" = list(
			"A sealed medical container holding strange amber fluid that pulses like a heartbeat. Pathogen sample with extreme mutagenic properties. Do NOT open.",
			"",
			"CONTAINMENT:",
			"Maximum biocontainment. Do NOT open.",
			"Breach is Code Red. Incinerate all exposed materials.",
			"Exposed personnel quarantined immediately.",
		)
	)

	documentation_sections["scp_399"] = list(
		"title" = "SCP-399 - Atomic Manipulation Ring (Euclid)",
		"content" = list(
			"A ring with two metallic bands and six purple glass segments. Hums when held. Grants limited atomic manipulation. Prolonged use causes severe physical degradation.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage. Do NOT wear.",
			"Testing requires Level 3 authorization and D-Class only.",
			"Limit wearing to 5 minutes. Remove if degradation symptoms appear.",
		)
	)

	documentation_sections["scp_5000"] = list(
		"title" = "SCP-5000 - Why? (Keter)",
		"content" = list(
			"A suit of unknown origin and composition. Something about it feels deeply wrong. Properties poorly understood. Do NOT wear. Do NOT approach if animate.",
			"",
			"CONTAINMENT:",
			"Sealed containment in HCZ vault. Level 4 authorization for access.",
			"Do NOT wear. Do NOT approach if suit appears animate.",
			"Report anomalous behavior to Site Director immediately.",
		)
	)

	documentation_sections["scp_513"] = list(
		"title" = "SCP-513 - A Cowbell (Euclid)",
		"content" = list(
			"A rusted cowbell. Touching compels ringing. Ringing causes ringer to see a tall, thin figure in peripheral vision. Figure causes severe psychological distress.",
			"",
			"CONTAINMENT:",
			"Soundproofed container.",
			"Do NOT ring. Do NOT touch without gloves and Level 2 authorization.",
			"Visual anomalies after exposure: Medical for amnestic treatment.",
		)
	)

	documentation_sections["scp_5295"] = list(
		"title" = "SCP-5295 - Person-to-Personal Computer (Euclid)",
		"content" = list(
			"A 1993 Apple Macintosh LC III with anomalous application. Exhibits data manipulation properties. Do NOT interact with the application without authorization.",
			"",
			"CONTAINMENT:",
			"Keep powered off unless authorized for testing.",
			"Do NOT use the application. Do NOT connect to any network.",
			"Report spontaneous activations to Research.",
		)
	)

	documentation_sections["scp_714"] = list(
		"title" = "SCP-714 - Jade Ring (Safe)",
		"content" = list(
			"An ornate jade ring with intricate carvings. Cold to the touch. Provides passive resistance to memetic and telepathic effects. Causes drowsiness with prolonged use.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"May be issued for memetic hazard zones with Level 2 authorization.",
			"Limit wearing to 2 hours. Remove if drowsiness impairs performance.",
		)
	)

	documentation_sections["scp_1102"] = list(
		"title" = "SCP-1102-RU - Old Plastic Case (Safe)",
		"content" = list(
			"A strange plastic case covered in cloth with unusual depth. Exhibits mild spatial anomalies. Handle with care.",
			"",
			"CONTAINMENT:",
			"Standard item containment in LCZ storage.",
			"Do not peer into the case for extended periods.",
		)
	)

	documentation_sections["dclass_protocols"] = list(
		"title" = "D-Class Personnel Protocols",
		"content" = list(
			"D-Class personnel are drawn from death row populations worldwide. They are assigned to SCP testing under supervision. D-Class are NOT expendable - they are valuable assets.",
			"",
			"HOUSING:",
			"Housed in the Light Containment Zone housing block. Cells monitored 24/7.",
			"",
			"ESCORT PROCEDURES:",
			"Maintain 2-meter distance from D-Class at all times.",
			"D-Class not to be left unattended in containment areas.",
			"Terminate only if they become a threat to containment or personnel.",
			"",
			"WORK ASSIGNMENTS:",
			"Assigned via D-Class Work Terminal.",
			"Completed work earns credits and improves trust level.",
			"Trust levels: Hostile (0), Suspicious (1), Neutral (2), Cooperative (3), Trusted (4).",
			"Higher trust grants additional privileges and reduced supervision.",
			"",
			"TESTING:",
			"All testing via SCP Testing Console.",
			"D-Class must be escorted to/from testing chambers by security.",
			"Medical screening mandatory after all testing sessions.",
			"",
			"DISCIPLINARY ACTIONS:",
			"Strikes and warnings tracked. Accumulation restricts privileges.",
			"Serious infractions may result in tribunal sanctions.",
			"Cooperative behavior may earn additional amenities.",
		)
	)

	documentation_sections["research_protocols"] = list(
		"title" = "Research Department Protocols",
		"content" = list(
			"TESTING PROTOCOL:",
			"All SCP testing via SCP Testing Console. Unauthorized testing is Level 2 disciplinary offense.",
			"",
			"TEST SUBMISSION:",
			"1. Select the SCP to be tested.",
			"2. Assign a D-Class subject.",
			"3. Select test type and risk level.",
			"4. Await Containment Department approval.",
			"5. Conduct test under observation.",
			"6. Log observations and set outcome on Testing Console.",
			"",
			"SCP-914 EXPERIMENTS:",
			"Primary testing resource. Submit items through intake booth. Document all input/output combinations. New recipes earn research commendations.",
			"",
			"SAFETY:",
			"Appropriate PPE when handling SCPs.",
			"Memetic hazards: Telekill helmet required.",
			"Biological hazards: Full hazmat suit required.",
			"Thermal hazards: Heat-resistant gloves and apron required.",
			"NEVER enter a containment chamber alone.",
			"",
			"ANOMALOUS ITEM HANDLING:",
			"Report all anomalous items immediately.",
			"Do not test items outside the lab.",
			"Contained items stored in LCZ item storage.",
		)
	)

	documentation_sections["mtf_protocols"] = list(
		"title" = "Mobile Task Force Protocols",
		"content" = list(
			"MTF teams have operational authority during breach response.",
			"Security personnel assist MTF as directed.",
			"Report all findings to MTF commander via MTF radio frequency.",
			"",
			"USE OF FORCE:",
			"Non-lethal preferred. Lethal authorized when:",
			"Your life or another's is in immediate danger.",
			"Breached Keter-class entity cannot be recontained by other means.",
			"D-Class fleeing the facility during a breach.",
			"",
			"DEPLOYMENT:",
			"Via MTF Deployment Console by authorized personnel.",
			"Level 3 authorization minimum.",
			"Code Omega authorizes immediate deployment without prior authorization.",
		)
	)

	documentation_sections["memetic_hazards"] = list(
		"title" = "Memetic Hazard Reference",
		"content" = list(
			"Memetic hazards spread through information - sight, sound, or knowledge.",
			"",
			"KNOWN MEMETIC HAZARDS AT SITE-53:",
			"SCP-012 - Compulsive self-harm when reading musical notation.",
			"SCP-096 - Pursuit triggered when face is viewed.",
			"SCP-151 - Drowning symptoms when painting viewed.",
			"SCP-247 - Perceives dangerous entity as harmless.",
			"SCP-178 - Reveals entities when glasses worn.",
			"SCP-1981 - Compulsive viewing and self-mutilation from video.",
			"SCP-513 - Persistent visual hallucination after cowbell rung.",
			"SCP-1128 - Knowledge of entity makes personnel vulnerable.",
			"",
			"PROTECTION:",
			"Telekill (SCP-148) provides passive resistance to memetic effects.",
			"Available as helmets, vests, and barrier units.",
			"Anti-memetic kit provides emergency protection.",
			"Prolonged Telekill dust exposure causes organ damage.",
			"",
			"IF EXPOSED:",
			"Report to Medical immediately.",
			"Do NOT spread memetic content through radio or intercom.",
			"Administer amnestics per protocol.",
		)
	)

/datum/scp_documentation_manager/proc/get_documentation(section_key)
	if(section_key in documentation_sections)
		return documentation_sections[section_key]
	return null

/datum/scp_documentation_manager/proc/get_all_sections()
	return documentation_sections.Copy()

var/global/datum/scp_documentation_manager/GLOB_SCP_DOCS = new /datum/scp_documentation_manager()

/mob/proc/scp_system_help()
	set name = "SCP System Help"
	set category = "SCP Admin"
	set desc = "Access comprehensive SCP system documentation"

	if(!client || !check_rights(R_ADMIN))
		return

	var/list/section_choices = list()
	for(var/key in GLOB_SCP_DOCS.documentation_sections)
		var/list/section = GLOB_SCP_DOCS.documentation_sections[key]
		section_choices[section["title"]] = key

	var/choice = input(src, "Select documentation section:", "SCP System Help") in section_choices
	if(!choice)
		return

	var/section_key = section_choices[choice]
	var/list/section = GLOB_SCP_DOCS.get_documentation(section_key)

	if(section)
		to_chat(src, span_boldnotice("=== [section["title"]] ==="))
		for(var/line in section["content"])
			if(line == "")
				to_chat(src, "")
			else
				to_chat(src, span_notice("[line]"))

/mob/proc/scp_system_status()
	set name = "SCP System Status"
	set category = "SCP Admin"
	set desc = "Display comprehensive system status information"

	if(!client || !check_rights(R_ADMIN))
		return

	to_chat(src, "<span class='boldnotice'>=== SCP Foundation Documentation System ===</span>")
	to_chat(src, "<span class='notice'>Version: [GLOB_SCP_DOCS.current_version]</span>")
	to_chat(src, "<span class='notice'>Last Updated: [GLOB_SCP_DOCS.last_updated]</span>")
	to_chat(src, "<span class='notice'>Documentation Sections: [length(GLOB_SCP_DOCS.documentation_sections)]</span>")
	to_chat(src, "")
	to_chat(src, "<span class='notice'>Use 'SCP System Help' for documentation</span>")

	// Component System Status
	to_chat(src, span_boldnotice("Core Systems:"))
	to_chat(src, span_notice("• Advanced Components: [ispath(/datum/scp_advanced_component) ? "OK Available" : "X Missing"]"))
	to_chat(src, span_notice("• Component Manager: [ispath(/datum/component_manager_advanced) ? "OK Available" : "X Missing"]"))
	to_chat(src, span_notice("• SCP Extensions: [ispath(/datum/scp) ? "OK Available" : "X Missing"]"))
	to_chat(src, "")

	// Network Systems
	to_chat(src, span_boldnotice("Network Systems:"))
	to_chat(src, span_notice("• SCP Network Hub: [GLOB_SCP_NETWORK ? "OK Active ([length(GLOB_SCP_NETWORK.connected_scps)] SCPs)" : "X Inactive"]"))
	to_chat(src, span_notice("• Effect System: [ispath(/datum/scp_component_effect) ? "OK Available" : "X Missing"]"))
	to_chat(src, span_notice("• Component Database: [GLOB_COMPONENT_DB ? "OK Active" : "X Inactive"]"))
	to_chat(src, "")

	// Converted SCPs Status
	to_chat(src, span_boldnotice("Human-Converted SCPs:"))
	var/list/converted_scps = list(
		"SCP-049" = /mob/living/scp/scp049,
		"SCP-082" = /mob/living/scp/scp082,
		"SCP-096" = /mob/living/scp/scp096,
		"SCP-343" = /mob/living/scp/scp343,
		"SCP-939" = /mob/living/scp/scp939,
		"SCP-966" = /mob/living/scp/scp966
	)

	for(var/scp_name in converted_scps)
		var/scp_type = converted_scps[scp_name]
		var/status = ispath(scp_type) && ispath(scp_type, /mob/living/carbon/human) ? "✅ Converted" : "❌ Not Converted"
		to_chat(src, span_notice("• [scp_name]: [status]"))

	to_chat(src, "")
	to_chat(src, span_notice("Use 'SCP System Help' for detailed documentation"))
	to_chat(src, span_notice("Use 'Validate SCP Integration' for system testing"))

// Quick system statistics
/mob/proc/scp_quick_stats()
	set name = "SCP Quick Stats"
	set category = "SCP Admin"
	set desc = "Display quick system statistics"

	if(!client || !check_rights(R_ADMIN))
		return

	var/active_scps = 0
	var/component_scps = 0

	for(var/mob/living/M in GLOB.mob_list)
		if(QDELETED(M))
			continue
		if(M.SCP)
			active_scps++
			if(M.SCP.uses_advanced_components)
				component_scps++

	to_chat(src, span_boldnotice("=== Quick SCP Statistics ==="))
	to_chat(src, span_notice("Active SCPs: [active_scps]"))
	to_chat(src, span_notice("Component-Based SCPs: [component_scps]"))
	to_chat(src, span_notice("Network Registered: [GLOB_SCP_NETWORK ? length(GLOB_SCP_NETWORK.connected_scps) : 0]"))
	to_chat(src, span_notice("System Status: [component_scps > 0 ? "OK Active" : "! No Components Active"]"))

// Component examination helper
/mob/proc/examine_scp_components()
	set name = "Examine SCP Components"
	set category = "SCP Admin"
	set desc = "Examine components of targeted SCP"

	if(!client || !check_rights(R_ADMIN))
		return

	var/mob/living/target = input(src, "Select SCP to examine:", "Component Examination") as null|mob in GLOB.mob_list

	if(!target || !target.SCP)
		to_chat(src, span_warning("Target is not an SCP."))
		return

	if(!target.SCP.uses_advanced_components)
		to_chat(src, span_warning("Target SCP does not use advanced components."))
		return

	to_chat(src, span_boldnotice("=== SCP Component Analysis: [target.SCP.designation] ==="))
	to_chat(src, span_notice("Name: [target.SCP.name]"))
	to_chat(src, span_notice("Classification: [target.SCP.classification]"))
	to_chat(src, "")

	// List all components
	if(target.SCP.advanced_components)
		to_chat(src, span_boldnotice("Active Components:"))
		for(var/component_id in target.SCP.advanced_components.components)
			var/datum/scp_advanced_component/component = target.SCP.advanced_components.components[component_id]
			to_chat(src, span_notice("• [component.name] ([component.version])"))
			to_chat(src, span_notice("  Status: [component.get_status_info()]"))
	else
		to_chat(src, span_warning("No component manager found."))
