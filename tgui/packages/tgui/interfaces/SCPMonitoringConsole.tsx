import { useBackend } from '../backend';
import { Window } from '../layouts';

type SCPData = {
  breach_count: number;
  health: number;
  id: string;
  interaction_count: number;
  last_breach: number;
  status: string;
};

type MonitoringData = {
  active_breaches: number;
  alert_level: number;
  global_stability: number;
  scps: SCPData[];
  time: number;
};

const C = {
  bg: '#0a0a0f',
  bgDark: '#050508',
  border: '#1a3a2a',
  text: '#00ff41',
  textDim: '#338855',
  warning: '#ffaa00',
  danger: '#ff3333',
  safe: '#00ff41',
  headerBg: '#0d1a12',
};

const statusColor = (status: string) => {
  switch (status) {
    case 'contained':
      return C.safe;
    case 'breached':
      return C.danger;
    case 'monitoring':
      return C.warning;
    default:
      return C.textDim;
  }
};

export const SCPMonitoringConsole = (_props: unknown) => {
  const { act, data } = useBackend<MonitoringData>();
  const { scps = [], global_stability, active_breaches, alert_level } = data;

  return (
    <Window theme="scp_terminal" width={700} height={500}>
      <Window.Content scrollable>
        <div
          style={{
            background: C.bg,
            padding: '12px',
            fontFamily: 'monospace',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <div
            style={{
              borderBottom: `1px solid ${C.border}`,
              paddingBottom: '8px',
              marginBottom: '12px',
            }}
          >
            <div
              style={{
                fontSize: '16px',
                fontWeight: 'bold',
                color: C.text,
              }}
            >
              SCP CONTAINMENT MONITORING SYSTEM
            </div>
            <div style={{ fontSize: '11px', color: C.textDim }}>
              SITE-53 FACILITY MANAGEMENT INTERFACE
            </div>
          </div>

          <div
            style={{
              display: 'flex',
              gap: '16px',
              marginBottom: '12px',
              flexWrap: 'wrap',
            }}
          >
            <div
              style={{
                flex: '1',
                minWidth: '150px',
                padding: '8px',
                border: `1px solid ${C.border}`,
                background: C.headerBg,
              }}
            >
              <div style={{ fontSize: '10px', color: C.textDim }}>
                GLOBAL STABILITY
              </div>
              <div
                style={{
                  fontSize: '20px',
                  color:
                    global_stability > 75
                      ? C.safe
                      : global_stability > 50
                        ? C.warning
                        : C.danger,
                }}
              >
                {global_stability}%
              </div>
            </div>
            <div
              style={{
                flex: '1',
                minWidth: '150px',
                padding: '8px',
                border: `1px solid ${C.border}`,
                background: C.headerBg,
              }}
            >
              <div style={{ fontSize: '10px', color: C.textDim }}>
                ACTIVE BREACHES
              </div>
              <div
                style={{
                  fontSize: '20px',
                  color: active_breaches > 0 ? C.danger : C.safe,
                }}
              >
                {active_breaches}
              </div>
            </div>
            <div
              style={{
                flex: '1',
                minWidth: '150px',
                padding: '8px',
                border: `1px solid ${C.border}`,
                background: C.headerBg,
              }}
            >
              <div style={{ fontSize: '10px', color: C.textDim }}>
                ALERT LEVEL
              </div>
              <div
                style={{
                  fontSize: '20px',
                  color:
                    alert_level >= 4
                      ? C.danger
                      : alert_level >= 2
                        ? C.warning
                        : C.safe,
                }}
              >
                {alert_level}
              </div>
            </div>
          </div>

          {active_breaches > 0 && (
            <div
              style={{
                padding: '8px',
                border: `1px solid ${C.danger}`,
                background: 'rgba(255,0,0,0.1)',
                marginBottom: '12px',
              }}
            >
              <button
                type="button"
                style={{
                  background: 'transparent',
                  border: `1px solid ${C.danger}`,
                  color: C.danger,
                  padding: '4px 12px',
                  cursor: 'pointer',
                  fontFamily: 'monospace',
                }}
                onClick={() => act('acknowledge_breach')}
              >
                ACKNOWLEDGE BREACH
              </button>
            </div>
          )}

          <div
            style={{
              borderBottom: `1px solid ${C.border}`,
              paddingBottom: '4px',
              marginBottom: '8px',
              display: 'flex',
              fontWeight: 'bold',
              fontSize: '11px',
              color: C.textDim,
            }}
          >
            <div style={{ flex: '2' }}>SCP DESIGNATION</div>
            <div style={{ flex: '1' }}>STATUS</div>
            <div style={{ flex: '1' }}>HEALTH</div>
            <div style={{ flex: '1' }}>BREACHES</div>
            <div style={{ flex: '1' }}>ACTIONS</div>
          </div>

          {scps.map((scp) => (
            <div
              key={scp.id}
              style={{
                display: 'flex',
                padding: '6px 0',
                borderBottom: `1px solid ${C.border}`,
                fontSize: '12px',
                alignItems: 'center',
              }}
            >
              <div style={{ flex: '2', color: C.text }}>{scp.id}</div>
              <div
                style={{
                  flex: '1',
                  color: statusColor(scp.status),
                  fontWeight: 'bold',
                }}
              >
                {scp.status.toUpperCase()}
              </div>
              <div
                style={{
                  flex: '1',
                  color:
                    scp.health > 75
                      ? C.safe
                      : scp.health > 50
                        ? C.warning
                        : C.danger,
                }}
              >
                {scp.health}%
              </div>
              <div style={{ flex: '1', color: C.textDim }}>
                {scp.breach_count}
              </div>
              <div style={{ flex: '1' }}>
                <button
                  type="button"
                  style={{
                    background: 'transparent',
                    border: `1px solid ${C.border}`,
                    color: C.textDim,
                    padding: '2px 8px',
                    cursor: 'pointer',
                    fontFamily: 'monospace',
                    fontSize: '10px',
                  }}
                  onClick={() => act('view_scp', { scp_id: scp.id })}
                >
                  VIEW
                </button>
              </div>
            </div>
          ))}

          {scps.length === 0 && (
            <div
              style={{
                textAlign: 'center',
                color: C.textDim,
                padding: '20px',
              }}
            >
              NO SCP DATA AVAILABLE
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};
