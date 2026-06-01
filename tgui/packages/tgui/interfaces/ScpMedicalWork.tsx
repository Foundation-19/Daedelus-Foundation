import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, Tabs, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Patient = {
  patient_id: string;
  patient_name: string;
  condition: string;
  severity: number;
  priority: number;
  status: number;
  assigned_doctor: string;
  area: string;
};

type Data = {
  is_trainee: BooleanLike;
  is_senior: BooleanLike;
  user_job: string;
  triage_queue: Patient[];
  active_cases: Patient[];
  pending_count: number;
  contamination_cases: object[];
  doctor_stats: object;
  total_patients: number;
  total_decons: number;
};

const STATUS_NAMES = ['Awaiting', 'Triaged', 'Treating', 'Complete', 'Quarantined'];
const PRIORITY_NAMES = ['Unassigned', 'Low', 'Medium', 'High', 'Critical', 'Immediate'];

export const ScpMedicalWork = (_props) => {
  const { act, data } = useBackend<Data>();

  const [selectedTab, setSelectedTab] = useLocalState<string>(
    'medTab',
    'triage',
  );

  const {
    is_trainee,
    is_senior,
    user_job,
    triage_queue,
    pending_count,
    doctor_stats,
    total_patients,
    total_decons,
  } = data;

  return (
    <NtosWindow width={550} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="Medical Work Terminal">
          <LabeledList>
            <LabeledList.Item label="Role">
              {user_job || 'Medical Staff'}
            </LabeledList.Item>
            <LabeledList.Item label="Pending Patients">
              {pending_count}
            </LabeledList.Item>
            <LabeledList.Item label="Patients Triageed">
              {total_patients}
            </LabeledList.Item>
            <LabeledList.Item label="Decontaminations">
              {total_decons}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Tabs>
          <Tabs.Tab
            selected={selectedTab === 'triage'}
            onClick={() => setSelectedTab('triage')}
          >
            Triage Queue
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'report'}
            onClick={() => setSelectedTab('report')}
          >
            Report Patient
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'contamination'}
            onClick={() => setSelectedTab('contamination')}
          >
            Contamination
          </Tabs.Tab>
        </Tabs>

        {selectedTab === 'triage' && (
          <Section title="Triage Queue">
            {(triage_queue || []).length > 0 ? (
              triage_queue.map((patient) => (
                <Box key={patient.patient_id} mb={1}>
                  <Box bold color={patient.severity >= 4 ? 'bad' : 'label'}>
                    {patient.patient_name} — {patient.condition}
                  </Box>
                  <Box color="label" fontSize="11px">
                    Priority: {PRIORITY_NAMES[patient.priority] || 'Unassigned'}
                    {' | '}Status: {STATUS_NAMES[patient.status] || 'Unknown'}
                    {' | '}Area: {patient.area}
                  </Box>
                  <Box mt={0.5}>
                    {patient.status === 0 && is_senior && (
                      <Button
                        onClick={() =>
                          act('triage_patient', {
                            patient_id: patient.patient_id,
                            priority: 3,
                          })
                        }
                      >
                        Triage
                      </Button>
                    )}
                    {patient.status === 1 && is_senior && (
                      <Button
                        onClick={() =>
                          act('diagnose_patient', {
                            patient_id: patient.patient_id,
                            diagnosis: 'Anomalous exposure',
                            treatment_type: 'observation',
                          })
                        }
                      >
                        Diagnose
                      </Button>
                    )}
                    {patient.status === 2 && (
                      <>
                        {is_senior && (
                          <Button
                            onClick={() =>
                              act('treat_patient', {
                                patient_id: patient.patient_id,
                              })
                            }
                          >
                            Treat
                          </Button>
                        )}
                        <Button
                          onClick={() =>
                            act('assist_treatment', {
                              patient_id: patient.patient_id,
                            })
                          }
                        >
                          Assist (+5 Research)
                        </Button>
                      </>
                    )}
                    {patient.status === 0 && (
                      <Button
                        onClick={() =>
                          act('dispatch_trainee', {
                            patient_id: patient.patient_id,
                          })
                        }
                      >
                        Self-Dispatch
                      </Button>
                    )}
                  </Box>
                </Box>
              ))
            ) : (
              <Box color="label">No patients in triage queue.</Box>
            )}
          </Section>
        )}

        {selectedTab === 'report' && (
          <ReportPatientTab act={act} />
        )}

        {selectedTab === 'contamination' && (
          <Section title="Contamination Reports">
            <Button
              fluid
              onClick={() =>
                act('report_contamination', {
                  condition: 'unknown_contaminant',
                  source: 'field_report',
                })
              }
            >
              Report Contamination Event
            </Button>
            <Button
              fluid
              mt={1}
              onClick={() =>
                act('perform_decontamination', {
                  patient_id: 'self',
                })
              }
            >
              Request Self-Decontamination
            </Button>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const ReportPatientTab = ({ act }) => {
  const [condition, setCondition] = useLocalState<string>(
    'rptCondition',
    'physical_trauma',
  );
  const [severity, setSeverity] = useLocalState<number>('rptSeverity', 1);
  const [source, setSource] = useLocalState<string>('rptSource', '');

  return (
    <Section title="Report Patient">
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Condition:
        </Box>
        {[
          'physical_trauma',
          'anomalous_exposure',
          'biohazard',
          'psychological',
          'contamination',
        ].map((cond) => (
          <Button
            key={cond}
            selected={condition === cond}
            onClick={() => setCondition(cond)}
          >
            {cond.replace(/_/g, ' ')}
          </Button>
        ))}
      </Box>
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Severity (1-5):
        </Box>
        {[1, 2, 3, 4, 5].map((s) => (
          <Button key={s} selected={severity === s} onClick={() => setSeverity(s)}>
            {s}
          </Button>
        ))}
      </Box>
      <Box mb={1}>
        <Box color="label" mb={0.5}>
          Source:
        </Box>
        <TextArea
          value={source}
          onInput={(_, value) => setSource(value)}
          height="40px"
          width="100%"
        />
      </Box>
      <Button
        fluid
        onClick={() => act('report_patient', { condition, severity, source })}
      >
        Report Patient
      </Button>
    </Section>
  );
};
