import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  gate_id: string;
  gate_open: BooleanLike;
  authorized: BooleanLike;
  one_way: BooleanLike;
};

export const FoundationGateControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { gate_id, gate_open, authorized, one_way } = data;

  return (
    <Window theme="scp_terminal" width={400} height={300}>
      <Window.Content scrollable>
        <Section title="FOUNDATION GATE CONTROL">
          <Box
            style={{
              fontFamily: 'monospace',
              color: '#d4a017',
              fontSize: '12px',
              marginBottom: '8px',
              padding: '8px',
              background: 'rgba(20,20,25,0.8)',
              border: '1px solid #2a2a30',
            }}
          >
            GATE ID: {gate_id || 'UNKNOWN'}
          </Box>
          <LabeledList>
            <LabeledList.Item label="Gate Status">
              {gate_open ? (
                <Box style={{ color: '#8b0000', fontFamily: 'monospace', fontWeight: 'bold', fontSize: '16px' }}>
                  OPEN
                </Box>
              ) : (
                <Box style={{ color: '#1a7a1a', fontFamily: 'monospace', fontWeight: 'bold', fontSize: '16px' }}>
                  SEALED
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Authorization">
              {authorized ? (
                <Box style={{ color: '#1a7a1a', fontFamily: 'monospace' }}>
                  AUTHORIZED
                </Box>
              ) : (
                <Box style={{ color: '#8b0000', fontFamily: 'monospace' }}>
                  LOCKED
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Direction">
              <Box style={{ color: '#555560', fontFamily: 'monospace' }}>
                {one_way ? 'ONE-WAY' : 'TWO-WAY'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="CONTROLS">
          <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            <Button
              onClick={() => act('toggle_gate')}
              disabled={!authorized}
              style={{
                fontFamily: 'monospace',
                background: gate_open
                  ? 'rgba(26,122,26,0.3)'
                  : 'rgba(139,0,0,0.3)',
                border: `1px solid ${gate_open ? '#1a7a1a' : '#8b0000'}`,
                color: gate_open ? '#44ff44' : '#cc2222',
                padding: '6px 12px',
                fontWeight: 'bold',
              }}
            >
              {gate_open ? 'CLOSE GATE' : 'OPEN GATE'}
            </Button>
            <Button
              onClick={() => act('toggle_lock')}
              style={{
                fontFamily: 'monospace',
                background: authorized
                  ? 'rgba(26,122,26,0.3)'
                  : 'rgba(139,0,0,0.3)',
                border: `1px solid ${authorized ? '#1a7a1a' : '#8b0000'}`,
                color: authorized ? '#44ff44' : '#cc2222',
                padding: '6px 12px',
              }}
            >
              LOCK: {authorized ? 'UNLOCKED' : 'LOCKED'}
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
