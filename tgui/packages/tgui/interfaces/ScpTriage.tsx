import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Input } from '../components';
import { NtosWindow } from '../layouts';

const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  red: '#8b0000',
  darkRed: '#5c0000',
  amber: '#d4a017',
  green: '#0a6e0a',
  brightGreen: '#44ff44',
  text: '#c8c8c8',
  dim: '#6a6a70',
  highlight: '#e8e8e8',
};

const conditionColor = (condition) => {
  const c = (condition || '').toLowerCase();
  if (c.includes('contagion') || c.includes('viral') || c.includes('biological')) return C.red;
  if (c.includes('exposure') || c.includes('anomalous') || c.includes('reality')) return C.amber;
  if (c.includes('psychological') || c.includes('cognitohazard')) return '#6a0dad';
  if (c.includes('physical') || c.includes('trauma') || c.includes('injury')) return '#cc6600';
  return C.dim;
};

const severityColor = (sev) => {
  if (sev <= 1) return C.green;
  if (sev <= 3) return C.amber;
  return C.red;
};

const priorityColor = (pri) => {
  if (pri <= 1) return C.brightGreen;
  if (pri <= 3) return C.amber;
  return C.red;
};

export const ScpTriage = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    triage_queue = [],
    active_cases = [],
    quarantine_list = [],
    treatment_log = [],
    doctor_stats,
    total_patients_triaged,
    total_decontaminations,
    total_quarantines,
    pending_count,
  } = data;

  const [diagnosisInput, setDiagnosisInput] = useState({});
  const [treatmentType, setTreatmentType] = useState({});
  const [reportCondition, setReportCondition] = useState('');
  const [reportSeverity, setReportSeverity] = useState(1);
  const [reportSource, setReportSource] = useState('');

  const getDiagnosis = (id) => diagnosisInput[id] || '';
  const getTreatment = (id) => treatmentType[id] || 'standard';

  const TREATMENT_TYPES = [
    { key: 'standard', label: 'STANDARD', color: C.green },
    { key: 'decontamination', label: 'DECON', color: '#00b5b5' },
    { key: 'surgery', label: 'SURGERY', color: C.amber },
    { key: 'amnestic', label: 'AMNESTIC', color: '#6a0dad' },
    { key: 'quarantine', label: 'QUARANTINE', color: C.red },
    { key: 'specialist', label: 'SPECIALIST', color: C.highlight },
  ];

  return (
    <NtosWindow width={700} height={700}>
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack justify="space-between" align="center">
                <Stack.Item>
                  <Box fontSize="18px" fontFamily="monospace" color={C.brightGreen} bold>
                    SCP MEDICAL TRIAGE
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={2}>
                    <Box fontFamily="monospace" color={C.dim}>
                      TRIAGED: <Box as="span" color={C.highlight}>{total_patients_triaged}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      DECONS: <Box as="span" color="#00b5b5">{total_decontaminations}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      QUARANTINED: <Box as="span" color={C.red}>{total_quarantines}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      PENDING: <Box as="span" color={C.amber}>{pending_count}</Box>
                    </Box>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.amber}>
                  TRIAGE QUEUE ({pending_count})
                </Box>
              }
            >
              {triage_queue.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO PATIENTS IN QUEUE
                </Box>
              )}
              {triage_queue.map((patient) => (
                <Box key={patient.patient_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item grow>
                      <Stack vertical>
                        <Stack.Item>
                          <Stack gap={1} align="center">
                            <Box fontFamily="monospace" color={C.highlight} bold>
                              {patient.patient_name}
                            </Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={conditionColor(patient.condition)}
                              color={C.highlight}
                              px={1}
                              bold
                            >
                              {patient.condition}
                            </Box>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack align="center" gap={0.5}>
                            <Box fontFamily="monospace" color={C.dim}>SEV:</Box>
                            {[1, 2, 3, 4, 5].map((seg) => (
                              <Box
                                key={seg}
                                width="16px"
                                height="10px"
                                backgroundColor={seg <= patient.severity ? severityColor(patient.severity) : C.panel}
                                border={`1px solid ${C.border}`}
                              />
                            ))}
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack gap={2}>
                            <Box fontFamily="monospace" color={C.dim}>
                              Source: <Box as="span" color={C.text}>{patient.source}</Box>
                            </Box>
                            <Box fontFamily="monospace" color={C.dim}>
                              Area: <Box as="span" color={C.text}>{patient.area}</Box>
                            </Box>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Box fontFamily="monospace" color={C.dim} fontSize="11px">
                            Reported: {patient.time_reported}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      {patient.status === 0 && (
                        <Stack gap={0.5}>
                          {[1, 2, 3, 4, 5].map((pri) => (
                            <Button
                              key={pri}
                              fontFamily="monospace"
                              fontSize="11px"
                              backgroundColor={priorityColor(pri)}
                              color={C.bg}
                              content={`P${pri}`}
                              onClick={() => act('triage_patient', {
                                patient_id: patient.patient_id,
                                priority: pri,
                              })}
                            />
                          ))}
                        </Stack>
                      )}
                      {patient.priority > 0 && (
                        <Box
                          fontFamily="monospace"
                          backgroundColor={priorityColor(patient.priority)}
                          color={C.bg}
                          px={1}
                          bold
                          textAlign="center"
                        >
                          P{patient.priority}
                        </Box>
                      )}
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color="#00b5b5">
                  ACTIVE CASES
                </Box>
              }
            >
              {active_cases.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO ACTIVE CASES
                </Box>
              )}
              {active_cases.map((patient) => (
                <Box key={patient.patient_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack vertical gap={1}>
                    <Stack.Item>
                      <Stack gap={1} align="center">
                        <Box fontFamily="monospace" color={C.highlight} bold>
                          {patient.patient_name}
                        </Box>
                        <Box
                          fontFamily="monospace"
                          backgroundColor={conditionColor(patient.condition)}
                          color={C.highlight}
                          px={1}
                        >
                          {patient.condition}
                        </Box>
                        <Box fontFamily="monospace" color={C.dim}>|</Box>
                        <Box fontFamily="monospace" color={C.dim}>
                          Dr. <Box as="span" color={C.text}>{patient.assigned_doctor}</Box>
                        </Box>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack gap={1} align="center">
                        <Box fontFamily="monospace" color={C.dim} width="100px">Diagnosis:</Box>
                        <Input
                          fontFamily="monospace"
                          backgroundColor={C.panel}
                          borderColor={C.border}
                          color={C.text}
                          value={getDiagnosis(patient.patient_id)}
                          onInput={(_e, val) => setDiagnosisInput((prev) => ({ ...prev, [patient.patient_id]: val }))}
                          fluid
                        />
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack gap={0.5} align="center">
                        <Box fontFamily="monospace" color={C.dim} width="100px">Treatment:</Box>
                        {TREATMENT_TYPES.map((tt) => (
                          <Button
                            key={tt.key}
                            fontFamily="monospace"
                            fontSize="11px"
                            backgroundColor={getTreatment(patient.patient_id) === tt.key ? tt.color : C.panel}
                            color={getTreatment(patient.patient_id) === tt.key ? C.bg : C.dim}
                            content={tt.label}
                            onClick={() => setTreatmentType((prev) => ({ ...prev, [patient.patient_id]: tt.key }))}
                          />
                        ))}
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack gap={1}>
                        <Button
                          fontFamily="monospace"
                          backgroundColor={C.amber}
                          color={C.bg}
                          content="DIAGNOSE"
                          onClick={() => act('diagnose_patient', {
                            patient_id: patient.patient_id,
                            diagnosis: getDiagnosis(patient.patient_id),
                            treatment_type: getTreatment(patient.patient_id),
                          })}
                        />
                        <Button
                          fontFamily="monospace"
                          backgroundColor={C.brightGreen}
                          color={C.bg}
                          content="TREAT"
                          onClick={() => act('treat_patient', { patient_id: patient.patient_id })}
                        />
                        <Button
                          fontFamily="monospace"
                          backgroundColor="#00b5b5"
                          color={C.bg}
                          content="DECON"
                          onClick={() => act('perform_decontamination', { patient_id: patient.patient_id })}
                        />
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.red}>
                  QUARANTINE
                </Box>
              }
            >
              {quarantine_list.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO QUARANTINED PATIENTS
                </Box>
              )}
              {quarantine_list.map((patient) => (
                <Box key={patient.patient_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item>
                      <Stack gap={1} align="center">
                        <Box fontFamily="monospace" color={C.highlight} bold>
                          {patient.patient_name}
                        </Box>
                        <Box
                          fontFamily="monospace"
                          backgroundColor={conditionColor(patient.condition)}
                          color={C.highlight}
                          px={1}
                        >
                          {patient.condition}
                        </Box>
                        {patient.diagnosis && (
                          <>
                            <Box fontFamily="monospace" color={C.dim}>|</Box>
                            <Box fontFamily="monospace" color={C.amber}>{patient.diagnosis}</Box>
                          </>
                        )}
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        fontFamily="monospace"
                        backgroundColor={C.green}
                        color={C.highlight}
                        content="RELEASE"
                        onClick={() => act('release_from_quarantine', { patient_id: patient.patient_id })}
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.dim}>
                  TREATMENT LOG
                </Box>
              }
            >
              {treatment_log.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO TREATMENT RECORDS
                </Box>
              )}
              {treatment_log.slice(0, 15).map((entry, i) => (
                <Box key={i} py={0.5} borderBottom={`1px solid ${C.border}`}>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.highlight}>{entry.patient_name}</Box>
                    <Box fontFamily="monospace" color={C.dim}>|</Box>
                    <Box fontFamily="monospace" color={C.text}>{entry.diagnosis}</Box>
                    <Box fontFamily="monospace" color={C.dim}>|</Box>
                    <Box fontFamily="monospace" color={C.amber}>{entry.treatment_type}</Box>
                    <Box fontFamily="monospace" color={C.dim} fontSize="11px" ml="auto">
                      {entry.time_treated}
                    </Box>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          {doctor_stats && (
            <Stack.Item>
              <Section
                title={
                  <Box fontFamily="monospace" color={C.dim}>
                    DOCTOR STATISTICS
                  </Box>
                }
              >
                <Stack gap={2} wrap>
                  <Box fontFamily="monospace" color={C.dim}>
                    Triaged: <Box as="span" color={C.text}>{doctor_stats.total_triaged}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Treated: <Box as="span" color={C.brightGreen}>{doctor_stats.total_treated}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Decons: <Box as="span" color="#00b5b5">{doctor_stats.total_decontaminations}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Research: <Box as="span" color={C.amber}>{doctor_stats.total_research}</Box>
                  </Box>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
