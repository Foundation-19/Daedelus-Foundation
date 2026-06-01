import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

type Song = {
  name: string;
  sanity_bonus: number;
};

type Data = {
  songs: Song[];
  cooldown_active: BooleanLike;
  cooldown_remaining: number;
};

const SONG_COLORS: Record<string, string> = {
  'Calming Melody': '#4488ff',
  'Uplifting March': '#d4a017',
  'Solemn Hymn': '#8b6914',
  'Jazz Interlude': '#44ff44',
};

export const ScpRecordPlayer = (props) => {
  const { act, data } = useBackend<Data>();
  const { songs, cooldown_active, cooldown_remaining } = data;

  return (
    <NtosWindow width={400} height={340}>
      <NtosWindow.Content scrollable>
        <Section title="FOUNDATION RECORD PLAYER">
          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#6a6a70',
              letterSpacing: '0.1em',
              marginBottom: '10px',
            }}
          >
            SCP FOUNDATION — MUSIC THERAPY SERVICES
          </Box>

          {cooldown_active && (
            <Box
              style={{
                fontFamily: 'monospace',
                fontSize: '11px',
                color: '#d4a017',
                marginBottom: '10px',
              }}
            >
              RESETTING: {cooldown_remaining}s
            </Box>
          )}
        </Section>

        <Section title="SELECT TRACK">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {songs.map((song) => {
              const color = SONG_COLORS[song.name] || '#c8c8c8';
              return (
                <Box
                  key={song.name}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '8px 10px',
                    borderLeft: `2px solid ${cooldown_active ? '#2a2a30' : color}`,
                    background: '#111114',
                  }}
                >
                  <Box>
                    <Box
                      style={{
                        color: cooldown_active ? '#555560' : color,
                        fontWeight: 'bold',
                        fontSize: '12px',
                        fontFamily: 'monospace',
                      }}
                    >
                      {song.name.toUpperCase()}
                    </Box>
                    <Box style={{ fontSize: '9px', color: '#6a6a70' }}>
                      Sanity bonus: +{song.sanity_bonus} for all listeners
                    </Box>
                  </Box>
                  <Button
                    onClick={() => act('play_song', { song_name: song.name })}
                    disabled={!!cooldown_active}
                    style={{
                      fontFamily: 'monospace',
                      fontSize: '9px',
                      background: !cooldown_active
                        ? `rgba(${color === '#4488ff' ? '68,136,255' : color === '#d4a017' ? '212,160,23' : color === '#44ff44' ? '68,255,68' : '139,105,20'},0.1)`
                        : 'transparent',
                      border: `1px solid ${!cooldown_active ? color : '#2a2a30'}`,
                      color: !cooldown_active ? color : '#555560',
                      padding: '4px 10px',
                    }}
                  >
                    PLAY
                  </Button>
                </Box>
              );
            })}
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
