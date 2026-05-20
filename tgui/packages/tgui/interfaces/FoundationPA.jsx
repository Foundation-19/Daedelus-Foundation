import { useBackend } from '../backend';
import { Button, Dropdown, Input, NoticeBox, Section } from '../components';
import { Window } from '../layouts';
import { useState } from 'react';

export const FoundationPA = (props, context) => {
  const { act, data } = useBackend(context);
  const { cooldown, zones } = data;
  const [message, setMessage] = useState('');
  const [zone, setZone] = useState('All Zones');

  return (
    <Window width={500} height={300} theme="scp_terminal">
      <Window.Content scrollable>
        <Section title="Foundation PA System">
          {cooldown > 0 && (
            <NoticeBox warning>
              Cooldown: {Math.ceil(cooldown / 10)}s
            </NoticeBox>
          )}
          <Dropdown
            options={zones || ['All Zones']}
            selected={zone}
            onSelected={val => setZone(val)}
          />
          <Input
            fluid
            placeholder="Enter announcement message..."
            value={message}
            onInput={(_, val) => setMessage(val)}
          />
          <Button
            content="BROADCAST"
            color="red"
            disabled={cooldown > 0 || !message}
            onClick={() => act('announce', { message, zone })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
