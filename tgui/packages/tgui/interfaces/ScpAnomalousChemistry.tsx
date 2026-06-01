import { useBackend, useLocalState } from '../backend';
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
  purple: '#9944cc',
};

type Compound = {
  name: string;
  properties: string;
  scp_origin: string;
  stability: number;
  researched: BooleanLike;
  time_registered: number;
};

type SynthesisEntry = {
  compound: string;
  amount: number;
  chemist: string;
  progress: number;
  stability_risk: number;
  status: string;
  time_started: number;
};

type TestResult = {
  compound: string;
  chemist: string;
  stability: number;
  success: BooleanLike;
  time: number;
};

type Data = {
  compounds: Compound[];
  synthesis_queue: SynthesisEntry[];
  test_results: TestResult[];
  total_synthesized: number;
  total_research: number;
  total_containment: number;
};

const StabilityBar = (props: { value: number }) => {
  const { value } = props;
  const color =
    value > 70 ? C.green : value > 40 ? C.amber : C.red;
  return (
    <Box
      style={{
        width: '100%',
        height: '10px',
        background: C.darkRed,
        borderRadius: '2px',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          width: `${value}%`,
          height: '100%',
          background: color,
          borderRadius: '2px',
        }}
      />
    </Box>
  );
};

const RiskBar = (props: { value: number }) => {
  const { value } = props;
  const color =
    value > 60 ? C.red : value > 30 ? C.amber : C.green;
  return (
    <Box
      style={{
        width: '100%',
        height: '10px',
        background: C.border,
        borderRadius: '2px',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          width: `${value}%`,
          height: '100%',
          background: color,
          borderRadius: '2px',
        }}
      />
    </Box>
  );
};

const StatusBadge = (props: { status: string }) => {
  const { status } = props;
  const colorMap: Record<string, string> = {
    synthesizing: C.brightGreen,
    unstable: C.amber,
    failed: C.red,
    complete: C.dim,
  };
  return (
    <Box
      inline
      style={{
        color: colorMap[status] || C.dim,
        fontFamily: 'monospace',
        fontWeight: 'bold',
        textTransform: 'uppercase',
      }}
    >
      [{status}]
    </Box>
  );
};

