import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  card_name: string;
  card_owner: string;
  card_assignment: string;
  card_access_list: string[];
  printing: BooleanLike;
  ink_remaining: number;
};

export const FoundationIDPrinter = (props) => {
  const { act, data } = useBackend<Data>();
  const { card_name, card_owner, card_assignment, card_access_list, printing, ink_remaining } = data;

  return (
    <Window theme="scp_terminal" width={450} height={500}>
      <Window.Content scrollable>
        <Section title="SCP FOUNDATION — ID CARD PRINTER">
          <Box
            style={{
              fontFamily: 'monospace',
              color: '#d4a017',
              fontSize: '12px',
              marginBottom: '8px',
              padding: '8px',
              background: 'rgba(20,20,25,0.8)',
              border: '1px solid #2a2a30',
            }}
          >
            PERSONNEL IDENTIFICATION CARD MANUFACTURING SYSTEM
          </Box>
        </Section>
        <Section title="CARD DATA">
          <LabeledList>
            <LabeledList.Item label="Card Name">
              <Box style={{ color: '#d4a017', fontFamily: 'monospace' }}>
                {card_name || 'UNCONFIGURED'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Owner">
              <Box style={{ color: '#c8c8c8', fontFamily: 'monospace' }}>
                {card_owner || 'NONE'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Assignment">
              <Box style={{ color: '#c8c8c8', fontFamily: 'monospace' }}>
                {card_assignment || 'NONE'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Ink Level">
              <Box style={{
                color: ink_remaining > 25 ? '#1a7a1a' : ink_remaining > 10 ? '#d4a017' : '#8b0000',
                fontFamily: 'monospace',
              }}>
                {ink_remaining}%
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="CARD CONFIGURATION">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
              <Box style={{ color: '#c8c8c8', fontFamily: 'monospace', minWidth: '100px' }}>
                CARD NAME:
              </Box>
              <Input
                placeholder="Enter card name..."
                onEnter={(e, value) => act('set_name', { name: value })}
                style={{
                  fontFamily: 'monospace',
                  background: 'rgba(20,20,25,0.8)',
                  border: '1px solid #2a2a30',
                  color: '#d4a017',
                  padding: '4px 8px',
                }}
              />
            </Box>
            <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
              <Box style={{ color: '#c8c8c8', fontFamily: 'monospace', minWidth: '100px' }}>
                ASSIGNMENT:
              </Box>
              <Input
                placeholder="Enter assignment..."
                onEnter={(e, value) => act('set_assignment', { assignment: value })}
                style={{
                  fontFamily: 'monospace',
                  background: 'rgba(20,20,25,0.8)',
                  border: '1px solid #2a2a30',
                  color: '#d4a017',
                  padding: '4px 8px',
                }}
              />
            </Box>
          </Box>
        </Section>
        <Section title="ACCESS LIST">
          <Box
            style={{
              background: 'rgba(20,20,25,0.8)',
              border: '1px solid #2a2a30',
              padding: '8px',
              fontFamily: 'monospace',
              maxHeight: '120px',
              overflowY: 'auto',
            }}
          >
            {card_access_list && card_access_list.length > 0 ? (
              card_access_list.map((access, index) => (
                <Box key={index} style={{ color: '#1a7a1a', fontSize: '12px' }}>
                  {access}
                </Box>
              ))
            ) : (
              <Box style={{ color: '#555560' }}>NO ACCESS ENTRIES</Box>
            )}
          </Box>
        </Section>
        <Section title="PRINT">
          <Button
            onClick={() => act('print_card')}
            disabled={printing || ink_remaining <= 0}
            style={{
              fontFamily: 'monospace',
              background: printing ? 'rgba(212,160,23,0.3)' : 'rgba(139,0,0,0.3)',
              border: `1px solid ${printing ? '#d4a017' : '#8b0000'}`,
              color: printing ? '#d4a017' : '#cc2222',
              padding: '8px 16px',
              fontWeight: 'bold',
              fontSize: '14px',
            }}
          >
            {printing ? 'PRINTING...' : 'PRINT CARD'}
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
