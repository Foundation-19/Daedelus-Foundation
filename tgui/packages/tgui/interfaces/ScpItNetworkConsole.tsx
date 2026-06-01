import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  nodes: NetworkNode[];
  racks: ServerRack[];
  overall_integrity: number;
  scp079_presence: number;
  last_scan: number;
};

type NetworkNode = {
  node_id: string;
  name: string;
  area: string;
  status: string;
  status_num: number;
  integrity: number;
  scp079_influence: number;
  last_maintenance: number;
};

type ServerRack = {
  rack_id: string;
  name: string;
  area: string;
  temperature: number;
  cpu: number;
  memory: number;
  storage: number;
  firewall: number;
  maintenance_required: BooleanLike;
  last_maintenance: number;
};

const NODE_STATUS_COLORS: Record<number, string> = {
  0: '#cc2222',
  1: '#44ff44',
  2: '#d4a017',
  3: '#cc2222',
};

export const ScpItNetworkConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { nodes, racks, overall_integrity, scp079_presence, last_scan } = data;

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="IT NETWORK MANAGEMENT">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            NETWORK INTEGRITY: <Box as="span" style={{ color: overall_integrity > 70 ? '#44ff44' : overall_integrity > 40 ? '#d4a017' : '#cc2222', fontWeight: 'bold' }}>{overall_integrity}%</Box>
            {scp079_presence > 0 && (
              <Box as="span" style={{ color: scp079_presence > 50 ? '#cc2222' : '#d4a017', marginLeft: '16px' }}>
                SCP-079 PRESENCE: {Math.round(scp079_presence)}%
              </Box>
            )}
          </Box>
          <Box style={{ display: 'flex', gap: '6px', marginBottom: '8px' }}>
            <Button
              onClick={() => act('network_scan')}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '4px 12px' }}
            >
              RUN NETWORK SCAN
            </Button>
            {scp079_presence > 0 && (
              <Button
                onClick={() => act('counter_scp079')}
                style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '4px 12px' }}
              >
                DEPLOY SCP-079 COUNTERMEASURES
              </Button>
            )}
          </Box>
        </Section>

        <Section title="NETWORK NODES">
          {nodes.map((n) => (
            <Box key={n.node_id} style={{ padding: '8px', marginBottom: '4px', borderLeft: `2px solid ${NODE_STATUS_COLORS[n.status_num] || '#6a6a70'}`, background: '#111114' }}>
              <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Box>
                  <Box style={{ color: NODE_STATUS_COLORS[n.status_num], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                    {n.name} — {n.status}
                  </Box>
                  <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                    Area: {n.area} | Integrity: {n.integrity}%
                  </Box>
                  {n.scp079_influence > 0 && (
                    <Box style={{ fontSize: '10px', color: n.scp079_influence > 50 ? '#cc2222' : '#d4a017' }}>
                      SCP-079 Influence: {Math.round(n.scp079_influence)}%
                    </Box>
                  )}
                </Box>
                {n.integrity < 100 && (
                  <Button
                    onClick={() => act('repair_node', { node_id: n.node_id })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                  >
                    REPAIR
                  </Button>
                )}
              </Box>
            </Box>
          ))}
        </Section>

        <Section title="SERVER RACKS">
          {racks.map((r) => (
            <Box key={r.rack_id} style={{ padding: '8px', marginBottom: '4px', borderLeft: `2px solid ${r.maintenance_required ? '#d4a017' : '#44ff44'}`, background: '#111114' }}>
              <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Box>
                  <Box style={{ color: r.maintenance_required ? '#d4a017' : '#44ff44', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                    {r.name} {r.maintenance_required ? '[MAINTENANCE REQUIRED]' : ''}
                  </Box>
                  <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                    Area: {r.area} | Temp: {r.temperature}°C | Firewall: {Math.round(r.firewall)}%
                  </Box>
                </Box>
                <Box style={{ display: 'flex', gap: '4px' }}>
                  {r.maintenance_required && (
                    <Button
                      onClick={() => act('maintain_rack', { rack_id: r.rack_id })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                    >
                      MAINTAIN
                    </Button>
                  )}
                  <Button
                    onClick={() => act('reboot_firewall', { rack_id: r.rack_id })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '2px 8px' }}
                  >
                    FIREWALL REBOOT
                  </Button>
                </Box>
              </Box>
            </Box>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
