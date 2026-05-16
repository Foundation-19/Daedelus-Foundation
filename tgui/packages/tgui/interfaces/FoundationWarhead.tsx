import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  foundation_authorized: BooleanLike;
  foundation_auth_code: string;
  timing: BooleanLike;
  exploding: BooleanLike;
  timer_set: number;
  minimum_timer_set: number;
  maximum_timer_set: number;
  yes_code: string;
};

export const FoundationWarhead = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    foundation_authorized,
    foundation_auth_code,
    timing,
    exploding,
    timer_set,
    minimum_timer_set,
    maximum_timer_set,
    yes_code,
  } = data;

  return (
    <Window theme="scp_terminal" width={500} height={550}>
      <Window.Content scrollable>
        <Section title="SCP FOUNDATION — ON-SITE WARHEAD">
          <Box
            style={{
              fontFamily: 'monospace',
              color: '#cc2222',
              fontSize: '18px',
              fontWeight: 'bold',
              textAlign: 'center',
              padding: '12px',
              background: 'rgba(139,0,0,0.3)',
              border: '2px solid #8b0000',
              marginBottom: '12px',
            }}
          >
            !! WARNING — NUCLEAR WARHEAD SYSTEM !!
          </Box>
          {exploding && (
            <Box
              style={{
                fontFamily: 'monospace',
                color: '#ff4444',
                fontSize: '24px',
                fontWeight: 'bold',
                textAlign: 'center',
                padding: '16px',
                background: 'rgba(204,34,34,0.5)',
                border: '2px solid #ff0000',
                marginBottom: '12px',
                animation: 'blink 1s infinite',
              }}
            >
              *** DETONATION IMMINENT ***
            </Box>
          )}
        </Section>
        <Section title="AUTHORIZATION STATUS">
          <LabeledList>
            <LabeledList.Item label="Foundation Auth">
              {foundation_authorized ? (
                <Box style={{ color: '#1a7a1a', fontFamily: 'monospace', fontWeight: 'bold' }}>
                  AUTHORIZED
                </Box>
              ) : (
                <Box style={{ color: '#8b0000', fontFamily: 'monospace', fontWeight: 'bold' }}>
                  NOT AUTHORIZED
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Auth Code">
              <Box style={{ color: '#d4a017', fontFamily: 'monospace' }}>
                {foundation_auth_code || '—'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Confirmation Code">
              <Box style={{ color: '#d4a017', fontFamily: 'monospace' }}>
                {yes_code || '—'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="TIMER CONTROL">
          <LabeledList>
            <LabeledList.Item label="Timer Status">
              {timing ? (
                <Box style={{ color: '#8b0000', fontFamily: 'monospace', fontWeight: 'bold', fontSize: '16px' }}>
                  ACTIVE — {timer_set}s
                </Box>
              ) : (
                <Box style={{ color: '#1a7a1a', fontFamily: 'monospace' }}>
                  INACTIVE
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Timer Range">
              <Box style={{ color: '#555560', fontFamily: 'monospace' }}>
                {minimum_timer_set}s — {maximum_timer_set}s
              </Box>
            </LabeledList.Item>
          </LabeledList>
          <Box style={{ marginTop: '8px', display: 'flex', gap: '8px', flexWrap: 'wrap', alignItems: 'center' }}>
            <Button
              onClick={() => act('toggle_timer')}
              disabled={!foundation_authorized}
              style={{
                fontFamily: 'monospace',
                background: timing ? 'rgba(26,122,26,0.3)' : 'rgba(139,0,0,0.3)',
                border: `1px solid ${timing ? '#1a7a1a' : '#8b0000'}`,
                color: timing ? '#44ff44' : '#cc2222',
                padding: '6px 12px',
                fontWeight: 'bold',
              }}
            >
              {timing ? 'ABORT TIMER' : 'START TIMER'}
            </Button>
          </Box>
        </Section>
        <Section title="WARHEAD CONTROLS">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
              <Box style={{ color: '#c8c8c8', fontFamily: 'monospace', minWidth: '80px' }}>
                ENTER CODE:
              </Box>
              <Input
                placeholder="Authorization code..."
                onEnter={(e, value) => act('enter_code', { code: value })}
                style={{
                  fontFamily: 'monospace',
                  background: 'rgba(20,20,25,0.8)',
                  border: '1px solid #2a2a30',
                  color: '#d4a017',
                  padding: '4px 8px',
                }}
              />
            </Box>
            <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
              <Button
                onClick={() => act('auth')}
                style={{
                  fontFamily: 'monospace',
                  background: 'rgba(139,0,0,0.3)',
                  border: '1px solid #8b0000',
                  color: '#cc2222',
                  padding: '6px 12px',
                }}
              >
                SUBMIT AUTHORIZATION
              </Button>
              {[60, 120, 180, 300, 600].map((time) => (
                <Button
                  key={time}
                  onClick={() => act('set_timer', { time })}
                  disabled={!foundation_authorized || time < minimum_timer_set || time > maximum_timer_set}
                  style={{
                    fontFamily: 'monospace',
                    background: 'rgba(20,20,25,0.8)',
                    border: '1px solid #2a2a30',
                    color: (time >= minimum_timer_set && time <= maximum_timer_set) ? '#d4a017' : '#555560',
                    padding: '6px 12px',
                  }}
                >
                  {time}s
                </Button>
              ))}
            </Box>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
