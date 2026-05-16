import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section, Table, TextArea } from '../components';
import { Window } from '../layouts';

type Inspection = {
  department: string;
  rating: number;
  findings: string;
  inspector: string;
  time: string;
};

type Data = {
  inspections: Inspection[];
};

const DEPARTMENTS = [
  'Security',
  'Science',
  'Medical',
  'Engineering',
  'Containment',
  'Logistics',
  'Service',
  'D-Class Housing',
];

export const FacilityInspection = (props) => {
  const { act, data } = useBackend<Data>();
  const { inspections } = data;
  const [department, setDepartment] = useState('');
  const [rating, setRating] = useState(75);
  const [findings, setFindings] = useState('');

  return (
    <Window theme="scp_terminal" width={550} height={550}>
      <Window.Content scrollable>
        <Section title="CONDUCT INSPECTION">
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
            <LabeledList.Item label="Rating">
              <Input
                value={rating}
                onInput={(_, v) => setRating(Number(v))}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Findings">
              <TextArea
                value={findings}
                onInput={(_, v) => setFindings(v)}
                height="80px"
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Submit">
              <Button
                content="FILE INSPECTION"
                disabled={!department || !findings}
                onClick={() => {
                  act('conduct_inspection', {
                    department,
                    rating,
                    findings,
                  });
                  setDepartment('');
                  setFindings('');
                  setRating(75);
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="INSPECTION LOG">
          <Table>
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>Department</Table.Cell>
              <Table.Cell>Rating</Table.Cell>
              <Table.Cell>Inspector</Table.Cell>
              <Table.Cell>Findings</Table.Cell>
            </Table.Row>
            {inspections.map((insp, i) => (
              <Table.Row key={i}>
                <Table.Cell>{insp.time}</Table.Cell>
                <Table.Cell>{insp.department}</Table.Cell>
                <Table.Cell
                  style={{
                    color:
                      insp.rating >= 75
                        ? '#44ff44'
                        : insp.rating >= 50
                          ? '#ffaa00'
                          : '#ff4444',
                  }}
                >
                  {insp.rating}%
                </Table.Cell>
                <Table.Cell>{insp.inspector}</Table.Cell>
                <Table.Cell>{insp.findings}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
