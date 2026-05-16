import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section } from '../components';
import { NtosWindow } from '../layouts';

type Page = {
  id: string;
  title: string;
  category: string;
};

type CurrentPage = {
  title: string;
  content: string;
};

type IntranetData = {
  pages: Page[];
  current_page: CurrentPage | null;
  search_results: string[];
  bookmarks: string[];
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#2a2a30',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

export const NtosFoundationIntranet = (_props: unknown) => {
  const { act, data } = useBackend<IntranetData>();
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    'intraSearch',
    '',
  );
  const [tab, setTab] = useLocalState<string>('intraTab', 'browse');

  const {
    pages = [],
    current_page = null,
    search_results = [],
    bookmarks = [],
  } = data;

  const categories = Array.from(new Set(pages.map((p) => p.category)));

  const TABS = [
    { key: 'browse', label: 'BROWSE' },
    { key: 'search', label: 'SEARCH' },
    { key: 'bookmarks', label: 'BOOKMARKS' },
  ];

  return (
    <NtosWindow theme="scp_terminal" width={650} height={550}>
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
              background:
                'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '14px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              FOUNDATION INTRANET
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              SECURE DOCUMENT ACCESS | CLASSIFIED NETWORK
            </Box>
          </Box>

          <Box
            style={{
              display: 'flex',
              borderBottom: `1px solid ${C.borderRed}`,
              overflowX: 'auto',
              background: C.panel,
            }}
          >
            {TABS.map((t) => {
              const isActive = tab === t.key;
              return (
                <Box
                  key={t.key}
                  style={{
                    padding: '6px 12px',
                    cursor: 'pointer',
                    background: isActive
                      ? 'rgba(139,0,0,0.25)'
                      : 'transparent',
                    borderRight: `1px solid ${C.border}`,
                    borderBottom: isActive
                      ? `2px solid ${C.amber}`
                      : '2px solid transparent',
                    color: isActive ? C.textBright : C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    fontFamily: C.mono,
                    whiteSpace: 'nowrap',
                  }}
                  onClick={() => setTab(t.key)}
                >
                  {isActive && '▸ '}
                  {t.label}
                </Box>
              );
            })}
          </Box>

          <Box style={{ padding: '14px' }}>
            {tab === 'browse' && !current_page && (
              <Box>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  DOCUMENT INDEX
                </Box>
                {categories.map((cat) => (
                  <Box key={cat} style={{ marginBottom: '12px' }}>
                    <Box
                      style={{
                        fontSize: '11px',
                        color: C.amber,
                        fontWeight: 'bold',
                        letterSpacing: '0.12em',
                        marginBottom: '6px',
                      }}
                    >
                      {cat.toUpperCase()}
                    </Box>
                    {pages
                      .filter((p) => p.category === cat)
                      .map((page) => (
                        <Box
                          key={page.id}
                          style={{
                            padding: '6px 8px',
                            borderLeft: `2px solid ${C.border}`,
                            background: C.panel,
                            marginBottom: '4px',
                            cursor: 'pointer',
                          }}
                          onClick={() =>
                            act('open_page', { id: page.id })
                          }
                        >
                          <Box
                            style={{
                              color: C.textBright,
                              fontSize: '11px',
                            }}
                          >
                            {page.title}
                          </Box>
                        </Box>
                      ))}
                  </Box>
                ))}
                {pages.length === 0 && (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    }}
                  >
                    NO PAGES AVAILABLE
                  </Box>
                )}
              </Box>
            )}

            {tab === 'browse' && current_page && (
              <Box>
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: '10px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '13px',
                      color: C.amber,
                      fontWeight: 'bold',
                      letterSpacing: '0.12em',
                    }}
                  >
                    {current_page.title}
                  </Box>
                  <Box style={{ display: 'flex', gap: '4px' }}>
                    <Button
                      onClick={() => act('add_bookmark', { id: current_page.title })}
                      style={{
                        fontFamily: C.mono,
                        fontSize: '10px',
                        letterSpacing: '0.1em',
                        textTransform: 'uppercase',
                        background: 'rgba(26,122,26,0.2)',
                        border: `1px solid ${C.green}`,
                        borderRadius: 0,
                        color: C.greenBright,
                        padding: '3px 8px',
                      }}
                    >
                      BOOKMARK
                    </Button>
                    <Button
                      onClick={() => act('close_document')}
                      style={{
                        fontFamily: C.mono,
                        fontSize: '10px',
                        letterSpacing: '0.1em',
                        textTransform: 'uppercase',
                        background: 'rgba(139,0,0,0.2)',
                        border: `1px solid ${C.border}`,
                        borderRadius: 0,
                        color: C.textDim,
                        padding: '3px 8px',
                      }}
                    >
                      CLOSE
                    </Button>
                  </Box>
                </Box>
                <Box
                  style={{
                    padding: '10px',
                    borderLeft: `2px solid ${C.amber}`,
                    background: 'rgba(20,20,25,0.8)',
                    color: C.text,
                    fontSize: '12px',
                    lineHeight: '1.6',
                    whiteSpace: 'pre-wrap',
                  }}
                >
                  {current_page.content}
                </Box>
              </Box>
            )}

            {tab === 'search' && (
              <Box>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  SEARCH INTRANET
                </Box>
                <Box
                  style={{
                    display: 'flex',
                    gap: '6px',
                    marginBottom: '12px',
                  }}
                >
                  <Input
                    value={searchQuery}
                    onChange={(_e: any, val: string) => setSearchQuery(val)}
                    placeholder="Enter search query..."
                    style={{
                      fontFamily: C.mono,
                      fontSize: '11px',
                      flex: '1',
                    }}
                  />
                  <Button
                    onClick={() => act('search', { query: searchQuery })}
                    style={{
                      fontFamily: C.mono,
                      fontSize: '10px',
                      letterSpacing: '0.1em',
                      textTransform: 'uppercase',
                      background: 'rgba(26,122,26,0.25)',
                      border: `1px solid ${C.green}`,
                      borderRadius: 0,
                      color: C.greenBright,
                      padding: '3px 8px',
                    }}
                  >
                    SEARCH
                  </Button>
                </Box>
                {search_results.length > 0 ? (
                  search_results.map((result, idx) => (
                    <Box
                      key={idx}
                      style={{
                        padding: '6px 8px',
                        borderLeft: `2px solid ${C.amber}`,
                        background: C.panel,
                        marginBottom: '4px',
                        cursor: 'pointer',
                      }}
                      onClick={() =>
                        act('open_page', { id: result })
                      }
                    >
                      <Box
                        style={{
                          color: C.textBright,
                          fontSize: '11px',
                        }}
                      >
                        {result}
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    }}
                  >
                    NO RESULTS
                  </Box>
                )}
              </Box>
            )}

            {tab === 'bookmarks' && (
              <Box>
                <Box
                  style={{
                    fontSize: '10px',
                    color: C.textDim,
                    letterSpacing: '0.18em',
                    textTransform: 'uppercase',
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: '4px',
                    marginBottom: '10px',
                  }}
                >
                  BOOKMARKED PAGES
                </Box>
                {bookmarks.length > 0 ? (
                  bookmarks.map((bm, idx) => (
                    <Box
                      key={idx}
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        padding: '6px 8px',
                        borderLeft: `2px solid ${C.amber}`,
                        background: C.panel,
                        marginBottom: '4px',
                      }}
                    >
                      <Box
                        style={{
                          color: C.textBright,
                          fontSize: '11px',
                          cursor: 'pointer',
                        }}
                        onClick={() =>
                          act('open_page', { id: bm })
                        }
                      >
                        {bm}
                      </Box>
                      <Button
                        onClick={() =>
                          act('remove_bookmark', { id: bm })
                        }
                        style={{
                          fontFamily: C.mono,
                          fontSize: '10px',
                          letterSpacing: '0.1em',
                          textTransform: 'uppercase',
                          background: 'rgba(139,0,0,0.2)',
                          border: `1px solid ${C.border}`,
                          borderRadius: 0,
                          color: C.redBright,
                          padding: '2px 6px',
                        }}
                      >
                        REMOVE
                      </Button>
                    </Box>
                  ))
                ) : (
                  <Box
                    style={{
                      color: C.textDim,
                      fontStyle: 'italic',
                      fontSize: '11px',
                    }}
                  >
                    NO BOOKMARKS
                  </Box>
                )}
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
              SCP FOUNDATION | INTRANET | DOCUMENT COUNT: {pages.length} |
              CLASSIFIED ACCESS ONLY
            </Box>
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
