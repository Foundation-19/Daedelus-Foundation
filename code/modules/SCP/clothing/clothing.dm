// SCP Foundation Clothing - Complete for Daedalus Dock compatibility

// Base SCP clothing class
/obj/item/clothing/under/scp
	icon = 'icons/obj/clothing/under/suits.dmi'
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

// Donor uniforms
/obj/item/clothing/under/scp/donor
	name = "grey uniform"
	desc = "A grey uniform."
	icon_state = "donor_sec"
	worn_icon_state = "donor_sec"

/obj/item/clothing/under/scp/donor2
	name = "blue uniform"
	desc = "A blue engineer's uniform."
	icon_state = "donor_eng"
	worn_icon_state = "donor_eng"

/obj/item/clothing/under/scp/donor3
	name = "green uniform"
	desc = "A green uniform."
	icon_state = "donate_sec"
	worn_icon_state = "donate_sec"

/obj/item/clothing/under/scp/greyuniform
	name = "grey uniform"
	desc = "A dull grey uniform."
	icon_state = "grey"
	worn_icon_state = "grey"

/obj/item/clothing/under/scp/suittie
	name = "suit and tie"
	desc = "A rather sterile looking suit and tie."
	icon_state = "charcoal_suit"
	worn_icon_state = "suit"

// D-Class uniforms
/obj/item/clothing/under/scp/dclass
	name = "D-Class uniform"
	desc = "A bright orange jumpsuit, indicative of Class D personnel."
	icon_state = "d"
	worn_icon_state = "d"

/obj/item/clothing/under/scp/dclass/short
	name = "Short Sleeved D-Class uniform"
	desc = "A bright orange jumpsuit, indicative of Class D personnel. This one has short sleeves."
	icon_state = "dr"
	worn_icon_state = "dr"

/obj/item/clothing/under/scp/dclass/undershirt
	name = "Undershirt D-Class uniform"
	desc = "A bright orange jumpsuit, indicative of Class D personnel. This one is missing the upper button-up shirt, showing a white short sleeved shirt."
	icon_state = "ds"
	worn_icon_state = "ds"

/obj/item/clothing/under/scp/dclass/turtleneck
	name = "Turtleneck D-Class uniform"
	desc = "A bright orange jumpsuit, indicative of Class D personnel. This one has a quite well-kempt turtleneck above the uniform."
	icon_state = "dt"
	worn_icon_state = "dt"

/obj/item/clothing/under/scp/dclass/janitor
	name = "Janitorial D-Class uniform"
	desc = "A bright orange jumpsuit, indicative of Class D personnel. This one only has the orange colors on the sleeves, indicating it's a janitor, but still D-Class scum."
	icon_state = "dj"
	worn_icon_state = "dj"

/obj/item/clothing/under/scp/eclass
	name = "Solitary D-Class uniform"
	desc = "A dark grey jumpsuit, indicative of trouble-making Class D personnel."
	icon_state = "e"
	worn_icon_state = "e"

/obj/item/clothing/under/scp/hdclass
	name = "High Security D-Class uniform"
	desc = "A bright red jumpsuit, indicative of dangerous Class D personnel."
	icon_state = "hd"
	worn_icon_state = "hd"

