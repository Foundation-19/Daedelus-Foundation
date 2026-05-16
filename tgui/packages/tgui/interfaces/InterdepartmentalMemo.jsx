import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input, Section, TextArea } from '../components';
import { Window } from '../layouts';

const C = {
  bg: '#0a0a0c', panel: '#111114', border: '#2a2a30', borderRed: '#6b0000',
  red: '#8b0000', redBright: '#cc2222', green: '#0a6e0a', greenBright: '#44ff44',
  amber: '#d4a017', text: '#c8c8c8', textBright: '#e8e8e8', textDim: '#6a6a70',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const PRIORITIES = ['Low', 'Standard', 'Urgent', 'Emergency'];

const getPriorityColor = (p) => {
  switch (p) { case 'Low': return C.textDim; case 'Standard': return C.text; case 'Urgent': return C.amber; case 'Emergency': return C.redBright; default: return C.textDim; }
};

export const InterdepartmentalMemo = (props) => {
  const { act, data } = useBackend();
  const { memos = [], my_department = '', departments = [] } = data;
  const [activeTab, setActiveTab] = useLocalState('im_tab', 'relevant');
  const [memoDept, setMemoDept] = useLocalState('im_dept', '');
  const [memoSubject, setMemoSubject] = useLocalState('im_subject', '');
  const [memoBody, setMemoBody] = useLocalState('im_body', '');
  const [memoPriority, setMemoPriority] = useLocalState('im_priority', 'Standard');

  const relevantMemos = memos.filter((m) => m.is_relevant);
  const displayMemos = activeTab === 'relevant' ? relevantMemos : memos;

  return (
    <Window theme="scp_terminal" width={600} height={650}>
      <Window.Content scrollable>
        <Box style={{ background: C.bg, border: `1px solid ${C.borderRed}`, fontFamily: C.mono, fontSize: '12px', color: C.text, minHeight: '100%' }}>
          <Box style={{ borderBottom: `2px solid ${C.borderRed}`, padding: '10px 14px 8px', background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)' }}>
            <Box style={{ fontSize: '14px', fontWeight: 'bold', color: C.amber, letterSpacing: '0.18em' }}>INTERDEPARTMENTAL MEMO SYSTEM</Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>SCP FOUNDATION | COMMUNICATIONS DIVISION | DEPT: {my_department?.toUpperCase() || 'UNKNOWN'}</Box>
          </Box>

          <Box style={{ padding: '14px' }}>
            <Box style={{ fontSize: '10px', color: C.textDim, letterSpacing: '0.18em', textTransform: 'uppercase', borderBottom: `1px solid ${C.border}`, paddingBottom: '4px', marginBottom: '10px' }}>SEND MEMO</Box>

            <Box style={{ marginBottom: '12px', padding: '8px', borderLeft: `2px solid ${C.amber}`, background: C.panel }}>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>RECIPIENT DEPARTMENT</Box>
                <Dropdown selected={memoDept} options={departments} onSelected={(v) => setMemoDept(v)} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>SUBJECT</Box>
                <Input value={memoSubject} onChange={(e, v) => setMemoSubject(v)} placeholder="Enter subject..." fluid style={{ fontFamily: C.mono, fontSize: '12px' }} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>PRIORITY</Box>
                <Dropdown selected={memoPriority} options={PRIORITIES} onSelected={(v) => setMemoPriority(v)} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>BODY</Box>
                <TextArea value={memoBody} onChange={(e, v) => setMemoBody(v)} placeholder="Enter memo content..." style={{ fontFamily: C.mono, fontSize: '11px', width: '100%', minHeight: '80px', background: C.bg, border: `1px solid ${C.border}`, color: C.text, borderRadius: 0 }} />
              </Box>
              <Button
                onClick={() => { act('send_memo', { recipient_dept: memoDept, subject: memoSubject, body: memoBody, priority: memoPriority }); setMemoDept(''); setMemoSubject(''); setMemoBody(''); setMemoPriority('Standard'); }}
                disabled={!memoDept || !memoSubject || !memoBody}
                style={{ fontFamily: C.mono, fontSize: '10px', letterSpacing: '0.1em', textTransform: 'uppercase', background: 'rgba(139,0,0,0.35)', border: `1px solid ${C.borderRed}`, borderRadius: 0, color: C.textBright, padding: '3px 8px' }}
              >SEND MEMO</Button>
            </Box>

            <Box style={{ color: C.borderRed, fontSize: '10px', letterSpacing: '0.3em', margin: '10px 0', userSelect: 'none', overflow: 'hidden', whiteSpace: 'nowrap' }}>{'─'.repeat(60)}</Box>

            <Box style={{ display: 'flex', borderBottom: `1px solid ${C.borderRed}`, marginBottom: '10px', background: C.panel }}>
              {[
                { key: 'relevant', label: 'RELEVANT' },
                { key: 'all', label: 'ALL MEMOS' },
              ].map((t) => {
                const isActive = activeTab === t.key;
                return (
                  <Box key={t.key} style={{ padding: '6px 12px', cursor: 'pointer', background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent', borderBottom: isActive ? `2px solid ${C.amber}` : '2px solid transparent', color: isActive ? C.textBright : C.textDim, fontSize: '10px', letterSpacing: '0.12em', textTransform: 'uppercase', fontFamily: C.mono }} onClick={() => setActiveTab(t.key)}>
                    {isActive && '▸ '}{t.label}
                  </Box>
                );
              })}
            </Box>

            {displayMemos.length > 0 ? displayMemos.map((memo, idx) => (
              <Box key={`${memo.id || idx}`} style={{ marginBottom: '6px', padding: '8px', borderLeft: `2px solid ${getPriorityColor(memo.priority)}`, background: C.panel }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                  <Box>
                    <Box style={{ color: C.textBright, fontWeight: 'bold', fontSize: '11px' }}>{memo.subject}</Box>
                    <Box style={{ display: 'flex', gap: '8px', marginTop: '2px' }}>
                      <Box as="span" style={{ color: C.amber, fontSize: '10px', letterSpacing: '0.1em' }}>FROM: {memo.sender_dept?.toUpperCase()}</Box>
                      <Box as="span" style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.1em' }}>TO: {memo.recipient_dept?.toUpperCase()}</Box>
                      <Box as="span" style={{ color: getPriorityColor(memo.priority), fontSize: '10px', letterSpacing: '0.1em', fontWeight: 'bold' }}>{memo.priority?.toUpperCase()}</Box>
                    </Box>
                  </Box>
                  <Box style={{ color: C.textDim, fontSize: '10px' }}>{memo.timestamp || ''}</Box>
                </Box>
                <Box style={{ color: C.text, fontSize: '11px', marginTop: '4px' }}>{memo.body}</Box>
              </Box>
            )) : (
              <Box style={{ color: C.textDim, fontStyle: 'italic', fontSize: '11px' }}>NO MEMOS</Box>
            )}
          </Box>

          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={{ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' }}>SCP FOUNDATION | INTERDEPARTMENTAL MEMO | ALL COMMUNICATIONS LOGGED | UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION</Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
