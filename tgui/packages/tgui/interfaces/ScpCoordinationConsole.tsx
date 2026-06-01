import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  tasks: Task[];
  memos: Memo[];
  total_tasks: number;
  completed_tasks: number;
};

type Task = {
  task_id: string;
  type: string;
  department: string;
  issuer: string;
  description: string;
  priority: number;
  status: string;
  assignee: string;
  notes: string;
  time: number;
};

type Memo = {
  from: string;
  to: string;
  subject: string;
  body: string;
  sender: string;
  time: number;
};

export const ScpCoordinationConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { tasks, memos, total_tasks, completed_tasks } = data;
  const [coordDept, setCoordDept] = useState('');
  const [coordType, setCoordType] = useState('');
  const [coordDesc, setCoordDesc] = useState('');
  const [memoFrom, setMemoFrom] = useState('');
  const [memoTo, setMemoTo] = useState('');
  const [memoSubject, setMemoSubject] = useState('');
  const [memoBody, setMemoBody] = useState('');

  return (
    <NtosWindow width={700} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="DEPARTMENT COORDINATION">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            TASKS: {total_tasks} | COMPLETED: {completed_tasks}
          </Box>
        </Section>

        <Section title="ISSUE COORDINATION TASK">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Input placeholder="Department (science/medical/engineering/security)..." value={coordDept} onInput={(_e, value: string) => setCoordDept(value)} style={{ width: '200px' }} />
              <Input placeholder="Task type (research/containment/maintenance)..." value={coordType} onInput={(_e, value: string) => setCoordType(value)} style={{ width: '200px' }} />
            </Box>
            <TextArea placeholder="Task description..." value={coordDesc} onInput={(_e, value: string) => setCoordDesc(value)} rows={2} />
            <Button
              onClick={() => {
                act('issue_task', { department: coordDept, task_type: coordType, description: coordDesc, priority: '0' });
                setCoordDept('');
                setCoordType('');
                setCoordDesc('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '4px 12px', alignSelf: 'flex-start' }}
            >
              ISSUE TASK
            </Button>
          </Box>
        </Section>

        <Section title="SEND INTERDEPARTMENTAL MEMO">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Input placeholder="From department..." value={memoFrom} onInput={(_e, value: string) => setMemoFrom(value)} style={{ width: '120px' }} />
              <Input placeholder="To department..." value={memoTo} onInput={(_e, value: string) => setMemoTo(value)} style={{ width: '120px' }} />
              <Input placeholder="Subject..." value={memoSubject} onInput={(_e, value: string) => setMemoSubject(value)} style={{ width: '200px' }} />
            </Box>
            <TextArea placeholder="Memo body..." value={memoBody} onInput={(_e, value: string) => setMemoBody(value)} rows={3} />
            <Button
              onClick={() => {
                act('send_memo', { from: memoFrom, to: memoTo, subject: memoSubject, body: memoBody });
                setMemoFrom('');
                setMemoTo('');
                setMemoSubject('');
                setMemoBody('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '4px 12px', alignSelf: 'flex-start' }}
            >
              SEND MEMO
            </Button>
          </Box>
        </Section>

        <Section title="TASKS">
          {tasks.map((t) => (
            <Box key={t.task_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${t.status === 'completed' ? '#44ff44' : t.status === 'assigned' ? '#4488ff' : '#d4a017'}`, background: '#111114' }}>
              <Box style={{ color: t.status === 'completed' ? '#44ff44' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {t.task_id} — {t.department}/{t.type}
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Issued by: {t.issuer} | Status: {t.status} | Assignee: {t.assignee || 'None'}
              </Box>
              <Box style={{ fontSize: '10px', color: '#8a8a90' }}>{t.description}</Box>
              {t.status === 'pending' && (
                <Button
                  onClick={() => act('assign_task', { task_id: t.task_id })}
                  style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '2px 8px', marginTop: '4px' }}
                >
                  ASSIGN TO SELF
                </Button>
              )}
              {t.status === 'assigned' && (
                <Button
                  onClick={() => act('complete_task', { task_id: t.task_id, notes: 'Completed' })}
                  style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px', marginTop: '4px' }}
                >
                  COMPLETE
                </Button>
              )}
            </Box>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
