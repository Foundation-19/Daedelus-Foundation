import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, NoticeBox, ProgressBar, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { useState } from 'react';

const RANK_COLORS: Record<string, string> = {
  'Trainee': '#6a6a70',
  'Junior Researcher': '#4488ff',
  'Researcher': '#44ff44',
  'Senior Researcher': '#d4a017',
  'Lead Researcher': '#ff8800',
  'Research Director': '#ff4444',
};

const REWARD_TYPE_COLORS: Record<string, string> = {
  'budget': '#44ff44',
  'progression': '#4488ff',
  'equipment': '#d4a017',
};

const ProfileTab = (props) => {
  const { act, data } = useBackend();
  const {
    researcher_profile,
    achievements = [],
    inserted_id,
    has_access,
  } = data;

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="IDENTIFICATION">
          <Flex wrap>
            <Flex.Item basis="50%">
              <Box color="#6a6a70" fontSize="11px">
                ACCESS STATUS:
              </Box>
              <Box bold color={has_access ? '#44ff44' : '#ff4444'} fontSize="14px">
                {has_access ? 'AUTHORIZED' : 'DENIED'}
              </Box>
            </Flex.Item>
            <Flex.Item basis="50%">
              <Box color="#6a6a70" fontSize="11px">
                INSERTED ID:
              </Box>
              <Box bold color={inserted_id ? '#4488ff' : '#6a6a70'} fontSize="14px">
                {inserted_id
                  ? `${inserted_id.name} - ${inserted_id.assignment}`
                  : 'NONE'}
              </Box>
              {inserted_id && (
                <Button
                  content="EJECT ID"
                  color="average"
                  fontSize="10px"
                  mt={0.5}
                  onClick={() => act('eject_id')}
                />
              )}
            </Flex.Item>
          </Flex>
        </Section>
      </Stack.Item>
      {!researcher_profile && (
        <Stack.Item>
          <NoticeBox info>
            No research data found. Begin researching SCPs to establish your
            profile.
          </NoticeBox>
        </Stack.Item>
      )}
      {researcher_profile && (
        <>
          <Stack.Item>
            <Section title="RESEARCHER PROFILE">
              <LabeledList>
                <LabeledList.Item label="Research Rank">
                  <Box
                    bold
                    color={
                      RANK_COLORS[researcher_profile.research_rank] || '#4488ff'
                    }
                  >
                    {researcher_profile.research_rank}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Research Points">
                  {researcher_profile.research_points}
                </LabeledList.Item>
                <LabeledList.Item label="Research Funding">
                  {researcher_profile.research_funding}
                </LabeledList.Item>
                <LabeledList.Item label="Progression Points">
                  {researcher_profile.progression_points}
                </LabeledList.Item>
                <LabeledList.Item label="Total Projects">
                  {researcher_profile.total_projects}
                </LabeledList.Item>
                <LabeledList.Item label="Completed">
                  <Box inline color="#44ff44">
                    {researcher_profile.completed_projects}
                  </Box>
                  {' / '}
                  <Box inline color="#ff4444">
                    {researcher_profile.failed_projects} FAILED
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          {achievements.length > 0 && (
            <Stack.Item>
              <Section title="ACHIEVEMENTS">
                {achievements.map((a, i) => (
                  <Box key={i} color="#d4a017" mb={0.5}>
                    {String.fromCharCode(9733)} {a.name}
                  </Box>
                ))}
              </Section>
            </Stack.Item>
          )}
        </>
      )}
    </Stack>
  );
};

