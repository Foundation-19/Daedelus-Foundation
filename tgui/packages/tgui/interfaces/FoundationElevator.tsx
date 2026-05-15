import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type FloorData = {
  id: number;
  name: string;
  accessible: BooleanLike;
};

type Data = {
  current_floor: number;
  floors: FloorData[];
  moving: BooleanLike;
  door_open: BooleanLike;
};

export const FoundationElevator = (props) => {
  const { act, data } = useBackend<Data>();
  const { current_floor, floors, moving, door_open } = data;

  return (
    <Window theme="scp_terminal" width={350} height={450}>
      <Window.Content scrollable>
        <Section title="FOUNDATION ELEVATOR">
          <LabeledList>
            <LabeledList.Item label="Current Floor">
              <Box
                style={{
                  color: '#d4a017',
                  fontFamily: 'monospace',
                  fontWeight: 'bold',
                  fontSize: '16px',
                }}
              >
                {floors?.find((f) => f.id === current_floor)?.name || `FLOOR ${current_floor}`}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Status">
              {moving ? (
                <Box style={{ color: '#8b0000', fontFamily: 'monospace', fontWeight: 'bold' }}>
                  IN TRANSIT
                </Box>
              ) : door_open ? (
                <Box style={{ color: '#1a7a1a', fontFamily: 'monospace' }}>
                  DOORS OPEN
                </Box>
              ) : (
                <Box style={{ color: '#555560', fontFamily: 'monospace' }}>
                  STANDING BY
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="SELECT FLOOR">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {floors && floors.length > 0 ? (
              floors.map((floor) => (
                <Button
                  key={floor.id}
                  onClick={() => act('goto', { floor: floor.id })}
                  disabled={moving || floor.id === current_floor || !floor.accessible}
                  style={{
                    fontFamily: 'monospace',
                    background: floor.id === current_floor
                      ? 'rgba(212,160,23,0.3)'
                      : !floor.accessible
                        ? 'rgba(20,20,25,0.8)'
                        : 'rgba(20,20,25,0.8)',
                    border: `1px solid ${floor.id === current_floor ? '#d4a017' : !floor.accessible ? '#2a2a30' : '#2a2a30'}`,
                    color: floor.id === current_floor
                      ? '#d4a017'
                      : !floor.accessible
                        ? '#555560'
                        : '#c8c8c8',
                    padding: '8px 12px',
                    textAlign: 'left',
                    fontWeight: floor.id === current_floor ? 'bold' : 'normal',
                  }}
                >
                  {floor.id === current_floor ? '> ' : '  '}
                  {floor.name}
                  {!floor.accessible && ' [RESTRICTED]'}
                </Button>
              ))
            ) : (
              <Box style={{ color: '#555560', fontFamily: 'monospace' }}>
                NO FLOORS AVAILABLE
              </Box>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
