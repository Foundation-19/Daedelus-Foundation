import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

export const DclassExperimentTerminal = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    selected_scp,
    selected_test_type,
    selected_danger,
    mandatory,
    available_scps,
    eligible_subjects,
    is_dclass,
  } = data;

  return (
    <Window
      title="D-Class Assignment Terminal"
      width={600}
      height={700}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        {is_dclass && (
          <Box color="red" bold mb={1}>
            ACCESS DENIED: D-Class personnel cannot operate this terminal.
          </Box>
        )}

        <Section title="Select SCP">
          {available_scps.map((scp) => (
            <Button
              key={scp.id}
              selected={selected_scp === scp.id}
              onClick={() => act('select_scp', { scp_id: scp.id })}
            >
              {scp.id} ({scp.class})
            </Button>
          ))}
        </Section>

        <Section title="Test Parameters">
          <LabeledList>
            <LabeledList.Item label="Test Type">
              <Stack>
                <Button
                  selected={selected_test_type === 1}
                  onClick={() => act('select_test_type', { type: 1 })}
                >
                  Behavioral
                </Button>
                <Button
                  selected={selected_test_type === 2}
                  onClick={() => act('select_test_type', { type: 2 })}
                >
                  Containment
                </Button>
                <Button
                  selected={selected_test_type === 5}
                  onClick={() => act('select_test_type', { type: 5 })}
                >
                  Medical
                </Button>
                <Button
                  selected={selected_test_type === 10}
                  onClick={() => act('select_test_type', { type: 10 })}
                >
                  Observation
                </Button>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Danger Level">
              <Stack>
                {[1, 2, 3, 4, 5].map((level) => (
                  <Button
                    key={level}
                    color={level <= 2 ? 'good' : level <= 3 ? 'average' : 'bad'}
                    selected={selected_danger === level}
                    onClick={() => act('select_danger', { danger: level })}
                  >
                    {
                      ['Minimal', 'Low', 'Medium', 'High', 'Critical'][
                        level - 1
                      ]
                    }
                  </Button>
                ))}
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Assignment Type">
              <Button
                color={mandatory ? 'bad' : 'default'}
                onClick={() => act('toggle_mandatory')}
              >
                {mandatory ? 'MANDATORY' : 'Voluntary'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Available D-Class Subjects">
          {!eligible_subjects.length && (
            <Box color="label">No eligible subjects. Select an SCP above.</Box>
          )}
          <Table>
            <Table.Row header>
              <Table.Cell>Designation</Table.Cell>
              <Table.Cell>Trust</Table.Cell>
              <Table.Cell>Tests</Table.Cell>
              <Table.Cell>Health</Table.Cell>
              <Table.Cell>Action</Table.Cell>
            </Table.Row>
            {eligible_subjects.map((subject) => (
              <Table.Row key={subject.ckey}>
                <Table.Cell>{subject.name}</Table.Cell>
                <Table.Cell>
                  {
                    [
                      'Hostile',
                      'Suspicious',
                      'Neutral',
                      'Cooperative',
                      'Trusted',
                    ][subject.trust]
                  }
                </Table.Cell>
                <Table.Cell>{subject.tests}</Table.Cell>
                <Table.Cell>{subject.health}%</Table.Cell>
                <Table.Cell>
                  <Button
                    icon="user-plus"
                    color="good"
                    onClick={() =>
                      act('assign_subject', { ckey: subject.ckey })
                    }
                  >
                    Assign
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
