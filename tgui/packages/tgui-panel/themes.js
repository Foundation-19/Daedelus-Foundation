/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { THEME_DARK, THEME_LIGHT } from './settings/constants';

const COLOR_DARK_BG = '#0a0a0c';
const COLOR_DARK_BG_DARKER = '#08080a';
const COLOR_DARK_TEXT = '#c8c8c8';
const COLOR_AMBER = '#d4a017';
const COLOR_DARK_RED = '#5c0000';
const COLOR_RED = '#8b0000';
const COLOR_BORDER = '#2a2a30';

let setClientThemeTimer = null;

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export const setClientTheme = (name) => {
  // Transmit once for fast updates and again in a little while in case we won
  // the race against statbrowser init.
  clearInterval(setClientThemeTimer);
  Byond.command(`.output statbrowser:set_theme ${name}`);
  setClientThemeTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_theme ${name}`);
  }, 1500);

  if (name === THEME_LIGHT) {
    return Byond.winset({
      // Main windows
      'infowindow.background-color': 'none',
      'infowindow.text-color': '#000000',
      'info.background-color': 'none',
      'info.text-color': '#000000',
      'browseroutput.background-color': 'none',
      'browseroutput.text-color': '#000000',
      'outputwindow.background-color': 'none',
      'outputwindow.text-color': '#000000',
      'mainwindow.background-color': 'none',
      'split.background-color': 'none',
      // Buttons
      'changelog.background-color': 'none',
      'changelog.text-color': '#000000',
      'rules.background-color': 'none',
      'rules.text-color': '#000000',
      'wiki.background-color': 'none',
      'wiki.text-color': '#000000',
      'forum.background-color': 'none',
      'forum.text-color': '#000000',
      'github.background-color': 'none',
      'github.text-color': '#000000',
      'report-issue.background-color': 'none',
      'report-issue.text-color': '#000000',
      // Status and verb tabs
      'output.background-color': 'none',
      'output.text-color': '#000000',
      'statwindow.background-color': 'none',
      'statwindow.text-color': '#000000',
      'stat.background-color': '#FFFFFF',
      'stat.tab-background-color': 'none',
      'stat.text-color': '#000000',
      'stat.tab-text-color': '#000000',
      'stat.prefix-color': '#000000',
      'stat.suffix-color': '#000000',
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': 'none',
      'saybutton.text-color': '#000000',
      'oocbutton.background-color': 'none',
      'oocbutton.text-color': '#000000',
      'mebutton.background-color': 'none',
      'mebutton.text-color': '#000000',
      'asset_cache_browser.background-color': 'none',
      'asset_cache_browser.text-color': '#000000',
      'tooltip.background-color': 'none',
      'tooltip.text-color': '#000000',
    });
  }
  if (name === THEME_DARK) {
    Byond.winset({
      // Main windows
      'infowindow.background-color': COLOR_DARK_BG,
      'infowindow.text-color': COLOR_DARK_TEXT,
      'info.background-color': COLOR_DARK_BG,
      'info.text-color': COLOR_DARK_TEXT,
      'browseroutput.background-color': COLOR_DARK_BG,
      'browseroutput.text-color': COLOR_DARK_TEXT,
      'outputwindow.background-color': COLOR_DARK_BG,
      'outputwindow.text-color': COLOR_DARK_TEXT,
      'mainwindow.background-color': COLOR_DARK_BG,
      'split.background-color': COLOR_DARK_BG,
      // Buttons
      'changelog.background-color': COLOR_DARK_RED,
      'changelog.text-color': COLOR_AMBER,
      'rules.background-color': COLOR_DARK_RED,
      'rules.text-color': COLOR_AMBER,
      'wiki.background-color': COLOR_DARK_RED,
      'wiki.text-color': COLOR_AMBER,
      'forum.background-color': COLOR_DARK_RED,
      'forum.text-color': COLOR_AMBER,
      'github.background-color': COLOR_BORDER,
      'github.text-color': COLOR_DARK_TEXT,
      'report-issue.background-color': COLOR_RED,
      'report-issue.text-color': COLOR_AMBER,
      // Status and verb tabs
      'output.background-color': COLOR_DARK_BG_DARKER,
      'output.text-color': COLOR_DARK_TEXT,
      'statwindow.background-color': COLOR_DARK_BG_DARKER,
      'statwindow.text-color': COLOR_DARK_TEXT,
      'stat.background-color': COLOR_DARK_BG_DARKER,
      'stat.tab-background-color': COLOR_DARK_BG,
      'stat.text-color': COLOR_DARK_TEXT,
      'stat.tab-text-color': COLOR_DARK_TEXT,
      'stat.prefix-color': COLOR_DARK_TEXT,
      'stat.suffix-color': COLOR_DARK_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_DARK_BG,
      'saybutton.text-color': COLOR_AMBER,
      'oocbutton.background-color': COLOR_DARK_BG,
      'oocbutton.text-color': COLOR_AMBER,
      'mebutton.background-color': COLOR_DARK_BG,
      'mebutton.text-color': COLOR_AMBER,
      'asset_cache_browser.background-color': COLOR_DARK_BG,
      'asset_cache_browser.text-color': COLOR_DARK_TEXT,
      'tooltip.background-color': COLOR_DARK_BG,
      'tooltip.text-color': COLOR_DARK_TEXT,
    });
  }
};
