
#define PATHOGEN_LIMIT 1
#define VIRUS_SYMPTOM_LIMIT 6

//Visibility Flags
#define HIDDEN_SCANNER (1<<0)
#define HIDDEN_PANDEMIC (1<<1)

//Disease Flags
/// If present, the disease can be cured either randomly over time or reagents.
#define PATHOGEN_CURABLE (1<<0)
/// If present, when the disease is cured, it will be added to the mob's resistances.
#define PATHOGEN_RESIST_ON_CURE (1<<2)
/// If present, an affected mob will need every reagent in the cure list to be cured.
#define PATHOGEN_NEED_ALL_CURES (1<<3)
/// A disease will need to regress to stage 1 to cure itself
#define PATHOGEN_REGRESS_TO_CURE (1<<4)

//Disease Spread Flags
#define PATHOGEN_SPREAD_SPECIAL (1<<0)
#define PATHOGEN_SPREAD_NON_CONTAGIOUS (1<<1)
#define PATHOGEN_SPREAD_BLOOD (1<<2)
#define PATHOGEN_SPREAD_CONTACT_FLUIDS (1<<3)
#define PATHOGEN_SPREAD_CONTACT_SKIN (1<<4)
#define PATHOGEN_SPREAD_AIRBORNE (1<<5)

//Disease properties
#define PATHOGEN_PROP_RESISTANCE "resistance"
#define PATHOGEN_PROP_STEALTH "stealth"
#define PATHOGEN_PROP_STAGE_RATE "stage_rate"
#define PATHOGEN_PROP_TRANSMITTABLE "transmittable"
#define PATHOGEN_PROP_SEVERITY "severity"

//Severity Defines
/// Diseases that buff, heal, or at least do nothing at all
#define PATHOGEN_SEVERITY_POSITIVE "Positive"
/// Diseases that may have annoying effects, but nothing disruptive (sneezing)
#define PATHOGEN_SEVERITY_NONTHREAT "Harmless"
/// Diseases that can annoy in concrete ways (dizziness)
#define PATHOGEN_SEVERITY_MINOR "Minor"
/// Diseases that can do minor harm, or severe annoyance (vomit)
#define PATHOGEN_SEVERITY_MEDIUM "Medium"
/// Diseases that can do significant harm, or severe disruption (brainrot)
#define PATHOGEN_SEVERITY_HARMFUL "Harmful"
/// Diseases that can kill or maim if left untreated (flesh eating, blindness)
#define PATHOGEN_SEVERITY_DANGEROUS "Dangerous"
/// Diseases that can quickly kill an unprepared victim (fungal tb, gbs)
#define PATHOGEN_SEVERITY_BIOHAZARD "BIOHAZARD"
/// Anomalous existential threat - Keter-class pathogens
#define PATHOGEN_SEVERITY_ANOMALOUS "ANOMALOUS"

//Biosafety Level Defines
/// BSL-1: Non-anomalous, routine handling. No special containment.
#define BSL_1 "BSL-1"
/// BSL-2: Anomalous but containable. Standard lab practices.
#define BSL_2 "BSL-2"
/// BSL-3: Dangerous anomalous. Requires containment suits, negative pressure.
#define BSL_3 "BSL-3"
/// BSL-4: Existential threat. Full suit, double-door decon, isolated systems.
#define BSL_4 "BSL-4"

//Transmission Type Defines
/// Spreads through HVAC and air systems
#define PATHOGEN_TRANSMISSION_AIRBORNE "airborne"
/// Spreads through blood and bodily fluids
#define PATHOGEN_TRANSMISSION_BLOOD "bloodborne"
/// Spreads through surface contact
#define PATHOGEN_TRANSMISSION_CONTACT "contact"
/// Spreads through animal/insect vectors
#define PATHOGEN_TRANSMISSION_VECTOR "vector"
/// Spreads through water/plumbing systems
#define PATHOGEN_TRANSMISSION_WATER "waterborne"
/// Spreads through food/kitchen
#define PATHOGEN_TRANSMISSION_FOOD "foodborne"
/// Anomalous transmission - memetic, dimensional, or reality-based
#define PATHOGEN_TRANSMISSION_ANOMALOUS "anomalous"

//Pathogen Research Stage Defines
/// Initial identification only
#define RESEARCH_STAGE_IDENTIFIED 1
/// Basic properties catalogued
#define RESEARCH_STAGE_CATALOGUED 2
/// Transmission vectors mapped
#define RESEARCH_STAGE_MAPPED 3
/// Countermeasures in development
#define RESEARCH_STAGE_COUNTERMEASURE 4
/// Cure/treatment developed
#define RESEARCH_STAGE_CURED 5
