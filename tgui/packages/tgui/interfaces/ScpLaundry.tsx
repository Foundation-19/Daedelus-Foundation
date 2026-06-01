import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  running: boolean;
  item_count: number;
  max_items: number;
  anomalous_cleanse: boolean;
  time_remaining: number;
};

export const ScpLaundry = (props) => {
  const { act, data } = useBackend<Data>();
  const { running, item_count, max_items, anomalous_cleanse, time_remaining } = data;

  return (
    <NtosWindow width={400} height={320}>
      <NtosWindow.Content scrollable>
        <Section title="FOUNDATION LAUNDRY UNIT">
          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#6a6a70',
              letterSpacing: '0.1em',
              marginBottom: '10px',
            }}
          >
            SCP FOUNDATION — ANOMALOUS DECONTAMINATION SERVICES
          </Box>

          <Box style={{ display: 'flex', gap: '16px', marginBottom: '12px' }}>
            <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#c8c8c8' }}>
              LOADED: {item_count}/{max_items}
            </Box>
            {running && (
              <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#d4a017' }}>
                CYCLE: {time_remaining}s REMAINING
              </Box>
            )}
          </Box>
        </Section>

        {!running && item_count > 0 && (
          <Section title="SELECT CYCLE">
            <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  padding: '8px 10px',
                  borderLeft: '2px solid #4488ff',
                  background: '#111114',
                }}
              >
                <Box>
                  <Box
                    style={{
                      color: '#4488ff',
                      fontWeight: 'bold',
                      fontSize: '12px',
                      fontFamily: 'monospace',
                    }}
                  >
                    STANDARD WASH
                  </Box>
                  <Box style={{ fontSize: '9px', color: '#6a6a70' }}>
                    Clean clothing and bedding. Removes dirt and stains.
                  </Box>
                </Box>
                <Button
                  onClick={() => act('start_standard')}
                  style={{
                    fontFamily: 'monospace',
                    fontSize: '9px',
                    background: 'rgba(68,136,255,0.1)',
                    border: '1px solid #4488ff',
                    color: '#4488ff',
                    padding: '4px 10px',
                  }}
                >
                  START
                </Button>
              </Box>

              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  padding: '8px 10px',
                  borderLeft: '2px solid #44ff44',
                  background: '#111114',
                }}
              >
                <Box>
                  <Box
                    style={{
                      color: '#44ff44',
                      fontWeight: 'bold',
                      fontSize: '12px',
                      fontFamily: 'monospace',
                    }}
                  >
                    ANOMALOUS DECON WASH
                  </Box>
                  <Box style={{ fontSize: '9px', color: '#6a6a70' }}>
                    Remove anomalous residues, SCP-106 corrosion, biohazard traces.
                  </Box>
                </Box>
                <Button
                  onClick={() => act('start_decon')}
                  style={{
                    fontFamily: 'monospace',
                    fontSize: '9px',
                    background: 'rgba(68,255,68,0.1)',
                    border: '1px solid #44ff44',
                    color: '#44ff44',
                    padding: '4px 10px',
                  }}
                >
                  START
                </Button>
              </Box>
            </Box>
          </Section>
        )}

        {!running && item_count > 0 && (
          <Section>
            <Button
              onClick={() => act('eject')}
              style={{
                fontFamily: 'monospace',
                fontSize: '9px',
                background: 'rgba(200,200,200,0.1)',
                border: '1px solid #6a6a70',
                color: '#c8c8c8',
                padding: '4px 10px',
              }}
            >
              EJECT ITEMS
            </Button>
          </Section>
        )}

        {!running && item_count === 0 && (
          <Section>
            <Box
              style={{
                fontFamily: 'monospace',
                fontSize: '11px',
                color: '#6a6a70',
                textAlign: 'center',
                padding: '12px',
              }}
            >
              UNIT EMPTY — LOAD CLOTHING OR BEDDING TO BEGIN
            </Box>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
