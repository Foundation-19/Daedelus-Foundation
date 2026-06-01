import { useState } from 'react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  red: '#8b0000',
  darkRed: '#5c0000',
  amber: '#d4a017',
  green: '#0a6e0a',
  brightGreen: '#44ff44',
  text: '#c8c8c8',
  dim: '#6a6a70',
  highlight: '#e8e8e8',
};

const MAINT_STATUS = ['NONE', 'SCHEDULED', 'IN PROGRESS', 'COMPLETE', 'OVERDUE'];

const integrityColor = (integrity: number): string => {
  if (integrity > 75) return C.brightGreen;
  if (integrity > 50) return C.amber;
  if (integrity > 25) return '#cc6600';
  return C.red;
};

type Data = {
  zones: Array<{
    name: string;
    area_type: string;
    integrity: number;
    decay_rate: number;
    last_maintained: number;
    maintenance_status: number;
    breached: BooleanLike;
    reinforced: BooleanLike;
  }>;
  maintenance_tasks: Array<{
    task_id: string;
    zone: string;
    reason: string;
    status: number;
    assigned_to: string;
    time_created: number;
  }>;
  overall_integrity: number;
  total_breach_repairs: number;
  total_maintenance: number;
  overdue_tasks: number;
  integrity_log: string[];
};

