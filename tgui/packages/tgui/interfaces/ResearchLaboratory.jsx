import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Icon,
  Input,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Table,
  Stack,
} from '../components';
import { NtosWindow } from '../layouts';

const EXPERIMENT_RISK_COLORS = {
  1: 'good',
  2: 'average',
  3: 'label',
  4: 'orange',
  5: 'bad',
};

const RISK_NAMES = {
  1: 'Minimal',
  2: 'Low',
  3: 'Medium',
  4: 'High',
  5: 'Critical',
};

const PHASE_NAMES = {
  1: 'Preparation',
  2: 'Execution',
  3: 'Observation',
  4: 'Conclusion',
};

export const ResearchLaboratory = (props) => {
  const { act, data } = useBackend();
  const [activeTab, setActiveTab] = React.useState('overview');

  if (!data) {
    return <Box color="red">Loading SCP terminal data...</Box>;
  }

  const { is_admin, is_command } = data;

  return (
    <NtosWindow
      title="SCiPNet Research Terminal"
      width={1200}
      height={800}
    >
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Flex>
              {[
                { id: 'overview', name: 'Overview', icon: 'home' },
                { id: 'profile', name: 'Profile', icon: 'id-card' },
                { id: 'experiments', name: 'Experiments', icon: 'flask' },
                { id: 'projects', name: 'Projects', icon: 'folder' },
                { id: 'testing', name: 'Testing', icon: 'vial' },
                { id: 'techtree', name: 'Tech Tree', icon: 'sitemap' },
                { id: 'teams', name: 'Teams', icon: 'users' },
                { id: 'safety', name: 'Safety', icon: 'shield-alt' },
              ].map((tab) => (
                <Flex.Item key={tab.id} mx={0.5}>
                  <Button
                    selected={activeTab === tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    compact
                  >
                    <Icon name={tab.icon} mr={0.5} />
                    {tab.name}
                  </Button>
                </Flex.Item>
              ))}
              {!!(is_admin || is_command) && (
                <Flex.Item mx={0.5}>
                  <Button
                    selected={activeTab === 'admin'}
                    onClick={() => setActiveTab('admin')}
                    color="red"
                    compact
                  >
                    <Icon name="cog" mr={0.5} />
                    Admin
                  </Button>
                </Flex.Item>
              )}
            </Flex>
          </Stack.Item>
          <Stack.Item grow={1}>
            {activeTab === 'overview' && <OverviewTab />}
            {activeTab === 'profile' && <ProfileTab />}
            {activeTab === 'experiments' && <ExperimentsTab />}
            {activeTab === 'projects' && <ProjectsTab />}
            {activeTab === 'testing' && <TestingTab />}
            {activeTab === 'techtree' && <TechTreeTab />}
            {activeTab === 'teams' && <TeamsTab />}
            {activeTab === 'safety' && <SafetyTab />}
            {activeTab === 'admin' && !!(is_admin || is_command) && <AdminTab />}
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const OverviewTab = (props) => {
  const { act, data } = useBackend();
  const { system_metrics, scp_research_data, user_name, user_job, user_access_level } = data;

  return (
    <Section title="Research Laboratory Overview">
      <Flex wrap="wrap">
        <Flex.Item width="48%" m={0.5}>
          <Section title="System Metrics" level={2}>
            <LabeledList>
              <LabeledList.Item label="Research Points">
                {system_metrics?.total_research_points || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Active Experiments">
                {system_metrics?.total_experiments || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Breakthroughs">
                {system_metrics?.total_breakthroughs || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Research Efficiency">
                {((system_metrics?.research_efficiency || 1) * 100).toFixed(0)}%
              </LabeledList.Item>
              <LabeledList.Item label="Safety Rating">
                <ProgressBar
                  value={system_metrics?.safety_rating || 100}
                  maxValue={100}
                  color={system_metrics?.safety_rating > 80 ? 'good' : system_metrics?.safety_rating > 60 ? 'average' : 'bad'}
                >
                  {(system_metrics?.safety_rating || 100).toFixed(0)}%
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Containment Breaches">
                <Box color={system_metrics?.containment_breaches > 0 ? 'bad' : 'good'}>
                  {system_metrics?.containment_breaches || 0}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Research Incidents">
                {system_metrics?.research_incidents || 0}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex.Item>
        <Flex.Item width="48%" m={0.5}>
          <Section title="Researcher Profile" level={2}>
            <LabeledList>
              <LabeledList.Item label="Name">
                {user_name || 'Unknown'}
              </LabeledList.Item>
              <LabeledList.Item label="Position">
                {user_job || 'Unknown'}
              </LabeledList.Item>
              <LabeledList.Item label="Clearance Level">
                {user_access_level || 0}
              </LabeledList.Item>
            </LabeledList>
          </Section>
          {scp_research_data && (
            <Section title="SCP Research Data" level={2} mt={1}>
              <LabeledList>
                <LabeledList.Item label="Total Points">
                  {scp_research_data.total_research_points || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Breakthroughs">
                  {scp_research_data.research_breakthroughs || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Containment Improvements">
                  {scp_research_data.containment_improvements || 0}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          )}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const RANK_COLORS = {
  'Trainee': '#6a6a70',
  'Junior Researcher': '#4488ff',
  'Researcher': '#44ff44',
  'Senior Researcher': '#d4a017',
  'Lead Researcher': '#ff8800',
  'Research Director': '#ff4444',
};

const REWARD_TYPE_COLORS = {
  'budget': '#44ff44',
  'progression': '#4488ff',
  'equipment': '#d4a017',
};

const ProfileTab = (props) => {
  const { act, data } = useBackend();
  const {
    researcher_profile,
    achievements = [],
    milestones = [],
    rewards = [],
    completed_research = [],
    active_projects = [],
    global_metrics,
    inserted_id,
    has_access,
  } = data;

  return (
    <Section title="Researcher Profile">
      <Flex wrap="wrap">
        <Flex.Item width="48%" m={0.5}>
          <Section title="Global Metrics" level={2}>
            <LabeledList>
              <LabeledList.Item label="Total Points">
                {global_metrics?.total_points || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Total Funding">
                {global_metrics?.total_funding || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Breakthroughs">
                {global_metrics?.breakthroughs || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Containment Improvements">
                {global_metrics?.containment_improvements || 0}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex.Item>
        <Flex.Item width="48%" m={0.5}>
          <Section title="Identification" level={2}>
            <LabeledList>
              <LabeledList.Item label="Access">
                <Box bold color={has_access ? 'good' : 'bad'}>
                  {has_access ? 'AUTHORIZED' : 'DENIED'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Inserted ID">
                {inserted_id ? (
                  <Box>
                    {inserted_id.name} - {inserted_id.assignment}
                    <Button
                      content="EJECT"
                      color="average"
                      fontSize="10px"
                      ml={1}
                      onClick={() => act('eject_id')}
                    />
                  </Box>
                ) : (
                  <Box color="label">None</Box>
                )}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex.Item>
      </Flex>
      {!researcher_profile && (
        <Box color="label" textAlign="center" p={2}>
          No research data found. Begin researching SCPs to establish your profile.
        </Box>
      )}
      {researcher_profile && (
        <Flex wrap="wrap" mt={1}>
          <Flex.Item width="48%" m={0.5}>
            <Section title="Research Data" level={2}>
              <LabeledList>
                <LabeledList.Item label="Rank">
                  <Box bold color={RANK_COLORS[researcher_profile.research_rank] || '#4488ff'}>
                    {researcher_profile.research_rank}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Research Points">
                  {researcher_profile.research_points}
                </LabeledList.Item>
                <LabeledList.Item label="Funding">
                  {researcher_profile.research_funding}
                </LabeledList.Item>
                <LabeledList.Item label="Progression Points">
                  {researcher_profile.progression_points}
                </LabeledList.Item>
                <LabeledList.Item label="Total Projects">
                  {researcher_profile.total_projects}
                </LabeledList.Item>
                <LabeledList.Item label="Completed / Failed">
                  <Box inline color="good">{researcher_profile.completed_projects}</Box>
                  {' / '}
                  <Box inline color="bad">{researcher_profile.failed_projects} FAILED</Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
          <Flex.Item width="48%" m={0.5}>
            {achievements.length > 0 && (
              <Section title="Achievements" level={2}>
                {achievements.map((a, i) => (
                  <Box key={i} color="#d4a017" mb={0.5}>
                    {String.fromCharCode(9733)} {a.name}
                  </Box>
                ))}
              </Section>
            )}
            {completed_research.length > 0 && (
              <Section title="Completed Research" level={2} mt={1}>
                {completed_research.map((entry, i) => (
                  <Box key={i} color="good" mb={0.5} style={{ borderLeft: '2px solid #44ff44' }} pl={1}>
                    {entry.name}
                  </Box>
                ))}
              </Section>
            )}
          </Flex.Item>
        </Flex>
      )}
      {active_projects.length > 0 && (
        <Section title="Active Research Projects" level={2} mt={1}>
          {active_projects.map((project) => (
            <Box key={project.project_id} mb={1} p={0.5} backgroundColor="rgba(0,0,0,0.2)">
              <Flex align="center">
                <Flex.Item grow={1}>
                  <b>SCP-{project.scp_designation}</b> - {project.research_type}
                  <Box color="label" fontSize="11px">
                    Level {project.research_level}/{project.max_research_level} | Discoveries: {project.discoveries} | Elapsed: {project.time_minutes}m
                  </Box>
                  <ProgressBar
                    value={project.progress_percent / 100}
                    ranges={{ good: [0.75, Infinity], average: [0.25, 0.75], bad: [-Infinity, 0.25] }}
                  >
                    {project.research_points} / {project.research_cost} ({project.progress_percent}%)
                  </ProgressBar>
                </Flex.Item>
                <Flex.Item ml={1}>
                  <Button icon="plus" size="tiny" color="good" onClick={() => act('contribute_points', { project_id: project.project_id, amount: 50 })}>+50</Button>
                  <Button icon="plus" size="tiny" color="good" onClick={() => act('contribute_points', { project_id: project.project_id, amount: 100 })}>+100</Button>
                  <Button icon="times" size="tiny" color="bad" onClick={() => act('cancel_research', { project_id: project.project_id })}>Cancel</Button>
                </Flex.Item>
              </Flex>
            </Box>
          ))}
        </Section>
      )}
      {milestones.length > 0 && (
        <Section title="Milestones" level={2} mt={1}>
          {milestones.map((milestone) => (
            <Flex key={milestone.milestone_id} mb={1} style={{ borderLeft: milestone.completed ? '3px solid #44ff44' : '3px solid #6a6a70' }} pl={1}>
              <Flex.Item grow={1}>
                <Box bold color={milestone.completed ? 'good' : 'label'} fontSize="13px">{milestone.name}</Box>
                <Box color="label" fontSize="11px">{milestone.description}</Box>
                {milestone.completed && milestone.completed_by && (
                  <Box color="#4488ff" fontSize="10px" mt={0.5}>Completed by: {milestone.completed_by}</Box>
                )}
              </Flex.Item>
              <Flex.Item>
                <Box bold color={milestone.completed ? 'good' : 'label'} fontSize="11px">
                  {milestone.completed ? 'ACHIEVED' : 'LOCKED'}
                </Box>
              </Flex.Item>
            </Flex>
          ))}
        </Section>
      )}
      {rewards.length > 0 && (
        <Section title="Rewards" level={2} mt={1}>
          {rewards.map((reward) => (
            <Flex key={reward.reward_id} mb={1} style={{ borderLeft: reward.unlocked ? `3px solid ${REWARD_TYPE_COLORS[reward.reward_type] || '#4488ff'}` : '3px solid #6a6a70' }} pl={1}>
              <Flex.Item grow={1}>
                <Box bold color={REWARD_TYPE_COLORS[reward.reward_type] || '#4488ff'} fontSize="13px">{reward.description}</Box>
                <Box color="label" fontSize="11px">Type: {reward.reward_type.toUpperCase()} | Amount: {reward.reward_amount}</Box>
              </Flex.Item>
              <Flex.Item>
                {reward.unlocked ? (
                  <Button icon="check" size="tiny" color="good" onClick={() => act('claim_reward', { reward_id: reward.reward_id })}>CLAIM</Button>
                ) : (
                  <Box bold color="label" fontSize="11px">LOCKED</Box>
                )}
              </Flex.Item>
            </Flex>
          ))}
        </Section>
      )}
    </Section>
  );
};

const TestingTab = (props) => {
  const { act, data } = useBackend();
  const {
    test_proposals = [],
    active_tests = [],
    completed_tests = [],
    researcher_stats,
    total_tests_conducted,
    total_research_earned,
    total_incidents_during_tests,
    pending_count,
    scp_list = [],
    subjects = [],
  } = data;

  const [scpId, setScpId] = React.useState('');
  const [testType, setTestType] = React.useState('');
  const [riskLevel, setRiskLevel] = React.useState(1);
  const [subjectName, setSubjectName] = React.useState('');
  const [description, setDescription] = React.useState('');

  return (
    <Section title="SCP Testing Protocol">
      <Flex wrap="wrap" mb={1}>
        <Flex.Item m={0.5}>
          <Box color="label" fontSize="10px">CONDUCTED</Box>
          <Box bold fontSize="14px">{total_tests_conducted || 0}</Box>
        </Flex.Item>
        <Flex.Item m={0.5}>
          <Box color="label" fontSize="10px">RESEARCH EARNED</Box>
          <Box bold color="#d4a017" fontSize="14px">{total_research_earned || 0}</Box>
        </Flex.Item>
        <Flex.Item m={0.5}>
          <Box color="label" fontSize="10px">INCIDENTS</Box>
          <Box bold color="bad" fontSize="14px">{total_incidents_during_tests || 0}</Box>
        </Flex.Item>
      </Flex>

      {test_proposals.length > 0 && (
        <Section title={`Pending Proposals (${pending_count || 0})`} level={2}>
          {test_proposals.map((proposal) => (
            <Box key={proposal.proposal_id} mb={1} p={0.5} backgroundColor="rgba(0,0,0,0.2)">
              <Flex align="center">
                <Flex.Item grow={1}>
                  <b>#{proposal.proposal_id}</b> | <Box as="span" color="#d4a017">{proposal.scp_id}</Box> | {proposal.test_type}
                  <Button
                    compact
                    selected
                    color={EXPERIMENT_RISK_COLORS[proposal.risk_level] || 'label'}
                    fontSize="10px"
                    ml={1}
                  >
                    RISK-{proposal.risk_level}
                  </Button>
                  {proposal.ethics_required === 1 && (
                    <Button compact color="bad" fontSize="10px" ml={0.5}>ETHICS REVIEW</Button>
                  )}
                  <Box color="label" fontSize="11px">Subject: {proposal.subject_name}</Box>
                  <Box color="label" fontSize="11px" italic>{proposal.description}</Box>
                  <Box color="label" fontSize="10px">By: {proposal.researcher} | Submitted: {proposal.time_submitted}</Box>
                </Flex.Item>
                <Flex.Item>
                  {proposal.status === 0 && (
                    <>
                      <Button icon="check" size="tiny" color="good" onClick={() => act('approve_proposal', { proposal_id: proposal.proposal_id })}>Approve</Button>
                      <Button icon="times" size="tiny" color="bad" onClick={() => act('reject_proposal', { proposal_id: proposal.proposal_id })}>Reject</Button>
                    </>
                  )}
                </Flex.Item>
              </Flex>
            </Box>
          ))}
        </Section>
      )}

      {active_tests.length > 0 && (
        <Section title="Active Tests" level={2}>
          {active_tests.map((test) => (
            <Box key={test.proposal_id} mb={1} p={0.5} backgroundColor="rgba(0,0,0,0.2)">
              <Flex align="center">
                <Flex.Item grow={1}>
                  <b>#{test.proposal_id}</b> | <Box as="span" color="#d4a017">{test.scp_id}</Box> | {test.test_type}
                  <Button compact selected color={EXPERIMENT_RISK_COLORS[test.risk_level] || 'label'} fontSize="10px" ml={1}>
                    RISK-{test.risk_level}
                  </Button>
                  <Box color="label" fontSize="11px">Subject: {test.subject_name}</Box>
                </Flex.Item>
                <Flex.Item>
                  {test.status === 1 && (
                    <Button icon="play" size="tiny" color="good" onClick={() => act('start_test', { proposal_id: test.proposal_id })}>Start</Button>
                  )}
                  {test.status === 2 && (
                    <>
                      <Button icon="flask" size="tiny" color="good" onClick={() => act('execute_test', { proposal_id: test.proposal_id })}>Execute</Button>
                      <Button icon="times" size="tiny" color="bad" onClick={() => act('cancel_test', { proposal_id: test.proposal_id })}>Cancel</Button>
                    </>
                  )}
                </Flex.Item>
              </Flex>
            </Box>
          ))}
        </Section>
      )}

      {completed_tests.length > 0 && (
        <Section title="Completed Tests" level={2}>
          <Table>
            <Table.Row header>
              <Table.Cell>ID</Table.Cell>
              <Table.Cell>SCP</Table.Cell>
              <Table.Cell>Type</Table.Cell>
              <Table.Cell>Outcome</Table.Cell>
              <Table.Cell>Research</Table.Cell>
            </Table.Row>
            {completed_tests.slice(0, 15).map((test) => (
              <Table.Row key={test.proposal_id}>
                <Table.Cell>#{test.proposal_id}</Table.Cell>
                <Table.Cell color="#d4a017">{test.scp_id}</Table.Cell>
                <Table.Cell>{test.test_type}</Table.Cell>
                <Table.Cell>{test.outcome}</Table.Cell>
                <Table.Cell color="good">+{test.research_points} RP</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      )}

      <Section title="Submit Test Proposal" level={2} mt={1}>
        <LabeledList>
          <LabeledList.Item label="SCP ID">
            <Input value={scpId} placeholder="e.g. SCP-173" onChange={(e, value) => setScpId(value)} fluid />
          </LabeledList.Item>
          <LabeledList.Item label="Test Type">
            <Input value={testType} placeholder="e.g. Behavioral" onChange={(e, value) => setTestType(value)} fluid />
          </LabeledList.Item>
          <LabeledList.Item label="Risk Level">
            {[1, 2, 3, 4, 5].map((lvl) => (
              <Button key={lvl} selected={riskLevel === lvl} color={EXPERIMENT_RISK_COLORS[lvl]} size="tiny" onClick={() => setRiskLevel(lvl)}>
                {lvl} - {RISK_NAMES[lvl]}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Subject">
            <Input value={subjectName} placeholder="D-Class name" onChange={(e, value) => setSubjectName(value)} fluid />
          </LabeledList.Item>
          <LabeledList.Item label="Description">
            <Input value={description} placeholder="Test description..." onChange={(e, value) => setDescription(value)} fluid />
          </LabeledList.Item>
          <LabeledList.Item label="Actions">
            <Button icon="flask" color="good" disabled={!scpId || !testType} onClick={() => {
              act('submit_proposal', { scp_id: scpId, test_type: testType, risk_level: riskLevel, subject_name: subjectName, description: description });
              setScpId('');
              setTestType('');
              setRiskLevel(1);
              setSubjectName('');
              setDescription('');
            }}>
              Submit Proposal
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>

      {researcher_stats && (
        <Section title="Researcher Statistics" level={2} mt={1}>
          <LabeledList>
            <LabeledList.Item label="Proposals">{researcher_stats.total_proposals}</LabeledList.Item>
            <LabeledList.Item label="Completed">{researcher_stats.total_completed}</LabeledList.Item>
            <LabeledList.Item label="Research Earned">{researcher_stats.total_research_earned}</LabeledList.Item>
            <LabeledList.Item label="Incidents">{researcher_stats.total_incidents}</LabeledList.Item>
            <LabeledList.Item label="Last Active">{researcher_stats.last_active}</LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Section>
  );
};

const ExperimentsTab = (props) => {
  const { act, data } = useBackend();
  const { active_experiments, scp_targets, user_access_level } = data;
  const [selectedSCP, setSelectedSCP] = React.useState(null);

  const experimentList = active_experiments
    ? Object.values(active_experiments)
    : [];

  return (
    <Section title="SCP Experiments">
      <Flex>
        <Flex.Item width="55%">
          <Section title="Active Experiments" level={2}>
            {experimentList.length > 0 ? (
              <Table>
                <Table.Row header>
                  <Table.Cell>Experiment</Table.Cell>
                  <Table.Cell>SCP</Table.Cell>
                  <Table.Cell>Risk</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {experimentList.map((exp) => (
                  <Table.Row key={exp.id}>
                    <Table.Cell>{exp.name}</Table.Cell>
                    <Table.Cell>{exp.scp_id || 'N/A'}</Table.Cell>
                    <Table.Cell>
                      <Box color={EXPERIMENT_RISK_COLORS[exp.risk_level] || 'label'}>
                        {RISK_NAMES[exp.risk_level] || exp.risk_level}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <ProgressBar
                        value={exp.current_progress || 0}
                        maxValue={exp.max_progress || 100}
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Box color={exp.status === 'active' ? 'good' : exp.status === 'suspended' ? 'average' : 'label'}>
                        {exp.status}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      {exp.status === 'active' && (
                        <Button
                          icon="pause"
                          size="tiny"
                          color="average"
                          onClick={() => act('suspend_experiment', { experiment_id: exp.id })}
                          tooltip="Suspend"
                        />
                      )}
                      {exp.status === 'suspended' && (
                        <Button
                          icon="play"
                          size="tiny"
                          color="good"
                          onClick={() => act('resume_experiment', { experiment_id: exp.id })}
                          tooltip="Resume"
                        />
                      )}
                      <Button
                        icon="stop"
                        size="tiny"
                        color="bad"
                        onClick={() => act('terminate_experiment', { experiment_id: exp.id })}
                        tooltip="Terminate"
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            ) : (
              <Box color="label" textAlign="center" p={2}>
                No active experiments.
              </Box>
            )}
          </Section>
        </Flex.Item>
        <Flex.Item width="43%" ml={1}>
          <Section title="SCP Targets" level={2}>
            {scp_targets && scp_targets.length > 0 ? (
              scp_targets.map((scp) => (
                <Button
                  key={scp.id}
                  fluid
                  selected={selectedSCP === scp.id}
                  onClick={() => setSelectedSCP(scp.id)}
                  mb={0.5}
                >
                  {scp.id} ({scp.status})
                </Button>
              ))
            ) : (
              <Box color="label">No SCP instances available.</Box>
            )}
          </Section>
          {selectedSCP && user_access_level >= 3 && (
            <Section title="Start Experiment" level={2} mt={1}>
              <Box color="label" mb={1}>Selected: {selectedSCP}</Box>
              {[
                { type: 1, name: 'Behavioral', icon: 'eye' },
                { type: 2, name: 'Containment', icon: 'lock' },
                { type: 3, name: 'Interaction', icon: 'hand-point-up' },
                { type: 4, name: 'Hazard', icon: 'radiation' },
                { type: 5, name: 'Medical', icon: 'medkit' },
                { type: 6, name: 'Technical', icon: 'wrench' },
              ].map((expType) => (
                <Button
                  key={expType.type}
                  fluid
                  icon={expType.icon}
                  onClick={() => act('start_experiment', { scp_id: selectedSCP, experiment_type: expType.type })}
                  mb={0.5}
                >
                  {expType.name}
                </Button>
              ))}
            </Section>
          )}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const STATUS_COLORS = {
  PROPOSED: 'average',
  APPROVED: 'good',
  ACTIVE: 'blue',
  COMPLETED: 'green',
  SUSPENDED: 'bad',
};

const ProjectsTab = (props) => {
  const { act, data } = useBackend();
  const { research_projects, scp_targets, research_teams, is_researcher, is_admin, is_command } = data;
  const canManage = is_researcher || is_admin || is_command;
  const [showCreate, setShowCreate] = React.useState(false);
  const [expandedProject, setExpandedProject] = React.useState(null);
  const [projectName, setProjectName] = React.useState('');
  const [projectDesc, setProjectDesc] = React.useState('');
  const [scpTargets, setScpTargets] = React.useState([]);
  const [riskLevel, setRiskLevel] = React.useState(1);
  const [researchPoints, setResearchPoints] = React.useState(100);
  const [addTargetProject, setAddTargetProject] = React.useState(null);
  const [addTargetSCP, setAddTargetSCP] = React.useState('');
  const [assignTeamProject, setAssignTeamProject] = React.useState(null);
  const [assignTeamId, setAssignTeamId] = React.useState('');

  const projectList = Object.entries(research_projects || {}).map(([id, p]) => ({ ...p, id }));
  const scpOptions = (scp_targets || []).map((s) => s.id);
  const teamList = research_teams ? Object.values(research_teams) : [];
  const riskOptions = [
    { level: 1, name: '1 - Minimal' },
    { level: 2, name: '2 - Low' },
    { level: 3, name: '3 - Medium' },
    { level: 4, name: '4 - High' },
    { level: 5, name: '5 - Critical' },
  ];

  const handleCreate = () => {
    if (!projectName) return;
    act('create_project', {
      name: projectName,
      description: projectDesc || 'SCP research project.',
      scp_targets: scpTargets,
      risk_level: riskLevel,
      research_points: researchPoints,
    });
    setProjectName('');
    setProjectDesc('');
    setScpTargets([]);
    setRiskLevel(1);
    setResearchPoints(100);
    setShowCreate(false);
  };

  return (
    <Section title="Research Projects" buttons={
      canManage && <Button icon="plus" onClick={() => setShowCreate(!showCreate)}>
        New Project
      </Button>
    }>
      {showCreate && (
        <Section title="Create Project" level={2} mb={1}>
          <LabeledList>
            <LabeledList.Item label="Project Name">
              <Input
                value={projectName}
                placeholder="Enter project name..."
                onChange={(e, value) => setProjectName(value)}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Description">
              <Input
                value={projectDesc}
                placeholder="Project description..."
                onChange={(e, value) => setProjectDesc(value)}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="SCP Targets">
              {scpTargets.length > 0 ? (
                <Stack vertical>
                  {scpTargets.map((t) => (
                    <Stack.Item key={t}>
                      <Box inline mr={1}>{t}</Box>
                      <Button icon="times" size="tiny" color="bad" onClick={() => setScpTargets(scpTargets.filter((s) => s !== t))} />
                    </Stack.Item>
                  ))}
                </Stack>
              ) : (
                <Box color="label">None selected</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Add SCP Target">
              <Flex>
                <Flex.Item grow={1} mr={1}>
                  <Dropdown
                    options={scpOptions.length > 0 ? scpOptions : ['None Available']}
                    onSelected={(value) => {
                      if (value && !scpTargets.includes(value)) {
                        setScpTargets([...scpTargets, value]);
                      }
                    }}
                  />
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Risk Level">
              {riskOptions.map((r) => (
                <Button
                  key={r.level}
                  selected={riskLevel === r.level}
                  color={EXPERIMENT_RISK_COLORS[r.level]}
                  onClick={() => setRiskLevel(r.level)}
                  size="tiny"
                >
                  {r.name}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Research Points">
              <NumberInput
                value={researchPoints}
                minValue={10}
                maxValue={5000}
                step={10}
                onChange={(value) => setResearchPoints(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Actions">
              <Button icon="check" color="good" onClick={handleCreate} disabled={!projectName}>
                Create
              </Button>
              <Button onClick={() => setShowCreate(false)}>
                Cancel
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
      {projectList.length > 0 ? (
        <Table>
          <Table.Row header>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>SCP Target</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Risk</Table.Cell>
            <Table.Cell>Docs</Table.Cell>
            <Table.Cell>Actions</Table.Cell>
          </Table.Row>
          {projectList.map((project) => (
            <React.Fragment key={project.id}>
              <Table.Row>
                <Table.Cell>
                  <Button
                    icon={expandedProject === project.id ? 'chevron-down' : 'chevron-right'}
                    size="tiny"
                    compact
                    onClick={() => setExpandedProject(expandedProject === project.id ? null : project.id)}
                    mr={0.5}
                  />
                  {project.name}
                </Table.Cell>
                <Table.Cell>{project.scp_target || 'N/A'}</Table.Cell>
                <Table.Cell>
                  <Box color={project.status === 'approved' ? 'good' : project.status === 'proposed' ? 'average' : 'label'}>
                    {project.status}
                  </Box>
                </Table.Cell>
                <Table.Cell>{RISK_NAMES[project.risk_level] || project.risk_level}</Table.Cell>
                <Table.Cell>
                  <Box color={project.attached_documents?.length > 0 ? 'good' : 'label'}>
                    {project.attached_documents?.length || 0}
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  {project.status === 'proposed' && (
                    <Button icon="check" size="tiny" color="good" onClick={() => act('approve_project', { project_id: project.id })} tooltip="Approve" />
                  )}
                  <Button icon="print" size="tiny" color="average" onClick={() => act('print_authorization_form', { project_id: project.id })} tooltip="Print Authorization Form" />
                  <Button icon="clipboard-check" size="tiny" onClick={() => act('print_result_form', { project_id: project.id })} tooltip="Print Result Report" />
                  <Button icon="trash" size="tiny" color="bad" onClick={() => act('delete_project', { project_id: project.id })} tooltip="Delete" />
                </Table.Cell>
              </Table.Row>
              {expandedProject === project.id && (
                <Table.Row>
                  <Table.Cell colSpan={6}>
                    <Section level={2} title="Attached Documents" mt={0.5} mb={0} buttons={
                      project.is_assigned ? (
                        <Button
                          icon="paperclip"
                          color="good"
                          size="tiny"
                          onClick={() => act('attach_document', { project_id: project.id })}
                          tooltip="Attach paper from active hand"
                        >
                          Attach
                        </Button>
                      ) : (
                        <Box as="span" color="label" fontSize="0.9em">
                          You are not assigned
                        </Box>
                      )
                    }>
                      {(project.attached_documents?.length > 0) ? (
                        <Table>
                          <Table.Row header>
                            <Table.Cell>Document</Table.Cell>
                            <Table.Cell>Attached By</Table.Cell>
                            <Table.Cell>Preview</Table.Cell>
                            <Table.Cell>Actions</Table.Cell>
                          </Table.Row>
                          {project.attached_documents.map((doc) => (
                            <Table.Row key={doc.doc_id}>
                              <Table.Cell>
                                <Icon name="file-alt" mr={0.5} />
                                {doc.doc_name}
                              </Table.Cell>
                              <Table.Cell>{doc.attached_by_name}</Table.Cell>
                              <Table.Cell color="label" italic>
                                {doc.content_preview || 'Empty'}
                              </Table.Cell>
                              <Table.Cell>
                                {project.is_assigned && (
                                  <Button
                                    icon="eject"
                                    size="tiny"
                                    color="average"
                                    onClick={() => act('remove_document', { project_id: project.id, doc_id: doc.doc_id })}
                                    tooltip="Remove and return to hand"
                                  />
                                )}
                              </Table.Cell>
                            </Table.Row>
                          ))}
                        </Table>
                      ) : (
                        <Box color="label" textAlign="center" p={1} fontSize="0.9em">
                          No documents attached. Hold a paper in your active hand and click Attach.
                        </Box>
                      )}
                    </Section>
                  </Table.Cell>
                </Table.Row>
              )}
            </React.Fragment>
          ))}
        </Table>
      ) : (
        <Box color="label" textAlign="center" p={2}>No research projects.</Box>
      )}
    </Section>
  );
};

const TechTreeTab = (props) => {
  const { act, data } = useBackend();
  const { tech_tree, available_tech, system_metrics } = data;
  const [selectedCategory, setSelectedCategory] = React.useState(null);

  const categories = ['Containment', 'Medical', 'Engineering', 'Cognitive', 'Analytical'];
  const points = system_metrics?.total_research_points || 0;

  const allNodes = tech_tree ? Object.values(tech_tree) : [];
  const filteredNodes = selectedCategory
    ? allNodes.filter((n) => n.category === selectedCategory)
    : allNodes;

  const unlockedNodes = filteredNodes.filter((n) => n.unlocked);
  const lockedNodes = filteredNodes.filter((n) => !n.unlocked);
  const availableIds = new Set((available_tech || []).map((t) => t.id));

  return (
    <Section title="Technology Tree">
      <Box color="label" mb={1}>Available Research Points: {points}</Box>
      <Flex mb={1}>
        <Button selected={!selectedCategory} onClick={() => setSelectedCategory(null)} compact>All</Button>
        {categories.map((cat) => (
          <Button key={cat} selected={selectedCategory === cat} onClick={() => setSelectedCategory(cat)} compact>{cat}</Button>
        ))}
      </Flex>
      {unlockedNodes.length > 0 && (
        <Section title="Unlocked Technologies" level={2}>
          {unlockedNodes.map((node) => (
            <Box key={node.id} mb={0.5} p={0.5} backgroundColor="rgba(0, 100, 0, 0.15)">
              <Icon name="check-circle" color="good" mr={1} />
              <b>Tier {node.tier}:</b> {node.name}
              <Box as="span" color="label" ml={1}>- {node.description}</Box>
            </Box>
          ))}
        </Section>
      )}
      {lockedNodes.length > 0 && (
        <Section title="Available for Research" level={2}>
          {lockedNodes.map((node) => {
            const canAfford = availableIds.has(node.id);
            return (
              <Box key={node.id} mb={0.5} p={0.5} backgroundColor="rgba(100, 100, 0, 0.1)">
                <Flex align="center">
                  <Flex.Item grow={1}>
                    <b>Tier {node.tier}:</b> {node.name}
                    <Box as="span" color="label" ml={1}>- {node.description}</Box>
                    <Box color="label" fontSize="11px">Cost: {node.cost} pts | Category: {node.category} | Prerequisites: {node.prerequisites?.length > 0 ? node.prerequisites.join(', ') : 'None'}</Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="unlock"
                      color="good"
                      disabled={!canAfford}
                      onClick={() => act('unlock_tech', { node_id: node.id })}
                      size="tiny"
                    >
                      Unlock ({node.cost})
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            );
          })}
        </Section>
      )}
    </Section>
  );
};

const TeamsTab = (props) => {
  const { act, data } = useBackend();
  const { research_teams, researcher_skills, user_ckey, is_researcher, pending_join_requests, is_admin, is_command } = data;
  const [showCreate, setShowCreate] = React.useState(false);
  const [teamName, setTeamName] = React.useState('');

  const teamList = research_teams ? Object.values(research_teams) : [];
  const skills = researcher_skills || {};
  const joinRequests = pending_join_requests || [];

  const userTeamId = (() => {
    for (const team of teamList) {
      for (const m of team.members || []) {
        if (m.ckey === user_ckey) return team.id;
      }
    }
    return null;
  })();

  const handleCreate = () => {
    act('create_team', { name: teamName || undefined });
    setTeamName('');
    setShowCreate(false);
  };

  return (
    <Section title="Research Teams" buttons={
      (is_researcher || is_admin || is_command) && <Button icon="plus" onClick={() => setShowCreate(!showCreate)}>
        New Team
      </Button>
    }>
      {showCreate && (
        <Section title="Create Team" level={2} mb={1}>
          <LabeledList>
            <LabeledList.Item label="Team Name">
              <Input
                value={teamName}
                placeholder="Leave blank for auto-name..."
                onChange={(e, value) => setTeamName(value)}
                fluid
              />
            </LabeledList.Item>
            <LabeledList.Item label="Actions">
              <Button icon="check" color="good" onClick={handleCreate}>
                Create
              </Button>
              <Button onClick={() => setShowCreate(false)}>
                Cancel
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
      <Flex>
        <Flex.Item width="55%">
          {teamList.length > 0 ? (
            teamList.map((team) => {
              const isMember = (team.members || []).some((m) => m.ckey === user_ckey);
              const hasPendingRequest = joinRequests.some((r) => r.ckey === user_ckey && r.team_id === team.id);
              const teamRequests = joinRequests.filter((r) => r.team_id === team.id);
              return (
                <Section key={team.id} title={team.name || team.id} level={2} buttons={
                  isMember ? (
                    <Button icon="user-minus" size="tiny" color="bad" onClick={() => act('remove_team_member', { team_id: team.id, ckey: user_ckey })}>
                      Leave
                    </Button>
                  ) : !userTeamId ? (
                    is_researcher ? (
                      <Button icon="user-plus" size="tiny" color="good" onClick={() => act('add_team_member', { team_id: team.id })}>
                        Join
                      </Button>
                    ) : hasPendingRequest ? (
                      <Button icon="clock" size="tiny" disabled tooltip="Request pending approval">
                        Pending
                      </Button>
                    ) : (
                      <Button icon="user-plus" size="tiny" color="average" onClick={() => act('request_team_join', { team_id: team.id })}>
                        Request to Join
                      </Button>
                    )
                  ) : (
                    <Button icon="user-plus" size="tiny" disabled tooltip="Already in a team">
                      Join
                    </Button>
                  )
                }>
                  <LabeledList>
                    <LabeledList.Item label="Status">
                      <Box color={team.status === 'active' ? 'good' : 'bad'}>{team.status}</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Members">
                      {(team.members || []).map((m) => m.name).join(', ') || 'None'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Experiments Completed">
                      {team.completed_experiments || 0}
                    </LabeledList.Item>
                  </LabeledList>
                  {(is_researcher || is_admin || is_command) && teamRequests.length > 0 && (
                    <Section title="Join Requests" level={3} mt={1}>
                      {teamRequests.map((req) => (
                        <Box key={req.request_id} mb={1}>
                          <Box inline color="label">{req.name}</Box>
                          <Box inline color="label" ml={1}>({req.role})</Box>
                          <Button icon="check" size="tiny" color="good" ml={1} onClick={() => act('approve_join_request', { request_id: req.request_id })}>
                            Approve
                          </Button>
                          <Button icon="times" size="tiny" color="bad" ml={1} onClick={() => act('deny_join_request', { request_id: req.request_id })}>
                            Deny
                          </Button>
                        </Box>
                      ))}
                    </Section>
                  )}
                </Section>
              );
            })
          ) : (
            <Box color="label" p={2}>No research teams created yet.</Box>
          )}
        </Flex.Item>
        <Flex.Item width="43%" ml={1}>
          <Section title="Active Researchers" level={2}>
            {Object.keys(skills).length > 0 ? (
              <Table>
                <Table.Row header>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Job</Table.Cell>
                  <Table.Cell>Skill</Table.Cell>
                </Table.Row>
                {Object.entries(skills).map(([name, skill]) => (
                  <Table.Row key={name}>
                    <Table.Cell>{name}</Table.Cell>
                    <Table.Cell>{skill.job}</Table.Cell>
                    <Table.Cell>
                      <ProgressBar value={skill.level || 0} maxValue={100} fontSize="10px">
                        Lv.{skill.level || 0}
                      </ProgressBar>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            ) : (
              <Box color="label">No researchers online.</Box>
            )}
          </Section>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const SafetyTab = (props) => {
  const { act, data } = useBackend();
  const { safety_protocols, system_metrics } = data;

  const protocolList = safety_protocols ? Object.values(safety_protocols) : [];

  return (
    <Section title="Safety Protocols">
      <LabeledList>
        <LabeledList.Item label="Overall Safety Rating">
          <ProgressBar value={system_metrics?.safety_rating || 100} maxValue={100} color={system_metrics?.safety_rating > 80 ? 'good' : 'bad'}>
            {(system_metrics?.safety_rating || 100).toFixed(0)}%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Research Incidents">
          {system_metrics?.research_incidents || 0}
        </LabeledList.Item>
        <LabeledList.Item label="Containment Breaches">
          {system_metrics?.containment_breaches || 0}
        </LabeledList.Item>
      </LabeledList>
      {protocolList.length > 0 && (
        <Section title="Active Protocols" level={2} mt={1}>
          {protocolList.map((protocol) => (
            <Box key={protocol.id} mb={1} p={0.5} backgroundColor={
              protocol.status === 'emergency' ? 'rgba(200, 0, 0, 0.15)' : 'rgba(0, 0, 0, 0.2)'
            }>
              <Flex align="center">
                <Flex.Item grow={1}>
                  <b>{protocol.name}</b>
                  <Box color="label" fontSize="11px">{protocol.description}</Box>
                  <Box fontSize="11px">Violations: {protocol.violations || 0} / {protocol.violation_threshold || 5}</Box>
                </Flex.Item>
                <Flex.Item>
                  <Box color={protocol.status === 'active' ? 'good' : protocol.status === 'emergency' ? 'bad' : 'average'}>
                    {protocol.status}
                  </Box>
                </Flex.Item>
              </Flex>
            </Box>
          ))}
        </Section>
      )}
    </Section>
  );
};

const AdminTab = (props) => {
  const { act, data } = useBackend();
  const { research_facilities, research_achievements } = data;

  return (
    <Section title="Admin Controls">
      <Flex wrap="wrap">
        <Flex.Item width="48%" m={0.5}>
          <Section title="Quick Actions" level={2}>
            <Button icon="users" fluid mb={0.5} onClick={() => act('create_team', {})}>
              Create Research Team
            </Button>
            <Button icon="shield-alt" fluid mb={0.5} onClick={() => act('record_violation', { protocol_id: 'safety_standard' })}>
              Record Safety Violation
            </Button>
          </Section>
        </Flex.Item>
        <Flex.Item width="48%" m={0.5}>
          <Section title="Facilities" level={2}>
            {(research_facilities ? Object.values(research_facilities) : []).map((facility) => (
              <Box key={facility.id} mb={0.5} p={0.5} backgroundColor="rgba(0,0,0,0.2)">
                <b>{facility.name}</b>
                <Box color="label" fontSize="11px">
                  Status: {facility.status} | Experiments: {facility.active_experiments || 0} | Safety: {facility.safety_rating || 100}%
                </Box>
              </Box>
            ))}
          </Section>
          <Section title="Achievements" level={2} mt={1}>
            {research_achievements && Object.keys(research_achievements).length > 0 ? (
              Object.values(research_achievements).map((ach) => (
                <Box key={ach.id} fontSize="11px" mb={0.5}>
                  <Icon name="trophy" color="gold" mr={0.5} />{ach.description}
                </Box>
              ))
            ) : (
              <Box color="label">No achievements unlocked yet.</Box>
            )}
          </Section>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
