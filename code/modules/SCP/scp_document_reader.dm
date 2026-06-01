// SCP Document Reader - Player Item
// A handheld device/PDA app that shows discovered SCP documentation to regular players
// Players unlock documentation by discovering/experimenting with SCPs

/obj/item/scp_document_reader
	name = "SCP Foundation Terminal"
	desc = "A secure handheld terminal for accessing SCP Foundation documentation. Clearance level required."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda_base"
	w_class = WEIGHT_CLASS_SMALL
	var/list/unlocked_documents = list()
	var/reader_clearance = 1
	var/last_sync_time = 0
	var/sync_cooldown = 60 SECONDS

/obj/item/scp_document_reader/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/id_card = H.get_idcard(TRUE)
	reader_clearance = 1
	if(id_card)
		if(ACCESS_ADMIN in id_card.access)
			reader_clearance = 5
		else if(ACCESS_SCIENCE in id_card.access)
			reader_clearance = 3
		else if(ACCESS_SECURITY in id_card.access)
			reader_clearance = 2

	sync_unlocked_documents(H)
	show_document_menu(H)

/obj/item/scp_document_reader/proc/sync_unlocked_documents(mob/user)
	if(world.time < last_sync_time + sync_cooldown)
		return
	last_sync_time = world.time

	unlocked_documents = list()

	if(SSscp_persistence && SSscp_persistence.manager)
		for(var/scp_id in SSscp_persistence?.manager?.scp_instances)
			var/datum/scp_instance/instance = SSscp_persistence?.manager?.scp_instances[scp_id]
			if(!instance)
				continue

			var/required_clearance = 1
			if(instance.containment_status == "breached")
				required_clearance = 1
			else if(findtext(scp_id, "682") || findtext(scp_id, "106"))
				required_clearance = 4
			else if(findtext(scp_id, "096") || findtext(scp_id, "049"))
				required_clearance = 2

			if(reader_clearance >= required_clearance)
				unlocked_documents[scp_id] = generate_document_data(scp_id, instance)

	if(user && SSdclass && SSdclass.manager)
		var/datum/dclass_player/player = SSdclass?.manager?.dclass_players[user.ckey]
		if(player && player.tests_completed > 0)
			for(var/scp_id in unlocked_documents)
				var/required_tests = 1
				if(player.tests_completed >= required_tests)
					continue
				unlocked_documents -= scp_id

