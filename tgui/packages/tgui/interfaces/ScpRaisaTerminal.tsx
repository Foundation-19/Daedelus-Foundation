import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, TextArea, Input } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  reports: IntelReport[];
  subjects: Subject[];
  breaches: InfoBreach[];
  total_reports: number;
  active_breaches: number;
  contained_breaches: number;
};

type IntelReport = {
  report_id: string;
  analyst: string;
  type: string;
  target: string;
  classification: string;
  findings: string;
  recommendations: string;
  status: string;
  time: number;
};

type Subject = {
  name: string;
  job: string;
  threat: number;
  observations: number;
  incidents: number;
  flagged: BooleanLike;
  flag_reason: string;
  last_observed: number;
};

type InfoBreach = {
  breach_id: string;
  type: string;
  source: string;
  data: string;
  severity: number;
  contained: BooleanLike;
  notes: string;
  time: number;
};

const THREAT_COLOR = (t: number) => (t > 70 ? '#cc2222' : t > 40 ? '#ff8800' : t > 15 ? '#d4a017' : '#44ff44');

const CLASS_OPTIONS = ['UNCLASSIFIED', 'CONFIDENTIAL', 'SECRET', 'TOP SECRET'];
const TYPE_OPTIONS = ['Surveillance', 'Incident', 'Assessment', 'Counterintelligence', 'Personnel', 'Anomalous'];

const RaisaButton = (props: { children: React.ReactNode; onClick?: () => void; color?: string; fluid?: boolean }) => (
  <Button
    onClick={props.onClick}
    fluid={props.fluid}
    style={{
      fontFamily: 'monospace',
      fontSize: '11px',
      background: `rgba(${props.color === 'red' ? '139,0,0' : props.color === 'green' ? '0,100,0' : '68,136,255'},0.2)`,
      border: `1px solid ${props.color === 'red' ? '#8b0000' : props.color === 'green' ? '#44ff44' : '#4488ff'}`,
      color: props.color === 'red' ? '#cc2222' : props.color === 'green' ? '#44ff44' : '#4488ff',
      padding: '6px 10px',
    }}
  >
    {props.children}
  </Button>
);

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
    <RaisaButton onClick={props.onAdd}>+ ADD PARAGRAPH</RaisaButton>
  </Box>
);

