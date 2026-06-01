import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  selected_class: string;
  stock_a: number;
  stock_b: number;
  stock_c: number;
  stock_e: number;
  cooldown_active: BooleanLike;
  cooldown_remaining: number;
};

const CLASS_INFO = {
  'Class-A': {
    color: '#d4a017',
    desc: 'Mild memory haze. Recent events become fuzzy.',
    severity: 1,
  },
  'Class-B': {
    color: '#d4a017',
    desc: 'Moderate memory wipe. Hours of memory lost.',
    severity: 2,
  },
  'Class-C': {
    color: '#8b0000',
    desc: 'Severe memory wipe. Days of memory erased.',
    severity: 3,
  },
  'Class-E': {
    color: '#cc2222',
    desc: 'Total memory wipe. Complete identity erasure.',
    severity: 4,
  },
};

export const ScpAmnesticDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const { selected_class, stock_a, stock_b, stock_c, stock_e, cooldown_active, cooldown_remaining } = data;

  const classes = ['Class-A', 'Class-B', 'Class-C', 'Class-E'];
  const stocks = { 'Class-A': stock_a, 'Class-B': stock_b, 'Class-C': stock_c, 'Class-E': stock_e };

  return (
    <NtosWindow width={500} height={450}>
      <NtosWindow.Content scrollable>
        <Section title="AMNESTIC DISPENSER">
          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#6a6a70',
              letterSpacing: '0.1em',
              marginBottom: '10px',
            }}
          >
            SCP FOUNDATION — MEMORY SUPPRESSION PROTOCOL
          </Box>

          <LabeledList>
            <LabeledList.Item label="Selected Class">
              <Box
                style={{
                  color: CLASS_INFO[selected_class]?.color || '#c8c8c8',
                  fontWeight: 'bold',
                  fontFamily: 'monospace',
                  fontSize: '14px',
                }}
              >
                {selected_class}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Effect">
              {CLASS_INFO[selected_class]?.desc}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="SELECT AMNESTIC CLASS">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            {classes.map((cls) => {
              const info = CLASS_INFO[cls];
              const stock = stocks[cls] || 0;
              const isSelected = selected_class === cls;
              return (
                <Box
                  key={cls}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '8px 10px',
                    borderLeft: `2px solid ${isSelected ? info.color : '#2a2a30'}`,
                    background: isSelected ? `rgba(${info.severity > 2 ? '139,0,0' : '212,160,23'},0.1)` : '#111114',
                  }}
                >
                  <Box>
                    <Box
                      style={{
                        color: isSelected ? info.color : '#c8c8c8',
                        fontWeight: 'bold',
                        fontSize: '12px',
                      }}
                    >
                      {cls}
                    </Box>
                    <Box style={{ fontSize: '9px', color: '#6a6a70' }}>
                      {info.desc}
                    </Box>
                  </Box>
                  <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                    <Box
                      style={{
                        fontSize: '10px',
                        color: stock > 0 ? '#44ff44' : '#cc2222',
                        fontFamily: 'monospace',
                      }}
                    >
                      STOCK: {stock}
                    </Box>
                    <Button
                      onClick={() => act('select_class', { class: cls })}
                      disabled={stock <= 0}
                      style={{
                        fontFamily: 'monospace',
                        fontSize: '9px',
                        background: isSelected ? `rgba(${info.severity > 2 ? '139,0,0' : '212,160,23'},0.2)` : 'transparent',
                        border: `1px solid ${isSelected ? info.color : '#2a2a30'}`,
                        color: isSelected ? info.color : '#6a6a70',
                        padding: '2px 8px',
                      }}
                    >
                      SELECT
                    </Button>
                  </Box>
                </Box>
              );
            })}
          </Box>
        </Section>

        <Section title="ADMINISTRATION">
          <Box style={{ display: 'flex', gap: '8px' }}>
            <Button
              onClick={() => act('administer')}
              disabled={cooldown_active || (stocks[selected_class] || 0) <= 0}
              style={{
                fontFamily: 'monospace',
                background: 'rgba(139,0,0,0.3)',
                border: '1px solid #8b0000',
                color: !cooldown_active && (stocks[selected_class] || 0) > 0 ? '#cc2222' : '#555560',
                padding: '6px 14px',
              }}
            >
              ADMINISTER TO SUBJECT
            </Button>
            <Button
              onClick={() => act('dispense_injector')}
              disabled={(stocks[selected_class] || 0) <= 0}
              style={{
                fontFamily: 'monospace',
                background: 'rgba(212,160,23,0.2)',
                border: '1px solid #d4a017',
                color: (stocks[selected_class] || 0) > 0 ? '#d4a017' : '#555560',
                padding: '6px 14px',
              }}
            >
              DISPENSE INJECTOR
            </Button>
          </Box>
          {cooldown_active && (
            <Box
              style={{
                marginTop: '8px',
                color: '#d4a017',
                fontFamily: 'monospace',
                fontSize: '10px',
              }}
            >
              RECHARGING: {Math.ceil(cooldown_remaining / 10)}s
            </Box>
          )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
