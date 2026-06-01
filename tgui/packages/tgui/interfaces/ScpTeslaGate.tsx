import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  gate_state: number;
  damage: number;
  cooldown_active: BooleanLike;
  cooldown_remaining: number;
  auto_mode: BooleanLike;
  has_linked: BooleanLike;
  linked_active: BooleanLike;
  power_available: BooleanLike;
};

const STATE_NAMES = ['INACTIVE', 'ACTIVE', 'OVERLOADED'];
const STATE_COLORS = ['#1a7a1a', '#8b0000', '#cc2222'];

export const ScpTeslaGate = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    gate_state,
    damage,
    cooldown_active,
    cooldown_remaining,
    auto_mode,
    has_linked,
    linked_active,
    power_available,
  } = data;

  return (
    <NtosWindow width={400} height={350}>
      <NtosWindow.Content scrollable>
        <Section title="TESLA GATE CONTROL">
          <LabeledList>
            <LabeledList.Item label="Status">
              <Box
                style={{
                  color: STATE_COLORS[gate_state],
                  fontWeight: 'bold',
                  fontFamily: 'monospace',
                  fontSize: '16px',
                }}
              >
                {STATE_NAMES[gate_state]}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Damage Output">
              {damage} burn
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              {power_available ? (
                <Box style={{ color: '#44ff44' }}>AVAILABLE</Box>
              ) : (
                <Box style={{ color: '#cc2222' }}>NO POWER</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Linked Gate">
              {has_linked ? (
                linked_active ? (
                  <Box style={{ color: '#8b0000' }}>ACTIVE</Box>
                ) : (
                  <Box style={{ color: '#1a7a1a' }}>STANDBY</Box>
                )
              ) : (
                <Box style={{ color: '#555560' }}>NONE</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Auto Mode">
              {auto_mode ? 'ENABLED' : 'DISABLED'}
            </LabeledList.Item>
            {cooldown_active && (
              <LabeledList.Item label="Cooldown">
                {Math.ceil(cooldown_remaining / 10)}s
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section title="CONTROLS">
          <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            <Button
              onClick={() => act('activate')}
              disabled={gate_state !== 0 || !power_available}
              style={{
                fontFamily: 'monospace',
                background: 'rgba(139,0,0,0.3)',
                border: '1px solid #8b0000',
                color: gate_state === 0 ? '#cc2222' : '#555560',
                padding: '6px 12px',
              }}
            >
              ACTIVATE
            </Button>
            <Button
              onClick={() => act('deactivate')}
              disabled={gate_state === 0}
              style={{
                fontFamily: 'monospace',
                background: 'rgba(26,122,26,0.3)',
                border: '1px solid #1a7a1a',
                color: gate_state !== 0 ? '#44ff44' : '#555560',
                padding: '6px 12px',
              }}
            >
              DEACTIVATE
            </Button>
            <Button
              onClick={() => act('overload')}
              disabled={gate_state !== 0 || !power_available}
              style={{
                fontFamily: 'monospace',
                background: 'rgba(204,34,34,0.3)',
                border: '1px solid #cc2222',
                color: gate_state === 0 ? '#ff4444' : '#555560',
                padding: '6px 12px',
                fontWeight: 'bold',
              }}
            >
              OVERLOAD
            </Button>
            <Button
              onClick={() => act('toggle_auto')}
              style={{
                fontFamily: 'monospace',
                background: auto_mode
                  ? 'rgba(26,122,26,0.3)'
                  : 'transparent',
                border: `1px solid ${auto_mode ? '#1a7a1a' : '#2a2a30'}`,
                color: auto_mode ? '#44ff44' : '#c8c8c8',
                padding: '6px 12px',
              }}
            >
              AUTO: {auto_mode ? 'ON' : 'OFF'}
            </Button>
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
