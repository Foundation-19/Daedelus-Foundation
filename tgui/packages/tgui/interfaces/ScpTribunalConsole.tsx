import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, LabeledList, ProgressBar, Section, Tabs, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Case = {
  case_id: string;
  defendant: string;
  defendant_job: string;
  prosecutor: string;
  charges: string;
  evidence_summary: string;
  evidence_list: string[];
  status: string;
  status_num: number;
  sanction: string;
  sanction_num: number;
  time: number;
  deliberation_progress: number;
  witnesses: string[];
  defense_statement: string;
  prosecution_statement: string;
  case_notes: string[];
  severity_rating: number;
  recommendation: string;
  attached_documents: AttachedDocument[];
};

type AttachedDocument = {
  doc_id: string;
  doc_name: string;
  attached_by: string;
  attached_time: number;
  content_preview: string;
  raw_info: string;
};

type Guideline = {
  category: string;
  description: string;
  recommended: number;
};

type Statistics = {
  total: number;
  pending: number;
  hearing: number;
  deliberating: number;
  guilty: number;
  not_guilty: number;
  dismissed: number;
};

type Data = {
  cases: Case[];
  total_cases: number;
  active_case: BooleanLike;
  access_denied: BooleanLike;
  statistics: Statistics;
  sentencing_guidelines: Guideline[];
};

const STATUS_COLORS: Record<number, string> = {
  0: '#d4a017',
  1: '#ff8800',
  2: '#4488ff',
 3: '#cc2222',
  4: '#44ff44',
  5: '#6a6a70',
};

const SANCTION_NAMES: Record<number, string> = {
  1: 'Reprimand',
  2: 'Suspension',
  3: 'Demotion',
  4: 'Termination',
  5: 'Amnestic Treatment',
};

const SEVERITY_LABELS = ['', 'Minor', 'Moderate', 'Serious', 'Severe', 'Critical'];

