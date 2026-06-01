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
  blue: '#4488ff',
};

const BOT_TYPES: Record<number, { label: string; color: string }> = {
  1: { label: 'MONITOR', color: C.amber },
  2: { label: 'CONTAINMENT', color: C.red },
  3: { label: 'DECON', color: C.green },
  4: { label: 'REPAIR', color: C.blue },
};

const STATUS_COLORS: Record<string, string> = {
  pending: C.amber,
  building: '#00cccc',
  complete: C.brightGreen,
  failed: C.red,
};

function integrityColor(integrity: number): string {
  if (integrity > 75) return C.brightGreen;
  if (integrity > 50) return C.amber;
  if (integrity > 25) return C.red;
  return C.darkRed;
}

function TypeBadge({ type }: { type: number }) {
  const info = BOT_TYPES[type] || { label: 'UNKNOWN', color: C.dim };
  return (
    <Box
      inline
      px={1}
      style={{
        border: `1px solid ${info.color}`,
        color: info.color,
        'font-size': '10px',
        'letter-spacing': '1px',
      }}
    >
      {info.label}
    </Box>
  );
}

function StatusBadge({ status }: { status: string }) {
  const color = STATUS_COLORS[status] || C.dim;
  return (
    <Box
      inline
      px={1}
      style={{
        border: `1px solid ${color}`,
        color,
        'font-size': '10px',
        'letter-spacing': '1px',
      }}
    >
      {status.toUpperCase()}
    </Box>
  );
}

function IntegrityBar({ value }: { value: number }) {
  const color = integrityColor(value);
  return (
    <Stack align="center" height="14px">
      <Stack.Item grow position="relative" height="14px">
        <Box
          position="absolute"
          top={0}
          left={0}
          bottom={0}
          width="100%"
          style={{
            background: C.border,
            border: `1px solid ${C.border}`,
          }}
        />
        <Box
          position="absolute"
          top={0}
          left={0}
          bottom={0}
          width={`${value}%`}
          style={{
            background: color,
            border: `1px solid ${color}`,
          }}
        />
        <Box
          position="absolute"
          top={0}
          left={0}
          right={0}
          bottom={0}
          textAlign="center"
          style={{
            color: C.highlight,
            'font-size': '10px',
            'line-height': '14px',
            'text-shadow': '0 0 4px #000',
          }}
        >
          {value}%
        </Box>
      </Stack.Item>
    </Stack>
  );
}

function ProgressBar({ value, status }: { value: number; status: string }) {
  const color = STATUS_COLORS[status] || C.dim;
  return (
    <Stack align="center" height="14px">
      <Stack.Item grow position="relative" height="14px">
        <Box
          position="absolute"
          top={0}
          left={0}
          bottom={0}
          width="100%"
          style={{
            background: C.border,
            border: `1px solid ${C.border}`,
          }}
        />
        <Box
          position="absolute"
          top={0}
          left={0}
          bottom={0}
          width={`${value}%`}
          style={{
            background: color,
            border: `1px solid ${color}`,
          }}
        />
        <Box
          position="absolute"
          top={0}
          left={0}
          right={0}
          bottom={0}
          textAlign="center"
          style={{
            color: C.highlight,
            'font-size': '10px',
            'line-height': '14px',
            'text-shadow': '0 0 4px #000',
          }}
        >
          {value}%
        </Box>
      </Stack.Item>
    </Stack>
  );
}

