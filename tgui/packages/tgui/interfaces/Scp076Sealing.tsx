import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Section,
  Stack,
} from '../components';
import { NtosWindow } from '../layouts';

const STATE_COLORS = {
  dormant: 'good',
  awakening: 'average',
  active: 'bad',
  deceased: 'label',
  unknown: 'label',
};

const STATE_LABELS = {
  dormant: 'DORMANT',
  awakening: 'AWAKENING',
  active: 'ACTIVE — BREACH',
  deceased: 'DECEASED (Respawning)',
  unknown: 'UNKNOWN',
};

export const Scp076Sealing = (props) => {
  const { act, data } = useBackend();

  const {
    sarcophagus_found,
    scp_state,
    respawn_count,
    max_respawns,
  } = data;

  const stateColor = STATE_COLORS[scp_state] || 'label';
  const stateLabel = STATE_LABELS[scp_state] || scp_state?.toUpperCase();

  return (
    <NtosWindow title="SCP-076 Sealing Control" width={450}
      height={350}
      
    >
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="SCP-076-2 Status">
              {!sarcophagus_found ? (
                <Box color="bad" textAlign="center" p={2}>
                  <Icon name="exclamation-triangle" size={2} mb={1} /><br />
                  SARCOPHAGUS NOT DETECTED<br />
                  <Box color="label" fontSize="11px" mt={1}>
                    Terminal must be within 20m of SCP-076-1
                  </Box>
                </Box>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Current State">
                        <Box color={stateColor} bold fontSize="14px">
                          {stateLabel}
                        </Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Respawn Count">
                        <Box color={respawn_count >= max_respawns ? 'good' : 'average'}>
                          {respawn_count}/{max_respawns}
                          {respawn_count >= max_respawns && ' (Permanently Deceased)'}
                        </Box>
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item>
                    <Box color="label" fontSize="11px" p={1} backgroundColor="rgba(0,0,0,0.3)">
                      <Icon name="info-circle" mr={1} />
                      Force seal can only be used when SCP-076-2 is DORMANT or DECEASED.
                      Active SCP-076-2 must be neutralized first.
                    </Box>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Sealing Controls">
              <Flex justify="center">
                <Flex.Item>
                  <Button
                    icon="lock"
                    color="bad"
                    fluid
                    disabled={!sarcophagus_found || scp_state === 'active' || scp_state === 'awakening'}
                    onClick={() => act('force_seal')}
                    tooltip="Force SCP-076-2 into dormant state and seal sarcophagus"
                  >
                    FORCE SEAL SARCOPHAGUS
                  </Button>
                </Flex.Item>
              </Flex>
              {(scp_state === 'active' || scp_state === 'awakening') && (
                <Box color="bad" textAlign="center" mt={1} fontSize="11px">
                  <Icon name="exclamation-triangle" mr={1} />
                  Cannot seal while SCP-076-2 is {stateLabel}. Neutralize first.
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
