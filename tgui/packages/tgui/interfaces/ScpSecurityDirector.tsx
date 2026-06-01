import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Section, TextArea, Input } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  directives: Directive[];
  alert_codes: AlertCode[];
  response_plans: ResponsePlan[];
  total_directives_issued: number;
  total_codes_activated: number;
  total_responses_coordinated: number;
  active_codes: number;
  active_directives: number;
  active_plans: number;
  guards_on_duty: number;
  patrol_stats: PatrolStats;
  threat_level: number;
  containment_status: ContainmentStatus;
};

type Directive = {
  directive_id: string;
  issuer: string;
  directive_type: string;
  target: string;
  description: string;
  priority: number;
  status: string;
  time_issued: number;
  responders: { name: string; time: number }[];
};

type AlertCode = {
  code_id: string;
  code_type: string;
  scope: string;
  reason: string;
  activated_by: string;
  time_activated: number;
  status: string;
};

type ResponsePlan = {
  plan_id: string;
  scp_id: string;
  response_type: string;
  coordinator: string;
  time_created: number;
  status: string;
};

type PatrolStats = {
  total_patrols: number;
  total_anomalies: number;
  total_breach_responses: number;
  total_contraband: number;
  zone_threats: { lcz: number; hcz: number; ez: number };
};

type ContainmentStatus = {
  overall: number;
  overdue_tasks: number;
};

const THREAT_COLOR = (t: number) => (t > 70 ? '#cc2222' : t > 40 ? '#ff8800' : t > 15 ? '#d4a017' : '#44ff44');
const CODE_COLORS: Record<string, string> = { lockdown: '#cc2222', sweep: '#d4a017', perimeter: '#4488ff', stand_down: '#44ff44' };
const RESPONSE_COLORS: Record<string, string> = { standard: '#4488ff', evacuation: '#ff8800', full_containment: '#cc2222' };

