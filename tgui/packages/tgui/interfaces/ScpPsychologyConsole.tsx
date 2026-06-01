import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  evaluations: Eval[];
  exposures: Exposure[];
  pending_evals: number;
  completed_evals: number;
  amnestics_recommended: number;
  amnestics_administered: number;
  counseling_sessions: number;
};

type Eval = {
  eval_id: string;
  patient: string;
  job: string;
  evaluator: string;
  type: string;
  status: string;
  findings: string;
  recommendations: string;
  amnestic: string;
  sanity_score: number;
  exposure: string;
  trauma: string;
  time: number;
};

type Exposure = {
  person: string;
  job: string;
  scp: string;
  type: string;
  symptoms: string;
  treated: BooleanLike;
  treatment: string;
  time: number;
};

export const ScpPsychologyConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { evaluations, exposures, pending_evals, completed_evals, amnestics_recommended, counseling_sessions } = data;
  const [psychPatient, setPsychPatient] = useState('');
  const [psychEvalType, setPsychEvalType] = useState('');
  const [psychActionPatient, setPsychActionPatient] = useState('');

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="PSYCHOLOGY DEPARTMENT">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            PENDING: {pending_evals} | COMPLETED: {completed_evals} | AMNESTICS REC: {data.amnestics_recommended} | SESSIONS: {counseling_sessions}
          </Box>
        </Section>

        <Section title="START EVALUATION">
          <Box style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
            <Input placeholder="Patient name..." value={psychPatient} onInput={(_e, value: string) => setPsychPatient(value)} style={{ width: '150px' }} />
            <Input placeholder="Eval type (routine/exposure/trauma)..." value={psychEvalType} onInput={(_e, value: string) => setPsychEvalType(value)} style={{ width: '200px' }} />
            <Button
              onClick={() => {
                act('start_evaluation', { patient: psychPatient, eval_type: psychEvalType || 'routine' });
                setPsychPatient('');
                setPsychEvalType('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '4px 12px' }}
            >
              START EVAL
            </Button>
          </Box>
        </Section>

        <Section title="QUICK ACTIONS">
          <Box style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
            <Input placeholder="Patient name..." value={psychActionPatient} onInput={(_e, value: string) => setPsychActionPatient(value)} style={{ width: '150px' }} />
            <Button
              onClick={() => {
                act('conduct_counseling', { patient: psychActionPatient });
              }}
              style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px' }}
            >
              COUNSELING SESSION
            </Button>
            <Button
              onClick={() => {
                act('assess_sanity', { patient: psychActionPatient });
              }}
              style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '4px 10px' }}
            >
              ASSESS SANITY
            </Button>
          </Box>
        </Section>

        <Section title="EVALUATIONS">
          {evaluations.map((e) => (
            <Box key={e.eval_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${e.status === 'Complete' ? '#44ff44' : '#d4a017'}`, background: '#111114' }}>
              <Box style={{ color: e.status === 'Complete' ? '#44ff44' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {e.eval_id} — {e.patient} ({e.type})
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Job: {e.job} | Evaluator: {e.evaluator} | Status: {e.status}
              </Box>
              {e.findings && <Box style={{ fontSize: '10px', color: '#8a8a90' }}>Findings: {e.findings}</Box>}
              {e.recommendations && <Box style={{ fontSize: '10px', color: '#8a8a90' }}>Recommendations: {e.recommendations}</Box>}
              {e.amnestic && e.amnestic !== 'None' && <Box style={{ fontSize: '10px', color: '#d4a017' }}>Amnestic Recommended: {e.amnestic}</Box>}
              {e.sanity_score < 100 && (
                <Box style={{ fontSize: '10px', color: e.sanity_score < 50 ? '#cc2222' : e.sanity_score < 75 ? '#d4a017' : '#44ff44' }}>
                  Sanity Score: {e.sanity_score} | Exposure: {e.exposure}
                </Box>
              )}
              {e.status !== 'Complete' && (
                <Box style={{ marginTop: '4px' }}>
                  <Button
                    onClick={() => act('complete_evaluation', { eval_id: e.eval_id, findings: 'Evaluation completed', recommendations: 'Monitor', amnestic: 'None', sanity: e.sanity_score, exposure: 0, trauma: '' })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px' }}
                  >
                    COMPLETE EVAL
                  </Button>
                </Box>
              )}
            </Box>
          ))}
        </Section>

        {exposures.length > 0 && (
          <Section title="SCP EXPOSURE RECORDS">
            {exposures.map((ex, i) => (
              <Box key={i} style={{ padding: '8px', marginBottom: '4px', borderLeft: `2px solid ${ex.treated ? '#44ff44' : '#cc2222'}`, background: '#111114' }}>
                <Box style={{ color: ex.treated ? '#44ff44' : '#cc2222', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {ex.person} — {ex.scp}
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Type: {ex.type} | Symptoms: {ex.symptoms}
                </Box>
                {!ex.treated && (
                  <Button
                    onClick={() => act('treat_exposure', { person: ex.person, treatment: 'Amnestic + Counseling' })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px', marginTop: '4px' }}
                  >
                    RECORD TREATMENT
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
