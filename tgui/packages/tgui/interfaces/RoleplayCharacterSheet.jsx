import React, { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';

export const RoleplayCharacterSheet = (props) => {
  const { act, data } = useBackend();
  const [activeTab, setActiveTab] = useState('basic');
  const [editing, setEditing] = useState(false);

  const {
    character,
    personality_traits,
    character_goals,
    achievements,
    relationships,
    editable,
  } = data;

  if (!character) {
    return (
      <Window width={1000} height={800}>
        <Window.Content>
          <Section title="Character Sheet">
            <Box textAlign="center" fontSize="1.2em">
              No character data available.
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={1000} height={800}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item>
            <Section title={`Character Sheet: ${character.character_name}`}>
              <Flex>
                <Flex.Item width="70%">
                  <LabeledList>
                    <LabeledList.Item label="Character Type">
                      {character.character_type}
                    </LabeledList.Item>
                    <LabeledList.Item label="Character Level">
                      {character.growth?.character_level || 1}
                    </LabeledList.Item>
                    <LabeledList.Item label="Experience Points">
                      {character.growth?.roleplay_experience_points || 0}
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
                <Flex.Item width="30%">
                  <Button
                    fluid
                    icon={editing ? 'save' : 'edit'}
                    onClick={() => {
                      if (editing) {
                        act('save_character');
                        setEditing(false);
                      } else {
                        setEditing(true);
                      }
                    }}
                    disabled={!editable}
                  >
                    {editing ? 'Save Changes' : 'Edit Character'}
                  </Button>
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>

          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === 'basic'}
                onClick={() => setActiveTab('basic')}
              >
                Basic Info
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'personality'}
                onClick={() => setActiveTab('personality')}
              >
                Personality
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'relationships'}
                onClick={() => setActiveTab('relationships')}
              >
                Relationships
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'development'}
                onClick={() => setActiveTab('development')}
              >
                Development
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'appearance'}
                onClick={() => setActiveTab('appearance')}
              >
                Appearance
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'preferences'}
                onClick={() => setActiveTab('preferences')}
              >
                Preferences Integration
              </Tabs.Tab>
            </Tabs>

            <Box height="calc(100% - 50px)" overflowY="auto">
              {activeTab === 'basic' && (
                <BasicInfoTab character={character} editing={editing} />
              )}
              {activeTab === 'personality' && (
                <PersonalityTab
                  character={character}
                  personality_traits={personality_traits}
                  editing={editing}
                />
              )}
              {activeTab === 'relationships' && (
                <RelationshipsTab relationships={relationships} />
              )}
              {activeTab === 'development' && (
                <DevelopmentTab
                  character={character}
                  achievements={achievements}
                />
              )}
              {activeTab === 'appearance' && (
                <AppearanceTab character={character} editing={editing} />
              )}
              {activeTab === 'preferences' && (
                <PreferencesTab character={character} />
              )}
            </Box>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const BasicInfoTab = ({ character, editing }) => {
  const { act } = useBackend();

  return (
    <Section title="Basic Information">
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Character Name">
              {editing ? (
                <Input
                  value={character.character_name}
                  onChange={(e, value) =>
                    act('update_character', { field: 'character_name', value })
                  }
                />
              ) : (
                character.character_name
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Character Type">
              {character.character_type}
            </LabeledList.Item>
            <LabeledList.Item label="Creation Date">
              {new Date(
                character.character_creation_date * 1000,
              ).toLocaleDateString()}
            </LabeledList.Item>
            <LabeledList.Item label="Last Updated">
              {new Date(
                character.character_last_updated * 1000,
              ).toLocaleDateString()}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>

        <Stack.Item>
          <Section title="Character Background">
            {editing ? (
              <TextArea
                value={character.character_background}
                onChange={(e, value) =>
                  act('update_character', {
                    field: 'character_background',
                    value,
                  })
                }
                height="200px"
                placeholder="Write your character's background story..."
              />
            ) : (
              <Box>
                {character.character_background || 'No background written yet.'}
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Character Goals">
            <LabeledList>
              {character.character_goals?.map((goal, index) => (
                <LabeledList.Item key={index} label={`Goal ${index + 1}`}>
                  {goal}
                </LabeledList.Item>
              )) || (
                <LabeledList.Item label="Goals">
                  No goals set yet.
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PersonalityTab = ({ character, personality_traits, editing }) => {
  const { act } = useBackend();

  return (
    <Section title="Personality">
      <Stack vertical>
        <Stack.Item>
          <Section title="Personality Traits">
            <Flex wrap>
              {Object.entries(personality_traits || {}).map(
                ([trait, description]) => (
                  <Flex.Item key={trait} width="50%" mb={1}>
                    <Box
                      backgroundColor={
                        character.personality?.traits?.[trait]
                          ? 'rgba(0, 255, 0, 0.1)'
                          : 'rgba(255, 255, 255, 0.05)'
                      }
                      p={1}
                      borderRadius="4px"
                      border="1px solid rgba(255, 255, 255, 0.1)"
                    >
                      <Box fontWeight="bold">{trait}</Box>
                      <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                        {description}
                      </Box>
                      {editing && (
                        <Button
                          size="small"
                          onClick={() => act('toggle_trait', { trait })}
                          selected={character.personality?.traits?.[trait]}
                        >
                          {character.personality?.traits?.[trait]
                            ? 'Remove'
                            : 'Add'}
                        </Button>
                      )}
                    </Box>
                  </Flex.Item>
                ),
              )}
            </Flex>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Character Quirks">
            {editing ? (
              <TextArea
                value={character.personality?.quirks?.join('\n') || ''}
                onChange={(e, value) =>
                  act('update_quirks', {
                    quirks: value.split('\n').filter((q) => q.trim()),
                  })
                }
                height="100px"
                placeholder="Enter character quirks, one per line..."
              />
            ) : (
              <Box>
                {character.personality?.quirks?.length > 0
                  ? character.personality.quirks.map((quirk, index) => (
                      <Box key={index}>• {quirk}</Box>
                    ))
                  : 'No quirks defined yet.'}
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Fears and Aspirations">
            <Flex>
              <Flex.Item width="50%">
                <Box fontWeight="bold" mb={1}>
                  Fears:
                </Box>
                {character.personality?.fears?.length > 0 ? (
                  character.personality.fears.map((fear, index) => (
                    <Box key={index}>• {fear}</Box>
                  ))
                ) : (
                  <Box color="rgba(255, 255, 255, 0.5)">No fears defined.</Box>
                )}
              </Flex.Item>
              <Flex.Item width="50%">
                <Box fontWeight="bold" mb={1}>
                  Aspirations:
                </Box>
                {character.personality?.aspirations?.length > 0 ? (
                  character.personality.aspirations.map((aspiration, index) => (
                    <Box key={index}>• {aspiration}</Box>
                  ))
                ) : (
                  <Box color="rgba(255, 255, 255, 0.5)">
                    No aspirations defined.
                  </Box>
                )}
              </Flex.Item>
            </Flex>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RelationshipsTab = ({ relationships }) => {
  return (
    <Section title="Character Relationships">
      {relationships?.length > 0 ? (
        relationships.map((relationship, index) => (
          <Box
            key={index}
            mb={2}
            p={1}
            backgroundColor="rgba(255, 255, 255, 0.05)"
          >
            <Flex justify="space-between" align="center">
              <Flex.Item>
                <Box fontWeight="bold">{relationship.other_character}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  {relationship.type} • Strength: {relationship.strength}/100
                </Box>
              </Flex.Item>
              <Flex.Item>
                <ProgressBar
                  value={relationship.strength}
                  maxValue={100}
                  color={
                    relationship.strength > 70
                      ? 'good'
                      : relationship.strength > 30
                        ? 'average'
                        : 'bad'
                  }
                />
              </Flex.Item>
            </Flex>
          </Box>
        ))
      ) : (
        <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
          No relationships formed yet.
        </Box>
      )}
    </Section>
  );
};

const DevelopmentTab = ({ character, achievements }) => {
  return (
    <Section title="Character Development">
      <Stack vertical>
        <Stack.Item>
          <Section title="Growth Progress">
            <LabeledList>
              <LabeledList.Item label="Character Level">
                {character.growth?.character_level || 1}
              </LabeledList.Item>
              <LabeledList.Item label="Experience Points">
                {character.growth?.roleplay_experience_points || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Next Level">
                {(character.growth?.character_level || 1) * 100 -
                  (character.growth?.roleplay_experience_points || 0)}{' '}
                XP needed
              </LabeledList.Item>
            </LabeledList>
            <ProgressBar
              value={character.growth?.roleplay_experience_points || 0}
              maxValue={(character.growth?.character_level || 1) * 100}
              color="blue"
              mt={1}
            />
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Recent Milestones">
            {character.growth?.growth_milestones?.length > 0 ? (
              character.growth.growth_milestones
                .slice(-5)
                .reverse()
                .map((milestone, index) => (
                  <Box
                    key={index}
                    mb={1}
                    p={1}
                    backgroundColor="rgba(0, 255, 0, 0.1)"
                  >
                    <Box fontWeight="bold">{milestone.description}</Box>
                    <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                      {new Date(
                        milestone.timestamp * 1000,
                      ).toLocaleDateString()}
                    </Box>
                  </Box>
                ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No milestones achieved yet.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Achievements">
            {achievements?.length > 0 ? (
              achievements.map((achievement, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 215, 0, 0.1)"
                >
                  <Box fontWeight="bold">{achievement.name}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    {achievement.description}
                  </Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No achievements earned yet.
              </Box>
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AppearanceTab = ({ character, editing }) => {
  const { act } = useBackend();

  return (
    <Section title="Character Appearance">
      <Stack vertical>
        <Stack.Item>
          <Section title="Physical Details">
            <LabeledList>
              <LabeledList.Item label="Face Details">
                {editing ? (
                  <TextArea
                    value={character.appearance?.face_details?.join('\n') || ''}
                    onChange={(e, value) =>
                      act('update_face_details', {
                        details: value.split('\n').filter((d) => d.trim()),
                      })
                    }
                    height="80px"
                    placeholder="Describe facial features..."
                  />
                ) : (
                  <Box>
                    {character.appearance?.face_details?.length > 0
                      ? character.appearance.face_details.map(
                          (detail, index) => <Box key={index}>• {detail}</Box>,
                        )
                      : 'No face details described.'}
                  </Box>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Body Details">
                {editing ? (
                  <TextArea
                    value={character.appearance?.body_details?.join('\n') || ''}
                    onChange={(e, value) =>
                      act('update_body_details', {
                        details: value.split('\n').filter((d) => d.trim()),
                      })
                    }
                    height="80px"
                    placeholder="Describe body features..."
                  />
                ) : (
                  <Box>
                    {character.appearance?.body_details?.length > 0
                      ? character.appearance.body_details.map(
                          (detail, index) => <Box key={index}>• {detail}</Box>,
                        )
                      : 'No body details described.'}
                  </Box>
                )}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Clothing Preferences">
            {editing ? (
              <TextArea
                value={
                  character.appearance?.clothing_preferences?.join('\n') || ''
                }
                onChange={(e, value) =>
                  act('update_clothing_preferences', {
                    preferences: value.split('\n').filter((p) => p.trim()),
                  })
                }
                height="80px"
                placeholder="Describe clothing preferences..."
              />
            ) : (
              <Box>
                {character.appearance?.clothing_preferences?.length > 0
                  ? character.appearance.clothing_preferences.map(
                      (preference, index) => (
                        <Box key={index}>• {preference}</Box>
                      ),
                    )
                  : 'No clothing preferences defined.'}
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Unique Features">
            {editing ? (
              <TextArea
                value={character.appearance?.unique_features?.join('\n') || ''}
                onChange={(e, value) =>
                  act('update_unique_features', {
                    features: value.split('\n').filter((f) => f.trim()),
                  })
                }
                height="80px"
                placeholder="Describe unique features..."
              />
            ) : (
              <Box>
                {character.appearance?.unique_features?.length > 0
                  ? character.appearance.unique_features.map(
                      (feature, index) => <Box key={index}>• {feature}</Box>,
                    )
                  : 'No unique features defined.'}
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Character Style">
            {editing ? (
              <TextArea
                value={character.appearance?.character_style || ''}
                onChange={(e, value) =>
                  act('update_character_style', { style: value })
                }
                height="60px"
                placeholder="Describe overall character style..."
              />
            ) : (
              <Box>
                {character.appearance?.character_style ||
                  'No style description.'}
              </Box>
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PreferencesTab = ({ character }) => {
  const { act, data } = useBackend();
  const { preferences_summary, character_sheet_status } = data;

  return (
    <Section title="Character Setup Preferences Integration">
      <Stack vertical>
        <Stack.Item>
          <Section title="Preferences Status">
            <LabeledList>
              <LabeledList.Item label="Preferences Loaded">
                {preferences_summary?.preferences_loaded ? 'Yes' : 'No'}
              </LabeledList.Item>
              <LabeledList.Item label="Character Sheet Status">
                {character_sheet_status?.has_character ? 'Active' : 'Inactive'}
              </LabeledList.Item>
              <LabeledList.Item label="Last Synced">
                {character_sheet_status?.last_updated
                  ? new Date(
                      character_sheet_status.last_updated * 1000,
                    ).toLocaleString()
                  : 'Never'}
              </LabeledList.Item>
              <LabeledList.Item label="Successful Reads">
                {preferences_summary?.successful_reads || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Total Cache Entries">
                {preferences_summary?.total_cache_entries || 0}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Current Preferences Data">
            {preferences_summary?.preferences_loaded ? (
              <LabeledList>
                <LabeledList.Item label="Character Name">
                  {preferences_summary.character_name}
                </LabeledList.Item>
                <LabeledList.Item label="Age">
                  {preferences_summary.age}
                </LabeledList.Item>
                <LabeledList.Item label="Gender">
                  {preferences_summary.gender}
                </LabeledList.Item>
                <LabeledList.Item label="Species">
                  {preferences_summary.species}
                </LabeledList.Item>
                <LabeledList.Item label="Hair Style">
                  {preferences_summary.hair_style}
                </LabeledList.Item>
                <LabeledList.Item label="Hair Color">
                  {preferences_summary.hair_color}
                </LabeledList.Item>
                <LabeledList.Item label="Eye Color">
                  {preferences_summary.eye_color}
                </LabeledList.Item>
                <LabeledList.Item label="Clothing Style">
                  {preferences_summary.clothing_style}
                </LabeledList.Item>
                <LabeledList.Item label="Flavor Text">
                  {preferences_summary.flavor_text}
                </LabeledList.Item>
              </LabeledList>
            ) : (
              <Box color="red">No preferences data available.</Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Sync Actions">
            <Flex>
              <Flex.Item width="50%">
                <Button
                  fluid
                  icon="download"
                  onClick={() => act('sync_from_preferences')}
                  tooltip="Update character sheet with current preferences data"
                >
                  Sync From Preferences
                </Button>
              </Flex.Item>
              <Flex.Item width="50%">
                <Button
                  fluid
                  icon="upload"
                  onClick={() => act('sync_to_preferences')}
                  tooltip="Update preferences with character sheet changes"
                >
                  Sync To Preferences
                </Button>
              </Flex.Item>
            </Flex>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Integration Information">
            <Box>
              <strong>How Integration Works:</strong>
              <br />
              • The character sheet automatically syncs with your character
              setup preferences
              <br />
              • Changes made in the character sheet can be synced back to
              preferences
              <br />
              • Character name and background automatically sync to preferences
              <br />
              • Appearance details are pulled from your character setup
              <br />• Use the sync buttons to manually update data in either
              direction
            </Box>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
