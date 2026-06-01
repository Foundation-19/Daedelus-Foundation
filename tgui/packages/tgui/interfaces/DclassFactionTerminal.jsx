import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Divider } from '../components';
import { Window } from '../layouts';

const FACTION_COLORS = {
  rebels: 'bad',
  collaborators: 'good',
  survivors: 'average',
};

export const DclassFactionTerminal = (props, context) => {
  const { act, data } = useBackend(context);
  const faction = data.faction || 0;
  const factionName = data.faction_name || 'None';
  const factionDesc = data.faction_desc || '';
  const factionPerks = data.faction_perks || [];
  const informant = data.informant || false;
  const informantReports = data.informant_reports || 0;
  const trustLevel = data.trust_level || 0;
  const factions = data.factions || [];

  return (
    <Window width={500} height={600} theme="scp_terminal">
      <Window.Content scrollable>
        <Section title="Current Status">
          <LabeledList>
            <LabeledList.Item label="Faction">
              {faction === 0 ? (
                <Box color="label">Unaffiliated</Box>
              ) : (
                <Box bold color={FACTION_COLORS[Object.keys(FACTION_COLORS)[faction - 1]]}>
                  {factionName}
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Trust Level">
              {['Hostile', 'Suspicious', 'Neutral', 'Cooperative', 'Trusted'][trustLevel] || 'Unknown'}
            </LabeledList.Item>
            <LabeledList.Item label="Informant">
              {informant ? (
                <Box bold color="good">Active ({informantReports} reports filed)</Box>
              ) : (
                <Box color="label">Not enrolled</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        {faction !== 0 && factionDesc && (
          <Section title={`Faction: ${factionName}`}>
            <Box mb={1}>{factionDesc}</Box>
            {factionPerks.length > 0 && (
              <Box>
                <Box bold mb={0.5}>Perks:</Box>
                {factionPerks.map((perk, i) => (
                  <Box key={i} color="label">- {perk.replace(/_/g, ' ')}</Box>
                ))}
              </Box>
            )}
            <Button
              mt={1}
              color="bad"
              content="Leave Faction"
              onClick={() => act('leave_faction')}
            />
          </Section>
        )}

        {faction === 0 && (
          <Section title="Available Factions">
            <Stack vertical>
              {factions.map(f => (
                <Stack.Item key={f.key}>
                  <Section
                    title={f.name}
                    buttons={(
                      <Button
                        color={FACTION_COLORS[f.key]}
                        content="Join"
                        onClick={() => act('join_faction', { faction: f.key })}
                      />
                    )}
                  >
                    <Box mb={0.5}>{f.description}</Box>
                    <Box fontSize="12px" color="label">
                      Members: {f.member_count} | Perks: {f.perks.join(', ').replace(/_/g, ' ')}
                    </Box>
                  </Section>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        )}

        <Divider />

        <Section title="Volunteer for Testing">
          <Box mb={1}>
            Sign up to be a test subject for SCP research. You will receive
            bonus credits and trust. A guard will escort you to the testing area
            when a researcher has a test ready.
          </Box>
          <Button
            color="good"
            content="Volunteer for SCP Testing"
            onClick={() => act('volunteer_for_testing')}
          />
        </Section>

        <Divider />

        <Section title="Informant Program">
          {!informant ? (
            <>
              <Box mb={1}>
                Report escape plans and suspicious activity to Foundation staff.
                Informants receive credits and trust bonuses for each report.
              </Box>
              <Box mb={1} color="label">
                Requires Neutral or higher trust level to enroll.
              </Box>
              <Button
                color="good"
                content="Sign Up as Informant"
                disabled={trustLevel < 2}
                onClick={() => act('become_informant')}
              />
            </>
          ) : (
            <>
              <Box bold color="good" mb={1}>
                You are an enrolled informant. File reports below.
              </Box>
              <Button
                color="average"
                content="Report Escape Plan"
                onClick={() => act('report_plan', {
                  plan: 'escape_activity',
                  participants: 1,
                })}
              />
              <Button
                color="average"
                content="Report Suspicious Activity"
                onClick={() => act('report_plan', {
                  plan: 'suspicious_activity',
                  participants: 0,
                })}
              />
              <Button
                color="average"
                content="Report Contraband Stash"
                onClick={() => act('report_plan', {
                  plan: 'contraband_stash',
                  participants: 0,
                })}
              />
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
