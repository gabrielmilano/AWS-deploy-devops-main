"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vite_1 = require("vite");
exports.default = (config) => {
    // Important: always return the modified config
    return (0, vite_1.mergeConfig)(config, {
        resolve: {
            alias: {
                '@': '/src',
            },
        },
    });
};
