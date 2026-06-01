import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Divider } from '../components';
import { Window } from '../layouts';

const CLASS_COLORS = {
  Safe: 'good',
  Euclid: 'average',
  Keter: 'bad',
};

export const SCPRecontainmentGuide = (props, context) => {
  const { act, data } = useBackend(context);
  const guides = data.guides || [];

  return (
    <Window width={550} height={700} theme="scp_terminal">
      <Window.Content scrollable>
        <Section title="SCP Recontainment Protocols">
          <Box color="label" mb={1}>
            CLASSIFIED — Level 2 Security Clearance Required
          </Box>
        </Section>
        <Stack vertical>
          {guides.map(guide => (
            <Stack.Item key={guide.designation}>
              <Section
                title={guide.designation}
                buttons={(
                  <Box
                    bold
                    color={CLASS_COLORS[guide.class] || 'label'}
                    fontSize="14px"
                  >
                    {guide.class}
                  </Box>
                )}
              >
                <LabeledList>
                  <LabeledList.Item label="Threat">
                    {guide.threat}
                  </LabeledList.Item>
                  <LabeledList.Item label="Recontainment Procedures">
                    <Stack vertical>
                      {guide.procedures.map((proc, i) => (
                        <Stack.Item key={i}>
                          <Box>
                            {i + 1}. {proc}
                          </Box>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </LabeledList.Item>
                </LabeledList>
                <Box
                  mt={1}
                  p={1}
                  backgroundColor="rgba(255,0,0,0.1)"
                  color="bad"
                  bold
                >
                  WARNING: {guide.warning}
                </Box>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
