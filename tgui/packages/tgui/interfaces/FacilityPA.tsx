import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  TextArea,
} from '../components';
import { Window } from '../layouts';

export const FacilityPA = (props) => {
  const { act, data } = useBackend();

  const {
    selected_zone,
    cooldown,
    cooldown_max,
    last_announcement,
    can_announce,
    is_command,
    zones,
    announcement_log,
  } = data;

  return (
    <Window
      title="Facility PA System"
      width={550}
      height={650}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Zone Selection">
              <Flex wrap="wrap" gap={1}>
                {zones && zones.map((zone) => (
                  <Flex.Item key={zone.key}>
                    <Button
                      icon={zone.selected ? 'check-circle' : 'circle'}
                      color={zone.selected ? 'good' : 'default'}
                      selected={zone.selected}
                      onClick={() => act('select_zone', { zone: zone.key })}
                    >
                      {zone.name}
                    </Button>
                  </Flex.Item>
                ))}
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Make Announcement">
              {can_announce ? (
                <Stack vertical>
                  <Stack.Item>
                    <TextArea
                      fluid
                      height={5}
                      placeholder="Enter announcement message (2-300 characters)..."
                      id="pa_message"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="bullhorn"
                      color="good"
                      fluid
                      onClick={() => {
                        const input = document.getElementById('pa_message');
                        if (input && input.value) {
                          act('make_announcement', { message: input.value });
                        }
                      }}
                    >
                      Broadcast to {zones?.find(z => z.key === selected_zone)?.name || 'Unknown Zone'}
                    </Button>
                  </Stack.Item>
                </Stack>
              ) : (
                <Box>
                  <ProgressBar
                    value={cooldown_max - cooldown}
                    minValue={0}
                    maxValue={cooldown_max}
                    color="average"
                  >
                    Cooldown: {Math.ceil(cooldown / 10)}s
                  </ProgressBar>
                </Box>
              )}
            </Section>
          </Stack.Item>
          {last_announcement && (
            <Stack.Item>
              <Section title="Last Announcement">
                <Box color="label" fontSize="12px" p={1} backgroundColor="rgba(0,0,0,0.3)">
                  {last_announcement}
                </Box>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section title="Announcement Log" fill scrollable>
              {announcement_log && announcement_log.length > 0 ? (
                announcement_log.slice().reverse().map((entry, i) => (
                  <Box key={i} mb={1} p={0.5} backgroundColor="rgba(0,0,0,0.2)" fontSize="11px">
                    <Flex justify="space-between">
                      <Flex.Item color="amber" bold>{entry.sender}</Flex.Item>
                      <Flex.Item color="label">{entry.time} | {entry.zone}</Flex.Item>
                    </Flex>
                    <Box mt={0.5} color="label">{entry.message}</Box>
                  </Box>
                ))
              ) : (
                <Box color="label" textAlign="center" p={2}>
                  No announcements made this shift.
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
