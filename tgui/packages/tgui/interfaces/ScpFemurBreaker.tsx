import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  occupied: BooleanLike;
  activation_progress: number;
  activation_threshold: number;
  victim_name: string;
  victim_health: number;
  scp106_status: string;
  lure_active: BooleanLike;
  completed: BooleanLike;
};

export const ScpFemurBreaker = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    occupied,
    activation_progress,
    activation_threshold,
    victim_name,
    victim_health,
    scp106_status,
    lure_active,
    completed,
  } = data;

  const progressPct = Math.round((activation_progress / activation_threshold) * 100);

  return (
    <NtosWindow width={500} height={500}>
      <NtosWindow.Content scrollable>
        <Section title="SCP-106 FEMUR BREAKER PROTOCOL">
          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#6a6a70',
              letterSpacing: '0.1em',
              marginBottom: '10px',
            }}
          >
            CONTAINMENT PROTOCOL 106-LURE
          </Box>

          <LabeledList>
            <LabeledList.Item label="Subject">
              {occupied ? (
                <Box style={{ color: '#cc2222', fontWeight: 'bold' }}>
                  {victim_name || 'UNKNOWN'}
                </Box>
              ) : (
                <Box style={{ color: '#555560', fontStyle: 'italic' }}>
                  NO SUBJECT LOADED
                </Box>
              )}
            </LabeledList.Item>
            {occupied && (
              <LabeledList.Item label="Subject Health">
                <Box
                  style={{
                    color:
                      victim_health > 50
                        ? '#44ff44'
                        : victim_health > 25
                          ? '#d4a017'
                          : '#cc2222',
                  }}
                >
                  {victim_health}%
                </Box>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="SCP-106 Status">
              <Box
                style={{
                  color:
                    scp106_status === 'breached'
                      ? '#cc2222'
                      : scp106_status === 'contained'
                        ? '#44ff44'
                        : '#6a6a70',
                  fontWeight: 'bold',
                }}
              >
                {scp106_status?.toUpperCase() || 'UNKNOWN'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Lure Status">
              {lure_active ? (
                <Box style={{ color: '#d4a017', fontWeight: 'bold' }}>
                  ACTIVE
                </Box>
              ) : (
                <Box style={{ color: '#6a6a70' }}>INACTIVE</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Protocol Status">
              {completed ? (
                <Box style={{ color: '#44ff44', fontWeight: 'bold' }}>
                  COMPLETED
                </Box>
              ) : (
                <Box style={{ color: '#d4a017' }}>{progressPct}%</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        {activation_progress > 0 && !completed && (
          <Section title="ACTIVATION PROGRESS">
            <Box
              style={{
                background: '#111114',
                border: '1px solid #2a2a30',
                height: '24px',
                position: 'relative',
                fontFamily: 'monospace',
              }}
            >
              <Box
                style={{
                  background: 'linear-gradient(90deg, #8b0000, #cc2222)',
                  height: '100%',
                  width: `${progressPct}%`,
                  transition: 'width 0.3s',
                }}
              />
              <Box
                style={{
                  position: 'absolute',
                  top: '4px',
                  left: '50%',
                  transform: 'translateX(-50%)',
                  color: '#e8e8e8',
                  fontSize: '11px',
                  fontWeight: 'bold',
                }}
              >
                {progressPct}%
              </Box>
            </Box>
          </Section>
        )}

        <Section title="CONTROLS">
          <Box
            style={{
              background: 'rgba(139,0,0,0.1)',
              border: '1px solid #8b0000',
              padding: '8px',
              marginBottom: '10px',
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#cc2222',
            }}
          >
            WARNING: FEMUR BREAKER PROTOCOL CAUSES SEVERE PHYSICAL HARM TO
            SUBJECT. REQUIRES SCP-106 IN BREACHED STATE. SUBJECT MUST BE
            VOLUNTEER OR D-CLASS.
          </Box>
          <Box style={{ display: 'flex', gap: '8px' }}>
            <Button
              onClick={() => act('enter')}
              disabled={occupied}
              style={{
                fontFamily: 'monospace',
                background: occupied ? 'transparent' : 'rgba(212,160,23,0.2)',
                border: `1px solid ${occupied ? '#2a2a30' : '#d4a017'}`,
                color: occupied ? '#555560' : '#d4a017',
                padding: '6px 14px',
              }}
            >
              ENTER CHAMBER
            </Button>
            <Button
              onClick={() => act('activate')}
              disabled={!occupied || completed || lure_active}
              style={{
                fontFamily: 'monospace',
                background:
                  !occupied || completed || lure_active
                    ? 'transparent'
                    : 'rgba(139,0,0,0.3)',
                border: `1px solid ${!occupied || completed || lure_active ? '#2a2a30' : '#8b0000'}`,
                color:
                  !occupied || completed || lure_active ? '#555560' : '#cc2222',
                padding: '6px 14px',
                fontWeight: 'bold',
              }}
            >
              ACTIVATE FEMUR BREAKER
            </Button>
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
