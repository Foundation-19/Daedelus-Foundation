import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

export const DclassCommissary = (props, context) => {
  const { act, data } = useBackend(context);
  const credits = data.credits || 0;
  const products = data.products || [];

  return (
    <Window width={400} height={520} theme="scp_terminal">
      <Window.Content scrollable>
        <Section title="D-Class Commissary">
          <Box fontSize="16px" bold mb={1}>
            Credits: {credits}
          </Box>
        </Section>
        <Section title="Available Items">
          <Stack vertical>
            {products.map(product => (
              <Stack.Item key={product.id}>
                <Stack>
                  <Stack.Item grow={1}>
                    <Box bold>{product.name}</Box>
                    <Box fontSize="12px" color="label">{product.desc}</Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      content={`${product.cost}cr`}
                      disabled={credits < product.cost}
                      onClick={() => act('purchase', {
                        id: product.id,
                        cost: product.cost,
                      })}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};