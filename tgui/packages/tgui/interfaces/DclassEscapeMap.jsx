import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const DclassEscapeMap = (props, context) => {
  const { act, data } = useBackend(context);
  const { routes = [] } = data;
  const [selectedRoute, setSelectedRoute] = useLocalState(
    context,
    'selectedRoute',
    null,
  );

  return (
    <Window theme="scp_terminal" width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Escape Routes">
          {routes.map((route) => (
            <Button
              key={route.id}
              fluid
              color={selectedRoute === route.id ? 'good' : 'default'}
              content={route.name}
              onClick={() => setSelectedRoute(route.id)}
            />
          ))}
        </Section>
        {selectedRoute &&
          (() => {
            const route = routes.find((r) => r.id === selectedRoute);
            if (!route) return null;
            return (
              <Section title={route.name}>
                <LabeledList>
                  <LabeledList.Item label="Description">
                    {route.description}
                  </LabeledList.Item>
                  <LabeledList.Item label="Difficulty">
                    <Box
                      color={
                        route.difficulty === 'Easy'
                          ? 'good'
                          : route.difficulty === 'Medium'
                            ? 'average'
                            : route.difficulty === 'Hard'
                              ? 'bad'
                              : 'default'
                      }
                    >
                      {route.difficulty}
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Success Chance">
                    {route.success_chance}%
                  </LabeledList.Item>
                  <LabeledList.Item label="Time Required">
                    {route.time_required} minutes
                  </LabeledList.Item>
                  <LabeledList.Item label="Requirements">
                    {(route.requirements || []).length === 0
                      ? 'None'
                      : route.requirements.map((req) => (
                          <Box key={req.name}>
                            {req.met ? '✓' : '✗'} {req.name}
                          </Box>
                        ))}
                  </LabeledList.Item>
                </LabeledList>
                <Button
                  mt={1}
                  fluid
                  color="danger"
                  content="Attempt Escape"
                  onClick={() => act('attempt', { route_id: route.id })}
                />
              </Section>
            );
          })()}
      </Window.Content>
    </Window>
  );
};
