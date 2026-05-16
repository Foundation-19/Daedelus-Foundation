import { useBackend } from '../../backend';
import { Box, Button, Flex, Section, Table } from '../../components';
import { Window } from '../../layouts';

export function LoadoutPanel() {
  const { act, data } = useBackend<any>();

  const currentLoadout = data?.current_loadout || [];
  const categories = data?.categories || [];
  const subcategories = data?.subcategories || [];
  const availableItems = data?.available_items || [];
  const remainingPoints = data?.remaining_points || 0;
  const maxPoints = data?.max_points || 10;
  const currentCategory = data?.current_category || '';
  const currentSubcategory = data?.current_subcategory || '';

  return (
    <Window title="Loadout Manager" width={800} height={600}>
      <Window.Content scrollable>
        <Section title={`Loadout Points: ${remainingPoints}/${maxPoints}`}>
          {currentLoadout.length === 0 ? (
            <Box color="label">No loadout items equipped.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Name</Table.Cell>
                <Table.Cell>Description</Table.Cell>
                <Table.Cell>Cost</Table.Cell>
                <Table.Cell>Action</Table.Cell>
              </Table.Row>
              {currentLoadout.map((item: any) => (
                <Table.Row key={item.path}>
                  <Table.Cell bold>{item.name}</Table.Cell>
                  <Table.Cell color="label">{item.desc}</Table.Cell>
                  <Table.Cell>{item.cost}</Table.Cell>
                  <Table.Cell>
                    <Button
                      color="bad"
                      onClick={() =>
                        act('loadout_toggle', {
                          item: item.path,
                          change_loadout: 1,
                        })
                      }
                    >
                      Remove
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>

        <Section title="Browse Items">
          <Box mb={1}>
            <Box bold mb={0.5}>
              Categories:
            </Box>
            <Flex wrap>
              {categories.map((cat: string) => (
                <Button
                  key={cat}
                  mr={0.5}
                  mb={0.5}
                  selected={cat === currentCategory}
                  onClick={() => act('set_category', { category: cat })}
                >
                  {cat}
                </Button>
              ))}
            </Flex>
          </Box>

          <Box mb={1}>
            <Box bold mb={0.5}>
              Subcategories:
            </Box>
            <Flex wrap>
              {subcategories.map((subcat: string) => (
                <Button
                  key={subcat}
                  mr={0.5}
                  mb={0.5}
                  selected={subcat === currentSubcategory}
                  onClick={() =>
                    act('set_subcategory', { subcategory: subcat })
                  }
                >
                  {subcat}
                </Button>
              ))}
            </Flex>
          </Box>

          <Box>
            <Box bold mb={0.5}>
              Available Items in {currentSubcategory}:
            </Box>
            {availableItems.length === 0 ? (
              <Box color="label">No items available in this category.</Box>
            ) : (
              <Table>
                <Table.Row header>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Description</Table.Cell>
                  <Table.Cell>Cost</Table.Cell>
                  <Table.Cell>Action</Table.Cell>
                </Table.Row>
                {availableItems.map((item: any) => (
                  <Table.Row key={item.path}>
                    <Table.Cell bold>{item.name}</Table.Cell>
                    <Table.Cell color="label">{item.desc}</Table.Cell>
                    <Table.Cell>{item.cost}</Table.Cell>
                    <Table.Cell>
                      <Button
                        color={item.equipped ? 'bad' : 'good'}
                        disabled={!item.equipped && item.cost > remainingPoints}
                        onClick={() =>
                          act('loadout_toggle', {
                            item: item.path,
                            change_loadout: 1,
                          })
                        }
                      >
                        {item.equipped ? 'Remove' : 'Add'}
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
}
