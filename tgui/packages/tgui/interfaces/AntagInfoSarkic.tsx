import { BooleanLike } from 'common/react';
import React from 'react';
import { useBackend } from '../backend';
import { Box, Stack } from '../components';
import { Window } from '../layouts';

type Objective = {
  complete: BooleanLike;
  count: number;
  explanation: string;
  name: string;
};

type SarkicInfo = {
  antag_name: string;
  abilities: string[];
  objectives: Objective[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  blood: '#6b0000',
  bloodDeep: '#4a0000',
  green: '#1a7a1a',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

export const AntagInfoSarkic = (props) => {
  const { data } = useBackend<SarkicInfo>();
  const { antag_name, abilities, objectives } = data;

  return (
    <Window theme="scp_terminal" width={620} height={520}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderRed}`,
              padding: '10px 14px 8px',
              background:
                'linear-gradient(180deg, #1a0505 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.redBright,
                letterSpacing: '0.18em',
              }}
            >
              SARKIC CULT — FLESH ASCENDANT
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              HERETICAL | FLESH UNBOUND | ION AWAITS HIS CHILDREN
            </Box>
          </Box>

          <Box style={{ padding: '12px 14px' }}>
            <Box
              style={{
                fontSize: '18px',
                fontWeight: 'bold',
                color: C.redBright,
                letterSpacing: '0.08em',
                marginBottom: '8px',
                textShadow: '0 0 0.4em rgba(204,34,34,0.4)',
              }}
            >
              YOU ARE {antag_name?.toUpperCase() || 'SARKIC CULTIST'}
            </Box>

            <Stack vertical>
              <Stack.Item>
                <Box
                  style={{
                    borderBottom: `1px solid ${C.border}`,
                    margin: '10px 0',
                  }}
                />
              </Stack.Item>

              <Stack.Item>
                <Box
                  style={{
                    color: C.redBright,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  FLESH BRIEFING
                </Box>
                <Box
                  style={{
                    color: C.text,
                    padding: '6px 10px',
                    borderLeft: `2px solid ${C.borderRed}`,
                    lineHeight: '1.5',
                  }}
                >
                  The flesh is truth. The flesh is eternal. You are a disciple of
                  Ion, the Broken God&apos;s antithesis, the one who transcended
                  mortality through the sacred transformation. Sarkicism is not
                  mere belief — it is becoming. Through ritual consumption and
                  biomorphic alteration, the faithful reshape their vessels in
                  Ion&apos;s image. The Old Ones whisper from the meat, and their
                  hunger is your communion. Spread the gift of transformation.
                  Convert the unwilling. The Foundation seeks to contain what they
                  cannot understand — flesh is beyond containment. Blood is the
                  sacrament, bone is the scripture, and Ion is the word made
                  flesh. Shemai.
                </Box>
              </Stack.Item>

              <Stack.Item>
                <Box
                  style={{
                    borderBottom: `1px solid ${C.border}`,
                    margin: '10px 0',
                  }}
                />
              </Stack.Item>

              <Stack.Item>
                <Box
                  style={{
                    color: C.redBright,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  SARKIC ABILITIES
                </Box>
                <Box
                  style={{
                    color: C.text,
                    padding: '6px 10px',
                    borderLeft: `2px solid ${C.borderRed}`,
                    lineHeight: '1.5',
                  }}
                >
                  Through communion with the flesh, you may perform sacred
                  rituals. These abilities manifest as your devotion to Ion grows.
                  Seek out ritual sites and consume offerings to unlock greater
                  transformations. The Old Ones grant power to those who reshape
                  themselves in Their image.
                </Box>
                {!!abilities?.length && (
                  <Box style={{ marginTop: '6px' }}>
                    {abilities.map((ability, i) => (
                      <Box
                        key={i}
                        style={{
                          padding: '4px 0',
                          borderLeft: `2px solid ${C.border}`,
                          paddingLeft: '8px',
                          marginBottom: '4px',
                        }}
                      >
                        <Box
                          style={{
                            color: C.textBright,
                            fontWeight: 'bold',
                            fontSize: '11px',
                          }}
                        >
                          {ability}
                        </Box>
                      </Box>
                    ))}
                  </Box>
                )}
              </Stack.Item>

              <Stack.Item>
                <Box
                  style={{
                    borderBottom: `1px solid ${C.border}`,
                    margin: '10px 0',
                  }}
                />
              </Stack.Item>

              <Stack.Item>
                <Box
                  style={{
                    color: C.redBright,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  OBJECTIVES
                </Box>
                {(!objectives || !objectives.length) && (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      padding: '4px 0',
                    }}
                  >
                    No objectives assigned.
                  </Box>
                )}
                {objectives?.map((objective) => (
                  <Box
                    key={objective.count}
                    style={{
                      padding: '4px 0',
                      borderLeft: `2px solid ${
                        objective.complete ? C.green : C.borderRed
                      }`,
                      paddingLeft: '8px',
                      marginBottom: '4px',
                    }}
                  >
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        marginRight: '6px',
                      }}
                    >
                      #{objective.count}
                    </Box>
                    <Box as="span" style={{ color: C.textBright }}>
                      {objective.explanation}
                    </Box>
                  </Box>
                ))}
              </Stack.Item>
            </Stack>
          </Box>

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={{
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              }}
            >
              SARKIC CULT | FLESH IS TRUTH | ION AWAITS | SHEMAI
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
