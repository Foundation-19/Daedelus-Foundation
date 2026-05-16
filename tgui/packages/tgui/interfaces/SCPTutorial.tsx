import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Stack } from '../components';
import { Window } from '../layouts';

type PageData = {
  id: string;
  title: string;
  category: string;
  content: string;
};

type TutorialData = {
  pages: PageData[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderCyan: '#005566',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  cyan: '#44aacc',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const stripHtml = (html: string) => {
  return html
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<b>(.*?)<\/b>/gi, '$1')
    .replace(/<span[^>]*>(.*?)<\/span>/gi, '$1')
    .replace(/<[^>]+>/g, '');
};

export const SCPTutorial = (props) => {
  const { data } = useBackend<TutorialData>();
  const { pages } = data;
  const [currentPage, setCurrentPage] = useState(0);

  const page = pages[currentPage];
  if (!page) return null;

  const categories = [...new Set(pages.map((p) => p.category))];

  return (
    <Window theme="scp_terminal" width={600} height={520}>
      <Window.Content>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderCyan}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderCyan}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #040a0e 0%, #08080a 100%)',
              flexShrink: 0,
            }}
          >
            <Box
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.cyan,
                letterSpacing: '2px',
              }}
            >
              FOUNDATION TERMINAL
            </Box>
            <Box style={{ fontSize: '10px', color: C.textDim, marginTop: '2px' }}>
              ORIENTATION & REFERENCE MATERIALS — SITE-53
            </Box>
          </Box>

          <Stack style={{ flex: 1, minHeight: 0 }}>
            <Box
              style={{
                width: '150px',
                flexShrink: 0,
                borderRight: `1px solid ${C.border}`,
                background: C.panel,
                overflowY: 'auto',
                padding: '4px 0',
              }}
            >
              {categories.map((cat) => (
                <Box key={cat}>
                  <Box
                    style={{
                      fontSize: '9px',
                      color: C.cyan,
                      fontWeight: 'bold',
                      padding: '6px 10px 2px',
                      letterSpacing: '1px',
                    }}
                  >
                    {cat.toUpperCase()}
                  </Box>
                  {pages
                    .filter((p) => p.category === cat)
                    .map((p, i) => {
                      const idx = pages.indexOf(p);
                      return (
                        <Box
                          key={p.id}
                          onClick={() => setCurrentPage(idx)}
                          style={{
                            padding: '3px 10px 3px 14px',
                            fontSize: '10px',
                            color:
                              currentPage === idx ? C.cyan : C.textDim,
                            background:
                              currentPage === idx
                                ? 'rgba(68,170,204,0.08)'
                                : 'transparent',
                            cursor: 'pointer',
                            borderLeft:
                              currentPage === idx
                                ? `2px solid ${C.cyan}`
                                : '2px solid transparent',
                          }}
                        >
                          {p.title}
                        </Box>
                      );
                    })}
                </Box>
              ))}
            </Box>

            <Box
              style={{
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                minHeight: 0,
              }}
            >
              <Box
                style={{
                  borderBottom: `1px solid ${C.border}`,
                  padding: '8px 14px',
                  flexShrink: 0,
                }}
              >
                <Box
                  style={{
                    fontSize: '13px',
                    fontWeight: 'bold',
                    color: C.textBright,
                  }}
                >
                  {page.title}
                </Box>
                <Box style={{ fontSize: '9px', color: C.textDim, marginTop: '2px' }}>
                  {page.category} — Page {currentPage + 1} of {pages.length}
                </Box>
              </Box>

              <Box
                style={{
                  flex: 1,
                  padding: '10px 14px',
                  overflowY: 'auto',
                  fontSize: '11px',
                  lineHeight: '1.6',
                  whiteSpace: 'pre-wrap',
                  color: C.text,
                }}
              >
                {stripHtml(page.content)}
              </Box>

              <Box
                style={{
                  borderTop: `1px solid ${C.border}`,
                  padding: '6px 14px',
                  flexShrink: 0,
                }}
              >
                <Stack>
                  <Stack.Item>
                    <Button
                      content="PREV"
                      icon="chevron-left"
                      fontSize="10px"
                      disabled={currentPage === 0}
                      onClick={() =>
                        setCurrentPage(Math.max(0, currentPage - 1))
                      }
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box
                      style={{
                        textAlign: 'center',
                        fontSize: '9px',
                        color: C.textDim,
                        lineHeight: '24px',
                      }}
                    >
                      {currentPage + 1} / {pages.length}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      content="NEXT"
                      icon="chevron-right"
                      fontSize="10px"
                      disabled={currentPage >= pages.length - 1}
                      onClick={() =>
                        setCurrentPage(
                          Math.min(pages.length - 1, currentPage + 1)
                        )
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Box>
            </Box>
          </Stack>

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              fontSize: '9px',
              color: C.textDim,
              textAlign: 'center',
              flexShrink: 0,
            }}
          >
            SCP FOUNDATION — ORIENTATION SYSTEM v1.0
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
