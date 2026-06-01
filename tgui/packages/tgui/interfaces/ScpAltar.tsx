import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  meditation_progress: number;
  ritual_ready: BooleanLike;
  ritual_cooldown: number;
};

export const ScpAltar = (props) => {
  const { act, data } = useBackend<Data>();
  const { meditation_progress, ritual_ready, ritual_cooldown } = data;

  return (
    <NtosWindow width={420} height={380}>
      <NtosWindow.Content scrollable>
        <Section title="FOUNDATION MEDITATION ALTAR">
          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#6a6a70',
              letterSpacing: '0.1em',
              marginBottom: '10px',
            }}
          >
            SCP FOUNDATION — SPIRITUAL GUIDANCE DIVISION
          </Box>

          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '11px',
              color: '#c8c8c8',
              marginBottom: '4px',
            }}
          >
            MEDITATION PROGRESS: {meditation_progress}%
          </Box>
          <Box
            style={{
              height: '4px',
              background: '#1a1a1e',
              marginBottom: '12px',
            }}
          >
            <Box
              style={{
                height: '100%',
                width: `${meditation_progress}%`,
                background: '#d4a017',
                transition: 'width 0.3s',
              }}
            />
          </Box>
        </Section>

        <Section title="ACTIONS">
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
                  MEDITATE
                </Box>
                <Box style={{ fontSize: '11px', color: '#6a6a70' }}>
                  Find inner peace. +5 sanity. Progresses meditation.
                </Box>
              </Box>
              <Button
                onClick={() => act('meditate')}
                style={{
                  fontFamily: 'monospace',
                  fontSize: '11px',
                  background: 'rgba(68,136,255,0.1)',
                  border: '1px solid #4488ff',
                  color: '#4488ff',
                  padding: '4px 10px',
                }}
              >
                MEDITATE
              </Button>
            </Box>

            <Box
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '8px 10px',
                borderLeft: '2px solid #d4a017',
                background: '#111114',
              }}
            >
              <Box>
                <Box
                  style={{
                    color: '#d4a017',
                    fontWeight: 'bold',
                    fontSize: '12px',
                    fontFamily: 'monospace',
                  }}
                >
                  SEEK GUIDANCE
                </Box>
                <Box style={{ fontSize: '11px', color: '#6a6a70' }}>
                  Receive wisdom from the Foundation creed. +3 sanity.
                </Box>
              </Box>
              <Button
                onClick={() => act('seek_guidance')}
                style={{
                  fontFamily: 'monospace',
                  fontSize: '11px',
                  background: 'rgba(212,160,23,0.1)',
                  border: '1px solid #d4a017',
                  color: '#d4a017',
                  padding: '4px 10px',
                }}
              >
                SEEK
              </Button>
            </Box>

            <Box
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '8px 10px',
                borderLeft: `2px solid ${ritual_ready ? '#44ff44' : '#6a6a70'}`,
                background: '#111114',
              }}
            >
              <Box>
                <Box
                  style={{
                    color: ritual_ready ? '#44ff44' : '#6a6a70',
                    fontWeight: 'bold',
                    fontSize: '12px',
                    fontFamily: 'monospace',
                  }}
                >
                  CALMING RITUAL
                </Box>
                <Box style={{ fontSize: '11px', color: '#6a6a70' }}>
                  {ritual_ready
                    ? 'Channel the altar to calm all nearby. +8 sanity each.'
                    : `Recovering... ${ritual_cooldown}s remaining.`}
                </Box>
              </Box>
              <Button
                onClick={() => act('calming_ritual')}
                disabled={!ritual_ready}
                style={{
                  fontFamily: 'monospace',
                  fontSize: '11px',
                  background: ritual_ready ? 'rgba(68,255,68,0.1)' : 'transparent',
                  border: `1px solid ${ritual_ready ? '#44ff44' : '#6a6a70'}`,
                  color: ritual_ready ? '#44ff44' : '#555560',
                  padding: '4px 10px',
                }}
              >
                PERFORM
              </Button>
            </Box>
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
