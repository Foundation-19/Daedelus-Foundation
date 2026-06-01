import { useState } from 'react';
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
};

const bslColors: Record<number, string> = {
  1: C.green,
  2: C.amber,
  3: '#d4760a',
  4: C.red,
};

const bslGlow: Record<number, string> = {
  1: C.green,
  2: C.amber,
  3: '#d4760a',
  4: '#ff1a1a',
};

const stageLabels: Record<string, string> = {
  sample_collection: 'SAMPLE COLLECTION',
  analysis: 'ANALYSIS',
  countermeasure_dev: 'COUNTERMEASURE DEV',
  complete: 'COMPLETE',
};

const stageColors: Record<string, string> = {
  sample_collection: C.amber,
  analysis: '#4488cc',
  countermeasure_dev: '#cc8844',
  complete: C.brightGreen,
};

type Infection = {
  host_name: string;
  host_job: string;
  host_ref: string;
  pathogen_type: string;
  bsl: number;
  progress: number;
  countermeasure: string;
  treated: BooleanLike;
  time_detected: number;
};

type ResearchProject = {
  project_id: string;
  pathogen: string;
  researcher: string;
  progress: number;
  stage: string;
  points_contributed: number;
  time_started: number;
};

type Countermeasure = {
  pathogen: string;
  developer: string;
  effective: BooleanLike;
  time_developed: number;
};

type Data = {
  active_infections: Infection[];
  research_projects: ResearchProject[];
  countermeasures: Countermeasure[];
  total_infections: number;
  total_countermeasures: number;
  total_research: number;
};

const BslBadge = (props: { level: number }) => {
  const { level } = props;
  return (
    <Box
      inline
      px={1}
      style={{
        border: `2px solid ${bslColors[level] || C.border}`,
        fontFamily: 'monospace',
        fontSize: '11px',
        fontWeight: 'bold',
        color: bslGlow[level] || C.text,
        background: level === 4 ? C.darkRed : 'transparent',
        borderRadius: '2px',
      }}
    >
      BSL-{level}
    </Box>
  );
};

const StageBadge = (props: { stage: string }) => {
  const { stage } = props;
  return (
    <Box
      inline
      px={1}
      style={{
        border: `1px solid ${stageColors[stage] || C.border}`,
        fontFamily: 'monospace',
        fontSize: '10px',
        fontWeight: 'bold',
        color: stageColors[stage] || C.text,
        borderRadius: '2px',
      }}
    >
      {stageLabels[stage] || stage.toUpperCase()}
    </Box>
  );
};

const EffectivenessBadge = (props: { effective: BooleanLike }) => {
  const { effective } = props;
  if (effective) {
    return (
      <Box
        inline
        px={1}
        style={{
          border: `1px solid ${C.brightGreen}`,
          fontFamily: 'monospace',
          fontSize: '10px',
          fontWeight: 'bold',
          color: C.brightGreen,
          borderRadius: '2px',
        }}
      >
        EFFECTIVE
      </Box>
    );
  }
  return (
    <Box
      inline
      px={1}
      style={{
        border: `1px solid ${C.red}`,
        fontFamily: 'monospace',
        fontSize: '10px',
        fontWeight: 'bold',
        color: C.red,
        borderRadius: '2px',
      }}
    >
      INEFFECTIVE
    </Box>
  );
};

