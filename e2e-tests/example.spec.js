"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const test_1 = require("@playwright/test");
(0, test_1.test)('abre painel admin do Strapi', async ({ page }) => {
    await page.goto('http://localhost:1337/admin');
    await (0, test_1.expect)(page).toHaveURL(/admin/);
});
