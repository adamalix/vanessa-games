# vanessa-games

Games for Vanessa!

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
