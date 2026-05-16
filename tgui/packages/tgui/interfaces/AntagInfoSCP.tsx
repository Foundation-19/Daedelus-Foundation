import { BooleanLike } from 'common/react';
import React from 'react';
import { useBackend } from '../backend';
import { Box, Stack } from '../components';
import { Window } from '../layouts';

type Objective = {
  complete: BooleanLike;
  count: number;
  explanation: string;
  name: string;
};

type Ability = {
  cooldown: string;
  desc: string;
  name: string;
};

type SCPInfo = {
  abilities: Ability[];
  antag_name: string;
  containment_status: string;
  is_scp: BooleanLike;
  lore_text: string;
  objectives: Objective[];
  scp_class: string;
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
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const getClassColor = (cls: string) => {
  switch (cls) {
    case 'Keter':
      return C.redBright;
    case 'Euclid':
      return C.amber;
    case 'Safe':
      return C.green;
    default:
      return C.textDim;
  }
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'contained':
      return C.green;
    case 'breached':
      return C.redBright;
    default:
      return C.amber;
  }
};

export const AntagInfoSCP = (props) => {
  const { data } = useBackend<SCPInfo>();
  const {
    antag_name,
    scp_id,
    scp_class,
    containment_status,
    lore_text,
    abilities,
    objectives,
  } = data;

  return (
    <Window theme="scp_terminal" width={620} height={520}>
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
              SCP FOUNDATION — ANOMALOUS ENTITY DESIGNATION
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLASSIFIED | EYES ONLY | CONTAINMENT PROTOCOL ACTIVE
            </Box>
          </Box>

          <Box style={{ padding: '12px 14px' }}>
            <Box
              style={{
                fontSize: '18px',
                fontWeight: 'bold',
                color: C.redBright,
                letterSpacing: '0.08em',
                marginBottom: '8px',
                textShadow: '0 0 0.4em rgba(204,34,34,0.4)',
              }}
            >
              YOU ARE {antag_name?.toUpperCase() || scp_id?.toUpperCase()}
            </Box>

            <Stack vertical>
              <Stack.Item>
                <Box style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
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
                      DESIGNATION:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{ color: C.textBright, fontWeight: 'bold' }}
                    >
                      {scp_id || antag_name}
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
                      CLASS:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: getClassColor(scp_class),
                        fontWeight: 'bold',
                      }}
                    >
                      {scp_class?.toUpperCase() || 'EUCLID'}
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
                      STATUS:{' '}
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: getStatusColor(containment_status),
                        fontWeight: 'bold',
                      }}
                    >
                      {containment_status?.toUpperCase() || 'ACTIVE'}
                    </Box>
                  </Box>
                </Box>
              </Stack.Item>

              {!!lore_text && (
                <>
                  <Stack.Item>
                    <Box
                      style={{
                        borderBottom: `1px solid ${C.border}`,
                        margin: '10px 0',
                      }}
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Box
                      style={{
                        color: C.amber,
                        fontWeight: 'bold',
                        letterSpacing: '0.1em',
                        fontSize: '11px',
                        textTransform: 'uppercase',
                        marginBottom: '6px',
                      }}
                    >
                      ENTITY BRIEFING
                    </Box>
                    <Box
                      style={{
                        color: C.text,
                        padding: '6px 10px',
                        borderLeft: `2px solid ${C.borderRed}`,
                        lineHeight: '1.5',
                      }}
                    >
                      {lore_text}
                    </Box>
                  </Stack.Item>
                </>
              )}

              {!!abilities?.length && (
                <>
                  <Stack.Item>
                    <Box
                      style={{
                        borderBottom: `1px solid ${C.border}`,
                        margin: '10px 0',
                      }}
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Box
                      style={{
                        color: C.amber,
                        fontWeight: 'bold',
                        letterSpacing: '0.1em',
                        fontSize: '11px',
                        textTransform: 'uppercase',
                        marginBottom: '6px',
                      }}
                    >
                      ANOMALOUS ABILITIES
                    </Box>
                    {abilities.map((ability) => (
                      <Box
                        key={ability.name}
                        style={{
                          padding: '4px 0',
                          borderLeft: `2px solid ${C.border}`,
                          paddingLeft: '8px',
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
                          {ability.name}
                          <Box
                            as="span"
                            style={{
                              color: C.textDim,
                              fontWeight: 'normal',
                              fontSize: '10px',
                              marginLeft: '8px',
                            }}
                          >
                            CD: {ability.cooldown}
                          </Box>
                        </Box>
                        <Box style={{ color: C.textDim, fontSize: '11px' }}>
                          {ability.desc}
                        </Box>
                      </Box>
                    ))}
                  </Stack.Item>
                </>
              )}

              <Stack.Item>
                <Box
                  style={{
                    borderBottom: `1px solid ${C.border}`,
                    margin: '10px 0',
                  }}
                />
              </Stack.Item>

              <Stack.Item>
                <Box
                  style={{
                    color: C.amber,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  OBJECTIVES
                </Box>
                {(!objectives || !objectives.length) && (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      padding: '4px 0',
                    }}
                  >
                    No objectives assigned.
                  </Box>
                )}
                {objectives?.map((objective) => (
                  <Box
                    key={objective.count}
                    style={{
                      padding: '4px 0',
                      borderLeft: `2px solid ${
                        objective.complete ? C.green : C.borderRed
                      }`,
                      paddingLeft: '8px',
                      marginBottom: '4px',
                    }}
                  >
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        marginRight: '6px',
                      }}
                    >
                      #{objective.count}
                    </Box>
                    <Box as="span" style={{ color: C.textBright }}>
                      {objective.explanation}
                    </Box>
                  </Box>
                ))}
              </Stack.Item>
            </Stack>
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
              SCP FOUNDATION | ANOMALOUS ENTITY | SECURE CONTAIN PROTECT |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
