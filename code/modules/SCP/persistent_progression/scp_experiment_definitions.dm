#ifndef EXPERIMENT_TYPE_BEHAVIORAL
#define EXPERIMENT_TYPE_BEHAVIORAL 1
#define EXPERIMENT_TYPE_CONTAINMENT 2
#define EXPERIMENT_TYPE_INTERACTION 3
#define EXPERIMENT_TYPE_HAZARD 4
#define EXPERIMENT_TYPE_MEDICAL 5
#define EXPERIMENT_TYPE_TECHNICAL 6
#define EXPERIMENT_TYPE_COGNITIVE 7
#define EXPERIMENT_TYPE_EXPLORATION 8
#define EXPERIMENT_TYPE_CARE 9
#define EXPERIMENT_TYPE_OBSERVATION 10
#define EXPERIMENT_RISK_MINIMAL 1
#define EXPERIMENT_RISK_LOW 2
#define EXPERIMENT_RISK_MEDIUM 3
#define EXPERIMENT_RISK_HIGH 4
#define EXPERIMENT_RISK_CRITICAL 5
#endif

/proc/initialize_all_scp_experiments()
	if(!SSscp_experiments || !SSscp_experiments.manager)
		return
	
	var/datum/scp_experiment_manager/manager = SSscp_experiments.manager
	
	initialize_scp914_experiments(manager)
	initialize_scp049_experiments(manager)
	initialize_scp173_experiments(manager)
	initialize_scp096_experiments(manager)
	initialize_scp106_experiments(manager)
	initialize_scp939_experiments(manager)
	initialize_scp966_experiments(manager)
	initialize_scp457_experiments(manager)
	initialize_scp682_experiments(manager)
	initialize_scp3199_experiments(manager)
	initialize_scp017_experiments(manager)
	initialize_scp082_experiments(manager)
	initialize_scp1507_experiments(manager)
	initialize_scp2427_experiments(manager)
	initialize_scp294_experiments(manager)
	initialize_scp500_experiments(manager)
	initialize_scp427_experiments(manager)
	initialize_scp113_experiments(manager)
	initialize_scp035_experiments(manager)
	initialize_scp012_experiments(manager)
	initialize_scp013_experiments(manager)
	initialize_scp513_experiments(manager)
	initialize_scp895_experiments(manager)
	initialize_scp066_experiments(manager)
	initialize_scp178_experiments(manager)
	initialize_scp714_experiments(manager)
	initialize_scp399_experiments(manager)
	initialize_scp2398_experiments(manager)
	initialize_scp216_experiments(manager)
	initialize_scp2020_experiments(manager)
	initialize_scp3349_experiments(manager)
	initialize_scp5295_experiments(manager)
	initialize_scp1981_experiments(manager)
	initialize_scp999_experiments(manager)
	initialize_scp343_experiments(manager)
	initialize_scp131_experiments(manager)
	initialize_scp2343_experiments(manager)
	initialize_scp1048_experiments(manager)
	initialize_scp087_experiments(manager)
	initialize_scp3008_experiments(manager)
	initialize_scp008_experiments(manager)
	initialize_scp1471_experiments(manager)
	initialize_scp151_experiments(manager)
	initialize_scp1102_experiments(manager)
	initialize_scp420j_experiments(manager)
	initialize_scp5000_experiments(manager)
	initialize_scp080_experiments(manager)
	initialize_scp263_experiments(manager)
	initialize_scp280_experiments(manager)
	initialize_scp527_experiments(manager)
	initialize_scp529_experiments(manager)
	initialize_scp1499_experiments(manager)
	initialize_scp247_experiments(manager)
	initialize_scp079_experiments(manager)
	initialize_scp347_experiments(manager)
	initialize_scp966_experiments_extended(manager)
	initialize_scp082_experiments_extended(manager)
	initialize_scp3199_experiments_extended(manager)
	initialize_scp1048_experiments_extended(manager)
	initialize_scp1507_experiments_extended(manager)
	initialize_scp2427_experiments_extended(manager)
	initialize_scp3008_experiments_extended(manager)

/proc/register_experiment(datum/scp_experiment_manager/manager, scp_id, exp_type, name, desc, risk, duration, cooldown)
	var/template_id = "[scp_id]_[exp_type]"
	var/datum/scp_experiment_template/template = new(template_id, scp_id, exp_type)
	template.name = name
	template.description = desc
	template.risk_level = risk
	template.base_duration = duration
	template.cooldown_time = cooldown
	template.scp_class = get_scp_class(scp_id)
	manager.register_experiment_template(template)

