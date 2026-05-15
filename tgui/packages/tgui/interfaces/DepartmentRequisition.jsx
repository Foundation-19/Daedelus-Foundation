import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input, NumberInput, Section, TextArea } from '../components';
import { Window } from '../layouts';

const C = {
  bg: '#0a0a0c', panel: '#111114', border: '#2a2a30', borderRed: '#6b0000',
  red: '#8b0000', redBright: '#cc2222', green: '#0a6e0a', greenBright: '#44ff44',
  amber: '#d4a017', text: '#c8c8c8', textBright: '#e8e8e8', textDim: '#6a6a70',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const CATEGORIES = ['Equipment', 'Medical', 'Scientific', 'Security', 'Engineering', 'General'];
const PRIORITIES = ['Low', 'Standard', 'Urgent', 'Emergency'];

const getPriorityColor = (p) => {
  switch (p) { case 'Low': return C.textDim; case 'Standard': return C.text; case 'Urgent': return C.amber; case 'Emergency': return C.redBright; default: return C.textDim; }
};

const getStatusColor = (s) => {
  switch (s) { case 'pending': return C.amber; case 'approved': return C.greenBright; case 'denied': return C.redBright; case 'fulfilled': return '#4488ff'; default: return C.textDim; }
};

const TermBtn = (props) => (
  <Button
    {...props}
    style={{
      fontFamily: C.mono, fontSize: '10px', letterSpacing: '0.1em',
      textTransform: 'uppercase', borderRadius: 0, padding: '3px 8px',
      ...props.style,
    }}
  />
);

export const DepartmentRequisition = (props) => {
  const { act, data } = useBackend();
  const { orders = [], is_logistics } = data;
  const [reqItem, setReqItem] = useLocalState('dr_item', '');
  const [reqCategory, setReqCategory] = useLocalState('dr_category', '');
  const [reqQuantity, setReqQuantity] = useLocalState('dr_quantity', 1);
  const [reqJustification, setReqJustification] = useLocalState('dr_justification', '');
  const [reqPriority, setReqPriority] = useLocalState('dr_priority', 'Standard');
  const [reqCost, setReqCost] = useLocalState('dr_cost', 0);
  const [reviewId, setReviewId] = useLocalState('dr_review_id', null);
  const [reviewNotes, setReviewNotes] = useLocalState('dr_review_notes', '');

  return (
    <Window theme="scp_terminal" width={600} height={700}>
      <Window.Content scrollable>
        <Box style={{ background: C.bg, border: `1px solid ${C.borderRed}`, fontFamily: C.mono, fontSize: '12px', color: C.text, minHeight: '100%' }}>
          <Box style={{ borderBottom: `2px solid ${C.borderRed}`, padding: '10px 14px 8px', background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)' }}>
            <Box style={{ fontSize: '14px', fontWeight: 'bold', color: C.amber, letterSpacing: '0.18em' }}>DEPARTMENT REQUISITION TERMINAL</Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>SCP FOUNDATION | SUPPLY CHAIN MANAGEMENT | BUDGET OVERSIGHT ACTIVE</Box>
          </Box>

          <Box style={{ padding: '14px' }}>
            <Box style={{ fontSize: '10px', color: C.textDim, letterSpacing: '0.18em', textTransform: 'uppercase', borderBottom: `1px solid ${C.border}`, paddingBottom: '4px', marginBottom: '10px' }}>SUBMIT REQUISITION REQUEST</Box>

            <Box style={{ marginBottom: '12px', padding: '8px', borderLeft: `2px solid ${C.amber}`, background: C.panel }}>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>ITEM NAME</Box>
                <Input value={reqItem} onChange={(e, v) => setReqItem(v)} placeholder="Enter item name..." fluid style={{ fontFamily: C.mono, fontSize: '12px' }} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>CATEGORY</Box>
                <Dropdown selected={reqCategory} options={CATEGORIES} onSelected={(v) => setReqCategory(v)} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>QUANTITY</Box>
                <NumberInput value={reqQuantity} minValue={1} maxValue={999} step={1} onChange={(v) => setReqQuantity(v)} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>PRIORITY</Box>
                <Dropdown selected={reqPriority} options={PRIORITIES} onSelected={(v) => setReqPriority(v)} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>ESTIMATED COST</Box>
                <NumberInput value={reqCost} minValue={0} maxValue={99999} step={50} onChange={(v) => setReqCost(v)} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>JUSTIFICATION</Box>
                <TextArea value={reqJustification} onChange={(e, v) => setReqJustification(v)} placeholder="Enter justification..." style={{ fontFamily: C.mono, fontSize: '11px', width: '100%', minHeight: '50px', background: C.bg, border: `1px solid ${C.border}`, color: C.text, borderRadius: 0 }} />
              </Box>
              <TermBtn
                onClick={() => { act('submit_request', { item: reqItem, category: reqCategory, quantity: reqQuantity, justification: reqJustification, priority: reqPriority, cost: reqCost }); setReqItem(''); setReqCategory(''); setReqQuantity(1); setReqJustification(''); setReqPriority('Standard'); setReqCost(0); }}
                disabled={!reqItem || !reqCategory || !reqJustification}
                style={{ background: 'rgba(139,0,0,0.35)', border: `1px solid ${C.borderRed}`, color: C.textBright }}
              >SUBMIT REQUEST</TermBtn>
            </Box>

            <Box style={{ color: C.borderRed, fontSize: '10px', letterSpacing: '0.3em', margin: '10px 0', userSelect: 'none', overflow: 'hidden', whiteSpace: 'nowrap' }}>{'─'.repeat(60)}</Box>

            <Box style={{ fontSize: '10px', color: C.textDim, letterSpacing: '0.18em', textTransform: 'uppercase', borderBottom: `1px solid ${C.border}`, paddingBottom: '4px', marginBottom: '10px' }}>REQUISITION ORDERS — {orders.length} RECORD{orders.length !== 1 ? 'S' : ''}</Box>

            {orders.length > 0 ? orders.map((order) => (
              <Box key={order.id} style={{ marginBottom: '6px', padding: '8px', borderLeft: `2px solid ${getPriorityColor(order.priority)}`, background: C.panel }}>
                <Box style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                  <Box>
                    <Box style={{ color: C.textBright, fontWeight: 'bold', fontSize: '11px' }}>{order.item}</Box>
                    <Box style={{ display: 'flex', gap: '8px', marginTop: '2px', flexWrap: 'wrap' }}>
                      <Box as="span" style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.1em' }}>x{order.quantity}</Box>
                      <Box as="span" style={{ color: C.amber, fontSize: '10px', letterSpacing: '0.1em' }}>{order.category?.toUpperCase()}</Box>
                      <Box as="span" style={{ color: getPriorityColor(order.priority), fontSize: '10px', letterSpacing: '0.1em', fontWeight: 'bold' }}>{order.priority?.toUpperCase()}</Box>
                      <Box as="span" style={{ color: getStatusColor(order.status), fontSize: '10px', letterSpacing: '0.1em', fontWeight: 'bold' }}>{order.status?.toUpperCase()}</Box>
                    </Box>
                  </Box>
                  <Box style={{ color: C.textDim, fontSize: '10px' }}>COST: {order.cost}</Box>
                </Box>
                {order.justification && <Box style={{ color: C.textDim, fontSize: '11px', marginTop: '4px' }}>{order.justification}</Box>}
                {is_logistics && order.status === 'pending' && (
                  <Box style={{ marginTop: '6px' }}>
                    {reviewId === order.id ? (
                      <Box>
                        <TextArea value={reviewNotes} onChange={(e, v) => setReviewNotes(v)} placeholder="Review notes..." style={{ fontFamily: C.mono, fontSize: '11px', width: '100%', minHeight: '40px', background: C.bg, border: `1px solid ${C.border}`, color: C.text, borderRadius: 0 }} />
                        <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                          <TermBtn onClick={() => { act('approve_request', { id: order.id, notes: reviewNotes }); setReviewId(null); setReviewNotes(''); }} style={{ background: 'rgba(26,122,26,0.35)', border: `1px solid ${C.green}`, color: C.greenBright }}>APPROVE</TermBtn>
                          <TermBtn onClick={() => { act('deny_request', { id: order.id, notes: reviewNotes }); setReviewId(null); setReviewNotes(''); }} style={{ background: 'rgba(139,0,0,0.35)', border: `1px solid ${C.red}`, color: C.redBright }}>DENY</TermBtn>
                          <TermBtn onClick={() => { setReviewId(null); setReviewNotes(''); }} style={{ background: 'transparent', border: `1px solid ${C.border}`, color: C.textDim }}>CANCEL</TermBtn>
                        </Box>
                      </Box>
                    ) : (
                      <Box style={{ display: 'flex', gap: '4px' }}>
                        <TermBtn onClick={() => setReviewId(order.id)} style={{ background: 'rgba(212,160,23,0.2)', border: `1px solid ${C.amber}`, color: C.amber }}>REVIEW</TermBtn>
                      </Box>
                    )}
                  </Box>
                )}
                {is_logistics && order.status === 'approved' && (
                  <Box style={{ marginTop: '6px' }}>
                    <TermBtn onClick={() => act('fulfill_request', { id: order.id })} style={{ background: 'rgba(26,122,26,0.35)', border: `1px solid ${C.green}`, color: C.greenBright }}>FULFILL</TermBtn>
                  </Box>
                )}
              </Box>
            )) : (
              <Box style={{ color: C.textDim, fontStyle: 'italic', fontSize: '11px' }}>NO REQUISITION ORDERS</Box>
            )}
          </Box>

          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={{ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' }}>SCP FOUNDATION | DEPARTMENT REQUISITION | ALL ORDERS LOGGED | UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION</Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
