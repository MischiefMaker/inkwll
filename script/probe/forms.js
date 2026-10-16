// Forms that redirect (Enter and Post thread), in Firefox and Chromium.
const { base, browsers, here, signUp } = require('./common');

(async () => {
  for (const [name, type] of browsers) {
    const player = `Probe${Date.now()}`;
    const browser = await type.launch();
    const page = await browser.newPage();
    page.on('console', m => { if (['error', 'warning'].includes(m.type())) console.log(name, 'console', m.type(), m.text().slice(0, 200)); });
    page.on('pageerror', e => console.log(name, 'page error:', String(e).slice(0, 200)));
    page.on('response', r => { if (r.request().method() === 'POST') console.log(name, 'POST', r.status(), r.url().replace(base, ''), r.headers()['location'] ? '-> ' + r.headers()['location'].replace(base, '') : ''); });
    await signUp(page, player);
    await page.fill('#character_name', `Tester ${player.slice(-4)}`);
    await page.locator('#character_name').locator('xpath=ancestor::form').locator('[type=submit]').click();
    await page.waitForURL(/\/characters\/\d+/);
    await page.waitForLoadState('networkidle');
    console.log(name, 'character made, now at', here(page));
    await page.goto(base + '/');
    const enter = page.locator('.place__enter-form button').first();
    console.log(name, 'Enter buttons on the front page:', await page.locator('.place__enter-form button').count());
    const before = here(page);
    await enter.click();
    await page.waitForTimeout(4000);
    console.log(name, 'Enter: before', before, '-> after 4s', here(page), '| title:', await page.title());
    await page.goto(base + '/boards');
    await page.locator('a', { hasText: 'Advertising' }).first().click();
    await page.waitForLoadState('networkidle');
    await page.locator('a', { hasText: /^Start a/ }).first().click();
    await page.waitForLoadState('networkidle');
    await page.fill('#forum_topic_title', 'Probe thread');
    await page.fill('#forum_topic_body', 'Testing the Post thread button.');
    const formUrl = here(page);
    await page.locator('form.forum-topic-form [type=submit]').click();
    await page.waitForTimeout(4000);
    console.log(name, 'Post thread: before', formUrl, '-> after 4s', here(page), '| title:', await page.title());
    await browser.close();
  }
})().catch(e => { console.error(e); process.exit(1); });
