import { useBackend } from '../backend';
import { Box, Button, NoticeBox } from '../components';
import { Window } from '../layouts';

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

const term = (overrides = {}) => ({
  fontFamily: C.mono,
  fontSize: '12px',
  color: C.text,
  ...overrides,
});

const TermBox = (props) => (
  <Box style={term({ ...props.style })}>{props.children}</Box>
);

const TermHeader = (props) => (
  <Box
    style={term({
      fontSize: '10px',
      color: C.textDim,
      letterSpacing: '0.18em',
      textTransform: 'uppercase',
      borderBottom: `1px solid ${C.border}`,
      paddingBottom: '4px',
      marginBottom: '8px',
      ...props.style,
    })}
  >
    {props.children}
  </Box>
);

const TermLabel = (props) => (
  <Box
    as="span"
    style={term({
      color: C.textDim,
      fontSize: '10px',
      letterSpacing: '0.12em',
      textTransform: 'uppercase',
      marginRight: '8px',
    })}
  >
    {props.children}
  </Box>
);

const TermValue = (props) => (
  <Box
    as="span"
    style={term({
      color: props.color || C.textBright,
      fontWeight: props.bold ? 'bold' : undefined,
    })}
  >
    {props.children}
  </Box>
);

const TermRow = (props) => (
  <Box style={{ marginBottom: '6px', display: 'flex', alignItems: 'center' }}>
    {props.children}
  </Box>
);

const TermDivider = () => (
  <Box
    style={{
      color: C.borderRed,
      fontSize: '10px',
      letterSpacing: '0.3em',
      margin: '10px 0',
      userSelect: 'none',
      overflow: 'hidden',
      whiteSpace: 'nowrap',
    }}
  >
    {'─'.repeat(80)}
  </Box>
);

const TermButton = (props) => {
  const selected = props.selected;
  const color = props.color;
  const bg = selected
    ? color === 'red'
      ? 'rgba(139,0,0,0.35)'
      : color === 'green'
        ? 'rgba(26,122,26,0.35)'
        : color === 'yellow'
          ? 'rgba(180,160,20,0.25)'
          : 'rgba(255,255,255,0.08)'
    : 'transparent';
  const borderColor = selected
    ? color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border
    : C.border;

  return (
    <Button
      {...props}
      style={{
        fontFamily: C.mono,
        fontSize: '10px',
        letterSpacing: '0.1em',
        textTransform: 'uppercase',
        background: bg,
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color: selected ? C.textBright : C.textDim,
        padding: '3px 8px',
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    >
      {props.children}
    </Button>
  );
};

const TermProgressBar = (props) => (
  <Box style={{ marginBottom: '6px' }}>
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        marginBottom: '2px',
      }}
    >
      <TermLabel>{props.label}</TermLabel>
      <TermValue color={props.color || C.amber}>{props.value}%</TermValue>
    </Box>
    <Box
      style={{
        height: '6px',
        background: C.panel,
        border: `1px solid ${C.border}`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          height: '100%',
          width: `${Math.min(100, Math.max(0, props.value))}%`,
          background:
            props.value >= 100 ? C.green : props.value > 50 ? C.amber : C.red,
          transition: 'width 0.3s',
        }}
      />
    </Box>
  </Box>
);

