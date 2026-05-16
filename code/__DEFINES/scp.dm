// Classifcations

#define SCP_SAFE		"Safe"
#define SCP_EUCLID		"Euclid"
#define SCP_KETER 		"Keter"
#define SCP_THAUMIEL	"Thaumiel"
#define SCP_NEUTRALIZED "Neutralized"

//Meta bitflags

///Is the SCP playable?
#define SCP_PLAYABLE 		(1<<0)
///Is it a roleplay oriented SCP?
#define SCP_ROLEPLAY		(1<<1)
///Does the scp have memetic properties?
#define SCP_MEMETIC			(1<<2)
///Is this SCP disabled and should be prevented from spawning?
#define SCP_DISABLED 		(1<<3)
///Is this SCP sentient (has consciousness)?
#define SCP_SENTIENT		(1<<4)

//Memetic bitflags

///Do memetics take affect when the atom is seen?
#define MVISUAL				(1<<0)
///Do memetics take affect when the atom is heard?
#define MAUDIBLE			(1<<1)
///Do memetics take affect when the atom is inspected?
#define MINSPECT			(1<<2)
///Should memetics take affect through cameras?
#define MCAMERA				(1<<3)
///Should memetics take affect through photos?
#define MPHOTO				(1<<4)
///Is the individual still affected after they no longer meet the memetic requirements? Only use if the MSYNCED flag is used.
#define MPERSISTENT			(1<<5)
///Is the scp memetic effect synced? If this flag is enabled the memetic comp's active_memetic_effect() must be called to enact the memetic effect.
#define MSYNCED				(1<<6)

// Component System Event Types
#define COMPONENT_EVENT_TICK "tick"
#define COMPONENT_EVENT_INTERACT "interact"
#define COMPONENT_EVENT_BREACH "breach"
#define COMPONENT_EVENT_DAMAGE "damage"
#define COMPONENT_EVENT_HEAL "heal"
#define COMPONENT_EVENT_DEATH "death"
#define COMPONENT_EVENT_SPAWN "spawn"
#define COMPONENT_EVENT_DESPAWN "despawn"
#define COMPONENT_EVENT_CONTAIN "contain"
#define COMPONENT_EVENT_SKILL_USE "skill_use"
#define COMPONENT_EVENT_ACTIVATE "activate"
#define COMPONENT_EVENT_DEACTIVATE "deactivate"
#define COMPONENT_EVENT_REVIVE "revive"

// Pestilence System
#define TRAIT_PESTILENCE "pestilence"
#define TRAIT_PESTILENCE_IMMUNE "pestilence_immune"
#define DATA_HUD_PESTILENCE "pestilence_hud"
