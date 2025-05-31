import { defineConfig } from "vite";
import viteReact from "@vitejs/plugin-react";
import { TanStackRouterVite } from "@tanstack/router-plugin/vite";
import { resolve } from "node:path";
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [TanStackRouterVite({ autoCodeSplitting: false }), viteReact(),
    tailwindcss()
  ], // Disable code splitting
  test: {
    globals: true,
    environment: "jsdom",
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
    },
  },
  
  build: {
    target: "es2015",
    outDir: '../priv/static/assets',
    emptyOutDir: false,
    
    rollupOptions: {
      input: './src/main.tsx',
      output: {
        format: "iife",
        name: "NekoAuthApp",
        entryFileNames: "app.js",
        // Force everything into a single file
        manualChunks: undefined,
        inlineDynamicImports: true,
        assetFileNames: (assetInfo) => {
          if (assetInfo.name && assetInfo.name.endsWith(".css")) {
            return "app.css";
          }
          return "[name][extname]";
        },
      },
    },
    cssCodeSplit: false,
    sourcemap: false,
    manifest: false, // Disable manifest for simpler setup
  },
});