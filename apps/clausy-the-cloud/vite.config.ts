import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  base: '/vanessa-games/clausy-the-cloud/', // Correct base for GitHub Pages deployment
  plugins: [react()],
});
