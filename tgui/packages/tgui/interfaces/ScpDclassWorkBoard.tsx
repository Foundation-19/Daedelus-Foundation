import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

type Assignment = {
  id: string;
  name: string;
  description: string;
  risk: number;
  reward: number;
  tools: string[];
  access: string[];
};

type WorkBoardData = {
  assignments: Assignment[];
  current_assignment: string | null;
  credits: number;
  trust: number;
  level: number;
};

const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  red: '#8b0000',
  darkRed: '#5c0000',
  amber: '#d4a017',
  green: '#0a6e0a',
  brightGreen: '#44ff44',
  text: '#c8c8c8',
  dim: '#6a6a70',
  highlight: '#e8e8e8',
};

const riskLabel = (risk: number): string => {
  switch (risk) {
    case 1:
      return 'LOW';
    case 2:
      return 'MODERATE';
    case 3:
      return 'HIGH';
    default:
      return 'UNKNOWN';
  }
};

const riskColor = (risk: number): string => {
  switch (risk) {
    case 1:
      return C.green;
    case 2:
      return C.amber;
    case 3:
      return C.red;
    default:
      return C.dim;
  }
};

export const ScpDclassWorkBoard = (_props: unknown) => {
  const { act, data } = useBackend<WorkBoardData>();
  const { assignments = [], current_assignment, credits, trust, level } = data;

  return (
    <NtosWindow width={500} height={600}  backgroundColor={C.bg}>
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="D-CLASS WORK ASSIGNMENTS"
              fontSize="14px"
              color={C.highlight}
              style={{
                borderBottom: `2px solid ${C.amber}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack>
                <Stack.Item grow>
                  <Box
                    fontFamily="monospace"
                    fontSize="11px"
                    color={C.dim}
                  >
                    SITE-53 DUTY ROTATION BOARD
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Box
                        as="span"
                        fontFamily="monospace"
                        fontSize="11px"
                        color={C.brightGreen}
                      >
                        CR:{credits}
                      </Box>
                    </Stack.Item>
                    <Stack.Item pl={1}>
                      <Box
                        as="span"
                        fontFamily="monospace"
                        fontSize="11px"
                        color={C.amber}
                      >
                        TR:{trust}%
                      </Box>
                    </Stack.Item>
                    <Stack.Item pl={1}>
                      <Box
                        as="span"
                        fontFamily="monospace"
                        fontSize="11px"
                        color={C.text}
                      >
                        LV:{level}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          {!!current_assignment && (
            <Stack.Item>
              <Section
                title="CURRENT ASSIGNMENT"
                fontSize="12px"
                color={C.brightGreen}
              >
                <Stack align="center">
                  <Stack.Item grow>
                    <Box
                      fontFamily="monospace"
                      fontSize="13px"
                      color={C.highlight}
                    >
                      {current_assignment.toUpperCase()}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      content="ABANDON (-5 Trust)"
                      color="red"
                      onClick={() => act('abandon')}
                      style={{ fontFamily: 'monospace', fontSize: '10px' }}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}

          <Stack.Item grow>
            {assignments.map((job) => (
              <Section
                key={job.id}
                title={
                  <Stack align="center">
                    <Stack.Item grow>
                      <Box
                        as="span"
                        fontFamily="monospace"
                        fontSize="12px"
                        color={C.highlight}
                      >
                        {job.name}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box
                        as="span"
                        fontFamily="monospace"
                        fontSize="10px"
                        color={riskColor(job.risk)}
                      >
                        [{riskLabel(job.risk)}]
                      </Box>
                    </Stack.Item>
                    <Stack.Item pl={1}>
                      <Box
                        as="span"
                        fontFamily="monospace"
                        fontSize="10px"
                        color={C.brightGreen}
                      >
                        +{job.reward}CR
                      </Box>
                    </Stack.Item>
                  </Stack>
                }
                style={{
                  border: `1px solid ${C.border}`,
                  backgroundColor: C.panel,
                }}
                mb={1}
              >
                <Box
                  fontFamily="monospace"
                  fontSize="11px"
                  color={C.text}
                  mb={1}
                >
                  {job.description}
                </Box>
                <Stack>
                  <Stack.Item grow>
                    <Box
                      fontFamily="monospace"
                      fontSize="10px"
                      color={C.dim}
                    >
                      Tools: {job.tools?.join(', ')}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      content="ACCEPT"
                      color="green"
                      disabled={!!current_assignment || level < job.risk}
                      onClick={() => act('accept', { id: job.id })}
                      style={{ fontFamily: 'monospace', fontSize: '10px' }}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            ))}
            {assignments.length === 0 && (
              <Box
                textAlign="center"
                color={C.dim}
                fontFamily="monospace"
                fontSize="12px"
                mt={4}
              >
                No work assignments available at this time.
              </Box>
            )}
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
