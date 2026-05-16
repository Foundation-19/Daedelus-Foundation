import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, NumberInput } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';

interface SafetySystem {
  name: string;
  active: BooleanLike;
}

interface Data {
  reactor_active: BooleanLike;
  core_temperature: number;
  critical_temperature: number;
  coolant_level: number;
  power_output: number;
  meltdown_timer: number;
  safety_systems: SafetySystem[];
  control_rod_position: number;
}

export const ReactorControl = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    reactor_active,
    core_temperature,
    critical_temperature,
    coolant_level,
    power_output,
    meltdown_timer,
    safety_systems = [],
    control_rod_position,
  } = data;

  const tempPercent = critical_temperature > 0
    ? Math.round((core_temperature / critical_temperature) * 100)
    : 0;

  const isCritical = core_temperature > critical_temperature * 0.8;
  const isMeltdown = meltdown_timer > 0;

  return (
    <Window width={800} height={650} theme="scp_terminal">
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${isMeltdown ? C.redBright : C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${isMeltdown ? C.redBright : C.borderRed}`,
              padding: '10px 14px 8px',
              background: isMeltdown
                ? 'linear-gradient(180deg, #1a0000 0%, #0a0000 100%)'
                : 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: isMeltdown ? C.redBright : C.amber,
                letterSpacing: '0.18em',
              }}
            >
              FOUNDATION REACTOR CONTROL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SITE POWER REACTOR | STATUS: {reactor_active ? 'ONLINE' : 'OFFLINE'}
              {isMeltdown && ' | MELTDOWN IMMINENT'}
            </Box>
          </Box>

          {isMeltdown && (
            <Box
              style={{
                padding: '8px 16px',
                background: 'rgba(139,0,0,0.3)',
                borderBottom: `1px solid ${C.redBright}`,
              }}
            >
              <TermRow>
                <TermLabel>MELTDOWN IN</TermLabel>
                <TermValue bold color={C.redBright}>{meltdown_timer}s</TermValue>
              </TermRow>
            </Box>
          )}

          <Box style={{ padding: '16px' }}>
            <TermHeader>REACTOR STATUS</TermHeader>
            <TermProgressBar
              label="CORE TEMPERATURE"
              value={core_temperature}
              maxValue={critical_temperature}
              color={tempPercent > 80 ? C.redBright : tempPercent > 50 ? C.amber : C.green}
            />
            <TermRow>
              <TermLabel>TEMPERATURE</TermLabel>
              <TermValue
                color={tempPercent > 80 ? C.redBright : tempPercent > 50 ? C.amber : C.green}
              >
                {core_temperature}K
              </TermValue>
              <TermLabel style={{ marginLeft: '8px' }}>CRITICAL</TermLabel>
              <TermValue color={C.redBright}>{critical_temperature}K</TermValue>
            </TermRow>
            <TermProgressBar
              label="COOLANT LEVEL"
              value={coolant_level}
              maxValue={100}
              color={coolant_level > 50 ? C.green : coolant_level > 20 ? C.amber : C.redBright}
              suffix="%"
            />
            <TermRow>
              <TermLabel>POWER OUTPUT</TermLabel>
              <TermValue bold color={C.amber}>{power_output} MW</TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>CONTROL RODS</TermHeader>
            <TermProgressBar
              label="ROD POSITION"
              value={control_rod_position}
              maxValue={100}
              color={control_rod_position < 30 ? C.redBright : C.amber}
              suffix="%"
            />
            <TermRow>
              <TermLabel>INSERTION</TermLabel>
              <NumberInput
                value={control_rod_position}
                minValue={0}
                maxValue={100}
                step={5}
                onChange={(value) => act('adjust_rods', { position: value })}
              />
              <TermLabel style={{ marginLeft: '4px' }}>%</TermLabel>
            </TermRow>

            <TermDivider />

            <TermHeader>COOLANT CONTROL</TermHeader>
            <TermRow>
              <TermLabel>SET COOLANT</TermLabel>
              <NumberInput
                value={coolant_level}
                minValue={0}
                maxValue={100}
                step={5}
                onChange={(value) => act('set_coolant', { level: value })}
              />
              <TermLabel style={{ marginLeft: '4px' }}>%</TermLabel>
            </TermRow>

            <TermDivider />

            <TermHeader>SAFETY SYSTEMS</TermHeader>
            {safety_systems.length > 0 ? (
              safety_systems.map((system, idx) => (
                <TermRow key={idx}>
                  <TermValue color={system.active ? C.green : C.redBright}>
                    {system.active ? '●' : '○'}
                  </TermValue>
                  <TermLabel style={{ marginLeft: '8px' }}>{system.name}</TermLabel>
                  <TermValue color={system.active ? C.green : C.redBright}>
                    {system.active ? 'ACTIVE' : 'OFFLINE'}
                  </TermValue>
                </TermRow>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO SAFETY SYSTEMS DATA
              </Box>
            )}

            <TermDivider />

            <TermHeader>REACTOR CONTROLS</TermHeader>
            <Box style={{ display: 'flex', gap: '4px' }}>
              <TermButton
                color={reactor_active ? 'red' : 'green'}
                selected={!!reactor_active}
                onClick={() => act('toggle_reactor')}
              >
                {reactor_active ? 'SHUTDOWN REACTOR' : 'START REACTOR'}
              </TermButton>
              <TermButton
                color="red"
                onClick={() => act('emergency_shutdown')}
              >
                EMERGENCY SHUTDOWN
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
              SCP FOUNDATION | REACTOR CONTROL | RADIATION HAZARD | AUTHORIZED PERSONNEL ONLY
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