export const ScpRaisaTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { reports, subjects, breaches, total_reports, active_breaches, contained_breaches } = data;
  const [raisaTarget, setRaisaTarget] = useState('');
  const [raisaTargetJob, setRaisaTargetJob] = useState('');
  const [raisaType, setRaisaType] = useState('');
  const [raisaClass, setRaisaClass] = useState('');
  const [findingsParagraphs, setFindingsParagraphs] = useState<string[]>(['']);
  const [recsParagraphs, setRecsParagraphs] = useState<string[]>(['']);
  const [activeTab, setActiveTab] = useState<'file' | 'reports' | 'subjects' | 'breaches'>('file');
  const [expandedReport, setExpandedReport] = useState<string | null>(null);

  const fileReport = () => {
    const findings = findingsParagraphs.filter((p) => p.trim()).join('\n\n');
    const recs = recsParagraphs.filter((p) => p.trim()).join('\n\n');
    act('file_report', { target: raisaTarget, target_job: raisaTargetJob, report_type: raisaType, classification: raisaClass, findings, recommendations: recs });
    setRaisaTarget('');
    setRaisaTargetJob('');
    setRaisaType('');
    setRaisaClass('');
    setFindingsParagraphs(['']);
    setRecsParagraphs(['']);
  };

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="RAISA — RECORDS AND INFORMATION SECURITY">
          <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px', lineHeight: '1.5' }}>
            REPORTS: {total_reports} | ACTIVE BREACHES: {active_breaches} | CONTAINED: {contained_breaches}
          </Box>
          <Box style={{ display: 'flex', gap: '2px', marginBottom: '4px' }}>
            {(['file', 'reports', 'subjects', 'breaches'] as const).map((tab) => (
              <Button
                key={tab}
                selected={activeTab === tab}
                onClick={() => setActiveTab(tab)}
                style={{ fontFamily: 'monospace', fontSize: '11px', padding: '4px 10px', textTransform: 'uppercase' }}
              >
                {tab === 'file' ? 'FILE REPORT' : tab === 'reports' ? 'REPORTS' : tab === 'subjects' ? 'SUBJECTS' : 'BREACHES'}
              </Button>
            ))}
          </Box>
        </Section>

        {activeTab === 'file' && (
          <Section title="FILE INTELLIGENCE REPORT">
            <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <Box style={{ display: 'flex', gap: '6px' }}>
                <Input placeholder="Target name..." value={raisaTarget} onInput={(_e, value: string) => setRaisaTarget(value)} style={{ width: '200px' }} />
                <Input placeholder="Target job..." value={raisaTargetJob} onInput={(_e, value: string) => setRaisaTargetJob(value)} style={{ width: '160px' }} />
              </Box>
              <Box style={{ display: 'flex', gap: '6px' }}>
                <Input placeholder="Report type..." value={raisaType} onInput={(_e, value: string) => setRaisaType(value)} style={{ width: '160px' }} />
                <Input placeholder="Classification..." value={raisaClass} onInput={(_e, value: string) => setRaisaClass(value)} style={{ width: '160px' }} />
              </Box>
              <Box style={{ borderBottom: '1px solid #333', paddingBottom: '4px', marginBottom: '4px' }}>
                <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#4488ff', marginBottom: '4px' }}>FINDINGS</Box>
                <ParagraphList
                  paragraphs={findingsParagraphs}
                  onAdd={() => setFindingsParagraphs([...findingsParagraphs, ''])}
                  onRemove={(i) => setFindingsParagraphs(findingsParagraphs.filter((_, idx) => idx !== i))}
                  onChange={(i, v) => setFindingsParagraphs(findingsParagraphs.map((p, idx) => (idx === i ? v : p)))}
                  placeholder="Finding"
                />
              </Box>
              <Box style={{ borderBottom: '1px solid #333', paddingBottom: '4px', marginBottom: '4px' }}>
                <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#4488ff', marginBottom: '4px' }}>RECOMMENDATIONS</Box>
                <ParagraphList
                  paragraphs={recsParagraphs}
                  onAdd={() => setRecsParagraphs([...recsParagraphs, ''])}
                  onRemove={(i) => setRecsParagraphs(recsParagraphs.filter((_, idx) => idx !== i))}
                  onChange={(i, v) => setRecsParagraphs(recsParagraphs.map((p, idx) => (idx === i ? v : p)))}
                  placeholder="Recommendation"
                />
              </Box>
              <RaisaButton onClick={fileReport}>FILE REPORT</RaisaButton>
            </Box>
          </Section>
        )}

        {activeTab === 'reports' && (
          <Section title="INTELLIGENCE REPORTS">
            {reports.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No reports filed.
              </Box>
            )}
            {reports.map((r) => (
              <Box key={r.report_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: '2px solid #4488ff', background: '#111114' }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between', cursor: 'pointer' }} onClick={() => setExpandedReport(expandedReport === r.report_id ? null : r.report_id)}>
                  <Box>
                    <Box style={{ color: '#4488ff', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '13px' }}>
                      {r.report_id}
                    </Box>
                    <Box style={{ fontSize: '11px', color: '#999', lineHeight: '1.5' }}>
                      {r.type} | {r.classification} | Target: {r.target} | Analyst: {r.analyst}
                    </Box>
                  </Box>
                  <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#666', padding: '2px 6px' }}>
                    {expandedReport === r.report_id ? '▼' : '▶'}
                  </Box>
                </Box>
                {expandedReport === r.report_id && (
                  <Box style={{ marginTop: '8px', borderTop: '1px solid #222', paddingTop: '8px' }}>
                    {r.findings && (
                      <Box style={{ marginBottom: '8px' }}>
                        <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#4488ff', marginBottom: '4px' }}>FINDINGS:</Box>
                        {r.findings.split('\n\n').map((para, i) => (
                          <Box key={i} style={{ fontFamily: 'monospace', fontSize: '12px', color: '#ccc', lineHeight: '1.5', paddingLeft: '12px', marginBottom: '4px' }}>
                            {para}
                          </Box>
                        ))}
                      </Box>
                    )}
                    {r.recommendations && (
                      <Box>
                        <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#44ff44', marginBottom: '4px' }}>RECOMMENDATIONS:</Box>
                        {r.recommendations.split('\n\n').map((para, i) => (
                          <Box key={i} style={{ fontFamily: 'monospace', fontSize: '12px', color: '#ccc', lineHeight: '1.5', paddingLeft: '12px', marginBottom: '4px' }}>
                            {para}
                          </Box>
                        ))}
                      </Box>
                    )}
                  </Box>
                )}
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'subjects' && (
          <Section title="SURVEILLANCE SUBJECTS">
            {subjects.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No subjects on record.
              </Box>
            )}
            {subjects.map((s) => (
              <Box key={s.name} style={{ padding: '12px', marginBottom: '8px', borderLeft: `2px solid ${THREAT_COLOR(s.threat)}`, background: '#111114' }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Box>
                    <Box style={{ color: THREAT_COLOR(s.threat), fontWeight: 'bold', fontFamily: 'monospace', fontSize: '13px' }}>
                      {s.name} {s.flagged ? '[FLAGGED]' : ''}
                    </Box>
                    <Box style={{ fontSize: '12px', color: '#c8c8c8', lineHeight: '1.5' }}>
                      {s.job} | Threat: {s.threat} | Observations: {s.observations} | Incidents: {s.incidents}
                    </Box>
                    {s.flag_reason && <Box style={{ fontSize: '12px', color: '#cc2222', lineHeight: '1.5' }}>Reason: {s.flag_reason}</Box>}
                  </Box>
                  <Box style={{ display: 'flex', gap: '4px' }}>
                    <RaisaButton onClick={() => act('observe_person', { target: s.name })}>OBSERVE</RaisaButton>
                    {!s.flagged && <RaisaButton color="red" onClick={() => act('flag_person', { target: s.name, reason: 'Suspicious activity' })}>FLAG</RaisaButton>}
                  </Box>
                </Box>
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'breaches' && (
          <Section title="INFORMATION BREACHES">
            {breaches.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No breaches recorded.
              </Box>
            )}
            {breaches.map((b) => (
              <Box key={b.breach_id} style={{ padding: '12px', marginBottom: '8px', borderLeft: `2px solid ${b.contained ? '#44ff44' : '#cc2222'}`, background: '#111114' }}>
                <Box style={{ color: b.contained ? '#44ff44' : '#cc2222', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '13px' }}>
                  {b.breach_id} — {b.type} [Severity: {b.severity}]
                </Box>
                <Box style={{ fontSize: '12px', color: '#c8c8c8', lineHeight: '1.5' }}>
                  Source: {b.source} | Data: {b.data}
                </Box>
                {!b.contained && (
                  <RaisaButton color="green" onClick={() => act('contain_breach', { breach_id: b.breach_id, notes: 'Contained by RAISA' })}>CONTAIN</RaisaButton>
                )}
                {b.contained && <Box style={{ fontSize: '12px', color: '#44ff44', fontFamily: 'monospace', marginTop: '8px', lineHeight: '1.5' }}>CONTAINED</Box>}
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
