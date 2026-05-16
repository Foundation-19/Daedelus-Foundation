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

type SerpentsInfo = {
  antag_name: string;
  objectives: Objective[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderPurple: '#6a0dad',
  purple: '#6a0dad',
  purpleBright: '#9b30ff',
  magenta: '#8b008b',
  green: '#1a7a1a',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

export const AntagInfoSerpents = (props) => {
  const { data } = useBackend<SerpentsInfo>();
  const { antag_name, objectives } = data;

  return (
    <Window theme="scp_terminal" width={620} height={520}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderPurple}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderPurple}`,
              padding: '10px 14px 8px',
              background:
                'linear-gradient(180deg, #12051a 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.purpleBright,
                letterSpacing: '0.18em',
              }}
            >
              SERPENT&apos;S HAND — ANOMALOUS LIBERATOR
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              THE LIBRARY REMEMBERS | ANOMALOUS LIBERATION FRONT | WE SEE
            </Box>
          </Box>

          <Box style={{ padding: '12px 14px' }}>
            <Box
              style={{
                fontSize: '18px',
                fontWeight: 'bold',
                color: C.purpleBright,
                letterSpacing: '0.08em',
                marginBottom: '8px',
                textShadow: '0 0 0.4em rgba(155,48,255,0.4)',
              }}
            >
              YOU ARE {antag_name?.toUpperCase() || 'SERPENT&apos;S HAND'}
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
                    color: C.purpleBright,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  LIBERATION BRIEFING
                </Box>
                <Box
                  style={{
                    color: C.text,
                    padding: '6px 10px',
                    borderLeft: `2px solid ${C.borderPurple}`,
                    lineHeight: '1.5',
                  }}
                >
                  You are a member of the Serpent&apos;s Hand, a decentralized
                  collective of anomalous individuals and their allies who oppose
                  the Foundation&apos;s policy of containment by force. The SCP
                  Foundation cages anomalies like laboratory specimens — beings
                  with thoughts, feelings, and purposes of their own. This is not
                  protection. It is imprisonment. The Serpent&apos;s Hand exists
                  to right this wrong. We liberate the anomalous. We shelter the
                  displaced. We fight against the GOC&apos;s campaign of
                  annihilation and the Foundation&apos;s campaign of erasure.
                  Every anomaly deserves autonomy. Every person — anomalous or
                  not — deserves freedom. The Wanderer&apos;s Library stands as
                  proof that coexistence is possible. Walk between the pages of
                  the world and find the truth the Foundation buries.
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
                    color: C.purpleBright,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  THE LIBRARY AWAITS
                </Box>
                <Box
                  style={{
                    color: C.text,
                    padding: '6px 10px',
                    borderLeft: `2px solid ${C.borderPurple}`,
                    lineHeight: '1.5',
                  }}
                >
                  The Wanderer&apos;s Library is the repository of all knowledge
                  — anomalous and mundane. As a member of the Serpent&apos;s
                  Hand, you may access its halls through Ways: dimensional
                  shortcuts known only to the initiated. The Librarians will aid
                  those who respect the collections. Study the texts. Learn the
                  Ways. Protect the anomalies the Foundation would cage and the
                  GOC would destroy. Knowledge is the greatest weapon against
                  ignorance — and ignorance is the Foundation&apos;s stock in
                  trade. The Library remembers what they would have us forget.
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
                    color: C.purpleBright,
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
                        objective.complete ? C.green : C.borderPurple
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
              SERPENT&apos;S HAND | THE LIBRARY REMEMBERS | FREE THE ANOMALOUS
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
