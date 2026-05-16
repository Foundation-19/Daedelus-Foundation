import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, NumberInput } from '../components';
import { Window } from '../layouts';

type CategoryItem = {
  name: string;
  path: string;
};

type Category = {
  items: CategoryItem[];
  name: string;
};

type CreatePanelData = {
  amount: number;
  categories: Category[];
  panel_type: string;
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  accent: '#c2960e',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  text: '#b0b0b0',
  textBright: '#e0e0e0',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const TermButton = (props) => {
  const { color, ...rest } = props;
  const borderColor =
    color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border;
  return (
    <Button
      {...rest}
      style={{
        fontFamily: C.mono,
        fontSize: '9px',
        letterSpacing: '0.08em',
        textTransform: 'uppercase',
        background: 'transparent',
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color:
          color === 'red'
            ? C.redBright
            : color === 'green'
              ? '#33cc33'
              : C.textDim,
        padding: '2px 6px',
      }}
    />
  );
};

export const AdminCreatePanel = (_props: unknown) => {
  const { act, data } = useBackend<CreatePanelData>();
  const { categories = [], panel_type } = data;
  const [filter, setFilter] = useLocalState('cpfilter', '');
  const [amount, setAmount] = useLocalState('cpamount', 1);
  const [selectedPath, setSelectedPath] = useLocalState('cppath', '');
  const [expandedCat, setExpandedCat] = useLocalState('cpcat', '');

  const panelTitle =
    panel_type === 'object'
      ? 'OBJECT MANIFESTATION'
      : panel_type === 'mob'
        ? 'ENTITY MANIFESTATION'
        : 'TERRAIN MODIFICATION';

  return (
    <Window theme="scp_terminal" width={700} height={550}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderRed}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              SCP FOUNDATION — {panelTitle}
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | SPAWN CONTROL | TYPE:{' '}
              {panel_type.toUpperCase()}
            </Box>
          </Box>

          <Box
            style={{
              padding: '8px 14px',
              borderBottom: `1px solid ${C.border}`,
            }}
          >
            <Box style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
              <Box
                style={{
                  fontSize: '10px',
                  color: C.textDim,
                  letterSpacing: '0.12em',
                  textTransform: 'uppercase',
                }}
              >
                FILTER:
              </Box>
              <Input
                value={filter}
                onInput={(_e, value) => setFilter(value)}
                placeholder="Path search..."
                style={{ fontFamily: C.mono, fontSize: '12px', flex: 1 }}
              />
              <Box
                style={{
                  fontSize: '10px',
                  color: C.textDim,
                  letterSpacing: '0.1em',
                }}
              >
                AMT:
              </Box>
              <NumberInput
                value={amount}
                minValue={1}
                maxValue={50}
                step={1}
                onChange={(value) => setAmount(value)}
              />
            </Box>
          </Box>

          {selectedPath && (
            <Box
              style={{
                padding: '8px 14px',
                borderBottom: `1px solid ${C.border}`,
                background: C.panel,
              }}
            >
              <Box
                style={{
                  fontSize: '10px',
                  color: C.textDim,
                  letterSpacing: '0.1em',
                  textTransform: 'uppercase',
                  marginBottom: '4px',
                }}
              >
                SELECTED
              </Box>
              <Box
                style={{
                  fontSize: '11px',
                  color: C.amber,
                  wordBreak: 'break-all',
                }}
              >
                {selectedPath}
              </Box>
              <Box style={{ display: 'flex', gap: '4px', marginTop: '6px' }}>
                <TermButton
                  color="green"
                  onClick={() =>
                    act('create', {
                      path: selectedPath,
                      amount: String(amount),
                    })
                  }
                >
                  MANIFEST
                </TermButton>
                <TermButton
                  color="yellow"
                  onClick={() => act('spawn_pod', { path: selectedPath })}
                >
                  POD SPAWN
                </TermButton>
                <TermButton onClick={() => setSelectedPath('')}>
                  CLEAR
                </TermButton>
              </Box>
            </Box>
          )}

          <Box
            style={{ padding: '8px', maxHeight: '350px', overflowY: 'auto' }}
          >
            {categories.map((cat) => {
              const filteredItems = filter
                ? cat.items.filter((item) =>
                    item.path.toLowerCase().includes(filter.toLowerCase()),
                  )
                : cat.items;
              if (filter && filteredItems.length === 0) return null;

              const isExpanded = expandedCat === cat.name || !!filter;
              return (
                <Box key={cat.name} style={{ marginBottom: '4px' }}>
                  <Box
                    style={{
                      padding: '4px 8px',
                      background: C.panel,
                      borderLeft: `2px solid ${C.borderRed}`,
                      cursor: 'pointer',
                      display: 'flex',
                      justifyContent: 'space-between',
                    }}
                    onClick={() =>
                      setExpandedCat(isExpanded && !filter ? '' : cat.name)
                    }
                  >
                    <Box
                      style={{
                        fontSize: '10px',
                        color: C.amber,
                        letterSpacing: '0.08em',
                      }}
                    >
                      {cat.name}
                    </Box>
                    <Box style={{ fontSize: '10px', color: C.textDim }}>
                      {filteredItems.length}
                    </Box>
                  </Box>
                  {isExpanded && (
                    <Box style={{ paddingLeft: '12px' }}>
                      {filteredItems.slice(0, 50).map((item) => (
                        <Box
                          key={item.path}
                          style={{
                            padding: '2px 4px',
                            fontSize: '10px',
                            cursor: 'pointer',
                            background:
                              selectedPath === item.path
                                ? 'rgba(139,0,0,0.2)'
                                : 'transparent',
                            color:
                              selectedPath === item.path ? C.amber : C.textDim,
                            borderBottom: `1px solid ${C.border}`,
                          }}
                          onClick={() => setSelectedPath(item.path)}
                        >
                          {item.path}
                        </Box>
                      ))}
                      {filteredItems.length > 50 && (
                        <Box
                          style={{
                            padding: '4px',
                            fontSize: '10px',
                            color: C.textDim,
                            fontStyle: 'italic',
                          }}
                        >
                          ...and {filteredItems.length - 50} more (use filter to
                          narrow)
                        </Box>
                      )}
                    </Box>
                  )}
                </Box>
              );
            })}
          </Box>

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={{
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              }}
            >
              SCP FOUNDATION | MANIFESTATION CONTROL | UNAUTHORIZED SPAWN IS A
              CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
