import { sortBy } from 'common/collections';
import { isEscape, KEY } from 'common/keys';
import { Component } from 'react';

import { resolveAsset } from '../../assets';
import { useBackend, useLocalState, useSharedState } from '../../backend';
import { Box, Button, Dropdown, Input, NoticeBox, Section, Flex, LabeledList, ColorBox, Icon, KeyListener, Stack, Table, Tabs, Tooltip, TrackOutsideClicks } from '../../components';
import { fetchRetry } from '../../http';
import { Window } from '../../layouts';
import { CharacterPreview } from '../PreferencesMenu/CharacterPreview';
import { ServerPreferencesFetcher } from '../PreferencesMenu/ServerPreferencesFetcher';
import features from '../PreferencesMenu/preferences/features';
import { FeatureValueInput } from '../PreferencesMenu/preferences/features/base';
import { C, term, TermBox, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, PriorityButtons } from './shared';

const TABS = [
  { key: 'overview', label: 'OVERVIEW' },
  { key: 'faction', label: 'FACTION' },
  { key: 'jobs', label: 'ASSIGNMENT' },
  { key: 'custom', label: 'PERSONNEL' },
  { key: 'quirks', label: 'PSYCHE' },
  { key: 'languages', label: 'LANG' },
  { key: 'loadout', label: 'EQUIP' },
  { key: 'augments', label: 'AUGMENT' },
  { key: 'mods', label: 'MODS' },
  { key: 'antags', label: 'SCP' },
  { key: 'keys', label: 'KEYS' },
  { key: 'game', label: 'SETTINGS' },
  { key: 'finalize', label: 'COMMIT' },
];

const inputStyle = { fontFamily: C.mono, fontSize: '14px', height: '32px', minHeight: '32px', width: '100%' };
const wideInputStyle = { fontFamily: C.mono, fontSize: '14px', height: '32px', minHeight: '32px', flex: 1, minWidth: '180px' };

