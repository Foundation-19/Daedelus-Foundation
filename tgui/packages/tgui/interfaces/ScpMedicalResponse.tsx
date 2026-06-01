import { useState } from 'react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Input, LabeledList } from '../components';
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

const STATUS_LABELS = ['PENDING', 'DISPATCHED', 'EN ROUTE', 'ON SCENE', 'COMPLETE'];
const STATUS_COLORS = [C.amber, '#3366cc', '#00aacc', C.green, C.dim];

const SEVERITY_COLORS: Record<number, string> = {
  1: C.green,
  2: C.green,
  3: C.amber,
  4: C.red,
  5: C.red,
};

type Incident = {
  incident_id: string;
  victim_name: string;
  victim_job: string;
  injury_type: string;
  severity: number;
  source: string;
  area: string;
  status: number;
  responder: string;
  time_reported: number;
  time_responded: number;
};

type Contamination = {
  victim_name: string;
  victim_job: string;
  contaminant: string;
  source: string;
  area: string;
  decon_required: boolean;
  decon_complete: boolean;
  time: number;
};

type Data = {
  active_incidents: Incident[];
  contamination_queue: Contamination[];
  total_incidents: number;
  total_responses: number;
  total_decontaminations: number;
  avg_response_time: number;
};

const SeverityBar = (props: { severity: number }) => {
  const { severity } = props;
  return (
    <Stack inline>
      {[1, 2, 3, 4, 5].map((level) => (
        <Stack.Item key={level}>
          <Box
            inline
            width="12px"
            height="8px"
            backgroundColor={level <= severity ? SEVERITY_COLORS[severity] : C.border}
            style={{ border: `1px solid ${C.border}` }}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const StatusBadge = (props: { status: number }) => {
  const { status } = props;
  return (
    <Box
      inline
      px={1}
      py="2px"
      style={{
        border: `1px solid ${STATUS_COLORS[status]}`,
        color: STATUS_COLORS[status],
        fontFamily: 'monospace',
        fontSize: '11px',
      }}
    >
      {STATUS_LABELS[status]}
    </Box>
  );
};

export const ScpMedicalResponse = (_props: unknown) => {
  const { act, data } = useBackend<Data>();
  const {
    active_incidents = [],
    contamination_queue = [],
    total_incidents,
    total_responses,
    total_decontaminations,
    avg_response_time,
  } = data;

  const [reportVictim, setReportVictim] = useState('');
  const [reportType, setReportType] = useState('');
  const [reportSeverity, setReportSeverity] = useState(1);
  const [reportSource, setReportSource] = useState('');

  return (
    <NtosWindow title="SCP Medical Response" width={700} height={650} >
      <NtosWindow.Content scrollable>
        <Box backgroundColor={C.bg} height="100%">
          <Section
            title={
              <Stack align="center">
                <Stack.Item grow>
                  <Box fontFamily="monospace" fontSize="16px" color={C.highlight} bold>
                    SCP MEDICAL RESPONSE
                  </Box>
                </Stack.Item>
              </Stack>
            }
          >
            <Stack>
              <Stack.Item grow basis={0}>
                <Box
                  textAlign="center"
                  backgroundColor={C.panel}
                  style={{ border: `1px solid ${C.border}` }}
                  p={1}
                >
                  <Box color={C.dim} fontSize="10px" fontFamily="monospace">INCIDENTS</Box>
                  <Box color={C.highlight} fontSize="18px" fontFamily="monospace" bold>{total_incidents}</Box>
                </Box>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Box
                  textAlign="center"
                  backgroundColor={C.panel}
                  style={{ border: `1px solid ${C.border}` }}
                  p={1}
                >
                  <Box color={C.dim} fontSize="10px" fontFamily="monospace">RESPONSES</Box>
                  <Box color={C.highlight} fontSize="18px" fontFamily="monospace" bold>{total_responses}</Box>
                </Box>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Box
                  textAlign="center"
                  backgroundColor={C.panel}
                  style={{ border: `1px solid ${C.border}` }}
                  p={1}
                >
                  <Box color={C.dim} fontSize="10px" fontFamily="monospace">DECONS</Box>
                  <Box color={C.highlight} fontSize="18px" fontFamily="monospace" bold>{total_decontaminations}</Box>
                </Box>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Box
                  textAlign="center"
                  backgroundColor={C.panel}
                  style={{ border: `1px solid ${C.border}` }}
                  p={1}
                >
                  <Box color={C.dim} fontSize="10px" fontFamily="monospace">AVG RESPONSE TIME</Box>
                  <Box color={C.amber} fontSize="18px" fontFamily="monospace" bold>{avg_response_time}s</Box>
                </Box>
              </Stack.Item>
            </Stack>
          </Section>

          <Section
            title={
              <Box fontFamily="monospace" color={C.red} bold>
                ACTIVE INCIDENTS
              </Box>
            }
          >
            {active_incidents.length === 0 && (
              <Box color={C.dim} fontFamily="monospace" textAlign="center" py={2}>
                NO ACTIVE INCIDENTS
              </Box>
            )}
            {active_incidents.map((inc) => (
              <Box
                key={inc.incident_id}
                backgroundColor={C.panel}
                style={{ border: `1px solid ${C.border}` }}
                p={1}
                mb={1}
              >
                <Stack align="center">
                  <Stack.Item basis="30%">
                    <LabeledList>
                      <LabeledList.Item label="ID" labelColor={C.dim} color={C.highlight} fontFamily="monospace">
                        {inc.incident_id}
                      </LabeledList.Item>
                      <LabeledList.Item label="VICTIM" labelColor={C.dim} color={C.text} fontFamily="monospace">
                        {inc.victim_name} ({inc.victim_job})
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item basis="20%">
                    <LabeledList>
                      <LabeledList.Item label="INJURY" labelColor={C.dim} color={C.text} fontFamily="monospace">
                        {inc.injury_type}
                      </LabeledList.Item>
                      <LabeledList.Item label="SEVERITY" labelColor={C.dim}>
                        <SeverityBar severity={inc.severity} />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item basis="20%">
                    <LabeledList>
                      <LabeledList.Item label="SOURCE" labelColor={C.dim} color={C.text} fontFamily="monospace">
                        {inc.source}
                      </LabeledList.Item>
                      <LabeledList.Item label="AREA" labelColor={C.dim} color={C.text} fontFamily="monospace">
                        {inc.area}
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item basis="15%">
                    <Stack vertical>
                      <Stack.Item>
                        <StatusBadge status={inc.status} />
                      </Stack.Item>
                      {inc.responder && (
                        <Stack.Item color={C.dim} fontFamily="monospace" fontSize="10px">
                          {inc.responder}
                        </Stack.Item>
                      )}
                    </Stack>
                  </Stack.Item>
                  <Stack.Item basis="15%" textAlign="right">
                    {inc.status === 0 && (
                      <Button
                        backgroundColor={C.darkRed}
                        color={C.highlight}
                        fontFamily="monospace"
                        fontSize="11px"
                        onClick={() => act('dispatch_responder', { incident_id: inc.incident_id })}
                      >
                        DISPATCH
                      </Button>
                    )}
                    {inc.status === 1 && (
                      <Stack vertical>
                        <Button
                          backgroundColor="#003344"
                          color="#00aacc"
                          fontFamily="monospace"
                          fontSize="10px"
                          onClick={() => act('update_status', { incident_id: inc.incident_id, status: 2 })}
                        >
                          EN ROUTE
                        </Button>
                        <Button
                          backgroundColor="#003311"
                          color={C.brightGreen}
                          fontFamily="monospace"
                          fontSize="10px"
                          onClick={() => act('update_status', { incident_id: inc.incident_id, status: 3 })}
                        >
                          ON SCENE
                        </Button>
                        <Button
                          backgroundColor={C.panel}
                          color={C.dim}
                          fontFamily="monospace"
                          fontSize="10px"
                          onClick={() => act('update_status', { incident_id: inc.incident_id, status: 4 })}
                        >
                          COMPLETE
                        </Button>
                      </Stack>
                    )}
                    {inc.status === 2 && (
                      <Stack vertical>
                        <Button
                          backgroundColor="#003311"
                          color={C.brightGreen}
                          fontFamily="monospace"
                          fontSize="10px"
                          onClick={() => act('update_status', { incident_id: inc.incident_id, status: 3 })}
                        >
                          ON SCENE
                        </Button>
                        <Button
                          backgroundColor={C.panel}
                          color={C.dim}
                          fontFamily="monospace"
                          fontSize="10px"
                          onClick={() => act('update_status', { incident_id: inc.incident_id, status: 4 })}
                        >
                          COMPLETE
                        </Button>
                      </Stack>
                    )}
                    {inc.status === 3 && (
                      <Button
                        backgroundColor={C.panel}
                        color={C.dim}
                        fontFamily="monospace"
                        fontSize="11px"
                        onClick={() => act('update_status', { incident_id: inc.incident_id, status: 4 })}
                      >
                        COMPLETE
                      </Button>
                    )}
                  </Stack.Item>
                </Stack>
              </Box>
            ))}
          </Section>

          <Section
            title={
              <Box fontFamily="monospace" color={C.amber} bold>
                CONTAMINATION QUEUE
              </Box>
            }
          >
            {contamination_queue.length === 0 && (
              <Box color={C.dim} fontFamily="monospace" textAlign="center" py={2}>
                NO CONTAMINATION RECORDS
              </Box>
            )}
            {contamination_queue.map((con, i) => (
              <Box
                key={`${con.victim_name}-${i}`}
                backgroundColor={C.panel}
                style={{ border: `1px solid ${C.border}` }}
                p={1}
                mb={1}
              >
                <Stack align="center">
                  <Stack.Item basis="25%">
                    <LabeledList>
                      <LabeledList.Item label="VICTIM" labelColor={C.dim} color={C.text} fontFamily="monospace">
                        {con.victim_name} ({con.victim_job})
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item basis="20%">
                    <LabeledList>
                      <LabeledList.Item label="CONTAMINANT" labelColor={C.dim} color={C.red} fontFamily="monospace">
                        {con.contaminant}
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item basis="20%">
                    <LabeledList>
                      <LabeledList.Item label="SOURCE" labelColor={C.dim} color={C.text} fontFamily="monospace">
                        {con.source}
                      </LabeledList.Item>
                      <LabeledList.Item label="AREA" labelColor={C.dim} color={C.text} fontFamily="monospace">
                        {con.area}
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box fontFamily="monospace" fontSize="11px">
                      {con.decon_complete ? (
                        <Box color={C.brightGreen} inline>DECON COMPLETE</Box>
                      ) : con.decon_required ? (
                        <Box color={C.amber} inline>DECON REQUIRED</Box>
                      ) : (
                        <Box color={C.dim} inline>NO DECON NEEDED</Box>
                      )}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    {con.decon_required && !con.decon_complete && (
                      <Button
                        backgroundColor={C.darkRed}
                        color={C.highlight}
                        fontFamily="monospace"
                        fontSize="11px"
                        onClick={() => act('complete_decon', { victim: con.victim_name })}
                      >
                        COMPLETE DECON
                      </Button>
                    )}
                  </Stack.Item>
                </Stack>
              </Box>
            ))}
          </Section>

          <Section
            title={
              <Box fontFamily="monospace" color={C.green} bold>
                REPORT INJURY
              </Box>
            }
          >
            <Stack>
              <Stack.Item grow basis="30%">
                <Box color={C.dim} fontFamily="monospace" fontSize="10px" mb={0.5}>VICTIM</Box>
                <Input
                  value={reportVictim}
                  onInput={(_e: unknown, value: string) => setReportVictim(value)}
                  backgroundColor={C.panel}
                  style={{ border: `1px solid ${C.border}`, color: C.text, fontFamily: 'monospace' }}
                  fluid
                />
              </Stack.Item>
              <Stack.Item grow basis="20%">
                <Box color={C.dim} fontFamily="monospace" fontSize="10px" mb={0.5}>INJURY TYPE</Box>
                <Input
                  value={reportType}
                  onInput={(_e: unknown, value: string) => setReportType(value)}
                  backgroundColor={C.panel}
                  style={{ border: `1px solid ${C.border}`, color: C.text, fontFamily: 'monospace' }}
                  fluid
                />
              </Stack.Item>
              <Stack.Item grow basis="15%">
                <Box color={C.dim} fontFamily="monospace" fontSize="10px" mb={0.5}>SEVERITY</Box>
                <Stack>
                  {[1, 2, 3, 4, 5].map((level) => (
                    <Stack.Item key={level}>
                      <Button
                        backgroundColor={reportSeverity === level ? SEVERITY_COLORS[level] : C.panel}
                        color={reportSeverity === level ? C.highlight : C.dim}
                        fontFamily="monospace"
                        fontSize="12px"
                        onClick={() => setReportSeverity(level)}
                        style={{ border: `1px solid ${reportSeverity === level ? SEVERITY_COLORS[level] : C.border}` }}
                      >
                        {level}
                      </Button>
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow basis="20%">
                <Box color={C.dim} fontFamily="monospace" fontSize="10px" mb={0.5}>SOURCE</Box>
                <Input
                  value={reportSource}
                  onInput={(_e: unknown, value: string) => setReportSource(value)}
                  backgroundColor={C.panel}
                  style={{ border: `1px solid ${C.border}`, color: C.text, fontFamily: 'monospace' }}
                  fluid
                />
              </Stack.Item>
              <Stack.Item alignSelf="flex-end">
                <Button
                  backgroundColor={C.darkRed}
                  color={C.highlight}
                  fontFamily="monospace"
                  bold
                  onClick={() => {
                    act('report_injury', {
                      victim: reportVictim,
                      type: reportType,
                      severity: reportSeverity,
                      source: reportSource,
                    });
                    setReportVictim('');
                    setReportType('');
                    setReportSeverity(1);
                    setReportSource('');
                  }}
                >
                  REPORT
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
