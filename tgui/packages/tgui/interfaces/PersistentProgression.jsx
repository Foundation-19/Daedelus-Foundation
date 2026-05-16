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

const StatBox = (props) => (
  <Box
    style={{
      flex: 1,
      padding: '10px',
      borderLeft: `2px solid ${props.color || C.borderRed}`,
      background: C.panel,
      textAlign: 'center',
    }}
  >
    <Box
      style={term({
        color: props.color || C.amber,
        fontSize: '18px',
        fontWeight: 'bold',
      })}
    >
      {props.value}
    </Box>
    <Box
      style={term({
        color: C.textDim,
        fontSize: '9px',
        letterSpacing: '0.12em',
      })}
    >
      {props.label}
    </Box>
  </Box>
);

export const PersistentProgression = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useLocalState('tab', 1);

  const safeData = data || {};
  const hasData = safeData.has_data || false;

  if (!hasData) {
    return (
      <Window
        title="SCP FOUNDATION — PERSISTENT PROGRESSION TERMINAL"
        width={1200}
        height={800}
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
            <NoticeBox>
              NO PERSISTENT DATA FOUND — CONTACT ADMINISTRATOR
            </NoticeBox>
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const {
    player_name = 'Unknown',
    player_key = 'Unknown',
    current_class = 'Unknown',
    current_faction = 'Unknown',
    current_rank = 'Unknown',
    current_rank_level = 0,
    total_experience = 0,
    rounds_played = 0,
    progress_to_next = 0,
    exp_needed = 0,
    total_rounds_survived = 0,
    total_rounds_died = 0,
    survival_rate = 0,
    average_exp_per_round = 0,
    class_description = 'No description available',
    class_exp_multiplier = 1.0,
    class_max_rank = 0,
    faction_description = 'No description available',
    faction_exp_multiplier = 1.0,
    unlocked_items = [],
    unlocked_titles = [],
    achievements = [],
    recent_experience = [],
  } = safeData;

  const TABS = [
    { key: 1, label: 'OVERVIEW' },
    { key: 2, label: 'ACHIEVEMENTS' },
    { key: 3, label: 'UNLOCKED' },
    { key: 4, label: 'ACTIVITY' },
    { key: 5, label: 'CLASS' },
    { key: 6, label: 'SCP' },
  ];

  return (
    <Window
      title="SCP FOUNDATION — PERSISTENT PROGRESSION TERMINAL"
      width={1200}
      height={800}
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
              SCP FOUNDATION — PERSISTENT PROGRESSION TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              PERSONNEL DEVELOPMENT & ACHIEVEMENT TRACKING | CLEARANCE LEVEL 2 |
              v3.2.1
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
              const isActive = tab === t.key;
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
                  onClick={() => setTab(t.key)}
                >
                  {isActive && '▸ '}
                  {t.label}
                </Box>
              );
            })}
          </Box>

          <Box style={{ padding: '16px' }}>
            {tab === 1 && (
              <Box>
                <TermHeader>QUICK ACTIONS</TermHeader>
                <Box
                  style={{ display: 'flex', gap: '4px', marginBottom: '12px' }}
                >
                  <TermButton color="green" onClick={() => act('export_data')}>
                    EXPORT
                  </TermButton>
                  <TermButton color="red" onClick={() => act('reset_progress')}>
                    RESET
                  </TermButton>
                  <TermButton color="yellow" onClick={() => act('save_data')}>
                    SAVE
                  </TermButton>
                  <TermButton onClick={() => act('load_data')}>LOAD</TermButton>
                </Box>

                <TermDivider />

                <TermHeader>PERSONNEL IDENTIFICATION</TermHeader>
                <TermRow>
                  <TermLabel>DESIGNATION</TermLabel>
                  <TermValue color={C.amber} bold>
                    {player_name}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>ID KEY</TermLabel>
                  <TermValue color={C.amber}>{player_key}</TermValue>
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
                    {total_experience.toLocaleString()}
                  </TermValue>
                </TermRow>

                <TermDivider />

                <TermHeader>PROGRESSION STATUS</TermHeader>
                <TermProgressBar
                  label="PROGRESS TO NEXT RANK"
                  value={progress_to_next}
                  maxValue={100}
                  color={progress_to_next >= 100 ? C.green : C.amber}
                  suffix="%"
                />
                {exp_needed > 0 && (
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '10px',
                      marginBottom: '8px',
                    })}
                  >
                    {exp_needed.toLocaleString()} XP REQUIRED
                  </Box>
                )}

                <Box style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                  <StatBox
                    label="ROUNDS PLAYED"
                    value={rounds_played}
                    color={C.green}
                  />
                  <StatBox
                    label="SURVIVAL RATE"
                    value={`${survival_rate}%`}
                    color={C.amber}
                  />
                  <StatBox
                    label="AVG XP/ROUND"
                    value={average_exp_per_round}
                    color={C.textBright}
                  />
                </Box>
              </Box>
            )}

            {tab === 2 && (
              <Box>
                <TermHeader>ACHIEVEMENTS & MILESTONES</TermHeader>
                {achievements && achievements.length > 0 ? (
                  achievements.map((achievement, index) => (
                    <Box
                      key={index}
                      style={{
                        marginBottom: '6px',
                        padding: '8px',
                        borderLeft: `2px solid ${C.borderRed}`,
                        background: C.panel,
                      }}
                    >
                      <TermRow>
                        <TermValue bold color={C.amber}>
                          {achievement.name}
                        </TermValue>
                        <Box
                          as="span"
                          style={term({
                            color: C.textDim,
                            fontSize: '10px',
                            marginLeft: '12px',
                          })}
                        >
                          {achievement.date}
                        </Box>
                      </TermRow>
                      <Box
                        style={term({
                          color: C.textDim,
                          fontSize: '11px',
                          fontStyle: 'italic',
                          marginTop: '2px',
                        })}
                      >
                        {achievement.description}
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                    NO ACHIEVEMENTS UNLOCKED
                  </Box>
                )}
              </Box>
            )}

            {tab === 3 && (
              <Box>
                <TermHeader>UNLOCKED CONTENT</TermHeader>
                <Box style={{ display: 'flex', gap: '16px' }}>
                  <Box style={{ flex: 1 }}>
                    <TermLabel>ITEMS ({unlocked_items.length})</TermLabel>
                    {unlocked_items.length > 0 ? (
                      unlocked_items.map((item, i) => (
                        <Box
                          key={i}
                          style={{
                            ...term({
                              color: C.text,
                              fontSize: '11px',
                              paddingLeft: '8px',
                              marginTop: '4px',
                            }),
                            borderLeft: `1px solid ${C.border}`,
                          }}
                        >
                          {item}
                        </Box>
                      ))
                    ) : (
                      <Box
                        style={term({
                          color: C.textDim,
                          fontStyle: 'italic',
                          fontSize: '11px',
                        })}
                      >
                        NONE
                      </Box>
                    )}
                  </Box>
                  <Box style={{ flex: 1 }}>
                    <TermLabel>TITLES ({unlocked_titles.length})</TermLabel>
                    {unlocked_titles.length > 0 ? (
                      unlocked_titles.map((title, i) => (
                        <Box
                          key={i}
                          style={{
                            ...term({
                              color: C.text,
                              fontSize: '11px',
                              paddingLeft: '8px',
                              marginTop: '4px',
                            }),
                            borderLeft: `1px solid ${C.border}`,
                          }}
                        >
                          {title}
                        </Box>
                      ))
                    ) : (
                      <Box
                        style={term({
                          color: C.textDim,
                          fontStyle: 'italic',
                          fontSize: '11px',
                        })}
                      >
                        NONE
                      </Box>
                    )}
                  </Box>
                </Box>
              </Box>
            )}

            {tab === 4 && (
              <Box>
                <TermHeader>RECENT EXPERIENCE ACTIVITY</TermHeader>
                {recent_experience && recent_experience.length > 0 ? (
                  recent_experience.map((exp, index) => (
                    <Box
                      key={index}
                      style={{
                        marginBottom: '4px',
                        padding: '8px',
                        borderLeft: `2px solid ${C.borderRed}`,
                        background: C.panel,
                      }}
                    >
                      <TermRow>
                        <TermValue color={C.green} bold>
                          +{exp.amount} XP
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          {exp.reason}
                        </TermLabel>
                        <Box
                          as="span"
                          style={term({
                            color: C.textDim,
                            fontSize: '10px',
                            marginLeft: 'auto',
                          })}
                        >
                          {exp.timestamp}
                        </Box>
                      </TermRow>
                    </Box>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                    NO RECENT ACTIVITY
                  </Box>
                )}
              </Box>
            )}

            {tab === 5 && (
              <Box>
                <TermHeader>CLASS & FACTION DETAILS</TermHeader>
                <Box style={{ display: 'flex', gap: '16px' }}>
                  <Box style={{ flex: 1 }}>
                    <TermHeader>
                      CLASS — {current_class.toUpperCase()}
                    </TermHeader>
                    <Box
                      style={term({
                        color: C.textDim,
                        fontSize: '11px',
                        fontStyle: 'italic',
                        marginBottom: '8px',
                      })}
                    >
                      {class_description}
                    </Box>
                    <TermRow>
                      <TermLabel>EXP MULTIPLIER</TermLabel>
                      <TermValue color={C.amber}>
                        {class_exp_multiplier}x
                      </TermValue>
                    </TermRow>
                    <TermRow>
                      <TermLabel>MAX RANK</TermLabel>
                      <TermValue>{class_max_rank}</TermValue>
                    </TermRow>
                  </Box>
                  <Box style={{ flex: 1 }}>
                    <TermHeader>
                      FACTION — {current_faction.toUpperCase()}
                    </TermHeader>
                    <Box
                      style={term({
                        color: C.textDim,
                        fontSize: '11px',
                        fontStyle: 'italic',
                        marginBottom: '8px',
                      })}
                    >
                      {faction_description}
                    </Box>
                    <TermRow>
                      <TermLabel>EXP MULTIPLIER</TermLabel>
                      <TermValue color={C.amber}>
                        {faction_exp_multiplier}x
                      </TermValue>
                    </TermRow>
                  </Box>
                </Box>
              </Box>
            )}

            {tab === 6 && (
              <Box>
                <TermHeader>SCP PROGRESSION</TermHeader>
                <TermRow>
                  <TermLabel>CURRENT SCP</TermLabel>
                  <TermValue color={C.amber} bold>
                    {safeData.current_scp || 'NONE'}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>SCP TOTAL XP</TermLabel>
                  <TermValue color={C.amber}>
                    {safeData.scp_total_experience || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>SCP ROUNDS</TermLabel>
                  <TermValue>{safeData.scp_rounds_played || 0}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>SCP ACHIEVEMENTS</TermLabel>
                  <TermValue color={C.green}>
                    {safeData.scp_achievements_unlocked || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>PERFORMANCE SCORE</TermLabel>
                  <TermValue>{safeData.scp_performance_score || 0}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>SCP RANK</TermLabel>
                  <TermValue color={C.green}>
                    {safeData.scp_rank || 'Novice'}
                  </TermValue>
                </TermRow>

                {safeData.scp_metrics &&
                  Object.keys(safeData.scp_metrics).length > 0 && (
                    <Box>
                      <TermDivider />
                      <TermHeader>SCP-SPECIFIC METRICS</TermHeader>
                      {Object.entries(safeData.scp_metrics).map(
                        ([scp_id, metrics]) => (
                          <Box
                            key={scp_id}
                            style={{
                              marginBottom: '8px',
                              padding: '8px',
                              borderLeft: `2px solid ${C.borderRed}`,
                              background: C.panel,
                            }}
                          >
                            <TermValue bold color={C.amber}>
                              SCP-{scp_id}
                            </TermValue>
                            {Object.entries(metrics).map(([metric, value]) => (
                              <TermRow key={metric}>
                                <TermLabel>{metric.toUpperCase()}</TermLabel>
                                <TermValue>{value}</TermValue>
                              </TermRow>
                            ))}
                          </Box>
                        ),
                      )}
                    </Box>
                  )}

                <TermDivider />

                <TermHeader>SCP PERFORMANCE</TermHeader>
                <TermRow>
                  <TermLabel>TOTAL SCP ROUNDS</TermLabel>
                  <TermValue>{safeData.total_scp_rounds || 0}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>AVG SCP PERFORMANCE</TermLabel>
                  <TermValue color={C.amber}>
                    {safeData.average_scp_performance || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>CONTAINMENT BREACHES</TermLabel>
                  <TermValue color={C.redBright}>
                    {safeData.scp_containment_breaches || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>RESEARCH POINTS</TermLabel>
                  <TermValue>{safeData.scp_research_points || 0}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>RESEARCH BREAKTHROUGHS</TermLabel>
                  <TermValue color={C.green}>
                    {safeData.scp_research_breakthroughs || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>INTERACTION EVENTS</TermLabel>
                  <TermValue>{safeData.scp_interaction_events || 0}</TermValue>
                </TermRow>

                {safeData.scp_achievements &&
                  safeData.scp_achievements.length > 0 && (
                    <Box>
                      <TermDivider />
                      <TermHeader>SCP ACHIEVEMENTS</TermHeader>
                      {safeData.scp_achievements.map((achievement, index) => (
                        <Box
                          key={index}
                          style={{
                            marginBottom: '4px',
                            padding: '6px 8px',
                            borderLeft: `2px solid ${achievement.unlocked ? C.green : C.border}`,
                            background: C.panel,
                          }}
                        >
                          <TermRow>
                            <TermValue
                              bold
                              color={achievement.unlocked ? C.green : C.textDim}
                            >
                              {achievement.name}
                            </TermValue>
                            <TermLabel style={{ marginLeft: '8px' }}>
                              {achievement.unlocked ? 'UNLOCKED' : 'LOCKED'}
                            </TermLabel>
                          </TermRow>
                          <Box
                            style={term({
                              color: C.textDim,
                              fontSize: '11px',
                              fontStyle: 'italic',
                            })}
                          >
                            {achievement.description}
                          </Box>
                        </Box>
                      ))}
                    </Box>
                  )}
              </Box>
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
              SCP FOUNDATION | PERSISTENT PROGRESSION | ALL DATA CLASSIFIED |
              UNAUTHORIZED ACCESS IS A CLASS-B INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
