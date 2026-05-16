import { useBackend, useSharedState } from '../../backend';
import { Box, Button, Dropdown, Input, Modal, NoticeBox, Stack, Section, Flex, LabeledList, ColorBox, Icon, Tooltip, Table, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from '../PreferencesMenu/CharacterPreview';

export const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  borderRed: '#6b0000',
  accent: '#c2960e',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#0a6e0a',
  greenDim: '#0d4a0d',
  brightGreen: '#44ff44',
  text: '#c8c8c8',
  textBright: '#e8e8e8',
  textDim: '#6a6a70',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

export const term = (overrides: Record<string, string> = {}) => ({
  fontFamily: C.mono,
  fontSize: '12px',
  color: C.text,
  ...overrides,
});

export const TermBox = (props: any) => (
  <Box style={term({ ...props.style })}>{props.children}</Box>
);

export const TermHeader = (props: any) => (
  <Box
    style={term({
      fontSize: '10px',
      color: C.textDim,
      letterSpacing: '0.18em',
      textTransform: 'uppercase',
      borderBottom: `1px solid ${C.border}`,
      paddingBottom: '4px',
      marginBottom: '8px',
      ...props.style,
    })}
  >
    {props.children}
  </Box>
);

export const TermLabel = (props: any) => (
  <Box
    as="span"
    style={term({
      color: C.textDim,
      fontSize: '10px',
      letterSpacing: '0.12em',
      textTransform: 'uppercase',
      marginRight: '8px',
    })}
  >
    {props.children}
  </Box>
);

export const TermValue = (props: any) => (
  <Box
    as="span"
    style={term({
      color: props.color || C.textBright,
      fontWeight: props.bold ? 'bold' : 'normal',
    })}
  >
    {props.children}
  </Box>
);

export const TermRow = (props: any) => (
  <Box style={{ marginBottom: '6px', display: 'flex', alignItems: 'center' }}>
    {props.children}
  </Box>
);

export const TermDivider = () => (
  <Box
    style={{
      color: C.borderRed,
      fontSize: '10px',
      letterSpacing: '0.3em',
      margin: '10px 0',
      userSelect: 'none',
      overflow: 'hidden',
      whiteSpace: 'nowrap',
    }}
  >
    {'─'.repeat(80)}
  </Box>
);

export const TermButton = (props: any) => {
  const selected = props.selected;
  const color = props.color;
  const bg = selected
    ? color === 'red'
      ? 'rgba(139,0,0,0.35)'
      : color === 'green'
        ? 'rgba(26,122,26,0.35)'
        : color === 'yellow'
          ? 'rgba(180,160,20,0.25)'
          : 'rgba(255,255,255,0.08)'
    : 'transparent';
  const borderColor = selected
    ? color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border
    : C.border;
  const { children, ...rest } = props;
  return (
    <Button
      {...rest}
      style={{
        fontFamily: C.mono,
        fontSize: '10px',
        letterSpacing: '0.1em',
        textTransform: 'uppercase',
        background: bg,
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color: selected ? C.textBright : C.textDim,
        padding: '3px 8px',
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    >
      {children}
    </Button>
  );
};

export const TermProgressBar = (props: any) => (
  <Box style={{ marginBottom: '6px' }}>
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        marginBottom: '2px',
      }}
    >
      <TermLabel>{props.label}</TermLabel>
      <TermValue color={props.color || C.amber}>
        {props.value}
        {props.suffix || ''}
      </TermValue>
    </Box>
    <Box
      style={{
        height: '6px',
        background: C.panel,
        border: `1px solid ${C.border}`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          height: '100%',
          width: `${Math.min(100, Math.max(0, (props.value / props.maxValue) * 100))}%`,
          background: props.color || C.amber,
          transition: 'width 0.3s',
        }}
      />
    </Box>
  </Box>
);

export const TermModal = (props: any) => (
  <Modal
    {...props}
    style={{
      background: C.bg,
      border: `1px solid ${C.borderRed}`,
      borderRadius: 0,
      fontFamily: C.mono,
      color: C.text,
      padding: '16px',
    }}
  >
    {props.children}
  </Modal>
);

export const PriorityButtons = ({ job, prefs, act }: any) => (
  <Box style={{ display: 'flex', gap: '2px' }}>
    <TermButton selected={!prefs} onClick={() => act('set_job_priority', { job, level: null })}>
      OFF
    </TermButton>
    <TermButton color="red" selected={prefs === 1} onClick={() => act('set_job_priority', { job, level: 1 })}>
      LOW
    </TermButton>
    <TermButton color="yellow" selected={prefs === 2} onClick={() => act('set_job_priority', { job, level: 2 })}>
      MED
    </TermButton>
    <TermButton color="green" selected={prefs === 3} onClick={() => act('set_job_priority', { job, level: 3 })}>
      HIGH
    </TermButton>
  </Box>
);