const ActiveProjectsTab = (props) => {
  const { act, data } = useBackend();
  const { active_projects = [] } = data;

  if (active_projects.length === 0) {
    return (
      <NoticeBox info>
        No active research projects. Interact with SCP specimens to begin
        research.
      </NoticeBox>
    );
  }

  return (
    <Stack vertical>
      {active_projects.map((project) => (
        <Stack.Item key={project.project_id}>
          <Section
            title={`SCP-${project.scp_designation} - ${project.research_type}`}
            buttons={
              <Button
                content="CANCEL"
                color="bad"
                fontSize="10px"
                onClick={() =>
                  act('cancel_research', {
                    project_id: project.project_id,
                  })
                }
              />
            }
          >
            <Flex wrap mb={1}>
              <Flex.Item basis="25%">
                <Box color="#6a6a70" fontSize="10px">
                  LEVEL
                </Box>
                <Box bold color="#4488ff" fontSize="14px">
                  {project.research_level}/{project.max_research_level}
                </Box>
              </Flex.Item>
              <Flex.Item basis="25%">
                <Box color="#6a6a70" fontSize="10px">
                  DISCOVERIES
                </Box>
                <Box bold color="#d4a017" fontSize="14px">
                  {project.discoveries}
                </Box>
              </Flex.Item>
              <Flex.Item basis="25%">
                <Box color="#6a6a70" fontSize="10px">
                  ELAPSED
                </Box>
                <Box bold color="#6a6a70" fontSize="14px">
                  {project.time_minutes}m
                </Box>
              </Flex.Item>
            </Flex>
            <Box color="#6a6a70" fontSize="10px" mb={0.5}>
              PROGRESS
            </Box>
            <ProgressBar
              value={project.progress_percent / 100}
              ranges={{
                good: [0.75, Infinity],
                average: [0.25, 0.75],
                bad: [-Infinity, 0.25],
              }}
            >
              {project.research_points} / {project.research_cost} (
              {project.progress_percent}%)
            </ProgressBar>
            <Flex mt={1}>
              <Flex.Item>
                <Button
                  content="+50"
                  color="good"
                  fontSize="10px"
                  onClick={() =>
                    act('contribute_points', {
                      project_id: project.project_id,
                      amount: 50,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item ml={0.5}>
                <Button
                  content="+100"
                  color="good"
                  fontSize="10px"
                  onClick={() =>
                    act('contribute_points', {
                      project_id: project.project_id,
                      amount: 100,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item ml={0.5}>
                <Button
                  content="+500"
                  color="good"
                  fontSize="10px"
                  onClick={() =>
                    act('contribute_points', {
                      project_id: project.project_id,
                      amount: 500,
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const CompletedTab = (props) => {
  const { data } = useBackend();
  const { completed_research = [] } = data;

  if (completed_research.length === 0) {
    return (
      <NoticeBox info>
        No completed research entries yet.
      </NoticeBox>
    );
  }

  return (
    <Section title="COMPLETED RESEARCH">
      {completed_research.map((entry, i) => (
        <Box
          key={i}
          color="#44ff44"
          mb={0.5}
          style={{ 'border-left': '2px solid #44ff44' }}
          pl={1}
        >
          {entry.name}
        </Box>
      ))}
    </Section>
  );
};

const MilestonesTab = (props) => {
  const { data } = useBackend();
  const { milestones = [] } = data;

  if (milestones.length === 0) {
    return (
      <NoticeBox info>
        No milestones available.
      </NoticeBox>
    );
  }

  return (
    <Section title="RESEARCH MILESTONES">
      {milestones.map((milestone) => (
        <Flex
          key={milestone.milestone_id}
          mb={1}
          style={{
            'border-left': milestone.completed
              ? '3px solid #44ff44'
              : '3px solid #6a6a70',
          }}
          pl={1}
        >
          <Flex.Item grow={1}>
            <Box
              bold
              color={milestone.completed ? '#44ff44' : '#6a6a70'}
              fontSize="13px"
            >
              {milestone.name}
            </Box>
            <Box color="#6a6a70" fontSize="11px">
              {milestone.description}
            </Box>
            {milestone.completed && milestone.completed_by && (
              <Box color="#4488ff" fontSize="10px" mt={0.5}>
                Completed by: {milestone.completed_by}
              </Box>
            )}
          </Flex.Item>
          <Flex.Item>
            <Box
              bold
              color={milestone.completed ? '#44ff44' : '#6a6a70'}
              fontSize="11px"
            >
              {milestone.completed ? 'ACHIEVED' : 'LOCKED'}
            </Box>
          </Flex.Item>
        </Flex>
      ))}
    </Section>
  );
};

const RewardsTab = (props) => {
  const { act, data } = useBackend();
  const { rewards = [] } = data;

  if (rewards.length === 0) {
    return (
      <NoticeBox info>
        No rewards available.
      </NoticeBox>
    );
  }

  return (
    <Section title="RESEARCH REWARDS">
      {rewards.map((reward) => (
        <Flex
          key={reward.reward_id}
          mb={1}
          style={{
            'border-left': reward.unlocked
              ? `3px solid ${REWARD_TYPE_COLORS[reward.reward_type] || '#4488ff'}`
              : '3px solid #6a6a70',
          }}
          pl={1}
        >
          <Flex.Item grow={1}>
            <Box
              bold
              color={
                REWARD_TYPE_COLORS[reward.reward_type] || '#4488ff'
              }
              fontSize="13px"
            >
              {reward.description}
            </Box>
            <Box color="#6a6a70" fontSize="11px">
              Type: {reward.reward_type.toUpperCase()} | Amount:{' '}
              {reward.reward_amount}
            </Box>
          </Flex.Item>
          <Flex.Item>
            {reward.unlocked ? (
              <Button
                content="CLAIM"
                color="good"
                fontSize="10px"
                onClick={() =>
                  act('claim_reward', { reward_id: reward.reward_id })
                }
              />
            ) : (
              <Box bold color="#6a6a70" fontSize="11px">
                LOCKED
              </Box>
            )}
          </Flex.Item>
        </Flex>
      ))}
    </Section>
  );
};

export const ScpResearchConsole = (props) => {
  const { act, data } = useBackend();
  const [tabIndex, setTabIndex] = useState(1);

  const {
    global_metrics,
    researcher_profile,
  } = data;

  return (
    <Window theme="scp_terminal" width={750} height={650}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="SCP FOUNDATION RESEARCH DIVISION">
              <Flex wrap>
                <Flex.Item basis="25%">
                  <Box color="#6a6a70" fontSize="10px">
                    TOTAL POINTS
                  </Box>
                  <Box bold color="#4488ff" fontSize="16px">
                    {global_metrics?.total_points || 0}
                  </Box>
                </Flex.Item>
                <Flex.Item basis="25%">
                  <Box color="#6a6a70" fontSize="10px">
                    TOTAL FUNDING
                  </Box>
                  <Box bold color="#44ff44" fontSize="16px">
                    {global_metrics?.total_funding || 0}
                  </Box>
                </Flex.Item>
                <Flex.Item basis="25%">
                  <Box color="#6a6a70" fontSize="10px">
                    BREAKTHROUGHS
                  </Box>
                  <Box bold color="#d4a017" fontSize="16px">
                    {global_metrics?.breakthroughs || 0}
                  </Box>
                </Flex.Item>
                <Flex.Item basis="25%">
                  <Box color="#6a6a70" fontSize="10px">
                    CONTAINMENT IMPROVEMENTS
                  </Box>
                  <Box bold color="#ff8800" fontSize="16px">
                    {global_metrics?.containment_improvements || 0}
                  </Box>
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                Profile
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                Active Projects
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 3}
                onClick={() => setTabIndex(3)}
              >
                Completed
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 4}
                onClick={() => setTabIndex(4)}
              >
                Milestones
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 5}
                onClick={() => setTabIndex(5)}
              >
                Rewards
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tabIndex === 1 && <ProfileTab />}
            {tabIndex === 2 && <ActiveProjectsTab />}
            {tabIndex === 3 && <CompletedTab />}
            {tabIndex === 4 && <MilestonesTab />}
            {tabIndex === 5 && <RewardsTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
