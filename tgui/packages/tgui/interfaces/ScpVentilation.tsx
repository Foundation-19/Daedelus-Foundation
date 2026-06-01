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

const ZONE_LABELS: Record<number, string> = {
  1: 'LCZ',
  2: 'HCZ',
  3: 'EZ',
  4: 'D-CLASS',
};

function qualityColor(value: number): string {
  if (value > 75) return C.brightGreen;
  if (value > 50) return C.amber;
  return C.red;
}

function contaminationColor(value: number): string {
  if (value <= 25) return C.brightGreen;
  if (value <= 50) return C.amber;
  return C.red;
}

function StatBar(props: {
  value: number;
  maxValue?: number;
  color: string;
  height?: string;
}) {
  const { value, maxValue = 100, color, height = '10px' } = props;
  const pct = Math.min(100, Math.max(0, (value / maxValue) * 100));
  return (
    <Box
      style={{
        border: `1px solid ${C.border}`,
        borderRadius: '2px',
        height,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          background: color,
          height: '100%',
          width: `${pct}%`,
        }}
      />
    </Box>
  );
}

export const ScpVentilation = (_props: unknown) => {
  const { act, data } = useBackend<Data>();

  const zones = data.zones || [];
  const alerts = data.alerts || [];
  const totalPurges = data.total_purges || 0;
  const totalFilters = data.total_filters || 0;
  const totalEmergency = data.total_emergency || 0;

  const [reportZone, setReportZone] = useState<number>(1);
  const [reportAmount, setReportAmount] = useState<number>(50);
  const [reportSource, setReportSource] = useState<string>('');

  return (
    <NtosWindow title="SCP Ventilation Control" width={700} height={600} >
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="ZONE VENTILATION CONTROL"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack fill>
                <Stack.Item grow basis={0}>
                  <Box color={C.dim} fontSize="11px" fontFamily="monospace">
                    PURGES
                  </Box>
                  <Box color={C.highlight} fontSize="18px" fontFamily="monospace">
                    {totalPurges}
                  </Box>
                </Stack.Item>
                <Stack.Item grow basis={0}>
                  <Box color={C.dim} fontSize="11px" fontFamily="monospace">
                    FILTERS REPLACED
                  </Box>
                  <Box color={C.highlight} fontSize="18px" fontFamily="monospace">
                    {totalFilters}
                  </Box>
                </Stack.Item>
                <Stack.Item grow basis={0}>
                  <Box color={C.dim} fontSize="11px" fontFamily="monospace">
                    EMERGENCY VENTS
                  </Box>
                  <Box color={C.highlight} fontSize="18px" fontFamily="monospace">
                    {totalEmergency}
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="VENTILATION ZONES"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack vertical>
                {zones.map((zone) => (
                  <Stack.Item key={zone.zone}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '8px',
                        borderRadius: '2px',
                      }}
                    >
                      <Stack vertical>
                        <Stack.Item>
                          <Stack fill>
                            <Stack.Item grow>
                              <Box
                                color={C.highlight}
                                fontSize="14px"
                                fontFamily="monospace"
                              >
                                {zone.name}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              {zone.purge_active && (
                                <Box
                                  inline
                                  style={{
                                    background: C.amber,
                                    color: C.bg,
                                    padding: '1px 6px',
                                    borderRadius: '2px',
                                    fontSize: '10px',
                                    fontFamily: 'monospace',
                                    fontWeight: 'bold',
                                  }}
                                >
                                  PURGE ACTIVE
                                </Box>
                              )}
                              {!!zone.emergency_vent && (
                                <Box
                                  inline
                                  ml={1}
                                  style={{
                                    background: C.red,
                                    color: C.highlight,
                                    padding: '1px 6px',
                                    borderRadius: '2px',
                                    fontSize: '10px',
                                    fontFamily: 'monospace',
                                    fontWeight: 'bold',
                                  }}
                                >
                                  EMERGENCY VENT
                                </Box>
                              )}
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>

                        <Stack.Item mt={1}>
                          <Stack fill>
                            <Stack.Item grow basis={0}>
                              <Box color={C.dim} fontSize="10px" fontFamily="monospace">
                                AIR QUALITY: {zone.air_quality}%
                              </Box>
                              <StatBar
                                value={zone.air_quality}
                                color={qualityColor(zone.air_quality)}
                              />
                            </Stack.Item>
                            <Stack.Item grow basis={0}>
                              <Box color={C.dim} fontSize="10px" fontFamily="monospace">
                                CONTAMINATION: {zone.contamination}%
                              </Box>
                              <StatBar
                                value={100 - zone.contamination}
                                color={contaminationColor(zone.contamination)}
                              />
                            </Stack.Item>
                            <Stack.Item grow basis={0}>
                              <Box color={C.dim} fontSize="10px" fontFamily="monospace">
                                FILTER: {zone.filter_integrity}%
                              </Box>
                              <StatBar
                                value={zone.filter_integrity}
                                color={qualityColor(zone.filter_integrity)}
                              />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>

                        <Stack.Item mt={1}>
                          <Stack fill>
                            <Stack.Item>
                              <Button
                                content="START PURGE"
                                color={zone.purge_active ? 'grey' : 'red'}
                                fontFamily="monospace"
                                fontSize="11px"
                                onClick={() =>
                                  act('start_purge', { zone: zone.zone })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                content="EMERGENCY VENT"
                                color={zone.emergency_vent ? 'grey' : 'red'}
                                fontFamily="monospace"
                                fontSize="11px"
                                onClick={() =>
                                  act('emergency_vent', { zone: zone.zone })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                content="REPLACE FILTER (+25)"
                                color="green"
                                fontFamily="monospace"
                                fontSize="11px"
                                onClick={() =>
                                  act('replace_filter', {
                                    zone: zone.zone,
                                    amount: 25,
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

          <Stack.Item>
            <Section
              title="AIR QUALITY ALERTS"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              {alerts.length === 0 && (
                <Box color={C.dim} fontFamily="monospace">
                  NO ACTIVE ALERTS
                </Box>
              )}
              <Stack vertical>
                {alerts.slice(0, 10).map((alert, idx) => (
                  <Stack.Item key={idx}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '6px 8px',
                        borderRadius: '2px',
                      }}
                    >
                      <Stack fill>
                        <Stack.Item grow basis={0}>
                          <Box color={C.highlight} fontSize="12px" fontFamily="monospace">
                            {alert.zone}
                          </Box>
                        </Stack.Item>
                        <Stack.Item grow basis={0}>
                          <Box
                            color={contaminationColor(alert.contamination)}
                            fontSize="12px"
                            fontFamily="monospace"
                          >
                            CONTAMINATION: {alert.contamination}%
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box color={C.dim} fontSize="12px" fontFamily="monospace">
                            T+{alert.time}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="REPORT CONTAMINATION"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack vertical>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow basis={0}>
                      <Box color={C.dim} fontSize="10px" fontFamily="monospace">
                        ZONE
                      </Box>
                      <Stack fill>
                        {[1, 2, 3, 4].map((z) => (
                          <Stack.Item key={z}>
                            <Button
                              content={ZONE_LABELS[z]}
                              color={reportZone === z ? 'red' : 'grey'}
                              fontFamily="monospace"
                              fontSize="11px"
                              onClick={() => setReportZone(z)}
                            />
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Box color={C.dim} fontSize="10px" fontFamily="monospace">
                    CONTAMINATION LEVEL: {reportAmount}%
                  </Box>
                  <Stack fill>
                    {[25, 50, 75, 100].map((v) => (
                      <Stack.Item key={v}>
                        <Button
                          content={`${v}%`}
                          color={reportAmount === v ? 'red' : 'grey'}
                          fontFamily="monospace"
                          fontSize="11px"
                          onClick={() => setReportAmount(v)}
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Box color={C.dim} fontSize="10px" fontFamily="monospace">
                    SOURCE
                  </Box>
                  <input
                    value={reportSource}
                    onChange={(e) => setReportSource(e.target.value)}
                    style={{
                      background: C.bg,
                      border: `1px solid ${C.border}`,
                      color: C.text,
                      fontFamily: 'monospace',
                      fontSize: '12px',
                      padding: '4px 8px',
                      width: '100%',
                      boxSizing: 'border-box',
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content="SUBMIT REPORT"
                    color="red"
                    fontFamily="monospace"
                    fontSize="12px"
                    onClick={() =>
                      act('report_contamination', {
                        zone: reportZone,
                        amount: reportAmount,
                        source: reportSource,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type BooleanLike = number | boolean;

type Data = {
  zones: Array<{
    name: string;
    zone: number;
    air_quality: number;
    contamination: number;
    filter_integrity: number;
    purge_active: BooleanLike;
    emergency_vent: BooleanLike;
  }>;
  alerts: Array<{
    zone: string;
    contamination: number;
    time: number;
  }>;
  total_purges: number;
  total_filters: number;
  total_emergency: number;
};
