

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!

// Roundstart roles
#define ROLE_BROTHER "Blood Brother"
#define ROLE_CHANGELING "Changeling"
#define ROLE_CULTIST "Cultist"
#define ROLE_FAMILIES "Gangster"
#define ROLE_FLOCK "Flock"
#define ROLE_HERETIC "Heretic"
#define ROLE_MALF "Malf AI"
#define ROLE_OPERATIVE "Operative"
#define ROLE_THIEF "Thief"
#define ROLE_TRAITOR "Traitor"
#define ROLE_VAMPIRE "Vampire"
#define ROLE_WIZARD "Wizard"

// Midround roles
#define ROLE_ABDUCTOR "Abductor"
#define ROLE_ALIEN "Xenomorph"
#define ROLE_BLOB "Blob"
#define ROLE_BLOB_INFECTION "Blob Infection"
#define ROLE_FAMILY_HEAD_ASPIRANT "Family Head Aspirant"
#define ROLE_FUGITIVE "Fugitive"
#define ROLE_LONE_OPERATIVE "Lone Operative"
#define ROLE_MALF_MIDROUND "Malf AI (Midround)"
#define ROLE_NIGHTMARE "Nightmare"
#define ROLE_NINJA "Space Ninja"
#define ROLE_OBSESSED "Obsessed"
#define ROLE_OPERATIVE_MIDROUND "Operative (Midround)"
#define ROLE_OPPORTUNIST "Opportunist"
#define ROLE_REV_HEAD "Head Revolutionary"
#define ROLE_SENTIENT_DISEASE "Sentient Disease"
#define ROLE_SLEEPER_AGENT "Syndicate Sleeper Agent"
#define ROLE_SPACE_DRAGON "Space Dragon"
#define ROLE_SPIDER "Spider"
#define ROLE_WIZARD_MIDROUND "Wizard (Midround)"
#define ROLE_DRIFTING_CONTRACTOR "Drifting Contractor"

// Latejoin roles
#define ROLE_HERETIC_SMUGGLER "Heretic Smuggler"
#define ROLE_PROVOCATEUR "Provocateur"
#define ROLE_SYNDICATE_INFILTRATOR "Syndicate Infiltrator"

// Other roles
#define ROLE_SYNDICATE "Syndicate"
#define ROLE_REV "Revolutionary"
#define ROLE_REV_SUCCESSFUL "Victorious Revolutionary"
#define ROLE_PAI "pAI"
#define ROLE_MONKEY_HELMET "Monkey Mind Magnification Helmet"
#define ROLE_REVENANT "Revenant"
#define ROLE_BRAINWASHED "Brainwashed Victim"
#define ROLE_HYPNOTIZED "Hypnotized Victim"
#define ROLE_OVERTHROW "Syndicate Mutineer" //Role removed, left here for safety.
#define ROLE_HIVE "Hivemind Host" //Role removed, left here for safety.
#define ROLE_SENTIENCE "Sentience Potion Spawn"
#define ROLE_PYROCLASTIC_SLIME "Pyroclastic Anomaly Slime"
#define ROLE_MIND_TRANSFER "Mind Transfer Potion"
#define ROLE_POSIBRAIN "Posibrain"
#define ROLE_DRONE "Drone"
#define ROLE_DEATHSQUAD "Deathsquad"
#define ROLE_POSITRONIC_BRAIN "Positronic Brain"
#define ROLE_FREE_GOLEM "Free Golem"
#define ROLE_SERVANT_GOLEM "Servant Golem"
#define ROLE_NUCLEAR_OPERATIVE "Nuclear Operative"
#define ROLE_CLOWN_OPERATIVE "Clown Operative"
#define ROLE_WIZARD_APPRENTICE "apprentice"
#define ROLE_SLAUGHTER_DEMON "Slaughter Demon"
#define ROLE_MORPH "Morph"
#define ROLE_SANTA "Santa"

