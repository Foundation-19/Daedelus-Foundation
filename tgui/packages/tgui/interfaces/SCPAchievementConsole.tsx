import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown } from '../components';
import { NtosWindow } from '../layouts';
import { C, term, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, TermProgressBar } from './CharacterSetup/shared';

interface Achievement {
  id: string;
  name: string;
  description: string;
  unlocked: BooleanLike;
  progress: number;
  max_progress: number;
  icon: string;
}

interface Data {
  achievements: Achievement[];
  total_unlocked: number;
  total_achievements: number;
  achievement_points: number;
}

export const SCPAchievementConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const [filterCategory, setFilterCategory] = useLocalState('achieveFilter', 'all');

  const {
    achievements = [],
    total_unlocked,
    total_achievements,
    achievement_points,
  } = data;

  const completionPercent = total_achievements > 0
    ? Math.round((total_unlocked / total_achievements) * 100)
    : 0;

  return (
    <NtosWindow width={800} height={600} >
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
              SCP FOUNDATION — ACHIEVEMENTS
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              PERSONNEL PERFORMANCE TRACKING | ACHIEVEMENT REWARDS SYSTEM
            </Box>
          </Box>

          <Box style={{ padding: '16px' }}>
            <TermHeader>ACHIEVEMENT OVERVIEW</TermHeader>
            <TermProgressBar
              label="COMPLETION"
              value={completionPercent}
              maxValue={100}
              color={completionPercent > 75 ? C.green : C.amber}
              suffix="%"
            />
            <TermRow>
              <TermLabel>UNLOCKED</TermLabel>
              <TermValue color={C.green}>{total_unlocked}</TermValue>
              <TermValue color={C.textDim}>/{total_achievements}</TermValue>
              <TermLabel style={{ marginLeft: '16px' }}>POINTS</TermLabel>
              <TermValue color={C.amber}>{achievement_points}</TermValue>
            </TermRow>

            <TermDivider />

            <TermHeader>FILTER</TermHeader>
            <TermRow>
              <Dropdown
                selected={filterCategory}
                options={['all', 'containment', 'research', 'security', 'exploration', 'special']}
                onSelected={(value) => {
                  setFilterCategory(value);
                  act('filter', { category: value });
                }}
              />
            </TermRow>

            <TermDivider />

            <TermHeader>ACHIEVEMENTS</TermHeader>
            {achievements.length > 0 ? (
              achievements.map((ach) => (
                <Box
                  key={ach.id}
                  style={{
                    marginBottom: '4px',
                    padding: '8px',
                    borderLeft: `2px solid ${ach.unlocked ? C.green : C.border}`,
                    background: C.panel,
                    opacity: ach.unlocked ? 1 : 0.7,
                  }}
                >
                  <TermRow>
                    <TermValue bold color={ach.unlocked ? C.amber : C.textDim}>
                      [{ach.icon}] {ach.name}
                    </TermValue>
                    <TermLabel style={{ marginLeft: '8px' }}>STATUS</TermLabel>
                    <TermValue color={ach.unlocked ? C.green : C.textDim}>
                      {ach.unlocked ? 'UNLOCKED' : 'LOCKED'}
                    </TermValue>
                  </TermRow>
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '11px',
                      fontStyle: 'italic',
                      marginTop: '2px',
                    })}
                  >
                    {ach.description}
                  </Box>
                  {!ach.unlocked && (
                    <TermProgressBar
                      label="PROGRESS"
                      value={ach.progress}
                      maxValue={ach.max_progress}
                      color={C.amber}
                    />
                  )}
                  {ach.unlocked && (
                    <Box style={{ marginTop: '4px' }}>
                      <TermButton
                        color="green"
                        onClick={() => act('claim_reward', { id: ach.id })}
                      >
                        CLAIM REWARD
                      </TermButton>
                    </Box>
                  )}
                </Box>
              ))
            ) : (
              <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                NO ACHIEVEMENTS AVAILABLE
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
              style={term({
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              })}
            >
              SCP FOUNDATION | ACHIEVEMENTS | PERSONNEL PERFORMANCE METRICS
            </Box>
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
