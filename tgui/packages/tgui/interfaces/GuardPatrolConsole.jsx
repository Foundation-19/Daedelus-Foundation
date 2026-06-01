import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Divider } from '../components';
import { Window } from '../layouts';

export const GuardPatrolConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const routes = data.routes || [];
  const guards = data.guards || [];
  const escorts = data.escorts || [];

  return (
    <Window width={600} height={700} theme="scp_terminal">
      <Window.Content scrollable>
        <Section title="Active Patrol Routes">
          <Stack vertical>
            {routes.map(route => (
              <Stack.Item key={route.route_id}>
                <Section
                  title={route.route_name}
                  buttons={(
                    <Button
                      color="good"
                      content="Self-Assign"
                      onClick={() => act('self_assign', {
                        route_id: route.route_id,
                      })}
                    />
                  )}
                >
                  <LabeledList>
                    <LabeledList.Item label="Zone">
                      {route.zone.toUpperCase()}
                    </LabeledList.Item>
                    <LabeledList.Item label="Waypoints">
                      {route.waypoint_count} checkpoints
                    </LabeledList.Item>
                    <LabeledList.Item label="Assigned Guard">
                      <Box color={route.guard_name === 'Unassigned' ? 'bad' : 'good'}>
                        {route.guard_name}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Completed Patrols">
                      {route.completed_count}
                    </LabeledList.Item>
                    <LabeledList.Item label="Status">
                      {route.on_cooldown ? (
                        <Box color="average">On cooldown</Box>
                      ) : (
                        <Box color="good">Ready</Box>
                      )}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
            ))}
            {routes.length === 0 && (
              <Box color="label">No patrol routes available.</Box>
            )}
          </Stack>
        </Section>

        <Divider />

        <Section
          title="Available Guards"
          buttons={(
            <Button
              color="average"
              content="Release Self from Patrol"
              onClick={() => act('self_release')}
            />
          )}
        >
          <Stack vertical>
            {guards.map(guard => (
              <Stack.Item key={guard.ckey}>
                <Stack>
                  <Stack.Item grow={1}>
                    <Box bold>{guard.name}</Box>
                    <Box fontSize="12px" color="label">
                      {guard.job}
                      {guard.assigned_route && (
                        <Box as="span" color="good">
                          {' '}| Patrol: {guard.assigned_route}
                        </Box>
                      )}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    {routes.map(route => (
                      <Button
                        key={route.route_id}
                        color="average"
                        compact
                        disabled={route.guard_name !== 'Unassigned'
                          && route.guard_name !== guard.name}
                        content={route.route_name}
                        onClick={() => act('assign_guard', {
                          ckey: guard.ckey,
                          route_id: route.route_id,
                        })}
                      />
                    ))}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
            {guards.length === 0 && (
              <Box color="label">No guards on duty.</Box>
            )}
          </Stack>
        </Section>

        {escorts.length > 0 && (
          <>
            <Divider />
            <Section title="Escort Tasks">
              <Stack vertical>
                {escorts.map(escort => (
                  <Stack.Item key={escort.task_id}>
                    <Section
                      title={`${escort.subject_name} → ${escort.scp_name}`}
                      buttons={(
                        <>
                          {escort.status === 'pending' && (
                            <Button
                              color="good"
                              content="Accept Escort"
                              onClick={() => act('accept_escort', {
                                task_id: escort.task_id,
                              })}
                            />
                          )}
                          {escort.status === 'escorting' && (
                            <Button
                              color="average"
                              content="Complete Delivery"
                              onClick={() => act('complete_escort', {
                                task_id: escort.task_id,
                              })}
                            />
                          )}
                        </>
                      )}
                    >
                      <LabeledList>
                        <LabeledList.Item label="Test Type">
                          {escort.test_type}
                        </LabeledList.Item>
                        <LabeledList.Item label="Risk Level">
                          {escort.risk_level}/5
                        </LabeledList.Item>
                        <LabeledList.Item label="Status">
                          <Box color={escort.status === 'pending' ? 'bad' : 'good'}>
                            {escort.status === 'pending' ? 'Awaiting Guard'
                              : escort.status === 'escorting' ? `Escorting (Guard: ${escort.guard_name})`
                              : escort.status}
                          </Box>
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
