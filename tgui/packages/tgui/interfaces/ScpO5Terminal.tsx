import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Section, TextArea, Input } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  directives: O5Directive[];
  audits: Audit[];
  total_directives: number;
  total_audits: number;
  total_overrides: number;
  facility_summary: FacilitySummary;
};

type O5Directive = {
  directive_id: string;
  issuer: string;
  directive_type: string;
  target: string;
  description: string;
  classification: string;
  status: string;
  time_issued: number;
  acknowledged_by: { name: string; job: string; time: number }[];
};

type Audit = {
  audit_id: string;
  initiated_by: string;
  audit_type: number;
  target_department: string;
  scope: string;
  description: string;
  status: string;
  time_initiated: number;
  findings: { finding_type: string; description: string; severity: number; time: number }[];
};

type FacilitySummary = {
  directives_active: number;
  directives_completed: number;
  directives_overdue: number;
  threat_level: number;
  active_dispatches: number;
  active_breaches: number;
  containment_stability: number;
  total_budget: number;
  total_spent: number;
  ethics_pending: number;
};

const AUDIT_TYPES = [
  { type: 1, label: 'PERSONNEL', color: '#4488ff' },
  { type: 2, label: 'CONTAINMENT', color: '#cc2222' },
  { type: 3, label: 'RESEARCH', color: '#d4a017' },
  { type: 4, label: 'BUDGET', color: '#44ff44' },
  { type: 5, label: 'ETHICS', color: '#ff8800' },
];

const CLASS_OPTIONS = ['CONFIDENTIAL', 'SECRET', 'TOP SECRET'];

