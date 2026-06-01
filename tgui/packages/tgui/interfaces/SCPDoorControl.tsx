import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { NtosWindow } from '../layouts';

type ZoneState = {
  name: string;
  state: number;
  state_name: string;
};

type LogEntry = {
  text: string;
  time: string;
};

type DoorControlData = {
  door_log: LogEntry[];
  locked_doors: number;
  total_doors: number;
  zone_states: ZoneState[];
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

const STATE_COLORS: Record<string, string> = {
  Normal: C.green,
  Locked: C.amber,
  'Forced Open': C.redBright,
  Bolted: C.redBright,
};

export const SCPDoorControl = (props) => {
  const { act, data } = useBackend<DoorControlData>();
  const { zone_states, total_doors, locked_doors, door_log } = data;

  return (
    <NtosWindow width={600} height={500}>
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
              SCP DOOR CONTROL
            </Box>
            <Box
              style={{
                fontSize: '11px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              {total_doors} DOORS MONITORED | {locked_doors} LOCKED
            </Box>
          </Box>

          <Box style={{ padding: '14px' }}>
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
              ZONE CONTROLS
            </Box>

            {(zone_states || []).map((zone) => (
              <Box
                key={zone.name}
                style={{
                  marginBottom: '6px',
                  padding: '8px',
                  borderLeft: `2px solid ${STATE_COLORS[zone.state_name] || C.border}`,
                  background: C.panel,
                }}
              >
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: '6px',
                  }}
                >
                  <Box
                    style={{
                      color: C.textBright,
                      fontWeight: 'bold',
                      fontSize: '12px',
                    }}
                  >
                    {zone.name.toUpperCase()}
                  </Box>
                  <Box
                    style={{
                      color: STATE_COLORS[zone.state_name] || C.textDim,
                      fontSize: '10px',
                      fontWeight: 'bold',
                      letterSpacing: '0.1em',
                    }}
                  >
                    {zone.state_name.toUpperCase()}
                  </Box>
                </Box>
                <Box style={{ display: 'flex', gap: '4px' }}>
                  <Button
                    onClick={() =>
                      act('set_zone_state', {
                        zone: zone.name,
                        state: 0,
                      })
                    }
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      letterSpacing: '0.1em',
                      background:
                        zone.state === 0
                          ? 'rgba(26,122,26,0.3)'
                          : 'transparent',
                      border: `1px solid ${zone.state === 0 ? C.green : C.border}`,
                      borderRadius: 0,
                      color: zone.state === 0 ? C.textBright : C.textDim,
                      padding: '4px 8px',
                    }}
                  >
                    NORMAL
                  </Button>
                  <Button
                    onClick={() =>
                      act('set_zone_state', {
                        zone: zone.name,
                        state: 1,
                      })
                    }
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      letterSpacing: '0.1em',
                      background:
                        zone.state === 1
                          ? 'rgba(212,160,23,0.3)'
                          : 'transparent',
                      border: `1px solid ${zone.state === 1 ? C.amber : C.border}`,
                      borderRadius: 0,
                      color: zone.state === 1 ? C.textBright : C.textDim,
                      padding: '4px 8px',
                    }}
                  >
                    LOCK
                  </Button>
                  <Button
                    onClick={() =>
                      act('set_zone_state', {
                        zone: zone.name,
                        state: 2,
                      })
                    }
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      letterSpacing: '0.1em',
                      background:
                        zone.state === 2
                          ? 'rgba(204,34,34,0.3)'
                          : 'transparent',
                      border: `1px solid ${zone.state === 2 ? C.redBright : C.border}`,
                      borderRadius: 0,
                      color: zone.state === 2 ? C.textBright : C.textDim,
                      padding: '4px 8px',
                    }}
                  >
                    FORCE OPEN
                  </Button>
                  <Button
                    onClick={() =>
                      act('set_zone_state', {
                        zone: zone.name,
                        state: 3,
                      })
                    }
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      letterSpacing: '0.1em',
                      background:
                        zone.state === 3
                          ? 'rgba(139,0,0,0.3)'
                          : 'transparent',
                      border: `1px solid ${zone.state === 3 ? C.red : C.border}`,
                      borderRadius: 0,
                      color: zone.state === 3 ? C.textBright : C.textDim,
                      padding: '4px 8px',
                    }}
                  >
                    BOLT
                  </Button>
                  <Button
                    onClick={() =>
                      act('cycle_airlock', { zone: zone.name })
                    }
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      letterSpacing: '0.1em',
                      background: 'transparent',
                      border: `1px solid ${C.border}`,
                      borderRadius: 0,
                      color: C.textDim,
                      padding: '4px 8px',
                    }}
                  >
                    CYCLE
                  </Button>
                </Box>
              </Box>
            ))}

            <Box
              style={{
                color: C.borderRed,
                fontSize: '10px',
                letterSpacing: '0.3em',
                margin: '12px 0',
                userSelect: 'none',
                overflow: 'hidden',
                whiteSpace: 'nowrap',
              }}
            >
              {'─'.repeat(50)}
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
              EMERGENCY ACTIONS
            </Box>

            <Box style={{ display: 'flex', gap: '6px' }}>
              <Button
                onClick={() => act('emergency_open_all')}
                style={{
                  fontFamily: C.mono,
                  fontSize: '10px',
                  letterSpacing: '0.1em',
                  background: 'rgba(204,34,34,0.25)',
                  border: `1px solid ${C.redBright}`,
                  borderRadius: 0,
                  color: C.textBright,
                  padding: '6px 12px',
                }}
              >
                EMERGENCY OPEN ALL
              </Button>
              <Button
                onClick={() => act('emergency_lock_all')}
                style={{
                  fontFamily: C.mono,
                  fontSize: '10px',
                  letterSpacing: '0.1em',
                  background: 'rgba(139,0,0,0.35)',
                  border: `1px solid ${C.red}`,
                  borderRadius: 0,
                  color: C.textBright,
                  padding: '6px 12px',
                }}
              >
                EMERGENCY LOCK ALL
              </Button>
            </Box>

            {(door_log || []).length > 0 && (
              <>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginTop: '14px',
                    marginBottom: '8px',
                  }}
                >
                  ACCESS LOG
                </Box>
                {door_log.map((entry, idx) => (
                  <Box
                    key={`log-${idx}`}
                    style={{
                      marginBottom: '2px',
                      padding: '4px 8px',
                      borderLeft: `2px solid ${C.border}`,
                      background: C.panel,
                      fontSize: '10px',
                      display: 'flex',
                      gap: '6px',
                    }}
                  >
                    <Box style={{ color: C.textDim, whiteSpace: 'nowrap' }}>
                      [{entry.time}]
                    </Box>
                    <Box style={{ color: C.text }}>{entry.text}</Box>
                  </Box>
                ))}
              </>
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
                fontSize: '11px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | DOOR CONTROL | ALL ACTIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
