import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Dropdown, Section, Stack } from '../components';
import { Window } from '../layouts';

type SquadData = {
  squad_name: string;
  leader: string;
  member_count: number;
  formation: string;
  objective: string;
  target_scp: string;
  engagement_protocol: string;
  status: string;
};

type TacticalData = {
  squads: SquadData[];
  formations: string[];
  objectives: string[];
  protocols: string[];
  scp_targets: string[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  blue: '#2244aa',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const formationLabel = (f: string) =>
  f.charAt(0).toUpperCase() + f.slice(1);
const objectiveLabel = (o: string) => o.toUpperCase();
const protocolColor = (p: string) => {
  if (p === 'lethal') return C.redBright;
  if (p === 'capture') return C.amber;
  if (p === 'observe') return C.green;
  return C.text;
};
const protocolLabel = (p: string) => p.toUpperCase();
const statusColor = (s: string) => {
  if (s === 'deployed') return C.greenBright;
  if (s === 'engaged') return C.redBright;
  if (s === 'extracting') return C.amber;
  return C.textDim;
};

const SquadCard = (props: { squad: SquadData; formations: string[]; objectives: string[]; scpTargets: string[]; act: (action: string, params?: Record<string, string>) => void }) => {
  const { squad, formations, objectives, scpTargets, act } = props;
  const [expanded, setExpanded] = useState(false);

  return (
    <Box
      style={{
        background: C.panel,
        border: `1px solid ${C.border}`,
        borderRadius: '2px',
        marginBottom: '6px',
      }}
    >
      <Stack
        onClick={() => setExpanded(!expanded)}
        style={{ cursor: 'pointer', padding: '8px 10px' }}
      >
        <Stack.Item grow>
          <Box style={{ color: C.textBright, fontSize: '12px', fontWeight: 'bold' }}>
            {squad.squad_name}
          </Box>
          <Box style={{ color: C.textDim, fontSize: '10px' }}>
            Leader: {squad.leader} | Members: {squad.member_count} |{' '}
            <Box as="span" style={{ color: statusColor(squad.status) }}>
              {squad.status.toUpperCase()}
            </Box>
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            style={{
              color: protocolColor(squad.engagement_protocol),
              fontSize: '10px',
              fontWeight: 'bold',
            }}
          >
            {protocolLabel(squad.engagement_protocol)}
          </Box>
        </Stack.Item>
      </Stack>

      {expanded && (
        <Box
          style={{
            borderTop: `1px solid ${C.border}`,
            padding: '8px 10px',
          }}
        >
          <Stack vertical gap={1}>
            <Stack.Item>
              <Box style={{ fontSize: '10px', color: C.textDim, marginBottom: '4px' }}>
                FORMATION
              </Box>
              <Stack>
                {formations.map((f) => (
                  <Stack.Item key={f}>
                    <Button
                      content={formationLabel(f)}
                      fontSize="10px"
                      selected={squad.formation === f}
                      color={squad.formation === f ? 'green' : 'default'}
                      onClick={() =>
                        act('set_formation', {
                          squad_name: squad.squad_name,
                          formation: f,
                        })
                      }
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>

            <Stack.Item>
              <Box style={{ fontSize: '10px', color: C.textDim, marginBottom: '4px' }}>
                OBJECTIVE
              </Box>
              <Stack>
                {objectives.map((o) => (
                  <Stack.Item key={o}>
                    <Button
                      content={objectiveLabel(o)}
                      fontSize="10px"
                      selected={squad.objective === o}
                      color={squad.objective === o ? 'green' : 'default'}
                      onClick={() =>
                        act('set_objective', {
                          squad_name: squad.squad_name,
                          objective: o,
                        })
                      }
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>

            <Stack.Item>
              <Box style={{ fontSize: '10px', color: C.textDim, marginBottom: '4px' }}>
                SCP TARGET / ENGAGEMENT PROTOCOL
              </Box>
              <Stack align="center">
                <Stack.Item grow>
                  <Dropdown
                    options={scpTargets}
                    selected={squad.target_scp}
                    onSelected={(value: string) =>
                      act('assign_protocol', {
                        squad_name: squad.squad_name,
                        scp_target: value,
                      })
                    }
                    width="100%"
                    color="default"
                    fontSize="11px"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box
                    style={{
                      color: protocolColor(squad.engagement_protocol),
                      fontSize: '10px',
                      fontWeight: 'bold',
                      padding: '0 6px',
                    }}
                  >
                    {protocolLabel(squad.engagement_protocol)}
                  </Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    content="DEPLOY"
                    icon="arrow-right"
                    fontSize="10px"
                    color="green"
                    onClick={() =>
                      act('deploy_squad', { squad_name: squad.squad_name })
                    }
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    content="EXTRACT"
                    icon="arrow-left"
                    fontSize="10px"
                    color="red"
                    onClick={() =>
                      act('extract_squad', { squad_name: squad.squad_name })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Box>
      )}
    </Box>
  );
};

export const MTFTacticalConsole = (props) => {
  const { act, data } = useBackend<TacticalData>();
  const { squads, formations, objectives, scp_targets } = data;

  return (
    <Window theme="scp_terminal" width={560} height={600}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.blue}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.blue}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #060812 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: '#4488ff',
                letterSpacing: '2px',
              }}
            >
              MTF TACTICAL COMMAND
            </Box>
            <Box style={{ fontSize: '10px', color: C.textDim, marginTop: '2px' }}>
              MOBILE TASK FORCE DEPLOYMENT & ENGAGEMENT SYSTEM
            </Box>
          </Box>

          <Box style={{ padding: '10px 14px' }}>
            {squads.length === 0 && (
              <Box
                style={{
                  textAlign: 'center',
                  padding: '30px 0',
                  color: C.textDim,
                  fontSize: '11px',
                }}
              >
                NO ACTIVE SQUADS — AWAITING DEPLOYMENT ORDERS
              </Box>
            )}
            {squads.map((squad) => (
              <SquadCard
                key={squad.squad_name}
                squad={squad}
                formations={formations}
                objectives={objectives}
                scpTargets={scp_targets}
                act={act}
              />
            ))}
          </Box>

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '6px 14px',
              fontSize: '9px',
              color: C.textDim,
              textAlign: 'center',
            }}
          >
            SCP FOUNDATION — MOBILE TASK FORCE COMMAND — TACTICAL v3.2
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
