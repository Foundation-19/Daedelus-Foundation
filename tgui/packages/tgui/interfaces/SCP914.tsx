import { useBackend } from '../backend';
import { Window } from '../layouts';

type ItemData = {
  name: string;
  ref: string;
};

type SCP914Data = {
  active: boolean;
  has_input: boolean;
  has_output: boolean;
  input_items: ItemData[];
  max_progress: number;
  objects_destroyed: number;
  objects_enhanced: number;
  output_items: ItemData[];
  progress: number;
  refinements_performed: number;
  setting: string;
  settings: string[];
};

const C = {
  bg: '#0a0a0f',
  bgDark: '#050508',
  border: '#2a1a0a',
  text: '#ffaa00',
  textDim: '#886633',
  danger: '#ff3333',
  safe: '#00ff41',
  headerBg: '#1a0d05',
};

const settingColors: Record<string, string> = {
  ROUGH: '#ff3333',
  COARSE: '#ff8800',
  '1:1': '#ffaa00',
  FINE: '#00ff41',
  'VERY FINE': '#aa00ff',
};

export const SCP914 = (_props: unknown) => {
  const { act, data } = useBackend<SCP914Data>();
  const {
    setting = '1:1',
    settings = [],
    active = false,
    progress = 0,
    max_progress = 100,
    refinements_performed = 0,
    objects_destroyed = 0,
    objects_enhanced = 0,
    input_items = [],
    output_items = [],
  } = data;

  const progressPct =
    max_progress > 0 ? Math.round((progress / max_progress) * 100) : 0;

  return (
    <Window theme="scp_terminal" width={550} height={520}>
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
              SCP-914 REFINEMENT INTERFACE
            </div>
            <div style={{ fontSize: '11px', color: C.textDim }}>
              CLOCKWORK REFINE-O-MATIC &mdash; AUTHORIZED PERSONNEL ONLY
            </div>
          </div>

          <div
            style={{
              display: 'flex',
              gap: '12px',
              marginBottom: '12px',
              flexWrap: 'wrap',
            }}
          >
            <div
              style={{
                flex: '1',
                minWidth: '100px',
                padding: '8px',
                border: `1px solid ${C.border}`,
                background: C.headerBg,
              }}
            >
              <div style={{ fontSize: '10px', color: C.textDim }}>
                REFINEMENTS
              </div>
              <div style={{ fontSize: '16px', color: C.text }}>
                {refinements_performed}
              </div>
            </div>
          </div>

          <div style={{ marginBottom: '12px' }}>
            <div
              style={{
                fontSize: '11px',
                color: C.textDim,
                marginBottom: '6px',
              }}
            >
              REFINEMENT SETTING
            </div>
            <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
              {settings.map((s) => (
                <button
                  type="button"
                  key={s}
                  style={{
                    background:
                      s === setting
                        ? settingColors[s] || C.text
                        : 'transparent',
                    border: `1px solid ${settingColors[s] || C.border}`,
                    color: s === setting ? '#000' : settingColors[s] || C.text,
                    padding: '6px 12px',
                    cursor: active ? 'not-allowed' : 'pointer',
                    fontFamily: 'monospace',
                    fontWeight: 'bold',
                    fontSize: '12px',
                    opacity: active ? 0.5 : 1,
                  }}
                  onClick={() =>
                    !active && act('change_setting', { setting: s })
                  }
                >
                  {s}
                </button>
              ))}
            </div>
          </div>

          {active && (
            <div style={{ marginBottom: '12px' }}>
              <div
                style={{
                  fontSize: '11px',
                  color: C.textDim,
                  marginBottom: '4px',
                }}
              >
                REFINEMENT PROGRESS: {progressPct}%
              </div>
              <div
                style={{
                  background: C.bgDark,
                  border: `1px solid ${C.border}`,
                  height: '16px',
                  position: 'relative',
                }}
              >
                <div
                  style={{
                    background: settingColors[setting] || C.text,
                    height: '100%',
                    width: `${progressPct}%`,
                    transition: 'width 0.3s',
                  }}
                />
              </div>
            </div>
          )}

          {!active && (
            <div style={{ marginBottom: '12px' }}>
              <button
                type="button"
                disabled={!input_items || input_items.length === 0}
                style={{
                  background: (!input_items || input_items.length === 0) ? 'grey' : (settingColors[setting] || C.text),
                  border: 'none',
                  color: (!input_items || input_items.length === 0) ? C.textDim : '#000',
                  padding: '10px 24px',
                  cursor: (!input_items || input_items.length === 0) ? 'not-allowed' : 'pointer',
                  fontFamily: 'monospace',
                  fontWeight: 'bold',
                  fontSize: '14px',
                  width: '100%',
                  opacity: (!input_items || input_items.length === 0) ? 0.5 : 1,
                }}
                onClick={() => act('start_refinement')}
              >
                START REFINEMENT
              </button>
            </div>
          )}

          {!active && (
            <div style={{ marginBottom: '12px' }}>
              <button
                type="button"
                style={{
                  background: 'transparent',
                  border: `1px solid ${C.border}`,
                  color: C.textDim,
                  padding: '6px 12px',
                  cursor: 'pointer',
                  fontFamily: 'monospace',
                  fontSize: '12px',
                }}
                onClick={() => act('insert_item')}
              >
                INSERT HELD ITEM
              </button>
            </div>
          )}

          <div
            style={{
              display: 'flex',
              gap: '16px',
              flexWrap: 'wrap',
            }}
          >
            <div style={{ flex: '1', minWidth: '200px' }}>
              <div
                style={{
                  fontSize: '12px',
                  fontWeight: 'bold',
                  color: C.text,
                  borderBottom: `1px solid ${C.border}`,
                  paddingBottom: '4px',
                  marginBottom: '6px',
                }}
              >
                INPUT ({input_items.length})
              </div>
              {input_items.map((item) => (
                <div
                  key={item.ref}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    padding: '3px 0',
                    fontSize: '12px',
                    color: C.textDim,
                  }}
                >
                  <span>{item.name}</span>
                  {!active && (
                    <button
                      type="button"
                      style={{
                        background: 'transparent',
                        border: `1px solid ${C.border}`,
                        color: C.textDim,
                        padding: '1px 6px',
                        cursor: 'pointer',
                        fontFamily: 'monospace',
                        fontSize: '10px',
                      }}
                      onClick={() => act('remove_input', { ref: item.ref })}
                    >
                      X
                    </button>
                  )}
                </div>
              ))}
              {input_items.length === 0 && (
                <div style={{ color: C.textDim, fontSize: '11px' }}>EMPTY</div>
              )}
            </div>

            <div style={{ flex: '1', minWidth: '200px' }}>
              <div
                style={{
                  fontSize: '12px',
                  fontWeight: 'bold',
                  color: C.safe,
                  borderBottom: `1px solid ${C.border}`,
                  paddingBottom: '4px',
                  marginBottom: '6px',
                }}
              >
                OUTPUT ({output_items.length})
              </div>
              {output_items.map((item) => (
                <div
                  key={item.ref}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    padding: '3px 0',
                    fontSize: '12px',
                    color: C.text,
                  }}
                >
                  <span>{item.name}</span>
                  <button
                    type="button"
                    style={{
                      background: 'transparent',
                      border: `1px solid ${C.border}`,
                      color: C.text,
                      padding: '1px 6px',
                      cursor: 'pointer',
                      fontFamily: 'monospace',
                      fontSize: '10px',
                    }}
                    onClick={() => act('remove_output', { ref: item.ref })}
                  >
                    TAKE
                  </button>
                </div>
              ))}
              {output_items.length === 0 && (
                <div style={{ color: C.textDim, fontSize: '11px' }}>EMPTY</div>
              )}
            </div>
          </div>

          <div
            style={{
              marginTop: '12px',
              display: 'flex',
              gap: '16px',
              fontSize: '11px',
              color: C.textDim,
            }}
          >
            <span>Destroyed: {objects_destroyed}</span>
            <span>Enhanced: {objects_enhanced}</span>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
