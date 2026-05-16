/obj/item/reagent_containers/glass/bottle/foundation_pathogen
	name = "Foundation Pathogen Sample"
	desc = "A sealed container holding a Foundation-classified pathogen sample."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"
	var/pathogen_type

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/Initialize()
	. = ..()
	if(pathogen_type)
		var/datum/pathogen/P = new pathogen_type()
		var/list/data = list()
		data["viruses"] = list(P)
		reagents.add_reagent(/datum/reagent/blood, 20, data)

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/common_cold
	name = "Rhinovirus Sample"
	pathogen_type = /datum/pathogen/foundation/common_cold

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/norovirus
	name = "Norovirus Sample"
	pathogen_type = /datum/pathogen/foundation/norovirus

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/tuberculosis
	name = "Tuberculosis Sample"
	pathogen_type = /datum/pathogen/foundation/tuberculosis

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/mrsa
	name = "MRSA Sample"
	pathogen_type = /datum/pathogen/foundation/mrsa

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/ebola
	name = "Ebola Sample (BSL-4)"
	pathogen_type = /datum/pathogen/foundation/ebola

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/rabies
	name = "Rabies Sample (BSL-3)"
	pathogen_type = /datum/pathogen/foundation/rabies

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/covid19
	name = "SARS-CoV-2 Sample (BSL-3)"
	pathogen_type = /datum/pathogen/foundation/covid19

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/anthrax
	name = "Anthrax Sample (BSL-3)"
	pathogen_type = /datum/pathogen/foundation/anthrax

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/smallpox
	name = "Variola Major Sample (BSL-4)"
	pathogen_type = /datum/pathogen/foundation/smallpox

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/random_foundation
	name = "Random Foundation Pathogen"

/obj/item/reagent_containers/glass/bottle/foundation_pathogen/random_foundation/Initialize()
	var/list/options = list(
		/datum/pathogen/foundation/common_cold,
		/datum/pathogen/foundation/norovirus,
		/datum/pathogen/foundation/strep_throat,
		/datum/pathogen/foundation/hepatitis_c,
		/datum/pathogen/foundation/mrsa,
		/datum/pathogen/foundation/pneumonia,
		/datum/pathogen/foundation/malaria,
		/datum/pathogen/foundation/dengue,
	)
	pathogen_type = pick(options)
	return ..()