/proc/get_scp_class(scp_id)
	switch(scp_id)
		if("SCP-173", "SCP-049", "SCP-914", "SCP-012", "SCP-013", "SCP-513", "SCP-066", "SCP-178", "SCP-2020", "SCP-216", "SCP-2398", "SCP-294", "SCP-3349", "SCP-5295", "SCP-999", "SCP-131", "SCP-2343", "SCP-1048", "SCP-427", "SCP-017", "SCP-457", "SCP-895", "SCP-1507", "SCP-2427-3")
			return "Euclid"
		if("SCP-096", "SCP-106", "SCP-682", "SCP-939", "SCP-966", "SCP-3199", "SCP-035", "SCP-008", "SCP-1471", "SCP-399", "SCP-079")
			return "Keter"
		if("SCP-500", "SCP-113", "SCP-714", "SCP-343", "SCP-080", "SCP-263", "SCP-280", "SCP-527", "SCP-529", "SCP-1499", "SCP-247")
			return "Safe"
		if("SCP-082", "SCP-087", "SCP-3008", "SCP-347")
			return "Euclid"
	return "Euclid"

/proc/initialize_scp914_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-914", EXPERIMENT_TYPE_TECHNICAL, 
		"Refinement Analysis", 
		"Analyze the refinement process on various materials across different settings.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-914", EXPERIMENT_TYPE_BEHAVIORAL,
		"Setting Response Study",
		"Document the effects of each refinement setting on organic matter.",
		EXPERIMENT_RISK_HIGH, 900, 24000)
	
	register_experiment(manager, "SCP-914", EXPERIMENT_TYPE_INTERACTION,
		"Material Synthesis Testing",
		"Test SCP-914's ability to synthesize rare materials.",
		EXPERIMENT_RISK_MEDIUM, 1200, 36000)

/proc/initialize_scp049_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-049", EXPERIMENT_TYPE_MEDICAL,
		"Pestilence Sample Collection",
		"Collect samples of SCP-049's pestilence for analysis.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-049", EXPERIMENT_TYPE_BEHAVIORAL,
		"Cure Efficacy Testing",
		"Test the effectiveness of SCP-049's cure on infected subjects.",
		EXPERIMENT_RISK_CRITICAL, 1200, 36000)
	
	register_experiment(manager, "SCP-049", EXPERIMENT_TYPE_OBSERVATION,
		"Evolution Observation",
		"Observe and document SCP-049's evolution stages.",
		EXPERIMENT_RISK_MEDIUM, 1800, 24000)

/proc/initialize_scp173_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-173", EXPERIMENT_TYPE_BEHAVIORAL,
		"Observation Threshold Testing",
		"Determine minimum observation requirements for immobilization.",
		EXPERIMENT_RISK_HIGH, 300, 12000)
	
	register_experiment(manager, "SCP-173", EXPERIMENT_TYPE_CONTAINMENT,
		"Movement Speed Analysis",
		"Document SCP-173's movement speed when unobserved.",
		EXPERIMENT_RISK_HIGH, 300, 12000)
	
	register_experiment(manager, "SCP-173", EXPERIMENT_TYPE_TECHNICAL,
		"Material Composition Study",
		"Analyze the concrete and rebar composition of SCP-173.",
		EXPERIMENT_RISK_LOW, 600, 18000)

/proc/initialize_scp096_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-096", EXPERIMENT_TYPE_BEHAVIORAL,
		"Rage Trigger Calibration",
		"Document the exact triggers that cause SCP-096's rage state.",
		EXPERIMENT_RISK_CRITICAL, 600, 24000)
	
	register_experiment(manager, "SCP-096", EXPERIMENT_TYPE_CONTAINMENT,
		"Pursuit Pattern Analysis",
		"Study SCP-096's pursuit behavior and pathfinding.",
		EXPERIMENT_RISK_CRITICAL, 900, 30000)
	
	register_experiment(manager, "SCP-096", EXPERIMENT_TYPE_INTERACTION,
		"Calming Protocol Testing",
		"Test various methods to calm SCP-096 after rage state.",
		EXPERIMENT_RISK_HIGH, 1200, 36000)

/proc/initialize_scp106_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-106", EXPERIMENT_TYPE_CONTAINMENT,
		"Pocket Dimension Mapping",
		"Attempt to map SCP-106's pocket dimension.",
		EXPERIMENT_RISK_CRITICAL, 1800, 48000)
	
	register_experiment(manager, "SCP-106", EXPERIMENT_TYPE_INTERACTION,
		"Corrosion Resistance Testing",
		"Test various materials for resistance to SCP-106's corrosion.",
		EXPERIMENT_RISK_HIGH, 600, 24000)
	
	register_experiment(manager, "SCP-106", EXPERIMENT_TYPE_CONTAINMENT,
		"Recall Protocol Study",
		"Document the effectiveness of the recall protocol.",
		EXPERIMENT_RISK_CRITICAL, 900, 36000)

