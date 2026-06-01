import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  details: VipDetail[];
  total_details: number;
  overdue_alerts: number;
};

type VipDetail = {
  detail_id: string;
  vip: string;
  vip_job: string;
  guard: string;
  status: string;
  checkins: number;
  last_checkin: number;
  overdue: BooleanLike;
  time: number;
};

export const ScpVipProtectionConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { details, total_details, overdue_alerts } = data;
  const [vipName, setVipName] = useState('');

  return (
    <NtosWindow width={600} height={500}>
      <NtosWindow.Content scrollable>
        <Section title="VIP PROTECTION — EZ SECURITY">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            TOTAL DETAILS: {total_details} | OVERDUE ALERTS: <Box as="span" style={{ color: overdue_alerts > 0 ? '#cc2222' : '#44ff44' }}>{overdue_alerts}</Box>
          </Box>
          <Box style={{ marginBottom: '8px' }}>
            <Input placeholder="VIP name to assign protection..." value={vipName} onInput={(_e, value: string) => setVipName(value)} style={{ width: '200px' }} />
            <Button
              onClick={() => {
                act('assign_detail', { vip: vipName });
                setVipName('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px', marginLeft: '6px' }}
            >
              ASSIGN PROTECTION
            </Button>
          </Box>
        </Section>

        <Section title="ACTIVE PROTECTION DETAILS">
          {details.map((d) => (
            <Box key={d.detail_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${d.overdue ? '#cc2222' : d.status === 'active' ? '#44ff44' : '#6a6a70'}`, background: '#111114' }}>
              <Box style={{ color: d.overdue ? '#cc2222' : '#44ff44', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {d.vip} ({d.vip_job}) {d.overdue ? '[OVERDUE CHECK-IN]' : ''}
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Assigned Guard: {d.guard} | Check-ins: {d.checkins} | Status: {d.status}
              </Box>
              {d.status === 'active' && (
                <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                  <Button
                    onClick={() => act('checkin', { detail_id: d.detail_id })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                  >
                    LOG CHECK-IN
                  </Button>
                  <Button
                    onClick={() => act('release_detail', { detail_id: d.detail_id })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '2px 8px' }}
                  >
                    RELEASE
                  </Button>
                </Box>
              )}
            </Box>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
