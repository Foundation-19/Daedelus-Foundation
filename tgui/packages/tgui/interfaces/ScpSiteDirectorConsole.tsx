import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  status: FacilityStatus;
  directives: Directive[];
  total_directives: number;
  budget_spent: number;
  budget_total: number;
  ethics_pending: number;
  tribunal_cases: number;
  research_points: number;
  network_integrity: number;
};

type FacilityStatus = {
  total_breaches: number;
  active_breaches: number;
  total_recontainments: number;
  power_status: string;
  comms_status: string;
  casualties: number;
  dclass_alive: number;
  dclass_escaped: number;
  research_points: number;
  time: number;
};

type Directive = {
  directive_id: string;
  issuer: string;
  type: string;
  title: string;
  content: string;
  priority: number;
  status: string;
  acknowledged_count: number;
  time: number;
};

const STATUS_COLORS: Record<string, string> = {
  Nominal: '#44ff44',
  Degraded: '#d4a017',
  Critical: '#cc2222',
  Online: '#44ff44',
  Compromised: '#cc2222',
  Unknown: '#6a6a70',
};

const DIR_TYPES = ['general', 'security', 'research', 'medical', 'engineering', 'administrative'];

const ParagraphList = (props: { paragraphs: string[]; onAdd: () => void; onRemove: (i: number) => void; onChange: (i: number, v: string) => void; placeholder: string }) => (
  <Box style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
    {props.paragraphs.map((p, i) => (
      <Box key={i} style={{ display: 'flex', gap: '4px', alignItems: 'flex-start' }}>
        <Box style={{ color: '#555', fontFamily: 'monospace', fontSize: '11px', paddingTop: '6px', minWidth: '18px' }}>
          {i + 1}.
        </Box>
        <TextArea
          placeholder={`${props.placeholder} ${i + 1}...`}
          value={p}
          onInput={(_e: any, value: string) => props.onChange(i, value)}
          rows={5}
          style={{ fontFamily: 'monospace', fontSize: '12px', flex: '1 1 auto', minHeight: '100px', resize: 'vertical' }}
        />
        <Button
          onClick={() => props.onRemove(i)}
          icon="times"
          style={{ background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '4px 6px', marginTop: '2px' }}
        />
      </Box>
    ))}
    <Button
      onClick={props.onAdd}
      style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '6px 10px', alignSelf: 'flex-start' }}
    >
      + ADD PARAGRAPH
    </Button>
  </Box>
);