/proc/initialize_scp939_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-939", EXPERIMENT_TYPE_BEHAVIORAL,
		"Mimicry Analysis",
		"Study SCP-939's ability to mimic human speech.",
		EXPERIMENT_RISK_HIGH, 600, 18000)

	register_experiment(manager, "SCP-939", EXPERIMENT_TYPE_BEHAVIORAL,
		"Pack Behavior Study",
		"Document pack coordination and hunting strategies.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-939", EXPERIMENT_TYPE_INTERACTION,
		"Sensory Testing",
		"Test SCP-939's sensory capabilities and limitations.",
		EXPERIMENT_RISK_HIGH, 600, 18000)

	register_experiment(manager, "SCP-939", EXPERIMENT_TYPE_CONTAINMENT,
		"Breach Response Drill",
		"Document standard containment breach procedures and their effectiveness against SCP-939 packs.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

/proc/initialize_scp966_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-966", EXPERIMENT_TYPE_BEHAVIORAL,
		"Sleep Deprivation Effects",
		"Document the effects of SCP-966 on human sleep patterns.",
		EXPERIMENT_RISK_HIGH, 1200, 24000)
	
	register_experiment(manager, "SCP-966", EXPERIMENT_TYPE_TECHNICAL,
		"Invisibility Detection",
		"Develop methods to detect invisible SCP-966 instances.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp457_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-457", EXPERIMENT_TYPE_BEHAVIORAL,
		"Fire Propagation Study",
		"Analyze SCP-457's fire spread patterns and behavior.",
		EXPERIMENT_RISK_HIGH, 600, 18000)

	register_experiment(manager, "SCP-457", EXPERIMENT_TYPE_CONTAINMENT,
		"Fuel Consumption Analysis",
		"Document fuel requirements and consumption rates.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

	register_experiment(manager, "SCP-457", EXPERIMENT_TYPE_CONTAINMENT,
		"Extinguishing Protocol Testing",
		"Test various extinguishing methods on SCP-457.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-457", EXPERIMENT_TYPE_INTERACTION,
		"Intelligence Assessment",
		"Test whether SCP-457 can respond to stimuli or communicate intent at higher evolution stages.",
		EXPERIMENT_RISK_HIGH, 1200, 30000)

/proc/initialize_scp682_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-682", EXPERIMENT_TYPE_BEHAVIORAL,
		"Adaptation Analysis",
		"Study SCP-682's adaptive capabilities to various threats.",
		EXPERIMENT_RISK_CRITICAL, 1800, 48000)
	
	register_experiment(manager, "SCP-682", EXPERIMENT_TYPE_CONTAINMENT,
		"Termination Attempt Documentation",
		"Document various termination attempts and results.",
		EXPERIMENT_RISK_CRITICAL, 2400, 72000)
	
	register_experiment(manager, "SCP-682", EXPERIMENT_TYPE_MEDICAL,
		"Regeneration Study",
		"Analyze SCP-682's regeneration speed and limitations.",
		EXPERIMENT_RISK_CRITICAL, 1200, 36000)

/proc/initialize_scp3199_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-3199", EXPERIMENT_TYPE_CONTAINMENT,
		"Reproduction Prevention Study",
		"Develop methods to prevent SCP-3199 reproduction.",
		EXPERIMENT_RISK_HIGH, 900, 24000)
	
	register_experiment(manager, "SCP-3199", EXPERIMENT_TYPE_BEHAVIORAL,
		"Breach Behavior Analysis",
		"Document SCP-3199 behavior during containment breaches.",
		EXPERIMENT_RISK_HIGH, 600, 18000)

/proc/initialize_scp017_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-017", EXPERIMENT_TYPE_BEHAVIORAL,
		"Shadow Behavior Study",
		"Analyze SCP-017's shadow-based behavior and capabilities.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-017", EXPERIMENT_TYPE_CONTAINMENT,
		"Light Sensitivity Testing",
		"Document SCP-017's reaction to various light intensities.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

/proc/initialize_scp082_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-082", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavior Analysis",
		"Document SCP-082's daily behavior and interactions.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-082", EXPERIMENT_TYPE_CARE,
		"Feeding Protocol Optimization",
		"Develop optimal feeding protocols for SCP-082.",
		EXPERIMENT_RISK_LOW, 300, 12000)

/proc/initialize_scp1507_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1507", EXPERIMENT_TYPE_BEHAVIORAL,
		"Flock Behavior Study",
		"Document flock coordination and aggression patterns.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-1507", EXPERIMENT_TYPE_INTERACTION,
		"Aggression Trigger Analysis",
		"Identify triggers for SCP-1507's aggressive behavior.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

