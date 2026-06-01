import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  dispatches: Dispatch[];
  threats: Threat[];
  facility_threat_level: number;
  active_dispatches: number;
  resolved_dispatches: number;
  total_announcements: number;
};

type Dispatch = {
  dispatch_id: string;
  type: string;
  caller: string;
  location: string;
  message: string;
  priority: number;
  responded: BooleanLike;
  responder_count: number;
  time: number;
};

type Threat = {
  threat_id: string;
  name: string;
  type: string;
  level: string;
  level_num: number;
  location: string;
  description: string;
  resolved: BooleanLike;
  resolved_by: string;
  time: number;
};

const THREAT_COLORS: Record<number, string> = {
  0: '#44ff44',
  1: '#d4a017',
  2: '#ff8800',
  3: '#cc2222',
};

const DISPATCH_TYPES = [
  { type: 1, label: 'SECURITY', color: '#cc2222' },
  { type: 2, label: 'MEDICAL', color: '#4488ff' },
  { type: 3, label: 'ENGINEERING', color: '#d4a017' },
  { type: 4, label: 'MTF', color: '#cc2222' },
];

export const ScpCommunicationsConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { dispatches, threats, facility_threat_level, active_dispatches, resolved_dispatches, total_announcements } = data;

  const [dispatchType, setDispatchType] = useState(1);
  const [dispatchMessage, setDispatchMessage] = useState('');
  const [announcementText, setAnnouncementText] = useState('');
  const [activeTab, setActiveTab] = useState<'dispatch' | 'announce' | 'dispatches' | 'threats'>('dispatch');

  const sendDispatch = () => {
    if (!dispatchMessage.trim()) return;
    act('dispatch', { dispatch_type: dispatchType, message: dispatchMessage, priority: 0 });
    setDispatchMessage('');
  };

  const sendAnnouncement = (priority: string) => {
    if (!announcementText.trim()) return;
    act('make_announcement', { message: announcementText, priority: priority });
    setAnnouncementText('');
  };

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="COMMUNICATIONS CENTER">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            FACILITY THREAT LEVEL:
            <Box as="span" style={{ color: THREAT_COLORS[facility_threat_level] || '#c8c8c8', fontWeight: 'bold', marginLeft: '8px' }}>
              {['GREEN', 'YELLOW', 'ORANGE', 'RED'][facility_threat_level] || 'UNKNOWN'}
            </Box>
          </Box>
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', marginBottom: '8px' }}>
            ACTIVE DISPATCHES: {active_dispatches} | RESOLVED: {resolved_dispatches} | ANNOUNCEMENTS: {total_announcements}
          </Box>
          <Box style={{ display: 'flex', gap: '2px' }}>
            {(['dispatch', 'announce', 'dispatches', 'threats'] as const).map((tab) => (
              <Button
                key={tab}
                selected={activeTab === tab}
                onClick={() => setActiveTab(tab)}
                style={{ fontFamily: 'monospace', fontSize: '11px', padding: '4px 10px', textTransform: 'uppercase' }}
              >
                {tab === 'dispatch' ? 'DISPATCH' : tab === 'announce' ? 'ANNOUNCE' : tab === 'dispatches' ? 'LOG' : 'THREATS'}
              </Button>
            ))}
          </Box>
        </Section>

        {activeTab === 'dispatch' && (
          <Section title="CREATE DISPATCH">
            <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <Box style={{ display: 'flex', gap: '2px' }}>
                {DISPATCH_TYPES.map((d) => (
                  <Button
                    key={d.type}
                    selected={dispatchType === d.type}
                    onClick={() => setDispatchType(d.type)}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: dispatchType === d.type ? `rgba(${d.color === '#4488ff' ? '68,136,255' : d.color === '#d4a017' ? '212,160,23' : '139,0,0'},0.2)` : 'transparent', border: `1px solid ${d.color}`, color: d.color, padding: '4px 10px' }}
                  >
                    {d.label}
                  </Button>
                ))}
              </Box>
              <TextArea
                placeholder="Dispatch message..."
                value={dispatchMessage}
                onInput={(_e, value: string) => setDispatchMessage(value)}
                rows={6}
                style={{ fontFamily: 'monospace', fontSize: '12px', lineHeight: '1.5', minHeight: '120px', resize: 'vertical', width: '100%' }}
              />
              <Button
                onClick={sendDispatch}
                style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '6px 12px', alignSelf: 'flex-start' }}
              >
                SEND DISPATCH
              </Button>
            </Box>
          </Section>
        )}

        {activeTab === 'announce' && (
          <Section title="MAKE ANNOUNCEMENT">
            <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <TextArea
                placeholder="Announcement text..."
                value={announcementText}
                onInput={(_e, value: string) => setAnnouncementText(value)}
                rows={6}
                style={{ fontFamily: 'monospace', fontSize: '12px', lineHeight: '1.5', minHeight: '120px', resize: 'vertical', width: '100%' }}
              />
              <Box style={{ display: 'flex', gap: '6px' }}>
                <Button
                  onClick={() => sendAnnouncement('0')}
                  style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '6px 12px' }}
                >
                  STANDARD
                </Button>
                <Button
                  onClick={() => sendAnnouncement('1')}
                  style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '6px 12px' }}
                >
                  PRIORITY
                </Button>
              </Box>
            </Box>
          </Section>
        )}

        {activeTab === 'dispatches' && (
          <Section title="DISPATCH LOG">
            {dispatches.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No dispatches on record.
              </Box>
            )}
            {dispatches.map((d) => (
              <Box key={d.dispatch_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${d.responded ? '#44ff44' : '#d4a017'}`, background: '#111114' }}>
                <Box style={{ color: d.responded ? '#44ff44' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {d.dispatch_id} — {d.type} {d.priority > 0 ? '[HIGH PRIORITY]' : ''}
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8', lineHeight: '1.5' }}>
                  Caller: {d.caller} | Location: {d.location} | Responders: {d.responder_count}
                </Box>
                <Box style={{ fontSize: '11px', color: '#8a8a90', lineHeight: '1.5', paddingLeft: '12px', marginTop: '4px' }}>
                  {d.message}
                </Box>
                {!d.responded && (
                  <Button
                    onClick={() => act('respond_dispatch', { dispatch_id: d.dispatch_id })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px', marginTop: '6px' }}
                  >
                    RESPOND
                  </Button>
                )}
                {d.responded && (
                  <Box style={{ fontSize: '10px', color: '#44ff44', fontFamily: 'monospace', marginTop: '4px' }}>RESPONDED</Box>
                )}
              </Box>
            ))}
          </Section>
        )}

        {activeTab === 'threats' && (
          <Section title="FACILITY THREATS">
            {threats.length === 0 && (
              <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#666', textAlign: 'center', padding: '16px' }}>
                No active threats.
              </Box>
            )}
            {threats.map((t) => (
              <Box key={t.threat_id} style={{ padding: '10px', marginBottom: '6px', borderLeft: `2px solid ${THREAT_COLORS[t.level_num] || '#6a6a70'}`, background: '#111114' }}>
                <Box style={{ color: THREAT_COLORS[t.level_num], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {t.name} — {t.level}
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8', lineHeight: '1.5' }}>
                  Type: {t.type} | Location: {t.location}
                </Box>
                <Box style={{ fontSize: '11px', color: '#8a8a90', lineHeight: '1.5', paddingLeft: '12px', marginTop: '4px' }}>
                  {t.description}
                </Box>
                {!t.resolved && (
                  <Button
                    onClick={() => act('resolve_threat', { threat_id: t.threat_id })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px', marginTop: '6px' }}
                  >
                    RESOLVE
                  </Button>
                )}
                {t.resolved && (
                  <Box style={{ fontSize: '10px', color: '#44ff44', fontFamily: 'monospace', marginTop: '4px' }}>RESOLVED by {t.resolved_by}</Box>
                )}
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
