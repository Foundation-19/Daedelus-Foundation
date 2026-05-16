import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type VoteData = {
  id: number;
  title: string;
  description: string;
  yes_votes: number;
  no_votes: number;
  required: number;
  status: string;
  initiator: string;
};

type Data = {
  active_votes: VoteData[];
};

const VOTE_STATUS_COLORS: Record<string, string> = {
  active: '#d4a017',
  passed: '#1a7a1a',
  failed: '#8b0000',
  pending: '#555560',
};

export const O5Council = (props) => {
  const { act, data } = useBackend<Data>();
  const { active_votes } = data;

  return (
    <Window theme="scp_terminal" width={600} height={500}>
      <Window.Content scrollable>
        <Section title="SCP FOUNDATION — O5 COUNCIL TERMINAL">
          <Box
            style={{
              fontFamily: 'monospace',
              color: '#d4a017',
              fontSize: '14px',
              marginBottom: '8px',
              padding: '8px',
              background: 'rgba(20,20,25,0.8)',
              border: '1px solid #2a2a30',
            }}
          >
            CLASSIFIED — O5 EYES ONLY — SECURITY CLEARANCE 5 REQUIRED
          </Box>
        </Section>
        <Section title="COUNCIL ACTIONS">
          <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            <Button
              onClick={() => act('call_vote', { title: 'Emergency Protocol', description: 'Emergency vote called by O5 member.' })}
              style={{
                fontFamily: 'monospace',
                background: 'rgba(139,0,0,0.3)',
                border: '1px solid #8b0000',
                color: '#cc2222',
                padding: '6px 12px',
              }}
            >
              CALL EMERGENCY VOTE
            </Button>
            <Button
              onClick={() => act('authorize_warhead')}
              style={{
                fontFamily: 'monospace',
                background: 'rgba(204,34,34,0.3)',
                border: '1px solid #cc2222',
                color: '#ff4444',
                padding: '6px 12px',
                fontWeight: 'bold',
              }}
            >
              AUTHORIZE WARHEAD
            </Button>
          </Box>
        </Section>
        <Section title="ACTIVE VOTES">
          {active_votes && active_votes.length > 0 ? (
            active_votes.map((vote) => (
              <Box
                key={vote.id}
                style={{
                  background: 'rgba(20,20,25,0.8)',
                  border: '1px solid #2a2a30',
                  padding: '10px',
                  marginBottom: '8px',
                  fontFamily: 'monospace',
                }}
              >
                <Box style={{ color: '#d4a017', fontWeight: 'bold', fontSize: '14px' }}>
                  {vote.title}
                </Box>
                <Box style={{ color: '#c8c8c8', fontSize: '12px', marginBottom: '6px' }}>
                  {vote.description}
                </Box>
                <LabeledList>
                  <LabeledList.Item label="Status">
                    <Box style={{ color: VOTE_STATUS_COLORS[vote.status] || '#555560', fontWeight: 'bold' }}>
                      {(vote.status || 'UNKNOWN').toUpperCase()}
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Initiator">
                    {vote.initiator}
                  </LabeledList.Item>
                  <LabeledList.Item label="Votes">
                    <Box style={{ color: '#1a7a1a' }}>YES: {vote.yes_votes}</Box>
                    <Box style={{ color: '#8b0000' }}>NO: {vote.no_votes}</Box>
                    <Box style={{ color: '#555560' }}>REQUIRED: {vote.required}</Box>
                  </LabeledList.Item>
                </LabeledList>
                {vote.status === 'active' && (
                  <Box style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                    <Button
                      onClick={() => act('cast_vote', { vote_id: vote.id, choice: 'yes' })}
                      style={{
                        fontFamily: 'monospace',
                        background: 'rgba(26,122,26,0.3)',
                        border: '1px solid #1a7a1a',
                        color: '#44ff44',
                        padding: '6px 12px',
                      }}
                    >
                      VOTE YES
                    </Button>
                    <Button
                      onClick={() => act('cast_vote', { vote_id: vote.id, choice: 'no' })}
                      style={{
                        fontFamily: 'monospace',
                        background: 'rgba(139,0,0,0.3)',
                        border: '1px solid #8b0000',
                        color: '#cc2222',
                        padding: '6px 12px',
                      }}
                    >
                      VOTE NO
                    </Button>
                  </Box>
                )}
              </Box>
            ))
          ) : (
            <Box style={{ color: '#555560', fontFamily: 'monospace' }}>
              NO ACTIVE VOTES
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
