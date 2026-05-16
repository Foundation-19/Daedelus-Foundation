import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type Request = {
  requestor: string;
  current: string;
  requested: string;
  reason: string;
  status: string;
  time: string;
};

type Data = {
  requests: Request[];
};

const CLEARANCE_LEVELS = ['0', '1', '2', '3', '4', '5'];

export const ClearanceReview = (props) => {
  const { act, data } = useBackend<Data>();
  const { requests } = data;
  const [name, setName] = useState('');
  const [currentLevel, setCurrentLevel] = useState('0');
  const [requestedLevel, setRequestedLevel] = useState('1');
  const [reason, setReason] = useState('');

  return (
    <Window theme="scp_terminal" width={550} height={550}>
      <Window.Content scrollable>
        <Section title="SUBMIT CLEARANCE REQUEST">
          <LabeledList>
            <LabeledList.Item label="Personnel Name">
              <Input value={name} onInput={(_, v) => setName(v)} fluid />
            </LabeledList.Item>
            <LabeledList.Item label="Current Level">
              {CLEARANCE_LEVELS.map((l) => (
                <Button
                  key={l}
                  content={`L${l}`}
                  selected={currentLevel === l}
                  onClick={() => setCurrentLevel(l)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Requested Level">
              {CLEARANCE_LEVELS.map((l) => (
                <Button
                  key={l}
                  content={`L${l}`}
                  selected={requestedLevel === l}
                  onClick={() => setRequestedLevel(l)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Justification">
              <Input value={reason} onInput={(_, v) => setReason(v)} fluid />
            </LabeledList.Item>
            <LabeledList.Item label="Submit">
              <Button
                content="SUBMIT REQUEST"
                disabled={!name || !reason}
                onClick={() => {
                  act('submit_request', {
                    name,
                    current_level: currentLevel,
                    requested_level: requestedLevel,
                    reason,
                  });
                  setName('');
                  setReason('');
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="PENDING REQUESTS">
          <Table>
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>Personnel</Table.Cell>
              <Table.Cell>Current</Table.Cell>
              <Table.Cell>Requested</Table.Cell>
              <Table.Cell>Reason</Table.Cell>
              <Table.Cell>Status</Table.Cell>
            </Table.Row>
            {requests.map((r, i) => (
              <Table.Row key={i}>
                <Table.Cell>{r.time}</Table.Cell>
                <Table.Cell>{r.requestor}</Table.Cell>
                <Table.Cell>L{r.current}</Table.Cell>
                <Table.Cell>L{r.requested}</Table.Cell>
                <Table.Cell>{r.reason}</Table.Cell>
                <Table.Cell>
                  {r.status === 'pending' ? (
                    <>
                      <Button
                        content="APPROVE"
                        color="good"
                        onClick={() => act('approve', { index: i + 1 })}
                      />
                      <Button
                        content="DENY"
                        color="bad"
                        onClick={() => act('deny', { index: i + 1 })}
                      />
                    </>
                  ) : (
                    <Box
                      style={{
                        color:
                          r.status === 'approved' ? '#44ff44' : '#ff4444',
                      }}
                    >
                      {r.status.toUpperCase()}
                    </Box>
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
