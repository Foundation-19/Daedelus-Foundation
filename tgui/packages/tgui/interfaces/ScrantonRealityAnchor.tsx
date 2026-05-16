import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  active: BooleanLike;
  integrity: number;
  max_integrity: number;
  field_radius: number;
  field_strength: number;
  power_usage: number;
  stabilized_entities: number;
};

export const ScrantonRealityAnchor = (props) => {
  const { act, data } = useBackend<Data>();
  const { active, integrity, max_integrity, field_radius, field_strength, power_usage, stabilized_entities } = data;

  const integrityPercent = max_integrity > 0 ? (integrity / max_integrity) * 100 : 0;
  const integrityColor = integrityPercent > 75 ? '#1a7a1a' : integrityPercent > 25 ? '#d4a017' : '#8b0000';

  return (
    <Window theme="scp_terminal" width={450} height={480}>
      <Window.Content scrollable>
        <Section title="SCRANTON REALITY ANCHOR">
          <Box
            style={{
              fontFamily: 'monospace',
              color: active ? '#1a7a1a' : '#555560',
              fontSize: '16px',
              fontWeight: 'bold',
              textAlign: 'center',
              padding: '10px',
              background: active ? 'rgba(26,122,26,0.15)' : 'rgba(20,20,25,0.8)',
              border: `1px solid ${active ? '#1a7a1a' : '#2a2a30'}`,
              marginBottom: '8px',
            }}
          >
            {active ? 'ANCHOR ACTIVE — REALITY FIELD STABLE' : 'ANCHOR OFFLINE'}
          </Box>
        </Section>
        <Section title="SYSTEM STATUS">
          <LabeledList>
            <LabeledList.Item label="Power">
              {active ? (
                <Box style={{ color: '#1a7a1a', fontFamily: 'monospace' }}>ONLINE</Box>
              ) : (
                <Box style={{ color: '#8b0000', fontFamily: 'monospace' }}>OFFLINE</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Integrity">
              <Box style={{ color: integrityColor, fontFamily: 'monospace', fontWeight: 'bold' }}>
                {integrity}/{max_integrity} ({integrityPercent.toFixed(1)}%)
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Field Radius">
              <Box style={{ color: '#d4a017', fontFamily: 'monospace' }}>
                {field_radius}m
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Field Strength">
              <Box style={{ color: '#d4a017', fontFamily: 'monospace' }}>
                {field_strength} Hume
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Power Draw">
              <Box style={{ color: '#555560', fontFamily: 'monospace' }}>
                {power_usage} W
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Stabilized Entities">
              <Box style={{ color: stabilized_entities > 0 ? '#1a7a1a' : '#555560', fontFamily: 'monospace' }}>
                {stabilized_entities}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="CONTROLS">
          <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            <Button
              onClick={() => act('toggle_power')}
              style={{
                fontFamily: 'monospace',
                background: active ? 'rgba(139,0,0,0.3)' : 'rgba(26,122,26,0.3)',
                border: `1px solid ${active ? '#8b0000' : '#1a7a1a'}`,
                color: active ? '#cc2222' : '#44ff44',
                padding: '6px 12px',
                fontWeight: 'bold',
              }}
            >
              {active ? 'DEACTIVATE' : 'ACTIVATE'}
            </Button>
          </Box>
        </Section>
        <Section title="FIELD PARAMETERS">
          <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            {[1, 2, 3, 5, 8, 10].map((radius) => (
              <Button
                key={radius}
                onClick={() => act('set_radius', { radius })}
                disabled={!active}
                style={{
                  fontFamily: 'monospace',
                  background: field_radius === radius
                    ? 'rgba(212,160,23,0.3)'
                    : 'rgba(20,20,25,0.8)',
                  border: `1px solid ${field_radius === radius ? '#d4a017' : '#2a2a30'}`,
                  color: field_radius === radius ? '#d4a017' : '#c8c8c8',
                  padding: '6px 12px',
                }}
              >
                {radius}m
              </Button>
            ))}
          </Box>
          <Box style={{ marginTop: '8px', display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            {[50, 75, 100, 125, 150].map((strength) => (
              <Button
                key={strength}
                onClick={() => act('set_strength', { strength })}
                disabled={!active}
                style={{
                  fontFamily: 'monospace',
                  background: field_strength === strength
                    ? 'rgba(212,160,23,0.3)'
                    : 'rgba(20,20,25,0.8)',
                  border: `1px solid ${field_strength === strength ? '#d4a017' : '#2a2a30'}`,
                  color: field_strength === strength ? '#d4a017' : '#c8c8c8',
                  padding: '6px 12px',
                }}
              >
                {strength}H
              </Button>
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
