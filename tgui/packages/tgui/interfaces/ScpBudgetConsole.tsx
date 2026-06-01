import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  departments: Department[];
  requests: BudgetRequest[];
  total_budget: number;
  total_spent: number;
};

type Department = {
  department: string;
  allocated: number;
  spent: number;
  remaining: number;
  pending: number;
  approved: number;
  denied: number;
};

type BudgetRequest = {
  request_id: string;
  department: string;
  requester: string;
  amount: number;
  purpose: string;
  justification: string;
  status: string;
  reviewer: string;
  notes: string;
  time: number;
};

export const ScpBudgetConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { departments, requests, total_budget, total_spent } = data;
  const [reallocateFrom, setReallocateFrom] = useState('');
  const [reallocateTo, setReallocateTo] = useState('');
  const [reallocateAmount, setReallocateAmount] = useState('');

  return (
    <NtosWindow width={700} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="BUDGET MANAGEMENT — FOUNDATION OPERATIONS">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            TOTAL BUDGET: {total_budget} CR | SPENT: {total_spent} CR | REMAINING: {total_budget - total_spent} CR
          </Box>
          {departments.map((d) => (
            <Box key={d.department} style={{ padding: '8px', marginBottom: '4px', borderLeft: '2px solid #4488ff', background: '#111114' }}>
              <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Box>
                  <Box style={{ color: '#4488ff', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>{d.department}</Box>
                  <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                    Allocated: {d.allocated} CR | Spent: {d.spent} CR | Remaining: {d.remaining} CR
                  </Box>
                  <Box style={{ fontSize: '10px', color: '#6a6a70' }}>
                    Pending: {d.pending} | Approved: {d.approved} | Denied: {d.denied}
                  </Box>
                </Box>
                <Box style={{ width: '100px', height: '8px', background: '#2a2a30', marginTop: '6px' }}>
                  <Box style={{ width: `${d.allocated > 0 ? (d.spent / d.allocated) * 100 : 0}%`, height: '100%', background: d.remaining > 0 ? '#4488ff' : '#cc2222' }} />
                </Box>
              </Box>
            </Box>
          ))}
        </Section>

        <Section title="BUDGET REQUESTS">
          {requests.map((r) => (
            <Box key={r.request_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${r.status === 'pending' ? '#d4a017' : r.status === 'approved' ? '#44ff44' : '#cc2222'}`, background: '#111114' }}>
              <Box style={{ color: r.status === 'pending' ? '#d4a017' : r.status === 'approved' ? '#44ff44' : '#cc2222', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {r.request_id} — {r.department}
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Requester: {r.requester} | Amount: {r.amount} CR | Purpose: {r.purpose}
              </Box>
              {r.justification && <Box style={{ fontSize: '10px', color: '#8a8a90' }}>Justification: {r.justification}</Box>}
              {r.status === 'pending' && (
                <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                  <Button
                    onClick={() => act('approve_request', { request_id: r.request_id, notes: '' })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                  >
                    APPROVE
                  </Button>
                  <Button
                    onClick={() => act('deny_request', { request_id: r.request_id, notes: '' })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '2px 8px' }}
                  >
                    DENY
                  </Button>
                </Box>
              )}
            </Box>
          ))}
        </Section>

        <Section title="REALLOCATE FUNDS">
          <Box style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
            <Input placeholder="From dept..." value={reallocateFrom} onInput={(_e, value: string) => setReallocateFrom(value)} style={{ width: '120px' }} />
            <Input placeholder="To dept..." value={reallocateTo} onInput={(_e, value: string) => setReallocateTo(value)} style={{ width: '120px' }} />
            <Input placeholder="Amount..." value={reallocateAmount} onInput={(_e, value: string) => setReallocateAmount(value)} style={{ width: '80px' }} />
            <Button
              onClick={() => {
                act('reallocate', { from: reallocateFrom, to: reallocateTo, amount: reallocateAmount || '0' });
                setReallocateFrom('');
                setReallocateTo('');
                setReallocateAmount('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '2px 8px' }}
            >
              TRANSFER
            </Button>
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
