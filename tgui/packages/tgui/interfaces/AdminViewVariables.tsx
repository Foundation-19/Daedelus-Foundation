import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input } from '../components';
import { Window } from '../layouts';

type VarEntry = {
  is_editable: number;
  name: string;
  value: string;
};

type VVCommand = {
  key: string;
  label: string;
};

type ViewVariablesData = {
  commands: VVCommand[];
  is_atom: number;
  is_datum: number;
  is_deleted: number;
  is_image: number;
  is_list: number;
  is_marked: number;
  is_tagged: number;
  is_var_edited: number;
  name: string;
  ref: string;
  tag_index: number;
  type: string;
  vars: VarEntry[];
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

const formatValue = (value: string): string => {
  if (value === 'null') return 'null';
  if (value === 'TRUE' || value === 'FALSE') return value;
  if (value.length > 120) return value.substring(0, 120) + '...';
  return value;
};

export const AdminViewVariables = (_props: unknown) => {
  const { act, data } = useBackend<ViewVariablesData>();
  const {
    commands = [],
    is_atom,
    is_datum,
    is_deleted,
    is_list,
    is_marked,
    is_tagged,
    is_var_edited,
    name,
    ref,
    type,
    vars = [],
  } = data;
  const [filter, setFilter] = useLocalState('vvfilter', '');

  const filteredVars = vars.filter((v) => {
    if (!filter) return true;
    const f = filter.toLowerCase();
    return (
      v.name.toLowerCase().includes(f) || v.value?.toLowerCase().includes(f)
    );
  });

  return (
    <Window theme="scp_terminal" width={750} height={650}>
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
              SCP FOUNDATION — ANOMALY INSPECTOR
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | DATA FORENSICS | VARIABLE INSPECTION
            </Box>
          </Box>

          <Box
            style={{
              padding: '8px 14px',
              borderBottom: `1px solid ${C.border}`,
              background: C.panel,
            }}
          >
            <Box
              style={{
                fontSize: '13px',
                fontWeight: 'bold',
                color: C.textBright,
                marginBottom: '4px',
              }}
            >
              {name}
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                wordBreak: 'break-all',
                marginBottom: '4px',
              }}
            >
              TYPE: {type}
            </Box>
            <Box
              style={{ fontSize: '9px', color: C.textDim, marginBottom: '4px' }}
            >
              REF: {ref}
            </Box>
            <Box style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
              {is_marked ? (
                <Box
                  style={{
                    fontSize: '9px',
                    color: C.amber,
                    border: `1px solid ${C.amber}`,
                    padding: '1px 6px',
                  }}
                >
                  MARKED
                </Box>
              ) : null}
              {is_tagged ? (
                <Box
                  style={{
                    fontSize: '9px',
                    color: '#44aaff',
                    border: '1px solid #44aaff',
                    padding: '1px 6px',
                  }}
                >
                  TAGGED
                </Box>
              ) : null}
              {is_var_edited ? (
                <Box
                  style={{
                    fontSize: '9px',
                    color: C.redBright,
                    border: `1px solid ${C.redBright}`,
                    padding: '1px 6px',
                  }}
                >
                  VAR EDITED
                </Box>
              ) : null}
              {is_deleted ? (
                <Box
                  style={{
                    fontSize: '9px',
                    color: C.redBright,
                    border: `1px solid ${C.redBright}`,
                    padding: '1px 6px',
                  }}
                >
                  DELETED
                </Box>
              ) : null}
            </Box>
          </Box>

          <Box
            style={{
              padding: '6px 14px',
              borderBottom: `1px solid ${C.border}`,
              display: 'flex',
              gap: '4px',
              flexWrap: 'wrap',
              alignItems: 'center',
            }}
          >
            <TermButton color="green" onClick={() => act('refresh')}>
              REFRESH
            </TermButton>
            <TermButton
              color={is_marked ? 'green' : undefined}
              selected={!!is_marked}
              onClick={() => act('mark')}
            >
              {is_marked ? '[MARKED]' : 'MARK'}
            </TermButton>
            <TermButton
              color={is_tagged ? 'green' : undefined}
              selected={!!is_tagged}
              onClick={() => act('tag')}
            >
              {is_tagged ? '[TAGGED]' : 'TAG'}
            </TermButton>
            {is_list ? (
              <>
                <TermButton onClick={() => act('list_add')}>
                  ADD ITEM
                </TermButton>
                <TermButton onClick={() => act('list_set_length')}>
                  SET LENGTH
                </TermButton>
                <TermButton onClick={() => act('list_erase_nulls')}>
                  ERASE NULLS
                </TermButton>
                <TermButton onClick={() => act('list_erase_dupes')}>
                  ERASE DUPES
                </TermButton>
                <TermButton onClick={() => act('list_shuffle')}>
                  SHUFFLE
                </TermButton>
              </>
            ) : null}
            <TermButton onClick={() => act('expose')}>
              EXPOSE TO PLAYER
            </TermButton>
          </Box>

          {commands.length > 0 && (
            <Box
              style={{
                padding: '6px 14px',
                borderBottom: `1px solid ${C.border}`,
              }}
            >
              <Box
                style={{
                  fontSize: '9px',
                  color: C.textDim,
                  letterSpacing: '0.12em',
                  textTransform: 'uppercase',
                  marginBottom: '4px',
                }}
              >
                COMMANDS
              </Box>
              <Box style={{ display: 'flex', gap: '3px', flexWrap: 'wrap' }}>
                {commands.map((cmd) => (
                  <TermButton
                    key={cmd.key}
                    color={
                      cmd.key === 'delete' || cmd.key === 'gib'
                        ? 'red'
                        : cmd.key === 'godmode' ||
                            cmd.key === 'direct_control' ||
                            cmd.key === 'buildmode'
                          ? 'green'
                          : undefined
                    }
                    onClick={() => act('vv_action', { vv_key: cmd.key })}
                  >
                    {cmd.label.toUpperCase()}
                  </TermButton>
                ))}
              </Box>
            </Box>
          )}

          <Box
            style={{
              padding: '6px 14px',
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
                SEARCH:
              </Box>
              <Input
                value={filter}
                onInput={(_e, value) => setFilter(value)}
                placeholder="Variable name or value..."
                style={{ fontFamily: C.mono, fontSize: '12px', flex: 1 }}
              />
              <Box style={{ fontSize: '9px', color: C.textDim }}>
                {filteredVars.length}/{vars.length} VARS
              </Box>
            </Box>
          </Box>

          <Box style={{ maxHeight: '380px', overflowY: 'auto' }}>
            <Box
              style={{
                display: 'flex',
                padding: '4px 14px',
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.1em',
                textTransform: 'uppercase',
                borderBottom: `1px solid ${C.border}`,
                background: C.panel,
                position: 'sticky',
                top: 0,
                zIndex: 1,
              }}
            >
              <Box style={{ width: '30px' }}>ACT</Box>
              <Box style={{ flex: '2' }}>VARIABLE</Box>
              <Box style={{ flex: '3' }}>VALUE</Box>
            </Box>

            {filteredVars.map((v) => (
              <Box
                key={v.name}
                style={{
                  display: 'flex',
                  padding: '2px 14px',
                  borderBottom: `1px solid ${C.border}`,
                  fontSize: '10px',
                  alignItems: 'center',
                }}
              >
                <Box style={{ width: '30px' }}>
                  {v.is_editable ? (
                    <TermButton
                      onClick={() => act('edit_var', { var_name: v.name })}
                    >
                      E
                    </TermButton>
                  ) : null}
                </Box>
                <Box
                  style={{
                    flex: '2',
                    color: C.amber,
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {v.name}
                </Box>
                <Box
                  style={{
                    flex: '3',
                    color: C.text,
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {formatValue(v.value)}
                </Box>
              </Box>
            ))}

            {filteredVars.length === 0 && (
              <Box
                style={{
                  textAlign: 'center',
                  color: C.textDim,
                  padding: '20px',
                  fontStyle: 'italic',
                }}
              >
                NO MATCHING VARIABLES
              </Box>
            )}
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
              SCP FOUNDATION | ANOMALY INSPECTOR | DATA FORENSICS | UNAUTHORIZED
              MODIFICATION IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
