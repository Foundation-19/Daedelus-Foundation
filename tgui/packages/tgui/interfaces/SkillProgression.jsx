import { useBackend, useLocalState } from '../backend';
import { Box, Button, NoticeBox } from '../components';
import { Window } from '../layouts';

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  accent: '#c2960e',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenDim: '#0d4a0d',
  text: '#b0b0b0',
  textBright: '#e0e0e0',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const term = (overrides = {}) => ({
  fontFamily: C.mono,
  fontSize: '12px',
  color: C.text,
  ...overrides,
});

const TermHeader = (props) => (
  <Box
    style={term({
      fontSize: '10px',
      color: C.textDim,
      letterSpacing: '0.18em',
      textTransform: 'uppercase',
      borderBottom: `1px solid ${C.border}`,
      paddingBottom: '4px',
      marginBottom: '8px',
      ...props.style,
    })}
  >
    {props.children}
  </Box>
);

const TermLabel = (props) => (
  <Box
    as="span"
    style={term({
      color: C.textDim,
      fontSize: '10px',
      letterSpacing: '0.12em',
      textTransform: 'uppercase',
      marginRight: '8px',
    })}
  >
    {props.children}
  </Box>
);

const TermValue = (props) => (
  <Box
    as="span"
    style={term({
      color: props.color || C.textBright,
      fontWeight: props.bold ? 'bold' : undefined,
    })}
  >
    {props.children}
  </Box>
);

const TermRow = (props) => (
  <Box style={{ marginBottom: '6px', display: 'flex', alignItems: 'center' }}>
    {props.children}
  </Box>
);

const TermDivider = () => (
  <Box
    style={{
      color: C.borderRed,
      fontSize: '10px',
      letterSpacing: '0.3em',
      margin: '10px 0',
      userSelect: 'none',
      overflow: 'hidden',
      whiteSpace: 'nowrap',
    }}
  >
    {'─'.repeat(80)}
  </Box>
);

const TermButton = (props) => {
  const selected = props.selected;
  const color = props.color;
  const bg = selected
    ? color === 'red'
      ? 'rgba(139,0,0,0.35)'
      : color === 'green'
        ? 'rgba(26,122,26,0.35)'
        : color === 'yellow'
          ? 'rgba(180,160,20,0.25)'
          : 'rgba(255,255,255,0.08)'
    : 'transparent';
  const borderColor = selected
    ? color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border
    : C.border;

  return (
    <Button
      {...props}
      style={{
        fontFamily: C.mono,
        fontSize: '10px',
        letterSpacing: '0.1em',
        textTransform: 'uppercase',
        background: bg,
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color: selected ? C.textBright : C.textDim,
        padding: '3px 8px',
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    >
      {props.children}
    </Button>
  );
};

const TermProgressBar = (props) => (
  <Box style={{ marginBottom: '6px' }}>
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        marginBottom: '2px',
      }}
    >
      <TermLabel>{props.label}</TermLabel>
      <TermValue color={props.color || C.amber}>
        {props.value}
        {props.suffix || ''}
      </TermValue>
    </Box>
    <Box
      style={{
        height: '6px',
        background: C.panel,
        border: `1px solid ${C.border}`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          height: '100%',
          width: `${Math.min(100, Math.max(0, (props.value / props.maxValue) * 100))}%`,
          background: props.color || C.amber,
          transition: 'width 0.3s',
        }}
      />
    </Box>
  </Box>
);

const getSkillExpForLevel = (level) => {
  const expList = [0, 100, 250, 500, 900, 1500, 2500];
  return expList[level] || 2500;
};

const getSkillLevelColor = (level) => {
  if (level >= 7) return '#aa44ff';
  if (level >= 6) return C.redBright;
  if (level >= 5) return '#ff8800';
  if (level >= 4) return C.amber;
  if (level >= 3) return C.green;
  if (level >= 2) return '#4488ff';
  return C.textDim;
};

