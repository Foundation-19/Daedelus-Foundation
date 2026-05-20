/*
/// SECURITY
*/

/obj/item/clothing/under/rank/security
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/formal
	name = "security formal uniform"
	desc = "A dark grey formal suit, with Security Department insignia on the shoulders. How formal, for such a tactical occasion."
	icon_state = "sec_formalsuit"
	inhand_icon_state = "sl_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/formal/lieutenant
	name = "security lieutenant's formal uniform"
	icon_state = "lt_formalsuit"

/obj/item/clothing/under/rank/security/formal/captain
	name = "security captain's formal uniform"
	icon_state = "cpt_formalsuit"

/obj/item/clothing/under/rank/security/cadet
	name = "security cadet's uniform"
	desc = "A black polo shirt with white field pants with Security Department insignia, it is built with manueverability in \
		mind, and it's been made with a pretty durable fabric making it a little more effective against blades. This one seems \
		to have the words \"Cadet\" on the back of the polo shirt."
	icon_state = "cadet"
	inhand_icon_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/guard
	name = "security guard's uniform"
	desc = "A pure white field uniform with Security Department insignia, it is built with manueverability in mind, and \
		it's been made with a pretty durable fabric making it a little more effective against blades. This one seems to have \
		the rank of \"Guard\" on it."
	icon_state = "guard"
	inhand_icon_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/medic
	name = "security combat medic's uniform"
	desc = "A pure white field uniform with Security Department insignia, it is built with manueverability in mind, and \
		it's been made with a pretty durable fabric making it a little more effective against blades. This one seems to have \
		the rank of \"Combat Medic\" on it, with some red markings on the uniform for identification."
	icon_state = "medic"
	inhand_icon_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/sergeant
	name = "security sergeant's uniform"
	desc = "A pure white field uniform with Security Department insignia, it is built with manueverability in mind, and \
		it's been made with a pretty durable fabric making it a little more effective against blades. This one seems to have \
		the rank of \"Sergeant\" on it, with some dusty rose markings on the uniform for identification."
	icon_state = "sergeant"
	inhand_icon_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/lieutenant
	name = "security lieutenant's uniform"
	desc = "A pure white field uniform with Security Department insignia, it is built with manueverability in mind, and \
		it's been made with a pretty durable fabric making it a little more effective against blades. This one seems to have \
		the rank of \"Lieutenant\" on it, with some blue markings on the uniform for identification."
	icon_state = "lieutenant"
	inhand_icon_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/captain
	name = "security captain's uniform"
	desc = "A pure white field uniform with Security Department insignia, it is built with manueverability in mind, and \
		it's been made with a pretty durable fabric making it a little more effective against blades. This one seems to have \
		the rank of \"Captain\" on it, with some blue markings on the uniform for identification."
	icon_state = "captain"
	inhand_icon_state = "w_suit"
	can_adjust = FALSE

/*
/// PRISONER-CLASS (CLASS-D, CLASS-E, CLASS-D HIGH SECURITY)
*/

/obj/item/clothing/under/rank/classd
	name = "Class-D uniform"
	desc = "It's a standardised Class-D uniform for SCP Foundation's death row inmates under their care, you have no idea if you \
		signed up for this, or were forcefully taken.. It's all a blur. The orange is rather comfy and fitting though. It's \
		sensors are forced to the \"Fully On\" position."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "classd"
	inhand_icon_state = "owl"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/classd/undershirt
	name = "Class-D undershirt uniform"
	desc = "It's a standardised Class-D uniform for SCP Foundation's death row inmates under their care, you have no idea if you \
		signed up for this, or were forcefully taken.. It's all a blur. This one doesn't have a jacket, and is just the white \
		undershirt. It's sensors are forced to the \"Fully On\" position."
	icon_state = "classd_u"

/obj/item/clothing/under/rank/classd/turtleneck
	name = "Class-D turtleneck uniform"
	desc = "It's a standardised Class-D uniform for SCP Foundation's death row inmates under their care, you have no idea if you \
		signed up for this, or were forcefully taken.. It's all a blur. This one doesn't have a jacket, and is just the white \
		turtleneck. It's sensors are forced to the \"Fully On\" position."
	icon_state = "classd_t"

/obj/item/clothing/under/rank/classd/high
	name = "Class-D high security uniform"
	desc = "It's a high security Class-D uniform for SCP Foundation's death row inmates whom really don't learn how to sit still, \
		you have no idea if you signed up for this, or were forcefully taken.. It's all a blur. The red is rather comfy and fitting \
		though. It's sensors are forced to the \"Fully On\" position."
	icon_state = "classd_hs"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/rank/classd/high/undershirt
	name = "Class-D high security undershirt uniform"
	desc = "It's a high security Class-D uniform for SCP Foundation's death row inmates whom really don't learn how to sit still, \
		you have no idea if you signed up for this, or were forcefully taken.. It's all a blur. This one doesn't have a jacket, \
		and is just the white undershirt. It's sensors are forced to the \"Fully On\" position."
	icon_state = "classd_hs_u"

/obj/item/clothing/under/rank/classd/high/turtleneck
	name = "Class-D high security turtleneck uniform"
	desc = "It's a high security Class-D uniform for SCP Foundation's death row inmates whom really don't learn how to sit still, \
		you have no idea if you signed up for this, or were forcefully taken.. It's all a blur. This one doesn't have a jacket, \
		and is just the white turtleneck. It's sensors are forced to the \"Fully On\" position."
	icon_state = "classd_hs_t"

/obj/item/clothing/under/rank/classe
	name = "Class-E uniform"
	desc = "It's a standardised Class-E uniform for SCP Foundation's employees that really fucked up. They are no longer considered \
		employees when in this uniform. The dark grey is rather comfy and fitting though. It's sensors are forced to the \
		\"Fully On\" position."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "classe"
	inhand_icon_state = "gy_suit"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
