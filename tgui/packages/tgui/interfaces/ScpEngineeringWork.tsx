import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';
import { NtosWindow } from '../layouts';

type Zone = {
  zone_name: string;
  integrity: number;
  status: string;
};

type Task = {
  task_id: string;
  zone: string;
  reason: string;
  status: number;
  assigned_engineer: string;
};

type Equipment = {
  name: string;
  id: string;
  integrity: number;
  operational: BooleanLike;
};

type Data = {
  is_senior: BooleanLike;
  is_junior: BooleanLike;
  user_job: string;
  containment_zones: Zone[];
  maintenance_tasks: Task[];
  ventilation_zones: object[];
  equipment_status: Equipment[];
  total_repairs: number;
  overall_integrity: number;
};

export const ScpEngineeringWork = (_props) => {
  const { act, data } = useBackend<Data>();

  const [selectedTab, setSelectedTab] = useLocalState<string>(
    'engiTab',
    'zones',
  );

  const {
    is_senior,
    is_junior,
    user_job,
    containment_zones,
    maintenance_tasks,
    ventilation_zones,
    equipment_status,
    total_repairs,
    overall_integrity,
  } = data;

  return (
    <NtosWindow width={550} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="Engineering Work Terminal">
          <LabeledList>
            <LabeledList.Item label="Role">
              {user_job || 'Engineer'}
            </LabeledList.Item>
            <LabeledList.Item label="Overall Integrity">
              <ProgressBar
                value={overall_integrity / 100}
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.5, 0.75],
                  bad: [-Infinity, 0.5],
                }}
              >
                {Math.round(overall_integrity)}%
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Total Repairs">
              {total_repairs}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Tabs>
          <Tabs.Tab
            selected={selectedTab === 'zones'}
            onClick={() => setSelectedTab('zones')}
          >
            Zones
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'maintenance'}
            onClick={() => setSelectedTab('maintenance')}
          >
            Maintenance
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'equipment'}
            onClick={() => setSelectedTab('equipment')}
          >
            Equipment
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'ventilation'}
            onClick={() => setSelectedTab('ventilation')}
          >
            Ventilation
          </Tabs.Tab>
        </Tabs>

        {selectedTab === 'zones' && (
          <Section title="Containment Zone Integrity">
            {(containment_zones || []).map((zone) => (
              <Box key={zone.zone_name} mb={1}>
                <LabeledList>
                  <LabeledList.Item label={zone.zone_name}>
                    <ProgressBar
                      value={(zone.integrity || 100) / 100}
                      ranges={{
                        good: [0.75, Infinity],
                        average: [0.5, 0.75],
                        bad: [-Infinity, 0.5],
                      }}
                    >
                      {Math.round(zone.integrity || 100)}% — {zone.status || 'Normal'}
                    </ProgressBar>
                  </LabeledList.Item>
                </LabeledList>
                <Button
                  mt={0.5}
                  onClick={() =>
                    act('repair_zone', {
                      zone_name: zone.zone_name,
                      repair_amount: 10,
                    })
                  }
                >
                  Repair Zone (+20 Research)
                </Button>
              </Box>
            ))}
            {is_senior && (
              <Button mt={1} onClick={() => act('request_maintenance', {})}>
                Generate Maintenance Task
              </Button>
            )}
          </Section>
        )}

        {selectedTab === 'maintenance' && (
          <Section title="Maintenance Tasks">
            {(maintenance_tasks || []).length > 0 ? (
              maintenance_tasks.map((task) => (
                <Box key={task.task_id} mb={1}>
                  <Box color="label">
                    [{task.zone}] {task.reason}
                  </Box>
                  {task.status === 1 ? (
                    <Button
                      onClick={() =>
                        act('self_assign_maintenance', {
                          task_id: task.task_id,
                        })
                      }
                    >
                      Self-Assign
                    </Button>
                  ) : (
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
              <Box color="label">No tasks available.</Box>
            )}
          </Section>
        )}

        {selectedTab === 'equipment' && (
          <Section title="Lab Equipment Status">
            {(equipment_status || []).map((equip) => (
              <Box key={equip.id} mb={1}>
                <LabeledList>
                  <LabeledList.Item label={equip.name}>
                    <ProgressBar
                      value={(equip.integrity || 0) / 100}
                      color={equip.operational ? 'good' : 'bad'}
                    >
                      {Math.round(equip.integrity || 0)}% —{' '}
                      {equip.operational ? 'Operational' : 'OFFLINE'}
                    </ProgressBar>
                  </LabeledList.Item>
                </LabeledList>
                {!equip.operational && (
                  <Button
                    mt={0.5}
                    onClick={() =>
                      act('repair_equipment', { equip_id: equip.id })
                    }
                  >
                    Repair
                  </Button>
                )}
              </Box>
            ))}
          </Section>
        )}

        {selectedTab === 'ventilation' && (
          <Section title="Ventilation Control">
            <Box color="label" mb={1}>
              Zone ventilation and filter management.
            </Box>
            {[1, 2, 3].map((zoneId) => (
              <Box key={zoneId} mb={1}>
                <LabeledList>
                  <LabeledList.Item label={`Zone ${zoneId}`}>
                    <Button
                      onClick={() => act('replace_filter', { zone_id: zoneId })}
                    >
                      Replace Filter
                    </Button>
                    <Button
                      onClick={() => act('start_purge', { zone_id: zoneId })}
                    >
                      Start Purge
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
