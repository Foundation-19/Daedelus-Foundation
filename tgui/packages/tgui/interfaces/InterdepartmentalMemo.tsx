import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section, Table, TextArea } from '../components';
import { Window } from '../layouts';

type Memo = {
  from: string;
  to: string;
  subject: string;
  body: string;
  priority: string;
  time: string;
  author: string;
};

type Data = {
  memos: Memo[];
};

const DEPARTMENTS = [
  'Command',
  'Security',
  'Science',
  'Medical',
  'Engineering',
  'Containment',
  'Logistics',
  'Service',
];

const PRIORITIES = ['low', 'normal', 'high', 'urgent'];

export const InterdepartmentalMemo = (props) => {
  const { act, data } = useBackend<Data>();
  const { memos } = data;
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [priority, setPriority] = useState('normal');

  return (
    <Window theme="scp_terminal" width={550} height={550}>
      <Window.Content scrollable>
        <Section title="SEND MEMO">
          <LabeledList>
            <LabeledList.Item label="From">
              {DEPARTMENTS.map((d) => (
                <Button
                  key={d}
                  content={d}
                  selected={from === d}
                  onClick={() => setFrom(d)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="To">
              {DEPARTMENTS.map((d) => (
                <Button
                  key={d}
                  content={d}
                  selected={to === d}
                  onClick={() => setTo(d)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Priority">
              {PRIORITIES.map((p) => (
                <Button
                  key={p}
                  content={p}
                  selected={priority === p}
                  color={
                    p === 'urgent'
                      ? 'bad'
                      : p === 'high'
                        ? 'average'
                        : 'default'
                  }
                  onClick={() => setPriority(p)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Subject">
              <Input
                value={subject}
                onInput={(_, v) => setSubject(v)}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Body">
              <TextArea
                value={body}
                onInput={(_, v) => setBody(v)}
                height="80px"
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Send">
              <Button
                content="SEND MEMO"
                disabled={!from || !to || !subject || !body}
                onClick={() => {
                  act('send_memo', { from, to, subject, body, priority });
                  setFrom('');
                  setTo('');
                  setSubject('');
                  setBody('');
                  setPriority('normal');
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="MEMO LOG">
          <Table>
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>From</Table.Cell>
              <Table.Cell>To</Table.Cell>
              <Table.Cell>Priority</Table.Cell>
              <Table.Cell>Subject</Table.Cell>
            </Table.Row>
            {memos.map((m, i) => (
              <Table.Row key={i}>
                <Table.Cell>{m.time}</Table.Cell>
                <Table.Cell>{m.from}</Table.Cell>
                <Table.Cell>{m.to}</Table.Cell>
                <Table.Cell
                  style={{
                    color:
                      m.priority === 'urgent'
                        ? '#ff4444'
                        : m.priority === 'high'
                          ? '#ffaa00'
                          : '#cccccc',
                  }}
                >
                  {m.priority.toUpperCase()}
                </Table.Cell>
                <Table.Cell>{m.subject}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
