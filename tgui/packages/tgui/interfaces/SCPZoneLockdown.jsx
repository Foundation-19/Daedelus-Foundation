import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const SCPZoneLockdown = (props, context) => {
  const { act, data } = useBackend(context);
  const { zone_states, cooldown } = data;

  return (
    <Window width={400} height={350} theme="scp_terminal">
      <Window.Content scrollable>
        <Section title="Zone Lockdown Control">
          {cooldown > 0 && (
            <NoticeBox warning>
              Cooldown: {Math.ceil(cooldown / 10)}s
            </NoticeBox>
          )}
          <LabeledList>
            {Object.entries(zone_states || {}).map(([zone, locked]) => (
              <LabeledList.Item
                key={zone}
                label={zone.toUpperCase()}
                color={locked ? 'red' : 'green'}>
                <Button
                  content={locked ? 'LOCKED' : 'OPEN'}
                  color={locked ? 'red' : 'green'}
                  disabled={cooldown > 0}
                  onClick={() => act('toggle_zone', { zone })}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
          <Section>
            <Button
              content="LOCKDOWN ALL ZONES"
              color="red"
              disabled={cooldown > 0}
              onClick={() => act('lockdown_all')}
            />
            <Button
              content="UNLOCK ALL ZONES"
              color="green"
              disabled={cooldown > 0}
              onClick={() => act('unlock_all')}
            />
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
