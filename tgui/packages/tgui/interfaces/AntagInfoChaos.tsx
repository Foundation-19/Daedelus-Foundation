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

type ChaosInfo = {
  antag_name: string;
  objectives: Objective[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderGreen: '#1a7a1a',
  green: '#1a7a1a',
  greenBright: '#2ecc40',
  amber: '#d4a017',
  red: '#8b0000',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

export const AntagInfoChaos = (props) => {
  const { data } = useBackend<ChaosInfo>();
  const { antag_name, objectives } = data;

  return (
    <Window theme="scp_terminal" width={620} height={520}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderGreen}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderGreen}`,
              padding: '10px 14px 8px',
              background:
                'linear-gradient(180deg, #0a1a0a 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.greenBright,
                letterSpacing: '0.18em',
              }}
            >
              CHAOS INSURGENCY — COVERT OPERATIVE
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLASSIFIED | INSURGENCY EYES ONLY | OPERATION ACTIVE
            </Box>
          </Box>

          <Box style={{ padding: '12px 14px' }}>
            <Box
              style={{
                fontSize: '18px',
                fontWeight: 'bold',
                color: C.greenBright,
                letterSpacing: '0.08em',
                marginBottom: '8px',
                textShadow: '0 0 0.4em rgba(46,204,64,0.4)',
              }}
            >
              YOU ARE {antag_name?.toUpperCase() || 'CHAOS INSURGENT'}
            </Box>

            <Stack vertical>
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
                    color: C.greenBright,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  MISSION BRIEFING
                </Box>
                <Box
                  style={{
                    color: C.text,
                    padding: '6px 10px',
                    borderLeft: `2px solid ${C.borderGreen}`,
                    lineHeight: '1.5',
                  }}
                >
                  You are a covert operative of the Chaos Insurgency, a rogue
                  splinter faction that defected from the SCP Foundation with one
                  purpose: to tear it down from the inside. The Foundation hoards
                  anomalies behind concrete and protocol — they call it
                  &quot;containment.&quot; We call it waste. Every SCP locked in a
                  cell is a weapon unused, a tool untapped, a future unwritten.
                  Your mission is threefold: destabilize Foundation operations,
                  acquire anomalous objects by any means necessary, and extract
                  your team when the job is done. Military precision is
                  non-negotiable. You are not a rogue element — you are the
                  scalpel that cuts the tumor from the body politic. The
                  Insurgency does not forgive failure. Complete your objectives.
                  Leave no trace. The Foundation will not see you coming.
                </Box>
              </Stack.Item>

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
                    color: C.greenBright,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  INSURGENCY PROTOCOLS
                </Box>
                <Box
                  style={{
                    color: C.text,
                    padding: '6px 10px',
                    borderLeft: `2px solid ${C.borderGreen}`,
                    lineHeight: '1.5',
                  }}
                >
                  As a Chaos Insurgency operative, you have access to specialized
                  equipment caches and covert communication channels. Your
                  embedded handlers will provide mission-critical intelligence as
                  situations develop. Maintain operational security at all times
                  — compromised operatives are considered expendable. Equipment
                  requisition is available through your assigned dead-drop
                  locations. Coordinate with fellow operatives using encrypted
                  channels. Remember: the mission always takes priority over
                  individual survival.
                </Box>
              </Stack.Item>

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
                    color: C.greenBright,
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
                        objective.complete ? C.green : C.borderGreen
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
              CHAOS INSURGENCY | DISRUPT | ACQUIRE | EXTRACT
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
