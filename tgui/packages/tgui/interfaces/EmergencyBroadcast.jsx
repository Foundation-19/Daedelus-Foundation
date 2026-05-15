import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, TextArea } from '../components';
import { Window } from '../layouts';

const C = {
  bg: '#0a0a0c', panel: '#111114', border: '#2a2a30', borderRed: '#6b0000',
  red: '#8b0000', redBright: '#cc2222', green: '#0a6e0a', greenBright: '#44ff44',
  amber: '#d4a017', text: '#c8c8c8', textBright: '#e8e8e8', textDim: '#6a6a70',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const EMERGENCY_CODES = [
  { id: 'code_black', label: 'CODE BLACK', desc: 'Total Containment Failure', color: C.redBright, act: 'broadcast_code_black' },
  { id: 'biohazard', label: 'BIOHAZARD', desc: 'Biological Contamination Event', color: '#44cc44', act: 'broadcast_biohazard' },
  { id: 'ci_incursion', label: 'CI INCURSION', desc: 'Chaos Insurgency Hostile Activity', color: '#ff8844', act: 'broadcast_ci_incursion' },
  { id: 'evacuation', label: 'EVACUATION', desc: 'Facility Evacuation Order', color: '#4488ff', act: 'broadcast_evacuation' },
  { id: 'medical', label: 'MEDICAL EMERGENCY', desc: 'Mass Casualty / Epidemic Event', color: C.amber, act: 'broadcast_medical_emergency' },
  { id: 'power', label: 'POWER FAILURE', desc: 'Critical Power Grid Failure', color: '#aa88ff', act: 'broadcast_power_failure' },
];

export const EmergencyBroadcast = (props) => {
  const { act, data } = useBackend();
  const { can_broadcast, cooldown_remaining } = data;
  const [customCode, setCustomCode] = useLocalState('eb_code', '');
  const [customMessage, setCustomMessage] = useLocalState('eb_message', '');

  const isCoolingDown = cooldown_remaining > 0;

  return (
    <Window theme="scp_terminal" width={550} height={600}>
      <Window.Content scrollable>
        <Box style={{ background: C.bg, border: `1px solid ${C.borderRed}`, fontFamily: C.mono, fontSize: '12px', color: C.text, minHeight: '100%' }}>
          <Box style={{ borderBottom: `2px solid ${C.borderRed}`, padding: '10px 14px 8px', background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)' }}>
            <Box style={{ fontSize: '14px', fontWeight: 'bold', color: C.redBright, letterSpacing: '0.18em' }}>EMERGENCY BROADCAST SYSTEM</Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>SCP FOUNDATION | CRITICAL ALERTS | USE WITH EXTREME CAUTION</Box>
          </Box>

          <Box style={{ padding: '14px' }}>
            {isCoolingDown && (
              <Box style={{ marginBottom: '12px', padding: '8px', borderLeft: `2px solid ${C.amber}`, background: C.panel }}>
                <Box style={{ color: C.amber, fontSize: '10px', letterSpacing: '0.12em' }}>BROADCAST COOLDOWN ACTIVE</Box>
                <Box style={{ color: C.textBright, fontSize: '14px', fontWeight: 'bold', marginTop: '4px' }}>{Math.ceil(cooldown_remaining / 10)}s</Box>
              </Box>
            )}

            {!can_broadcast && !isCoolingDown && (
              <Box style={{ marginBottom: '12px', padding: '8px', borderLeft: `2px solid ${C.red}`, background: C.panel }}>
                <Box style={{ color: C.redBright, fontSize: '10px', letterSpacing: '0.12em' }}>INSUFFICIENT CLEARANCE TO BROADCAST</Box>
              </Box>
            )}

            <Box style={{ fontSize: '10px', color: C.textDim, letterSpacing: '0.18em', textTransform: 'uppercase', borderBottom: `1px solid ${C.border}`, paddingBottom: '4px', marginBottom: '10px' }}>EMERGENCY CODES</Box>

            <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px', marginBottom: '14px' }}>
              {EMERGENCY_CODES.map((code) => (
                <Button
                  key={code.id}
                  onClick={() => act(code.act)}
                  disabled={!can_broadcast || isCoolingDown}
                  style={{
                    fontFamily: C.mono,
                    fontSize: '13px',
                    fontWeight: 'bold',
                    letterSpacing: '0.15em',
                    textTransform: 'uppercase',
                    background: can_broadcast && !isCoolingDown ? `rgba(${code.color === C.redBright ? '139,0,0' : '20,20,24'},0.6)` : C.panel,
                    border: `2px solid ${can_broadcast && !isCoolingDown ? code.color : C.border}`,
                    borderRadius: 0,
                    color: can_broadcast && !isCoolingDown ? code.color : C.textDim,
                    padding: '10px 14px',
                    textAlign: 'left',
                    width: '100%',
                  }}
                >
                  <Box style={{ fontSize: '13px', fontWeight: 'bold' }}>{code.label}</Box>
                  <Box style={{ fontSize: '9px', color: can_broadcast && !isCoolingDown ? C.textDim : C.border, fontWeight: 'normal', letterSpacing: '0.1em', marginTop: '2px' }}>{code.desc}</Box>
                </Button>
              ))}
            </Box>

            <Box style={{ color: C.borderRed, fontSize: '10px', letterSpacing: '0.3em', margin: '10px 0', userSelect: 'none', overflow: 'hidden', whiteSpace: 'nowrap' }}>{'─'.repeat(60)}</Box>

            <Box style={{ fontSize: '10px', color: C.textDim, letterSpacing: '0.18em', textTransform: 'uppercase', borderBottom: `1px solid ${C.border}`, paddingBottom: '4px', marginBottom: '10px' }}>CUSTOM BROADCAST</Box>

            <Box style={{ marginBottom: '12px', padding: '8px', borderLeft: `2px solid ${C.amber}`, background: C.panel }}>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>CODE NAME</Box>
                <Input value={customCode} onChange={(e, v) => setCustomCode(v)} placeholder="Enter code name..." fluid style={{ fontFamily: C.mono, fontSize: '12px' }} />
              </Box>
              <Box style={{ marginBottom: '8px' }}>
                <Box style={{ color: C.textDim, fontSize: '10px', letterSpacing: '0.12em', marginBottom: '4px' }}>MESSAGE</Box>
                <TextArea value={customMessage} onChange={(e, v) => setCustomMessage(v)} placeholder="Enter broadcast message..." style={{ fontFamily: C.mono, fontSize: '11px', width: '100%', minHeight: '60px', background: C.bg, border: `1px solid ${C.border}`, color: C.text, borderRadius: 0 }} />
              </Box>
              <Button
                onClick={() => { act('broadcast_custom', { code: customCode, message: customMessage }); setCustomCode(''); setCustomMessage(''); }}
                disabled={!can_broadcast || isCoolingDown || !customCode || !customMessage}
                style={{ fontFamily: C.mono, fontSize: '10px', letterSpacing: '0.1em', textTransform: 'uppercase', background: 'rgba(139,0,0,0.35)', border: `1px solid ${C.redBright}`, borderRadius: 0, color: C.redBright, padding: '6px 14px' }}
              >BROADCAST CUSTOM CODE</Button>
            </Box>
          </Box>

          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={{ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' }}>SCP FOUNDATION | EMERGENCY BROADCAST | ALL ALERTS LOGGED | MISUSE IS A CLASS-A INFRACTION</Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
