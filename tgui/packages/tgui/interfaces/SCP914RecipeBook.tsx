import { BooleanLike } from 'common/react';
import React from 'react';
import { useBackend } from '../backend';
import { Box, Button, Stack } from '../components';
import { NtosWindow } from '../layouts';

type Recipe = {
  id: string;
  input: string;
  output: string;
  setting: string;
  discovered: BooleanLike;
};

type RecentOutput = {
  input: string;
  output: string;
  setting: string;
  time: string;
};

type SCP914Data = {
  recipes: Recipe[];
  current_setting: string;
  available_settings: string[];
  recent_outputs: RecentOutput[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#2ecc40',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const getSettingColor = (setting: string) => {
  switch (setting) {
    case 'Rough':
      return C.redBright;
    case 'Coarse':
      return C.red;
    case '1:1':
      return C.amber;
    case 'Fine':
      return C.green;
    case 'Very Fine':
      return C.greenBright;
    default:
      return C.textDim;
  }
};

export const SCP914RecipeBook = (props) => {
  const { act, data } = useBackend<SCP914Data>();
  const {
    recipes = [],
    current_setting = '',
    available_settings = [],
    recent_outputs = [],
  } = data;

  return (
    <NtosWindow width={700} height={600}>
      <NtosWindow.Content scrollable>
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
              SCP-914 RECIPE CATALOG
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              FOUNDATION RESEARCH DIVISION | REFINE | CATALOG | UNDERSTAND
            </Box>
          </Box>

          <Box style={{ padding: '12px 14px' }}>
            <Box
              style={{
                color: C.amber,
                fontWeight: 'bold',
                letterSpacing: '0.1em',
                fontSize: '11px',
                textTransform: 'uppercase',
                marginBottom: '6px',
              }}
            >
              CURRENT SETTING
            </Box>
            <Box
              style={{
                display: 'flex',
                gap: '4px',
                flexWrap: 'wrap',
                marginBottom: '10px',
              }}
            >
              {available_settings.map((setting) => (
                <Button
                  key={setting}
                  content={setting}
                  selected={setting === current_setting}
                  color={setting === current_setting ? 'default' : 'transparent'}
                  style={{
                    fontFamily: C.mono,
                    fontSize: '11px',
                    color:
                      setting === current_setting
                        ? C.textBright
                        : getSettingColor(setting),
                    border: `1px solid ${
                      setting === current_setting
                        ? C.amber
                        : C.border
                    }`,
                    padding: '2px 8px',
                  }}
                  onClick={() => act('set_setting', { setting })}
                />
              ))}
            </Box>

            <Box
              style={{
                borderBottom: `1px solid ${C.border}`,
                margin: '10px 0',
              }}
            />

            <Box
              style={{
                display: 'flex',
                gap: '6px',
                marginBottom: '10px',
              }}
            >
              <Button
                content="ALL RECIPES"
                style={{
                  fontFamily: C.mono,
                  fontSize: '10px',
                  color: C.amber,
                  border: `1px solid ${C.border}`,
                  padding: '2px 8px',
                }}
                onClick={() => act('filter_discovered')}
              />
              {available_settings.map((setting) => (
                <Button
                  key={setting}
                  content={setting}
                  style={{
                    fontFamily: C.mono,
                    fontSize: '10px',
                    color: getSettingColor(setting),
                    border: `1px solid ${C.border}`,
                    padding: '2px 8px',
                  }}
                  onClick={() => act('filter_setting', { setting })}
                />
              ))}
            </Box>

            <Box
              style={{
                color: C.amber,
                fontWeight: 'bold',
                letterSpacing: '0.1em',
                fontSize: '11px',
                textTransform: 'uppercase',
                marginBottom: '6px',
              }}
            >
              RECIPE DATABASE ({recipes.length})
            </Box>

            <Box
              style={{
                display: 'grid',
                gridTemplateColumns: '1fr auto 1fr',
                gap: '0',
                border: `1px solid ${C.border}`,
                background: C.panel,
              }}
            >
              <Box
                style={{
                  padding: '4px 8px',
                  borderBottom: `1px solid ${C.borderRed}`,
                  color: C.textDim,
                  fontSize: '10px',
                  fontWeight: 'bold',
                  letterSpacing: '0.1em',
                }}
              >
                INPUT
              </Box>
              <Box
                style={{
                  padding: '4px 8px',
                  borderBottom: `1px solid ${C.borderRed}`,
                  color: C.textDim,
                  fontSize: '10px',
                  fontWeight: 'bold',
                  letterSpacing: '0.1em',
                  textAlign: 'center',
                }}
              >
                SETTING
              </Box>
              <Box
                style={{
                  padding: '4px 8px',
                  borderBottom: `1px solid ${C.borderRed}`,
                  color: C.textDim,
                  fontSize: '10px',
                  fontWeight: 'bold',
                  letterSpacing: '0.1em',
                }}
              >
                OUTPUT
              </Box>

              {!recipes.length && (
                <Box
                  style={{
                    padding: '8px',
                    gridColumn: '1 / -1',
                    color: C.textDim,
                    fontStyle: 'italic',
                    textAlign: 'center',
                  }}
                >
                  No recipes catalogued.
                </Box>
              )}

              {recipes.map((recipe) => (
                <React.Fragment key={recipe.id}>
                  <Box
                    style={{
                      padding: '3px 8px',
                      borderBottom: `1px solid ${C.border}`,
                      color: recipe.discovered ? C.textBright : C.textDim,
                      fontSize: '11px',
                    }}
                    onClick={() => act('view_recipe', { id: recipe.id })}
                  >
                    {recipe.discovered ? recipe.input : '???'}
                  </Box>
                  <Box
                    style={{
                      padding: '3px 8px',
                      borderBottom: `1px solid ${C.border}`,
                      color: getSettingColor(recipe.setting),
                      fontSize: '11px',
                      textAlign: 'center',
                    }}
                    onClick={() => act('view_recipe', { id: recipe.id })}
                  >
                    {recipe.setting}
                  </Box>
                  <Box
                    style={{
                      padding: '3px 8px',
                      borderBottom: `1px solid ${C.border}`,
                      color: recipe.discovered ? C.textBright : C.textDim,
                      fontSize: '11px',
                    }}
                    onClick={() => act('view_recipe', { id: recipe.id })}
                  >
                    {recipe.discovered ? recipe.output : '???'}
                  </Box>
                </React.Fragment>
              ))}
            </Box>

            {!!recent_outputs?.length && (
              <>
                <Box
                  style={{
                    borderBottom: `1px solid ${C.border}`,
                    margin: '10px 0',
                  }}
                />

                <Box
                  style={{
                    color: C.amber,
                    fontWeight: 'bold',
                    letterSpacing: '0.1em',
                    fontSize: '11px',
                    textTransform: 'uppercase',
                    marginBottom: '6px',
                  }}
                >
                  RECENT OUTPUTS
                </Box>

                {recent_outputs.map((entry, i) => (
                  <Box
                    key={i}
                    style={{
                      padding: '4px 0',
                      borderLeft: `2px solid ${getSettingColor(
                        entry.setting,
                      )}`,
                      paddingLeft: '8px',
                      marginBottom: '4px',
                    }}
                  >
                    <Box
                      as="span"
                      style={{ color: C.textBright, fontSize: '11px' }}
                    >
                      {entry.input}
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: getSettingColor(entry.setting),
                        fontSize: '11px',
                        margin: '0 6px',
                      }}
                    >
                      [{entry.setting}]
                    </Box>
                    <Box
                      as="span"
                      style={{
                        color: C.green,
                        fontSize: '11px',
                      }}
                    >
                      {entry.output}
                    </Box>
                    {!!entry.time && (
                      <Box
                        as="span"
                        style={{
                          color: C.textDim,
                          fontSize: '10px',
                          marginLeft: '8px',
                        }}
                      >
                        {entry.time}
                      </Box>
                    )}
                  </Box>
                ))}
              </>
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
              SCP-914 | CLOCKWORK REFINING | ITEM CATALOG v2.1 | AUTHORIZED
              PERSONNEL ONLY
            </Box>
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
