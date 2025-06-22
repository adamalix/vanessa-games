#!/bin/bash

# Vanessa Games Repository Setup Script
# This script initializes the development environment for the repository

set -e  # Exit on any error

echo "🎮 Setting up Vanessa Games repository..."

# Check if mise is installed
if ! command -v mise &> /dev/null; then
    echo "❌ mise is not installed. Please install mise first:"
    echo "   curl https://mise.run | sh"
    echo "   Then restart your shell and run this script again."
    exit 1
fi

# Install tools via mise
echo "📦 Installing development tools via mise..."
mise install

# Check if pnpm is available (either from mise or system)
if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm is not available. Please install pnpm:"
    echo "   npm install -g pnpm"
    echo "   or"
    echo "   curl -fsSL https://get.pnpm.io/install.sh | sh -"
    exit 1
fi

# Install dependencies
echo "📦 Installing project dependencies..."
pnpm install

# Setup pre-commit hooks
echo "🔧 Setting up pre-commit hooks..."
if command -v pre-commit &> /dev/null; then
    pre-commit install
    echo "✅ Pre-commit hooks installed successfully"
else
    echo "⚠️  pre-commit not found. Run 'mise install' to install it."
fi

# Verify setup
echo ""
echo "🔍 Verifying setup..."

# Check mise tools
echo "📋 Installed mise tools:"
mise list

# Check pnpm workspaces
echo ""
echo "📋 Available pnpm workspaces:"
pnpm list --depth=0 2>/dev/null || echo "   (Run from individual app directories for app-specific dependencies)"

echo ""
echo "✅ Repository setup complete!"
echo ""
echo "🚀 Quick start:"
echo "   • Start Clausy the Cloud: pnpm --filter clausy-the-cloud dev"
echo "   • Build all games: pnpm build"
echo "   • Lint code: pnpm lint"
echo "   • Format code: pnpm format"
echo ""
echo "📚 See CLAUDE.md for detailed development instructions"