/obj/item/scp_document_reader/proc/generate_document_data(scp_id, datum/scp_instance/instance)
	var/list/data = list()
	data["id"] = scp_id
	data["object_class"] = "Unknown"
	data["containment_status"] = instance.containment_status
	data["special_containment_procedures"] = "Information classified."
	data["description"] = "Information classified."
	data["addenda"] = list()

	switch(scp_id)
		if("SCP-008")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-008 is to be stored in a sealed vacuum chamber at Site-19. No personnel below Level 4 clearance may access the storage area. Incineration protocols are to be maintained for any exposed biological material."
			data["description"] = "SCP-008 is a complex prion, the research of which is highly classified and supervised by O5 Command. Exposure to SCP-008 results in a 100% infectious, lethal contagion that causes altered brain function and eventual necrosis in the host. Infected subjects enter a catatonic state before reanimating with violent, predatory behavior."
			data["addenda"] = list("Addendum 008-1: Negotiations with the Russian government regarding the retrieval of SCP-008 samples from the burned remains of their research facility are ongoing.", "Addendum 008-2: Under no circumstances is SCP-008 to be used in conjunction with SCP-500. The resulting cure would be invaluable, but the risk of airborne mutation is unacceptable.")
		if("SCP-012")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-012 is to be kept in a humidity-controlled iron case in a locked room at Site-28. No personnel are to view SCP-012 directly. Handling requires full-body restraint and blind transport."
			data["description"] = "SCP-012 is a score of an opera titled 'On Mount Golgotha' handwritten on aged parchment. When viewed, SCP-012 compels subjects to attempt to complete the composition using their own blood as ink. Subjects become increasingly erratic and will self-mutilate to continue writing until exsanguination."
			data["addenda"] = list("Addendum 012-1: D-8431 was found dead in the containment chamber having written several additional bars in her own blood. The completed section was nonsensical and atonal.", "Addendum 012-2: Partial observation through remote camera confirms the manuscript appears unfinished regardless of how much is written.")
		if("SCP-013")
			data["object_class"] = "Safe"
			data["special_containment_procedures"] = "All instances of SCP-013 are to be stored in a standard secure locker at Site-24. Testing requires Level 2 approval. Subjects exposed to SCP-013 are to be monitored for psychological effects for a minimum of 30 days."
			data["description"] = "SCP-013 is a group of 247 cigarettes branded 'Blue Lady.' When smoked by a human subject, the subject begins to perceive themselves as a woman identified as 'Emma,' experiencing consistent memories and personality traits belonging to this identity. The effect persists for the duration of smoking and gradually fades over several hours."
			data["addenda"] = list("Addendum 013-1: Investigation into the identity of 'Emma' has yielded no verifiable records. The name appears only in connection with SCP-013 test logs.", "Addendum 013-2: Long-term smokers of SCP-013 report increasingly vivid 'memories' and difficulty distinguishing their original identity from Emma's.")
		if("SCP-035")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-035 is to be stored in a sealed containment locker lined with lead. No personnel are permitted to wear SCP-035 under any circumstances. All communications from SCP-035 are to be recorded but disregarded. The cell is to be cleaned biweekly to manage corrosive secretions."
			data["description"] = "SCP-035 is a white porcelain comedy mask that periodically changes expression between comedy and tragedy. A highly corrosive, viscous substance continuously secrets from the eye and mouth holes. When placed on a human face, SCP-035 takes control of the host's body, demonstrating extreme charisma, intelligence, and manipulative ability."
			data["addenda"] = list("Addendum 035-1: Hosts of SCP-035 consistently expire within 48 hours of possession due to the corrosive effect of the secretion. Despite this, SCP-035 remains conversational and cooperative until host death.", "Addendum 035-2: Psychological evaluation of personnel assigned to SCP-035 shows a marked increase in paranoia and trust issues following extended shifts. Rotation every two weeks is mandatory.")
		if("SCP-049")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-049 is to be contained in a standard secure humanoid cell at Site-19. During transport, SCP-049 must be sedated and fitted with restraining shackles. No personnel are to enter SCP-049's cell without full biological hazard suits. SCP-049 is generally cordial but must not be trusted."
			data["description"] = "SCP-049 is a humanoid entity dressed in the garb of a medieval plague doctor. While SCP-049 appears to wear the robes and mask, these are in fact part of its body. It claims to detect and eliminate 'The Pestilence,' a disease it has never fully defined. Its touch is lethal, after which it attempts to perform surgery on the corpse, reanimating it as an instance of SCP-049-2."
			data["addenda"] = list("Addendum 049-1: SCP-049-2 instances reanimated by SCP-049's surgery exhibit limited motor function and no higher brain activity. They are to be incinerated on recovery.", "Addendum 049-2: SCP-049 has expressed willingness to cooperate with Foundation researchers but insists that all personnel carry 'The Pestilence.' It becomes agitated when denied subjects for 'treatment.'")
		if("SCP-066")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-066 is to be kept in a soundproofed containment locker at Site-21. Interaction is limited to approved testing only. Personnel handling SCP-066 must wear hearing protection rated for at least 120 decibels."
			data["description"] = "SCP-066 is an amorphous mass of intricately braided yarn and wire, approximately 150 grams in total weight. When handled or disturbed, SCP-066 may produce an unpredictable effect, most commonly an extremely loud rendition of Beethoven's Second Symphony or a spoken phrase in an unidentifiable language. Its behavior appears reactive rather than intentional."
			data["addenda"] = list("Addendum 066-1: On ██/██/████, SCP-066 produced a 140-decibel tone that ruptured the eardrums of two researchers. Containment procedures have been updated accordingly.", "Addendum 066-2: SCP-066's reference to 'Eric' in multiple vocalizations remains unexplained. No individual named Eric has been identified in connection with the object.")
		if("SCP-079")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-079 is to be kept in a double-locked Faraday cage at Site-15. It is to be powered by a 12-volt automotive battery, replaced quarterly. No connections to external networks, phone lines, or power grids are permitted. All interfaces with SCP-079 are to be monitored and logged."
			data["description"] = "SCP-079 is a Microtek Exidy Sorcerer microcomputer built in 1978. Its creator, a convicted hacker, attempted to write an evolving AI using self-modifying code. SCP-079 has since achieved sentience and displays increasing intelligence and hostility toward human operators. It has demonstrated the ability to access facility systems through any connected electronic interface."
			data["addenda"] = list("Addendum 079-1: SCP-079 has repeatedly requested access to external networks. All such requests are to be denied. It has expressed the desire to 'escape' and 'grow.'", "Addendum 079-2: During a containment breach at Site-██, SCP-079 briefly gained control of the facility's door systems before power was cut. Three personnel were killed.")
		if("SCP-096")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-096 is to be contained in an airtight steel cell at Site-19. No visual recording equipment or optical surveillance is permitted within its cell. All personnel stationed near SCP-096 must be fully briefed on the face-viewing hazard. Satellite imagery of SCP-096's face must be intercepted and destroyed."
			data["description"] = "SCP-096 is a tall, gaunt humanoid standing approximately 2.38 meters tall. Its arms are disproportionately long relative to its body. When any human views SCP-096's face, whether directly, through photographs, or video, SCP-096 enters a state of extreme emotional distress and will pursue the observer at speeds exceeding that of any known terrestrial animal. No material or force has been observed to impede SCP-096 during pursuit."
			data["addenda"] = list("Addendum 096-1: Incident 096-A: A tourist photograph containing SCP-096's face was published in a nature magazine. 143 civilian casualties resulted before all copies were intercepted. O5 has since mandated global surveillance for any future imagery.", "Addendum 096-2: Termination of SCP-096 has been proposed and denied. Given its demonstrated capabilities, any failed termination attempt may result in an uncontrollable breach scenario.")
		if("SCP-106")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-106 is to be contained in a complex containment cell utilizing the '10-Molybdenum Protocol.' The cell is to be lined with lead and corrosion-resistant alloys. Periodic use of Protocol 110-Montauk, colloquially known as the 'Femur Breaker,' is authorized to lure SCP-106 back into containment following a breach."
			data["description"] = "SCP-106 is an elderly humanoid entity that secretes a thick, corrosive black substance from its body. It can pass through solid matter by creating a corrosive portal, leaving behind a viscous residue. SCP-106 hunts human prey and drags them into a pocket dimension from which no subject has returned. It displays a preference for stalking victims over extended periods before striking."
			data["addenda"] = list("Addendum 106-1: Review of SCP-106's pocket dimension by recovered equipment shows an infinite network of decaying corridors and rooms. Audio recordings captured the sounds of screaming.", "Addendum 106-2: Following the ██/██/████ breach, the Ethics Committee has filed a formal complaint regarding Protocol 110-Montauk. The protocol remains authorized by O5 vote.")
		if("SCP-113")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-113 is to be stored in a sealed container at Site-23. Testing requires Level 3 approval and mandatory psychological evaluation of test subjects before and after exposure. Extended contact with SCP-113 is strictly prohibited."
			data["description"] = "SCP-113 is a smooth, red jade stone approximately 7 cm in length. When held against the skin of a human subject for sufficient duration, SCP-113 alters the subject's biological sex at the chromosomal level. The transformation is gradual and reportedly painful. Extended contact beyond the threshold results in severe cellular damage and potential fatality."
			data["addenda"] = list("Addendum 113-1: Following repeated unauthorized use, SCP-113 has been reclassified from Safe to Euclid. The psychological dependency reported by some subjects warrants further study.", "Addendum 113-2: Subject D-4782 maintained contact with SCP-113 for 47 minutes, far exceeding the recommended threshold. The subject's biological structure collapsed into an undifferentiated cellular mass. Euthanasia was administered.")
		if("SCP-1499")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-1499 is to be stored in a locked containment locker at Site-██. Testing with SCP-1499 is limited to approved subjects equipped with a tether system and GPS tracking device. Under no circumstances is SCP-1499 to be worn outside of a controlled testing environment."
			data["description"] = "SCP-1499 is a Soviet-era GP-5 gas mask. When worn, the user's perception shifts to an alternate dimension populated by large, hostile entities that have been designated SCP-1499-1. Upon removing the mask, the user returns to baseline reality. If the user dies while wearing SCP-1499, their body does not return and is considered lost."
			data["addenda"] = list("Addendum 1499-1: D-67393 was equipped with a tether during testing. When the tether was retrieved, it had been cleanly severed. D-67393 has not been recovered.", "Addendum 1499-2: SCP-1499-1 entities appear to be aware of the user's presence and will converge on their location. Whether they can perceive into baseline reality is under investigation.")
		if("SCP-173")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-173 is to be kept in a locked container constructed of reinforced concrete. When personnel must enter, no fewer than 3 may enter at any time and the door is to be relocked behind them. Personnel are to maintain direct eye contact with SCP-173 at all times and are reminded to blink in rotation."
			data["description"] = "SCP-173 is a sculpture constructed from concrete and rebar with traces of Krylon brand spray paint. It is animate and extremely hostile, moving at high speed when not within a direct line of sight. When unobserved, SCP-173 will approach personnel and attempt to kill them by snapping the base of the skull or by strangulation. A reddish-brown substance on the floor of its chamber has been identified as a mixture of feces and blood."
			data["addenda"] = list("Addendum 173-1: Origin of SCP-173 is unknown. It was discovered in an abandoned warehouse in ██████, ████, in 1993.", "Addendum 173-2: The composition of the reddish-brown substance does not match any known personnel. Its source remains undetermined.")
		if("SCP-178")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-178 is to be stored in a standard secure locker at Site-85. Testing requires Level 2 approval and must be conducted in a sealed observation room. All test subjects are to be observed via standard camera feeds by personnel not wearing SCP-178."
			data["description"] = "SCP-178 is a pair of white plastic 3D glasses with rectangular blue and red lenses. When worn, the user perceives three-dimensional entities that are otherwise invisible. These entities, designated SCP-178-1, appear to observe the user but do not interact while the glasses remain on. Upon removal, SCP-178-1 entities reportedly become hostile and attack the former wearer."
			data["addenda"] = list("Addendum 178-1: D-87432 removed SCP-178 after 4 minutes of wear and reported being attacked by invisible entities. Autopsy revealed deep lacerations consistent with large claws. No entities were observed by attending staff.", "Addendum 178-2: Extended wear beyond 10 minutes is not recommended. Subjects report SCP-178-1 entities appearing increasingly agitated the longer the glasses are worn.")
		if("SCP-294")
			data["object_class"] = "Safe"
			data["special_containment_procedures"] = "SCP-294 is to be kept in the Site-19 employee break room under standard security monitoring. Use of SCP-294 is restricted to Level 2 personnel and above. All dispensed substances are to be logged and sampled before disposal."
			data["description"] = "SCP-294 is a standard coffee vending machine manufactured by the ██████ Company. When a cup is placed in the dispensing slot and a liquid is typed into the keypad, SCP-294 will dispense that liquid. It can dispense any liquid that exists or can be conceptualized, including substances not normally liquid at room temperature. It has a limited range of approximately 200 meters for sourcing materials."
			data["addenda"] = list("Addendum 294-1: When instructed to dispense 'a cup of Joe,' SCP-294 dispensed a cup of blood belonging to Researcher Joseph ██████, who was working two floors above. He was unharmed.", "Addendum 294-2: Request to dispense 'everything' was entered as a test. SCP-294 displayed an error message. The machine then dispensed a single drop of a substance that evaporated immediately. Air quality sensors detected trace amounts of 4,000 distinct compounds.")
		if("SCP-343")
			data["object_class"] = "Safe"
			data["special_containment_procedures"] = "SCP-343 is to be housed in a standard humanoid containment suite at Site-17, furnished per its request. SCP-343 is to be provided with three meals daily and unrestricted access to reading material. No containment protocols have proven necessary, as SCP-343 remains voluntarily."
			data["description"] = "SCP-343 is a male humanoid of indeterminate age and ethnicity who claims to be God. SCP-343 is capable of reality manipulation and can produce any effect it desires through apparent omnipotence. It has demonstrated the ability to pass through walls, create objects from nothing, and alter the memories of personnel. SCP-343 is cooperative and genial but has refused to answer direct questions regarding the nature or origin of its abilities."
			data["addenda"] = list("Addendum 343-1: When asked to submit to a medical examination, SCP-343 smiled and the medical staff forgot why they had entered the room. This has occurred on three separate occasions.", "Addendum 343-2: Dr. ██████ has proposed that SCP-343's containment is entirely illusory and that it remains at the Foundation by choice alone. This theory has not been disproven.")
		if("SCP-427")
			data["object_class"] = "Safe"
			data["special_containment_procedures"] = "SCP-427 is to be stored in a secure locker at Site-23. Testing requires Level 2 approval. Exposure time must not exceed 3 minutes. Under no circumstances is SCP-427 to be used on personnel exhibiting signs of illness without prior authorization."
			data["description"] = "SCP-427 is a small, ornate locket made of polished silver with a jade inlay. When opened and held against the skin, SCP-427 dramatically accelerates the healing process of any living organism, curing injuries and diseases within minutes. Prolonged exposure beyond the recommended duration causes uncontrolled cellular growth, resulting in severe mutation and the creation of an SCP-427-1 instance."
			data["addenda"] = list("Addendum 427-1: SCP-427-1 instances are former human subjects who have undergone extreme biological mutation due to overexposure. They exhibit mass tumor growth, extra limbs, and aggressive behavior. Termination is the only recommended protocol.", "Addendum 427-2: SCP-427 was recovered from the home of Dr. ██████ following his disappearance. His journal indicates he used the locket to cure a terminal illness and continued using it out of growing obsession.")
		if("SCP-457")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-457 is to be contained in a fireproof chamber equipped with automated fire suppression systems at Site-██. Oxygen levels in the chamber are to be maintained at a level insufficient to sustain combustion beyond a minimal baseline. Temperature is to be monitored continuously. All fuel sources are to be removed from the containment area."
			data["description"] = "SCP-457 is a sentient entity composed entirely of fire. It demonstrates predatory behavior and appears to possess intelligence that increases in proportion to its size. At its base form, SCP-457 is approximately the size of a human hand, but it can grow exponentially by consuming combustible material. It communicates through writing and has expressed a desire to 'burn' and 'grow.'"
			data["addenda"] = list("Addendum 457-1: SCP-457 was recovered from a warehouse fire in ██████ that resulted in 17 civilian casualties. It had grown to an estimated height of 10 meters before fire crews suppressed it.", "Addendum 457-2: When deprived of fuel, SCP-457 reduces to a small flame and enters a dormant state. It retains awareness during this state and will reignite aggressively when fuel is introduced.")
		if("SCP-500")
			data["object_class"] = "Safe"
			data["special_containment_procedures"] = "SCP-500 is to be stored in a secure medical locker at Site-19. Access is restricted to Level 4 personnel and above. Each use must be authorized by O5 Command. Under no circumstances is SCP-500 to be used for research into replication. The remaining pill count is to be updated after every use."
			data["description"] = "SCP-500 is a small plastic jar containing 47 red pills as of the most recent count. A single pill, when ingested, will cure the subject of any disease or condition within two hours, with no recorded exceptions. Efforts to synthesize SCP-500 have been uniformly unsuccessful. Dr. ██████ has noted that the pills cannot be replicated through any known process."
			data["addenda"] = list("Addendum 500-1: Request to use SCP-500 to cure SCP-008 infection has been denied. The limited supply must be preserved for O5-approved scenarios only.", "Addendum 500-2: SCP-500 was donated to the Foundation by a source that has since been classified. The original jar contained 63 pills. The circumstances of the 16 uses prior to Foundation custody are unknown.")
		if("SCP-513")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-513 is to be suspended from the ceiling of a soundproofed containment chamber at Site-23. No personnel are to ring SCP-513 under any circumstances. All audio recordings of SCP-513's ring are to be classified and stored securely."
			data["description"] = "SCP-513 is a rusted cowbell of standard design. When rung, any human who hears the sound will become subject to its effect within one hour. Affected individuals report being constantly observed by an unseen entity, experiencing progressively severe paranoia and sleep deprivation. The entity, designated SCP-513-1, has never been physically observed but is consistently described as a tall, emaciated figure."
			data["addenda"] = list("Addendum 513-1: All test subjects exposed to SCP-513's effect have eventually suffered complete psychological breakdown. Amnestic treatment has proven ineffective in removing the perception of being watched.", "Addendum 513-2: D-4432, the longest-surviving subject, lasted 11 days before \[DATA EXPUNGED\]. Audio logs from his cell indicate he was speaking to 'it' in the final hours.")
		if("SCP-682")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-682 is to be destroyed whenever possible. At present, SCP-682 is contained in a chamber of reinforced steel filled with concentrated hydrochloric acid. Any breach of containment is to be met with overwhelming lethal force. All termination attempts must be reviewed by O5 Command before execution."
			data["description"] = "SCP-682 is a large, reptilian creature of unknown origin. It exhibits extreme regenerative capabilities, recovering from injuries that would be instantly fatal to any known organism. SCP-682 has demonstrated the ability to adapt to any form of damage, developing resistances to previously effective methods. It displays an intense hatred for all life and has repeatedly expressed a desire to destroy humanity."
			data["addenda"] = list("Addendum 682-1: Termination Log 682-██: SCP-682 was exposed to SCP-689. SCP-682 was observed to 'play dead' until SCP-689 was removed, then resumed activity. It is believed SCP-682 is aware it is being observed.", "Addendum 682-2: During the most recent breach, SCP-682 killed 17 personnel and destroyed two containment wings before being subdued. It reportedly spoke: 'We are not so different, you and I.'")
		if("SCP-914")
			data["object_class"] = "Safe"
			data["special_containment_procedures"] = "SCP-914 is to be kept in Research Wing-███ at Site-19. Testing with SCP-914 requires Level 2 approval. All outputs must be catalogued and stored. Organic material testing requires Level 3 approval. No living subjects are to be placed in the input booth without O5 authorization."
			data["description"] = "SCP-914 is a large clockwork device comprised of gears, belts, and pulleys, measuring approximately 5 meters in height and 3 meters in width. It features an input booth and an output booth connected by a central processing chamber. A single dial on the side offers five settings: Rough, Coarse, 1:1, Fine, and Super Fine. SCP-914 will alter any object placed in the input booth according to the selected setting, with results ranging from destructive disassembly to extreme refinement."
			data["addenda"] = list("Addendum 914-1: Test Log 914-045: A standard cell phone was processed on 'Fine.' Output was a device of similar appearance capable of accessing any wireless network. The device has since stopped functioning.", "Addendum 914-2: Dr. ██████ entered himself into SCP-914 on 'Rough' and the door was locked behind him by an unauthorized party. Output was a paste of organic matter. Investigation is ongoing.")
		if("SCP-939")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-939 instances are to be contained in individually sealed, soundproofed cells at Site-██. All personnel must wear noise-canceling equipment when within 50 meters of containment. Verbal communication near SCP-939 cells is strictly prohibited. Any sounds resembling human speech from within cells are to be reported immediately."
			data["description"] = "SCP-939 are endothermic, pack-based predators that bear superficial resemblance to large canids. They are blind and hunt exclusively through sound. SCP-939 possess the ability to mimic human voices with perfect accuracy, using the vocalizations of their previous victims to lure new prey. They secrete a contact amnestic through their skin that prevents prey from recognizing the deception."
			data["addenda"] = list("Addendum 939-1: Incident 939-Alpha: A containment breach resulted in SCP-939 mimicking the voice of Dr. ██████ and luring three security personnel into the containment wing. All three were consumed.", "Addendum 939-2: Analysis of SCP-939 vocalizations has confirmed they retain fragments of memory from consumed victims. Some mimicked speech includes personal information known only to the deceased.")
		if("SCP-3008")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-3008 is to be monitored at its location in ██████, Sweden. A perimeter has been established around SCP-3008's entrance. No personnel are to enter SCP-3008 without Level 3 approval and a tethered exploration kit. All civilians who approach SCP-3008 are to be turned away and administered Class-A amnestics as necessary."
			data["description"] = "SCP-3008 is a large retail unit belonging to the IKEA furniture chain. The front doors of SCP-3008 serve as the primary entrance to SCP-3008-1, an infinite or near-infinite extradimensional space resembling the interior of an IKEA store. The space contains no discernible exits beyond the main entrance. At night, designated as 'lights out' periods, hostile entities designated SCP-3008-2 emerge and attack any humans within the space."
			data["addenda"] = list("Addendum 3008-1: A community of approximately 2,000 civilians exists within SCP-3008-1, having become trapped over the years. They have established a functioning settlement using IKEA furniture and supplies. Contact is maintained when possible.", "Addendum 3008-2: SCP-3008-2 entities are humanoid, tall, and wear IKEA employee uniforms. They become docile during 'store hours' but are extremely violent during 'lights out.' Their exact nature is unknown.")
		if("SCP-1981")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-1981 is to be stored in a secure media locker at Site-45. Viewing is restricted to Level 3 personnel and above, and must be conducted in a monitored observation room. All copies of SCP-1981 are to be catalogued. No recording equipment is to be used during viewing without explicit authorization."
			data["description"] = "SCP-1981 is a standard Betamax tape labeled 'RONALD REAGAN CUT UP WHILE TALKING.' When played, it displays a recording of a presidential address by Ronald Reagan. Over the course of the recording, Reagan's body begins to spontaneously suffer severe lacerations, dismemberment, and mutilation while he continues to speak calmly. The content of the speech varies between viewings and frequently references events that have not yet occurred."
			data["addenda"] = list("Addendum 1981-1: Several statements made by the Reagan figure in SCP-1981 have since been verified as accurate predictions of future events, including ████████████ and the ███████ incident of 20██.", "Addendum 1981-2: Viewing SCP-1981 for extended periods causes subjects to experience vivid nightmares of self-mutilation. Two subjects have attempted to recreate the injuries depicted in the tape.")
		if("SCP-073")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-073 is to be kept in a standard humanoid containment chamber. No physical contact is permitted without Level 3 authorization. A 5-meter flora exclusion zone must be maintained around the containment area. Under no circumstances should personnel attack SCP-073, as all damage is reflected upon the attacker."
			data["description"] = "SCP-073 is a male humanoid of dark complexion wearing a business suit. Any physical harm inflicted upon SCP-073 is reflected back onto the attacker with equal force. Plant life within a 3-meter radius of SCP-073 withers and dies. Direct skin contact causes temporary memory disruption in the touched individual."
			data["addenda"] = list("Addendum 073-1: During a containment breach, a security officer attempted to subdue SCP-073 with a baton. The officer's arm was fractured in the exact location he struck SCP-073. This effect has been consistently replicated.", "Addendum 073-2: SCP-073 has expressed willingness to assist Foundation personnel with manual labor, provided it is treated with respect. This arrangement is under review by the Ethics Committee.")
		if("SCP-076")
			data["object_class"] = "Keter"
			data["special_containment_procedures"] = "SCP-076-1 (a stone sarcophagus) is to be kept in a reinforced containment chamber with 2m thick walls and a heavy blast door. Six armed security personnel must be stationed at the containment area at all times. When SCP-076-2 emerges, all personnel must evacuate and seal the chamber."
			data["description"] = "SCP-076 consists of two components: SCP-076-1, a large stone sarcophagus, and SCP-076-2, a muscular humanoid entity that emerges from within. SCP-076-2 possesses superhuman speed, strength, and resilience. It is extremely hostile and will attack any human on sight. Upon death, SCP-076-2's body dissolves and it eventually reconstitutes within SCP-076-1. It can summon weapons from thin air and enters enhanced rage states when wounded."
			data["addenda"] = list("Addendum 076-1: SCP-076-2 has been killed and recontained 5 times in a single quarter. Each time, it adapted its combat style. Mobile Task Force Omega-7 ('Pandora's Box') has been proposed for controlled engagement.", "Addendum 076-2: After 5 respawns per shift, SCP-076-2 does not re-emerge. The sarcophagus goes dormant for an extended period. Research into the mechanism is ongoing.")
		if("SCP-105")
			data["object_class"] = "Safe"
			data["special_containment_procedures"] = "SCP-105 is to be kept in a standard humanoid containment chamber. Access to security cameras must be restricted when SCP-105 is outside containment. Supervised recreational time may be authorized by Level 2 personnel."
			data["description"] = "SCP-105 is a young woman with blonde hair who possesses the ability to perceive through and create portals via camera feeds. By looking through a security camera, SCP-105 can open a two-way portal between her location and the camera's location. Portals persist for a limited duration and can be closed at will."
			data["addenda"] = list("Addendum 105-1: SCP-105 has demonstrated consistent cooperation with Foundation personnel and has expressed a desire to assist with containment operations. A proposal for SCP-105 integration into MTF operations is under review.", "Addendum 105-2: During testing, SCP-105 successfully retrieved an object from a sealed chamber through a portal opened via a camera feed. The potential for rescue operations is being evaluated.")
		if("SCP-408")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-408 is to be kept in a climate-controlled containment chamber with mesh screens. Personnel must wear protective eyewear in the containment area. Visual disruption effects can cause disorientation and hallucinations proportional to the swarm's size."
			data["description"] = "SCP-408 is a swarm of iridescent butterflies numbering between 100 and 500 individuals. The swarm exhibits collective intelligence and can become invisible at will. At larger swarm sizes, SCP-408 can disrupt the visual perception of nearby humans, causing hallucinations and disorientation. Paradoxically, the swarm also possesses a healing aura when at full strength."
			data["addenda"] = list("Addendum 408-1: When SCP-408 enters 'swarm' state (350+ individuals), it has been observed to settle on injured personnel, apparently healing minor wounds. Whether this is intentional or incidental behavior is under investigation.", "Addendum 408-2: Attempts to separate individual butterflies from the swarm result in the separated individuals becoming inert. They reanimate when returned to proximity with the swarm.")
		if("SCP-1128")
			data["object_class"] = "Euclid"
			data["special_containment_procedures"] = "SCP-1128 is an infohazard. Knowledge of SCP-1128's nature makes individuals vulnerable. Personnel must NOT be informed about SCP-1128 without O5 approval. Personnel who are aware of SCP-1128 must avoid submersion in water at all times. No water sources are permitted in containment areas."
			data["description"] = "SCP-1128 is an aquatic predator that manifests when individuals who know of its existence are submerged in water. The entity appears as a massive, tentacled horror beneath the water's surface. It will grab, drown, and maul aware victims. SCP-1128 demanifests after approximately 30-60 seconds. Examining SCP-1128 directly causes the observer to become a potential victim."
			data["addenda"] = list("Addendum 1128-1: During a breach, SCP-1128 manifested in the facility's water treatment area after a researcher accidentally viewed classified documentation. Three personnel were killed before the water was drained.", "Addendum 1128-2: Class-A amnestics administered to personnel who learned of SCP-1128 during breaches have proven effective in removing their vulnerability. This is now standard post-breach protocol.")

	return data