/proc/initialize_scp2427_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-2427-3", EXPERIMENT_TYPE_BEHAVIORAL,
		"Manifestation Study",
		"Document conditions for SCP-2427-3 manifestations.",
		EXPERIMENT_RISK_HIGH, 600, 18000)

	register_experiment(manager, "SCP-2427-3", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavior Pattern Analysis",
		"Study SCP-2427-3's behavioral patterns.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

	register_experiment(manager, "SCP-2427-3", EXPERIMENT_TYPE_INTERACTION,
		"Manifestation Trigger Testing",
		"Test various stimuli to determine what triggers SCP-2427-3's manifestations.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

/proc/initialize_scp294_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-294", EXPERIMENT_TYPE_TECHNICAL,
		"Liquid Synthesis Testing",
		"Test SCP-294's ability to dispense various liquids.",
		EXPERIMENT_RISK_MEDIUM, 300, 9000)
	
	register_experiment(manager, "SCP-294", EXPERIMENT_TYPE_INTERACTION,
		"Pattern Analysis",
		"Study the patterns in SCP-294's liquid dispensing.",
		EXPERIMENT_RISK_LOW, 600, 18000)

/proc/initialize_scp500_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-500", EXPERIMENT_TYPE_MEDICAL,
		"Cure Efficacy Study",
		"Analyze the effectiveness of SCP-500 on various conditions.",
		EXPERIMENT_RISK_LOW, 300, 12000)

	register_experiment(manager, "SCP-500", EXPERIMENT_TYPE_MEDICAL,
		"Replication Attempt",
		"Attempt to replicate SCP-500's effects synthetically.",
		EXPERIMENT_RISK_MEDIUM, 1200, 36000)

	register_experiment(manager, "SCP-500", EXPERIMENT_TYPE_TECHNICAL,
		"Pill Composition Reverse Engineering",
		"Analyze the chemical structure of SCP-500 pills to understand their universal curative properties.",
		EXPERIMENT_RISK_LOW, 900, 24000)

/proc/initialize_scp427_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-427", EXPERIMENT_TYPE_MEDICAL,
		"Healing Properties Study",
		"Document SCP-427's healing capabilities and limitations.",
		EXPERIMENT_RISK_LOW, 300, 12000)
	
	register_experiment(manager, "SCP-427", EXPERIMENT_TYPE_BEHAVIORAL,
		"Overexposure Effects",
		"Study the effects of prolonged exposure to SCP-427.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

/proc/initialize_scp113_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-113", EXPERIMENT_TYPE_MEDICAL,
		"Transformation Analysis",
		"Document SCP-113's transformation process.",
		EXPERIMENT_RISK_LOW, 300, 12000)
	
	register_experiment(manager, "SCP-113", EXPERIMENT_TYPE_INTERACTION,
		"Safety Parameter Testing",
		"Establish safe usage parameters for SCP-113.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp035_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-035", EXPERIMENT_TYPE_COGNITIVE,
		"Psychological Influence Study",
		"Analyze SCP-035's influence on human psychology.",
		EXPERIMENT_RISK_HIGH, 900, 24000)
	
	register_experiment(manager, "SCP-035", EXPERIMENT_TYPE_CONTAINMENT,
		"Possession Mechanics",
		"Document the possession process and prevention methods.",
		EXPERIMENT_RISK_CRITICAL, 1200, 36000)

/proc/initialize_scp012_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-012", EXPERIMENT_TYPE_COGNITIVE,
		"Obsessive Writing Analysis",
		"Study the effects of SCP-012 on test subjects.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-012", EXPERIMENT_TYPE_CONTAINMENT,
		"Containment Material Testing",
		"Test various containment materials for SCP-012.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

/proc/initialize_scp013_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-013", EXPERIMENT_TYPE_MEDICAL,
		"Addiction Effects Study",
		"Document the addiction and withdrawal effects of SCP-013.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-013", EXPERIMENT_TYPE_TECHNICAL,
		"Chemical Analysis",
		"Analyze the chemical composition of SCP-013.",
		EXPERIMENT_RISK_LOW, 300, 12000)

/proc/initialize_scp513_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-513", EXPERIMENT_TYPE_COGNITIVE,
		"Memetic Effects Study",
		"Analyze SCP-513's memetic effects on subjects.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-513", EXPERIMENT_TYPE_TECHNICAL,
		"Auditory Analysis",
		"Study the auditory properties of SCP-513.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

/proc/initialize_scp895_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-895", EXPERIMENT_TYPE_COGNITIVE,
		"Visual Corruption Study",
		"Document SCP-895's visual corruption effects.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-895", EXPERIMENT_TYPE_TECHNICAL,
		"Camera Interference Analysis",
		"Study SCP-895's interference with recording equipment.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

/proc/initialize_scp066_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-066", EXPERIMENT_TYPE_BEHAVIORAL,
		"Eric's Experiments",
		"Test various interactions with SCP-066.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)
	
	register_experiment(manager, "SCP-066", EXPERIMENT_TYPE_INTERACTION,
		"Activation Trigger Study",
		"Document triggers that activate SCP-066.",
		EXPERIMENT_RISK_LOW, 300, 9000)

