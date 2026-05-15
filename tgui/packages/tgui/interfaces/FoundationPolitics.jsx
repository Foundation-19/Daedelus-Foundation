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

export const FoundationPolitics = (props) => {
  const { act, data } = useBackend();
  const [activeTab, setActiveTab] = useState('overview');
  const [selectedDepartment, setSelectedDepartment] = useState(null);
  const [selectedFaction, setSelectedFaction] = useState(null);

  const {
    departments,
    factions,
    power_structures,
    political_events,
    alliances,
    conflicts,
    metrics,
  } = data;

  return (
    <Window width={1400} height={900}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item>
            <Section title="Foundation Politics & Hierarchy System">
              <Flex>
                <Flex.Item width="70%">
                  <LabeledList>
                    <LabeledList.Item label="Total Departments">
                      {metrics?.total_departments || 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Active Factions">
                      {metrics?.active_factions || 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Political Tensions">
                      {metrics?.political_tensions || 0}/100
                    </LabeledList.Item>
                    <LabeledList.Item label="Power Balance">
                      {metrics?.power_balance_score || 50}/100
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
                <Flex.Item width="30%">
                  <Button
                    fluid
                    icon="plus"
                    onClick={() => act('create_department')}
                  >
                    Create Department
                  </Button>
                  <Button
                    fluid
                    icon="users"
                    onClick={() => act('create_faction')}
                    mt={1}
                  >
                    Create Faction
                  </Button>
                  <Button
                    fluid
                    icon="crown"
                    onClick={() => act('create_power_structure')}
                    mt={1}
                  >
                    Create Power Structure
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
                selected={activeTab === 'departments'}
                onClick={() => setActiveTab('departments')}
              >
                Departments
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'factions'}
                onClick={() => setActiveTab('factions')}
              >
                Factions
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'power_structures'}
                onClick={() => setActiveTab('power_structures')}
              >
                Power Structures
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'events'}
                onClick={() => setActiveTab('events')}
              >
                Political Events
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'conflicts'}
                onClick={() => setActiveTab('conflicts')}
              >
                Conflicts & Alliances
              </Tabs.Tab>
            </Tabs>

            <Box height="calc(100% - 50px)" overflowY="auto">
              {activeTab === 'overview' && (
                <OverviewTab
                  departments={departments}
                  factions={factions}
                  power_structures={power_structures}
                  metrics={metrics}
                />
              )}
              {activeTab === 'departments' && (
                <DepartmentsTab
                  departments={departments}
                  selectedDepartment={selectedDepartment}
                  setSelectedDepartment={setSelectedDepartment}
                />
              )}
              {activeTab === 'factions' && (
                <FactionsTab
                  factions={factions}
                  selectedFaction={selectedFaction}
                  setSelectedFaction={setSelectedFaction}
                />
              )}
              {activeTab === 'power_structures' && (
                <PowerStructuresTab power_structures={power_structures} />
              )}
              {activeTab === 'events' && (
                <PoliticalEventsTab events={political_events} />
              )}
              {activeTab === 'conflicts' && (
                <ConflictsTab conflicts={conflicts} alliances={alliances} />
              )}
            </Box>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const OverviewTab = ({ departments, factions, power_structures, metrics }) => {
  return (
    <Flex>
      <Flex.Item width="50%">
        <Section title="Department Overview">
          {Object.entries(departments || {}).map(([dept_id, dept]) => (
            <Box
              key={dept_id}
              mb={2}
              p={1}
              backgroundColor="rgba(255, 255, 255, 0.05)"
            >
              <Flex justify="space-between" align="center">
                <Flex.Item>
                  <Box fontWeight="bold">{dept.name}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    Head: {dept.head} ΓÇó Budget: ${dept.budget?.toLocaleString()}
                  </Box>
                </Flex.Item>
                <Flex.Item>
                  <ProgressBar
                    value={dept.influence}
                    maxValue={100}
                    color={
                      dept.influence > 70
                        ? 'good'
                        : dept.influence > 40
                          ? 'average'
                          : 'bad'
                    }
                  />
                  <Box fontSize="0.8em" textAlign="center">
                    {dept.influence}/100 Influence
                  </Box>
                </Flex.Item>
              </Flex>
            </Box>
          ))}
        </Section>
      </Flex.Item>

      <Flex.Item width="50%">
        <Section title="Faction Overview">
          {Object.entries(factions || {}).map(([faction_id, faction]) => (
            <Box
              key={faction_id}
              mb={2}
              p={1}
              backgroundColor="rgba(255, 255, 255, 0.05)"
            >
              <Flex justify="space-between" align="center">
                <Flex.Item>
                  <Box fontWeight="bold">{faction.name}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    Leader: {faction.leader} ΓÇó {faction.membership || 0} members
                  </Box>
                </Flex.Item>
                <Flex.Item>
                  <ProgressBar
                    value={faction.influence}
                    maxValue={100}
                    color={
                      faction.influence > 70
                        ? 'good'
                        : faction.influence > 40
                          ? 'average'
                          : 'bad'
                    }
                  />
                  <Box fontSize="0.8em" textAlign="center">
                    {faction.influence}/100 Influence
                  </Box>
                </Flex.Item>
              </Flex>
            </Box>
          ))}
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const DepartmentsTab = ({
  departments,
  selectedDepartment,
  setSelectedDepartment,
}) => {
  const { act } = useBackend();

  return (
    <Flex>
      <Flex.Item width="40%">
        <Section title="Departments">
          {Object.entries(departments || {}).map(([dept_id, dept]) => (
            <Box
              key={dept_id}
              p={1}
              mb={1}
              backgroundColor={
                selectedDepartment?.department_id === dept_id
                  ? 'rgba(0, 255, 0, 0.1)'
                  : 'rgba(255, 255, 255, 0.05)'
              }
              onClick={() => setSelectedDepartment(dept)}
              style={{ cursor: 'pointer' }}
            >
              <Box fontWeight="bold">{dept.name}</Box>
              <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                {dept.type} ΓÇó {dept.status || 'active'}
              </Box>
              <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                {dept.members?.length || 0} members
              </Box>
            </Box>
          ))}
        </Section>
      </Flex.Item>

      <Flex.Item width="60%">
        {selectedDepartment ? (
          <DepartmentDetailView department={selectedDepartment} />
        ) : (
          <Section title="Department Details">
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              Select a department to view details.
            </Box>
          </Section>
        )}
      </Flex.Item>
    </Flex>
  );
};

const DepartmentDetailView = ({ department }) => {
  const { act } = useBackend();

  return (
    <Section title={department.name}>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Type">{department.type}</LabeledList.Item>
            <LabeledList.Item label="Head">{department.head}</LabeledList.Item>
            <LabeledList.Item label="Status">
              {department.status}
            </LabeledList.Item>
            <LabeledList.Item label="Budget">
              ${department.budget?.toLocaleString()}
            </LabeledList.Item>
            <LabeledList.Item label="Influence">
              {department.influence}/100
            </LabeledList.Item>
          </LabeledList>
          <ProgressBar
            value={department.influence}
            maxValue={100}
            color={
              department.influence > 70
                ? 'good'
                : department.influence > 40
                  ? 'average'
                  : 'bad'
            }
            mt={1}
          />
        </Stack.Item>

        <Stack.Item>
          <Section title="Department Goals">
            {department.goals?.length > 0 ? (
              department.goals.map((goal, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(0, 255, 0, 0.1)"
                >
                  <Box fontWeight="bold">{goal}</Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No goals defined.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Department Members">
            {department.members?.length > 0 ? (
              department.members.map((member, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 255, 255, 0.05)"
                >
                  <Box fontWeight="bold">{member}</Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No members listed.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Political Relationships">
            <Flex>
              <Flex.Item width="50%">
                <Box fontWeight="bold" mb={1}>
                  Allies:
                </Box>
                {department.allies?.length > 0 ? (
                  department.allies.map((ally, index) => (
                    <Box
                      key={index}
                      fontSize="0.9em"
                      color="rgba(0, 255, 0, 0.7)"
                    >
                      ΓÇó {ally}
                    </Box>
                  ))
                ) : (
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.5)">
                    No allies.
                  </Box>
                )}
              </Flex.Item>
              <Flex.Item width="50%">
                <Box fontWeight="bold" mb={1}>
                  Rivals:
                </Box>
                {department.rivals?.length > 0 ? (
                  department.rivals.map((rival, index) => (
                    <Box
                      key={index}
                      fontSize="0.9em"
                      color="rgba(255, 0, 0, 0.7)"
                    >
                      ΓÇó {rival}
                    </Box>
                  ))
                ) : (
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.5)">
                    No rivals.
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

const FactionsTab = ({ factions, selectedFaction, setSelectedFaction }) => {
  const { act } = useBackend();

  return (
    <Flex>
      <Flex.Item width="40%">
        <Section title="Factions">
          {Object.entries(factions || {}).map(([faction_id, faction]) => (
            <Box
              key={faction_id}
              p={1}
              mb={1}
              backgroundColor={
                selectedFaction?.faction_id === faction_id
                  ? 'rgba(0, 255, 0, 0.1)'
                  : 'rgba(255, 255, 255, 0.05)'
              }
              onClick={() => setSelectedFaction(faction)}
              style={{ cursor: 'pointer' }}
            >
              <Box fontWeight="bold">{faction.name}</Box>
              <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                {faction.type} ΓÇó {faction.membership || 0} members
              </Box>
              <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                {faction.influence}/100 influence
              </Box>
            </Box>
          ))}
        </Section>
      </Flex.Item>

      <Flex.Item width="60%">
        {selectedFaction ? (
          <FactionDetailView faction={selectedFaction} />
        ) : (
          <Section title="Faction Details">
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              Select a faction to view details.
            </Box>
          </Section>
        )}
      </Flex.Item>
    </Flex>
  );
};

const FactionDetailView = ({ faction }) => {
  const { act } = useBackend();

  return (
    <Section title={faction.name}>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Type">{faction.type}</LabeledList.Item>
            <LabeledList.Item label="Leader">{faction.leader}</LabeledList.Item>
            <LabeledList.Item label="Membership">
              {faction.membership || 0}
            </LabeledList.Item>
            <LabeledList.Item label="Influence">
              {faction.influence}/100
            </LabeledList.Item>
          </LabeledList>
          <ProgressBar
            value={faction.influence}
            maxValue={100}
            color={
              faction.influence > 70
                ? 'good'
                : faction.influence > 40
                  ? 'average'
                  : 'bad'
            }
            mt={1}
          />
        </Stack.Item>

        <Stack.Item>
          <Section title="Ideology">
            <Box>{faction.ideology || 'No ideology defined.'}</Box>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Faction Goals">
            {faction.goals?.length > 0 ? (
              faction.goals.map((goal, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(0, 255, 0, 0.1)"
                >
                  <Box fontWeight="bold">{goal}</Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No goals defined.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Recent Activities">
            {faction.activities?.length > 0 ? (
              faction.activities.slice(-5).map((activity, index) => (
                <Box
                  key={index}
                  mb={1}
                  p={1}
                  backgroundColor="rgba(255, 255, 255, 0.05)"
                >
                  <Box fontWeight="bold">{activity.type}</Box>
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                    {activity.description}
                  </Box>
                  <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                    {new Date(activity.timestamp * 1000).toLocaleDateString()}
                  </Box>
                </Box>
              ))
            ) : (
              <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
                No recent activities.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Political Relationships">
            <Flex>
              <Flex.Item width="50%">
                <Box fontWeight="bold" mb={1}>
                  Allies:
                </Box>
                {faction.allies?.length > 0 ? (
                  faction.allies.map((ally, index) => (
                    <Box
                      key={index}
                      fontSize="0.9em"
                      color="rgba(0, 255, 0, 0.7)"
                    >
                      ΓÇó {ally}
                    </Box>
                  ))
                ) : (
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.5)">
                    No allies.
                  </Box>
                )}
              </Flex.Item>
              <Flex.Item width="50%">
                <Box fontWeight="bold" mb={1}>
                  Enemies:
                </Box>
                {faction.enemies?.length > 0 ? (
                  faction.enemies.map((enemy, index) => (
                    <Box
                      key={index}
                      fontSize="0.9em"
                      color="rgba(255, 0, 0, 0.7)"
                    >
                      ΓÇó {enemy}
                    </Box>
                  ))
                ) : (
                  <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.5)">
                    No enemies.
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

const PowerStructuresTab = ({ power_structures }) => {
  return (
    <Section title="Power Structures">
      {Object.entries(power_structures || {}).map(
        ([structure_id, structure]) => (
          <Box
            key={structure_id}
            mb={2}
            p={2}
            backgroundColor="rgba(255, 255, 255, 0.05)"
          >
            <Flex justify="space-between" align="center">
              <Flex.Item>
                <Box fontWeight="bold">{structure.name}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  Type: {structure.type} ΓÇó Leader: {structure.leader}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {structure.members?.length || 0} members
                </Box>
              </Flex.Item>
              <Flex.Item>
                <ProgressBar
                  value={structure.influence}
                  maxValue={100}
                  color={
                    structure.influence > 70
                      ? 'good'
                      : structure.influence > 40
                        ? 'average'
                        : 'bad'
                  }
                />
                <Box fontSize="0.8em" textAlign="center">
                  {structure.influence}/100 Influence
                </Box>
              </Flex.Item>
            </Flex>

            <Box mt={1}>
              <Box fontWeight="bold" fontSize="0.9em">
                Members:
              </Box>
              <Flex wrap>
                {structure.members?.map((member, index) => (
                  <Flex.Item key={index} mr={1} mb={1}>
                    <Box
                      p={0.5}
                      backgroundColor="rgba(0, 255, 0, 0.1)"
                      borderRadius="4px"
                      fontSize="0.8em"
                    >
                      {member}
                    </Box>
                  </Flex.Item>
                ))}
              </Flex>
            </Box>

            <Box mt={1}>
              <Box fontWeight="bold" fontSize="0.9em">
                Policies:
              </Box>
              <Flex wrap>
                {structure.policies?.map((policy, index) => (
                  <Flex.Item key={index} mr={1} mb={1}>
                    <Box
                      p={0.5}
                      backgroundColor="rgba(255, 215, 0, 0.1)"
                      borderRadius="4px"
                      fontSize="0.8em"
                    >
                      {policy}
                    </Box>
                  </Flex.Item>
                ))}
              </Flex>
            </Box>
          </Box>
        ),
      )}
    </Section>
  );
};

const PoliticalEventsTab = ({ events }) => {
  return (
    <Section title="Political Events">
      {events?.length > 0 ? (
        events.map((event, index) => (
          <Box
            key={event.event_id}
            mb={2}
            p={2}
            backgroundColor="rgba(255, 255, 255, 0.05)"
          >
            <Box fontWeight="bold">{event.event_title}</Box>
            <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
              Type: {event.event_type} ΓÇó Impact: {event.event_impact}
            </Box>
            <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
              {event.event_description}
            </Box>
            <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
              Created:{' '}
              {new Date(event.event_creation_date * 1000).toLocaleDateString()}
            </Box>
            {event.event_outcome && (
              <Box fontSize="0.9em" color="rgba(0, 255, 0, 0.7)">
                Outcome: {event.event_outcome}
              </Box>
            )}
          </Box>
        ))
      ) : (
        <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
          No political events recorded.
        </Box>
      )}
    </Section>
  );
};

const ConflictsTab = ({ conflicts, alliances }) => {
  return (
    <Flex>
      <Flex.Item width="50%">
        <Section title="Active Conflicts">
          {conflicts?.length > 0 ? (
            conflicts.map((conflict, index) => (
              <Box
                key={conflict.conflict_id}
                mb={2}
                p={2}
                backgroundColor="rgba(255, 0, 0, 0.1)"
              >
                <Box fontWeight="bold">{conflict.conflict_title}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  Type: {conflict.conflict_type} ΓÇó Severity:{' '}
                  {conflict.conflict_severity}/10
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {conflict.conflict_description}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  Parties: {conflict.conflict_parties?.join(', ')}
                </Box>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              No active conflicts.
            </Box>
          )}
        </Section>
      </Flex.Item>

      <Flex.Item width="50%">
        <Section title="Active Alliances">
          {alliances?.length > 0 ? (
            alliances.map((alliance, index) => (
              <Box
                key={alliance.alliance_id}
                mb={2}
                p={2}
                backgroundColor="rgba(0, 255, 0, 0.1)"
              >
                <Box fontWeight="bold">{alliance.alliance_name}</Box>
                <Box fontSize="0.9em" color="rgba(255, 255, 255, 0.7)">
                  Type: {alliance.alliance_type} ΓÇó Strength:{' '}
                  {alliance.alliance_strength}/100
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  {alliance.alliance_description}
                </Box>
                <Box fontSize="0.8em" color="rgba(255, 255, 255, 0.5)">
                  Members: {alliance.alliance_members?.join(', ')}
                </Box>
              </Box>
            ))
          ) : (
            <Box textAlign="center" color="rgba(255, 255, 255, 0.5)">
              No active alliances.
            </Box>
          )}
        </Section>
      </Flex.Item>
    </Flex>
  );
};
