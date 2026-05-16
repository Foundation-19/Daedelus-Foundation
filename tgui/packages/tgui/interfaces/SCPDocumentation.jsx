import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

export const SCPDocumentation = (props) => {
  const { act, data } = useBackend();
  const [activeTab, setActiveTab] = React.useState('overview');
  const [searchTerm, setSearchTerm] = React.useState('');
  const [selectedSection, setSelectedSection] = React.useState(null);
  const [selectedSCP, setSelectedSCP] = React.useState(null);

  const {
    documentation_sections,
    system_status,
    active_scps,
    component_stats,
    performance_metrics,
    system_info,
  } = data;

  return (
    <Window
      title="SCP Foundation Documentation System"
      width={1400}
      height={900}
      theme="scp_terminal"
    >
      <Window.Content>
        <Flex>
          <Flex.Item width="250px">
            <NavigationSidebar
              activeTab={activeTab}
              setActiveTab={setActiveTab}
              systemInfo={system_info}
              componentStats={component_stats}
            />
          </Flex.Item>

          <Flex.Item grow={1}>
            <Box ml={2}>
              {activeTab === 'overview' && (
                <SystemOverview
                  systemStatus={system_status}
                  activeScps={active_scps}
                  performanceMetrics={performance_metrics}
                  systemInfo={system_info}
                  act={act}
                />
              )}

              {activeTab === 'documentation' && (
                <DocumentationViewer
                  sections={documentation_sections}
                  selectedSection={selectedSection}
                  setSelectedSection={setSelectedSection}
                  searchTerm={searchTerm}
                  setSearchTerm={setSearchTerm}
                  act={act}
                />
              )}

              {activeTab === 'scps' && (
                <SCPDatabase
                  activeScps={active_scps}
                  selectedSCP={selectedSCP}
                  setSelectedSCP={setSelectedSCP}
                  act={act}
                />
              )}

              {activeTab === 'components' && (
                <ComponentExplorer
                  activeScps={active_scps}
                  componentStats={component_stats}
                  act={act}
                />
              )}

              {activeTab === 'performance' && (
                <PerformanceDashboard
                  performanceMetrics={performance_metrics}
                  componentStats={component_stats}
                  act={act}
                />
              )}

              {activeTab === 'diagnostics' && (
                <SystemDiagnostics
                  systemStatus={system_status}
                  performanceMetrics={performance_metrics}
                  act={act}
                />
              )}
            </Box>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const NavigationSidebar = ({
  activeTab,
  setActiveTab,
  systemInfo,
  componentStats,
}) => {
  const navigationItems = [
    { id: 'overview', name: 'System Overview', icon: 'home' },
    { id: 'documentation', name: 'Documentation', icon: 'book' },
    { id: 'scps', name: 'SCP Database', icon: 'database' },
    { id: 'components', name: 'Component Explorer', icon: 'cogs' },
    { id: 'performance', name: 'Performance', icon: 'chart-line' },
    { id: 'diagnostics', name: 'Diagnostics', icon: 'stethoscope' },
  ];

  return (
    <Box>
      <Section title="SCP Foundation">
        <Box
          style={{
            background: 'rgba(0,0,0,0.7)',
            border: '1px solid rgba(255,255,255,0.2)',
            borderRadius: '5px',
            padding: '10px',
            marginBottom: '15px',
            fontFamily: 'monospace',
            fontSize: '12px',
            color: '#ffffff',
          }}
        >
          <Box style={{ textAlign: 'center', marginBottom: '10px' }}>
            <Box style={{ fontSize: '16px', fontWeight: 'bold' }}>
              DOCUMENTATION SYSTEM
            </Box>
            <Box style={{ fontSize: '14px', opacity: 0.8 }}>
              v{systemInfo?.version || '2.0.0'}
            </Box>
          </Box>

          <Box style={{ fontSize: '10px' }}>
            <Box>Components: {componentStats?.total_components || 0}</Box>
            <Box>Active: {componentStats?.active_components || 0}</Box>
            <Box>Last Updated: {systemInfo?.last_updated || 'Unknown'}</Box>
          </Box>
        </Box>

        {navigationItems.map((item) => (
          <Button
            key={item.id}
            content={
              <Flex align="center">
                <Flex.Item>
                  <Icon name={item.icon} mr={1} />
                </Flex.Item>
                <Flex.Item>{item.name}</Flex.Item>
              </Flex>
            }
            selected={activeTab === item.id}
            onClick={() => setActiveTab(item.id)}
            fluid
            mb={1}
          />
        ))}
      </Section>
    </Box>
  );
};

const SystemOverview = ({
  systemStatus,
  activeScps,
  performanceMetrics,
  systemInfo,
  act,
}) => {
  return (
    <Box>
      <Section title="System Overview">
        <Flex>
          <Flex.Item width="50%">
            <Section title="System Status" level={2}>
              {systemStatus?.core_systems && (
                <Box mb={2}>
                  <Box fontSize="14px" fontWeight="bold" mb={1}>
                    Core Systems
                  </Box>
                  {Object.keys(systemStatus.core_systems).map((system) => {
                    const systemData = systemStatus.core_systems[system];
                    return (
                      <Box key={system} mb={1}>
                        <Flex align="center">
                          <Flex.Item>
                            <Icon
                              name={systemData.available ? 'check' : 'times'}
                              color={systemData.available ? 'green' : 'red'}
                              mr={1}
                            />
                          </Flex.Item>
                          <Flex.Item grow={1}>
                            <Box>{systemData.description}</Box>
                            <Box fontSize="12px" opacity={0.7}>
                              {systemData.status}
                            </Box>
                          </Flex.Item>
                        </Flex>
                      </Box>
                    );
                  })}
                </Box>
              )}

              {systemStatus?.subsystems && (
                <Box>
                  <Box fontSize="14px" fontWeight="bold" mb={1}>
                    Subsystems
                  </Box>
                  {Object.keys(systemStatus.subsystems).map((system) => {
                    const systemData = systemStatus.subsystems[system];
                    return (
                      <Box key={system} mb={1}>
                        <Flex align="center">
                          <Flex.Item>
                            <Icon
                              name={systemData.available ? 'check' : 'times'}
                              color={systemData.available ? 'green' : 'red'}
                              mr={1}
                            />
                          </Flex.Item>
                          <Flex.Item grow={1}>
                            <Box>{systemData.description}</Box>
                            <Box fontSize="12px" opacity={0.7}>
                              {systemData.status}
                            </Box>
                          </Flex.Item>
                        </Flex>
                      </Box>
                    );
                  })}
                </Box>
              )}
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Quick Statistics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Active SCPs">
                  {activeScps?.total_active || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Component-Based SCPs">
                  {activeScps?.component_based || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Total Components">
                  {performanceMetrics?.component_managers || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Network Registered">
                  {activeScps?.network_registered || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Server Time">
                  {systemInfo?.server_time || 'Unknown'}
                </LabeledList.Item>
              </LabeledList>

              <Box mt={2}>
                <Button
                  content="Refresh Status"
                  icon="sync-alt"
                  onClick={() => act('refresh_status')}
                  color="blue"
                />
                <Button
                  content="Run Diagnostics"
                  icon="stethoscope"
                  onClick={() => act('run_system_diagnostics')}
                  color="orange"
                  ml={1}
                />
                <Button
                  content="Export Data"
                  icon="download"
                  onClick={() => act('export_documentation')}
                  color="green"
                  ml={1}
                />
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Section>

      {performanceMetrics?.performance_issues?.length > 0 && (
        <Section title="Performance Alerts" color="orange">
          {performanceMetrics.performance_issues.map((issue, index) => (
            <Box
              key={index}
              p={2}
              mb={2}
              backgroundColor="rgba(255, 165, 0, 0.1)"
              border="1px solid orange"
              borderRadius="5px"
            >
              <Flex align="center">
                <Flex.Item>
                  <Icon name="exclamation-triangle" color="orange" mr={2} />
                </Flex.Item>
                <Flex.Item grow={1}>
                  <Box>
                    SCP-{issue.scp}: High update time ({issue.average_time}ms
                    avg)
                  </Box>
                  <Box fontSize="12px" opacity={0.7}>
                    Severity: {issue.severity} | Updates: {issue.update_cycles}
                  </Box>
                </Flex.Item>
              </Flex>
            </Box>
          ))}
        </Section>
      )}
    </Box>
  );
};

const DocumentationViewer = ({
  sections,
  selectedSection,
  setSelectedSection,
  searchTerm,
  setSearchTerm,
  act,
}) => {
  const filteredSections =
    sections?.filter(
      (section) =>
        !searchTerm ||
        section.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        section.content.some((line) =>
          line.toLowerCase().includes(searchTerm.toLowerCase()),
        ),
    ) || [];

  const categorizedSections = {};
  filteredSections.forEach((section) => {
    const category = section.category || 'General';
    if (!categorizedSections[category]) {
      categorizedSections[category] = [];
    }
    categorizedSections[category].push(section);
  });

  return (
    <Box>
      <Section title="Documentation">
        <Box mb={2}>
          <Input
            placeholder="Search documentation..."
            value={searchTerm}
            onChange={(e, value) => setSearchTerm(value)}
            fluid
          />
        </Box>

        <Flex>
          <Flex.Item width="300px">
            <Section title="Sections" level={2}>
              {Object.keys(categorizedSections).map((category) => (
                <Box key={category} mb={2}>
                  <Box fontSize="14px" fontWeight="bold" mb={1} color="blue">
                    {category}
                  </Box>
                  {categorizedSections[category].map((section) => (
                    <Button
                      key={section.id}
                      content={section.title}
                      selected={selectedSection === section.id}
                      onClick={() => setSelectedSection(section.id)}
                      fluid
                      mb={0.5}
                      fontSize="12px"
                    />
                  ))}
                </Box>
              ))}
            </Section>
          </Flex.Item>

          <Flex.Item grow={1} ml={2}>
            {selectedSection ? (
              <DocumentationContent
                section={filteredSections.find((s) => s.id === selectedSection)}
              />
            ) : (
              <Section title="Select a Section" level={2}>
                <Box p={4} textAlign="center" opacity={0.7}>
                  <Icon name="book" size={3} mb={2} />
                  <Box>
                    Select a documentation section from the left to view its
                    content.
                  </Box>
                </Box>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const DocumentationContent = ({ section }) => {
  if (!section) return null;

  return (
    <Section title={section.title} level={2}>
      <Box
        style={{
          background: 'rgba(0,0,0,0.3)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '15px',
          fontFamily: 'monospace',
          fontSize: '13px',
          lineHeight: '1.6',
        }}
      >
        {section.content.map((line, index) => (
          <Box key={index} mb={line === '' ? 1 : 0}>
            {line === '' ? <br /> : formatDocumentationLine(line)}
          </Box>
        ))}
      </Box>
    </Section>
  );
};

const formatDocumentationLine = (line) => {
  // Format special lines
  if (line.startsWith('•')) {
    return (
      <Box ml={2} color="lightblue">
        <Icon name="circle" size={0.5} mr={1} />
        {line.substring(1).trim()}
      </Box>
    );
  }

  if (line.endsWith(':')) {
    return (
      <Box fontWeight="bold" color="yellow" mt={1}>
        {line}
      </Box>
    );
  }

  return <Box>{line}</Box>;
};

const SCPDatabase = ({ activeScps, selectedSCP, setSelectedSCP, act }) => {
  const scpList = activeScps?.scps || [];

  return (
    <Box>
      <Section title="SCP Database">
        <Flex>
          <Flex.Item width="400px">
            <Section title="Active SCPs" level={2}>
              <Table>
                <Table.Row header>
                  <Table.Cell>SCP</Table.Cell>
                  <Table.Cell>Player</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Components</Table.Cell>
                </Table.Row>
                {scpList.map((scp) => (
                  <Table.Row
                    key={scp.id}
                    className={selectedSCP === scp.id ? 'selected' : ''}
                    onClick={() => setSelectedSCP(scp.id)}
                    style={{ cursor: 'pointer' }}
                  >
                    <Table.Cell>
                      <Box fontWeight="bold">SCP-{scp.id}</Box>
                      <Box fontSize="11px" opacity={0.7}>
                        {scp.classification}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      {scp.player_controlled ? scp.player_name : 'NPC'}
                    </Table.Cell>
                    <Table.Cell>
                      <Box color={scp.status === 'Alive' ? 'green' : 'red'}>
                        {scp.status}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      {scp.uses_components ? (
                        <Icon name="check" color="green" />
                      ) : (
                        <Icon name="times" color="red" />
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Flex.Item>

          <Flex.Item grow={1} ml={2}>
            {selectedSCP ? (
              <SCPDetails
                scp={scpList.find((s) => s.id === selectedSCP)}
                act={act}
              />
            ) : (
              <Section title="Select an SCP" level={2}>
                <Box p={4} textAlign="center" opacity={0.7}>
                  <Icon name="database" size={3} mb={2} />
                  <Box>
                    Select an SCP from the list to view detailed information.
                  </Box>
                </Box>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const SCPDetails = ({ scp, act }) => {
  if (!scp) return null;

  return (
    <Section title={`SCP-${scp.id} Details`} level={2}>
      <LabeledList>
        <LabeledList.Item label="Name">{scp.name}</LabeledList.Item>
        <LabeledList.Item label="Classification">
          {scp.classification}
        </LabeledList.Item>
        <LabeledList.Item label="Type">{scp.type}</LabeledList.Item>
        <LabeledList.Item label="Player">{scp.player_name}</LabeledList.Item>
        <LabeledList.Item label="Health">
          <ProgressBar
            value={scp.health}
            maxValue={scp.max_health}
            color={scp.health > scp.max_health * 0.5 ? 'green' : 'red'}
          >
            {scp.health}/{scp.max_health}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Location">{scp.location}</LabeledList.Item>
        <LabeledList.Item label="Status">
          <Box color={scp.status === 'Alive' ? 'green' : 'red'}>
            {scp.status}
          </Box>
        </LabeledList.Item>
      </LabeledList>

      {scp.components && scp.components.length > 0 && (
        <Box mt={3}>
          <Box fontSize="14px" fontWeight="bold" mb={2}>
            Components ({scp.components.length})
          </Box>
          <Table>
            <Table.Row header>
              <Table.Cell>Component</Table.Cell>
              <Table.Cell>Version</Table.Cell>
              <Table.Cell>State</Table.Cell>
              <Table.Cell>Errors</Table.Cell>
            </Table.Row>
            {scp.components.map((component) => (
              <Table.Row key={component.id}>
                <Table.Cell>
                  <Box fontWeight="bold">{component.name}</Box>
                  <Box fontSize="11px" opacity={0.7}>
                    {component.category}
                  </Box>
                </Table.Cell>
                <Table.Cell>{component.version}</Table.Cell>
                <Table.Cell>
                  <Box color={component.state === 2 ? 'green' : 'orange'}>
                    {component.state === 2 ? 'Active' : 'Inactive'}
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  <Box color={component.error_count > 0 ? 'red' : 'green'}>
                    {component.error_count}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Box>
      )}

      <Box mt={3}>
        <Button
          content="Examine SCP"
          icon="search"
          onClick={() => act('examine_scp', { scp_id: scp.id })}
          color="blue"
        />
      </Box>
    </Section>
  );
};

const ComponentExplorer = ({ activeScps, componentStats, act }) => {
  const scpList = activeScps?.scps || [];
  const scpsWithComponents = scpList.filter((scp) => scp.uses_components);

  return (
    <Box>
      <Section title="Component Explorer">
        <Flex>
          <Flex.Item width="300px">
            <Section title="Statistics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Components">
                  {componentStats?.total_components || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Active Components">
                  {componentStats?.active_components || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Error Components">
                  <Box
                    color={
                      componentStats?.error_components > 0 ? 'red' : 'green'
                    }
                  >
                    {componentStats?.error_components || 0}
                  </Box>
                </LabeledList.Item>
              </LabeledList>

              {componentStats?.categories &&
                componentStats.categories.length > 0 && (
                  <Box mt={2}>
                    <Box fontSize="14px" fontWeight="bold" mb={1}>
                      By Category
                    </Box>
                    {componentStats.categories.map((category) => (
                      <Box key={category.name} mb={1}>
                        <Flex justify="space-between">
                          <Flex.Item>{category.name}</Flex.Item>
                          <Flex.Item>{category.count}</Flex.Item>
                        </Flex>
                      </Box>
                    ))}
                  </Box>
                )}
            </Section>
          </Flex.Item>

          <Flex.Item grow={1} ml={2}>
            <Section title="Component-Based SCPs" level={2}>
              {scpsWithComponents.map((scp) => (
                <Box
                  key={scp.id}
                  mb={2}
                  p={2}
                  backgroundColor="rgba(0,0,0,0.3)"
                  border="1px solid rgba(255,255,255,0.2)"
                  borderRadius="5px"
                >
                  <Flex align="center" mb={2}>
                    <Flex.Item grow={1}>
                      <Box fontSize="16px" fontWeight="bold">
                        SCP-{scp.id}: {scp.name}
                      </Box>
                      <Box fontSize="12px" opacity={0.7}>
                        {scp.components?.length || 0} components
                      </Box>
                    </Flex.Item>
                    <Flex.Item>
                      <Box color={scp.status === 'Alive' ? 'green' : 'red'}>
                        {scp.status}
                      </Box>
                    </Flex.Item>
                  </Flex>

                  {scp.components && scp.components.length > 0 && (
                    <Box>
                      <Flex wrap="wrap" style={{ gap: '5px' }}>
                        {scp.components.map((component) => (
                          <Box
                            key={component.id}
                            p={1}
                            backgroundColor={
                              component.state === 2
                                ? 'rgba(0,255,0,0.2)'
                                : 'rgba(255,165,0,0.2)'
                            }
                            borderRadius="3px"
                            fontSize="11px"
                            style={{ cursor: 'pointer' }}
                            onClick={() =>
                              act('examine_component', {
                                scp_id: scp.id,
                                component_id: component.id,
                              })
                            }
                          >
                            {component.name}
                            {component.error_count > 0 && (
                              <Icon
                                name="exclamation-triangle"
                                color="red"
                                ml={1}
                              />
                            )}
                          </Box>
                        ))}
                      </Flex>
                    </Box>
                  )}
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const PerformanceDashboard = ({ performanceMetrics, componentStats, act }) => {
  return (
    <Box>
      <Section title="Performance Dashboard">
        <Flex>
          <Flex.Item width="50%">
            <Section title="Performance Metrics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Update Time">
                  {performanceMetrics?.total_update_time || 0}ms
                </LabeledList.Item>
                <LabeledList.Item label="Average Update Time">
                  {performanceMetrics?.average_update_time?.toFixed(2) || 0}ms
                </LabeledList.Item>
                <LabeledList.Item label="Component Managers">
                  {performanceMetrics?.component_managers || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Total Updates">
                  {performanceMetrics?.total_updates || 0}
                </LabeledList.Item>
              </LabeledList>

              {componentStats?.most_used_components && (
                <Box mt={2}>
                  <Box fontSize="14px" fontWeight="bold" mb={1}>
                    Most Used Components
                  </Box>
                  {componentStats.most_used_components.map(
                    (component, index) => (
                      <Box key={index} mb={1}>
                        <Flex justify="space-between">
                          <Flex.Item>
                            <Box fontSize="12px">{component.type}</Box>
                          </Flex.Item>
                          <Flex.Item>{component.count}</Flex.Item>
                        </Flex>
                      </Box>
                    ),
                  )}
                </Box>
              )}
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Performance Issues" level={2}>
              {performanceMetrics?.performance_issues?.length > 0 ? (
                performanceMetrics.performance_issues.map((issue, index) => (
                  <Box
                    key={index}
                    mb={2}
                    p={2}
                    backgroundColor="rgba(255, 165, 0, 0.1)"
                    border="1px solid orange"
                    borderRadius="5px"
                  >
                    <Box fontWeight="bold">SCP-{issue.scp}</Box>
                    <Box fontSize="12px">
                      Average Time: {issue.average_time}ms
                    </Box>
                    <Box fontSize="12px">
                      Update Cycles: {issue.update_cycles}
                    </Box>
                    <Box fontSize="12px" color="orange">
                      Severity: {issue.severity}
                    </Box>
                  </Box>
                ))
              ) : (
                <Box p={2} textAlign="center" opacity={0.7}>
                  <Icon name="check" color="green" size={2} mb={1} />
                  <Box>No performance issues detected</Box>
                </Box>
              )}
            </Section>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const SystemDiagnostics = ({ systemStatus, performanceMetrics, act }) => {
  const getSystemHealth = () => {
    let healthy = 0;
    let total = 0;

    // Check core systems
    if (systemStatus?.core_systems) {
      Object.values(systemStatus.core_systems).forEach((system) => {
        total++;
        if (system.available) healthy++;
      });
    }

    // Check subsystems
    if (systemStatus?.subsystems) {
      Object.values(systemStatus.subsystems).forEach((system) => {
        total++;
        if (system.available) healthy++;
      });
    }

    return {
      healthy,
      total,
      percentage: total > 0 ? (healthy / total) * 100 : 0,
    };
  };

  const health = getSystemHealth();

  return (
    <Box>
      <Section title="System Diagnostics">
        <Box mb={3}>
          <Box fontSize="16px" fontWeight="bold" mb={2}>
            Overall System Health
          </Box>
          <ProgressBar
            value={health.healthy}
            maxValue={health.total}
            color={
              health.percentage > 80
                ? 'green'
                : health.percentage > 60
                  ? 'yellow'
                  : 'red'
            }
          >
            {health.healthy}/{health.total} systems operational (
            {health.percentage.toFixed(1)}%)
          </ProgressBar>
        </Box>

        <Flex>
          <Flex.Item width="50%">
            <Section title="System Status" level={2}>
              {systemStatus?.core_systems && (
                <Box mb={3}>
                  <Box fontSize="14px" fontWeight="bold" mb={1}>
                    Core Systems
                  </Box>
                  {Object.keys(systemStatus.core_systems).map((system) => {
                    const systemData = systemStatus.core_systems[system];
                    return (
                      <Flex key={system} align="center" mb={1}>
                        <Flex.Item width="20px">
                          <Icon
                            name={systemData.available ? 'check' : 'times'}
                            color={systemData.available ? 'green' : 'red'}
                          />
                        </Flex.Item>
                        <Flex.Item grow={1}>
                          <Box>{systemData.description}</Box>
                        </Flex.Item>
                      </Flex>
                    );
                  })}
                </Box>
              )}

              {systemStatus?.subsystems && (
                <Box>
                  <Box fontSize="14px" fontWeight="bold" mb={1}>
                    Subsystems
                  </Box>
                  {Object.keys(systemStatus.subsystems).map((system) => {
                    const systemData = systemStatus.subsystems[system];
                    return (
                      <Flex key={system} align="center" mb={1}>
                        <Flex.Item width="20px">
                          <Icon
                            name={systemData.available ? 'check' : 'times'}
                            color={systemData.available ? 'green' : 'red'}
                          />
                        </Flex.Item>
                        <Flex.Item grow={1}>
                          <Box>{systemData.description}</Box>
                        </Flex.Item>
                      </Flex>
                    );
                  })}
                </Box>
              )}
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Diagnostic Tools" level={2}>
              <Box mb={2}>
                <Button
                  content="Run Full Diagnostics"
                  icon="stethoscope"
                  onClick={() => act('run_system_diagnostics')}
                  color="blue"
                  fluid
                />
              </Box>

              <Box mb={2}>
                <Button
                  content="Refresh All Data"
                  icon="sync-alt"
                  onClick={() => act('refresh_status')}
                  color="green"
                  fluid
                />
              </Box>

              <Box mb={2}>
                <Button
                  content="Export Diagnostic Report"
                  icon="download"
                  onClick={() => act('export_documentation')}
                  color="orange"
                  fluid
                />
              </Box>

              {performanceMetrics?.performance_issues?.length > 0 && (
                <Box mt={3}>
                  <Box fontSize="14px" fontWeight="bold" mb={1} color="orange">
                    Performance Alerts
                  </Box>
                  <Box fontSize="12px" opacity={0.7}>
                    {performanceMetrics.performance_issues.length} performance
                    issue(s) detected
                  </Box>
                </Box>
              )}
            </Section>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};
