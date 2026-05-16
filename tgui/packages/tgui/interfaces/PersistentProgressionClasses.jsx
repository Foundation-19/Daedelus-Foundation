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

export const PersistentProgressionClasses = (props) => {
  const { act, data } = useBackend();
  const { classes } = data;

  return (
    <Window
      title="SCP FOUNDATION — CLASS REGISTRY"
      width={900}
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
              SCP FOUNDATION — CLASS REGISTRY
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 2 | CLASSIFIED | PERSONNEL CLASSIFICATION DATABASE
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            {!classes || classes.length === 0 ? (
              <NoticeBox>NO CLASS DATA ON FILE</NoticeBox>
            ) : (
              classes.map((classData) => (
                <Box key={classData.id} style={{ marginBottom: '12px' }}>
                  <TermHeader>{classData.name}</TermHeader>
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '11px',
                      fontStyle: 'italic',
                      marginBottom: '8px',
                      paddingLeft: '8px',
                    })}
                  >
                    {classData.description}
                  </Box>
                  <TermRow>
                    <TermLabel>EXP MULTIPLIER</TermLabel>
                    <TermValue color={C.amber}>
                      {classData.exp_multiplier}x
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <TermLabel>MAX RANK</TermLabel>
                    <TermValue color={C.textBright}>
                      {classData.max_rank}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <TermLabel>COMPATIBLE FACTIONS</TermLabel>
                    <TermValue color={C.textBright}>
                      {classData.compatible_factions.join(', ')}
                    </TermValue>
                  </TermRow>

                  <TermDivider />

                  <TermHeader>
                    RANK PROGRESSION — {classData.name.toUpperCase()}
                  </TermHeader>
                  {classData.ranks && classData.ranks.length > 0 ? (
                    classData.ranks.map((rank, index) => (
                      <Box
                        key={index}
                        style={{
                          marginBottom: '4px',
                          padding: '8px',
                          borderLeft: `2px solid ${rank.color || C.borderRed}`,
                          background: C.panel,
                        }}
                      >
                        <TermValue bold color={rank.color || C.amber}>
                          {rank.name}
                        </TermValue>
                        <Box
                          style={term({
                            color: C.textDim,
                            fontSize: '10px',
                            marginTop: '2px',
                          })}
                        >
                          {rank.requirement.toLocaleString()} XP REQUIRED
                        </Box>
                      </Box>
                    ))
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO RANKS DEFINED
                    </Box>
                  )}

                  <TermDivider />
                </Box>
              ))
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
              style={term({
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              })}
            >
              SCP FOUNDATION | CLASS REGISTRY | ALL DATA CLASSIFIED |
              UNAUTHORIZED ACCESS IS A CLASS-B INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
