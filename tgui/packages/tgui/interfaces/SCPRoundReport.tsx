import { useState } from 'react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type LogEntry = {
  cause?: string;
  duration?: number;
  experiment?: string;
  participants?: string[];
  points?: number;
  reason?: string;
  researcher?: string;
  scp_id?: string;
  time?: number;
  victim?: string;
  zone?: string;
};

type AreaDamage = {
  area: string;
  damage: number;
};

type RoundReportData = {
  breach_log: LogEntry[];
  casualty_log: LogEntry[];
  classification: string;
  containment_rate: number;
  damage_rating: string;
  damage_score: number;
  doors_destroyed: number;
  facility_stability_low: number;
  facility_stability_peak: number;
  final_stability: number;
  floors_destroyed: number;
  lockdown_log: LogEntry[];
  machines_destroyed: number;
  recontainment_log: LogEntry[];
  research_log: LogEntry[];
  round_duration: string;
  round_id: string;
  total_breaches: number;
  total_casualties: number;
  total_recontainments: number;
  total_research_points: number;
  walls_destroyed: number;
  windows_broken: number;
  worst_areas: AreaDamage[];
};

const C = {
  bg: '#0a0a0c',
  bgDark: '#050508',
  panel: '#111114',
  border: '#2a2a30',
  red: '#8b0000',
  darkRed: '#5c0000',
  amber: '#d4a017',
  green: '#0a6e0a',
  brightGreen: '#44ff44',
  blue: '#44aaff',
  orange: '#ff8844',
  text: '#c8c8c8',
  dim: '#6a6a70',
  highlight: '#e8e8e8',
};

const formatTime = (ticks?: number): string => {
  if (!ticks) return '00:00:00';
  const totalSeconds = Math.floor(ticks / 10);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
};

const stabilityColor = (val: number): string => {
  if (val >= 70) return C.brightGreen;
  if (val >= 40) return C.amber;
  return '#ff3333';
};

const classificationColor = (cls: string): string => {
  if (cls.startsWith('NOMINAL')) return C.brightGreen;
  if (cls.startsWith('ELEVATED')) return C.amber;
  if (cls.startsWith('CRITICAL')) return '#ff3333';
  return '#ff0000';
};

const TabButton = (props: {
  active: boolean;
  count?: number;
  label: string;
  onClick: () => void;
}) => {
  const { label, active, count, onClick } = props;
  return (
    <button
      type="button"
      onClick={onClick}
      style={{
        background: active ? C.darkRed : 'transparent',
        border: `1px solid ${active ? C.red : C.border}`,
        color: active ? C.highlight : C.dim,
        padding: '6px 12px',
        cursor: 'pointer',
        fontFamily: 'Consolas, monospace',
        fontSize: '11px',
        fontWeight: active ? 'bold' : 'normal',
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        transition: 'all 0.15s',
      }}
    >
      {label}
      {count !== undefined && count > 0 && (
        <span
          style={{
            marginLeft: '6px',
            color: active ? C.amber : C.dim,
            fontSize: '10px',
          }}
        >
          [{count}]
        </span>
      )}
    </button>
  );
};

const LogSection = (props: {
  children: (entry: LogEntry, idx: number) => React.ReactNode;
  color: string;
  entries: LogEntry[];
  icon: string;
  title: string;
}) => {
  const { title, color, icon, entries, children } = props;
  return (
    <div style={{ marginBottom: '16px' }}>
      <div
        style={{
          fontSize: '13px',
          fontWeight: 'bold',
          color: color,
          borderBottom: `1px solid ${color}`,
          paddingBottom: '4px',
          marginBottom: '8px',
          fontFamily: 'Consolas, monospace',
          letterSpacing: '0.08em',
        }}
      >
        {icon} {title}
      </div>
      {entries.length === 0 && (
        <div
          style={{
            color: C.dim,
            fontSize: '11px',
            fontStyle: 'italic',
            padding: '8px 0',
            fontFamily: 'Consolas, monospace',
          }}
        >
          NO RECORDS FOUND
        </div>
      )}
      {entries.map((entry, idx) => children(entry, idx))}
    </div>
  );
};

