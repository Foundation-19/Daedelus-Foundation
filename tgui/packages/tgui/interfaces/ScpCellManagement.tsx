import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Input, LabeledList } from '../components';
import { NtosWindow } from '../layouts';

type CellData = {
  area_name: string;
  area_ref: string;
  cell_type: string;
  assigned_dclass: string[];
  capacity: number;
  security_level: number;
  lockdown: BooleanLike;
};

type ScheduleData = {
  name: string;
  time: string;
  type: string;
  active: BooleanLike;
};

type IncidentData = {
  type: string;
  location: string;
  reporter: string;
  time: number;
};

type CellManagementData = {
  cells: CellData[];
  schedules: ScheduleData[];
  incidents: IncidentData[];
  total_incidents: number;
  total_transfers: number;
  next_schedule: string;
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

const CELL_TYPE_LABEL = (t: string): string => {
  switch (t) {
    case 'cell_block':
      return 'CELL BLOCK';
    case 'solitary':
      return 'SOLITARY';
    case 'interrogation':
      return 'INTERROGATION';
    case 'recreation':
      return 'RECREATION';
    case 'cafeteria':
      return 'CAFETERIA';
    case 'testing':
      return 'TESTING';
    case 'general':
      return 'GENERAL';
    default:
      return 'UNKNOWN';
  }
};

const CELL_TYPE_COLOR = (t: string): string => {
  switch (t) {
    case 'cell_block':
      return C.amber;
    case 'solitary':
      return C.red;
    case 'interrogation':
      return C.darkRed;
    case 'recreation':
      return C.green;
    case 'cafeteria':
      return C.green;
    case 'testing':
      return '#4488ff';
    case 'general':
      return C.dim;
    default:
      return C.dim;
  }
};

const SCHEDULE_TYPE_ICON = (t: string): string => {
  switch (t) {
    case 'roll_call':
      return '[RC]';
    case 'meal':
      return '[ML]';
    case 'work':
      return '[WK]';
    case 'recreation':
      return '[RC]';
    case 'lockdown':
      return '[LD]';
    default:
      return '[??]';
  }
};

const SECURITY_COLOR = (level: number): string => {
  if (level >= 4) return C.red;
  if (level >= 3) return C.amber;
  if (level >= 2) return C.text;
  return C.green;
};

export const ScpCellManagement = (_props: unknown) => {
  const { act, data } = useBackend<CellManagementData>();
  const { cells = [], schedules = [], incidents = [], total_incidents, total_transfers, next_schedule } = data;

  const [assignName, setAssignName] = useState('');
  const [assignCellType, setAssignCellType] = useState('');
  const [transferName, setTransferName] = useState('');
  const [transferFrom, setTransferFrom] = useState('');
  const [transferTo, setTransferTo] = useState('');
  const [incidentType, setIncidentType] = useState('');
  const [incidentLocation, setIncidentLocation] = useState('');

  return (
    <NtosWindow width={700} height={650}  backgroundColor={C.bg}>
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="CELL MANAGEMENT — D-CLASS HOUSING"
              fontSize="14px"
              color={C.highlight}
              style={{
                borderBottom: `2px solid ${C.amber}`,
                fontFamily: 'monospace',
              }}
            >
              <Stack>
                <Stack.Item>
                  <Box
                    as="span"
                    fontFamily="monospace"
                    fontSize="11px"
                    color={C.red}
                  >
                    INCIDENTS:{total_incidents}
                  </Box>
                </Stack.Item>
                <Stack.Item pl={2}>
                  <Box
                    as="span"
                    fontFamily="monospace"
                    fontSize="11px"
                    color={C.amber}
                  >
                    TRANSFERS:{total_transfers}
                  </Box>
                </Stack.Item>
                <Stack.Item pl={2}>
                  <Box
                    as="span"
                    fontFamily="monospace"
                    fontSize="11px"
                    color={C.brightGreen}
                  >
                    NEXT:{next_schedule || 'N/A'}
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="CELLS"
              fontSize="12px"
              color={C.amber}
              style={{ fontFamily: 'monospace' }}
            >
              {cells.map((cell, index) => (
                <Box
                  key={cell.area_ref}
                  style={{
                    padding: '8px',
                    marginBottom: '4px',
                    borderLeft: `3px solid ${cell.lockdown ? C.red : CELL_TYPE_COLOR(cell.cell_type)}`,
                    background: C.panel,
                    fontFamily: 'monospace',
                  }}
                >
                  <Stack align="center">
                    <Stack.Item grow>
                      <Box style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <Box
                          fontFamily="monospace"
                          fontSize="12px"
                          color={C.highlight}
                        >
                          {cell.area_name}
                        </Box>
                        <Box
                          as="span"
                          fontFamily="monospace"
                          fontSize="10px"
                          color={CELL_TYPE_COLOR(cell.cell_type)}
                          style={{
                            border: `1px solid ${CELL_TYPE_COLOR(cell.cell_type)}`,
                            padding: '1px 4px',
                          }}
                        >
                          {CELL_TYPE_LABEL(cell.cell_type)}
                        </Box>
                        {cell.lockdown === 1 && (
                          <Box
                            as="span"
                            fontFamily="monospace"
                            fontSize="10px"
                            color={C.red}
                            style={{
                              border: `1px solid ${C.red}`,
                              padding: '1px 4px',
                            }}
                          >
                            LOCKDOWN
                          </Box>
                        )}
                      </Box>
                      <Box
                        fontFamily="monospace"
                        fontSize="10px"
                        color={C.dim}
                        mt={1}
                      >
                        OCCUPANCY: {cell.assigned_dclass.length}/{cell.capacity} | SECURITY: LVL-{cell.security_level}
                      </Box>
                      {cell.assigned_dclass.length > 0 && (
                        <Box
                          fontFamily="monospace"
                          fontSize="10px"
                          color={C.text}
                          mt={1}
                        >
                          D-CLASS: {cell.assigned_dclass.join(', ')}
                        </Box>
                      )}
                    </Stack.Item>
                    <Stack.Item>
                      {cell.lockdown === 1 ? (
                        <Button
                          content="UNLOCKDOWN"
                          onClick={() => act('unlockdown_cell', { index })}
                          style={{
                            fontFamily: 'monospace',
                            fontSize: '10px',
                            background: 'rgba(10,110,10,0.3)',
                            border: `1px solid ${C.brightGreen}`,
                            color: C.brightGreen,
                            padding: '2px 8px',
                          }}
                        />
                      ) : (
                        <Button
                          content="LOCKDOWN"
                          onClick={() => act('lockdown_cell', { index })}
                          style={{
                            fontFamily: 'monospace',
                            fontSize: '10px',
                            background: 'rgba(139,0,0,0.3)',
                            border: `1px solid ${C.red}`,
                            color: C.red,
                            padding: '2px 8px',
                          }}
                        />
                      )}
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
              {cells.length === 0 && (
                <Box
                  textAlign="center"
                  color={C.dim}
                  fontFamily="monospace"
                  fontSize="11px"
                  mt={2}
                >
                  No cells registered in system.
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="DAILY SCHEDULE"
              fontSize="12px"
              color={C.amber}
              style={{ fontFamily: 'monospace' }}
            >
              {schedules.map((schedule) => (
                <Box
                  key={`${schedule.name}-${schedule.time}`}
                  style={{
                    padding: '6px 8px',
                    marginBottom: '3px',
                    borderLeft: `3px solid ${schedule.active ? C.brightGreen : C.border}`,
                    background: C.panel,
                    fontFamily: 'monospace',
                  }}
                >
                  <Stack align="center">
                    <Stack.Item>
                      <Box
                        fontFamily="monospace"
                        fontSize="10px"
                        color={C.dim}
                      >
                        {schedule.time}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box
                        as="span"
                        fontFamily="monospace"
                        fontSize="10px"
                        color={C.amber}
                      >
                        {SCHEDULE_TYPE_ICON(schedule.type)}
                      </Box>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Box
                        fontFamily="monospace"
                        fontSize="11px"
                        color={schedule.active ? C.brightGreen : C.text}
                      >
                        {schedule.name}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box
                        fontFamily="monospace"
                        fontSize="10px"
                        color={schedule.active ? C.brightGreen : C.dim}
                      >
                        {schedule.active ? 'ACTIVE' : 'PENDING'}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
              {schedules.length === 0 && (
                <Box
                  textAlign="center"
                  color={C.dim}
                  fontFamily="monospace"
                  fontSize="11px"
                  mt={2}
                >
                  No schedules loaded.
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="INCIDENT LOG"
              fontSize="12px"
              color={C.amber}
              style={{ fontFamily: 'monospace' }}
            >
              {incidents.map((incident, index) => (
                <Box
                  key={`incident-${index}-${incident.time}`}
                  style={{
                    padding: '6px 8px',
                    marginBottom: '3px',
                    borderLeft: `3px solid ${C.red}`,
                    background: C.panel,
                    fontFamily: 'monospace',
                  }}
                >
                  <Stack>
                    <Stack.Item grow>
                      <Box
                        fontFamily="monospace"
                        fontSize="11px"
                        color={C.highlight}
                      >
                        {incident.type}
                      </Box>
                      <Box
                        fontFamily="monospace"
                        fontSize="10px"
                        color={C.dim}
                      >
                        LOCATION: {incident.location} | REPORTER: {incident.reporter}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
              {incidents.length === 0 && (
                <Box
                  textAlign="center"
                  color={C.dim}
                  fontFamily="monospace"
                  fontSize="11px"
                  mt={2}
                >
                  No incidents on record.
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="ACTIONS"
              fontSize="12px"
              color={C.amber}
              style={{ fontFamily: 'monospace' }}
            >
              <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <Box>
                  <Box
                    fontFamily="monospace"
                    fontSize="10px"
                    color={C.dim}
                    mb={1}
                  >
                    ASSIGN D-CLASS TO CELL
                  </Box>
                  <Box style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
                    <Input
                      placeholder="D-Class name..."
                      value={assignName}
                      onInput={(_e, value: string) => setAssignName(value)}
                      style={{ width: '140px' }}
                    />
                    <Input
                      placeholder="Cell type..."
                      value={assignCellType}
                      onInput={(_e, value: string) => setAssignCellType(value)}
                      style={{ width: '120px' }}
                    />
                    <Button
                      content="ASSIGN CELL"
                      onClick={() => {
                        act('assign_cell', { name: assignName, cell_type: assignCellType });
                        setAssignName('');
                        setAssignCellType('');
                      }}
                      style={{
                        fontFamily: 'monospace',
                        fontSize: '10px',
                        background: 'rgba(10,110,10,0.3)',
                        border: `1px solid ${C.brightGreen}`,
                        color: C.brightGreen,
                        padding: '2px 8px',
                      }}
                    />
                  </Box>
                </Box>

                <Box>
                  <Box
                    fontFamily="monospace"
                    fontSize="10px"
                    color={C.dim}
                    mb={1}
                  >
                    TRANSFER D-CLASS
                  </Box>
                  <Box style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
                    <Input
                      placeholder="D-Class name..."
                      value={transferName}
                      onInput={(_e, value: string) => setTransferName(value)}
                      style={{ width: '120px' }}
                    />
                    <Input
                      placeholder="From cell..."
                      value={transferFrom}
                      onInput={(_e, value: string) => setTransferFrom(value)}
                      style={{ width: '100px' }}
                    />
                    <Input
                      placeholder="To cell..."
                      value={transferTo}
                      onInput={(_e, value: string) => setTransferTo(value)}
                      style={{ width: '100px' }}
                    />
                    <Button
                      content="TRANSFER"
                      onClick={() => {
                        act('transfer_dclass', { name: transferName, from: transferFrom, to: transferTo });
                        setTransferName('');
                        setTransferFrom('');
                        setTransferTo('');
                      }}
                      style={{
                        fontFamily: 'monospace',
                        fontSize: '10px',
                        background: 'rgba(68,136,255,0.2)',
                        border: '1px solid #4488ff',
                        color: '#4488ff',
                        padding: '2px 8px',
                      }}
                    />
                  </Box>
                </Box>

                <Box>
                  <Box
                    fontFamily="monospace"
                    fontSize="10px"
                    color={C.dim}
                    mb={1}
                  >
                    LOG INCIDENT
                  </Box>
                  <Box style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
                    <Input
                      placeholder="Incident type..."
                      value={incidentType}
                      onInput={(_e, value: string) => setIncidentType(value)}
                      style={{ width: '140px' }}
                    />
                    <Input
                      placeholder="Location..."
                      value={incidentLocation}
                      onInput={(_e, value: string) => setIncidentLocation(value)}
                      style={{ width: '140px' }}
                    />
                    <Button
                      content="LOG INCIDENT"
                      onClick={() => {
                        act('log_incident', { type: incidentType, location: incidentLocation });
                        setIncidentType('');
                        setIncidentLocation('');
                      }}
                      style={{
                        fontFamily: 'monospace',
                        fontSize: '10px',
                        background: 'rgba(139,0,0,0.3)',
                        border: `1px solid ${C.red}`,
                        color: C.red,
                        padding: '2px 8px',
                      }}
                    />
                  </Box>
                </Box>
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
