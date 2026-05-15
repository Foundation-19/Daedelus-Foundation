import { BooleanLike } from 'common/react';
import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type Personnel = {
  name: string;
  job: string;
  area: string;
  health: number;
  ref: string;
};

type Data = {
  personnel: Personnel[];
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
  'D-Class',
];

export const PersonnelManagement = (props) => {
  const { act, data } = useBackend<Data>();
  const { personnel } = data;
  const [selectedRef, setSelectedRef] = useState<string | null>(null);
  const selected = personnel.find((p) => p.ref === selectedRef);

  return (
    <Window theme="scp_terminal" width={600} height={500}>
      <Window.Content scrollable>
        <Section title="PERSONNEL ROSTER">
          <Table>
            <Table.Row header>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Assignment</Table.Cell>
              <Table.Cell>Location</Table.Cell>
              <Table.Cell>Health</Table.Cell>
            </Table.Row>
            {personnel.map((p) => (
              <Table.Row
                key={p.ref}
                onClick={() => setSelectedRef(p.ref)}
                style={{
                  backgroundColor:
                    p.ref === selectedRef ? '#553300' : 'transparent',
                  cursor: 'pointer',
                }}
              >
                <Table.Cell>{p.name}</Table.Cell>
                <Table.Cell>{p.job}</Table.Cell>
                <Table.Cell>{p.area}</Table.Cell>
                <Table.Cell
                  style={{
                    color:
                      p.health > 75
                        ? '#44ff44'
                        : p.health > 25
                          ? '#ffaa00'
                          : '#ff4444',
                  }}
                >
                  {p.health}%
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        {selected && (
          <Section title={`TRANSFER: ${selected.name}`}>
            <LabeledList>
              <LabeledList.Item label="Current Assignment">
                {selected.job}
              </LabeledList.Item>
              <LabeledList.Item label="Location">
                {selected.area}
              </LabeledList.Item>
              <LabeledList.Item label="Transfer To">
                {DEPARTMENTS.map((dept) => (
                  <Button
                    key={dept}
                    content={dept}
                    onClick={() =>
                      act('transfer', {
                        ref: selected.ref,
                        department: dept,
                      })
                    }
                  />
                ))}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
