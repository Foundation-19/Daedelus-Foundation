import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const STATE_COLORS = {
  good: 'good',
  neutral: 'label',
  stressed: 'average',
  distressed: 'orange',
  panic: 'bad',
  insane: 'purple',
  catastrophic: 'bad',
};

const STATE_LABELS = {
  good: 'STABLE',
  neutral: 'NOMINAL',
  stressed: 'STRESSED',
  distressed: 'DISTRESSED',
  panic: 'PANIC',
  insane: 'INSANE',
  catastrophic: 'CATATONIC',
};

const TRAUMA_ICONS = {
  scp_exposure: 'biohazard',
  violence: 'fist-raised',
  death: 'skull',
  isolation: 'user-slash',
  psychological: 'brain',
  physical: 'band-aid',
};

const VFX_LABELS = {
  color_distortion: 'Color Distortion',
  blur: 'Visual Blur',
  vignette: 'Vignette',
  jitter: 'Screen Shake',
  wave: 'Wave Distortion',
  static: 'Static Noise',
};

const EPISODE_LABELS = {
  panic_attack: 'PANIC ATTACK',
  dissociative_episode: 'DISSOCIATIVE EPISODE',
  flashback: 'TRAUMA FLASHBACK',
  catatonic_state: 'CATATONIC STATE',
};

const PROFILE_LABELS = {
  default: 'Standard',
  dclass: 'D-Class (Conditioned)',
  mtf: 'MTF Operator',
  researcher: 'Researcher',
  medical: 'Medical Staff',
  security: 'Security',
  engineering: 'Engineering',
  command: 'Command',
};

