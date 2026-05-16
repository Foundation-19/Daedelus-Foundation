import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, NoticeBox, ProgressBar, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { useState } from 'react';

const BSL_COLORS: Record<string, string> = {
  'BSL-1': '#44ff44',
  'BSL-2': '#d4a017',
  'BSL-3': '#ff6600',
  'BSL-4': '#ff0000',
};

const RESEARCH_STAGES: Record<number, string> = {
  1: 'IDENTIFIED',
  2: 'CATALOGUED',
  3: 'MAPPED',
  4: 'COUNTERMEASURE',
  5: 'CURED',
};

const RESEARCH_COLORS: Record<number, string> = {
  1: '#6a6a70',
  2: '#d4a017',
  3: '#4488ff',
  4: '#ff8800',
  5: '#44ff44',
};

const formatTime = (deciseconds: number): string => {
  const seconds = Math.ceil(deciseconds / 10);
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${s.toString().padStart(2, '0')}`;
};

export const PathogenResearchConsole = (props) => {
  const { act, data } = useBackend();
  const [tabIndex, setTabIndex] = useState(1);

  const {
    active_infections = [],
    cure_log = [],
    bsl_summary = [],
    research_data = [],
    host_diseases = [],
    inserted_sample,
    research_points = 0,
  } = data;

  return (
    <Window theme="scp_terminal" width={750} height={650}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="FOUNDATION PATHOGEN RESEARCH">
              <Flex wrap>
                <Flex.Item basis="50%">
                  <Box color="#6a6a70" fontSize="11px">
                    RESEARCH POINTS:
                  </Box>
                  <Box bold color="#4488ff" fontSize="16px">
                    {research_points}
                  </Box>
                </Flex.Item>
                <Flex.Item basis="50%">
                  <Box color="#6a6a70" fontSize="11px">
                    INSERTED SAMPLE:
                  </Box>
                  <Box bold color={inserted_sample ? '#44ff44' : '#6a6a70'} fontSize="14px">
                    {inserted_sample ? inserted_sample.name : 'NONE'}
                  </Box>
                  {inserted_sample && (
                    <Flex ml={1} mt={0.5}>
                      <Flex.Item>
                        <Button
                          content="EJECT"
                          color="average"
                          fontSize="10px"
                          onClick={() => act('eject_sample')}
                        />
                      </Flex.Item>
                    </Flex>
                  )}
                  {!inserted_sample && (
                    <Button
                      content="INSERT SAMPLE"
                      color="good"
                      fontSize="10px"
                      onClick={() => act('insert_sample')}
                    />
                  )}
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                ACTIVE INFECTIONS
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                PATHOGEN DATABASE
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 3}
                onClick={() => setTabIndex(3)}
              >
                RESEARCH
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 4}
                onClick={() => setTabIndex(4)}
              >
                SELF-SCAN
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            {tabIndex === 1 && (
              <ActiveInfectionsTab
                infections={active_infections}
                bsl_summary={bsl_summary}
              />
            )}
            {tabIndex === 2 && (
              <PathogenDatabaseTab
                research_data={research_data}
              />
            )}
            {tabIndex === 3 && (
              <ResearchTab
                research_data={research_data}
                research_points={research_points}
                inserted_sample={inserted_sample}
                act={act}
              />
            )}
            {tabIndex === 4 && (
              <SelfScanTab
                host_diseases={host_diseases}
                act={act}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ActiveInfectionsTab = (props) => {
  const { infections, bsl_summary } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="BSL SUMMARY">
          <Flex wrap>
            {bsl_summary.map((bsl, i) => (
              <Flex.Item key={i} basis="25%">
                <Box
                  inline
                  bold
                  color={BSL_COLORS[bsl.level]}
                >
                  {bsl.level}:
                </Box>
                {' '}{bsl.count} active
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="ACTIVE INFECTIONS">
          {infections.length === 0 ? (
            <NoticeBox info>No active infections detected.</NoticeBox>
          ) : (
            infections.map((inf, i) => (
              <Box key={i} mb={1} pl={1} style={{
                'border-left': `3px solid ${BSL_COLORS[inf.bsl] || '#6a6a70'}`,
              }}>
                <LabeledList>
                  <LabeledList.Item label="Pathogen">
                    {inf.pathogen_type.split('/').pop()}
                  </LabeledList.Item>
                  <LabeledList.Item label="Host">
                    {inf.host_name}
                  </LabeledList.Item>
                  <LabeledList.Item label="BSL">
                    <Box inline bold color={BSL_COLORS[inf.bsl]}>
                      {inf.bsl}
                    </Box>
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            ))
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const PathogenDatabaseTab = (props) => {
  const { research_data } = props;

  return (
    <Section title="PATHOGEN DATABASE">
      {research_data.length === 0 ? (
        <NoticeBox info>No pathogen data available.</NoticeBox>
      ) : (
        research_data.map((pdata, i) => (
          <Box key={i} mb={1} pl={1} style={{
            'border-left': `3px solid ${BSL_COLORS[pdata.bsl] || '#6a6a70'}`,
          }}>
            <LabeledList>
              <LabeledList.Item label="Name">
                <Box inline bold color={pdata.anomalous ? '#ff4444' : '#c8c8c8'}>
                  {pdata.name}
                </Box>
                {pdata.anomalous && (
                  <Box inline ml={1} bold color="#ff0000">
                    [ANOMALOUS]
                  </Box>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="BSL">
                <Box inline bold color={BSL_COLORS[pdata.bsl]}>
                  {pdata.bsl}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Transmission">
                {(pdata.transmission || []).join(', ') || 'Unknown'}
              </LabeledList.Item>
              <LabeledList.Item label="Research">
                <Box inline bold color={RESEARCH_COLORS[pdata.research_stage]}>
                  {RESEARCH_STAGES[pdata.research_stage] || 'UNKNOWN'}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Box>
        ))
      )}
    </Section>
  );
};

const ResearchTab = (props) => {
  const { research_data, research_points, inserted_sample, act } = props;

  const researchable = research_data.filter(
    (p) => p.research_stage < 5
  );

  return (
    <Section title="CURE DEVELOPMENT">
      {researchable.length === 0 ? (
        <NoticeBox success>
          All known pathogens have been fully researched.
        </NoticeBox>
      ) : (
        researchable.map((pdata, i) => {
          const isResearching = pdata.progress > 0;
          const canAfford = research_points >= pdata.point_cost;
          const hasReagent = !pdata.reagent?.name
            || (inserted_sample?.reagents || []).some(
              (r) => r.name === pdata.reagent.name && r.volume >= pdata.reagent.amount
            );
          const canStart = !isResearching && canAfford && hasReagent;

          return (
            <Box key={i} mb={1} pl={1} style={{
              'border-left': `3px solid ${BSL_COLORS[pdata.bsl] || '#6a6a70'}`,
            }}>
              <Flex align="center" justify="space-between">
                <Flex.Item grow={1}>
                  <Box bold color={pdata.anomalous ? '#ff4444' : '#c8c8c8'}>
                    {pdata.name}
                  </Box>
                  <Box fontSize="11px" color="#6a6a70">
                    Stage: {RESEARCH_STAGES[pdata.research_stage]} &rarr;{' '}
                    {RESEARCH_STAGES[pdata.research_stage + 1] || 'CURED'}
                  </Box>
                </Flex.Item>
                <Flex.Item>
                  {pdata.research_stage >= 5 && (
                    <Button
                      content="Dispense Cure"
                      color="good"
                      onClick={() => act('dispense_cure', {
                        pathogen_type: pdata.type,
                      })}
                    />
                  )}
                </Flex.Item>
              </Flex>
              {isResearching && (
                <Box mt={0.5}>
                  <ProgressBar
                    value={pdata.progress}
                    minValue={0}
                    maxValue={1}
                    color={pdata.progress >= 1 ? 'good' : 'average'}
                  >
                    {Math.round(pdata.progress * 100)}%
                    {' '}({formatTime(pdata.time_remaining)} remaining)
                    {pdata.researcher && (
                      <Box inline ml={1} color="#6a6a70">
                        [{pdata.researcher}]
                      </Box>
                    )}
                  </ProgressBar>
                  <Button
                    content="CANCEL"
                    color="bad"
                    fontSize="10px"
                    mt={0.5}
                    onClick={() => act('cancel_research', {
                      pathogen_type: pdata.type,
                    })}
                  />
                </Box>
              )}
              {!isResearching && pdata.research_stage < 5 && (
                <Box mt={0.5}>
                  <Box fontSize="11px" color="#6a6a70">
                    Cost: {pdata.point_cost} pts
                    {pdata.reagent?.name && (
                      <>
                        {' '}| {pdata.reagent.name} x{pdata.reagent.amount}
                        <Box
                          inline
                          ml={1}
                          color={hasReagent ? '#44ff44' : '#ff4444'}
                        >
                          [{hasReagent ? 'READY' : 'NEEDED'}]
                        </Box>
                      </>
                    )}
                    {' '}| Est. {formatTime(pdata.research_time)}
                  </Box>
                  <Button
                    content="START RESEARCH"
                    color={canStart ? 'good' : 'bad'}
                    disabled={!canStart}
                    mt={0.5}
                    onClick={() => act('start_research', {
                      pathogen_type: pdata.type,
                    })}
                  />
                  {!canAfford && (
                    <Box inline ml={1} fontSize="10px" color="#ff4444">
                      INSUFFICIENT POINTS
                    </Box>
                  )}
                  {!hasReagent && pdata.reagent?.name && (
                    <Box inline ml={1} fontSize="10px" color="#ff4444">
                      INSERT {pdata.reagent.name}
                    </Box>
                  )}
                </Box>
              )}
            </Box>
          );
        })
      )}
    </Section>
  );
};

const SelfScanTab = (props) => {
  const { host_diseases, act } = props;

  return (
    <Section title="SELF-DIAGNOSTIC SCAN">
      {host_diseases.length === 0 ? (
        <NoticeBox success>No pathogens detected in system.</NoticeBox>
      ) : (
        host_diseases.map((disease, i) => (
          <Box key={i} mb={1} pl={1} style={{
            'border-left': `3px solid ${BSL_COLORS[disease.bsl] || '#6a6a70'}`,
          }}>
            <Flex align="center" justify="space-between">
              <Flex.Item>
                <Box bold color={disease.anomalous ? '#ff4444' : '#c8c8c8'}>
                  {disease.name}
                </Box>
                <Box fontSize="11px" color="#6a6a70">
                  BSL: {disease.bsl} | Stage: {disease.stage}/{disease.max_stage}
                </Box>
              </Flex.Item>
              <Flex.Item>
                {disease.anomalous && (
                  <Button
                    content="Administer SCP-500"
                    color="bad"
                    onClick={() => act('administer_scp500')}
                  />
                )}
              </Flex.Item>
            </Flex>
          </Box>
        ))
      )}
    </Section>
  );
};