export const ScpContainmentRobotics = (_props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    registered_bots = [],
    construction_queue = [],
    total_built,
    total_maintenance,
    total_assists,
  } = data;

  return (
    <NtosWindow title="Containment Robotics" width={700} height={650} >
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center" justify="space-between">
                <Stack.Item>
                  <Box
                    fontSize="18px"
                    color={C.highlight}
                    fontFamily="monospace"
                    letterSpacing="3px"
                  >
                    CONTAINMENT ROBOTICS
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Box
                        inline
                        textAlign="center"
                        px={2}
                        style={{ border: `1px solid ${C.green}` }}
                      >
                        <Box fontSize="9px" color={C.dim} letterSpacing="1px">
                          BUILT
                        </Box>
                        <Box fontSize="14px" color={C.brightGreen}>
                          {total_built}
                        </Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box
                        inline
                        textAlign="center"
                        px={2}
                        style={{ border: `1px solid ${C.amber}` }}
                      >
                        <Box fontSize="9px" color={C.dim} letterSpacing="1px">
                          MAINTENANCE
                        </Box>
                        <Box fontSize="14px" color={C.amber}>
                          {total_maintenance}
                        </Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box
                        inline
                        textAlign="center"
                        px={2}
                        style={{ border: `1px solid ${C.blue}` }}
                      >
                        <Box fontSize="9px" color={C.dim} letterSpacing="1px">
                          ASSISTS
                        </Box>
                        <Box fontSize="14px" color={C.blue}>
                          {total_assists}
                        </Box>
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="REGISTERED BOTS">
              {registered_bots.length === 0 && (
                <Box color={C.dim} textAlign="center" py={2}>
                  NO REGISTERED BOTS
                </Box>
              )}
              <Stack vertical>
                {registered_bots.map((bot) => (
                  <Stack.Item key={bot.bot_ref}>
                    <Box
                      p={1}
                      style={{
                        background: C.panel,
                        border: `1px solid ${C.border}`,
                      }}
                    >
                      <Stack vertical>
                        <Stack.Item>
                          <Stack align="center" justify="space-between">
                            <Stack.Item>
                              <Stack align="center">
                                <Stack.Item>
                                  <Box
                                    color={C.highlight}
                                    fontFamily="monospace"
                                    letterSpacing="1px"
                                  >
                                    {bot.bot_name}
                                  </Box>
                                </Stack.Item>
                                <Stack.Item ml={1}>
                                  <TypeBadge type={bot.bot_type} />
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                inline
                                px={1}
                                style={{
                                  border: `1px solid ${bot.active ? C.brightGreen : C.red}`,
                                  color: bot.active ? C.brightGreen : C.red,
                                  'font-size': '10px',
                                  'letter-spacing': '1px',
                                }}
                              >
                                {bot.active ? 'ACTIVE' : 'OFFLINE'}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" justify="space-between">
                            <Stack.Item>
                              <Box color={C.dim} fontSize="11px">
                                OWNER:{' '}
                                <Box inline color={C.text}>
                                  {bot.owner}
                                </Box>
                              </Box>
                            </Stack.Item>
                            <Stack.Item width="140px">
                              <IntegrityBar value={bot.integrity} />
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
            <Section title="CONSTRUCTION QUEUE">
              {construction_queue.length === 0 && (
                <Box color={C.dim} textAlign="center" py={2}>
                  NO ORDERS IN QUEUE
                </Box>
              )}
              <Stack vertical>
                {construction_queue.map((order, index) => (
                  <Stack.Item key={index}>
                    <Box
                      p={1}
                      style={{
                        background: C.panel,
                        border: `1px solid ${C.border}`,
                      }}
                    >
                      <Stack vertical>
                        <Stack.Item>
                          <Stack align="center" justify="space-between">
                            <Stack.Item>
                              <Stack align="center">
                                <Stack.Item>
                                  <Box
                                    color={C.highlight}
                                    fontFamily="monospace"
                                    letterSpacing="1px"
                                  >
                                    {order.description}
                                  </Box>
                                </Stack.Item>
                                <Stack.Item ml={1}>
                                  <TypeBadge type={order.order_type} />
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                            <Stack.Item>
                              <StatusBadge status={order.status} />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" justify="space-between">
                            <Stack.Item>
                              <Box color={C.dim} fontSize="11px">
                                ORDERER:{' '}
                                <Box inline color={C.text}>
                                  {order.orderer}
                                </Box>
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Stack align="center" gap={1}>
                                {order.status === 'pending' && (
                                  <Button
                                    fontSize="10px"
                                    color="teal"
                                    onClick={() =>
                                      act('start_construction', { index })
                                    }
                                  >
                                    START CONSTRUCTION
                                  </Button>
                                )}
                                {order.status === 'building' && (
                                  <Button
                                    fontSize="10px"
                                    color="teal"
                                    onClick={() =>
                                      act('advance_construction', {
                                        index,
                                        progress: Math.min(
                                          order.progress + 25,
                                          100
                                        ),
                                        stability: 100,
                                      })
                                    }
                                  >
                                    ADVANCE (+25)
                                  </Button>
                                )}
                              </Stack>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <ProgressBar
                            value={order.progress}
                            status={order.status}
                          />
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="SUBMIT ORDER">
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    fontSize="12px"
                    color="caution"
                    onClick={() => act('submit_order', { type: 1 })}
                  >
                    MONITOR DRONE
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    fontSize="12px"
                    color="danger"
                    onClick={() => act('submit_order', { type: 2 })}
                  >
                    CONTAINMENT BOT
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    fontSize="12px"
                    color="good"
                    onClick={() => act('submit_order', { type: 3 })}
                  >
                    DECON DRONE
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    fontSize="12px"
                    color="blue"
                    onClick={() => act('submit_order', { type: 4 })}
                  >
                    REPAIR DRONE
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