export const ScpSecurityDirector = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    directives, alert_codes, response_plans,
    total_directives_issued, total_codes_activated, total_responses_coordinated,
    active_codes, active_directives, active_plans, guards_on_duty,
    patrol_stats, threat_level, containment_status,
  } = data;

  const [activeTab, setActiveTab] = useState<'status' | 'directives' | 'codes' | 'response'>('status');
  const [dirType, setDirType] = useState('');
  const [dirTarget, setDirTarget] = useState('');
  const [dirDesc, setDirDesc] = useState('');
  const [dirPriority, setDirPriority] = useState(0);
  const [codeType, setCodeType] = useState('lockdown');
  const [codeScope, setCodeScope] = useState('facility');
  const [codeReason, setCodeReason] = useState('');
  const [respScp, setRespScp] = useState('');
  const [respType, setRespType] = useState('standard');

  return (
    <NtosWindow width={750} height={700}>
      <NtosWindow.Content scrollable>
        <Section title="SECURITY DIRECTOR CONSOLE">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            DIRECTIVES: {active_directives} | ALERT CODES: {active_codes} | RESPONSE PLANS: {active_plans} | GUARDS: {guards_on_duty}
          </Box>
          <Box style={{ display: 'flex', gap: '2px', marginBottom: '4px' }}>
            {(['status', 'directives', 'codes', 'response'] as const).map((tab) => (
              <Button key={tab} selected={activeTab === tab} onClick={() => setActiveTab(tab)}
                style={{ fontFamily: 'monospace', fontSize: '11px', padding: '4px 10px', textTransform: 'uppercase' }}>
                {tab}
              </Button>
            ))}
          </Box>
        </Section>

        {activeTab === 'status' && (
          <Section title="SECURITY STATUS">
            <Box style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginBottom: '8px' }}>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: `2px solid ${THREAT_COLOR(threat_level * 25)}` }}>
                <Box style={{ color: THREAT_COLOR(threat_level * 25), fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>THREAT LEVEL</Box>
                <Box style={{ fontSize: '16px', fontWeight: 'bold', fontFamily: 'monospace' }}>
                  {['GREEN', 'YELLOW', 'ORANGE', 'RED'][threat_level] || 'UNKNOWN'}
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #4488ff' }}>
                <Box style={{ color: '#4488ff', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>GUARDS ON DUTY</Box>
                <Box style={{ fontSize: '16px', fontWeight: 'bold', fontFamily: 'monospace' }}>{guards_on_duty}</Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #d4a017' }}>
                <Box style={{ color: '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>CONTAINMENT INTEGRITY</Box>
                <Box style={{ fontSize: '16px', fontWeight: 'bold', fontFamily: 'monospace', color: (containment_status?.overall || 100) >= 75 ? '#44ff44' : (containment_status?.overall || 100) >= 50 ? '#d4a017' : '#cc2222' }}>
                  {containment_status?.overall ?? 100}%
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #44ff44' }}>
                <Box style={{ color: '#44ff44', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '11px' }}>PATROL STATS</Box>
                <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>
                  Completed: {patrol_stats?.total_patrols || 0} | Anomalies: {patrol_stats?.total_anomalies || 0} | Contraband: {patrol_stats?.total_contraband || 0}
                </Box>
              </Box>
            </Box>
            {patrol_stats?.zone_threats && (
              <Box style={{ display: 'flex', gap: '8px', marginBottom: '8px' }}>
                {Object.entries(patrol_stats.zone_threats).map(([zone, level]) => (
                  <Box key={zone} style={{ padding: '6px 12px', background: '#111114', borderLeft: `2px solid ${THREAT_COLOR(level)}`, flex: 1, textAlign: 'center' }}>
                    <Box style={{ color: THREAT_COLOR(level), fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>{zone.toUpperCase()}</Box>
                    <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>Threat: {level}</Box>
                  </Box>
                ))}
              </Box>
            )}
          </Section>
        )}

        {activeTab === 'directives' && (
          <Section title="SECURITY DIRECTIVES" buttons={
            <Button icon="plus" onClick={() => setActiveTab('directives')}>New Directive</Button>
          }>
            <Box style={{ marginBottom: '8px', padding: '8px', background: '#111114', border: '1px solid #333' }}>
              <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#4488ff', marginBottom: '4px' }}>ISSUE NEW DIRECTIVE</Box>
              <Box style={{ display: 'flex', gap: '6px', marginBottom: '4px' }}>
                <Input placeholder="Directive type..." value={dirType} onInput={(_e, v: string) => setDirType(v)} style={{ width: '150px' }} />
                <Input placeholder="Target..." value={dirTarget} onInput={(_e, v: string) => setDirTarget(v)} style={{ width: '150px' }} />
                <Button selected={dirPriority === 0} onClick={() => setDirPriority(0)} style={{ fontFamily: 'monospace', fontSize: '10px' }}>STD</Button>
                <Button selected={dirPriority === 1} onClick={() => setDirPriority(1)} color={dirPriority === 1 ? 'bad' : undefined} style={{ fontFamily: 'monospace', fontSize: '10px' }}>HIGH</Button>
              </Box>
              <TextArea placeholder="Directive description..." value={dirDesc} onInput={(_e, v: string) => setDirDesc(v)} rows={3}
                style={{ fontFamily: 'monospace', fontSize: '12px', width: '100%', resize: 'vertical' }} />
              <Button style={{ marginTop: '4px', fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '4px 12px' }}
                onClick={() => { act('issue_directive', { directive_type: dirType, target: dirTarget, description: dirDesc, priority: dirPriority }); setDirType(''); setDirTarget(''); setDirDesc(''); }}>
                ISSUE DIRECTIVE
              </Button>
            </Box>
            {directives.length === 0 && <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>No directives issued.</Box>}
            {directives.map((d) => (
              <Box key={d.directive_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${d.status === 'active' ? (d.priority > 0 ? '#cc2222' : '#d4a017') : '#44ff44'}`, background: '#111114' }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Box>
                    <Box style={{ color: d.priority > 0 ? '#cc2222' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                      {d.directive_id} — {d.directive_type} {d.priority > 0 ? '[HIGH PRIORITY]' : ''}
                    </Box>
                    <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>Target: {d.target || 'General'} | Issued by: {d.issuer}</Box>
                    <Box style={{ fontSize: '11px', color: '#8a8a90' }}>{d.description}</Box>
                    <Box style={{ fontSize: '10px', color: '#6a6a70' }}>Responders: {d.responders?.length || 0}</Box>
                  </Box>
                  <Box style={{ display: 'flex', gap: '4px', alignItems: 'flex-start' }}>
                    {d.status === 'active' && (
                      <>
                        <Button icon="check" size="tiny" color="good" onClick={() => act('acknowledge_directive', { directive_id: d.directive_id })} tooltip="Acknowledge" />
                        <Button icon="check-double" size="tiny" onClick={() => act('complete_directive', { directive_id: d.directive_id })} tooltip="Complete" />
                      </>
                    )}
                    <Button icon="print" size="tiny" color="average" onClick={() => act('print_directive', { directive_id: d.directive_id })} tooltip="Print" />
                  </Box>
                </Box>
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'codes' && (
          <Section title="ALERT CODES">
            <Box style={{ marginBottom: '8px', padding: '8px', background: '#111114', border: '1px solid #333' }}>
              <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#cc2222', marginBottom: '4px' }}>ACTIVATE ALERT CODE</Box>
              <Box style={{ display: 'flex', gap: '4px', marginBottom: '4px' }}>
                {['lockdown', 'sweep', 'perimeter', 'stand_down'].map((ct) => (
                  <Button key={ct} selected={codeType === ct} onClick={() => setCodeType(ct)}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: codeType === ct ? `rgba(${ct === 'lockdown' ? '139,0,0' : ct === 'stand_down' ? '0,100,0' : '212,160,23'},0.3)` : 'transparent', border: `1px solid ${CODE_COLORS[ct]}`, color: CODE_COLORS[ct], padding: '4px 8px' }}>
                    {ct.replace('_', ' ').toUpperCase()}
                  </Button>
                ))}
              </Box>
              <Box style={{ display: 'flex', gap: '6px', marginBottom: '4px' }}>
                <Input placeholder="Scope (facility, lcz, hcz, ez)..." value={codeScope} onInput={(_e, v: string) => setCodeScope(v)} style={{ width: '200px' }} />
              </Box>
              <TextArea placeholder="Reason for code activation..." value={codeReason} onInput={(_e, v: string) => setCodeReason(v)} rows={2}
                style={{ fontFamily: 'monospace', fontSize: '12px', width: '100%', resize: 'vertical' }} />
              <Button style={{ marginTop: '4px', fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '4px 12px' }}
                onClick={() => { act('activate_code', { code_type: codeType, scope: codeScope, reason: codeReason }); setCodeReason(''); }}>
                ACTIVATE CODE
              </Button>
            </Box>
            {alert_codes.map((c) => (
              <Box key={c.code_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${CODE_COLORS[c.code_type] || '#6a6a70'}`, background: '#111114' }}>
                <Box style={{ color: CODE_COLORS[c.code_type], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {c.code_type.toUpperCase()} — {c.scope}
                </Box>
                <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>Reason: {c.reason} | By: {c.activated_by}</Box>
                <Box style={{ fontSize: '10px', color: c.status === 'active' ? '#cc2222' : '#44ff44' }}>{c.status.toUpperCase()}</Box>
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'response' && (
          <Section title="BREACH RESPONSE COORDINATION">
            <Box style={{ marginBottom: '8px', padding: '8px', background: '#111114', border: '1px solid #333' }}>
              <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#ff8800', marginBottom: '4px' }}>COORDINATE BREACH RESPONSE</Box>
              <Box style={{ display: 'flex', gap: '6px', marginBottom: '4px' }}>
                <Input placeholder="SCP designation (e.g. 173)..." value={respScp} onInput={(_e, v: string) => setRespScp(v)} style={{ width: '150px' }} />
                {['standard', 'evacuation', 'full_containment'].map((rt) => (
                  <Button key={rt} selected={respType === rt} onClick={() => setRespType(rt)}
                    style={{ fontFamily: 'monospace', fontSize: '10px', background: respType === rt ? `rgba(${rt === 'full_containment' ? '139,0,0' : rt === 'evacuation' ? '212,160,23' : '68,136,255'},0.3)` : 'transparent', border: `1px solid ${RESPONSE_COLORS[rt]}`, color: RESPONSE_COLORS[rt], padding: '4px 6px' }}>
                    {rt.replace('_', ' ').toUpperCase()}
                  </Button>
                ))}
              </Box>
              <Button style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(255,136,0,0.2)', border: '1px solid #ff8800', color: '#ff8800', padding: '4px 12px' }}
                onClick={() => { act('coordinate_response', { scp_id: respScp, response_type: respType }); setRespScp(''); }}>
                DEPLOY RESPONSE
              </Button>
            </Box>
            {response_plans.map((p) => (
              <Box key={p.plan_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${RESPONSE_COLORS[p.response_type] || '#6a6a70'}`, background: '#111114' }}>
                <Box style={{ color: RESPONSE_COLORS[p.response_type], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  SCP-{p.scp_id} — {p.response_type.replace('_', ' ').toUpperCase()}
                </Box>
                <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>Coordinator: {p.coordinator}</Box>
                <Box style={{ fontSize: '10px', color: p.status === 'active' ? '#d4a017' : '#44ff44' }}>{p.status.toUpperCase()}</Box>
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
