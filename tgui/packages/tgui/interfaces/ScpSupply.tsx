import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Input } from '../components';
import { NtosWindow } from '../layouts';

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

const reqStatusColor = (status) => {
  switch (status) {
    case 0: return C.amber;
    case 1: return C.green;
    case 2: return '#00b5b5';
    case 3: return C.dim;
    case 4: return C.red;
    default: return C.dim;
  }
};

const reqStatusLabel = (status) => {
  switch (status) {
    case 0: return 'PENDING';
    case 1: return 'APPROVED';
    case 2: return 'SHIPPING';
    case 3: return 'DELIVERED';
    case 4: return 'REJECTED';
    default: return 'UNKNOWN';
  }
};

const priorityColor = (pri) => {
  if (pri <= 1) return C.green;
  if (pri === 2) return C.amber;
  return C.red;
};

const DEPARTMENTS = [
  { key: 'security', label: 'SECURITY', color: C.red },
  { key: 'medical', label: 'MEDICAL', color: '#00b5b5' },
  { key: 'science', label: 'SCIENCE', color: C.amber },
  { key: 'engineering', label: 'ENGINEERING', color: '#cc6600' },
  { key: 'logistics', label: 'LOGISTICS', color: C.green },
  { key: 'administration', label: 'ADMIN', color: C.highlight },
  { key: 'mtf', label: 'MTF', color: C.darkRed },
];

const ITEM_TYPES = [
  { key: 'equipment', label: 'EQUIPMENT' },
  { key: 'consumable', label: 'CONSUMABLE' },
  { key: 'anomalous', label: 'ANOMALOUS' },
  { key: 'restricted', label: 'RESTRICTED' },
];

