import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Input } from '../components';
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

const threatColor = (level) => {
  if (level <= 1) return C.green;
  if (level === 2) return C.amber;
  return C.red;
};

const zoneLabel = (zone) => {
  switch (zone) {
    case 'lcz': return 'LCZ';
    case 'hcz': return 'HCZ';
    case 'ez': return 'EZ';
    default: return zone;
  }
};

export const ScpPatrol = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    patrol_routes = [],
    active_patrols = [],
    patrol_log = [],
    anomaly_reports = [],
    guard_stats,
    total_patrols_completed,
    total_anomalies_reported,
    zone_threat_levels = {},
  } = data;

  const [anomalyType, setAnomalyType] = useState('');
  const [anomalyLocation, setAnomalyLocation] = useState('');
  const [anomalyDesc, setAnomalyDesc] = useState('');

  const userPatrol = active_patrols.length > 0 ? active_patrols[0] : null;

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack justify="space-between" align="center">
                <Stack.Item>
                  <Box fontSize="18px" fontFamily="monospace" color={C.brightGreen} bold>
                    SCP PATROL MANAGEMENT
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={2}>
                    <Box fontFamily="monospace" color={C.dim}>
                      COMPLETED: <Box as="span" color={C.highlight}>{total_patrols_completed}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      ANOMALIES: <Box as="span" color={C.red}>{total_anomalies_reported}</Box>
                    </Box>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.amber}>
                  ZONE THREAT LEVELS
                </Box>
              }
            >
              <Stack gap={2}>
                {['lcz', 'hcz', 'ez'].map((zone) => {
                  const level = zone_threat_levels[zone] || 0;
                  return (
                    <Stack.Item key={zone} grow>
                      <Box
                        fontFamily="monospace"
                        backgroundColor={C.panel}
                        border={`2px solid ${threatColor(level)}`}
                        p={1}
                        textAlign="center"
                      >
                        <Box color={C.highlight} bold>{zoneLabel(zone)}</Box>
                        <Box color={threatColor(level)} bold mt={0.5}>
                          THREAT {level}
                        </Box>
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.amber}>
                  AVAILABLE ROUTES
                </Box>
              }
            >
              {patrol_routes.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO AVAILABLE ROUTES
                </Box>
              )}
              {patrol_routes.map((route) => (
                <Box key={route.route_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item grow>
                      <Stack vertical>
                        <Stack.Item>
                          <Stack gap={1} align="center">
                            <Box fontFamily="monospace" color={C.highlight} bold>
                              {route.name}
                            </Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={threatColor(zone_threat_levels[route.zone] || route.threat_level)}
                              color={C.highlight}
                              px={1}
                              bold
                            >
                              {zoneLabel(route.zone)}
                            </Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={threatColor(route.threat_level)}
                              color={C.highlight}
                              px={1}
                              bold
                            >
                              THREAT-{route.threat_level}
                            </Box>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack gap={2}>
                            <Box fontFamily="monospace" color={C.dim}>
                              Waypoints: <Box as="span" color={C.text}>{route.waypoints}</Box>
                            </Box>
                            <Box fontFamily="monospace" color={C.amber}>
                              +{route.reward_research} RP
                            </Box>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Box fontFamily="monospace" color={C.dim} italic>
                            {route.description}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        fontFamily="monospace"
                        backgroundColor={C.green}
                        color={C.highlight}
                        content="ACCEPT"
                        disabled={!!userPatrol}
                        onClick={() => act('accept_patrol', { route_id: route.route_id })}
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color="#00b5b5">
                  ACTIVE PATROL
                </Box>
              }
            >
              {!userPatrol ? (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO ACTIVE PATROL - ACCEPT A ROUTE ABOVE
                </Box>
              ) : (
                <Stack vertical gap={1}>
                  <Stack.Item>
                    <Stack gap={1} align="center">
                      <Box fontFamily="monospace" color={C.highlight} bold>
                        {userPatrol.guard_name}
                      </Box>
                      <Box fontFamily="monospace" color={C.dim}>|</Box>
                      <Box fontFamily="monospace" color={C.amber}>
                        Route #{userPatrol.route_id}
                      </Box>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack align="center" gap={1}>
                      <Box fontFamily="monospace" color={C.dim}>Progress:</Box>
                      <Box
                        fontFamily="monospace"
                        backgroundColor={C.panel}
                        border={`1px solid ${C.border}`}
                        width="200px"
                        height="16px"
                        position="relative"
                      >
                        <Box
                          backgroundColor={C.brightGreen}
                          height="100%"
                          width={`${(userPatrol.checkpoints_visited / Math.max(userPatrol.total_checkpoints, 1)) * 100}%`}
                        />
                      </Box>
                      <Box fontFamily="monospace" color={C.text}>
                        {userPatrol.checkpoints_visited}/{userPatrol.total_checkpoints}
                      </Box>
                    </Stack>
                  </Stack.Item>
                  {userPatrol.anomalies_found > 0 && (
                    <Stack.Item>
                      <Box fontFamily="monospace" color={C.red}>
                        Anomalies Found: {userPatrol.anomalies_found}
                      </Box>
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    <Stack gap={1}>
                      <Button
                        fontFamily="monospace"
                        backgroundColor="#00b5b5"
                        color={C.bg}
                        content="VISIT CHECKPOINT"
                        onClick={() => act('visit_checkpoint')}
                      />
                      {userPatrol.checkpoints_visited >= userPatrol.total_checkpoints && (
                        <Button
                          fontFamily="monospace"
                          backgroundColor={C.brightGreen}
                          color={C.bg}
                          content="COMPLETE"
                          onClick={() => act('complete_patrol')}
                        />
                      )}
                      <Button
                        fontFamily="monospace"
                        backgroundColor={C.red}
                        color={C.highlight}
                        content="ABANDON"
                        onClick={() => act('abandon_patrol')}
                      />
                    </Stack>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.red}>
                  REPORT ANOMALY
                </Box>
              }
            >
              <Stack vertical gap={1}>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">TYPE:</Box>
                    <Stack gap={0.5}>
                      {['Breach', 'Sightings', 'Disturbance', 'Equipment', 'Unknown'].map((t) => (
                        <Button
                          key={t}
                          fontFamily="monospace"
                          backgroundColor={anomalyType === t ? C.red : C.panel}
                          color={anomalyType === t ? C.highlight : C.dim}
                          content={t.toUpperCase()}
                          fontSize="11px"
                          onClick={() => setAnomalyType(t)}
                        />
                      ))}
                    </Stack>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">LOCATION:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={anomalyLocation}
                      onInput={(_e, val) => setAnomalyLocation(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">DETAILS:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={anomalyDesc}
                      onInput={(_e, val) => setAnomalyDesc(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fontFamily="monospace"
                    backgroundColor={C.red}
                    color={C.highlight}
                    bold
                    content="REPORT ANOMALY"
                    fluid
                    onClick={() => {
                      act('report_anomaly', {
                        anomaly_type: anomalyType,
                        location: anomalyLocation,
                        description: anomalyDesc,
                      });
                      setAnomalyType('');
                      setAnomalyLocation('');
                      setAnomalyDesc('');
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.dim}>
                  ANOMALY LOG
                </Box>
              }
            >
              {anomaly_reports.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO ANOMALY REPORTS
                </Box>
              )}
              {anomaly_reports.slice(0, 10).map((report, i) => (
                <Box key={i} py={0.5} borderBottom={`1px solid ${C.border}`}>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.red} bold>{report.type}</Box>
                    <Box fontFamily="monospace" color={C.dim}>|</Box>
                    <Box fontFamily="monospace" color={C.text}>{report.location}</Box>
                    <Box fontFamily="monospace" color={C.dim}>|</Box>
                    <Box fontFamily="monospace" color={C.dim} italic>{report.description}</Box>
                    <Box fontFamily="monospace" color={C.dim} fontSize="11px" ml="auto">
                      {report.time}
                    </Box>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          {guard_stats && (
            <Stack.Item>
              <Section
                title={
                  <Box fontFamily="monospace" color={C.dim}>
                    GUARD STATISTICS
                  </Box>
                }
              >
                <Stack gap={2} wrap>
                  <Box fontFamily="monospace" color={C.dim}>
                    Patrols: <Box as="span" color={C.text}>{guard_stats.total_patrols}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Checkpoints: <Box as="span" color={C.brightGreen}>{guard_stats.total_checkpoints}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Anomalies: <Box as="span" color={C.red}>{guard_stats.total_anomalies}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Breach Responses: <Box as="span" color={C.amber}>{guard_stats.total_breach_responses}</Box>
                  </Box>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
