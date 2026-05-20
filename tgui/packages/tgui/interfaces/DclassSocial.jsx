import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, LabeledList, Modal, Section, Stack } from '../components';
import { Window } from '../layouts';

const TradeModal = (props, context) => {
  const { act, data } = useBackend(context);
  const { my_trade_items = [] } = data;
  const { player, onClose } = props;
  const [offerRef, setOfferRef] = useLocalState(context, 'trade_offer', null);
  const [requestRef, setRequestRef] = useLocalState(context, 'trade_request', null);

  const myOptions = my_trade_items.map((item) => ({
    displayText: item.name,
    value: item.ref,
  }));

  const theirOptions = (player.trade_items || []).map((item) => ({
    displayText: item.name,
    value: item.ref,
  }));

  const selectedOffer = my_trade_items.find((i) => i.ref === offerRef);
  const selectedRequest = (player.trade_items || []).find(
    (i) => i.ref === requestRef
  );

  return (
    <Modal width="400px">
      <Stack vertical>
        <Stack.Item>
          <Box fontSize="16px" bold textAlign="center">
            Trade with {player.name}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Section title="Your Offer">
            {myOptions.length > 0 ? (
              <Dropdown
                width="100%"
                options={myOptions}
                selected={selectedOffer?.name || ''}
                displayText={selectedOffer?.name || 'Select item to offer...'}
                onSelected={(opt) => setOfferRef(opt.value)}
              />
            ) : (
              <Box color="bad">You have no contraband to trade.</Box>
            )}
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Section title={`Request from ${player.name}`}>
            {theirOptions.length > 0 ? (
              <Dropdown
                width="100%"
                options={theirOptions}
                selected={selectedRequest?.name || ''}
                displayText={
                  selectedRequest?.name || 'Select item to request...'
                }
                onSelected={(opt) => setRequestRef(opt.value)}
              />
            ) : (
              <Box color="bad">They have no contraband to trade.</Box>
            )}
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                color="good"
                content="Confirm Trade"
                disabled={!offerRef || !requestRef}
                onClick={() => {
                  act('trade', {
                    player_id: player.player_id,
                    offer_ref: offerRef,
                    request_ref: requestRef,
                  });
                  setOfferRef(null);
                  setRequestRef(null);
                  onClose();
                }}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                color="bad"
                content="Cancel"
                onClick={() => {
                  setOfferRef(null);
                  setRequestRef(null);
                  onClose();
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

export const DclassSocial = (props, context) => {
  const { act, data } = useBackend(context);
  const { nearby_players = [], my_trade_items = [] } = data;
  const [tradeTarget, setTradeTarget] = useLocalState(
    context,
    'trade_target',
    null
  );

  return (
    <Window theme="scp_terminal" width={450} height={500}>
      <Window.Content scrollable>
        {!!tradeTarget && (
          <TradeModal
            player={tradeTarget}
            onClose={() => setTradeTarget(null)}
          />
        )}
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
                        act('ally', {
                          player_id: player.player_id,
                          name: player.name,
                        })
                      }
                    />
                    <Button
                      color="default"
                      content="Trade"
                      disabled={
                        my_trade_items.length === 0 &&
                        (player.trade_items || []).length === 0
                      }
                      onClick={() => setTradeTarget(player)}
                    />
                    <Button
                      color="bad"
                      content="Report"
                      onClick={() =>
                        act('report', {
                          player_id: player.player_id,
                          name: player.name,
                        })
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
                  <LabeledList.Item label="Trade Items">
                    {(player.trade_items || []).length > 0
                      ? player.trade_items.map((i) => i.name).join(', ')
                      : 'None visible'}
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