// ── OVERVIEW PAGE ──────────────────────────────────────────────
const OverviewPage = ({ data }: any) => (
  <TermBox>
    <TermHeader>PERSONNEL SUMMARY</TermHeader>
    <TermRow><TermLabel>DESIGNATION</TermLabel><TermValue bold color={C.amber}>{data.name_to_use || 'UNASSIGNED'}</TermValue></TermRow>
    <TermRow><TermLabel>FACTION</TermLabel><TermValue>{data.faction || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>CLASS</TermLabel><TermValue>{data.class || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>SPECIES</TermLabel><TermValue>{data.species_names?.[data.species_id] || data.species_id || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>GENDER</TermLabel><TermValue>{data.gender || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>AGE</TermLabel><TermValue>{data.age || '—'}</TermValue></TermRow>
    <TermDivider />
    <TermRow><TermLabel>STATUS</TermLabel><TermValue color={data.faction_class_locked ? C.green : C.amber}>{data.faction_class_locked ? 'LOCKED' : 'UNLOCKED'}</TermValue></TermRow>
    <TermRow><TermLabel>RESET TOKENS</TermLabel><TermValue>{data.faction_class_reset_tokens || 0}</TermValue></TermRow>
  </TermBox>
);

// ── FACTION/CLASS PAGE ─────────────────────────────────────────
const FactionClassPage = () => {
  const { act, data }: any = useBackend();
  const factionToClasses: Record<string, string[]> = data.faction_to_classes || {};
  const factionLore: Record<string, string> = data.faction_lore || {};
  const classLore: Record<string, string> = data.class_lore || {};
  const factions = Object.keys(factionToClasses);
  const selectedFaction = data.faction || '';
  const classes = selectedFaction ? factionToClasses[selectedFaction] || [] : [];
  const selectedClass = data.class || '';
  const locked = !!data.faction_class_locked;
  const tokens = data.faction_class_reset_tokens || 0;
  const canAdmin = !!data.can_admin_override;
  const [confirmReset, setConfirmReset] = useSharedState('CS.confirmReset', false);
  const [confirmAdmin, setConfirmAdmin] = useSharedState('CS.confirmAdmin', false);

  return (
    <TermBox>
      <TermHeader>FACTION ASSIGNMENT</TermHeader>
      <TermRow>
        <TermLabel>FACTION</TermLabel>
        {locked ? <TermValue color={C.amber} bold>{selectedFaction || '—'}</TermValue> : (
          <Dropdown width="100%" options={factions} selected={selectedFaction} displayText={selectedFaction || 'SELECT...'} onSelected={(v: string) => act('set_faction', { value: v })} />
        )}
      </TermRow>
      <TermRow>
        <TermLabel>CLASS</TermLabel>
        {locked ? <TermValue color={C.amber} bold>{selectedClass || '—'}</TermValue> : (
          <Dropdown width="100%" options={classes} selected={selectedClass} displayText={selectedClass || 'SELECT...'} onSelected={(v: string) => act('set_class', { value: v })} />
        )}
      </TermRow>
      <TermDivider />
      <TermHeader>INTELLIGENCE BRIEFING</TermHeader>
      <TermBox style={{ marginBottom: '8px' }}>
        <TermRow><TermLabel>FACTION</TermLabel><TermValue>{selectedFaction || '—'}</TermValue></TermRow>
        <Box style={term({ color: C.textDim, fontSize: '11px', paddingLeft: '16px', fontStyle: 'italic' })}>
          {(selectedFaction && factionLore[selectedFaction]) || 'No intelligence available.'}
        </Box>
      </TermBox>
      <TermBox>
        <TermRow><TermLabel>CLASS</TermLabel><TermValue>{selectedClass || '—'}</TermValue></TermRow>
        <Box style={term({ color: C.textDim, fontSize: '11px', paddingLeft: '16px', fontStyle: 'italic' })}>
          {(selectedClass && classLore[selectedClass]) || 'No intelligence available.'}
        </Box>
      </TermBox>
      <TermDivider />
      <TermHeader>COMMITMENT</TermHeader>
      {locked ? (
        <Box>
          <TermRow><TermValue color={C.green}>FACTION/CLASS COMMITTED AND LOCKED</TermValue></TermRow>
          {tokens > 0 ? (confirmReset ? (
            <Box><NoticeBox>CONSUME ONE RESET TOKEN TO UNLOCK?</NoticeBox>
              <Box style={{ display: 'flex', gap: '4px' }}>
                <TermButton color="red" onClick={() => { setConfirmReset(false); act('request_reset_faction_class'); }}>CONFIRM</TermButton>
                <TermButton onClick={() => setConfirmReset(false)}>CANCEL</TermButton>
              </Box>
            </Box>
          ) : <TermButton color="red" onClick={() => setConfirmReset(true)}>USE RESET TOKEN ({tokens} LEFT)</TermButton>
          ) : <Box style={term({ color: C.textDim, fontSize: '11px' })}>NO RESET TOKENS AVAILABLE</Box>}
          {canAdmin && <Box style={{ marginTop: '8px' }}>{confirmAdmin ? (
            <Box style={{ display: 'flex', gap: '4px' }}>
              <TermButton color="red" onClick={() => { setConfirmAdmin(false); act('admin_override_unlock'); }}>CONFIRM ADMIN UNLOCK</TermButton>
              <TermButton onClick={() => setConfirmAdmin(false)}>CANCEL</TermButton>
            </Box>
          ) : <TermButton color="red" onClick={() => setConfirmAdmin(true)}>ADMIN OVERRIDE</TermButton>}</Box>}
        </Box>
      ) : <TermButton color="green" onClick={() => act('commit_faction_class')}>COMMIT AND LOCK</TermButton>}
    </TermBox>
  );
};

// ── JOBS PAGE ──────────────────────────────────────────────────
const JobsPage = () => {
  const { act, data }: any = useBackend();
  const available: { description: string; title: string }[] = data.available_jobs || [];
  const jobPrefs: Record<string, number> = data.job_preferences || {};
  if (!data.faction || !data.class) return <TermBox><NoticeBox>SELECT FACTION AND CLASS TO VIEW ASSIGNMENTS</NoticeBox></TermBox>;
  if (!available.length) return <TermBox><NoticeBox>NO ASSIGNMENTS AVAILABLE</NoticeBox></TermBox>;
  return (
    <TermBox>
      <TermHeader>ASSIGNMENT PREFERENCES — {data.faction?.toUpperCase()} / {data.class?.toUpperCase()}</TermHeader>
      {available.map((j) => (
        <Box key={j.title} style={{ marginBottom: '8px', borderBottom: `1px solid ${C.border}`, paddingBottom: '8px' }}>
          <Box style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <Box><TermValue bold>{j.title}</TermValue><Box style={term({ color: C.textDim, fontSize: '10px', marginTop: '2px' })}>{j.description}</Box></Box>
            <PriorityButtons job={j.title} prefs={jobPrefs[j.title]} act={act} />
          </Box>
        </Box>
      ))}
    </TermBox>
  );
};

// ── CUSTOMIZATION (PERSONNEL) PAGE ─────────────────────────────
const CustomizationPage = () => {
  const { act, data }: any = useBackend();
  const charPrefs: any = data.character_preferences || {};
  const clothing: Record<string, any> = charPrefs.clothing || {};
  const features: Record<string, any> = charPrefs.features || {};
  const secondaryFeatures: Record<string, any> = charPrefs.secondary_features || {};
  const supplementalFeatures: Record<string, any> = charPrefs.supplemental_features || {};
  const names: Record<string, any> = charPrefs.names || {};
  const nonContextual: Record<string, any> = charPrefs.non_contextual || {};
  const randomization: Record<string, any> = charPrefs.randomization || {};
  const genderChoices: string[] = data.gender_choices || ['male', 'female', 'plural'];
  const [nameDraft, setNameDraft] = useSharedState('CS.nameDraft', data.real_name || '');
  const [ageDraft, setAgeDraft] = useSharedState('CS.ageDraft', String(data.age ?? ''));
  const [eyeDraft, setEyeDraft] = useSharedState('CS.eyeDraft', (data.eye_color || '').replace('#', ''));
  const [hairDraft, setHairDraft] = useSharedState('CS.hairDraft', (data.hair_color || '').replace('#', ''));

  const renderPrefRow = (key: string, val: any) => {
    if (val === null || val === undefined) return null;
    if (typeof val === 'object' && val?.choices) {
      return (
        <TermRow key={key}>
          <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
          <Dropdown width="200px" options={val.choices} selected={val.selected} displayText={val.selected || 'SELECT...'} onSelected={(v: string) => act('set_preference', { preference: key, value: v })} />
        </TermRow>
      );
    }
    if (typeof val === 'boolean') {
      return (
        <TermRow key={key}>
          <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
          <TermButton selected={!!val} color={val ? 'green' : undefined} onClick={() => act('set_preference', { preference: key, value: !val })}>{val ? 'ON' : 'OFF'}</TermButton>
        </TermRow>
      );
    }
    if (typeof val === 'string' && val.startsWith('#')) {
      return (
        <TermRow key={key}>
          <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
          <Box style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
            <Box style={{ width: '20px', height: '20px', background: val, border: `1px solid ${C.border}` }} />
            <TermButton onClick={() => act('set_color_preference', { preference: key })}>CHANGE</TermButton>
          </Box>
        </TermRow>
      );
    }
    return <TermRow key={key}><TermLabel>{key.replace(/_/g, ' ')}</TermLabel><TermValue>{String(val)}</TermValue></TermRow>;
  };

  return (
    <TermBox>
      <TermHeader>PERSONNEL IDENTIFICATION</TermHeader>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>DESIGNATION</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
          <Input fluid value={nameDraft} onChange={(_: any, v: string) => setNameDraft(v)} style={wideInputStyle} />
          <TermButton onClick={() => act('set_preference', { preference: 'real_name', value: nameDraft })}>SAVE</TermButton>
          <TermButton color="yellow" onClick={() => act('randomize_name', { preference: 'real_name' })}>RAND</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>AGE</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
          <Input fluid value={ageDraft} onChange={(_: any, v: string) => setAgeDraft(v.replace(/[^0-9]/g, ''))} style={wideInputStyle} />
          <TermButton onClick={() => act('set_preference', { preference: 'age', value: Number(ageDraft) })}>SAVE</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>GENDER</TermLabel>
        <Box style={{ marginTop: '4px' }}>
          <Dropdown width="100%" options={genderChoices} selected={data.gender || ''} displayText={data.gender || 'SELECT...'} onSelected={(v: string) => act('set_preference', { preference: 'gender', value: v })} />
        </Box>
      </Box>

      <TermDivider />
      <TermHeader>BIOMETRIC DATA</TermHeader>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>EYE COLOR</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', alignItems: 'center', marginTop: '4px' }}>
          <Input value={eyeDraft} onChange={(_: any, v: string) => setEyeDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))} style={wideInputStyle} />
          <Box style={{ width: '32px', height: '32px', background: eyeDraft ? `#${eyeDraft}` : 'transparent', border: `1px solid ${C.border}`, flexShrink: 0 }} />
          <TermButton onClick={() => act('set_preference', { preference: 'eye_color', value: `#${eyeDraft}` })}>SAVE</TermButton>
          <TermButton color="yellow" onClick={() => act('set_color_preference', { preference: 'eye_color' })}>PICK</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>HAIR COLOR</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', alignItems: 'center', marginTop: '4px' }}>
          <Input value={hairDraft} onChange={(_: any, v: string) => setHairDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))} style={wideInputStyle} />
          <Box style={{ width: '32px', height: '32px', background: hairDraft ? `#${hairDraft}` : 'transparent', border: `1px solid ${C.border}`, flexShrink: 0 }} />
          <TermButton onClick={() => act('set_preference', { preference: 'hair_color', value: `#${hairDraft}` })}>SAVE</TermButton>
          <TermButton color="yellow" onClick={() => act('set_color_preference', { preference: 'hair_color' })}>PICK</TermButton>
        </Box>
      </Box>

      <TermDivider />
      <TermHeader>CLOTHING & FEATURES</TermHeader>
      <Box style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '4px' }}>
        {Object.entries(clothing).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
      </Box>

      {Object.keys(secondaryFeatures).length > 0 && (
        <>
          <TermDivider />
          <TermHeader>SPECIES FEATURES</TermHeader>
          <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {Object.entries(secondaryFeatures).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
          </Box>
        </>
      )}

      {Object.keys(supplementalFeatures).length > 0 && (
        <>
          <TermDivider />
          <TermHeader>SUPPLEMENTAL</TermHeader>
          <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {Object.entries(supplementalFeatures).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
          </Box>
        </>
      )}

      {Object.keys(features).length > 0 && (
        <>
          <TermDivider />
          <TermHeader>BODY FEATURES</TermHeader>
          <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {Object.entries(features).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
          </Box>
        </>
      )}

      {Object.keys(names).filter((k) => k !== 'real_name').length > 0 && (
        <>
          <TermDivider />
          <TermHeader>ALTERNATE NAMES</TermHeader>
          {Object.entries(names).filter(([k]) => k !== 'real_name').map(([key, val]: [string, any]) => renderPrefRow(key, val))}
        </>
      )}

      <TermDivider />
      <Box style={{ display: 'flex', gap: '6px' }}>
        <TermButton color="yellow" onClick={() => act('randomize_character')}>RANDOMIZE ALL</TermButton>
      </Box>
    </TermBox>
  );
};

// ── QUIRKS PAGE ────────────────────────────────────────────────
const QuirksPage = () => {
  const { act, data }: any = useBackend();
  const userQuirks: string[] = data.quirks || [];
  const allQuirks: string[] = data.all_quirks || [];
  const quirkInfo: Record<string, { description: string }> = data.quirk_info || {};
  const list = allQuirks.length ? allQuirks : userQuirks;
  if (!list.length) return <TermBox><NoticeBox>NO PSYCHOLOGICAL DATA ON FILE</NoticeBox></TermBox>;

  return (
    <TermBox>
      <TermHeader>PSYCHOLOGICAL EVALUATION</TermHeader>
      <Box style={term({ color: C.textDim, fontSize: '11px', marginBottom: '10px' })}>
        ACTIVE: {userQuirks.length} trait{userQuirks.length !== 1 ? 's' : ''} selected
      </Box>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
        {list.map((q: string) => (
          <TermButton key={q} selected={userQuirks.includes(q)} color={userQuirks.includes(q) ? 'green' : undefined} onClick={() => act('quirk_toggle', { quirk: q })} tooltip={quirkInfo[q]?.description}>
            {q}
          </TermButton>
        ))}
      </Box>
    </TermBox>
  );
};

// ── LANGUAGES PAGE ─────────────────────────────────────────────
const LanguagesPage = () => {
  const { act, data }: any = useBackend();
  const langs: Record<string, number> = data.languages || {};
  const catalog: Record<string, string> = data.languages_catalog || {};
  const paths = Object.keys(catalog);
  if (!paths.length) return <TermBox><NoticeBox>NO LANGUAGE DATA</NoticeBox></TermBox>;
  return (
    <TermBox>
      <TermHeader>LANGUAGE PROFICIENCY</TermHeader>
      {paths.map((path) => {
        const flags = langs[path] || 0;
        const name = catalog[path] || path;
        return (
          <TermRow key={path}>
            <TermLabel style={{ flex: 1 }}>{name}</TermLabel>
            <TermButton selected={Boolean(flags & 1)} onClick={() => act('language_toggle_understand', { language: path })}>R</TermButton>
            <TermButton selected={Boolean(flags & 2)} onClick={() => act('language_toggle_speak', { language: path })}>W</TermButton>
          </TermRow>
        );
      })}
    </TermBox>
  );
};

// ── LOADOUT PAGE ───────────────────────────────────────────────
const LoadoutPage = () => {
  const { act, data }: any = useBackend();
  const loadout: { desc: string; name: string; path: string }[] = data.loadout_entries || [];
  return (
    <TermBox>
      <TermHeader>EQUIPMENT LOADOUT</TermHeader>
      {loadout.length > 0 ? loadout.map((entry) => (
        <Box key={entry.path} style={{ marginBottom: '6px', borderBottom: `1px solid ${C.border}`, paddingBottom: '6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box><TermValue bold>{entry.name}</TermValue><Box style={term({ color: C.textDim, fontSize: '10px' })}>{entry.desc}</Box></Box>
          <TermButton onClick={() => act('loadout_toggle', { item: entry.path, change_loadout: 1 })}>TOGGLE</TermButton>
        </Box>
      )) : <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO EQUIPMENT ASSIGNED</Box>}
      <TermButton onClick={() => act('open_loadout')}>OPEN EQUIPMENT INTERFACE</TermButton>
    </TermBox>
  );
};

// ── AUGMENTS PAGE ──────────────────────────────────────────────
const AugmentsPage = () => {
  const { act, data }: any = useBackend();
  const augs: Record<string, any> = data.augments || {};
  const entries = Object.entries(augs);
  return (
    <TermBox>
      <TermHeader>AUGMENTATIONS</TermHeader>
      {entries.length > 0 ? entries.map(([slot, path]: [string, any]) => (
        <TermRow key={slot} style={{ borderBottom: `1px solid ${C.border}`, paddingBottom: '6px' }}>
          <TermLabel>{slot}</TermLabel><TermValue style={{ flex: 1 }}>{String(path)}</TermValue>
          <TermButton onClick={() => act('augments_act', { switch_augment: slot })}>SWAP</TermButton>
          <TermButton color="red" onClick={() => act('augments_act', { remove_augment: slot })}>RM</TermButton>
        </TermRow>
      )) : <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO AUGMENTATIONS INSTALLED</Box>}
      <TermButton onClick={() => act('augments_act', { add_augment: 'General' })}>INSTALL AUGMENTATION</TermButton>
    </TermBox>
  );
};

// ── APPEARANCE MODS PAGE ───────────────────────────────────────
const AppearanceModsPage = () => {
  const { act, data }: any = useBackend();
  const mods: Record<string, any> = data.appearance_mods || {};
  const entries = Object.keys(mods);
  return (
    <TermBox>
      <TermHeader>APPEARANCE MODIFICATIONS</TermHeader>
      {entries.length > 0 ? entries.map((type: string) => (
        <TermRow key={type} style={{ borderBottom: `1px solid ${C.border}`, paddingBottom: '6px' }}>
          <TermValue style={{ flex: 1 }}>{type}</TermValue>
          <TermButton onClick={() => act('appearance_mods_act', { modify: 1, mod_name: type })}>EDIT</TermButton>
          <TermButton color="red" onClick={() => act('appearance_mods_act', { remove: 1, mod_name: type })}>RM</TermButton>
        </TermRow>
      )) : <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO MODIFICATIONS ON FILE</Box>}
      <TermButton onClick={() => act('appearance_mods_act', { add: 1 })}>ADD MODIFICATION</TermButton>
    </TermBox>
  );
};

// ── ANTAGONISTS PAGE ───────────────────────────────────────────
const AntagonistsPage = () => {
  const { act, data }: any = useBackend();
  const antags: Record<string, boolean> = data.antagonists || {};
  const entries = Object.entries(antags);
  if (!entries.length) return <TermBox><NoticeBox>NO CLASSIFIED ROLES</NoticeBox></TermBox>;
  return (
    <TermBox>
      <TermHeader>CLASSIFIED ROLE PREFERENCES</TermHeader>
      <Box style={{ display: 'flex', gap: '4px', marginBottom: '10px' }}>
        <TermButton onClick={() => act('antag_select_all')}>ALL</TermButton>
        <TermButton onClick={() => act('antag_select_all_available')}>AVAILABLE</TermButton>
        <TermButton color="red" onClick={() => act('antag_deselect_all')}>NONE</TermButton>
      </Box>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
        {entries.map(([role, enabled]: [string, boolean]) => (
          <TermButton key={role} selected={!!enabled} color={enabled ? 'red' : undefined} onClick={() => act('antag_toggle', { role })}>{role}</TermButton>
        ))}
      </Box>
    </TermBox>
  );
};

// ── GAME PREFERENCES PAGE ──────────────────────────────────────
const GamePage = () => {
  const { act, data }: any = useBackend();
  const charPrefs: any = data.character_preferences || {};
  const gamePrefs: Record<string, unknown> = charPrefs.game_preferences || {};
  const [activeCategory, setActiveCategory] = useSharedState('CS.gameCategory', '');

  const categories: Record<string, { featureId: string; feature: any; value: unknown }[]> = {};
  const featureIds = Object.keys(gamePrefs);

  for (const featureId of featureIds) {
    const value = gamePrefs[featureId];
    const feature = features[featureId];
    const category = feature?.category || 'GENERAL';
    if (!categories[category]) categories[category] = [];
    categories[category].push({ featureId, feature, value });
  }

  const sortedCategories = Object.keys(categories).sort();
  const currentCat = activeCategory || sortedCategories[0] || '';

  if (!featureIds.length) return <TermBox><NoticeBox>NO GAME PREFERENCES LOADED</NoticeBox></TermBox>;

  return (
    <TermBox>
      <TermHeader>SYSTEM CONFIGURATION</TermHeader>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '2px', marginBottom: '8px', borderBottom: `1px solid ${C.border}`, paddingBottom: '8px' }}>
        {sortedCategories.map((cat) => (
          <TermButton key={cat} selected={cat === currentCat} onClick={() => setActiveCategory(cat)}>
            {cat}
          </TermButton>
        ))}
      </Box>
      <ServerPreferencesFetcher render={(serverData: any) => {
        const items = categories[currentCat] || [];
        return items.map(({ featureId, feature, value }) => {
          const featureName = feature?.name || featureId.replace(/_/g, ' ');
          const hasDescription = !!feature?.description;
          const nameElement = hasDescription ? (
            <Tooltip content={feature.description} position="bottom-start">
              <Box as="span" style={{ borderBottom: `1px dotted ${C.amber}`, cursor: 'help' }}>{featureName}</Box>
            </Tooltip>
          ) : featureName;

          return (
            <Box key={featureId} style={{ marginBottom: '6px', display: 'flex', alignItems: 'center', gap: '8px', borderBottom: `1px solid ${C.border}`, paddingBottom: '6px' }}>
              <Box style={{ flex: '0 0 40%', fontFamily: C.mono, fontSize: '10px', color: C.text, letterSpacing: '0.05em' }}>
                {nameElement}
              </Box>
              <Box style={{ flex: 1 }}>
                {feature ? (
                  <FeatureValueInput feature={feature} featureId={featureId} value={value} act={act} />
                ) : (
                  <Box style={{ fontFamily: C.mono, fontSize: '10px', color: C.redBright }}>
                    [{String(value)}]
                  </Box>
                )}
              </Box>
            </Box>
          );
        });
      }} />
    </TermBox>
  );
};

// ── KEYBINDINGS PAGE ───────────────────────────────────────────

type Keybinding = {
  description?: string;
  name: string;
};

type Keybindings = Record<string, Record<string, Keybinding>>;

const KEY_CODE_TO_BYOND: Record<string, string> = {
  DEL: 'Delete',
  DOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  LEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  RIGHT: 'East',
  SPACEBAR: 'Space',
  UP: 'North',
};

const DOM_KEY_LOCATION_NUMPAD = 3;

function isStandardKey(event: KeyboardEvent): boolean {
  return (
    event.key !== KEY.Alt &&
    event.key !== KEY.Control &&
    event.key !== KEY.Shift &&
    !isEscape(event.key)
  );
}

const formatKeyboardEvent = (event: KeyboardEvent): string => {
  let text = '';
  if (event.altKey) text += 'Alt';
  if (event.ctrlKey) text += 'Ctrl';
  if (event.shiftKey) text += 'Shift';
  if (event.location === DOM_KEY_LOCATION_NUMPAD) text += 'Numpad';
  if (isStandardKey(event)) {
    const key = event.key.toUpperCase();
    text += KEY_CODE_TO_BYOND[key] || key;
  }
  return text;
};

const sortKeybindings = sortBy(([_, keybinding]: [string, Keybinding]) => keybinding.name);
const sortKeybindingsByCategory = sortBy(([category]: [string, Record<string, Keybinding>]) => category);

const moveToBottom = (entries: [string, unknown][], findCategory: string) => {
  const idx = entries.findIndex(([cat]) => cat === findCategory);
  if (idx >= 0) entries.push(entries.splice(idx, 1)[0]);
};

const KeybindingName = (props: { keybinding: Keybinding }) => {
  const { keybinding } = props;
  if (keybinding.description) {
    return (
      <Tooltip content={keybinding.description} position="bottom">
        <Box as="span" style={{ borderBottom: `1px dotted ${C.amber}`, cursor: 'help' }}>
          {keybinding.name}
        </Box>
      </Tooltip>
    );
  }
  return <span>{keybinding.name}</span>;
};

const KeybindingSlot = (props: {
  currentHotkey?: string;
  onClick?: () => void;
  typingHotkey?: string;
}) => {
  const { currentHotkey, onClick, typingHotkey } = props;
  const isCapturing = typingHotkey !== undefined;
  const child = (
    <TermButton
      fluid
      selected={isCapturing}
      color={isCapturing ? 'yellow' : undefined}
      onClick={(event: any) => {
        event.stopPropagation();
        onClick?.();
      }}
      style={{ textAlign: 'center', minWidth: '70px' }}
    >
      {typingHotkey || currentHotkey || '—'}
    </TermButton>
  );
  if (isCapturing && onClick) {
    return <TrackOutsideClicks onOutsideClick={onClick}>{child}</TrackOutsideClicks>;
  }
  return child;
};

type KeybindingsPageState = {
  keybindings?: Keybindings;
  lastKeyboardEvent?: KeyboardEvent;
  rebindingHotkey?: [string, number];
  selectedKeybindings?: Record<string, string[]>;
  activeCategory?: string;
};

class KeybindingsPageInner extends Component<{}, KeybindingsPageState> {
  cancelNextKeyUp?: number;
  keybindingOnClicks: Record<string, (() => void)[]> = {};
  lastKeybinds?: Record<string, string[]>;

  state: KeybindingsPageState = {
    lastKeyboardEvent: undefined,
    keybindings: undefined,
    selectedKeybindings: undefined,
    rebindingHotkey: undefined,
    activeCategory: undefined,
  };

  constructor(props: any) {
    super(props);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
  }

  componentDidMount() {
    this.populateSelectedKeybindings();
    this.populateKeybindings();
  }

  componentDidUpdate() {
    const { data }: any = useBackend();
    if (data.keybindings !== this.lastKeybinds) {
      this.populateSelectedKeybindings();
    }
  }

  setRebindingHotkey(value?: string) {
    const { act }: any = useBackend();
    this.setState((state) => {
      let sel = state.selectedKeybindings;
      if (!sel || !state.rebindingHotkey) return state;
      sel = { ...sel };
      const [keybindName, slot] = state.rebindingHotkey;
      if (sel[keybindName]) {
        if (value) {
          sel[keybindName] = [...sel[keybindName]];
          sel[keybindName][Math.min(sel[keybindName].length, slot)] = value;
        } else {
          sel[keybindName] = [...sel[keybindName]];
          sel[keybindName].splice(slot, 1);
        }
      } else if (!value) {
        return state;
      } else {
        sel[keybindName] = [value];
      }
      act('set_keybindings', {
        keybind_name: keybindName,
        hotkeys: sel[keybindName],
      });
      return { lastKeyboardEvent: undefined, rebindingHotkey: undefined, selectedKeybindings: sel };
    });
  }

  handleKeyDown(keyEvent: any) {
    const event: KeyboardEvent = keyEvent.event;
    if (!this.state.rebindingHotkey) return;
    event.preventDefault();
    this.cancelNextKeyUp = keyEvent.code;
    if (isStandardKey(event)) {
      this.setRebindingHotkey(formatKeyboardEvent(event));
    } else if (isEscape(event.key)) {
      this.setRebindingHotkey(undefined);
    } else {
      this.setState({ lastKeyboardEvent: event });
    }
  }

  handleKeyUp(keyEvent: any) {
    if (this.cancelNextKeyUp === keyEvent.code) {
      this.cancelNextKeyUp = undefined;
      keyEvent.event.preventDefault();
    }
    const { lastKeyboardEvent, rebindingHotkey } = this.state;
    if (rebindingHotkey && lastKeyboardEvent) {
      this.setRebindingHotkey(formatKeyboardEvent(lastKeyboardEvent));
    }
  }

  getKeybindingOnClick(keybindingId: string, slot: number): () => void {
    if (!this.keybindingOnClicks[keybindingId]) this.keybindingOnClicks[keybindingId] = [];
    if (!this.keybindingOnClicks[keybindingId][slot]) {
      this.keybindingOnClicks[keybindingId][slot] = () => {
        if (this.state.rebindingHotkey === undefined) {
          this.setState({ lastKeyboardEvent: undefined, rebindingHotkey: [keybindingId, slot] });
        } else {
          this.setState({ lastKeyboardEvent: undefined, rebindingHotkey: undefined });
        }
      };
    }
    return this.keybindingOnClicks[keybindingId][slot];
  }

  getTypingHotkey(keybindingId: string, slot: number): string | undefined {
    const { lastKeyboardEvent, rebindingHotkey } = this.state;
    if (!rebindingHotkey || rebindingHotkey[0] !== keybindingId || rebindingHotkey[1] !== slot) return undefined;
    if (lastKeyboardEvent === undefined) return '...';
    return formatKeyboardEvent(lastKeyboardEvent);
  }

  async populateKeybindings() {
    const resp = await fetchRetry(resolveAsset('keybindings.json'));
    const data: Keybindings = await resp.json();
    this.setState({ keybindings: data, activeCategory: Object.keys(data).sort()[0] });
  }

  populateSelectedKeybindings() {
    const { data }: any = useBackend();
    this.lastKeybinds = data.keybindings;
    this.setState({
      selectedKeybindings: Object.fromEntries(
        Object.entries(data.keybindings as Record<string, string[]>).map(([kb, hotkeys]) => [
          kb,
          hotkeys.filter((v) => v !== 'Unbound'),
        ]),
      ),
    });
  }

  render() {
    const { act }: any = useBackend();
    const keybindings = this.state.keybindings;
    if (!keybindings) {
      return <TermBox><Box style={term({ color: C.textDim, fontStyle: 'italic' })}>LOADING KEYBINDING DATA...</Box></TermBox>;
    }

    const entries = sortKeybindingsByCategory(Object.entries(keybindings));
    moveToBottom(entries, 'EMOTE');
    moveToBottom(entries, 'ADMIN');

    const categories = entries.map(([cat]) => cat);
    const activeCat = this.state.activeCategory || categories[0];
    const catData = entries.find(([c]) => c === activeCat);

    return (
      <TermBox>
        <KeyListener onKeyDown={this.handleKeyDown} onKeyUp={this.handleKeyUp} />
        <TermHeader>KEYBINDING CONFIGURATION</TermHeader>
        <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '2px', marginBottom: '8px', borderBottom: `1px solid ${C.border}`, paddingBottom: '8px' }}>
          {categories.map((cat) => (
            <TermButton key={cat} selected={cat === activeCat} onClick={() => this.setState({ activeCategory: cat })}>
              {cat}
            </TermButton>
          ))}
        </Box>
        {catData && sortKeybindings(Object.entries(catData[1])).map(([keybindingId, keybinding]) => {
          const keys = this.state.selectedKeybindings?.[keybindingId] || [];
          return (
            <Box key={keybindingId} style={{ marginBottom: '4px', display: 'flex', alignItems: 'center', gap: '4px', borderBottom: `1px solid ${C.border}`, paddingBottom: '4px' }}>
              <Box style={{ flex: '0 0 30%', fontFamily: C.mono, fontSize: '10px', color: C.text, letterSpacing: '0.05em' }}>
                <KeybindingName keybinding={keybinding} />
              </Box>
              {[0, 1, 2].map((slot) => (
                <Box key={slot} style={{ flex: '0 0 18%' }}>
                  <KeybindingSlot
                    currentHotkey={keys[slot]}
                    typingHotkey={this.getTypingHotkey(keybindingId, slot)}
                    onClick={this.getKeybindingOnClick(keybindingId, slot)}
                  />
                </Box>
              ))}
              <Box style={{ flex: '0 0 12%' }}>
                <TermButton color="red" fluid onClick={() => act('reset_keybinds_to_defaults', { keybind_name: keybindingId })} style={{ textAlign: 'center' }}>RST</TermButton>
              </Box>
            </Box>
          );
        })}
        <TermDivider />
        <TermButton color="red" onClick={() => act('reset_all_keybinds')}>RESET ALL KEYBINDINGS</TermButton>
      </TermBox>
    );
  }
}