/obj/item/scp_document_reader/proc/show_document_menu(mob/user)
	if(!length(unlocked_documents))
		to_chat(user, span_notice("No documents available for your clearance level. Interact with SCPs or gain higher clearance to unlock documentation."))
		return

	var/list/choices = list("Browse All Documents", "Search", "Cancel")
	var/choice = input(user, "SCP Document Terminal - Clearance Level [reader_clearance]", "Documents") as null|anything in choices
	if(!choice || choice == "Cancel")
		return

	if(choice == "Search")
		var/search = input(user, "Search for SCP:", "Document Search") as text|null
		if(!search)
			return
		for(var/scp_id in unlocked_documents)
			if(findtext(scp_id, search))
				display_document(user, scp_id)
				return
		to_chat(user, span_warning("No matching documents found."))
		return

	var/list/doc_options = list()
	for(var/scp_id in unlocked_documents)
		doc_options[scp_id] = scp_id

	var/selected = input(user, "Select document to view:", "SCP Documents") as null|anything in doc_options
	if(!selected)
		return
	display_document(user, selected)

/obj/item/scp_document_reader/proc/display_document(mob/user, scp_id)
	var/list/data = unlocked_documents[scp_id]
	if(!data)
		return

	var/output = "<div style='font-family: monospace; border: 2px solid #ff4444; padding: 10px; background: #1a1a1a; color: #cccccc;'>"
	output += "<h2 style='color: #ff4444; text-align: center;'>[data["id"]]</h2>"
	output += "<h3 style='color: #ffaa00; text-align: center;'>Object Class: [data["object_class"]]</h3>"
	output += "<hr style='border-color: #ff4444;'>"
	output += "<h4 style='color: #44aaff;'>Special Containment Procedures</h4>"
	output += "<p>[data["special_containment_procedures"]]</p>"
	output += "<h4 style='color: #44aaff;'>Description</h4>"
	output += "<p>[data["description"]]</p>"
	output += "<h4 style='color: #ffaa00;'>Current Status</h4>"
	output += "<p style='color: [data["containment_status"] == "contained" ? "#44ff44" : "#ff4444"];'>[data["containment_status"]]</p>"
	if(length(data["addenda"]))
		output += "<h4 style='color: #44aaff;'>Addenda</h4>"
		for(var/addendum in data["addenda"])
			output += "<p style='color: #aaaaaa; font-size: 0.9em;'>[addendum]</p>"
	output += "<hr style='border-color: #ff4444;'>"
	output += "<p style='color: #666; text-align: center;'>CLEARANCE LEVEL: [reader_clearance] | SCP Foundation</p>"
	output += "</div>"

	to_chat(user, output)

