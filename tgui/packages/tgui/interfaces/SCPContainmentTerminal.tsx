import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

type Resource = {
  key: string;
  value: number;
};

type Interaction = {
  cost: number;
  desc: string;
  id: string;
  name: string;
  resource: string;
};

type LogEntry = {
  name: string;
  time: string;
};

type ContainmentData = {
  cell_type: string;
  containment_integrity: number;
  containment_state: number;
  containment_state_name: string;
  interactions: Interaction[];
  is_scp: BooleanLike;
  observer_count: number;
  recent_log: LogEntry[];
  resources: Resource[];
  scp_id: string;
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const getStateColor = (stateName: string) => {
  switch (stateName) {
    case 'Secure':
      return C.greenBright;
    case 'Stable':
      return C.green;
    case 'Degrading':
      return C.amber;
    case 'Critical':
      return C.redBright;
    case 'Breached':
      return C.redBright;
    default:
      return C.textDim;
  }
};

const getResourceLabel = (key: string) => {
  switch (key) {
    case 'tension':
      return 'TENSION';
    case 'corrosion':
      return 'CORROSION';
    case 'hack_progress':
      return 'HACK PROGRESS';
    case 'adaptation':
      return 'ADAPTATION';
    case 'infection':
      return 'INFECTION';
    case 'fuel':
      return 'FUEL';
    case 'voice_data':
      return 'VOICE DATA';
    case 'offspring':
      return 'OFFSPRING';
    case 'visibility':
      return 'VISIBILITY';
    case 'hunger':
      return 'HUNGER';
    default:
      return key.toUpperCase();
  }
};

const getResourceColor = (key: string) => {
  switch (key) {
    case 'tension':
      return C.redBright;
    case 'corrosion':
      return '#88aa44';
    case 'hack_progress':
      return '#4488ff';
    case 'adaptation':
      return '#cc44cc';
    case 'infection':
      return '#44cc44';
    case 'fuel':
      return '#ff8844';
    case 'voice_data':
      return '#aa88ff';
    default:
      return C.amber;
  }
};

const getIntegrityColor = (value: number) => {
  if (value > 80) return C.greenBright;
  if (value > 50) return C.green;
  if (value > 20) return C.amber;
  return C.redBright;
};

const TermProgressBar = (props: {
  color?: string;
  label: string;
  maxValue?: number;
  suffix?: string;
  value: number;
}) => (
  <Box style={{ marginBottom: '6px' }}>
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        marginBottom: '2px',
      }}
    >
      <Box
        style={{
          fontFamily: C.mono,
          fontSize: '10px',
          color: C.textDim,
          letterSpacing: '0.12em',
          textTransform: 'uppercase',
        }}
      >
        {props.label}
      </Box>
      <Box
        style={{
          fontFamily: C.mono,
          fontSize: '10px',
          color: props.color || C.amber,
          fontWeight: 'bold',
        }}
      >
        {Math.round(props.value)}
        {props.suffix || ''}
      </Box>
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
          width: `${Math.min(100, Math.max(0, (props.value / (props.maxValue || 100)) * 100))}%`,
          background: props.color || C.amber,
          transition: 'width 0.3s',
        }}
      />
    </Box>
  </Box>
);

