// Shared by the browser checks in this folder. They sign up a throwaway
// player, so they only ever run against a copy of the game started for the
// check (see .github/workflows/probe.yml), never the live game.
const { firefox, chromium } = require('playwright');

const base = process.env.PROBE_URL || 'http://127.0.0.1:3000';
const host = new URL(base).hostname;
if (!['127.0.0.1', 'localhost'].includes(host)) {
  console.error(`Refusing to run against ${base}: browser checks make players, so they only run against a local copy of the game.`);
  process.exit(1);
}

// A new random password each run; nothing reusable is ever written down.
const password = process.env.PROBE_PASSWORD;
if (!password || password.length < 20) {
  console.error('Set PROBE_PASSWORD to a long random password for this run.');
  process.exit(1);
}

const browsers = (process.env.PROBE_BROWSERS || 'firefox,chromium').split(',')
  .map(name => [name, { firefox, chromium }[name]]);

const here = (page) => page.url().replace(base, '') || '/';

async function signUp(page, player) {
  await page.goto(base + '/registration/new');
  await page.fill('#account_display_name', player);
  await page.fill('#account_email', player.toLowerCase() + '@example.com');
  await page.fill('#account_password', password);
  await page.fill('#account_password_confirmation', password);
  await page.click('form[action="/registration"] [type=submit]');
  await page.waitForLoadState('networkidle');
}

module.exports = { base, password, browsers, here, signUp };