//Spawner roles
#define ROLE_GHOST_ROLE "Ghost Role"
#define ROLE_EXILE "Exile"
#define ROLE_FUGITIVE_HUNTER "Fugitive Hunter"
#define ROLE_ESCAPED_PRISONER "Escaped Prisoner"
#define ROLE_LIFEBRINGER "Lifebringer"
#define ROLE_ASHWALKER "Ash Walker"
#define ROLE_HERMIT "Hermit"
#define ROLE_BEACH_BUM "Beach Bum"
#define ROLE_HOTEL_STAFF "Hotel Staff"
#define ROLE_SPACE_SYNDICATE "Space Syndicate"
#define ROLE_SYNDICATE_CYBERSUN "Cybersun Space Syndicate" //Ghost role syndi from Forgottenship ruin
#define ROLE_SYNDICATE_CYBERSUN_CAPTAIN "Cybersun Space Syndicate Captain" //Forgottenship captain syndie
#define ROLE_HEADSLUG_CHANGELING "Headslug Changeling"
#define ROLE_ANCIENT_CREW "Ancient Crew"
#define ROLE_SPACE_DOCTOR "Space Doctor"
#define ROLE_SPACE_BARTENDER "Space Bartender"
#define ROLE_SPACE_BAR_PATRON "Space Bar Patron"
#define ROLE_SKELETON "Skeleton"
#define ROLE_ZOMBIE "Zombie"
#define ROLE_MAINTENANCE_DRONE "Maintenance Drone"
#define ROLE_BATTLECRUISER_CREW "Battlecruiser Crew"
#define ROLE_BATTLECRUISER_CAPTAIN "Battlecruiser Captain"

// SCP and Hostile Group roles
#define ROLE_SCP173 "SCP-173"
#define ROLE_SCP096 "SCP-096"
#define ROLE_SCP008 "SCP-008 Infection"
#define ROLE_SCP035 "SCP-035"
#define ROLE_SCP049 "SCP-049"
#define ROLE_SCP2427_3 "SCP-2427-3"
#define ROLE_SCP079 "SCP-079"
#define ROLE_SCP106 "SCP-106"
#define ROLE_SCP457 "SCP-457"
#define ROLE_SCP939 "SCP-939"
#define ROLE_SCP682 "SCP-682"
#define ROLE_SCP610 "SCP-610"
#define ROLE_SARKIC_CULT "Sarkic Cultist"
#define ROLE_CHAOS_INSURGENCY "Chaos Insurgency Agent"
#define ROLE_SERPENTS_HAND "Serpent's Hand Member"
#define ROLE_MTF "Mobile Task Force"


/// This defines the antagonists you can operate with in the settings.
/// Keys are the antagonist, values are the number of days since the player's
/// first connection in order to play.
GLOBAL_LIST_INIT(special_roles, list(
	// Roundstart
	ROLE_BROTHER = 0,
	ROLE_CHANGELING = 0,
	ROLE_CLOWN_OPERATIVE = 14,
	ROLE_CULTIST = 14,
	ROLE_FAMILIES = 0,
	ROLE_HERETIC = 0,
	ROLE_MALF = 0,
	ROLE_OPERATIVE = 14,
	ROLE_REV_HEAD = 14,
	ROLE_THIEF = 0,
	ROLE_TRAITOR = 0,
	ROLE_WIZARD = 14,
	ROLE_VAMPIRE = 0,

	// Midround
	ROLE_ABDUCTOR = 0,
	ROLE_ALIEN = 0,
	ROLE_BLOB = 0,
	ROLE_BLOB_INFECTION = 0,
	ROLE_FAMILY_HEAD_ASPIRANT = 0,
	ROLE_FUGITIVE = 0,
	ROLE_LONE_OPERATIVE = 14,
	ROLE_MALF_MIDROUND = 0,
	ROLE_NIGHTMARE = 0,
	ROLE_NINJA = 0,
	ROLE_OBSESSED = 0,
	ROLE_OPERATIVE_MIDROUND = 14,
	ROLE_OPPORTUNIST = 0,
	ROLE_REVENANT = 0,
	ROLE_SENTIENT_DISEASE = 0,
	ROLE_SLEEPER_AGENT = 0,
	ROLE_SPACE_DRAGON = 0,
	ROLE_SPIDER = 0,
	ROLE_WIZARD_MIDROUND = 14,
	ROLE_DRIFTING_CONTRACTOR = 14,

	// Latejoin
	ROLE_HERETIC_SMUGGLER = 0,
	ROLE_PROVOCATEUR = 14,
	ROLE_SYNDICATE_INFILTRATOR = 0,

	// SCP and Hostile Groups
	ROLE_SCP173 = 0,
	ROLE_SCP096 = 0,
	ROLE_SCP008 = 0,
	ROLE_SCP035 = 0,
	ROLE_SCP049 = 0,
	ROLE_SCP2427_3 = 0,
	ROLE_SCP079 = 0,
	ROLE_SCP106 = 0,
	ROLE_SCP457 = 0,
	ROLE_SCP939 = 0,
	ROLE_SCP682 = 0,
	ROLE_SARKIC_CULT = 0,
	ROLE_CHAOS_INSURGENCY = 0,
	ROLE_SERPENTS_HAND = 0,

	// I'm not too sure why these are here, but they're not moving.
	ROLE_PAI = 0,
	ROLE_SENTIENCE = 0,
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW "Join as Assistant"
#define BERANDOMJOB "Join as Random"
#define RETURNTOLOBBY "Return to Lobby"
