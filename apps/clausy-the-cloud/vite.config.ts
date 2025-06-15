import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  base: '/clausy-the-cloud/', // Set base for GitHub Pages subfolder deployment
  plugins: [react()],
});
