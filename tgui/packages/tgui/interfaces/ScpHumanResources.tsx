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

const statusColor = (status: number) => {
  if (status === 0) return C.amber;
  if (status === 1) return C.brightGreen;
  if (status === 2) return C.red;
  return C.dim;
};

const statusLabel = (status: number) => {
  if (status === 0) return 'PENDING';
  if (status === 1) return 'APPROVED';
  if (status === 2) return 'DENIED';
  return 'UNKNOWN';
};

type ClearanceRequest = {
  requestor: string;
  job: string;
  current_access: number;
  requested_level: number;
  reason: string;
  status: number;
  time: number;
  ckey: string;
};

type ReassignmentRequest = {
  subject: string;
  job: string;
  current_dept: string;
  new_dept: string;
  reason: string;
  requestor: string;
  status: number;
  time: number;
};

type AmnesticAuthorization = {
  subject_name: string;
  class: string;
  reason: string;
  authorizer: string;
  time: number;
};

type ExposureReview = {
  subject_name: string;
  exposure_level: number;
  review_status: number;
  notes: string;
  time: number;
};

type Data = {
  access_denied: boolean;
  clearance_requests: ClearanceRequest[];
  reassignment_requests: ReassignmentRequest[];
  amnestic_authorizations: AmnesticAuthorization[];
  exposure_reviews: ExposureReview[];
  pending_count: number;
  total_reviews: number;
  approved_reviews: number;
  denied_reviews: number;
  total_reassignments: number;
  total_amnestic_auths: number;
};

