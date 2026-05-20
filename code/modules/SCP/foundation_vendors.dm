/obj/machinery/vending/foundation_cafe
	name = "Foundation Cafeteria Vendor"
	desc = "A Foundation-branded food and beverage vendor."
	icon_state = "coffee"
	icon_deny = "coffee"
	products = list(
		/obj/item/reagent_containers/food/drinks/coffee = 5,
		/obj/item/food/burger/plain = 3,
		/obj/item/food/breadslice/moldy = 5,
		/obj/item/food/chips = 5,
		/obj/item/food/candy = 5,
		/obj/item/food/donut/plain = 5,
		/obj/item/food/cheesiehonkers = 5,
	)
	contraband = list(
		/obj/item/reagent_containers/food/drinks/bottle/beer = 2,
	)
	refill_canister = /obj/item/vending_refill/foundation_cafe

/obj/item/vending_refill/foundation_cafe
	machine_name = "Foundation Cafeteria Vendor"
	icon_state = "refill_snack"

/obj/machinery/vending/foundation_medical
	name = "Foundation Medical Vendor"
	desc = "A Foundation-branded medical supply vendor."
	icon_state = "med"
	icon_deny = "med-deny"
	products = list(
		/obj/item/stack/medical/gauze = 8,
		/obj/item/stack/medical/bruise_pack = 5,
		/obj/item/stack/medical/ointment = 5,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 3,
		/obj/item/reagent_containers/glass/bottle/saline_glucose = 3,
		/obj/item/healthanalyzer = 2,
		/obj/item/clothing/gloves/color/latex = 3,
		/obj/item/clothing/mask/surgical = 3,
		/obj/item/reagent_containers/pill/amnestics/classa = 6,
		/obj/item/reagent_containers/syringe/amnesticsc = 3,
		/obj/item/reagent_containers/syringe/amnesticse = 2,
		/obj/item/stack/medical/bone_gel = 3,
		/obj/item/retractor = 2,
		/obj/item/hemostat = 2,
		/obj/item/cautery = 2,
	)
	contraband = list(
		/obj/item/reagent_containers/glass/bottle/morphine = 2,
		/obj/item/reagent_containers/pill/amnestics/classb = 3,
		/obj/item/reagent_containers/syringe/amnesticsg = 2,
	)
	premium = list(
		/obj/item/reagent_containers/ivbag/amnesticsf = 1,
		/obj/item/reagent_containers/pill/amnestics/classh = 3,
	)
	refill_canister = /obj/item/vending_refill/foundation_medical

/obj/item/vending_refill/foundation_medical
	machine_name = "Foundation Medical Vendor"
	icon_state = "refill_medical"

/obj/machinery/vending/foundation_tools
	name = "Foundation Engineering Vendor"
	desc = "A Foundation-branded engineering supply vendor."
	icon_state = "tool"
	icon_deny = "tool-deny"
	products = list(
		/obj/item/crowbar = 3,
		/obj/item/wrench = 3,
		/obj/item/weldingtool = 3,
		/obj/item/screwdriver = 3,
		/obj/item/wirecutters = 3,
		/obj/item/stack/cable_coil = 5,
		/obj/item/flashlight = 5,
		/obj/item/t_scanner = 2,
		/obj/item/analyzer = 2,
		/obj/item/stock_parts/cell = 3,
		/obj/item/multitool = 2,
	)
	contraband = list(
		/obj/item/weldingtool/hugetank = 1,
	)
	refill_canister = /obj/item/vending_refill/foundation_tools

/obj/item/vending_refill/foundation_tools
	machine_name = "Foundation Engineering Vendor"
	icon_state = "refill_engi"

/obj/machinery/vending/foundation_security
	name = "Foundation Security Vendor"
	desc = "A Foundation-branded security equipment vendor. Requires Security access."
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/restraints/handcuffs = 8,
		/obj/item/restraints/legcuffs = 4,
		/obj/item/food/donut/plain = 12,
		/obj/item/storage/belt/security = 4,
		/obj/item/clothing/gloves/color/black = 4,
		/obj/item/flashlight/seclite = 4,
		/obj/item/melee/baton/loaded = 4,
		/obj/item/grenade/flashbang = 4,
		/obj/item/grenade/chem_grenade/teargas = 4,
		/obj/item/ammo_box/magazine/scp/ierichon = 6,
		/obj/item/ammo_box/magazine/scp/ierichon/rubber = 6,
	)
	contraband = list(
		/obj/item/gun/ballistic/automatic/scp/ierichon = 2,
		/obj/item/ammo_box/magazine/scp/mk9/ap = 4,
	)
	refill_canister = /obj/item/vending_refill/foundation_security

/obj/item/vending_refill/foundation_security
	machine_name = "Foundation Security Vendor"
	icon_state = "refill_sec"

/obj/machinery/vending/foundation_science
	name = "Foundation Research Vendor"
	desc = "A Foundation-branded research supply vendor. Requires Science access."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access = list(ACCESS_SCIENCE)
	products = list(
		/obj/item/reagent_containers/glass/beaker = 5,
		/obj/item/reagent_containers/glass/beaker/large = 3,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/storage/bag/chemistry = 2,
		/obj/item/pen = 5,
		/obj/item/clipboard = 3,
		/obj/item/camera = 3,
		/obj/item/taperecorder = 3,
	)
	refill_canister = /obj/item/vending_refill/foundation_science

/obj/item/vending_refill/foundation_science
	machine_name = "Foundation Research Vendor"
	icon_state = "refill_robotics"

/obj/machinery/vending/foundation_armory
	name = "Foundation Armory Vendor"
	desc = "A Foundation-branded armory supply vendor. Requires Security Level 3 access."
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access = list(ACCESS_SECURITY_LVL3)
	products = list(
		/obj/item/gun/ballistic/automatic/scp/p90 = 4,
		/obj/item/gun/ballistic/automatic/scp/ierichon = 6,
		/obj/item/ammo_box/magazine/scp/p90_mag = 10,
		/obj/item/ammo_box/magazine/scp/ierichon = 10,
		/obj/item/ammo_box/magazine/scp/mk9 = 10,
		/obj/item/ammo_box/magazine/scp/mk9/rubber = 10,
		/obj/item/ammo_box/a9mm = 4,
		/obj/item/storage/belt/military = 4,
		/obj/item/clothing/gloves/combat = 4,
		/obj/item/flashlight/seclite = 4,
	)
	contraband = list(
		/obj/item/gun/ballistic/automatic/scp/m16 = 2,
		/obj/item/ammo_box/magazine/scp/m16_mag = 4,
		/obj/item/ammo_box/magazine/scp/p90_mag/ap = 4,
	)
	premium = list(
		/obj/item/gun/ballistic/shotgun/combat = 1,
		/obj/item/ammo_box/buckshot = 2,
		/obj/item/ammo_box/slug = 2,
	)
	refill_canister = /obj/item/vending_refill/foundation_armory

/obj/item/vending_refill/foundation_armory
	machine_name = "Foundation Armory Vendor"
	icon_state = "refill_sec"