export const ScpO5Terminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { directives, audits, total_directives, total_audits, total_overrides, facility_summary } = data;

  const [activeTab, setActiveTab] = useState<'overview' | 'directives' | 'audits' | 'override'>('overview');
  const [dirType, setDirType] = useState('');
  const [dirTarget, setDirTarget] = useState('');
  const [dirDesc, setDirDesc] = useState('');
  const [dirClass, setDirClass] = useState('CONFIDENTIAL');
  const [auditType, setAuditType] = useState(1);
  const [auditDept, setAuditDept] = useState('');
  const [auditScope, setAuditScope] = useState('full');
  const [auditDesc, setAuditDesc] = useState('');
  const [findingDesc, setFindingDesc] = useState('');
  const [findingType, setFindingType] = useState('');
  const [findingSeverity, setFindingSeverity] = useState(1);
  const [activeAuditId, setActiveAuditId] = useState<string | null>(null);
  const [overrideType, setOverrideType] = useState('security_level');
  const [overrideTarget, setOverrideTarget] = useState('');
  const [overrideReason, setOverrideReason] = useState('');

  const stability = facility_summary?.containment_stability || 100;
  const stabilityColor = stability >= 75 ? '#44ff44' : stability >= 50 ? '#d4a017' : '#cc2222';

  return (
    <NtosWindow width={750} height={700}>
      <NtosWindow.Content scrollable>
        <Section title="O5 COUNCIL TERMINAL">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#8b0000', letterSpacing: '0.2em', marginBottom: '8px' }}>
            CLASSIFIED — O5 EYES ONLY — CLEARANCE LEVEL 5 REQUIRED
          </Box>
          <Box style={{ display: 'flex', gap: '2px', marginBottom: '4px' }}>
            {(['overview', 'directives', 'audits', 'override'] as const).map((tab) => (
              <Button key={tab} selected={activeTab === tab} onClick={() => setActiveTab(tab)}
                style={{ fontFamily: 'monospace', fontSize: '11px', padding: '4px 10px', textTransform: 'uppercase' }}>
                {tab}
              </Button>
            ))}
          </Box>
        </Section>

        {activeTab === 'overview' && (
          <Section title="FACILITY OVERVIEW">
            <Box style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '8px', marginBottom: '8px' }}>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #8b0000' }}>
                <Box style={{ color: '#8b0000', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '10px' }}>DIRECTIVES</Box>
                <Box style={{ fontSize: '14px', fontFamily: 'monospace' }}>
                  <Box as="span" style={{ color: '#d4a017' }}>{facility_summary?.directives_active || 0}</Box> active
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #cc2222' }}>
                <Box style={{ color: '#cc2222', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '10px' }}>BREACHES</Box>
                <Box style={{ fontSize: '14px', fontFamily: 'monospace', color: (facility_summary?.active_breaches || 0) > 0 ? '#cc2222' : '#44ff44' }}>
                  {facility_summary?.active_breaches || 0}
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: `2px solid ${stabilityColor}` }}>
                <Box style={{ color: stabilityColor, fontWeight: 'bold', fontFamily: 'monospace', fontSize: '10px' }}>STABILITY</Box>
                <Box style={{ fontSize: '14px', fontFamily: 'monospace', color: stabilityColor }}>
                  {stability}%
                </Box>
              </Box>
            </Box>
            <Box style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '8px' }}>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #4488ff' }}>
                <Box style={{ color: '#4488ff', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '10px' }}>THREAT LEVEL</Box>
                <Box style={{ fontSize: '14px', fontFamily: 'monospace' }}>
                  {['GREEN', 'YELLOW', 'ORANGE', 'RED'][facility_summary?.threat_level || 0] || 'UNKNOWN'}
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #44ff44' }}>
                <Box style={{ color: '#44ff44', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '10px' }}>BUDGET</Box>
                <Box style={{ fontSize: '11px', fontFamily: 'monospace' }}>
                  {facility_summary?.total_spent || 0}/{facility_summary?.total_budget || 0}cr
                </Box>
              </Box>
              <Box style={{ padding: '8px', background: '#111114', borderLeft: '2px solid #ff8800' }}>
                <Box style={{ color: '#ff8800', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '10px' }}>ETHICS PENDING</Box>
                <Box style={{ fontSize: '14px', fontFamily: 'monospace', color: (facility_summary?.ethics_pending || 0) > 0 ? '#ff8800' : '#44ff44' }}>
                  {facility_summary?.ethics_pending || 0}
                </Box>
              </Box>
            </Box>
          </Section>
        )}

        {activeTab === 'directives' && (
          <Section title="O5 COUNCIL DIRECTIVES">
            <Box style={{ marginBottom: '8px', padding: '8px', background: '#111114', border: '1px solid #8b0000' }}>
              <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#8b0000', marginBottom: '4px' }}>ISSUE O5 DIRECTIVE</Box>
              <Box style={{ display: 'flex', gap: '6px', marginBottom: '4px' }}>
                <Input placeholder="Directive type..." value={dirType} onInput={(_e, v: string) => setDirType(v)} style={{ width: '150px' }} />
                <Input placeholder="Target department..." value={dirTarget} onInput={(_e, v: string) => setDirTarget(v)} style={{ width: '150px' }} />
              </Box>
              <Box style={{ display: 'flex', gap: '4px', marginBottom: '4px' }}>
                {CLASS_OPTIONS.map((c) => (
                  <Button key={c} selected={dirClass === c} onClick={() => setDirClass(c)}
                    style={{ fontFamily: 'monospace', fontSize: '10px', border: `1px solid ${c === 'TOP SECRET' ? '#8b0000' : c === 'SECRET' ? '#d4a017' : '#4488ff'}`, color: c === 'TOP SECRET' ? '#8b0000' : c === 'SECRET' ? '#d4a017' : '#4488ff', padding: '2px 8px' }}>
                    {c}
                  </Button>
                ))}
              </Box>
              <TextArea placeholder="Directive content..." value={dirDesc} onInput={(_e, v: string) => setDirDesc(v)} rows={4}
                style={{ fontFamily: 'monospace', fontSize: '12px', width: '100%', resize: 'vertical' }} />
              <Button style={{ marginTop: '4px', fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#8b0000', padding: '4px 12px' }}
                onClick={() => { act('issue_directive', { directive_type: dirType, target: dirTarget, description: dirDesc, classification: dirClass }); setDirType(''); setDirTarget(''); setDirDesc(''); }}>
                ISSUE DIRECTIVE
              </Button>
            </Box>
            {directives.map((d) => (
              <Box key={d.directive_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${d.status === 'active' ? '#8b0000' : '#44ff44'}`, background: '#111114' }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Box>
                    <Box style={{ color: '#8b0000', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                      {d.directive_id} — {d.directive_type}
                    </Box>
                    <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>Target: {d.target || 'All'} | Classification: {d.classification}</Box>
                    <Box style={{ fontSize: '11px', color: '#8a8a90' }}>{d.description}</Box>
                    <Box style={{ fontSize: '10px', color: '#6a6a70' }}>Acknowledged: {d.acknowledged_by?.length || 0} heads</Box>
                  </Box>
                  <Box style={{ display: 'flex', gap: '4px' }}>
                    {d.status === 'active' && (
                      <>
                        <Button icon="check" size="tiny" color="good" onClick={() => act('acknowledge_directive', { directive_id: d.directive_id })} tooltip="Acknowledge" />
                        <Button icon="times" size="tiny" color="bad" onClick={() => act('rescind_directive', { directive_id: d.directive_id })} tooltip="Rescind" />
                      </>
                    )}
                    <Button icon="print" size="tiny" color="average" onClick={() => act('print_directive', { directive_id: d.directive_id })} tooltip="Print" />
                  </Box>
                </Box>
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'audits' && (
          <Section title="O5 COUNCIL AUDITS">
            <Box style={{ marginBottom: '8px', padding: '8px', background: '#111114', border: '1px solid #d4a017' }}>
              <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#d4a017', marginBottom: '4px' }}>INITIATE AUDIT</Box>
              <Box style={{ display: 'flex', gap: '4px', marginBottom: '4px' }}>
                {AUDIT_TYPES.map((at) => (
                  <Button key={at.type} selected={auditType === at.type} onClick={() => setAuditType(at.type)}
                    style={{ fontFamily: 'monospace', fontSize: '10px', border: `1px solid ${at.color}`, color: at.color, padding: '2px 8px' }}>
                    {at.label}
                  </Button>
                ))}
              </Box>
              <Box style={{ display: 'flex', gap: '6px', marginBottom: '4px' }}>
                <Input placeholder="Department..." value={auditDept} onInput={(_e, v: string) => setAuditDept(v)} style={{ width: '150px' }} />
                <Input placeholder="Scope..." value={auditScope} onInput={(_e, v: string) => setAuditScope(v)} style={{ width: '100px' }} />
              </Box>
              <TextArea placeholder="Audit description..." value={auditDesc} onInput={(_e, v: string) => setAuditDesc(v)} rows={3}
                style={{ fontFamily: 'monospace', fontSize: '12px', width: '100%', resize: 'vertical' }} />
              <Button style={{ marginTop: '4px', fontFamily: 'monospace', fontSize: '11px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '4px 12px' }}
                onClick={() => { act('initiate_audit', { audit_type: auditType, target_department: auditDept, scope: auditScope, description: auditDesc }); setAuditDept(''); setAuditDesc(''); }}>
                INITIATE AUDIT
              </Button>
            </Box>
            {audits.map((a) => (
              <Box key={a.audit_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${a.status === 'active' ? '#d4a017' : '#44ff44'}`, background: '#111114' }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Box style={{ flex: 1 }}>
                    <Box style={{ color: '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                      {a.audit_id} — {AUDIT_TYPES.find((at) => at.type === a.audit_type)?.label || 'Unknown'} — {a.target_department}
                    </Box>
                    <Box style={{ fontSize: '11px', color: '#c8c8c8' }}>Scope: {a.scope} | By: {a.initiated_by}</Box>
                    <Box style={{ fontSize: '11px', color: '#8a8a90' }}>{a.description}</Box>
                    {a.findings?.length > 0 && (
                      <Box style={{ marginTop: '4px', borderTop: '1px solid #222', paddingTop: '4px' }}>
                        <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', marginBottom: '2px' }}>FINDINGS ({a.findings.length}):</Box>
                        {a.findings.map((f, i) => (
                          <Box key={i} style={{ fontSize: '11px', color: '#8a8a90', paddingLeft: '12px' }}>
                            [{f.finding_type}] {f.description} (Severity: {f.severity})
                          </Box>
                        ))}
                      </Box>
                    )}
                  </Box>
                  <Box style={{ display: 'flex', flexDirection: 'column', gap: '4px', marginLeft: '8px' }}>
                    {a.status === 'active' && (
                      <>
                        <Button size="tiny" onClick={() => setActiveAuditId(a.audit_id)} style={{ fontFamily: 'monospace', fontSize: '10px' }}>
                          + FINDING
                        </Button>
                        <Button size="tiny" color="good" onClick={() => act('complete_audit', { audit_id: a.audit_id })}>
                          COMPLETE
                        </Button>
                      </>
                    )}
                    <Box style={{ fontSize: '10px', color: a.status === 'active' ? '#d4a017' : '#44ff44' }}>{a.status.toUpperCase()}</Box>
                  </Box>
                </Box>
                {activeAuditId === a.audit_id && a.status === 'active' && (
                  <Box style={{ marginTop: '6px', padding: '6px', background: '#0a0a0c', border: '1px solid #333' }}>
                    <Input placeholder="Finding type..." value={findingType} onInput={(_e, v: string) => setFindingType(v)} style={{ width: '150px', marginBottom: '4px' }} />
                    <TextArea placeholder="Finding description..." value={findingDesc} onInput={(_e, v: string) => setFindingDesc(v)} rows={2}
                      style={{ fontFamily: 'monospace', fontSize: '12px', width: '100%', resize: 'vertical' }} />
                    <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                      {[1, 2, 3, 4, 5].map((s) => (
                        <Button key={s} selected={findingSeverity === s} onClick={() => setFindingSeverity(s)}
                          style={{ fontFamily: 'monospace', fontSize: '10px', padding: '2px 6px', color: s >= 4 ? '#cc2222' : s >= 3 ? '#ff8800' : s >= 2 ? '#d4a017' : '#44ff44' }}>
                          S{s}
                        </Button>
                      ))}
                      <Button onClick={() => { act('submit_finding', { audit_id: a.audit_id, finding_type: findingType, description: findingDesc, severity: findingSeverity }); setFindingDesc(''); setFindingType(''); setActiveAuditId(null); }}
                        style={{ fontFamily: 'monospace', fontSize: '10px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4017', padding: '2px 8px' }}>
                        SUBMIT
                      </Button>
                    </Box>
                  </Box>
                )}
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'override' && (
          <Section title="O5 COUNCIL OVERRIDES">
            <Box style={{ marginBottom: '8px', padding: '8px', background: '#111114', border: '1px solid #8b0000' }}>
              <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#8b0000', marginBottom: '4px' }}>EXERCISE O5 OVERRIDE AUTHORITY</Box>
              <Box style={{ display: 'flex', gap: '4px', marginBottom: '4px', flexWrap: 'wrap' }}>
                {[
                  { type: 'security_level', label: 'SECURITY LEVEL' },
                  { type: 'ethics_veto', label: 'ETHICS VETO' },
                  { type: 'budget_freeze', label: 'BUDGET FREEZE' },
                  { type: 'budget_unfreeze', label: 'BUDGET UNFREEZE' },
                  { type: 'testing_suspension', label: 'SUSPEND TESTING' },
                  { type: 'containment_review', label: 'CONTAINMENT REVIEW' },
                ].map((o) => (
                  <Button key={o.type} selected={overrideType === o.type} onClick={() => setOverrideType(o.type)}
                    style={{ fontFamily: 'monospace', fontSize: '10px', border: '1px solid #8b0000', color: '#8b0000', padding: '2px 8px' }}>
                    {o.label}
                  </Button>
                ))}
              </Box>
              <Box style={{ display: 'flex', gap: '6px', marginBottom: '4px' }}>
                <Input placeholder="Target (department/SCP/proposal ID)..." value={overrideTarget} onInput={(_e, v: string) => setOverrideTarget(v)} style={{ width: '200px' }} />
              </Box>
              <TextArea placeholder="Override justification (required)..." value={overrideReason} onInput={(_e, v: string) => setOverrideReason(v)} rows={3}
                style={{ fontFamily: 'monospace', fontSize: '12px', width: '100%', resize: 'vertical' }} />
              <Button style={{ marginTop: '4px', fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.4)', border: '1px solid #8b0000', color: '#8b0000', padding: '6px 16px' }}
                onClick={() => { act('issue_override', { override_type: overrideType, target: overrideTarget, reason: overrideReason }); setOverrideTarget(''); setOverrideReason(''); }}>
                EXECUTE OVERRIDE
              </Button>
            </Box>
            <Box style={{ fontFamily: 'monospace', fontSize: '11px', color: '#6a6a70' }}>
              Total overrides issued this shift: {total_overrides}
            </Box>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
