import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Modal } from '../components';
import { Window } from '../layouts';
import { SkillProgression } from './SkillProgression';

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  accent: '#c2960e',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenDim: '#0d4a0d',
  text: '#b0b0b0',
  textBright: '#e0e0e0',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const term = (overrides = {}) => ({
  fontFamily: C.mono,
  fontSize: '12px',
  color: C.text,
  ...overrides,
});

const TermHeader = (props) => (
  <Box
    style={term({
      fontSize: '10px',
      color: C.textDim,
      letterSpacing: '0.18em',
      textTransform: 'uppercase',
      borderBottom: `1px solid ${C.border}`,
      paddingBottom: '4px',
      marginBottom: '8px',
      ...props.style,
    })}
  >
    {props.children}
  </Box>
);

const TermLabel = (props) => (
  <Box
    as="span"
    style={term({
      color: C.textDim,
      fontSize: '10px',
      letterSpacing: '0.12em',
      textTransform: 'uppercase',
      marginRight: '8px',
    })}
  >
    {props.children}
  </Box>
);

const TermValue = (props) => (
  <Box
    as="span"
    style={term({
      color: props.color || C.textBright,
      fontWeight: props.bold ? 'bold' : undefined,
    })}
  >
    {props.children}
  </Box>
);

const TermRow = (props) => (
  <Box style={{ marginBottom: '6px', display: 'flex', alignItems: 'center' }}>
    {props.children}
  </Box>
);

const TermDivider = () => (
  <Box
    style={{
      color: C.borderRed,
      fontSize: '10px',
      letterSpacing: '0.3em',
      margin: '10px 0',
      userSelect: 'none',
      overflow: 'hidden',
      whiteSpace: 'nowrap',
    }}
  >
    {'─'.repeat(80)}
  </Box>
);

const TermButton = (props) => {
  const selected = props.selected;
  const color = props.color;
  const bg = selected
    ? color === 'red'
      ? 'rgba(139,0,0,0.35)'
      : color === 'green'
        ? 'rgba(26,122,26,0.35)'
        : color === 'yellow'
          ? 'rgba(180,160,20,0.25)'
          : 'rgba(255,255,255,0.08)'
    : 'transparent';
  const borderColor = selected
    ? color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border
    : C.border;

  return (
    <Button
      {...props}
      style={{
        fontFamily: C.mono,
        fontSize: '10px',
        letterSpacing: '0.1em',
        textTransform: 'uppercase',
        background: bg,
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color: selected ? C.textBright : C.textDim,
        padding: '3px 8px',
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    >
      {props.children}
    </Button>
  );
};

const TermProgressBar = (props) => (
  <Box style={{ marginBottom: '6px' }}>
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        marginBottom: '2px',
      }}
    >
      <TermLabel>{props.label}</TermLabel>
      <TermValue color={props.color || C.amber}>
        {props.value}
        {props.suffix || ''}
      </TermValue>
    </Box>
    <Box
      style={{
        height: '6px',
        background: C.panel,
        border: `1px solid ${C.border}`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          height: '100%',
          width: `${Math.min(100, Math.max(0, (props.value / props.maxValue) * 100))}%`,
          background: props.color || C.amber,
          transition: 'width 0.3s',
        }}
      />
    </Box>
  </Box>
);

const TermModal = (props) => (
  <Modal
    {...props}
    style={{
      background: C.bg,
      border: `1px solid ${C.borderRed}`,
      borderRadius: 0,
      fontFamily: C.mono,
      color: C.text,
      padding: '16px',
    }}
  >
    {props.children}
  </Modal>
);

const StatusDot = ({ online }) => (
  <Box
    as="span"
    style={{
      display: 'inline-block',
      width: '6px',
      height: '6px',
      borderRadius: '50%',
      background: online ? C.green : C.redBright,
      marginRight: '4px',
    }}
  />
);

const NAV_ITEMS = [
  { key: 'desktop', label: 'INDEX' },
  { key: 'facility', label: 'FACILITY' },
  { key: 'scp', label: 'SCP' },
  { key: 'technology', label: 'TECH' },
  { key: 'medical', label: 'MEDICAL' },
  { key: 'security', label: 'SECURITY' },
  { key: 'research', label: 'RESEARCH' },
  { key: 'chemical', label: 'CHEMICAL' },
  { key: 'incident', label: 'INCIDENT' },
  { key: 'psychological', label: 'PSYCH' },
  { key: 'infrastructure', label: 'INFRA' },
  { key: 'analytics', label: 'ANALYTICS' },
  { key: 'personnel', label: 'PERSONNEL' },
  { key: 'players', label: 'PLAYERS' },
  { key: 'budget', label: 'BUDGET' },
  { key: 'progression', label: 'PROGRESS' },
  { key: 'skill_progression', label: 'SKILLS' },
];

const SubTabBar = ({ tabs, active, onChange }) => (
  <Box
    style={{
      display: 'flex',
      borderBottom: `1px solid ${C.border}`,
      marginBottom: '12px',
      overflowX: 'auto',
    }}
  >
    {tabs.map((t) => {
      const isActive = active === t.key;
      return (
        <Box
          key={t.key}
          style={{
            padding: '4px 10px',
            cursor: 'pointer',
            background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
            borderBottom: isActive
              ? `2px solid ${C.amber}`
              : '2px solid transparent',
            color: isActive ? C.textBright : C.textDim,
            fontSize: '10px',
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            fontFamily: C.mono,
            whiteSpace: 'nowrap',
          }}
          onClick={() => onChange(t.key)}
        >
          {t.label}
        </Box>
      );
    })}
  </Box>
);