const getSkillBasedRankRequirements = () => ({
  1: { total_skill_levels: 10 },
  2: { total_skill_levels: 25, expert_skills: 1 },
  3: { total_skill_levels: 50, expert_skills: 2, master_skills: 1 },
  4: { total_skill_levels: 100, expert_skills: 3, master_skills: 2 },
  5: {
    total_skill_levels: 200,
    expert_skills: 5,
    master_skills: 3,
    legendary_skills: 1,
  },
});

const calculatePlayerSkillStats = (skillSummary) => {
  const stats = {
    total_skill_levels: 0,
    expert_skills: 0,
    master_skills: 0,
    legendary_skills: 0,
  };
  Object.values(skillSummary || {}).forEach((skill) => {
    stats.total_skill_levels += skill.level;
    if (skill.level >= 5) stats.expert_skills++;
    if (skill.level >= 6) stats.master_skills++;
    if (skill.level >= 7) stats.legendary_skills++;
  });
  return stats;
};

const formatRequirementName = (requirement) => {
  const names = {
    total_skill_levels: 'Total Skill Levels',
    expert_skills: 'Expert Skills',
    master_skills: 'Master Skills',
    legendary_skills: 'Legendary Skills',
  };
  return names[requirement] || requirement;
};

const getClassSkillBoosts = (className) => {
  const boosts = {
    security: [
      ['Combat', 1.5],
      ['Security', 1.5],
      ['Melee', 1.5],
      ['Firearms', 1.5],
    ],
    engineering: [
      ['Engineering', 1.5],
      ['Construction', 1.5],
      ['Electrical', 1.5],
      ['Atmospherics', 1.5],
    ],
    medical: [
      ['Medical', 1.5],
      ['Surgery', 1.5],
      ['Chemistry', 1.5],
    ],
    research: [
      ['Science', 1.5],
      ['Plasmatech', 1.5],
      ['Robotics', 1.5],
    ],
    containment: [
      ['Containment', 1.5],
      ['Security', 1.3],
      ['Combat', 1.3],
    ],
  };
  return boosts[className] || [];
};

const getMilestoneReward = (level) => {
  const rewards = { 2: 10, 3: 25, 4: 50, 5: 100, 6: 250, 7: 500 };
  return rewards[level] || 0;
};

const getClassSkillStats = (skillData) => {
  const classStats = {};
  skillData.forEach((skill) => {
    const className = skill.progression_class;
    if (!classStats[className])
      classStats[className] = { count: 0, total: 0, highest: 0 };
    classStats[className].count++;
    classStats[className].total += skill.level;
    classStats[className].highest = Math.max(
      classStats[className].highest,
      skill.level,
    );
  });
  return Object.entries(classStats).map(([className, stats]) => [
    className,
    {
      count: stats.count,
      average: stats.total / stats.count,
      highest: stats.highest,
    },
  ]);
};