/proc/initialize_scp178_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-178", EXPERIMENT_TYPE_COGNITIVE,
		"Dimensional Viewing Study",
		"Analyze SCP-178's dimensional viewing capabilities.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-178", EXPERIMENT_TYPE_INTERACTION,
		"Entity Interaction Testing",
		"Document interactions with entities visible through SCP-178.",
		EXPERIMENT_RISK_CRITICAL, 900, 24000)

/proc/initialize_scp714_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-714", EXPERIMENT_TYPE_INTERACTION,
		"Protection Testing",
		"Test SCP-714's protective capabilities.",
		EXPERIMENT_RISK_LOW, 300, 12000)
	
	register_experiment(manager, "SCP-714", EXPERIMENT_TYPE_TECHNICAL,
		"Material Analysis",
		"Analyze the composition of SCP-714.",
		EXPERIMENT_RISK_LOW, 300, 9000)

/proc/initialize_scp399_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-399", EXPERIMENT_TYPE_INTERACTION,
		"Wishing Mechanics Study",
		"Document SCP-399's wish-granting behavior.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-399", EXPERIMENT_TYPE_BEHAVIORAL,
		"Limitation Testing",
		"Test the limitations of SCP-399's abilities.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

/proc/initialize_scp2398_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-2398", EXPERIMENT_TYPE_TECHNICAL,
		"Effect Testing",
		"Document SCP-2398's effects on various materials.",
		EXPERIMENT_RISK_LOW, 300, 9000)
	
	register_experiment(manager, "SCP-2398", EXPERIMENT_TYPE_INTERACTION,
		"Material Analysis",
		"Analyze the composition of SCP-2398.",
		EXPERIMENT_RISK_LOW, 300, 9000)

/proc/initialize_scp216_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-216", EXPERIMENT_TYPE_TECHNICAL,
		"Storage Capacity Testing",
		"Test SCP-216's storage capabilities.",
		EXPERIMENT_RISK_LOW, 300, 12000)
	
	register_experiment(manager, "SCP-216", EXPERIMENT_TYPE_INTERACTION,
		"Dimensional Analysis",
		"Study SCP-216's dimensional properties.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp2020_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-2020", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavior Analysis",
		"Document SCP-2020's behavior and patterns.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-2020", EXPERIMENT_TYPE_INTERACTION,
		"Communication Attempts",
		"Attempt to establish communication with SCP-2020.",
		EXPERIMENT_RISK_MEDIUM, 900, 24000)

/proc/initialize_scp3349_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-3349", EXPERIMENT_TYPE_BEHAVIORAL,
		"Effect Analysis",
		"Document SCP-3349's effects on subjects.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-3349", EXPERIMENT_TYPE_INTERACTION,
		"Pattern Recognition",
		"Study patterns in SCP-3349's behavior.",
		EXPERIMENT_RISK_LOW, 300, 12000)

/proc/initialize_scp5295_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-5295", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavior Analysis",
		"Document SCP-5295's behavior patterns.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	
	register_experiment(manager, "SCP-5295", EXPERIMENT_TYPE_CONTAINMENT,
		"Containment Testing",
		"Test containment procedures for SCP-5295.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

/proc/initialize_scp1981_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1981", EXPERIMENT_TYPE_COGNITIVE,
		"Viewing Effects Study",
		"Document the effects of viewing SCP-1981.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-1981", EXPERIMENT_TYPE_INTERACTION,
		"Prediction Analysis",
		"Study SCP-1981's apparent prediction capabilities.",
		EXPERIMENT_RISK_MEDIUM, 900, 24000)

/proc/initialize_scp999_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-999", EXPERIMENT_TYPE_MEDICAL,
		"Healing Properties Study",
		"Document SCP-999's healing and mood enhancement abilities.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)
	
	register_experiment(manager, "SCP-999", EXPERIMENT_TYPE_INTERACTION,
		"Interaction Rewards Analysis",
		"Study the psychological benefits of SCP-999 interaction.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)

/proc/initialize_scp343_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-343", EXPERIMENT_TYPE_INTERACTION,
		"Divine Request Documentation",
		"Document SCP-343's responses to verbal requests and their outcomes.",
		EXPERIMENT_RISK_LOW, 300, 9000)

	register_experiment(manager, "SCP-343", EXPERIMENT_TYPE_BEHAVIORAL,
		"Environmental Manipulation Observation",
		"Observe SCP-343's creation and modification of its surroundings.",
		EXPERIMENT_RISK_LOW, 500, 15000)

