import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Input, Section, Tabs } from '../components';
import { Window } from '../layouts';

type DocSummary = {
  id: string;
  objectClass: string;
  status: string;
};

type DocDetail = {
  id: string;
  objectClass: string;
  containmentStatus: string;
  procedures: string;
  description: string;
  addenda: string[];
};

type DocumentReaderData = {
  clearance: number;
  currentTime: string;
  documents: DocSummary[];
  allDocuments: Record<string, DocDetail>;
};

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenBright: '#44ff44',
  text: '#b0b0b0',
  textBright: '#e0e0e8',
  textDim: '#555560',
  amber: '#d4a017',
  blue: '#4488cc',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const CLASS_COLORS: Record<string, string> = {
  Safe: C.greenBright,
  Euclid: C.amber,
  Keter: C.redBright,
  Thaumiel: C.blue,
  Neutralized: C.textDim,
  Unknown: C.textDim,
};

const STATUS_COLORS: Record<string, string> = {
  contained: C.greenBright,
  breached: C.redBright,
  unknown: C.amber,
};

const ClearanceBadge = (props: { level: number }) => {
  const colors = [C.textDim, C.green, C.amber, C.blue, C.redBright, '#fff'];
  const labels = ['', 'LEVEL 1', 'LEVEL 2', 'LEVEL 3', 'LEVEL 4', 'LEVEL 5'];
  return (
    <Box
      inline
      px={1}
      py={0.25}
      style={{
        background: C.bg,
        border: `1px solid ${colors[props.level] || C.textDim}`,
        color: colors[props.level] || C.textDim,
        fontFamily: C.mono,
        fontSize: '10px',
        letterSpacing: '1px',
      }}
    >
      {labels[props.level] || 'UNKNOWN'}
    </Box>
  );
};

const DocumentView = (props: { doc: DocDetail; onBack: () => void }) => {
  const { doc, onBack } = props;
  const classColor = CLASS_COLORS[doc.objectClass] || C.textDim;
  const statusColor = STATUS_COLORS[doc.containmentStatus] || C.textDim;

  return (
    <Box>
      <Button
        onClick={onBack}
        icon="arrow-left"
        style={{
          background: C.bg,
          border: `1px solid ${C.border}`,
          color: C.text,
          fontFamily: C.mono,
          fontSize: '10px',
          marginBottom: '4px',
        }}
        content="◄ BACK TO INDEX"
      />
      {/* Document Header */}
      <Box
        textAlign="center"
        py={1}
        px={1}
        mb={1}
        style={{
          borderBottom: `2px solid ${C.borderRed}`,
          borderTop: `2px solid ${C.borderRed}`,
        }}
      >
        <Box
          bold
          fontSize="18px"
          color={C.redBright}
          style={{ letterSpacing: '3px', fontFamily: C.mono }}
        >
          {doc.id}
        </Box>
        <Box mt={0.5}>
          <Box
            inline
            px={1}
            style={{
              color: classColor,
              fontFamily: C.mono,
              fontSize: '11px',
              letterSpacing: '1px',
            }}
          >
            OBJECT CLASS: {doc.objectClass.toUpperCase()}
          </Box>
          <Box
            inline
            ml={2}
            px={1}
            style={{
              color: statusColor,
              fontFamily: C.mono,
              fontSize: '11px',
              letterSpacing: '1px',
            }}
          >
            STATUS: {doc.containmentStatus.toUpperCase()}
          </Box>
        </Box>
      </Box>

      {/* Containment Procedures */}
      <Box
        px={1}
        py={0.5}
        mb={0.5}
        style={{ borderBottom: `1px solid ${C.border}` }}
      >
        <Box
          bold
          color={C.blue}
          style={{ fontSize: '11px', letterSpacing: '1px' }}
        >
          SPECIAL CONTAINMENT PROCEDURES
        </Box>
        <Box
          color={C.text}
          mt={0.5}
          style={{ fontSize: '11px', lineHeight: '1.5' }}
        >
          {doc.procedures}
        </Box>
      </Box>

      {/* Description */}
      <Box
        px={1}
        py={0.5}
        mb={0.5}
        style={{ borderBottom: `1px solid ${C.border}` }}
      >
        <Box
          bold
          color={C.blue}
          style={{ fontSize: '11px', letterSpacing: '1px' }}
        >
          DESCRIPTION
        </Box>
        <Box
          color={C.text}
          mt={0.5}
          style={{ fontSize: '11px', lineHeight: '1.5' }}
        >
          {doc.description}
        </Box>
      </Box>

      {/* Addenda */}
      {!!doc.addenda && doc.addenda.length > 0 && (
        <Box px={1} py={0.5}>
          <Box
            bold
            color={C.amber}
            style={{ fontSize: '11px', letterSpacing: '1px' }}
          >
            ADDENDA
          </Box>
          {doc.addenda.map((addendum, i) => (
            <Box
              key={i}
              px={1}
              py={0.5}
              mt={0.25}
              style={{
                background: C.bg,
                border: `1px solid ${C.border}`,
                fontSize: '10px',
                color: C.textDim,
                lineHeight: '1.4',
              }}
            >
              {addendum}
            </Box>
          ))}
        </Box>
      )}
    </Box>
  );
};

