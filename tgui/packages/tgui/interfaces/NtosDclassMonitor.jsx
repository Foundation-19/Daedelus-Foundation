import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Tabs } from '../components';
import { NtosWindow } from '../layouts';

const STATUS_COLOR = '#d4a017';
const TEXT_COLOR = '#c8c8c8';
const RED_COLOR = '#8b0000';
const GREEN_COLOR = '#0a6e0a';

export const NtosDclassMonitor = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useState('status');

  if (!data.is_dclass) {
    return (
      <NtosWindow width={500} height={600} theme="scp_terminal">
        <NtosWindow.Content scrollable>
          <Section>
            <Box
              color={RED_COLOR}
              bold
              fontSize="18px"
              textAlign="center"
              mt={2}
              mb={2}
            >
              ACCESS DENIED - Unauthorized user
            </Box>
          </Section>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }

  return (
    <NtosWindow width={500} height={600} theme="scp_terminal">
      <NtosWindow.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === 'status'}
            onClick={() => setTab('status')}
          >
            Status
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'contraband'}
            onClick={() => setTab('contraband')}
          >
            Contraband
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'achievements'}
            onClick={() => setTab('achievements')}
          >
            Achievements
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'events'}
            onClick={() => setTab('events')}
          >
            Events
          </Tabs.Tab>
        </Tabs>

        {tab === 'status' && <StatusTab />}
        {tab === 'contraband' && <ContrabandTab />}
        {tab === 'achievements' && <AchievementsTab />}
        {tab === 'events' && <EventsTab />}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const StatusTab = (props) => {
  const { act, data } = useBackend();
  const {
    level,
    experience,
    trust_level,
    credits,
    strikes,
    current_work_assignment,
    security_level,
    current_time,
    skills,
    abilities,
  } = data;

  return (
    <>
      <Section title="Personnel Record">
        <LabeledList>
          <LabeledList.Item label="Level">
            <Box color={STATUS_COLOR}>{level}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Experience">
            <Box color={TEXT_COLOR}>{experience}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Trust Level">
            <Box color={STATUS_COLOR}>{trust_level}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Credits">
            <Box color={STATUS_COLOR}>{credits}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Strikes">
            <Box color={strikes > 0 ? RED_COLOR : GREEN_COLOR}>{strikes}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Work Assignment">
            <Box color={TEXT_COLOR}>{current_work_assignment || 'None'}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Security Level">
            <Box color={STATUS_COLOR}>{security_level}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Current Time">
            <Box color={TEXT_COLOR}>{current_time}</Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Skills">
        {skills && skills.length > 0 ? (
          skills.map((skill) => (
            <Box key={skill.name} color={TEXT_COLOR} mb={1}>
              <Box as="span" color={STATUS_COLOR}>
                {skill.name}:
              </Box>{' '}
              {skill.level}
            </Box>
          ))
        ) : (
          <Box color={TEXT_COLOR}>No skills recorded</Box>
        )}
      </Section>

      <Section title="Abilities">
        {abilities && abilities.length > 0 ? (
          abilities.map((ability) => (
            <Box key={ability.name} color={TEXT_COLOR} mb={1}>
              <Box as="span" color={STATUS_COLOR}>
                {ability.name}
              </Box>
              {ability.description && ` - ${ability.description}`}
            </Box>
          ))
        ) : (
          <Box color={TEXT_COLOR}>No abilities unlocked</Box>
        )}
      </Section>
    </>
  );
};