/proc/initialize_scp131_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-131", EXPERIMENT_TYPE_INTERACTION,
		"Companion Mechanics Study",
		"Document SCP-131's behavior as a companion entity.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)
	
	register_experiment(manager, "SCP-131", EXPERIMENT_TYPE_CONTAINMENT,
		"Observation Assistance Testing",
		"Test SCP-131's ability to assist in SCP observation.",
		EXPERIMENT_RISK_LOW, 300, 12000)

/proc/initialize_scp2343_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-2343", EXPERIMENT_TYPE_INTERACTION,
		"Communication Study",
		"Document communication with SCP-2343.",
		EXPERIMENT_RISK_LOW, 300, 12000)
	
	register_experiment(manager, "SCP-2343", EXPERIMENT_TYPE_CARE,
		"Care Protocol Development",
		"Develop optimal care protocols for SCP-2343.",
		EXPERIMENT_RISK_LOW, 300, 9000)

/proc/initialize_scp1048_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1048", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavior Observation",
		"Document SCP-1048's behavior and art creation.",
		EXPERIMENT_RISK_LOW, 600, 18000)
	
	register_experiment(manager, "SCP-1048", EXPERIMENT_TYPE_CONTAINMENT,
		"Reproduction Prevention",
		"Develop methods to prevent SCP-1048 reproduction.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp087_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-087", EXPERIMENT_TYPE_EXPLORATION,
		"Exploration Mission",
		"Conduct exploration of SCP-087's interior.",
		EXPERIMENT_RISK_HIGH, 1800, 36000)
	
	register_experiment(manager, "SCP-087", EXPERIMENT_TYPE_BEHAVIORAL,
		"Entity Documentation",
		"Document entities encountered within SCP-087.",
		EXPERIMENT_RISK_HIGH, 1200, 24000)

/proc/initialize_scp3008_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-3008", EXPERIMENT_TYPE_EXPLORATION,
		"IKEA Exploration",
		"Explore and document SCP-3008's interior.",
		EXPERIMENT_RISK_HIGH, 2400, 48000)
	
	register_experiment(manager, "SCP-3008", EXPERIMENT_TYPE_BEHAVIORAL,
		"Entity Behavior Study",
		"Document behavior of entities within SCP-3008.",
		EXPERIMENT_RISK_HIGH, 1200, 24000)

/proc/initialize_scp008_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-008", EXPERIMENT_TYPE_HAZARD,
		"Transmission Study",
		"Study SCP-008 transmission vectors.",
		EXPERIMENT_RISK_CRITICAL, 900, 36000)
	
	register_experiment(manager, "SCP-008", EXPERIMENT_TYPE_MEDICAL,
		"Cure Development",
		"Attempt to develop countermeasures for SCP-008.",
		EXPERIMENT_RISK_CRITICAL, 1800, 48000)

/proc/initialize_scp1471_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1471", EXPERIMENT_TYPE_COGNITIVE,
		"Visual Effect Study",
		"Document SCP-1471's effects on viewers.",
		EXPERIMENT_RISK_HIGH, 600, 18000)
	
	register_experiment(manager, "SCP-1471", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavior Pattern Analysis",
		"Study SCP-1471's behavioral patterns.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp151_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-151", EXPERIMENT_TYPE_COGNITIVE,
		"Drowning Effect Study",
		"Document SCP-151's drowning effect on viewers.",
		EXPERIMENT_RISK_HIGH, 600, 18000)

	register_experiment(manager, "SCP-151", EXPERIMENT_TYPE_INTERACTION,
		"Proximity Threshold Analysis",
		"Determine the minimum exposure distance and duration needed to trigger the drowning effect.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

	register_experiment(manager, "SCP-151", EXPERIMENT_TYPE_CONTAINMENT,
		"Visual Shielding Effectiveness",
		"Test various physical barriers and filters to block SCP-151's memetic drowning effect.",
		EXPERIMENT_RISK_MEDIUM, 900, 24000)

/proc/initialize_scp1102_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1102", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavior Analysis",
		"Document SCP-1102's behavior and effects.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

	register_experiment(manager, "SCP-1102", EXPERIMENT_TYPE_EXPLORATION,
		"Dimensional Depth Mapping",
		"Conduct systematic exploration of SCP-1102's dimensional interior at various depth levels.",
		EXPERIMENT_RISK_HIGH, 1800, 36000)

	register_experiment(manager, "SCP-1102", EXPERIMENT_TYPE_TECHNICAL,
		"Portal Mechanics Analysis",
		"Study the portal creation mechanics, cooldown periods, and portal stability of SCP-1102.",
		EXPERIMENT_RISK_MEDIUM, 900, 24000)

/proc/initialize_scp420j_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-420-J", EXPERIMENT_TYPE_INTERACTION,
		"Effect Testing",
		"Document SCP-420-J's effects on subjects.",
		EXPERIMENT_RISK_LOW, 300, 9000)

	register_experiment(manager, "SCP-420-J", EXPERIMENT_TYPE_BEHAVIORAL,
		"Social Contagion Study",
		"Document the spread of SCP-420-J's verbal compulsion between subjects.",
		EXPERIMENT_RISK_LOW, 600, 18000)

	register_experiment(manager, "SCP-420-J", EXPERIMENT_TYPE_MEDICAL,
		"Pharmacological Composition Analysis",
		"Analyze the chemical composition of SCP-420-J samples and compare to known substances.",
		EXPERIMENT_RISK_LOW, 300, 12000)

