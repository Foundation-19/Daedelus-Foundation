import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  Modal,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';

export const EventStoryManagement = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = useLocalState(
    context,
    'activeTab',
    'events',
  );
  const [selectedEvent, setSelectedEvent] = useLocalState(
    context,
    'selectedEvent',
    null,
  );
  const [selectedArc, setSelectedArc] = useLocalState(
    context,
    'selectedArc',
    null,
  );
  const [showCreateModal, setShowCreateModal] = useLocalState(
    context,
    'showCreateModal',
    false,
  );
  const [createType, setCreateType] = useLocalState(
    context,
    'createType',
    'event',
  );

  const {
    active_events = [],
    event_templates = {},
    story_arcs = [],
    player_initiated_events = [],
    emergent_stories = [],
    event_triggers = {},
    metrics = {},
  } = data;

  return (
    <Window
      title="Event & Story Management System"
      width={1200}
      height={800}
      theme="admin"
    >
      <Window.Content>
        <Stack fill>
          <Stack.Item width="25%">
            <Section title="Navigation">
              <Tabs vertical>
                <Tabs.Tab
                  selected={activeTab === 'events'}
                  onClick={() => setActiveTab('events')}
                >
                  Active Events ({active_events.length})
                </Tabs.Tab>
                <Tabs.Tab
                  selected={activeTab === 'arcs'}
                  onClick={() => setActiveTab('arcs')}
                >
                  Story Arcs ({story_arcs.length})
                </Tabs.Tab>
                <Tabs.Tab
                  selected={activeTab === 'player_events'}
                  onClick={() => setActiveTab('player_events')}
                >
                  Player Events ({player_initiated_events.length})
                </Tabs.Tab>
                <Tabs.Tab
                  selected={activeTab === 'emergent'}
                  onClick={() => setActiveTab('emergent')}
                >
                  Emergent Stories ({emergent_stories.length})
                </Tabs.Tab>
                <Tabs.Tab
                  selected={activeTab === 'templates'}
                  onClick={() => setActiveTab('templates')}
                >
                  Event Templates
                </Tabs.Tab>
                <Tabs.Tab
                  selected={activeTab === 'metrics'}
                  onClick={() => setActiveTab('metrics')}
                >
                  Metrics & Analytics
                </Tabs.Tab>
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item width="75%">
            {activeTab === 'events' && (
              <EventsTab
                events={active_events}
                onSelectEvent={setSelectedEvent}
                selectedEvent={selectedEvent}
                onCreateEvent={() => {
                  setCreateType('event');
                  setShowCreateModal(true);
                }}
              />
            )}
            {activeTab === 'arcs' && (
              <ArcsTab
                arcs={story_arcs}
                onSelectArc={setSelectedArc}
                selectedArc={selectedArc}
                onCreateArc={() => {
                  setCreateType('arc');
                  setShowCreateModal(true);
                }}
              />
            )}
            {activeTab === 'player_events' && (
              <PlayerEventsTab
                events={player_initiated_events}
                onApproveEvent={(eventId) =>
                  act('approve_event', { event_id: eventId })
                }
              />
            )}
            {activeTab === 'emergent' && (
              <EmergentStoriesTab stories={emergent_stories} />
            )}
            {activeTab === 'templates' && (
              <TemplatesTab
                templates={event_templates}
                onUseTemplate={(templateId) =>
                  act('use_event_template', { template_id: templateId })
                }
              />
            )}
            {activeTab === 'metrics' && <MetricsTab metrics={metrics} />}
          </Stack.Item>
        </Stack>
        {showCreateModal && (
          <CreateModal
            type={createType}
            onClose={() => setShowCreateModal(false)}
            onCreate={(data) => {
              if (createType === 'event') {
                act('create_event', data);
              } else {
                act('create_story_arc', data);
              }
              setShowCreateModal(false);
            }}
          />
        )}
      </Window.Content>
    </Window>
  );
};

