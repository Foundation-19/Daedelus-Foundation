import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input, Section, TextArea } from '../components';
import { Window } from '../layouts';

const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#0a6e0a',
  greenBright: '#44ff44',
  amber: '#d4a017',
  text: '#c8c8c8',
  textBright: '#e8e8e8',
  textDim: '#6a6a70',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const ACTION_TYPES = [
  'Written Warning',
  'Suspension',
  'Demotion',
  'Termination',
  'Amnestic Treatment',
];

const getActionColor = (actionType) => {
  switch (actionType) {
    case 'Written Warning':
      return C.amber;
    case 'Suspension':
      return '#d48017';
    case 'Demotion':
      return C.red;
    case 'Termination':
      return C.redBright;
    case 'Amnestic Treatment':
      return '#8844cc';
    default:
      return C.textDim;
  }
};

export const DisciplinaryConsole = (props) => {
  const { act, data } = useBackend();
  const { records = [], personnel = [] } = data;
  const [issueTarget, setIssueTarget] = useLocalState('dc_target', '');
  const [issueAction, setIssueAction] = useLocalState('dc_action', '');
  const [issueReason, setIssueReason] = useLocalState('dc_reason', '');

  return (
    <Window theme="scp_terminal" width={600} height={650}>
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
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              DISCIPLINARY ACTIONS CONSOLE
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SCP FOUNDATION | INTERNAL AFFAIRS | ALL ACTIONS ARE PERMANENT
            </Box>
          </Box>

          <Box style={{ padding: '14px' }}>
            <Box
              style={{
                fontSize: '10px',
                color: C.textDim,
                letterSpacing: '0.18em',
                textTransform: 'uppercase',
                borderBottom: `1px solid ${C.border}`,
                paddingBottom: '4px',
                marginBottom: '10px',
              }}
            >
              ISSUE NEW DISCIPLINARY ACTION
            </Box>

            <Box
              style={{
                marginBottom: '12px',
                padding: '8px',
                borderLeft: `2px solid ${C.amber}`,
                background: C.panel,
              }}
            >
              <Box style={{ marginBottom: '8px' }}>
                <Box
                  style={{
                    color: C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    marginBottom: '4px',
                  }}
                >
                  TARGET PERSONNEL
                </Box>
                <Dropdown
                  selected={issueTarget}
                  options={personnel.map((p) => p.name)}
                  onSelected={(value) => setIssueTarget(value)}
                />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box
                  style={{
                    color: C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    marginBottom: '4px',
                  }}
                >
                  ACTION TYPE
                </Box>
                <Dropdown
                  selected={issueAction}
                  options={ACTION_TYPES}
                  onSelected={(value) => setIssueAction(value)}
                />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box
                  style={{
                    color: C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    marginBottom: '4px',
                  }}
                >
                  REASON
                </Box>
                <TextArea
                  value={issueReason}
                  onChange={(e, value) => setIssueReason(value)}
                  placeholder="Enter reason for disciplinary action..."
                  style={{
                    fontFamily: C.mono,
                    fontSize: '11px',
                    width: '100%',
                    minHeight: '60px',
                    background: C.bg,
                    border: `1px solid ${C.border}`,
                    color: C.text,
                    borderRadius: 0,
                  }}
                />
              </Box>
              <Button
                onClick={() => {
                  act('issue_action', {
                    target: issueTarget,
                    action_type: issueAction,
                    reason: issueReason,
                  });
                  setIssueTarget('');
                  setIssueAction('');
                  setIssueReason('');
                }}
                disabled={!issueTarget || !issueAction || !issueReason}
                style={{
                  fontFamily: C.mono,
                  fontSize: '10px',
                  letterSpacing: '0.1em',
                  textTransform: 'uppercase',
                  background: 'rgba(139,0,0,0.35)',
                  border: `1px solid ${C.red}`,
                  borderRadius: 0,
                  color: C.textBright,
                  padding: '3px 8px',
                }}
              >
                ISSUE ACTION
              </Button>
            </Box>

            <Box
              style={{
                color: C.borderRed,
                fontSize: '10px',
                letterSpacing: '0.3em',
                margin: '10px 0',
                userSelect: 'none',
                overflow: 'hidden',
                whiteSpace: 'nowrap',
              }}
            >
              {'─'.repeat(60)}
            </Box>

            <Box
              style={{
                fontSize: '10px',
                color: C.textDim,
                letterSpacing: '0.18em',
                textTransform: 'uppercase',
                borderBottom: `1px solid ${C.border}`,
                paddingBottom: '4px',
                marginBottom: '10px',
              }}
            >
              ACTIVE DISCIPLINARY RECORDS — {records.length} RECORD{records.length !== 1 ? 'S' : ''}
            </Box>

            {records.length > 0 ? (
              records.map((record, idx) => (
                <Box
                  key={`${record.target}-${idx}`}
                  style={{
                    marginBottom: '6px',
                    padding: '8px',
                    borderLeft: `2px solid ${getActionColor(record.action_type)}`,
                    background: C.panel,
                  }}
                >
                  <Box
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      marginBottom: '4px',
                    }}
                  >
                    <Box>
                      <Box
                        style={{
                          color: C.textBright,
                          fontWeight: 'bold',
                          fontSize: '11px',
                        }}
                      >
                        {record.target}
                      </Box>
                      <Box
                        style={{
                          display: 'flex',
                          gap: '12px',
                          marginTop: '2px',
                        }}
                      >
                        <Box
                          as="span"
                          style={{
                            color: getActionColor(record.action_type),
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                            fontWeight: 'bold',
                          }}
                        >
                          {record.action_type?.toUpperCase()}
                        </Box>
                        <Box
                          as="span"
                          style={{
                            color: C.textDim,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                          }}
                        >
                          {record.date || 'N/A'}
                        </Box>
                      </Box>
                    </Box>
                    {!record.resolved && (
                      <Button
                        onClick={() => act('resolve', { target: record.target })}
                        style={{
                          fontFamily: C.mono,
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                          textTransform: 'uppercase',
                          background: 'rgba(26,122,26,0.35)',
                          border: `1px solid ${C.green}`,
                          borderRadius: 0,
                          color: C.greenBright,
                          padding: '3px 8px',
                        }}
                      >
                        RESOLVE
                      </Button>
                    )}
                  </Box>
                  <Box
                    style={{
                      color: C.textDim,
                      fontSize: '11px',
                      marginTop: '4px',
                    }}
                  >
                    {record.reason}
                  </Box>
                  {record.resolved && (
                    <Box
                      style={{
                        color: C.green,
                        fontSize: '10px',
                        letterSpacing: '0.1em',
                        marginTop: '4px',
                      }}
                    >
                      RESOLVED
                    </Box>
                  )}
                </Box>
              ))
            ) : (
              <Box
                style={{
                  color: C.textDim,
                  fontStyle: 'italic',
                  fontSize: '11px',
                }}
              >
                NO DISCIPLINARY RECORDS
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
              style={{
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | DISCIPLINARY CONSOLE | ALL ACTIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
