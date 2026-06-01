/datum/uplink_category/ci_weapons
	name = "Weapons"
	weight = 10

/datum/uplink_category/ci_equipment
	name = "Equipment"
	weight = 9

/datum/uplink_category/ci_medical
	name = "Medical"
	weight = 8

/datum/uplink_category/ci_sabotage
	name = "Sabotage"
	weight = 7

/datum/uplink_category/ci_intel
	name = "Intelligence"
	weight = 6

/datum/uplink_category/ci_anomalous
	name = "Anomalous Items"
	weight = 5

/datum/uplink_item/ci
	purchasable_from = UPLINK_CI
	surplus = 0
	illegal_tech = FALSE

/datum/uplink_item/ci/pistol
	name = "Makarov Pistol"
	desc = "A reliable sidearm. Comes with one magazine."
	item = /obj/item/gun/ballistic/automatic/pistol
	cost = 4
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/pistol_ammo
	name = "10mm Magazine"
	desc = "A spare magazine for the Makarov pistol."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/smg
	name = "C-20r Submachine Gun"
	desc = "A compact submachine gun. Effective at close range."
	item = /obj/item/gun/ballistic/automatic/c20r
	cost = 8
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/smg_ammo
	name = "SMG Magazine"
	desc = "A spare magazine for the C-20r."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 2
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/shotgun
	name = "Bulldog Shotgun"
	desc = "A semi-automatic drum-fed shotgun."
	item = /obj/item/gun/ballistic/shotgun/bulldog
	cost = 8
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/combat_knife
	name = "Combat Knife"
	desc = "A military-grade combat knife."
	item = /obj/item/knife/combat
	cost = 2
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/emp_grenade
	name = "EMP Grenade"
	desc = "Disables electronics and cameras in a large radius."
	item = /obj/item/grenade/empgrenade
	cost = 2
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/frag_grenade
	name = "Frag Grenade"
	desc = "A standard fragmentation grenade."
	item = /obj/item/grenade/syndieminibomb
	cost = 4
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/flashbang_pack
	name = "Flashbang Pack"
	desc = "A box of 7 flashbang grenades for crowd control."
	item = /obj/item/storage/box/flashbangs
	cost = 3
	category = /datum/uplink_category/ci_weapons

/datum/uplink_item/ci/ci_uniform
	name = "CI Tactical Uniform"
	desc = "A dark green tactical uniform with Chaos Insurgency insignia."
	item = /obj/item/clothing/under/scp/syndicate/chaos
	cost = 2
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/ci_vest
	name = "CI Armored Vest"
	desc = "A lightweight armored vest providing decent protection."
	item = /obj/item/clothing/suit/armor/vest
	cost = 3
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/ci_helmet
	name = "CI Tactical Helmet"
	desc = "A tactical helmet with basic head protection."
	item = /obj/item/clothing/head/helmet
	cost = 2
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/ci_mask
	name = "CI Gas Mask"
	desc = "A tactical gas mask with smoke protection."
	item = /obj/item/clothing/mask/gas
	cost = 1
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/encryption_key
	name = "CI Encryption Key"
	desc = "An encryption key for the Chaos Insurgency radio channel."
	item = /obj/item/encryptionkey/ci
	cost = 1
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/headset
	name = "CI Headset"
	desc = "A radio headset tuned to Chaos Insurgency frequencies."
	item = /obj/item/radio/headset/ci
	cost = 1
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/toolkit
	name = "Toolbox"
	desc = "A full engineering toolbox for breaking and entering."
	item = /obj/item/storage/toolbox/syndicate
	cost = 1
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/emag
	name = "Cryptographic Sequencer"
	desc = "An electromagnetic attack card that breaks open airlocks and overrides access."
	item = /obj/item/card/emag
	cost = 4
	category = /datum/uplink_category/ci_equipment

/datum/uplink_item/ci/medkit
	name = "Medical Kit"
	desc = "A first aid kit for field medicine."
	item = /obj/item/storage/medkit/regular
	cost = 2
	category = /datum/uplink_category/ci_medical

/datum/uplink_item/ci/stimpack
	name = "Stimpack Bundle"
	desc = "Three survival medipens for emergency healing."
	item = /obj/item/storage/box/medipens
	cost = 3
	category = /datum/uplink_category/ci_medical

/datum/uplink_item/ci/surgery_kit
	name = "Field Surgery Kit"
	desc = "A compact surgical kit for field operations."
	item = /obj/item/storage/medkit/surgery
	cost = 4
	category = /datum/uplink_category/ci_medical

/datum/uplink_item/ci/c4
	name = "C-4 Explosive"
	desc = "A plastic explosive charge for breaching walls and doors."
	item = /obj/item/grenade/c4
	cost = 2
	category = /datum/uplink_category/ci_sabotage

/datum/uplink_item/ci/c4_bundle
	name = "C-4 Bundle"
	desc = "A duffel bag containing four C-4 charges for heavy demolition work."
	item = /obj/item/storage/backpack/duffelbag/syndie/c4
	cost = 5
	category = /datum/uplink_category/ci_sabotage

/datum/uplink_item/ci/ci_breach_device
	name = "CI Breach Device"
	desc = "A specialized tool for breaching containment doors."
	item = /obj/item/ci_breach_device
	cost = 3
	category = /datum/uplink_category/ci_sabotage

