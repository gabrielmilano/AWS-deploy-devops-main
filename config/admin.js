"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = ({ env }) => ({
    apiToken: {
        salt: env('API_TOKEN_SALT', 'someRandomLongString'),
    },
    auth: {
        secret: env('ADMIN_JWT_SECRET', 'someSecretKey'),
    },
});
