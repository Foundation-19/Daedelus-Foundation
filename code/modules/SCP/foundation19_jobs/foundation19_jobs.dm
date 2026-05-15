// Foundation-19 Job Constants and Defines
// Only defines that don't already exist in code/__DEFINES/jobs.dm are defined here
// Duplicate defines are guarded with #ifndef

// Class Levels
#define CLASS_A 1
#define CLASS_B 2
#define CLASS_C 3
#define CLASS_D 4
#define CLASS_E 5

// Experience Types (SCP-specific)
#define EXP_TYPE_LCZ "LCZ"
#define EXP_TYPE_HCZ "HCZ"
#define EXP_TYPE_EZ "EZ"
#ifndef EXP_TYPE_SECURITY
#define EXP_TYPE_SECURITY "Security"
#define EXP_TYPE_MEDICAL "Medical"
#define EXP_TYPE_SCIENCE "Science"
#define EXP_TYPE_ENGINEERING "Engineering"
#define EXP_TYPE_SUPPLY "Supply"
#define EXP_TYPE_SERVICE "Service"
#endif
#define EXP_TYPE_DCLASS "D-Class"

// Skill Levels
#define SKILL_NONE 0
#define SKILL_BASIC 1
#define SKILL_ADEPT 2
#define SKILL_EXPERT 3
#define SKILL_MASTER 4

// Skill Types
#define SKILL_COMBAT "Combat"
#define SKILL_MEDICAL "Medical"
#define SKILL_ENGINEERING "Engineering"
#define SKILL_SCIENCE "Science"
#define SKILL_SECURITY "Security"
#define SKILL_SERVICE "Service"

// Department Flags (SCP-specific, used by job_hooks and progression)
#define DEPT_FLAG_COMMAND (1<<0)
#define DEPT_FLAG_SECURITY (1<<1)
#define DEPT_FLAG_MEDICAL (1<<2)
#define DEPT_FLAG_SCIENCE (1<<3)
#define DEPT_FLAG_ENGINEERING (1<<4)
#define DEPT_FLAG_SUPPLY (1<<5)
#define DEPT_FLAG_SERVICE (1<<6)
#define DEPT_FLAG_LCZ (1<<7)
#define DEPT_FLAG_HCZ (1<<8)
#define DEPT_FLAG_EZ (1<<9)

// Job Categories
#define JOB_CATEGORY_COMMAND "Command"
#define JOB_CATEGORY_SECURITY "Security"
#define JOB_CATEGORY_MEDICAL "Medical"
#define JOB_CATEGORY_SCIENCE "Science"
#define JOB_CATEGORY_ENGINEERING "Engineering"
#define JOB_CATEGORY_SUPPLY "Supply"
#define JOB_CATEGORY_SERVICE "Service"
#define JOB_CATEGORY_CIVILIAN "Civilian"
#define JOB_CATEGORY_SILICON "Silicon"
#define JOB_CATEGORY_DCLASS "D-Class"

// Roleplay Difficulty
#define ROLEPLAY_DIFFICULTY_EASY 1
#define ROLEPLAY_DIFFICULTY_MEDIUM 2
#define ROLEPLAY_DIFFICULTY_HARD 3

// Mechanical Difficulty
#define MECHANICAL_DIFFICULTY_EASY 1
#define MECHANICAL_DIFFICULTY_MEDIUM 2
#define MECHANICAL_DIFFICULTY_HARD 3