/datum/uplink_item/ci/jammer
	name = "Signal Jammer"
	desc = "Blocks radio communications in a wide area."
	item = /obj/item/jammer
	cost = 3
	category = /datum/uplink_category/ci_sabotage

/datum/uplink_item/ci/agent_card
	name = "Agent ID Card"
	desc = "A forged ID card that can copy access from other cards."
	item = /obj/item/card/id/advanced/chameleon
	cost = 3
	category = /datum/uplink_category/ci_intel

/datum/uplink_item/ci/camera
	name = "Intel Camera"
	desc = "A camera that can photograph documents and evidence."
	item = /obj/item/camera/ci_intel_camera
	cost = 1
	category = /datum/uplink_category/ci_intel

/datum/uplink_item/ci/binoculars
	name = "Tactical Binoculars"
	desc = "Long-range observation equipment."
	item = /obj/item/binoculars
	cost = 1
	category = /datum/uplink_category/ci_intel

/datum/uplink_item/ci/stolen_document
	name = "Stolen Foundation Document"
	desc = "Pre-forged intelligence documents for cover stories."
	item = /obj/item/ci_document
	cost = 1
	category = /datum/uplink_category/ci_intel

/datum/uplink_item/ci/amnestic_kit
	name = "Amnestic Kit"
	desc = "Three Class-A amnestic injectors for silencing witnesses."
	item = /obj/item/storage/box/syndie_kit/amnestics
	cost = 2
	category = /datum/uplink_category/ci_anomalous

/datum/uplink_item/ci/scp148_shard
	name = "Telekill Alloy Shard"
	desc = "A small shard of SCP-148 that provides limited memetic resistance when carried."
	item = /obj/item/stack/sheet/telekill
	cost = 5
	category = /datum/uplink_category/ci_anomalous

/datum/uplink_item/ci/anomalous_scanner
	name = "Anomalous Scanner"
	desc = "A handheld device that detects nearby anomalous signatures and containment breaches."
	item = /obj/item/healthanalyzer
	cost = 4
	category = /datum/uplink_category/ci_anomalous

/datum/uplink_item/ci/containment_breach_kit
	name = "Containment Breach Kit"
	desc = "A specialized kit for breaching SCP containment cells. Contains C-4, an emag, and breach device."
	item = /obj/item/storage/box/syndie_kit/ci_breach
	cost = 7
	category = /datum/uplink_category/ci_anomalous

/obj/item/storage/box/syndie_kit/ci_breach/PopulateContents()
	new /obj/item/grenade/c4(src)
	new /obj/item/grenade/c4(src)
	new /obj/item/card/emag(src)
	new /obj/item/ci_breach_device(src)

/obj/item/storage/box/syndie_kit/amnestics/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/syringe/amnestic(src)

/obj/item/uplink/ci
	name = "strange device"
	desc = "A compact communications device linked to Chaos Insurgency command."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	uplink_flag = UPLINK_CI

/obj/item/uplink/ci/Initialize(mapload, owner, tc_amount = 15)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	if(hidden_uplink)
		hidden_uplink.name = "Chaos Insurgency uplink"
		hidden_uplink.unlock_text = "Chaos Insurgency command link established. Use your telecrystals wisely, operative."

/obj/item/encryptionkey/ci
	name = "CI encryption key"
	desc = "An encryption key for Chaos Insurgency radio channels."
	icon_state = "cypherkey"

/obj/item/radio/headset/ci
	name = "CI radio headset"
	desc = "A radio headset tuned to Chaos Insurgency frequencies."
	icon_state = "sec_headset"
	keyslot = new /obj/item/encryptionkey/ci

/obj/effect/spawner/random/ci_uplink
	name = "Chaos Insurgency Uplink Spawner"
	loot = list(/obj/item/uplink/ci)

/obj/item/ci_supply_beacon
	name = "CI Supply Beacon"
	desc = "A beacon that signals Chaos Insurgency forces to airdrop supplies. Single use."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller_left"
	var/used = FALSE

/obj/item/ci_supply_beacon/attack_self(mob/user)
	if(used)
		to_chat(user, span_warning("This beacon has already been used."))
		return
	var/confirm = alert(user, "Activate CI supply beacon? This will airdrop a supply crate at your location.", "Supply Beacon", "Activate", "Cancel")
	if(confirm != "Activate")
		return
	used = TRUE
	user.visible_message(span_warning("[user] activates the supply beacon!"))
	playsound(src, 'sound/machines/triple_beep.ogg', 50, TRUE)
	priority_announce("ALERT: Unauthorized supply signal detected at [get_area_name(src)]. Possible hostile resupply operation.", "SECURITY ALERT", null, ANNOUNCER_ALERT)

	var/turf/T = get_turf(src)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/spawn_ci_crate, T), 10 SECONDS)

/proc/spawn_ci_crate(turf/T)
	if(!T)
		return
	var/obj/structure/closet/crate/C = new(T)
	new /obj/item/storage/medkit/regular(C)
	new /obj/item/reagent_containers/syringe(C)
	new /obj/item/flashlight(C)
	new /obj/item/radio/off(C)

/obj/item/ci_document
	name = "stolen Foundation document"
	desc = "A classified Foundation document stolen by Chaos Insurgency operatives."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_words"
	var/document_type = "generic"

/obj/item/ci_document/attack_self(mob/user)
	to_chat(user, span_notice("You read the classified document: [document_type] intelligence report."))
