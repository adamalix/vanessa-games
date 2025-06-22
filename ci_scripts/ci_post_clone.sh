#!/bin/sh

# Install dependencies needed for our build tools
brew install zstd
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

# Install tools from .mise.toml in repo root
cd "$CI_PRIMARY_REPOSITORY_PATH"
mise install
eval "$(mise activate bash --shims)"

# Navigate to VanessaGames directory and generate Xcode project
cd "$CI_PRIMARY_REPOSITORY_PATH/VanessaGames"
tuist install
tuist generate --no-open