// Foundation-19 Job Title Constants
// Guarded with #ifndef to avoid redefinition warnings from __DEFINES/jobs.dm
#ifndef JOB_SITE_DIRECTOR
#define JOB_SITE_DIRECTOR "Site Director"
#endif
#ifndef JOB_RESEARCH_DIRECTOR
#define JOB_RESEARCH_DIRECTOR "Research Director"
#endif
#ifndef JOB_MEDICAL_DIRECTOR
#define JOB_MEDICAL_DIRECTOR "Medical Director"
#endif
#ifndef JOB_ENGINEERING_DIRECTOR
#define JOB_ENGINEERING_DIRECTOR "Engineering Director"
#endif
#ifndef JOB_SENIOR_RESEARCHER
#define JOB_SENIOR_RESEARCHER "Senior Researcher"
#endif
#ifndef JOB_RESEARCHER
#define JOB_RESEARCHER "Researcher"
#endif
#ifndef JOB_JUNIOR_RESEARCHER
#define JOB_JUNIOR_RESEARCHER "Junior Researcher"
#endif
#ifndef JOB_MEDICAL_DOCTOR
#define JOB_MEDICAL_DOCTOR "Medical Doctor"
#endif
#ifndef JOB_SURGEON
#define JOB_SURGEON "Surgeon"
#endif
#ifndef JOB_PARAMEDIC
#define JOB_PARAMEDIC "Paramedic"
#endif
#ifndef JOB_CHEMIST
#define JOB_CHEMIST "Chemist"
#endif
#ifndef JOB_VIROLOGIST
#define JOB_VIROLOGIST "Virologist"
#endif
#ifndef JOB_CONTAINMENT_ENGINEER
#define JOB_CONTAINMENT_ENGINEER "Containment Engineer"
#endif
#ifndef JOB_SENIOR_ENGINEER
#define JOB_SENIOR_ENGINEER "Senior Engineer"
#endif
#ifndef JOB_ENGINEER
#define JOB_ENGINEER "Engineer"
#endif
#ifndef JOB_JUNIOR_ENGINEER
#define JOB_JUNIOR_ENGINEER "Junior Engineer"
#endif
#ifndef JOB_ATMOSPHERIC_TECHNICIAN
#define JOB_ATMOSPHERIC_TECHNICIAN "Atmospheric Technician"
#endif
#ifndef JOB_LOGISTICS_OFFICER
#define JOB_LOGISTICS_OFFICER "Logistics Officer"
#endif
#ifndef JOB_BOTANIST
#define JOB_BOTANIST "Botanist"
#endif
#ifndef JOB_COOK
#define JOB_COOK "Cook"
#endif
#ifndef JOB_BARTENDER
#define JOB_BARTENDER "Bartender"
#endif
#ifndef JOB_JANITOR
#define JOB_JANITOR "Janitor"
#endif
#ifndef JOB_CHAPLAIN
#define JOB_CHAPLAIN "Chaplain"
#endif
#ifndef JOB_LCZ_GUARD
#define JOB_LCZ_GUARD "LCZ Guard"
#endif
#ifndef JOB_HCZ_GUARD
#define JOB_HCZ_GUARD "HCZ Guard"
#endif
#ifndef JOB_EZ_GUARD
#define JOB_EZ_GUARD "EZ Guard"
#endif

// SCP-specific job defines (not in __DEFINES/jobs.dm)
#define JOB_O5_REPRESENTATIVE "O5 Representative"
#ifndef JOB_GUARD_COMMANDER
#define JOB_GUARD_COMMANDER "Guard Commander"
#endif
#define JOB_LCZ_ZONE_COMMANDER "LCZ Zone Junior Lieutenant"
#define JOB_HCZ_ZONE_COMMANDER "HCZ Zone Senior Lieutenant"
#define JOB_EZ_ZONE_COMMANDER "EZ Zone Supervisor"
#define JOB_MTF_COMMANDER "MTF Commander"
#define JOB_MTF_OPERATIVE "MTF Operative"
#define JOB_RESEARCH_ASSOCIATE "Research Associate"
#define JOB_LAB_TECHNICIAN "Lab Technician"
#define JOB_XENOBIOLOGIST "Xenobiologist"
#define JOB_ROBOTICIST "Roboticist"
#define JOB_CHEMIST_SCIENCE "Chemist (Science)"
#define JOB_ARCHAEOLOGIST "Archaeologist"
#define JOB_FIELD_AGENT "Field Agent"
#define JOB_ELECTRICAL_ENGINEER "Electrical Engineer"
#define JOB_COMMUNICATIONS_TECHNICIAN "Communications Technician"
#define JOB_MAINTENANCE_TECHNICIAN "Maintenance Technician"
#define JOB_QUARTERMASTER "Quartermaster"
#define JOB_CARGO_TECHNICIAN "Cargo Technician"
#define JOB_SHAFT_MINER "Shaft Miner"
#define JOB_SUPPLY_SPECIALIST "Supply Specialist"
#define JOB_CURATOR "Curator"
#define JOB_LAWYER "Lawyer"
#define JOB_PSYCHIATRIST "Psychiatrist"
#define JOB_MEDICAL_INTERN "Medical Intern"
#define JOB_CORONER "Coroner"

// D-Class job variants
#define JOB_DCLASS_GENERAL "D-Class Personnel"
#define JOB_DCLASS_MEDICAL "D-Class Medical"
#define JOB_DCLASS_KITCHEN "D-Class Kitchen"
#define JOB_DCLASS_JANITORIAL "D-Class Janitorial"
#define JOB_DCLASS_MINING "D-Class Mining"
#define JOB_DCLASS_RESEARCH "D-Class Research"
