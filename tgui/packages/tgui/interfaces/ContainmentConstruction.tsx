import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type MaterialData = {
  name: string;
  amount: number;
  provided: number;
};

type Data = {
  chamber_type: string;
  chamber_name: string;
  has_chamber: BooleanLike;
  construction_progress: number;
  construction_stage: string;
  required_materials: MaterialData[];
  scp_id: string;
  scp_class: string;
};

const SCP_CLASS_COLORS: Record<string, string> = {
  safe: '#1a7a1a',
  euclid: '#d4a017',
  keter: '#8b0000',
  thaumiel: '#6a0dad',
  neutralized: '#555560',
};

export const ContainmentConstruction = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    chamber_type,
    chamber_name,
    has_chamber,
    construction_progress,
    construction_stage,
    required_materials,
    scp_id,
    scp_class,
  } = data;

  const classColor = SCP_CLASS_COLORS[(scp_class || '').toLowerCase()] || '#555560';

  return (
    <Window theme="scp_terminal" width={550} height={550}>
      <Window.Content scrollable>
        <Section title="SCP FOUNDATION — CONTAINMENT CONSTRUCTION">
          <Box
            style={{
              fontFamily: 'monospace',
              color: '#d4a017',
              fontSize: '12px',
              marginBottom: '8px',
              padding: '8px',
              background: 'rgba(20,20,25,0.8)',
              border: '1px solid #2a2a30',
            }}
          >
            SPECIAL CONTAINMENT PROTOCOLS — FACILITIES DIVISION
          </Box>
          {scp_id && (
            <Box
              style={{
                fontFamily: 'monospace',
                color: classColor,
                fontSize: '16px',
                fontWeight: 'bold',
                padding: '8px',
                background: 'rgba(20,20,25,0.8)',
                border: `1px solid ${classColor}`,
                marginBottom: '8px',
              }}
            >
              {scp_id} — CLASS: {(scp_class || 'UNKNOWN').toUpperCase()}
            </Box>
          )}
        </Section>
        {has_chamber ? (
          <>
            <Section title="CHAMBER STATUS">
              <LabeledList>
                <LabeledList.Item label="Chamber">
                  <Box style={{ color: '#d4a017', fontFamily: 'monospace', fontWeight: 'bold' }}>
                    {chamber_name || chamber_type || 'UNKNOWN'}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Stage">
                  <Box style={{ color: '#c8c8c8', fontFamily: 'monospace' }}>
                    {(construction_stage || 'UNKNOWN').toUpperCase()}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Progress">
                  <Box style={{ color: construction_progress >= 100 ? '#1a7a1a' : '#d4a017', fontFamily: 'monospace', fontWeight: 'bold' }}>
                    {construction_progress.toFixed(1)}%
                  </Box>
                  <Box
                    style={{
                      background: 'rgba(20,20,25,0.8)',
                      border: '1px solid #2a2a30',
                      height: '12px',
                      marginTop: '4px',
                      position: 'relative',
                    }}
                  >
                    <Box
                      style={{
                        background: construction_progress >= 100 ? '#1a7a1a' : '#d4a017',
                        height: '100%',
                        width: `${Math.min(construction_progress, 100)}%`,
                      }}
                    />
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="REQUIRED MATERIALS">
              <Box
                style={{
                  background: 'rgba(20,20,25,0.8)',
                  border: '1px solid #2a2a30',
                  padding: '8px',
                  fontFamily: 'monospace',
                }}
              >
                {required_materials && required_materials.length > 0 ? (
                  required_materials.map((mat, index) => (
                    <Box
                      key={index}
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        padding: '4px 0',
                        borderBottom: index < required_materials.length - 1 ? '1px solid #2a2a30' : 'none',
                      }}
                    >
                      <Box style={{ color: mat.provided >= mat.amount ? '#1a7a1a' : '#c8c8c8' }}>
                        {mat.name}
                      </Box>
                      <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                        <Box style={{ color: mat.provided >= mat.amount ? '#1a7a1a' : '#d4a017' }}>
                          {mat.provided}/{mat.amount}
                        </Box>
                        {mat.provided < mat.amount && (
                          <Button
                            onClick={() => act('add_material', { material: mat.name })}
                            style={{
                              fontFamily: 'monospace',
                              background: 'rgba(26,122,26,0.3)',
                              border: '1px solid #1a7a1a',
                              color: '#44ff44',
                              padding: '2px 8px',
                              fontSize: '11px',
                            }}
                          >
                            ADD
                          </Button>
                        )}
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box style={{ color: '#555560' }}>NO MATERIALS REQUIRED</Box>
                )}
              </Box>
            </Section>
            <Section title="ACTIONS">
              <Button
                onClick={() => act('cancel_construction')}
                style={{
                  fontFamily: 'monospace',
                  background: 'rgba(139,0,0,0.3)',
                  border: '1px solid #8b0000',
                  color: '#cc2222',
                  padding: '6px 12px',
                }}
              >
                CANCEL CONSTRUCTION
              </Button>
            </Section>
          </>
        ) : (
          <Section title="BUILD CHAMBER">
            <Box style={{ color: '#555560', fontFamily: 'monospace', marginBottom: '8px' }}>
              NO CHAMBER SELECTED — SELECT A CHAMBER TYPE TO BEGIN CONSTRUCTION
            </Box>
            <Box style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
              {['standard', 'humanoid', 'large', 'aquatic', 'hazardous'].map((type) => (
                <Button
                  key={type}
                  onClick={() => act('build_chamber', { type })}
                  style={{
                    fontFamily: 'monospace',
                    background: 'rgba(20,20,25,0.8)',
                    border: '1px solid #2a2a30',
                    color: '#d4a017',
                    padding: '6px 12px',
                  }}
                >
                  {type.toUpperCase()}
                </Button>
              ))}
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
