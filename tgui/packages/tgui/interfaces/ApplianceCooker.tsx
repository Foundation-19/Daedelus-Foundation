import { BooleanLike } from 'common/react';
import React from 'react';
import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, NoticeBox, Section, Slider, Table } from '../components';
import { Window } from '../layouts';

type ContentItem = {
  name: string;
  progress: number;
  overcook: number;
};

type Data = {
  active: BooleanLike;
  current_temp: number;
  set_temp: number;
  min_temp: number;
  max_temp: number;
  optimal_temp: number;
  efficiency: number;
  contents: ContentItem[];
};

export const ApplianceCooker = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    current_temp,
    set_temp,
    min_temp,
    max_temp,
    optimal_temp,
    efficiency,
    contents,
  } = data;

  const efficiencyColor =
    efficiency >= 75 ? '#44ff44' : efficiency >= 40 ? '#ffaa00' : '#ff4444';

  return (
    <Window theme="scp_terminal" width={450} height={400}>
      <Window.Content scrollable>
        <Section title="TEMPERATURE CONTROL">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                content={active ? 'ON' : 'OFF'}
                color={active ? 'good' : 'bad'}
                onClick={() => act('toggle')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Set Temperature">
              <Slider
                value={set_temp}
                minValue={min_temp}
                maxValue={max_temp}
                step={10}
                onChange={(e, v) => act('set_temp', { temperature: v })}
                format={(v) => `${v}K`}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Current Temperature">
              <Box style={{ color: current_temp >= optimal_temp * 0.8 ? '#ff8844' : '#aaaaaa', fontFamily: 'monospace' }}>
                {Math.round(current_temp)}K
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Efficiency">
              <Box style={{ color: efficiencyColor, fontWeight: 'bold' }}>
                {efficiency}%
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Optimal Range">
              {optimal_temp - 50}K — {optimal_temp + 50}K
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {contents.length > 0 && (
          <Section title="COOKING CONTENTS">
            <Table>
              <Table.Row header>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell>Progress</Table.Cell>
                <Table.Cell>Burn Risk</Table.Cell>
              </Table.Row>
              {contents.map((item, i) => (
                <Table.Row key={i}>
                  <Table.Cell>{item.name}</Table.Cell>
                  <Table.Cell>
                    <Box
                      style={{
                        color:
                          item.progress >= 100
                            ? '#44ff44'
                            : item.progress >= 60
                              ? '#ffaa00'
                              : '#cccccc',
                      }}
                    >
                      {item.progress}%
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box
                      style={{
                        color:
                          item.overcook >= 70
                            ? '#ff4444'
                            : item.overcook >= 30
                              ? '#ffaa00'
                              : '#44ff44',
                      }}
                    >
                      {item.overcook >= 100
                        ? 'BURNING'
                        : item.overcook >= 70
                          ? 'HIGH'
                          : item.overcook >= 30
                            ? 'MEDIUM'
                            : 'LOW'}
                    </Box>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
        {contents.length === 0 && (
          <NoticeBox info>No items cooking.</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};
