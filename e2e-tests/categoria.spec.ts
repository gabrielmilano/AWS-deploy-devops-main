import { test, expect } from '@playwright/test';

const ADMIN_EMAIL = 'admin@satc.edu.br';
const ADMIN_PASS = 'welcomeToStrapi123';

test('cria categoria pelo painel', async ({ page }) => {
  await page.goto('http://127.0.0.1:1337/admin');

  await page.fill('input[name="email"]', ADMIN_EMAIL);
  await page.fill('input[name="password"]', ADMIN_PASS);
  await page.click('button[type="submit"]');

  await page.click('text=Categoria');

  await page.click('text=Create new entry');
  await page.fill('input[name="name"]', 'Categoria Playwright');
  await page.click('text=Save');

  await expect(page.getByText('Categoria Playwright')).toBeVisible();
});