const GenericSection = ({ title, data, act, actions }) => (
  <Box>
    <TermHeader>{title}</TermHeader>
    <Box
      style={{
        display: 'flex',
        gap: '4px',
        marginBottom: '12px',
        flexWrap: 'wrap',
      }}
    >
      {actions &&
        actions.map((a, i) => (
          <TermButton
            key={i}
            color={a.color}
            onClick={() => act(a.action, a.params || undefined)}
          >
            {a.label}
          </TermButton>
        ))}
    </Box>
    {data ? (
      <Box style={{ lineHeight: '1.6' }}>
        {Object.entries(data)
          .filter(([k, v]) => typeof v !== 'object')
          .map(([key, value]) => (
            <TermRow key={key}>
              <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
              <TermValue
                color={typeof value === 'number' ? C.amber : C.textBright}
              >
                {String(value)}
              </TermValue>
            </TermRow>
          ))}
      </Box>
    ) : (
      <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
        NO DATA AVAILABLE
      </Box>
    )}
  </Box>
);

export const PersistenceMasterPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = React.useState('desktop');
  const [subTabs, setSubTabs] = React.useState({});

  const getSubTab = (section, defaultValue = 'overview') =>
    subTabs[section] || defaultValue;
  const setSubTab = (section, value) =>
    setSubTabs((prev) => ({ ...prev, [section]: value }));

  const {
    facility_data,
    scp_data,
    technology_data,
    medical_data,
    security_data,
    research_data,
    chemical_data,
    incident_data,
    psychological_data,
    infrastructure_data,
    analytics_data,
    personnel_data,
    budget_data,
    player_data,
    system_status,
  } = data;

  return (
    <Window
      title="SCP FOUNDATION — PERSISTENCE CONTROL TERMINAL"
      width={1400}
      height={900}
      theme="scp_terminal"
    >
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
          {/* HEADER */}
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
              SCP FOUNDATION — PERSISTENCE CONTROL TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | ADMINISTRATIVE OVERRIDE | ALL SYSTEMS
              MONITORED
            </Box>
          </Box>

          {/* NAV BAR */}
          <Box
            style={{
              display: 'flex',
              borderBottom: `1px solid ${C.borderRed}`,
              overflowX: 'auto',
              background: C.panel,
            }}
          >
            {NAV_ITEMS.map((t) => {
              const isActive = activeTab === t.key;
              return (
                <Box
                  key={t.key}
                  style={{
                    padding: '6px 12px',
                    cursor: 'pointer',
                    background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
                    borderRight: `1px solid ${C.border}`,
                    borderBottom: isActive
                      ? `2px solid ${C.amber}`
                      : '2px solid transparent',
                    color: isActive ? C.textBright : C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    fontFamily: C.mono,
                    whiteSpace: 'nowrap',
                  }}
                  onClick={() => setActiveTab(t.key)}
                >
                  {isActive && '▸ '}
                  {t.label}
                </Box>
              );
            })}
          </Box>

          {/* MAIN CONTENT */}
          <Box style={{ display: 'flex' }}>
            {/* LEFT: Content */}
            <Box style={{ flex: 1, padding: '16px', minHeight: '500px' }}>
              {/* DESKTOP / INDEX */}
              {activeTab === 'desktop' && (
                <Box>
                  <TermHeader>SYSTEM INDEX</TermHeader>
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '11px',
                      fontStyle: 'italic',
                      marginBottom: '12px',
                      borderLeft: `2px solid ${C.amber}`,
                      paddingLeft: '8px',
                    })}
                  >
                    SCP Foundation Persistence Control System. Select a section
                    from the navigation bar above to manage subsystems.
                  </Box>
                  <TermDivider />
                  <TermHeader>SYSTEM STATUS</TermHeader>
                  <TermRow>
                    <StatusDot online={!!facility_data} />
                    <TermLabel>FACILITY</TermLabel>
                    <TermValue color={facility_data ? C.green : C.redBright}>
                      {facility_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!scp_data} />
                    <TermLabel>SCP CONTAINMENT</TermLabel>
                    <TermValue color={scp_data ? C.green : C.redBright}>
                      {scp_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!technology_data} />
                    <TermLabel>TECHNOLOGY</TermLabel>
                    <TermValue color={technology_data ? C.green : C.redBright}>
                      {technology_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!medical_data} />
                    <TermLabel>MEDICAL</TermLabel>
                    <TermValue color={medical_data ? C.green : C.redBright}>
                      {medical_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!security_data} />
                    <TermLabel>SECURITY</TermLabel>
                    <TermValue color={security_data ? C.green : C.redBright}>
                      {security_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!research_data} />
                    <TermLabel>RESEARCH</TermLabel>
                    <TermValue color={research_data ? C.green : C.redBright}>
                      {research_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!personnel_data} />
                    <TermLabel>PERSONNEL</TermLabel>
                    <TermValue color={personnel_data ? C.green : C.redBright}>
                      {personnel_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!player_data} />
                    <TermLabel>PLAYER DATA</TermLabel>
                    <TermValue color={player_data ? C.green : C.redBright}>
                      {player_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermDivider />
                  <TermHeader>QUICK ACTIONS</TermHeader>
                  <Box
                    style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('facility_save_data')}
                    >
                      SAVE ALL
                    </TermButton>
                    <TermButton onClick={() => act('facility_load_data')}>
                      LOAD ALL
                    </TermButton>
                    <TermButton
                      color="yellow"
                      onClick={() => act('progression_export_data')}
                    >
                      DOWNLOAD ALL
                    </TermButton>
                    <TermButton
                      color="red"
                      onClick={() => act('progression_reset_data')}
                    >
                      RESET ALL
                    </TermButton>
                  </Box>
                </Box>
              )}

              {/* FACILITY */}
              {activeTab === 'facility' && (
                <Box>
                  <SubTabBar
                    tabs={[
                      { key: 'overview', label: 'OVERVIEW' },
                      { key: 'rooms', label: 'ROOMS' },
                      { key: 'equipment', label: 'EQUIPMENT' },
                      { key: 'systems', label: 'SYSTEMS' },
                    ]}
                    active={getSubTab('facility')}
                    onChange={(v) => setSubTab('facility', v)}
                  />
                  <TermHeader>FACILITY MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('facility_save_data')}
                    >
                      SAVE
                    </TermButton>
                    <TermButton onClick={() => act('facility_load_data')}>
                      LOAD
                    </TermButton>
                    <TermButton
                      color="red"
                      onClick={() => act('facility_reset_data')}
                    >
                      RESET
                    </TermButton>
                    <TermButton onClick={() => act('test_systems')}>
                      TEST SYSTEMS
                    </TermButton>
                    <TermButton
                      onClick={() => act('facility_power_grid_status')}
                    >
                      POWER GRID
                    </TermButton>
                  </Box>
                  {facility_data ? (
                    <>
                      {getSubTab('facility') === 'overview' && (
                        <Box style={{ lineHeight: '1.6' }}>
                          <TermRow>
                            <TermLabel>ROOMS</TermLabel>
                            <TermValue>
                              {facility_data.room_states_count || 0}/50
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TermLabel>EQUIPMENT</TermLabel>
                            <TermValue>
                              {facility_data.equipment_operational || 0}/45
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TermLabel>SECURITY SYSTEMS</TermLabel>
                            <TermValue>
                              {facility_data.security_systems_count || 0}/15
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TermLabel>POWER EFFICIENCY</TermLabel>
                            <TermValue color={C.amber}>
                              {facility_data.power_efficiency
                                ? Math.round(facility_data.power_efficiency * 100)
                                : 0}
                              %
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TermLabel>CONTAINMENT STABILITY</TermLabel>
                            <TermValue>
                              {facility_data.containment_stability || 0}%
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TermLabel>HEALTH</TermLabel>
                            <TermValue color={C.green}>
                              {facility_data.facility_health || 0}%
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TermLabel>MAINTENANCE</TermLabel>
                            <TermValue>
                              {facility_data.maintenance_level || 0}%
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TermLabel>SECURITY LEVEL</TermLabel>
                            <TermValue color={C.redBright}>
                              {facility_data.security_level || 0}
                            </TermValue>
                          </TermRow>
                        </Box>
                      )}
                      {getSubTab('facility') === 'rooms' && (
                        <Box>
                          {facility_data.rooms &&
                          facility_data.rooms.length > 0 ? (
                            facility_data.rooms.map((room, idx) => (
                              <Box
                                key={idx}
                                style={{
                                  marginBottom: '4px',
                                  padding: '6px 8px',
                                  borderLeft: `2px solid ${
                                    room.status === 'OPERATIONAL'
                                      ? C.green
                                      : C.redBright
                                  }`,
                                  background: C.panel,
                                }}
                              >
                                <TermRow>
                                  <TermValue bold color={C.amber}>
                                    {(room.room_type || 'UNKNOWN').toUpperCase()}
                                  </TermValue>
                                  <TermLabel style={{ marginLeft: '8px' }}>
                                    ID
                                  </TermLabel>
                                  <TermValue color={C.textDim}>
                                    {room.room_id}
                                  </TermValue>
                                </TermRow>
                                <TermRow>
                                  <TermLabel>STATUS</TermLabel>
                                  <TermValue
                                    color={
                                      room.status === 'OPERATIONAL'
                                        ? C.green
                                        : C.redBright
                                    }
                                  >
                                    {room.status}
                                  </TermValue>
                                  <TermLabel style={{ marginLeft: '8px' }}>
                                    HEALTH
                                  </TermLabel>
                                  <TermValue color={C.amber}>
                                    {room.health}%
                                  </TermValue>
                                  <TermLabel style={{ marginLeft: '8px' }}>
                                    SECURITY
                                  </TermLabel>
                                  <TermValue>
                                    LVL {room.security_level}
                                  </TermValue>
                                </TermRow>
                              </Box>
                            ))
                          ) : (
                            <Box
                              style={term({
                                color: C.textDim,
                                fontStyle: 'italic',
                              })}
                            >
                              NO ROOM DATA
                            </Box>
                          )}
                        </Box>
                      )}
                      {getSubTab('facility') === 'equipment' && (
                        <Box>
                          {facility_data.equipment_status &&
                          Object.keys(facility_data.equipment_status).length >
                            0 ? (
                            Object.entries(facility_data.equipment_status).map(
                              ([eqId, eq]) => (
                                <Box
                                  key={eqId}
                                  style={{
                                    marginBottom: '4px',
                                    padding: '6px 8px',
                                    borderLeft: `2px solid ${
                                      eq.operational ? C.green : C.redBright
                                    }`,
                                    background: C.panel,
                                  }}
                                >
                                  <TermRow>
                                    <TermValue bold color={C.amber}>
                                      {(
                                        eq.equipment_type ||
                                        eqId
                                      ).toUpperCase()}
                                    </TermValue>
                                    <TermLabel style={{ marginLeft: '8px' }}>
                                      STATUS
                                    </TermLabel>
                                    <TermValue
                                      color={
                                        eq.operational
                                          ? C.green
                                          : C.redBright
                                      }
                                    >
                                      {eq.operational
                                        ? 'OPERATIONAL'
                                        : 'OFFLINE'}
                                    </TermValue>
                                  </TermRow>
                                  <TermRow>
                                    <TermLabel>HEALTH</TermLabel>
                                    <TermValue color={C.amber}>
                                      {Math.round(eq.health || 0)}%
                                    </TermValue>
                                    <TermLabel style={{ marginLeft: '8px' }}>
                                      EFFICIENCY
                                    </TermLabel>
                                    <TermValue>
                                      {Math.round(
                                        (eq.efficiency || 0) * 100,
                                      )}
                                      %
                                    </TermValue>
                                    {eq.maintenance_required && (
                                      <TermValue
                                        color={C.redBright}
                                        style={{ marginLeft: '8px' }}
                                      >
                                        MAINTENANCE REQUIRED
                                      </TermValue>
                                    )}
                                  </TermRow>
                                </Box>
                              ),
                            )
                          ) : (
                            <Box
                              style={term({
                                color: C.textDim,
                                fontStyle: 'italic',
                              })}
                            >
                              NO EQUIPMENT DATA
                            </Box>
                          )}
                          {facility_data.maintenance_tasks &&
                            facility_data.maintenance_tasks.length > 0 && (
                              <Box>
                                <TermDivider />
                                <TermHeader>MAINTENANCE SCHEDULE</TermHeader>
                                {facility_data.maintenance_tasks.map(
                                  (task, idx) => (
                                    <Box
                                      key={idx}
                                      style={{
                                        marginBottom: '4px',
                                        padding: '6px 8px',
                                        borderLeft: `2px solid ${
                                          task.priority === 'high'
                                            ? C.redBright
                                            : task.priority === 'medium'
                                              ? C.amber
                                              : C.border
                                        }`,
                                        background: C.panel,
                                      }}
                                    >
                                      <TermRow>
                                        <TermValue bold color={C.amber}>
                                          {task.task_id}
                                        </TermValue>
                                        <TermLabel style={{ marginLeft: '8px' }}>
                                          {task.task_name}
                                        </TermLabel>
                                      </TermRow>
                                      <TermRow>
                                        <TermLabel>PRIORITY</TermLabel>
                                        <TermValue
                                          color={
                                            task.priority === 'high'
                                              ? C.redBright
                                              : C.amber
                                          }
                                        >
                                          {(task.priority || 'LOW').toUpperCase()}
                                        </TermValue>
                                        <TermLabel style={{ marginLeft: '8px' }}>
                                          ASSIGNED
                                        </TermLabel>
                                        <TermValue>
                                          {task.assigned_to}
                                        </TermValue>
                                        <TermLabel style={{ marginLeft: '8px' }}>
                                          DUE
                                        </TermLabel>
                                        <TermValue color={C.textDim}>
                                          {task.due_date}
                                        </TermValue>
                                      </TermRow>
                                    </Box>
                                  ),
                                )}
                              </Box>
                            )}
                        </Box>
                      )}
                      {getSubTab('facility') === 'systems' && (
                        <Box>
                          {facility_data.security_systems &&
                          Object.keys(facility_data.security_systems).length >
                            0 ? (
                            Object.entries(facility_data.security_systems).map(
                              ([sysId, sys]) => (
                                <Box
                                  key={sysId}
                                  style={{
                                    marginBottom: '4px',
                                    padding: '6px 8px',
                                    borderLeft: `2px solid ${
                                      sys.operational ? C.green : C.redBright
                                    }`,
                                    background: C.panel,
                                  }}
                                >
                                  <TermRow>
                                    <TermValue bold color={C.amber}>
                                      {(sys.system_type || sysId).toUpperCase()}
                                    </TermValue>
                                    <TermLabel style={{ marginLeft: '8px' }}>
                                      STATUS
                                    </TermLabel>
                                    <TermValue
                                      color={
                                        sys.operational
                                          ? C.green
                                          : C.redBright
                                      }
                                    >
                                      {sys.operational
                                        ? 'OPERATIONAL'
                                        : 'OFFLINE'}
                                    </TermValue>
                                  </TermRow>
                                  <TermRow>
                                    <TermLabel>HEALTH</TermLabel>
                                    <TermValue color={C.amber}>
                                      {Math.round(sys.health || 0)}%
                                    </TermValue>
                                    <TermLabel style={{ marginLeft: '8px' }}>
                                      SECURITY LEVEL
                                    </TermLabel>
                                    <TermValue>
                                      LVL {sys.security_level || 0}
                                    </TermValue>
                                    {sys.alert_status && (
                                      <TermValue
                                        color={C.redBright}
                                        style={{ marginLeft: '8px' }}
                                      >
                                        ALERT: {sys.alert_status}
                                      </TermValue>
                                    )}
                                  </TermRow>
                                </Box>
                              ),
                            )
                          ) : (
                            <Box
                              style={term({
                                color: C.textDim,
                                fontStyle: 'italic',
                              })}
                            >
                              NO SECURITY SYSTEM DATA
                            </Box>
                          )}
                        </Box>
                      )}
                    </>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO FACILITY DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* SCP */}
              {activeTab === 'scp' && (
                <Box>
                  <TermHeader>SCP CONTAINMENT MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('scp_view_status')}
                    >
                      VIEW STATUS
                    </TermButton>
                    <TermButton onClick={() => act('scp_save_data')}>
                      SAVE
                    </TermButton>
                    <TermButton color="red" onClick={() => act('test_systems')}>
                      CONTAINMENT CHECK
                    </TermButton>
                  </Box>
                  {scp_data ? (
                    <Box style={{ lineHeight: '1.6' }}>
                      {Object.entries(scp_data)
                        .filter(([k, v]) => typeof v !== 'object')
                        .map(([key, value]) => (
                          <TermRow key={key}>
                            <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                            <TermValue
                              color={
                                typeof value === 'number'
                                  ? C.amber
                                  : C.textBright
                              }
                            >
                              {String(value)}
                            </TermValue>
                          </TermRow>
                        ))}
                    </Box>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO SCP DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* TECHNOLOGY */}
              {activeTab === 'technology' && (
                <GenericSection
                  title="TECHNOLOGY MANAGEMENT"
                  data={technology_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'technology_save_data',
                    },
                    { label: 'VIEW', action: 'technology_view_status' },
                  ]}
                />
              )}

              {/* MEDICAL */}
              {activeTab === 'medical' && (
                <GenericSection
                  title="MEDICAL RECORDS MANAGEMENT"
                  data={medical_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'medical_save_data',
                    },
                    { label: 'LOAD', action: 'medical_load_data' },
                    { label: 'VIEW', action: 'medical_view_status' },
                  ]}
                />
              )}

              {/* SECURITY */}
              {activeTab === 'security' && (
                <GenericSection
                  title="SECURITY OPERATIONS MANAGEMENT"
                  data={security_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'security_save_data',
                    },
                    { label: 'LOAD', action: 'security_load_data' },
                    {
                      label: 'SCAN',
                      color: 'yellow',
                      action: 'security_scan',
                      params: {
                        scan_data: {
                          scan_type: 'comprehensive',
                          target_systems: {
                            access_control: true,
                            surveillance: true,
                            communications: true,
                            databases: true,
                            networks: true,
                            physical_security: true,
                          },
                        },
                      },
                    },
                  ]}
                />
              )}

              {/* RESEARCH */}
              {activeTab === 'research' && (
                <Box>
                  <TermHeader>RESEARCH PROJECTS MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('research_save_data')}
                    >
                      SAVE
                    </TermButton>
                    <TermButton onClick={() => act('research_load_data')}>
                      LOAD
                    </TermButton>
                    <TermButton onClick={() => act('research_view_status')}>
                      VIEW
                    </TermButton>
                  </Box>
                  {research_data ? (
                    <Box style={{ lineHeight: '1.6' }}>
                      {Object.entries(research_data)
                        .filter(([k, v]) => typeof v !== 'object')
                        .map(([key, value]) => (
                          <TermRow key={key}>
                            <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                            <TermValue
                              color={
                                typeof value === 'number'
                                  ? C.amber
                                  : C.textBright
                              }
                            >
                              {String(value)}
                            </TermValue>
                          </TermRow>
                        ))}
                      {research_data.research_projects &&
                        research_data.research_projects.length > 0 && (
                          <Box>
                            <TermDivider />
                            <TermHeader>PROJECTS</TermHeader>
                            {research_data.research_projects.map((proj, idx) => (
                              <Box
                                key={proj.project_id || idx}
                                style={{
                                  marginBottom: '6px',
                                  padding: '6px 8px',
                                  borderLeft: `2px solid ${
                                    proj.status === 'COMPLETED'
                                      ? C.green
                                      : proj.status === 'ACTIVE'
                                        ? C.amber
                                        : proj.status === 'CANCELLED'
                                          ? C.redBright
                                          : C.border
                                  }`,
                                  background: C.panel,
                                }}
                              >
                                <TermRow>
                                  <TermValue bold color={C.amber}>
                                    {proj.project_name || 'Unknown'}
                                  </TermValue>
                                  <TermLabel style={{ marginLeft: '8px' }}>
                                    ID
                                  </TermLabel>
                                  <TermValue color={C.textDim}>
                                    {proj.project_id || 'N/A'}
                                  </TermValue>
                                </TermRow>
                                <TermRow>
                                  <TermLabel>STATUS</TermLabel>
                                  <TermValue
                                    color={
                                      proj.status === 'COMPLETED'
                                        ? C.green
                                        : proj.status === 'ACTIVE'
                                          ? C.amber
                                          : proj.status === 'CANCELLED'
                                            ? C.redBright
                                            : C.textBright
                                    }
                                  >
                                    {proj.status || 'UNKNOWN'}
                                  </TermValue>
                                  {proj.field && (
                                    <>
                                      <TermLabel style={{ marginLeft: '8px' }}>
                                        FIELD
                                      </TermLabel>
                                      <TermValue>{proj.field}</TermValue>
                                    </>
                                  )}
                                  {proj.lead_researcher && (
                                    <>
                                      <TermLabel style={{ marginLeft: '8px' }}>
                                        LEAD
                                      </TermLabel>
                                      <TermValue>{proj.lead_researcher}</TermValue>
                                    </>
                                  )}
                                </TermRow>
                                <TermRow>
                                  <TermLabel>PROGRESS</TermLabel>
                                  <TermValue color={C.amber}>
                                    {Math.round(proj.progress || 0)}%
                                  </TermValue>
                                  {proj.budget !== undefined && (
                                    <>
                                      <TermLabel style={{ marginLeft: '8px' }}>
                                        BUDGET
                                      </TermLabel>
                                      <TermValue>
                                        {proj.budget_used || 0}/{proj.budget || 0}
                                      </TermValue>
                                    </>
                                  )}
                                  <TermButton
                                    color="red"
                                    style={{ marginLeft: '8px' }}
                                    onClick={() =>
                                      act('research_delete_project', {
                                        project_id: proj.project_id,
                                      })
                                    }
                                  >
                                    DELETE
                                  </TermButton>
                                </TermRow>
                                {proj.description && (
                                  <Box
                                    style={{
                                      color: C.textDim,
                                      fontSize: '10px',
                                      marginTop: '2px',
                                      borderLeft: `1px solid ${C.border}`,
                                      paddingLeft: '6px',
                                    }}
                                  >
                                    {proj.description}
                                  </Box>
                                )}
                              </Box>
                            ))}
                          </Box>
                        )}
                    </Box>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO RESEARCH DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* CHEMICAL */}
              {activeTab === 'chemical' && (
                <GenericSection
                  title="CHEMICAL CONTAINMENT MANAGEMENT"
                  data={chemical_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'chemical_save_data',
                    },
                    { label: 'LOAD', action: 'chemical_load_data' },
                    { label: 'VIEW', action: 'chemical_view_records' },
                    {
                      label: 'RESEARCH',
                      color: 'green',
                      action: 'chemical_add_research',
                    },
                    {
                      label: 'CONTAINMENT',
                      color: 'yellow',
                      action: 'chemical_containment_status',
                    },
                  ]}
                />
              )}

              {/* INCIDENT */}
              {activeTab === 'incident' && (
                <GenericSection
                  title="INCIDENT RESPONSE MANAGEMENT"
                  data={incident_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'incident_save_data',
                    },
                    { label: 'LOAD', action: 'incident_load_data' },
                    { label: 'VIEW', action: 'incident_view_logs' },
                    {
                      label: 'BREACH',
                      color: 'red',
                      action: 'incident_add_breach',
                    },
                    {
                      label: 'TEAMS',
                      color: 'yellow',
                      action: 'incident_response_teams',
                    },
                  ]}
                />
              )}

              {/* PSYCHOLOGICAL */}
              {activeTab === 'psychological' && (
                <GenericSection
                  title="PSYCHOLOGICAL SERVICES MANAGEMENT"
                  data={psychological_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'psychological_save_data',
                    },
                    { label: 'LOAD', action: 'psychological_load_data' },
                    { label: 'VIEW', action: 'psychological_view_records' },
                    {
                      label: 'SESSION',
                      color: 'green',
                      action: 'psychological_add_session',
                    },
                    {
                      label: 'ASSESS',
                      color: 'yellow',
                      action: 'psychological_assessments',
                    },
                  ]}
                />
              )}

              {/* INFRASTRUCTURE */}
              {activeTab === 'infrastructure' && (
                <GenericSection
                  title="INFRASTRUCTURE MANAGEMENT"
                  data={infrastructure_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'infrastructure_save_data',
                    },
                    { label: 'LOAD', action: 'infrastructure_load_data' },
                    { label: 'VIEW', action: 'infrastructure_view_status' },
                    {
                      label: 'RESET',
                      color: 'red',
                      action: 'infrastructure_reset_data',
                    },
                  ]}
                />
              )}

              {/* ANALYTICS */}
              {activeTab === 'analytics' && (
                <GenericSection
                  title="ANALYTICS & PERFORMANCE"
                  data={analytics_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'analytics_save_data',
                    },
                    { label: 'LOAD', action: 'analytics_load_data' },
                    { label: 'VIEW', action: 'analytics_view_status' },
                    {
                      label: 'RESET',
                      color: 'red',
                      action: 'analytics_reset_data',
                    },
                  ]}
                />
              )}

              {/* PERSONNEL */}
              {activeTab === 'personnel' && (
                <GenericSection
                  title="PERSONNEL MANAGEMENT"
                  data={personnel_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'personnel_save_data',
                    },
                    { label: 'LOAD', action: 'personnel_load_data' },
                    { label: 'VIEW', action: 'personnel_view_status' },
                  ]}
                />
              )}

              {/* PLAYERS */}
              {activeTab === 'players' && (
                <Box>
                  <TermHeader>PLAYER DATA MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('player_view_data')}
                    >
                      VIEW
                    </TermButton>
                    <TermButton
                      color="yellow"
                      onClick={() => act('player_export_data')}
                    >
                      DOWNLOAD
                    </TermButton>
                    <TermButton
                      color="red"
                      onClick={() => act('player_reset_progress')}
                    >
                      RESET ALL
                    </TermButton>
                  </Box>
                  {player_data && player_data.length > 0 ? (
                    player_data.map((player) => (
                      <Box
                        key={player.ckey || player.key}
                        style={{
                          marginBottom: '6px',
                          padding: '8px',
                          borderLeft: `2px solid ${C.borderRed}`,
                          background: C.panel,
                        }}
                      >
                        <TermRow>
                          <TermValue bold color={C.amber}>
                            {player.name || player.ckey}
                          </TermValue>
                          <TermLabel style={{ marginLeft: '8px' }}>
                            KEY
                          </TermLabel>
                          <TermValue color={C.textDim}>
                            {player.ckey || player.key}
                          </TermValue>
                        </TermRow>
                        {player.class && (
                          <TermRow>
                            <TermLabel>CLASS</TermLabel>
                            <TermValue>{player.class}</TermValue>
                          </TermRow>
                        )}
                        {player.rank && (
                          <TermRow>
                            <TermLabel>RANK</TermLabel>
                            <TermValue color={C.green}>{player.rank}</TermValue>
                          </TermRow>
                        )}
                        {player.experience !== undefined && (
                          <TermRow>
                            <TermLabel>XP</TermLabel>
                            <TermValue color={C.amber}>
                              {player.experience?.toLocaleString()}
                            </TermValue>
                          </TermRow>
                        )}
                        {player.rounds_played !== undefined && (
                          <TermRow>
                            <TermLabel>ROUNDS</TermLabel>
                            <TermValue>{player.rounds_played}</TermValue>
                          </TermRow>
                        )}
                        <Box
                          style={{
                            display: 'flex',
                            gap: '4px',
                            marginTop: '4px',
                          }}
                        >
                          <TermButton
                            onClick={() =>
                              act('view_progress', {
                                ckey: player.ckey || player.key,
                              })
                            }
                          >
                            VIEW
                          </TermButton>
                          <TermButton
                            color="red"
                            onClick={() =>
                              act('reset_progress', {
                                ckey: player.ckey || player.key,
                              })
                            }
                          >
                            RESET
                          </TermButton>
                        </Box>
                      </Box>
                    ))
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO PLAYER DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* BUDGET */}
              {activeTab === 'budget' && (
                <Box>
                  <TermHeader>BUDGET MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() =>
                        act('budget_request_increase', {
                          request_data: {
                            department_id: 'general',
                            requested_amount: 50000,
                            requested_category: 'operational',
                            justification: 'Admin emergency request',
                            priority: 1,
                          },
                        })
                      }
                    >
                      REQUEST
                    </TermButton>
                    <TermButton
                      onClick={() =>
                        act('budget_add_transaction', {
                          transaction_data: {
                            department_id: 'general',
                            transaction_type: 'EXPENSE',
                            amount: 10000,
                            category: 'miscellaneous',
                            description: 'Admin logged transaction',
                          },
                        })
                      }
                    >
                      TRANSACTION
                    </TermButton>
                    <TermButton
                      color="yellow"
                      onClick={() =>
                        act('budget_transfer', {
                          transfer_data: {
                            from_department: 'general',
                            to_department: 'security',
                            amount: 25000,
                            reason: 'Admin budget transfer',
                          },
                        })
                      }
                    >
                      TRANSFER
                    </TermButton>
                  </Box>
                  {budget_data ? (
                    <Box style={{ lineHeight: '1.6' }}>
                      {Object.entries(budget_data)
                        .filter(([k, v]) => typeof v !== 'object')
                        .map(([key, value]) => (
                          <TermRow key={key}>
                            <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                            <TermValue
                              color={
                                typeof value === 'number'
                                  ? C.amber
                                  : C.textBright
                              }
                            >
                              {typeof value === 'number'
                                ? String(value).replace(
                                    /\B(?=(\d{3})+(?!\d))/g,
                                    ',',
                                  )
                                : String(value)}
                            </TermValue>
                          </TermRow>
                        ))}
                      {budget_data.departments &&
                        Object.keys(budget_data.departments).length > 0 && (
                          <Box>
                            <TermDivider />
                            <TermHeader>DEPARTMENT BUDGETS</TermHeader>
                            {Object.entries(budget_data.departments).map(
                              ([deptId, dept]) => (
                                <Box
                                  key={deptId}
                                  style={{
                                    marginBottom: '6px',
                                    padding: '6px 8px',
                                    borderLeft: `2px solid ${C.borderRed}`,
                                    background: C.panel,
                                  }}
                                >
                                  <TermRow>
                                    <TermValue bold color={C.amber}>
                                      {(dept.name || deptId).toUpperCase()}
                                    </TermValue>
                                  </TermRow>
                                  <TermRow>
                                    <TermLabel>ALLOCATED</TermLabel>
                                    <TermValue color={C.amber}>
                                      {String(dept.allocated || 0).replace(
                                        /\B(?=(\d{3})+(?!\d))/g,
                                        ',',
                                      )}
                                    </TermValue>
                                    <TermLabel style={{ marginLeft: '8px' }}>
                                      SPENT
                                    </TermLabel>
                                    <TermValue color={C.redBright}>
                                      {String(dept.spent || 0).replace(
                                        /\B(?=(\d{3})+(?!\d))/g,
                                        ',',
                                      )}
                                    </TermValue>
                                    <TermLabel style={{ marginLeft: '8px' }}>
                                      REMAINING
                                    </TermLabel>
                                    <TermValue color={C.green}>
                                      {String(dept.remaining || 0).replace(
                                        /\B(?=(\d{3})+(?!\d))/g,
                                        ',',
                                      )}
                                    </TermValue>
                                  </TermRow>
                                </Box>
                              ),
                            )}
                          </Box>
                        )}
                      {budget_data.pending_requests &&
                        budget_data.pending_requests.length > 0 && (
                          <Box>
                            <TermDivider />
                            <TermHeader>PENDING REQUESTS</TermHeader>
                            {budget_data.pending_requests.map((req, idx) => (
                              <TermRow key={idx}>
                                <TermValue bold color={C.amber}>
                                  {req.id}
                                </TermValue>
                                <TermLabel style={{ marginLeft: '8px' }}>
                                  DEPT
                                </TermLabel>
                                <TermValue>{req.department}</TermValue>
                                <TermLabel style={{ marginLeft: '8px' }}>
                                  AMOUNT
                                </TermLabel>
                                <TermValue color={C.amber}>
                                  {String(req.amount).replace(
                                    /\B(?=(\d{3})+(?!\d))/g,
                                    ',',
                                  )}
                                </TermValue>
                              </TermRow>
                            ))}
                          </Box>
                        )}
                    </Box>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO BUDGET DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* PROGRESSION */}
              {activeTab === 'progression' && (
                <GenericSection
                  title="PERSISTENT PROGRESSION"
                  data={data}
                  act={act}
                  actions={[
                    {
                      label: 'DOWNLOAD',
                      color: 'green',
                      action: 'progression_export_data',
                    },
                    { label: 'VIEW', action: 'progression_view_data' },
                    {
                      label: 'RESET',
                      color: 'red',
                      action: 'progression_reset_data',
                    },
                  ]}
                />
              )}

              {/* SKILL PROGRESSION */}
              {activeTab === 'skill_progression' && <SkillProgression />}
            </Box>

            {/* RIGHT: SCIPNET Sidebar */}
            <Box
              style={{
                width: '280px',
                borderLeft: `1px solid ${C.border}`,
                background: C.panel,
                padding: '10px',
                flexShrink: 0,
              }}
            >
              <TermHeader>SCIPNET</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '10px',
                  lineHeight: '1.6',
                  marginBottom: '12px',
                })}
              >
                <Box style={{ color: C.redBright }}>COUNTRY: [REDACTED]</Box>
                <Box style={{ color: C.redBright }}>REGION: [REDACTED]</Box>
                <Box style={{ color: C.redBright }}>IP: [REDACTED]</Box>
              </Box>

              <TermDivider />

              <TermHeader>SYSTEM OVERVIEW</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '10px',
                  lineHeight: '1.6',
                })}
              >
                <Box>
                  <StatusDot online={!!facility_data} /> FACILITY:{' '}
                  {facility_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!scp_data} /> SCP:{' '}
                  {scp_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!technology_data} /> TECH:{' '}
                  {technology_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!medical_data} /> MEDICAL:{' '}
                  {medical_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!security_data} /> SECURITY:{' '}
                  {security_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!research_data} /> RESEARCH:{' '}
                  {research_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!chemical_data} /> CHEMICAL:{' '}
                  {chemical_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!incident_data} /> INCIDENT:{' '}
                  {incident_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!psychological_data} /> PSYCH:{' '}
                  {psychological_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!infrastructure_data} /> INFRA:{' '}
                  {infrastructure_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!analytics_data} /> ANALYTICS:{' '}
                  {analytics_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!personnel_data} /> PERSONNEL:{' '}
                  {personnel_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!player_data} /> PLAYERS:{' '}
                  {player_data ? 'LIVE' : 'OFFLINE'}
                </Box>
              </Box>

              <TermDivider />

              <TermHeader>KEY METRICS</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '10px',
                  lineHeight: '1.6',
                })}
              >
                <Box>
                  ACTIVE THREATS:{' '}
                  {security_data?.active_threats ?? 0}
                </Box>
                <Box>
                  OUTBREAKS:{' '}
                  {medical_data?.active_outbreaks ?? 0}
                </Box>
                <Box>
                  BREACHES:{' '}
                  {incident_data?.active_incidents ?? 0}
                </Box>
                <Box>
                  STAFF:{' '}
                  {personnel_data?.active_staff ?? 0}
                </Box>
                <Box>
                  PROJECTS:{' '}
                  {research_data?.total_research_projects ?? 0}
                </Box>
                <Box>
                  PLAYERS:{' '}
                  {player_data?.total_players ?? 0}
                </Box>
              </Box>

              <TermDivider />

              <TermHeader>LIVE ALERTS</TermHeader>
              <Box
                style={{
                  padding: '6px 8px',
                  borderLeft: `2px solid ${C.green}`,
                  background: 'rgba(26,122,26,0.15)',
                }}
              >
                <Box style={term({ color: C.green, fontSize: '10px' })}>
                  ALL SYSTEMS OPERATIONAL
                </Box>
              </Box>

              <TermDivider />

              <TermHeader>TERMINAL</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '9px',
                  lineHeight: '1.6',
                })}
              >
                <Box>LINK: NOMINAL</Box>
                <Box>NET: SECURE</Box>
                <Box>CRYPTO: AES-512</Box>
                <Box>
                  STATUS:{' '}
                  <Box as="span" style={{ color: C.green }}>
                    ONLINE
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>

          {/* FOOTER */}
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
              SCP FOUNDATION | PERSISTENCE CONTROL | ALL ACTIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
