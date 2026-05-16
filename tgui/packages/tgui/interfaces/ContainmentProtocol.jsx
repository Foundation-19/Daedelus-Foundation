import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, TextArea } from '../components';
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

const getStatusColor = (status) => {
  switch (status) {
    case 'Contained':
      return C.greenBright;
    case 'Stable':
      return C.green;
    case 'Degrading':
      return C.amber;
    case 'Breached':
      return C.redBright;
    default:
      return C.textDim;
  }
};

export const ContainmentProtocol = (props) => {
  const { act, data } = useBackend();
  const { scp_list = [] } = data;
  const [selectedSCP, setSelectedSCP] = useLocalState('cp_selected', null);
  const [containmentEdit, setContainmentEdit] = useLocalState('cp_contain_edit', '');
  const [recontainmentEdit, setRecontainmentEdit] = useLocalState('cp_recontain_edit', '');

  const selected = scp_list.find((s) => s.scp_id === selectedSCP);

  const handleSelect = (scp) => {
    setSelectedSCP(scp.scp_id);
    setContainmentEdit(scp.containment_procedures || '');
    setRecontainmentEdit(scp.recontainment_procedures || '');
  };

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
              CONTAINMENT PROTOCOL EDITOR
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SCP FOUNDATION | PROTOCOL MANAGEMENT | AUTHORIZED PERSONNEL ONLY
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
              SCP SELECTOR — {scp_list.length} ENTIT{scp_list.length !== 1 ? 'IES' : 'Y'}
            </Box>

            {scp_list.length > 0 ? (
              scp_list.map((scp) => (
                <Box
                  key={scp.scp_id}
                  style={{
                    marginBottom: '4px',
                    padding: '8px',
                    borderLeft: `2px solid ${selectedSCP === scp.scp_id ? C.amber : getStatusColor(scp.status)}`,
                    background: selectedSCP === scp.scp_id
                      ? 'rgba(212,160,23,0.1)'
                      : C.panel,
                    cursor: 'pointer',
                  }}
                  onClick={() => handleSelect(scp)}
                >
                  <Box
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <Box>
                      <Box
                        style={{
                          color: selectedSCP === scp.scp_id ? C.amber : C.textBright,
                          fontWeight: 'bold',
                          fontSize: '11px',
                        }}
                      >
                        {scp.name}
                      </Box>
                      <Box
                        as="span"
                        style={{
                          color: C.textDim,
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                        }}
                      >
                        {scp.scp_id}
                      </Box>
                    </Box>
                    <Box
                      style={{
                        color: getStatusColor(scp.status),
                        fontSize: '10px',
                        letterSpacing: '0.1em',
                        fontWeight: 'bold',
                      }}
                    >
                      {scp.status?.toUpperCase()}
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
                NO SCP RECORDS FOUND
              </Box>
            )}

            {selected && (
              <>
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
                  EDITING PROTOCOLS — {selected.name} ({selected.scp_id})
                </Box>

                <Box
                  style={{
                    marginBottom: '12px',
                    padding: '8px',
                    borderLeft: `2px solid ${C.borderRed}`,
                    background: C.panel,
                  }}
                >
                  <Box
                    style={{
                      color: C.amber,
                      fontSize: '10px',
                      letterSpacing: '0.12em',
                      marginBottom: '6px',
                    }}
                  >
                    CONTAINMENT PROCEDURES
                  </Box>
                  <TextArea
                    value={containmentEdit}
                    onChange={(e, value) => setContainmentEdit(value)}
                    placeholder="Enter containment procedures..."
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      width: '100%',
                      minHeight: '100px',
                      background: C.bg,
                      border: `1px solid ${C.border}`,
                      color: C.text,
                      borderRadius: 0,
                    }}
                  />
                  <Box style={{ marginTop: '6px' }}>
                    <Button
                      onClick={() =>
                        act('update_containment', {
                          scp_id: selected.scp_id,
                          procedures: containmentEdit,
                        })
                      }
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
                      SAVE CONTAINMENT
                    </Button>
                  </Box>
                </Box>

                <Box
                  style={{
                    marginBottom: '12px',
                    padding: '8px',
                    borderLeft: `2px solid ${C.red}`,
                    background: C.panel,
                  }}
                >
                  <Box
                    style={{
                      color: C.redBright,
                      fontSize: '10px',
                      letterSpacing: '0.12em',
                      marginBottom: '6px',
                    }}
                  >
                    RECONTAINMENT PROCEDURES
                  </Box>
                  <TextArea
                    value={recontainmentEdit}
                    onChange={(e, value) => setRecontainmentEdit(value)}
                    placeholder="Enter recontainment procedures..."
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      width: '100%',
                      minHeight: '100px',
                      background: C.bg,
                      border: `1px solid ${C.border}`,
                      color: C.text,
                      borderRadius: 0,
                    }}
                  />
                  <Box style={{ marginTop: '6px' }}>
                    <Button
                      onClick={() =>
                        act('update_recontainment', {
                          scp_id: selected.scp_id,
                          procedures: recontainmentEdit,
                        })
                      }
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
                      SAVE RECONTAINMENT
                    </Button>
                  </Box>
                </Box>
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
              style={{
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | CONTAINMENT PROTOCOL EDITOR | ALL CHANGES LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
