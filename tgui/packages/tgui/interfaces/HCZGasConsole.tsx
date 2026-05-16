import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

type GasData = {
  gasActive: BooleanLike;
  gasType: number;
  gasTypeName: string;
  gasRemaining: number;
  maxGas: number;
  ventCooldown: BooleanLike;
  affectedAreaCount: number;
  hasAccess: BooleanLike;
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  blue: '#4488cc',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const GAS_COLORS: Record<number, string> = {
  0: C.textDim,
  1: C.amber,
  2: C.blue,
  3: C.redBright,
};

const GAS_NAMES: Record<number, string> = {
  0: 'NONE',
  1: 'SLEEPING AGENT',
  2: 'FIRE SUPPRESSANT',
  3: 'NEUROTOXIN',
};

export const HCZGasConsole = (props) => {
  const { act, data } = useBackend<GasData>();
  const {
    gasActive,
    gasType,
    gasTypeName,
    gasRemaining,
    maxGas,
    ventCooldown,
    affectedAreaCount,
    hasAccess,
  } = data;
  const [selectedGas, setSelectedGas] = useState<number | null>(null);

  const gasPercent = maxGas > 0 ? Math.round((gasRemaining / maxGas) * 100) : 0;
  const barColor =
    gasPercent > 60 ? C.greenBright : gasPercent > 30 ? C.amber : C.redBright;

  return (
    <Window theme="scp_terminal" width={500} height={500}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            padding: '8px',
          }}
        >
          {/* Header */}
          <Box
            textAlign="center"
            py={1}
            style={{
              borderBottom: `1px solid ${C.borderRed}`,
              marginBottom: '8px',
            }}
          >
            <Box
              color={C.textDim}
              style={{ fontSize: '10px', letterSpacing: '3px' }}
            >
              SCP FOUNDATION — HCZ GAS CONTROL
            </Box>
            <Box mt={0.5}>
              <Box
                inline
                px={2}
                py={0.5}
                style={{
                  background: gasActive ? C.red : C.green,
                  border: `1px solid ${gasActive ? C.redBright : C.greenBright}`,
                  borderRadius: '2px',
                  color: '#fff',
                  fontSize: '14px',
                  fontWeight: 'bold',
                  letterSpacing: '2px',
                }}
              >
                {gasActive ? 'GAS ACTIVE' : 'STANDBY'}
              </Box>
            </Box>
          </Box>

          {!hasAccess && (
            <Box
              textAlign="center"
              py={2}
              color={C.redBright}
              style={{ fontSize: '11px' }}
            >
              ACCESS DENIED — Command authorization required
            </Box>
          )}

          {!!hasAccess && (
            <>
              {/* Current Status */}
              <Box
                px={2}
                py={1}
                mb={1}
                style={{
                  background: C.panel,
                  border: `1px solid ${C.border}`,
                }}
              >
                <Box
                  color={C.amber}
                  bold
                  style={{ fontSize: '11px', letterSpacing: '1px' }}
                >
                  CURRENT STATUS
                </Box>
                <Box mt={0.5} color={C.text} style={{ fontSize: '11px' }}>
                  Gas Type:{' '}
                  <Box
                    inline
                    color={GAS_COLORS[gasType] || C.textDim}
                    bold
                  >
                    {gasTypeName?.toUpperCase() || 'NONE'}
                  </Box>
                </Box>
                <Box color={C.text} style={{ fontSize: '11px' }}>
                  Affected Zones: {affectedAreaCount}
                </Box>
                {/* Gas Level Bar */}
                <Box mt={0.5}>
                  <Box color={C.textDim} style={{ fontSize: '10px' }}>
                    GAS RESERVE: {gasPercent}%
                  </Box>
                  <Box
                    style={{
                      background: C.bg,
                      border: `1px solid ${C.border}`,
                      height: '8px',
                      marginTop: '2px',
                    }}
                  >
                    <Box
                      style={{
                        background: barColor,
                        width: `${gasPercent}%`,
                        height: '100%',
                      }}
                    />
                  </Box>
                </Box>
              </Box>

              {/* Gas Selection */}
              {!gasActive && (
                <Box
                  px={2}
                  py={1}
                  mb={1}
                  style={{
                    background: C.panel,
                    border: `1px solid ${C.border}`,
                  }}
                >
                  <Box
                    color={C.amber}
                    bold
                    style={{ fontSize: '11px', letterSpacing: '1px' }}
                  >
                    SELECT GAS AGENT
                  </Box>
                  <Box mt={0.5}>
                    {[1, 2, 3].map((type) => (
                      <Button
                        key={type}
                        fluid
                        disabled={gasActive}
                        onClick={() => setSelectedGas(type)}
                        style={{
                          background:
                            selectedGas === type
                              ? GAS_COLORS[type]
                              : C.bg,
                          borderColor: GAS_COLORS[type],
                          color: '#ccc',
                          fontFamily: C.mono,
                          fontSize: '11px',
                          marginBottom: '2px',
                          textAlign: 'left',
                        }}
                        content={`${GAS_NAMES[type]}`}
                      />
                    ))}
                  </Box>
                  {selectedGas !== null && (
                    <Button
                      mt={0.5}
                      fluid
                      disabled={ventCooldown}
                      onClick={() => act('releaseGas', { gasType: selectedGas })}
                      style={{
                        background: C.red,
                        border: '1px solid #cc0000',
                        color: '#fff',
                        fontFamily: C.mono,
                        fontSize: '12px',
                        fontWeight: 'bold',
                        letterSpacing: '1px',
                      }}
                      content={`RELEASE ${GAS_NAMES[selectedGas]}`}
                    />
                  )}
                </Box>
              )}

              {/* Stop Gas */}
              {!!gasActive && (
                <Button
                  fluid
                  onClick={() => act('stopGas')}
                  style={{
                    background: C.red,
                    border: `1px solid ${C.redBright}`,
                    color: '#fff',
                    fontFamily: C.mono,
                    fontSize: '13px',
                    fontWeight: 'bold',
                    letterSpacing: '1px',
                  }}
                  content="■ TERMINATE GAS RELEASE"
                />
              )}

              {ventCooldown && !gasActive && (
                <Box
                  textAlign="center"
                  color={C.amber}
                  mt={1}
                  style={{ fontSize: '10px' }}
                >
                  VENT COOLDOWN ACTIVE
                </Box>
              )}
            </>
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};
