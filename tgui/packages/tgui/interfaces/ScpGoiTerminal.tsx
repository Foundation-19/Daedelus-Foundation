import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  intel: IntelEntry[];
  standing: StandingEntry[];
  communiques: Communique[];
  total_intel: number;
  total_communiques: number;
};

type IntelEntry = {
  intel_id: string;
  goi: string;
  type: string;
  classification: string;
  findings: string;
  recommendations: string;
  analyst: string;
  verified: BooleanLike;
  time: number;
};

type StandingEntry = {
  goi: string;
  standing: number;
};

type Communique = {
  communique_id: string;
  goi: string;
  sender: string;
  message: string;
  response: string;
  responded: BooleanLike;
  priority: number;
  time: number;
};

const STANDING_COLOR = (s: number) => (s >= 60 ? '#44ff44' : s >= 30 ? '#d4a017' : '#cc2222');

export const ScpGoiTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { intel, standing, communiques, total_intel, total_communiques } = data;
  const [goiName, setGoiName] = useState('');
  const [goiItype, setGoiItype] = useState('');
  const [goiClass, setGoiClass] = useState('');
  const [goiFindings, setGoiFindings] = useState('');
  const [goiRecs, setGoiRecs] = useState('');
  const [comGoi, setComGoi] = useState('');
  const [comPriority, setComPriority] = useState('');
  const [comMessage, setComMessage] = useState('');

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="GOI RELATIONS — GROUPS OF INTEREST">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            INTEL REPORTS: {total_intel} | COMMUNIQUES: {total_communiques}
          </Box>
        </Section>

        <Section title="GOI STANDING">
          {standing.map((s) => (
            <Box key={s.goi} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '6px', marginBottom: '4px', borderLeft: `2px solid ${STANDING_COLOR(s.standing)}`, background: '#111114' }}>
              <Box style={{ color: STANDING_COLOR(s.standing), fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {s.goi}
              </Box>
              <Box style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
                <Box style={{ width: '80px', height: '6px', background: '#2a2a30' }}>
                  <Box style={{ width: `${s.standing}%`, height: '100%', background: STANDING_COLOR(s.standing) }} />
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8', fontFamily: 'monospace', width: '30px' }}>{s.standing}</Box>
              </Box>
            </Box>
          ))}
        </Section>

        <Section title="FILE INTELLIGENCE">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Input placeholder="GOI name..." value={goiName} onInput={(_e, value: string) => setGoiName(value)} style={{ width: '150px' }} />
              <Input placeholder="Intel type..." value={goiItype} onInput={(_e, value: string) => setGoiItype(value)} style={{ width: '120px' }} />
              <Input placeholder="Classification..." value={goiClass} onInput={(_e, value: string) => setGoiClass(value)} style={{ width: '120px' }} />
            </Box>
            <TextArea placeholder="Findings..." value={goiFindings} onInput={(_e, value: string) => setGoiFindings(value)} rows={2} />
            <TextArea placeholder="Recommendations..." value={goiRecs} onInput={(_e, value: string) => setGoiRecs(value)} rows={2} />
            <Button
              onClick={() => {
                act('file_intel', { goi: goiName, intel_type: goiItype, classification: goiClass, findings: goiFindings, recommendations: goiRecs });
                setGoiName('');
                setGoiItype('');
                setGoiClass('');
                setGoiFindings('');
                setGoiRecs('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '4px 12px', alignSelf: 'flex-start' }}
            >
              FILE INTEL
            </Button>
          </Box>
        </Section>

        <Section title="SEND COMMUNIQUE">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Input placeholder="GOI name..." value={comGoi} onInput={(_e, value: string) => setComGoi(value)} style={{ width: '150px' }} />
              <Input placeholder="Priority (0=standard, 1=high)..." value={comPriority} onInput={(_e, value: string) => setComPriority(value)} style={{ width: '150px' }} />
            </Box>
            <TextArea placeholder="Message to GOI..." value={comMessage} onInput={(_e, value: string) => setComMessage(value)} rows={3} />
            <Button
              onClick={() => {
                act('send_communique', { goi: comGoi, priority: comPriority || '0', message: comMessage });
                setComGoi('');
                setComPriority('');
                setComMessage('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '4px 12px', alignSelf: 'flex-start' }}
            >
              SEND COMMUNIQUE
            </Button>
          </Box>
        </Section>

        {intel.length > 0 && (
          <Section title="INTELLIGENCE DATABASE">
            {intel.map((i) => (
              <Box key={i.intel_id} style={{ padding: '8px', marginBottom: '4px', borderLeft: `2px solid ${i.verified ? '#44ff44' : '#d4a017'}`, background: '#111114' }}>
                <Box style={{ color: i.verified ? '#44ff44' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {i.intel_id} — {i.goi} ({i.classification})
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Type: {i.type} | Analyst: {i.analyst}
                </Box>
                <Box style={{ fontSize: '10px', color: '#8a8a90' }}>{i.findings}</Box>
                {!i.verified && (
                  <Button
                    onClick={() => act('verify_intel', { intel_id: i.intel_id })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px', marginTop: '4px' }}
                  >
                    VERIFY
                  </Button>
                )}
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
