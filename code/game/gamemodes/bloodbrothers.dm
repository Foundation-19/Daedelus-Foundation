///What percentage of the crew can become bros :flooshed:.
#define BROTHER_SCALING_COEFF 0.15
//The minimum amount of people in a blood brothers team. Set this below 2 and you're stupid.
#define BROTHER_MINIMUM_TEAM_SIZE 2

/datum/game_mode/brothers
	name = "Blood Brothers"

	weight = GAMEMODE_WEIGHT_NEVER
	required_enemies = BROTHER_MINIMUM_TEAM_SIZE

	var/list/datum/team/brother_team/pre_brother_teams = list()
