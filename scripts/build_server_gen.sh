#!/bin/bash

# This script will install dependencies & generate the workspace. It then creates a
# build server configuration for the workspace, which enables editors other than
# Xcode to provide code completion etc via the swift language server.
WORKSPACE_PATH="VanessaGames"
tuist install --path $WORKSPACE_PATH && \
    tuist generate --path $WORKSPACE_PATH --no-open && \
    xcode-build-server config -scheme ClausyTheCloud -workspace $WORKSPACE_PATH/VanessaGames.xcworkspace
