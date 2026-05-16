import React, { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';

export const StorytellingSystem = (props) => {
  const { act, data } = useBackend();
  const [activeTab, setActiveTab] = useState('stories');
  const [selectedStory, setSelectedStory] = useState(null);
  const [editing, setEditing] = useState(false);

  const {
    stories,
    story_templates,
    collaborative_sessions,
    user_stories,
    user_contributions,
    metrics,
  } = data;

  return (
    <Window width={1200} height={800}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item>
            <Section title="Storytelling & Documentation System">
              <Flex>
                <Flex.Item width="70%">
                  <LabeledList>
                    <LabeledList.Item label="Total Stories">
                      {metrics?.total_stories || 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Active Collaborations">
                      {metrics?.active_collaborations || 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Your Stories">
                      {user_stories?.length || 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Your Contributions">
                      {user_contributions?.length || 0}
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
                <Flex.Item width="30%">
                  <Button fluid icon="plus" onClick={() => act('create_story')}>
                    Create New Story
                  </Button>
                  <Button
                    fluid
                    icon="users"
                    onClick={() => act('create_session')}
                    mt={1}
                  >
                    Start Collaboration
                  </Button>
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>

          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === 'stories'}
                onClick={() => setActiveTab('stories')}
              >
                Stories
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'templates'}
                onClick={() => setActiveTab('templates')}
              >
                Templates
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'collaborations'}
                onClick={() => setActiveTab('collaborations')}
              >
                Collaborations
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'my_work'}
                onClick={() => setActiveTab('my_work')}
              >
                My Work
              </Tabs.Tab>
            </Tabs>

            <Box height="calc(100% - 50px)" overflowY="auto">
              {activeTab === 'stories' && (
                <StoriesTab
                  stories={stories}
                  selectedStory={selectedStory}
                  setSelectedStory={setSelectedStory}
                  editing={editing}
                  setEditing={setEditing}
                />
              )}
              {activeTab === 'templates' && (
                <TemplatesTab templates={story_templates} />
              )}
              {activeTab === 'collaborations' && (
                <CollaborationsTab sessions={collaborative_sessions} />
              )}
              {activeTab === 'my_work' && (
                <MyWorkTab
                  user_stories={user_stories}
                  user_contributions={user_contributions}
                />
              )}
            </Box>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const StoriesTab = ({
  stories,
  selectedStory,
  setSelectedStory,
  editing,
  setEditing,
}) => {
  const { act } = useBackend();

  return (
    <Flex>
      <Flex.Item width="40%">
        <Section title="Available Stories">
          {stories?.length > 0 ? (
            stories.map((story, index) => (
              <Box
                key={story.story_id}
                p={1}
                mb={1}
                backgroundColor={
                  selectedStory?.story_id === story.story_id
                    ? 'rgba(0, 255, 0, 0.1)'
                    : 'rgba(255, 255, 255, 0.05)'
                }
                onClick={() => setSelectedStory(story)}
                style={{ cursor: 'pointer' }}
              >
                <Box fontWeight="bold">{story.story_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  {story.story_type} • {story.story_status}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {story.story_contributors?.length || 0} contributors
                </Box>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              No stories available.
            </Box>
          )}
        </Section>
      </Flex.Item>

      <Flex.Item width="60%">
        {selectedStory ? (
          <StoryDetailView
            story={selectedStory}
            editing={editing}
            setEditing={setEditing}
          />
        ) : (
          <Section title="Story Details">
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              Select a story to view details.
            </Box>
          </Section>
        )}
      </Flex.Item>
    </Flex>
  );
};

const StoryDetailView = ({ story, editing, setEditing }) => {
  const { act } = useBackend();

  return (
    <Section title={story.story_title}>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Type">{story.story_type}</LabeledList.Item>
            <LabeledList.Item label="Status">
              <Box
                color={
                  story.story_status === 'completed'
                    ? 'green'
                    : story.story_status === 'active'
                      ? 'blue'
                      : 'orange'
                }
              >
                {story.story_status}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Priority">
              {story.story_priority}/5
            </LabeledList.Item>
            <LabeledList.Item label="Created">
              {new Date(story.story_creation_date * 1000).toLocaleDateString()}
            </LabeledList.Item>
            <LabeledList.Item label="Last Updated">
              {new Date(story.story_last_updated * 1000).toLocaleDateString()}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>

        <Stack.Item>
          <Section title="Description">
            {editing ? (
              <TextArea
                value={story.story_description}
                onChange={(e, value) =>
                  act('update_story', {
                    story_id: story.story_id,
                    field: 'story_description',
                    value,
                  })
                }
                height="150px"
                placeholder="Describe the story..."
              />
            ) : (
              <Box>
                {story.story_description || 'No description available.'}
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Chapters">
            {story.story_chapters?.length > 0 ? (
              story.story_chapters.map((chapter, index) => (
                <Box
                  key={chapter.chapter_id}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 255, 255, 0.05)"
                >
                  <Box fontWeight="bold">{chapter.chapter_title}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    by {chapter.chapter_author}
                  </Box>
                  <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                    {new Date(
                      chapter.chapter_creation_date * 1000,
                    ).toLocaleDateString()}
                  </Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No chapters yet.
              </Box>
            )}
            <Button
              fluid
              icon="plus"
              onClick={() => act('add_chapter', { story_id: story.story_id })}
              mt={1}
            >
              Add Chapter
            </Button>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Contributors">
            {story.story_contributors?.length > 0 ? (
              Object.entries(story.story_contributors).map(([ckey, data]) => (
                <Box
                  key={ckey}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 255, 255, 0.05)"
                >
                  <Box fontWeight="bold">{ckey}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    {data.role}
                  </Box>
                  <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                    Joined:{' '}
                    {new Date(
                      data.contribution_date * 1000,
                    ).toLocaleDateString()}
                  </Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No contributors yet.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Flex>
            <Flex.Item width="50%">
              <Button
                fluid
                icon={editing ? 'save' : 'edit'}
                onClick={() => {
                  if (editing) {
                    act('save_story', { story_id: story.story_id });
                    setEditing(false);
                  } else {
                    setEditing(true);
                  }
                }}
              >
                {editing ? 'Save Changes' : 'Edit Story'}
              </Button>
            </Flex.Item>
            <Flex.Item width="50%">
              <Button
                fluid
                icon="users"
                onClick={() =>
                  act('invite_contributor', { story_id: story.story_id })
                }
              >
                Invite Contributor
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const TemplatesTab = ({ templates }) => {
  const { act } = useBackend();

  return (
    <Section title="Story Templates">
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
                Category: {template.category} • Difficulty:{' '}
                {template.difficulty}/5
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="plus"
                onClick={() => act('use_template', { template_id })}
              >
                Use Template
              </Button>
            </Flex.Item>
          </Flex>

          <Box mt={1}>
            <Box fontWeight="bold" fontSize="0.9em">
              Structure:
            </Box>
            <Flex wrap>
              {template.structure?.map((step, index) => (
                <Flex.Item key={index} mr={1} mb={1}>
                  <Box
                    p={0.5}
                    backgroundColor="rgba(0, 255, 0, 0.1)"
                    borderRadius="4px"
                    fontSize="0.8em"
                  >
                    {step}
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

const CollaborationsTab = ({ sessions }) => {
  const { act } = useBackend();

  return (
    <Section title="Collaborative Sessions">
      {sessions?.length > 0 ? (
        sessions.map((session, index) => (
          <Box
            key={session.session_id}
            mb={2}
            p={2}
            backgroundColor="rgba(255, 255, 255, 0.05)"
          >
            <Flex justify="space-between" align="center">
              <Flex.Item>
                <Box fontWeight="bold">{session.session_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  {session.session_type} • {session.session_status}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {session.session_participants?.length || 0} participants
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  icon="sign-in-alt"
                  onClick={() =>
                    act('join_session', { session_id: session.session_id })
                  }
                  disabled={session.session_status !== 'active'}
                >
                  Join Session
                </Button>
              </Flex.Item>
            </Flex>

            {session.session_notes?.length > 0 && (
              <Box mt={1}>
                <Box fontWeight="bold" fontSize="0.9em">
                  Recent Notes:
                </Box>
                {session.session_notes.slice(-3).map((note, noteIndex) => (
                  <Box
                    key={noteIndex}
                    fontSize="0.8em"
                    color="rgba(255, 255, 255, 0.7)"
                  >
                    • {note}
                  </Box>
                ))}
              </Box>
            )}
          </Box>
        ))
      ) : (
        <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
          No active collaborative sessions.
        </Box>
      )}
    </Section>
  );
};

const MyWorkTab = ({ user_stories, user_contributions }) => {
  const { act } = useBackend();

  return (
    <Flex>
      <Flex.Item width="50%">
        <Section title="My Stories">
          {user_stories?.length > 0 ? (
            user_stories.map((story, index) => (
              <Box
                key={story.story_id}
                mb={1}
                p={1}
                backgroundColor="rgba(0, 255, 0, 0.1)"
              >
                <Box fontWeight="bold">{story.story_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  {story.story_type} • {story.story_status}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {story.story_chapters?.length || 0} chapters
                </Box>
                <Button
                  size="small"
                  onClick={() =>
                    act('open_story', { story_id: story.story_id })
                  }
                  mt={0.5}
                >
                  Open Story
                </Button>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              You haven't created any stories yet.
            </Box>
          )}
        </Section>
      </Flex.Item>

      <Flex.Item width="50%">
        <Section title="My Contributions">
          {user_contributions?.length > 0 ? (
            user_contributions.map((contribution, index) => (
              <Box
                key={contribution.story_id}
                mb={1}
                p={1}
                backgroundColor="rgba(255, 215, 0, 0.1)"
              >
                <Box fontWeight="bold">{contribution.story_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  Role: {contribution.role}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {contribution.chapters_contributed || 0} chapters contributed
                </Box>
                <Button
                  size="small"
                  onClick={() =>
                    act('open_story', { story_id: contribution.story_id })
                  }
                  mt={0.5}
                >
                  View Story
                </Button>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              You haven't contributed to any stories yet.
            </Box>
          )}
        </Section>
      </Flex.Item>
    </Flex>
  );
};
