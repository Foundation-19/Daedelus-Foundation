import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';

type Ruleset = {
  name: string;
  ref: string;
};

type GamePanelData = {
  force_extended: number;
  forced_rulesets: Ruleset[];
  forced_threat: number;
  has_marked_datum: boolean;
  mode: string;
  no_stacking: number;
  round_state: number;
  round_state_text: string;
  stacking_limit: number;
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  accent: '#c2960e',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  text: '#b0b0b0',
  textBright: '#e0e0e0',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const TermButton = (props) => {
  const { color, selected, ...rest } = props;
  const borderColor =
    color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border;
  const bg = selected
    ? color === 'red'
      ? 'rgba(139,0,0,0.35)'
      : color === 'green'
        ? 'rgba(26,122,26,0.35)'
        : 'rgba(255,255,255,0.08)'
    : 'transparent';
  return (
    <Button
      {...rest}
      style={{
        fontFamily: C.mono,
        fontSize: '9px',
        letterSpacing: '0.08em',
        textTransform: 'uppercase',
        background: bg,
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color: selected ? C.textBright : C.textDim,
        padding: '3px 8px',
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    />
  );
};

export const AdminGamePanel = (_props: unknown) => {
  const { act, data } = useBackend<GamePanelData>();
  const {
    round_state,
    round_state_text,
    mode,
    forced_rulesets = [],
    force_extended,
    no_stacking,
    forced_threat,
    stacking_limit,
    has_marked_datum,
  } = data;

  const isPregame = round_state <= 0;

  return (
    <Window theme="scp_terminal" width={700} height={550}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderRed}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              SCP FOUNDATION — GAME CONTROL TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | FACILITY MANAGEMENT | ROUND STATE:{' '}
              {round_state_text} | MODE: {mode}
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.1em',
                borderBottom: `1px solid ${C.border}`,
                paddingBottom: '4px',
                marginBottom: '8px',
                textTransform: 'uppercase',
              }}
            >
              Entity Manifestation
            </Box>
            <Box style={{ display: 'flex', gap: '4px', marginBottom: '16px' }}>
              <TermButton color="green" onClick={() => act('create_object')}>
                CREATE OBJECT
              </TermButton>
              <TermButton onClick={() => act('quick_create_object')}>
                QUICK CREATE
              </TermButton>
              <TermButton color="yellow" onClick={() => act('create_turf')}>
                CREATE TURF
              </TermButton>
              <TermButton color="red" onClick={() => act('create_mob')}>
                CREATE MOB
              </TermButton>
              {has_marked_datum && (
                <TermButton onClick={() => act('dupe_marked')}>
                  DUPE MARKED
                </TermButton>
              )}
            </Box>

            {isPregame && (
              <>
                <Box
                  style={{
                    fontSize: '9px',
                    color: C.textDim,
                    letterSpacing: '0.1em',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '8px',
                    textTransform: 'uppercase',
                  }}
                >
                  Dynamic Round Configuration
                </Box>
                <Box style={{ marginBottom: '8px' }}>
                  <TermButton
                    color="green"
                    onClick={() => act('force_ruleset')}
                  >
                    FORCE ROUNDSTART RULESET
                  </TermButton>
                  <TermButton color="red" onClick={() => act('clear_rulesets')}>
                    CLEAR ALL
                  </TermButton>
                  <TermButton onClick={() => act('dynamic_options')}>
                    DYNAMIC OPTIONS
                  </TermButton>
                </Box>

                {forced_rulesets.length > 0 && (
                  <Box style={{ marginBottom: '12px' }}>
                    {forced_rulesets.map((rs) => (
                      <Box
                        key={rs.ref}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          marginBottom: '4px',
                          padding: '4px 8px',
                          borderLeft: `2px solid ${C.amber}`,
                          background: C.panel,
                        }}
                      >
                        <Box
                          style={{
                            flex: 1,
                            fontSize: '11px',
                            color: C.textBright,
                          }}
                        >
                          {rs.name}
                        </Box>
                        <TermButton
                          color="red"
                          onClick={() => act('remove_ruleset', { ref: rs.ref })}
                        >
                          REMOVE
                        </TermButton>
                      </Box>
                    ))}
                  </Box>
                )}

                <Box style={{ marginBottom: '16px' }}>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '8px',
                      alignItems: 'center',
                      marginBottom: '4px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '10px',
                        color: C.textDim,
                        letterSpacing: '0.1em',
                        textTransform: 'uppercase',
                        width: '160px',
                      }}
                    >
                      Force Extended
                    </Box>
                    <TermButton
                      color={force_extended ? 'green' : undefined}
                      selected={!!force_extended}
                      onClick={() => act('toggle_force_extended')}
                    >
                      {force_extended ? 'ON' : 'OFF'}
                    </TermButton>
                  </Box>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '8px',
                      alignItems: 'center',
                      marginBottom: '4px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '10px',
                        color: C.textDim,
                        letterSpacing: '0.1em',
                        textTransform: 'uppercase',
                        width: '160px',
                      }}
                    >
                      No Stacking
                    </Box>
                    <TermButton
                      color={no_stacking ? 'green' : undefined}
                      selected={!!no_stacking}
                      onClick={() => act('toggle_no_stacking')}
                    >
                      {no_stacking ? 'ON' : 'OFF'}
                    </TermButton>
                  </Box>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '8px',
                      alignItems: 'center',
                      marginBottom: '4px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '10px',
                        color: C.textDim,
                        letterSpacing: '0.1em',
                        textTransform: 'uppercase',
                        width: '160px',
                      }}
                    >
                      Forced Threat Level
                    </Box>
                    <TermButton onClick={() => act('set_forced_threat')}>
                      {forced_threat}
                    </TermButton>
                  </Box>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '8px',
                      alignItems: 'center',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '10px',
                        color: C.textDim,
                        letterSpacing: '0.1em',
                        textTransform: 'uppercase',
                        width: '160px',
                      }}
                    >
                      Stacking Limit
                    </Box>
                    <TermButton onClick={() => act('set_stacking_limit')}>
                      {stacking_limit}
                    </TermButton>
                  </Box>
                </Box>
              </>
            )}

            {!isPregame && (
              <Box style={{ marginBottom: '16px' }}>
                <TermButton color="green" onClick={() => act('gamemode_panel')}>
                  GAME MODE PANEL
                </TermButton>
              </Box>
            )}
          </Box>

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={{
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | GAME CONTROL | ALL ACTIONS LOGGED | UNAUTHORIZED
              ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
