import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, NumberInput } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton } from './CharacterSetup/shared';

interface GyrotronData {
  ref: string;
  name: string;
  active: BooleanLike;
  energy: number;
  fire_delay: number;
}

interface Data {
  gyrotrons: GyrotronData[];
  core_found: BooleanLike;
  plasma_temperature: number;
  percent_unstable: number;
}

export const FusionGyroControl = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    gyrotrons = [],
    core_found,
    plasma_temperature,
    percent_unstable,
  } = data;

  const instabilityPct = Math.round(percent_unstable * 100);

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
              GYROTRON CONTROL
            </Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>
              MICROWAVE ENERGY INJECTION | CORE: {core_found ? 'DETECTED' : 'NOT FOUND'}
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            {core_found && (
              <>
                <TermHeader>FIELD STATUS</TermHeader>
                <TermRow>
                  <TermLabel>PLASMA TEMP</TermLabel>
                  <TermValue color={plasma_temperature > 50000 ? C.redBright : C.amber}>
                    {Math.round(plasma_temperature)}K
                  </TermValue>
                </TermRow>
                <TermRow>
                  <TermLabel>INSTABILITY</TermLabel>
                  <TermValue color={instabilityPct > 50 ? C.redBright : C.amber}>
                    {instabilityPct}%
                  </TermValue>
                </TermRow>
                <TermDivider />
              </>
            )}

            <TermHeader>GYROTRON EMITTERS</TermHeader>
            {gyrotrons.length > 0 ? (
              gyrotrons.map((gyro, idx) => (
                <Box key={idx}>
                  <TermRow>
                    <TermLabel>{gyro.name.toUpperCase()}</TermLabel>
                    <TermValue color={gyro.active ? C.green : C.redBright}>
                      {gyro.active ? 'FIRING' : 'STANDBY'}
                    </TermValue>
                    <TermButton
                      color={gyro.active ? 'red' : 'green'}
                      onClick={() => act('toggle_gyrotron', { ref: gyro.ref })}
                    >
                      {gyro.active ? 'DISABLE' : 'ENABLE'}
                    </TermButton>
                  </TermRow>
                  <TermRow>
                    <TermLabel>ENERGY</TermLabel>
                    <NumberInput
                      value={gyro.energy}
                      minValue={0}
                      maxValue={50}
                      step={1}
                      onChange={(value) => act('set_energy', { ref: gyro.ref, value })}
                    />
                    <TermLabel style={{ marginLeft: '4px' }}>MeV</TermLabel>
                  </TermRow>
                  {idx < gyrotrons.length - 1 && <Box style={{ height: '8px' }} />}
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>NO GYROTRONS DETECTED</Box>
            )}
          </Box>

          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={term({ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' })}>
              SCP FOUNDATION | GYROTRON CONTROL | MICROWAVE EMISSION SYSTEM
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
