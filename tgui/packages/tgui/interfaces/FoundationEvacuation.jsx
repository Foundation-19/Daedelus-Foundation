import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const FoundationEvacuation = (props, context) => {
  const { act, data } = useBackend(context);
  const { evacuation_called, time_remaining, security_level } = data;

  return (
    <Window width={400} height={300} theme="scp_terminal">
      <Window.Content scrollable>
        <Section title="Foundation Evacuation System">
          <NoticeBox info>
            Security Level: {security_level}
          </NoticeBox>
          {evacuation_called ? (
            <>
              <NoticeBox danger>
                EVACUATION IN PROGRESS
                <br />
                Time Remaining: {Math.ceil(time_remaining)}s
              </NoticeBox>
              <Button
                content="CANCEL EVACUATION"
                color="red"
                onClick={() => act('cancel_evacuation')}
              />
            </>
          ) : (
            <>
              <NoticeBox>
                Evacuation requires Code Red or higher.
              </NoticeBox>
              <Button
                content="AUTHORIZE EVACUATION"
                color="red"
                disabled={security_level < 2}
                onClick={() => act('call_evacuation')}
              />
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
