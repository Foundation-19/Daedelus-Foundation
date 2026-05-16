/datum/supply_pack/foundation_emergency
	group = "Foundation Emergency"

/datum/supply_pack/foundation_emergency/breach_kit
	name = "Breach Response Kit"
	desc = "Contains containment breach response equipment: blast doors, repair materials, and hazmat gear."
	cost = 2000
	contains = list(/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/oxygen,
					/obj/item/storage/bag/bio,
					/obj/item/stack/sheet/iron,
					/obj/item/stack/sheet/plasteel)
	crate_name = "breach response crate"
	access = ACCESS_SECURITY

/datum/supply_pack/foundation_emergency/amnestic
	name = "Amnestic Supply Kit"
	desc = "Contains amnestic injectors for civilian containment protocols."
	cost = 1500
	contains = list(/obj/item/reagent_containers/syringe,
					/obj/item/reagent_containers/syringe,
					/obj/item/reagent_containers/syringe,
					/obj/item/reagent_containers/syringe,
					/obj/item/reagent_containers/syringe)
	crate_name = "amnestic supply crate"
	access = ACCESS_MEDICAL

/datum/supply_pack/foundation_emergency/fire_fighting
	name = "Fire Suppression Kit"
	desc = "Contains fire-fighting equipment for SCP-457 containment support."
	cost = 1200
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced)
	crate_name = "fire suppression crate"
	access = ACCESS_SECURITY

/datum/supply_pack/foundation_security
	group = "Foundation Security"

/datum/supply_pack/foundation_security/riot_gear
	name = "Riot Equipment"
	desc = "Contains riot shields and armor for D-Class riot suppression."
	cost = 2500
	contains = list(/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/clothing/suit/armor/vest/scp/medarmor/riot,
					/obj/item/clothing/suit/armor/vest/scp/medarmor/riot,
					/obj/item/clothing/head/helmet/scp/security/riot,
					/obj/item/clothing/head/helmet/scp/security/riot)
	crate_name = "riot equipment crate"
	access = ACCESS_SECURITY

/datum/supply_pack/foundation_security/restraints
	name = "Restraint Supply Kit"
	desc = "Contains handcuffs and leg irons for D-Class management."
	cost = 800
	contains = list(/obj/item/restraints/handcuffs,
					/obj/item/restraints/handcuffs,
					/obj/item/restraints/handcuffs,
					/obj/item/restraints/handcuffs,
					/obj/item/restraints/legcuffs,
					/obj/item/restraints/legcuffs)
	crate_name = "restraint supply crate"
	access = ACCESS_SECURITY

/datum/supply_pack/foundation_security/mtf_loadout
	name = "MTF Equipment Crate"
	desc = "Contains basic MTF deployment equipment."
	cost = 3000
	contains = list(/obj/item/clothing/under/scp/alpha,
					/obj/item/clothing/suit/armor/vest/scp/medarmor,
					/obj/item/clothing/head/helmet/scp/security,
					/obj/item/radio/headset/scp_mtf,
					/obj/item/storage/belt/security/full)
	crate_name = "MTF equipment crate"
	access = ACCESS_SECURITY

/datum/supply_pack/foundation_containment
	group = "Foundation Containment"

/datum/supply_pack/foundation_containment/scranton_anchor
	name = "Scranton Reality Anchor Components"
	desc = "Contains components for constructing a Scranton Reality Anchor."
	cost = 5000
	contains = list(/obj/item/stack/sheet/plasteel,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/scanning_module,
					/obj/item/stock_parts/manipulator,
					/obj/item/circuitboard/machine/scranton_reality_anchor)
	crate_name = "scranton anchor components"
	access = ACCESS_SCIENCE

/datum/supply_pack/foundation_containment/containment_materials
	name = "Containment Construction Materials"
	desc = "Heavy-duty materials for building and repairing containment cells."
	cost = 3000
	contains = list(/obj/item/stack/sheet/plasteel,
					/obj/item/stack/sheet/iron,
					/obj/item/stack/sheet/glass)
	crate_name = "containment materials crate"
	access = ACCESS_ENGINEERING

/datum/supply_pack/foundation_medical
	group = "Foundation Medical"

/datum/supply_pack/foundation_medical/quarantine
	name = "Quarantine Medical Kit"
	desc = "Contains biohazard containment and treatment supplies."
	cost = 1800
	contains = list(/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/mask/gas,
					/obj/item/storage/medkit/regular,
					/obj/item/storage/medkit/regular,
					/obj/item/reagent_containers/syringe,
					/obj/item/reagent_containers/syringe)
	crate_name = "quarantine medical crate"
	access = ACCESS_MEDICAL

/datum/supply_pack/foundation_research
	group = "Foundation Research"

/datum/supply_pack/foundation_research/testing_equipment
	name = "SCP Testing Equipment"
	desc = "Standard equipment for supervised SCP testing sessions."
	cost = 1500
	contains = list(/obj/item/clipboard,
					/obj/item/pen,
					/obj/item/camera,
					/obj/item/taperecorder,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/head/bio_hood)
	crate_name = "testing equipment crate"
	access = ACCESS_SCIENCE

/datum/supply_pack/foundation_research/reagent_analysis
	name = "Reagent Analysis Kit"
	desc = "Equipment for analyzing anomalous materials and substances."
	cost = 2000
	contains = list(/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/storage/bag/chemistry)
	crate_name = "reagent analysis crate"
	access = ACCESS_SCIENCE

/datum/supply_pack/foundation_engineering
	group = "Foundation Engineering"

/datum/supply_pack/foundation_engineering/power_backup
	name = "Backup Power Supplies"
	desc = "Contains power cells for facility power maintenance."
	cost = 2000
	contains = list(/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	crate_name = "backup power crate"
	access = ACCESS_ENGINEERING

/datum/supply_pack/foundation_engineering/hvac_repair
	name = "HVAC Repair Kit"
	desc = "Atmospherics repair equipment for facility ventilation systems."
	cost = 1800
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/oxygen,
					/obj/item/wrench,
					/obj/item/weldingtool,
					/obj/item/analyzer)
	crate_name = "HVAC repair crate"
	access = ACCESS_ENGINEERING

/datum/supply_pack/foundation_service
	group = "Foundation Service"

/datum/supply_pack/foundation_service/dclass_supplies
	name = "D-Class Maintenance Supplies"
	desc = "Basic cleaning and maintenance supplies for D-Class work assignments."
	cost = 400
	contains = list(/obj/item/mop,
					/obj/item/soap,
					/obj/item/pushbroom)
	crate_name = "D-Class supplies crate"
	access = ACCESS_DCLASS