export const ScpSiteDirectorConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { status, directives, total_directives, budget_spent, budget_total, ethics_pending, tribunal_cases, research_points, network_integrity } = data;

  const [dirType, setDirType] = useState('general');
  const [dirPriority, setDirPriority] = useState('0');
  const [dirTitle, setDirTitle] = useState('');
  const [contentParagraphs, setContentParagraphs] = useState<string[]>(['']);
  const [dirExpiry, setDirExpiry] = useState('0');
  const [activeTab, setActiveTab] = useState<'status' | 'issue' | 'directives'>('status');

  const issueDirective = () => {
    const content = contentParagraphs.filter((p) => p.trim()).join('\n\n');
    act('issue_directive', {
      directive_type: dirType || 'general',
      priority: dirPriority || '0',
      title: dirTitle,
      content,
      expiry: dirExpiry || '0',
    });
    setDirTitle('');
    setContentParagraphs(['']);
  };

  return (
    <NtosWindow width={700} height={700}>
      <NtosWindow.Content scrollable>
        <Section title="SITE COMMAND — FACILITY CONTROL">
          <Box style={{ display: 'flex', gap: '2px', marginBottom: '8px' }}>
            {(['status', 'issue', 'directives'] as const).map((tab) => (
              <Button
                key={tab}
                selected={activeTab === tab}
                onClick={() => setActiveTab(tab)}
                style={{ fontFamily: 'monospace', fontSize: '11px', padding: '4px 10px', textTransform: 'uppercase' }}
              >
                {tab === 'status' ? 'STATUS' : tab === 'issue' ? 'ISSUE' : 'DIRECTIVES'}
              </Button>
            ))}
          </Box>
        </Section>

        {activeTab === 'status' && (
          <Section title="FACILITY STATUS">
            <Box style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginBottom: '8px' }}>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #4488ff' }}>
                <Box style={{ color: '#4488ff', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>BREACHES</Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Active: <Box as="span" style={{ color: status.active_breaches > 0 ? '#cc2222' : '#44ff44' }}>{status.active_breaches}</Box> |
                  Total: {status.total_breaches} |
                  Recontained: {status.total_recontainments}
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #d4a017' }}>
                <Box style={{ color: '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>INFRASTRUCTURE</Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Power: <Box as="span" style={{ color: STATUS_COLORS[status.power_status] }}>{status.power_status}</Box> |
                  Comms: <Box as="span" style={{ color: STATUS_COLORS[status.comms_status] }}>{status.comms_status}</Box> |
                  Network: <Box as="span" style={{ color: network_integrity > 70 ? '#44ff44' : network_integrity > 30 ? '#d4a017' : '#cc2222' }}>{network_integrity}%</Box>
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #cc2222' }}>
                <Box style={{ color: '#cc2222', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>PERSONNEL</Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Casualties: {status.casualties} | D-Class Alive: {status.dclass_alive} | Escaped: {status.dclass_escaped}
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #44ff44' }}>
                <Box style={{ color: '#44ff44', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>OPERATIONS</Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Research: {research_points}pts | Budget: {budget_spent}/{budget_total}cr
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Ethics Pending: {ethics_pending} | Tribunal Cases: {tribunal_cases}
                </Box>
              </Box>
            </Box>
            <Button
              onClick={() => act('print_status_report')}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '4px 12px' }}
            >
              PRINT STATUS REPORT
            </Button>
          </Section>
        )}

        {activeTab === 'issue' && (
          <Section title="ISSUE DIRECTIVE">
            <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <Input
                placeholder="Directive title..."
                value={dirTitle}
                onInput={(_e, value: string) => setDirTitle(value)}
                style={{ width: '100%' }}
              />
              <Box style={{ display: 'flex', gap: '6px' }}>
                <Box style={{ display: 'flex', gap: '2px' }}>
                  {DIR_TYPES.map((t) => (
                    <Button
                      key={t}
                      selected={dirType === t}
                      onClick={() => setDirType(t)}
                      style={{ fontFamily: 'monospace', fontSize: '10px', padding: '2px 6px', textTransform: 'uppercase' }}
                    >
                      {t.slice(0, 3).toUpperCase()}
                    </Button>
                  ))}
                </Box>
                <Box style={{ display: 'flex', gap: '2px' }}>
                  <Button
                    selected={dirPriority === '0'}
                    onClick={() => setDirPriority('0')}
                    style={{ fontFamily: 'monospace', fontSize: '10px', padding: '2px 6px' }}
                  >
                    STD
                  </Button>
                  <Button
                    selected={dirPriority === '1'}
                    onClick={() => setDirPriority('1')}
                    style={{ fontFamily: 'monospace', fontSize: '10px', padding: '2px 6px', color: dirPriority === '1' ? '#cc2222' : undefined }}
                  >
                    HIGH
                  </Button>
                </Box>
                <Input
                  placeholder="Expiry (min, 0=none)..."
                  value={dirExpiry}
                  onInput={(_e, value: string) => setDirExpiry(value)}
                  style={{ width: '120px' }}
                />
              </Box>
              <Box style={{ borderBottom: '1px solid #333', paddingBottom: '4px', marginBottom: '4px' }}>
                <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#d4a017', marginBottom: '4px' }}>DIRECTIVE CONTENT</Box>
                <ParagraphList
                  paragraphs={contentParagraphs}
                  onAdd={() => setContentParagraphs([...contentParagraphs, ''])}
                  onRemove={(i) => setContentParagraphs(contentParagraphs.filter((_, idx) => idx !== i))}
                  onChange={(i, v) => setContentParagraphs(contentParagraphs.map((p, idx) => (idx === i ? v : p)))}
                  placeholder="Paragraph"
                />
              </Box>
              <Button
                onClick={issueDirective}
                style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '6px 12px', alignSelf: 'flex-start' }}
              >
                ISSUE DIRECTIVE
              </Button>
            </Box>
          </Section>
        )}

        {activeTab === 'directives' && (
          <Section title="DIRECTIVE LOG">
            {directives.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No directives issued.
              </Box>
            )}
            {directives.map((d) => (
              <Box key={d.directive_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${d.status === 'active' ? (d.priority > 0 ? '#cc2222' : '#d4a017') : '#6a6a70'}`, background: '#111114' }}>
                <Box style={{ color: d.priority > 0 ? '#cc2222' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {d.title} {d.priority > 0 ? '[PRIORITY]' : ''}
                </Box>
                {d.content.split('\n\n').map((para, i) => (
                  <Box key={i} style={{ fontSize: '10px', color: '#c8c8c8', lineHeight: '1.5', paddingLeft: i > 0 ? '12px' : '0' }}>
                    {para}
                  </Box>
                ))}
                <Box style={{ fontSize: '10px', color: '#6a6a70', marginTop: '4px' }}>
                  Issued by: {d.issuer} | Type: {d.type} | Acknowledged: {d.acknowledged_count} | Status: {d.status}
                </Box>
                {d.status === 'active' && (
                  <Box style={{ display: 'flex', gap: '4px', marginTop: '6px' }}>
                    <Button
                      onClick={() => act('acknowledge_directive', { directive_id: d.directive_id })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px' }}
                    >
                      ACKNOWLEDGE
                    </Button>
                    <Button
                      onClick={() => act('rescind_directive', { directive_id: d.directive_id })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '4px 10px' }}
                    >
                      RESCIND
                    </Button>
                  </Box>
                )}
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
