import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';

interface APC {
  area_name: string;
  charge: number;
  loading: BooleanLike;
  operating: BooleanLike;
  ref: string;
}

interface Data {
  total_power: number;
  power_capacity: number;
  power_consumption: number;
  apcs: APC[];
  alert_level: string;
}

const getAlertColor = (alert: string) => {
  switch (alert) {
    case 'critical':
      return C.redBright;
    case 'warning':
      return C.amber;
    case 'normal':
      return C.green;
    default:
      return C.textDim;
  }
};

export const FacilityPowerConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const [selectedAPC, setSelectedAPC] = useLocalState('selectedAPC', '');

  const {
    total_power,
    power_capacity,
    power_consumption,
    apcs = [],
    alert_level,
  } = data;

  const powerPercent = power_capacity > 0
    ? Math.round((total_power / power_capacity) * 100)
    : 0;

  const consumptionPercent = power_capacity > 0
    ? Math.round((power_consumption / power_capacity) * 100)
    : 0;

  return (
    <Window width={950} height={650} theme="scp_terminal">
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
              FACILITY POWER GRID
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              POWER DISTRIBUTION MANAGEMENT | GRID STATUS: {alert_level.toUpperCase()}
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>POWER OVERVIEW</TermHeader>
            <TermProgressBar
              label="POWER STORAGE"
              value={total_power}
              maxValue={power_capacity}
              color={powerPercent > 50 ? C.green : powerPercent > 20 ? C.amber : C.redBright}
            />
            <TermRow>
              <TermLabel>STORED</TermLabel>
              <TermValue color={C.amber}>{total_power}</TermValue>
              <TermValue color={C.textDim}>/{power_capacity} kW</TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>CHARGE</TermLabel>
              <TermValue
                color={powerPercent > 50 ? C.green : powerPercent > 20 ? C.amber : C.redBright}
              >
                {powerPercent}%
              </TermValue>
            </TermRow>
            <TermProgressBar
              label="CONSUMPTION"
              value={power_consumption}
              maxValue={power_capacity}
              color={consumptionPercent > 80 ? C.redBright : C.amber}
              suffix=" kW"
            />
            <TermRow>
              <TermLabel>GRID ALERT</TermLabel>
              <TermValue color={getAlertColor(alert_level)}>
                {alert_level.toUpperCase()}
              </TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>AREA POWER CONTROLLERS ({apcs.length})</TermHeader>
            {apcs.length > 0 ? (
              apcs.map((apc) => (
                <Box
                  key={apc.ref}
                  style={{
                    marginBottom: '4px',
                    padding: '8px',
                    borderLeft: `2px solid ${apc.operating ? C.green : C.redBright}`,
                    background: C.panel,
                  }}
                >
                  <TermRow>
                    <TermValue bold color={C.amber}>{apc.area_name}</TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>CHARGE</TermLabel>
                    <TermValue
                      color={
                        apc.charge > 75 ? C.green
                        : apc.charge > 25 ? C.amber
                        : C.redBright
                      }
                    >
                      {apc.charge}%
                    </TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>STATUS</TermLabel>
                    <TermValue color={apc.operating ? C.green : C.redBright}>
                      {apc.operating ? 'ONLINE' : 'OFFLINE'}
                    </TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>LOAD</TermLabel>
                    <TermValue color={apc.loading ? C.amber : C.textDim}>
                      {apc.loading ? 'ACTIVE' : 'IDLE'}
                    </TermValue>
                  </TermRow>
                  <Box style={{ marginTop: '4px' }}>
                    <TermButton
                      color={apc.operating ? 'red' : 'green'}
                      onClick={() => act('toggle_apc', { ref: apc.ref })}
                    >
                      {apc.operating ? 'DISABLE' : 'ENABLE'}
                    </TermButton>
                  </Box>
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO APC DATA AVAILABLE
              </Box>
            )}

            <TermDivider />

            <TermHeader>GRID ACTIONS</TermHeader>
            <Box style={{ display: 'flex', gap: '4px' }}>
              <TermButton color="yellow" onClick={() => act('emergency_power')}>
                EMERGENCY POWER
              </TermButton>
              <TermButton color="red" onClick={() => act('reset_grid')}>
                RESET GRID
              </TermButton>
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
              SCP FOUNDATION | POWER GRID | FACILITY CRITICAL INFRASTRUCTURE
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
