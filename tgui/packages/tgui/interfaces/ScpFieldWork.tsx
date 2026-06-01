import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Tabs, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Material = {
  item_name: string;
  source: string;
  containment_class: string;
};

type MaintenanceTask = {
  task_id: string;
  zone: string;
  reason: string;
  status: number;
  assigned_engineer: string;
};

type PatrolRoute = {
  route_id: string;
  name: string;
  zone: string;
  threat_level: number;
  description: string;
};

type Data = {
  is_researcher: BooleanLike;
  is_archaeologist: BooleanLike;
  is_miner: BooleanLike;
  user_job: string;
  user_ckey: string;
  anomalous_materials: Material[];
  containment_zones: object[];
  maintenance_tasks: MaintenanceTask[];
  specimen_kit_available: BooleanLike;
  patrol_routes: PatrolRoute[];
};

export const ScpFieldWork = (_props) => {
  const { act, data } = useBackend<Data>();

  const [selectedTab, setSelectedTab] = useLocalState<string>(
    'fieldTab',
    'overview',
  );

  const {
    is_researcher,
    is_archaeologist,
    is_miner,
    user_job,
    anomalous_materials,
    maintenance_tasks,
    patrol_routes,
  } = data;

  return (
    <NtosWindow width={550} height={600}>
      <NtosWindow.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={selectedTab === 'overview'}
            onClick={() => setSelectedTab('overview')}
          >
            Overview
          </Tabs.Tab>
          {is_archaeologist && (
            <Tabs.Tab
              selected={selectedTab === 'artifacts'}
              onClick={() => setSelectedTab('artifacts')}
            >
              Artifacts
            </Tabs.Tab>
          )}
          {is_miner && (
            <Tabs.Tab
              selected={selectedTab === 'mining'}
              onClick={() => setSelectedTab('mining')}
            >
              Mining
            </Tabs.Tab>
          )}
          {is_researcher && (
            <Tabs.Tab
              selected={selectedTab === 'specimens'}
              onClick={() => setSelectedTab('specimens')}
            >
              Specimens
            </Tabs.Tab>
          )}
          <Tabs.Tab
            selected={selectedTab === 'maintenance'}
            onClick={() => setSelectedTab('maintenance')}
          >
            Maintenance
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'patrol'}
            onClick={() => setSelectedTab('patrol')}
          >
            Patrol
          </Tabs.Tab>
        </Tabs>

        {selectedTab === 'overview' && (
          <Section title="Field Work Terminal">
            <Box mb={1} color="label">
              Assigned Role: {user_job || 'Unknown'}
            </Box>
            <Box mb={1} color="label">
              Logged Anomalous Materials:{' '}
              {(anomalous_materials || []).length}
            </Box>
            <Box mb={1} color="label">
              Available Maintenance Tasks:{' '}
              {(maintenance_tasks || []).length}
            </Box>
            <Box color="label">
              Available Patrol Routes: {(patrol_routes || []).length}
            </Box>
          </Section>
        )}

        {selectedTab === 'artifacts' && (
          <ArtifactLogging act={act} materials={anomalous_materials} />
        )}

        {selectedTab === 'mining' && (
          <MiningOperations act={act} materials={anomalous_materials} />
        )}

        {selectedTab === 'specimens' && (
          <SpecimenTracking act={act} materials={anomalous_materials} />
        )}

        {selectedTab === 'maintenance' && (
          <MaintenancePanel act={act} tasks={maintenance_tasks} />
        )}

        {selectedTab === 'patrol' && (
          <PatrolPanel act={act} routes={patrol_routes} />
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const ArtifactLogging = ({ act, materials }) => {
  const [artifactName, setArtifactName] = useLocalState<string>(
    'artName',
    '',
  );
  const [artifactSource, setArtifactSource] = useLocalState<string>(
    'artSource',
    '',
  );
  const [artifactClass, setArtifactClass] = useLocalState<string>(
    'artClass',
    'Safe',
  );

  return (
    <Section title="Artifact Logging">
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Artifact Name:
        </Box>
        <TextArea
          value={artifactName}
          onInput={(_, value) => setArtifactName(value)}
          height="40px"
          width="100%"
        />
      </Box>
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Recovery Source:
        </Box>
        <TextArea
          value={artifactSource}
          onInput={(_, value) => setArtifactSource(value)}
          height="40px"
          width="100%"
        />
      </Box>
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Containment Class:
        </Box>
        {['Safe', 'Euclid', 'Keter'].map((cls) => (
          <Button
            key={cls}
            selected={artifactClass === cls}
            onClick={() => setArtifactClass(cls)}
          >
            {cls}
          </Button>
        ))}
      </Box>
      <Button
        fluid
        onClick={() => {
          act('log_artifact', {
            item_name: artifactName,
            source: artifactSource,
            containment_class: artifactClass,
          });
          setArtifactName('');
          setArtifactSource('');
        }}
      >
        Log Artifact (+25 Research)
      </Button>
      {(materials || []).length > 0 && (
        <Section title="Recent Materials" mt={1}>
          {materials.slice(-5).map((m, i) => (
            <Box key={i} color="label">
              {m.item_name} ({m.containment_class}) — {m.source}
            </Box>
          ))}
        </Section>
      )}
    </Section>
  );
};

const MiningOperations = ({ act, materials }) => {
  const [mineralName, setMineralName] = useLocalState<string>(
    'minName',
    '',
  );
  const [mineralSource, setMineralSource] = useLocalState<string>(
    'minSource',
    '',
  );

  return (
    <Section title="Mining Operations">
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Mineral Sample Name:
        </Box>
        <TextArea
          value={mineralName}
          onInput={(_, value) => setMineralName(value)}
          height="40px"
          width="100%"
        />
      </Box>
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Extraction Source:
        </Box>
        <TextArea
          value={mineralSource}
          onInput={(_, value) => setMineralSource(value)}
          height="40px"
          width="100%"
        />
      </Box>
      <Button
        fluid
        onClick={() => {
          act('log_mineral_sample', {
            item_name: mineralName,
            source: mineralSource,
          });
          setMineralName('');
          setMineralSource('');
        }}
      >
        Log Mineral Sample (+15 Research)
      </Button>
      <Button fluid onClick={() => act('submit_supply_request', {})}>
        Request Mining Equipment
      </Button>
    </Section>
  );
};

const SpecimenTracking = ({ act, materials }) => (
  <Section title="Specimen Tracking">
    <Button fluid onClick={() => act('submit_supply_request', {})}>
      Request Specimen Supplies
    </Button>
    {(materials || []).length > 0 && (
      <Section title="Recent Specimens" mt={1}>
        {materials.slice(-8).map((m, i) => (
          <Box key={i} color="label">
            {m.item_name} ({m.containment_class})
          </Box>
        ))}
      </Section>
    )}
  </Section>
);

const MaintenancePanel = ({ act, tasks }) => (
  <Section title="Maintenance Tasks">
    {(tasks || []).length > 0 ? (
      tasks.map((task) => (
        <Box key={task.task_id} mb={1}>
          <Box color="label">
            [{task.zone}] {task.reason}
          </Box>
          <Button
            onClick={() => act('self_assign_maintenance', { task_id: task.task_id })}
            disabled={task.status === 2}
          >
            {task.status === 2 ? 'In Progress' : 'Self-Assign'}
          </Button>
          {task.status === 2 && (
            <Button
              onClick={() =>
                act('complete_maintenance', {
                  task_id: task.task_id,
                  repair_amount: 5,
                })
              }
            >
              Complete (+10 Research)
            </Button>
          )}
        </Box>
      ))
    ) : (
      <Box color="label">No maintenance tasks available.</Box>
    )}
  </Section>
);

const PatrolPanel = ({ act, routes }) => {
  const [reportText, setReportText] = useLocalState<string>(
    'patrolReport',
    '',
  );

  return (
    <Section title="Patrol Operations">
      {(routes || []).length > 0 && (
        <Box mb={1}>
          <Box color="label" mb={0.5}>
            Available Routes:
          </Box>
          {routes.map((route) => (
            <Box key={route.route_id} mb={0.5}>
              <Button
                onClick={() =>
                  act('accept_patrol', { route_id: route.route_id })
                }
              >
                {route.name} (Threat: {route.threat_level})
              </Button>
            </Box>
          ))}
        </Box>
      )}
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Submit Shift Report:
        </Box>
        <TextArea
          value={reportText}
          onInput={(_, value) => setReportText(value)}
          height="80px"
          width="100%"
        />
        <Button
          fluid
          mt={0.5}
          onClick={() => {
            act('submit_shift_report', { report_text: reportText });
            setReportText('');
          }}
        >
          Submit Report (+8 Research)
        </Button>
      </Box>
      <Box>
        <Box color="label" mb={0.5}>
          Quick Incident Response:
        </Box>
        <Button onClick={() => act('respond_to_incident', { incident_type: 'containment_breach', zone: 'LCZ' })}>
          Breach — LCZ (+15)
        </Button>
        <Button onClick={() => act('respond_to_incident', { incident_type: 'containment_breach', zone: 'HCZ' })}>
          Breach — HCZ (+15)
        </Button>
        <Button onClick={() => act('respond_to_incident', { incident_type: 'unauthorized_access', zone: 'EZ' })}>
          Intruder — EZ (+15)
        </Button>
      </Box>
    </Section>
  );
};
