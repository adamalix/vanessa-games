# Vanessa Games

A hybrid monorepo containing fun games for Vanessa, available as both web and iOS applications!

## 🎮 Current Games

- **Clausy the Cloud**: A 2D game where you control a cloud to water plants
  - Web version: React + TypeScript + Canvas
  - iOS version: SwiftUI + Swift 6.1

## 🚀 Quick Setup

Run the automated setup script to get everything configured:

```bash
./scripts/setup.sh
```

This script will:

- Install development tools via mise
- Install project dependencies via pnpm
- Set up pre-commit hooks for code quality

## 📋 Prerequisites

### For Web Development

- [mise](https://mise.jdx.dev/) - Development tool manager
- [Node.js](https://nodejs.org/) (>=18) - Installed via mise
- [pnpm](https://pnpm.io/) - Package manager

### For iOS Development

- macOS with Xcode 15.0+
- [mise](https://mise.jdx.dev/) - Development tool manager
- All iOS tools are managed via mise (SwiftLint, Tuist, Periphery)

### Manual Installation

If you prefer to set up manually:

```bash
# Install mise (if not already installed)
curl https://mise.run | sh

# Install development tools
mise install

# Install project dependencies
pnpm install

# Set up pre-commit hooks
pre-commit install
```

## 🛠️ Development

### Web Apps

```bash
# Start development server for Clausy the Cloud
pnpm --filter clausy-the-cloud dev

# Build all web games
pnpm build

# Build specific game
pnpm --filter clausy-the-cloud build
```

### iOS Apps

```bash
# Generate Xcode workspace (run from repository root)
mise exec -- tuist generate --path VanessaGames

# Build iOS apps
mise exec -- tuist build --path VanessaGames

# Run tests
mise exec -- tuist test --path VanessaGames

# Open in Xcode
open VanessaGames/VanessaGames.xcworkspace
```

## 🔍 Code Quality

### Linting and Formatting

```bash
# Check code quality
pnpm lint

# Auto-fix lint issues
pnpm lint:fix

# Format code
pnpm format

# Check formatting
pnpm format:check
```

### iOS Code Quality

iOS projects use SwiftLint with strict rules configured in `VanessaGames/.swiftlint.yml`:

```bash
# Lint iOS code
./scripts/swiftlint.sh

# Check for unused code
./scripts/periphery.sh
```

## 📦 Building for Production

### Web Games

```bash
# Build all web games
pnpm build

# Build specific game
pnpm --filter clausy-the-cloud build
```

Production files are output to `apps/<game>/dist/` and can be deployed to any static hosting provider.

### iOS Apps

```bash
# Build iOS apps for release
mise exec -- tuist build --path VanessaGames --configuration Release
```

## 🚀 Deployment

### GitHub Pages Deployment

When deploying web apps to GitHub Pages, configure the `base` option in `vite.config.ts`:

```typescript
base: '/vanessa-games/<app-folder>/',
```

Example for Clausy the Cloud:

```typescript
base: '/vanessa-games/clausy-the-cloud/';
```

This ensures assets load correctly at `https://<user>.github.io/vanessa-games/<app-folder>/`.

### iOS App Store

1. Open `VanessaGames.xcworkspace` in Xcode
2. Select your target (e.g., "ClausyTheCloud")
3. Archive and upload via Xcode or use `xcodebuild`

## 🏗️ Project Architecture

This hybrid monorepo supports both web and iOS development:

### Web Apps (pnpm workspace)

- Located in `apps/<game-name>/`
- Built with React + TypeScript + Vite
- Canvas-based games with React UI overlays

### iOS Apps (Tuist workspace)

- Located in `VanessaGames/Games/<GameName>/`
- Built with SwiftUI + Swift 6.1
- Shared frameworks: `SharedGameEngine`, `SharedAssets`
- Minimum iOS 18.0, optimized for iPad

## 🛠️ Troubleshooting

### Common Issues

**mise command not found**

```bash
curl https://mise.run | sh
# Restart your shell, then run: mise install
```

**pnpm command not found**

```bash
npm install -g pnpm
# Or: curl -fsSL https://get.pnpm.io/install.sh | sh -
```

**Xcode build errors**

```bash
# Clean and regenerate Tuist workspace
cd VanessaGames
mise exec -- tuist clean
mise exec -- tuist generate
```

**Pre-commit hooks failing**

```bash
# Update and reinstall hooks
pre-commit autoupdate
pre-commit install
```

## 📚 More Information

- See `CLAUDE.md` for detailed development instructions
- iOS development uses Swift Testing (not XCTest)
- Web games support touch controls and keyboard input
- All tools are version-managed via mise (see `.mise.toml`)
