import { test, expect } from '@playwright/test';

const ADMIN_EMAIL = 'admin@satc.edu.br';
const ADMIN_PASS = 'welcomeToStrapi123';

test('cria categoria pelo painel do Strapi', async ({ page }) => {
  // Abre o painel admin
  await page.goto('http://127.0.0.1:1337/admin', { waitUntil: 'networkidle' });

  // Login como Super Admin
  await page.fill('input[name="email"]', ADMIN_EMAIL);
  await page.fill('input[name="password"]', ADMIN_PASS);
  await page.click('button[type="submit"]');

  // Vai para a collection Categoria (ajuste o texto se estiver em inglês)
  await page.click('text=Categoria');

  // Cria nova categoria
  await page.click('text=Create new entry');
  await page.fill('input[name="name"]', 'Categoria Playwright');
  await page.click('text=Save');

  // Verifica se a categoria criada aparece na lista
  await expect(page.getByText('Categoria Playwright')).toBeVisible();
});
