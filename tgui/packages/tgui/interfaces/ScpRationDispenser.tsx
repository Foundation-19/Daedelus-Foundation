import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  standard_rations: number;
  improved_rations: number;
  premium_rations: number;
  total_dispensed: number;
};

const RATION_TYPES = [
  {
    key: 'standard',
    label: 'STANDARD RATION',
    desc: 'Mass-produced, meets minimum nutritional requirements.',
    color: '#6a6a70',
  },
  {
    key: 'improved',
    label: 'IMPROVED RATION',
    desc: 'Better quality with actual flavor. D-Class appreciate it.',
    color: '#d4a017',
  },
  {
    key: 'premium',
    label: 'PREMIUM RATION',
    desc: 'A genuinely decent meal. D-Class will notice the difference.',
    color: '#44ff44',
  },
];

export const ScpRationDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const { standard_rations, improved_rations, premium_rations, total_dispensed } = data;

  const stocks: Record<string, number> = {
    standard: standard_rations,
    improved: improved_rations,
    premium: premium_rations,
  };

  return (
    <NtosWindow width={400} height={380}>
      <NtosWindow.Content scrollable>
        <Section title="D-CLASS RATION DISPENSER">
          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#6a6a70',
              letterSpacing: '0.1em',
              marginBottom: '10px',
            }}
          >
            SCP FOUNDATION — NUTRITIONAL SERVICES DIVISION
          </Box>

          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '11px',
              color: '#c8c8c8',
              marginBottom: '12px',
            }}
          >
            TOTAL DISPENSED: {total_dispensed}
          </Box>
        </Section>

        <Section title="AVAILABLE RATIONS">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {RATION_TYPES.map((ration) => {
              const stock = stocks[ration.key] || 0;
              return (
                <Box
                  key={ration.key}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '8px 10px',
                    borderLeft: `2px solid ${stock > 0 ? ration.color : '#2a2a30'}`,
                    background: '#111114',
                  }}
                >
                  <Box>
                    <Box
                      style={{
                        color: stock > 0 ? ration.color : '#555560',
                        fontWeight: 'bold',
                        fontSize: '12px',
                        fontFamily: 'monospace',
                      }}
                    >
                      {ration.label}
                    </Box>
                    <Box style={{ fontSize: '9px', color: '#6a6a70' }}>
                      {ration.desc}
                    </Box>
                  </Box>
                  <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                    <Box
                      style={{
                        fontSize: '10px',
                        color: stock > 0 ? '#c8c8c8' : '#cc2222',
                        fontFamily: 'monospace',
                      }}
                    >
                      STOCK: {stock}
                    </Box>
                    <Button
                      onClick={() => act('dispense', { ration_type: ration.key })}
                      disabled={stock <= 0}
                      style={{
                        fontFamily: 'monospace',
                        fontSize: '9px',
                        background: stock > 0 ? `rgba(68,255,68,0.1)` : 'transparent',
                        border: `1px solid ${stock > 0 ? '#44ff44' : '#2a2a30'}`,
                        color: stock > 0 ? '#44ff44' : '#555560',
                        padding: '2px 8px',
                      }}
                    >
                      DISPENSE
                    </Button>
                  </Box>
                </Box>
              );
            })}
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