const formatTime = (deciseconds) => {
  if (deciseconds <= 0) return '--:--';
  const seconds = Math.ceil(deciseconds / 10);
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${s.toString().padStart(2, '0')}`;
};

export const SanityPanel = (props) => {
  const { act, data } = useBackend();

  if (!data) {
    return (
      <Window title="Sanity Monitor" width={700} height={600} theme="scp_terminal">
        <Window.Content>
          <Box color="red">No sanity data available.</Box>
        </Window.Content>
      </Window>
    );
  }

  const { sanity_level, max_sanity, sanity_state, episode_active, is_admin } = data;

  return (
    <Window
      title="SCiPNet Sanity Monitor"
      width={750}
      height={750}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <SanityHeader data={data} />
          </Stack.Item>
          {episode_active && (
            <Stack.Item>
              <EpisodeAlert data={data} act={act} />
            </Stack.Item>
          )}
          <Stack.Item>
            <Flex wrap="wrap" gap={1}>
              <Flex.Item width="48%">
                <SanityMeters data={data} />
              </Flex.Item>
              <Flex.Item width="48%">
                <ProfileCard data={data} />
              </Flex.Item>
            </Flex>
          </Stack.Item>
          <Stack.Item>
            <Flex wrap="wrap" gap={1}>
              <Flex.Item width="48%">
                <TraumaList data={data} act={act} is_admin={is_admin} />
              </Flex.Item>
              <Flex.Item width="48%">
                <SCPExposures data={data} />
              </Flex.Item>
            </Flex>
          </Stack.Item>
          <Stack.Item>
            <Flex wrap="wrap" gap={1}>
              <Flex.Item width="48%">
                <MedicationTracker data={data} act={act} />
              </Flex.Item>
              <Flex.Item width="48%">
                <ActiveEffects data={data} />
              </Flex.Item>
            </Flex>
          </Stack.Item>
          <Stack.Item>
            <MedicalRecommendations data={data} />
          </Stack.Item>
          {!!is_admin && (
            <Stack.Item>
              <AdminControls data={data} act={act} />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SanityHeader = (props) => {
  const { data } = props;
  const { sanity_level, max_sanity, sanity_state, sanity_percentage } = data;
  const stateColor = STATE_COLORS[sanity_state] || 'label';
  const stateLabel = STATE_LABELS[sanity_state] || sanity_state?.toUpperCase();

  return (
    <Section title="Mental Health Status">
      <Flex align="center" justify="space-between">
        <Flex.Item grow={1}>
          <ProgressBar
            value={sanity_level}
            minValue={0}
            maxValue={max_sanity}
            color={stateColor}
            height={3}
          >
            <Box textAlign="center" bold fontSize="14px">
              {sanity_percentage}% — {stateLabel}
            </Box>
          </ProgressBar>
        </Flex.Item>
      </Flex>
      {sanity_state === 'catastrophic' && (
        <Box color="red" bold textAlign="center" mt={1} fontSize="13px">
          <Icon name="exclamation-triangle" mr={1} />
          CRITICAL: SUBJECT REQUIRES IMMEDIATE PSYCHIATRIC INTERVENTION
          <Icon name="exclamation-triangle" ml={1} />
        </Box>
      )}
    </Section>
  );
};

const EpisodeAlert = (props) => {
  const { data, act } = props;
  const { episode_type } = data;
  const label = EPISODE_LABELS[episode_type] || episode_type;

  return (
    <Section backgroundColor="rgba(139, 0, 0, 0.3)" title="ACTIVE PSYCHIATRIC EPISODE">
      <Flex align="center" justify="space-between">
        <Flex.Item>
          <Box color="red" bold fontSize="16px">
            <Icon name="exclamation-circle" mr={1} />
            {label}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="hand-holding-medical"
            color="bad"
            onClick={() => act('dismiss_episode')}
          >
            Attempt Recovery
          </Button>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const SanityMeters = (props) => {
  const { data } = props;
  const {
    hallucination_level, max_hallucination,
    insanity_level, max_insanity,
    social_isolation, max_social_isolation,
    environmental_drain, recovery_rate,
    treatment_effectiveness,
  } = data;

  return (
    <Section title="Vital Meters" level={2}>
      <LabeledList>
        <LabeledList.Item label="Hallucination">
          <ProgressBar
            value={hallucination_level}
            minValue={0}
            maxValue={max_hallucination}
            color={hallucination_level > 60 ? 'bad' : hallucination_level > 30 ? 'average' : 'good'}
          >
            {hallucination_level}/{max_hallucination}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Insanity">
          <ProgressBar
            value={insanity_level}
            minValue={0}
            maxValue={max_insanity}
            color={insanity_level > 60 ? 'bad' : insanity_level > 30 ? 'average' : 'good'}
          >
            {insanity_level}/{max_insanity}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Social Isolation">
          <ProgressBar
            value={social_isolation}
            minValue={0}
            maxValue={max_social_isolation}
            color={social_isolation > 70 ? 'bad' : social_isolation > 40 ? 'average' : 'good'}
          >
            {social_isolation}/{max_social_isolation}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Env. Drain">
          <Box color={environmental_drain > 0.3 ? 'bad' : 'good'}>
            {environmental_drain?.toFixed(3) || 0}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Recovery Rate">
          <Box color={recovery_rate > 0.5 ? 'good' : 'average'}>
            {recovery_rate?.toFixed(2) || 0}/tick
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Treatment Eff.">
          <Box color={treatment_effectiveness >= 1.0 ? 'good' : 'average'}>
            {((treatment_effectiveness || 1) * 100).toFixed(0)}%
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ProfileCard = (props) => {
  const { data } = props;
  const { profile, statistics, prognosis } = data;
  const profileLabel = PROFILE_LABELS[profile?.profile] || profile?.profile || 'Standard';

  return (
    <Section title="Personnel Profile" level={2}>
      <LabeledList>
        <LabeledList.Item label="Profile">
          <Box bold color="amber">{profileLabel}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Conditioning">
          <ProgressBar
            value={profile?.conditioning_resistance || 0}
            minValue={0}
            maxValue={0.5}
            color="good"
          >
            {((profile?.conditioning_resistance || 0) * 100).toFixed(0)}%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Memetic Vuln.">
          <Box color={(profile?.memetic_vulnerability || 1) > 1.2 ? 'bad' : 'good'}>
            {((profile?.memetic_vulnerability || 1) * 100).toFixed(0)}%
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Combat Resist.">
          <ProgressBar
            value={profile?.combat_stress_resistance || 0}
            minValue={0}
            maxValue={0.5}
            color="average"
          >
            {((profile?.combat_stress_resistance || 0) * 100).toFixed(0)}%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Med. Horror Resist.">
          <Box color={(profile?.medical_horror_resistance || 0) > 0.2 ? 'good' : 'label'}>
            {((profile?.medical_horror_resistance || 0) * 100).toFixed(0)}%
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Prognosis">
          <Box bold color={prognosis === 'Critical' || prognosis === 'Poor' ? 'bad' : prognosis === 'Fair' ? 'average' : 'good'}>
            {prognosis}
          </Box>
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1} fontSize="11px" color="label">
        Breakdowns: {statistics?.breakdowns || 0} | Lost: {statistics?.total_lost?.toFixed(1) || 0} | Gained: {statistics?.total_gained?.toFixed(1) || 0}
      </Box>
    </Section>
  );
};

const TraumaList = (props) => {
  const { data, act, is_admin } = props;
  const { traumas } = data;

  return (
    <Section title="Active Traumas" level={2} buttons={
      !!is_admin && (
        <Button icon="trash" color="bad" size="tiny" onClick={() => act('admin_clear_traumas')}>
          Clear All (Admin)
        </Button>
      )
    }>
      {traumas && traumas.length > 0 ? (
        <Table>
          <Table.Row header>
            <Table.Cell>Type</Table.Cell>
            <Table.Cell>Severity</Table.Cell>
            <Table.Cell>Drain</Table.Cell>
          </Table.Row>
          {traumas.map((trauma, i) => (
            <Table.Row key={i}>
              <Table.Cell>
                <Icon name={TRAUMA_ICONS[trauma.type] || 'question'} mr={1} />
                {trauma.type?.replace(/_/g, ' ')}
              </Table.Cell>
              <Table.Cell>
                <ProgressBar
                  value={trauma.severity}
                  minValue={0}
                  maxValue={30}
                  color={trauma.severity > 20 ? 'bad' : 'average'}
                  fontSize="10px"
                >
                  {trauma.severity?.toFixed(1)}
                </ProgressBar>
              </Table.Cell>
              <Table.Cell color="bad">
                -{trauma.drain?.toFixed(2)}/tick
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Box color="good" textAlign="center" p={1}>
          <Icon name="check-circle" mr={1} />No active traumas
        </Box>
      )}
    </Section>
  );
};

const SCPExposures = (props) => {
  const { data } = props;
  const { scp_exposures } = data;

  return (
    <Section title="SCP Exposures" level={2}>
      {scp_exposures && scp_exposures.length > 0 ? (
        <Table>
          <Table.Row header>
            <Table.Cell>SCP</Table.Cell>
            <Table.Cell>Time Since</Table.Cell>
          </Table.Row>
          {scp_exposures.map((exp, i) => (
            <Table.Row key={i}>
              <Table.Cell bold color="amber">{exp.scp_id}</Table.Cell>
              <Table.Cell color="label">
                {formatTime(exp.time_since)}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Box color="good" textAlign="center" p={1}>
          <Icon name="shield-alt" mr={1} />No SCP exposures recorded
        </Box>
      )}
    </Section>
  );
};

const MedicationTracker = (props) => {
  const { data, act } = props;
  const { medications } = data;

  return (
    <Section title="Active Medications" level={2} buttons={
      <Flex>
        <Button icon="pills" size="tiny" color="good" onClick={() => act('medicate_antipsychotic')} tooltip="Administer antipsychotic">
          Antipsychotic
        </Button>
        <Button icon="pills" size="tiny" color="average" onClick={() => act('medicate_antianxiety')} tooltip="Administer anti-anxiety">
          Anti-Anxiety
        </Button>
        <Button icon="pills" size="tiny" color="label" onClick={() => act('medicate_sedative')} tooltip="Administer sedative">
          Sedative
        </Button>
      </Flex>
    }>
      {medications && medications.length > 0 ? (
        <Table>
          <Table.Row header>
            <Table.Cell>Medication</Table.Cell>
            <Table.Cell>Effectiveness</Table.Cell>
            <Table.Cell>Remaining</Table.Cell>
          </Table.Row>
          {medications.map((med, i) => (
            <Table.Row key={i}>
              <Table.Cell>{med.name}</Table.Cell>
              <Table.Cell>
                <ProgressBar value={med.effectiveness} minValue={0} maxValue={2} fontSize="10px">
                  {((med.effectiveness || 1) * 100).toFixed(0)}%
                </ProgressBar>
              </Table.Cell>
              <Table.Cell color="label">
                {med.time_remaining < 0 ? 'Permanent' : formatTime(med.time_remaining)}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Box color="label" textAlign="center" p={1}>
          No active medications
        </Box>
      )}
    </Section>
  );
};

const ActiveEffects = (props) => {
  const { data } = props;
  const { insanity_effects, active_vfx } = data;

  return (
    <Section title="Active Effects" level={2}>
      {insanity_effects && insanity_effects.length > 0 && (
        <Box mb={1}>
          <Box color="label" fontSize="11px" mb={0.5}>Insanity Effects:</Box>
          {insanity_effects.map((effect, i) => (
            <Box key={i} color="bad" fontSize="12px" mb={0.5}>
              <Icon name="exclamation-triangle" mr={1} />
              {effect?.replace(/_/g, ' ').toUpperCase()}
            </Box>
          ))}
        </Box>
      )}
      {active_vfx && active_vfx.length > 0 && (
        <Box>
          <Box color="label" fontSize="11px" mb={0.5}>Visual Effects:</Box>
          {active_vfx.map((vfx, i) => (
            <Box key={i} color="average" fontSize="12px" mb={0.5}>
              <Icon name="eye" mr={1} />
              {VFX_LABELS[vfx] || vfx}
            </Box>
          ))}
        </Box>
      )}
      {(!insanity_effects || insanity_effects.length === 0) && (!active_vfx || active_vfx.length === 0) && (
        <Box color="good" textAlign="center" p={1}>
          <Icon name="check-circle" mr={1} />No active effects
        </Box>
      )}
    </Section>
  );
};

const MedicalRecommendations = (props) => {
  const { data } = props;
  const { recommendations } = data;

  return (
    <Section title="Medical Recommendations" level={2}>
      {recommendations && recommendations.length > 0 ? (
        recommendations.map((rec, i) => (
          <Box key={i} mb={0.5} p={0.5} backgroundColor="rgba(212, 160, 23, 0.1)" fontSize="12px">
            <Icon name="notes-medical" color="amber" mr={1} />
            {rec}
          </Box>
        ))
      ) : (
        <Box color="good" textAlign="center" p={1}>
          <Icon name="check-circle" mr={1} />No treatment recommendations — subject is stable
        </Box>
      )}
    </Section>
  );
};

const AdminControls = (props) => {
  const { data, act } = props;

  return (
    <Collapsible title="Admin Controls" color="red" icon="cog">
      <Section level={2}>
        <Flex wrap="wrap" gap={1}>
          <Flex.Item>
            <Button icon="heart" color="good" onClick={() => act('admin_set_sanity', { amount: 100 })}>
              Full Sanity
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button icon="brain" color="average" onClick={() => act('admin_set_sanity', { amount: 50 })}>
              50% Sanity
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button icon="skull" color="bad" onClick={() => act('admin_set_sanity', { amount: 5 })}>
              Near Zero
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button icon="trash" color="bad" onClick={() => act('admin_clear_traumas')}>
              Clear Traumas
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button icon="redo" color="good" onClick={() => act('admin_reset_sanity')}>
              Full Reset
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </Collapsible>
  );
};