const KeybindingsPage = () => <KeybindingsPageInner />;

// ── FINALIZE PAGE ──────────────────────────────────────────────
const FinalizePage = ({ data, act }: any) => (
  <TermBox>
    <TermHeader>COMMIT PERSONNEL RECORD</TermHeader>
    <Box style={term({ color: C.amber, fontSize: '11px', marginBottom: '12px', borderLeft: `2px solid ${C.amber}`, paddingLeft: '8px' })}>
      WARNING: This action will persist all configuration data to the Foundation database and synchronize your personnel record. This cannot be undone.
    </Box>
    <OverviewPage data={data} />
    <TermDivider />
    <TermButton color="green" onClick={() => act('finalize')}>COMMIT TO DATABASE</TermButton>
  </TermBox>
);

// ── CHARACTER SLOT SELECTOR ────────────────────────────────────
const CharacterSlots = (props: { profiles: (string | null)[]; activeSlot: number }) => {
  const { act } = useBackend<any>();
  const { profiles, activeSlot } = props;
  return (
    <Flex justify="center" style={{ marginBottom: '4px' }}>
      <Flex.Item width="30%">
        <Dropdown width="100%" displayText={profiles[activeSlot] || `SLOT ${activeSlot + 1}`} options={profiles.map((p, i) => ({ value: i, displayText: p || `SLOT ${i + 1}` }))} onSelected={(slot: number) => act('change_slot', { slot: slot + 1 })} />
      </Flex.Item>
    </Flex>
  );
};

