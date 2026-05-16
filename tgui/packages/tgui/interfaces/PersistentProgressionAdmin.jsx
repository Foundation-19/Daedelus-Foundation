import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Modal, NoticeBox } from '../components';
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

const TermModal = (props) => (
  <Modal
    {...props}
    style={{
      background: C.bg,
      border: `1px solid ${C.borderRed}`,
      borderRadius: 0,
      fontFamily: C.mono,
      color: C.text,
      padding: '16px',
    }}
  >
    {props.children}
  </Modal>
);

export const PersistentProgressionAdmin = (props, context) => {
  const { act, data } = useBackend(context);
  const { players } = data;
  const [selectedPlayer, setSelectedPlayer] = useLocalState(
    context,
    'selectedPlayer',
    null,
  );
  const [showAwardModal, setShowAwardModal] = useLocalState(
    context,
    'showAwardModal',
    false,
  );
  const [showRankModal, setShowRankModal] = useLocalState(
    context,
    'showRankModal',
    false,
  );
  const [awardAmount, setAwardAmount] = useLocalState(
    context,
    'awardAmount',
    '',
  );
  const [awardReason, setAwardReason] = useLocalState(
    context,
    'awardReason',
    '',
  );
  const [rankClass, setRankClass] = useLocalState(context, 'rankClass', '');
  const [rankLevel, setRankLevel] = useLocalState(context, 'rankLevel', '');

  const handleAwardExperience = () => {
    if (selectedPlayer && awardAmount && awardReason) {
      act('award_experience', {
        ckey: selectedPlayer,
        amount: parseInt(awardAmount),
        reason: awardReason,
      });
      setShowAwardModal(false);
      setAwardAmount('');
      setAwardReason('');
    }
  };

  const handleSetRank = () => {
    if (selectedPlayer && rankClass && rankLevel !== '') {
      act('set_rank', {
        ckey: selectedPlayer,
        class_id: rankClass,
        rank_level: parseInt(rankLevel),
      });
      setShowRankModal(false);
      setRankClass('');
      setRankLevel('');
    }
  };

  return (
    <Window
      title="SCP FOUNDATION — ADMIN PROGRESSION CONTROL"
      width={1100}
      height={750}
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
              SCP FOUNDATION — ADMIN PROGRESSION CONTROL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | ADMINISTRATIVE OVERRIDE | PERSONNEL MANAGEMENT
              TERMINAL
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>
              PERSONNEL REGISTRY — {players ? players.length : 0} RECORDS
            </TermHeader>

            {!players || players.length === 0 ? (
              <NoticeBox>NO PERSONNEL RECORDS ON FILE</NoticeBox>
            ) : (
              players.map((player) => (
                <Box
                  key={player.ckey}
                  style={{
                    marginBottom: '8px',
                    padding: '10px',
                    borderLeft: `2px solid ${C.borderRed}`,
                    background: C.panel,
                  }}
                >
                  <TermRow>
                    <TermValue bold color={C.amber}>
                      {player.name}
                    </TermValue>
                    <TermLabel style={{ marginLeft: '12px' }}>KEY</TermLabel>
                    <TermValue color={C.textDim}>{player.ckey}</TermValue>
                  </TermRow>
                  <TermRow>
                    <TermLabel>CLASS</TermLabel>
                    <TermValue>{player.class}</TermValue>
                    <TermLabel style={{ marginLeft: '16px' }}>RANK</TermLabel>
                    <TermValue color={C.green}>{player.rank}</TermValue>
                    <TermLabel style={{ marginLeft: '16px' }}>XP</TermLabel>
                    <TermValue color={C.amber}>
                      {player.experience.toLocaleString()}
                    </TermValue>
                    <TermLabel style={{ marginLeft: '16px' }}>ROUNDS</TermLabel>
                    <TermValue>{player.rounds_played}</TermValue>
                  </TermRow>
                  <Box
                    style={{ display: 'flex', gap: '4px', marginTop: '6px' }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => {
                        setSelectedPlayer(player.ckey);
                        setShowAwardModal(true);
                      }}
                    >
                      AWARD XP
                    </TermButton>
                    <TermButton
                      color="yellow"
                      onClick={() => {
                        setSelectedPlayer(player.ckey);
                        setShowRankModal(true);
                      }}
                    >
                      SET RANK
                    </TermButton>
                    <TermButton
                      color="red"
                      onClick={() =>
                        act('reset_progress', { ckey: player.ckey })
                      }
                    >
                      RESET
                    </TermButton>
                    <TermButton
                      onClick={() =>
                        act('view_progress', { ckey: player.ckey })
                      }
                    >
                      VIEW
                    </TermButton>
                  </Box>
                </Box>
              ))
            )}
          </Box>

          {showAwardModal && (
            <TermModal>
              <TermHeader>AWARD EXPERIENCE — {selectedPlayer}</TermHeader>
              <Box style={{ marginBottom: '10px' }}>
                <TermLabel>AMOUNT</TermLabel>
                <Input
                  value={awardAmount}
                  onChange={(e, value) => setAwardAmount(value)}
                  placeholder="0"
                  type="number"
                  style={{
                    fontFamily: C.mono,
                    fontSize: '14px',
                    height: '32px',
                  }}
                />
              </Box>
              <Box style={{ marginBottom: '10px' }}>
                <TermLabel>REASON</TermLabel>
                <Input
                  fluid
                  value={awardReason}
                  onChange={(e, value) => setAwardReason(value)}
                  placeholder="Administrative award..."
                  style={{
                    fontFamily: C.mono,
                    fontSize: '14px',
                    height: '32px',
                  }}
                />
              </Box>
              <Box style={{ display: 'flex', gap: '4px' }}>
                <TermButton color="green" onClick={handleAwardExperience}>
                  CONFIRM
                </TermButton>
                <TermButton
                  color="red"
                  onClick={() => setShowAwardModal(false)}
                >
                  CANCEL
                </TermButton>
              </Box>
            </TermModal>
          )}

          {showRankModal && (
            <TermModal>
              <TermHeader>SET RANK — {selectedPlayer}</TermHeader>
              <Box style={{ marginBottom: '10px' }}>
                <TermLabel>CLASS ID</TermLabel>
                <Input
                  value={rankClass}
                  onChange={(e, value) => setRankClass(value)}
                  placeholder="e.g. security"
                  style={{
                    fontFamily: C.mono,
                    fontSize: '14px',
                    height: '32px',
                  }}
                />
              </Box>
              <Box style={{ marginBottom: '10px' }}>
                <TermLabel>RANK LEVEL</TermLabel>
                <Input
                  value={rankLevel}
                  onChange={(e, value) => setRankLevel(value)}
                  placeholder="0-6"
                  type="number"
                  style={{
                    fontFamily: C.mono,
                    fontSize: '14px',
                    height: '32px',
                  }}
                />
              </Box>
              <Box style={{ display: 'flex', gap: '4px' }}>
                <TermButton color="green" onClick={handleSetRank}>
                  CONFIRM
                </TermButton>
                <TermButton color="red" onClick={() => setShowRankModal(false)}>
                  CANCEL
                </TermButton>
              </Box>
            </TermModal>
          )}

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
              SCP FOUNDATION | ADMIN CONTROL | ALL ACTIONS LOGGED | MISUSE IS
              GROUNDS FOR IMMEDIATE TERMINATION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
