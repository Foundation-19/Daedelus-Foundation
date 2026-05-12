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

const CLEARANCE_LEVELS = ['Level 1', 'Level 2', 'Level 3', 'Level 4', 'Level 5'];

const getStatusColor = (status) => {
  switch (status) {
    case 'pending':
      return C.amber;
    case 'approved':
      return C.greenBright;
    case 'denied':
      return C.redBright;
    default:
      return C.textDim;
  }
};

export const ClearanceReview = (props) => {
  const { act, data } = useBackend();
  const { requests = [], is_reviewer } = data;
  const [reqClearance, setReqClearance] = useLocalState('cr_clearance', '');
  const [reqJustification, setReqJustification] = useLocalState('cr_justification', '');
  const [reqSupervisor, setReqSupervisor] = useLocalState('cr_supervisor', '');
  const [reviewId, setReviewId] = useLocalState('cr_review_id', null);
  const [reviewNotes, setReviewNotes] = useLocalState('cr_review_notes', '');
  const [activeTab, setActiveTab] = useLocalState('cr_tab', 'pending');

  const pending = requests.filter((r) => r.status === 'pending');
  const approved = requests.filter((r) => r.status === 'approved');
  const denied = requests.filter((r) => r.status === 'denied');

  const tabRecords =
    activeTab === 'pending' ? pending :
    activeTab === 'approved' ? approved :
    denied;

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
              CLEARANCE REVIEW TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SCP FOUNDATION | ACCESS CONTROL | SECURITY PROTOCOL ACTIVE
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
              SUBMIT CLEARANCE REQUEST
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
                  REQUESTED CLEARANCE
                </Box>
                <Dropdown
                  selected={reqClearance}
                  options={CLEARANCE_LEVELS}
                  onSelected={(value) => setReqClearance(value)}
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
                  JUSTIFICATION
                </Box>
                <Input
                  value={reqJustification}
                  onChange={(e, value) => setReqJustification(value)}
                  placeholder="Enter justification..."
                  fluid
                  style={{
                    fontFamily: C.mono,
                    fontSize: '12px',
                  }}
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
                  SUPERVISOR
                </Box>
                <Input
                  value={reqSupervisor}
                  onChange={(e, value) => setReqSupervisor(value)}
                  placeholder="Enter supervisor name..."
                  fluid
                  style={{
                    fontFamily: C.mono,
                    fontSize: '12px',
                  }}
                />
              </Box>
              <Button
                onClick={() => {
                  act('submit_request', {
                    requested_clearance: reqClearance,
                    justification: reqJustification,
                    supervisor: reqSupervisor,
                  });
                  setReqClearance('');
                  setReqJustification('');
                  setReqSupervisor('');
                }}
                disabled={!reqClearance || !reqJustification || !reqSupervisor}
                style={{
                  fontFamily: C.mono,
                  fontSize: '10px',
                  letterSpacing: '0.1em',
                  textTransform: 'uppercase',
                  background: 'rgba(139,0,0,0.35)',
                  border: `1px solid ${C.borderRed}`,
                  borderRadius: 0,
                  color: C.textBright,
                  padding: '3px 8px',
                }}
              >
                SUBMIT REQUEST
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
                display: 'flex',
                borderBottom: `1px solid ${C.borderRed}`,
                marginBottom: '10px',
                background: C.panel,
              }}
            >
              {[
                { key: 'pending', label: 'PENDING' },
                { key: 'approved', label: 'APPROVED' },
                { key: 'denied', label: 'DENIED' },
              ].map((t) => {
                const isActive = activeTab === t.key;
                return (
                  <Box
                    key={t.key}
                    style={{
                      padding: '6px 12px',
                      cursor: 'pointer',
                      background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
                      borderBottom: isActive
                        ? `2px solid ${C.amber}`
                        : '2px solid transparent',
                      color: isActive ? C.textBright : C.textDim,
                      fontSize: '10px',
                      letterSpacing: '0.12em',
                      textTransform: 'uppercase',
                      fontFamily: C.mono,
                    }}
                    onClick={() => setActiveTab(t.key)}
                  >
                    {isActive && '▸ '}
                    {t.label}
                  </Box>
                );
              })}
            </Box>

            {tabRecords.length > 0 ? (
              tabRecords.map((req) => (
                <Box
                  key={req.id}
                  style={{
                    marginBottom: '6px',
                    padding: '8px',
                    borderLeft: `2px solid ${getStatusColor(req.status)}`,
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
                        {req.requester}
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
                            color: C.amber,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                          }}
                        >
                          {req.requested_clearance?.toUpperCase()}
                        </Box>
                        <Box
                          as="span"
                          style={{
                            color: getStatusColor(req.status),
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                            fontWeight: 'bold',
                          }}
                        >
                          {req.status?.toUpperCase()}
                        </Box>
                      </Box>
                    </Box>
                    {is_reviewer && req.status === 'pending' && (
                      <Box style={{ display: 'flex', gap: '4px' }}>
                        {reviewId === req.id ? (
                          <Box style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
                            <TextArea
                              value={reviewNotes}
                              onChange={(e, value) => setReviewNotes(value)}
                              placeholder="Review notes..."
                              style={{
                                fontFamily: C.mono,
                                fontSize: '11px',
                                width: '150px',
                                minHeight: '40px',
                                background: C.bg,
                                border: `1px solid ${C.border}`,
                                color: C.text,
                                borderRadius: 0,
                              }}
                            />
                            <Button
                              onClick={() => {
                                act('approve_request', {
                                  id: req.id,
                                  notes: reviewNotes,
                                });
                                setReviewId(null);
                                setReviewNotes('');
                              }}
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
                              APPROVE
                            </Button>
                            <Button
                              onClick={() => {
                                act('deny_request', {
                                  id: req.id,
                                  notes: reviewNotes,
                                });
                                setReviewId(null);
                                setReviewNotes('');
                              }}
                              style={{
                                fontFamily: C.mono,
                                fontSize: '10px',
                                letterSpacing: '0.1em',
                                textTransform: 'uppercase',
                                background: 'rgba(139,0,0,0.35)',
                                border: `1px solid ${C.red}`,
                                borderRadius: 0,
                                color: C.redBright,
                                padding: '3px 8px',
                              }}
                            >
                              DENY
                            </Button>
                            <Button
                              onClick={() => {
                                setReviewId(null);
                                setReviewNotes('');
                              }}
                              style={{
                                fontFamily: C.mono,
                                fontSize: '10px',
                                letterSpacing: '0.1em',
                                textTransform: 'uppercase',
                                background: 'transparent',
                                border: `1px solid ${C.border}`,
                                borderRadius: 0,
                                color: C.textDim,
                                padding: '3px 8px',
                              }}
                            >
                              CANCEL
                            </Button>
                          </Box>
                        ) : (
                          <Button
                            onClick={() => setReviewId(req.id)}
                            style={{
                              fontFamily: C.mono,
                              fontSize: '10px',
                              letterSpacing: '0.1em',
                              textTransform: 'uppercase',
                              background: 'rgba(212,160,23,0.2)',
                              border: `1px solid ${C.amber}`,
                              borderRadius: 0,
                              color: C.amber,
                              padding: '3px 8px',
                            }}
                          >
                            REVIEW
                          </Button>
                        )}
                      </Box>
                    )}
                  </Box>
                  <Box
                    style={{
                      color: C.textDim,
                      fontSize: '11px',
                      marginTop: '4px',
                    }}
                  >
                    {req.justification}
                  </Box>
                  {req.notes && (
                    <Box
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        marginTop: '4px',
                        fontStyle: 'italic',
                      }}
                    >
                      NOTES: {req.notes}
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
                NO {activeTab.toUpperCase()} REQUESTS
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
              SCP FOUNDATION | CLEARANCE REVIEW | ALL DECISIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
