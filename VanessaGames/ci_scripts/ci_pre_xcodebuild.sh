#!/bin/sh

export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash --shims)"

# Debug snapshot testing environment (helps troubleshoot CI issues)
if [[ -f "$CI_PRIMARY_REPOSITORY_PATH/VanessaGames/ci_scripts/debug_snapshot_environment.sh" ]]; then
    echo "🔍 Running snapshot environment debug..."
    "$CI_PRIMARY_REPOSITORY_PATH/VanessaGames/ci_scripts/debug_snapshot_environment.sh"
else
    echo "⚠️  Debug script not found, skipping environment debug"
fi

# Run SwiftLint on the VanessaGames directory
if [[ -n "$CI_PRIMARY_REPOSITORY_PATH" ]]; then
    swiftlint --strict "$CI_PRIMARY_REPOSITORY_PATH/VanessaGames" --config "$CI_PRIMARY_REPOSITORY_PATH/VanessaGames/.swiftlint.yml"
else
    echo "CI_PRIMARY_REPOSITORY_PATH is not set. Skipping linting."
fi
