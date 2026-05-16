#define MIXED_WEIGHT_TRAITOR 100
#define MIXED_WEIGHT_CHANGELING 0
#define MIXED_WEIGHT_HERETIC 20
#define MIXED_WEIGHT_WIZARD 1

///What percentage of the pop can become antags
#define MIXED_ANTAG_COEFF 0.15

/datum/game_mode/mixed
	name = "Mixed"
	weight = GAMEMODE_WEIGHT_NEVER
	force_pre_setup_check = TRUE

	///The antagonist selectors for this gamemode.
	var/datum/antagonist_selector/traitor/traitor_selector
	var/datum/antagonist_selector/changeling/changeling_selector
	var/datum/antagonist_selector/heretic/heretic_selector
	var/datum/antagonist_selector/wizard/wizard_selector

	var/list/antag_weight_map = list(
		ROLE_TRAITOR = MIXED_WEIGHT_TRAITOR,
		ROLE_CHANGELING = MIXED_WEIGHT_CHANGELING,
		ROLE_HERETIC = MIXED_WEIGHT_HERETIC,
		ROLE_WIZARD = MIXED_WEIGHT_WIZARD
	)

/datum/game_mode/mixed/pre_setup()
	. = ..()

	var/list/antag_pool = list()
	var/number_of_antags = max(1, round(length(SSticker.ready_players) * MIXED_ANTAG_COEFF))

	//Setup a list of antags to try to spawn
	while(number_of_antags)
		antag_pool[pick_weight(antag_weight_map)] += 1
		number_of_antags--

	if(antag_pool[ROLE_TRAITOR])
		traitor_selector = new /datum/antagonist_selector/traitor()
		traitor_selector.setup(antag_pool[ROLE_TRAITOR], possible_antags)

	if(antag_pool[ROLE_CHANGELING])
		changeling_selector = new /datum/antagonist_selector/changeling()
		changeling_selector.setup(antag_pool[ROLE_CHANGELING], possible_antags)

	if(antag_pool[ROLE_HERETIC])
		heretic_selector = new /datum/antagonist_selector/heretic()
		heretic_selector.setup(antag_pool[ROLE_HERETIC], possible_antags)

	if(length(GLOB.wizardstart) && antag_pool[ROLE_WIZARD])
		wizard_selector = new /datum/antagonist_selector/wizard()
		wizard_selector.setup(antag_pool[ROLE_WIZARD], possible_antags)

/datum/game_mode/mixed/post_setup()
	. = ..()
	if(traitor_selector)
		traitor_selector.give_antag_datums(src)
	if(changeling_selector)
		changeling_selector.give_antag_datums(src)
	if(heretic_selector)
		heretic_selector.give_antag_datums(src)
	if(wizard_selector)
		wizard_selector.give_antag_datums(src)
