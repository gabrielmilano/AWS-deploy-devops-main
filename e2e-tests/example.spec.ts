import { test, expect } from '@playwright/test';

test('abre painel admin do Strapi', async ({ page }) => {
  await page.goto('http://127.0.0.1:1337/admin', { waitUntil: 'networkidle' });
  await expect(page).toHaveURL(/admin/);
});