const ContrabandTab = (props) => {
  const { act, data } = useBackend();
  const { contraband, hidden_items, crafted_items } = data;

  return (
    <>
      <Section title="Contraband Inventory">
        {contraband && contraband.length > 0 ? (
          contraband.map((item) => (
            <Box
              key={item.name}
              mb={1}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <Box color={TEXT_COLOR}>
                <Box as="span" color={RED_COLOR}>
                  {item.name}
                </Box>{' '}
                x{item.count}
              </Box>
              <Box>
                <Button
                  color="bad"
                  compact
                  onClick={() => act('drop', { item: item.ref || item.name })}
                >
                  Drop
                </Button>
                <Button
                  compact
                  onClick={() => act('hide', { item: item.ref || item.name })}
                >
                  Hide
                </Button>
              </Box>
            </Box>
          ))
        ) : (
          <Box color={TEXT_COLOR}>No contraband in possession</Box>
        )}
      </Section>

      <Section title="Hidden Items">
        {hidden_items && hidden_items.length > 0 ? (
          hidden_items.map((item) => (
            <Box key={item.name || item} color={TEXT_COLOR} mb={1}>
              {item.name || item}
            </Box>
          ))
        ) : (
          <Box color={TEXT_COLOR}>No hidden items</Box>
        )}
      </Section>

      <Section title="Crafted Items">
        {crafted_items && crafted_items.length > 0 ? (
          crafted_items.map((item) => (
            <Box key={item.name || item} color={TEXT_COLOR} mb={1}>
              {item.name || item}
            </Box>
          ))
        ) : (
          <Box color={TEXT_COLOR}>No crafted items</Box>
        )}
      </Section>
    </>
  );
};

const AchievementsTab = (props) => {
  const { act, data } = useBackend();
  const {
    rounds_played,
    total_escapes,
    contraband_found,
    work_completed,
    achievements,
  } = data;

  return (
    <>
      <Section title="Career Statistics">
        <LabeledList>
          <LabeledList.Item label="Rounds Played">
            <Box color={TEXT_COLOR}>{rounds_played}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Total Escapes">
            <Box color={GREEN_COLOR}>{total_escapes}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Contraband Found">
            <Box color={RED_COLOR}>{contraband_found}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Work Completed">
            <Box color={STATUS_COLOR}>{work_completed}</Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Achievements">
        {achievements && achievements.length > 0 ? (
          achievements.map((ach) => (
            <Box key={ach.name} mb={1}>
              <Box>
                <Box as="span" color={ach.unlocked ? GREEN_COLOR : RED_COLOR}>
                  {ach.unlocked ? '\u2713' : '\u2717'}
                </Box>{' '}
                <Box as="span" color={ach.unlocked ? STATUS_COLOR : TEXT_COLOR}>
                  {ach.name}
                </Box>
              </Box>
              {ach.description && (
                <Box color={TEXT_COLOR} ml={3} fontSize="12px">
                  {ach.description}
                </Box>
              )}
            </Box>
          ))
        ) : (
          <Box color={TEXT_COLOR}>No achievements available</Box>
        )}
      </Section>
    </>
  );
};

const EventsTab = (props) => {
  const { act, data } = useBackend();
  const { active_events, next_event_countdown } = data;

  return (
    <>
      <Section title="Active Events">
        {active_events && active_events.length > 0 ? (
          active_events.map((evt) => (
            <Box key={evt.name} mb={2}>
              <Box color={STATUS_COLOR} bold>
                {evt.name}
              </Box>
              {evt.description && (
                <Box color={TEXT_COLOR} mt={1}>
                  {evt.description}
                </Box>
              )}
              <LabeledList mt={1}>
                {evt.time_remaining !== undefined && (
                  <LabeledList.Item label="Time Remaining">
                    <Box color={TEXT_COLOR}>{evt.time_remaining}</Box>
                  </LabeledList.Item>
                )}
                {evt.escape_bonus !== undefined && evt.escape_bonus > 0 && (
                  <LabeledList.Item label="Escape Bonus">
                    <Box color={GREEN_COLOR}>+{evt.escape_bonus}</Box>
                  </LabeledList.Item>
                )}
                {evt.contraband_bonus !== undefined &&
                  evt.contraband_bonus > 0 && (
                    <LabeledList.Item label="Contraband Bonus">
                      <Box color={RED_COLOR}>+{evt.contraband_bonus}</Box>
                    </LabeledList.Item>
                  )}
              </LabeledList>
            </Box>
          ))
        ) : (
          <Box color={TEXT_COLOR}>No active events</Box>
        )}
      </Section>

      <Section title="Next Event">
        <Box color={STATUS_COLOR} textAlign="center" fontSize="16px">
          {next_event_countdown || 'No upcoming events'}
        </Box>
      </Section>
    </>
  );
};
