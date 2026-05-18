import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';

const CLASS_COLORS = {
  Safe: 'good',
  Euclid: 'average',
  Keter: 'bad',
  Thaumiel: 'purple',
  Neutralized: 'label',
};

const STATUS_ICONS = {
  contained: 'lock',
  breached: 'exclamation-triangle',
  unknown: 'question',
};

export const AnomalyScanner = (props) => {
  const { act, data } = useBackend();

  const {
    scan_cooldown,
    scan_cooldown_max,
    detection_range,
    detect_breached_only,
    show_detailed,
    results,
    result_count,
  } = data;

  return (
    <Window
      title="Anomaly Scanner"
      width={500}
      height={600}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Scanner Controls">
              <Flex align="center" justify="space-between" wrap="wrap" gap={1}>
                <Flex.Item>
                  <Button
                    icon="satellite-dish"
                    color={scan_cooldown > 0 ? 'default' : 'good'}
                    disabled={scan_cooldown > 0}
                    onClick={() => act('scan')}
                  >
                    {scan_cooldown > 0 ? `Recharging...` : 'SCAN'}
                  </Button>
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="filter"
                    color={detect_breached_only ? 'bad' : 'default'}
                    selected={detect_breached_only}
                    onClick={() => act('toggle_breached_only')}
                    tooltip="Only show breached SCPs"
                  >
                    Breach Filter
                  </Button>
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="search-plus"
                    color={show_detailed ? 'average' : 'default'}
                    selected={show_detailed}
                    onClick={() => act('toggle_detailed')}
                  >
                    Detailed
                  </Button>
                </Flex.Item>
              </Flex>
              {scan_cooldown > 0 && (
                <Box mt={1}>
                  <ProgressBar
                    value={scan_cooldown_max - scan_cooldown}
                    minValue={0}
                    maxValue={scan_cooldown_max}
                    color="average"
                  >
                    Recharging...
                  </ProgressBar>
                </Box>
              )}
              <Box mt={1} color="label" fontSize="11px">
                Range: {detection_range} tiles | Results: {result_count || 0}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Scan Results" fill scrollable>
              {results && results.length > 0 ? (
                <Table>
                  <Table.Row header>
                    <Table.Cell>SCP</Table.Cell>
                    <Table.Cell>Class</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Dist</Table.Cell>
                    <Table.Cell>Dir</Table.Cell>
                  </Table.Row>
                  {results.map((result, i) => (
                    <Table.Row key={i}>
                      <Table.Cell bold color="amber">
                        {result.scp_id}
                      </Table.Cell>
                      <Table.Cell>
                        <Box
                          color={CLASS_COLORS[result.scp_class] || 'label'}
                          bold
                          fontSize="11px"
                        >
                          {result.scp_class}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Flex align="center">
                          <Icon
                            name={STATUS_ICONS[result.status] || 'question'}
                            color={result.status === 'breached' ? 'bad' : 'good'}
                            mr={1}
                          />
                          <Box
                            color={result.status === 'breached' ? 'bad' : 'good'}
                            fontSize="11px"
                          >
                            {result.status}
                          </Box>
                        </Flex>
                      </Table.Cell>
                      <Table.Cell color="label" fontSize="11px">
                        {result.distance}t
                      </Table.Cell>
                      <Table.Cell color="label" fontSize="11px">
                        {result.direction}
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              ) : (
                <Box color="label" textAlign="center" p={2}>
                  <Icon name="satellite-dish" size={2} mb={1} /><br />
                  No anomalous signatures detected.<br />
                  Click SCAN to search for SCPs.
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
