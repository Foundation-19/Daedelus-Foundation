import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input, Section, Table } from '../components';
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

export const PersonnelManagement = (props) => {
  const { act, data } = useBackend();
  const { personnel = [], departments = [] } = data;
  const [deptFilter, setDeptFilter] = useLocalState('pm_dept_filter', 'All');
  const [transferTarget, setTransferTarget] = useLocalState('pm_transfer', null);
  const [transferDept, setTransferDept] = useLocalState('pm_transfer_dept', '');
  const [reassignTarget, setReassignTarget] = useLocalState('pm_reassign', null);
  const [reassignRank, setReassignRank] = useLocalState('pm_reassign_rank', '');

  const filtered = deptFilter === 'All'
    ? personnel
    : personnel.filter((p) => p.department === deptFilter);

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
              PERSONNEL MANAGEMENT TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SCP FOUNDATION | HUMAN RESOURCES DIVISION | CLEARANCE 3 REQUIRED
            </Box>
          </Box>

          <Box style={{ padding: '14px' }}>
            <Section
              title="FILTER BY DEPARTMENT"
              style={{
                background: C.panel,
                border: `1px solid ${C.border}`,
                marginBottom: '12px',
              }}
            >
              <Dropdown
                selected={deptFilter}
                options={['All', ...departments]}
                onSelected={(value) => setDeptFilter(value)}
              />
            </Section>

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
              PERSONNEL ROSTER — {filtered.length} RECORD{filtered.length !== 1 ? 'S' : ''}
            </Box>

            {filtered.length > 0 ? (
              filtered.map((person) => (
                <Box
                  key={person.name}
                  style={{
                    marginBottom: '6px',
                    padding: '8px',
                    borderLeft: `2px solid ${C.borderRed}`,
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
                        {person.name}
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
                          RANK: {person.rank}
                        </Box>
                        <Box
                          as="span"
                          style={{
                            color: C.textDim,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                          }}
                        >
                          DEPT: {person.department}
                        </Box>
                      </Box>
                    </Box>
                    <Box style={{ display: 'flex', gap: '4px' }}>
                      {transferTarget === person.name ? (
                        <Box style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
                          <Dropdown
                            selected={transferDept}
                            options={departments}
                            onSelected={(value) => setTransferDept(value)}
                          />
                          <Button
                            onClick={() => {
                              act('transfer', {
                                name: person.name,
                                department: transferDept,
                              });
                              setTransferTarget(null);
                              setTransferDept('');
                            }}
                            disabled={!transferDept}
                            style={{
                              fontFamily: C.mono,
                              fontSize: '10px',
                              letterSpacing: '0.1em',
                              textTransform: 'uppercase',
                              background: 'rgba(26,122,26,0.35)',
                              border: `1px solid ${C.green}`,
                              borderRadius: 0,
                              color: C.textBright,
                              padding: '3px 8px',
                            }}
                          >
                            CONFIRM
                          </Button>
                          <Button
                            onClick={() => {
                              setTransferTarget(null);
                              setTransferDept('');
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
                          onClick={() => setTransferTarget(person.name)}
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
                          TRANSFER
                        </Button>
                      )}
                      {reassignTarget === person.name ? (
                        <Box style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
                          <Input
                            value={reassignRank}
                            onChange={(e, value) => setReassignRank(value)}
                            placeholder="New rank..."
                            style={{
                              fontFamily: C.mono,
                              fontSize: '12px',
                              height: '24px',
                            }}
                          />
                          <Button
                            onClick={() => {
                              act('reassign', {
                                name: person.name,
                                rank: reassignRank,
                              });
                              setReassignTarget(null);
                              setReassignRank('');
                            }}
                            disabled={!reassignRank}
                            style={{
                              fontFamily: C.mono,
                              fontSize: '10px',
                              letterSpacing: '0.1em',
                              textTransform: 'uppercase',
                              background: 'rgba(26,122,26,0.35)',
                              border: `1px solid ${C.green}`,
                              borderRadius: 0,
                              color: C.textBright,
                              padding: '3px 8px',
                            }}
                          >
                            CONFIRM
                          </Button>
                          <Button
                            onClick={() => {
                              setReassignTarget(null);
                              setReassignRank('');
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
                          onClick={() => setReassignTarget(person.name)}
                          style={{
                            fontFamily: C.mono,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                            textTransform: 'uppercase',
                            background: 'rgba(139,0,0,0.2)',
                            border: `1px solid ${C.border}`,
                            borderRadius: 0,
                            color: C.text,
                            padding: '3px 8px',
                          }}
                        >
                          REASSIGN
                        </Button>
                      )}
                    </Box>
                  </Box>
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
                NO PERSONNEL RECORDS FOUND
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
              SCP FOUNDATION | PERSONNEL MANAGEMENT | ALL ACTIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
