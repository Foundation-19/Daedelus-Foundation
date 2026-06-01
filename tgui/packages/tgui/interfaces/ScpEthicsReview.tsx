import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea, Dropdown } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  violations: Violation[];
  test_oversights: TestOversight[];
  pending_count: number;
  total_reviews: number;
  upheld_count: number;
  dismissed_count: number;
};

type Violation = {
  violation_id: string;
  reporter: string;
  accused: string;
  type: string;
  severity: string;
  severity_num: number;
  description: string;
  status: string;
  status_num: number;
  notes: string;
  time: number;
};

type TestOversight = {
  test_id: string;
  scp_name: string;
  researcher: string;
  risk_level: number;
  approved: BooleanLike;
  denied: BooleanLike;
  time: number;
};

const SEVERITY_COLORS: Record<number, string> = { 1: '#44ff44', 2: '#d4a017', 3: '#ff8800', 4: '#cc2222' };
const SEVERITY_OPTIONS = ['Minor', 'Moderate', 'Severe', 'Critical'];
const VIOLATION_TYPES = ['Unethical Conduct', 'Protocol Violation', 'Containment Breach', 'Unauthorized Testing', 'D-Class Abuse', 'Data Exploitation', 'Insubordination', 'Safety Negligence'];

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

export const ScpEthicsReview = (props) => {
  const { act, data } = useBackend<Data>();
  const { violations, test_oversights, pending_count, total_reviews, upheld_count, dismissed_count } = data;

  const [activeTab, setActiveTab] = useState<'violations' | 'file' | 'oversight'>('violations');
  const [fileAccused, setFileAccused] = useState('');
  const [fileAccusedJob, setFileAccusedJob] = useState('');
  const [fileType, setFileType] = useState('Unethical Conduct');
  const [fileSeverity, setFileSeverity] = useState(1);
  const [descParagraphs, setDescParagraphs] = useState<string[]>(['']);
  const [evidenceParagraphs, setEvidenceParagraphs] = useState<string[]>(['']);
  const [reviewNotes, setReviewNotes] = useState<Record<string, string>>({});

  const fileViolation = () => {
    const description = descParagraphs.filter((p) => p.trim()).join('\n\n');
    const evidence = evidenceParagraphs.filter((p) => p.trim()).join('\n\n');
    act('file_violation', {
      accused: fileAccused,
      accused_job: fileAccusedJob,
      violation_type: fileType,
      severity: fileSeverity,
      description,
      evidence,
    });
    setFileAccused('');
    setFileAccusedJob('');
    setDescParagraphs(['']);
    setEvidenceParagraphs(['']);
  };

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="ETHICS COMMITTEE — REVIEW PANEL">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            PENDING: {pending_count} | REVIEWS: {total_reviews} | UPHELD: {upheld_count} | DISMISSED: {dismissed_count}
          </Box>
          <Box style={{ display: 'flex', gap: '2px' }}>
            {(['violations', 'file', 'oversight'] as const).map((tab) => (
              <Button
                key={tab}
                selected={activeTab === tab}
                onClick={() => setActiveTab(tab)}
                style={{ fontFamily: 'monospace', fontSize: '11px', padding: '4px 10px', textTransform: 'uppercase' }}
              >
                {tab === 'violations' ? 'VIOLATIONS' : tab === 'file' ? 'FILE' : 'OVERSIGHT'}
              </Button>
            ))}
          </Box>
        </Section>

        {activeTab === 'violations' && (
          <Section title="VIOLATION RECORDS">
            {violations.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No violations on record.
              </Box>
            )}
            {violations.map((v) => (
              <Box key={v.violation_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${SEVERITY_COLORS[v.severity_num] || '#6a6a70'}`, background: '#111114' }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Box style={{ flex: 1 }}>
                    <Box style={{ color: SEVERITY_COLORS[v.severity_num], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                      {v.violation_id} — {v.type} [{v.severity}]
                    </Box>
                    <Box style={{ fontSize: '10px', color: '#c8c8c8', lineHeight: '1.5' }}>
                      Reporter: {v.reporter} | Accused: {v.accused} | Status: {v.status}
                    </Box>
                    {v.description && v.description.split('\n\n').map((para, i) => (
                      <Box key={i} style={{ fontSize: '10px', color: '#8a8a90', lineHeight: '1.5', paddingLeft: i > 0 ? '12px' : '0' }}>
                        {para}
                      </Box>
                    ))}
                    {v.notes && <Box style={{ fontSize: '10px', color: '#6a6a70', marginTop: '4px' }}>Notes: {v.notes}</Box>}
                  </Box>
                  {v.status_num < 2 && (
                    <Box style={{ display: 'flex', flexDirection: 'column', gap: '4px', marginLeft: '8px' }}>
                      <TextArea
                        placeholder="Review notes..."
                        value={reviewNotes[v.violation_id] || ''}
                        onInput={(_e: any, val: string) => setReviewNotes({ ...reviewNotes, [v.violation_id]: val })}
                        rows={2}
                        style={{ fontFamily: 'monospace', fontSize: '10px', width: '150px' }}
                      />
                      <Button
                        onClick={() => act('review_uphold', { violation_id: v.violation_id, notes: reviewNotes[v.violation_id] || '' })}
                        style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '4px 10px' }}
                      >
                        UPHOLD
                      </Button>
                      <Button
                        onClick={() => act('review_dismiss', { violation_id: v.violation_id, notes: reviewNotes[v.violation_id] || '' })}
                        style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px' }}
                      >
                        DISMISS
                      </Button>
                    </Box>
                  )}
                </Box>
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'file' && (
          <Section title="FILE VIOLATION">
            <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <Box style={{ display: 'flex', gap: '6px' }}>
                <Input placeholder="Accused name..." value={fileAccused} onInput={(_e, value: string) => setFileAccused(value)} style={{ width: '200px' }} />
                <Input placeholder="Accused job..." value={fileAccusedJob} onInput={(_e, value: string) => setFileAccusedJob(value)} style={{ width: '160px' }} />
              </Box>
              <Box style={{ display: 'flex', gap: '6px' }}>
                <Dropdown options={VIOLATION_TYPES} selected={fileType} onSelected={(v: string) => setFileType(v)} width="200px" />
                <Box style={{ display: 'flex', gap: '2px' }}>
                  {SEVERITY_OPTIONS.map((s, i) => (
                    <Button
                      key={s}
                      selected={fileSeverity === i + 1}
                      onClick={() => setFileSeverity(i + 1)}
                      style={{ fontFamily: 'monospace', fontSize: '10px', padding: '2px 8px', color: SEVERITY_COLORS[i + 1] }}
                    >
                      {s.slice(0, 3).toUpperCase()}
                    </Button>
                  ))}
                </Box>
              </Box>
              <Box style={{ borderBottom: '1px solid #333', paddingBottom: '4px', marginBottom: '4px' }}>
                <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#cc2222', marginBottom: '4px' }}>DESCRIPTION OF VIOLATION</Box>
                <ParagraphList
                  paragraphs={descParagraphs}
                  onAdd={() => setDescParagraphs([...descParagraphs, ''])}
                  onRemove={(i) => setDescParagraphs(descParagraphs.filter((_, idx) => idx !== i))}
                  onChange={(i, v) => setDescParagraphs(descParagraphs.map((p, idx) => (idx === i ? v : p)))}
                  placeholder="Description"
                />
              </Box>
              <Box style={{ borderBottom: '1px solid #333', paddingBottom: '4px', marginBottom: '4px' }}>
                <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#4488ff', marginBottom: '4px' }}>EVIDENCE</Box>
                <ParagraphList
                  paragraphs={evidenceParagraphs}
                  onAdd={() => setEvidenceParagraphs([...evidenceParagraphs, ''])}
                  onRemove={(i) => setEvidenceParagraphs(evidenceParagraphs.filter((_, idx) => idx !== i))}
                  onChange={(i, v) => setEvidenceParagraphs(evidenceParagraphs.map((p, idx) => (idx === i ? v : p)))}
                  placeholder="Evidence"
                />
              </Box>
              <Button
                onClick={fileViolation}
                style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '6px 12px', alignSelf: 'flex-start' }}
              >
                FILE VIOLATION
              </Button>
            </Box>
          </Section>
        )}

        {activeTab === 'oversight' && (
          <Section title="TEST OVERSIGHT — HIGH-RISK EXPERIMENTS">
            {test_oversights.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No tests flagged for oversight.
              </Box>
            )}
            {test_oversights.map((t) => (
              <Box key={t.test_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: '2px solid #d4a017', background: '#111114' }}>
                <Box style={{ color: '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {t.test_id} — {t.scp_name}
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Researcher: {t.researcher} | Risk Level: {t.risk_level}
                </Box>
                {!t.approved && !t.denied && (
                  <Box style={{ display: 'flex', gap: '4px', marginTop: '6px' }}>
                    <Button
                      onClick={() => act('approve_test', { test_id: t.test_id })}
                      style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px' }}
                    >
                      APPROVE
                    </Button>
                    <Button
                      onClick={() => act('deny_test', { test_id: t.test_id })}
                      style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '4px 10px' }}
                    >
                      DENY
                    </Button>
                  </Box>
                )}
                {t.approved && <Box style={{ fontSize: '10px', color: '#44ff44', fontFamily: 'monospace', marginTop: '6px' }}>APPROVED</Box>}
                {t.denied && <Box style={{ fontSize: '10px', color: '#cc2222', fontFamily: 'monospace', marginTop: '6px' }}>DENIED</Box>}
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
