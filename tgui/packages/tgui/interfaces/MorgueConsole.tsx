import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, TextArea } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton } from './CharacterSetup/shared';

interface Body {
  name: string;
  cause_of_death: string;
  time_of_death: string;
  drawer: number;
  status: string;
}

interface SelectedBody extends Body {
  notes: string;
}

interface Data {
  bodies: Body[];
  selected_body: SelectedBody | null;
  total_drawers: number;
  occupied_drawers: number;
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'unprocessed':
      return C.redBright;
    case 'processed':
      return C.amber;
    case 'released':
      return C.green;
    default:
      return C.textDim;
  }
};

export const MorgueConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const [noteText, setNoteText] = useLocalState('morgueNotes', '');

  const {
    bodies = [],
    selected_body,
    total_drawers,
    occupied_drawers,
  } = data;

  return (
    <Window width={850} height={600} theme="scp_terminal">
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
              MORGUE MANAGEMENT CONSOLE
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              MEDICAL EXAMINATION & BODY STORAGE | MORTUARY SERVICES
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>FACILITY STATUS</TermHeader>
            <TermRow>
              <TermLabel>OCCUPIED</TermLabel>
              <TermValue color={occupied_drawers > total_drawers * 0.8 ? C.redBright : C.amber}>
                {occupied_drawers}
              </TermValue>
              <TermValue color={C.textDim}>/{total_drawers}</TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>AVAILABLE</TermLabel>
              <TermValue color={C.green}>{total_drawers - occupied_drawers}</TermValue>
            </TermRow>

            <TermDivider />

            {selected_body ? (
              <Box>
                <TermHeader>SELECTED BODY — DRAWER {selected_body.drawer}</TermHeader>
                <TermRow>
                  <TermLabel>NAME</TermLabel>
                  <TermValue bold color={C.amber}>{selected_body.name}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>CAUSE OF DEATH</TermLabel>
                  <TermValue color={C.textBright}>{selected_body.cause_of_death}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>TIME OF DEATH</TermLabel>
                  <TermValue color={C.textDim}>{selected_body.time_of_death}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>STATUS</TermLabel>
                  <TermValue color={getStatusColor(selected_body.status)}>
                    {selected_body.status.toUpperCase()}
                  </TermValue>
                </TermRow>
                <TermDivider />
                <TermLabel>NOTES</TermLabel>
                <TextArea
                  value={noteText || selected_body.notes || ''}
                  onChange={(e, value) => setNoteText(value)}
                  placeholder="Enter examination notes..."
                  style={{
                    fontFamily: C.mono,
                    fontSize: '11px',
                    height: '80px',
                    background: C.panel,
                    border: `1px solid ${C.border}`,
                    color: C.text,
                    marginTop: '4px',
                  }}
                />
                <Box style={{ display: 'flex', gap: '4px', marginTop: '8px' }}>
                  <TermButton
                    color="yellow"
                    onClick={() => act('update_notes', { notes: noteText || selected_body.notes })}
                  >
                    SAVE NOTES
                  </TermButton>
                  <TermButton
                    color="green"
                    onClick={() => act('mark_processed', { drawer: selected_body.drawer })}
                  >
                    MARK PROCESSED
                  </TermButton>
                  <TermButton
                    color="green"
                    onClick={() => act('release_body', { drawer: selected_body.drawer })}
                  >
                    RELEASE BODY
                  </TermButton>
                  <TermButton onClick={() => act('select_body', { drawer: -1 })}>
                    DESELECT
                  </TermButton>
                </Box>
              </Box>
            ) : (
              <Box>
                <TermHeader>STORED BODIES</TermHeader>
                {bodies.length > 0 ? (
                  bodies.map((body) => (
                    <Box
                      key={body.drawer}
                      style={{
                        marginBottom: '2px',
                        padding: '6px 8px',
                        borderLeft: `2px solid ${getStatusColor(body.status)}`,
                        background: C.panel,
                        cursor: 'pointer',
                      }}
                      onClick={() => {
                        act('select_body', { drawer: body.drawer });
                        setNoteText('');
                      }}
                    >
                      <TermRow>
                        <TermLabel>#{body.drawer}</TermLabel>
                        <TermValue bold color={C.amber}>{body.name}</TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>CAUSE</TermLabel>
                        <TermValue color={C.textDim}>{body.cause_of_death}</TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>STATUS</TermLabel>
                        <TermValue color={getStatusColor(body.status)}>
                          {body.status.toUpperCase()}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          {body.time_of_death}
                        </TermLabel>
                      </TermRow>
                    </Box>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                    NO BODIES IN STORAGE
                  </Box>
                )}
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
              SCP FOUNDATION | MORGUE MANAGEMENT | MEDICAL EXAMINATION PROTOCOL
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
