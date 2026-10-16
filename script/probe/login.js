// Sign up and log in, printing what each browser does with the cookies.
const { base, password, browsers, signUp } = require('./common');

(async () => {
  for (const [name, type] of browsers) {
    const player = `Probe${Date.now()}`;
    const browser = await type.launch();
    const page = await browser.newPage();
    page.on('response', async r => {
      if (r.request().method() === 'POST') {
        const h = await r.headersArray();
        console.log(name, 'POST', r.status(), r.url().replace(base, ''), 'set-cookie names:',
          h.filter(x => x.name.toLowerCase() === 'set-cookie').map(x => x.value.split('=')[0]).join(', ') || 'none');
      }
    });
    await signUp(page, player);
    console.log(name, 'after sign up:', page.url().replace(base, ''), '| cookies:', (await page.context().cookies()).map(c => c.name).join(', '));
    await page.context().clearCookies();
    await page.goto(base + '/session/new');
    await page.fill('[name=username]', player);
    await page.fill('[name=password]', password);
    await page.click('form[action="/session"] [type=submit]');
    await page.waitForLoadState('networkidle');
    const text = await page.locator('body').innerText();
    console.log(name, 'after log in:', page.url().replace(base, ''), '| cookies:', (await page.context().cookies()).map(c => c.name).join(', '));
    console.log(name, 'logged in?', text.includes('Log out') ? 'YES' : 'NO (still a guest)');
    await browser.close();
  }
})().catch(e => { console.error(e); process.exit(1); });