export const SCPContainmentTerminal = (props) => {
  const { act, data } = useBackend<ContainmentData>();

  if (!data) {
    return <Box color="red">Loading SCP terminal data...</Box>;
  }

  const [selectedTab, setSelectedTab] = useLocalState<string>(
    'contTab',
    'status',
  );

  const {
    scp_id,
    containment_integrity,
    containment_state,
    containment_state_name,
    cell_type,
    observer_count,
    resources,
    interactions,
    recent_log,
    is_scp,
  } = data;

  const TABS = [
    { key: 'status', label: 'STATUS' },
    { key: 'interact', label: 'INTERACT' },
    { key: 'log', label: 'ACTIVITY LOG' },
  ];

  return (
    <NtosWindow width={550} height={620}>
      <NtosWindow.Content scrollable>
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
              background:
                'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              SCP CONTAINMENT TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              {scp_id || 'NO ENTITY LINKED'} | CELL TYPE:{' '}
              {cell_type?.toUpperCase() || 'UNKNOWN'}
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
              const isActive = selectedTab === t.key;
              return (
                <Box
                  key={t.key}
                  style={{
                    padding: '6px 12px',
                    cursor: 'pointer',
                    background: isActive
                      ? 'rgba(139,0,0,0.25)'
                      : 'transparent',
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
                  onClick={() => setSelectedTab(t.key)}
                >
                  {isActive && '▸ '}
                  {t.label}
                </Box>
              );
            })}
          </Box>

          <Box style={{ padding: '14px' }}>
            {selectedTab === 'status' && (
              <Box>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  CONTAINMENT STATUS
                </Box>

                <Box
                  style={{
                    display: 'flex',
                    gap: '16px',
                    marginBottom: '12px',
                    flexWrap: 'wrap',
                  }}
                >
                  <Box>
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        letterSpacing: '0.12em',
                        textTransform: 'uppercase',
                      }}
                    >
                      ENTITY:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: C.textBright,
                        fontWeight: 'bold',
                      }}
                    >
                      {scp_id || 'NONE'}
                    </Box>
                  </Box>
                  <Box>
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        letterSpacing: '0.12em',
                        textTransform: 'uppercase',
                      }}
                    >
                      STATE:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: getStateColor(containment_state_name),
                        fontWeight: 'bold',
                      }}
                    >
                      {containment_state_name?.toUpperCase() || 'UNKNOWN'}
                    </Box>
                  </Box>
                  <Box>
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        letterSpacing: '0.12em',
                        textTransform: 'uppercase',
                      }}
                    >
                      OBSERVERS:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: observer_count > 0 ? C.amber : C.textBright,
                        fontWeight: 'bold',
                      }}
                    >
                      {observer_count}
                    </Box>
                  </Box>
                </Box>

                <TermProgressBar
                  label="CONTAINMENT INTEGRITY"
                  value={containment_integrity}
                  maxValue={100}
                  color={getIntegrityColor(containment_integrity)}
                  suffix="%"
                />

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
                  {'─'.repeat(60)}
                </Box>

                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  ANOMALOUS RESOURCES
                </Box>

                {(resources || []).length > 0 ? (
                  resources.map((res) => (
                    <TermProgressBar
                      key={res.key}
                      label={getResourceLabel(res.key)}
                      value={res.value}
                      maxValue={100}
                      color={getResourceColor(res.key)}
                      suffix="%"
                    />
                  ))
                ) : (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    }}
                  >
                    NO RESOURCES DETECTED
                  </Box>
                )}

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
                  {'─'.repeat(60)}
                </Box>

                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  CELL INFORMATION
                </Box>

                <Box style={{ display: 'flex', gap: '16px' }}>
                  <Box>
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        letterSpacing: '0.12em',
                        textTransform: 'uppercase',
                      }}
                    >
                      TYPE:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{ color: C.textBright }}
                    >
                      {cell_type?.toUpperCase() || 'STANDARD'}
                    </Box>
                  </Box>
                  <Box>
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        letterSpacing: '0.12em',
                        textTransform: 'uppercase',
                      }}
                    >
                      INTEGRITY:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: getIntegrityColor(containment_integrity),
                        fontWeight: 'bold',
                      }}
                    >
                      {Math.round(containment_integrity)}%
                    </Box>
                  </Box>
                </Box>
              </Box>
            )}

            {selectedTab === 'interact' && (
              <Box>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  CONTAINMENT INTERACTIONS
                </Box>

                {!is_scp && (
                  <Box
                    style={{
                      color: C.amber,
                      fontStyle: 'italic',
                      fontSize: '11px',
                      borderLeft: `2px solid ${C.amber}`,
                      paddingLeft: '8px',
                      marginBottom: '12px',
                    }}
                  >
                    OBSERVER MODE — Only contained entities may perform
                    interactions.
                  </Box>
                )}

                {(interactions || []).length > 0 ? (
                  interactions.map((interaction) => {
                    const resourceObj = resources?.find(
                      (r) => r.key === interaction.resource,
                    );
                    const currentAmount = resourceObj?.value || 0;
                    const canAfford =
                      interaction.cost <= 0 ||
                      currentAmount >= interaction.cost;

                    return (
                      <Box
                        key={interaction.id}
                        style={{
                          marginBottom: '6px',
                          padding: '8px',
                          borderLeft: `2px solid ${canAfford && is_scp ? C.borderRed : C.border}`,
                          background: C.panel,
                        }}
                      >
                        <Box
                          style={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            marginBottom: '4px',
                          }}
                        >
                          <Box
                            style={{
                              color: C.textBright,
                              fontWeight: 'bold',
                              fontSize: '11px',
                            }}
                          >
                            {interaction.name}
                          </Box>
                          {interaction.cost > 0 && (
                            <Box
                              style={{
                                color: canAfford ? C.amber : C.red,
                                fontSize: '10px',
                                letterSpacing: '0.1em',
                              }}
                            >
                              {getResourceLabel(interaction.resource)}:{' '}
                              {Math.round(currentAmount)}/{interaction.cost}
                            </Box>
                          )}
                        </Box>
                        <Box
                          style={{
                            color: C.textDim,
                            fontSize: '11px',
                            marginBottom: '6px',
                          }}
                        >
                          {interaction.desc}
                        </Box>
                        <Button
                          disabled={!canAfford || !is_scp}
                          onClick={() =>
                            act('interact', { id: interaction.id })
                          }
                          style={{
                            fontFamily: C.mono,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                            textTransform: 'uppercase',
                            background:
                              canAfford && is_scp
                                ? 'rgba(139,0,0,0.35)'
                                : 'transparent',
                            border: `1px solid ${canAfford && is_scp ? C.red : C.border}`,
                            borderRadius: 0,
                            color:
                              canAfford && is_scp
                                ? C.textBright
                                : C.textDim,
                            padding: '3px 8px',
                          }}
                        >
                          EXECUTE
                        </Button>
                      </Box>
                    );
                  })
                ) : (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    }}
                  >
                    NO INTERACTIONS AVAILABLE
                  </Box>
                )}
                {!is_scp && (
                  <Box style={{ marginTop: '12px' }}>
                    <Box
                      style={{
                        fontSize: '10px',
                        color: C.textDim,
                        letterSpacing: '0.18em',
                        textTransform: 'uppercase',
                        borderBottom: `1px solid ${C.border}`,
                        paddingBottom: '4px',
                        marginBottom: '8px',
                      }}
                    >
                      RESEARCH ACTIONS
                    </Box>
                    <Box style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                      <Button
                        onClick={() => act('start_experiment')}
                        style={{
                          fontFamily: C.mono,
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                          textTransform: 'uppercase',
                          background: 'rgba(139,0,0,0.25)',
                          border: `1px solid ${C.red}`,
                          borderRadius: 0,
                          color: C.textBright,
                          padding: '3px 8px',
                        }}
                      >
                        Start Experiment
                      </Button>
                      <Button
                        onClick={() => act('request_subject')}
                        style={{
                          fontFamily: C.mono,
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                          textTransform: 'uppercase',
                          background: 'transparent',
                          border: `1px solid ${C.border}`,
                          borderRadius: 0,
                          color: C.textDim,
                          padding: '3px 8px',
                        }}
                      >
                        Request D-Class
                      </Button>
                    </Box>
                  </Box>
                )}
              </Box>
            )}

            {selectedTab === 'log' && (
              <Box>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  ACTIVITY LOG
                </Box>

                <Box style={{ marginBottom: '8px' }}>
                  <Button
                    onClick={() => act('refresh')}
                    style={{
                      fontFamily: C.mono,
                      fontSize: '10px',
                      letterSpacing: '0.1em',
                      textTransform: 'uppercase',
                      background: 'rgba(139,0,0,0.2)',
                      border: `1px solid ${C.border}`,
                      borderRadius: 0,
                      color: C.text,
                      padding: '3px 8px',
                    }}
                  >
                    REFRESH
                  </Button>
                </Box>

                {(recent_log || []).length > 0 ? (
                  recent_log.map((entry, idx) => (
                    <Box
                      key={`${entry.time}-${idx}`}
                      style={{
                        marginBottom: '4px',
                        padding: '4px 8px',
                        borderLeft: `2px solid ${C.borderRed}`,
                        background: C.panel,
                        display: 'flex',
                        gap: '8px',
                        alignItems: 'center',
                      }}
                    >
                      <Box
                        style={{
                          color: C.textDim,
                          fontSize: '10px',
                          fontFamily: C.mono,
                          whiteSpace: 'nowrap',
                        }}
                      >
                        [{entry.time}]
                      </Box>
                      <Box
                        style={{
                          color: C.text,
                          fontSize: '11px',
                        }}
                      >
                        {entry.name}
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    }}
                  >
                    NO RECENT ACTIVITY
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
              style={{
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | CONTAINMENT TERMINAL | SECURE CONTAIN PROTECT |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
