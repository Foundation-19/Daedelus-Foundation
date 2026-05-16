import { BooleanLike } from 'common/react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Modal } from '../components';
import { Window } from '../layouts';

type MTFTeam = {
  desc: string;
  key: string;
  min_breach: number;
  name: string;
  size: number;
  specialty: string;
};

type MTFData = {
  active_breach_count: number;
  available_teams: MTFTeam[];
  cooldown_remaining: number;
  cooldown_total: number;
  last_deployment: string;
  on_cooldown: BooleanLike;
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

const term = (overrides = {}) => ({
  fontFamily: C.mono,
  fontSize: '12px',
  color: C.text,
  ...overrides,
});

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

const formatCooldown = (ms: number): string => {
  const totalSeconds = Math.ceil(ms / 10);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};

const teamDesignation = (key: string): string => {
  switch (key) {
    case 'mtf_nu7':
      return 'NU-7';
    case 'mtf_epsilon11':
      return 'EPS-11';
    case 'mtf_epsilon9':
      return 'EPS-9';
    case 'mtf_beta7':
      return 'B-7';
    default:
      return 'MTF';
  }
};

const teamColor = (key: string): string => {
  switch (key) {
    case 'mtf_nu7':
      return C.redBright;
    case 'mtf_epsilon11':
      return C.amber;
    case 'mtf_epsilon9':
      return '#ff6600';
    case 'mtf_beta7':
      return '#44aa44';
    default:
      return C.text;
  }
};

const DeployConfirmModal = (props: {
  breachCount: number;
  onCancel: () => void;
  onConfirm: () => void;
  team: MTFTeam;
}) => {
  const { team, breachCount, onConfirm, onCancel } = props;
  const meetsRequirement = breachCount >= team.min_breach;

  return (
    <Modal
      style={{
        background: C.bg,
        border: `1px solid ${C.borderRed}`,
        borderRadius: 0,
        fontFamily: C.mono,
        color: C.text,
        padding: '16px',
        maxWidth: '420px',
      }}
    >
      <Box
        style={{
          fontSize: '13px',
          fontWeight: 'bold',
          color: C.amber,
          letterSpacing: '0.12em',
          marginBottom: '10px',
        }}
      >
        CONFIRM DEPLOYMENT
      </Box>
      <Box style={term({ color: C.textBright, marginBottom: '8px' })}>
        Deploy <span style={{ color: teamColor(team.key) }}>{team.name}</span>?
      </Box>
      <Box
        style={term({
          color: C.textDim,
          fontSize: '11px',
          marginBottom: '6px',
        })}
      >
        Team size: {team.size} operatives
      </Box>
      <Box
        style={term({
          color: meetsRequirement ? C.green : C.redBright,
          fontSize: '11px',
          marginBottom: '12px',
        })}
      >
        Breach requirement: {team.min_breach} | Current: {breachCount}{' '}
        {meetsRequirement ? '[MET]' : '[NOT MET]'}
      </Box>
      {!meetsRequirement && (
        <Box
          style={term({
            color: C.redBright,
            fontSize: '10px',
            marginBottom: '10px',
            borderLeft: `2px solid ${C.redBright}`,
            paddingLeft: '8px',
          })}
        >
          WARNING: Insufficient threat level. Deployment may be denied.
        </Box>
      )}
      <Box style={{ display: 'flex', gap: '8px' }}>
        <Button
          style={{
            fontFamily: C.mono,
            fontSize: '11px',
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            background: 'rgba(139,0,0,0.35)',
            border: `1px solid ${C.red}`,
            borderRadius: 0,
            color: C.textBright,
            padding: '4px 14px',
          }}
          onClick={onConfirm}
        >
          Deploy
        </Button>
        <Button
          style={{
            fontFamily: C.mono,
            fontSize: '11px',
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            background: 'transparent',
            border: `1px solid ${C.border}`,
            borderRadius: 0,
            color: C.textDim,
            padding: '4px 14px',
          }}
          onClick={onCancel}
        >
          Cancel
        </Button>
      </Box>
    </Modal>
  );
};

export const MTFDeployment = (_props: unknown) => {
  const { act, data } = useBackend<MTFData>();
  const [confirmTeam, setConfirmTeam] = useLocalState<MTFTeam | null>(
    'confirmTeam',
    null,
  );

  const {
    available_teams = [],
    active_breach_count = 0,
    cooldown_remaining = 0,
    cooldown_total = 0,
    on_cooldown = false,
    last_deployment = '',
  } = data;

  const cooldownPercent =
    cooldown_total > 0 ? (cooldown_remaining / cooldown_total) * 100 : 0;

  const handleDeploy = (team: MTFTeam) => {
    setConfirmTeam(null);
    act('deploy', { team_name: team.key });
  };

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
              SCP FOUNDATION — MTF DEPLOYMENT TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | MOBILE TASK FORCE COMMAND
            </Box>
          </Box>

          <Box style={{ padding: '14px' }}>
            <Box
              style={{
                display: 'flex',
                gap: '12px',
                marginBottom: '12px',
              }}
            >
              <Box
                style={{
                  flex: '1',
                  padding: '8px 10px',
                  border: `1px solid ${active_breach_count > 0 ? C.red : C.border}`,
                  background: C.panel,
                }}
              >
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.12em',
                  }}
                >
                  ACTIVE BREACHES
                </Box>
                <Box
                  style={{
                    fontSize: '22px',
                    color: active_breach_count > 0 ? C.redBright : C.green,
                    fontWeight: 'bold',
                  }}
                >
                  {active_breach_count}
                </Box>
              </Box>
              <Box
                style={{
                  flex: '1',
                  padding: '8px 10px',
                  border: `1px solid ${on_cooldown ? C.amber : C.border}`,
                  background: C.panel,
                }}
              >
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.12em',
                  }}
                >
                  DEPLOY STATUS
                </Box>
                <Box
                  style={{
                    fontSize: '22px',
                    color: on_cooldown ? C.amber : C.green,
                    fontWeight: 'bold',
                  }}
                >
                  {on_cooldown ? 'RECHARGING' : 'READY'}
                </Box>
              </Box>
              <Box
                style={{
                  flex: '1',
                  padding: '8px 10px',
                  border: `1px solid ${C.border}`,
                  background: C.panel,
                }}
              >
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.12em',
                  }}
                >
                  LAST DEPLOYED
                </Box>
                <Box
                  style={{
                    fontSize: '14px',
                    color: last_deployment ? C.textBright : C.textDim,
                    fontWeight: 'bold',
                    marginTop: '4px',
                  }}
                >
                  {last_deployment || 'NONE'}
                </Box>
              </Box>
            </Box>

            {on_cooldown && (
              <Box
                style={{
                  marginBottom: '12px',
                  padding: '6px 10px',
                  borderLeft: `2px solid ${C.amber}`,
                  background: C.panel,
                }}
              >
                <Box
                  style={term({
                    fontSize: '10px',
                    color: C.amber,
                    letterSpacing: '0.1em',
                    marginBottom: '4px',
                  })}
                >
                  SYSTEM RECHARGE IN PROGRESS —{' '}
                  {formatCooldown(cooldown_remaining)} REMAINING
                </Box>
                <Box
                  style={{
                    height: '4px',
                    background: C.panel,
                    border: `1px solid ${C.border}`,
                    position: 'relative',
                    overflow: 'hidden',
                  }}
                >
                  <Box
                    style={{
                      height: '100%',
                      width: `${cooldownPercent}%`,
                      background: C.amber,
                      transition: 'width 1s',
                    }}
                  />
                </Box>
              </Box>
            )}

            <TermDivider />

            <Box
              style={{
                fontSize: '10px',
                color: C.textDim,
                letterSpacing: '0.12em',
                textTransform: 'uppercase',
                borderBottom: `1px solid ${C.border}`,
                paddingBottom: '4px',
                marginBottom: '8px',
              }}
            >
              Available Task Forces
            </Box>

            {available_teams.map((team) => {
              const canDeploy =
                !on_cooldown && active_breach_count >= team.min_breach;
              const color = teamColor(team.key);

              return (
                <Box
                  key={team.key}
                  style={{
                    marginBottom: '8px',
                    padding: '10px',
                    borderLeft: `3px solid ${color}`,
                    background: C.panel,
                    borderRight: `1px solid ${C.border}`,
                    borderTop: `1px solid ${C.border}`,
                    borderBottom: `1px solid ${C.border}`,
                  }}
                >
                  <Box
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'flex-start',
                      marginBottom: '4px',
                    }}
                  >
                    <Box>
                      <Box
                        style={{
                          fontSize: '13px',
                          fontWeight: 'bold',
                          color,
                          letterSpacing: '0.08em',
                        }}
                      >
                        [{teamDesignation(team.key)}] {team.name}
                      </Box>
                      <Box
                        style={term({
                          fontSize: '10px',
                          color: C.textDim,
                          letterSpacing: '0.08em',
                          marginTop: '1px',
                        })}
                      >
                        SPECIALTY: {team.specialty}
                      </Box>
                    </Box>
                    <Box
                      style={{
                        display: 'flex',
                        gap: '4px',
                        alignItems: 'center',
                      }}
                    >
                      <Box
                        style={term({
                          fontSize: '10px',
                          color: C.textDim,
                          marginRight: '6px',
                        })}
                      >
                        SIZE: {team.size}
                      </Box>
                      <Box
                        style={term({
                          fontSize: '10px',
                          color:
                            active_breach_count >= team.min_breach
                              ? C.green
                              : C.redBright,
                          marginRight: '8px',
                        })}
                      >
                        MIN BREACH: {team.min_breach}
                      </Box>
                      {on_cooldown ? (
                        <Button
                          style={{
                            fontFamily: C.mono,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                            textTransform: 'uppercase',
                            background: 'rgba(85,85,96,0.2)',
                            border: `1px solid ${C.border}`,
                            borderRadius: 0,
                            color: C.textDim,
                            padding: '3px 10px',
                            cursor: 'not-allowed',
                            opacity: '0.5',
                          }}
                          disabled
                        >
                          Cooldown
                        </Button>
                      ) : (
                        <Button
                          style={{
                            fontFamily: C.mono,
                            fontSize: '10px',
                            letterSpacing: '0.1em',
                            textTransform: 'uppercase',
                            background: canDeploy
                              ? 'rgba(139,0,0,0.3)'
                              : 'rgba(85,85,96,0.15)',
                            border: `1px solid ${canDeploy ? C.red : C.border}`,
                            borderRadius: 0,
                            color: canDeploy ? C.textBright : C.textDim,
                            padding: '3px 10px',
                          }}
                          onClick={() =>
                            canDeploy
                              ? setConfirmTeam(team)
                              : act('deploy', { team_name: team.key })
                          }
                        >
                          Deploy
                        </Button>
                      )}
                    </Box>
                  </Box>
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '11px',
                      fontStyle: 'italic',
                    })}
                  >
                    {team.desc}
                  </Box>
                </Box>
              );
            })}
          </Box>

          {confirmTeam && (
            <DeployConfirmModal
              team={confirmTeam}
              breachCount={active_breach_count}
              onConfirm={() => handleDeploy(confirmTeam)}
              onCancel={() => setConfirmTeam(null)}
            />
          )}

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '6px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.1em',
                fontFamily: C.mono,
              }}
            >
              SCP FOUNDATION | MTF DEPLOYMENT SYSTEM | CLASSIFIED — LEVEL 5
              CLEARANCE REQUIRED | UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
