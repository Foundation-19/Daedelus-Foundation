import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Input, Section, Tabs } from '../components';
import { Window } from '../layouts';

type CodeInfo = {
  level: number;
  name: string;
  color: string;
  description: string;
};

type SecurityData = {
  currentLevel: number;
  currentCodeName: string;
  currentCodeColor: string;
  description: string;
  procedures: string[];
  availableCodes: CodeInfo[];
  hasAccess: BooleanLike;
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
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const LevelBadge = (props: { level: number; name: string; color: string }) => {
  const { level, name, color } = props;
  const bg =
    level === 0
      ? C.green
      : level === 1
        ? C.amber
        : level === 2
          ? C.red
          : '#3a0000';
  return (
    <Box
      inline
      px={2}
      py={0.5}
      style={{
        background: bg,
        border: `1px solid ${color}`,
        borderRadius: '2px',
        color: level === 0 ? '#000' : '#fff',
        fontFamily: C.mono,
        fontSize: '16px',
        fontWeight: 'bold',
        letterSpacing: '2px',
      }}
    >
      {name.toUpperCase()}
    </Box>
  );
};

const ProcedureList = (props: { procedures: string[]; critical?: boolean }) => {
  const { procedures, critical } = props;
  return (
    <Box mt={1}>
      {procedures.map((proc, i) => (
        <Box
          key={i}
          py={0.3}
          px={1}
          style={{
            borderBottom: `1px solid ${C.border}`,
            color: critical && i === 0 ? C.redBright : C.text,
            fontFamily: C.mono,
            fontSize: '11px',
            fontWeight: critical && i === 0 ? 'bold' : 'normal',
          }}
        >
          {critical && i === 0 ? '⚠ ' : '► '}
          {proc}
        </Box>
      ))}
    </Box>
  );
};

export const FoundationSecurityConsole = (props) => {
  const { act, data } = useBackend<SecurityData>();
  const {
    currentLevel,
    currentCodeName,
    currentCodeColor,
    description,
    procedures,
    availableCodes,
    hasAccess,
  } = data;
  const [reason, setReason] = useState('');
  const [selectedLevel, setSelectedLevel] = useState<number | null>(null);

  const isCritical = currentLevel >= 2;

  return (
    <Window theme="scp_terminal" width={700} height={600}>
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
              style={{
                color: C.textDim,
                fontSize: '10px',
                letterSpacing: '3px',
              }}
            >
              SCP FOUNDATION — SECURITY CODE MANAGEMENT
            </Box>
            <Box mt={1}>
              <LevelBadge
                level={currentLevel}
                name={currentCodeName}
                color={currentCodeColor}
              />
            </Box>
          </Box>

          {/* Current Status */}
          <Box
            px={2}
            py={1}
            mb={1}
            style={{
              background: C.panel,
              border: `1px solid ${C.border}`,
            }}
          >
            <Box
              color={C.amber}
              bold
              fontSize="12px"
              style={{ letterSpacing: '1px' }}
            >
              CURRENT STATUS
            </Box>
            <Box color={C.text} mt={0.5} style={{ fontSize: '11px' }}>
              {description}
            </Box>
            <Box color={C.amber} bold mt={1} fontSize="12px">
              ACTIVE PROCEDURES
            </Box>
            <ProcedureList procedures={procedures} critical={isCritical} />
          </Box>

          {/* Code Selection */}
          <Box
            px={2}
            py={1}
            mb={1}
            style={{
              background: C.panel,
              border: `1px solid ${C.border}`,
            }}
          >
            <Box
              color={C.amber}
              bold
              fontSize="12px"
              style={{ letterSpacing: '1px' }}
            >
              CHANGE SECURITY CODE
            </Box>
            {!hasAccess && (
              <Box color={C.redBright} mt={1} fontSize="11px">
                ACCESS DENIED — Command authorization required
              </Box>
            )}
            {!!hasAccess && (
              <>
                <Box mt={1}>
                  {availableCodes.map((code) => (
                    <Button
                      key={code.level}
                      fluid
                      disabled={code.level === currentLevel}
                      onClick={() => setSelectedLevel(code.level)}
                      style={{
                        background:
                          selectedLevel === code.level
                            ? code.color
                            : C.bg,
                        borderColor: code.color,
                        color:
                          code.level === 0
                            ? '#000'
                            : '#ccc',
                        fontFamily: C.mono,
                        fontSize: '11px',
                        marginBottom: '2px',
                        textAlign: 'left',
                      }}
                      content={
                        <Box>
                          <Box bold inline>
                            {code.name}
                          </Box>
                          <Box
                            inline
                            ml={2}
                            color={C.textDim}
                            style={{ fontSize: '10px' }}
                          >
                            — {code.description.substring(0, 60)}
                            {code.description.length > 60 ? '...' : ''}
                          </Box>
                        </Box>
                      }
                    />
                  ))}
                </Box>
                {selectedLevel !== null &&
                  selectedLevel !== currentLevel && (
                    <Box mt={1}>
                      <Input
                        fluid
                        placeholder="Enter reason for code change..."
                        value={reason}
                        onChange={(_, value) => setReason(value)}
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
                        onClick={() =>
                          act('setCode', {
                            level: selectedLevel,
                            reason: reason,
                          })
                        }
                        style={{
                          background: C.red,
                          border: '1px solid #cc0000',
                          color: '#fff',
                          fontFamily: C.mono,
                          fontSize: '12px',
                          fontWeight: 'bold',
                          letterSpacing: '1px',
                        }}
                        content={`CONFIRM: ${foundation_code_name(selectedLevel)}`}
                      />
                    </Box>
                  )}
              </>
            )}
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

const foundation_code_name = (level: number): string => {
  switch (level) {
    case 0:
      return 'CODE WHITE';
    case 1:
      return 'CODE YELLOW';
    case 2:
      return 'CODE RED';
    case 3:
      return 'CODE OMEGA';
    default:
      return 'UNKNOWN';
  }
};
