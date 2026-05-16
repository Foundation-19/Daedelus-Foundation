import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type Requisition = {
  department: string;
  item: string;
  quantity: number;
  priority: string;
  reason: string;
  status: string;
  requestor: string;
  time: string;
};

type Data = {
  requisitions: Requisition[];
};

const DEPARTMENTS = [
  'Security',
  'Science',
  'Medical',
  'Engineering',
  'Containment',
  'Logistics',
  'Service',
];

const PRIORITIES = ['low', 'normal', 'high', 'critical'];

export const DepartmentRequisition = (props) => {
  const { act, data } = useBackend<Data>();
  const { requisitions } = data;
  const [department, setDepartment] = useState('');
  const [item, setItem] = useState('');
  const [quantity, setQuantity] = useState(1);
  const [priority, setPriority] = useState('normal');
  const [reason, setReason] = useState('');

  return (
    <Window theme="scp_terminal" width={600} height={550}>
      <Window.Content scrollable>
        <Section title="SUBMIT REQUISITION">
          <LabeledList>
            <LabeledList.Item label="Department">
              {DEPARTMENTS.map((d) => (
                <Button
                  key={d}
                  content={d}
                  selected={department === d}
                  onClick={() => setDepartment(d)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Item">
              <Input value={item} onInput={(_, v) => setItem(v)} fluid />
            </LabeledList.Item>
            <LabeledList.Item label="Quantity">
              <Input
                value={quantity}
                onInput={(_, v) => setQuantity(Number(v))}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Priority">
              {PRIORITIES.map((p) => (
                <Button
                  key={p}
                  content={p}
                  selected={priority === p}
                  color={
                    p === 'critical'
                      ? 'bad'
                      : p === 'high'
                        ? 'average'
                        : 'default'
                  }
                  onClick={() => setPriority(p)}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Reason">
              <Input value={reason} onInput={(_, v) => setReason(v)} fluid />
            </LabeledList.Item>
            <LabeledList.Item label="Submit">
              <Button
                content="SUBMIT REQUISITION"
                disabled={!department || !item}
                onClick={() => {
                  act('submit_requisition', {
                    department,
                    item,
                    quantity,
                    priority,
                    reason,
                  });
                  setDepartment('');
                  setItem('');
                  setReason('');
                  setQuantity(1);
                  setPriority('normal');
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="REQUISITIONS LOG">
          <Table>
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>Dept</Table.Cell>
              <Table.Cell>Item</Table.Cell>
              <Table.Cell>Qty</Table.Cell>
              <Table.Cell>Priority</Table.Cell>
              <Table.Cell>Status</Table.Cell>
            </Table.Row>
            {requisitions.map((r, i) => (
              <Table.Row key={i}>
                <Table.Cell>{r.time}</Table.Cell>
                <Table.Cell>{r.department}</Table.Cell>
                <Table.Cell>{r.item}</Table.Cell>
                <Table.Cell>{r.quantity}</Table.Cell>
                <Table.Cell
                  style={{
                    color:
                      r.priority === 'critical'
                        ? '#ff4444'
                        : r.priority === 'high'
                          ? '#ffaa00'
                          : '#cccccc',
                  }}
                >
                  {r.priority.toUpperCase()}
                </Table.Cell>
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
                  ) : r.status === 'approved' ? (
                    <Button
                      content="FULFILL"
                      color="good"
                      onClick={() => act('fulfill', { index: i + 1 })}
                    />
                  ) : (
                    <Box
                      style={{
                        color:
                          r.status === 'fulfilled'
                            ? '#44ff44'
                            : '#ff4444',
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