export const ScpTribunalConsole = (props) => {
  const { act, data } = useBackend<Data>();

  const [selectedTab, setSelectedTab] = useLocalState<string>(
    'tribTab',
    'overview',
  );

  const [selectedCaseId, setSelectedCaseId] = useLocalState<string>(
    'tribCase',
    '',
  );

  const { cases, total_cases, active_case, statistics, sentencing_guidelines } =
    data;

  const selectedCase = cases?.find((c) => c.case_id === selectedCaseId);

  return (
    <NtosWindow width={700} height={700}>
      <NtosWindow.Content scrollable>
        <Section title="INTERNAL TRIBUNAL DEPARTMENT">
          <Box
            style={{
              fontFamily: 'monospace',
              fontSize: '10px',
              color: '#6a6a70',
              letterSpacing: '0.1em',
            }}
          >
            TOTAL CASES: {total_cases} |{' '}
            {active_case ? 'HEARING IN SESSION' : 'NO ACTIVE HEARING'}
          </Box>
        </Section>

        <Tabs>
          <Tabs.Tab
            selected={selectedTab === 'overview'}
            onClick={() => setSelectedTab('overview')}
          >
            Overview
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'file'}
            onClick={() => setSelectedTab('file')}
          >
            File Case
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'cases'}
            onClick={() => setSelectedTab('cases')}
          >
            Cases
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'detail'}
            onClick={() => setSelectedTab('detail')}
          >
            Case Detail
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'guidelines'}
            onClick={() => setSelectedTab('guidelines')}
          >
            Guidelines
          </Tabs.Tab>
        </Tabs>

        {selectedTab === 'overview' && (
          <Section title="Tribunal Statistics">
            <LabeledList>
              <LabeledList.Item label="Total Cases">
                {statistics?.total || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Pending">
                {statistics?.pending || 0}
              </LabeledList.Item>
              <LabeledList.Item label="In Hearing">
                {statistics?.hearing || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Deliberating">
                {statistics?.deliberating || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Guilty Verdicts">
                {statistics?.guilty || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Not Guilty Verdicts">
                {statistics?.not_guilty || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Dismissed">
                {statistics?.dismissed || 0}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}

        {selectedTab === 'file' && <FileCaseTab act={act} />}

        {selectedTab === 'cases' && (
          <Section title="All Cases">
            {(cases || []).length > 0 ? (
              cases.map((c) => (
                <Box
                  key={c.case_id}
                  style={{
                    padding: '8px',
                    marginBottom: '6px',
                    borderLeft: `2px solid ${STATUS_COLORS[c.status_num] || '#6a6a70'}`,
                    background:
                      selectedCaseId === c.case_id ? '#1a1a20' : '#111114',
                    cursor: 'pointer',
                  }}
                  onClick={() => {
                    setSelectedCaseId(c.case_id);
                    setSelectedTab('detail');
                  }}
                >
                  <Box
                    style={{
                      color: STATUS_COLORS[c.status_num],
                      fontWeight: 'bold',
                      fontFamily: 'monospace',
                      fontSize: '12px',
                    }}
                  >
                    {c.case_id} — {c.defendant}
                    {c.defendant_job ? ` (${c.defendant_job})` : ''}
                  </Box>
                  <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                    Charges: {c.charges} | Status: {c.status}
                    {c.severity_rating > 1 &&
                      ` | Severity: ${SEVERITY_LABELS[c.severity_rating] || c.severity_rating}`}
                  </Box>
                  {c.sanction && (
                    <Box style={{ fontSize: '10px', color: '#cc2222' }}>
                      Sanction: {c.sanction}
                    </Box>
                  )}
                </Box>
              ))
            ) : (
              <Box color="label">No cases filed.</Box>
            )}
          </Section>
        )}

        {selectedTab === 'detail' && (
          <CaseDetailTab
            act={act}
            caseData={selectedCase}
            setSelectedCaseId={setSelectedCaseId}
          />
        )}

        {selectedTab === 'guidelines' && (
          <Section title="Sentencing Guidelines">
            {(sentencing_guidelines || []).map((g, i) => (
              <Box
                key={i}
                style={{
                  padding: '8px',
                  marginBottom: '6px',
                  borderLeft: '2px solid #d4a017',
                  background: '#111114',
                }}
              >
                <Box
                  style={{
                    color: '#d4a017',
                    fontWeight: 'bold',
                    fontFamily: 'monospace',
                    fontSize: '12px',
                  }}
                >
                  {g.category}
                </Box>
                <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>
                  {g.description}
                </Box>
                <Box style={{ fontSize: '10px', color: '#8a8a90' }}>
                  Recommended Sanction:{' '}
                  {SANCTION_NAMES[g.recommended] || 'Unknown'}
                </Box>
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const FileCaseTab = ({ act }) => {
  const [defendant, setDefendant] = useState('');
  const [charges, setCharges] = useState('');
  const [evidence, setEvidence] = useState('');

  return (
    <Section title="File New Case">
      <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <Box>
          <Box color="label" mb={0.5}>
            Defendant Name:
          </Box>
          <Input
            fluid
            placeholder="Full name of the accused..."
            value={defendant}
            onInput={(_e, value: string) => setDefendant(value)}
          />
        </Box>
        <Box>
          <Box color="label" mb={0.5}>
            Charges:
          </Box>
          <Input
            fluid
            placeholder="Charges filed against the defendant..."
            value={charges}
            onInput={(_e, value: string) => setCharges(value)}
          />
        </Box>
        <Box>
          <Box color="label" mb={0.5}>
            Evidence Summary:
          </Box>
          <TextArea
            value={evidence}
            onInput={(_e, value: string) => setEvidence(value)}
            height="120px"
            style={{ width: '100%', resize: 'vertical', minHeight: '100px' }}
            placeholder="Enter each piece of evidence on a new line.&#10;&#10;Example:&#10;Security camera footage of unauthorized access to LCZ at 14:32&#10;Witness testimony from Dr. Klein (LCZ Senior Researcher)&#10;DNA evidence recovered from containment door handle"
          />
        </Box>
        <Button
          fluid
          onClick={() => {
            act('file_case', {
              defendant,
              charges,
              evidence,
            });
            setDefendant('');
            setCharges('');
            setEvidence('');
          }}
          style={{
            fontFamily: 'monospace',
            fontSize: '11px',
            background: 'rgba(212,160,23,0.2)',
            border: '1px solid #d4a017',
            color: '#d4a017',
            padding: '6px 12px',
          }}
        >
          FILE CASE
        </Button>
      </Box>
    </Section>
  );
};

const CaseDetailTab = ({ act, caseData, setSelectedCaseId }) => {
  const [witnessInput, setWitnessInput] = useState('');
  const [evidenceInput, setEvidenceInput] = useState('');
  const [noteInput, setNoteInput] = useState('');
  const [defenseText, setDefenseText] = useState(
    caseData?.defense_statement || '',
  );
  const [prosecutionText, setProsecutionText] = useState(
    caseData?.prosecution_statement || '',
  );
  const [recommendation, setRecommendation] = useState(
    caseData?.recommendation || '',
  );

  if (!caseData) {
    return (
      <Section title="Case Detail">
        <Box color="label">
          Select a case from the Cases tab to view details.
        </Box>
      </Section>
    );
  }

  const c = caseData;

  return (
    <Section
      title={`Case: ${c.case_id}`}
      buttons={
        <Button onClick={() => setSelectedCaseId('')}>
          Back to List
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Defendant">
          {c.defendant}
          {c.defendant_job ? ` (${c.defendant_job})` : ''}
        </LabeledList.Item>
        <LabeledList.Item label="Prosecutor">{c.prosecutor}</LabeledList.Item>
        <LabeledList.Item label="Charges">{c.charges}</LabeledList.Item>
        <LabeledList.Item label="Status">
          <Box
            style={{
              color: STATUS_COLORS[c.status_num],
              fontWeight: 'bold',
            }}
          >
            {c.status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Severity">
          <Box style={{ display: 'flex', gap: '4px' }}>
            {[1, 2, 3, 4, 5].map((s) => (
              <Button
                key={s}
                selected={c.severity_rating === s}
                disabled={c.status_num >= 3}
                onClick={() =>
                  act('set_severity', {
                    case_id: c.case_id,
                    severity: s,
                  })
                }
                style={{ fontSize: '10px', padding: '2px 6px' }}
              >
                {SEVERITY_LABELS[s]}
              </Button>
            ))}
          </Box>
        </LabeledList.Item>
      </LabeledList>

      <Section title="Evidence" mt={1} level={2}>
        {(c.evidence_list || []).length > 0 ? (
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {c.evidence_list.map((ev, i) => (
              <Box
                key={i}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  padding: '4px 8px',
                  background: '#111114',
                  borderLeft: '2px solid #d4a017',
                }}
              >
                <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>
                  {i + 1}. {ev}
                </Box>
                {c.status_num < 3 && (
                  <Button
                    onClick={() =>
                      act('remove_evidence', {
                        case_id: c.case_id,
                        evidence_idx: i + 1,
                      })
                    }
                    style={{ fontSize: '10px', padding: '2px 6px' }}
                  >
                    Remove
                  </Button>
                )}
              </Box>
            ))}
          </Box>
        ) : (
          <Box color="label" fontSize="11px">
            No evidence submitted.
          </Box>
        )}
        {c.status_num < 3 && (
          <Box mt={1} style={{ display: 'flex', gap: '4px' }}>
            <Input
              fluid
              placeholder="Add evidence item..."
              value={evidenceInput}
              onInput={(_e, value: string) => setEvidenceInput(value)}
            />
            <Button
              onClick={() => {
                act('add_evidence', {
                  case_id: c.case_id,
                  evidence_text: evidenceInput,
                });
                setEvidenceInput('');
              }}
            >
              Add
            </Button>
          </Box>
        )}
      </Section>

      <Section title="Documents" level={2}>
        {(c.attached_documents || []).length > 0 ? (
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {c.attached_documents.map((doc) => (
              <Box
                key={doc.doc_id}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'flex-start',
                  padding: '6px 8px',
                  background: '#111114',
                  borderLeft: '2px solid #4488ff',
                }}
              >
                <Box style={{ flex: '1' }}>
                  <Box style={{ fontSize: '11px', color: '#4488ff', fontWeight: 'bold' }}>
                    {doc.doc_name}
                  </Box>
                  <Box style={{ fontSize: '10px', color: '#8a8a90' }}>
                    Attached by: {doc.attached_by}
                  </Box>
                  {doc.content_preview && (
                    <Box style={{ fontSize: '10px', color: '#6a6a70', marginTop: '2px' }}>
                      {doc.content_preview}...
                    </Box>
                  )}
                </Box>
                {c.status_num < 3 && (
                  <Button
                    onClick={() =>
                      act('remove_document', {
                        case_id: c.case_id,
                        doc_id: doc.doc_id,
                      })
                    }
                    style={{ fontSize: '10px', padding: '2px 6px' }}
                  >
                    Remove
                  </Button>
                )}
              </Box>
            ))}
          </Box>
        ) : (
          <Box color="label" fontSize="11px">
            No documents attached.
          </Box>
        )}
        {c.status_num < 3 && (
          <Box mt={1}>
            <Button
              onClick={() =>
                act('attach_document', { case_id: c.case_id })
              }
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(68,136,255,0.2)',
                border: '1px solid #4488ff',
                color: '#4488ff',
                padding: '4px 8px',
              }}
            >
              ATTACH PAPER FROM HAND
            </Button>
          </Box>
        )}
      </Section>

      <Section title="Witnesses" level={2}>
        {(c.witnesses || []).length > 0 ? (
          <Box style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
            {c.witnesses.map((w, i) => (
              <Box
                key={i}
                style={{
                  padding: '2px 8px',
                  background: '#1a1a20',
                  border: '1px solid #333',
                  fontSize: '11px',
                  color: '#c8c8c8',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                }}
              >
                {w}
                {c.status_num < 3 && (
                  <Button
                    onClick={() =>
                      act('remove_witness', {
                        case_id: c.case_id,
                        witness_name: w,
                      })
                    }
                    style={{ fontSize: '9px', padding: '0px 4px' }}
                  >
                    X
                  </Button>
                )}
              </Box>
            ))}
          </Box>
        ) : (
          <Box color="label" fontSize="11px">
            No witnesses registered.
          </Box>
        )}
        {c.status_num < 3 && (
          <Box mt={1} style={{ display: 'flex', gap: '4px' }}>
            <Input
              fluid
              placeholder="Witness name..."
              value={witnessInput}
              onInput={(_e, value: string) => setWitnessInput(value)}
            />
            <Button
              onClick={() => {
                act('add_witness', {
                  case_id: c.case_id,
                  witness_name: witnessInput,
                });
                setWitnessInput('');
              }}
            >
              Add
            </Button>
          </Box>
        )}
      </Section>

      <Section title="Statements" level={2}>
        <Box mb={1}>
          <Box color="label" mb={0.5}>
            Prosecution Statement:
          </Box>
          <TextArea
            value={prosecutionText}
            onInput={(_e, value: string) => setProsecutionText(value)}
            height="80px"
            style={{
              width: '100%',
              resize: 'vertical',
              minHeight: '80px',
            }}
            placeholder="Prosecution arguments and case summary..."
          />
          {c.status_num < 3 && (
            <Button
              mt={0.5}
              onClick={() =>
                act('set_prosecution_statement', {
                  case_id: c.case_id,
                  statement: prosecutionText,
                })
              }
            >
              Save Prosecution Statement
            </Button>
          )}
        </Box>
        <Box>
          <Box color="label" mb={0.5}>
            Defense Statement:
          </Box>
          <TextArea
            value={defenseText}
            onInput={(_e, value: string) => setDefenseText(value)}
            height="80px"
            style={{
              width: '100%',
              resize: 'vertical',
              minHeight: '80px',
            }}
            placeholder="Defense arguments and rebuttal..."
          />
          {c.status_num < 3 && (
            <Button
              mt={0.5}
              onClick={() =>
                act('set_defense_statement', {
                  case_id: c.case_id,
                  statement: defenseText,
                })
              }
            >
              Save Defense Statement
            </Button>
          )}
        </Box>
      </Section>

      <Section title="Recommendation" level={2}>
        <TextArea
          value={recommendation}
          onInput={(_e, value: string) => setRecommendation(value)}
          height="60px"
          style={{
            width: '100%',
            resize: 'vertical',
            minHeight: '60px',
          }}
          placeholder="Tribunal officer's sentencing recommendation..."
        />
        {c.status_num < 3 && (
          <Button
            mt={0.5}
            onClick={() =>
              act('set_recommendation', {
                case_id: c.case_id,
                recommendation,
              })
            }
          >
            Save Recommendation
          </Button>
        )}
      </Section>

      <Section title="Case Notes" level={2}>
        {(c.case_notes || []).length > 0 && (
          <Box
            mb={1}
            style={{
              display: 'flex',
              flexDirection: 'column',
              gap: '2px',
            }}
          >
            {c.case_notes.map((note, i) => (
              <Box
                key={i}
                style={{
                  fontSize: '10px',
                  color: '#8a8a90',
                  padding: '2px 4px',
                  borderLeft: '1px solid #333',
                }}
              >
                {note}
              </Box>
            ))}
          </Box>
        )}
        {c.status_num < 3 && (
          <Box style={{ display: 'flex', gap: '4px' }}>
            <Input
              fluid
              placeholder="Add a note..."
              value={noteInput}
              onInput={(_e, value: string) => setNoteInput(value)}
            />
            <Button
              onClick={() => {
                act('add_note', {
                  case_id: c.case_id,
                  note_text: noteInput,
                });
                setNoteInput('');
              }}
            >
              Add
            </Button>
          </Box>
        )}
      </Section>

      {c.status_num === 2 && (
        <Section title="Deliberation" level={2}>
          <ProgressBar
            value={c.deliberation_progress / 100}
            ranges={{
              good: [0.75, Infinity],
              average: [0.5, 0.75],
              bad: [-Infinity, 0.5],
            }}
          >
            {Math.round(c.deliberation_progress)}% Complete
          </ProgressBar>
          <Box mt={1} style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
            <Button
              onClick={() =>
                act('render_verdict', {
                  case_id: c.case_id,
                  guilty: 1,
                  sanction: 1,
                  sanction_text: 'Formal Reprimand',
                })
              }
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(139,0,0,0.2)',
                border: '1px solid #8b0000',
                color: '#cc2222',
                padding: '4px 8px',
              }}
            >
              Guilty — Reprimand
            </Button>
            <Button
              onClick={() =>
                act('render_verdict', {
                  case_id: c.case_id,
                  guilty: 1,
                  sanction: 2,
                  sanction_text: 'Suspension of duties',
                })
              }
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(139,0,0,0.2)',
                border: '1px solid #8b0000',
                color: '#cc2222',
                padding: '4px 8px',
              }}
            >
              Guilty — Suspension
            </Button>
            <Button
              onClick={() =>
                act('render_verdict', {
                  case_id: c.case_id,
                  guilty: 1,
                  sanction: 3,
                  sanction_text: 'Demotion',
                })
              }
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(139,0,0,0.3)',
                border: '1px solid #8b0000',
                color: '#cc2222',
                padding: '4px 8px',
              }}
            >
              Guilty — Demotion
            </Button>
            <Button
              onClick={() =>
                act('render_verdict', {
                  case_id: c.case_id,
                  guilty: 1,
                  sanction: 4,
                  sanction_text: 'Employment Termination',
                })
              }
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(139,0,0,0.4)',
                border: '1px solid #8b0000',
                color: '#cc2222',
                padding: '4px 8px',
              }}
            >
              Guilty — Termination
            </Button>
            <Button
              onClick={() =>
                act('render_verdict', {
                  case_id: c.case_id,
                  guilty: 1,
                  sanction: 5,
                  sanction_text: 'Mandatory Amnestic Treatment',
                })
              }
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(139,0,0,0.3)',
                border: '1px solid #8b0000',
                color: '#cc2222',
                padding: '4px 8px',
              }}
            >
              Guilty — Amnestic
            </Button>
            <Button
              onClick={() =>
                act('render_verdict', {
                  case_id: c.case_id,
                  guilty: 0,
                  sanction: 0,
                  sanction_text: '',
                })
              }
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(68,255,68,0.1)',
                border: '1px solid #44ff44',
                color: '#44ff44',
                padding: '4px 8px',
              }}
            >
              Not Guilty
            </Button>
            <Button
              onClick={() => act('dismiss_case', { case_id: c.case_id })}
              style={{
                fontFamily: 'monospace',
                fontSize: '10px',
                background: 'rgba(106,106,112,0.2)',
                border: '1px solid #6a6a70',
                color: '#6a6a70',
                padding: '4px 8px',
              }}
            >
              Dismiss
            </Button>
          </Box>
        </Section>
      )}

      {c.status_num === 0 && (
        <Box mt={1}>
          <Button
            fluid
            onClick={() => act('begin_hearing', { case_id: c.case_id })}
            style={{
              fontFamily: 'monospace',
              fontSize: '11px',
              background: 'rgba(212,160,23,0.2)',
              border: '1px solid #d4a017',
              color: '#d4a017',
              padding: '6px 12px',
            }}
          >
            BEGIN HEARING
          </Button>
        </Box>
      )}

      {c.status_num === 1 && (
        <Box mt={1}>
          <Button
            fluid
            onClick={() =>
              act('enter_deliberation', { case_id: c.case_id })
            }
            style={{
              fontFamily: 'monospace',
              fontSize: '11px',
              background: 'rgba(68,136,255,0.2)',
              border: '1px solid #4488ff',
              color: '#4488ff',
              padding: '6px 12px',
            }}
          >
            ENTER DELIBERATION
          </Button>
        </Box>
      )}

      {c.sanction && (
        <Section title="Verdict" mt={1} level={2}>
          <LabeledList>
            <LabeledList.Item label="Verdict">
              <Box
                style={{
                  color:
                    c.status_num === 3
                      ? '#cc2222'
                      : c.status_num === 4
                        ? '#44ff44'
                        : '#6a6a70',
                  fontWeight: 'bold',
                }}
              >
                {c.status}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Sanction">
              {c.sanction}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Section>
  );
};
