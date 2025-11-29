import { test, expect } from '@playwright/test';

test('abre painel admin do Strapi', async ({ page }) => {
  await page.goto('http://localhost:1337/admin');
  await expect(page).toHaveURL(/admin/);
});
