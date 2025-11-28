const { test, expect } = require('@playwright/test');

test('Login and create article', async ({ page }) => {
  await page.goto('http://localhost:1337/admin');
  await page.fill('input[name="email"]', 'admin@satc.edu.br');
  await page.fill('input[name="password"]', 'welcomeToStrapi123');
  await page.click('button[type="submit"]');
  
  await page.click('text="Content Manager"');
  await page.click('text="Article"');
  await page.click('text="Create new entry"');
  
  await page.fill('input[name="title"]', 'Test Article');
  await page.click('button[type="submit"]');
  
  await expect(page.locator('text="Test Article"')).toBeVisible();
});