import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button } from '../components';
import { NtosWindow } from '../layouts';

type CameraInfo = {
  area: string;
  name: string;
  network: string;
  ref: string;
  status: string;
};

type AlertEntry = {
  text: string;
  time: string;
};

type CameraConsoleData = {
  alerts: AlertEntry[];
  anomaly_detection: BooleanLike;
  broken_count: number;
  camera_count: number;
  cameras: CameraInfo[];
  current_zone: string;
  motion_detection: BooleanLike;
  zones: string[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

export const SCPCameraConsole = (props) => {
  const { act, data } = useBackend<CameraConsoleData>();
  const [selectedTab, setSelectedTab] = useLocalState<string>(
    'camTab',
    'cameras',
  );
  const {
    current_zone,
    zones,
    cameras,
    camera_count,
    broken_count,
    motion_detection,
    anomaly_detection,
    alerts,
  } = data;

  return (
    <NtosWindow width={600} height={550}>
      <NtosWindow.Content scrollable>
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
              background:
                'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              SCP CAMERA MONITORING
            </Box>
            <Box
              style={{
                fontSize: '11px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              {camera_count} FEEDS | {broken_count} OFFLINE | ZONE:{' '}
              {current_zone?.toUpperCase() || 'ALL'}
            </Box>
          </Box>

          <Box
            style={{
              display: 'flex',
              borderBottom: `1px solid ${C.borderRed}`,
              overflowX: 'auto',
              background: C.panel,
              marginBottom: '8px',
            }}
          >
            {zones?.map((zone) => (
              <Box
                key={zone}
                style={{
                  padding: '5px 10px',
                  cursor: 'pointer',
                  background:
                    current_zone === zone
                      ? 'rgba(139,0,0,0.25)'
                      : 'transparent',
                  borderRight: `1px solid ${C.border}`,
                  borderBottom:
                    current_zone === zone
                      ? `2px solid ${C.amber}`
                      : '2px solid transparent',
                  color:
                    current_zone === zone ? C.textBright : C.textDim,
                  fontSize: '11px',
                  letterSpacing: '0.1em',
                  textTransform: 'uppercase',
                  fontFamily: C.mono,
                  whiteSpace: 'nowrap',
                }}
                onClick={() => act('set_zone', { zone })}
              >
                {zone}
              </Box>
            ))}
          </Box>

          <Box style={{ padding: '0 14px' }}>
            <Box style={{ display: 'flex', gap: '6px', marginBottom: '10px' }}>
              <Button
                onClick={() => act('toggle_motion')}
                style={{
                  fontFamily: C.mono,
                  fontSize: '11px',
                  letterSpacing: '0.1em',
                  background: motion_detection
                    ? 'rgba(26,122,26,0.3)'
                    : 'transparent',
                  border: `1px solid ${motion_detection ? C.green : C.border}`,
                  borderRadius: 0,
                  color: motion_detection ? C.textBright : C.textDim,
                  padding: '3px 8px',
                }}
              >
                MOTION [ON/OFF]
              </Button>
              <Button
                onClick={() => act('toggle_anomaly')}
                style={{
                  fontFamily: C.mono,
                  fontSize: '11px',
                  letterSpacing: '0.1em',
                  background: anomaly_detection
                    ? 'rgba(212,160,23,0.3)'
                    : 'transparent',
                  border: `1px solid ${anomaly_detection ? C.amber : C.border}`,
                  borderRadius: 0,
                  color: anomaly_detection ? C.textBright : C.textDim,
                  padding: '3px 8px',
                }}
              >
                ANOMALY [ON/OFF]
              </Button>
            </Box>

            <Box
              style={{
                fontSize: '10px',
                color: C.textDim,
                letterSpacing: '0.18em',
                textTransform: 'uppercase',
                borderBottom: `1px solid ${C.border}`,
                paddingBottom: '4px',
                marginBottom: '8px',
              }}
            >
              CAMERA FEEDS
            </Box>

            {(cameras || []).length > 0 ? (
              cameras.map((cam) => (
                <Box
                  key={cam.ref}
                  style={{
                    marginBottom: '3px',
                    padding: '5px 8px',
                    borderLeft: `2px solid ${cam.status === 'active' ? C.green : C.redBright}`,
                    background: C.panel,
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                  }}
                >
                  <Box>
                    <Box
                      style={{
                        color:
                          cam.status === 'active'
                            ? C.textBright
                            : C.textDim,
                        fontSize: '11px',
                        fontWeight: 'bold',
                      }}
                    >
                      {cam.name}
                    </Box>
                    <Box
                      style={{
                        color: C.textDim,
                        fontSize: '11px',
                      }}
                    >
                      {cam.area} | {cam.network}
                    </Box>
                  </Box>
                  <Button
                    disabled={cam.status !== 'active'}
                    onClick={() =>
                      act('view_camera', { ref: cam.ref })
                    }
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      letterSpacing: '0.1em',
                      background:
                        cam.status === 'active'
                          ? 'rgba(139,0,0,0.2)'
                          : 'transparent',
                      border: `1px solid ${cam.status === 'active' ? C.borderRed : C.border}`,
                      borderRadius: 0,
                      color:
                        cam.status === 'active'
                          ? C.textBright
                          : C.textDim,
                      padding: '4px 8px',
                    }}
                  >
                    VIEW
                  </Button>
                </Box>
              ))
            ) : (
              <Box
                style={{
                  color: C.textDim,
                  fontStyle: 'italic',
                  fontSize: '11px',
                }}
              >
                NO CAMERAS IN ZONE
              </Box>
            )}

            {(alerts || []).length > 0 && (
              <>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginTop: '12px',
                    marginBottom: '8px',
                  }}
                >
                  ALERTS
                </Box>
                {alerts.map((alert, idx) => (
                  <Box
                    key={`alert-${idx}`}
                    style={{
                      marginBottom: '2px',
                      padding: '3px 6px',
                      borderLeft: `2px solid ${C.amber}`,
                      background: C.panel,
                      fontSize: '10px',
                      display: 'flex',
                      gap: '6px',
                    }}
                  >
                    <Box
                      style={{ color: C.textDim, whiteSpace: 'nowrap' }}
                    >
                      [{alert.time}]
                    </Box>
                    <Box style={{ color: C.text }}>{alert.text}</Box>
                  </Box>
                ))}
              </>
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
              style={{
                color: C.textDim,
                fontSize: '11px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | CAMERA MONITORING | ALL FEEDS RECORDED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
