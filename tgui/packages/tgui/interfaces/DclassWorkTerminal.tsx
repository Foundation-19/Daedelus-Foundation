import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';

interface Assignment {
  scp_id: string;
  test_type: string;
  danger_level: number;
  voluntary: BooleanLike;
  elapsed: number;
}

interface AvailableTest {
  name: string;
  scp_id: string;
  test_type: string;
  danger_level: number;
  reward: number;
}

interface HistoryRecord {
  scp_id: string;
  outcome: string;
  danger_level: number;
  reward: number;
  time: string;
}

interface Data {
  dclass_name: string;
  dclass_id: string;
  trust_level: number;
  trust_name: string;
  credits: number;
  strikes: number;
  tests_completed: number;
  behavior_score: number;
  is_active: BooleanLike;
  assignments: Assignment[];
  available_tests: AvailableTest[];
  history: HistoryRecord[];
}

const dangerColor = (level: number): string => {
  switch (level) {
    case 1: return C.green;
    case 2: return C.amber;
    case 3: return C.orange;
    default: return C.redBright;
  }
};

const dangerLabel = (level: number): string => {
  switch (level) {
    case 1: return 'LOW';
    case 2: return 'MEDIUM';
    case 3: return 'HIGH';
    default: return 'EXTREME';
  };
};

const formatElapsed = (ticks: number): string => {
  const seconds = Math.floor(ticks / 10);
  const minutes = Math.floor(seconds / 60);
  if (minutes > 0) return `${minutes}m ${seconds % 60}s`;
  return `${seconds}s`;
};

