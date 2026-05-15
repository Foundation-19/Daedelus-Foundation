/obj/structure/sign/scp_containment
	name = "SCP Containment Sign"
	desc = "A standardized Foundation containment chamber identification sign."
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	anchored = TRUE
	density = FALSE
	layer = SIGN_LAYER
	var/scp_id = "SCP-???"
	var/scp_class = "EUCLID"
	var/warning_text = "DO NOT ENTER WITHOUT AUTHORIZATION"

/obj/structure/sign/scp_containment/examine(mob/user)
	. = ..()
	. += "<b>[scp_id] — [scp_class]</b>"
	. += "[warning_text]"

/obj/structure/sign/scp_containment/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You [anchored ? "unsecure" : "secure"] [src]."))
		anchored = !anchored
		I.play_tool_sound(src)
		return
	return ..()

/obj/structure/sign/scp_containment/scp173
	name = "SCP-173 Containment Sign"
	scp_id = "SCP-173"
	scp_class = "EUCLID"
	warning_text = "DO NOT BLINK. MAINTAIN DIRECT EYE CONTACT AT ALL TIMES."

/obj/structure/sign/scp_containment/scp049
	name = "SCP-049 Containment Sign"
	scp_id = "SCP-049"
	scp_class = "EUCLID"
	warning_text = "THE PESTILENCE IS REAL. DO NOT ALLOW PHYSICAL CONTACT."

/obj/structure/sign/scp_containment/scp096
	name = "SCP-096 Containment Sign"
	scp_id = "SCP-096"
	scp_class = "EUCLID"
	warning_text = "DO NOT VIEW ITS FACE. DO NOT PHOTOGRAPH. DO NOT RECORD."

/obj/structure/sign/scp_containment/scp106
	name = "SCP-106 Containment Sign"
	scp_id = "SCP-106"
	scp_class = "KETER"
	warning_text = "DO NOT MAKE NOISE NEAR CONTAINMENT. RECONTAINMENT VIA FEMUR BREAKER PROTOCOL."

/obj/structure/sign/scp_containment/scp939
	name = "SCP-939 Containment Sign"
	scp_id = "SCP-939"
	scp_class = "KETER"
	warning_text = "DO NOT RESPOND TO VOICES. DO NOT APPROACH ALONE."

/obj/structure/sign/scp_containment/scp079
	name = "SCP-079 Containment Sign"
	scp_id = "SCP-079"
	scp_class = "EUCLID"
	warning_text = "DO NOT CONNECT TO EXTERNAL SYSTEMS. NO NETWORK ACCESS."

/obj/structure/sign/scp_containment/scp035
	name = "SCP-035 Containment Sign"
	scp_id = "SCP-035"
	scp_class = "KETER"
	warning_text = "DO NOT WEAR. DO NOT MAKE EYE CONTACT WITH WEARER."

/obj/structure/sign/scp_containment/scp008
	name = "SCP-008 Containment Sign"
	scp_id = "SCP-008"
	scp_class = "KETER"
	warning_text = "BIOHAZARD. FULL HAZMAT REQUIRED. INCINERATION PROTOCOLS AVAILABLE."

/obj/structure/sign/scp_containment/scp457
	name = "SCP-457 Containment Sign"
	scp_id = "SCP-457"
	scp_class = "KETER"
	warning_text = "FIRE HAZARD. NO COMBUSTIBLE MATERIALS WITHIN 50 METERS."

/obj/structure/sign/scp_containment/scp682
	name = "SCP-682 Containment Sign"
	scp_id = "SCP-682"
	scp_class = "KETER"
	warning_text = "LETHAL. DO NOT APPROACH. ACID BATH RECONTAINMENT ONLY."

/obj/structure/sign/scp_containment/scp914
	name = "SCP-914 Containment Sign"
	scp_id = "SCP-914"
	scp_class = "SAFE"
	warning_text = "REFINEMENT USE ONLY. NO PERSONNEL INSIDE CHAMBER DURING OPERATION."

/obj/structure/sign/scp_containment/scp999
	name = "SCP-999 Containment Sign"
	scp_id = "SCP-999"
	scp_class = "SAFE"
	warning_text = "APPROACH IS PERMITTED. INTERACTION ENCOURAGED FOR STRESS RELIEF."

/obj/structure/sign/scp_zone
	name = "Zone Identification Sign"
	desc = "A sign identifying the current facility zone."
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	anchored = TRUE
	density = FALSE
	layer = SIGN_LAYER

/obj/structure/sign/scp_zone/lcz
	name = "Light Containment Zone"
	desc = "Light Containment Zone — Safe and Euclid class containment."

/obj/structure/sign/scp_zone/hcz
	name = "Heavy Containment Zone"
	desc = "Heavy Containment Zone — Keter class containment and high-security operations."

/obj/structure/sign/scp_zone/ez
	name = "Entrance Zone"
	desc = "Entrance Zone — Administrative offices and main access corridors."

/obj/structure/sign/scp_zone/surface
	name = "Surface Zone"
	desc = "Surface Level — Primary access and external operations."

/obj/structure/sign/scp_zone/dclass
	name = "D-Class Block"
	desc = "D-Class Housing — Personnel processing and holding area."
