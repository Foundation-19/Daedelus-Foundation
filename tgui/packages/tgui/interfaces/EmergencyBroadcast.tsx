import { BooleanLike } from 'common/react';
import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type PresetCode = {
  code: string;
  desc: string;
};

type Data = {
  cooldown_active: BooleanLike;
  cooldown_remaining: number;
  preset_codes: PresetCode[];
};

export const EmergencyBroadcast = (props) => {
  const { act, data } = useBackend<Data>();
  const { cooldown_active, cooldown_remaining, preset_codes } = data;
  const [customCode, setCustomCode] = useState('');
  const [customMessage, setCustomMessage] = useState('');

  return (
    <Window theme="scp_terminal" width={500} height={450}>
      <Window.Content scrollable>
        <Section title="EMERGENCY BROADCAST SYSTEM">
          <LabeledList>
            <LabeledList.Item label="Status">
              {cooldown_active ? (
                <Box style={{ color: '#ffaa00' }}>
                  COOLDOWN: {Math.ceil(cooldown_remaining / 10)}s
                </Box>
              ) : (
                <Box style={{ color: '#44ff44' }}>READY</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="PRESET CODES">
          {preset_codes.map((p) => (
            <Box key={p.code} mb={1}>
              <Button
                content={`${p.code}: ${p.desc}`}
                disabled={cooldown_active}
                color="bad"
                fluid
                onClick={() => act('broadcast_preset', { code: p.code })}
              />
            </Box>
          ))}
        </Section>
        <Section title="CUSTOM BROADCAST">
          <LabeledList>
            <LabeledList.Item label="Code">
              <Input
                value={customCode}
                onInput={(_, v) => setCustomCode(v)}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Message">
              <Input
                value={customMessage}
                onInput={(_, v) => setCustomMessage(v)}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Broadcast">
              <Button
                content="BROADCAST"
                color="bad"
                disabled={cooldown_active || !customCode || !customMessage}
                onClick={() =>
                  act('broadcast_custom', {
                    code: customCode,
                    message: customMessage,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