export const ScpAnomalousChemistry = () => {
  const { act, data } = useBackend<Data>();
  const {
    compounds = [],
    synthesis_queue = [],
    test_results = [],
    total_synthesized,
    total_research,
    total_containment,
  } = data;

  const [regName, setRegName] = useLocalState<string>('regName', '');
  const [regProperties, setRegProperties] = useLocalState<string>(
    'regProperties',
    ''
  );
  const [regOrigin, setRegOrigin] = useLocalState<string>('regOrigin', '');

  return (
    <NtosWindow title="ANOMALOUS CHEMISTRY" width={700} height={650} >
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack justify="space-between" align="center">
                <Stack.Item>
                  <Box
                    style={{
                      color: C.highlight,
                      fontSize: '18px',
                      fontWeight: 'bold',
                      letterSpacing: '2px',
                      fontFamily: 'monospace',
                    }}
                  >
                    ANOMALOUS CHEMISTRY
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={2}>
                    <Stack.Item>
                      <Box style={{ color: C.dim, fontFamily: 'monospace' }}>
                        SYNTHESIZED:{' '}
                        <Box inline style={{ color: C.brightGreen }}>
                          {total_synthesized}
                        </Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box style={{ color: C.dim, fontFamily: 'monospace' }}>
                        RESEARCH PTS:{' '}
                        <Box inline style={{ color: C.amber }}>
                          {total_research}
                        </Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box style={{ color: C.dim, fontFamily: 'monospace' }}>
                        CONTAINMENT CHEMS:{' '}
                        <Box inline style={{ color: C.purple }}>
                          {total_containment}
                        </Box>
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="COMPOUND REGISTRY"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              {compounds.length === 0 && (
                <Box style={{ color: C.dim, textAlign: 'center' }}>
                  NO COMPOUNDS REGISTERED
                </Box>
              )}
              <Stack vertical>
                {compounds.map((compound, i) => (
                  <Stack.Item key={i}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '8px',
                        borderRadius: '2px',
                      }}
                    >
                      <Stack vertical gap={1}>
                        <Stack.Item>
                          <Stack justify="space-between" align="center">
                            <Stack.Item>
                              <Box
                                style={{
                                  color: C.highlight,
                                  fontWeight: 'bold',
                                  fontFamily: 'monospace',
                                }}
                              >
                                {compound.name}
                                {compound.researched && (
                                  <Box
                                    inline
                                    ml={1}
                                    style={{
                                      color: C.brightGreen,
                                      fontSize: '10px',
                                    }}
                                  >
                                    [RESEARCHED]
                                  </Box>
                                )}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                inline
                                style={{
                                  color: C.purple,
                                  fontFamily: 'monospace',
                                  fontSize: '11px',
                                }}
                              >
                                ORIGIN: {compound.scp_origin}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              color: C.dim,
                              fontFamily: 'monospace',
                              fontSize: '11px',
                            }}
                          >
                            PROPERTIES: {compound.properties}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            <Stack.Item
                              grow
                              style={{ maxWidth: '200px' }}
                            >
                              <StabilityBar value={compound.stability} />
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  color: C.dim,
                                  fontFamily: 'monospace',
                                  fontSize: '11px',
                                }}
                              >
                                STABILITY: {compound.stability}%
                              </Box>
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
              title="SYNTHESIS QUEUE"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              {synthesis_queue.length === 0 && (
                <Box style={{ color: C.dim, textAlign: 'center' }}>
                  SYNTHESIS QUEUE EMPTY
                </Box>
              )}
              <Stack vertical>
                {synthesis_queue.map((entry, i) => (
                  <Stack.Item key={i}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '8px',
                        borderRadius: '2px',
                      }}
                    >
                      <Stack vertical gap={1}>
                        <Stack.Item>
                          <Stack justify="space-between" align="center">
                            <Stack.Item>
                              <Box
                                style={{
                                  color: C.highlight,
                                  fontWeight: 'bold',
                                  fontFamily: 'monospace',
                                }}
                              >
                                {entry.compound} x{entry.amount}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <StatusBadge status={entry.status} />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              color: C.dim,
                              fontFamily: 'monospace',
                              fontSize: '11px',
                            }}
                          >
                            CHEMIST: {entry.chemist}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            <Stack.Item
                              grow
                              style={{ maxWidth: '180px' }}
                            >
                              <StabilityBar value={entry.progress} />
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  color: C.dim,
                                  fontFamily: 'monospace',
                                  fontSize: '11px',
                                }}
                              >
                                PROGRESS: {entry.progress}%
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            <Stack.Item
                              grow
                              style={{ maxWidth: '180px' }}
                            >
                              <RiskBar value={entry.stability_risk} />
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  color: C.dim,
                                  fontFamily: 'monospace',
                                  fontSize: '11px',
                                }}
                              >
                                RISK: {entry.stability_risk}%
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack gap={1}>
                            <Button
                              content="ADVANCE (+25)"
                              style={{
                                background: C.green,
                                color: C.highlight,
                                fontFamily: 'monospace',
                                border: `1px solid ${C.brightGreen}`,
                              }}
                              onClick={() =>
                                act('advance_synthesis', {
                                  index: i + 1,
                                  progress: 25,
                                  stability: entry.stability_risk,
                                })
                              }
                            />
                            <Button
                              content="STABILIZE (-20 RISK)"
                              style={{
                                background: C.darkRed,
                                color: C.highlight,
                                fontFamily: 'monospace',
                                border: `1px solid ${C.amber}`,
                              }}
                              onClick={() =>
                                act('stabilize', {
                                  index: i + 1,
                                  amount: 20,
                                })
                              }
                            />
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
              title="TEST RESULTS"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              {test_results.length === 0 && (
                <Box style={{ color: C.dim, textAlign: 'center' }}>
                  NO TEST RESULTS RECORDED
                </Box>
              )}
              <Stack vertical>
                {test_results.map((result, i) => (
                  <Stack.Item key={i}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '6px 8px',
                        borderRadius: '2px',
                      }}
                    >
                      <Stack justify="space-between" align="center">
                        <Stack.Item>
                          <Box
                            style={{
                              color: C.highlight,
                              fontFamily: 'monospace',
                            }}
                          >
                            {result.compound}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              color: C.dim,
                              fontFamily: 'monospace',
                              fontSize: '11px',
                            }}
                          >
                            CHEMIST: {result.chemist}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              color: C.dim,
                              fontFamily: 'monospace',
                              fontSize: '11px',
                            }}
                          >
                            STABILITY: {result.stability}%
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          {result.success ? (
                            <Box
                              inline
                              style={{
                                color: C.brightGreen,
                                fontFamily: 'monospace',
                                fontWeight: 'bold',
                              }}
                            >
                              [SUCCESS]
                            </Box>
                          ) : (
                            <Box
                              inline
                              style={{
                                color: C.red,
                                fontFamily: 'monospace',
                                fontWeight: 'bold',
                              }}
                            >
                              [FAIL]
                            </Box>
                          )}
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
              title="REGISTER COMPOUND"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack vertical gap={1}>
                <Stack.Item>
                  <Stack align="center" gap={1}>
                    <Stack.Item
                      style={{
                        color: C.dim,
                        fontFamily: 'monospace',
                        minWidth: '100px',
                      }}
                    >
                      NAME:
                    </Stack.Item>
                    <Stack.Item grow>
                      <Input
                        value={regName}
                        onInput={(_e, value: string) => setRegName(value)}
                        style={{
                          width: '100%',
                          background: C.bg,
                          color: C.text,
                          border: `1px solid ${C.border}`,
                          fontFamily: 'monospace',
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack align="center" gap={1}>
                    <Stack.Item
                      style={{
                        color: C.dim,
                        fontFamily: 'monospace',
                        minWidth: '100px',
                      }}
                    >
                      PROPERTIES:
                    </Stack.Item>
                    <Stack.Item grow>
                      <Input
                        value={regProperties}
                        onInput={(_e, value: string) =>
                          setRegProperties(value)
                        }
                        style={{
                          width: '100%',
                          background: C.bg,
                          color: C.text,
                          border: `1px solid ${C.border}`,
                          fontFamily: 'monospace',
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack align="center" gap={1}>
                    <Stack.Item
                      style={{
                        color: C.dim,
                        fontFamily: 'monospace',
                        minWidth: '100px',
                      }}
                    >
                      SCP ORIGIN:
                    </Stack.Item>
                    <Stack.Item grow>
                      <Input
                        value={regOrigin}
                        onInput={(_e, value: string) => setRegOrigin(value)}
                        style={{
                          width: '100%',
                          background: C.bg,
                          color: C.text,
                          border: `1px solid ${C.border}`,
                          fontFamily: 'monospace',
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content="REGISTER"
                    style={{
                      background: C.purple,
                      color: C.highlight,
                      fontFamily: 'monospace',
                      fontWeight: 'bold',
                      border: `1px solid ${C.purple}`,
                      width: '100%',
                      textAlign: 'center',
                    }}
                    onClick={() => {
                      act('register_compound', {
                        name: regName,
                        properties: regProperties,
                        origin: regOrigin,
                      });
                      setRegName('');
                      setRegProperties('');
                      setRegOrigin('');
                    }}
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
