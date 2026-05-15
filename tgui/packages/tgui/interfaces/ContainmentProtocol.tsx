import { BooleanLike } from 'common/react';
import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section, TextArea } from '../components';
import { Window } from '../layouts';

type SCP = {
  name: string;
  scp_id: string;
  breached: BooleanLike;
  containment: string;
  recontainment: string;
  ref: string;
};

type Data = {
  scps: SCP[];
};

export const ContainmentProtocol = (props) => {
  const { act, data } = useBackend<Data>();
  const { scps } = data;
  const [selectedRef, setSelectedRef] = useState<string | null>(null);
  const [newContainment, setNewContainment] = useState('');
  const selected = scps.find((s) => s.ref === selectedRef);

  return (
    <Window theme="scp_terminal" width={550} height={550}>
      <Window.Content scrollable>
        <Section title="SCP ENTITIES">
          {scps.map((s) => (
            <Button
              key={s.ref}
              content={`${s.name} ${s.breached ? '[BREACHED]' : '[CONTAINED]'}`}
              selected={s.ref === selectedRef}
              color={s.breached ? 'bad' : 'default'}
              onClick={() => {
                setSelectedRef(s.ref);
                setNewContainment(s.containment);
              }}
              fluid
            />
          ))}
        </Section>
        {selected && (
          <Section title={`CONTAINMENT: ${selected.name}`}>
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box
                  style={{
                    color: selected.breached ? '#ff4444' : '#44ff44',
                    fontWeight: 'bold',
                  }}
                >
                  {selected.breached ? 'BREACHED' : 'CONTAINED'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Containment Procedures">
                <TextArea
                  value={newContainment}
                  onInput={(_, v) => setNewContainment(v)}
                  height="120px"
                  fluid
                />
              </LabeledList.Item>
              <LabeledList.Item label="Update">
                <Button
                  content="UPDATE CONTAINMENT PROCEDURES"
                  onClick={() =>
                    act('update_procedures', {
                      ref: selected.ref,
                      type: 'containment',
                      text: newContainment,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Recontainment">
                <Box style={{ whiteSpace: 'pre-wrap' }}>
                  {selected.recontainment}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
