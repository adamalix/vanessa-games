#!/bin/sh

export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash --shims)"

# Run SwiftLint on the VanessaGames directory
if [[ -n "$CI_PRIMARY_REPOSITORY_PATH" ]]; then
    swiftlint --strict "$CI_PRIMARY_REPOSITORY_PATH/VanessaGames"
else
    echo "CI_PRIMARY_REPOSITORY_PATH is not set. Skipping linting."
fi
