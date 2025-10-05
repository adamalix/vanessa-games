---
allowed-tools: Bash(mise exec*)
---

# Context

# OLD COMMAND:

# `mise exec -- tuist test --path VanessaGames ClausyTheCloud --no-selective-testing --device "iPhone 16 Pro" --os "18.6"`

This runs the snapshot tests for the project:

`mise exec -- tuist test --path VanessaGames/ --no-selective-testing -- -destination 'platform=iOS Simulator,OS=26.0,name=iPhone 17 Pro'`