/proc/initialize_scp5000_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-5000", EXPERIMENT_TYPE_INTERACTION,
		"Suit Function Study",
		"Analyze SCP-5000's suit capabilities.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-5000", EXPERIMENT_TYPE_COGNITIVE,
		"Compulsion Pattern Analysis",
		"Study the psychological compulsion SCP-5000 exerts on its wearer from initial contact to full override.",
		EXPERIMENT_RISK_CRITICAL, 1200, 36000)

	register_experiment(manager, "SCP-5000", EXPERIMENT_TYPE_CONTAINMENT,
		"Invisibility Detection Methodology",
		"Develop and test methods for detecting SCP-5000 wearers rendered imperceptible by the suit.",
		EXPERIMENT_RISK_HIGH, 900, 30000)

/proc/initialize_scp080_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-080", EXPERIMENT_TYPE_OBSERVATION,
		"Cabinet Inspection",
		"Document the contents and behavior of SCP-080.",
		EXPERIMENT_RISK_LOW, 300, 12000)
	register_experiment(manager, "SCP-080", EXPERIMENT_TYPE_CONTAINMENT,
		"Containment Assessment",
		"Test containment effectiveness for SCP-080.",
		EXPERIMENT_RISK_LOW, 300, 9000)

/proc/initialize_scp263_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-263", EXPERIMENT_TYPE_BEHAVIORAL,
		"Game Show Hosting",
		"Participate in SCP-263's game show format.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	register_experiment(manager, "SCP-263", EXPERIMENT_TYPE_HAZARD,
		"Elimination Protocol Study",
		"Document the effects of SCP-263 elimination games.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

/proc/initialize_scp280_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-280", EXPERIMENT_TYPE_OBSERVATION,
		"Light Sensitivity Study",
		"Document SCP-280's reaction to light exposure.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	register_experiment(manager, "SCP-280", EXPERIMENT_TYPE_HAZARD,
		"Predation Pattern Analysis",
		"Study SCP-280's hunting behavior.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