const ProgressBar = (props: { value: number; colorFn?: (v: number) => string }) => {
  const { value, colorFn } = props;
  const defaultColor = (v: number) =>
    v >= 75 ? C.red : v >= 40 ? C.amber : C.green;
  const color = colorFn ? colorFn(value) : defaultColor(value);
  return (
    <Box
      style={{
        width: '120px',
        height: '8px',
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

export const ScpPathogenResearch = () => {
  const { act, data } = useBackend<Data>();
  const [newPathogen, setNewPathogen] = useState('');

  const {
    active_infections = [],
    research_projects = [],
    countermeasures = [],
    total_infections,
    total_countermeasures,
    total_research,
  } = data;

  return (
    <NtosWindow title="Pathogen Research" width={750} height={650} >
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                borderBottom: `2px solid ${C.border}`,
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
                    PATHOGEN RESEARCH
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={2}>
                    <Stack.Item>
                      <Box style={{ color: C.dim, fontFamily: 'monospace', fontSize: '11px' }}>
                        INFECTIONS
                      </Box>
                      <Box
                        style={{
                          color: C.red,
                          fontFamily: 'monospace',
                          fontSize: '16px',
                          fontWeight: 'bold',
                          textAlign: 'center',
                        }}
                      >
                        {total_infections}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box style={{ color: C.dim, fontFamily: 'monospace', fontSize: '11px' }}>
                        COUNTERMEASURES
                      </Box>
                      <Box
                        style={{
                          color: C.brightGreen,
                          fontFamily: 'monospace',
                          fontSize: '16px',
                          fontWeight: 'bold',
                          textAlign: 'center',
                        }}
                      >
                        {total_countermeasures}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box style={{ color: C.dim, fontFamily: 'monospace', fontSize: '11px' }}>
                        RESEARCH PTS
                      </Box>
                      <Box
                        style={{
                          color: C.amber,
                          fontFamily: 'monospace',
                          fontSize: '16px',
                          fontWeight: 'bold',
                          textAlign: 'center',
                        }}
                      >
                        {total_research}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="ACTIVE INFECTIONS"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
              buttons={
                <Box style={{ color: C.dim, fontFamily: 'monospace', fontSize: '11px' }}>
                  {active_infections.length} ACTIVE
                </Box>
              }
            >
              {active_infections.length === 0 && (
                <Box style={{ color: C.dim, textAlign: 'center', fontFamily: 'monospace' }} py={2}>
                  NO ACTIVE INFECTIONS DETECTED
                </Box>
              )}
              <Stack vertical>
                {active_infections.map((inf) => (
                  <Stack.Item key={inf.host_ref}>
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
                              <Stack align="center" gap={1}>
                                <Stack.Item>
                                  <Box
                                    style={{
                                      color: inf.treated ? C.brightGreen : C.text,
                                      fontFamily: 'monospace',
                                      fontSize: '13px',
                                      fontWeight: 'bold',
                                    }}
                                  >
                                    {inf.host_name}
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
                                    {inf.host_job}
                                  </Box>
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                fontFamily="monospace"
                                fontSize="11px"
                                color={inf.treated ? 'grey' : 'red'}
                                backgroundColor={inf.treated ? C.border : C.darkRed}
                                disabled={!!inf.treated}
                                onClick={() =>
                                  act('treat_infection', {
                                    host: inf.host_ref,
                                    pathogen: inf.pathogen_type,
                                  })
                                }
                              >
                                TREAT
                              </Button>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            <Stack.Item>
                              <BslBadge level={inf.bsl} />
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '12px',
                                  color: C.text,
                                }}
                              >
                                {inf.pathogen_type}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            <Stack.Item>
                              <ProgressBar value={inf.progress} />
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '10px',
                                  color: C.dim,
                                }}
                              >
                                {inf.progress}%
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            {inf.treated ? (
                              <Box
                                inline
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '11px',
                                  fontWeight: 'bold',
                                  color: C.brightGreen,
                                }}
                              >
                                [TREATED]
                              </Box>
                            ) : (
                              <Box
                                inline
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '11px',
                                  color: C.red,
                                }}
                              >
                                [UNTREATED]
                              </Box>
                            )}
                            {inf.countermeasure && (
                              <Box
                                inline
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '10px',
                                  color: C.dim,
                                }}
                              >
                                CM: {inf.countermeasure}
                              </Box>
                            )}
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
              title="RESEARCH PROJECTS"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
              buttons={
                <Stack align="center" gap={1}>
                  <Input
                    value={newPathogen}
                    onInput={(_e, val: string) => setNewPathogen(val)}
                    placeholder="Pathogen name..."
                    fontFamily="monospace"
                    fontSize="11px"
                    width="150px"
                    backgroundColor={C.bg}
                    textColor={C.text}
                  />
                  <Button
                    fontFamily="monospace"
                    fontSize="11px"
                    color="green"
                    backgroundColor={C.green}
                    disabled={!newPathogen.trim()}
                    onClick={() => {
                      act('start_research', { pathogen: newPathogen.trim() });
                      setNewPathogen('');
                    }}
                  >
                    START RESEARCH
                  </Button>
                </Stack>
              }
            >
              {research_projects.length === 0 && (
                <Box style={{ color: C.dim, textAlign: 'center', fontFamily: 'monospace' }} py={2}>
                  NO ACTIVE RESEARCH PROJECTS
                </Box>
              )}
              <Stack vertical>
                {research_projects.map((proj) => (
                  <Stack.Item key={proj.project_id}>
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
                              <Stack align="center" gap={1}>
                                <Stack.Item>
                                  <Box
                                    style={{
                                      fontFamily: 'monospace',
                                      fontSize: '12px',
                                      fontWeight: 'bold',
                                      color: C.amber,
                                    }}
                                  >
                                    [{proj.project_id}]
                                  </Box>
                                </Stack.Item>
                                <Stack.Item>
                                  <Box
                                    style={{
                                      fontFamily: 'monospace',
                                      fontSize: '12px',
                                      color: C.text,
                                    }}
                                  >
                                    {proj.pathogen}
                                  </Box>
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                fontFamily="monospace"
                                fontSize="11px"
                                color="amber"
                                backgroundColor={C.panel}
                                disabled={proj.stage === 'complete'}
                                onClick={() =>
                                  act('contribute_research', {
                                    project_id: proj.project_id,
                                    amount: 10,
                                  })
                                }
                              >
                                CONTRIBUTE +10
                              </Button>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '10px',
                                  color: C.dim,
                                }}
                              >
                                Researcher: {proj.researcher}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <StageBadge stage={proj.stage} />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={1}>
                            <Stack.Item>
                              <ProgressBar
                                value={Math.min(proj.progress, 100)}
                                colorFn={(v: number) =>
                                  v >= 100
                                    ? C.brightGreen
                                    : v >= 60
                                      ? C.amber
                                      : '#4488cc'
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '10px',
                                  color: C.dim,
                                }}
                              >
                                {proj.progress}%
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '10px',
                                  color: C.dim,
                                }}
                              >
                                {proj.points_contributed} pts
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
              title="COUNTERMEASURES"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                fontFamily: 'monospace',
              }}
              buttons={
                <Box style={{ color: C.dim, fontFamily: 'monospace', fontSize: '11px' }}>
                  {countermeasures.length} DEVELOPED
                </Box>
              }
            >
              {countermeasures.length === 0 && (
                <Box style={{ color: C.dim, textAlign: 'center', fontFamily: 'monospace' }} py={2}>
                  NO COUNTERMEASURES DEVELOPED
                </Box>
              )}
              <Stack vertical>
                {countermeasures.map((cm, idx) => (
                  <Stack.Item key={idx}>
                    <Box
                      style={{
                        background: C.bg,
                        border: `1px solid ${C.border}`,
                        padding: '8px',
                        borderRadius: '2px',
                      }}
                    >
                      <Stack justify="space-between" align="center">
                        <Stack.Item grow>
                          <Stack align="center" gap={1}>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '12px',
                                  fontWeight: 'bold',
                                  color: C.text,
                                }}
                              >
                                {cm.pathogen}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '10px',
                                  color: C.dim,
                                }}
                              >
                                Developer: {cm.developer}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <EffectivenessBadge effective={cm.effective} />
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              fontFamily: 'monospace',
                              fontSize: '10px',
                              color: C.dim,
                            }}
                          >
                            {cm.time_developed}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
