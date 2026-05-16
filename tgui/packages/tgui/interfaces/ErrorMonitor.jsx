import React from 'react';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

export const ErrorMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = useLocalState(
    context,
    'activeTab',
    'overview',
  );
  const [selectedError, setSelectedError] = React.useState(null);

  const {
    error_statistics,
    error_entries,
    auto_recovery_enabled,
    admin_notification_threshold,
    critical_error_threshold,
  } = data;

  return (
    <Window
      title="Enhanced Error Monitor"
      width={1200}
      height={800}
      theme="scp_terminal"
    >
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            selected={activeTab === 'overview'}
            onClick={() => setActiveTab('overview')}
          >
            Overview
          </Tabs.Tab>
          <Tabs.Tab
            selected={activeTab === 'errors'}
            onClick={() => setActiveTab('errors')}
          >
            Error Log
          </Tabs.Tab>
          <Tabs.Tab
            selected={activeTab === 'statistics'}
            onClick={() => setActiveTab('statistics')}
          >
            Statistics
          </Tabs.Tab>
          <Tabs.Tab
            selected={activeTab === 'settings'}
            onClick={() => setActiveTab('settings')}
          >
            Settings
          </Tabs.Tab>
        </Tabs>

        {activeTab === 'overview' && (
          <ErrorOverview
            statistics={error_statistics}
            auto_recovery_enabled={auto_recovery_enabled}
            admin_notification_threshold={admin_notification_threshold}
            critical_error_threshold={critical_error_threshold}
          />
        )}

        {activeTab === 'errors' && (
          <ErrorLog
            errorEntries={error_entries}
            selectedError={selectedError}
            setSelectedError={setSelectedError}
            act={act}
          />
        )}

        {activeTab === 'statistics' && (
          <ErrorStatistics statistics={error_statistics} />
        )}

        {activeTab === 'settings' && (
          <ErrorSettings
            auto_recovery_enabled={auto_recovery_enabled}
            admin_notification_threshold={admin_notification_threshold}
            critical_error_threshold={critical_error_threshold}
            act={act}
          />
        )}
      </Window.Content>
    </Window>
  );
};

const ErrorOverview = (props, context) => {
  const {
    statistics,
    auto_recovery_enabled,
    admin_notification_threshold,
    critical_error_threshold,
  } = props;

  const totalErrors = statistics.total_errors || 0;
  const autoRecovered = statistics.auto_recovered || 0;
  const requiresAttention = statistics.requires_attention || 0;

  return (
    <Box>
      <Section title="Error Monitor Overview">
        <LabeledList>
          <LabeledList.Item label="Total Errors">
            {totalErrors}
          </LabeledList.Item>
          <LabeledList.Item label="Auto-Recovered">
            {autoRecovered}
          </LabeledList.Item>
          <LabeledList.Item label="Requires Attention">
            {requiresAttention}
          </LabeledList.Item>
          <LabeledList.Item label="Auto Recovery">
            {auto_recovery_enabled ? 'Enabled' : 'Disabled'}
          </LabeledList.Item>
          <LabeledList.Item label="Admin Notification Threshold">
            {admin_notification_threshold}
          </LabeledList.Item>
          <LabeledList.Item label="Critical Error Threshold">
            {critical_error_threshold}
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Error Categories">
        <Box>
          {statistics.categories &&
            Object.keys(statistics.categories).map((category) => (
              <Box key={category} mb={1}>
                <LabeledList>
                  <LabeledList.Item label={category}>
                    {statistics.categories[category]}
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            ))}
        </Box>
      </Section>

      <Section title="Error Severities">
        <Box>
          {statistics.severities &&
            Object.keys(statistics.severities).map((severity) => {
              const severityName = getSeverityName(severity);
              const count = statistics.severities[severity];
              return (
                <Box key={severity} mb={1}>
                  <LabeledList>
                    <LabeledList.Item label={severityName}>
                      {count}
                    </LabeledList.Item>
                  </LabeledList>
                </Box>
              );
            })}
        </Box>
      </Section>
    </Box>
  );
};

