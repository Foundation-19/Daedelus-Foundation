import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, NumberInput } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton } from './CharacterSetup/shared';

interface InjectorData {
  ref: string;
  name: string;
  active: BooleanLike;
  inject_rate: number;
}

interface ReactantData {
  name: string;
  amount: number;
}

interface Data {
  injectors: InjectorData[];
  core_found: BooleanLike;
  reactants: ReactantData[];
  plasma_temperature: number;
}

export const FusionFuelControl = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    injectors = [],
    core_found,
    reactants = [],
    plasma_temperature,
  } = data;

  return (
    <Window width={600} height={500} theme="scp_terminal">
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
              borderBottom: '2px solid ' + C.borderRed,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box style={{ fontSize: '15px', fontWeight: 'bold', color: C.amber, letterSpacing: '0.18em' }}>
              FUSION FUEL CONTROL
            </Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>
              FUEL INJECTION SYSTEM | CORE: {core_found ? 'DETECTED' : 'NOT FOUND'}
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>FUEL INJECTORS</TermHeader>
            {injectors.length > 0 ? (
              injectors.map((inj, idx) => (
                <Box key={idx}>
                  <TermRow>
                    <TermLabel>{inj.name.toUpperCase()}</TermLabel>
                    <TermValue color={inj.active ? C.green : C.redBright}>
                      {inj.active ? 'ACTIVE' : 'OFFLINE'}
                    </TermValue>
                    <TermButton
                      color={inj.active ? 'red' : 'green'}
                      onClick={() => act('toggle_injector', { ref: inj.ref })}
                    >
                      {inj.active ? 'DISABLE' : 'ENABLE'}
                    </TermButton>
                  </TermRow>
                  <TermRow>
                    <TermLabel>INJECT RATE</TermLabel>
                    <NumberInput
                      value={inj.inject_rate}
                      minValue={1}
                      maxValue={50}
                      step={1}
                      onChange={(value) => act('set_rate', { ref: inj.ref, rate: value })}
                    />
                    <TermLabel style={{ marginLeft: '4px' }}>mol/cycle</TermLabel>
                  </TermRow>
                  {idx < injectors.length - 1 && <Box style={{ height: '8px' }} />}
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>NO INJECTORS DETECTED</Box>
            )}

            <TermDivider />

            <TermHeader>REACTOR CONTENTS</TermHeader>
            {core_found ? (
              <>
                <TermRow>
                  <TermLabel>PLASMA TEMP</TermLabel>
                  <TermValue color={plasma_temperature > 50000 ? C.redBright : C.amber}>
                    {Math.round(plasma_temperature)}K
                  </TermValue>
                </TermRow>
                {reactants.length > 0 ? (
                  reactants.map((r, idx) => (
                    <TermRow key={idx}>
                      <TermLabel>{r.name.toUpperCase()}</TermLabel>
                      <TermValue>{Math.round(r.amount)}</TermValue>
                    </TermRow>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>NO REACTANTS</Box>
                )}
              </>
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>NO CORE DETECTED</Box>
            )}
          </Box>

          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={term({ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' })}>
              SCP FOUNDATION | FUEL CONTROL | FUSION INJECTION SYSTEM
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
