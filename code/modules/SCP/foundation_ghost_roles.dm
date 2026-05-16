/obj/effect/mob_spawn/ghost_role/foundation_mtf
	name = "MTF Operative"
	desc = "A Mobile Task Force spawn point."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "MTF Operative"
	you_are_text = "You are a Mobile Task Force operative of the SCP Foundation."
	flavour_text = "Secure. Contain. Protect. Respond to containment breaches and secure SCP objects. Follow your commander's orders."
	important_text = "Follow the chain of command. Do not harm Foundation personnel unless they are confirmed hostile."
	outfit = /datum/outfit/mtf/security
	spawner_job_path = /datum/job/mtf_operative

/obj/effect/mob_spawn/ghost_role/foundation_goc
	name = "GOC Operative"
	prompt_name = "GOC Operative"
	you_are_text = "You are a Global Occult Coalition operative."
	flavour_text = "You represent the UN's paranormal response agency. Assist or neutralize anomalies as directed. The Foundation is an ally, but your mission comes first."
	important_text = "Coordinate with Foundation personnel. Destroy hostile anomalies. Protect civilian witnesses."
	outfit = /datum/outfit/mtf/goc
	spawner_job_path = /datum/job/mtf_operative

/obj/effect/mob_spawn/ghost_role/foundation_goc/commander
	name = "GOC Commander"
	prompt_name = "GOC Commander"
	outfit = /datum/outfit/mtf/goc/commander

/obj/effect/mob_spawn/ghost_role/foundation_scientist
	name = "Visiting Researcher"
	prompt_name = "Visiting Researcher"
	you_are_text = "You are a visiting researcher from another Site."
	flavour_text = "You've been transferred to Site-53 to conduct research on specific SCP objects. Follow testing protocols and avoid unauthorized experiments."
	important_text = "You have Level 2 clearance. Submit testing requests before experimenting. Do not enter containment cells alone."
	outfit = /datum/outfit/mtf/security
	spawner_job_path = /datum/job/researcher

/obj/effect/mob_spawn/ghost_role/chaos_insurgency
	name = "Chaos Insurgency Operative"
	prompt_name = "CI Operative"
	you_are_text = "You are a Chaos Insurgency operative."
	flavour_text = "Infiltrate Site-53 and complete your mission. Steal SCP objects, extract D-Class, or sabotage Foundation operations."
	important_text = "You are hostile to the Foundation. Avoid detection as long as possible. Complete your objectives at any cost."
	outfit = /datum/outfit/ci_operative
	spawner_job_path = /datum/job/mtf_operative

/obj/effect/mob_spawn/ghost_role/scp_witness
	name = "Civilian Witness"
	prompt_name = "Civilian Witness"
	you_are_text = "You are a civilian who stumbled onto something you shouldn't have."
	flavour_text = "You don't know what's going on, but strange things are happening. Foundation personnel are everywhere. Try to survive and maybe learn the truth."
	important_text = "You are not Foundation personnel. You have no access, no radio, and no training. Good luck."
	outfit = /datum/outfit/mtf/security
	spawner_job_path = /datum/job/dclass_general

/obj/effect/mob_spawn/ghost_role/dclass_latejoin
	name = "Late D-Class Arrival"
	prompt_name = "D-Class Personnel"
	you_are_text = "You are a D-Class personnel recently transferred to Site-53."
	flavour_text = "Follow orders from Foundation staff. You are expendable. Do your assigned work and you might survive the day."
	important_text = "Follow instructions. Do not enter restricted areas without authorization. Report any anomalous events to security."
	outfit = /datum/outfit/mtf/security
	spawner_job_path = /datum/job/dclass_general