// ── MAIN EXPORT ────────────────────────────────────────────────
export const CharacterSetup = () => {
  const { act, data }: any = useBackend();
  const { character_preview_view, character_profiles, active_slot, content_unlocked } = data;
  const [active, setActive] = useSharedState('CS.activeTab', 'overview');

  const profiles = character_profiles || [];

  return (
    <Window title="SCP PERSONNEL CONFIGURATION TERMINAL v5.0" width={1300} height={850} theme="scp_terminal">
      <Window.Content scrollable>
        <Box style={{ background: C.bg, border: `1px solid ${C.borderRed}`, padding: 0, fontFamily: C.mono, fontSize: '12px', color: C.text, minHeight: '100%' }}>
          {/* HEADER */}
          <Box style={{ borderBottom: `2px solid ${C.borderRed}`, padding: '10px 14px 8px', background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)' }}>
            <Box style={{ fontSize: '15px', fontWeight: 'bold', color: C.amber, letterSpacing: '0.18em' }}>SCP FOUNDATION — PERSONNEL CONFIGURATION</Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>TERMINAL v5.0 | CLEARANCE LEVEL 2 | CLASSIFIED | ENCRYPTION: AES-512</Box>
          </Box>

          {/* SLOT SELECTOR */}
          <Box style={{ padding: '6px 14px', borderBottom: `1px solid ${C.border}`, background: C.panel }}>
            <CharacterSlots profiles={profiles} activeSlot={(active_slot || 1) - 1} />
            {!content_unlocked && <Box style={term({ color: C.textDim, fontSize: '9px', textAlign: 'center' })}>[ CLEARANCE UPGRADE REQUIRED FOR ADDITIONAL PERSONNEL SLOTS ]</Box>}
          </Box>

          {/* TAB BAR */}
          <Box style={{ display: 'flex', borderBottom: `1px solid ${C.borderRed}`, overflowX: 'auto', background: C.panel }}>
            {TABS.map((t) => {
              const isActive = active === t.key;
              return (
                <Box key={t.key} style={{ padding: '6px 10px', cursor: 'pointer', background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent', borderRight: `1px solid ${C.border}`, borderBottom: isActive ? `2px solid ${C.amber}` : `2px solid transparent`, color: isActive ? C.textBright : C.textDim, fontSize: '9px', letterSpacing: '0.12em', textTransform: 'uppercase', fontFamily: C.mono, whiteSpace: 'nowrap', transition: 'background 0.1s' }} onClick={() => setActive(t.key)}>
                  {isActive && '▸ '}{t.label}
                </Box>
              );
            })}
          </Box>

          {/* MAIN CONTENT AREA */}
          <Box style={{ display: 'flex' }}>
            <Box style={{ flex: 1, padding: '16px', minHeight: '480px' }}>
              {active === 'overview' && <OverviewPage data={data} />}
              {active === 'faction' && <FactionClassPage />}
              {active === 'jobs' && <JobsPage />}
              {active === 'custom' && <CustomizationPage />}
              {active === 'quirks' && <QuirksPage />}
              {active === 'languages' && <LanguagesPage />}
              {active === 'loadout' && <LoadoutPage />}
              {active === 'augments' && <AugmentsPage />}
              {active === 'mods' && <AppearanceModsPage />}
              {active === 'antags' && <AntagonistsPage />}
              {active === 'keys' && <KeybindingsPage />}
              {active === 'game' && <GamePage />}
              {active === 'finalize' && <FinalizePage data={data} act={act} />}
            </Box>

            {/* RIGHT: Preview + Status */}
            <Box style={{ width: '300px', borderLeft: `1px solid ${C.border}`, background: C.panel, padding: '10px', flexShrink: 0 }}>
              <TermHeader>VISUAL RECORD</TermHeader>
              <Box style={{ height: '260px', marginBottom: '10px' }}>
                {character_preview_view ? <CharacterPreview height="100%" id={character_preview_view} /> : <Box style={term({ color: C.textDim, textAlign: 'center', paddingTop: '100px' })}>NO SIGNAL</Box>}
              </Box>
              <TermButton fluid onClick={() => act('rotate')}>ROTATE</TermButton>
              <TermDivider />
              <TermHeader>PREVIEW MODE</TermHeader>
              <Box style={{ display: 'flex', gap: '2px', marginBottom: '8px' }}>
                {(data.preview_options || []).map((opt: string) => (
                  <TermButton key={opt} selected={data.preview_selection === opt} color={data.preview_selection === opt ? 'green' : undefined} onClick={() => act('set_preview_pref', { value: opt })}>{opt.toUpperCase()}</TermButton>
                ))}
              </Box>
              <TermDivider />
              <TermHeader>SYSTEM</TermHeader>
              <Box style={term({ color: C.textDim, fontSize: '9px', lineHeight: '1.6' })}>
                <Box>LINK: NOMINAL</Box>
                <Box>NET: SECURE</Box>
                <Box>CRYPTO: AES-512</Box>
                <Box>STATUS: <Box as="span" style={{ color: C.green }}>ONLINE</Box></Box>
              </Box>
            </Box>
          </Box>

          {/* FOOTER */}
          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={term({ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' })}>SCP FOUNDATION | SECURE CONTAIN PROTECT | ALL ACTIVITY LOGGED | UNAUTHORIZED ACCESS IS A CLASS-B INFRACTION</Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
