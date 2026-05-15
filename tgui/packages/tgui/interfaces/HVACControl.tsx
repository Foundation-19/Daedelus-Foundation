import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type ZoneData = {
  name: string;
  vents_active: number;
  vents_total: number;
  scrubbers_active: number;
  scrubbers_total: number;
};

type Data = {
  zones: ZoneData[];
};

export const HVACControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { zones } = data;

  return (
    <Window theme="scp_terminal" width={500} height={450}>
      <Window.Content scrollable>
        <Section title="HVAC CONTROL SYSTEM">
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
            ENVIRONMENTAL CONTROL — VENTILATION & SCRUBBER MANAGEMENT
          </Box>
        </Section>
        <Section title="ZONE STATUS">
          {zones && zones.length > 0 ? (
            zones.map((zone, index) => (
              <Box
                key={index}
                style={{
                  background: 'rgba(20,20,25,0.8)',
                  border: '1px solid #2a2a30',
                  padding: '10px',
                  marginBottom: '8px',
                  fontFamily: 'monospace',
                }}
              >
                <Box style={{ color: '#d4a017', fontWeight: 'bold', fontSize: '14px', marginBottom: '6px' }}>
                  {zone.name}
                </Box>
                <LabeledList>
                  <LabeledList.Item label="Vents">
                    <Box style={{ color: zone.vents_active > 0 ? '#1a7a1a' : '#555560' }}>
                      {zone.vents_active}/{zone.vents_total} ACTIVE
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Scrubbers">
                    <Box style={{ color: zone.scrubbers_active > 0 ? '#1a7a1a' : '#555560' }}>
                      {zone.scrubbers_active}/{zone.scrubbers_total} ACTIVE
                    </Box>
                  </LabeledList.Item>
                </LabeledList>
                <Box style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                  <Button
                    onClick={() => act('toggle_vents', { zone: zone.name })}
                    style={{
                      fontFamily: 'monospace',
                      background: zone.vents_active > 0
                        ? 'rgba(26,122,26,0.3)'
                        : 'rgba(20,20,25,0.8)',
                      border: `1px solid ${zone.vents_active > 0 ? '#1a7a1a' : '#2a2a30'}`,
                      color: zone.vents_active > 0 ? '#44ff44' : '#c8c8c8',
                      padding: '6px 12px',
                    }}
                  >
                    VENTS: {zone.vents_active > 0 ? 'ON' : 'OFF'}
                  </Button>
                  <Button
                    onClick={() => act('toggle_scrubbers', { zone: zone.name })}
                    style={{
                      fontFamily: 'monospace',
                      background: zone.scrubbers_active > 0
                        ? 'rgba(26,122,26,0.3)'
                        : 'rgba(20,20,25,0.8)',
                      border: `1px solid ${zone.scrubbers_active > 0 ? '#1a7a1a' : '#2a2a30'}`,
                      color: zone.scrubbers_active > 0 ? '#44ff44' : '#c8c8c8',
                      padding: '6px 12px',
                    }}
                  >
                    SCRUBBERS: {zone.scrubbers_active > 0 ? 'ON' : 'OFF'}
                  </Button>
                </Box>
              </Box>
            ))
          ) : (
            <Box style={{ color: '#555560', fontFamily: 'monospace' }}>
              NO ZONES DETECTED
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
