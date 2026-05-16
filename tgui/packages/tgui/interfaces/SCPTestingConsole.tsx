import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar, TermModal } from './CharacterSetup/shared';

interface AvailableTest {
  id: string;
  name: string;
  description: string;
  risk_level: string;
  required_clearance: number;
}

interface ActiveTest {
  name: string;
  progress: number;
  time_remaining: number;
}

interface Data {
  available_tests: AvailableTest[];
  active_test: ActiveTest | null;
  completed_tests: string[];
  clearance_level: number;
}

const getRiskColor = (risk: string) => {
  switch (risk) {
    case 'extreme':
      return C.redBright;
    case 'high':
      return C.amber;
    case 'medium':
      return '#cc8800';
    case 'low':
      return C.green;
    default:
      return C.textDim;
  }
};

export const SCPTestingConsole = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    available_tests = [],
    active_test,
    completed_tests = [],
    clearance_level,
  } = data;

  return (
    <Window width={900} height={650} theme="scp_terminal">
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
              SCP TESTING PROTOCOL CONSOLE
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              ANOMALOUS MATERIALS TESTING | CLEARANCE LEVEL {clearance_level}
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>CURRENT STATUS</TermHeader>
            <TermRow>
              <TermLabel>CLEARANCE LEVEL</TermLabel>
              <TermValue bold color={C.amber}>{clearance_level}</TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>COMPLETED TESTS</TermLabel>
              <TermValue color={C.green}>{completed_tests.length}</TermValue>
            </TermRow>

            {active_test && (
              <Box>
                <TermDivider />
                <TermHeader>ACTIVE TEST IN PROGRESS</TermHeader>
                <TermRow>
                  <TermLabel>TEST</TermLabel>
                  <TermValue bold color={C.amber}>{active_test.name}</TermValue>
                </TermRow>
                <TermProgressBar
                  label="PROGRESS"
                  value={active_test.progress}
                  maxValue={100}
                  color={C.amber}
                  suffix="%"
                />
                <TermRow>
                  <TermLabel>TIME REMAINING</TermLabel>
                  <TermValue color={active_test.time_remaining < 30 ? C.redBright : C.textBright}>
                    {active_test.time_remaining}s
                  </TermValue>
                </TermRow>
                <Box style={{ display: 'flex', gap: '4px', marginTop: '6px' }}>
                  <TermButton color="red" onClick={() => act('cancel_test')}>
                    CANCEL TEST
                  </TermButton>
                </Box>
              </Box>
            )}

            <TermDivider />

            <TermHeader>AVAILABLE TESTS</TermHeader>
            {available_tests.length > 0 ? (
              available_tests.map((test) => {
                const canRun = clearance_level >= test.required_clearance;
                const isCompleted = completed_tests.includes(test.id);
                return (
                  <Box
                    key={test.id}
                    style={{
                      marginBottom: '4px',
                      padding: '8px',
                      borderLeft: `2px solid ${isCompleted ? C.green : getRiskColor(test.risk_level)}`,
                      background: C.panel,
                      opacity: canRun ? 1 : 0.5,
                    }}
                  >
                    <TermRow>
                      <TermValue bold color={C.amber}>{test.name}</TermValue>
                      <TermLabel style={{ marginLeft: '8px' }}>RISK</TermLabel>
                      <TermValue color={getRiskColor(test.risk_level)}>
                        {test.risk_level.toUpperCase()}
                      </TermValue>
                      <TermLabel style={{ marginLeft: '8px' }}>CLEARANCE</TermLabel>
                      <TermValue color={canRun ? C.green : C.redBright}>
                        {test.required_clearance}
                      </TermValue>
                      {isCompleted && (
                        <>
                          <TermLabel style={{ marginLeft: '8px' }}>STATUS</TermLabel>
                          <TermValue color={C.green}>COMPLETED</TermValue>
                        </>
                      )}
                    </TermRow>
                    <Box
                      style={term({
                        color: C.textDim,
                        fontSize: '11px',
                        fontStyle: 'italic',
                        marginTop: '2px',
                      })}
                    >
                      {test.description}
                    </Box>
                    <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                      <TermButton
                        color="green"
                        onClick={() => act('start_test', { id: test.id })}
                      >
                        START TEST
                      </TermButton>
                      {isCompleted && (
                        <TermButton
                          color="yellow"
                          onClick={() => act('review_results', { id: test.id })}
                        >
                          REVIEW RESULTS
                        </TermButton>
                      )}
                    </Box>
                  </Box>
                );
              })
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO TESTS AVAILABLE
              </Box>
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
              SCP FOUNDATION | TESTING PROTOCOL | ALL TESTS LOGGED AND MONITORED
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