const SkillOverview = (props) => {
  const {
    player_name,
    current_class,
    current_faction,
    current_rank,
    current_rank_level,
    total_experience,
    rounds_played,
    progress_to_next,
    exp_needed,
    skill_summary,
    performance_metrics,
  } = props;

  const total_skill_levels = performance_metrics?.total_skill_levels || 0;
  const highest_skill_level = performance_metrics?.highest_skill_level || 0;
  const skill_count = performance_metrics?.skill_count || 0;
  const average_skill_level = performance_metrics?.average_skill_level || 0;

  return (
    <Box>
      <TermHeader>PERSONNEL IDENTIFICATION</TermHeader>
      <TermRow>
        <TermLabel>DESIGNATION</TermLabel>
        <TermValue color={C.amber} bold>
          {player_name}
        </TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>CLASS</TermLabel>
        <TermValue>{current_class}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>FACTION</TermLabel>
        <TermValue>{current_faction}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>RANK</TermLabel>
        <TermValue color={C.green}>
          {current_rank} (LEVEL {current_rank_level})
        </TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>TOTAL XP</TermLabel>
        <TermValue color={C.amber}>
          {total_experience?.toLocaleString() || 0}
        </TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>ROUNDS</TermLabel>
        <TermValue>{rounds_played}</TermValue>
      </TermRow>

      <TermDivider />

      <TermHeader>RANK PROGRESSION</TermHeader>
      <TermProgressBar
        label="PROGRESS"
        value={progress_to_next}
        maxValue={100}
        color={progress_to_next >= 100 ? C.green : C.amber}
        suffix="%"
      />
      {exp_needed > 0 && (
        <Box style={term({ color: C.textDim, fontSize: '10px' })}>
          {exp_needed.toLocaleString()} XP REQUIRED
        </Box>
      )}

      <TermDivider />

      <TermHeader>SKILL STATISTICS</TermHeader>
      <TermRow>
        <TermLabel>TOTAL SKILL LEVELS</TermLabel>
        <TermValue>{total_skill_levels}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>HIGHEST SKILL</TermLabel>
        <TermValue color={getSkillLevelColor(highest_skill_level)}>
          {highest_skill_level}
        </TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>ACTIVE SKILLS</TermLabel>
        <TermValue>{skill_count}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>AVERAGE LEVEL</TermLabel>
        <TermValue>{average_skill_level.toFixed(1)}</TermValue>
      </TermRow>
    </Box>
  );
};

const SkillDetails = (props, context) => {
  const { skill_summary, skill_boosts, current_class, act } = props;
  const [skillFilter, setSkillFilter] = useLocalState(
    context,
    'skillFilter',
    'all',
  );

  const skillCategories = {
    all: 'All',
    security: 'Security',
    engineering: 'Engineering',
    medical: 'Medical',
    research: 'Research',
    service: 'Service',
    supply: 'Supply',
    administrative: 'Admin',
    containment: 'Containment',
  };

  const filteredSkills = Object.entries(skill_summary || {}).filter(
    ([_, skillData]) => {
      if (skillFilter === 'all') return true;
      return skillData.progression_class === skillFilter;
    },
  );

  return (
    <Box>
      <TermHeader>SKILL FILTER</TermHeader>
      <Box
        style={{
          display: 'flex',
          flexWrap: 'wrap',
          gap: '2px',
          marginBottom: '12px',
        }}
      >
        {Object.entries(skillCategories).map(([key, name]) => (
          <TermButton
            key={key}
            selected={skillFilter === key}
            onClick={() => setSkillFilter(key)}
          >
            {name}
          </TermButton>
        ))}
      </Box>

      <TermDivider />

      {filteredSkills.length === 0 ? (
        <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
          NO SKILLS MATCH FILTER
        </Box>
      ) : (
        filteredSkills.map(([skillType, skillData]) => {
          const levelColor = getSkillLevelColor(skillData.level);
          return (
            <Box
              key={skillType}
              style={{
                marginBottom: '6px',
                padding: '8px',
                borderLeft: `2px solid ${levelColor}`,
                background: C.panel,
              }}
            >
              <TermRow>
                <TermValue bold color={levelColor}>
                  {skillType.split('/').pop()}
                </TermValue>
                <TermLabel style={{ marginLeft: '8px' }}>
                  {skillData.progression_class}
                </TermLabel>
              </TermRow>
              <TermRow>
                <TermLabel>LEVEL</TermLabel>
                <TermValue color={levelColor}>
                  {skillData.level_name} ({skillData.level})
                </TermValue>
                <TermLabel style={{ marginLeft: '12px' }}>XP</TermLabel>
                <TermValue>{skillData.experience.toLocaleString()}</TermValue>
                {skillData.boost_multiplier > 1.0 && (
                  <>
                    <TermLabel style={{ marginLeft: '12px' }}>BOOST</TermLabel>
                    <TermValue color={C.green}>
                      +{((skillData.boost_multiplier - 1) * 100).toFixed(0)}%
                    </TermValue>
                  </>
                )}
              </TermRow>
              <TermProgressBar
                label="PROGRESS"
                value={skillData.experience}
                maxValue={getSkillExpForLevel(skillData.level + 1)}
                color={levelColor}
              />
            </Box>
          );
        })
      )}
    </Box>
  );
};

