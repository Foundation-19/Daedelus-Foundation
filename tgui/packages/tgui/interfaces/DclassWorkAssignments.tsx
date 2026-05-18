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

const TYPE_ICONS = {
  Cleaning: 'broom',
  Maintenance: 'wrench',
  Laundry: 'tshirt',
  'Kitchen Duty': 'utensils',
  Logistics: 'truck',
  'SCP-Adjacent Labor': 'biohazard',
};

const TYPE_COLORS = {
  Cleaning: 'label',
  Maintenance: 'average',
  Laundry: 'label',
  'Kitchen Duty': 'good',
  Logistics: 'average',
  'SCP-Adjacent Labor': 'bad',
};

export const DclassWorkAssignments = (props) => {
  const { act, data } = useBackend();

  const {
    is_dclass,
    is_guard,
    credits,
    trust,
    tasks_completed,
    available_tasks,
    active_tasks,
  } = data;

  return (
    <Window
      title="D-Class Work Assignments"
      width={600}
      height={700}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          {is_dclass && (
            <Stack.Item>
              <Section title="Your Status">
                <Flex wrap="wrap" gap={2}>
                  <Flex.Item>
                    <LabeledList>
                      <LabeledList.Item label="Credits">
                        <Box color="gold" bold>{credits || 0}</Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Trust Level">
                        <ProgressBar value={trust || 0} minValue={0} maxValue={100} color="good">
                          {trust || 0}%
                        </ProgressBar>
                      </LabeledList.Item>
                      <LabeledList.Item label="Tasks Done">
                        {tasks_completed || 0}
                      </LabeledList.Item>
                    </LabeledList>
                  </Flex.Item>
                </Flex>
              </Section>
            </Stack.Item>
          )}
          {active_tasks && active_tasks.length > 0 && (
            <Stack.Item>
              <Section title="Active Tasks">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Task</Table.Cell>
                    <Table.Cell>Progress</Table.Cell>
                    <Table.Cell>Time</Table.Cell>
                    <Table.Cell>Action</Table.Cell>
                  </Table.Row>
                  {active_tasks.map((task, i) => (
                    <Table.Row key={i}>
                      <Table.Cell>
                        <Icon name={TYPE_ICONS[task.type] || 'tasks'} mr={1} color={TYPE_COLORS[task.type] || 'label'} />
                        {task.description}
                      </Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={task.progress}
                          minValue={0}
                          maxValue={100}
                          color={task.completed ? 'good' : task.progress > 50 ? 'average' : 'bad'}
                          fontSize="10px"
                        >
                          {task.progress?.toFixed(0)}%
                        </ProgressBar>
                      </Table.Cell>
                      <Table.Cell color="label" fontSize="10px">
                        {task.completed ? 'DONE' : `${Math.ceil((task.time_remaining || 0) / 10)}s`}
                      </Table.Cell>
                      <Table.Cell>
                        {!task.completed && (
                          <Button
                            icon="times"
                            color="bad"
                            size="tiny"
                            onClick={() => act('abandon_task', { id: task.id })}
                          >
                            Drop
                          </Button>
                        )}
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section title="Available Tasks" fill scrollable>
              {available_tasks && available_tasks.length > 0 ? (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Task</Table.Cell>
                    <Table.Cell>Type</Table.Cell>
                    <Table.Cell>Credits</Table.Cell>
                    <Table.Cell>Trust</Table.Cell>
                    <Table.Cell>Time</Table.Cell>
                    <Table.Cell>Action</Table.Cell>
                  </Table.Row>
                  {available_tasks.map((task, i) => (
                    <Table.Row key={i}>
                      <Table.Cell fontSize="11px">{task.description}</Table.Cell>
                      <Table.Cell>
                        <Box color={TYPE_COLORS[task.type] || 'label'} fontSize="11px">
                          <Icon name={TYPE_ICONS[task.type] || 'tasks'} mr={1} />
                          {task.type}
                        </Box>
                      </Table.Cell>
                      <Table.Cell color="gold" fontSize="11px">{task.reward_credits}</Table.Cell>
                      <Table.Cell color="good" fontSize="11px">+{task.reward_trust}</Table.Cell>
                      <Table.Cell color="label" fontSize="11px">{Math.ceil(task.duration / 10)}s</Table.Cell>
                      <Table.Cell>
                        <Button
                          icon="check"
                          color="good"
                          size="tiny"
                          disabled={task.already_assigned || !is_dclass}
                          onClick={() => act('accept_task', { id: task.id })}
                        >
                          Accept
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              ) : (
                <Box color="label" textAlign="center" p={2}>
                  No tasks available.
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
