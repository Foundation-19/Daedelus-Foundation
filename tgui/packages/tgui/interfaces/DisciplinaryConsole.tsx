import { BooleanLike } from 'common/react';
import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type Action = {
  target: string;
  type: string;
  reason: string;
  time: string;
  resolved: BooleanLike;
};

type Personnel = {
  name: string;
  job: string;
  ref: string;
};

type Data = {
  actions: Action[];
  personnel: Personnel[];
};

const ACTION_TYPES = [
  'Formal Warning',
  'Written Reprimand',
  'Suspension',
  'Demotion Request',
  'Termination Review',
];

export const DisciplinaryConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { actions, personnel } = data;
  const [target, setTarget] = useState('');
  const [actionType, setActionType] = useState('');
  const [reason, setReason] = useState('');

  return (
    <Window theme="scp_terminal" width={550} height={550}>
      <Window.Content scrollable>
        <Section title="ISSUE DISCIPLINARY ACTION">
          <LabeledList>
            <LabeledList.Item label="Target">
              {personnel.map((p) => (
                <Button
                  key={p.ref}
                  content={p.name}
                  selected={target === p.name}
                  onClick={() => setTarget(p.name)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Action Type">
              {ACTION_TYPES.map((t) => (
                <Button
                  key={t}
                  content={t}
                  selected={actionType === t}
                  onClick={() => setActionType(t)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Reason">
              <Input
                value={reason}
                onInput={(_, v) => setReason(v)}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Submit">
              <Button
                content="ISSUE ACTION"
                color="bad"
                disabled={!target || !actionType || !reason}
                onClick={() => {
                  act('issue_action', {
                    target,
                    action_type: actionType,
                    reason,
                  });
                  setTarget('');
                  setActionType('');
                  setReason('');
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="ACTIONS LOG">
          <Table>
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>Target</Table.Cell>
              <Table.Cell>Type</Table.Cell>
              <Table.Cell>Reason</Table.Cell>
              <Table.Cell>Status</Table.Cell>
            </Table.Row>
            {actions.map((a, i) => (
              <Table.Row key={i}>
                <Table.Cell>{a.time}</Table.Cell>
                <Table.Cell>{a.target}</Table.Cell>
                <Table.Cell>{a.type}</Table.Cell>
                <Table.Cell>{a.reason}</Table.Cell>
                <Table.Cell>
                  {a.resolved ? (
                    <Box style={{ color: '#44ff44' }}>RESOLVED</Box>
                  ) : (
                    <Button
                      content="RESOLVE"
                      onClick={() => act('resolve', { index: i + 1 })}
                    />
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
