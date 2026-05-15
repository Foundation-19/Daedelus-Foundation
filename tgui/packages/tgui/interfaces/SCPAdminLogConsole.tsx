import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input } from '../components';
import { Window } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';

interface LogEntry {
  timestamp: string;
  log_type: string;
  scp_id: string;
  admin_ckey: string;
  target: string;
  description: string;
  severity: string;
}

interface Data {
  log_entries: LogEntry[];
  filter_type: string;
  total_entries: number;
}

const getSeverityColor = (severity: string) => {
  switch (severity) {
    case 'critical':
      return C.redBright;
    case 'warning':
      return C.amber;
    case 'info':
      return C.green;
    default:
      return C.textDim;
  }
};

const getLogTypeColor = (logType: string) => {
  switch (logType) {
    case 'containment':
      return C.redBright;
    case 'admin':
      return C.amber;
    case 'research':
      return '#4488ff';
    case 'security':
      return C.green;
    default:
      return C.textDim;
  }
};

export const SCPAdminLogConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const [selectedFilter, setSelectedFilter] = useLocalState('logFilter', data.filter_type || 'all');

  const {
    log_entries = [],
    filter_type,
    total_entries,
  } = data;

  const filteredEntries = selectedFilter === 'all'
    ? log_entries
    : log_entries.filter((e) => e.log_type === selectedFilter);

  return (
    <Window width={900} height={650} theme="scp_terminal">
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
              SCP FOUNDATION — ADMIN LOG CONSOLE
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLASSIFIED | ADMINISTRATIVE LOG ACCESS | ALL ACTIONS MONITORED
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>LOG STATISTICS</TermHeader>
            <TermRow>
              <TermLabel>TOTAL ENTRIES</TermLabel>
              <TermValue color={C.amber}>{total_entries}</TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>DISPLAYED</TermLabel>
              <TermValue color={C.textBright}>{filteredEntries.length}</TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>FILTER</TermLabel>
              <TermValue color={getLogTypeColor(selectedFilter)}>
                {selectedFilter.toUpperCase()}
              </TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>FILTER & ACTIONS</TermHeader>
            <TermRow>
              <TermLabel>FILTER TYPE</TermLabel>
              <Dropdown
                selected={selectedFilter}
                options={['all', 'containment', 'admin', 'research', 'security']}
                onSelected={(value) => {
                  setSelectedFilter(value);
                  act('set_filter', { type: value });
                }}
              />
            </TermRow>
            <Box style={{ display: 'flex', gap: '4px', marginTop: '6px' }}>
              <TermButton color="red" onClick={() => act('clear_logs')}>
                CLEAR LOGS
              </TermButton>
              <TermButton color="yellow" onClick={() => act('export_logs')}>
                EXPORT LOGS
              </TermButton>
            </Box>

            <TermDivider />

            <TermHeader>LOG ENTRIES</TermHeader>
            {filteredEntries.length > 0 ? (
              filteredEntries.map((entry, idx) => (
                <Box
                  key={`${entry.timestamp}-${idx}`}
                  style={{
                    marginBottom: '4px',
                    padding: '8px',
                    borderLeft: `2px solid ${getSeverityColor(entry.severity)}`,
                    background: C.panel,
                  }}
                >
                  <TermRow>
                    <TermValue bold color={C.amber}>
                      {entry.timestamp}
                    </TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>TYPE</TermLabel>
                    <TermValue color={getLogTypeColor(entry.log_type)}>
                      {entry.log_type.toUpperCase()}
                    </TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>SCP</TermLabel>
                    <TermValue color={C.textBright}>{entry.scp_id}</TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>ADMIN</TermLabel>
                    <TermValue color={C.textDim}>{entry.admin_ckey}</TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>SEVERITY</TermLabel>
                    <TermValue color={getSeverityColor(entry.severity)}>
                      {entry.severity.toUpperCase()}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <TermLabel>TARGET</TermLabel>
                    <TermValue>{entry.target}</TermValue>
                  </TermRow>
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '11px',
                      fontStyle: 'italic',
                      marginTop: '2px',
                    })}
                  >
                    {entry.description}
                  </Box>
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO LOG ENTRIES FOUND
              </Box>
            )}
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
              SCP FOUNDATION | ADMIN LOG CONSOLE | UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
