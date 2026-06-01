import React, { useState } from 'react';
import { useBackend, useLocalState } from '../backend';
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
  blue: '#4488ff',
};

const STATUS_LABELS = ['PENDING', 'ACCEPTED', 'IN PROGRESS', 'COMPLETED', 'OVERDUE'];

const STATUS_COLORS: Record<number, string> = {
  0: C.amber,
  1: C.blue,
  2: C.amber,
  3: C.green,
  4: C.red,
};

const DEPARTMENTS = [
  'Science',
  'Security',
  'Medical',
  'Engineering',
  'Logistics',
  'Administration',
  'MTF Operations',
];

const deptBorderColor = (review) => {
  if (!review) return C.border;
  if (review.overdue_directives > 0) return C.red;
  if (review.active_directives > 0) return C.amber;
  return C.green;
};

const deptGlowColor = (review) => {
  if (!review) return 'transparent';
  if (review.overdue_directives > 0) return C.red;
  if (review.active_directives > 0) return C.amber;
  return C.green;
};

export const ScpDirectorOversight = (_props, context) => {
  const { act, data } = useBackend(context);

  const {
    directive_queue = [],
    active_directives = [],
    completed_directives = [],
    total_directives_issued = 0,
    total_directives_completed = 0,
    total_overdue = 0,
    department_reviews = [],
  } = data;

  const [issueDept, setIssueDept] = useState('Science');
  const [issueType, setIssueType] = useState('');
  const [issueTarget, setIssueTarget] = useState('');
  const [issueDesc, setIssueDesc] = useState('');
  const [issueDeadline, setIssueDeadline] = useState('10');

  const getReview = (dept: string) =>
    department_reviews.find((r) => r.department === dept);

  const progressBar = (progress: number) => {
    const pct = Math.min(Math.max(progress, 0), 100);
    const barColor = pct >= 100 ? C.brightGreen : pct >= 50 ? C.amber : C.red;
    return (
      <Box
        style={{
          'background': C.bg,
          'border': `1px solid ${C.border}`,
          'border-radius': '2px',
          'height': '14px',
          'position': 'relative',
          'width': '100%',
        }}>
        <Box
          style={{
            'background': barColor,
            'height': '100%',
            'width': `${pct}%`,
            'transition': 'width 0.3s ease',
          }}
        />
        <Box
          style={{
            'color': C.highlight,
            'font-size': '10px',
            'left': '50%',
            'position': 'absolute',
            'top': '50%',
            'transform': 'translate(-50%, -50%)',
          }}>
          {pct}%
        </Box>
      </Box>
    );
  };

  return (
    <NtosWindow width={800} height={700} scrollable>
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              style={{
                'background': C.panel,
                'border': `1px solid ${C.border}`,
              }}>
              <Stack justify="space-between" align="center">
                <Stack.Item>
                  <Box
                    style={{
                      'color': C.amber,
                      'font-family': 'monospace',
                      'font-size': '18px',
                      'font-weight': 'bold',
                      'letter-spacing': '3px',
                    }}>
                    DIRECTOR OVERSIGHT CONSOLE
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={2}>
                    <Box
                      style={{
                        'background': C.bg,
                        'border': `1px solid ${C.border}`,
                        'padding': '4px 12px',
                        'text-align': 'center',
                      }}>
                      <Box style={{ 'color': C.dim, 'font-size': '10px' }}>
                        ISSUED
                      </Box>
                      <Box
                        style={{
                          'color': C.highlight,
                          'font-size': '16px',
                          'font-weight': 'bold',
                        }}>
                        {total_directives_issued}
                      </Box>
                    </Box>
                    <Box
                      style={{
                        'background': C.bg,
                        'border': `1px solid ${C.green}`,
                        'padding': '4px 12px',
                        'text-align': 'center',
                      }}>
                      <Box style={{ 'color': C.dim, 'font-size': '10px' }}>
                        COMPLETED
                      </Box>
                      <Box
                        style={{
                          'color': C.brightGreen,
                          'font-size': '16px',
                          'font-weight': 'bold',
                        }}>
                        {total_directives_completed}
                      </Box>
                    </Box>
                    <Box
                      style={{
                        'background': C.bg,
                        'border': `1px solid ${C.red}`,
                        'padding': '4px 12px',
                        'text-align': 'center',
                      }}>
                      <Box style={{ 'color': C.dim, 'font-size': '10px' }}>
                        OVERDUE
                      </Box>
                      <Box
                        style={{
                          'color': C.red,
                          'font-size': '16px',
                          'font-weight': 'bold',
                        }}>
                        {total_overdue}
                      </Box>
                    </Box>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="DEPARTMENT STATUS"
              style={{
                'background': C.panel,
                'border': `1px solid ${C.border}`,
                'color': C.text,
              }}>
              <Stack wrap gap={1}>
                {DEPARTMENTS.map((dept) => {
                  const review = getReview(dept);
                  const borderCol = deptBorderColor(review);
                  const glowCol = deptGlowColor(review);
                  return (
                    <Stack.Item key={dept} grow basis="30%">
                      <Box
                        style={{
                          'background': C.bg,
                          'border': `1px solid ${borderCol}`,
                          'box-shadow': `inset 0 0 8px ${glowCol}22`,
                          'padding': '8px',
                        }}>
                        <Box
                          style={{
                            'color': C.highlight,
                            'font-family': 'monospace',
                            'font-size': '12px',
                            'font-weight': 'bold',
                            'margin-bottom': '6px',
                          }}>
                          {dept.toUpperCase()}
                        </Box>
                        <Stack vertical>
                          <Stack.Item>
                            <Box style={{ 'color': C.dim, 'font-size': '11px' }}>
                              <Box
                                style={{
                                  'color': C.amber,
                                  'display': 'inline',
                                }}>
                                {review?.pending_directives ?? 0}
                              </Box>{' '}
                              Pending
                            </Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Box style={{ 'color': C.dim, 'font-size': '11px' }}>
                              <Box
                                style={{
                                  'color': C.blue,
                                  'display': 'inline',
                                }}>
                                {review?.active_directives ?? 0}
                              </Box>{' '}
                              Active
                            </Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Box style={{ 'color': C.dim, 'font-size': '11px' }}>
                              <Box
                                style={{
                                  'color': C.red,
                                  'display': 'inline',
                                }}>
                                {review?.overdue_directives ?? 0}
                              </Box>{' '}
                              Overdue
                            </Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Box style={{ 'color': C.dim, 'font-size': '11px' }}>
                              Budget:{' '}
                              <Box
                                style={{
                                  'color': C.brightGreen,
                                  'display': 'inline',
                                }}>
                                {review?.budget_remaining ?? 0}
                              </Box>
                              /{review?.budget_allocated ?? 0}
                            </Box>
                          </Stack.Item>
                          {dept === 'Science' && (
                            <Stack.Item>
                              <Box
                                style={{ 'color': C.dim, 'font-size': '11px' }}>
                                Research:{' '}
                                <Box
                                  style={{
                                    'color': C.brightGreen,
                                    'display': 'inline',
                                  }}>
                                  {review?.research_points ?? 0}
                                </Box>
                              </Box>
                            </Stack.Item>
                          )}
                          {dept === 'Engineering' && (
                            <Stack.Item>
                              <Box
                                style={{ 'color': C.dim, 'font-size': '11px' }}>
                                Integrity:{' '}
                                <Box
                                  style={{
                                    'color':
                                      (review?.containment_integrity ?? 100) >=
                                      75
                                        ? C.brightGreen
                                        : (review?.containment_integrity ??
                                            100) >= 50
                                          ? C.amber
                                          : C.red,
                                    'display': 'inline',
                                  }}>
                                  {review?.containment_integrity ?? 100}%
                                </Box>
                              </Box>
                            </Stack.Item>
                          )}
                        </Stack>
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="PENDING DIRECTIVES"
              style={{
                'background': C.panel,
                'border': `1px solid ${C.border}`,
                'color': C.text,
              }}>
              {directive_queue.length === 0 && (
                <Box style={{ 'color': C.dim, 'font-style': 'italic' }}>
                  No pending directives.
                </Box>
              )}
              <Stack vertical>
                {directive_queue.map((dir) => (
                  <Stack.Item key={dir.directive_id}>
                    <Box
                      style={{
                        'background': C.bg,
                        'border': `1px solid ${C.border}`,
                        'padding': '8px',
                      }}>
                      <Stack justify="space-between" align="flex-start">
                        <Stack.Item grow>
                          <Stack vertical>
                            <Stack.Item>
                              <Box
                                style={{
                                  'color': C.highlight,
                                  'font-family': 'monospace',
                                  'font-size': '12px',
                                }}>
                                {dir.issuer}{' '}
                                <Box
                                  style={{
                                    'background': C.darkRed,
                                    'color': C.amber,
                                    'display': 'inline',
                                    'font-size': '10px',
                                    'padding': '1px 6px',
                                  }}>
                                  {dir.department}
                                </Box>{' '}
                                <Box
                                  style={{
                                    'color': C.blue,
                                    'display': 'inline',
                                    'font-size': '11px',
                                  }}>
                                  [{dir.directive_type}]
                                </Box>
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  'color': C.dim,
                                  'font-size': '11px',
                                }}>
                                Target:{' '}
                                <Box
                                  style={{
                                    'color': C.text,
                                    'display': 'inline',
                                  }}>
                                  {dir.target}
                                </Box>
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  'color': C.text,
                                  'font-size': '12px',
                                }}>
                                {dir.description}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box
                                style={{
                                  'color': C.amber,
                                  'font-size': '11px',
                                }}>
                                Deadline: {dir.deadline_text || dir.deadline}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            content="ACCEPT"
                            style={{
                              'background': C.green,
                              'color': C.highlight,
                              'font-family': 'monospace',
                              'font-weight': 'bold',
                            }}
                            onClick={() =>
                              act('accept_directive', {
                                directive_id: dir.directive_id,
                              })
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="ACTIVE DIRECTIVES"
              style={{
                'background': C.panel,
                'border': `1px solid ${C.border}`,
                'color': C.text,
              }}>
              {active_directives.length === 0 && (
                <Box style={{ 'color': C.dim, 'font-style': 'italic' }}>
                  No active directives.
                </Box>
              )}
              <Stack vertical>
                {active_directives.map((dir) => {
                  const isOverdue = dir.status === 4;
                  return (
                    <Stack.Item key={dir.directive_id}>
                      <Box
                        style={{
                          'background': C.bg,
                          'border': `1px solid ${isOverdue ? C.red : C.border}`,
                          'box-shadow': isOverdue
                            ? `inset 0 0 12px ${C.red}33`
                            : 'none',
                          'padding': '8px',
                        }}>
                        <Stack vertical>
                          <Stack.Item>
                            <Stack justify="space-between" align="center">
                              <Stack.Item>
                                <Box
                                  style={{
                                    'color': C.highlight,
                                    'font-family': 'monospace',
                                    'font-size': '12px',
                                  }}>
                                  {dir.issuer}{' '}
                                  <Box
                                    style={{
                                      'background': C.darkRed,
                                      'color': C.amber,
                                      'display': 'inline',
                                      'font-size': '10px',
                                      'padding': '1px 6px',
                                    }}>
                                    {dir.department}
                                  </Box>{' '}
                                  <Box
                                    style={{
                                      'color': C.blue,
                                      'display': 'inline',
                                      'font-size': '11px',
                                    }}>
                                    [{dir.directive_type}]
                                  </Box>
                                  {isOverdue && (
                                    <Box
                                      style={{
                                        'color': C.red,
                                        'display': 'inline',
                                        'font-size': '11px',
                                        'margin-left': '8px',
                                      }}>
                                      [OVERDUE]
                                    </Box>
                                  )}
                                </Box>
                              </Stack.Item>
                              <Stack.Item>
                                <Box
                                  style={{
                                    'color': C.amber,
                                    'font-size': '11px',
                                  }}>
                                  Deadline: {dir.deadline_text || dir.deadline}
                                </Box>
                              </Stack.Item>
                            </Stack>
                          </Stack.Item>
                          <Stack.Item>
                            <Box style={{ 'color': C.text, 'font-size': '12px' }}>
                              {dir.description}
                            </Box>
                          </Stack.Item>
                          <Stack.Item>{progressBar(dir.progress)}</Stack.Item>
                          <Stack.Item>
                            <Stack gap={1}>
                              <Button
                                content="UPDATE PROGRESS (+25)"
                                style={{
                                  'background': C.amber,
                                  'color': C.bg,
                                  'font-family': 'monospace',
                                  'font-size': '11px',
                                  'font-weight': 'bold',
                                }}
                                onClick={() =>
                                  act('update_progress', {
                                    directive_id: dir.directive_id,
                                    progress: Math.min(dir.progress + 25, 100),
                                  })
                                }
                              />
                              <Button
                                content="COMPLETE"
                                style={{
                                  'background': C.green,
                                  'color': C.highlight,
                                  'font-family': 'monospace',
                                  'font-size': '11px',
                                  'font-weight': 'bold',
                                }}
                                onClick={() =>
                                  act('complete_directive', {
                                    directive_id: dir.directive_id,
                                  })
                                }
                              />
                            </Stack>
                          </Stack.Item>
                        </Stack>
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="COMPLETED DIRECTIVES"
              style={{
                'background': C.panel,
                'border': `1px solid ${C.border}`,
                'color': C.text,
              }}>
              {completed_directives.length === 0 && (
                <Box style={{ 'color': C.dim, 'font-style': 'italic' }}>
                  No completed directives.
                </Box>
              )}
              <Stack vertical>
                {completed_directives.slice(0, 10).map((dir) => (
                  <Stack.Item key={dir.directive_id}>
                    <Box
                      style={{
                        'background': C.bg,
                        'border': `1px solid ${C.border}`,
                        'padding': '6px 8px',
                      }}>
                      <Stack justify="space-between" align="center">
                        <Stack.Item>
                          <Box
                            style={{
                              'color': C.text,
                              'font-family': 'monospace',
                              'font-size': '11px',
                            }}>
                            <Box
                              style={{
                                'color': C.brightGreen,
                                'display': 'inline',
                              }}>
                              &#x2713;
                            </Box>{' '}
                            {dir.issuer}{' '}
                            <Box
                              style={{
                                'color': C.dim,
                                'display': 'inline',
                                'font-size': '10px',
                              }}>
                              [{dir.department}]
                            </Box>{' '}
                            {dir.directive_type} — {dir.target}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box
                            style={{
                              'color': C.dim,
                              'font-size': '10px',
                            }}>
                            {dir.time_completed}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title="ISSUE DIRECTIVE"
              style={{
                'background': C.panel,
                'border': `1px solid ${C.amber}`,
                'color': C.text,
              }}>
              <Stack vertical>
                <Stack.Item>
                  <Box
                    style={{
                      'color': C.dim,
                      'font-size': '11px',
                      'margin-bottom': '4px',
                    }}>
                    DEPARTMENT:
                  </Box>
                  <Stack gap={1} wrap>
                    {DEPARTMENTS.map((dept) => (
                      <Stack.Item key={dept}>
                        <Button
                          content={dept}
                          style={{
                            'background':
                              issueDept === dept ? C.amber : C.bg,
                            'color': issueDept === dept ? C.bg : C.text,
                            'border': `1px solid ${issueDept === dept ? C.amber : C.border}`,
                            'font-family': 'monospace',
                            'font-size': '11px',
                          }}
                          onClick={() => setIssueDept(dept)}
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Box
                    style={{
                      'color': C.dim,
                      'font-size': '11px',
                      'margin-bottom': '2px',
                    }}>
                    DIRECTIVE TYPE:
                  </Box>
                  <Input
                    value={issueType}
                    onChange={(_e, val) => setIssueType(val)}
                    style={{
                      'background': C.bg,
                      'border': `1px solid ${C.border}`,
                      'color': C.text,
                      'font-family': 'monospace',
                      'width': '100%',
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box
                    style={{
                      'color': C.dim,
                      'font-size': '11px',
                      'margin-bottom': '2px',
                    }}>
                    TARGET:
                  </Box>
                  <Input
                    value={issueTarget}
                    onChange={(_e, val) => setIssueTarget(val)}
                    style={{
                      'background': C.bg,
                      'border': `1px solid ${C.border}`,
                      'color': C.text,
                      'font-family': 'monospace',
                      'width': '100%',
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box
                    style={{
                      'color': C.dim,
                      'font-size': '11px',
                      'margin-bottom': '2px',
                    }}>
                    DESCRIPTION:
                  </Box>
                  <Input
                    value={issueDesc}
                    onChange={(_e, val) => setIssueDesc(val)}
                    style={{
                      'background': C.bg,
                      'border': `1px solid ${C.border}`,
                      'color': C.text,
                      'font-family': 'monospace',
                      'width': '100%',
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box
                    style={{
                      'color': C.dim,
                      'font-size': '11px',
                      'margin-bottom': '2px',
                    }}>
                    DEADLINE (MINUTES):
                  </Box>
                  <Input
                    value={issueDeadline}
                    onChange={(_e, val) => setIssueDeadline(val)}
                    style={{
                      'background': C.bg,
                      'border': `1px solid ${C.border}`,
                      'color': C.text,
                      'font-family': 'monospace',
                      'width': '120px',
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content="ISSUE"
                    style={{
                      'background': C.red,
                      'color': C.highlight,
                      'font-family': 'monospace',
                      'font-size': '14px',
                      'font-weight': 'bold',
                      'padding': '6px 24px',
                    }}
                    onClick={() =>
                      act('issue_directive', {
                        department: issueDept,
                        directive_type: issueType,
                        target: issueTarget,
                        description: issueDesc,
                        deadline: issueDeadline,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
