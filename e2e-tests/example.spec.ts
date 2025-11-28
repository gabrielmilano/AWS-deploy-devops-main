import { test, expect } from '@playwright/test';

test('has title and welcome message', async ({ page }) => {

  await page.goto(process.env.BASE_URL || 'http://localhost:80');

  await expect(page).toHaveTitle(/Minha Aplicação DevOps/);

  await expect(page.locator('h1')).toHaveText('Deploy de HTML Estático com Sucesso!');

  await expect(page.locator('p').first()).toHaveText('Esta é a minha aplicação de teste com deploy na AWS');

  // A linha que continha o nome foi removida do index.html, ajustando o teste.
});