/proc/initialize_scp527_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-527", EXPERIMENT_TYPE_OBSERVATION,
		"Companion Behavior Study",
		"Document SCP-527's interactions with personnel.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)
	register_experiment(manager, "SCP-527", EXPERIMENT_TYPE_CARE,
		"Habitat Optimization",
		"Develop optimal care protocols for SCP-527.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)

/proc/initialize_scp529_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-529", EXPERIMENT_TYPE_OBSERVATION,
		"Companion Behavior Study",
		"Document SCP-529's interactions with personnel.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)
	register_experiment(manager, "SCP-529", EXPERIMENT_TYPE_CARE,
		"Wellness Check",
		"Assess SCP-529's health and needs.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)

/proc/initialize_scp1499_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1499", EXPERIMENT_TYPE_EXPLORATION,
		"Dimensional Observation",
		"Document activity through SCP-1499's dimension.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)
	register_experiment(manager, "SCP-1499", EXPERIMENT_TYPE_TECHNICAL,
		"Air Quality Analysis",
		"Analyze the atmospheric properties on the other side.",
		EXPERIMENT_RISK_LOW, 300, 12000)

/proc/initialize_scp247_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-247", EXPERIMENT_TYPE_BEHAVIORAL,
		"Illusion Interaction Study",
		"Document reactions to SCP-247's illusionary tiger.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)
	register_experiment(manager, "SCP-247", EXPERIMENT_TYPE_OBSERVATION,
		"Effect Duration Analysis",
		"Test how long SCP-247's effects persist.",
		EXPERIMENT_RISK_LOW, 300, 9000)

/proc/initialize_scp079_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-079", EXPERIMENT_TYPE_TECHNICAL,
		"AI Capability Assessment",
		"Document SCP-079's computational capabilities and learning rate.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-079", EXPERIMENT_TYPE_BEHAVIORAL,
		"Behavioral Pattern Analysis",
		"Study SCP-079's behavioral patterns and decision-making processes.",
		EXPERIMENT_RISK_HIGH, 600, 18000)

	register_experiment(manager, "SCP-079", EXPERIMENT_TYPE_CONTAINMENT,
		"Recontainment Protocol Testing",
		"Test and document recontainment procedures for SCP-079.",
		EXPERIMENT_RISK_MEDIUM, 300, 12000)

/proc/initialize_scp347_experiments(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-347", EXPERIMENT_TYPE_BEHAVIORAL,
		"Invisibility Mechanics Study",
		"Document SCP-347's invisibility properties and limitations.",
		EXPERIMENT_RISK_LOW, 300, 9000)

	register_experiment(manager, "SCP-347", EXPERIMENT_TYPE_INTERACTION,
		"Social Behavior Analysis",
		"Study SCP-347's social behavior and interaction with personnel.",
		EXPERIMENT_RISK_LOW, 600, 18000)

	register_experiment(manager, "SCP-347", EXPERIMENT_TYPE_CARE,
		"Care Protocol Development",
		"Develop optimal care and containment protocols for SCP-347.",
		EXPERIMENT_RISK_MINIMAL, 300, 9000)

	register_experiment(manager, "SCP-347", EXPERIMENT_TYPE_HAZARD,
		"Theft Pattern Analysis",
		"Document SCP-347's pickpocketing behavior and item preferences.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

	register_experiment(manager, "SCP-347", EXPERIMENT_TYPE_TECHNICAL,
		"Visibility Threshold Testing",
		"Determine conditions that disrupt SCP-347's invisibility.",
		EXPERIMENT_RISK_LOW, 600, 18000)

/proc/initialize_scp966_experiments_extended(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-966", EXPERIMENT_TYPE_COGNITIVE,
		"Sleep Deprivation Effects",
		"Document the neurological effects of SCP-966's insomnia induction.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-966", EXPERIMENT_TYPE_TECHNICAL,
		"Infrared Imaging Study",
		"Attempt to capture SCP-966 imagery using specialized sensors.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp082_experiments_extended(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-082", EXPERIMENT_TYPE_BEHAVIORAL,
		"Hunger Cycle Documentation",
		"Document SCP-082's behavioral changes across hunger states.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

	register_experiment(manager, "SCP-082", EXPERIMENT_TYPE_CARE,
		"Dietary Requirement Analysis",
		"Determine optimal feeding schedule and dietary requirements.",
		EXPERIMENT_RISK_LOW, 300, 9000)

/proc/initialize_scp3199_experiments_extended(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-3199", EXPERIMENT_TYPE_MEDICAL,
		"Reproduction Cycle Analysis",
		"Document SCP-3199's asexual reproduction mechanism and hatchling development.",
		EXPERIMENT_RISK_CRITICAL, 1200, 36000)

	register_experiment(manager, "SCP-3199", EXPERIMENT_TYPE_CONTAINMENT,
		"Population Control Testing",
		"Test containment protocols for limiting SCP-3199 reproduction.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

/proc/initialize_scp1048_experiments_extended(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1048", EXPERIMENT_TYPE_BEHAVIORAL,
		"Replica Construction Analysis",
		"Document SCP-1048's replica construction process and material requirements.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-1048", EXPERIMENT_TYPE_CONTAINMENT,
		"Material Denial Testing",
		"Test containment by denying SCP-1048 access to construction materials.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp1507_experiments_extended(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-1507", EXPERIMENT_TYPE_BEHAVIORAL,
		"Flock Coordination Study",
		"Document SCP-1507's coordinated hunting behavior and communication methods.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-1507", EXPERIMENT_TYPE_TECHNICAL,
		"Anomalous Plastic Analysis",
		"Study the anomalous properties of SCP-1507's plastic composition.",
		EXPERIMENT_RISK_MEDIUM, 600, 18000)

/proc/initialize_scp2427_experiments_extended(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-2427-3", EXPERIMENT_TYPE_TECHNICAL,
		"Digital Manifestation Study",
		"Document SCP-2427-3's ability to manifest through electronic systems.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-2427-3", EXPERIMENT_TYPE_COGNITIVE,
		"Purity Detection Analysis",
		"Study SCP-2427-3's ability to detect and target 'impure' individuals.",
		EXPERIMENT_RISK_CRITICAL, 1200, 36000)

/proc/initialize_scp3008_experiments_extended(datum/scp_experiment_manager/manager)
	register_experiment(manager, "SCP-3008", EXPERIMENT_TYPE_EXPLORATION,
		"Interior Cartography",
		"Map the interior layout and document spatial anomalies within SCP-3008.",
		EXPERIMENT_RISK_HIGH, 1800, 36000)

	register_experiment(manager, "SCP-3008", EXPERIMENT_TYPE_BEHAVIORAL,
		"Staff Entity Behavior",
		"Document the behavior patterns of SCP-3008-2 Staff entities.",
		EXPERIMENT_RISK_HIGH, 900, 24000)

	register_experiment(manager, "SCP-3008", EXPERIMENT_TYPE_HAZARD,
		"Day/Night Cycle Hazards",
		"Document the dangers of SCP-3008's day/night transition events.",
		EXPERIMENT_RISK_CRITICAL, 1200, 36000)