export const DclassWorkTerminal = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    dclass_name,
    dclass_id,
    trust_level,
    trust_name,
    credits,
    strikes,
    tests_completed,
    behavior_score,
    is_active,
    assignments = [],
    available_tests = [],
    history = [],
  } = data;

  return (
    <Window width={700} height={600} theme="scp_terminal">
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.border}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.border}`,
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
              D-CLASS WORK ASSIGNMENTS
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              PERSONNEL TESTING PROGRAM | WORK ASSIGNMENT TERMINAL
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>PERSONNEL INFORMATION</TermHeader>
            <TermRow>
              <TermLabel>NAME</TermLabel>
              <TermValue bold color={C.amber}>{dclass_name || 'Unknown'}</TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>ID</TermLabel>
              <TermValue color={C.textBright}>{dclass_id || 'N/A'}</TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>TRUST</TermLabel>
              <TermValue color={trust_level >= 3 ? C.green : trust_level >= 2 ? C.amber : C.redBright}>
                {trust_name || 'Unknown'}
              </TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>CREDITS</TermLabel>
              <TermValue color={C.green}>{credits || 0}</TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>STRIKES</TermLabel>
              <TermValue color={(strikes || 0) >= 2 ? C.redBright : C.textBright}>
                {strikes || 0}/3
              </TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>TESTS</TermLabel>
              <TermValue color={C.textBright}>{tests_completed || 0}</TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>BEHAVIOR ASSESSMENT</TermHeader>
            <TermProgressBar
              label="BEHAVIOR"
              value={behavior_score || 0}
              maxValue={100}
              color={(behavior_score || 0) > 75 ? C.green : (behavior_score || 0) > 40 ? C.amber : C.redBright}
              suffix="%"
            />

            <TermDivider />

            {is_active && assignments.length > 0 && (
              <>
                <TermHeader>ACTIVE ASSIGNMENT</TermHeader>
                {assignments.map((assignment, i) => (
                  <Box
                    key={i}
                    style={{
                      marginBottom: '4px',
                      padding: '8px',
                      borderLeft: `2px solid ${C.amber}`,
                      background: C.panel,
                    }}
                  >
                    <TermRow>
                      <TermLabel>SCP</TermLabel>
                      <TermValue bold color={C.amber}>{assignment.scp_id}</TermValue>
                    </TermRow>
                    <TermRow>
                      <TermLabel>TYPE</TermLabel>
                      <TermValue color={C.textBright}>{assignment.test_type}</TermValue>
                      <TermLabel style={{ marginLeft: '16px' }}>DANGER</TermLabel>
                      <TermValue color={dangerColor(assignment.danger_level)}>
                        {dangerLabel(assignment.danger_level)}
                      </TermValue>
                    </TermRow>
                    <TermRow>
                      <TermLabel>ELAPSED</TermLabel>
                      <TermValue color={C.textBright}>{formatElapsed(assignment.elapsed)}</TermValue>
                      <TermLabel style={{ marginLeft: '16px' }}>VOLUNTARY</TermLabel>
                      <TermValue color={assignment.voluntary ? C.green : C.redBright}>
                        {assignment.voluntary ? 'Yes' : 'No'}
                      </TermValue>
                    </TermRow>
                    <Box style={{ marginTop: '6px' }}>
                      <TermButton
                        color="green"
                        onClick={() => act('report_complete')}
                      >
                        REPORT COMPLETION
                      </TermButton>
                    </Box>
                  </Box>
                ))}
                <TermDivider />
              </>
            )}

            <TermHeader>AVAILABLE TESTS</TermHeader>
            {available_tests.length > 0 ? (
              available_tests.map((test, i) => (
                <Box
                  key={i}
                  style={{
                    marginBottom: '4px',
                    padding: '8px',
                    borderLeft: `2px solid ${dangerColor(test.danger_level)}`,
                    background: C.panel,
                  }}
                >
                  <TermRow>
                    <TermValue bold color={C.amber}>{test.name}</TermValue>
                  </TermRow>
                  <TermRow>
                    <TermLabel>SCP</TermLabel>
                    <TermValue color={C.textBright}>{test.scp_id}</TermValue>
                    <TermLabel style={{ marginLeft: '16px' }}>TYPE</TermLabel>
                    <TermValue color={C.textBright}>{test.test_type}</TermValue>
                  </TermRow>
                  <TermRow>
                    <TermLabel>DANGER</TermLabel>
                    <TermValue color={dangerColor(test.danger_level)}>
                      {dangerLabel(test.danger_level)}
                    </TermValue>
                    <TermLabel style={{ marginLeft: '16px' }}>REWARD</TermLabel>
                    <TermValue color={C.green}>{test.reward}cr</TermValue>
                  </TermRow>
                  <Box style={{ marginTop: '6px' }}>
                    <TermButton
                      color="green"
                      onClick={() => act('volunteer', { scp_id: test.scp_id })}
                    >
                      VOLUNTEER
                    </TermButton>
                  </Box>
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO TESTS CURRENTLY AVAILABLE
              </Box>
            )}

            {history.length > 0 && (
              <>
                <TermDivider />
                <TermHeader>TEST HISTORY</TermHeader>
                {history.map((record, i) => (
                  <Box
                    key={i}
                    style={{
                      marginBottom: '2px',
                      padding: '4px 8px',
                      borderBottom: `1px solid ${C.border}`,
                    }}
                  >
                    <TermRow>
                      <TermValue color={C.textBright} bold>{record.scp_id}</TermValue>
                      <TermLabel style={{ marginLeft: '12px' }}>RESULT</TermLabel>
                      <TermValue color={record.outcome === 'success' ? C.green : C.amber}>
                        {(record.outcome || 'unknown').toUpperCase()}
                      </TermValue>
                      <TermLabel style={{ marginLeft: '12px' }}>DANGER</TermLabel>
                      <TermValue color={dangerColor(record.danger_level)}>
                        {dangerLabel(record.danger_level)}
                      </TermValue>
                      <TermLabel style={{ marginLeft: '12px' }}>REWARD</TermLabel>
                      <TermValue color={C.green}>{record.reward}cr</TermValue>
                      <TermLabel style={{ marginLeft: '12px' }}>TIME</TermLabel>
                      <TermValue color={C.textDim}>{record.time}</TermValue>
                    </TermRow>
                  </Box>
                ))}
              </>
            )}
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
              SCP FOUNDATION | D-CLASS WORK PROGRAM | PERSONNEL TESTING DIVISION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
