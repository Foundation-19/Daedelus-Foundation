import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';

interface SessionType {
  id: string;
  name: string;
  description: string;
}

interface Data {
  subject_name: string;
  subject_id: string;
  sessions_completed: number;
  sessions_required: number;
  behavior_score: number;
  eligible_for_release: BooleanLike;
  session_types: SessionType[];
}

export const RehabilitationConsole = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    subject_name,
    subject_id,
    sessions_completed,
    sessions_required,
    behavior_score,
    eligible_for_release,
    session_types = [],
  } = data;

  const progressPercent = sessions_required > 0
    ? Math.round((sessions_completed / sessions_required) * 100)
    : 0;

  return (
    <Window width={750} height={550} theme="scp_terminal">
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
              background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              D-CLASS REHABILITATION CONSOLE
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              PERSONNEL REHABILITATION PROGRAM | BEHAVIORAL ASSESSMENT UNIT
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>SUBJECT INFORMATION</TermHeader>
            <TermRow>
              <TermLabel>NAME</TermLabel>
              <TermValue bold color={C.amber}>{subject_name}</TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>SUBJECT ID</TermLabel>
              <TermValue color={C.textBright}>{subject_id}</TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>REHABILITATION PROGRESS</TermHeader>
            <TermProgressBar
              label="SESSIONS"
              value={sessions_completed}
              maxValue={sessions_required}
              color={progressPercent >= 100 ? C.green : C.amber}
            />
            <TermRow>
              <TermLabel>COMPLETED</TermLabel>
              <TermValue color={C.textBright}>{sessions_completed}</TermValue>
              <TermValue color={C.textDim}>/{sessions_required}</TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>PROGRESS</TermLabel>
              <TermValue color={progressPercent >= 100 ? C.green : C.amber}>
                {progressPercent}%
              </TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>BEHAVIORAL ASSESSMENT</TermHeader>
            <TermProgressBar
              label="BEHAVIOR SCORE"
              value={behavior_score}
              maxValue={100}
              color={behavior_score > 75 ? C.green : behavior_score > 40 ? C.amber : C.redBright}
              suffix="%"
            />
            <TermRow>
              <TermLabel>RELEASE ELIGIBILITY</TermLabel>
              <TermValue color={eligible_for_release ? C.green : C.redBright}>
                {eligible_for_release ? 'ELIGIBLE' : 'NOT ELIGIBLE'}
              </TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>AVAILABLE SESSIONS</TermHeader>
            {session_types.length > 0 ? (
              session_types.map((session) => (
                <Box
                  key={session.id}
                  style={{
                    marginBottom: '4px',
                    padding: '8px',
                    borderLeft: `2px solid ${C.border}`,
                    background: C.panel,
                  }}
                >
                  <TermRow>
                    <TermValue bold color={C.amber}>{session.name}</TermValue>
                  </TermRow>
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '11px',
                      fontStyle: 'italic',
                      marginTop: '2px',
                    })}
                  >
                    {session.description}
                  </Box>
                  <Box style={{ marginTop: '4px' }}>
                    <TermButton
                      color="green"
                      onClick={() => act('start_session', { type: session.id })}
                    >
                      START SESSION
                    </TermButton>
                  </Box>
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO SESSIONS AVAILABLE
              </Box>
            )}

            <TermDivider />

            <TermHeader>ADMINISTRATIVE ACTIONS</TermHeader>
            <Box style={{ display: 'flex', gap: '4px' }}>
              <TermButton
                color="yellow"
                onClick={() => act('evaluate_subject')}
              >
                EVALUATE SUBJECT
              </TermButton>
              <TermButton
                color="green"
                selected={!!eligible_for_release}
                onClick={() => act('approve_release')}
              >
                APPROVE RELEASE
              </TermButton>
            </Box>
          </Box>

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={term({
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              })}
            >
              SCP FOUNDATION | D-CLASS REHABILITATION | SUBJECT WELFARE PROTOCOL
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