export const ScpContainmentIntegrity = (_props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [reasonInput, setReasonInput] = useLocalState<Record<string, string>>(
    context,
    'reasonInput',
    {}
  );

  const {
    zones,
    maintenance_tasks,
    overall_integrity,
    total_breach_repairs,
    total_maintenance,
    overdue_tasks,
    integrity_log,
  } = data;

  return (
    <NtosWindow title="Containment Integrity Monitor" width={700} height={700} >
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="CONTAINMENT INTEGRITY MONITOR"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                color: C.text,
                fontFamily: 'monospace',
              }}
            >
              <Stack>
                <Stack.Item grow>
                  <Box style={{ fontFamily: 'monospace', color: C.dim, fontSize: '11px' }}>
                    OVERALL INTEGRITY
                  </Box>
                  <Box
                    style={{
                      fontFamily: 'monospace',
                      fontSize: '28px',
                      fontWeight: 'bold',
                      color: integrityColor(overall_integrity),
                    }}
                  >
                    {overall_integrity}%
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box style={{ fontFamily: 'monospace', color: C.dim, fontSize: '11px' }}>
                    TOTAL BREACH REPAIRS
                  </Box>
                  <Box
                    style={{
                      fontFamily: 'monospace',
                      fontSize: '22px',
                      color: C.highlight,
                    }}
                  >
                    {total_breach_repairs}
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box style={{ fontFamily: 'monospace', color: C.dim, fontSize: '11px' }}>
                    TOTAL MAINTENANCE
                  </Box>
                  <Box
                    style={{
                      fontFamily: 'monospace',
                      fontSize: '22px',
                      color: C.highlight,
                    }}
                  >
                    {total_maintenance}
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box style={{ fontFamily: 'monospace', color: C.dim, fontSize: '11px' }}>
                    OVERDUE TASKS
                  </Box>
                  <Box
                    style={{
                      fontFamily: 'monospace',
                      fontSize: '22px',
                      color: overdue_tasks > 0 ? C.red : C.brightGreen,
                    }}
                  >
                    {overdue_tasks}
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section
              title="CONTAINMENT ZONES"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                color: C.text,
                fontFamily: 'monospace',
              }}
            >
              <Stack vertical>
                {zones.map((zone) => (
                  <Stack.Item key={zone.name}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '8px',
                        marginBottom: '4px',
                      }}
                    >
                      <Stack vertical>
                        <Stack.Item>
                          <Stack>
                            <Stack.Item grow>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  color: C.highlight,
                                  fontSize: '14px',
                                  fontWeight: 'bold',
                                }}
                              >
                                {zone.name.toUpperCase()}
                              </Box>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  color: C.dim,
                                  fontSize: '11px',
                                }}
                              >
                                {zone.area_type} | DECAY: {zone.decay_rate}/t
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              {!!zone.breached && (
                                <Box
                                  style={{
                                    fontFamily: 'monospace',
                                    background: C.darkRed,
                                    color: C.red,
                                    padding: '2px 8px',
                                    fontWeight: 'bold',
                                    fontSize: '12px',
                                    border: `1px solid ${C.red}`,
                                  }}
                                >
                                  BREACHED
                                </Box>
                              )}
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  background:
                                    zone.maintenance_status === 4
                                      ? C.darkRed
                                      : zone.maintenance_status === 2
                                        ? C.green
                                        : C.panel,
                                  color:
                                    zone.maintenance_status === 4
                                      ? C.red
                                      : zone.maintenance_status === 2
                                        ? C.brightGreen
                                        : zone.maintenance_status === 1
                                          ? C.amber
                                          : C.dim,
                                  padding: '2px 8px',
                                  fontSize: '11px',
                                  border: `1px solid ${C.border}`,
                                }}
                              >
                                {MAINT_STATUS[zone.maintenance_status] || 'NONE'}
                              </Box>
                            </Stack.Item>
                            {!!zone.reinforced && (
                              <Stack.Item>
                                <Box
                                  style={{
                                    fontFamily: 'monospace',
                                    color: C.brightGreen,
                                    fontSize: '11px',
                                  }}
                                >
                                  [REINFORCED]
                                </Box>
                              </Stack.Item>
                            )}
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack>
                            <Stack.Item grow>
                              <Box
                                style={{
                                  background: C.darkRed,
                                  height: '16px',
                                  width: '100%',
                                  border: `1px solid ${C.border}`,
                                  position: 'relative',
                                }}
                              >
                                <Box
                                  style={{
                                    background: integrityColor(zone.integrity),
                                    height: '100%',
                                    width: `${zone.integrity}%`,
                                  }}
                                />
                                <Box
                                  style={{
                                    position: 'absolute',
                                    top: 0,
                                    left: '50%',
                                    transform: 'translateX(-50%)',
                                    fontFamily: 'monospace',
                                    fontSize: '11px',
                                    color: C.highlight,
                                    lineHeight: '16px',
                                  }}
                                >
                                  {zone.integrity}%
                                </Box>
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack>
                            <Stack.Item>
                              <Button
                                content="REPAIR ZONE (+20)"
                                style={{
                                  fontFamily: 'monospace',
                                  background: C.green,
                                  color: C.brightGreen,
                                  border: `1px solid ${C.brightGreen}`,
                                  fontSize: '11px',
                                }}
                                onClick={() =>
                                  act('repair_zone', {
                                    zone: zone.name,
                                    amount: 20,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item grow>
                              <Box
                                style={{
                                  display: 'flex',
                                  alignItems: 'center',
                                  gap: '4px',
                                }}
                              >
                                <input
                                  type="text"
                                  placeholder="Reason..."
                                  value={reasonInput[zone.name] || ''}
                                  onChange={(e) =>
                                    setReasonInput({
                                      ...reasonInput,
                                      [zone.name]: e.target.value,
                                    })
                                  }
                                  style={{
                                    fontFamily: 'monospace',
                                    background: C.bg,
                                    color: C.text,
                                    border: `1px solid ${C.border}`,
                                    padding: '2px 6px',
                                    fontSize: '11px',
                                    width: '100%',
                                    outline: 'none',
                                  }}
                                />
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                content="GENERATE TASK"
                                style={{
                                  fontFamily: 'monospace',
                                  background: C.panel,
                                  color: C.amber,
                                  border: `1px solid ${C.amber}`,
                                  fontSize: '11px',
                                }}
                                onClick={() =>
                                  act('generate_task', {
                                    zone: zone.name,
                                    reason: reasonInput[zone.name] || '',
                                  })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section
              title="MAINTENANCE TASKS"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                color: C.text,
                fontFamily: 'monospace',
              }}
            >
              <Stack vertical>
                {maintenance_tasks.map((task) => (
                  <Stack.Item key={task.task_id}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '6px 8px',
                        marginBottom: '4px',
                      }}
                    >
                      <Stack>
                        <Stack.Item basis="25%">
                          <Box
                            style={{
                              fontFamily: 'monospace',
                              color: C.highlight,
                              fontSize: '12px',
                            }}
                          >
                            {task.task_id}
                          </Box>
                        </Stack.Item>
                        <Stack.Item basis="18%">
                          <Box
                            style={{
                              fontFamily: 'monospace',
                              color: C.text,
                              fontSize: '12px',
                            }}
                          >
                            {task.zone}
                          </Box>
                        </Stack.Item>
                        <Stack.Item grow>
                          <Box
                            style={{
                              fontFamily: 'monospace',
                              color: C.dim,
                              fontSize: '12px',
                            }}
                          >
                            {task.reason}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              fontFamily: 'monospace',
                              background:
                                task.status === 4
                                  ? C.darkRed
                                  : task.status === 2
                                    ? C.green
                                    : C.panel,
                              color:
                                task.status === 4
                                  ? C.red
                                  : task.status === 2
                                    ? C.brightGreen
                                    : task.status === 1
                                      ? C.amber
                                      : C.dim,
                              padding: '1px 6px',
                              fontSize: '11px',
                              border: `1px solid ${C.border}`,
                            }}
                          >
                            {MAINT_STATUS[task.status] || 'NONE'}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              fontFamily: 'monospace',
                              color: C.dim,
                              fontSize: '11px',
                            }}
                          >
                            {task.assigned_to || 'UNASSIGNED'}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          {task.status === 0 && (
                            <Button
                              content="ASSIGN TO ME"
                              style={{
                                fontFamily: 'monospace',
                                background: C.panel,
                                color: C.amber,
                                border: `1px solid ${C.amber}`,
                                fontSize: '11px',
                              }}
                              onClick={() =>
                                act('assign_task', { task_id: task.task_id })
                              }
                            />
                          )}
                          {task.status === 2 && (
                            <Button
                              content="COMPLETE TASK"
                              style={{
                                fontFamily: 'monospace',
                                background: C.green,
                                color: C.brightGreen,
                                border: `1px solid ${C.brightGreen}`,
                                fontSize: '11px',
                              }}
                              onClick={() =>
                                act('complete_task', {
                                  task_id: task.task_id,
                                  repair: 1,
                                })
                              }
                            />
                          )}
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
                {maintenance_tasks.length === 0 && (
                  <Stack.Item>
                    <Box
                      style={{
                        fontFamily: 'monospace',
                        color: C.dim,
                        fontSize: '12px',
                        textAlign: 'center',
                        padding: '8px',
                      }}
                    >
                      NO ACTIVE MAINTENANCE TASKS
                    </Box>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="INTEGRITY LOG"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                color: C.text,
                fontFamily: 'monospace',
              }}
            >
              <Stack vertical>
                {integrity_log.slice(0, 10).map((entry, index) => (
                  <Stack.Item key={index}>
                    <Box
                      style={{
                        fontFamily: 'monospace',
                        color: C.dim,
                        fontSize: '11px',
                        lineHeight: '16px',
                      }}
                    >
                      {entry}
                    </Box>
                  </Stack.Item>
                ))}
                {integrity_log.length === 0 && (
                  <Stack.Item>
                    <Box
                      style={{
                        fontFamily: 'monospace',
                        color: C.dim,
                        fontSize: '11px',
                        textAlign: 'center',
                      }}
                    >
                      NO LOG ENTRIES
                    </Box>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
