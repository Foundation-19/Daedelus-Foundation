import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, TextArea } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermModal } from './CharacterSetup/shared';

interface Email {
  id: string;
  sender: string;
  subject: string;
  timestamp: string;
  read: BooleanLike;
  priority: string;
}

interface CurrentEmail {
  sender: string;
  subject: string;
  body: string;
  timestamp: string;
}

interface Data {
  emails: Email[];
  current_email: CurrentEmail | null;
  can_compose: BooleanLike;
}

const getPriorityColor = (priority: string) => {
  switch (priority) {
    case 'urgent':
      return C.redBright;
    case 'high':
      return C.amber;
    case 'normal':
      return C.textDim;
    case 'low':
      return C.green;
    default:
      return C.textDim;
  }
};

export const FoundationEmail = (props) => {
  const { act, data } = useBackend<Data>();
  const [showCompose, setShowCompose] = useLocalState('showCompose', false);
  const [composeTo, setComposeTo] = useLocalState('composeTo', '');
  const [composeSubject, setComposeSubject] = useLocalState('composeSubject', '');
  const [composeBody, setComposeBody] = useLocalState('composeBody', '');

  const {
    emails = [],
    current_email,
    can_compose,
  } = data;

  const unreadCount = emails.filter((e) => !e.read).length;

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
              FOUNDATION EMAIL TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SECURE COMMUNICATIONS | ENCRYPTED CHANNEL | UNREAD: {unreadCount}
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            {current_email ? (
              <Box>
                <TermHeader>READING EMAIL</TermHeader>
                <TermRow>
                  <TermLabel>FROM</TermLabel>
                  <TermValue bold color={C.amber}>{current_email.sender}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>SUBJECT</TermLabel>
                  <TermValue color={C.textBright}>{current_email.subject}</TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>RECEIVED</TermLabel>
                  <TermValue color={C.textDim}>{current_email.timestamp}</TermValue>
                </TermRow>
                <TermDivider />
                <Box
                  style={{
                    background: C.panel,
                    border: `1px solid ${C.border}`,
                    padding: '12px',
                    minHeight: '150px',
                    whiteSpace: 'pre-wrap',
                    ...term({ fontSize: '11px' }),
                  }}
                >
                  {current_email.body}
                </Box>
                <Box style={{ display: 'flex', gap: '4px', marginTop: '8px' }}>
                  <TermButton onClick={() => act('close_email')}>
                    BACK TO INBOX
                  </TermButton>
                </Box>
              </Box>
            ) : (
              <Box>
                <TermHeader>INBOX — {emails.length} MESSAGES</TermHeader>
                <Box style={{ display: 'flex', gap: '4px', marginBottom: '8px' }}>
                  {!!can_compose && (
                    <TermButton color="green" onClick={() => setShowCompose(true)}>
                      COMPOSE
                    </TermButton>
                  )}
                </Box>
                {emails.length > 0 ? (
                  emails.map((email) => (
                    <Box
                      key={email.id}
                      style={{
                        marginBottom: '2px',
                        padding: '6px 8px',
                        borderLeft: `2px solid ${getPriorityColor(email.priority)}`,
                        background: email.read ? C.panel : 'rgba(212,160,23,0.06)',
                        cursor: 'pointer',
                      }}
                      onClick={() => act('open_email', { id: email.id })}
                    >
                      <TermRow>
                        <TermValue
                          bold={!email.read}
                          color={email.read ? C.textDim : C.amber}
                        >
                          {email.subject}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>FROM</TermLabel>
                        <TermValue color={C.textBright}>{email.sender}</TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>PRIORITY</TermLabel>
                        <TermValue color={getPriorityColor(email.priority)}>
                          {email.priority.toUpperCase()}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          {email.timestamp}
                        </TermLabel>
                      </TermRow>
                      <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                        <TermButton
                          color="red"
                          onClick={(e) => {
                            e.stopPropagation();
                            act('delete_email', { id: email.id });
                          }}
                        >
                          DELETE
                        </TermButton>
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                    NO MESSAGES
                  </Box>
                )}
              </Box>
            )}
          </Box>

          {showCompose && (
            <TermModal>
              <TermHeader>COMPOSE EMAIL</TermHeader>
              <Box style={{ marginBottom: '10px' }}>
                <TermLabel>TO</TermLabel>
                <Input
                  value={composeTo}
                  onChange={(e, value) => setComposeTo(value)}
                  placeholder="Recipient..."
                  style={{ fontFamily: C.mono, fontSize: '14px', height: '32px' }}
                />
              </Box>
              <Box style={{ marginBottom: '10px' }}>
                <TermLabel>SUBJECT</TermLabel>
                <Input
                  value={composeSubject}
                  onChange={(e, value) => setComposeSubject(value)}
                  placeholder="Subject..."
                  style={{ fontFamily: C.mono, fontSize: '14px', height: '32px' }}
                />
              </Box>
              <Box style={{ marginBottom: '10px' }}>
                <TermLabel>BODY</TermLabel>
                <TextArea
                  value={composeBody}
                  onChange={(e, value) => setComposeBody(value)}
                  placeholder="Message body..."
                  style={{
                    fontFamily: C.mono,
                    fontSize: '12px',
                    height: '120px',
                    background: C.panel,
                    border: `1px solid ${C.border}`,
                    color: C.text,
                  }}
                />
              </Box>
              <Box style={{ display: 'flex', gap: '4px' }}>
                <TermButton
                  color="green"
                  onClick={() => {
                    act('compose', {
                      to: composeTo,
                      subject: composeSubject,
                      body: composeBody,
                    });
                    setShowCompose(false);
                    setComposeTo('');
                    setComposeSubject('');
                    setComposeBody('');
                  }}
                >
                  SEND
                </TermButton>
                <TermButton color="red" onClick={() => setShowCompose(false)}>
                  CANCEL
                </TermButton>
              </Box>
            </TermModal>
          )}

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
              SCP FOUNDATION | EMAIL TERMINAL | ENCRYPTED COMMUNICATIONS PROTOCOL
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
