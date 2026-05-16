import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Input, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type ContagionEntry = {
  carrier_name: string;
  carrier_ckey: string;
  contagion_type: string;
  spread_count: number;
  active: BooleanLike;
};

type QuarantineZone = {
  area_name: string;
  reason: string;
  declared_time: number;
};

type ExposureEntry = {
  contagion_type: string;
  exposure_time: number;
  source: string;
};

type ExposureChain = {
  ckey: string;
  exposures: ExposureEntry[];
};

type ContagionData = {
  contagions: ContagionEntry[];
  quarantine_zones: QuarantineZone[];
  exposure_chains: ExposureChain[];
  time: number;
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderAmber: '#6b5000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const timeAgo = (ts: number, now: number) => {
  const diff = Math.max(0, Math.floor((now - ts) / 10));
  if (diff < 60) return `${diff}s ago`;
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  return `${Math.floor(diff / 3600)}h ago`;
};

export const ContagionConsole = (props) => {
  const { act, data } = useBackend<ContagionData>();
  const { contagions, quarantine_zones, exposure_chains, time } = data;
  const [tab, setTab] = useState(0);
  const [quarantineReason, setQuarantineReason] = useState('');

  return (
    <Window theme="scp_terminal" width={550} height={560}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderAmber}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderAmber}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #0e0c02 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '2px',
              }}
            >
              CONTAGION MONITOR
            </Box>
            <Box style={{ fontSize: '10px', color: C.textDim, marginTop: '2px' }}>
              MEDICAL DIVISION — BIOHAZARD TRACKING SYSTEM
            </Box>
          </Box>

          <Tabs
            fluid
            style={{
              background: C.panel,
              borderBottom: `1px solid ${C.border}`,
              padding: '0 8px',
              fontSize: '11px',
            }}
          >
            <Tabs.Tab
              selected={tab === 0}
              onClick={() => setTab(0)}
              color={tab === 0 ? 'yellow' : 'grey'}
            >
              CONTAGIONS ({contagions.length})
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === 1}
              onClick={() => setTab(1)}
              color={tab === 1 ? 'yellow' : 'grey'}
            >
              QUARANTINES ({quarantine_zones.length})
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === 2}
              onClick={() => setTab(2)}
              color={tab === 2 ? 'yellow' : 'grey'}
            >
              EXPOSURES ({exposure_chains.length})
            </Tabs.Tab>
          </Tabs>

          {tab === 0 && (
            <Box style={{ padding: '8px 14px' }}>
              {contagions.length === 0 && (
                <Box
                  style={{
                    textAlign: 'center',
                    padding: '24px 0',
                    color: C.greenBright,
                    fontSize: '11px',
                  }}
                >
                  NO ACTIVE CONTAGIONS DETECTED
                </Box>
              )}
              {contagions.map((c, i) => (
                <Box
                  key={i}
                  style={{
                    background: C.panel,
                    border: `1px solid ${c.active ? C.red : C.border}`,
                    borderRadius: '2px',
                    padding: '6px 10px',
                    marginBottom: '4px',
                  }}
                >
                  <Stack>
                    <Stack.Item grow>
                      <Box style={{ color: C.textBright, fontSize: '11px' }}>
                        {c.carrier_name}
                      </Box>
                      <Box style={{ color: C.textDim, fontSize: '10px' }}>
                        {c.contagion_type} | Spread: {c.spread_count}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box
                        style={{
                          color: c.active ? C.redBright : C.textDim,
                          fontSize: '10px',
                          fontWeight: 'bold',
                        }}
                      >
                        {c.active ? 'ACTIVE' : 'INACTIVE'}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Box>
          )}

          {tab === 1 && (
            <Box style={{ padding: '8px 14px' }}>
              <Box
                style={{
                  background: C.panel,
                  border: `1px solid ${C.border}`,
                  borderRadius: '2px',
                  padding: '8px 10px',
                  marginBottom: '8px',
                }}
              >
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.amber,
                    fontWeight: 'bold',
                    marginBottom: '6px',
                  }}
                >
                  DECLARE QUARANTINE (CURRENT AREA)
                </Box>
                <Stack>
                  <Stack.Item grow>
                    <Input
                      fluid
                      value={quarantineReason}
                      onInput={(_, value) => setQuarantineReason(value)}
                      placeholder="Reason..."
                      fontSize="11px"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      content="DECLARE"
                      fontSize="10px"
                      color="red"
                      onClick={() =>
                        act('declare_quarantine', {
                          reason: quarantineReason || 'Contagion risk detected',
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Box>

              {quarantine_zones.length === 0 && (
                <Box
                  style={{
                    textAlign: 'center',
                    padding: '16px 0',
                    color: C.textDim,
                    fontSize: '11px',
                  }}
                >
                  NO ACTIVE QUARANTINE ZONES
                </Box>
              )}
              {quarantine_zones.map((z, i) => (
                <Box
                  key={i}
                  style={{
                    background: C.panel,
                    border: `1px solid ${C.amber}`,
                    borderRadius: '2px',
                    padding: '6px 10px',
                    marginBottom: '4px',
                  }}
                >
                  <Stack>
                    <Stack.Item grow>
                      <Box
                        style={{ color: C.amber, fontSize: '11px', fontWeight: 'bold' }}
                      >
                        {z.area_name}
                      </Box>
                      <Box style={{ color: C.textDim, fontSize: '10px' }}>
                        {z.reason} — {timeAgo(z.declared_time, time)}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="LIFT"
                        fontSize="10px"
                        color="green"
                        onClick={() => act('lift_quarantine')}
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Box>
          )}

          {tab === 2 && (
            <Box style={{ padding: '8px 14px' }}>
              {exposure_chains.length === 0 && (
                <Box
                  style={{
                    textAlign: 'center',
                    padding: '24px 0',
                    color: C.textDim,
                    fontSize: '11px',
                  }}
                >
                  NO EXPOSURE DATA RECORDED
                </Box>
              )}
              {exposure_chains.map((chain, i) => (
                <Box
                  key={i}
                  style={{
                    background: C.panel,
                    border: `1px solid ${C.border}`,
                    borderRadius: '2px',
                    padding: '6px 10px',
                    marginBottom: '4px',
                  }}
                >
                  <Stack>
                    <Stack.Item grow>
                      <Box style={{ color: C.textBright, fontSize: '11px' }}>
                        {chain.ckey}
                      </Box>
                      {chain.exposures.map((e, j) => (
                        <Box
                          key={j}
                          style={{ color: C.textDim, fontSize: '10px', paddingLeft: '8px' }}
                        >
                          {e.contagion_type} from {e.source} —{' '}
                          {timeAgo(e.exposure_time, time)}
                        </Box>
                      ))}
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="DETAILS"
                        fontSize="10px"
                        onClick={() =>
                          act('view_exposure_chain', { ckey: chain.ckey })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
              <Box style={{ marginTop: '8px' }}>
                <Button
                  fluid
                  content="REQUEST SCP-500 REQUISITION"
                  icon="prescription-bottle"
                  fontSize="10px"
                  color="green"
                  onClick={() => act('order_scp500')}
                />
              </Box>
            </Box>
          )}

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '6px 14px',
              fontSize: '9px',
              color: C.textDim,
              textAlign: 'center',
            }}
          >
            SCP FOUNDATION — MEDICAL DIVISION — CONTAGION TRACKING v1.7
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