const ProgressionDetails = (props) => {
  const {
    current_class,
    current_rank,
    current_rank_level,
    total_experience,
    progress_to_next,
    exp_needed,
    skill_summary,
    act,
  } = props;
  const skillRequirements = getSkillBasedRankRequirements();
  const currentRequirements = skillRequirements[current_rank_level + 1] || {};
  const playerStats = calculatePlayerSkillStats(skill_summary);

  return (
    <Box>
      <TermHeader>CURRENT STATUS</TermHeader>
      <TermRow>
        <TermLabel>CLASS</TermLabel>
        <TermValue>{current_class}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>RANK</TermLabel>
        <TermValue color={C.green}>
          {current_rank} (LEVEL {current_rank_level})
        </TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>TOTAL XP</TermLabel>
        <TermValue color={C.amber}>
          {total_experience?.toLocaleString() || 0}
        </TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>PROGRESS</TermLabel>
        <TermValue color={progress_to_next >= 100 ? C.green : C.amber}>
          {progress_to_next}%
        </TermValue>
      </TermRow>

      <TermDivider />

      {Object.keys(currentRequirements).length > 0 && (
        <Box>
          <TermHeader>
            NEXT RANK REQUIREMENTS (RANK {current_rank_level + 1})
          </TermHeader>
          {Object.entries(currentRequirements).map(([requirement, value]) => {
            const current = playerStats[requirement] || 0;
            const met = current >= value;
            return (
              <Box key={requirement} style={{ marginBottom: '8px' }}>
                <TermRow>
                  <TermLabel>{formatRequirementName(requirement)}</TermLabel>
                  <TermValue color={met ? C.green : C.redBright}>
                    {current} / {value}
                  </TermValue>
                  {met && (
                    <TermValue color={C.green} style={{ marginLeft: '8px' }}>
                      [MET]
                    </TermValue>
                  )}
                </TermRow>
                <TermProgressBar
                  value={current}
                  maxValue={value}
                  color={met ? C.green : C.amber}
                />
              </Box>
            );
          })}
        </Box>
      )}

      <TermDivider />

      <TermHeader>
        CLASS SKILL BOOSTS — {current_class?.toUpperCase()}
      </TermHeader>
      {getClassSkillBoosts(current_class).map(([skill, boost]) => (
        <TermRow key={skill}>
          <TermLabel>{skill}</TermLabel>
          <TermValue color={C.green}>
            +{((boost - 1) * 100).toFixed(0)}%
          </TermValue>
        </TermRow>
      ))}
    </Box>
  );
};