const ErrorLog = (props, context) => {
  const { errorEntries, selectedError, setSelectedError, act } = props;

  return (
    <Box>
      <Section title="Error Log">
        {(!errorEntries || errorEntries.length === 0) && (
          <Box mb={2} p={2} backgroundColor="rgba(255, 255, 0, 0.1)">
            <Box fontSize="14px" color="yellow">
              No errors found. This could mean:
            </Box>
            <Box fontSize="12px" mt={1}>
              • No runtime errors have occurred yet
            </Box>
            <Box fontSize="12px">
              • The enhanced error manager is not initialized
            </Box>
            <Box fontSize="12px">
              • Sample data should be displayed for testing
            </Box>
          </Box>
        )}
        {errorEntries && errorEntries.length > 0 && (
          <Box mb={2} p={2} backgroundColor="rgba(0, 255, 0, 0.1)">
            <Box fontSize="12px" color="green">
              Found {errorEntries.length} error(s). Click &quot;Details&quot; to
              view full information.
            </Box>
          </Box>
        )}
        <Table>
          <Table.Row header>
            <Table.Cell>Time</Table.Cell>
            <Table.Cell>Severity</Table.Cell>
            <Table.Cell>Category</Table.Cell>
            <Table.Cell>Error</Table.Cell>
            <Table.Cell>File:Line</Table.Cell>
            <Table.Cell>Count</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Actions</Table.Cell>
          </Table.Row>
          {errorEntries &&
            errorEntries.map((errorItem) => (
              <Table.Row key={errorItem.error_id}>
                <Table.Cell>{formatTimestamp(errorItem.timestamp)}</Table.Cell>
                <Table.Cell>
                  <Box color={getSeverityColor(errorItem.severity)}>
                    {getSeverityName(errorItem.severity)}
                  </Box>
                </Table.Cell>
                <Table.Cell>{errorItem.category}</Table.Cell>
                <Table.Cell>{errorItem.name}</Table.Cell>
                <Table.Cell>
                  {errorItem.file}:{errorItem.line}
                </Table.Cell>
                <Table.Cell>{errorItem.count}</Table.Cell>
                <Table.Cell>
                  <Box>
                    {errorItem.auto_recovered && (
                      <Icon name="check" color="green" />
                    )}
                    {errorItem.requires_attention && (
                      <Icon name="exclamation-triangle" color="red" />
                    )}
                    {!errorItem.auto_recovered &&
                      !errorItem.requires_attention && (
                        <Icon name="info" color="blue" />
                      )}
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  <Button
                    content="Details"
                    onClick={() => {
                      setSelectedError(errorItem);
                    }}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      </Section>

      {selectedError ? (
        <ErrorDetails
          error={selectedError}
          onClose={() => setSelectedError(null)}
          act={act}
        />
      ) : (
        <Box mt={2} p={2} backgroundColor="rgba(255, 0, 0, 0.1)">
          <Box fontSize="12px" color="red">
            No error selected. Click &quot;Details&quot; on an error to view
            information.
          </Box>
        </Box>
      )}
    </Box>
  );
};

const ErrorDetails = (props, context) => {
  const { error, onClose, act } = props;

  if (!error) {
    return (
      <Section title="Error Details">
        <Box>No error selected or error data unavailable.</Box>
        <Box mt={2}>
          <Button content="Close" onClick={onClose} />
        </Box>
      </Section>
    );
  }

  // Check if error is an array (which would be wrong)
  if (Array.isArray(error)) {
    return (
      <Section title="Error Details - Debug Mode">
        <Box mb={2} p={2} backgroundColor="rgba(255, 0, 0, 0.1)">
          <Box fontSize="14px" color="red">
            ERROR: Received array instead of single error object!
          </Box>
          <Box fontSize="12px" mt={1}>
            Array length: {error.length}
          </Box>
          <Box fontSize="12px">First item: {JSON.stringify(error[0])}</Box>
        </Box>
        <Box mt={2}>
          <Button content="Close" onClick={onClose} />
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Error Details">
      <LabeledList>
        <LabeledList.Item label="Error ID">
          {error.error_id || 'Unknown'}
        </LabeledList.Item>
        <LabeledList.Item label="Type">
          {error.type || 'Unknown'}
        </LabeledList.Item>
        <LabeledList.Item label="Name">
          {error.name || 'Unknown'}
        </LabeledList.Item>
        <LabeledList.Item label="File">
          {error.file || 'Unknown'}
        </LabeledList.Item>
        <LabeledList.Item label="Line">
          {error.line || 'Unknown'}
        </LabeledList.Item>
        <LabeledList.Item label="Severity">
          <Box color={getSeverityColor(error.severity)}>
            {getSeverityName(error.severity)}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Category">
          {error.category || 'Unknown'}
        </LabeledList.Item>
        <LabeledList.Item label="Timestamp">
          {formatTimestamp(error.timestamp)}
        </LabeledList.Item>
        <LabeledList.Item label="Count">{error.count || 0}</LabeledList.Item>
        <LabeledList.Item label="Recovery Strategy">
          {error.recovery_strategy || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Auto Recovered">
          {error.auto_recovered ? 'Yes' : 'No'}
        </LabeledList.Item>
        <LabeledList.Item label="Requires Attention">
          {error.requires_attention ? 'Yes' : 'No'}
        </LabeledList.Item>
      </LabeledList>

      <Section title="Description" level={2}>
        <Box fontFamily="monospace" whiteSpace="pre-wrap">
          {error.desc || 'No description available'}
        </Box>
      </Section>

      <Box mt={2}>
        <Button content="Close" onClick={onClose} />
        <Button
          content="Export Error Data"
          onClick={() => act('export_error_data', { error_id: error.error_id })}
          ml={1}
        />
      </Box>
    </Section>
  );
};

const ErrorStatistics = (props, context) => {
  const { statistics } = props;

  return (
    <Box>
      <Section title="Error Statistics">
        <LabeledList>
          <LabeledList.Item label="Total Errors">
            {statistics.total_errors || 0}
          </LabeledList.Item>
          <LabeledList.Item label="Auto Recovered">
            {statistics.auto_recovered || 0}
          </LabeledList.Item>
          <LabeledList.Item label="Requires Attention">
            {statistics.requires_attention || 0}
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Category Distribution">
        {statistics.categories &&
          Object.keys(statistics.categories).map((category) => {
            const count = statistics.categories[category];
            const percentage =
              statistics.total_errors > 0
                ? (count / statistics.total_errors) * 100
                : 0;

            return (
              <Box key={category} mb={1}>
                <LabeledList>
                  <LabeledList.Item label={category}>
                    {count} ({percentage.toFixed(1)}%)
                  </LabeledList.Item>
                </LabeledList>
                <ProgressBar value={percentage} maxValue={100} />
              </Box>
            );
          })}
      </Section>

      <Section title="Severity Distribution">
        {statistics.severities &&
          Object.keys(statistics.severities).map((severity) => {
            const count = statistics.severities[severity];
            const percentage =
              statistics.total_errors > 0
                ? (count / statistics.total_errors) * 100
                : 0;
            const severityName = getSeverityName(severity);

            return (
              <Box key={severity} mb={1}>
                <LabeledList>
                  <LabeledList.Item label={severityName}>
                    {count} ({percentage.toFixed(1)}%)
                  </LabeledList.Item>
                </LabeledList>
                <ProgressBar
                  value={percentage}
                  maxValue={100}
                  color={getSeverityColor(severity)}
                />
              </Box>
            );
          })}
      </Section>
    </Box>
  );
};

const ErrorSettings = (props, context) => {
  const {
    auto_recovery_enabled,
    admin_notification_threshold,
    critical_error_threshold,
    act,
  } = props;

  return (
    <Box>
      <Section title="Error Monitor Settings">
        <LabeledList>
          <LabeledList.Item label="Auto Recovery">
            <Button
              content={auto_recovery_enabled ? 'Enabled' : 'Disabled'}
              color={auto_recovery_enabled ? 'green' : 'red'}
              onClick={() => act('toggle_auto_recovery')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Admin Notification Threshold">
            <Button
              content="Decrease"
              onClick={() =>
                act('adjust_notification_threshold', { direction: 'decrease' })
              }
            />
            <Box inline mx={1}>
              {admin_notification_threshold}
            </Box>
            <Button
              content="Increase"
              onClick={() =>
                act('adjust_notification_threshold', { direction: 'increase' })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Critical Error Threshold">
            <Button
              content="Decrease"
              onClick={() =>
                act('adjust_critical_threshold', { direction: 'decrease' })
              }
            />
            <Box inline mx={1}>
              {critical_error_threshold}
            </Box>
            <Button
              content="Increase"
              onClick={() =>
                act('adjust_critical_threshold', { direction: 'increase' })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Actions">
        <Button
          content="Clear Error Log"
          color="red"
          onClick={() => act('clear_error_log')}
        />
        <Button
          content="Export All Data"
          onClick={() => act('export_all_data')}
          ml={1}
        />
        <Button
          content="Reset Statistics"
          onClick={() => act('reset_statistics')}
          ml={1}
        />
      </Section>
    </Box>
  );
};

// Helper functions
const getSeverityName = (severity) => {
  switch (severity) {
    case '1':
      return 'Low';
    case '2':
      return 'Medium';
    case '3':
      return 'High';
    case '4':
      return 'Critical';
    default:
      return 'Unknown';
  }
};

const getSeverityColor = (severity) => {
  switch (severity) {
    case '1':
      return 'green';
    case '2':
      return 'yellow';
    case '3':
      return 'orange';
    case '4':
      return 'red';
    default:
      return 'grey';
  }
};

const formatTimestamp = (timestamp) => {
  if (!timestamp) return 'Unknown';
  const date = new Date(timestamp * 1000);
  return date.toLocaleString();
};