export const SCPDocumentReader = (props) => {
  const { act, data } = useBackend<DocumentReaderData>();
  const { clearance, currentTime, documents, allDocuments } = data;
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [searchText, setSearchText] = useState('');

  if (selectedId && allDocuments[selectedId]) {
    return (
      <Window theme="scp_terminal" width={600} height={700}>
        <Window.Content scrollable>
          <Box
            style={{
              background: C.bg,
              border: `1px solid ${C.borderRed}`,
              fontFamily: C.mono,
              padding: '8px',
            }}
          >
            <DocumentView
              doc={allDocuments[selectedId]}
              onBack={() => setSelectedId(null)}
            />
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const filteredDocs = searchText
    ? documents.filter((d) =>
        d.id.toLowerCase().includes(searchText.toLowerCase()),
      )
    : documents;

  return (
    <Window theme="scp_terminal" width={500} height={600}>
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            padding: '8px',
          }}
        >
          {/* Header */}
          <Box
            textAlign="center"
            py={1}
            style={{
              borderBottom: `1px solid ${C.borderRed}`,
              marginBottom: '8px',
            }}
          >
            <Box
              color={C.textDim}
              style={{ fontSize: '10px', letterSpacing: '3px' }}
            >
              SCP FOUNDATION — DOCUMENT TERMINAL
            </Box>
            <Box mt={0.5}>
              <ClearanceBadge level={clearance} />
            </Box>
          </Box>

          {/* Search + Sync */}
          <Box mb={1}>
            <Input
              fluid
              placeholder="Search SCP files..."
              value={searchText}
              onChange={(_, value) => setSearchText(value)}
              style={{
                background: C.bg,
                border: `1px solid ${C.border}`,
                color: C.text,
                fontFamily: C.mono,
                fontSize: '11px',
              }}
            />
            <Button
              mt={0.5}
              fluid
              icon="sync"
              onClick={() => act('sync')}
              style={{
                background: C.bg,
                border: `1px solid ${C.border}`,
                color: C.amber,
                fontFamily: C.mono,
                fontSize: '10px',
              }}
              content="SYNC DATABASE"
            />
          </Box>

          {/* Document List */}
          {filteredDocs.length === 0 && (
            <Box
              textAlign="center"
              py={2}
              color={C.textDim}
              style={{ fontSize: '11px' }}
            >
              No documents available for your clearance level.
              <br />
              Interact with SCPs or gain higher clearance to unlock
              documentation.
            </Box>
          )}
          {filteredDocs.map((doc) => {
            const classColor = CLASS_COLORS[doc.objectClass] || C.textDim;
            const statusColor = STATUS_COLORS[doc.status] || C.textDim;
            return (
              <Button
                key={doc.id}
                fluid
                onClick={() => setSelectedId(doc.id)}
                style={{
                  background: C.panel,
                  border: `1px solid ${C.border}`,
                  color: C.text,
                  fontFamily: C.mono,
                  fontSize: '11px',
                  marginBottom: '2px',
                  textAlign: 'left',
                }}
                content={
                  <Box>
                    <Box bold color={C.redBright} inline>
                      {doc.id}
                    </Box>
                    <Box inline ml={2} color={classColor} fontSize="10px">
                      [{doc.objectClass}]
                    </Box>
                    <Box inline ml={2} color={statusColor} fontSize="10px">
                      {doc.status}
                    </Box>
                  </Box>
                }
              />
            );
          })}
        </Box>
      </Window.Content>
    </Window>
  );
};
