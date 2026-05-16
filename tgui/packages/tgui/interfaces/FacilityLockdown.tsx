import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Input, Modal } from '../components';
import { Window } from '../layouts';

type FacilityLockdownData = {
  blast_doors_closed: BooleanLike;
  comms_jammed: BooleanLike;
  elevators_disabled: BooleanLike;
  lockdown_duration: number;
  lockdown_reason: string;
  lockdown_start_time: number;
  lockdown_state: number;
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

const formatDuration = (deciseconds: number): string => {
  if (deciseconds <= 0) return 'N/A';
  const totalSeconds = Math.floor(deciseconds / 10);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  if (hours > 0) {
    return `${hours}H ${String(minutes).padStart(2, '0')}M ${String(seconds).padStart(2, '0')}S`;
  }
  return `${minutes}M ${String(seconds).padStart(2, '0')}S`;
};

const getStatusColor = (state: number): string => {
  switch (state) {
    case 2:
      return C.redBright;
    case 1:
      return C.amber;
    default:
      return C.green;
  }
};

const getStatusLabel = (state: number): string => {
  switch (state) {
    case 2:
      return 'FULL LOCKDOWN';
    case 1:
      return 'PARTIAL LOCKDOWN';
    default:
      return 'NOMINAL';
  }
};

const getStatusGlow = (state: number): string => {
  switch (state) {
    case 2:
      return `0 0 12px ${C.redBright}66`;
    case 1:
      return `0 0 12px ${C.amber}66`;
    default:
      return `0 0 12px ${C.green}66`;
  }
};

const SystemStatusCard = (props: {
  active: boolean;
  activeLabel: string;
  icon: string;
  inactiveLabel: string;
  label: string;
}) => {
  const { label, active, activeLabel, inactiveLabel, icon } = props;
  return (
    <Box
      style={{
        flex: '1',
        minWidth: '130px',
        padding: '10px',
        background: C.panel,
        border: `1px solid ${active ? C.borderRed : C.border}`,
        borderLeft: `3px solid ${active ? C.redBright : C.green}`,
      }}
    >
      <Box
        style={term({
          fontSize: '9px',
          color: C.textDim,
          letterSpacing: '0.12em',
          textTransform: 'uppercase',
          marginBottom: '6px',
        })}
      >
        {icon} {label}
      </Box>
      <Box
        style={term({
          fontSize: '13px',
          fontWeight: 'bold',
          color: active ? C.redBright : C.green,
          letterSpacing: '0.08em',
        })}
      >
        {active ? activeLabel : inactiveLabel}
      </Box>
    </Box>
  );
};

const LockdownReasonModal = (props: {
  level: number;
  onClose: () => void;
  onConfirm: (level: number, reason: string) => void;
}) => {
  const { level, onClose, onConfirm } = props;
  const [reason, setReason] = useState('');

  return (
    <Modal
      style={{
        background: C.bg,
        border: `1px solid ${C.borderRed}`,
        borderRadius: 0,
        fontFamily: C.mono,
        color: C.text,
        padding: '20px',
        width: '400px',
      }}
    >
      <Box
        style={term({
          fontSize: '13px',
          fontWeight: 'bold',
          color: C.redBright,
          letterSpacing: '0.12em',
          marginBottom: '12px',
        })}
      >
        {level === 2 ? 'INITIATE FULL LOCKDOWN' : 'INITIATE PARTIAL LOCKDOWN'}
      </Box>
      <Box
        style={term({
          fontSize: '11px',
          color: C.textDim,
          marginBottom: '12px',
        })}
      >
        ENTER REASON FOR LOCKDOWN PROTOCOL:
      </Box>
      <Input
        value={reason}
        onChange={(_e, value) => setReason(value)}
        placeholder="Unspecified security concern"
        style={{
          fontFamily: C.mono,
          fontSize: '12px',
          width: '100%',
          marginBottom: '14px',
        }}
      />
      <Box style={{ display: 'flex', gap: '6px' }}>
        <Button
          style={{
            fontFamily: C.mono,
            fontSize: '10px',
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            background: 'rgba(139,0,0,0.35)',
            border: `1px solid ${C.red}`,
            borderRadius: 0,
            color: C.textBright,
            padding: '5px 14px',
          }}
          onClick={() =>
            onConfirm(level, reason || 'Unspecified security concern')
          }
        >
          CONFIRM
        </Button>
        <Button
          style={{
            fontFamily: C.mono,
            fontSize: '10px',
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            background: 'transparent',
            border: `1px solid ${C.border}`,
            borderRadius: 0,
            color: C.textDim,
            padding: '5px 14px',
          }}
          onClick={onClose}
        >
          CANCEL
        </Button>
      </Box>
    </Modal>
  );
};

export const FacilityLockdown = (_props: unknown) => {
  const { act, data } = useBackend<FacilityLockdownData>();
  const {
    lockdown_state = 0,
    lockdown_reason = '',
    lockdown_duration = 0,
    comms_jammed = false,
    elevators_disabled = false,
    blast_doors_closed = false,
  } = data;

  const [showReasonModal, setShowReasonModal] = useState(false);
  const [pendingLevel, setPendingLevel] = useState(0);

  const handleLockdown = (level: number) => {
    setPendingLevel(level);
    setShowReasonModal(true);
  };

  const handleConfirmLockdown = (level: number, reason: string) => {
    act('lockdown', { level, reason });
    setShowReasonModal(false);
  };

  const handleLiftLockdown = () => {
    act('lift_lockdown');
  };

  const statusColor = getStatusColor(lockdown_state);
  const statusLabel = getStatusLabel(lockdown_state);
  const statusGlow = getStatusGlow(lockdown_state);
  const isActive = lockdown_state > 0;

  return (
    <Window theme="scp_terminal" width={650} height={550}>
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
              SCP FOUNDATION — FACILITY LOCKDOWN CONTROL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | FACILITY SECURITY
            </Box>
          </Box>

          <Box style={{ padding: '14px' }}>
            <Box
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '12px',
                background: C.panel,
                border: `1px solid ${isActive ? C.borderRed : C.border}`,
                marginBottom: '14px',
              }}
            >
              <Box
                style={{
                  width: '14px',
                  height: '14px',
                  borderRadius: '50%',
                  background: statusColor,
                  boxShadow: statusGlow,
                  flexShrink: 0,
                }}
              />
              <Box style={{ flex: '1' }}>
                <Box
                  style={term({
                    fontSize: '9px',
                    color: C.textDim,
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                  })}
                >
                  LOCKDOWN STATUS
                </Box>
                <Box
                  style={term({
                    fontSize: '16px',
                    fontWeight: 'bold',
                    color: statusColor,
                    letterSpacing: '0.1em',
                    textShadow: statusGlow,
                  })}
                >
                  {statusLabel}
                </Box>
              </Box>
              {isActive && (
                <Box
                  style={term({
                    fontSize: '11px',
                    color: C.textDim,
                    textAlign: 'right',
                  })}
                >
                  DURATION:{' '}
                  <Box as="span" style={{ color: C.textBright }}>
                    {formatDuration(lockdown_duration)}
                  </Box>
                </Box>
              )}
            </Box>

            {isActive && (
              <Box
                style={{
                  padding: '10px 12px',
                  background: C.panel,
                  border: `1px solid ${C.border}`,
                  borderLeft: `3px solid ${statusColor}`,
                  marginBottom: '14px',
                }}
              >
                <Box
                  style={term({
                    fontSize: '9px',
                    color: C.textDim,
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    marginBottom: '4px',
                  })}
                >
                  LOCKDOWN REASON
                </Box>
                <Box
                  style={term({
                    fontSize: '12px',
                    color: C.textBright,
                    fontStyle: lockdown_reason ? undefined : 'italic',
                  })}
                >
                  {lockdown_reason || 'No reason specified'}
                </Box>
                {lockdown_state === 1 && (
                  <Box
                    style={term({
                      fontSize: '10px',
                      color: C.amber,
                      marginTop: '6px',
                    })}
                  >
                    ▸ BLAST DOORS SEALED — D-CLASS AREAS LOCKED
                  </Box>
                )}
                {lockdown_state === 2 && (
                  <Box
                    style={term({
                      fontSize: '10px',
                      color: C.redBright,
                      marginTop: '6px',
                    })}
                  >
                    ▸ ALL SYSTEMS LOCKED — FULL FACILITY CONTAINMENT
                  </Box>
                )}
              </Box>
            )}

            <Box
              style={term({
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                textTransform: 'uppercase',
                borderBottom: `1px solid ${C.border}`,
                paddingBottom: '4px',
                marginBottom: '10px',
              })}
            >
              SUBSYSTEM STATUS
            </Box>

            <Box
              style={{
                display: 'flex',
                gap: '8px',
                marginBottom: '16px',
                flexWrap: 'wrap',
              }}
            >
              <SystemStatusCard
                label="BLAST DOORS"
                active={!!blast_doors_closed}
                activeLabel="SEALED"
                inactiveLabel="OPEN"
                icon="║"
              />
              <SystemStatusCard
                label="D-CLASS SECTOR"
                active={!!blast_doors_closed}
                activeLabel="LOCKED"
                inactiveLabel="NORMAL"
                icon="⟐"
              />
              <SystemStatusCard
                label="ELEVATORS"
                active={!!elevators_disabled}
                activeLabel="DISABLED"
                inactiveLabel="OPERATIONAL"
                icon="↕"
              />
              <SystemStatusCard
                label="COMMUNICATIONS"
                active={!!comms_jammed}
                activeLabel="JAMMED"
                inactiveLabel="NORMAL"
                icon="◈"
              />
            </Box>

            <Box
              style={{
                fontSize: '10px',
                color: C.borderRed,
                letterSpacing: '0.3em',
                margin: '10px 0',
                userSelect: 'none',
                overflow: 'hidden',
                whiteSpace: 'nowrap',
              }}
            >
              {'─'.repeat(80)}
            </Box>

            <Box
              style={term({
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                textTransform: 'uppercase',
                borderBottom: `1px solid ${C.border}`,
                paddingBottom: '4px',
                marginBottom: '10px',
              })}
            >
              LOCKDOWN PROTOCOLS
            </Box>

            <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
              {lockdown_state === 0 && (
                <>
                  <Button
                    style={{
                      fontFamily: C.mono,
                      fontSize: '12px',
                      fontWeight: 'bold',
                      letterSpacing: '0.1em',
                      textTransform: 'uppercase',
                      background: 'rgba(212,160,23,0.15)',
                      border: `2px solid ${C.amber}`,
                      borderRadius: 0,
                      color: C.amber,
                      padding: '10px 18px',
                      boxShadow: `0 0 10px ${C.amber}33`,
                      flex: '1',
                      textAlign: 'center',
                    }}
                    onClick={() => handleLockdown(1)}
                  >
                    INITIATE PARTIAL LOCKDOWN
                  </Button>
                  <Button
                    style={{
                      fontFamily: C.mono,
                      fontSize: '12px',
                      fontWeight: 'bold',
                      letterSpacing: '0.1em',
                      textTransform: 'uppercase',
                      background: 'rgba(139,0,0,0.2)',
                      border: `2px solid ${C.redBright}`,
                      borderRadius: 0,
                      color: C.redBright,
                      padding: '10px 18px',
                      boxShadow: `0 0 10px ${C.redBright}33`,
                      flex: '1',
                      textAlign: 'center',
                    }}
                    onClick={() => handleLockdown(2)}
                  >
                    INITIATE FULL LOCKDOWN
                  </Button>
                </>
              )}
              {lockdown_state === 1 && (
                <>
                  <Button
                    style={{
                      fontFamily: C.mono,
                      fontSize: '12px',
                      fontWeight: 'bold',
                      letterSpacing: '0.1em',
                      textTransform: 'uppercase',
                      background: 'rgba(139,0,0,0.2)',
                      border: `2px solid ${C.redBright}`,
                      borderRadius: 0,
                      color: C.redBright,
                      padding: '10px 18px',
                      boxShadow: `0 0 10px ${C.redBright}33`,
                      flex: '1',
                      textAlign: 'center',
                    }}
                    onClick={() => handleLockdown(2)}
                  >
                    ESCALATE TO FULL LOCKDOWN
                  </Button>
                  <Button
                    style={{
                      fontFamily: C.mono,
                      fontSize: '12px',
                      fontWeight: 'bold',
                      letterSpacing: '0.1em',
                      textTransform: 'uppercase',
                      background: 'rgba(26,122,26,0.15)',
                      border: `2px solid ${C.green}`,
                      borderRadius: 0,
                      color: C.green,
                      padding: '10px 18px',
                      boxShadow: `0 0 10px ${C.green}33`,
                      flex: '1',
                      textAlign: 'center',
                    }}
                    onClick={handleLiftLockdown}
                  >
                    LIFT LOCKDOWN
                  </Button>
                </>
              )}
              {lockdown_state === 2 && (
                <Button
                  style={{
                    fontFamily: C.mono,
                    fontSize: '12px',
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    textTransform: 'uppercase',
                    background: 'rgba(26,122,26,0.15)',
                    border: `2px solid ${C.green}`,
                    borderRadius: 0,
                    color: C.green,
                    padding: '10px 18px',
                    boxShadow: `0 0 10px ${C.green}33`,
                    width: '100%',
                    textAlign: 'center',
                  }}
                  onClick={handleLiftLockdown}
                >
                  LIFT LOCKDOWN
                </Button>
              )}
            </Box>
          </Box>

          {showReasonModal && (
            <LockdownReasonModal
              level={pendingLevel}
              onClose={() => setShowReasonModal(false)}
              onConfirm={handleConfirmLockdown}
            />
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
              SCP FOUNDATION | CLASSIFIED | ALL LOCKDOWN ACTIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