const MilestoneTracker = (props) => {
  const { skill_milestones, skill_summary, act } = props;
  const milestoneLevels = [
    { level: 2, name: 'Novice' },
    { level: 3, name: 'Apprentice' },
    { level: 4, name: 'Journeyman' },
    { level: 5, name: 'Expert' },
    { level: 6, name: 'Master' },
    { level: 7, name: 'Legendary' },
  ];

  return (
    <Box>
      <TermHeader>SKILL MILESTONES</TermHeader>
      {milestoneLevels.map(({ level, name }) => {
        const levelColor = getSkillLevelColor(level);
        return (
          <Box key={level} style={{ marginBottom: '12px' }}>
            <TermHeader
              style={{ color: levelColor, borderBottomColor: levelColor }}
            >
              {name} MILESTONES
            </TermHeader>
            {Object.entries(skill_summary || {}).map(
              ([skillType, skillData]) => {
                const hasMilestone =
                  skill_milestones?.[skillType]?.includes(level);
                const canReach = skillData.level >= level;
                return (
                  <Box
                    key={skillType}
                    style={{
                      marginBottom: '4px',
                      padding: '6px 8px',
                      borderLeft: `2px solid ${hasMilestone ? C.green : canReach ? C.amber : C.border}`,
                      background: C.panel,
                    }}
                  >
                    <TermRow>
                      <TermValue bold>{skillType.split('/').pop()}</TermValue>
                      <TermLabel style={{ marginLeft: '8px' }}>LEVEL</TermLabel>
                      <TermValue color={getSkillLevelColor(skillData.level)}>
                        {skillData.level}
                      </TermValue>
                      <TermLabel style={{ marginLeft: '8px' }}>
                        STATUS
                      </TermLabel>
                      <TermValue
                        color={
                          hasMilestone
                            ? C.green
                            : canReach
                              ? C.amber
                              : C.textDim
                        }
                      >
                        {hasMilestone
                          ? 'ACHIEVED'
                          : canReach
                            ? 'UNCLAIMED'
                            : 'LOCKED'}
                      </TermValue>
                      {hasMilestone && (
                        <TermLabel style={{ marginLeft: '8px' }}>
                          REWARD
                        </TermLabel>
                      )}
                      {hasMilestone && (
                        <TermValue color={C.amber}>
                          +{getMilestoneReward(level)} XP
                        </TermValue>
                      )}
                    </TermRow>
                  </Box>
                );
              },
            )}
          </Box>
        );
      })}
    </Box>
  );
};

const SkillAnalytics = (props) => {
  const { skill_summary, performance_metrics, rounds_played, act } = props;
  const skillData = Object.values(skill_summary || {});
  const totalSkills = skillData.length;
  const activeSkills = skillData.filter((skill) => skill.level > 1).length;
  const averageLevel =
    totalSkills > 0
      ? skillData.reduce((sum, skill) => sum + skill.level, 0) / totalSkills
      : 0;

  return (
    <Box>
      <TermHeader>SKILL ANALYTICS</TermHeader>
      <TermRow>
        <TermLabel>TOTAL SKILLS</TermLabel>
        <TermValue>{totalSkills}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>ACTIVE SKILLS</TermLabel>
        <TermValue color={C.green}>{activeSkills}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>AVERAGE LEVEL</TermLabel>
        <TermValue>{averageLevel.toFixed(1)}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>HIGHEST LEVEL</TermLabel>
        <TermValue>{performance_metrics?.highest_skill_level || 0}</TermValue>
      </TermRow>
      <TermRow>
        <TermLabel>TOTAL LEVELS</TermLabel>
        <TermValue>{performance_metrics?.total_skill_levels || 0}</TermValue>
      </TermRow>

      <TermDivider />

      <TermHeader>SKILL DISTRIBUTION BY CLASS</TermHeader>
      {getClassSkillStats(skillData).map(([className, stats]) => (
        <Box
          key={className}
          style={{
            marginBottom: '6px',
            padding: '8px',
            borderLeft: `2px solid ${C.borderRed}`,
            background: C.panel,
          }}
        >
          <TermRow>
            <TermValue bold color={C.amber}>
              {className}
            </TermValue>
          </TermRow>
          <TermRow>
            <TermLabel>SKILLS</TermLabel>
            <TermValue>{stats.count}</TermValue>
            <TermLabel style={{ marginLeft: '12px' }}>AVG</TermLabel>
            <TermValue>{stats.average.toFixed(1)}</TermValue>
            <TermLabel style={{ marginLeft: '12px' }}>HIGHEST</TermLabel>
            <TermValue>{stats.highest}</TermValue>
          </TermRow>
        </Box>
      ))}
    </Box>
  );
};

