import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, NumberInput } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';

interface RodData {
  slot: string;
  name: string;
  type: number;
}

interface ReactantData {
  name: string;
  amount: number;
}

interface Data {
  core_found: BooleanLike;
  is_on: BooleanLike;
  field_strength: number;
  max_field_strength: number;
  plasma_temperature: number;
  energy: number;
  size: number;
  percent_unstable: number;
  radiation: number;
  reactants: ReactantData[];
  rods: RodData[];
}

const rodTypeNames: Record<number, string> = {
  0: '',
  1: 'FUEL',
  2: 'MODERATOR',
  4: 'CONTROL',
};

export const FusionCoreControl = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    core_found,
    is_on,
    field_strength,
    max_field_strength,
    plasma_temperature,
    energy,
    size,
    percent_unstable,
    radiation,
    reactants = [],
    rods = [],
  } = data;

  const instabilityPct = Math.round(percent_unstable * 100);
  const isDangerous = instabilityPct > 50;

  return (
    <Window width={700} height={600} theme="scp_terminal">
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${isDangerous ? C.redBright : C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${isDangerous ? C.redBright : C.borderRed}`,
              padding: '10px 14px 8px',
              background: isDangerous
                ? 'linear-gradient(180deg, #1a0000 0%, #0a0000 100%)'
                : 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box style={{ fontSize: '15px', fontWeight: 'bold', color: isDangerous ? C.redBright : C.amber, letterSpacing: '0.18em' }}>
              R-UST FUSION CORE CONTROL
            </Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>
              TOKAMAK REACTOR | STATUS: {is_on ? 'ONLINE' : 'OFFLINE'} | SIZE: {size}
            </Box>
          </Box>

          {!core_found && (
            <Box style={{ padding: '16px', color: C.amber }}>
              NO REACTOR CORE DETECTED WITHIN RANGE
            </Box>
          )}

          {core_found && (
            <Box style={{ padding: '16px' }}>
              <TermHeader>FIELD PARAMETERS</TermHeader>
              <TermRow>
                <TermLabel>FIELD STRENGTH</TermLabel>
                <NumberInput
                  value={field_strength}
                  minValue={1}
                  maxValue={max_field_strength || 10000}
                  step={100}
                  onChange={(value) => act('set_strength', { value })}
                />
              </TermRow>
              <TermProgressBar
                label="INSTABILITY"
                value={instabilityPct}
                maxValue={100}
                color={instabilityPct > 70 ? C.redBright : instabilityPct > 40 ? C.amber : C.green}
                suffix="%"
              />
              <TermRow>
                <TermLabel>PLASMA TEMP</TermLabel>
                <TermValue color={plasma_temperature > 50000 ? C.redBright : plasma_temperature > 10000 ? C.amber : C.green}>
                  {Math.round(plasma_temperature)}K
                </TermValue>
              </TermRow>
              <TermRow>
                <TermLabel>ENERGY</TermLabel>
                <TermValue>{Math.round(energy)}</TermValue>
                <TermLabel style={{ marginLeft: '8px' }}>RADIATION</TermLabel>
                <TermValue color={radiation > 100 ? C.redBright : C.amber}>{Math.round(radiation)}</TermValue>
              </TermRow>

              <TermDivider />

              <TermHeader>REACTANTS</TermHeader>
              {reactants.length > 0 ? (
                reactants.map((r, idx) => (
                  <TermRow key={idx}>
                    <TermLabel>{r.name.toUpperCase()}</TermLabel>
                    <TermValue>{Math.round(r.amount)}</TermValue>
                  </TermRow>
                ))
              ) : (
                <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>NO REACTANTS DETECTED</Box>
              )}

              <TermDivider />

              <TermHeader>FUEL RODS</TermHeader>
              {rods.map((rod, idx) => (
                <TermRow key={idx}>
                  <TermLabel>SLOT {rod.slot.toUpperCase()}</TermLabel>
                  <TermValue color={rod.type > 0 ? C.green : C.textDim}>
                    {rod.name}
                  </TermValue>
                  {rod.type > 0 && (
                    <Box style={{ marginLeft: '4px', color: C.amber, fontSize: '9px' }}>
                      [{rodTypeNames[rod.type] || 'UNKNOWN'}]
                    </Box>
                  )}
                  {rod.type > 0 && (
                    <TermButton color="red" onClick={() => act('eject_rod', { slot: rod.slot })}>
                      EJECT
                    </TermButton>
                  )}
                </TermRow>
              ))}

              <TermDivider />

              <TermHeader>REACTOR CONTROLS</TermHeader>
              <Box style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                <TermButton
                  color={is_on ? 'red' : 'green'}
                  selected={!!is_on}
                  onClick={() => act('toggle_core')}
                >
                  {is_on ? 'SHUTDOWN' : 'STARTUP'}
                </TermButton>
                <TermButton color="amber" onClick={() => act('jumpstart')}>
                  JUMPSTART
                </TermButton>
                <TermButton color="red" onClick={() => act('emergency_shutdown')}>
                  EMERGENCY SHUTDOWN
                </TermButton>
              </Box>
            </Box>
          )}

          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={term({ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' })}>
              SCP FOUNDATION | R-UST MK.10 | FUSION CORE CONTROL | AUTHORIZED PERSONNEL ONLY
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
