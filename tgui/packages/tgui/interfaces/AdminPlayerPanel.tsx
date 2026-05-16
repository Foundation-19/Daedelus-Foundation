import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input } from '../components';
import { Window } from '../layouts';

type PlayerData = {
  admin_rank: string;
  byond_version: string;
  ckey: string;
  discord_id: string;
  discord_linked: boolean;
  has_client: boolean;
  has_mind: boolean;
  input_mode: string;
  is_ai: boolean;
  is_antag: number;
  is_cyborg: boolean;
  is_human: boolean;
  is_monkey: boolean;
  is_new_player: boolean;
  is_observer: boolean;
  job: string;
  join_date: string;
  key: string;
  last_ip: string;
  mob_type: string;
  name: string;
  previous_names: string;
  real_name: string;
  ref: string;
};

type PlayerPanelData = {
  has_centcom_db: boolean;
  has_exp_tracking: boolean;
  players: PlayerData[];
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
  greenDim: '#0d4a0d',
  text: '#b0b0b0',
  textBright: '#e0e0e0',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const TermButton = (props) => {
  const { color, ...rest } = props;
  const borderColor =
    color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border;
  return (
    <Button
      {...rest}
      style={{
        fontFamily: C.mono,
        fontSize: '9px',
        letterSpacing: '0.08em',
        textTransform: 'uppercase',
        background: 'transparent',
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color:
          color === 'red'
            ? C.redBright
            : color === 'green'
              ? '#33cc33'
              : C.textDim,
        padding: '2px 6px',
      }}
    />
  );
};

const jobColor = (job: string) => {
  if (job === 'Observer' || job === 'Ghost') return C.textDim;
  if (job === 'New Player') return C.amber;
  if (job === 'AI' || job === 'Cyborg') return '#44aaff';
  return C.textBright;
};

const antagColor = (level: number) => {
  if (level > 0) return C.redBright;
  return C.textDim;
};

export const AdminPlayerPanel = (_props: unknown) => {
  const { act, data } = useBackend<PlayerPanelData>();
  const { players = [], has_centcom_db, has_exp_tracking } = data;
  const [filter, setFilter] = useLocalState('ppfilter', '');
  const [selectedPlayer, setSelectedPlayer] = useLocalState<PlayerData | null>(
    'ppselected',
    null,
  );

  const filtered = players.filter((p) => {
    if (!filter) return true;
    const f = filter.toLowerCase();
    return (
      p.name?.toLowerCase().includes(f) ||
      p.real_name?.toLowerCase().includes(f) ||
      p.key?.toLowerCase().includes(f) ||
      p.ckey?.toLowerCase().includes(f) ||
      p.job?.toLowerCase().includes(f) ||
      p.previous_names?.toLowerCase().includes(f)
    );
  });

  return (
    <Window theme="scp_terminal" width={900} height={600}>
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
              SCP FOUNDATION — PERSONNEL DATABASE
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | SITE-53 FACILITY | ALL PERSONNEL RECORDS |
              TOTAL: {players.length} ENTRIES
            </Box>
          </Box>

          <Box
            style={{
              padding: '8px 14px',
              borderBottom: `1px solid ${C.border}`,
            }}
          >
            <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
              <Box
                style={{
                  fontSize: '10px',
                  color: C.textDim,
                  letterSpacing: '0.12em',
                  textTransform: 'uppercase',
                }}
              >
                SEARCH:
              </Box>
              <Input
                value={filter}
                onInput={(_e, value) => setFilter(value)}
                placeholder="Name, key, job..."
                style={{
                  fontFamily: C.mono,
                  fontSize: '12px',
                  flex: 1,
                }}
              />
              <TermButton onClick={() => act('check_antags')} color="red">
                CHECK ANTAGS
              </TermButton>
            </Box>
          </Box>

          <Box style={{ display: 'flex', minHeight: '400px' }}>
            <Box
              style={{
                flex: '1',
                borderRight: `1px solid ${C.border}`,
                overflowY: 'auto',
                maxHeight: '440px',
              }}
            >
              <Box
                style={{
                  display: 'flex',
                  borderBottom: `1px solid ${C.border}`,
                  padding: '4px 8px',
                  fontSize: '9px',
                  color: C.textDim,
                  letterSpacing: '0.1em',
                  textTransform: 'uppercase',
                  fontWeight: 'bold',
                  background: C.panel,
                  position: 'sticky',
                  top: 0,
                  zIndex: 1,
                }}
              >
                <Box style={{ flex: '2' }}>NAME</Box>
                <Box style={{ flex: '1' }}>JOB</Box>
                <Box style={{ width: '50px' }}>STATUS</Box>
              </Box>

              {filtered.map((p) => (
                <Box
                  key={p.ref}
                  style={{
                    display: 'flex',
                    padding: '4px 8px',
                    borderBottom: `1px solid ${C.border}`,
                    cursor: 'pointer',
                    background:
                      selectedPlayer?.ref === p.ref
                        ? 'rgba(139,0,0,0.2)'
                        : 'transparent',
                    fontSize: '11px',
                    alignItems: 'center',
                  }}
                  onClick={() => setSelectedPlayer(p)}
                >
                  <Box style={{ flex: '2', color: C.textBright }}>
                    {p.name}
                    <Box style={{ fontSize: '9px', color: C.textDim }}>
                      {p.key}
                    </Box>
                  </Box>
                  <Box style={{ flex: '1', color: jobColor(p.job) }}>
                    {p.job}
                  </Box>
                  <Box style={{ width: '50px' }}>
                    {p.is_antag > 0 && (
                      <Box
                        style={{
                          color: C.redBright,
                          fontSize: '9px',
                          fontWeight: 'bold',
                        }}
                      >
                        ANTAG
                      </Box>
                    )}
                  </Box>
                </Box>
              ))}

              {filtered.length === 0 && (
                <Box
                  style={{
                    textAlign: 'center',
                    color: C.textDim,
                    padding: '20px',
                    fontStyle: 'italic',
                  }}
                >
                  NO MATCHING RECORDS
                </Box>
              )}
            </Box>

            <Box
              style={{
                flex: '1',
                padding: '12px',
                overflowY: 'auto',
                maxHeight: '440px',
              }}
            >
              {selectedPlayer ? (
                <PlayerDetail
                  player={selectedPlayer}
                  act={act}
                  has_centcom_db={has_centcom_db}
                  has_exp_tracking={has_exp_tracking}
                />
              ) : (
                <Box
                  style={{
                    textAlign: 'center',
                    color: C.textDim,
                    padding: '40px',
                    fontStyle: 'italic',
                  }}
                >
                  SELECT A PERSONNEL RECORD FROM THE LIST
                </Box>
              )}
            </Box>
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
              SCP FOUNDATION | PERSONNEL DATABASE | UNAUTHORIZED ACCESS IS A
              CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

const PlayerDetail = (props: {
  act: (action: string, params?: Record<string, string>) => void;
  has_centcom_db: boolean;
  has_exp_tracking: boolean;
  player: PlayerData;
}) => {
  const { player: p, act, has_centcom_db, has_exp_tracking } = props;

  return (
    <Box>
      <Box
        style={{
          borderBottom: `1px solid ${C.borderRed}`,
          paddingBottom: '8px',
          marginBottom: '8px',
        }}
      >
        <Box style={{ fontSize: '14px', fontWeight: 'bold', color: C.amber }}>
          {p.name}
        </Box>
        <Box style={{ fontSize: '10px', color: C.textDim }}>
          REAL NAME: {p.real_name} | KEY: {p.key}
        </Box>
        {p.is_antag > 0 && (
          <Box
            style={{
              color: C.redBright,
              fontWeight: 'bold',
              fontSize: '10px',
              marginTop: '4px',
            }}
          >
            [ANTAGONIST DETECTED]
          </Box>
        )}
      </Box>

      <Box style={{ marginBottom: '8px' }}>
        <Box
          style={{
            fontSize: '9px',
            color: C.textDim,
            letterSpacing: '0.1em',
            borderBottom: `1px solid ${C.border}`,
            paddingBottom: '2px',
            marginBottom: '4px',
            textTransform: 'uppercase',
          }}
        >
          Quick Actions
        </Box>
        <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
          <TermButton onClick={() => act('pp', { ref: p.ref })}>PP</TermButton>
          <TermButton onClick={() => act('vv', { ref: p.ref })}>VV</TermButton>
          <TermButton
            onClick={() => act('tp', { ref: p.ref })}
            color={p.has_mind ? undefined : 'red'}
          >
            TP
          </TermButton>
          <TermButton onClick={() => act('pm', { ref: p.ref })}>PM</TermButton>
          <TermButton onClick={() => act('sm', { ref: p.ref })}>SM</TermButton>
          <TermButton onClick={() => act('flw', { ref: p.ref })} color="green">
            FLW
          </TermButton>
          <TermButton onClick={() => act('logs', { ref: p.ref })}>
            LOGS
          </TermButton>
          <TermButton onClick={() => act('skills', { ref: p.ref })}>
            SKILLS
          </TermButton>
        </Box>
      </Box>

      <Box style={{ marginBottom: '8px' }}>
        <Box
          style={{
            fontSize: '9px',
            color: C.textDim,
            letterSpacing: '0.1em',
            borderBottom: `1px solid ${C.border}`,
            paddingBottom: '2px',
            marginBottom: '4px',
            textTransform: 'uppercase',
          }}
        >
          Administrative Actions
        </Box>
        <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
          <TermButton color="red" onClick={() => act('kick', { ref: p.ref })}>
            KICK
          </TermButton>
          <TermButton color="red" onClick={() => act('ban', { ref: p.ref })}>
            BAN
          </TermButton>
          <TermButton onClick={() => act('notes', { ref: p.ref })}>
            NOTES
          </TermButton>
          <TermButton color="green" onClick={() => act('heal', { ref: p.ref })}>
            HEAL
          </TermButton>
          <TermButton onClick={() => act('prison', { ref: p.ref })}>
            PRISON
          </TermButton>
          <TermButton onClick={() => act('send_to_lobby', { ref: p.ref })}>
            LOBBY
          </TermButton>
        </Box>
      </Box>

      <Box style={{ marginBottom: '8px' }}>
        <Box
          style={{
            fontSize: '9px',
            color: C.textDim,
            letterSpacing: '0.1em',
            borderBottom: `1px solid ${C.border}`,
            paddingBottom: '2px',
            marginBottom: '4px',
            textTransform: 'uppercase',
          }}
        >
          Movement
        </Box>
        <Box style={{ display: 'flex', gap: '4px' }}>
          <TermButton
            color="green"
            onClick={() => act('jump_to', { ref: p.ref })}
          >
            JUMP TO
          </TermButton>
          <TermButton onClick={() => act('get', { ref: p.ref })}>
            GET
          </TermButton>
          <TermButton onClick={() => act('send', { ref: p.ref })}>
            SEND TO
          </TermButton>
        </Box>
      </Box>

      <Box style={{ marginBottom: '8px' }}>
        <Box
          style={{
            fontSize: '9px',
            color: C.textDim,
            letterSpacing: '0.1em',
            borderBottom: `1px solid ${C.border}`,
            paddingBottom: '2px',
            marginBottom: '4px',
            textTransform: 'uppercase',
          }}
        >
          Communication
        </Box>
        <Box style={{ display: 'flex', gap: '4px' }}>
          <TermButton onClick={() => act('narrate', { ref: p.ref })}>
            NARRATE
          </TermButton>
          <TermButton onClick={() => act('subtle_msg', { ref: p.ref })}>
            SUBTLE MSG
          </TermButton>
          <TermButton onClick={() => act('play_sound', { ref: p.ref })}>
            PLAY SOUND
          </TermButton>
          <TermButton onClick={() => act('forcesay', { ref: p.ref })}>
            FORCESAY
          </TermButton>
        </Box>
      </Box>

      {p.has_client && !p.is_new_player && (
        <Box style={{ marginBottom: '8px' }}>
          <Box
            style={{
              fontSize: '9px',
              color: C.textDim,
              letterSpacing: '0.1em',
              borderBottom: `1px solid ${C.border}`,
              paddingBottom: '2px',
              marginBottom: '4px',
              textTransform: 'uppercase',
            }}
          >
            Transformation
          </Box>
          <Box style={{ display: 'flex', gap: '4px' }}>
            <TermButton
              color={p.is_observer ? 'green' : undefined}
              onClick={() => act('make_observer', { ref: p.ref })}
            >
              {p.is_observer ? '[GHOST]' : 'GHOST'}
            </TermButton>
            <TermButton
              color={p.is_human && !p.is_monkey ? 'green' : undefined}
              onClick={() => act('make_human', { ref: p.ref })}
            >
              {p.is_human && !p.is_monkey ? '[HUMAN]' : 'HUMAN'}
            </TermButton>
            <TermButton
              color={p.is_monkey ? 'green' : undefined}
              onClick={() => act('make_monkey', { ref: p.ref })}
            >
              {p.is_monkey ? '[MONKEY]' : 'MONKEY'}
            </TermButton>
            <TermButton
              color={p.is_cyborg ? 'green' : undefined}
              onClick={() => act('make_cyborg', { ref: p.ref })}
            >
              {p.is_cyborg ? '[CYBORG]' : 'CYBORG'}
            </TermButton>
            <TermButton
              color={p.is_ai ? 'green' : undefined}
              onClick={() => act('make_ai', { ref: p.ref })}
            >
              {p.is_ai ? '[AI]' : 'AI'}
            </TermButton>
          </Box>
        </Box>
      )}

      <Box
        style={{
          fontSize: '9px',
          color: C.textDim,
          letterSpacing: '0.1em',
          borderBottom: `1px solid ${C.border}`,
          paddingBottom: '2px',
          marginBottom: '4px',
          textTransform: 'uppercase',
        }}
      >
        Personnel Record
      </Box>
      <Box style={{ fontSize: '10px', lineHeight: '1.6' }}>
        <Box>
          <Box as="span" style={{ color: C.textDim }}>
            JOB:
          </Box>{' '}
          <Box as="span" style={{ color: jobColor(p.job) }}>
            {p.job}
          </Box>
        </Box>
        <Box>
          <Box as="span" style={{ color: C.textDim }}>
            RANK:
          </Box>{' '}
          <Box as="span" style={{ color: C.amber }}>
            {p.admin_rank || 'Player'}
          </Box>
        </Box>
        {p.has_client && (
          <>
            <Box>
              <Box as="span" style={{ color: C.textDim }}>
                BYOND:
              </Box>{' '}
              <Box as="span">{p.byond_version}</Box>
            </Box>
            <Box>
              <Box as="span" style={{ color: C.textDim }}>
                JOINED:
              </Box>{' '}
              <Box as="span">{p.join_date}</Box>
            </Box>
            <Box>
              <Box as="span" style={{ color: C.textDim }}>
                INPUT:
              </Box>{' '}
              <Box as="span">{p.input_mode}</Box>
            </Box>
          </>
        )}
        <Box>
          <Box as="span" style={{ color: C.textDim }}>
            IP:
          </Box>{' '}
          <Box as="span">{p.last_ip || 'N/A'}</Box>
        </Box>
        <Box>
          <Box as="span" style={{ color: C.textDim }}>
            TYPE:
          </Box>{' '}
          <Box as="span" style={{ fontSize: '9px' }}>
            {p.mob_type}
          </Box>
        </Box>
      </Box>
    </Box>
  );
};