const EventsTab = (props, context) => {
  const { events, onSelectEvent, selectedEvent, onCreateEvent } = props;
  const { act } = useBackend(context);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Active Events">
          <Button
            content="Create New Event"
            icon="plus"
            onClick={onCreateEvent}
            color="green"
            mb={1}
          />
          <Table>
            <Table.Row header>
              <Table.Cell>Title</Table.Cell>
              <Table.Cell>Type</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              <Table.Cell>Severity</Table.Cell>
              <Table.Cell>Stage</Table.Cell>
              <Table.Cell>Actions</Table.Cell>
            </Table.Row>
            {events.map((event) => (
              <Table.Row key={event.event_id}>
                <Table.Cell>
                  <Button
                    content={event.event_title}
                    onClick={() => onSelectEvent(event)}
                    color={
                      selectedEvent?.event_id === event.event_id
                        ? 'blue'
                        : 'transparent'
                    }
                  />
                </Table.Cell>
                <Table.Cell>{event.event_type}</Table.Cell>
                <Table.Cell>
                  <Box color={getStatusColor(event.event_status)}>
                    {event.event_status}
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  <Box color={getSeverityColor(event.event_severity)}>
                    {event.event_severity}
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  {event.current_stage}/{event.event_stages}
                </Table.Cell>
                <Table.Cell>
                  <Button
                    content="Join"
                    icon="user-plus"
                    onClick={() =>
                      act('join_event', { event_id: event.event_id })
                    }
                    color="green"
                    compact
                  />
                  <Button
                    content="Advance"
                    icon="arrow-right"
                    onClick={() =>
                      act('advance_event', { event_id: event.event_id })
                    }
                    color="blue"
                    compact
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      {selectedEvent && (
        <Stack.Item>
          <EventDetails event={selectedEvent} />
        </Stack.Item>
      )}
    </Stack>
  );
};

const ArcsTab = (props, context) => {
  const { arcs, onSelectArc, selectedArc, onCreateArc } = props;
  const { act } = useBackend(context);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Story Arcs">
          <Button
            content="Create New Story Arc"
            icon="plus"
            onClick={onCreateArc}
            color="green"
            mb={1}
          />
          <Table>
            <Table.Row header>
              <Table.Cell>Title</Table.Cell>
              <Table.Cell>Type</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              <Table.Cell>Complexity</Table.Cell>
              <Table.Cell>Events</Table.Cell>
              <Table.Cell>Actions</Table.Cell>
            </Table.Row>
            {arcs.map((arc) => (
              <Table.Row key={arc.arc_id}>
                <Table.Cell>
                  <Button
                    content={arc.arc_title}
                    onClick={() => onSelectArc(arc)}
                    color={
                      selectedArc?.arc_id === arc.arc_id
                        ? 'blue'
                        : 'transparent'
                    }
                  />
                </Table.Cell>
                <Table.Cell>{arc.arc_type}</Table.Cell>
                <Table.Cell>
                  <Box color={getStatusColor(arc.arc_status)}>
                    {arc.arc_status}
                  </Box>
                </Table.Cell>
                <Table.Cell>{arc.arc_complexity}</Table.Cell>
                <Table.Cell>{arc.arc_events?.length || 0}</Table.Cell>
                <Table.Cell>
                  <Button
                    content="Add Event"
                    icon="plus"
                    onClick={() =>
                      act('add_event_to_arc', { arc_id: arc.arc_id })
                    }
                    color="green"
                    compact
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      {selectedArc && (
        <Stack.Item>
          <ArcDetails arc={selectedArc} />
        </Stack.Item>
      )}
    </Stack>
  );
};

const PlayerEventsTab = (props, context) => {
  const { events, onApproveEvent } = props;

  return (
    <Section title="Player Initiated Events">
      <Table>
        <Table.Row header>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Initiator</Table.Cell>
          <Table.Cell>Type</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Votes</Table.Cell>
          <Table.Cell>Actions</Table.Cell>
        </Table.Row>
        {events.map((event) => (
          <Table.Row key={event.event_id}>
            <Table.Cell>{event.event_title}</Table.Cell>
            <Table.Cell>{event.event_initiator}</Table.Cell>
            <Table.Cell>{event.event_type}</Table.Cell>
            <Table.Cell>
              <Box color={getStatusColor(event.event_status)}>
                {event.event_status}
              </Box>
            </Table.Cell>
            <Table.Cell>{event.event_approval_votes}</Table.Cell>
            <Table.Cell>
              {event.event_status === 'pending' && (
                <Button
                  content="Approve"
                  icon="check"
                  onClick={() => onApproveEvent(event.event_id)}
                  color="green"
                  compact
                />
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const EmergentStoriesTab = (props, context) => {
  const { stories } = props;

  return (
    <Section title="Emergent Stories">
      <Table>
        <Table.Row header>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Type</Table.Cell>
          <Table.Cell>Creation Date</Table.Cell>
        </Table.Row>
        {stories.map((story) => (
          <Table.Row key={story.story_id}>
            <Table.Cell>{story.story_title}</Table.Cell>
            <Table.Cell>{story.story_type}</Table.Cell>
            <Table.Cell>{formatDate(story.story_creation_date)}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const TemplatesTab = (props, context) => {
  const { templates, onUseTemplate } = props;

  return (
    <Section title="Event Templates">
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Type</Table.Cell>
          <Table.Cell>Severity</Table.Cell>
          <Table.Cell>Description</Table.Cell>
          <Table.Cell>Actions</Table.Cell>
        </Table.Row>
        {Object.entries(templates).map(([id, template]) => (
          <Table.Row key={id}>
            <Table.Cell>{template.name}</Table.Cell>
            <Table.Cell>{template.type}</Table.Cell>
            <Table.Cell>
              <Box color={getSeverityColor(template.severity)}>
                {template.severity}
              </Box>
            </Table.Cell>
            <Table.Cell>{template.description}</Table.Cell>
            <Table.Cell>
              <Button
                content="Use Template"
                icon="copy"
                onClick={() => onUseTemplate(id)}
                color="blue"
                compact
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const MetricsTab = (props, context) => {
  const { metrics } = props;

  return (
    <Section title="Metrics & Analytics">
      <LabeledList>
        <LabeledList.Item label="Total Events Created">
          {metrics.total_events_created || 0}
        </LabeledList.Item>
        <LabeledList.Item label="Active Story Arcs">
          {metrics.active_story_arcs || 0}
        </LabeledList.Item>
        <LabeledList.Item label="Player Participation Rate">
          <ProgressBar
            value={metrics.player_participation_rate || 0}
            maxValue={100}
            color="green"
          />
          {metrics.player_participation_rate || 0}%
        </LabeledList.Item>
        <LabeledList.Item label="Event Completion Rate">
          <ProgressBar
            value={metrics.event_completion_rate || 0}
            maxValue={100}
            color="blue"
          />
          {metrics.event_completion_rate || 0}%
        </LabeledList.Item>
        <LabeledList.Item label="Story Coherence Score">
          <ProgressBar
            value={metrics.story_coherence_score || 0}
            maxValue={100}
            color="purple"
          />
          {metrics.story_coherence_score || 0}%
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const EventDetails = (props, context) => {
  const { event } = props;

  return (
    <Section title={`Event Details: ${event.event_title}`}>
      <LabeledList>
        <LabeledList.Item label="Event ID">{event.event_id}</LabeledList.Item>
        <LabeledList.Item label="Type">{event.event_type}</LabeledList.Item>
        <LabeledList.Item label="Status">
          <Box color={getStatusColor(event.event_status)}>
            {event.event_status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Severity">
          <Box color={getSeverityColor(event.event_severity)}>
            {event.event_severity}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Priority">
          {event.event_priority}
        </LabeledList.Item>
        <LabeledList.Item label="Stage">
          {event.current_stage}/{event.event_stages}
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {event.event_description}
        </LabeledList.Item>
        <LabeledList.Item label="Participants">
          {event.event_participants?.join(', ') || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Start Time">
          {formatDate(event.event_start_time)}
        </LabeledList.Item>
        <LabeledList.Item label="Estimated Duration">
          {event.event_estimated_duration}
        </LabeledList.Item>
        <LabeledList.Item label="Actual Duration">
          {event.event_actual_duration}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ArcDetails = (props, context) => {
  const { arc } = props;

  return (
    <Section title={`Story Arc Details: ${arc.arc_title}`}>
      <LabeledList>
        <LabeledList.Item label="Arc ID">{arc.arc_id}</LabeledList.Item>
        <LabeledList.Item label="Type">{arc.arc_type}</LabeledList.Item>
        <LabeledList.Item label="Status">
          <Box color={getStatusColor(arc.arc_status)}>{arc.arc_status}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Complexity">
          {arc.arc_complexity}
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {arc.arc_description}
        </LabeledList.Item>
        <LabeledList.Item label="Characters">
          {arc.arc_characters?.join(', ') || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Locations">
          {arc.arc_locations?.join(', ') || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Objectives">
          {arc.arc_objectives?.join(', ') || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Themes">
          {arc.arc_themes?.join(', ') || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Creation Date">
          {formatDate(arc.arc_creation_date)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const CreateModal = (props, context) => {
  const { type, onClose, onCreate } = props;
  const [title, setTitle] = useLocalState(context, 'createTitle', '');
  const [eventType, setEventType] = useLocalState(
    context,
    'createEventType',
    'containment_breach',
  );
  const [description, setDescription] = useLocalState(
    context,
    'createDescription',
    '',
  );

  const eventTypes = [
    'containment_breach',
    'research_discovery',
    'personnel_conflict',
    'scp_interaction',
    'facility_incident',
  ];

  const arcTypes = [
    'containment_breach',
    'research_project',
    'personnel_drama',
    'scp_awakening',
    'facility_crisis',
  ];

  return (
    <Modal>
      <Section title={`Create New ${type === 'event' ? 'Event' : 'Story Arc'}`}>
        <LabeledList>
          <LabeledList.Item label="Title">
            <Input
              value={title}
              onChange={(e, value) => setTitle(value)}
              placeholder="Enter title..."
            />
          </LabeledList.Item>
          <LabeledList.Item label="Type">
            <Input
              value={eventType}
              onChange={(e, value) => setEventType(value)}
              placeholder="Select type..."
            />
          </LabeledList.Item>
          <LabeledList.Item label="Description">
            <TextArea
              value={description}
              onChange={(e, value) => setDescription(value)}
              placeholder="Enter description..."
              height="100px"
            />
          </LabeledList.Item>
        </LabeledList>
        <Stack mt={2}>
          <Stack.Item>
            <Button
              content="Create"
              icon="plus"
              onClick={() =>
                onCreate({ title, event_type: eventType, description })
              }
              color="green"
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              content="Cancel"
              icon="times"
              onClick={onClose}
              color="red"
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};

// Helper functions
const getStatusColor = (status) => {
  switch (status) {
    case 'active':
      return 'green';
    case 'pending':
      return 'yellow';
    case 'completed':
      return 'blue';
    case 'cancelled':
      return 'red';
    default:
      return 'white';
  }
};

const getSeverityColor = (severity) => {
  switch (severity) {
    case 'low':
      return 'green';
    case 'medium':
      return 'yellow';
    case 'high':
      return 'orange';
    case 'critical':
      return 'red';
    default:
      return 'white';
  }
};

const formatDate = (timestamp) => {
  if (!timestamp) return 'Unknown';
  const date = new Date(timestamp * 1000);
  return date.toLocaleString();
};
