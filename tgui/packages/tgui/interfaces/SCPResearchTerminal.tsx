import { useBackend } from '../backend';
import { Window } from '../layouts';

type Experiment = {
  id: string;
  name: string;
  reward: number;
  risk: number;
  type: string;
};

type ResearchData = {
  experiments: Experiment[];
  experiments_completed: number;
  research_points: number;
  total_scps: number;
};

const C = {
  bg: '#0a0a0f',
  border: '#1a2a3a',
  text: '#00aaff',
  textDim: '#336688',
  warning: '#ffaa00',
  danger: '#ff3333',
  safe: '#00ff41',
  headerBg: '#0a1220',
};

const riskLabel = (risk: number) => {
  if (risk <= 1) return { text: 'LOW', color: C.safe };
  if (risk <= 2) return { text: 'MODERATE', color: C.warning };
  if (risk <= 3) return { text: 'HIGH', color: '#ff8800' };
  return { text: 'EXTREME', color: C.danger };
};

export const SCPResearchTerminal = (_props: unknown) => {
  const { act, data } = useBackend<ResearchData>();
  const {
    experiments = [],
    research_points = 0,
    experiments_completed = 0,
    total_scps = 0,
  } = data;

  return (
    <Window theme="scp_terminal" width={600} height={450}>
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
              style={{ fontSize: '16px', fontWeight: 'bold', color: C.text }}
            >
              SCP RESEARCH MANAGEMENT TERMINAL
            </div>
            <div style={{ fontSize: '11px', color: C.textDim }}>
              AUTHORIZED PERSONNEL ONLY
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
                minWidth: '120px',
                padding: '8px',
                border: `1px solid ${C.border}`,
                background: C.headerBg,
              }}
            >
              <div style={{ fontSize: '10px', color: C.textDim }}>
                RESEARCH POINTS
              </div>
              <div style={{ fontSize: '18px', color: C.text }}>
                {research_points}
              </div>
            </div>
            <div
              style={{
                flex: '1',
                minWidth: '120px',
                padding: '8px',
                border: `1px solid ${C.border}`,
                background: C.headerBg,
              }}
            >
              <div style={{ fontSize: '10px', color: C.textDim }}>
                EXPERIMENTS COMPLETED
              </div>
              <div style={{ fontSize: '18px', color: C.text }}>
                {experiments_completed}
              </div>
            </div>
            <div
              style={{
                flex: '1',
                minWidth: '120px',
                padding: '8px',
                border: `1px solid ${C.border}`,
                background: C.headerBg,
              }}
            >
              <div style={{ fontSize: '10px', color: C.textDim }}>
                REGISTERED SCPS
              </div>
              <div style={{ fontSize: '18px', color: C.text }}>
                {total_scps}
              </div>
            </div>
          </div>

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
            <div style={{ flex: '2' }}>EXPERIMENT</div>
            <div style={{ flex: '1' }}>TYPE</div>
            <div style={{ flex: '1' }}>RISK</div>
            <div style={{ flex: '1' }}>REWARD</div>
            <div style={{ flex: '1' }}>ACTION</div>
          </div>

          {experiments.map((exp) => {
            const risk = riskLabel(exp.risk);
            return (
              <div
                key={exp.id}
                style={{
                  display: 'flex',
                  padding: '6px 0',
                  borderBottom: `1px solid ${C.border}`,
                  fontSize: '12px',
                  alignItems: 'center',
                }}
              >
                <div style={{ flex: '2', color: C.text }}>{exp.name}</div>
                <div style={{ flex: '1', color: C.textDim }}>
                  {exp.type.toUpperCase()}
                </div>
                <div
                  style={{ flex: '1', color: risk.color, fontWeight: 'bold' }}
                >
                  {risk.text}
                </div>
                <div style={{ flex: '1', color: C.safe }}>+{exp.reward} XP</div>
                <div style={{ flex: '1' }}>
                  <button
                    type="button"
                    style={{
                      background: 'transparent',
                      border: `1px solid ${C.border}`,
                      color: C.text,
                      padding: '2px 8px',
                      cursor: 'pointer',
                      fontFamily: 'monospace',
                      fontSize: '10px',
                    }}
                    onClick={() =>
                      act('start_experiment', { experiment_id: exp.id })
                    }
                  >
                    START
                  </button>
                </div>
              </div>
            );
          })}

          {experiments.length === 0 && (
            <div
              style={{
                textAlign: 'center',
                color: C.textDim,
                padding: '20px',
              }}
            >
              NO EXPERIMENTS AVAILABLE
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};
