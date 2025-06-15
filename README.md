# vanessa-games

Games for Vanessa!

## ⚠️ Vite Config for GitHub Pages

When deploying a Vite app to GitHub Pages from this monorepo, set the `base` option in your `vite.config.ts` to the correct subfolder path:

```
base: '/vanessa-games/<app-folder>/',
```

For example, for the Clausy the Cloud app:

```
base: '/vanessa-games/clausy-the-cloud/'
```

This ensures assets load correctly at `https://<user>.github.io/vanessa-games/<app-folder>/`.

## Getting Started

This repository is set up as a pnpm workspace to manage one or more web apps.

### Prerequisites

- [Node.js](https://nodejs.org/) (>=16)
- [pnpm](https://pnpm.io/) (install via `npm install -g pnpm`)

### Install dependencies

```bash
pnpm install
```

### Running the first app (Clausy the Cloud)

```bash
pnpm --filter clausy-the-cloud dev
```

The source for the game lives in `apps/clausy-the-cloud`.

## Linting

To check code quality and catch errors, run:

```bash
pnpm lint
```

To automatically fix lint issues, run:

```bash
pnpm lint:fix
```

## Building Clausy the Cloud for Production Hosting

To build the Clausy the Cloud app for deployment:

```bash
pnpm --filter clausy-the-cloud build
```

The production-ready files will be generated in `apps/clausy-the-cloud/dist/`.

You can then deploy the contents of the `dist` folder to any static hosting provider (e.g., Vercel, Netlify, GitHub Pages, Firebase Hosting, etc.).
