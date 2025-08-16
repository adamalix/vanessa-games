#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the repository root (parent of scripts directory)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
# SwiftLint config is in VanessaGames subdirectory
VANESSA_DIR="$REPO_ROOT/VanessaGames"

cd "$VANESSA_DIR" && $HOME/.local/bin/mise exec -- swiftlint --fix && $HOME/.local/bin/mise exec -- swiftlint --strict