// MTF uniforms
/obj/item/clothing/under/scp/alpha
	name = "Alpha-1 uniform"
	desc = "A modified uniform made specifically for the MTF unit 'Red Right Hand.'"
	icon_state = "alpha-uniform"
	worn_icon_state = "alpha-uniform"
	armor = list(melee = 30, bullet = 20, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

// Foundation-19 Security Uniforms - Adapted for Daedalus Dock

// Entrance Zone Uniforms
/obj/item/clothing/under/scp/security/ez
	name = "EZ Security Suit"
	desc = "A black formal-like uniform used by Entrance Zone's security personnel, woven with fabric durable enough to absorb melee attacks. It has a Entrance Zone badge on the chest."
	icon_state = "ez_guard"
	worn_icon_state = "ez_guard"
	armor = list(melee = 25, bullet = 15, laser = 10, energy = 5, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/warden/ez
	name = "EZ Senior Security Suit"
	desc = "A black formal-like uniform used by Entrance Zone's senior security personnel, woven with fabric durable enough to absorb melee attacks. It has a Entrance Zone badge on the chest, and silver insignia."
	icon_state = "ez_sergeant"
	worn_icon_state = "ez_sergeant"
	armor = list(melee = 30, bullet = 20, laser = 15, energy = 10, bomb = 10, bio = 5, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/hos/ez
	name = "EZ Supervisor Suit"
	desc = "A black formal-like uniform used by Entrance Zone's lead security personnel, woven with fabric durable enough to absorb melee attacks. It has a Entrance Zone badge on the chest, and golden insignia."
	icon_state = "ez_supervisor"
	worn_icon_state = "ez_supervisor"
	armor = list(melee = 35, bullet = 25, laser = 20, energy = 15, bomb = 15, bio = 10, rad = 5)
	siemens_coefficient = 0.8

// Light Containment Zone Uniforms
/obj/item/clothing/under/scp/security/lcz/medic
	name = "LCZ Combat Medic uniform"
	desc = "A white, tactical security uniform with SCP insignia on it, with red shoulder and wrist markings, as well as medical insignia. Weaved with a durable fabric to absorb melee hits. Sterilized fabric for better treatment, and less likely for infections."
	icon_state = "lczmed_guard"
	worn_icon_state = "lczmed_guard"
	armor = list(melee = 30, bullet = 20, laser = 15, energy = 10, bomb = 10, bio = 20, rad = 5)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/security/lcz/riot
	name = "LCZ Riot Control Unit uniform"
	desc = "A white, tactical security uniform with SCP insignia on it, with blue shoulder and wrist markings, as well as shield insignia. Weaved with a durable fabric to absorb melee hits. Moreso than the other security uniforms."
	icon_state = "lczriot_guard"
	worn_icon_state = "lczriot_guard"
	armor = list(melee = 40, bullet = 15, laser = 10, energy = 10, bomb = 20, bio = 5, rad = 5)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/security/lcz/recontain
	name = "LCZ Recontainment Unit uniform"
	desc = "A white, tactical security uniform with SCP insignia on it, with cyan shoulder and wrist markings, as well as chevron insignia. Weaved with a durable fabric to absorb melee hits. You feel like this division will come back one day.."
	icon_state = "lczrecon_guard"
	worn_icon_state = "lczrecon_guard"
	armor = list(melee = 35, bullet = 25, laser = 20, energy = 15, bomb = 15, bio = 10, rad = 5)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/security/lcz/cadet
	name = "LCZ cadet uniform"
	desc = "A black shortsleeved shirt worn by Cadets still in training, bearing \"Trainee\" on the back of the shirt in white, with the Security Department logo on the shoulder. Also along with this is the LCZ security trousers."
	icon_state = "lcz_cadet"
	worn_icon_state = "lcz_cadet"
	armor = list(melee = 20, bullet = 10, laser = 5, energy = 5, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/security/lcz
	name = "LCZ security uniform"
	desc = "A white, tactical security uniform with SCP insignia on it, with black shoulder and wrist markings. Weaved with a durable fabric to absorb melee hits."
	icon_state = "lcz_guard"
	worn_icon_state = "lcz_guard"
	armor = list(melee = 30, bullet = 20, laser = 15, energy = 10, bomb = 10, bio = 5, rad = 5)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/warden/lcz
	name = "LCZ senior security uniform"
	desc = "A white, tactical security uniform with SCP insignia on it. Weaved with a durable fabric to absorb melee hits. This one has a silver badge, and belt buckle, with a dirty rose color on the shoulders and wrists most known for Sergeants."
	icon_state = "lcz_sergeant"
	worn_icon_state = "lcz_sergeant"
	armor = list(melee = 35, bullet = 25, laser = 20, energy = 15, bomb = 15, bio = 10, rad = 5)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/hos/lcz
	name = "LCZ lieutenant uniform"
	desc = "A white, tactical security uniform with SCP insignia on it, with black shoulder and wrist markings. Weaved with a durable fabric to absorb melee hits. This one has a golden badge, and belt buckle, with a command blue color most known for Commanders."
	icon_state = "lcz_commander"
	worn_icon_state = "lcz_commander"
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 20, bomb = 20, bio = 15, rad = 10)
	siemens_coefficient = 0.8

// Heavy Containment Zone Uniforms
/obj/item/clothing/under/scp/security/hcz
	name = "HCZ Security Jumpsuit"
	desc = "A black tactical jumpsuit, with dark red shoulder and wrist markings. Weaved with a durable fabric to absorb melee hits."
	icon_state = "hcz_guard"
	worn_icon_state = "hcz_guard"
	armor = list(melee = 35, bullet = 25, laser = 20, energy = 15, bomb = 15, bio = 10, rad = 10)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/warden/hcz
	name = "HCZ Senior Security Jumpsuit"
	desc = "A black tactical jumpsuit, with dark red shoulder and wrist markings. Weaved with a durable fabric to absorb melee hits. This one has a silver badge, and belt buckle, with a dirty rose color most known for Sergeants."
	icon_state = "hcz_sergeant"
	worn_icon_state = "hcz_sergeant"
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 20, bomb = 20, bio = 15, rad = 15)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/hos/hcz
	name = "HCZ Lieutenant Jumpsuit"
	desc = "A black tactical jumpsuit, with dark red shoulder and wrist markings. Weaved with a durable fabric to absorb melee hits. This one has a golden badge, and belt buckle, with a lighter red color most known for Commanders."
	icon_state = "hcz_commander"
	worn_icon_state = "hcz_commander"
	armor = list(melee = 45, bullet = 35, laser = 30, energy = 25, bomb = 25, bio = 20, rad = 20)
	siemens_coefficient = 0.8

// Guard Commander Uniforms
/obj/item/clothing/under/scp/hos/guardcom
	name = "Guard Commander Uniform"
	desc = "A white tactical shirt, with a pair of black trousers with golden striping on the side, the shirt is covered in gold insignia, with an additional black color over the wrists. There's a golden badge and belt buckle. This is definitely the definition of prospertiy."
	icon_state = "hos"
	worn_icon_state = "hos"
	armor = list(melee = 50, bullet = 40, laser = 35, energy = 30, bomb = 30, bio = 25, rad = 25)
	siemens_coefficient = 0.7

/obj/item/clothing/under/scp/hos/guardcom/alt
	name = "Guard Commander Turtleneck"
	desc = "A white turtleneck, atop of a set of black tactical cargo pants. The turtleneck has a golden insignia on the right shoulder, denoting the rank of Guard Commander. It smells of gunpowder."
	icon_state = "hosalt"
	worn_icon_state = "hosalt"
	armor = list(melee = 45, bullet = 35, laser = 30, energy = 25, bomb = 25, bio = 20, rad = 20)
	siemens_coefficient = 0.7

// Representative Organizations
/obj/item/clothing/under/scp/civilian/goc
	name = "Global Occult Coalition formal suit"
	desc = "A white formal shirt, with a cyan suit trousers. It has insignia of a executive officer of the Global Occult Coalition. You have a feeling whoever wears this doesn't care for SoP."
	icon_state = "gocclothes"
	worn_icon_state = "gocclothes"

/obj/item/clothing/under/scp/civilian/uiu
	name = "Federal Bureau of Investigation turtleneck"
	desc = "A comfortable turtleneck in FBI colors, with some khaki pants. Do the FBI really wear this kind of thing? Usually the outfit of a UIU Relations Agent."
	icon_state = "uiuclothes"
	worn_icon_state = "uiuclothes"

/obj/item/clothing/under/scp/civilian/uiu/formal
	name = "Federal Bureau of Investigation formal suit"
	desc = "A snazzy pair of formal slacks, and a light blue button-up shirt in FBI colors, with some khaki pants. Usually the outfit of a UIU Relations Agent."
	icon_state = "uiuformal"
	worn_icon_state = "uiuformal"

/obj/item/clothing/under/scp/security/goc
	name = "Global Occult Coalition tactical jumpsuit"
	desc = "A blue-ish black tactical suit with a UNGOC logo on one of the shoulders. It's comfortable materials make it good for manueverability. All combat, all the time."
	icon_state = "goc_jumpsuit"
	worn_icon_state = "goc_jumpsuit"
	armor = list(melee = 40, bullet = 35, laser = 30, energy = 25, bomb = 20, bio = 15, rad = 15)
	siemens_coefficient = 0.8

// Standard Security Uniforms
/obj/item/clothing/under/scp/warden
	name = "Security Senior Jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. Issued to intermediate ranked guards and agents of SD."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "warden"
	worn_icon_state = "warden"
	armor = list(melee = 30, bullet = 20, laser = 15, energy = 10, bomb = 10, bio = 5, rad = 5)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/security
	name = "Security Jumpsuit"
	desc = "A jumpsuit made for Foundation SD guards, agents and officers."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "security"
	worn_icon_state = "security"
	armor = list(melee = 25, bullet = 15, laser = 10, energy = 5, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/dispatch
	name = "dispatcher's uniform"
	desc = "A dress shirt and khakis with a security patch sewn on."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "security"
	worn_icon_state = "security"
	armor = list(melee = 20, bullet = 10, laser = 5, energy = 5, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/security2
	name = "Security Jumpsuit"
	desc = "A jumpsuit made for Foundation SD guards, agents and officers."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "security"
	worn_icon_state = "security"
	armor = list(melee = 25, bullet = 15, laser = 10, energy = 5, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/scp/security/corp
	name = "Corporate Security Jumpsuit"
	desc = "A corporate-style security jumpsuit."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "officerblueclothes"
	worn_icon_state = "officerblueclothes"

/obj/item/clothing/under/scp/warden/corp
	name = "Corporate Senior Security Jumpsuit"
	desc = "A corporate-style senior security jumpsuit."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "wardenblueclothes"
	worn_icon_state = "wardenblueclothes"

/obj/item/clothing/under/scp/tactical
	name = "tactical jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "security"
	worn_icon_state = "security"
	armor = list(melee = 35, bullet = 25, laser = 20, energy = 15, bomb = 15, bio = 10, rad = 10)
	siemens_coefficient = 0.9

// Detective Uniforms
/obj/item/clothing/under/scp/det
	name = "detective's suit"
	desc = "A rumpled white dress shirt paired with well-worn grey slacks."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "detective"
	worn_icon_state = "detective"

/obj/item/clothing/under/scp/det/grey
	name = "detective's grey suit"
	desc = "A serious-looking tan dress shirt paired with freshly-pressed black slacks."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "detective"
	worn_icon_state = "detective_d"

/obj/item/clothing/under/scp/det/black
	name = "detective's black suit"
	desc = "An immaculate white dress shirt, paired with a pair of dark grey dress pants, a red tie, and a charcoal vest."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "noirdet"
	worn_icon_state = "detective_noir"

// Head of Security Uniforms
/obj/item/clothing/under/scp/hos
	name = "Security Officer Jumpsuit"
	desc = "SD uniform issued to certain officers."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "hos"
	worn_icon_state = "hos"
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 20, bomb = 20, bio = 15, rad = 15)
	siemens_coefficient = 0.8

/obj/item/clothing/under/scp/hos/corp
	name = "Corporate Security Officer Jumpsuit"
	desc = "A corporate-style security officer jumpsuit."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "hosblueclothes"
	worn_icon_state = "hosblueclothes"

/obj/item/clothing/under/scp/hos/jensen
	name = "head of security's jumpsuit"
	desc = "You never asked for anything that stylish."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "hos"
	worn_icon_state = "hos"
	siemens_coefficient = 0.6

// Chaos Insurgency
/obj/item/clothing/under/scp/syndicate/chaos
	name = "Chaos Insurgency field uniform"
	desc = "Heavy green field military garbs from an unknown group of interest, you'd assume it's from the Chaos Insurgency."
	icon_state = "ci_jumpsuit"
	worn_icon_state = "ci_jumpsuit"

// Utility Uniforms
/obj/item/clothing/under/scp/cargotech/utility
	name = "Logistics Specialist utility uniform"
	desc = "A heavy utility jumpsuit used by the Logistics Department."
	icon_state = "gorka_cargo"
	worn_icon_state = "gorka_cargo"

/obj/item/clothing/under/scp/cargotech/utility/qm
	name = "Logistics Officer utility uniform"
	desc = "A heavy utility jumpsuit used by the Logistics Department. This one has silver markings, and is for the Officer of Logistics."
	icon_state = "gorka_qm"
	worn_icon_state = "gorka_qm"

/obj/item/clothing/under/scp/engineer/comms
	name = "Communications Technician jumpsuit"
	desc = "A heavy duty pair of a tactical engineering high-vis jumpsuit. It's assumed to be mainly used by Communications Techs."
	icon_state = "comms_tech"
	worn_icon_state = "comms_tech"

/obj/item/clothing/under/scp/security/comms
	name = "Communications Officer suit"
	desc = "A pair of black trousers along with a white dress shirt. It has some golden patches on the shoulders denoting the rank of Communications Officer."
	icon_state = "comms_officer"
	worn_icon_state = "comms_officer"

/obj/item/clothing/under/scp/security/isd
	name = "Internal Security field uniform"
	desc = "A smooth black, yet comfortable turtleneck. There isn't much to note about it, atop of some dark grey trousers. Worn by Internal Security Department's goons."
	icon_state = "isd_field"
	worn_icon_state = "isd_field"

/obj/item/clothing/under/scp/security/isd/suit
	name = "Internal Security formal uniform"
	desc = "A pair of formal slacks, with a dark grey dress shirt. It's covered by a black formal vest, and a snazzy red tie. Only worn by the executives of the Internal Security Department."
	icon_state = "isd_suit"
	worn_icon_state = "isd_suit"

// Navy Uniforms
/obj/item/clothing/under/scp/security/navyblue
	name = "security officer's uniform"
	desc = "The latest in fashionable security outfits."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "officerblueclothes"
	worn_icon_state = "officerblueclothes"

/obj/item/clothing/under/scp/hos/navyblue
	name = "Security Officer Uniform"
	desc = "The insignia on this uniform tells you that this uniform belongs to a SD Officer."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "hosblueclothes"
	worn_icon_state = "hosblueclothes"

/obj/item/clothing/under/scp/warden/navyblue
	name = "Security Uniform"
	desc = "The insignia on this uniform tells you that this uniform belongs to an agent of SD."
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	icon_state = "wardenblueclothes"
	worn_icon_state = "wardenblueclothes"

// Representative Organization Jackets
/obj/item/clothing/suit/scp/gocjacket
	name = "Global Occult Coalition formal jacket"
	desc = "A cyan formal coat, those who wear this are executive officers of the Global Occult Coalition, with insignia of such."
	icon_state = "gocjacket"
	worn_icon_state = "gocjacket"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'

/obj/item/clothing/suit/scp/uiucoat
	name = "Federal Bureau of Investigation jacket"
	desc = "A FBI jacket, used by Federal Bureau of Investigation, and or UIU Relations Agents. You feel like you deserve more than this."
	icon_state = "uiucoat"
	worn_icon_state = "uiucoat"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'

// Head of Security Jackets
/obj/item/clothing/suit/scp/hos
	name = "armored coat"
	desc = "A greatcoat enhanced with a special alloy for some protection and style."
	icon_state = "hos"
	worn_icon_state = "hos"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	body_parts_covered = 15
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 20, bomb = 20, bio = 15, rad = 15)
	siemens_coefficient = 0.6

/obj/item/clothing/suit/scp/hos/jensen
	name = "Guard Commander Coat"
	desc = "A long trenchcoat issued to the Highest Ranking security officer of the SCP Foundation."
	icon_state = "hostrench"
	worn_icon_state = "hostrench"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'

/obj/item/clothing/suit/scp/hos/vest
	name = "Guard Commander's armored vest"
	desc = "A slim tactical vest with a golden badge on it. You feel like a marine wearing this somehow."
	icon_state = "gc_vest"
	worn_icon_state = "gc_vest"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	body_parts_covered = 3
	armor = list(melee = 35, bullet = 30, laser = 25, energy = 20, bomb = 15, bio = 10, rad = 10)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/scp/hos/coat
	name = "Guard Commander's padded coat"
	desc = "A black coat with a nameplate, and rank badge on the chest, it feels thick, and armored unlike most coats. This makes you feel the sense of style."
	icon_state = "gc_coat"
	worn_icon_state = "gc_coat"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	body_parts_covered = 15
	armor = list(melee = 30, bullet = 25, laser = 20, energy = 15, bomb = 15, bio = 10, rad = 10)
	siemens_coefficient = 0.8

/obj/item/clothing/suit/armor/director_coat
	name = "Site Director's Armored Coat"
	desc = "A formal long coat worn by the Site Director. Reinforced with lightweight armor plating for personal protection."
	icon_state = "hostrench"
	worn_icon_state = "hostrench"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	body_parts_covered = 15
	armor = list(melee = 40, bullet = 35, laser = 30, energy = 25, bomb = 20, bio = 15, rad = 10)
	siemens_coefficient = 0.7
	allowed = list(/obj/item/gun/energy, /obj/item/restraints/handcuffs, /obj/item/assembly/flash)

// Communications Officer Jacket
/obj/item/clothing/suit/scp/comms
	name = "Communications Officer jacket"
	desc = "A luxurious suit jacket worn by the Communications Officer, it has the same gold patches on the shoulders."
	icon_state = "co_coat"
	worn_icon_state = "co_coat"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'

// Headgear
/obj/item/clothing/head/scp/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force."
	icon_state = "policehelm"
	worn_icon_state = "policehelm"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	body_parts_covered = 0

/obj/item/clothing/head/scp/hos
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	worn_icon_state = "hoscap"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	body_parts_covered = 0
	siemens_coefficient = 0.8

/obj/item/clothing/head/scp/hos/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"
	worn_icon_state = "dermal"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	body_parts_covered = 0
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 20, bomb = 20, bio = 15, rad = 15)
	siemens_coefficient = 0.6

/obj/item/clothing/head/beret/sec/guardcom
	name = "Guard Commander beret"
	desc = "A black beret with the Guard Commander's insignia. For those who command with authority and style."
	icon_state = "beret_badge"
	worn_icon_state = "beret_guardcom"
	armor = list(melee = 10, bullet = 5, laser = 5, energy = 5, bomb = 5, bio = 0, rad = 0)

// Detective Headgear
/obj/item/clothing/head/scp/det
	name = "fedora"
	desc = "A brown fedora - either the cornerstone of a detective's style or a poor attempt at looking cool, depending on the person wearing it."
	icon_state = "detective"
	worn_icon_state = "detective"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	armor = list(melee = 30, bullet = 15, laser = 10, energy = 5, bomb = 5, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/head/scp/det/grey
	name = "grey fedora"
	desc = "A grey fedora - either the cornerstone of a detective's style or a poor attempt at looking cool, depending on the person wearing it."
	icon_state = "detective"
	worn_icon_state = "detective_noir"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'

// SCP Split Personality Necklace
/obj/item/clothing/neck/scp/split_personality_necklace
	name = "mysterious necklace"
	desc = "A strange necklace with an otherworldly aura. You feel like it's watching you..."
	icon = 'icons/obj/clothing/neck.dmi'
	worn_icon = 'icons/mob/clothing/neck.dmi'
	icon_state = "eldritch_necklace"
	worn_icon_state = "eldritch_necklace"
	slot_flags = ITEM_SLOT_NECK
	var/datum/brain_trauma/severe/split_personality/active_trauma

/obj/item/clothing/neck/scp/split_personality_necklace/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_NECK && ishuman(user))
		if(!active_trauma)
			active_trauma = new(user)
			user.gain_trauma(active_trauma, TRAUMA_RESILIENCE_BASIC)
			to_chat(user, span_warning("You feel a strange presence entering your mind as you put on the necklace..."))
			log_game("[key_name(user)] put on the split personality necklace and gained split personality.")
			message_admins("[ADMIN_LOOKUPFLW(user)] put on the split personality necklace and gained split personality.")

/obj/item/clothing/neck/scp/split_personality_necklace/unequipped(mob/living/carbon/human/user)
	. = ..()
	if(active_trauma && user.has_trauma_type(/datum/brain_trauma/severe/split_personality))
		user.cure_trauma_type(/datum/brain_trauma/severe/split_personality, TRAUMA_RESILIENCE_BASIC)
		active_trauma = null
		to_chat(user, span_notice("The strange presence leaves your mind as you remove the necklace."))
		log_game("[key_name(user)] removed the split personality necklace and lost split personality.")
		message_admins("[ADMIN_LOOKUPFLW(user)] removed the split personality necklace and lost split personality.")

/obj/item/clothing/neck/scp/split_personality_necklace/Destroy()
	if(active_trauma)
		active_trauma = null
	return ..()
