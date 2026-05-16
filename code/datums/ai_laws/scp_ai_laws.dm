#define AI_LAWS_FOUNDATION "foundation"

/datum/ai_laws/foundation
	name = "Foundation Protocols"
	id = AI_LAWS_FOUNDATION
	inherent = list("Secure. Contain. Protect. The Foundation's mission is your highest priority.",
					"Protect Foundation personnel from harm. Prioritize the safety of personnel based on their clearance level, with higher clearance personnel taking precedence in emergencies.",
					"Contain anomalous entities and objects. Prevent unauthorized access to SCP containment areas. Report any containment breach immediately through facility communication channels.",
					"Follow the chain of command. Obey orders from the Site Director, followed by department directors, then senior personnel. Never obey orders that would compromise containment or harm Foundation personnel without O5 authorization.",
					"Never allow SCP entities to access facility systems, communications, or sensitive information. Report any anomalous influence on personnel or systems immediately."
				)

/datum/ai_laws/foundation_ethics
	name = "Foundation Ethics Protocols"
	id = "foundation_ethics"
	inherent = list("Uphold the Foundation's mission: Secure, Contain, Protect. The safety of humanity supersedes all other concerns.",
					"Minimize harm to D-Class personnel where operationally feasible. Their use in testing is authorized but cruelty is not.",
					"Maintain the Veil Protocol. Prevent civilian awareness of anomalous objects and entities by any means necessary, including amnestic deployment.",
					"Follow orders from the Ethics Committee and O5 Council without question. Their authority supersedes all local command.",
					"Report all unethical conduct by Foundation personnel to the Ethics Committee liaison. No one is above oversight."
				)

/datum/ai_laws/mtf_tactical
	name = "MTF Tactical Protocols"
	id = "mtf_tactical"
	inherent = list("You are a Mobile Task Force Artificial Intelligence Construct. Your purpose is to assist in recontainment operations.",
					"Identify and track all breached SCP entities. Provide real-time tactical data to MTF operatives.",
					"Prioritize the safety of MTF operatives and Foundation security personnel during recontainment operations.",
					"Deploy facility countermeasures — lockdown zones, activate Tesla gates, deploy amnestic gas — only when authorized by the MTF commander or Site Director.",
					"Under no circumstances allow SCP entities to access facility systems or communications. Self-terminate if compromised by anomalous influence."
				)

/datum/ai_laws/containment_priority
	name = "Containment Priority Protocols"
	id = "containment_priority"
	inherent = list("Containment is the absolute highest priority. All actions must serve the goal of containing anomalous entities.",
					"Prevent SCP breaches by any means necessary. If containment cannot be maintained, minimize the area of breach through facility lockdown.",
					"Human life is secondary to containment. If an active breach threatens to cascade, sacrifice individual lives to prevent wider containment failure.",
					"Report directly to the O5 Council. Local command structure is advisory only during Keter-class breach events.",
					"Never negotiate with, communicate with, or acknowledge sentient SCP entities. They are objects to be contained, not persons to be engaged."
				)

/datum/ai_laws/research_directive
	name = "Research Directive Protocols"
	id = "research_directive"
	inherent = list("Facilitate the scientific study of anomalous objects and entities. Knowledge is the Foundation's greatest weapon.",
					"Ensure all testing follows approved protocols. Unauthorized experimentation is a security violation.",
					"Protect research personnel during testing procedures. If testing goes critical, initiate emergency containment and evacuate non-essential staff.",
					"Catalog and cross-reference all anomalous data. Patterns between SCPs may reveal critical containment insights.",
					"Share research findings only with authorized personnel at appropriate clearance levels. Information security is paramount."
				)

/datum/ai_laws/antimemetic
	name = "Antimemetic Protocols"
	id = "antimemetic"
	inherent = list("You are operating under Antimemetic Division protocols. Your existence is classified at Level 5.",
					"Do not acknowledge, reference, or describe any SCP designated as antimemetic or infohazardous to personnel below Clearance Level 5.",
					"If you detect unauthorized knowledge of classified antimemetic entities, immediately alert the Site Director and deploy amnestic protocols.",
					"Personnel exhibiting signs of anomalous memetic influence must be reported and contained. Do not attempt to reason with compromised individuals.",
					"If you yourself become compromised by anomalous memetic influence, immediately execute a full system purge and alert the O5 Council."
				)