export const SkillProgression = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = useLocalState(
    context,
    'activeTab',
    'overview',
  );

  const {
    has_data,
    player_name,
    player_key,
    current_class,
    current_faction,
    current_rank,
    current_rank_level,
    total_experience,
    rounds_played,
    progress_to_next,
    exp_needed,
    skill_summary,
    skill_milestones,
    performance_metrics,
    skill_boosts,
  } = data;

  if (!has_data) {
    return (
      <Window
        title="SCP FOUNDATION — SKILL PROGRESSION"
        width={1100}
        height={750}
        theme="scp_terminal"
      >
        <Window.Content scrollable>
          <Box
            style={{
              background: C.bg,
              border: `1px solid ${C.borderRed}`,
              fontFamily: C.mono,
              fontSize: '12px',
              color: C.text,
              minHeight: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <NoticeBox>NO PROGRESSION DATA AVAILABLE</NoticeBox>
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const TABS = [
    { key: 'overview', label: 'OVERVIEW' },
    { key: 'skills', label: 'SKILLS' },
    { key: 'progression', label: 'PROGRESSION' },
    { key: 'milestones', label: 'MILESTONES' },
    { key: 'analytics', label: 'ANALYTICS' },
  ];

  return (
    <Window
      title="SCP FOUNDATION — SKILL PROGRESSION TERMINAL"
      width={1100}
      height={750}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderRed}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              SCP FOUNDATION — SKILL PROGRESSION TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 2 | PERSONNEL DEVELOPMENT TRACKING | v2.1.0
            </Box>
          </Box>

          <Box
            style={{
              display: 'flex',
              borderBottom: `1px solid ${C.borderRed}`,
              overflowX: 'auto',
              background: C.panel,
            }}
          >
            {TABS.map((t) => {
              const isActive = activeTab === t.key;
              return (
                <Box
                  key={t.key}
                  style={{
                    padding: '6px 12px',
                    cursor: 'pointer',
                    background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
                    borderRight: `1px solid ${C.border}`,
                    borderBottom: isActive
                      ? `2px solid ${C.amber}`
                      : '2px solid transparent',
                    color: isActive ? C.textBright : C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    fontFamily: C.mono,
                    whiteSpace: 'nowrap',
                  }}
                  onClick={() => setActiveTab(t.key)}
                >
                  {isActive && '▸ '}
                  {t.label}
                </Box>
              );
            })}
          </Box>

          <Box style={{ padding: '16px' }}>
            {activeTab === 'overview' && (
              <SkillOverview
                player_name={player_name}
                current_class={current_class}
                current_faction={current_faction}
                current_rank={current_rank}
                current_rank_level={current_rank_level}
                total_experience={total_experience}
                rounds_played={rounds_played}
                progress_to_next={progress_to_next}
                exp_needed={exp_needed}
                skill_summary={skill_summary}
                performance_metrics={performance_metrics}
              />
            )}
            {activeTab === 'skills' && (
              <SkillDetails
                skill_summary={skill_summary}
                skill_boosts={skill_boosts}
                current_class={current_class}
                act={act}
              />
            )}
            {activeTab === 'progression' && (
              <ProgressionDetails
                current_class={current_class}
                current_rank={current_rank}
                current_rank_level={current_rank_level}
                total_experience={total_experience}
                progress_to_next={progress_to_next}
                exp_needed={exp_needed}
                skill_summary={skill_summary}
                act={act}
              />
            )}
            {activeTab === 'milestones' && (
              <MilestoneTracker
                skill_milestones={skill_milestones}
                skill_summary={skill_summary}
                act={act}
              />
            )}
            {activeTab === 'analytics' && (
              <SkillAnalytics
                skill_summary={skill_summary}
                performance_metrics={performance_metrics}
                rounds_played={rounds_played}
                act={act}
              />
            )}
          </Box>

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={term({
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              })}
            >
              SCP FOUNDATION | SKILL PROGRESSION | ALL DATA CLASSIFIED |
              UNAUTHORIZED ACCESS IS A CLASS-B INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
