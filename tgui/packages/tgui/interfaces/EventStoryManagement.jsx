import React, { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

export const EventStoryManagement = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = useState('overview');
  const [selectedEvent, setSelectedEvent] = useState(null);
  const [selectedArc, setSelectedArc] = useState(null);

  const {
    active_events,
    event_templates,
    story_arcs,
    player_initiated_events,
    emergent_stories,
    event_triggers,
    metrics,
  } = data;

  return (
    <Window width={1400} height={900}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item>
            <Section title="Event & Story Management System">
              <Flex>
                <Flex.Item width="70%">
                  <LabeledList>
                    <LabeledList.Item label="Total Events Created">
                      {metrics?.total_events_created || 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Active Story Arcs">
                      {metrics?.active_story_arcs || 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Player Participation Rate">
                      {metrics?.player_participation_rate || 0}%
                    </LabeledList.Item>
                    <LabeledList.Item label="Event Completion Rate">
                      {metrics?.event_completion_rate || 0}%
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
                <Flex.Item width="30%">
                  <Button fluid icon="plus" onClick={() => act('create_event')}>
                    Create Event
                  </Button>
                  <Button
                    fluid
                    icon="book"
                    onClick={() => act('create_story_arc')}
                    mt={1}
                  >
                    Create Story Arc
                  </Button>
                  <Button
                    fluid
                    icon="user-plus"
                    onClick={() => act('propose_player_event')}
                    mt={1}
                  >
                    Propose Player Event
                  </Button>
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>

          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === 'overview'}
                onClick={() => setActiveTab('overview')}
              >
                Overview
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'events'}
                onClick={() => setActiveTab('events')}
              >
                Active Events
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'story_arcs'}
                onClick={() => setActiveTab('story_arcs')}
              >
                Story Arcs
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'player_events'}
                onClick={() => setActiveTab('player_events')}
              >
                Player Events
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'emergent_stories'}
                onClick={() => setActiveTab('emergent_stories')}
              >
                Emergent Stories
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'templates'}
                onClick={() => setActiveTab('templates')}
              >
                Event Templates
              </Tabs.Tab>
            </Tabs>

            <Box height="calc(100% - 50px)" overflowY="auto">
              {activeTab === 'overview' && (
                <OverviewTab
                  active_events={active_events}
                  story_arcs={story_arcs}
                  player_initiated_events={player_initiated_events}
                  emergent_stories={emergent_stories}
                  metrics={metrics}
                />
              )}
              {activeTab === 'events' && (
                <EventsTab
                  active_events={active_events}
                  selectedEvent={selectedEvent}
                  setSelectedEvent={setSelectedEvent}
                />
              )}
              {activeTab === 'story_arcs' && (
                <StoryArcsTab
                  story_arcs={story_arcs}
                  selectedArc={selectedArc}
                  setSelectedArc={setSelectedArc}
                />
              )}
              {activeTab === 'player_events' && (
                <PlayerEventsTab events={player_initiated_events} />
              )}
              {activeTab === 'emergent_stories' && (
                <EmergentStoriesTab stories={emergent_stories} />
              )}
              {activeTab === 'templates' && (
                <EventTemplatesTab templates={event_templates} />
              )}
            </Box>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const OverviewTab = ({
  active_events,
  story_arcs,
  player_initiated_events,
  emergent_stories,
  metrics,
}) => {
  return (
    <Flex>
      <Flex.Item width="50%">
        <Section title="Active Events">
          {active_events?.length > 0 ? (
            active_events.map((event, index) => (
              <Box
                key={event.event_id}
                mb={2}
                p={1}
                backgroundColor="rgba(255, 255, 255, 0.05)"
              >
                <Flex justify="space-between" align="center">
                  <Flex.Item>
                    <Box fontWeight="bold">{event.event_title}</Box>
                    <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                      {event.event_type} • Severity: {event.event_severity}/10
                    </Box>
                    <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                      Stage {event.current_stage}/
                      {event.event_stages?.length || 1}
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Box
                      color={
                        event.event_status === 'resolved'
                          ? 'green'
                          : event.event_status === 'active'
                            ? 'blue'
                            : 'orange'
                      }
                    >
                      {event.event_status}
                    </Box>
                  </Flex.Item>
                </Flex>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              No active events.
            </Box>
          )}
        </Section>
      </Flex.Item>

      <Flex.Item width="50%">
        <Section title="Active Story Arcs">
          {story_arcs?.length > 0 ? (
            story_arcs.map((arc, index) => (
              <Box
                key={arc.arc_id}
                mb={2}
                p={1}
                backgroundColor="rgba(255, 255, 255, 0.05)"
              >
                <Flex justify="space-between" align="center">
                  <Flex.Item>
                    <Box fontWeight="bold">{arc.arc_title}</Box>
                    <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                      {arc.arc_type} • Complexity: {arc.arc_complexity}/10
                    </Box>
                    <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                      {arc.arc_events?.length || 0} events
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Box
                      color={
                        arc.arc_status === 'completed'
                          ? 'green'
                          : arc.arc_status === 'active'
                            ? 'blue'
                            : 'orange'
                      }
                    >
                      {arc.arc_status}
                    </Box>
                  </Flex.Item>
                </Flex>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              No active story arcs.
            </Box>
          )}
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const EventsTab = ({ active_events, selectedEvent, setSelectedEvent }) => {
  const { act } = useBackend(context);

  return (
    <Flex>
      <Flex.Item width="40%">
        <Section title="Active Events">
          {active_events?.length > 0 ? (
            active_events.map((event, index) => (
              <Box
                key={event.event_id}
                p={1}
                mb={1}
                backgroundColor={
                  selectedEvent?.event_id === event.event_id
                    ? 'rgba(0, 255, 0, 0.1)'
                    : 'rgba(255, 255, 255, 0.05)'
                }
                onClick={() => setSelectedEvent(event)}
                style={{ cursor: 'pointer' }}
              >
                <Box fontWeight="bold">{event.event_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  {event.event_type} • {event.event_status}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  Severity: {event.event_severity}/10 • Priority:{' '}
                  {event.event_priority}/5
                </Box>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              No active events.
            </Box>
          )}
        </Section>
      </Flex.Item>

      <Flex.Item width="60%">
        {selectedEvent ? (
          <EventDetailView event={selectedEvent} />
        ) : (
          <Section title="Event Details">
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              Select an event to view details.
            </Box>
          </Section>
        )}
      </Flex.Item>
    </Flex>
  );
};

const EventDetailView = ({ event }) => {
  const { act } = useBackend(context);

  return (
    <Section title={event.event_title}>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Type">{event.event_type}</LabeledList.Item>
            <LabeledList.Item label="Status">
              {event.event_status}
            </LabeledList.Item>
            <LabeledList.Item label="Severity">
              {event.event_severity}/10
            </LabeledList.Item>
            <LabeledList.Item label="Priority">
              {event.event_priority}/5
            </LabeledList.Item>
            <LabeledList.Item label="Current Stage">
              {event.current_stage}/{event.event_stages?.length || 1}
            </LabeledList.Item>
            <LabeledList.Item label="Duration">
              {Math.round((world.time - event.event_start_time) / 600)} minutes
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>

        <Stack.Item>
          <Section title="Description">
            <Box>{event.event_description || 'No description available.'}</Box>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Event Progression">
            <ProgressBar
              value={event.current_stage}
              maxValue={event.event_stages?.length || 1}
              color="blue"
            />
            <Box fontSize="0.8em" textAlign="center" mt={1}>
              Stage {event.current_stage} of {event.event_stages?.length || 1}
            </Box>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Participants">
            {event.event_participants?.length > 0 ? (
              event.event_participants.map((participant, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 255, 255, 0.05)"
                >
                  <Box fontWeight="bold">{participant}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    Role: {event.event_roles?.[participant] || 'Participant'}
                  </Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No participants yet.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Recent Actions">
            {event.event_actions?.length > 0 ? (
              event.event_actions.slice(-5).map((action, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 255, 255, 0.05)"
                >
                  <Box fontSize="0.9em">{action}</Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No recent actions.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Flex>
            <Flex.Item width="50%">
              <Button
                fluid
                icon="user-plus"
                onClick={() => act('join_event', { event_id: event.event_id })}
              >
                Join Event
              </Button>
            </Flex.Item>
            <Flex.Item width="50%">
              <Button
                fluid
                icon="forward"
                onClick={() =>
                  act('advance_event', { event_id: event.event_id })
                }
              >
                Advance Event
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StoryArcsTab = ({ story_arcs, selectedArc, setSelectedArc }) => {
  const { act } = useBackend(context);

  return (
    <Flex>
      <Flex.Item width="40%">
        <Section title="Story Arcs">
          {story_arcs?.length > 0 ? (
            story_arcs.map((arc, index) => (
              <Box
                key={arc.arc_id}
                p={1}
                mb={1}
                backgroundColor={
                  selectedArc?.arc_id === arc.arc_id
                    ? 'rgba(0, 255, 0, 0.1)'
                    : 'rgba(255, 255, 255, 0.05)'
                }
                onClick={() => setSelectedArc(arc)}
                style={{ cursor: 'pointer' }}
              >
                <Box fontWeight="bold">{arc.arc_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  {arc.arc_type} • {arc.arc_status}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  Complexity: {arc.arc_complexity}/10 •{' '}
                  {arc.arc_events?.length || 0} events
                </Box>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              No story arcs available.
            </Box>
          )}
        </Section>
      </Flex.Item>

      <Flex.Item width="60%">
        {selectedArc ? (
          <StoryArcDetailView arc={selectedArc} />
        ) : (
          <Section title="Story Arc Details">
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              Select a story arc to view details.
            </Box>
          </Section>
        )}
      </Flex.Item>
    </Flex>
  );
};

const StoryArcDetailView = ({ arc }) => {
  const { act } = useBackend(context);

  return (
    <Section title={arc.arc_title}>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Type">{arc.arc_type}</LabeledList.Item>
            <LabeledList.Item label="Status">{arc.arc_status}</LabeledList.Item>
            <LabeledList.Item label="Complexity">
              {arc.arc_complexity}/10
            </LabeledList.Item>
            <LabeledList.Item label="Events">
              {arc.arc_events?.length || 0}
            </LabeledList.Item>
            <LabeledList.Item label="Characters">
              {arc.arc_characters?.length || 0}
            </LabeledList.Item>
            <LabeledList.Item label="Objectives">
              {arc.arc_objectives?.length || 0}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>

        <Stack.Item>
          <Section title="Description">
            <Box>{arc.arc_description || 'No description available.'}</Box>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Themes">
            {arc.arc_themes?.length > 0 ? (
              <Flex wrap>
                {arc.arc_themes.map((theme, index) => (
                  <Flex.Item key={index} mr={1} mb={1}>
                    <Box
                      p={0.5}
                      backgroundColor="rgba(0, 255, 0, 0.1)"
                      borderRadius="4px"
                      fontSize="0.8em"
                    >
                      {theme}
                    </Box>
                  </Flex.Item>
                ))}
              </Flex>
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No themes defined.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Objectives">
            {arc.arc_objectives?.length > 0 ? (
              arc.arc_objectives.map((objective, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(0, 255, 0, 0.1)"
                >
                  <Box fontWeight="bold">{objective}</Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No objectives defined.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Arc Events">
            {arc.arc_events?.length > 0 ? (
              arc.arc_events.map((event, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 255, 255, 0.05)"
                >
                  <Box fontWeight="bold">{event.event_title}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    {event.event_type} • {event.event_status}
                  </Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No events in this arc.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Button
            fluid
            icon="plus"
            onClick={() => act('add_event_to_arc', { arc_id: arc.arc_id })}
          >
            Add Event to Arc
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PlayerEventsTab = ({ events }) => {
  const { act } = useBackend(context);

  return (
    <Section title="Player-Initiated Events">
      {events?.length > 0 ? (
        events.map((event, index) => (
          <Box
            key={event.event_id}
            mb={2}
            p={2}
            backgroundColor="rgba(255, 255, 255, 0.05)"
          >
            <Flex justify="space-between" align="center">
              <Flex.Item>
                <Box fontWeight="bold">{event.event_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  Type: {event.event_type} • Initiator: {event.event_initiator}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {event.event_description}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Box
                  color={
                    event.event_status === 'approved'
                      ? 'green'
                      : event.event_status === 'proposed'
                        ? 'blue'
                        : 'orange'
                  }
                >
                  {event.event_status}
                </Box>
                {event.event_status === 'proposed' && (
                  <Button
                    size="small"
                    icon="check"
                    onClick={() =>
                      act('approve_event', { event_id: event.event_id })
                    }
                    mt={1}
                  >
                    Approve
                  </Button>
                )}
              </Flex.Item>
            </Flex>
          </Box>
        ))
      ) : (
        <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
          No player-initiated events.
        </Box>
      )}
    </Section>
  );
};

const EmergentStoriesTab = ({ stories }) => {
  return (
    <Section title="Emergent Stories">
      {stories?.length > 0 ? (
        stories.map((story, index) => (
          <Box
            key={story.story_id}
            mb={2}
            p={2}
            backgroundColor="rgba(255, 215, 0, 0.1)"
          >
            <Box fontWeight="bold">{story.story_title}</Box>
            <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
              Type: {story.story_type}
            </Box>
            <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
              {story.story_description}
            </Box>
            <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
              Created:{' '}
              {new Date(story.story_creation_date * 1000).toLocaleDateString()}
            </Box>
          </Box>
        ))
      ) : (
        <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
          No emergent stories.
        </Box>
      )}
    </Section>
  );
};

const EventTemplatesTab = ({ templates }) => {
  const { act } = useBackend(context);

  return (
    <Section title="Event Templates">
      {Object.entries(templates || {}).map(([template_id, template]) => (
        <Box
          key={template_id}
          mb={2}
          p={2}
          backgroundColor="rgba(255, 255, 255, 0.05)"
        >
          <Flex justify="space-between" align="center">
            <Flex.Item>
              <Box fontWeight="bold">{template.name}</Box>
              <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                {template.description}
              </Box>
              <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                Severity: {template.severity}/10
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="plus"
                onClick={() => act('use_event_template', { template_id })}
              >
                Use Template
              </Button>
            </Flex.Item>
          </Flex>

          <Box mt={1}>
            <Box fontWeight="bold" fontSize="0.9em">
              Stages:
            </Box>
            <Flex wrap>
              {template.stages?.map((stage, index) => (
                <Flex.Item key={index} mr={1} mb={1}>
                  <Box
                    p={0.5}
                    backgroundColor="rgba(0, 255, 0, 0.1)"
                    borderRadius="4px"
                    fontSize="0.8em"
                  >
                    {stage}
                  </Box>
                </Flex.Item>
              ))}
            </Flex>
          </Box>

          <Box mt={1}>
            <Box fontWeight="bold" fontSize="0.9em">
              Requirements:
            </Box>
            <Flex wrap>
              {template.requirements?.map((requirement, index) => (
                <Flex.Item key={index} mr={1} mb={1}>
                  <Box
                    p={0.5}
                    backgroundColor="rgba(255, 215, 0, 0.1)"
                    borderRadius="4px"
                    fontSize="0.8em"
                  >
                    {requirement}
                  </Box>
                </Flex.Item>
              ))}
            </Flex>
          </Box>
        </Box>
      ))}
    </Section>
  );
};
