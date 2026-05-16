import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const DclassSocial = (props, context) => {
  const { act, data } = useBackend(context);
  const { nearby_players = [] } = data;

  return (
    <Window theme="scp_terminal" width={450} height={500}>
      <Window.Content scrollable>
        {nearby_players.length === 0 ? (
          <Section title="Water Cooler">
            <Box color="average">
              No other D-Class nearby. Wait for someone to come by.
            </Box>
          </Section>
        ) : (
          <Section title="Nearby D-Class">
            {nearby_players.map((player) => (
              <Section
                key={player.player_id}
                title={player.name}
                buttons={
                  <>
                    <Button
                      color={
                        player.relationship === 'Ally' ? 'good' : 'default'
                      }
                      content="Ally"
                      onClick={() =>
                        act('ally', { player_id: player.player_id })
                      }
                    />
                    <Button
                      color="default"
                      content="Trade"
                      onClick={() =>
                        act('trade', { player_id: player.player_id })
                      }
                    />
                    <Button
                      color="bad"
                      content="Report"
                      onClick={() =>
                        act('report', { player_id: player.player_id })
                      }
                    />
                  </>
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Level">
                    {player.level}
                  </LabeledList.Item>
                  <LabeledList.Item label="Relationship">
                    <Box
                      color={
                        player.relationship === 'Ally'
                          ? 'good'
                          : player.relationship === 'Enemy'
                            ? 'bad'
                            : 'average'
                      }
                    >
                      {player.relationship}
                    </Box>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