export const SCPRoundReport = (_props: unknown) => {
  const { act, data } = useBackend<RoundReportData>();
  const [activeTab, setActiveTab] = useState('summary');

  const {
    round_id = 'N/A',
    round_duration = 'N/A',
    total_breaches = 0,
    total_recontainments = 0,
    total_casualties = 0,
    total_research_points = 0,
    final_stability = 100,
    facility_stability_peak = 100,
    facility_stability_low = 100,
    classification = 'UNKNOWN',
    containment_rate = 100,
    breach_log = [],
    recontainment_log = [],
    casualty_log = [],
    research_log = [],
    lockdown_log = [],
    damage_rating = 'INTACT',
    damage_score = 0,
    walls_destroyed = 0,
    floors_destroyed = 0,
    windows_broken = 0,
    doors_destroyed = 0,
    machines_destroyed = 0,
    worst_areas = [],
  } = data;

  return (
    <Window theme="scp_terminal" width={750} height={620}>
      <Window.Content scrollable>
        <div
          style={{
            background: C.bg,
            padding: '16px',
            fontFamily: 'Consolas, monospace',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <div
            style={{
              borderBottom: `2px solid ${C.red}`,
              paddingBottom: '10px',
              marginBottom: '14px',
            }}
          >
            <div
              style={{
                fontSize: '18px',
                fontWeight: 'bold',
                color: C.red,
                textAlign: 'center',
                letterSpacing: '0.12em',
              }}
            >
              SCP FOUNDATION — SITE-53 ROUND REPORT
            </div>
            <div
              style={{
                fontSize: '11px',
                color: C.dim,
                textAlign: 'center',
                marginTop: '4px',
                letterSpacing: '0.05em',
              }}
            >
              REPORT ID: {round_id} &nbsp;|&nbsp; DURATION: {round_duration}
            </div>
          </div>

          <div
            style={{
              border: `1px solid ${classificationColor(classification)}`,
              background: `${classificationColor(classification)}11`,
              padding: '10px',
              marginBottom: '14px',
              textAlign: 'center',
            }}
          >
            <div
              style={{
                fontSize: '10px',
                color: C.dim,
                letterSpacing: '0.1em',
                marginBottom: '4px',
              }}
            >
              FACILITY CLASSIFICATION
            </div>
            <div
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: classificationColor(classification),
                letterSpacing: '0.05em',
              }}
            >
              {classification}
            </div>
          </div>

          <div
            style={{
              display: 'flex',
              gap: '6px',
              marginBottom: '14px',
              flexWrap: 'wrap',
            }}
          >
            <TabButton
              label="Summary"
              active={activeTab === 'summary'}
              onClick={() => setActiveTab('summary')}
            />
            <TabButton
              label="Breaches"
              active={activeTab === 'breaches'}
              count={breach_log.length}
              onClick={() => setActiveTab('breaches')}
            />
            <TabButton
              label="Recontainment"
              active={activeTab === 'recontainment'}
              count={recontainment_log.length}
              onClick={() => setActiveTab('recontainment')}
            />
            <TabButton
              label="Casualties"
              active={activeTab === 'casualties'}
              count={casualty_log.length}
              onClick={() => setActiveTab('casualties')}
            />
            <TabButton
              label="Research"
              active={activeTab === 'research'}
              count={research_log.length}
              onClick={() => setActiveTab('research')}
            />
            <TabButton
              label="Lockdowns"
              active={activeTab === 'lockdowns'}
              count={lockdown_log.length}
              onClick={() => setActiveTab('lockdowns')}
            />
            <TabButton
              label="Damage"
              active={activeTab === 'damage'}
              onClick={() => setActiveTab('damage')}
            />
          </div>

          {activeTab === 'summary' && (
            <div>
              <div
                style={{
                  display: 'flex',
                  gap: '10px',
                  marginBottom: '14px',
                  flexWrap: 'wrap',
                }}
              >
                <div
                  style={{
                    flex: '1',
                    minWidth: '140px',
                    padding: '10px',
                    border: `1px solid ${C.border}`,
                    background: C.panel,
                  }}
                >
                  <div
                    style={{
                      fontSize: '10px',
                      color: C.dim,
                      letterSpacing: '0.08em',
                    }}
                  >
                    CONTAINMENT RATE
                  </div>
                  <div
                    style={{
                      fontSize: '22px',
                      color: stabilityColor(containment_rate),
                      fontWeight: 'bold',
                    }}
                  >
                    {containment_rate}%
                  </div>
                </div>
                <div
                  style={{
                    flex: '1',
                    minWidth: '140px',
                    padding: '10px',
                    border: `1px solid ${C.border}`,
                    background: C.panel,
                  }}
                >
                  <div
                    style={{
                      fontSize: '10px',
                      color: C.dim,
                      letterSpacing: '0.08em',
                    }}
                  >
                    FACILITY STABILITY
                  </div>
                  <div
                    style={{
                      fontSize: '22px',
                      color: stabilityColor(final_stability),
                      fontWeight: 'bold',
                    }}
                  >
                    {final_stability}%
                  </div>
                  <div
                    style={{
                      fontSize: '10px',
                      color: C.dim,
                      marginTop: '2px',
                    }}
                  >
                    PEAK: {facility_stability_peak}% &nbsp; LOW:{' '}
                    {facility_stability_low}%
                  </div>
                </div>
                <div
                  style={{
                    flex: '1',
                    minWidth: '140px',
                    padding: '10px',
                    border: `1px solid ${C.border}`,
                    background: C.panel,
                  }}
                >
                  <div
                    style={{
                      fontSize: '10px',
                      color: C.dim,
                      letterSpacing: '0.08em',
                    }}
                  >
                    RESEARCH POINTS
                  </div>
                  <div
                    style={{
                      fontSize: '22px',
                      color: C.blue,
                      fontWeight: 'bold',
                    }}
                  >
                    {total_research_points}
                  </div>
                </div>
              </div>

              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: '1fr 1fr',
                  gap: '8px',
                }}
              >
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: `3px solid #ff3333`,
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    TOTAL BREACHES
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: '#ff3333',
                      fontWeight: 'bold',
                    }}
                  >
                    {total_breaches}
                  </div>
                </div>
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: `3px solid ${C.brightGreen}`,
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    RECONTAINMENTS
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: C.brightGreen,
                      fontWeight: 'bold',
                    }}
                  >
                    {total_recontainments}
                  </div>
                </div>
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: `3px solid ${C.orange}`,
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    CASUALTIES
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: C.orange,
                      fontWeight: 'bold',
                    }}
                  >
                    {total_casualties}
                  </div>
                </div>
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: `3px solid ${C.amber}`,
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    LOCKDOWNS
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: C.amber,
                      fontWeight: 'bold',
                    }}
                  >
                    {lockdown_log.length}
                  </div>
                </div>
              </div>

              <div
                style={{
                  marginTop: '14px',
                  padding: '10px',
                  border: `1px solid ${C.border}`,
                  background: C.panel,
                }}
              >
                <div
                  style={{
                    fontSize: '10px',
                    color: C.dim,
                    letterSpacing: '0.08em',
                    marginBottom: '6px',
                  }}
                >
                  STABILITY TIMELINE
                </div>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                  }}
                >
                  <span
                    style={{ fontSize: '11px', color: C.dim, minWidth: '30px' }}
                  >
                    0%
                  </span>
                  <div
                    style={{
                      flex: '1',
                      height: '12px',
                      background: C.bgDark,
                      border: `1px solid ${C.border}`,
                      position: 'relative',
                    }}
                  >
                    <div
                      style={{
                        position: 'absolute',
                        left: 0,
                        top: 0,
                        height: '100%',
                        width: `${final_stability}%`,
                        background: stabilityColor(final_stability),
                        opacity: 0.7,
                      }}
                    />
                    {facility_stability_peak !== facility_stability_low && (
                      <div
                        style={{
                          position: 'absolute',
                          left: `${facility_stability_low}%`,
                          top: 0,
                          height: '100%',
                          width: `${facility_stability_peak - facility_stability_low}%`,
                          background: C.amber,
                          opacity: 0.2,
                        }}
                      />
                    )}
                  </div>
                  <span
                    style={{ fontSize: '11px', color: C.dim, minWidth: '40px' }}
                  >
                    100%
                  </span>
                </div>
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    fontSize: '9px',
                    color: C.dim,
                    marginTop: '4px',
                    paddingLeft: '38px',
                    paddingRight: '48px',
                  }}
                >
                  <span>LOW: {facility_stability_low}%</span>
                  <span>CURRENT: {final_stability}%</span>
                  <span>PEAK: {facility_stability_peak}%</span>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'breaches' && (
            <LogSection
              title="CONTAINMENT BREACHES"
              color="#ff3333"
              icon="▲"
              entries={breach_log}
            >
              {(entry, idx) => (
                <div
                  key={idx}
                  style={{
                    padding: '6px 8px',
                    borderLeft: `3px solid #ff3333`,
                    background: C.panel,
                    marginBottom: '6px',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <span style={{ color: '#ff3333', fontWeight: 'bold' }}>
                      {entry.scp_id || 'UNKNOWN'}
                    </span>
                    <span style={{ color: C.dim, fontSize: '10px' }}>
                      {formatTime(entry.time)}
                    </span>
                  </div>
                  {entry.zone && (
                    <div style={{ color: C.amber, fontSize: '11px' }}>
                      ZONE: {entry.zone}
                    </div>
                  )}
                </div>
              )}
            </LogSection>
          )}

          {activeTab === 'recontainment' && (
            <LogSection
              title="SUCCESSFUL RECONTAINMENTS"
              color={C.brightGreen}
              icon="◆"
              entries={recontainment_log}
            >
              {(entry, idx) => (
                <div
                  key={idx}
                  style={{
                    padding: '6px 8px',
                    borderLeft: `3px solid ${C.brightGreen}`,
                    background: C.panel,
                    marginBottom: '6px',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <span style={{ color: C.brightGreen, fontWeight: 'bold' }}>
                      {entry.scp_id || 'UNKNOWN'}
                    </span>
                    <span style={{ color: C.dim, fontSize: '10px' }}>
                      {formatTime(entry.time)}
                    </span>
                  </div>
                  {entry.participants && entry.participants.length > 0 && (
                    <div style={{ color: C.dim, fontSize: '11px' }}>
                      PERSONNEL: {entry.participants.join(', ')}
                    </div>
                  )}
                </div>
              )}
            </LogSection>
          )}

          {activeTab === 'casualties' && (
            <LogSection
              title="CASUALTIES"
              color={C.orange}
              icon="✝"
              entries={casualty_log}
            >
              {(entry, idx) => (
                <div
                  key={idx}
                  style={{
                    padding: '6px 8px',
                    borderLeft: `3px solid ${C.orange}`,
                    background: C.panel,
                    marginBottom: '6px',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <span style={{ color: C.orange, fontWeight: 'bold' }}>
                      {entry.victim || 'UNKNOWN'}
                    </span>
                    <span style={{ color: C.dim, fontSize: '10px' }}>
                      {formatTime(entry.time)}
                    </span>
                  </div>
                  {entry.cause && (
                    <div style={{ color: C.text, fontSize: '11px' }}>
                      CAUSE: {entry.cause}
                    </div>
                  )}
                  {entry.zone && (
                    <div style={{ color: C.dim, fontSize: '11px' }}>
                      ZONE: {entry.zone}
                    </div>
                  )}
                </div>
              )}
            </LogSection>
          )}

          {activeTab === 'research' && (
            <LogSection
              title="RESEARCH COMPLETED"
              color={C.blue}
              icon="●"
              entries={research_log}
            >
              {(entry, idx) => (
                <div
                  key={idx}
                  style={{
                    padding: '6px 8px',
                    borderLeft: `3px solid ${C.blue}`,
                    background: C.panel,
                    marginBottom: '6px',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <span style={{ color: C.blue, fontWeight: 'bold' }}>
                      {entry.experiment || 'UNKNOWN'}
                    </span>
                    <span style={{ color: C.dim, fontSize: '10px' }}>
                      {formatTime(entry.time)}
                    </span>
                  </div>
                  <div
                    style={{
                      display: 'flex',
                      gap: '12px',
                      fontSize: '11px',
                      color: C.dim,
                    }}
                  >
                    {entry.scp_id && <span>SCP: {entry.scp_id}</span>}
                    {entry.points !== undefined && (
                      <span style={{ color: C.blue }}>+{entry.points} PTS</span>
                    )}
                    {entry.researcher && <span>BY: {entry.researcher}</span>}
                  </div>
                </div>
              )}
            </LogSection>
          )}

          {activeTab === 'lockdowns' && (
            <LogSection
              title="LOCKDOWNS ENACTED"
              color={C.amber}
              icon="■"
              entries={lockdown_log}
            >
              {(entry, idx) => (
                <div
                  key={idx}
                  style={{
                    padding: '6px 8px',
                    borderLeft: `3px solid ${C.amber}`,
                    background: C.panel,
                    marginBottom: '6px',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <span style={{ color: C.amber, fontWeight: 'bold' }}>
                      {entry.reason || 'UNKNOWN'}
                    </span>
                    <span style={{ color: C.dim, fontSize: '10px' }}>
                      {formatTime(entry.time)}
                    </span>
                  </div>
                  {entry.duration !== undefined && (
                    <div style={{ color: C.dim, fontSize: '11px' }}>
                      DURATION: {entry.duration}
                    </div>
                  )}
                </div>
              )}
            </LogSection>
          )}

          {activeTab === 'damage' && (
            <div>
              <div
                style={{
                  border: `1px solid ${damage_score > 150 ? '#ff3333' : damage_score > 50 ? C.amber : C.brightGreen}`,
                  background: `${damage_score > 150 ? '#ff333311' : damage_score > 50 ? `${C.amber}11` : `${C.brightGreen}11`}`,
                  padding: '10px',
                  marginBottom: '14px',
                  textAlign: 'center',
                }}
              >
                <div
                  style={{
                    fontSize: '10px',
                    color: C.dim,
                    letterSpacing: '0.1em',
                    marginBottom: '4px',
                  }}
                >
                  FACILITY DAMAGE RATING
                </div>
                <div
                  style={{
                    fontSize: '20px',
                    fontWeight: 'bold',
                    color:
                      damage_score > 150
                        ? '#ff3333'
                        : damage_score > 50
                          ? C.amber
                          : C.brightGreen,
                  }}
                >
                  {damage_rating}
                </div>
                <div
                  style={{ fontSize: '11px', color: C.dim, marginTop: '2px' }}
                >
                  DAMAGE SCORE: {damage_score}
                </div>
              </div>

              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: '1fr 1fr',
                  gap: '8px',
                  marginBottom: '14px',
                }}
              >
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: '3px solid #ff3333',
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    WALLS DESTROYED
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: '#ff3333',
                      fontWeight: 'bold',
                    }}
                  >
                    {walls_destroyed}
                  </div>
                </div>
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: `3px solid ${C.orange}`,
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    FLOORS DESTROYED
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: C.orange,
                      fontWeight: 'bold',
                    }}
                  >
                    {floors_destroyed}
                  </div>
                </div>
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: `3px solid ${C.amber}`,
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    WINDOWS BROKEN
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: C.amber,
                      fontWeight: 'bold',
                    }}
                  >
                    {windows_broken}
                  </div>
                </div>
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: `3px solid ${C.blue}`,
                    background: C.panel,
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    DOORS DESTROYED
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: C.blue,
                      fontWeight: 'bold',
                    }}
                  >
                    {doors_destroyed}
                  </div>
                </div>
                <div
                  style={{
                    padding: '8px 10px',
                    borderLeft: '3px solid #aa00ff',
                    background: C.panel,
                    gridColumn: '1 / -1',
                  }}
                >
                  <div style={{ fontSize: '10px', color: C.dim }}>
                    MACHINES DESTROYED
                  </div>
                  <div
                    style={{
                      fontSize: '18px',
                      color: '#aa00ff',
                      fontWeight: 'bold',
                    }}
                  >
                    {machines_destroyed}
                  </div>
                </div>
              </div>

              {worst_areas.length > 0 && (
                <div>
                  <div
                    style={{
                      fontSize: '13px',
                      fontWeight: 'bold',
                      color: '#ff3333',
                      borderBottom: '1px solid #ff3333',
                      paddingBottom: '4px',
                      marginBottom: '8px',
                      fontFamily: 'Consolas, monospace',
                      letterSpacing: '0.08em',
                    }}
                  >
                    ▲ MOST DAMAGED AREAS
                  </div>
                  {worst_areas.map((area, idx) => (
                    <div
                      key={idx}
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        padding: '6px 8px',
                        borderLeft: `3px solid ${idx < 2 ? '#ff3333' : C.amber}`,
                        background: C.panel,
                        marginBottom: '4px',
                      }}
                    >
                      <span style={{ color: C.text, fontSize: '12px' }}>
                        {area.area}
                      </span>
                      <span
                        style={{
                          color: idx < 2 ? '#ff3333' : C.amber,
                          fontSize: '12px',
                          fontWeight: 'bold',
                        }}
                      >
                        {area.damage} INCIDENTS
                      </span>
                    </div>
                  ))}
                </div>
              )}

              {damage_score === 0 && (
                <div
                  style={{
                    textAlign: 'center',
                    color: C.brightGreen,
                    padding: '20px',
                    fontSize: '13px',
                    letterSpacing: '0.08em',
                  }}
                >
                  NO STRUCTURAL DAMAGE RECORDED
                </div>
              )}
            </div>
          )}

          <div
            style={{
              marginTop: '20px',
              paddingTop: '10px',
              borderTop: `1px solid ${C.border}`,
              textAlign: 'center',
            }}
          >
            <div
              style={{
                fontSize: '10px',
                color: C.dim,
                letterSpacing: '0.1em',
              }}
            >
              SECURE. CONTAIN. PROTECT.
            </div>
            <div
              style={{
                fontSize: '9px',
                color: C.dim,
                marginTop: '4px',
                opacity: 0.5,
              }}
            >
              SCP FOUNDATION — SITE-53 — REPORT ID: {round_id}
            </div>
          </div>

          <div style={{ textAlign: 'center', marginTop: '12px' }}>
            <button
              type="button"
              onClick={() => act('close')}
              style={{
                background: C.darkRed,
                border: `1px solid ${C.red}`,
                color: C.highlight,
                padding: '8px 24px',
                cursor: 'pointer',
                fontFamily: 'Consolas, monospace',
                fontWeight: 'bold',
                fontSize: '12px',
                letterSpacing: '0.08em',
                textTransform: 'uppercase',
              }}
            >
              CLOSE REPORT
            </button>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
