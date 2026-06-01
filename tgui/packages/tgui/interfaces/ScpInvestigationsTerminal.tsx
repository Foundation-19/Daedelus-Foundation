import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  evidence: Evidence[];
  cases: Case[];
  total_evidence: number;
  analyzed_evidence: number;
};

type Evidence = {
  evidence_id: string;
  type: string;
  collector: string;
  location: string;
  scp: string;
  description: string;
  analyzed: BooleanLike;
  result: string;
  time: number;
};

type Case = {
  name: string;
  description: string;
  status: string;
  evidence_count: number;
  time: number;
};

export const ScpInvestigationsTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { evidence, cases, total_evidence, analyzed_evidence } = data;
  const [invScp, setInvScp] = useState('');
  const [invDesc, setInvDesc] = useState('');

  return (
    <NtosWindow width={700} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="ANOMALOUS INVESTIGATIONS">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            EVIDENCE: {total_evidence} | ANALYZED: {analyzed_evidence} | OPEN CASES: {cases.filter((c) => c.status === 'open').length}
          </Box>
        </Section>

        <Section title="OPEN INVESTIGATION CASE">
          <Box style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
            <Input placeholder="SCP or case name..." value={invScp} onInput={(_e, value: string) => setInvScp(value)} style={{ width: '150px' }} />
            <Input placeholder="Description..." value={invDesc} onInput={(_e, value: string) => setInvDesc(value)} style={{ width: '250px' }} />
            <Button
              onClick={() => {
                act('open_case', { scp_name: invScp, description: invDesc });
                setInvScp('');
                setInvDesc('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '2px 8px' }}
            >
              OPEN CASE
            </Button>
          </Box>
        </Section>

        <Section title="EVIDENCE LOG">
          {evidence.map((e) => (
            <Box key={e.evidence_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${e.analyzed ? '#44ff44' : '#d4a017'}`, background: '#111114' }}>
              <Box style={{ color: e.analyzed ? '#44ff44' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {e.evidence_id} — {e.type} {e.scp ? `(${e.scp})` : ''}
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Collector: {e.collector} | Location: {e.location}
              </Box>
              <Box style={{ fontSize: '10px', color: '#8a8a90' }}>{e.description}</Box>
              {e.analyzed && <Box style={{ fontSize: '10px', color: '#44ff44' }}>Analysis: {e.result}</Box>}
              {!e.analyzed && (
                <Button
                  onClick={() => act('analyze_evidence', { evidence_id: e.evidence_id, result: 'Analysis complete — evidence consistent with anomalous origin' })}
                  style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px', marginTop: '4px' }}
                >
                  ANALYZE
                </Button>
              )}
            </Box>
          ))}
        </Section>

        {cases.length > 0 && (
          <Section title="INVESTIGATION CASES">
            {cases.map((c) => (
              <Box key={c.name} style={{ padding: '8px', marginBottom: '4px', borderLeft: `2px solid ${c.status === 'open' ? '#d4a017' : '#44ff44'}`, background: '#111114' }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Box>
                    <Box style={{ color: c.status === 'open' ? '#d4a017' : '#44ff44', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                      {c.name} — {c.status}
                    </Box>
                    <Box style={{ fontSize: '10px', color: '#8a8a90' }}>{c.description}</Box>
                  </Box>
                  {c.status === 'open' && (
                    <Button
                      onClick={() => act('close_case', { scp_name: c.name })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                    >
                      CLOSE
                    </Button>
                  )}
                </Box>
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
