import { useBackend } from '../backend';
import { Window } from '../layouts';

type GhostActionsData = {
  can_reenter: boolean;
  chem_scan: boolean;
  data_huds_on: boolean;
  exorcised: boolean;
  following: string | null;
  gas_scan: boolean;
  ghost_orbit: string;
  has_body: boolean;
  health_scan: boolean;
  orbit_modes: { id: string; name: string }[];
};

const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  red: '#8b0000',
  darkRed: '#5c0000',
  amber: '#d4a017',
  green: '#0a6e0a',
  brightGreen: '#44ff44',
  text: '#c8c8c8',
  dim: '#6a6a70',
  highlight: '#e8e8e8',
};

const ActionButton = (props: {
  color?: string;
  disabled?: boolean;
  label: string;
  onClick: () => void;
}) => {
  const { label, color = C.amber, disabled = false, onClick } = props;
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      style={{
        background: disabled ? 'transparent' : `${color}22`,
        border: `1px solid ${disabled ? C.border : color}`,
        color: disabled ? C.dim : color,
        padding: '8px 12px',
        cursor: disabled ? 'not-allowed' : 'pointer',
        fontFamily: 'Consolas, monospace',
        fontSize: '11px',
        fontWeight: 'bold',
        letterSpacing: '0.05em',
        textTransform: 'uppercase',
        width: '100%',
        textAlign: 'left',
        opacity: disabled ? 0.4 : 1,
        transition: 'all 0.15s',
      }}
    >
      ▸ {label}
    </button>
  );
};

const ToggleButton = (props: {
  active: boolean;
  label: string;
  onClick: () => void;
}) => {
  const { label, active, onClick } = props;
  return (
    <button
      type="button"
      onClick={onClick}
      style={{
        background: active ? `${C.brightGreen}22` : 'transparent',
        border: `1px solid ${active ? C.brightGreen : C.border}`,
        color: active ? C.brightGreen : C.dim,
        padding: '6px 10px',
        cursor: 'pointer',
        fontFamily: 'Consolas, monospace',
        fontSize: '10px',
        letterSpacing: '0.05em',
        textTransform: 'uppercase',
        transition: 'all 0.15s',
      }}
    >
      {active ? '◉' : '○'} {label}
    </button>
  );
};

export const GhostActions = (_props: unknown) => {
  const { act, data } = useBackend<GhostActionsData>();
  const {
    can_reenter = false,
    has_body = false,
    data_huds_on = false,
    health_scan = false,
    chem_scan = false,
    gas_scan = false,
    exorcised = false,
    following = null,
    ghost_orbit = 'circle',
    orbit_modes = [],
  } = data;

  return (
    <Window theme="scp_terminal" width={340} height={520}>
      <Window.Content scrollable>
        <div
          style={{
            background: C.bg,
            padding: '12px',
            fontFamily: 'Consolas, monospace',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <div
            style={{
              borderBottom: `2px solid ${C.red}`,
              paddingBottom: '8px',
              marginBottom: '12px',
            }}
          >
            <div
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.red,
                letterSpacing: '0.1em',
              }}
            >
              SCiPNet GHOST INTERFACE
            </div>
            <div style={{ fontSize: '10px', color: C.dim, marginTop: '2px' }}>
              DECEASED PERSONNEL TERMINAL
            </div>
          </div>

          {following && (
            <div
              style={{
                padding: '6px 10px',
                border: `1px solid ${C.amber}`,
                background: `${C.amber}11`,
                marginBottom: '10px',
                fontSize: '10px',
                color: C.amber,
              }}
            >
              ORBITING: {following.toUpperCase()}
            </div>
          )}

          <div style={{ marginBottom: '12px' }}>
            <div
              style={{
                fontSize: '10px',
                color: C.dim,
                letterSpacing: '0.08em',
                marginBottom: '6px',
              }}
            >
              CORPOREAL ACTIONS
            </div>
            <div
              style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}
            >
              <ActionButton
                label="Re-Enter Corpse"
                color={C.brightGreen}
                disabled={!can_reenter}
                onClick={() => act('reenter_corpse')}
              />
              <ActionButton
                label="Do Not Resuscitate"
                color="#ff3333"
                disabled={!has_body || exorcised}
                onClick={() => act('stay_dead')}
              />
            </div>
          </div>

          <div style={{ marginBottom: '12px' }}>
            <div
              style={{
                fontSize: '10px',
                color: C.dim,
                letterSpacing: '0.08em',
                marginBottom: '6px',
              }}
            >
              NAVIGATION
            </div>
            <div
              style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}
            >
              <ActionButton
                label="Teleport to Area"
                onClick={() => act('teleport')}
              />
              <ActionButton label="Orbit Mob" onClick={() => act('follow')} />
            </div>
          </div>

          <div style={{ marginBottom: '12px' }}>
            <div
              style={{
                fontSize: '10px',
                color: C.dim,
                letterSpacing: '0.08em',
                marginBottom: '6px',
              }}
            >
              SCANNING SYSTEMS
            </div>
            <div
              style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: '4px',
              }}
            >
              <ToggleButton
                label="Data HUDs"
                active={data_huds_on}
                onClick={() => act('toggle_data_huds')}
              />
              <ToggleButton
                label="Health"
                active={health_scan}
                onClick={() => act('toggle_health_scan')}
              />
              <ToggleButton
                label="Chem"
                active={chem_scan}
                onClick={() => act('toggle_chem_scan')}
              />
              <ToggleButton
                label="Gas"
                active={gas_scan}
                onClick={() => act('toggle_gas_scan')}
              />
            </div>
          </div>

          <div style={{ marginBottom: '12px' }}>
            <div
              style={{
                fontSize: '10px',
                color: C.dim,
                letterSpacing: '0.08em',
                marginBottom: '6px',
              }}
            >
              ORBIT MODE
            </div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '3px' }}>
              {orbit_modes.map((mode) => (
                <button
                  type="button"
                  key={mode.id}
                  onClick={() => act('orbit_mode', { mode: mode.id })}
                  style={{
                    background:
                      ghost_orbit === mode.id ? `${C.amber}22` : 'transparent',
                    border: `1px solid ${ghost_orbit === mode.id ? C.amber : C.border}`,
                    color: ghost_orbit === mode.id ? C.amber : C.dim,
                    padding: '3px 8px',
                    cursor: 'pointer',
                    fontFamily: 'Consolas, monospace',
                    fontSize: '10px',
                    textTransform: 'uppercase',
                    transition: 'all 0.15s',
                  }}
                >
                  {mode.name}
                </button>
              ))}
            </div>
          </div>

          <div>
            <div
              style={{
                fontSize: '10px',
                color: C.dim,
                letterSpacing: '0.08em',
                marginBottom: '6px',
              }}
            >
              RE-ENTRY OPTIONS
            </div>
            <div
              style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}
            >
              <ActionButton
                label="Spawners Menu"
                onClick={() => act('spawners_menu')}
              />
              <ActionButton
                label="Minigames"
                onClick={() => act('minigames')}
              />
              <ActionButton label="pAI Candidate" onClick={() => act('pai')} />
            </div>
          </div>

          {exorcised && (
            <div
              style={{
                marginTop: '12px',
                padding: '8px',
                border: `1px solid #ff0000`,
                background: '#ff000011',
                color: '#ff3333',
                fontSize: '10px',
                textAlign: 'center',
                letterSpacing: '0.05em',
              }}
            >
              SOUL DEPARTED — NO RESURRECTION
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};
