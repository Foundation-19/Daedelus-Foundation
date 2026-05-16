import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
  Stack,
} from '../components';
import { Window } from '../layouts';

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

  const { is_admin } = data;

  return (
    <Window
      title="SCiPNet Research Terminal"
      width={1200}
      height={800}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Flex>
              {[
                { id: 'overview', name: 'Overview', icon: 'home' },
                { id: 'experiments', name: 'Experiments', icon: 'flask' },
                { id: 'projects', name: 'Projects', icon: 'folder' },
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
              {!!is_admin && (
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
            {activeTab === 'experiments' && <ExperimentsTab />}
            {activeTab === 'projects' && <ProjectsTab />}
            {activeTab === 'techtree' && <TechTreeTab />}
            {activeTab === 'teams' && <TeamsTab />}
            {activeTab === 'safety' && <SafetyTab />}
            {activeTab === 'admin' && !!is_admin && <AdminTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
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
          <Section title="Active Experiments" level={2} buttons={
            <Button icon="flask" onClick={() => act('start_experiment', { scp_id: selectedSCP, experiment_type: 1 })} disabled={!selectedSCP || user_access_level < 3}>
              Start Behavioral Experiment
            </Button>
          }>
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

const ProjectsTab = (props) => {
  const { act, data } = useBackend();
  const { research_projects } = data;
  const [showCreate, setShowCreate] = React.useState(false);

  const projectList = research_projects ? Object.values(research_projects) : [];

  return (
    <Section title="Research Projects" buttons={
      <Button icon="plus" onClick={() => setShowCreate(!showCreate)}>
        New Project
      </Button>
    }>
      {showCreate && (
        <Section title="Create Project" level={2} mb={1}>
          <LabeledList>
            <LabeledList.Item label="Project Name">
              <Button icon="edit" onClick={() => act('create_project', { name: 'New Research Project', description: 'SCP research project.', risk_level: 1, research_points: 100 })}>
                Create Default
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
            <Table.Cell>Actions</Table.Cell>
          </Table.Row>
          {projectList.map((project) => (
            <Table.Row key={project.id}>
              <Table.Cell>{project.name}</Table.Cell>
              <Table.Cell>{project.scp_target || 'N/A'}</Table.Cell>
              <Table.Cell>
                <Box color={project.status === 'approved' ? 'good' : project.status === 'proposed' ? 'average' : 'label'}>
                  {project.status}
                </Box>
              </Table.Cell>
              <Table.Cell>{RISK_NAMES[project.risk_level] || project.risk_level}</Table.Cell>
              <Table.Cell>
                {project.status === 'proposed' && (
                  <Button icon="check" size="tiny" color="good" onClick={() => act('approve_project', { project_id: project.id })} tooltip="Approve" />
                )}
                <Button icon="trash" size="tiny" color="bad" onClick={() => act('delete_project', { project_id: project.id })} tooltip="Delete" />
              </Table.Cell>
            </Table.Row>
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
  const { research_teams, researcher_skills } = data;

  const teamList = research_teams ? Object.values(research_teams) : [];
  const skills = researcher_skills || {};

  return (
    <Section title="Research Teams" buttons={
      <Button icon="plus" onClick={() => act('create_team', { name: 'Research Team Alpha' })}>
        New Team
      </Button>
    }>
      <Flex>
        <Flex.Item width="55%">
          {teamList.length > 0 ? (
            teamList.map((team) => (
              <Section key={team.id} title={team.name || team.id} level={2} buttons={
                <Button icon="user-plus" size="tiny" onClick={() => act('add_team_member', { team_id: team.id })}>
                  Join
                </Button>
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
              </Section>
            ))
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
            <Button icon="plus" fluid mb={0.5} onClick={() => act('create_project', { name: 'Admin Research Project', description: 'Admin-created project.', risk_level: 3, research_points: 500 })}>
              Create Research Project
            </Button>
            <Button icon="users" fluid mb={0.5} onClick={() => act('create_team', { name: 'Admin Team' })}>
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