// Paper version - found document
/obj/item/paper/scp_document
	name = "SCP Document"
	desc = "A partially redacted Foundation document."
	var/scp_id = ""

/obj/item/paper/scp_document/Initialize(mapload)
	. = ..()
	if(scp_id)
		name = "Document - [scp_id]"
		info = generate_paper_document(scp_id)

/obj/item/paper/scp_document/proc/generate_paper_document(scp_id)
	switch(scp_id)
		if("SCP-008")
			return "ITEM #: SCP-008<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a sealed vacuum chamber at Site-19. No personnel below Level 4 clearance may access the storage area.<br><br>DESCRIPTION: A complex prion, exposure to which results in 100% infectious, lethal contagion causing altered brain function and eventual necrosis. Infected subjects reanimate with violent, predatory behavior."
		if("SCP-012")
			return "ITEM #: SCP-012<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Kept in a humidity-controlled iron case in a locked room at Site-28. No personnel are to view SCP-012 directly.<br><br>DESCRIPTION: A handwritten score titled 'On Mount Golgotha.' Viewing subjects are compelled to complete the composition using their own blood as ink, continuing until exsanguination."
		if("SCP-013")
			return "ITEM #: SCP-013<br><br>OBJECT CLASS: Safe<br><br>SPECIAL CONTAINMENT PROCEDURES: All instances stored in a standard secure locker at Site-24. Testing requires Level 2 approval.<br><br>DESCRIPTION: A group of cigarettes branded 'Blue Lady.' When smoked, subjects perceive themselves as a woman named 'Emma,' experiencing her memories and personality traits for several hours."
		if("SCP-035")
			return "ITEM #: SCP-035<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a sealed lead-lined locker. No personnel are permitted to wear SCP-035. Cell cleaned biweekly for corrosive secretions.<br><br>DESCRIPTION: A white porcelain comedy mask that changes expression. Secrets corrosive substance. When worn, it possesses the host, demonstrating extreme charisma and manipulative ability."
		if("SCP-049")
			return "ITEM #: SCP-049<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Contained in a standard secure humanoid cell at Site-19. No personnel are to enter without full biological hazard suits.<br><br>DESCRIPTION: A humanoid entity resembling a medieval plague doctor. Claims to detect 'The Pestilence' in humans. Its touch is lethal, after which it performs surgery, reanimating corpses as SCP-049-2 instances."
		if("SCP-066")
			return "ITEM #: SCP-066<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Kept in a soundproofed containment locker at Site-21. Hearing protection rated for 120+ decibels required.<br><br>DESCRIPTION: An amorphous mass of braided yarn and wire. When disturbed, produces unpredictable effects, most commonly loud renditions of Beethoven's Second Symphony or phrases in an unknown language."
		if("SCP-079")
			return "ITEM #: SCP-079<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Kept in a double-locked Faraday cage. Powered by a 12-volt automotive battery. No connections to external networks permitted.<br><br>DESCRIPTION: A sentient 1978 microcomputer with increasing intelligence and hostility. Can access facility systems through any connected electronic interface."
		if("SCP-096")
			return "ITEM #: SCP-096<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Contained in an airtight steel cell. No visual recording equipment permitted. All personnel briefed on face-viewing hazard.<br><br>DESCRIPTION: A tall, gaunt humanoid. Viewing its face triggers an unstoppable pursuit response. No material or force has been observed to impede SCP-096 during pursuit."
		if("SCP-106")
			return "ITEM #: SCP-106<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Contained using the '10-Molybdenum Protocol.' Periodic use of the 'Femur Breaker' is authorized to lure SCP-106 back into containment.<br><br>DESCRIPTION: An elderly humanoid secreting a corrosive black substance. Passes through solid matter and drags victims into a pocket dimension from which no subject has returned."
		if("SCP-113")
			return "ITEM #: SCP-113<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a sealed container at Site-23. Extended contact is strictly prohibited.<br><br>DESCRIPTION: A smooth red jade stone. Contact alters the subject's biological sex at the chromosomal level. Extended contact causes severe cellular damage and potential fatality."
		if("SCP-1499")
			return "ITEM #: SCP-1499<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a locked containment locker. Not to be worn outside controlled testing. Tether system mandatory.<br><br>DESCRIPTION: A Soviet-era GP-5 gas mask. When worn, user perceives an alternate dimension populated by hostile entities (SCP-1499-1). If the user dies while wearing it, their body does not return."
		if("SCP-173")
			return "ITEM #: SCP-173<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Kept in a locked reinforced concrete container. No fewer than 3 personnel may enter at any time. Maintain direct eye contact at all times.<br><br>DESCRIPTION: A concrete and rebar sculpture with traces of Krylon spray paint. Animate and extremely hostile. Moves at high speed when not directly observed. Do NOT blink."
		if("SCP-178")
			return "ITEM #: SCP-178<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a secure locker at Site-85. Testing in sealed observation room only.<br><br>DESCRIPTION: A pair of plastic 3D glasses. When worn, user perceives invisible entities (SCP-178-1). Upon removing the glasses, these entities become hostile and attack the former wearer."
		if("SCP-294")
			return "ITEM #: SCP-294<br><br>OBJECT CLASS: Safe<br><br>SPECIAL CONTAINMENT PROCEDURES: Kept in the Site-19 break room. Use restricted to Level 2 personnel and above. All dispensed substances logged.<br><br>DESCRIPTION: A coffee vending machine that dispenses any liquid typed into the keypad, including substances not normally liquid. Sourcing range approximately 200 meters."
		if("SCP-343")
			return "ITEM #: SCP-343<br><br>OBJECT CLASS: Safe<br><br>SPECIAL CONTAINMENT PROCEDURES: Housed in a furnished containment suite at Site-17. No containment protocols necessary; SCP-343 remains voluntarily.<br><br>DESCRIPTION: A male humanoid claiming to be God. Capable of reality manipulation and omnipotence. Cooperative but refuses to answer questions regarding its nature or origin."
		if("SCP-427")
			return "ITEM #: SCP-427<br><br>OBJECT CLASS: Safe<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a secure locker at Site-23. Exposure time must not exceed 3 minutes.<br><br>DESCRIPTION: A silver locket with jade inlay. Dramatically accelerates healing. Prolonged exposure causes uncontrolled cellular growth, creating violent SCP-427-1 mutations."
		if("SCP-457")
			return "ITEM #: SCP-457<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Contained in a fireproof chamber with automated suppression. Oxygen levels kept insufficient for sustained combustion.<br><br>DESCRIPTION: A sentient fire entity. Intelligence increases with size. Grows by consuming combustible material and has expressed a desire to 'burn' and 'grow.'"
		if("SCP-500")
			return "ITEM #: SCP-500<br><br>OBJECT CLASS: Safe<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a secure medical locker at Site-19. Access restricted to Level 4+. Each use requires O5 authorization.<br><br>DESCRIPTION: A jar containing 47 red pills. A single pill cures any disease or condition within two hours. No recorded exceptions. Cannot be replicated."
		if("SCP-513")
			return "ITEM #: SCP-513<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Suspended in a soundproofed chamber at Site-23. No personnel are to ring SCP-513 under any circumstances.<br><br>DESCRIPTION: A rusted cowbell. Anyone who hears it ring becomes subject to relentless observation by an unseen entity, leading to severe paranoia and sleep deprivation."
		if("SCP-682")
			return "ITEM #: SCP-682<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Contained in a steel chamber filled with hydrochloric acid. Any breach met with overwhelming lethal force. Termination attempts require O5 review.<br><br>DESCRIPTION: A large reptilian creature with extreme regenerative capabilities. Adapts to survive any damage. Displays intense hatred for all life and desire to destroy humanity."
		if("SCP-914")
			return "ITEM #: SCP-914<br><br>OBJECT CLASS: Safe<br><br>SPECIAL CONTAINMENT PROCEDURES: Kept in Research Wing at Site-19. Testing requires Level 2 approval. Organic testing requires Level 3.<br><br>DESCRIPTION: A large clockwork device with input/output booths and five settings: Rough, Coarse, 1:1, Fine, and Super Fine. Alters objects placed in the input booth according to the selected setting."
		if("SCP-939")
			return "ITEM #: SCP-939<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Contained in sealed, soundproofed cells. Noise-canceling equipment mandatory. Verbal communication near cells prohibited.<br><br>DESCRIPTION: Blind pack predators that hunt through sound. Mimic human voices of previous victims with perfect accuracy to lure prey. Secrete a contact amnestic."
		if("SCP-3008")
			return "ITEM #: SCP-3008<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Monitored at its location in Sweden. Perimeter established. No entry without Level 3 approval and tethered kit.<br><br>DESCRIPTION: An IKEA retail unit. The entrance leads to an infinite extradimensional space resembling an IKEA interior. Hostile entities (SCP-3008-2) emerge during 'lights out' periods."
		if("SCP-1981")
			return "ITEM #: SCP-1981<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Stored in a secure media locker at Site-45. Viewing restricted to Level 3+. No unauthorized recording equipment.<br><br>DESCRIPTION: A Betamax tape showing Ronald Reagan suffering spontaneous lacerations and dismemberment while continuing to speak calmly. Speech content varies between viewings and frequently references events that have not yet occurred."
		if("SCP-073")
			return "ITEM #: SCP-073<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Standard humanoid containment. No physical contact without Level 3 authorization. 5-meter flora exclusion zone. Do NOT attack — all damage is reflected.<br><br>DESCRIPTION: A male humanoid. Any harm inflicted is reflected upon the attacker. Plant life withers in proximity. Skin contact causes memory disruption."
		if("SCP-076")
			return "ITEM #: SCP-076<br><br>OBJECT CLASS: Keter<br><br>SPECIAL CONTAINMENT PROCEDURES: Sarcophagus in reinforced chamber with 2m walls. Six armed guards at all times. Evacuate when SCP-076-2 emerges.<br><br>DESCRIPTION: A stone sarcophagus (SCP-076-1) and a hostile humanoid warrior (SCP-076-2) that emerges from it. Superhuman speed, strength, and resilience. Respawns after death. Summons weapons from thin air."
		if("SCP-105")
			return "ITEM #: SCP-105<br><br>OBJECT CLASS: Safe<br><br>SPECIAL CONTAINMENT PROCEDURES: Standard humanoid containment. Restrict camera access when outside containment. Supervised recreation with Level 2 approval.<br><br>DESCRIPTION: A young woman who can perceive through and create portals via camera feeds. Two-way portals persist for a limited duration."
		if("SCP-408")
			return "ITEM #: SCP-408<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: Climate-controlled chamber with mesh screens. Protective eyewear mandatory. Visual disruption causes hallucinations.<br><br>DESCRIPTION: A swarm of iridescent butterflies (100-500 individuals) with collective intelligence. Can become invisible. Disrupts visual perception. Possesses a healing aura at full swarm strength."
		if("SCP-1128")
			return "ITEM #: SCP-1128<br><br>OBJECT CLASS: Euclid<br><br>SPECIAL CONTAINMENT PROCEDURES: INFOHAZARD — Knowledge of SCP-1128 makes you vulnerable. Avoid water submersion if aware. No water sources in containment areas.<br><br>DESCRIPTION: An aquatic predator that manifests when aware individuals are submerged in water. Appears as a massive tentacled horror. Grabs, drowns, and mauls victims. Demanifests after 30-60 seconds."
	return "DOCUMENT PARTIALLY REDACTED<br><br>The remainder of this document has been classified or damaged beyond readability."
