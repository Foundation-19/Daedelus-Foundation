import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

type EmergencyType = {
  id: string;
  name: string;
};

type HistoryEntry = {
  text: string;
  time: string;
};

type IntercomData = {
  cooldown_remaining: number;
  emergency_types: EmergencyType[];
  history: HistoryEntry[];
  selected_zone: string;
  zones: string[];
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

export const SCPIntercomConsole = (props) => {
  const { act, data } = useBackend<IntercomData>();
  const [message, setMessage] = useLocalState('intercomMsg', '');
  const {
    selected_zone,
    zones,
    cooldown_remaining,
    emergency_types,
    history,
  } = data;

  const onCooldown = cooldown_remaining > 0;

  return (
    <NtosWindow width={550} height={500}>
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
              SCP INTERCOM / PA SYSTEM
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              BROADCAST ZONE: {selected_zone?.toUpperCase() || 'ALL'}
              {onCooldown &&
                ` | COOLDOWN: ${Math.ceil(cooldown_remaining / 10)}s`}
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
              ZONE SELECTION
            </Box>
            <Box style={{ display: 'flex', gap: '4px', flexWrap: 'wrap', marginBottom: '14px' }}>
              {(zones || []).map((zone) => (
                <Button
                  key={zone}
                  onClick={() => act('set_zone', { zone })}
                  style={{
                    fontFamily: C.mono,
                    fontSize: '9px',
                    letterSpacing: '0.1em',
                    background:
                      selected_zone === zone
                        ? 'rgba(139,0,0,0.3)'
                        : 'transparent',
                    border: `1px solid ${selected_zone === zone ? C.borderRed : C.border}`,
                    borderRadius: 0,
                    color:
                      selected_zone === zone ? C.textBright : C.textDim,
                    padding: '3px 8px',
                  }}
                >
                  {zone.toUpperCase()}
                </Button>
              ))}
            </Box>

            <Box
              style={{
                color: C.borderRed,
                fontSize: '10px',
                letterSpacing: '0.3em',
                margin: '8px 0',
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
              BROADCAST MESSAGE
            </Box>

            <Box style={{ marginBottom: '8px' }}>
              <Input
                value={message}
                onChange={(e, value) => setMessage(value)}
                placeholder="Enter broadcast message..."
                fluid
                style={{
                  fontFamily: C.mono,
                  fontSize: '12px',
                  height: '32px',
                  background: C.panel,
                  border: `1px solid ${C.border}`,
                  color: C.text,
                }}
              />
            </Box>
            <Button
              disabled={onCooldown || !message}
              onClick={() => {
                act('broadcast', { message });
                setMessage('');
              }}
              style={{
                fontFamily: C.mono,
                fontSize: '10px',
                letterSpacing: '0.1em',
                background: onCooldown
                  ? 'transparent'
                  : 'rgba(26,122,26,0.25)',
                border: `1px solid ${onCooldown ? C.border : C.green}`,
                borderRadius: 0,
                color: onCooldown ? C.textDim : C.textBright,
                padding: '6px 14px',
                width: '100%',
              }}
            >
              {onCooldown
                ? `COOLDOWN: ${Math.ceil(cooldown_remaining / 10)}s`
                : 'BROADCAST'}
            </Button>

            <Box
              style={{
                color: C.borderRed,
                fontSize: '10px',
                letterSpacing: '0.3em',
                margin: '14px 0 8px',
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
              EMERGENCY ANNOUNCEMENTS
            </Box>

            <Box style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
              {(emergency_types || []).map((emerg) => (
                <Button
                  key={emerg.id}
                  disabled={onCooldown}
                  onClick={() => act('emergency', { type: emerg.id })}
                  style={{
                    fontFamily: C.mono,
                    fontSize: '9px',
                    letterSpacing: '0.1em',
                    background: onCooldown
                      ? 'transparent'
                      : 'rgba(139,0,0,0.2)',
                    border: `1px solid ${onCooldown ? C.border : C.red}`,
                    borderRadius: 0,
                    color: onCooldown ? C.textDim : C.textBright,
                    padding: '4px 8px',
                  }}
                >
                  {emerg.name.toUpperCase()}
                </Button>
              ))}
            </Box>

            {(history || []).length > 0 && (
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
                  BROADCAST HISTORY
                </Box>
                {history.map((entry, idx) => (
                  <Box
                    key={`hist-${idx}`}
                    style={{
                      marginBottom: '2px',
                      padding: '3px 6px',
                      borderLeft: `2px solid ${C.borderRed}`,
                      background: C.panel,
                      fontSize: '10px',
                      display: 'flex',
                      gap: '6px',
                    }}
                  >
                    <Box
                      style={{ color: C.textDim, whiteSpace: 'nowrap' }}
                    >
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
                fontSize: '9px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | INTERCOM SYSTEM | ALL BROADCASTS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
