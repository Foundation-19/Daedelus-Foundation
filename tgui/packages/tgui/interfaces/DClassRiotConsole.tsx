import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type RiotData = {
  riot_active: BooleanLike;
  stage: number;
  demands: string[];
  met_demands: string[];
  rioting_count: number;
  negotiation_progress: number;
  suppression_progress: number;
  escalation_timer: number;
  has_negotiator: BooleanLike;
  partial_win: BooleanLike;
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

const STAGE_LABELS = [
  'No Riot',
  'Unrest',
  'Protest',
  'Riot',
  'Uprising',
  'Full Revolt',
];

const stageColor = (stage: number) => {
  if (stage <= 1) return C.green;
  if (stage <= 2) return C.amber;
  return C.redBright;
};

const ProgressBar = (props: { value: number; max?: number; color?: string }) => {
  const { value, max = 100, color = C.redBright } = props;
  const pct = Math.min(100, Math.max(0, (value / max) * 100));
  return (
    <Box
      style={{
        background: C.panel,
        border: `1px solid ${C.border}`,
        height: '14px',
        position: 'relative',
        borderRadius: '2px',
      }}
    >
      <Box
        style={{
          background: color,
          height: '100%',
          width: `${pct}%`,
          borderRadius: '2px',
          transition: 'width 0.3s',
        }}
      />
      <Box
        style={{
          position: 'absolute',
          top: '0',
          left: '50%',
          transform: 'translateX(-50%)',
          fontSize: '10px',
          lineHeight: '14px',
          color: C.textBright,
          fontFamily: C.mono,
        }}
      >
        {Math.round(pct)}%
      </Box>
    </Box>
  );
};

export const DClassRiotConsole = (props) => {
  const { act, data } = useBackend<RiotData>();
  const {
    riot_active,
    stage,
    demands,
    met_demands,
    rioting_count,
    negotiation_progress,
    suppression_progress,
    escalation_timer,
    has_negotiator,
    partial_win,
  } = data;

  const escalateSecs = Math.max(0, Math.ceil(escalation_timer / 10));

  return (
    <Window theme="scp_terminal" width={520} height={580}>
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
              background:
                'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '2px',
              }}
            >
              D-CLASS RIOT CONTROL
            </Box>
            <Box
              style={{
                fontSize: '10px',
                color: C.textDim,
                marginTop: '2px',
              }}
            >
              FACILITY SECURITY TERMINAL — AUTHORIZED PERSONNEL ONLY
            </Box>
          </Box>

          {!riot_active && (
            <Box style={{ padding: '40px 14px', textAlign: 'center' }}>
              <Box
                style={{
                  color: C.greenBright,
                  fontSize: '16px',
                  fontWeight: 'bold',
                }}
              >
                NO ACTIVE RIOT
              </Box>
              <Box
                style={{ color: C.textDim, marginTop: '8px', fontSize: '11px' }}
              >
                All D-Class personnel are compliant. System monitoring.
              </Box>
            </Box>
          )}

          {riot_active && (
            <>
              <Box style={{ padding: '10px 14px' }}>
                <Stack vertical>
                  <Stack.Item>
                    <Box
                      style={{
                        color: stageColor(stage),
                        fontSize: '13px',
                        fontWeight: 'bold',
                      }}
                    >
                      ALERT LEVEL: {STAGE_LABELS[stage] || 'UNKNOWN'}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box style={{ color: C.text, fontSize: '11px' }}>
                      Rioting D-Class: <b>{rioting_count}</b>
                      {' | '}Negotiator: {has_negotiator ? 'ASSIGNED' : 'NONE'}
                      {partial_win && (
                        <Box
                          as="span"
                          style={{ color: C.amber, marginLeft: '8px' }}
                        >
                          PARTIAL COMPLIANCE
                        </Box>
                      )}
                    </Box>
                  </Stack.Item>
                  {escalation_timer > 0 && (
                    <Stack.Item>
                      <Box
                        style={{ color: C.redBright, fontSize: '11px' }}
                      >
                        ESCALATION IN: {escalateSecs}s
                      </Box>
                    </Stack.Item>
                  )}
                </Stack>
              </Box>

              <Box
                style={{
                  borderTop: `1px solid ${C.border}`,
                  borderBottom: `1px solid ${C.border}`,
                  padding: '10px 14px',
                  background: C.panel,
                }}
              >
                <Box
                  style={{
                    fontSize: '11px',
                    fontWeight: 'bold',
                    color: C.amber,
                    marginBottom: '6px',
                  }}
                >
                  SUPPRESSION PROGRESS
                </Box>
                <ProgressBar
                  value={suppression_progress}
                  color={C.redBright}
                />

                <Box
                  style={{
                    fontSize: '11px',
                    fontWeight: 'bold',
                    color: C.green,
                    marginTop: '10px',
                    marginBottom: '6px',
                  }}
                >
                  NEGOTIATION PROGRESS
                </Box>
                <ProgressBar
                  value={negotiation_progress}
                  color={C.greenBright}
                />
              </Box>

              {demands.length > 0 && (
                <Box style={{ padding: '10px 14px' }}>
                  <Box
                    style={{
                      fontSize: '11px',
                      fontWeight: 'bold',
                      color: C.amber,
                      marginBottom: '6px',
                    }}
                  >
                    D-CLASS DEMANDS
                  </Box>
                  <Stack vertical>
                    {demands.map((demand) => {
                      const met = met_demands.includes(demand);
                      return (
                        <Stack.Item key={demand}>
                          <Box
                            style={{
                              background: C.panel,
                              border: `1px solid ${met ? C.green : C.border}`,
                              padding: '6px 8px',
                              borderRadius: '2px',
                            }}
                          >
                            <Stack>
                              <Stack.Item grow>
                                <Box
                                  style={{
                                    color: met ? C.greenBright : C.text,
                                    textDecoration: met
                                      ? 'line-through'
                                      : 'none',
                                    fontSize: '11px',
                                  }}
                                >
                                  {met ? '[MET] ' : ''}
                                  {demand}
                                </Box>
                              </Stack.Item>
                              {!met && (
                                <Stack.Item>
                                  <Button
                                    fluid
                                    content="GRANT"
                                    fontSize="10px"
                                    color="green"
                                    onClick={() =>
                                      act('meet_demand', { demand })
                                    }
                                  />
                                </Stack.Item>
                              )}
                            </Stack>
                          </Box>
                        </Stack.Item>
                      );
                    })}
                  </Stack>
                </Box>
              )}

              <Box
                style={{
                  borderTop: `1px solid ${C.border}`,
                  padding: '10px 14px',
                }}
              >
                <Box
                  style={{
                    fontSize: '11px',
                    fontWeight: 'bold',
                    color: C.amber,
                    marginBottom: '8px',
                  }}
                >
                  ACTIONS
                </Box>
                <Stack>
                  <Stack.Item grow>
                    <Button
                      fluid
                      content="NEGOTIATE"
                      icon="comments"
                      fontSize="11px"
                      color="green"
                      onClick={() => act('negotiate')}
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button
                      fluid
                      content="ACCEPT DEMANDS"
                      icon="check"
                      fontSize="11px"
                      color="green"
                      onClick={() => act('accept_demands')}
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item grow>
                    <Button
                      fluid
                      content="AUTHORIZE SUPPRESSION"
                      icon="shield-alt"
                      fontSize="11px"
                      color="red"
                      onClick={() => act('authorize_suppression')}
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button
                      fluid
                      content="REJECT DEMANDS"
                      icon="times"
                      fontSize="11px"
                      color="red"
                      onClick={() => act('reject_demands')}
                    />
                  </Stack.Item>
                </Stack>
              </Box>
            </>
          )}

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '6px 14px',
              fontSize: '9px',
              color: C.textDim,
              textAlign: 'center',
            }}
          >
            SCP FOUNDATION — SECURITY DIVISION — RIOT CONTROL SYSTEM v2.1
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