export const ScpHumanResources = (_props: unknown) => {
  const { act, data } = useBackend<Data>();
  const {
    access_denied,
    clearance_requests = [],
    reassignment_requests = [],
    amnestic_authorizations = [],
    exposure_reviews = [],
    pending_count,
    total_reviews,
    approved_reviews,
    denied_reviews,
    total_reassignments,
    total_amnestic_auths,
  } = data;

  const [clearanceNotes, setClearanceNotes] = useLocalState<Record<string, string>>('clearanceNotes', {});
  const [reassignNotes, setReassignNotes] = useLocalState<Record<number, string>>('reassignNotes', {});
  const [amnesticSubject, setAmnesticSubject] = useLocalState<string>('amnesticSubject', '');
  const [amnesticClass, setAmnesticClass] = useLocalState<string>('amnesticClass', '');
  const [amnesticReason, setAmnesticReason] = useLocalState<string>('amnesticReason', '');
  const [exposureNotes, setExposureNotes] = useLocalState<Record<number, string>>('exposureNotes', {});

  if (access_denied) {
    return (
      <NtosWindow width={700} height={650}>
        <NtosWindow.Content scrollable>
          <Box
            style={{
              fontFamily: 'monospace',
              background: C.bg,
              border: `1px solid ${C.border}`,
              padding: '24px',
              textAlign: 'center',
              marginTop: '120px',
            }}
          >
            <Box style={{ color: C.red, fontSize: '14px', letterSpacing: '0.15em', marginBottom: '12px' }}>
              ACCESS DENIED
            </Box>
            <Box style={{ color: C.dim, fontSize: '10px', letterSpacing: '0.1em' }}>
              INSUFFICIENT CLEARANCE FOR PERSONNEL MANAGEMENT SYSTEM
            </Box>
          </Box>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section
          title="HUMAN RESOURCES — PERSONNEL MANAGEMENT"
          style={{
            fontFamily: 'monospace',
            background: C.panel,
            border: `1px solid ${C.border}`,
          }}
        >
          <Box style={{ fontSize: '10px', color: C.dim, letterSpacing: '0.1em', marginBottom: '12px' }}>
            SCP FOUNDATION PERSONNEL OVERSIGHT TERMINAL v3.2
          </Box>
          <Stack style={{ marginBottom: '4px' }}>
            <Stack.Item grow>
              <Box
                style={{
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  padding: '6px 8px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ color: C.dim, fontSize: '11px', letterSpacing: '0.1em' }}>PENDING</Box>
                <Box style={{ color: C.amber, fontSize: '16px' }}>{pending_count}</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box
                style={{
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  padding: '6px 8px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ color: C.dim, fontSize: '11px', letterSpacing: '0.1em' }}>REVIEWS</Box>
                <Box style={{ color: C.text, fontSize: '16px' }}>{total_reviews}</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box
                style={{
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  padding: '6px 8px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ color: C.dim, fontSize: '11px', letterSpacing: '0.1em' }}>APPROVED</Box>
                <Box style={{ color: C.brightGreen, fontSize: '16px' }}>{approved_reviews}</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box
                style={{
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  padding: '6px 8px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ color: C.dim, fontSize: '11px', letterSpacing: '0.1em' }}>DENIED</Box>
                <Box style={{ color: C.red, fontSize: '16px' }}>{denied_reviews}</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box
                style={{
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  padding: '6px 8px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ color: C.dim, fontSize: '11px', letterSpacing: '0.1em' }}>REASSIGNMENTS</Box>
                <Box style={{ color: C.text, fontSize: '16px' }}>{total_reassignments}</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box
                style={{
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  padding: '6px 8px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ color: C.dim, fontSize: '11px', letterSpacing: '0.1em' }}>AMNESTIC AUTHS</Box>
                <Box style={{ color: C.text, fontSize: '16px' }}>{total_amnestic_auths}</Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>

        <Section
          title="CLEARANCE REQUESTS"
          style={{
            fontFamily: 'monospace',
            background: C.panel,
            border: `1px solid ${C.border}`,
            marginTop: '8px',
          }}
        >
          {clearance_requests.length === 0 && (
            <Box style={{ color: C.dim, fontSize: '10px', letterSpacing: '0.1em', textAlign: 'center', padding: '12px' }}>
              NO CLEARANCE REQUESTS ON FILE
            </Box>
          )}
          {clearance_requests.map((req, i) => (
            <Box
              key={i}
              style={{
                background: C.bg,
                border: `1px solid ${C.border}`,
                borderLeft: `3px solid ${statusColor(req.status)}`,
                padding: '8px',
                marginBottom: '6px',
              }}
            >
              <Stack>
                <Stack.Item grow>
                  <Box style={{ color: C.highlight, fontSize: '11px', marginBottom: '2px' }}>
                    {req.requestor} — {req.job}
                  </Box>
                  <Box style={{ color: C.dim, fontSize: '10px', marginBottom: '2px' }}>
                    CLEARANCE: LVL-{req.current_access} → LVL-{req.requested_level}
                  </Box>
                  <Box style={{ color: C.text, fontSize: '10px', marginBottom: '2px' }}>
                    REASON: {req.reason}
                  </Box>
                  <Box style={{ color: statusColor(req.status), fontSize: '10px', letterSpacing: '0.1em' }}>
                    STATUS: {statusLabel(req.status)}
                  </Box>
                </Stack.Item>
              </Stack>
              {req.status === 0 && (
                <Box style={{ marginTop: '6px' }}>
                  <Box style={{ marginBottom: '4px' }}>
                    <Input
                      value={clearanceNotes[req.ckey] || ''}
                      placeholder="Review notes..."
                      fluid
                      onInput={(_e: unknown, val: string) =>
                        setClearanceNotes({ ...clearanceNotes, [req.ckey]: val })
                      }
                    />
                  </Box>
                  <Stack>
                    <Stack.Item>
                      <Button
                        content="APPROVE"
                        style={{
                          background: C.green,
                          color: C.brightGreen,
                          borderColor: C.green,
                          fontFamily: 'monospace',
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                        }}
                        onClick={() =>
                          act('approve_clearance', {
                            ckey: req.ckey,
                            notes: clearanceNotes[req.ckey] || '',
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="DENY"
                        style={{
                          background: C.darkRed,
                          color: C.red,
                          borderColor: C.red,
                          fontFamily: 'monospace',
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                        }}
                        onClick={() =>
                          act('deny_clearance', {
                            ckey: req.ckey,
                            notes: clearanceNotes[req.ckey] || '',
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              )}
            </Box>
          ))}
        </Section>

        <Section
          title="REASSIGNMENT REQUESTS"
          style={{
            fontFamily: 'monospace',
            background: C.panel,
            border: `1px solid ${C.border}`,
            marginTop: '8px',
          }}
        >
          {reassignment_requests.length === 0 && (
            <Box style={{ color: C.dim, fontSize: '10px', letterSpacing: '0.1em', textAlign: 'center', padding: '12px' }}>
              NO REASSIGNMENT REQUESTS ON FILE
            </Box>
          )}
          {reassignment_requests.map((req, i) => (
            <Box
              key={i}
              style={{
                background: C.bg,
                border: `1px solid ${C.border}`,
                borderLeft: `3px solid ${statusColor(req.status)}`,
                padding: '8px',
                marginBottom: '6px',
              }}
            >
              <Stack>
                <Stack.Item grow>
                  <Box style={{ color: C.highlight, fontSize: '11px', marginBottom: '2px' }}>
                    {req.subject} — {req.job}
                  </Box>
                  <Box style={{ color: C.dim, fontSize: '10px', marginBottom: '2px' }}>
                    DEPT: {req.current_dept} → {req.new_dept}
                  </Box>
                  <Box style={{ color: C.text, fontSize: '10px', marginBottom: '2px' }}>
                    REASON: {req.reason}
                  </Box>
                  <Box style={{ color: C.dim, fontSize: '10px', marginBottom: '2px' }}>
                    REQUESTOR: {req.requestor}
                  </Box>
                  <Box style={{ color: statusColor(req.status), fontSize: '10px', letterSpacing: '0.1em' }}>
                    STATUS: {statusLabel(req.status)}
                  </Box>
                </Stack.Item>
              </Stack>
              {req.status === 0 && (
                <Box style={{ marginTop: '6px' }}>
                  <Box style={{ marginBottom: '4px' }}>
                    <Input
                      value={reassignNotes[i] || ''}
                      placeholder="Review notes..."
                      fluid
                      onInput={(_e: unknown, val: string) =>
                        setReassignNotes({ ...reassignNotes, [i]: val })
                      }
                    />
                  </Box>
                  <Stack>
                    <Stack.Item>
                      <Button
                        content="APPROVE"
                        style={{
                          background: C.green,
                          color: C.brightGreen,
                          borderColor: C.green,
                          fontFamily: 'monospace',
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                        }}
                        onClick={() =>
                          act('approve_reassignment', {
                            index: i,
                            notes: reassignNotes[i] || '',
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="DENY"
                        style={{
                          background: C.darkRed,
                          color: C.red,
                          borderColor: C.red,
                          fontFamily: 'monospace',
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                        }}
                        onClick={() =>
                          act('deny_reassignment', {
                            index: i,
                            notes: reassignNotes[i] || '',
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              )}
            </Box>
          ))}
        </Section>

        <Section
          title="AMNESTIC AUTHORIZATION"
          style={{
            fontFamily: 'monospace',
            background: C.panel,
            border: `1px solid ${C.border}`,
            marginTop: '8px',
          }}
        >
          <Box
            style={{
              background: C.bg,
              border: `1px solid ${C.border}`,
              borderLeft: `3px solid ${C.amber}`,
              padding: '8px',
              marginBottom: '8px',
            }}
          >
            <Box style={{ color: C.dim, fontSize: '11px', letterSpacing: '0.1em', marginBottom: '8px' }}>
              ISSUE NEW AMNESTIC AUTHORIZATION
            </Box>
            <LabeledList>
              <LabeledList.Item label="SUBJECT" style={{ color: C.dim }}>
                <Input
                  value={amnesticSubject}
                  placeholder="Subject name..."
                  fluid
                  onInput={(_e: unknown, val: string) => setAmnesticSubject(val)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="CLASS" style={{ color: C.dim }}>
                <Input
                  value={amnesticClass}
                  placeholder="A / B / C"
                  fluid
                  onInput={(_e: unknown, val: string) => setAmnesticClass(val)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="REASON" style={{ color: C.dim }}>
                <Input
                  value={amnesticReason}
                  placeholder="Justification..."
                  fluid
                  onInput={(_e: unknown, val: string) => setAmnesticReason(val)}
                />
              </LabeledList.Item>
            </LabeledList>
            <Box style={{ marginTop: '8px' }}>
              <Button
                content="AUTHORIZE"
                disabled={!amnesticSubject || !amnesticClass || !amnesticReason}
                style={{
                  background: C.amber,
                  color: C.bg,
                  borderColor: C.amber,
                  fontFamily: 'monospace',
                  fontSize: '10px',
                  letterSpacing: '0.1em',
                }}
                onClick={() =>
                  act('authorize_amnestic', {
                    subject: amnesticSubject,
                    class: amnesticClass,
                    reason: amnesticReason,
                  })
                }
              />
            </Box>
          </Box>
          {amnestic_authorizations.length === 0 && (
            <Box style={{ color: C.dim, fontSize: '10px', letterSpacing: '0.1em', textAlign: 'center', padding: '12px' }}>
              NO AMNESTIC AUTHORIZATIONS ON FILE
            </Box>
          )}
          {amnestic_authorizations.map((auth, i) => (
            <Box
              key={i}
              style={{
                background: C.bg,
                border: `1px solid ${C.border}`,
                borderLeft: `3px solid ${C.red}`,
                padding: '8px',
                marginBottom: '6px',
              }}
            >
              <Box style={{ color: C.highlight, fontSize: '11px', marginBottom: '2px' }}>
                {auth.subject_name}
              </Box>
              <Box style={{ color: C.red, fontSize: '10px', marginBottom: '2px' }}>
                CLASS-{auth.class} AMNESTIC
              </Box>
              <Box style={{ color: C.text, fontSize: '10px', marginBottom: '2px' }}>
                REASON: {auth.reason}
              </Box>
              <Box style={{ color: C.dim, fontSize: '10px' }}>
                AUTHORIZED BY: {auth.authorizer}
              </Box>
            </Box>
          ))}
        </Section>

        <Section
          title="EXPOSURE REVIEWS"
          style={{
            fontFamily: 'monospace',
            background: C.panel,
            border: `1px solid ${C.border}`,
            marginTop: '8px',
          }}
        >
          {exposure_reviews.length === 0 && (
            <Box style={{ color: C.dim, fontSize: '10px', letterSpacing: '0.1em', textAlign: 'center', padding: '12px' }}>
              NO EXPOSURE REVIEWS ON FILE
            </Box>
          )}
          {exposure_reviews.map((rev, i) => {
            const reviewed = rev.review_status !== 0;
            return (
              <Box
                key={i}
                style={{
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  borderLeft: `3px solid ${rev.review_status === 0 ? C.amber : rev.review_status === 1 ? C.brightGreen : C.red}`,
                  padding: '8px',
                  marginBottom: '6px',
                }}
              >
                <Box style={{ color: C.highlight, fontSize: '11px', marginBottom: '2px' }}>
                  {rev.subject_name}
                </Box>
                <Box style={{ color: C.amber, fontSize: '10px', marginBottom: '2px' }}>
                  EXPOSURE LEVEL: {rev.exposure_level}
                </Box>
                <Box style={{ color: C.text, fontSize: '10px', marginBottom: '2px' }}>
                  NOTES: {rev.notes}
                </Box>
                <Box
                  style={{
                    color: rev.review_status === 0 ? C.amber : rev.review_status === 1 ? C.brightGreen : C.red,
                    fontSize: '10px',
                    letterSpacing: '0.1em',
                  }}
                >
                  {rev.review_status === 0 ? 'PENDING REVIEW' : rev.review_status === 1 ? 'FIT FOR DUTY' : 'UNFIT FOR DUTY'}
                </Box>
                {!reviewed && (
                  <Box style={{ marginTop: '6px' }}>
                    <Box style={{ marginBottom: '4px' }}>
                      <Input
                        value={exposureNotes[i] || ''}
                        placeholder="Review notes..."
                        fluid
                        onInput={(_e: unknown, val: string) =>
                          setExposureNotes({ ...exposureNotes, [i]: val })
                        }
                      />
                    </Box>
                    <Stack>
                      <Stack.Item>
                        <Button
                          content="FIT FOR DUTY"
                          style={{
                            background: C.green,
                            color: C.brightGreen,
                            borderColor: C.green,
                            fontFamily: 'monospace',
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                          }}
                          onClick={() =>
                            act('review_exposure', {
                              index: i,
                              fit: '1',
                              notes: exposureNotes[i] || '',
                            })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          content="UNFIT"
                          style={{
                            background: C.darkRed,
                            color: C.red,
                            borderColor: C.red,
                            fontFamily: 'monospace',
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                          }}
                          onClick={() =>
                            act('review_exposure', {
                              index: i,
                              fit: '0',
                              notes: exposureNotes[i] || '',
                            })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Box>
                )}
              </Box>
            );
          })}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