export const ScpSupply = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    requisition_queue = [],
    active_shipments = [],
    delivery_log = [],
    screening_queue = [],
    supply_stats,
    total_requisitions_processed,
    total_deliveries_completed,
    total_screenings,
    total_contraband_caught,
    department_budgets = {},
  } = data;

  const [selDept, setSelDept] = useState('security');
  const [selItemType, setSelItemType] = useState('equipment');
  const [itemName, setItemName] = useState('');
  const [itemQty, setItemQty] = useState('1');
  const [itemPriority, setItemPriority] = useState(1);
  const [justification, setJustification] = useState('');

  const maxBudget = Math.max(...Object.values(department_budgets), 1);

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack justify="space-between" align="center">
                <Stack.Item>
                  <Box fontSize="18px" fontFamily="monospace" color={C.brightGreen} bold>
                    SCP SUPPLY OPERATIONS
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={2}>
                    <Box fontFamily="monospace" color={C.dim}>
                      PROCESSED: <Box as="span" color={C.highlight}>{total_requisitions_processed}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      DELIVERED: <Box as="span" color={C.brightGreen}>{total_deliveries_completed}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      SCREENED: <Box as="span" color="#00b5b5">{total_screenings}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      CONTRABAND: <Box as="span" color={C.red}>{total_contraband_caught}</Box>
                    </Box>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.amber}>
                  DEPARTMENT BUDGETS
                </Box>
              }
            >
              <Stack wrap gap={1}>
                {DEPARTMENTS.map((dept) => {
                  const budget = department_budgets[dept.key] || 0;
                  const pct = Math.max((budget / maxBudget) * 100, 0);
                  return (
                    <Stack.Item key={dept.key} grow basis="30%">
                      <Box
                        fontFamily="monospace"
                        backgroundColor={C.panel}
                        border={`1px solid ${C.border}`}
                        p={0.5}
                      >
                        <Box color={dept.color} bold fontSize="11px">{dept.label}</Box>
                        <Box
                          backgroundColor={C.bg}
                          height="8px"
                          mt={0.5}
                          position="relative"
                        >
                          <Box
                            backgroundColor={budget > 0 ? dept.color : C.red}
                            height="100%"
                            width={`${pct}%`}
                          />
                        </Box>
                        <Box color={C.text} fontSize="11px" mt={0.5}>{budget} CR</Box>
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.amber}>
                  REQUISITION QUEUE
                </Box>
              }
            >
              {requisition_queue.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO PENDING REQUISITIONS
                </Box>
              )}
              {requisition_queue.map((req) => (
                <Box key={req.requisition_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item grow>
                      <Stack vertical>
                        <Stack.Item>
                          <Stack gap={1} align="center">
                            <Box fontFamily="monospace" color={C.dim} bold>
                              #{req.requisition_id}
                            </Box>
                            <Box fontFamily="monospace" color={C.dim}>|</Box>
                            <Box fontFamily="monospace" color={C.text}>{req.requestor}</Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={
                                (DEPARTMENTS.find((d) => d.key === req.department) || {}).color || C.dim
                              }
                              color={C.bg}
                              px={1}
                              bold
                              fontSize="11px"
                            >
                              {(DEPARTMENTS.find((d) => d.key === req.department) || {}).label || req.department}
                            </Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={reqStatusColor(req.status)}
                              color={C.bg}
                              px={1}
                              bold
                              fontSize="11px"
                            >
                              {reqStatusLabel(req.status)}
                            </Box>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack gap={2}>
                            <Box fontFamily="monospace" color={C.text}>
                              {req.item_name} x{req.quantity}
                            </Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={priorityColor(req.priority)}
                              color={C.bg}
                              px={1}
                              fontSize="11px"
                            >
                              P{req.priority}
                            </Box>
                            <Box fontFamily="monospace" color={C.amber}>{req.budget_cost} CR</Box>
                            {req.requires_screening === 1 && (
                              <Box
                                fontFamily="monospace"
                                backgroundColor={C.red}
                                color={C.highlight}
                                px={1}
                                fontSize="11px"
                                bold
                              >
                                SCREENING REQ
                              </Box>
                            )}
                          </Stack>
                        </Stack.Item>
                        {req.justification && (
                          <Stack.Item>
                            <Box fontFamily="monospace" color={C.dim} italic fontSize="11px">
                              {req.justification}
                            </Box>
                          </Stack.Item>
                        )}
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      {req.status === 0 && (
                        <Stack vertical gap={0.5}>
                          <Button
                            fontFamily="monospace"
                            backgroundColor={C.green}
                            color={C.highlight}
                            content="APPROVE"
                            onClick={() => act('approve_requisition', { requisition_id: req.requisition_id })}
                          />
                          <Button
                            fontFamily="monospace"
                            backgroundColor={C.red}
                            color={C.highlight}
                            content="REJECT"
                            onClick={() => act('reject_requisition', { requisition_id: req.requisition_id })}
                          />
                        </Stack>
                      )}
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.red}>
                  SCREENING QUEUE
                </Box>
              }
            >
              {screening_queue.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO ITEMS AWAITING SCREENING
                </Box>
              )}
              {screening_queue.map((req) => (
                <Box key={req.requisition_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item>
                      <Stack gap={1} align="center">
                        <Box fontFamily="monospace" color={C.dim} bold>#{req.requisition_id}</Box>
                        <Box fontFamily="monospace" color={C.dim}>|</Box>
                        <Box fontFamily="monospace" color={C.text}>{req.item_name}</Box>
                        <Box fontFamily="monospace" color={C.dim}>|</Box>
                        <Box fontFamily="monospace" color={C.text}>{req.requestor}</Box>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack gap={0.5}>
                        <Button
                          fontFamily="monospace"
                          backgroundColor={C.green}
                          color={C.highlight}
                          content="PASS"
                          onClick={() => act('screen_delivery', {
                            requisition_id: req.requisition_id,
                            passed: 1,
                          })}
                        />
                        <Button
                          fontFamily="monospace"
                          backgroundColor={C.red}
                          color={C.highlight}
                          content="FAIL"
                          onClick={() => act('screen_delivery', {
                            requisition_id: req.requisition_id,
                            passed: 0,
                          })}
                        />
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color="#00b5b5">
                  ACTIVE SHIPMENTS
                </Box>
              }
            >
              {active_shipments.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO ACTIVE SHIPMENTS
                </Box>
              )}
              {active_shipments.map((ship) => (
                <Box key={ship.requisition_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} bold>#{ship.requisition_id}</Box>
                    <Box fontFamily="monospace" color={C.dim}>|</Box>
                    <Box fontFamily="monospace" color={C.text}>{ship.item_name} x{ship.quantity}</Box>
                    <Box fontFamily="monospace" color={C.dim}>|</Box>
                    <Box
                      fontFamily="monospace"
                      backgroundColor={reqStatusColor(ship.status)}
                      color={C.bg}
                      px={1}
                      fontSize="11px"
                    >
                      {reqStatusLabel(ship.status)}
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>|</Box>
                    <Box fontFamily="monospace" color={C.text}>{ship.department}</Box>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.brightGreen}>
                  SUBMIT REQUISITION
                </Box>
              }
            >
              <Stack vertical gap={1}>
                <Stack.Item>
                  <Stack gap={0.5} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">DEPT:</Box>
                    {DEPARTMENTS.map((dept) => (
                      <Button
                        key={dept.key}
                        fontFamily="monospace"
                        fontSize="11px"
                        backgroundColor={selDept === dept.key ? dept.color : C.panel}
                        color={selDept === dept.key ? C.bg : C.dim}
                        content={dept.label}
                        onClick={() => setSelDept(dept.key)}
                      />
                    ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={0.5} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">TYPE:</Box>
                    {ITEM_TYPES.map((it) => (
                      <Button
                        key={it.key}
                        fontFamily="monospace"
                        fontSize="11px"
                        backgroundColor={selItemType === it.key ? C.amber : C.panel}
                        color={selItemType === it.key ? C.bg : C.dim}
                        content={it.label}
                        onClick={() => setSelItemType(it.key)}
                      />
                    ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">ITEM:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={itemName}
                      onInput={(_e, val) => setItemName(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">QTY:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={itemQty}
                      onInput={(_e, val) => setItemQty(val)}
                      width="80px"
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={0.5} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">PRIORITY:</Box>
                    {[1, 2, 3].map((pri) => (
                      <Button
                        key={pri}
                        fontFamily="monospace"
                        backgroundColor={itemPriority === pri ? priorityColor(pri) : C.panel}
                        color={itemPriority === pri ? C.bg : C.dim}
                        content={`P${pri}`}
                        onClick={() => setItemPriority(pri)}
                      />
                    ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="100px">REASON:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={justification}
                      onInput={(_e, val) => setJustification(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fontFamily="monospace"
                    backgroundColor={C.brightGreen}
                    color={C.bg}
                    bold
                    content="SUBMIT REQUISITION"
                    fluid
                    onClick={() => {
                      act('submit_requisition', {
                        department: selDept,
                        item_type: selItemType,
                        item_name: itemName,
                        quantity: itemQty,
                        priority: itemPriority,
                        justification: justification,
                      });
                      setItemName('');
                      setItemQty('1');
                      setItemPriority(1);
                      setJustification('');
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          {delivery_log.length > 0 && (
            <Stack.Item>
              <Section
                title={
                  <Box fontFamily="monospace" color={C.dim}>
                    DELIVERY LOG
                  </Box>
                }
              >
                {delivery_log.slice(0, 10).map((entry, i) => (
                  <Box key={i} py={0.5} borderBottom={`1px solid ${C.border}`}>
                    <Stack gap={1} align="center">
                      <Box fontFamily="monospace" color={C.dim}>#{entry.requisition_id}</Box>
                      <Box fontFamily="monospace" color={C.dim}>|</Box>
                      <Box fontFamily="monospace" color={C.text}>{entry.item_name}</Box>
                      <Box fontFamily="monospace" color={C.dim}>|</Box>
                      <Box fontFamily="monospace" color={C.text}>{entry.department}</Box>
                      <Box fontFamily="monospace" color={C.dim}>|</Box>
                      <Box fontFamily="monospace" color={C.brightGreen}>DELIVERED</Box>
                    </Stack>
                  </Box>
                ))}
              </Section>
            </Stack.Item>
          )}

          {supply_stats && (
            <Stack.Item>
              <Section
                title={
                  <Box fontFamily="monospace" color={C.dim}>
                    SUPPLY STATISTICS
                  </Box>
                }
              >
                <Stack gap={2} wrap>
                  <Box fontFamily="monospace" color={C.dim}>
                    Requisitions: <Box as="span" color={C.text}>{supply_stats.total_requisitions}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Deliveries: <Box as="span" color={C.brightGreen}>{supply_stats.total_deliveries}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Screenings: <Box as="span" color="#00b5b5">{supply_stats.total_screenings}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Contraband: <Box as="span" color={C.red}>{supply_stats.total_contraband}</Box>
                  </Box>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