export const PersistentProgressionPlayerView = (props, context) => {
  const { act, data } = useBackend(context);

  if (!data.has_data) {
    return (
      <Window
        title="SCP FOUNDATION — PERSONNEL MONITOR"
        width={1000}
        height={700}
        theme="scp_terminal"
      >
        <Window.Content scrollable>
          <Box
            style={{
              background: C.bg,
              border: `1px solid ${C.borderRed}`,
              fontFamily: C.mono,
              fontSize: '12px',
              color: C.text,
              minHeight: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <NoticeBox>
              NO PERSISTENT DATA FOUND FOR THIS PERSONNEL RECORD
            </NoticeBox>
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const {
    ckey,
    current_class,
    current_faction,
    current_rank,
    current_rank_level,
    total_experience,
    rounds_played,
    last_login,
    progress_to_next,
    exp_needed,
    unlocked_items,
    unlocked_titles,
    achievements,
    recent_experience,
  } = data;

  return (
    <Window
      title={`SCP FOUNDATION — PERSONNEL MONITOR — ${ckey}`}
      width={1000}
      height={700}
      theme="scp_terminal"
    >
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
              SCP FOUNDATION — PERSONNEL MONITOR
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 3 | ADMINISTRATIVE | SUBJECT: {ckey}
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>PERSONNEL IDENTIFICATION</TermHeader>
            <TermRow>
              <TermLabel>IDENTIFICATION KEY</TermLabel>
              <TermValue color={C.amber}>{ckey}</TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>CLASS</TermLabel>
              <TermValue>{current_class}</TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>FACTION</TermLabel>
              <TermValue>{current_faction}</TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>RANK</TermLabel>
              <TermValue color={C.green}>
                {current_rank} (LEVEL {current_rank_level})
              </TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>TOTAL XP</TermLabel>
              <TermValue color={C.amber}>
                {total_experience.toLocaleString()}
              </TermValue>
            </TermRow>
            <TermRow>
              <TermLabel>ROUNDS PLAYED</TermLabel>
              <TermValue>{rounds_played}</TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>RANK PROGRESSION</TermHeader>
            <TermProgressBar
              label="PROGRESS TO NEXT RANK"
              value={progress_to_next}
            />
            {exp_needed > 0 && (
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '10px',
                  marginBottom: '8px',
                })}
              >
                {exp_needed.toLocaleString()} XP REQUIRED FOR NEXT RANK
              </Box>
            )}

            <TermDivider />

            <TermHeader>UNLOCKED CONTENT</TermHeader>
            <Box style={{ display: 'flex', gap: '16px', marginBottom: '8px' }}>
              <Box style={{ flex: 1 }}>
                <TermLabel>
                  ITEMS ({unlocked_items ? unlocked_items.length : 0})
                </TermLabel>
                {unlocked_items && unlocked_items.length > 0 ? (
                  unlocked_items.map((item, i) => (
                    <Box
                      key={i}
                      style={term({
                        color: C.text,
                        fontSize: '11px',
                        paddingLeft: '8px',
                      })}
                    >
                      {item}
                    </Box>
                  ))
                ) : (
                  <Box
                    style={term({
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    })}
                  >
                    NONE
                  </Box>
                )}
              </Box>
              <Box style={{ flex: 1 }}>
                <TermLabel>
                  TITLES ({unlocked_titles ? unlocked_titles.length : 0})
                </TermLabel>
                {unlocked_titles && unlocked_titles.length > 0 ? (
                  unlocked_titles.map((title, i) => (
                    <Box
                      key={i}
                      style={term({
                        color: C.text,
                        fontSize: '11px',
                        paddingLeft: '8px',
                      })}
                    >
                      {title}
                    </Box>
                  ))
                ) : (
                  <Box
                    style={term({
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    })}
                  >
                    NONE
                  </Box>
                )}
              </Box>
            </Box>

            <TermDivider />

            <TermHeader>RECENT EXPERIENCE ACTIVITY</TermHeader>
            {recent_experience && recent_experience.length > 0 ? (
              recent_experience.map((exp, i) => (
                <Box
                  key={i}
                  style={{
                    marginBottom: '4px',
                    padding: '6px 8px',
                    borderLeft: `2px solid ${C.borderRed}`,
                    background: C.panel,
                  }}
                >
                  <TermRow>
                    <TermValue color={C.green} bold>
                      +{exp.amount} XP
                    </TermValue>
                    <TermLabel style={{ marginLeft: '12px' }}>
                      {exp.reason}
                    </TermLabel>
                    <Box
                      as="span"
                      style={term({
                        color: C.textDim,
                        fontSize: '10px',
                        marginLeft: 'auto',
                      })}
                    >
                      {exp.timestamp}
                    </Box>
                  </TermRow>
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO RECENT ACTIVITY
              </Box>
            )}

            <TermDivider />

            <TermHeader>ADMINISTRATIVE ACTIONS</TermHeader>
            <Box style={{ display: 'flex', gap: '4px' }}>
              <TermButton color="green" onClick={() => act('export_data')}>
                DOWNLOAD DATA
              </TermButton>
              <TermButton color="red" onClick={() => act('reset_progress')}>
                RESET PROGRESS
              </TermButton>
              <TermButton onClick={() => act('close_viewer')}>CLOSE</TermButton>
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
              style={term({
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              })}
            >
              SCP FOUNDATION | PERSONNEL MONITOR | ALL ACCESS LOGGED |
              UNAUTHORIZED REVIEW IS A CLASS-C INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
