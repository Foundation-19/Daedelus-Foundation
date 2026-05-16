import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, Section, Stack } from '../components';
import { Window } from '../layouts';

type ProcedureStep = string;

type SCPProcedure = {
  classification: string;
  containment: ProcedureStep[];
  recontainment: ProcedureStep[];
};

type ChecklistData = {
  breached_scps: string[];
  procedures: Record<string, SCPProcedure>;
};

const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  red: '#8b0000',
  darkRed: '#5c0000',
  amber: '#d4a017',
  green: '#0a6e0a',
  brightGreen: '#44ff44',
  text: '#c8c8c8',
  dim: '#6a6a70',
  highlight: '#e8e8e8',
};

const classificationColor = (cls: string): string => {
  switch (cls?.toLowerCase()) {
    case 'safe':
      return C.green;
    case 'euclid':
      return C.amber;
    case 'keter':
      return C.red;
    default:
      return C.dim;
  }
};

const SCPEntry = (
  props: {
    scpId: string;
    data: SCPProcedure;
    isBreached: BooleanLike;
    checked: Set<string>;
    onToggle: (key: string) => void;
  },
) => {
  const { scpId, data, isBreached, checked, onToggle } = props;
  const [expanded, setExpanded] = useLocalState<boolean>(
    `scp_expand_${scpId}`,
    !!isBreached,
  );

  return (
    <Collapsible
      title={
        <Stack align="center">
          <Stack.Item>
            <Box
              as="span"
              color={isBreached ? C.red : C.brightGreen}
              fontSize="14px"
              fontFamily="monospace"
            >
              {scpId}
            </Box>
          </Stack.Item>
          <Stack.Item pl={1}>
            <Box
              as="span"
              color={classificationColor(data.classification)}
              fontSize="11px"
              fontFamily="monospace"
            >
              [{data.classification?.toUpperCase()}]
            </Box>
          </Stack.Item>
          {!!isBreached && (
            <Stack.Item pl={1}>
              <Box
                as="span"
                color={C.red}
                fontSize="11px"
                fontFamily="monospace"
              >
                BREACHED
              </Box>
            </Stack.Item>
          )}
        </Stack>
      }
      open={expanded}
      onOpen={() => setExpanded(true)}
      onClose={() => setExpanded(false)}
      color={isBreached ? 'red' : 'default'}
    >
      <Box
        backgroundColor={C.panel}
        borderRadius="4px"
        p={1}
        ml={1}
        mr={1}
        mb={1}
        style={{ border: `1px solid ${C.border}` }}
      >
        <Section title="Containment Procedures" fontSize="12px">
          {data.containment?.map((step, i) => {
            const key = `${scpId}_c_${i}`;
            return (
              <Stack key={key} align="center" mb={0.5}>
                <Stack.Item width="20px" textAlign="center">
                  <Button
                    compact
                    color={checked.has(key) ? 'green' : 'default'}
                    icon={checked.has(key) ? 'check-square' : 'square'}
                    onClick={() => onToggle(key)}
                    style={{
                      border: `1px solid ${C.border}`,
                      backgroundColor: checked.has(key)
                        ? C.green
                        : C.panel,
                    }}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Box
                    fontFamily="monospace"
                    fontSize="11px"
                    color={checked.has(key) ? C.dim : C.text}
                    style={{
                      textDecoration: checked.has(key)
                        ? 'line-through'
                        : 'none',
                    }}
                  >
                    {step}
                  </Box>
                </Stack.Item>
              </Stack>
            );
          })}
        </Section>

        <Section
          title="Recontainment Procedures"
          fontSize="12px"
          color={C.amber}
        >
          {data.recontainment?.map((step, i) => {
            const key = `${scpId}_r_${i}`;
            return (
              <Stack key={key} align="center" mb={0.5}>
                <Stack.Item width="20px" textAlign="center">
                  <Button
                    compact
                    color={checked.has(key) ? 'green' : 'default'}
                    icon={checked.has(key) ? 'check-square' : 'square'}
                    onClick={() => onToggle(key)}
                    style={{
                      border: `1px solid ${C.border}`,
                      backgroundColor: checked.has(key)
                        ? C.green
                        : C.panel,
                    }}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Box
                    fontFamily="monospace"
                    fontSize="11px"
                    color={checked.has(key) ? C.dim : C.text}
                    style={{
                      textDecoration: checked.has(key)
                        ? 'line-through'
                        : 'none',
                    }}
                  >
                    {step}
                  </Box>
                </Stack.Item>
              </Stack>
            );
          })}
        </Section>
      </Box>
    </Collapsible>
  );
};

export const ScpContainmentConsole = (_props: unknown) => {
  const { data } = useBackend<ChecklistData>();
  const { procedures, breached_scps = [] } = data;
  const [checked, setChecked] = useLocalState<Set<string>>(
    'checklist_checked',
    new Set(),
  );
  const [filter, setFilter] = useLocalState<string>(
    'checklist_filter',
    'all',
  );

  const toggleCheck = (key: string) => {
    const next = new Set(checked);
    if (next.has(key)) {
      next.delete(key);
    } else {
      next.add(key);
    }
    setChecked(next);
  };

  const breachedSet = new Set(breached_scps);

  const filteredEntries = Object.entries(procedures || {})
    .filter(([scpId]) => {
      if (filter === 'breached') return breachedSet.has(scpId);
      if (filter === 'keter')
        return procedures[scpId]?.classification?.toLowerCase() === 'keter';
      return true;
    })
    .sort(([aId], [bId]) => {
      const aB = breachedSet.has(aId) ? 0 : 1;
      const bB = breachedSet.has(bId) ? 0 : 1;
      if (aB !== bB) return aB - bB;
      return aId.localeCompare(bId);
    });

  return (
    <Window
      width={600}
      height={700}
      theme="scp"
      backgroundColor={C.bg}
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="CONTAINMENT PROCEDURES DATABASE"
              fontSize="14px"
              color={C.highlight}
              style={{
                borderBottom: `2px solid ${C.red}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack>
                <Stack.Item grow>
                  <Box
                    fontFamily="monospace"
                    fontSize="11px"
                    color={C.dim}
                  >
                    SITE-53 STANDARDIZED RECONTAINMENT PROTOCOLS
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button
                        compact
                        content="ALL"
                        selected={filter === 'all'}
                        onClick={() => setFilter('all')}
                        style={{
                          fontFamily: 'monospace',
                          fontSize: '10px',
                        }}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        compact
                        content="BREACHED"
                        selected={filter === 'breached'}
                        color={filter === 'breached' ? 'red' : 'default'}
                        onClick={() => setFilter('breached')}
                        style={{
                          fontFamily: 'monospace',
                          fontSize: '10px',
                        }}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        compact
                        content="KETER"
                        selected={filter === 'keter'}
                        color={filter === 'keter' ? 'red' : 'default'}
                        onClick={() => setFilter('keter')}
                        style={{
                          fontFamily: 'monospace',
                          fontSize: '10px',
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            {filteredEntries.map(([scpId, procData]) => (
              <SCPEntry
                key={scpId}
                scpId={scpId}
                data={procData}
                isBreached={breachedSet.has(scpId)}
                checked={checked}
                onToggle={toggleCheck}
              />
            ))}
            {filteredEntries.length === 0 && (
              <Box
                textAlign="center"
                color={C.dim}
                fontFamily="monospace"
                fontSize="12px"
                mt={4}
              >
                No SCPs match the current filter.
              </Box>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
