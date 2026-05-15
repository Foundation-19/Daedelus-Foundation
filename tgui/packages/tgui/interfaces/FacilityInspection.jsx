import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Section, TextArea } from '../components';
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

const DEPARTMENTS = [
  'Command',
  'Security',
  'Medical',
  'Science',
  'Engineering',
  'Logistics',
  'D-Class Management',
  'MTF Operations',
];

const INSPECTION_TYPES = [
  'Containment Integrity',
  'Security Compliance',
  'Personnel Readiness',
  'Medical Preparedness',
  'Engineering Status',
];

const getRatingColor = (rating) => {
  if (rating >= 90) return C.greenBright;
  if (rating >= 70) return C.green;
  if (rating >= 50) return C.amber;
  if (rating >= 30) return C.red;
  return C.redBright;
};

export const FacilityInspection = (props) => {
  const { act, data } = useBackend();
  const { reports = [] } = data;
  const [newDept, setNewDept] = useLocalState('fi_dept', '');
  const [newType, setNewType] = useLocalState('fi_type', '');
  const [notesId, setNotesId] = useLocalState('fi_notes_id', null);
  const [notesText, setNotesText] = useLocalState('fi_notes_text', '');

  return (
    <Window theme="scp_terminal" width={600} height={700}>
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
              FACILITY INSPECTION TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SCP FOUNDATION | QUALITY ASSURANCE | SITE INSPECTION PROTOCOL
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
              BEGIN NEW INSPECTION
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
                  DEPARTMENT
                </Box>
                <Dropdown
                  selected={newDept}
                  options={DEPARTMENTS}
                  onSelected={(value) => setNewDept(value)}
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
                  INSPECTION TYPE
                </Box>
                <Dropdown
                  selected={newType}
                  options={INSPECTION_TYPES}
                  onSelected={(value) => setNewType(value)}
                />
              </Box>
              <Button
                onClick={() => {
                  act('begin_inspection', {
                    department: newDept,
                    type: newType,
                  });
                  setNewDept('');
                  setNewType('');
                }}
                disabled={!newDept || !newType}
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
                BEGIN INSPECTION
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
              INSPECTION REPORTS — {reports.length} RECORD{reports.length !== 1 ? 'S' : ''}
            </Box>

            {reports.length > 0 ? (
              reports.map((report) => (
                <Box
                  key={report.id}
                  style={{
                    marginBottom: '6px',
                    padding: '8px',
                    borderLeft: `2px solid ${getRatingColor(report.rating)}`,
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
                        {report.department} — {report.type}
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
                            color: C.textDim,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                          }}
                        >
                          INSPECTOR: {report.inspector}
                        </Box>
                        <Box
                          as="span"
                          style={{
                            color: getRatingColor(report.rating),
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                            fontWeight: 'bold',
                          }}
                        >
                          RATING: {report.rating}%
                        </Box>
                      </Box>
                    </Box>
                  </Box>
                  {report.findings && (
                    <Box
                      style={{
                        color: C.text,
                        fontSize: '11px',
                        marginTop: '4px',
                      }}
                    >
                      {report.findings}
                    </Box>
                  )}
                  {report.notes && (
                    <Box
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        marginTop: '4px',
                        fontStyle: 'italic',
                      }}
                    >
                      NOTES: {report.notes}
                    </Box>
                  )}
                  {report.follow_up && (
                    <Box
                      style={{
                        color: C.amber,
                        fontSize: '10px',
                        marginTop: '2px',
                        letterSpacing: '0.1em',
                      }}
                    >
                      FOLLOW-UP REQUIRED
                    </Box>
                  )}
                  {notesId === report.id ? (
                    <Box style={{ marginTop: '6px' }}>
                      <TextArea
                        value={notesText}
                        onChange={(e, value) => setNotesText(value)}
                        placeholder="Add inspection notes..."
                        style={{
                          fontFamily: C.mono,
                          fontSize: '11px',
                          width: '100%',
                          minHeight: '50px',
                          background: C.bg,
                          border: `1px solid ${C.border}`,
                          color: C.text,
                          borderRadius: 0,
                        }}
                      />
                      <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                        <Button
                          onClick={() => {
                            act('add_notes', {
                              id: report.id,
                              notes: notesText,
                            });
                            setNotesId(null);
                            setNotesText('');
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
                          SAVE
                        </Button>
                        <Button
                          onClick={() => {
                            setNotesId(null);
                            setNotesText('');
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
                    </Box>
                  ) : (
                    <Box style={{ marginTop: '4px' }}>
                      <Button
                        onClick={() => setNotesId(report.id)}
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
                        ADD NOTES
                      </Button>
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
                NO INSPECTION REPORTS
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
              SCP FOUNDATION | FACILITY INSPECTION | ALL REPORTS ARCHIVED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
