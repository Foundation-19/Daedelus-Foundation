import { useBackend, useLocalState } from '../backend';
import { Box, Button, NoticeBox } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';


export const SCPProgression = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useLocalState('scpTab', 1);
  const [selectedSCP, setSelectedSCP] = useLocalState('selectedSCP', null);

  const safeData = data || {};
  const hasData = safeData.has_data || false;

  if (!hasData) {
    return (
      <Window
        title="SCP FOUNDATION — SCP PROGRESSION TERMINAL"
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
            <NoticeBox>NO SCP PROGRESSION DATA FOUND</NoticeBox>
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const {
    player_name = 'Unknown',
    player_key = 'Unknown',
    current_scp = 'None',
    scp_progression_data = {},
    global_scp_stats = {},
    available_scps = [],
    achievements = [],
    recent_events = [],
  } = safeData;

  const TABS = [
    { key: 1, label: 'OVERVIEW' },
    { key: 2, label: 'SCP DATA' },
    { key: 3, label: 'ACHIEVEMENTS' },
    { key: 4, label: 'EVENTS' },
    { key: 5, label: 'GLOBAL' },
  ];

  return (
    <Window
      title="SCP FOUNDATION — SCP PROGRESSION TERMINAL"
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
              SCP FOUNDATION — SCP PROGRESSION TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              ANOMALOUS ENTITY PERFORMANCE TRACKING | SUBJECT: {player_name} |
              KEY: {player_key} | CURRENT:{' '}
              {current_scp !== 'None' ? `SCP-${current_scp}` : 'NONE'}
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
                <TermHeader>SCP PROGRESSION OVERVIEW</TermHeader>
                <Box
                  style={{ display: 'flex', gap: '4px', marginBottom: '12px' }}
                >
                  <TermButton
                    color="green"
                    onClick={() => act('export_scp_data')}
                  >
                    EXPORT
                  </TermButton>
                  <TermButton onClick={() => act('refresh_scp_data')}>
                    REFRESH
                  </TermButton>
                  <TermButton
                    color="yellow"
                    onClick={() => act('save_scp_data')}
                  >
                    SAVE
                  </TermButton>
                  <TermButton onClick={() => act('load_scp_data')}>
                    LOAD
                  </TermButton>
                </Box>

                <TermRow>
                  <TermLabel>CURRENT SCP</TermLabel>
                  <TermValue color={C.amber} bold>
                    {current_scp !== 'None'
                      ? `SCP-${current_scp}`
                      : 'NOT ASSIGNED'}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>SCPs PLAYED</TermLabel>
                  <TermValue>
                    {Object.keys(scp_progression_data).length}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>TOTAL SCP XP</TermLabel>
                  <TermValue color={C.amber}>
                    {Object.values(scp_progression_data).reduce(
                      (sum, scp) => sum + (scp.total_experience || 0),
                      0,
                    )}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>ACHIEVEMENTS</TermLabel>
                  <TermValue color={C.green}>{achievements.length}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>RECENT EVENTS</TermLabel>
                  <TermValue>{recent_events.length}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>SYSTEM</TermLabel>
                  <TermValue color={C.green}>OPERATIONAL</TermValue>
                </TermRow>
              </Box>
            )}

            {tab === 2 && (
              <Box>
                <TermHeader>AVAILABLE SCPs</TermHeader>
                <Box
                  style={{
                    display: 'flex',
                    flexWrap: 'wrap',
                    gap: '6px',
                    marginBottom: '12px',
                  }}
                >
                  {available_scps.map((scp) => (
                    <TermButton
                      key={scp.scp_id}
                      selected={selectedSCP === scp.scp_id}
                      color={selectedSCP === scp.scp_id ? 'red' : undefined}
                      onClick={() => setSelectedSCP(scp.scp_id)}
                    >
                      SCP-{scp.scp_id}
                    </TermButton>
                  ))}
                </Box>

                {selectedSCP && scp_progression_data[selectedSCP] && (
                  <Box>
                    <TermDivider />
                    <TermHeader>SCP-{selectedSCP} DETAILS</TermHeader>
                    <TermRow>
                      <TermLabel>ROUNDS PLAYED</TermLabel>
                      <TermValue>
                        {scp_progression_data[selectedSCP].rounds_played || 0}
                      </TermValue>
                    </TermRow>
                    <TermRow>
                      <TermLabel>TOTAL XP</TermLabel>
                      <TermValue color={C.amber}>
                        {scp_progression_data[selectedSCP].total_experience ||
                          0}
                      </TermValue>
                    </TermRow>
                    <TermRow>
                      <TermLabel>ACHIEVEMENTS</TermLabel>
                      <TermValue color={C.green}>
                        {scp_progression_data[selectedSCP].achievements
                          ?.length || 0}
                      </TermValue>
                    </TermRow>
                    <TermRow>
                      <TermLabel>LAST UPDATE</TermLabel>
                      <TermValue>
                        {scp_progression_data[selectedSCP].last_update
                          ? new Date(
                              scp_progression_data[selectedSCP].last_update *
                                1000,
                            ).toLocaleString()
                          : 'NEVER'}
                      </TermValue>
                    </TermRow>

                    {Object.keys(
                      scp_progression_data[selectedSCP].metrics || {},
                    ).length > 0 && (
                      <Box>
                        <TermDivider />
                        <TermHeader>METRICS</TermHeader>
                        {Object.entries(
                          scp_progression_data[selectedSCP].metrics || {},
                        ).map(([metric, value]) => (
                          <TermRow key={metric}>
                            <TermLabel>
                              {metric.replace(/_/g, ' ').toUpperCase()}
                            </TermLabel>
                            <TermValue color={C.amber}>{value}</TermValue>
                          </TermRow>
                        ))}
                      </Box>
                    )}
                  </Box>
                )}
              </Box>
            )}

            {tab === 3 && (
              <Box>
                <TermHeader>SCP ACHIEVEMENTS</TermHeader>
                {achievements && achievements.length > 0 ? (
                  achievements.map((achievement, index) => (
                    <Box
                      key={index}
                      style={{
                        marginBottom: '6px',
                        padding: '8px',
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
                          STATUS
                        </TermLabel>
                        <TermValue
                          color={achievement.unlocked ? C.green : C.textDim}
                        >
                          {achievement.unlocked ? 'UNLOCKED' : 'LOCKED'}
                        </TermValue>
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
                    NO SCP ACHIEVEMENTS AVAILABLE
                  </Box>
                )}
              </Box>
            )}

            {tab === 4 && (
              <Box>
                <TermHeader>RECENT SCP EVENTS</TermHeader>
                {recent_events && recent_events.length > 0 ? (
                  recent_events.map((event, index) => (
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
                        <TermValue color={C.amber} bold>
                          +{event.experience} XP
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          SCP-{event.scp_id}
                        </TermLabel>
                        <TermLabel>{event.event_type}</TermLabel>
                        <Box
                          as="span"
                          style={term({
                            color: C.textDim,
                            fontSize: '10px',
                            marginLeft: 'auto',
                          })}
                        >
                          {new Date(event.timestamp * 1000).toLocaleString()}
                        </Box>
                      </TermRow>
                      <Box style={term({ color: C.textDim, fontSize: '11px' })}>
                        {event.details}
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                    NO RECENT EVENTS
                  </Box>
                )}
              </Box>
            )}

            {tab === 5 && (
              <Box>
                <TermHeader>GLOBAL SCP STATISTICS</TermHeader>
                <TermRow>
                  <TermLabel>TOTAL SCP ROUNDS</TermLabel>
                  <TermValue>
                    {global_scp_stats.total_scp_rounds_played || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>TOTAL ACHIEVEMENTS</TermLabel>
                  <TermValue color={C.green}>
                    {global_scp_stats.total_scp_achievements_unlocked || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>AVERAGE PERFORMANCE</TermLabel>
                  <TermValue color={C.amber}>
                    {global_scp_stats.average_scp_performance || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>RESEARCH POINTS</TermLabel>
                  <TermValue>
                    {global_scp_stats.total_scp_research_points || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>CONTAINMENT BREACHES</TermLabel>
                  <TermValue color={C.redBright}>
                    {global_scp_stats.scp_containment_breaches || 0}
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>RESEARCH BREAKTHROUGHS</TermLabel>
                  <TermValue color={C.green}>
                    {global_scp_stats.scp_research_breakthroughs || 0}
                  </TermValue>
                </TermRow>
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
              SCP FOUNDATION | ANOMALOUS ENTITY PROGRESSION | ALL DATA
              CLASSIFIED | v1.0
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
